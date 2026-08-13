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

export const openAppRouteWithDownloadFallback = (route = '/login', platform = detectClientPlatform()) => {
  if (typeof window === 'undefined') return false
  const safeRoute = /^\/[a-z0-9/_-]*$/i.test(route) ? route : '/login'

  if (platform === 'android') {
    const fallbackUrl = encodeURIComponent(ANDROID_PLAY_STORE_URL)
    window.location.href = `intent://${safeRoute}#Intent;scheme=joybilliardsapp;package=nz.co.joybilliards.app;S.browser_fallback_url=${fallbackUrl};end`
    return true
  }

  if (platform === 'ios') {
    let appOpened = false
    const trackAppOpen = () => {
      if (document.visibilityState === 'hidden') appOpened = true
    }
    document.addEventListener('visibilitychange', trackAppOpen)
    window.location.href = `joybilliardsapp://${safeRoute}`
    window.setTimeout(() => {
      document.removeEventListener('visibilitychange', trackAppOpen)
      if (!appOpened && document.visibilityState === 'visible') {
        window.location.href = IOS_APP_STORE_URL
      }
    }, 1400)
    return true
  }

  return false
}

export const openAppLoginWithDownloadFallback = (platform = detectClientPlatform()) =>
  openAppRouteWithDownloadFallback('/login', platform)
