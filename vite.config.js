import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

function readJsonBody(req) {
  return new Promise(async (resolve, reject) => {
    try {
      const chunks = []
      for await (const chunk of req) chunks.push(chunk)
      const raw = Buffer.concat(chunks).toString('utf8') || '{}'
      resolve(JSON.parse(raw))
    } catch (err) {
      reject(err)
    }
  })
}

function spotifyDevProxies() {
  let cachedClientToken = null
  let clientTokenExpiresAt = 0
  let cachedUserToken = null
  let userTokenExpiresAt = 0

  async function getClientCredentialsToken(clientId, clientSecret) {
    const now = Date.now()
    if (cachedClientToken && now < clientTokenExpiresAt - 30_000) return cachedClientToken

    const basic = Buffer.from(`${clientId}:${clientSecret}`).toString('base64')
    const res = await fetch('https://accounts.spotify.com/api/token', {
      method: 'POST',
      headers: {
        Authorization: `Basic ${basic}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'grant_type=client_credentials'
    })
    if (!res.ok) {
      const text = await res.text()
      throw new Error(`Spotify auth failed (${res.status}): ${text}`)
    }
    const data = await res.json()
    cachedClientToken = data.access_token
    clientTokenExpiresAt = now + (data.expires_in || 3600) * 1000
    return cachedClientToken
  }

  async function getUserAccessToken(clientId, clientSecret, refreshToken) {
    const now = Date.now()
    if (cachedUserToken && now < userTokenExpiresAt - 30_000) return cachedUserToken

    const basic = Buffer.from(`${clientId}:${clientSecret}`).toString('base64')
    const res = await fetch('https://accounts.spotify.com/api/token', {
      method: 'POST',
      headers: {
        Authorization: `Basic ${basic}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'refresh_token',
        refresh_token: refreshToken
      })
    })
    if (!res.ok) {
      const text = await res.text()
      throw new Error(`Spotify refresh failed (${res.status}): ${text}`)
    }
    const data = await res.json()
    cachedUserToken = data.access_token
    userTokenExpiresAt = now + (data.expires_in || 3600) * 1000
    return cachedUserToken
  }

  function mapTrack(t) {
    return {
      spotify_track_id: t.id,
      track_name: t.name,
      artist_name: (t.artists || []).map((a) => a.name).join(', '),
      album_name: t.album?.name || null,
      album_art_url: t.album?.images?.[0]?.url || null,
      duration_ms: t.duration_ms || null,
      preview_url: t.preview_url || null,
      spotify_url: t.external_urls?.spotify || null
    }
  }

  function json(res, status, body) {
    res.statusCode = status
    res.setHeader('Content-Type', 'application/json')
    res.end(JSON.stringify(body))
  }

  return {
    name: 'spotify-dev-proxies',
    configureServer(server) {
      server.middlewares.use('/api/spotify-search', async (req, res) => {
        if (req.method === 'OPTIONS') {
          res.statusCode = 204
          res.end()
          return
        }
        if (req.method !== 'GET' && req.method !== 'POST') {
          json(res, 405, { error: 'Method not allowed' })
          return
        }

        try {
          const env = loadEnv(server.config.mode, process.cwd(), '')
          const clientId = (env.SPOTIFY_CLIENT_ID || process.env.SPOTIFY_CLIENT_ID || '').trim()
          const clientSecret = (env.SPOTIFY_CLIENT_SECRET || process.env.SPOTIFY_CLIENT_SECRET || '').trim()

          let q = ''
          let limit = 10
          if (req.method === 'GET') {
            const rawUrl = req.url || ''
            const qs = rawUrl.includes('?') ? rawUrl.slice(rawUrl.indexOf('?') + 1) : ''
            const params = new URLSearchParams(qs)
            q = (params.get('q') || params.get('query') || '').trim()
            const parsedLimit = Number.parseInt(params.get('limit') || '10', 10)
            limit =
              Number.isFinite(parsedLimit) && parsedLimit > 0
                ? Math.min(parsedLimit, 50)
                : 10
          } else {
            const body = await readJsonBody(req)
            q = String(body.q || body.query || '').trim()
            const parsedLimit = Number.parseInt(String(body.limit ?? '10'), 10)
            limit =
              Number.isFinite(parsedLimit) && parsedLimit > 0
                ? Math.min(parsedLimit, 50)
                : 10
          }

          if (!q) {
            json(res, 400, { error: 'Search query is required', tracks: [] })
            return
          }

          if (!clientId || !clientSecret) {
            json(res, 200, {
              tracks: [],
              mock: true,
              missing_secrets: [
                !clientId ? 'SPOTIFY_CLIENT_ID' : null,
                !clientSecret ? 'SPOTIFY_CLIENT_SECRET' : null
              ].filter(Boolean),
              message:
                'Add SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET to .env.local, then restart npm run dev.'
            })
            return
          }

          const token = await getClientCredentialsToken(clientId, clientSecret)
          const searchUrl = `https://api.spotify.com/v1/search?type=track&q=${encodeURIComponent(q)}`

          const searchRes = await fetch(searchUrl, {
            headers: { Authorization: `Bearer ${token}` }
          })
          if (!searchRes.ok) {
            const text = await searchRes.text()
            throw new Error(`Spotify search failed: ${searchRes.status} ${text}`)
          }
          const data = await searchRes.json()
          const items = (data.tracks?.items || []).slice(0, limit)

          json(res, 200, {
            tracks: items.map(mapTrack),
            mock: false,
            source: 'local-dev-proxy'
          })
        } catch (err) {
          json(res, 500, { error: err.message || String(err), tracks: [] })
        }
      })

      server.middlewares.use('/api/spotify-push-queue', async (req, res) => {
        if (req.method === 'OPTIONS') {
          res.statusCode = 204
          res.end()
          return
        }
        if (req.method !== 'POST') {
          json(res, 405, { error: 'Method not allowed' })
          return
        }

        try {
          const env = loadEnv(server.config.mode, process.cwd(), '')
          const clientId = (env.SPOTIFY_CLIENT_ID || process.env.SPOTIFY_CLIENT_ID || '').trim()
          const clientSecret = (
            env.SPOTIFY_CLIENT_SECRET ||
            process.env.SPOTIFY_CLIENT_SECRET ||
            ''
          ).trim()
          // Strip accidental URL junk (e.g. pasted "&ubi=...") after the raw token
          const refreshToken = (
            env.SPOTIFY_REFRESH_TOKEN ||
            process.env.SPOTIFY_REFRESH_TOKEN ||
            ''
          )
            .trim()
            .split(/[&\s]/)[0]

          const body = await readJsonBody(req)
          let uri = body.uri
          const trackId = body.spotify_track_id

          if (!uri && trackId) {
            if (String(trackId).startsWith('mock_track_')) {
              json(res, 400, {
                success: false,
                error: 'Mock track IDs cannot be pushed to Spotify.'
              })
              return
            }
            uri = `spotify:track:${trackId}`
          }

          if (!uri) {
            json(res, 400, { success: false, error: 'spotify_track_id or uri required' })
            return
          }

          if (!clientId || !clientSecret || !refreshToken) {
            json(res, 200, {
              success: false,
              skipped: true,
              missing_secrets: [
                !clientId ? 'SPOTIFY_CLIENT_ID' : null,
                !clientSecret ? 'SPOTIFY_CLIENT_SECRET' : null,
                !refreshToken ? 'SPOTIFY_REFRESH_TOKEN' : null
              ].filter(Boolean),
              message:
                'SPOTIFY_REFRESH_TOKEN missing in .env.local. Run: npm run spotify:refresh-token — then restart npm run dev. Website Live queue still works.'
            })
            return
          }

          const accessToken = await getUserAccessToken(clientId, clientSecret, refreshToken)

          const devicesRes = await fetch('https://api.spotify.com/v1/me/player/devices', {
            headers: { Authorization: `Bearer ${accessToken}` }
          })
          const devicesData = devicesRes.ok ? await devicesRes.json() : { devices: [] }
          const devices = devicesData.devices || []
          const active =
            devices.find((d) => d.is_active) || devices.find((d) => d.name) || null

          if (!devices.length) {
            json(res, 200, {
              success: false,
              error: 'No Spotify devices found for the venue account.',
              hint: 'Open Spotify on the venue phone/tablet/computer (same Premium login), start playing any track once, then retry Send to Spotify.'
            })
            return
          }

          const queueRes = await fetch(
            `https://api.spotify.com/v1/me/player/queue?uri=${encodeURIComponent(uri)}`,
            {
              method: 'POST',
              headers: { Authorization: `Bearer ${accessToken}` }
            }
          )

          if (!queueRes.ok) {
            const text = await queueRes.text()
            json(res, 200, {
              success: false,
              error: `Spotify queue push failed: ${queueRes.status} ${text}`,
              hint: 'Ensure venue Premium is playing on an active device, then open Queue in the Spotify app.'
            })
            return
          }

          json(res, 200, {
            success: true,
            uri,
            device_name: active?.name || null,
            source: 'local-dev-proxy'
          })
        } catch (err) {
          json(res, 500, { success: false, error: err.message || String(err) })
        }
      })
    }
  }
}

export default defineConfig({
  plugins: [vue(), spotifyDevProxies()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  },
  server: {
    port: 3001,
    host: true,
    hmr: {
      port: 3001,
      clientPort: 3001
    }
  }
})
