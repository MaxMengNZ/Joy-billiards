-- Daily song request quotas by membership tier.
-- Lite 3 / Plus 5 / Pro 7 / Pro Max 15 (of which up to 10 may be priority).

CREATE OR REPLACE FUNCTION public._song_daily_limits(p_level text)
RETURNS TABLE (daily_limit integer, priority_limit integer)
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT
    CASE COALESCE(p_level, 'lite')
      WHEN 'plus' THEN 5
      WHEN 'pro' THEN 7
      WHEN 'pro_max' THEN 15
      ELSE 3
    END,
    CASE COALESCE(p_level, 'lite')
      WHEN 'pro_max' THEN 10
      ELSE 0
    END;
$$;

REVOKE ALL ON FUNCTION public._song_daily_limits(text) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.get_song_priority_quota()
RETURNS json
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  v_user public.users%ROWTYPE;
  v_nz_today date;
  v_daily_used integer := 0;
  v_priority_used integer := 0;
  v_daily_limit integer := 3;
  v_priority_limit integer := 0;
BEGIN
  SELECT * INTO v_user
  FROM public.users
  WHERE auth_id = auth.uid()
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Profile not found',
      'is_pro_max', false,
      'membership_level', null,
      'used', 0,
      'limit', 0,
      'remaining', 0,
      'priority_used', 0,
      'priority_limit', 0,
      'priority_remaining', 0,
      'daily_used', 0,
      'daily_limit', 0,
      'daily_remaining', 0
    );
  END IF;

  SELECT d.daily_limit, d.priority_limit
  INTO v_daily_limit, v_priority_limit
  FROM public._song_daily_limits(v_user.membership_level) d;

  v_nz_today := (timezone('Pacific/Auckland', now()))::date;

  SELECT COUNT(*)::integer INTO v_daily_used
  FROM public.song_requests
  WHERE user_id = v_user.id
    AND (timezone('Pacific/Auckland', created_at))::date = v_nz_today
    AND status <> 'cancelled';

  SELECT COUNT(*)::integer INTO v_priority_used
  FROM public.song_requests
  WHERE user_id = v_user.id
    AND is_priority = true
    AND (timezone('Pacific/Auckland', created_at))::date = v_nz_today
    AND status <> 'cancelled';

  RETURN json_build_object(
    'success', true,
    'is_pro_max', COALESCE(v_user.membership_level, '') = 'pro_max',
    'membership_level', v_user.membership_level,
    'used', v_priority_used,
    'limit', v_priority_limit,
    'remaining', GREATEST(v_priority_limit - v_priority_used, 0),
    'priority_used', v_priority_used,
    'priority_limit', v_priority_limit,
    'priority_remaining', GREATEST(v_priority_limit - v_priority_used, 0),
    'daily_used', v_daily_used,
    'daily_limit', v_daily_limit,
    'daily_remaining', GREATEST(v_daily_limit - v_daily_used, 0)
  );
END;
$$;

REVOKE ALL ON FUNCTION public.get_song_priority_quota() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_song_priority_quota() TO authenticated;

CREATE OR REPLACE FUNCTION public.submit_song_request(
  p_spotify_track_id text,
  p_track_name text,
  p_artist_name text,
  p_album_name text DEFAULT NULL,
  p_album_art_url text DEFAULT NULL,
  p_duration_ms integer DEFAULT NULL,
  p_preview_url text DEFAULT NULL,
  p_is_priority boolean DEFAULT false
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  v_user public.users%ROWTYPE;
  v_pending_count integer;
  v_daily_used integer;
  v_priority_used integer;
  v_daily_limit integer := 3;
  v_priority_limit integer := 0;
  v_nz_today date;
  v_row public.song_requests%ROWTYPE;
  v_ahead integer;
  v_want_priority boolean := COALESCE(p_is_priority, false);
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF nullif(trim(p_spotify_track_id), '') IS NULL
     OR nullif(trim(p_track_name), '') IS NULL
     OR nullif(trim(p_artist_name), '') IS NULL THEN
    RAISE EXCEPTION 'Track details are required';
  END IF;

  SELECT * INTO v_user
  FROM public.users
  WHERE auth_id = auth.uid()
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;

  IF COALESCE(v_user.is_active, true) = false THEN
    RAISE EXCEPTION 'Account is deactivated';
  END IF;

  IF COALESCE(v_user.membership_level, '') NOT IN ('lite', 'plus', 'pro', 'pro_max') THEN
    RAISE EXCEPTION 'Active membership required';
  END IF;

  IF NOT public.is_admin() THEN
    IF NOT EXISTS (
      SELECT 1
      FROM public.song_venue_presence p
      WHERE p.user_id = v_user.id
        AND p.expires_at > now()
    ) THEN
      RAISE EXCEPTION 'Venue check-in required. Scan the QR code at Joy Billiards to request songs.';
    END IF;
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.song_requests
    WHERE spotify_track_id = trim(p_spotify_track_id)
      AND status IN ('pending', 'playing')
  ) THEN
    RAISE EXCEPTION 'This song is already in the queue';
  END IF;

  SELECT COUNT(*)::integer INTO v_pending_count
  FROM public.song_requests
  WHERE user_id = v_user.id
    AND status = 'pending';

  IF v_pending_count >= 3 THEN
    RAISE EXCEPTION 'You already have 3 songs pending. Wait until one is played.';
  END IF;

  SELECT d.daily_limit, d.priority_limit
  INTO v_daily_limit, v_priority_limit
  FROM public._song_daily_limits(v_user.membership_level) d;

  v_nz_today := (timezone('Pacific/Auckland', now()))::date;

  SELECT COUNT(*)::integer INTO v_daily_used
  FROM public.song_requests
  WHERE user_id = v_user.id
    AND (timezone('Pacific/Auckland', created_at))::date = v_nz_today
    AND status <> 'cancelled';

  IF v_daily_used >= v_daily_limit THEN
    RAISE EXCEPTION 'Daily song request limit reached (%). Come back tomorrow or upgrade your membership.', v_daily_limit;
  END IF;

  SELECT COUNT(*)::integer INTO v_priority_used
  FROM public.song_requests
  WHERE user_id = v_user.id
    AND is_priority = true
    AND (timezone('Pacific/Auckland', created_at))::date = v_nz_today
    AND status <> 'cancelled';

  IF v_want_priority THEN
    IF COALESCE(v_user.membership_level, '') <> 'pro_max' THEN
      RAISE EXCEPTION 'Priority queue is for Pro Max members only';
    END IF;
    IF v_priority_used >= v_priority_limit THEN
      RAISE EXCEPTION 'Daily priority limit reached (%). You can still use the normal queue.', v_priority_limit;
    END IF;
  END IF;

  INSERT INTO public.song_requests (
    user_id, spotify_track_id, track_name, artist_name, album_name,
    album_art_url, duration_ms, preview_url, is_priority, status
  ) VALUES (
    v_user.id, trim(p_spotify_track_id), trim(p_track_name), trim(p_artist_name),
    nullif(trim(COALESCE(p_album_name, '')), ''),
    nullif(trim(COALESCE(p_album_art_url, '')), ''),
    p_duration_ms,
    nullif(trim(COALESCE(p_preview_url, '')), ''),
    v_want_priority,
    'pending'
  )
  RETURNING * INTO v_row;

  SELECT COUNT(*)::integer INTO v_ahead
  FROM public.song_requests sr
  WHERE sr.status = 'pending'
    AND sr.id <> v_row.id
    AND (
      (sr.is_priority > v_row.is_priority)
      OR (sr.is_priority = v_row.is_priority AND sr.created_at < v_row.created_at)
    );

  RETURN json_build_object(
    'success', true,
    'request', row_to_json(v_row),
    'queue_position_estimate', v_ahead + 1,
    'priority_left_today', CASE
      WHEN COALESCE(v_user.membership_level, '') = 'pro_max'
        THEN GREATEST(v_priority_limit - v_priority_used - CASE WHEN v_want_priority THEN 1 ELSE 0 END, 0)
      ELSE 0
    END,
    'daily_left_today', GREATEST(v_daily_limit - v_daily_used - 1, 0),
    'daily_limit', v_daily_limit,
    'is_priority', v_want_priority
  );
END;
$$;

REVOKE ALL ON FUNCTION public.submit_song_request(text, text, text, text, text, integer, text, boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_song_request(text, text, text, text, text, integer, text, boolean) TO authenticated;
