<template>
  <main class="short-link-state">
    <section>
      <div v-if="!error" class="spinner" aria-hidden="true"></div>
      <b v-else aria-hidden="true">!</b>
      <h1>{{ error ? copy.unavailable : copy.loading }}</h1>
      <p v-if="error">{{ copy.hint }}</p>
      <router-link v-if="error" to="/">{{ copy.home }}</router-link>
    </section>
  </main>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../config/supabase'
import { useI18n } from '../i18n'

const route = useRoute()
const router = useRouter()
const { locale } = useI18n()
const error = ref(false)
const copy = computed(() => locale.value === 'zh'
  ? { loading: '正在打开官方赛事', unavailable: '赛事链接无效', hint: '请向赛事主办方索取最新链接。', home: '返回 JOY CLUB' }
  : { loading: 'Opening the official event', unavailable: 'Tournament link unavailable', hint: 'Please request the latest link from the organiser.', home: 'Back to JOY CLUB' })

onMounted(async () => {
  const reference = String(route.params.reference || '').trim()
  if (!/^[a-z0-9][a-z0-9-]{2,46}[a-z0-9]$/i.test(reference)) {
    error.value = true
    return
  }

  const code = reference.toUpperCase()
  const alias = reference.toLowerCase()
  const result = await supabase
    .from('tournaments')
    .select('id')
    .or(`share_code.eq.${code},share_alias.eq.${alias}`)
    .maybeSingle()

  if (result.error || !result.data?.id) {
    error.value = true
    return
  }

  await router.replace(`/app/event/${result.data.id}`)
})
</script>

<style scoped>
.short-link-state{min-height:100svh;display:grid;place-items:center;padding:24px;background:radial-gradient(circle at 50% -8%,#fff 0,#f8f5f1 42%,#eef1f4 100%);font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;color:#17191d}.short-link-state section{width:min(100%,430px);padding:48px 30px;border:1px solid #fff;border-radius:28px;background:rgba(255,255,255,.92);box-shadow:0 18px 48px rgba(29,34,43,.09);text-align:center}.spinner{width:48px;height:48px;margin:0 auto;border:3px solid #eceef1;border-top-color:#ed1c2e;border-radius:50%;animation:spin .8s linear infinite}.short-link-state b{width:54px;height:54px;display:grid;place-items:center;margin:0 auto;border-radius:18px;background:#fff0f1;color:#ed1c2e;font-size:24px}.short-link-state h1{margin:18px 0 0;font-size:23px}.short-link-state p{margin:10px 0 0;color:#777d86;font-size:13px;line-height:1.6}.short-link-state a{display:inline-block;margin-top:22px;padding:13px 19px;border-radius:14px;background:#ed1c2e;color:#fff;font-size:12px;font-weight:800;text-decoration:none}@keyframes spin{to{transform:rotate(360deg)}}
</style>
