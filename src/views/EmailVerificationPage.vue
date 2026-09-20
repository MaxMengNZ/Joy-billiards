<template>
  <main class="verification-page">
    <div class="ambient ambient-red"></div>
    <div class="ambient ambient-gold"></div>

    <section class="verification-shell">
      <header class="brand-row">
        <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards New Zealand">
        <div><strong>JOY CLUB</strong><span>PLAY · ENJOY · BELONG</span></div>
      </header>

      <article class="verification-card">
        <p class="eyebrow">{{ pageCopy.eyebrow }}</p>

        <div v-if="verificationSuccess" class="status-panel">
          <div class="status-icon success-icon"><span>✓</span></div>
          <h1>{{ t('verification.confirmed') }}</h1>
          <p>{{ t('verification.confirmedDesc') }}</p>
          <button type="button" class="primary-action" @click="openAppLogin">
            <span>{{ t('verification.goLogin') }}</span><b>→</b>
          </button>
          <small>{{ pageCopy.ready }}</small>
        </div>

        <div v-else-if="verificationError" class="status-panel">
          <div class="status-icon error-icon"><span>!</span></div>
          <h1>{{ t('verification.failed') }}</h1>
          <p>{{ verificationError }}</p>
          <button type="button" class="primary-action" @click="openAppRegistration">
            <span>{{ pageCopy.retry }}</span><b>→</b>
          </button>
          <small>{{ pageCopy.support }}</small>
        </div>

        <div v-else class="status-panel">
          <div class="status-icon pending-icon"><span></span></div>
          <h1>{{ t('verification.confirming') }}</h1>
          <p>{{ t('verification.waiting') }}</p>
        </div>

        <div class="trust-row">
          <div><b>✓</b><span>{{ pageCopy.secure }}</span></div>
          <i></i>
          <div><b>JOY</b><span>{{ pageCopy.profile }}</span></div>
        </div>
      </article>

      <footer>
        <strong>JOY BILLIARDS NEW ZEALAND</strong>
        <span>88 Tristram Street, Hamilton Central</span>
      </footer>
    </section>
  </main>
</template>

<script>
import { onMounted, ref } from 'vue'
import { supabase } from '../config/supabase'
import { useI18n } from '../i18n'
import { openAppLoginWithDownloadFallback, openAppRouteWithDownloadFallback } from '../utils/appDownload'

const confirmationType = (value) => {
  if (!value || value === 'signup' || value === 'email') return 'email'
  return value
}

export default {
  name: 'EmailVerificationPage',
  setup() {
    const { t } = useI18n()
    const isZh = /^zh\b/i.test(navigator.language || '')
    const pageCopy = isZh
      ? { eyebrow: 'JOY 安全验证', secure: '安全账户', profile: '会员档案已就绪', ready: '验证完成后请返回 Joy Club App 登录', retry: '打开 Joy Club App 重新发送', support: '验证链接失效时，请在 App 注册页面使用同一邮箱重新发送。仍需帮助？请联系 info@joybilliards.co.nz' }
      : { eyebrow: 'JOY SECURE VERIFICATION', secure: 'Secure account', profile: 'Member profile ready', ready: 'Return to the Joy Club App to sign in after verification', retry: 'Open Joy Club App to resend', support: 'If the link expired, resend it from the App registration screen using the same email. Need help? Contact info@joybilliards.co.nz' }
    const verificationSuccess = ref(false)
    const verificationError = ref('')
    const requestedEvent = (() => {
      const value = new URLSearchParams(window.location.search).get('event') || ''
      return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value) ? value : ''
    })()

    const completeVerification = async () => {
      try {
        const query = new URLSearchParams(window.location.search)
        const hash = new URLSearchParams(window.location.hash.replace(/^#/, ''))
        const authError = query.get('error_description') || hash.get('error_description')
        if (authError) throw new Error(decodeURIComponent(authError.replace(/\+/g, ' ')))

        const tokenHash = query.get('token_hash') || hash.get('token_hash')
        const code = query.get('code')
        const accessToken = hash.get('access_token') || query.get('access_token')
        const refreshToken = hash.get('refresh_token') || query.get('refresh_token')

        if (tokenHash) {
          const { error } = await supabase.auth.verifyOtp({ token_hash: tokenHash, type: confirmationType(query.get('type') || hash.get('type')) })
          if (error) throw error
        } else if (accessToken && refreshToken) {
          const { error } = await supabase.auth.setSession({ access_token: accessToken, refresh_token: refreshToken })
          if (error) throw error
        } else if (code) {
          const { error } = await supabase.auth.exchangeCodeForSession(code)
          // Supabase confirms the email before redirecting here. A confirmation
          // link is frequently opened on a different browser/device from the
          // one that started registration, so that browser may not hold the
          // PKCE verifier needed to create a session. The account is still
          // confirmed; login remains protected by Supabase and happens in App.
          const crossDeviceHandoff = /code verifier|pkce|flow[ _-]?state/i.test(error?.message || '')
          if (error && !crossDeviceHandoff) throw error
          if (error) console.info('Email confirmed; cross-device session handoff was skipped:', error.message)
        } else {
          const { data, error } = await supabase.auth.getSession()
          if (error) throw error
          if (!data.session?.user?.email_confirmed_at) throw new Error(t('verification.missingToken'))
        }

        verificationSuccess.value = true
        window.history.replaceState({}, document.title, window.location.pathname)
      } catch (error) {
        console.error('Email verification error:', error)
        verificationError.value = error.message || t('verification.genericFailed')
      }
    }

    const openAppLogin = () => {
      const opened = requestedEvent
        ? openAppRouteWithDownloadFallback(`/tournament/${requestedEvent}?entrySource=share&entryAction=register`)
        : openAppLoginWithDownloadFallback()
      if (!opened) window.location.href = '/#app-download'
    }

    const openAppRegistration = () => {
      if (!openAppRouteWithDownloadFallback('/register')) window.location.href = '/#app-download'
    }

    onMounted(completeVerification)
    return { openAppLogin, openAppRegistration, pageCopy, t, verificationError, verificationSuccess }
  }
}
</script>

<style scoped>
.verification-page { min-height: 100svh; position: relative; overflow: hidden; display: grid; place-items: center; padding: 24px; background: linear-gradient(155deg, #fff 0%, #faf8f5 56%, #f2eee9 100%); color: #171719; }
.ambient { position: fixed; border-radius: 999px; filter: blur(5px); pointer-events: none; }
.ambient-red { width: 360px; height: 360px; right: -170px; top: -150px; background: radial-gradient(circle, rgba(215,25,32,.12), transparent 68%); }
.ambient-gold { width: 330px; height: 330px; left: -180px; bottom: -150px; background: radial-gradient(circle, rgba(194,145,48,.14), transparent 68%); }
.verification-shell { position: relative; z-index: 1; width: min(100%, 520px); }
.brand-row { display: flex; align-items: center; justify-content: center; gap: 16px; margin-bottom: 20px; }
.brand-row img { width: 142px; height: 58px; object-fit: contain; }
.brand-row div { padding-left: 16px; border-left: 1px solid #ded8d1; display: grid; gap: 4px; }
.brand-row strong { font-size: 15px; letter-spacing: .16em; }
.brand-row span { color: #9b2025; font-size: 9px; letter-spacing: .14em; }
.verification-card { background: rgba(255,255,255,.94); border: 1px solid rgba(40,32,28,.08); border-radius: 30px; padding: 36px; box-shadow: 0 24px 70px rgba(52,40,31,.12); backdrop-filter: blur(16px); }
.eyebrow { margin: 0 0 28px; text-align: center; color: #a87720; font-size: 11px; font-weight: 800; letter-spacing: .19em; }
.status-panel { text-align: center; }
.status-icon { width: 82px; height: 82px; margin: 0 auto 22px; border-radius: 27px; display: grid; place-items: center; transform: rotate(8deg); }
.status-icon span { transform: rotate(-8deg); font-size: 38px; font-weight: 800; }
.success-icon { color: #fff; background: linear-gradient(145deg, #e22831, #b90f18); box-shadow: 0 15px 35px rgba(195,22,30,.26); }
.error-icon { color: #a50f17; background: #fff0f1; border: 1px solid #f0c6c9; }
.pending-icon { background: #fff5f5; border: 1px solid #efd6d7; }
.pending-icon span { width: 30px; height: 30px; border: 3px solid #f1c7c9; border-top-color: #cc1921; border-radius: 50%; animation: spin .8s linear infinite; }
.status-panel h1 { margin: 0; font-size: clamp(27px, 7vw, 36px); letter-spacing: -.035em; }
.status-panel > p { max-width: 370px; margin: 13px auto 0; color: #747074; font-size: 15px; line-height: 1.65; }
.primary-action { width: 100%; min-height: 56px; margin-top: 28px; border: 0; border-radius: 17px; padding: 0 22px; display: flex; align-items: center; justify-content: space-between; color: white; background: linear-gradient(100deg, #db1c25, #bd1018); box-shadow: 0 12px 25px rgba(194,18,26,.2); font: inherit; font-weight: 750; text-decoration: none; cursor: pointer; }
.primary-action b { font-size: 21px; }
.status-panel small { display: block; margin: 15px auto 0; max-width: 390px; color: #9a9694; font-size: 12px; line-height: 1.55; }
.trust-row { margin-top: 30px; padding-top: 22px; border-top: 1px solid #eee9e5; display: grid; grid-template-columns: 1fr 1px 1fr; align-items: center; }
.trust-row > i { height: 34px; background: #e5dfda; }
.trust-row > div { display: grid; justify-items: center; gap: 5px; }
.trust-row b { color: #cc1921; font-size: 12px; letter-spacing: .08em; }
.trust-row span { color: #777270; font-size: 11px; }
footer { display: grid; justify-items: center; gap: 5px; margin-top: 21px; color: #999491; }
footer strong { color: #6b6663; font-size: 10px; letter-spacing: .18em; }
footer span { font-size: 11px; letter-spacing: .05em; }
@keyframes spin { to { transform: rotate(360deg); } }
@media (max-width: 560px) {
  .verification-page { padding: 20px 16px; }
  .brand-row img { width: 124px; height: 52px; }
  .brand-row div { padding-left: 12px; }
  .verification-card { border-radius: 25px; padding: 29px 22px 25px; }
  .eyebrow { margin-bottom: 23px; }
  .status-icon { width: 74px; height: 74px; border-radius: 24px; }
}
</style>
