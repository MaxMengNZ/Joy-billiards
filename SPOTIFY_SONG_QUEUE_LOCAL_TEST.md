# Spotify Member Song Queue — Local Test Checklist

## Prerequisites

1. Migration applied: `supabase/migrations/20260725120000_spotify_song_queue.sql`
2. Frontend: `npm run dev` (port 3001)
3. Login as a member (`lite|plus|pro|pro_max`, active)

## Live queue buttons (Play / Cancel / Send)

- Actions update the list **immediately** (optimistic UI). You should not need a hard refresh.
- Feedback appears under the **Live queue** heading.
- If auth loads slowly, the page now waits for membership before starting Realtime.

## With Spotify search (local)

1. Put `SPOTIFY_CLIENT_ID` + `SPOTIFY_CLIENT_SECRET` in `.env.local`
2. Restart `npm run dev`
3. Search uses `/api/spotify-search` (real tracks)

## With Send to Spotify (required for real push)

Website Live queue ≠ Spotify app queue. Staff “Send to Spotify” pushes into the **venue Premium** account Queue.

1. Spotify Developer Dashboard → add Redirect URI: `http://127.0.0.1:3911/callback`
2. Run: `npm run spotify:refresh-token`
3. Sign in with the **venue Premium** Spotify account
4. Paste `SPOTIFY_REFRESH_TOKEN=...` into `.env.local`
5. Also set the same three secrets on Supabase Edge Functions:  
   `SPOTIFY_CLIENT_ID`, `SPOTIFY_CLIENT_SECRET`, `SPOTIFY_REFRESH_TOKEN`
6. Restart `npm run dev`
7. Open Spotify on the venue device (same Premium login), play any track once (creates an active device)
8. Admin: **Send to Spotify** → check Spotify app **Queue** (not Home / Liked Songs)

Without `SPOTIFY_REFRESH_TOKEN`, the UI shows a yellow warning (skipped) — not a fake success.

## Do not

- Do not commit `.env.local` or real Spotify tokens.
- Do not push this feature to GitHub until you are ready.
