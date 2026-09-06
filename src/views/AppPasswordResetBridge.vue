<template>
  <main class="recovery-page">
    <section class="recovery-card">
      <header><img src="/JoyBilliards-Logo.svg" alt="Joy Billiards New Zealand"><button class="language" @click="zh = !zh">{{ zh ? 'English' : '中文' }}</button></header>
      <p class="eyebrow">JOY CLUB · SECURE ACCOUNT</p>
      <div class="symbol" aria-hidden="true">{{ appUrl ? '↗' : '!' }}</div>
      <h1>{{ appUrl ? copy.title : copy.invalid }}</h1>
      <p class="intro">{{ appUrl ? copy.intro : copy.retry }}</p>
      <button class="primary" @click="continueInApp">{{ appUrl ? copy.open : copy.resend }}</button>
      <p class="privacy">{{ copy.privacy }}</p>
      <nav :aria-label="copy.download"><a v-for="store in stores" :key="store.platform" :href="store.url">{{ store.label }} ↗</a></nav>
      <footer>JOY BILLIARDS NEW ZEALAND<br><a href="mailto:info@joybilliards.co.nz">info@joybilliards.co.nz</a></footer>
    </section>
  </main>
</template>

<script setup>
import { computed, ref } from 'vue'
import { recoveryAppUrl } from '../utils/recoveryBridge'
import { downloadOptionsForClient, openAppRouteWithDownloadFallback } from '../utils/appDownload'
const zh = ref(/^zh/i.test(navigator.language || ''))
// Keep credentials only in memory. Never verify on page load or expose to stores.
const appUrl = recoveryAppUrl(window.location.search, window.location.hash)
window.history.replaceState({}, document.title, window.location.pathname)
const stores = downloadOptionsForClient()
const copy = computed(() => zh.value ? {
  title: '在 Joy Club 设置新密码', invalid: '请重新获取重置链接',
  intro: '点击下方按钮返回 App，完成新密码设置。打开链接不会自动修改密码。',
  retry: '链接缺少验证信息、已过期或已被使用。请打开 App，重新发送密码重置邮件。',
  open: '打开 App 设置新密码', resend: '打开 App 重新发送',
  privacy: '请勿转发此链接。安全验证仅在 App 中完成。', download: '下载 Joy Club',
} : {
  title: 'Set a new password in Joy Club', invalid: 'Request a new reset link',
  intro: 'Continue in the App to choose your new password. Opening this link does not change your password.',
  retry: 'This link is incomplete, expired or already used. Open the App and request a new password reset email.',
  open: 'Open App to set password', resend: 'Open App to request a new link',
  privacy: 'Do not share this link. Secure verification takes place in the App.', download: 'Download Joy Club',
})
const continueInApp = () => {
  if (appUrl) window.location.href = appUrl
  else openAppRouteWithDownloadFallback('/forgot-password')
}
</script>

<style scoped>
.recovery-page{box-sizing:border-box;min-height:100dvh;display:grid;place-items:center;padding:24px;background:radial-gradient(ellipse at top right,#f4e6cd,transparent 55%),#f7f6f2;color:#262528;font-family:Inter,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}.recovery-card{box-sizing:border-box;width:100%;max-width:440px;padding:28px;border:1px solid #e5dfd4;border-radius:28px;background:#fffdf9;box-shadow:0 20px 60px #30231112;text-align:center}header{display:flex;align-items:center;justify-content:space-between;gap:16px}header img{width:130px;height:auto}.language{border:1px solid #ddd5c8;background:none;border-radius:20px;padding:8px 12px;color:#75644b}.eyebrow{margin:32px 0 20px;color:#9b7950;font-size:10px;font-weight:800;letter-spacing:2px}.symbol{margin:auto;width:62px;height:62px;display:grid;place-items:center;border-radius:20px;background:#f9e9eb;color:#ba2037;font-size:32px}h1{font-size:28px;line-height:1.2;margin:24px 0 16px}.intro{color:#78716b;line-height:1.75;font-size:15px}.primary{width:100%;border:0;border-radius:18px;background:#bd2038;color:white;padding:19px 14px;font:inherit;font-weight:750;margin-top:16px;cursor:pointer}.privacy{font-size:12px;line-height:1.6;color:#91877c}nav{display:flex;gap:24px;justify-content:center;margin-top:30px}a{color:#826944;text-decoration:none}footer{font-size:10px;letter-spacing:1px;line-height:2;margin-top:32px;color:#998d7c}button:focus-visible,a:focus-visible{outline:3px solid #b58b43;outline-offset:4px}
</style>
