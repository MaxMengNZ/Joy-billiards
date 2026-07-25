-- Auto-complete "playing" tracks after their duration so they leave the live queue.

CREATE OR REPLACE FUNCTION public.get_live_song_queue()
RETURNS json
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  v_my_user_id uuid;
  v_result json;
  v_default_ms integer := 240000; -- 4 min fallback when duration unknown
  v_grace_ms integer := 8000;     -- small grace after track end
BEGIN
  -- Finish any track that should already be done
  UPDATE public.song_requests
  SET status = 'played',
      played_at = COALESCE(played_at, now()),
      updated_at = now()
  WHERE status = 'playing'
    AND COALESCE(played_at, created_at) +
        make_interval(secs => (COALESCE(duration_ms, v_default_ms) + v_grace_ms) / 1000.0)
        <= now();

  SELECT id INTO v_my_user_id
  FROM public.users
  WHERE auth_id = auth.uid()
  LIMIT 1;

  WITH ordered AS (
    SELECT
      sr.id,
      sr.track_name,
      sr.artist_name,
      sr.album_name,
      sr.album_art_url,
      sr.duration_ms,
      sr.spotify_track_id,
      sr.status,
      sr.is_priority,
      sr.created_at,
      sr.played_at,
      sr.user_id,
      NULLIF(split_part(trim(COALESCE(u.name, '')), ' ', 1), '') AS requester_first_name,
      CASE
        WHEN v_my_user_id IS NOT NULL AND sr.user_id = v_my_user_id THEN true
        ELSE false
      END AS is_mine
    FROM public.song_requests sr
    LEFT JOIN public.users u ON u.id = sr.user_id
    WHERE sr.status IN ('pending', 'playing')
  ),
  ranked AS (
    SELECT
      o.*,
      CASE
        WHEN o.status = 'playing' THEN 0
        ELSE ROW_NUMBER() OVER (
          PARTITION BY CASE WHEN o.status = 'pending' THEN 1 ELSE 0 END
          ORDER BY o.is_priority DESC, o.created_at ASC
        )
      END AS queue_position
    FROM ordered o
  )
  SELECT COALESCE(
    json_agg(
      json_build_object(
        'id', r.id,
        'track_name', r.track_name,
        'artist_name', r.artist_name,
        'album_name', r.album_name,
        'album_art_url', r.album_art_url,
        'duration_ms', r.duration_ms,
        'spotify_track_id', r.spotify_track_id,
        'status', r.status,
        'is_priority', r.is_priority,
        'created_at', r.created_at,
        'played_at', r.played_at,
        'queue_position', CASE WHEN r.status = 'playing' THEN NULL ELSE r.queue_position END,
        'requester_label', COALESCE(r.requester_first_name, 'Member'),
        'is_mine', r.is_mine
      )
      ORDER BY
        CASE WHEN r.status = 'playing' THEN 0 ELSE 1 END,
        r.is_priority DESC,
        r.created_at ASC
    ),
    '[]'::json
  )
  INTO v_result
  FROM ranked r;

  RETURN v_result;
END;
$$;

REVOKE ALL ON FUNCTION public.get_live_song_queue() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_live_song_queue() TO anon, authenticated;
