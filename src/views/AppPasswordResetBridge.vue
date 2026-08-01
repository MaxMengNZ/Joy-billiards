<template>
  <main class="bridge-page">
    <section class="bridge-card">
      <div class="brand-mark">JOY</div>
      <p class="eyebrow">JOY BILLIARDS · SECURE ACCOUNT RECOVERY</p>

      <template v-if="ready">
        <div class="status-icon">✓</div>
        <h1>继续在 JOY App 重置密码</h1>
        <p class="intro">安全验证信息已经准备好。点击下方按钮打开 JOY Billiards App，然后设置新密码。</p>
        <button class="primary" type="button" @click="openApp">在 JOY App 中继续</button>
        <p class="privacy">此页面不会修改密码，也不会保存你的验证信息。</p>
      </template>

      <template v-else>
        <div class="status-icon error">!</div>
        <h1>重置链接无法使用</h1>
        <p class="intro">链接可能已被使用、已过期，或页面被重新载入。请返回 JOY App 重新发送密码重置邮件。</p>
      </template>

      <footer>JOY BILLIARDS NEW ZEALAND<br>88 Tristram Street, Hamilton Central</footer>
    </section>
  </main>
</template>

<script setup>
import { onMounted, ref } from 'vue'

const tokenHash = ref('')
const ready = ref(false)

onMounted(() => {
  const params = new URLSearchParams(window.location.search)
  const token = params.get('token_hash') || ''
  const type = params.get('type')
  if (token && type === 'recovery') {
    tokenHash.value = token
    ready.value = true
    // Remove the one-time credential from browser history and the visible URL.
    window.history.replaceState({}, document.title, '/app-reset')
  }
})

const openApp = () => {
  if (!tokenHash.value) return
  const query = new URLSearchParams({ token_hash: tokenHash.value, type: 'recovery' })
  window.location.href = `joybilliardsapp:///reset-password?${query.toString()}`
}
</script>

<style scoped>
.bridge-page{min-height:100vh;display:grid;place-items:center;padding:24px;background:radial-gradient(circle at 80% 5%,rgba(220,42,53,.12),transparent 32%),#f6f6f4;font-family:Inter,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}.bridge-card{width:min(100%,430px);padding:38px 26px 28px;border:1px solid #e4e4e1;border-radius:28px;background:rgba(255,255,255,.96);box-shadow:0 24px 70px rgba(26,27,31,.12);text-align:center}.brand-mark{display:grid;place-items:center;width:74px;height:46px;margin:0 auto;border:2px solid #df303b;border-radius:13px;color:#c99b43;font-size:19px;font-weight:900;letter-spacing:2px}.eyebrow{margin:20px 0 28px;color:#df303b;font-size:9px;font-weight:900;letter-spacing:1.3px}.status-icon{display:grid;place-items:center;width:52px;height:52px;margin:0 auto 17px;border-radius:18px;background:#edf8f1;color:#2b8a57;font-size:24px;font-weight:900}.status-icon.error{background:#fff0f1;color:#d93640}h1{margin:0;color:#17191d;font-size:25px;line-height:1.25;font-weight:900}.intro{margin:15px auto 0;color:#727780;font-size:13px;line-height:1.8}.primary{width:100%;height:58px;margin-top:28px;border:0;border-radius:17px;background:#e32f3a;color:#fff;font-size:14px;font-weight:900;box-shadow:0 12px 28px rgba(227,47,58,.22);cursor:pointer}.primary:active{transform:scale(.985)}.privacy{margin:13px 0 0;color:#999da3;font-size:10px}footer{margin-top:42px;color:#a0a3a8;font-size:9px;font-weight:700;line-height:1.65;letter-spacing:.7px}
</style>
