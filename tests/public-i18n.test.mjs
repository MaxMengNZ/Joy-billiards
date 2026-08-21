import assert from 'node:assert/strict'
import test from 'node:test'
import { readFile } from 'node:fs/promises'

test('device detection uses the primary device language only', async () => {
  globalThis.localStorage = { getItem: () => null, setItem: () => {} }
  globalThis.document = { documentElement: { lang: '' } }
  Object.defineProperty(globalThis, 'navigator', {
    configurable: true,
    value: { language: 'en-NZ', languages: ['en-NZ', 'zh-CN'] },
  })
  const { detectDeviceLocale } = await import(`../src/i18n/deviceLocale.js?test=${Date.now()}`)
  assert.equal(detectDeviceLocale(globalThis.navigator), 'en')
  assert.equal(detectDeviceLocale({ language: 'zh-Hans-NZ' }), 'zh')
})

test('club landing and registration expose the shared language switcher', async () => {
  const [landing, register] = await Promise.all([
    readFile(new URL('../src/views/ClubLandingPage.vue', import.meta.url), 'utf8'),
    readFile(new URL('../src/views/AppInviteRegisterPage.vue', import.meta.url), 'utf8'),
  ])
  for (const source of [landing, register]) {
    assert.match(source, /<LanguageSwitcher\s*\/>/)
    assert.match(source, /useI18n/)
  }
  assert.match(landing, /Your matches and honours/)
  assert.match(register, /Create your account/)
})
