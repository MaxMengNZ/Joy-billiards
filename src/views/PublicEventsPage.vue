<template>
  <main class="events-page">
    <div class="page-shell">
      <PublicClubHeader />
      <section class="events-intro" aria-labelledby="events-title">
        <div class="intro-copy">
          <h1 id="events-title">{{ isZh ? '下一场，\n一起上场。' : 'Your next match\nstarts here.' }}</h1>
          <p>{{ isZh ? '从每周的熟悉对手，到公开赛的新挑战。找到你的比赛，来 JOY 打一场。' : 'Weekly rivalries. New challenges. Find your tournament and join us at the tables.' }}</p>
          <router-link class="intro-link" :to="{ path: '/events', hash: '#event-list' }">{{ isZh ? '查看赛事安排' : 'Explore the schedule' }}<span aria-hidden="true">↘</span></router-link>
        </div>
        <router-link v-if="featured" :to="eventSharePath(featured)" class="next-event" :aria-label="`${labels.details}: ${featured.name}`">
          <img v-if="bannerFor(featured) && !failedImages.has(featured.id)" :src="bannerFor(featured)" alt="" @error="imageFailed(featured.id)" />
          <div class="next-content">
            <span class="next-label">{{ featured.status === 'in_progress' ? labels.live : (isZh ? '即将开赛' : 'UP NEXT') }}</span>
            <h2>{{ featured.name }}</h2>
            <p>{{ dateFor(featured).date }}</p>
            <span class="next-action">{{ labels.details }} <span aria-hidden="true">↗</span></span>
          </div>
        </router-link>
        <div v-else class="intro-wordmark" aria-hidden="true">JOY<span>PLAY · ENJOY · BELONG</span></div>
      </section>

      <section id="event-list" class="event-list" aria-labelledby="schedule-title" :aria-busy="loading">
        <div class="list-heading">
          <div><h2 id="schedule-title">{{ isZh ? '赛事安排' : 'The schedule' }}</h2><p>{{ isZh ? '时间均为举办门店的当地时间' : 'All times are local to the host venue' }}</p></div>
          <label class="venue-picker">{{ isZh ? '举办门店' : 'Host venue' }}
            <select v-model="venueId" :disabled="venuesLoading">
              <option value="all">{{ isZh ? '全部门店' : 'All venues' }}</option>
              <option v-for="venue in venues" :key="venue.id" :value="venue.id">{{ venue.name }}</option>
            </select>
          </label>
        </div>
        <div class="kind-filters" role="group" :aria-label="isZh ? '赛事类型' : 'Event type'">
          <button v-for="value in EVENT_KINDS" :key="value" type="button" :aria-pressed="kind === value" @click="kind = value">{{ kindLabels[value] }}</button>
        </div>
        <div v-if="error" class="empty-state" role="alert">
          <h3>{{ isZh ? '赛事暂时未能载入' : 'The schedule couldn’t load' }}</h3>
          <p>{{ isZh ? '请检查网络后重试，不影响 App 内的报名记录。' : 'Check your connection and try again. Your App entries are unchanged.' }}</p>
          <button type="button" @click="retryLoad">{{ isZh ? '重新载入' : 'Try again' }}</button>
        </div>
        <div v-else-if="loading && !events.length" class="loading-grid" role="status">
          <p>{{ isZh ? '正在读取赛事安排…' : 'Loading the schedule…' }}</p>
          <div v-for="n in 3" :key="n" class="skeleton" aria-hidden="true"></div>
        </div>
        <template v-else>
          <div v-if="!events.length" class="empty-state">
            <h3>{{ isZh ? '这个分类暂无赛事' : 'No tournaments in this selection' }}</h3>
            <p>{{ isZh ? '换个分类或门店，看看还有哪些比赛。' : 'Try another event type or venue to find your next match.' }}</p>
            <button type="button" @click="resetFilters">{{ isZh ? '查看全部赛事' : 'Show all events' }}</button>
          </div>
          <section v-for="group in groups" :key="group.key" class="schedule-group" :aria-labelledby="`group-${group.key}`">
            <div class="group-heading"><h3 :id="`group-${group.key}`"><span v-if="group.key === 'live'" class="live-dot" aria-hidden="true"></span>{{ group.title }}</h3><span>{{ group.events.length }} {{ isZh ? '场赛事' : 'events' }}</span></div>
            <div class="events-grid">
              <router-link v-for="event in group.events" :key="event.id" :to="eventSharePath(event)" class="event-card" :aria-label="`${event.name} · ${labels.details}`">
                <div class="event-poster">
                  <img v-if="bannerFor(event) && !failedImages.has(event.id)" :src="bannerFor(event)" alt="" loading="lazy" @error="imageFailed(event.id)" />
                  <div v-else class="poster-placeholder" aria-hidden="true"><strong>JOY</strong><span>PLAY · ENJOY · BELONG</span></div>
                  <span class="event-status" :class="{ live: event.status === 'in_progress' }">{{ statusFor(event) }}</span>
                </div>
                <div class="card-content">
                  <p class="event-kind">{{ kindLabels[publicEventKind(event)] }}</p>
                  <h4>{{ event.name }}</h4>
                  <p class="event-date"><time :datetime="event.start_date">{{ dateFor(event).date }}</time></p>
                  <p class="event-venue">{{ venueFor(event)?.name || (isZh ? '门店信息见详情' : 'See event for venue') }}<span v-if="dateFor(event).zone"> · {{ dateFor(event).zone }}</span></p>
                  <div class="card-bottom"><strong>{{ feeFor(event) }}</strong><span>{{ labels.details }}<span aria-hidden="true"> ↗</span></span></div>
                </div>
              </router-link>
            </div>
          </section>
          <div v-if="hasMore || loading" class="load-more"><button type="button" :disabled="loading" @click="loadEvents(true)">{{ loading ? (isZh ? '正在载入…' : 'Loading…') : (isZh ? '查看更多赛事' : 'Load more events') }}</button></div>
        </template>
      </section>
      <aside class="entry-note"><strong>{{ isZh ? '找到心仪的赛事？' : 'Found your next match?' }}</strong><p>{{ isZh ? '打开赛事详情，查看完整规则与报名方式。已有 App 的选手可继续前往 App；新选手可通过现有流程创建账号。' : 'Open an event for full rules and entry options. Continue in the App, or create your JOY account through the existing registration flow.' }}</p></aside>
      <PublicClubFooter />
    </div>
  </main>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import PublicClubHeader from '../components/PublicClubHeader.vue'
import PublicClubFooter from '../components/PublicClubFooter.vue'
import { useI18n } from '../i18n'
import { supabase } from '../config/supabase'
import { eventSharePath, safeEventBanner } from '../utils/eventShare.js'
import { EVENT_KINDS, EVENT_PAGE_SIZE, orderPublicEvents, publicEventDate, publicEventFee, publicEventGroup, publicEventKind } from '../utils/publicEvents.js'
import { publicEventsQuery } from '../utils/publicEventsQuery.js'

const { isZh } = useI18n()
const venues = ref([]), events = ref([]), venueId = ref('hamilton-central'), kind = ref('all')
const loading = ref(true), venuesLoading = ref(true), error = ref(false), hasMore = ref(false)
const failedImages = ref(new Set())
let request = 0, controller, offset = 0, liveOffset = 0, disposed = false
let venueController
const language = computed(() => isZh.value ? 'zh' : 'en')
const labels = computed(() => ({ details: isZh.value ? '查看赛事' : 'View event', live: isZh.value ? '进行中' : 'LIVE NOW' }))
const kindLabels = computed(() => isZh.value
  ? { all: '全部赛事', weekly_pro: '周赛', weekly_student: '学生赛', open: '公开赛', custom: '挑战赛及其他' }
  : { all: 'All events', weekly_pro: 'Weekly', weekly_student: 'Student', open: 'Open', custom: 'Challenges & more' })
const featured = computed(() => events.value[0])
const venueFor = event => venues.value.find(venue => venue.id === event.venue_id)
const dateFor = event => publicEventDate(event, venueFor(event), language.value)
const feeFor = event => publicEventFee(event, venueFor(event), language.value)
const bannerFor = event => safeEventBanner(event.event_options?.bannerUrl)
const imageFailed = id => { failedImages.value = new Set([...failedImages.value, id]) }
const statusFor = event => event.status === 'in_progress' ? labels.value.live : event.status === 'registration' ? (isZh.value ? '报名中' : 'Registration') : (isZh.value ? '即将举行' : 'Upcoming')
const groups = computed(() => ['live', 'soon', 'later'].map((key, index) => ({
  key, title: (isZh.value ? ['正在进行', '未来七天', '后续赛事'] : ['On the tables now', 'In the next 7 days', 'Coming up'])[index],
  events: events.value.filter(event => publicEventGroup(event) === key),
})).filter(group => group.events.length))

async function loadEvents(append = false) {
  const seq = ++request
  controller?.abort()
  controller = new AbortController()
  const currentController = controller
  const timeout = setTimeout(() => currentController.abort(), 15000)
  loading.value = true; error.value = false
  if (!append) { events.value = []; offset = 0; liveOffset = 0; hasMore.value = false }
  try {
    const options = { venueId: venueId.value, kind: kind.value, signal: currentController.signal }
    const [liveResult, futureResult] = await Promise.all([
      publicEventsQuery(supabase, { ...options, live: true, offset: liveOffset }),
      publicEventsQuery(supabase, { ...options, live: false, offset }),
    ])
    if (liveResult.error || futureResult.error) throw liveResult.error || futureResult.error
    if (seq !== request) return
    const liveRows = liveResult.data || [], futureRows = futureResult.data || []
    const rows = [...liveRows, ...futureRows]
    const available = new Set(venues.value.map(venue => venue.id))
    const merged = [...(append ? events.value : []), ...rows].filter(event => available.has(event.venue_id))
    events.value = orderPublicEvents([...new Map(merged.map(event => [event.id, event])).values()])
    offset += futureRows.length; liveOffset += liveRows.length
    hasMore.value = liveRows.length === EVENT_PAGE_SIZE || futureRows.length === EVENT_PAGE_SIZE
  } catch {
    if (seq === request) error.value = true
  } finally {
    clearTimeout(timeout)
    if (seq === request) loading.value = false
  }
}
function resetFilters() {
  if (venueId.value === 'all' && kind.value === 'all') void loadEvents()
  else { venueId.value = 'all'; kind.value = 'all' }
}
watch([venueId, kind], () => { if (!venuesLoading.value) void loadEvents() })
watch(isZh, () => { document.title = isZh.value ? '赛事安排 · JOY CLUB' : 'Events · JOY CLUB' })
async function loadVenues() {
  venueController?.abort()
  venueController = new AbortController()
  const currentController = venueController
  loading.value = true; error.value = false; venuesLoading.value = true
  const timeout = setTimeout(() => currentController.abort(), 15000)
  try {
    const result = await supabase.from('venues').select('id,name,address,timezone,currency').eq('status', 'active').order('name').limit(50).abortSignal(venueController.signal)
    if (result.error) throw result.error
    if (disposed) return
    venues.value = result.data || []
    if (!venues.value.some(venue => venue.id === venueId.value)) venueId.value = 'all'
    venuesLoading.value = false
    void loadEvents()
  } catch {
    if (!disposed) { venuesLoading.value = false; loading.value = false; error.value = true }
  } finally { clearTimeout(timeout) }
}
function retryLoad() {
  if (venues.value.length) void loadEvents()
  else void loadVenues()
}
onMounted(() => {
  document.title = isZh.value ? '赛事安排 · JOY CLUB' : 'Events · JOY CLUB'
  void loadVenues()
})
onUnmounted(() => { disposed = true; ++request; controller?.abort(); venueController?.abort() })
</script>

<style scoped>
.events-page{--red:#d9212f;--ink:#191817;min-height:100svh;background:#f7f5f2;color:var(--ink);padding:0 20px 36px;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}.page-shell{max-width:1120px;margin:auto}.events-intro{display:grid;grid-template-columns:1fr 1fr;overflow:hidden;border-radius:30px;background:#191719;color:#fff}.intro-copy{padding:42px}.intro-copy h1{white-space:pre-line;margin:0 0 20px;font-size:clamp(32px,4.2vw,54px);font-weight:800;letter-spacing:-.035em;line-height:1.1}.intro-copy p{max-width:390px;margin:0;color:#d1ccca;font-size:14px;line-height:1.8}.intro-link{display:inline-flex;align-items:center;gap:25px;color:#fff;background:var(--red);padding:13px 18px;min-height:46px;box-sizing:border-box;border-radius:12px;margin-top:24px;font-size:13px;font-weight:750;text-decoration:none}.next-event{position:relative;display:flex;align-items:end;min-height:330px;color:#fff;text-decoration:none;background:#302826;isolation:isolate}.next-event>img{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;z-index:-2}.next-event:after{content:"";position:absolute;inset:0;background:linear-gradient(180deg,rgba(15,13,13,.08),rgba(15,13,13,.9));z-index:-1}.next-content{padding:30px;width:100%;box-sizing:border-box}.next-label{display:inline-block;font-size:11px;font-weight:800;letter-spacing:.08em;color:#f3d5a5}.next-content h2{margin:10px 0;font-size:23px;line-height:1.3;text-wrap:balance}.next-content p{font-size:13px;margin:0;color:#eee5df}.next-action{display:flex;justify-content:space-between;margin-top:20px;padding-top:16px;border-top:1px solid #ffffff45;font-size:12px;font-weight:750}.intro-wordmark{display:flex;flex-direction:column;justify-content:center;align-items:center;font-size:100px;font-weight:900;color:#bfa474}.intro-wordmark span{font-size:10px;letter-spacing:.15em;color:#d1ccca}.event-list{scroll-margin-top:24px;margin-top:44px}.list-heading{display:flex;align-items:end;justify-content:space-between;gap:20px}.list-heading h2{font-size:28px;letter-spacing:-.025em;margin:0 0 8px}.list-heading p{color:#6a625d;font-size:12px;margin:0}.venue-picker{display:flex;flex-direction:column;gap:7px;font-size:11px;color:#625c57}.venue-picker select{max-width:300px;min-height:44px;padding:0 35px 0 13px;border:1px solid #d8d1c9;border-radius:12px;background:#fff;color:#272320;font:600 12px inherit}.kind-filters{display:flex;flex-wrap:wrap;gap:8px;margin:24px 0 8px}.kind-filters button{border:1px solid #ded8d2;border-radius:12px;min-height:42px;padding:0 16px;background:#fff;color:#5e5751;font:650 12px -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;cursor:pointer}.kind-filters button[aria-pressed=true]{background:#191719;color:#fff;border-color:#191719}.schedule-group{margin-top:28px}.group-heading{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:14px}.group-heading h3{display:flex;align-items:center;gap:8px;margin:0;font-size:17px;letter-spacing:-.015em}.group-heading>span{font-size:11px;color:#6f665f}.live-dot{width:8px;height:8px;border-radius:50%;background:#d9212f}.events-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:18px}.event-card{display:flex;flex-direction:column;border:1px solid #e2ddd7;border-radius:16px;background:#fff;overflow:hidden;color:inherit;text-decoration:none;transition:transform 180ms ease-out,border-color 180ms ease-out}.event-card:hover{transform:translateY(-3px);border-color:#c9afa0}.event-poster{position:relative;aspect-ratio:1.95;background:#e8e2da;overflow:hidden}.event-poster img{width:100%;height:100%;object-fit:cover}.poster-placeholder{height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;background:#242020;color:#dcc6a2}.poster-placeholder strong{font-size:42px;letter-spacing:.03em}.poster-placeholder span{font-size:8px;letter-spacing:.15em;margin-top:7px}.event-status{position:absolute;top:12px;left:12px;border-radius:7px;background:#fff;color:#4e3e32;padding:6px 9px;font-size:10px;font-weight:800}.event-status.live{background:#d9212f;color:#fff}.card-content{padding:20px;display:flex;flex-direction:column;flex:1}.event-kind{margin:0 0 9px;color:#9b2730;font-size:11px;font-weight:750}.card-content h4{font-size:17px;line-height:1.4;letter-spacing:-.015em;margin:0 0 16px;overflow-wrap:anywhere}.event-date{font-size:12px;font-weight:700;margin:0 0 7px}.event-venue{font-size:11px;line-height:1.6;color:#6d635b;margin:0 0 20px}.event-venue span{display:block;font-size:10px;color:#7b7067}.card-bottom{display:flex;justify-content:space-between;align-items:center;gap:10px;margin-top:auto;border-top:1px solid #eee9e3;padding-top:15px}.card-bottom strong{font-size:14px}.card-bottom>span{color:#bc2531;font-weight:750;font-size:11px}.empty-state{padding:54px 20px;text-align:center;background:#fff;border-radius:16px;margin-top:20px}.empty-state h3{font-size:20px;margin:0 0 12px}.empty-state p{color:#685f57;font-size:13px;line-height:1.7}.empty-state button,.load-more button{min-height:44px;border:1px solid #cec5bb;border-radius:12px;padding:0 20px;background:#fff;color:#28221f;font-size:12px;font-weight:700;cursor:pointer}.load-more{display:flex;justify-content:center;margin-top:30px}.load-more button:disabled{opacity:.6;cursor:wait}.loading-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:18px}.loading-grid>p{grid-column:1/-1;color:#6d635b;font-size:13px}.skeleton{height:300px;border-radius:16px;background:#ebe6df}.entry-note{margin-top:44px;padding:25px 0;border-top:1px solid #ded8d1;display:grid;grid-template-columns:1fr 2fr;gap:28px}.entry-note strong{font-size:17px}.entry-note p{font-size:12px;line-height:1.8;color:#655b53;margin:0;max-width:620px}.events-page :is(a,button,select):focus-visible{outline:3px solid #d9212f;outline-offset:4px}.events-page ::selection{background:#f1c7ca;color:#311516}@media(max-width:1000px){.events-grid{grid-template-columns:repeat(2,minmax(0,1fr))}.intro-copy{padding:32px}.next-content{padding:24px}.next-content h2{font-size:20px}}@media(max-width:600px){.events-page{padding:0 12px 24px}.events-intro{grid-template-columns:1fr;border-radius:24px}.intro-copy{padding:30px 24px}.intro-copy h1{font-size:36px}.intro-copy p{font-size:13px}.next-event{min-height:235px}.next-content{padding:22px 24px}.next-content h2{font-size:20px}.event-list{margin-top:32px}.list-heading{align-items:stretch;flex-direction:column;gap:18px}.venue-picker select{max-width:100%;width:100%}.list-heading h2{font-size:26px}.kind-filters{flex-wrap:nowrap;overflow-x:auto;padding-bottom:8px;margin-top:18px}.kind-filters button{flex:none;padding:0 13px}.events-grid,.loading-grid{grid-template-columns:1fr;gap:16px}.event-poster{aspect-ratio:2.15}.card-content{padding:20px}.card-content h4{font-size:19px}.entry-note{grid-template-columns:1fr;gap:10px;margin-top:32px}.intro-wordmark{display:none}}@media(prefers-reduced-motion:reduce){.event-card{transition:none}.event-card:hover{transform:none}}
</style>
