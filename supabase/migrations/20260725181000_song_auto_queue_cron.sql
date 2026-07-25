-- Server-side ticker so auto-queue keeps working with no browser open.
-- Uses the public anon key (already shipped in the frontend bundle), not the
-- service role key, and stays idle when nothing is pending or playing.

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Vault secrets are seeded per-environment, e.g.:
--   SELECT vault.create_secret('https://<ref>.supabase.co', 'song_sync_project_url', '');
--   SELECT vault.create_secret('<anon key>', 'song_sync_anon_key', '');

CREATE OR REPLACE FUNCTION public.run_song_queue_sync()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'extensions', 'vault', 'pg_temp'
AS $$
DECLARE
  v_url text;
  v_key text;
  v_has_work boolean;
BEGIN
  -- Stay idle (and off Spotify's rate limit) when nothing is queued or playing.
  SELECT EXISTS (
    SELECT 1 FROM public.song_requests WHERE status IN ('pending', 'playing')
  ) INTO v_has_work;

  IF NOT v_has_work THEN
    RETURN;
  END IF;

  SELECT decrypted_secret INTO v_url
  FROM vault.decrypted_secrets WHERE name = 'song_sync_project_url';

  SELECT decrypted_secret INTO v_key
  FROM vault.decrypted_secrets WHERE name = 'song_sync_anon_key';

  IF v_url IS NULL OR v_key IS NULL THEN
    RETURN;
  END IF;

  PERFORM net.http_post(
    url := v_url || '/functions/v1/spotify-sync-playback',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || v_key
    ),
    body := jsonb_build_object('force', true),
    timeout_milliseconds := 15000
  );
END;
$$;

REVOKE ALL ON FUNCTION public.run_song_queue_sync() FROM PUBLIC, anon, authenticated;

SELECT cron.unschedule('song-queue-sync') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'song-queue-sync'
);

SELECT cron.schedule(
  'song-queue-sync',
  '30 seconds',
  $cron$SELECT public.run_song_queue_sync();$cron$
);
