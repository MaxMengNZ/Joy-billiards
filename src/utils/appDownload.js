export const IOS_APP_STORE_URL = 'https://apps.apple.com/app/id6796553031'
export const ANDROID_PLAY_STORE_URL = 'https://play.google.com/store/apps/details?id=nz.co.joybilliards.app'

export const detectClientPlatform = () => {
  if (typeof navigator === 'undefined') return 'desktop'
  const userAgent = `${navigator.userAgent || ''} ${navigator.userAgentData?.platform || ''}`
  if (/android/i.test(userAgent)) return 'android'
  if (/iphone|ipad|ipod/i.test(userAgent)) return 'ios'
  if (/macintosh/i.test(userAgent) && navigator.maxTouchPoints > 1) return 'ios'
  return 'desktop'
}

export const downloadOptionsForClient = (platform = detectClientPlatform()) => {
  if (platform === 'ios') {
    return [{ platform: 'ios', label: 'App Store', url: IOS_APP_STORE_URL }]
  }
  if (platform === 'android') {
    return [{ platform: 'android', label: 'Google Play', url: ANDROID_PLAY_STORE_URL }]
  }
  return [
    { platform: 'ios', label: 'App Store', url: IOS_APP_STORE_URL },
    { platform: 'android', label: 'Google Play', url: ANDROID_PLAY_STORE_URL },
  ]
}
