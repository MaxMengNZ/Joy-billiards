/**
 * Applies Spotify song queue migration via Postgres multi-statement SQL.
 * Requires DATABASE_URL or SUPABASE_DB_PASSWORD in .env / .env.local.
 */

import { readFileSync, existsSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import postgres from 'postgres'

const __dirname = dirname(fileURLToPath(import.meta.url))
const ROOT = join(__dirname, '..')
const MIGRATION = join(
  ROOT,
  'supabase/migrations/20260725120000_spotify_song_queue.sql'
)

function stripQuotes(s) {
  const v = s.trim()
  if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
    return v.slice(1, -1)
  }
  return v
}

function parseEnvLines(text) {
  const out = {}
  for (let line of text.split('\n')) {
    line = line.trim()
    if (!line || line.startsWith('#')) continue
    const eq = line.indexOf('=')
    if (eq === -1) continue
    const key = line.slice(0, eq).trim()
    const val = stripQuotes(line.slice(eq + 1))
    if (key) out[key] = val
  }
  return out
}

function loadEnvFiles() {
  const merged = {}
  for (const name of ['.env', '.env.local']) {
    const p = join(ROOT, name)
    if (!existsSync(p)) continue
    Object.assign(merged, parseEnvLines(readFileSync(p, 'utf8')))
  }
  for (const [k, v] of Object.entries(merged)) {
    process.env[k] = v
  }
}

loadEnvFiles()

const PROJECT_DB_HOST_DEFAULT = 'db.qnwtqgdbgyqwpsdqvxfl.supabase.co'

function resolvedDatabaseUrl() {
  let url = process.env.DATABASE_URL?.trim()
  if (url && /^postgres(ql)?:\/\//i.test(url)) return url
  const pw = process.env.SUPABASE_DB_PASSWORD?.trim()
  if (!pw) return null
  const host =
    process.env.SUPABASE_DB_HOST?.trim().replace(/^https?:\/\//, '') || PROJECT_DB_HOST_DEFAULT
  const user = encodeURIComponent(process.env.SUPABASE_DB_USER || 'postgres')
  const encodedPw = encodeURIComponent(pw)
  return `postgresql://${user}:${encodedPw}@${host}:5432/postgres`
}

let dbUrl = resolvedDatabaseUrl()

if (dbUrl && /\.supabase\.co/i.test(dbUrl) && !/[?&]sslmode=/i.test(dbUrl)) {
  dbUrl += (dbUrl.includes('?') ? '&' : '?') + 'sslmode=require'
}

if (!dbUrl) {
  console.error(
    '[apply-song-queue-migration] Set DATABASE_URL or SUPABASE_DB_PASSWORD in .env.local'
  )
  process.exit(1)
}

if (!existsSync(MIGRATION)) {
  console.error('[apply-song-queue-migration] Missing:', MIGRATION)
  process.exit(1)
}

const sqlText = readFileSync(MIGRATION, 'utf8')
let sql
try {
  sql = postgres(dbUrl, { max: 1, connect_timeout: 60, idle_timeout: 20 })
  await sql.unsafe(sqlText)
  console.error('[apply-song-queue-migration] OK')
} catch (e) {
  console.error('[apply-song-queue-migration] Failed:', e?.message || e)
  process.exit(1)
} finally {
  if (sql) await sql.end({ timeout: 5 })
}
