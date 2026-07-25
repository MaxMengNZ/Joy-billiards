/**
 * One-time helper: get a Spotify refresh token for the venue Premium account.
 *
 * Prerequisites:
 * 1. Spotify Developer Dashboard → your app
 * 2. Add Redirect URI: http://127.0.0.1:3911/callback
 * 3. .env.local has SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET
 *
 * Usage: npm run spotify:refresh-token
 * Then paste SPOTIFY_REFRESH_TOKEN into .env.local AND Supabase Edge Function secrets.
 */
import http from 'node:http'
import { readFileSync, existsSync } from 'node:fs'
import { resolve } from 'node:path'
import { spawn } from 'node:child_process'

const PORT = 3911
const REDIRECT_URI = `http://127.0.0.1:${PORT}/callback`
const SCOPES = [
  'user-modify-playback-state',
  'user-read-playback-state',
  'user-read-currently-playing'
].join(' ')

function loadEnvLocal() {
  const path = resolve(process.cwd(), '.env.local')
  if (!existsSync(path)) return {}
  const out = {}
  for (const line of readFileSync(path, 'utf8').split('\n')) {
    const trimmed = line.trim()
    if (!trimmed || trimmed.startsWith('#')) continue
    const i = trimmed.indexOf('=')
    if (i < 0) continue
    const key = trimmed.slice(0, i).trim()
    let val = trimmed.slice(i + 1).trim()
    if (
      (val.startsWith('"') && val.endsWith('"')) ||
      (val.startsWith("'") && val.endsWith("'"))
    ) {
      val = val.slice(1, -1)
    }
    out[key] = val
  }
  return out
}

function openBrowser(url) {
  const cmd =
    process.platform === 'darwin'
      ? 'open'
      : process.platform === 'win32'
        ? 'start'
        : 'xdg-open'
  spawn(cmd, [url], { stdio: 'ignore', shell: process.platform === 'win32' })
}

const env = { ...loadEnvLocal(), ...process.env }
const clientId = (env.SPOTIFY_CLIENT_ID || '').trim()
const clientSecret = (env.SPOTIFY_CLIENT_SECRET || '').trim()

if (!clientId || !clientSecret) {
  console.error('Missing SPOTIFY_CLIENT_ID / SPOTIFY_CLIENT_SECRET in .env.local')
  process.exit(1)
}

const authUrl =
  'https://accounts.spotify.com/authorize?' +
  new URLSearchParams({
    response_type: 'code',
    client_id: clientId,
    scope: SCOPES,
    redirect_uri: REDIRECT_URI,
    show_dialog: 'true'
  }).toString()

console.log('\n1) In Spotify Developer Dashboard, add Redirect URI:')
console.log(`   ${REDIRECT_URI}`)
console.log('\n2) Sign in with the VENUE Premium Spotify account in the browser.\n')

const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url || '/', `http://127.0.0.1:${PORT}`)
    if (url.pathname !== '/callback') {
      res.writeHead(404)
      res.end('Not found')
      return
    }

    const err = url.searchParams.get('error')
    const code = url.searchParams.get('code')
    if (err) {
      res.writeHead(400, { 'Content-Type': 'text/plain' })
      res.end(`Spotify auth error: ${err}`)
      console.error('Auth error:', err)
      server.close()
      process.exit(1)
    }
    if (!code) {
      res.writeHead(400, { 'Content-Type': 'text/plain' })
      res.end('Missing code')
      return
    }

    const basic = Buffer.from(`${clientId}:${clientSecret}`).toString('base64')
    const tokenRes = await fetch('https://accounts.spotify.com/api/token', {
      method: 'POST',
      headers: {
        Authorization: `Basic ${basic}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code,
        redirect_uri: REDIRECT_URI
      })
    })
    const tokenJson = await tokenRes.json()
    if (!tokenRes.ok) {
      res.writeHead(500, { 'Content-Type': 'text/plain' })
      res.end(JSON.stringify(tokenJson))
      console.error('Token exchange failed:', tokenJson)
      server.close()
      process.exit(1)
    }

    const refresh = tokenJson.refresh_token
    if (!refresh) {
      res.writeHead(500, { 'Content-Type': 'text/plain' })
      res.end('No refresh_token returned. Try again with show_dialog / revoke app access.')
      console.error('No refresh_token in response:', tokenJson)
      server.close()
      process.exit(1)
    }

    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' })
    res.end(
      `<h1>Success</h1><p>Copy the refresh token from the terminal into <code>.env.local</code> and Supabase Edge secrets, then close this tab.</p>`
    )

    console.log('\n=== Paste into .env.local ===\n')
    console.log(`SPOTIFY_REFRESH_TOKEN=${refresh}`)
    console.log('\nAlso set the same secret on Supabase Edge Functions (spotify-push-queue).')
    console.log('Restart: npm run dev\n')
    server.close()
    process.exit(0)
  } catch (e) {
    console.error(e)
    res.writeHead(500)
    res.end(String(e))
    server.close()
    process.exit(1)
  }
})

server.listen(PORT, '127.0.0.1', () => {
  console.log(`Listening on ${REDIRECT_URI}`)
  console.log('Opening browser…\n')
  openBrowser(authUrl)
})
