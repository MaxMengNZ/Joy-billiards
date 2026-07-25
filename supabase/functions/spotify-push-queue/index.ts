import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

async function refreshVenueAccessToken() {
  const clientId = Deno.env.get("SPOTIFY_CLIENT_ID");
  const clientSecret = Deno.env.get("SPOTIFY_CLIENT_SECRET");
  const refreshToken = Deno.env.get("SPOTIFY_REFRESH_TOKEN");

  if (!clientId || !clientSecret || !refreshToken) {
    return {
      accessToken: null as string | null,
      missing: [
        !clientId ? "SPOTIFY_CLIENT_ID" : null,
        !clientSecret ? "SPOTIFY_CLIENT_SECRET" : null,
        !refreshToken ? "SPOTIFY_REFRESH_TOKEN" : null,
      ].filter(Boolean) as string[],
    };
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

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Failed to refresh Spotify token: ${res.status} ${text}`);
  }

  const data = await res.json();
  return { accessToken: data.access_token as string, missing: [] as string[] };
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Authorization required" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: userData, error: userErr } = await userClient.auth.getUser();
    if (userErr || !userData?.user) {
      return new Response(JSON.stringify({ error: "Invalid session" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const { data: profile, error: profileErr } = await adminClient
      .from("users")
      .select("id, role")
      .eq("auth_id", userData.user.id)
      .maybeSingle();

    if (profileErr || !profile || profile.role !== "admin") {
      return new Response(JSON.stringify({ error: "Admin access required" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = await req.json().catch(() => ({}));
    let uri = body.uri as string | undefined;
    const trackId = body.spotify_track_id as string | undefined;
    const requestId = body.request_id as string | undefined;

    if (!uri && trackId) {
      if (String(trackId).startsWith("mock_track_")) {
        return new Response(
          JSON.stringify({
            success: false,
            error: "Mock track IDs cannot be pushed to Spotify. Search and add a real track.",
          }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }
      uri = `spotify:track:${trackId}`;
    }

    if (!uri && requestId) {
      const { data: row } = await adminClient
        .from("song_requests")
        .select("spotify_track_id")
        .eq("id", requestId)
        .maybeSingle();
      if (row?.spotify_track_id) {
        if (String(row.spotify_track_id).startsWith("mock_track_")) {
          return new Response(
            JSON.stringify({
              success: false,
              error: "Mock track IDs cannot be pushed to Spotify.",
            }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
          );
        }
        uri = `spotify:track:${row.spotify_track_id}`;
      }
    }

    if (!uri) {
      return new Response(JSON.stringify({ error: "uri, spotify_track_id, or request_id required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { accessToken, missing } = await refreshVenueAccessToken();
    if (!accessToken) {
      return new Response(
        JSON.stringify({
          success: false,
          skipped: true,
          missing_secrets: missing,
          message:
            "Spotify venue token not configured (need SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, SPOTIFY_REFRESH_TOKEN). Website Live queue still works.",
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const devicesRes = await fetch("https://api.spotify.com/v1/me/player/devices", {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const devicesData = devicesRes.ok ? await devicesRes.json() : { devices: [] };
    const devices = (devicesData.devices || []) as Array<{
      id: string;
      name: string;
      is_active: boolean;
    }>;
    const active = devices.find((d) => d.is_active) || devices[0] || null;

    if (!devices.length) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "No Spotify devices online for the venue Premium account.",
          hint:
            "Open Spotify on the venue phone/tablet/PC with that Premium login, play any song once, then retry Send to Spotify. Check Queue (not Home).",
        }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const queueRes = await fetch(
      `https://api.spotify.com/v1/me/player/queue?uri=${encodeURIComponent(uri)}`,
      {
        method: "POST",
        headers: { Authorization: `Bearer ${accessToken}` },
      },
    );

    if (!queueRes.ok) {
      const text = await queueRes.text();
      return new Response(
        JSON.stringify({
          success: false,
          error: `Spotify queue push failed: ${queueRes.status} ${text}`,
          hint:
            "Ensure the venue Premium account has an active Spotify device open, then open the Queue panel in Spotify.",
        }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Service role has no auth.uid() — update rows directly (do not call admin RPC)
    if (requestId) {
      await adminClient
        .from("song_requests")
        .update({ status: "played", played_at: new Date().toISOString() })
        .eq("status", "playing")
        .neq("id", requestId);

      await adminClient
        .from("song_requests")
        .update({ status: "playing", played_at: new Date().toISOString() })
        .eq("id", requestId);
    }

    return new Response(
      JSON.stringify({
        success: true,
        uri,
        device_name: active?.name || null,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error(err);
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : String(err) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
