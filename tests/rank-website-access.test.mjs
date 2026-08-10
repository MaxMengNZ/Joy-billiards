import assert from 'node:assert/strict'
import test from 'node:test'

import {
  canUseLegacyRankWebsite,
  isRankWebsiteHost,
} from '../src/utils/rankWebsiteAccess.js'

test('only Max Meng administrator account can retain the legacy Rank website', () => {
  assert.equal(
    canUseLegacyRankWebsite({
      user: { email: 'MaxMengNZ@qq.com' },
      profile: { role: 'admin', name: 'Max Meng' },
    }),
    true,
  )
  assert.equal(
    canUseLegacyRankWebsite({
      user: { email: 'maxmengnz@qq.com' },
      profile: { role: 'player', name: 'Max Meng' },
    }),
    false,
  )
  assert.equal(
    canUseLegacyRankWebsite({
      user: { email: 'another-admin@example.com' },
      profile: { role: 'admin' },
    }),
    false,
  )
})

test('Rank host matching is exact and case insensitive', () => {
  assert.equal(isRankWebsiteHost('RANK.JOYBILLIARDS.CO.NZ'), true)
  assert.equal(isRankWebsiteHost('club.joybilliards.co.nz'), false)
  assert.equal(isRankWebsiteHost('evil-rank.joybilliards.co.nz'), false)
})
