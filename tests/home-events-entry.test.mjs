import assert from 'node:assert/strict'
import test from 'node:test'
import { readFileSync } from 'node:fs'

test('homepage public event entry precedes existing discovery links and preserves App/account actions', () => {
  const source = readFileSync('src/views/ClubLandingPage.vue', 'utf8')
  assert.match(source, /<router-link to="\/events" class="events-entry">/)
  assert.ok(source.indexOf('to="/events"') < source.indexOf('to="/pricing"'))
  assert.match(source, /events: '近期赛事与报名'/)
  assert.match(source, /events: 'Upcoming tournaments'/)
  assert.match(source, /grid-column:1\/-1/)
  assert.match(source, /@click="openApp"/)
  assert.match(source, /to="\/join"/)
  assert.match(source, /openAppLoginWithDownloadFallback\(\)/)
  assert.doesNotMatch(source, /from.*supabase|\.insert\(|\.update\(|checkout|\.rpc\(/)
})
