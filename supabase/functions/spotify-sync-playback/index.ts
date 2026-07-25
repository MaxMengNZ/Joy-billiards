import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function refreshVenueAccessToken() {
  const clientId = Deno.env.get("SPOTIFY_CLIENT_ID");
  const clientSecret = Deno.env.get("SPOTIFY_CLIENT_SECRET");
  const refreshToken = Deno.env.get("SPOTIFY_REFRESH_TOKEN");

  if (!clientId || !clientSecret || !refreshToken) {
    return null;
  }

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

    const accessToken = await refreshVenueAccessToken();
    if (!accessToken) {
      return json({
        success: false,
        skipped: true,
        message: "Spotify venue token not configured.",
      });
    }

    // What is Spotify actually playing right now?
    const nowRes = await fetch(
      "https://api.spotify.com/v1/me/player/currently-playing",
      { headers: { Authorization: `Bearer ${accessToken}` } },
    );

    let spotify: {
      track_id: string | null;
      track_name: string | null;
      artist_name: string | null;
      is_playing: boolean;
      progress_ms: number | null;
      duration_ms: number | null;
    } = {
      track_id: null,
      track_name: null,
      artist_name: null,
      is_playing: false,
      progress_ms: null,
      duration_ms: null,
    };

    if (nowRes.status === 200) {
      const data = await nowRes.json();
      const item = data?.item;
      spotify = {
        track_id: item?.id ?? null,
        track_name: item?.name ?? null,
        artist_name: (item?.artists || [])
          .map((a: { name: string }) => a.name)
          .join(", ") || null,
        is_playing: !!data?.is_playing,
        progress_ms: typeof data?.progress_ms === "number" ? data.progress_ms : null,
        duration_ms: typeof item?.duration_ms === "number" ? item.duration_ms : null,
      };
    }
    // 204 = nothing playing / no active device → spotify stays "not playing"

    // Website's current "playing" row
    const { data: playingRow } = await adminClient
      .from("song_requests")
      .select("id, spotify_track_id, track_name")
      .eq("status", "playing")
      .maybeSingle();

    const changes: string[] = [];

    if (playingRow) {
      const stillPlayingSame =
        spotify.track_id &&
        spotify.track_id === playingRow.spotify_track_id &&
        spotify.is_playing;

      if (!stillPlayingSame) {
        // Spotify moved on (finished, skipped, or different track) → finish it
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

    // If Spotify is playing a track that matches a pending request, promote it.
    if (spotify.track_id && spotify.is_playing) {
      const { data: pendingMatch } = await adminClient
        .from("song_requests")
        .select("id")
        .eq("status", "pending")
        .eq("spotify_track_id", spotify.track_id)
        .order("created_at", { ascending: true })
        .limit(1)
        .maybeSingle();

      if (pendingMatch) {
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
      spotify,
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
