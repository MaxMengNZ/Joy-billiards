-- Store the real Spotify upcoming count (after padding collapse), separate from
-- the capped track list we show in the UI (top 30).

ALTER TABLE public.spotify_player_snapshot
  ADD COLUMN IF NOT EXISTS queue_count integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS queue_may_have_more boolean NOT NULL DEFAULT false;

UPDATE public.spotify_player_snapshot
SET queue_count = COALESCE(jsonb_array_length(queue), 0)
WHERE id = 1;

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
      'queue_count', 0,
      'queue_may_have_more', false,
      'is_playing', false,
      'updated_at', NULL
    );
  END IF;

  RETURN json_build_object(
    'currently_playing', v_row.currently_playing,
    'queue', COALESCE(v_row.queue, '[]'::jsonb),
    'queue_count', COALESCE(v_row.queue_count, jsonb_array_length(COALESCE(v_row.queue, '[]'::jsonb))),
    'queue_may_have_more', COALESCE(v_row.queue_may_have_more, false),
    'is_playing', COALESCE(v_row.is_playing, false),
    'updated_at', v_row.updated_at
  );
END;
$$;

REVOKE ALL ON FUNCTION public.get_spotify_player_snapshot() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_spotify_player_snapshot() TO anon, authenticated;
