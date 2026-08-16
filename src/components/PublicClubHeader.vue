<template>
  <header class="public-header">
    <router-link to="/" class="public-brand" aria-label="Joy Club home">
      <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards New Zealand">
      <span><strong>JOY CLUB</strong><small>PLAY · ENJOY · BELONG</small></span>
    </router-link>
    <nav aria-label="Public navigation">
      <router-link to="/pricing">{{ isZh ? '价格' : 'Pricing' }}</router-link>
      <router-link to="/membership">{{ isZh ? '会员' : 'Membership' }}</router-link>
      <button type="button" @click="toggleLocale" :aria-label="isZh ? 'Switch to English' : '切换到中文'">{{ isZh ? 'EN' : '中文' }}</button>
    </nav>
  </header>
</template>

<script setup>
import { useI18n } from '../i18n'
const { isZh, toggleLocale } = useI18n()
</script>

<style scoped>
.public-header{display:flex;align-items:center;justify-content:space-between;gap:18px;width:min(100%,1120px);margin:0 auto;padding:20px 0}.public-brand{display:flex;align-items:center;gap:12px;color:#17191d;text-decoration:none}.public-brand img{width:72px;height:42px;object-fit:contain;transform:scale(1.45)}.public-brand span{display:flex;flex-direction:column;padding-left:12px;border-left:1px solid #d9d5d0}.public-brand strong{font-size:14px;letter-spacing:.14em}.public-brand small{margin-top:4px;color:#8f8a85;font-size:7px;font-weight:800;letter-spacing:.16em}.public-header nav{display:flex;align-items:center;gap:6px}.public-header nav a,.public-header button{min-height:38px;padding:0 13px;border:0;border-radius:12px;background:transparent;color:#5d5b59;font:700 12px/38px -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;text-decoration:none;white-space:nowrap}.public-header nav a.router-link-active{background:#f4e8e7;color:#c9202d}.public-header button{border:1px solid #dedbd7;background:#fff;cursor:pointer}@media(max-width:520px){.public-header{padding-top:12px}.public-brand{width:78px;overflow:hidden}.public-brand img{width:68px;height:36px;transform:scale(1.8)}.public-brand span{display:none}.public-header nav a,.public-header button{padding:0 10px;font-size:11px}}
</style>
