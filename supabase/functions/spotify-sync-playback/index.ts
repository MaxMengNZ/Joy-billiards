import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const MIN_SYNC_INTERVAL_MS = 8000;

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

    // Rate-limit: reuse fresh snapshot instead of hammering Spotify
    const { data: existing } = await adminClient
      .from("spotify_player_snapshot")
      .select("currently_playing, queue, is_playing, updated_at")
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
        queue: existing.queue || [],
        is_playing: !!existing.is_playing,
        updated_at: existing.updated_at,
        changes: [],
      });
    }

    const accessToken = await refreshVenueAccessToken();
    if (!accessToken) {
      return json({
        success: false,
        skipped: true,
        message: "Spotify venue token not configured.",
        currently_playing: existing?.currently_playing ?? null,
        queue: existing?.queue ?? [],
        is_playing: false,
      });
    }

    // Fetch currently-playing (includes progress) + queue in parallel
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
    let queueCurrently = currentlyPlaying;

    if (queueRes.ok) {
      const qData = await queueRes.json();
      // Prefer queue endpoint's currently_playing if we didn't get one
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
      queueTracks = ((qData?.queue as unknown[]) || [])
        .map((t) => mapTrack(t as Record<string, unknown>))
        .filter(Boolean) as Array<Record<string, unknown>>;
    }

    await adminClient.from("spotify_player_snapshot").upsert({
      id: 1,
      currently_playing: currentlyPlaying,
      queue: queueTracks,
      is_playing: isPlaying,
      updated_at: new Date().toISOString(),
    });

    // Align website song_requests with real Spotify playback
    const changes: string[] = [];
    const playingTrackId = (currentlyPlaying?.spotify_track_id as string) || null;

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
        // Demote any other playing first
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

    return json({
      success: true,
      cached: false,
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
      is_playing: isPlaying,
      updated_at: new Date().toISOString(),
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
