<template>
  <main class="share-page">
    <div class="ambient ambient-one"></div>
    <div class="ambient ambient-two"></div>

    <section class="share-shell">
      <header class="brand">
        <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards New Zealand" class="brand-logo">
        <div class="brand-copy">
          <strong>JOY CLUB</strong>
          <span>BY JOY BILLIARDS NZ</span>
        </div>
      </header>

      <article class="share-card" :class="{ 'honour-card': kind === 'honours' }">
        <div class="card-kicker">{{ kind === 'honours' ? 'MONTHLY HONOURS' : 'JOY PLAYER CARD' }}</div>
        <div v-if="loading" class="loading-orb"></div>
        <template v-else>
          <div class="avatar" :class="{ placeholder: !profile.avatar_url }">
            <img v-if="profile.avatar_url" :src="profile.avatar_url" :alt="profile.name">
            <span v-else>{{ initials }}</span>
          </div>
          <div v-if="kind === 'honours'" class="medal">{{ medal }}</div>
          <h1>{{ profile.name }}</h1>
          <p class="level">{{ subtitle }}</p>
          <div class="rule"></div>
          <p class="invitation">
            {{ kind === 'honours'
              ? '这份成绩值得被记录，也值得与你分享。'
              : '查看球员档案、赛事成绩与 JOY 荣誉。' }}
          </p>
        </template>
      </article>

      <section class="join-card">
        <div class="join-copy">
          <span class="eyebrow">PLAY · ENJOY · BELONG</span>
          <h2>加入 Joy Club</h2>
          <p>报名赛事、查看排行榜、领取会员礼遇，并记录你的每一次进步。</p>
        </div>

        <button class="primary-action" type="button" @click="openApp">
          <span>打开 Joy Club App</span><span aria-hidden="true">↗</span>
        </button>
        <router-link class="secondary-action" :to="registerLink">
          免费注册 JOY 账号
        </router-link>
        <a class="store-action" href="https://apps.apple.com/app/id6796553031" target="_blank" rel="noopener">
          <span class="apple">●</span>
          <span><small>Download on the</small>App Store</span>
        </a>
        <p class="app-hint">尚未正式上架时，可先完成注册；已受邀的测试用户请通过 TestFlight 安装。</p>
      </section>

      <footer>
        <strong>JOY BILLIARDS NEW ZEALAND</strong>
        <span>88 Tristram Street, Hamilton Central</span>
        <nav><router-link to="/privacy-policy">隐私政策</router-link><router-link to="/terms-of-service">用户协议</router-link></nav>
      </footer>
    </section>
  </main>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '../config/supabase'

const props = defineProps({ kind: { type: String, default: 'player' } })
const route = useRoute()
const loading = ref(true)
const profile = reactive({ name: props.kind === 'honours' ? 'JOY 月榜荣耀球员' : 'JOY 球员', avatar_url: '', ranking_level: '' })
const year = Number(route.query.year) || new Date().getFullYear()
const month = Number(route.query.month) || new Date().getMonth() + 1

const initials = computed(() => profile.name.trim().slice(0, 2).toUpperCase() || 'JOY')
const registerLink = computed(() => ({
  path: '/register',
  query: {
    source: props.kind === 'honours' ? 'monthly-honours-share' : 'player-card-share',
    ...(route.params.id ? { ref: String(route.params.id) } : {}),
  },
}))
const subtitle = computed(() => props.kind === 'honours'
  ? `${year} 年 ${month} 月 · JOY OFFICIAL PODIUM`
  : String(profile.ranking_level || 'JOY PLAYER').replaceAll('_', ' ').toUpperCase())
const medal = computed(() => {
  const place = Number(route.query.place)
  return place === 2 ? '🥈' : place === 3 ? '🥉' : '🏆'
})

const loadPlayer = async () => {
  const playerId = props.kind === 'honours' ? route.query.player : route.params.id
  if (!playerId) return
  const { data } = await supabase
    .from('users')
    .select('name,avatar_url,ranking_level')
    .eq('id', String(playerId))
    .maybeSingle()
  if (data) Object.assign(profile, data)
}

const openApp = () => {
  const path = props.kind === 'honours'
    ? `/monthly-honours?year=${year}&month=${month}`
    : `/player/${encodeURIComponent(String(route.params.id || ''))}`
  window.location.href = `joybilliardsapp:///${path.replace(/^\//, '')}`
}

onMounted(async () => {
  try { await loadPlayer() } catch (error) { console.warn('Unable to load shared player preview', error) }
  finally { loading.value = false }
})
</script>

<style scoped>
.share-page{--red:#e52b36;--gold:#c99b4c;min-height:100svh;overflow:hidden;position:relative;background:radial-gradient(circle at 50% -10%,#fff 0,#f8f4ef 36%,#f3f4f6 74%,#eceef1 100%);color:#191b20;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;padding:28px 18px 42px}.share-shell{width:min(100%,520px);margin:0 auto;position:relative;z-index:1}.ambient{position:absolute;border-radius:999px;filter:blur(1px);pointer-events:none}.ambient-one{width:290px;height:290px;background:rgba(229,43,54,.055);top:14%;left:-150px}.ambient-two{width:340px;height:340px;border:46px solid rgba(201,155,76,.05);right:-220px;bottom:8%}.brand{display:flex;align-items:center;justify-content:center;gap:15px;margin:4px 0 24px}.brand-logo{width:104px;height:54px;object-fit:contain}.brand-copy{border-left:1px solid #d7d9de;padding-left:15px;display:flex;flex-direction:column}.brand-copy strong{font-size:17px;letter-spacing:.13em}.brand-copy span{font-size:8px;letter-spacing:.19em;color:#8a8e96;margin-top:4px;font-weight:700}.share-card{position:relative;min-height:320px;border-radius:32px;padding:30px 26px;text-align:center;background:linear-gradient(145deg,#25161a,#111318 70%);box-shadow:0 24px 55px rgba(23,16,18,.19);overflow:hidden}.share-card:before{content:"8";position:absolute;right:-16px;bottom:-75px;color:rgba(255,255,255,.035);font-size:240px;font-family:Georgia,serif;font-weight:800}.share-card:after{content:"";position:absolute;width:200px;height:200px;border:34px solid rgba(229,43,54,.07);border-radius:50%;top:-125px;left:-95px}.honour-card{background:linear-gradient(145deg,#281d10,#111318 70%)}.card-kicker{position:relative;z-index:1;color:#d7ad65;font-size:9px;letter-spacing:.23em;font-weight:800}.avatar{width:94px;height:94px;border:3px solid #d6aa58;box-shadow:0 0 0 7px rgba(214,170,88,.09);border-radius:50%;margin:25px auto 14px;overflow:hidden;display:grid;place-items:center;background:#722630;color:#fff;font-size:25px;font-weight:900}.avatar img{width:100%;height:100%;object-fit:cover}.medal{position:absolute;top:58px;right:calc(50% - 64px);z-index:2;font-size:28px}.share-card h1{position:relative;z-index:1;color:#fff;font-size:25px;margin:5px 0 0;letter-spacing:.01em}.level{position:relative;z-index:1;color:#c9a35d;font-size:9px;letter-spacing:.16em;font-weight:800;margin-top:6px}.rule{position:relative;z-index:1;width:42px;height:2px;background:var(--red);margin:20px auto 13px}.invitation{position:relative;z-index:1;color:#a8abb2;font-size:12px;margin:0}.loading-orb{width:72px;height:72px;border:3px solid rgba(255,255,255,.14);border-top-color:#d6aa58;border-radius:50%;margin:90px auto 0;animation:spin .8s linear infinite}.join-card{background:rgba(255,255,255,.88);backdrop-filter:blur(18px);border:1px solid rgba(255,255,255,.95);border-radius:28px;padding:25px 22px;margin-top:14px;box-shadow:0 15px 38px rgba(29,34,43,.08)}.eyebrow{font-size:8px;color:var(--red);letter-spacing:.2em;font-weight:900}.join-copy h2{font-size:24px;margin:8px 0 7px}.join-copy p{font-size:13px;line-height:1.7;color:#737780;margin-bottom:20px}.primary-action,.secondary-action,.store-action{width:100%;min-height:54px;border-radius:16px;display:flex;align-items:center;justify-content:center;text-decoration:none;font-weight:800}.primary-action{border:0;color:#fff;background:linear-gradient(110deg,#ef1f2c,#d91d29);font-size:15px;justify-content:space-between;padding:0 20px;box-shadow:0 12px 24px rgba(229,43,54,.22);cursor:pointer}.secondary-action{border:1px solid #dfe1e5;color:#202227;background:#fff;font-size:14px;margin-top:10px}.store-action{border:1px solid #1d1f23;color:#17191d;background:transparent;margin-top:10px;gap:10px;font-size:15px;line-height:1}.store-action small{display:block;font-size:8px;font-weight:500;margin-bottom:3px}.apple{font-size:19px}.app-hint{text-align:center;color:#999da5;font-size:10px;line-height:1.55;margin:12px 10px 0}footer{text-align:center;color:#8a8e96;margin-top:27px;display:flex;flex-direction:column;gap:4px;font-size:10px;letter-spacing:.04em}footer strong{color:#555960;letter-spacing:.12em;font-size:9px}footer nav{display:flex;justify-content:center;gap:18px;margin-top:7px}footer a{color:#777b83;text-decoration:none}.placeholder{background:linear-gradient(145deg,#8c303a,#54181f)}@keyframes spin{to{transform:rotate(360deg)}}@media(max-width:380px){.share-page{padding-left:12px;padding-right:12px}.share-card{min-height:300px;padding:24px 18px}.brand-logo{width:88px}.join-card{padding:22px 17px}}
</style>
