-- Public snapshot of venue Spotify currently-playing + queue (sanitized track fields only).

CREATE TABLE IF NOT EXISTS public.spotify_player_snapshot (
  id integer PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  currently_playing jsonb,
  queue jsonb NOT NULL DEFAULT '[]'::jsonb,
  is_playing boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO public.spotify_player_snapshot (id, currently_playing, queue, is_playing)
VALUES (1, NULL, '[]'::jsonb, false)
ON CONFLICT (id) DO NOTHING;

ALTER TABLE public.spotify_player_snapshot ENABLE ROW LEVEL SECURITY;

-- No direct table access for clients; read via RPC only
DROP POLICY IF EXISTS "No direct select on spotify_player_snapshot" ON public.spotify_player_snapshot;

CREATE OR REPLACE FUNCTION public.get_spotify_player_snapshot()
RETURNS json
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  v_row public.spotify_player_snapshot%ROWTYPE;
BEGIN
  SELECT * INTO v_row FROM public.spotify_player_snapshot WHERE id = 1;
  IF NOT FOUND THEN
    RETURN json_build_object(
      'currently_playing', NULL,
      'queue', '[]'::json,
      'is_playing', false,
      'updated_at', NULL
    );
  END IF;

  RETURN json_build_object(
    'currently_playing', v_row.currently_playing,
    'queue', COALESCE(v_row.queue, '[]'::jsonb),
    'is_playing', COALESCE(v_row.is_playing, false),
    'updated_at', v_row.updated_at
  );
END;
$$;

REVOKE ALL ON FUNCTION public.get_spotify_player_snapshot() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_spotify_player_snapshot() TO anon, authenticated;
