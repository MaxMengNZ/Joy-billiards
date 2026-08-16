<template>
  <footer class="public-footer">
    <div><strong>JOY BILLIARDS NEW ZEALAND</strong><span>88 Tristram Street, Hamilton Central</span></div>
    <nav>
      <a href="tel:+64221660688">+64 22 166 0688</a>
      <a href="mailto:info@joybilliards.co.nz">info@joybilliards.co.nz</a>
      <router-link to="/privacy-policy">{{ isZh ? '隐私政策' : 'Privacy' }}</router-link>
      <router-link to="/terms-of-service">{{ isZh ? '用户协议' : 'Terms' }}</router-link>
    </nav>
  </footer>
</template>

<script setup>
import { useI18n } from '../i18n'
const { isZh } = useI18n()
</script>

<style scoped>
.public-footer{display:flex;justify-content:space-between;gap:24px;width:min(100%,1120px);margin:56px auto 0;padding:24px 0 8px;border-top:1px solid #dedbd7;color:#817d78;font:500 11px/1.7 -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}.public-footer div{display:flex;flex-direction:column}.public-footer strong{color:#3b3937;font-size:10px;letter-spacing:.12em}.public-footer nav{display:flex;flex-wrap:wrap;justify-content:flex-end;gap:8px 18px}.public-footer a{color:#696662;text-decoration:none}@media(max-width:640px){.public-footer{flex-direction:column;text-align:center}.public-footer nav{justify-content:center}}
</style>
