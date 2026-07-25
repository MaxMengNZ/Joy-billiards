-- Auto queue: the website stays the source of truth for ordering, and the
-- server drip-feeds requests into Spotify so Pro Max priority still applies to
-- everything still waiting. Admins can fall back to manual approval any time.

CREATE TABLE IF NOT EXISTS public.song_queue_settings (
  id integer PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  auto_queue_enabled boolean NOT NULL DEFAULT true,
  auto_queue_buffer integer NOT NULL DEFAULT 1 CHECK (auto_queue_buffer BETWEEN 1 AND 5),
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by uuid REFERENCES public.users(id) ON DELETE SET NULL
);

INSERT INTO public.song_queue_settings (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

ALTER TABLE public.song_queue_settings ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.song_queue_settings FROM PUBLIC, anon, authenticated;
GRANT ALL ON TABLE public.song_queue_settings TO service_role;

-- Tracks which pending requests we've already handed to Spotify.
ALTER TABLE public.song_requests
  ADD COLUMN IF NOT EXISTS pushed_to_spotify_at timestamptz;

CREATE INDEX IF NOT EXISTS song_requests_pending_push_idx
  ON public.song_requests (status, is_priority DESC, created_at)
  WHERE status = 'pending';

CREATE OR REPLACE FUNCTION public.get_song_queue_settings()
RETURNS json
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  v_row public.song_queue_settings%ROWTYPE;
BEGIN
  SELECT * INTO v_row FROM public.song_queue_settings WHERE id = 1;
  IF NOT FOUND THEN
    RETURN json_build_object('auto_queue_enabled', true, 'auto_queue_buffer', 1);
  END IF;
  RETURN json_build_object(
    'auto_queue_enabled', v_row.auto_queue_enabled,
    'auto_queue_buffer', v_row.auto_queue_buffer,
    'updated_at', v_row.updated_at
  );
END;
$$;

REVOKE ALL ON FUNCTION public.get_song_queue_settings() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_song_queue_settings() TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.admin_set_song_auto_queue(p_enabled boolean)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  v_admin_id uuid;
  v_row public.song_queue_settings%ROWTYPE;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Admin access required';
  END IF;

  SELECT id INTO v_admin_id FROM public.users WHERE auth_id = auth.uid() LIMIT 1;

  UPDATE public.song_queue_settings
  SET auto_queue_enabled = COALESCE(p_enabled, true),
      updated_at = now(),
      updated_by = v_admin_id
  WHERE id = 1
  RETURNING * INTO v_row;

  RETURN json_build_object(
    'success', true,
    'auto_queue_enabled', v_row.auto_queue_enabled,
    'auto_queue_buffer', v_row.auto_queue_buffer
  );
END;
$$;

REVOKE ALL ON FUNCTION public.admin_set_song_auto_queue(boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_set_song_auto_queue(boolean) TO authenticated;
