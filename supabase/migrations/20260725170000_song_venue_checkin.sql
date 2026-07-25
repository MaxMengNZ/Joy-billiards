-- Venue check-in for song queue:
-- Dynamic QR (10 min) → member redeems → 4h presence → required to request songs.
-- Admins always bypass. Live queue remains publicly readable.

CREATE TABLE IF NOT EXISTS public.song_venue_checkin_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  valid_from timestamptz NOT NULL DEFAULT now(),
  valid_until timestamptz NOT NULL,
  created_by uuid REFERENCES public.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT song_venue_checkin_codes_window_chk CHECK (valid_until > valid_from)
);

CREATE INDEX IF NOT EXISTS song_venue_checkin_codes_valid_until_idx
  ON public.song_venue_checkin_codes (valid_until DESC);

CREATE TABLE IF NOT EXISTS public.song_venue_presence (
  user_id uuid PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  checked_in_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  checkin_code_id uuid REFERENCES public.song_venue_checkin_codes(id) ON DELETE SET NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT song_venue_presence_expires_chk CHECK (expires_at > checked_in_at)
);

CREATE INDEX IF NOT EXISTS song_venue_presence_expires_idx
  ON public.song_venue_presence (expires_at);

ALTER TABLE public.song_venue_checkin_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.song_venue_presence ENABLE ROW LEVEL SECURITY;

-- No direct client access; use SECURITY DEFINER RPCs only.
REVOKE ALL ON TABLE public.song_venue_checkin_codes FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.song_venue_presence FROM PUBLIC, anon, authenticated;
GRANT ALL ON TABLE public.song_venue_checkin_codes TO service_role;
GRANT ALL ON TABLE public.song_venue_presence TO service_role;

CREATE OR REPLACE FUNCTION public._song_checkin_code_token()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  v_raw text;
BEGIN
  v_raw := translate(
    encode(gen_random_bytes(18), 'base64'),
    '+/',
    '-_'
  );
  RETURN rtrim(v_raw, '=');
END;
$$;

REVOKE ALL ON FUNCTION public._song_checkin_code_token() FROM PUBLIC;

CREATE OR REPLACE FUNCTION public.has_song_venue_presence()
RETURNS boolean
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  v_user_id uuid;
BEGIN
  IF auth.uid() IS NULL THEN
    RETURN false;
  END IF;

  IF public.is_admin() THEN
    RETURN true;
  END IF;

  SELECT id INTO v_user_id
  FROM public.users
  WHERE auth_id = auth.uid()
  LIMIT 1;

  IF v_user_id IS NULL THEN
    RETURN false;
  END IF;

  RETURN EXISTS (
    SELECT 1
    FROM public.song_venue_presence p
    WHERE p.user_id = v_user_id
      AND p.expires_at > now()
  );
END;
$$;

REVOKE ALL ON FUNCTION public.has_song_venue_presence() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.has_song_venue_presence() TO authenticated;

CREATE OR REPLACE FUNCTION public.get_my_song_venue_presence()
RETURNS json
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  v_user_id uuid;
  v_admin boolean := false;
  v_expires timestamptz;
  v_checked_in timestamptz;
BEGIN
  IF auth.uid() IS NULL THEN
    RETURN json_build_object(
      'present', false,
      'is_admin', false,
      'expires_at', NULL,
      'checked_in_at', NULL
    );
  END IF;

  v_admin := public.is_admin();

  SELECT id INTO v_user_id
  FROM public.users
  WHERE auth_id = auth.uid()
  LIMIT 1;

  IF v_user_id IS NOT NULL THEN
    SELECT p.expires_at, p.checked_in_at
    INTO v_expires, v_checked_in
    FROM public.song_venue_presence p
    WHERE p.user_id = v_user_id
      AND p.expires_at > now();
  END IF;

  IF v_admin THEN
    RETURN json_build_object(
      'present', true,
      'is_admin', true,
      'expires_at', v_expires,
      'checked_in_at', v_checked_in,
      'bypass', true
    );
  END IF;

  RETURN json_build_object(
    'present', v_expires IS NOT NULL,
    'is_admin', false,
    'expires_at', v_expires,
    'checked_in_at', v_checked_in,
    'bypass', false
  );
END;
$$;

REVOKE ALL ON FUNCTION public.get_my_song_venue_presence() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_my_song_venue_presence() TO authenticated;

-- Admin: get current QR code or rotate a new 10-minute code.
CREATE OR REPLACE FUNCTION public.admin_get_song_checkin_qr(p_force_new boolean DEFAULT false)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  v_admin_user_id uuid;
  v_row public.song_venue_checkin_codes%ROWTYPE;
  v_code text;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Admin access required';
  END IF;

  SELECT id INTO v_admin_user_id
  FROM public.users
  WHERE auth_id = auth.uid()
  LIMIT 1;

  IF NOT COALESCE(p_force_new, false) THEN
    SELECT * INTO v_row
    FROM public.song_venue_checkin_codes
    WHERE valid_until > now() + interval '30 seconds'
    ORDER BY valid_until DESC
    LIMIT 1;

    IF FOUND THEN
      RETURN json_build_object(
        'success', true,
        'code', v_row.code,
        'valid_from', v_row.valid_from,
        'valid_until', v_row.valid_until,
        'rotated', false
      );
    END IF;
  END IF;

  -- Expire any still-active codes when forcing a new one.
  UPDATE public.song_venue_checkin_codes
  SET valid_until = now()
  WHERE valid_until > now();

  LOOP
    v_code := public._song_checkin_code_token();
    BEGIN
      INSERT INTO public.song_venue_checkin_codes (code, valid_from, valid_until, created_by)
      VALUES (v_code, now(), now() + interval '10 minutes', v_admin_user_id)
      RETURNING * INTO v_row;
      EXIT;
    EXCEPTION
      WHEN unique_violation THEN
        NULL; -- retry new token
    END;
  END LOOP;

  RETURN json_build_object(
    'success', true,
    'code', v_row.code,
    'valid_from', v_row.valid_from,
    'valid_until', v_row.valid_until,
    'rotated', true
  );
END;
$$;

REVOKE ALL ON FUNCTION public.admin_get_song_checkin_qr(boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_get_song_checkin_qr(boolean) TO authenticated;

CREATE OR REPLACE FUNCTION public.redeem_song_venue_checkin(p_code text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  v_user public.users%ROWTYPE;
  v_code public.song_venue_checkin_codes%ROWTYPE;
  v_expires timestamptz;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF nullif(trim(COALESCE(p_code, '')), '') IS NULL THEN
    RAISE EXCEPTION 'Check-in code required';
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

  IF public.is_admin() THEN
    -- Admins do not need check-in, but still allow a no-op success.
    RETURN json_build_object(
      'success', true,
      'present', true,
      'is_admin', true,
      'bypass', true,
      'expires_at', NULL,
      'message', 'Admin accounts can request songs without venue check-in.'
    );
  END IF;

  IF COALESCE(v_user.membership_level, '') NOT IN ('lite', 'plus', 'pro', 'pro_max') THEN
    RAISE EXCEPTION 'Active membership required to check in for song requests';
  END IF;

  SELECT * INTO v_code
  FROM public.song_venue_checkin_codes
  WHERE code = trim(p_code)
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invalid check-in code. Ask staff for the current venue QR.';
  END IF;

  IF now() < v_code.valid_from OR now() > v_code.valid_until THEN
    RAISE EXCEPTION 'This QR code has expired. Scan the latest code on the venue screen.';
  END IF;

  v_expires := now() + interval '4 hours';

  INSERT INTO public.song_venue_presence (user_id, checked_in_at, expires_at, checkin_code_id, updated_at)
  VALUES (v_user.id, now(), v_expires, v_code.id, now())
  ON CONFLICT (user_id) DO UPDATE
  SET
    checked_in_at = now(),
    expires_at = EXCLUDED.expires_at,
    checkin_code_id = EXCLUDED.checkin_code_id,
    updated_at = now();

  RETURN json_build_object(
    'success', true,
    'present', true,
    'is_admin', false,
    'bypass', false,
    'expires_at', v_expires,
    'checked_in_at', now(),
    'message', 'Checked in. You can request songs for the next 4 hours.'
  );
END;
$$;

REVOKE ALL ON FUNCTION public.redeem_song_venue_checkin(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.redeem_song_venue_checkin(text) TO authenticated;

-- Gate song requests on venue presence (admins exempt).
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
  v_priority_used integer;
  v_priority_limit integer := 5;
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

  -- Venue presence required for non-admins on every request.
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

  v_nz_today := (timezone('Pacific/Auckland', now()))::date;

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
    -- Priority also requires venue presence (already enforced above for non-admins).
    IF v_priority_used >= v_priority_limit THEN
      RAISE EXCEPTION 'Daily priority limit reached (5). You can still use the normal queue.';
    END IF;
  END IF;

  INSERT INTO public.song_requests (
    user_id,
    spotify_track_id,
    track_name,
    artist_name,
    album_name,
    album_art_url,
    duration_ms,
    preview_url,
    is_priority,
    status
  ) VALUES (
    v_user.id,
    trim(p_spotify_track_id),
    trim(p_track_name),
    trim(p_artist_name),
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
    'is_priority', v_want_priority
  );
END;
$$;

REVOKE ALL ON FUNCTION public.submit_song_request(text, text, text, text, text, integer, text, boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_song_request(text, text, text, text, text, integer, text, boolean) TO authenticated;
