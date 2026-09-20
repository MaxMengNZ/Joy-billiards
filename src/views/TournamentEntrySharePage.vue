<template>
  <main class="event-page">
    <div class="ambient ambient-red"></div>
    <div class="ambient ambient-gold"></div>

    <section class="event-shell">
      <header class="top-bar">
        <div class="brand">
          <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards New Zealand">
          <div><strong>JOY CLUB</strong><span>PLAY · ENJOY · BELONG</span></div>
        </div>
        <LanguageSwitcher />
      </header>

      <article v-if="loading" class="state-card">
        <div class="spinner"></div>
        <h1>{{ text.loading }}</h1>
      </article>

      <article v-else-if="error || !event" class="state-card">
        <b class="state-mark">!</b>
        <h1>{{ text.notFound }}</h1>
        <p>{{ text.notFoundHint }}</p>
      </article>

      <template v-else>
        <article class="hero" :style="heroStyle">
          <div class="hero-shade"></div>
          <div class="hero-top">
            <span>JOY OFFICIAL</span>
            <button type="button" @click="shareEvent">{{ text.share }} ↗</button>
          </div>
          <div class="hero-copy">
            <p>{{ eventKind }}</p>
            <h1>{{ event.name }}</h1>
            <strong>{{ eventDate }}</strong>
            <span>JOY BILLIARDS · HAMILTON CENTRAL</span>
          </div>
        </article>

        <section class="facts">
          <div><span>{{ text.entryFee }}</span><strong>{{ entryFee }}</strong></div>
          <div><span>{{ text.players }}</span><strong>{{ playerCount }}</strong></div>
          <div><span>{{ text.status }}</span><strong>{{ statusText }}</strong></div>
        </section>

        <article class="detail-card">
          <p class="eyebrow">{{ text.officialEntry }}</p>
          <h2>{{ text.clearReliable }}</h2>
          <p class="description">{{ event.description || text.defaultDescription }}</p>
          <div class="trust"><b>✓</b><span>{{ text.security }}</span></div>
        </article>

        <section class="entry-card">
          <template v-if="canEnter">
            <button class="primary" type="button" @click="createAccount">
              <span>{{ text.createAndEnter }}</span><b>→</b>
            </button>
            <button class="secondary" type="button" @click="openApp">
              {{ text.alreadyMember }}
            </button>
          </template>
          <button v-else class="primary disabled" type="button" disabled>
            <span>{{ statusText }}</span><b>—</b>
          </button>
          <div class="stores">
            <a v-for="option in downloadOptions" :key="option.platform" :href="option.url" target="_blank" rel="noopener">
              {{ option.platform === 'ios' ? 'App Store' : 'Google Play' }}
            </a>
          </div>
          <small>{{ text.appHint }}</small>
        </section>
      </template>

      <footer>
        <strong>JOY BILLIARDS NEW ZEALAND</strong>
        <span>88 Tristram Street, Hamilton Central</span>
      </footer>
    </section>
  </main>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import LanguageSwitcher from '../components/LanguageSwitcher.vue'
import { supabase } from '../config/supabase'
import { useI18n } from '../i18n'
import { downloadOptionsForClient, openAppRouteWithDownloadFallback } from '../utils/appDownload'

const route = useRoute()
const router = useRouter()
const { locale } = useI18n()
const event = ref(null)
const publicEntry = ref(null)
const registrationCount = ref(0)
const loading = ref(true)
const error = ref('')
const downloadOptions = downloadOptionsForClient()
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
const eventId = computed(() => uuid.test(String(route.params.id || '')) ? String(route.params.id) : '')

const copy = {
  zh: {
    loading: '正在载入官方赛事', notFound: '找不到该赛事', notFoundHint: '请检查分享链接，或从 Joy Club App 赛事页面重新进入。',
    share: '分享赛事', entryFee: '报名费', players: '参赛人数', status: '当前状态', free: '免费',
    open: '接受报名', full: '名额已满', soon: '即将开放', closed: '报名已结束',
    officialEntry: '官方赛事报名', clearReliable: '信息清楚，报名可靠',
    defaultDescription: '查看赛事时间、参赛资格、报名费用和当前报名状态。',
    security: '每个分享链接只对应这一场赛事；付款与报名确认由 Joy Club 安全处理。',
    createAndEnter: '创建账户并报名', alreadyMember: '已有 Joy Club App？打开并报名',
    appHint: '已安装 App 的设备会直接进入本赛事；新用户创建账户后仍会保留本赛事入口。',
    weekly: 'JOY WEEKLY', student: 'JOY STUDENT', official: 'JOY OFFICIAL EVENT',
  },
  en: {
    loading: 'Loading the official event', notFound: 'Tournament not found', notFoundHint: 'Check the shared link or reopen the event from the Joy Club App.',
    share: 'Share event', entryFee: 'ENTRY FEE', players: 'PLAYERS', status: 'STATUS', free: 'Free',
    open: 'Registration open', full: 'Full', soon: 'Opening soon', closed: 'Registration closed',
    officialEntry: 'OFFICIAL EVENT ENTRY', clearReliable: 'Clear details. Secure entry.',
    defaultDescription: 'Review the event time, eligibility, entry fee and current registration status.',
    security: 'Each shared link belongs to this event only. Joy Club securely handles payment and entry confirmation.',
    createAndEnter: 'Create account & enter', alreadyMember: 'Already have Joy Club? Open the App',
    appHint: 'Installed devices open this exact event. New accounts keep this event ready after registration.',
    weekly: 'JOY WEEKLY', student: 'JOY STUDENT', official: 'JOY OFFICIAL EVENT',
  },
}
const text = computed(() => copy[locale.value] || copy.en)
const options = computed(() => event.value?.event_options || {})
const eventKind = computed(() => {
  if (options.value.kind === 'weekly_pro') return text.value.weekly
  if (options.value.kind === 'weekly_student') return text.value.student
  return locale.value === 'zh'
    ? (options.value.customLabel || text.value.official)
    : (options.value.customLabelEn || text.value.official)
})
const eventDate = computed(() => new Intl.DateTimeFormat(locale.value === 'zh' ? 'zh-NZ' : 'en-NZ', {
  dateStyle: 'long', timeStyle: 'short', timeZone: 'Pacific/Auckland',
}).format(new Date(event.value.start_date)))
const entryFee = computed(() => Number(event.value?.entry_fee || 0) > 0 ? `NZ$${Number(event.value.entry_fee).toFixed(2)}` : text.value.free)
const playerCount = computed(() => `${registrationCount.value}${event.value?.max_players ? ` / ${event.value.max_players}` : ''}`)
const registrationNotStarted = computed(() => Boolean(publicEntry.value?.registrationOpensAt && new Date(publicEntry.value.registrationOpensAt).getTime() > Date.now()))
const registrationEnded = computed(() => Boolean(publicEntry.value?.registrationClosesAt && new Date(publicEntry.value.registrationClosesAt).getTime() <= Date.now()))
const isFull = computed(() => Boolean(event.value?.max_players && registrationCount.value >= event.value.max_players))
const statusAllowsEntry = computed(() => ['registration', 'upcoming'].includes(event.value?.status))
const canEnter = computed(() => statusAllowsEntry.value && !registrationNotStarted.value && !registrationEnded.value && !isFull.value)
const statusText = computed(() => registrationNotStarted.value ? text.value.soon : isFull.value ? text.value.full : canEnter.value ? text.value.open : text.value.closed)
const heroStyle = computed(() => {
  const banner = options.value.bannerUrl
  return banner ? { backgroundImage: `url(${JSON.stringify(String(banner)).slice(1, -1)})` } : {}
})
const appRoute = computed(() => `/tournament/${eventId.value}?entrySource=share&entryAction=register`)

const createAccount = () => router.push({ path: '/register', query: { event: eventId.value } })
const openApp = () => {
  if (!openAppRouteWithDownloadFallback(appRoute.value)) document.querySelector('.stores')?.scrollIntoView({ behavior: 'smooth' })
}
const shareEvent = async () => {
  const url = window.location.href
  if (navigator.share) return navigator.share({ title: event.value.name, text: text.value.officialEntry, url }).catch(() => undefined)
  await navigator.clipboard?.writeText(url)
}

onMounted(async () => {
  if (!eventId.value) { error.value = 'INVALID_EVENT'; loading.value = false; return }
  try {
    const [eventResult, entryResult, registrationsResult] = await Promise.all([
      supabase.from('tournaments').select('*').eq('id', eventId.value).maybeSingle(),
      supabase.rpc('app_get_public_tournament_entry', { p_tournament_id: eventId.value }),
      supabase.from('tournament_registrations').select('id', { count: 'exact', head: true }).eq('tournament_id', eventId.value).eq('status', 'registered'),
    ])
    if (eventResult.error) throw eventResult.error
    event.value = eventResult.data
    publicEntry.value = entryResult.error ? null : entryResult.data
    registrationCount.value = registrationsResult.error ? Number(entryResult.data?.confirmedCount || 0) : Number(registrationsResult.count || 0)
    if (!event.value) error.value = 'NOT_FOUND'
  } catch (reason) {
    console.warn('Unable to load shared tournament', reason)
    error.value = 'LOAD_FAILED'
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.event-page,.event-page *{box-sizing:border-box}.event-page{--red:#e52b36;min-height:100svh;position:relative;overflow:hidden;padding:27px 16px 42px;background:radial-gradient(circle at 50% -8%,#fff 0,#f8f5f1 36%,#eef1f4 100%);color:#17191d;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}.event-shell{position:relative;z-index:2;width:min(100%,560px);margin:0 auto}.ambient{position:absolute;border-radius:50%;pointer-events:none}.ambient-red{width:350px;height:350px;left:-230px;top:18%;background:rgba(229,43,54,.055)}.ambient-gold{width:380px;height:380px;right:-260px;bottom:3%;border:50px solid rgba(202,155,74,.055)}.top-bar{display:flex;align-items:center;justify-content:space-between;gap:14px;margin-bottom:19px}.brand{display:flex;align-items:center;gap:13px;min-width:0}.brand img{width:96px;height:50px;object-fit:contain}.brand>div{display:flex;flex-direction:column;padding-left:13px;border-left:1px solid #d5d8dc}.brand strong{font-size:15px;letter-spacing:.14em}.brand span{margin-top:4px;color:#999da4;font-size:6px;font-weight:900;letter-spacing:.18em}.hero{position:relative;min-height:360px;overflow:hidden;display:flex;flex-direction:column;justify-content:space-between;padding:23px;border-radius:31px;background:linear-gradient(145deg,#25181a,#111318 72%);background-size:cover;background-position:center;box-shadow:0 24px 58px rgba(24,18,20,.2);color:#fff}.hero-shade{position:absolute;inset:0;background:linear-gradient(180deg,rgba(4,7,8,.08),rgba(4,7,8,.2) 40%,rgba(4,7,8,.91))}.hero-top,.hero-copy{position:relative;z-index:1}.hero-top{display:flex;align-items:center;justify-content:space-between}.hero-top>span{padding:7px 11px;border-radius:99px;background:var(--red);font-size:8px;font-weight:950;letter-spacing:.12em}.hero-top button{border:1px solid rgba(255,255,255,.34);border-radius:99px;padding:8px 11px;background:rgba(17,19,24,.35);color:#fff;font-size:9px;font-weight:850}.hero-copy p{margin:0 0 7px;color:#e6c370;font-size:10px;font-weight:900;letter-spacing:.16em}.hero-copy h1{margin:0;font-size:clamp(31px,8vw,43px);line-height:1.05;letter-spacing:-.035em}.hero-copy strong,.hero-copy span{display:block}.hero-copy strong{margin-top:16px;font-size:14px}.hero-copy span{margin-top:7px;color:rgba(255,255,255,.68);font-size:8px;font-weight:800;letter-spacing:.1em}.facts{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-top:11px}.facts>div{min-width:0;min-height:82px;padding:13px;border:1px solid #e5e7ea;border-radius:17px;background:#fff}.facts span,.facts strong{display:block}.facts span{color:#969aa2;font-size:7px;font-weight:900;letter-spacing:.1em}.facts strong{margin-top:9px;font-size:14px;overflow-wrap:anywhere}.detail-card,.entry-card,.state-card{margin-top:11px;padding:22px;border:1px solid rgba(255,255,255,.94);border-radius:25px;background:rgba(255,255,255,.92);box-shadow:0 14px 37px rgba(29,34,43,.07)}.eyebrow{margin:0;color:var(--red);font-size:8px;font-weight:950;letter-spacing:.18em}.detail-card h2{margin:7px 0 0;font-size:22px}.description{margin:10px 0 0;color:#70757d;font-size:12px;line-height:1.7}.trust{display:flex;gap:9px;margin-top:16px;padding-top:15px;border-top:1px solid #eceef0;color:#6f747c;font-size:10px;line-height:1.55}.trust b{color:#168158}.primary,.secondary{width:100%;min-height:55px;border-radius:16px;font:inherit;font-weight:900;cursor:pointer}.primary{display:flex;align-items:center;justify-content:space-between;padding:0 19px;border:0;background:linear-gradient(110deg,#ef1f2c,#d91d29);box-shadow:0 12px 24px rgba(229,43,54,.22);color:#fff}.primary.disabled{opacity:.52;box-shadow:none}.secondary{margin-top:9px;border:1px solid #dfe1e5;background:#fff;color:#24272c}.stores{display:flex;justify-content:center;gap:15px;margin-top:14px}.stores a{color:#31343a;font-size:10px;font-weight:850}.entry-card small{display:block;margin-top:12px;color:#969aa2;font-size:8px;line-height:1.55;text-align:center}.state-card{min-height:330px;display:grid;place-items:center;align-content:center;text-align:center}.state-card h1{margin:13px 0 0;font-size:23px}.state-card p{color:#7c8188;font-size:12px}.state-mark{width:58px;height:58px;display:grid;place-items:center;border-radius:20px;background:#fff0f1;color:var(--red);font-size:24px}.spinner{width:48px;height:48px;border:3px solid #eceef1;border-top-color:var(--red);border-radius:50%;animation:spin .8s linear infinite}footer{display:flex;flex-direction:column;gap:4px;margin-top:23px;color:#8a8e95;font-size:8px;text-align:center}footer strong{color:#625b50;font-size:7px;letter-spacing:.13em}@keyframes spin{to{transform:rotate(360deg)}}@media(max-width:390px){.event-page{padding-left:10px;padding-right:10px}.hero{min-height:330px;padding:19px}.facts{gap:5px}.facts>div{padding:11px 9px}.detail-card,.entry-card{padding:19px 17px}.brand img{width:82px}.brand strong{font-size:13px}}
</style>
