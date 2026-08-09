<template>
  <main class="annual-page">
    <div class="glow glow-gold" />
    <div class="glow glow-red" />
    <div class="year-watermark">
      {{ record.year }}
    </div>

    <section class="page-shell">
      <header class="brand">
        <img
          src="/JoyBilliards-Logo.svg"
          alt="Joy Billiards New Zealand"
          class="brand-logo"
        >
        <div class="brand-copy">
          <strong>JOY CLUB</strong>
          <span>ANNUAL HALL OF HONOUR</span>
        </div>
      </header>

      <article
        class="honour-card"
        :class="rankClass"
      >
        <div class="metal-line" />
        <div class="card-halo" />
        <div class="eight-ball">
          8
        </div>

        <div
          v-if="loading"
          class="loading-state"
        >
          <div class="loading-ring" />
          <p>{{ copy.verifying }}</p>
        </div>

        <div
          v-else-if="errorMessage"
          class="error-state"
        >
          <div class="error-mark">
            !
          </div>
          <h1>{{ copy.notFound }}</h1>
          <p>{{ errorMessage }}</p>
        </div>

        <template v-else>
          <div class="official-row">
            <span class="official-dot" />
            <span>JOY OFFICIAL · VERIFIED</span>
            <span>{{ record.year }}</span>
          </div>

          <div class="rank-mark">
            {{ rankMark }}
          </div>
          <p class="edition">
            {{ divisionLabel }} · {{ copy.annualEdition }}
          </p>

          <div class="portrait-wrap">
            <div class="portrait">
              <img
                v-if="record.avatar_url"
                :src="record.avatar_url"
                :alt="record.player_name"
              >
              <span v-else>{{ initials }}</span>
            </div>
            <span class="verified-seal">✓</span>
          </div>

          <h1>{{ record.player_name }}</h1>
          <p class="honour-title">
            {{ honourTitle }}
          </p>
          <p class="honour-title-en">
            {{ honourTitleEnglish }}
          </p>

          <div class="diamond-rule">
            <span /><i /><span />
          </div>
          <p class="statement">
            {{ copy.statement }}
          </p>

          <div class="achievement-grid">
            <div>
              <strong>#{{ record.placement }}</strong>
              <span>{{ copy.officialRank }}</span>
            </div>
            <div>
              <strong>{{ record.points }}</strong>
              <span>{{ copy.rankingPoints }}</span>
            </div>
            <div>
              <strong>{{ divisionLabel }}</strong>
              <span>{{ copy.division }}</span>
            </div>
          </div>

          <div class="permanent-seal">
            <span>JOY</span>
            <p>{{ copy.permanent }}</p>
          </div>
        </template>
      </article>

      <section
        v-if="!loading && !errorMessage"
        class="action-card"
      >
        <p class="eyebrow">
          PLAY · ENJOY · BELONG
        </p>
        <h2>{{ copy.joinTitle }}</h2>
        <p class="join-copy">
          {{ copy.joinText }}
        </p>

        <button
          class="primary-action"
          type="button"
          @click="openApp"
        >
          <span>{{ copy.openApp }}</span><span aria-hidden="true">↗</span>
        </button>
        <a
          v-for="option in downloadOptions"
          :key="option.platform"
          class="download-action"
          :href="option.url"
          target="_blank"
          rel="noopener"
        >
          <b>{{ option.platform === 'ios' ? '●' : '▶' }}</b>
          <span><small>{{ option.platform === 'ios' ? 'Download on the' : 'GET IT ON' }}</small>{{ option.label }}</span>
        </a>
        <router-link
          v-if="playerLink"
          class="secondary-action"
          :to="playerLink"
        >
          {{ copy.viewPlayer }}
        </router-link>
        <button
          class="share-action"
          type="button"
          @click="sharePage"
        >
          {{ copy.shareAgain }}
        </button>
        <router-link
          class="register-link"
          :to="registerLink"
        >
          {{ copy.createAccount }}
        </router-link>
      </section>

      <footer>
        <strong>JOY BILLIARDS NEW ZEALAND</strong>
        <span>88 Tristram Street, Hamilton Central</span>
        <nav>
          <router-link to="/privacy-policy">
            Privacy
          </router-link><router-link to="/terms-of-service">
            Terms
          </router-link>
        </nav>
      </footer>
    </section>
  </main>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '../config/supabase'
import { downloadOptionsForClient } from '../utils/appDownload'

const route = useRoute()
const shareToken = computed(() => String(route.params.token || ''))
const loading = ref(true)
const errorMessage = ref('')
const year = Number(route.query.year) || new Date().getFullYear()
const playerId = String(route.query.player || '')
const downloadOptions = downloadOptionsForClient()
const isZh = /^zh\b/i.test(navigator.language || '')
const record = reactive({ year, division: '', placement: 0, points: 0, user_id: playerId, player_name: '', ranking_level: '', avatar_url: '' })

const zh = {
  verifying: '正在核验官方年度荣耀…', notFound: '未找到这份年度荣耀', invalid: '链接无效，或该年度结果尚未正式发布。', annualEdition: '年度荣耀', statement: '这一年，每一场比赛都算数。此刻的荣耀，是实力、坚持与赛场风度共同写下的答案。', officialRank: '年度官方排名', rankingPoints: '年度排名积分', division: '组别', permanent: '永久收录于 JOY 球员荣誉墙', joinTitle: '让下一张荣耀卡，写下你的名字', joinText: '加入 Joy Club，参与官方赛事、记录每一次成长，并与新西兰台球社群一起迎接下一场挑战。', openApp: '打开 Joy Club App', viewPlayer: '查看公开球员主页', shareAgain: '分享这份年度荣耀', createAccount: '还没有账号？免费加入 Joy Club', shareText: '这份 JOY 年度荣耀值得被看见。', shareDone: '链接已复制', shareFailed: '请复制浏览器地址分享',
}
const en = {
  verifying: 'Verifying official annual honour…', notFound: 'Annual honour not found', invalid: 'This link is invalid, or the annual result has not been officially published.', annualEdition: 'ANNUAL HONOURS', statement: 'Every match counted. This honour is the lasting mark of performance, dedication and sportsmanship.', officialRank: 'OFFICIAL RANK', rankingPoints: 'RANKING POINTS', division: 'DIVISION', permanent: 'PERMANENTLY RECORDED IN THE JOY HALL OF HONOUR', joinTitle: 'Make the next honour card yours', joinText: 'Join Joy Club to compete in official events, record your progress and become part of New Zealand’s growing billiards community.', openApp: 'Open Joy Club App', viewPlayer: 'View public player profile', shareAgain: 'Share this annual honour', createAccount: 'New to Joy Club? Create a free account', shareText: 'This official JOY annual honour deserves to be seen.', shareDone: 'Link copied', shareFailed: 'Copy the browser address to share',
}
const copy = computed(() => isZh ? zh : en)
const initials = computed(() => record.player_name.trim().slice(0, 2).toUpperCase() || 'JOY')
const divisionLabel = computed(() => String(record.division || 'JOY').toUpperCase())
const rankMark = computed(() => record.placement === 1 ? '♛' : record.placement === 2 ? 'Ⅱ' : record.placement === 3 ? 'Ⅲ' : `#${record.placement}`)
const rankClass = computed(() => record.placement === 1 ? 'rank-gold' : record.placement === 2 ? 'rank-silver' : record.placement === 3 ? 'rank-bronze' : 'rank-elite')
const honourTitle = computed(() => {
  const group = divisionLabel.value
  if (!isZh) return honourTitleEnglish.value
  if (record.placement === 1) return `${record.year} JOY ${group} ${record.division === 'pro' ? '年度球王' : '年度冠军'}`
  if (record.placement === 2) return `${record.year} JOY ${group} 年度银冠`
  if (record.placement === 3) return `${record.year} JOY ${group} 年度铜冠`
  return `${record.year} JOY ${group} 年度十强精英 · 第 ${record.placement} 名`
})
const honourTitleEnglish = computed(() => {
  const group = divisionLabel.value
  if (record.placement === 1) return `${record.year} JOY ${group} ${record.division === 'pro' ? 'PLAYER OF THE YEAR' : 'ANNUAL CHAMPION'}`
  if (record.placement === 2) return `${record.year} JOY ${group} ANNUAL SILVER`
  if (record.placement === 3) return `${record.year} JOY ${group} ANNUAL BRONZE`
  return `${record.year} JOY ${group} ANNUAL TOP 10 ELITE · NO. ${record.placement}`
})
const playerLink = computed(() => record.user_id ? `/app/player/${encodeURIComponent(record.user_id)}` : '')
const registerLink = computed(() => ({
  path: '/join',
  query: {
    source: 'annual-honours-share',
    ...(shareToken.value ? { invite: shareToken.value } : { ref: record.user_id }),
  },
}))

const loadHonour = async () => {
  if (shareToken.value) {
    const { data, error } = await supabase.rpc('resolve_public_app_share', { p_token: shareToken.value })
    if (error || !data || data.kind !== 'annual_honour' || !data.award) throw new Error(copy.value.invalid)
    Object.assign(record, data.award, { user_id: '' })
    return
  }
  if (!playerId || !Number.isInteger(year)) throw new Error(copy.value.invalid)
  const { data, error } = await supabase.rpc('get_public_annual_honour', { p_year: year, p_user_id: playerId })
  if (error) throw error
  const official = Array.isArray(data) ? data[0] : data
  if (!official) throw new Error(copy.value.invalid)
  Object.assign(record, official)
}

const openApp = () => {
  if (shareToken.value) {
    window.location.href = `joybilliardsapp:///shared/${encodeURIComponent(shareToken.value)}`
    return
  }
  window.location.href = `joybilliardsapp:///annual-honours?year=${record.year}`
}

const sharePage = async () => {
  const payload = { title: honourTitle.value, text: copy.value.shareText, url: window.location.href }
  try {
    if (navigator.share) await navigator.share(payload)
    else {
      await navigator.clipboard.writeText(window.location.href)
      window.alert(copy.value.shareDone)
    }
  } catch (error) {
    if (error?.name !== 'AbortError') window.alert(copy.value.shareFailed)
  }
}

onMounted(async () => {
  try { await loadHonour() }
  catch (error) { errorMessage.value = error?.message === copy.value.invalid ? copy.value.invalid : copy.value.invalid }
  finally { loading.value = false }
})
</script>

<style scoped>
.annual-page{--gold:#d8ad5f;--metal:#f2d590;--red:#e52b36;min-height:100svh;position:relative;overflow:hidden;padding:24px 16px 44px;background:radial-gradient(circle at 50% -5%,#2a2113 0,#111216 31%,#08090c 78%);color:#fff;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}.page-shell{position:relative;z-index:2;width:min(100%,540px);margin:0 auto}.glow{position:absolute;border-radius:50%;pointer-events:none}.glow-gold{width:420px;height:420px;top:4%;left:50%;transform:translateX(-50%);background:radial-gradient(circle,rgba(216,173,95,.17),transparent 68%)}.glow-red{width:330px;height:330px;right:-220px;bottom:12%;border:45px solid rgba(229,43,54,.05)}.year-watermark{position:absolute;top:25%;left:-28px;transform:rotate(-90deg);color:rgba(255,255,255,.018);font:900 96px Georgia,serif;letter-spacing:.08em}.brand{display:flex;align-items:center;justify-content:center;gap:14px;margin:2px 0 20px}.brand-logo{width:102px;height:52px;object-fit:contain;filter:invert(1) grayscale(1) brightness(2)}.brand-copy{display:flex;flex-direction:column;padding-left:14px;border-left:1px solid rgba(255,255,255,.18)}.brand-copy strong{font-size:17px;letter-spacing:.15em}.brand-copy span{margin-top:5px;color:#a88d5c;font-size:7px;font-weight:900;letter-spacing:.2em}.honour-card{--rank:#d8ad5f;position:relative;min-height:645px;overflow:hidden;padding:24px 22px 30px;border:1px solid rgba(216,173,95,.42);border-radius:32px;background:linear-gradient(155deg,#251b0e 0,#0b0c10 50%,#190e11 100%);box-shadow:0 30px 90px rgba(0,0,0,.45),inset 0 0 0 1px rgba(255,255,255,.025);text-align:center}.rank-silver{--rank:#bec6d4;border-color:rgba(190,198,212,.45);background:linear-gradient(155deg,#1c2028,#0b0c10 52%,#15171c)}.rank-bronze{--rank:#c47c50;border-color:rgba(196,124,80,.47)}.rank-elite{--rank:#e52b36;border-color:rgba(229,43,54,.35)}.metal-line{position:absolute;top:0;left:12%;width:76%;height:3px;background:linear-gradient(90deg,transparent,var(--rank),#fff0bd,var(--rank),transparent);box-shadow:0 0 19px color-mix(in srgb,var(--rank) 55%,transparent)}.card-halo{position:absolute;top:42px;left:50%;width:310px;height:310px;transform:translateX(-50%);border:1px solid rgba(216,173,95,.09);border-radius:50%;box-shadow:0 0 0 35px rgba(216,173,95,.025),0 0 0 70px rgba(216,173,95,.018)}.eight-ball{position:absolute;right:-30px;bottom:-88px;color:rgba(255,255,255,.022);font:900 260px Georgia,serif}.official-row{position:relative;z-index:1;display:flex;align-items:center;justify-content:space-between;color:#978b76;font-size:7px;font-weight:900;letter-spacing:.17em}.official-dot{width:6px;height:6px;border-radius:50%;background:var(--rank);box-shadow:0 0 9px var(--rank)}.rank-mark{position:relative;z-index:1;margin-top:23px;color:var(--rank);font:500 67px Georgia,serif;line-height:1;text-shadow:0 5px 28px color-mix(in srgb,var(--rank) 34%,transparent)}.edition{position:relative;z-index:1;margin:4px 0 18px;color:#9e8d6d;font-size:8px;font-weight:900;letter-spacing:.22em}.portrait-wrap{position:relative;z-index:1;width:108px;margin:0 auto}.portrait{width:102px;height:102px;overflow:hidden;border:2px solid var(--rank);border-radius:50%;background:linear-gradient(145deg,#8b303a,#441319);box-shadow:0 0 0 7px rgba(216,173,95,.075),0 16px 30px rgba(0,0,0,.38);display:grid;place-items:center;color:#fff;font-size:26px;font-weight:900}.portrait img{width:100%;height:100%;object-fit:cover}.verified-seal{position:absolute;right:0;bottom:6px;width:24px;height:24px;border:3px solid #111217;border-radius:50%;background:var(--rank);display:grid;place-items:center;color:#111217;font-size:12px;font-weight:1000}.honour-card h1{position:relative;z-index:1;margin:17px 0 5px;font-size:28px;letter-spacing:-.025em}.honour-title{position:relative;z-index:1;margin:0;color:var(--rank);font-size:15px;font-weight:850;line-height:1.4}.honour-title-en{position:relative;z-index:1;margin:5px auto 0;max-width:370px;color:#8f897d;font-size:7px;font-weight:900;letter-spacing:.14em}.diamond-rule{position:relative;z-index:1;display:flex;align-items:center;justify-content:center;gap:9px;margin:19px auto 14px}.diamond-rule span{width:48px;height:1px;background:linear-gradient(90deg,transparent,var(--rank))}.diamond-rule span:last-child{transform:rotate(180deg)}.diamond-rule i{width:6px;height:6px;border:1px solid var(--rank);transform:rotate(45deg)}.statement{position:relative;z-index:1;max-width:390px;margin:0 auto;color:#ada9a1;font-size:11px;line-height:1.75}.achievement-grid{position:relative;z-index:1;display:grid;grid-template-columns:repeat(3,1fr);gap:7px;margin-top:21px}.achievement-grid div{padding:13px 5px 11px;border:1px solid rgba(255,255,255,.065);border-radius:14px;background:rgba(255,255,255,.035)}.achievement-grid strong{display:block;color:#fff;font-size:18px}.achievement-grid span{display:block;margin-top:4px;color:#6f7077;font-size:6px;font-weight:900;letter-spacing:.1em}.permanent-seal{position:relative;z-index:1;display:flex;align-items:center;justify-content:center;gap:9px;margin-top:19px}.permanent-seal>span{width:29px;height:29px;border:1px solid var(--rank);border-radius:50%;display:grid;place-items:center;color:var(--rank);font-size:7px;font-weight:1000}.permanent-seal p{margin:0;color:#77746d;font-size:7px;font-weight:900;letter-spacing:.13em}.loading-state,.error-state{position:relative;z-index:1;min-height:570px;display:flex;flex-direction:column;align-items:center;justify-content:center}.loading-ring{width:64px;height:64px;border:2px solid rgba(255,255,255,.1);border-top-color:var(--gold);border-radius:50%;animation:spin .8s linear infinite}.loading-state p{margin-top:16px;color:#928877;font-size:11px;letter-spacing:.08em}.error-mark{width:58px;height:58px;border:1px solid #b47854;border-radius:50%;display:grid;place-items:center;color:#d6a172;font:30px Georgia,serif}.error-state h1{font-size:22px}.error-state p{max-width:320px;color:#898b92;font-size:12px;line-height:1.7}.action-card{margin-top:14px;padding:25px 21px;border:1px solid rgba(216,173,95,.15);border-radius:27px;background:linear-gradient(150deg,rgba(32,29,24,.96),rgba(16,17,21,.96));box-shadow:0 18px 45px rgba(0,0,0,.28);text-align:center}.eyebrow{margin:0;color:var(--gold);font-size:8px;font-weight:900;letter-spacing:.2em}.action-card h2{margin:9px 0 7px;font-size:22px}.join-copy{margin:0 3px 20px;color:#92959c;font-size:12px;line-height:1.7}.primary-action,.secondary-action,.share-action{box-sizing:border-box;width:100%;min-height:53px;border-radius:16px;display:flex;align-items:center;justify-content:center;text-decoration:none;font-weight:850}.primary-action{justify-content:space-between;padding:0 19px;border:0;background:linear-gradient(110deg,#ef1f2c,#d91d29);box-shadow:0 12px 24px rgba(229,43,54,.2);color:#fff;font-size:14px;cursor:pointer}.secondary-action{margin-top:9px;border:1px solid rgba(216,173,95,.4);color:#e7c880;background:rgba(216,173,95,.04);font-size:13px}.share-action{margin-top:9px;border:1px solid rgba(255,255,255,.11);color:#d7d8dc;background:transparent;font-size:13px;cursor:pointer}.register-link{display:inline-block;margin-top:16px;color:#898d95;font-size:10px;text-decoration:none}.register-link:hover{color:#fff}footer{display:flex;flex-direction:column;gap:4px;margin-top:25px;color:#74777f;font-size:9px;letter-spacing:.04em;text-align:center}footer strong{color:#a58959;font-size:8px;letter-spacing:.14em}footer nav{display:flex;justify-content:center;gap:17px;margin-top:7px}footer a{color:#74777f;text-decoration:none}@keyframes spin{to{transform:rotate(360deg)}}@media(max-width:380px){.annual-page{padding-left:10px;padding-right:10px}.honour-card{padding-left:15px;padding-right:15px;min-height:630px}.brand-logo{width:88px}.achievement-grid{gap:4px}.honour-card h1{font-size:25px}.action-card{padding-left:16px;padding-right:16px}}
.download-action{box-sizing:border-box;width:100%;min-height:53px;margin-top:9px;border:1px solid rgba(255,255,255,.18);border-radius:16px;display:flex;align-items:center;justify-content:center;gap:10px;color:#fff;background:rgba(255,255,255,.035);font-size:13px;font-weight:850;line-height:1;text-decoration:none}.download-action>b{font-size:17px}.download-action small{display:block;margin-bottom:3px;color:#888b92;font-size:6px;font-weight:500}
</style>
