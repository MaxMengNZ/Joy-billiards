import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const MIN_SYNC_INTERVAL_MS = 8000;
/** Spotify's /me/player/queue endpoint is hard-capped around this size. */
const SPOTIFY_QUEUE_API_CAP = 20;
/** How many upcoming tracks we keep for the website list. */
const QUEUE_DISPLAY_LIMIT = 30;
/** Re-offer a pushed track if Spotify never played it (queue cleared, device swap). */
const PUSH_STALE_MS = 45 * 60 * 1000;

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function mapTrack(item: Record<string, unknown> | null | undefined) {
  if (!item || typeof item !== "object") return null;
  const album = item.album as { name?: string; images?: Array<{ url?: string }> } | undefined;
  const artists = (item.artists as Array<{ name: string }> | undefined) || [];
  return {
    spotify_track_id: (item.id as string) || null,
    track_name: (item.name as string) || null,
    artist_name: artists.map((a) => a.name).filter(Boolean).join(", ") || null,
    album_name: album?.name || null,
    album_art_url: album?.images?.[0]?.url || null,
    duration_ms: typeof item.duration_ms === "number" ? item.duration_ms : null,
  };
}

/**
 * Spotify often pads /me/player/queue up to ~20 by repeating the real queue
 * (e.g. [A,B,C,A,B,C,...]). Collapse that padding so the count is real.
 */
function collapseQueuePadding(
  tracks: Array<Record<string, unknown>>,
): Array<Record<string, unknown>> {
  if (tracks.length <= 1) return tracks;
  const key = (t: Record<string, unknown>) =>
    String(t.spotify_track_id || `${t.track_name || ""}\0${t.artist_name || ""}`);
  const n = tracks.length;
  for (let p = 1; p <= Math.floor(n / 2); p++) {
    let ok = true;
    for (let i = 0; i < n; i++) {
      if (key(tracks[i]) !== key(tracks[i % p])) {
        ok = false;
        break;
      }
    }
    if (ok) return tracks.slice(0, p);
  }
  return tracks;
}

async function refreshVenueAccessToken() {
  const clientId = Deno.env.get("SPOTIFY_CLIENT_ID");
  const clientSecret = Deno.env.get("SPOTIFY_CLIENT_SECRET");
  const refreshToken = Deno.env.get("SPOTIFY_REFRESH_TOKEN");
  if (!clientId || !clientSecret || !refreshToken) return null;

  const basic = btoa(`${clientId}:${clientSecret}`);
  const res = await fetch("https://accounts.spotify.com/api/token", {
    method: "POST",
    headers: {
      Authorization: `Basic ${basic}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "refresh_token",
      refresh_token: refreshToken,
    }),
  });
  if (!res.ok) return null;
  const data = await res.json();
  return (data.access_token as string) || null;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const { data: existing } = await adminClient
      .from("spotify_player_snapshot")
      .select("currently_playing, queue, is_playing, updated_at, queue_count, queue_may_have_more")
      .eq("id", 1)
      .maybeSingle();

    const updatedAt = existing?.updated_at ? new Date(existing.updated_at).getTime() : 0;
    let bodyForce = false;
    if (req.method === "POST") {
      const body = await req.json().catch(() => ({}));
      bodyForce = !!body?.force;
    }

    if (!bodyForce && existing && Date.now() - updatedAt < MIN_SYNC_INTERVAL_MS) {
      const cp = existing.currently_playing as Record<string, unknown> | null;
      const cachedQueue = Array.isArray(existing.queue) ? existing.queue : [];
      return json({
        success: true,
        cached: true,
        spotify: {
          track_id: (cp?.spotify_track_id as string) || null,
          track_name: (cp?.track_name as string) || null,
          artist_name: (cp?.artist_name as string) || null,
          is_playing: !!existing.is_playing,
          progress_ms: (cp?.progress_ms as number) ?? null,
          duration_ms: (cp?.duration_ms as number) ?? null,
        },
        currently_playing: existing.currently_playing,
        queue: cachedQueue,
        queue_count: existing.queue_count ?? cachedQueue.length,
        queue_may_have_more: !!existing.queue_may_have_more,
        is_playing: !!existing.is_playing,
        updated_at: existing.updated_at,
        changes: [],
      });
    }

    const accessToken = await refreshVenueAccessToken();
    if (!accessToken) {
      const cachedQueue = Array.isArray(existing?.queue) ? existing.queue : [];
      return json({
        success: false,
        skipped: true,
        message: "Spotify venue token not configured.",
        currently_playing: existing?.currently_playing ?? null,
        queue: cachedQueue,
        queue_count: existing?.queue_count ?? cachedQueue.length,
        queue_may_have_more: !!existing?.queue_may_have_more,
        is_playing: false,
      });
    }

    const [nowRes, queueRes] = await Promise.all([
      fetch("https://api.spotify.com/v1/me/player/currently-playing", {
        headers: { Authorization: `Bearer ${accessToken}` },
      }),
      fetch("https://api.spotify.com/v1/me/player/queue", {
        headers: { Authorization: `Bearer ${accessToken}` },
      }),
    ]);

    let currentlyPlaying: Record<string, unknown> | null = null;
    let isPlaying = false;
    let progressMs: number | null = null;

    if (nowRes.status === 200) {
      const data = await nowRes.json();
      const mapped = mapTrack(data?.item);
      isPlaying = !!data?.is_playing;
      progressMs = typeof data?.progress_ms === "number" ? data.progress_ms : null;
      currentlyPlaying = mapped
        ? { ...mapped, progress_ms: progressMs, is_playing: isPlaying }
        : null;
    }

    let queueTracks: Array<Record<string, unknown>> = [];
    let queueCount = 0;
    let queueMayHaveMore = false;
    let queueCurrently = currentlyPlaying;

    if (queueRes.ok) {
      const qData = await queueRes.json();
      if (!queueCurrently && qData?.currently_playing) {
        queueCurrently = mapTrack(qData.currently_playing);
        if (queueCurrently) {
          currentlyPlaying = {
            ...queueCurrently,
            progress_ms: progressMs,
            is_playing: isPlaying,
          };
        }
      }
      const rawQueue = ((qData?.queue as unknown[]) || [])
        .map((t) => mapTrack(t as Record<string, unknown>))
        .filter(Boolean) as Array<Record<string, unknown>>;
      const collapsed = collapseQueuePadding(rawQueue);
      // Spotify hard-caps around 20; if we still have a full page after
      // collapsing padding, the real queue may be longer than we can see.
      queueMayHaveMore = rawQueue.length >= SPOTIFY_QUEUE_API_CAP &&
        collapsed.length >= SPOTIFY_QUEUE_API_CAP;
      queueTracks = collapsed.slice(0, QUEUE_DISPLAY_LIMIT);
    }

    const changes: string[] = [];
    const playingTrackId = (currentlyPlaying?.spotify_track_id as string) || null;

    // Spotify often leaves already-played tracks (or radio suggestions) in
    // /me/player/queue. Hide anything the website already finished, unless a
    // guest has re-requested the same track and it's pending/playing again.
    {
      const sinceIso = new Date(Date.now() - 12 * 60 * 60 * 1000).toISOString();
      const [{ data: finishedRows }, { data: activeRows }] = await Promise.all([
        adminClient
          .from("song_requests")
          .select("spotify_track_id")
          .in("status", ["played", "skipped", "cancelled"])
          .gte("updated_at", sinceIso),
        adminClient
          .from("song_requests")
          .select("spotify_track_id")
          .in("status", ["pending", "playing"]),
      ]);

      const activeIds = new Set(
        (activeRows || [])
          .map((r) => r.spotify_track_id as string | null)
          .filter(Boolean) as string[],
      );
      const hideIds = new Set(
        (finishedRows || [])
          .map((r) => r.spotify_track_id as string | null)
          .filter((id): id is string => !!id && !activeIds.has(id)),
      );
      if (playingTrackId) hideIds.add(playingTrackId);

      if (hideIds.size && queueTracks.length) {
        const before = queueTracks.length;
        queueTracks = queueTracks.filter(
          (t) => !hideIds.has(String(t.spotify_track_id || "")),
        );
        if (queueTracks.length !== before) {
          changes.push(`filtered_stale_queue:${before - queueTracks.length}`);
        }
      }
      queueCount = queueTracks.length;
      if (queueTracks.length < QUEUE_DISPLAY_LIMIT) {
        queueMayHaveMore = false;
      }
    }

    const { data: playingRow } = await adminClient
      .from("song_requests")
      .select("id, spotify_track_id")
      .eq("status", "playing")
      .maybeSingle();

    if (playingRow) {
      const stillPlayingSame =
        playingTrackId &&
        playingTrackId === playingRow.spotify_track_id &&
        isPlaying;

      if (!stillPlayingSame) {
        await adminClient
          .from("song_requests")
          .update({
            status: "played",
            played_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          })
          .eq("id", playingRow.id)
          .eq("status", "playing");
        changes.push(`completed:${playingRow.id}`);
      }
    }

    if (playingTrackId && isPlaying) {
      const { data: pendingMatch } = await adminClient
        .from("song_requests")
        .select("id")
        .eq("status", "pending")
        .eq("spotify_track_id", playingTrackId)
        .order("created_at", { ascending: true })
        .limit(1)
        .maybeSingle();

      if (pendingMatch) {
        await adminClient
          .from("song_requests")
          .update({
            status: "played",
            played_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          })
          .eq("status", "playing")
          .neq("id", pendingMatch.id);

        await adminClient
          .from("song_requests")
          .update({
            status: "playing",
            played_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          })
          .eq("id", pendingMatch.id)
          .eq("status", "pending");
        changes.push(`promoted:${pendingMatch.id}`);
      }
    }

    // Auto drip-feed: keep a small buffer of website requests inside Spotify so
    // priority ordering still applies to everything still waiting on the site.
    let autoQueued: string[] = [];
    let autoEnabled = false;

    {
      const { data: settings } = await adminClient
        .from("song_queue_settings")
        .select("auto_queue_enabled, auto_queue_buffer")
        .eq("id", 1)
        .maybeSingle();

      autoEnabled = settings?.auto_queue_enabled !== false;
      const buffer = Math.max(1, Math.min(5, settings?.auto_queue_buffer ?? 1));

      if (autoEnabled) {
        // Release tracks Spotify never played so they can be offered again.
        await adminClient
          .from("song_requests")
          .update({ pushed_to_spotify_at: null })
          .eq("status", "pending")
          .not("pushed_to_spotify_at", "is", null)
          .lt("pushed_to_spotify_at", new Date(Date.now() - PUSH_STALE_MS).toISOString());

        const { count: inFlight } = await adminClient
          .from("song_requests")
          .select("id", { count: "exact", head: true })
          .eq("status", "pending")
          .not("pushed_to_spotify_at", "is", null);

        let slots = buffer - (inFlight ?? 0);

        if (slots > 0) {
          const { data: candidates } = await adminClient
            .from("song_requests")
            .select("id, spotify_track_id, track_name")
            .eq("status", "pending")
            .is("pushed_to_spotify_at", null)
            .order("is_priority", { ascending: false })
            .order("created_at", { ascending: true })
            .limit(slots);

          for (const row of candidates ?? []) {
            if (slots <= 0) break;
            const trackId = row.spotify_track_id as string | null;
            if (!trackId || String(trackId).startsWith("mock_track_")) continue;

            const addRes = await fetch(
              `https://api.spotify.com/v1/me/player/queue?uri=${encodeURIComponent(`spotify:track:${trackId}`)}`,
              { method: "POST", headers: { Authorization: `Bearer ${accessToken}` } },
            );

            if (!addRes.ok) {
              // No active device / transient error — try again on the next tick.
              break;
            }

            await adminClient
              .from("song_requests")
              .update({ pushed_to_spotify_at: new Date().toISOString() })
              .eq("id", row.id)
              .eq("status", "pending");

            autoQueued.push(row.id as string);
            changes.push(`auto_queued:${row.id}`);
            slots -= 1;
          }
        }
      }
    }

    const updatedAtIso = new Date().toISOString();
    await adminClient.from("spotify_player_snapshot").upsert({
      id: 1,
      currently_playing: currentlyPlaying,
      queue: queueTracks,
      queue_count: queueCount,
      queue_may_have_more: queueMayHaveMore,
      is_playing: isPlaying,
      updated_at: updatedAtIso,
    });

    return json({
      success: true,
      cached: false,
      auto_queue_enabled: autoEnabled,
      auto_queued: autoQueued,
      spotify: {
        track_id: playingTrackId,
        track_name: (currentlyPlaying?.track_name as string) || null,
        artist_name: (currentlyPlaying?.artist_name as string) || null,
        is_playing: isPlaying,
        progress_ms: progressMs,
        duration_ms: (currentlyPlaying?.duration_ms as number) ?? null,
      },
      currently_playing: currentlyPlaying,
      queue: queueTracks,
      queue_count: queueCount,
      queue_may_have_more: queueMayHaveMore,
      is_playing: isPlaying,
      updated_at: updatedAtIso,
      changes,
    });
  } catch (err) {
    console.error(err);
    return json(
      { success: false, error: err instanceof Error ? err.message : String(err) },
      500,
    );
  }
});
