/**
 * Use the device's primary language only. A secondary Chinese keyboard or
 * preferred language must not turn an English device into a Chinese session.
 */
export function detectDeviceLocale(browserNavigator = globalThis.navigator) {
  try {
    const primary = browserNavigator?.language
      || browserNavigator?.languages?.[0]
      || browserNavigator?.userLanguage
    return String(primary || '').toLowerCase().startsWith('zh') ? 'zh' : 'en'
  } catch {
    return 'en'
  }
}
