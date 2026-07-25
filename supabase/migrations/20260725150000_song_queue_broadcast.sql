-- Realtime for everyone (including logged-out guests) without exposing song_requests.
--
-- `anon` has no SELECT grant on song_requests, so postgres_changes never reaches
-- guests. Instead we broadcast a contentless "queue changed" ping on a public
-- Realtime topic; clients then re-read the queue through the sanitized
-- get_live_song_queue() RPC.

create or replace function public.broadcast_song_queue_change()
returns trigger
language plpgsql
security definer
set search_path = public, realtime
as $$
begin
  -- Never let a broadcast failure roll back the song request itself.
  begin
    perform realtime.send(
      jsonb_build_object(
        'op', tg_op,
        'at', now()
      ),
      'queue_changed',
      'song_queue_public',
      false
    );
  exception
    when others then
      null;
  end;

  return null;
end;
$$;

-- Trigger-only: never reachable through PostgREST /rpc.
revoke execute on function public.broadcast_song_queue_change() from anon, authenticated, public;

drop trigger if exists song_requests_broadcast_change on public.song_requests;

create trigger song_requests_broadcast_change
after insert or update or delete on public.song_requests
for each row
execute function public.broadcast_song_queue_change();
