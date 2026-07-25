import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const MOCK_TRACKS = [
  {
    id: "mock_track_1",
    name: "Blinding Lights",
    artists: [{ name: "The Weeknd" }],
    album: {
      name: "After Hours",
      images: [{ url: "https://i.scdn.co/image/ab67616d0000b2738863bc11d2aa12b11d2c72ab" }],
    },
    duration_ms: 200040,
    preview_url: null,
    external_urls: { spotify: "https://open.spotify.com/track/0VjIjW4GlUZAMYd2vXMi3b" },
  },
  {
    id: "mock_track_2",
    name: "As It Was",
    artists: [{ name: "Harry Styles" }],
    album: {
      name: "Harry's House",
      images: [{ url: "https://i.scdn.co/image/ab67616d0000b2732e8ed79e177ff6011076f5f0" }],
    },
    duration_ms: 167303,
    preview_url: null,
    external_urls: { spotify: "https://open.spotify.com/track/4LRPiXqCikLlN15B4G4z1t" },
  },
  {
    id: "mock_track_3",
    name: "Levitating",
    artists: [{ name: "Dua Lipa" }],
    album: {
      name: "Future Nostalgia",
      images: [{ url: "https://i.scdn.co/image/ab67616d0000b273ef24c3fdbf856340d55cfeb2" }],
    },
    duration_ms: 203064,
    preview_url: null,
    external_urls: { spotify: "https://open.spotify.com/track/39LLxExYz6ewLAcYrzQQyP" },
  },
  {
    id: "mock_track_4",
    name: "Stay",
    artists: [{ name: "The Kid LAROI" }, { name: "Justin Bieber" }],
    album: {
      name: "F*CK LOVE 3: OVER YOU",
      images: [{ url: "https://i.scdn.co/image/ab67616d0000b2738e6551a723239580995ecc60" }],
    },
    duration_ms: 141806,
    preview_url: null,
    external_urls: { spotify: "https://open.spotify.com/track/5HCyWlXZPP0y6Gqq8TgA20" },
  },
  {
    id: "mock_track_5",
    name: "Good 4 U",
    artists: [{ name: "Olivia Rodrigo" }],
    album: {
      name: "SOUR",
      images: [{ url: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a" }],
    },
    duration_ms: 178147,
    preview_url: null,
    external_urls: { spotify: "https://open.spotify.com/track/4ZtFanR9U6ndgddUvNcjcG" },
  },
];

function mapTrack(t: Record<string, unknown>) {
  const album = t.album as { name?: string; images?: { url: string }[] } | undefined;
  const artists = (t.artists as { name: string }[]) || [];
  return {
    spotify_track_id: t.id as string,
    track_name: t.name as string,
    artist_name: artists.map((a) => a.name).join(", "),
    album_name: album?.name || null,
    album_art_url: album?.images?.[0]?.url || null,
    duration_ms: (t.duration_ms as number) || null,
    preview_url: (t.preview_url as string) || null,
    spotify_url: (t.external_urls as { spotify?: string })?.spotify || null,
  };
}

function toBasicAuth(clientId: string, clientSecret: string) {
  const raw = `${clientId}:${clientSecret}`;
  const bytes = new TextEncoder().encode(raw);
  let binary = "";
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary);
}

async function getClientCredentialsToken(clientId: string, clientSecret: string) {
  const basic = toBasicAuth(clientId, clientSecret);
  const res = await fetch("https://accounts.spotify.com/api/token", {
    method: "POST",
    headers: {
      Authorization: `Basic ${basic}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({ grant_type: "client_credentials" }).toString(),
  });
  if (!res.ok) {
    const text = await res.text();
    let detail = text;
    try {
      const parsed = JSON.parse(text);
      detail = parsed.error_description || parsed.error || text;
    } catch {
      // keep raw text
    }
    throw new Error(
      `Spotify auth failed (${res.status}): ${detail}. Check SPOTIFY_CLIENT_ID / SPOTIFY_CLIENT_SECRET values.`,
    );
  }
  const data = await res.json();
  return data.access_token as string;
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

    const body = await req.json().catch(() => ({}));
    const q = String(body.q || body.query || "").trim();
    const limit = Math.min(Math.max(Number(body.limit) || 10, 1), 20);

    if (!q) {
      return new Response(JSON.stringify({ error: "Search query is required", tracks: [] }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const clientId = (Deno.env.get("SPOTIFY_CLIENT_ID") || "").trim();
    const clientSecret = (Deno.env.get("SPOTIFY_CLIENT_SECRET") || "").trim();
    const hasClientId = clientId.length > 0;
    const hasClientSecret = clientSecret.length > 0;

    if (!hasClientId || !hasClientSecret) {
      const missing = [
        !hasClientId ? "SPOTIFY_CLIENT_ID" : null,
        !hasClientSecret ? "SPOTIFY_CLIENT_SECRET" : null,
      ].filter(Boolean);

      const filtered = MOCK_TRACKS.filter((t) => {
        const hay = `${t.name} ${t.artists.map((a) => a.name).join(" ")}`.toLowerCase();
        return hay.includes(q.toLowerCase()) || q.length < 2;
      }).slice(0, limit);

      return new Response(
        JSON.stringify({
          tracks: filtered.map((t) => mapTrack(t as unknown as Record<string, unknown>)),
          mock: true,
          missing_secrets: missing,
          message:
            `Spotify secrets missing on Edge Function: ${missing.join(", ")}. ` +
            "Add them in Supabase → Edge Functions → Secrets, then search again.",
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const token = await getClientCredentialsToken(clientId, clientSecret);
    // Avoid sending limit query param (can trigger Spotify "Invalid limit" with some clients)
    const searchUrl =
      `https://api.spotify.com/v1/search?type=track&q=${encodeURIComponent(q)}`;

    const searchRes = await fetch(searchUrl, {
      headers: { Authorization: `Bearer ${token}` },
    });

    if (!searchRes.ok) {
      const text = await searchRes.text();
      throw new Error(`Spotify search failed: ${searchRes.status} ${text}`);
    }

    const data = await searchRes.json();
    const items = ((data.tracks?.items || []) as Record<string, unknown>[]).slice(0, limit);

    return new Response(
      JSON.stringify({
        tracks: items.map(mapTrack),
        mock: false,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error(err);
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : String(err), tracks: [] }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
