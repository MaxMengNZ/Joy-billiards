import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'
import test from 'node:test'

test('Vercel permanently retires every Rank path at the edge', async () => {
  const config = JSON.parse(
    await readFile(new URL('../vercel.json', import.meta.url), 'utf8'),
  )
  const redirect = config.redirects.find((rule) =>
    rule.has?.some(
      (condition) =>
        condition.type === 'host' &&
        condition.value === 'rank.joybilliards.co.nz',
    ),
  )

  assert.ok(redirect)
  assert.equal(redirect.source, '/(.*)')
  assert.equal(redirect.destination, 'https://club.joybilliards.co.nz/')
  assert.equal(redirect.permanent, true)
})

test('Vercel deployment aliases cannot expose the retired website', async () => {
  const config = JSON.parse(
    await readFile(new URL('../vercel.json', import.meta.url), 'utf8'),
  )
  const retiredHosts = config.redirects
    .flatMap((rule) => rule.has ?? [])
    .filter((condition) => condition.type === 'host')
    .map((condition) => condition.value)

  assert.ok(retiredHosts.includes('joy-billiards.vercel.app'))
  assert.ok(
    retiredHosts.includes(
      'joy-billiards-[a-z0-9]+-max-mengs-projects\\.vercel\\.app',
    ),
  )
})

test('the client fallback has no administrator exception', async () => {
  const router = await readFile(
    new URL('../src/router/index.js', import.meta.url),
    'utf8',
  )
  assert.match(router, /if \(isRetiredWebHost\)/)
  assert.match(router, /currentHost\.endsWith\('\.vercel\.app'\)/)
  assert.match(
    router,
    /window\.location\.replace\(`https:\/\/\$\{CLUB_HOST\}\/`\)/,
  )
  assert.doesNotMatch(router, /canUseLegacyRankWebsite/)
  assert.doesNotMatch(router, /LEGACY_RANK_OPERATOR_EMAIL/)
})
