-- Spotify member song queue: table, RPCs, RLS.
-- Priority quota for Pro Max: 5 per calendar day in Pacific/Auckland.

CREATE TABLE IF NOT EXISTS public.song_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  spotify_track_id text NOT NULL,
  track_name text NOT NULL,
  artist_name text NOT NULL,
  album_name text,
  album_art_url text,
  duration_ms integer,
  preview_url text,
  is_priority boolean NOT NULL DEFAULT false,
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'playing', 'played', 'skipped', 'cancelled')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  played_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_song_requests_queue_order
  ON public.song_requests (status, is_priority DESC, created_at ASC);

CREATE INDEX IF NOT EXISTS idx_song_requests_user_created
  ON public.song_requests (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_song_requests_track_active
  ON public.song_requests (spotify_track_id)
  WHERE status IN ('pending', 'playing');

CREATE OR REPLACE FUNCTION public.set_song_requests_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_song_requests_updated_at ON public.song_requests;
CREATE TRIGGER trg_song_requests_updated_at
  BEFORE UPDATE ON public.song_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.set_song_requests_updated_at();

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.song_requests;
EXCEPTION
  WHEN duplicate_object THEN NULL;
  WHEN undefined_object THEN NULL;
END $$;

ALTER TABLE public.song_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated can view active song queue" ON public.song_requests;
CREATE POLICY "Authenticated can view active song queue"
  ON public.song_requests
  FOR SELECT
  TO authenticated
  USING (
    status IN ('pending', 'playing')
    OR user_id IN (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR public.is_admin()
  );

DROP POLICY IF EXISTS "Admins can update song requests" ON public.song_requests;
CREATE POLICY "Admins can update song requests"
  ON public.song_requests
  FOR UPDATE
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can delete song requests" ON public.song_requests;
CREATE POLICY "Admins can delete song requests"
  ON public.song_requests
  FOR DELETE
  TO authenticated
  USING (public.is_admin());

CREATE OR REPLACE FUNCTION public.get_song_priority_quota()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  v_user public.users%ROWTYPE;
  v_used integer := 0;
  v_limit integer := 5;
  v_nz_today date;
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
      'used', 0,
      'limit', v_limit,
      'remaining', 0
    );
  END IF;

  v_nz_today := (timezone('Pacific/Auckland', now()))::date;

  SELECT COUNT(*)::integer INTO v_used
  FROM public.song_requests
  WHERE user_id = v_user.id
    AND is_priority = true
    AND (timezone('Pacific/Auckland', created_at))::date = v_nz_today
    AND status <> 'cancelled';

  RETURN json_build_object(
    'success', true,
    'is_pro_max', COALESCE(v_user.membership_level, '') = 'pro_max',
    'used', v_used,
    'limit', v_limit,
    'remaining', GREATEST(v_limit - v_used, 0)
  );
END;
$$;

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

CREATE OR REPLACE FUNCTION public.admin_update_song_request_status(
  p_request_id uuid,
  p_status text
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  v_row public.song_requests%ROWTYPE;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Access denied';
  END IF;

  IF p_status NOT IN ('pending', 'playing', 'played', 'skipped', 'cancelled') THEN
    RAISE EXCEPTION 'Invalid status';
  END IF;

  IF p_status = 'playing' THEN
    UPDATE public.song_requests
    SET status = 'played',
        played_at = COALESCE(played_at, now())
    WHERE status = 'playing'
      AND id <> p_request_id;
  END IF;

  UPDATE public.song_requests
  SET status = p_status,
      played_at = CASE
        WHEN p_status IN ('played', 'playing', 'skipped') THEN COALESCE(played_at, now())
        ELSE played_at
      END
  WHERE id = p_request_id
  RETURNING * INTO v_row;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Song request not found';
  END IF;

  RETURN json_build_object('success', true, 'request', row_to_json(v_row));
END;
$$;

CREATE OR REPLACE FUNCTION public.cancel_my_song_request(p_request_id uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  v_user_id uuid;
  v_row public.song_requests%ROWTYPE;
BEGIN
  SELECT id INTO v_user_id FROM public.users WHERE auth_id = auth.uid() LIMIT 1;
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;

  UPDATE public.song_requests
  SET status = 'cancelled'
  WHERE id = p_request_id
    AND user_id = v_user_id
    AND status = 'pending'
  RETURNING * INTO v_row;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Pending request not found or not yours';
  END IF;

  RETURN json_build_object('success', true, 'request', row_to_json(v_row));
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_song_priority_quota() TO authenticated;
GRANT EXECUTE ON FUNCTION public.submit_song_request(text, text, text, text, text, integer, text, boolean) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_update_song_request_status(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.cancel_my_song_request(uuid) TO authenticated;

GRANT SELECT ON public.song_requests TO authenticated;
GRANT UPDATE, DELETE ON public.song_requests TO authenticated;
