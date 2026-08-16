<template>
  <main class="membership-page">
    <div class="page-shell">
      <PublicClubHeader />
      <section class="hero">
        <div>
          <p class="eyebrow">JOY MEMBERSHIP</p>
          <h1>{{ isZh ? '每一次开球，都更有价值。' : 'More value in every visit.' }}</h1>
          <p>{{ isZh ? '免费加入 Lite，或通过门店充值升级会员。充值金额会进入你的门店会员账户，用于球房消费，不是额外会费。' : 'Join Lite for free or unlock a higher tier with an in-venue top-up. Your full top-up is credited to your venue account for spending—it is not an extra membership fee.' }}</p>
          <div class="hero-actions"><router-link to="/join">{{ isZh ? '免费创建账号' : 'Create a free account' }}</router-link><router-link to="/pricing">{{ isZh ? '查看完整价格' : 'View all pricing' }}</router-link></div>
        </div>
        <div class="hero-stats"><div><strong>4</strong><span>{{ isZh ? '会员等级' : 'MEMBER TIERS' }}</span></div><div><strong>$6</strong><span>{{ isZh ? '每小时最多节省' : 'MAX HOURLY SAVING' }}</span></div><div><strong>1.6×</strong><span>{{ isZh ? '最高积分倍数' : 'MAX POINTS RATE' }}</span></div></div>
      </section>

      <section class="tier-section">
        <div class="section-heading"><p>{{ isZh ? '会员等级' : 'MEMBERSHIP TIERS' }}</p><h2>{{ isZh ? '找到适合你的等级' : 'Find your level' }}</h2></div>
        <div class="tier-tabs" role="tablist"><button v-for="tier in tiers" :key="tier.id" :class="{ active: activeTier === tier.id }" @click="activeTier = tier.id">{{ tier.name }}</button></div>
        <div class="tier-grid">
          <article v-for="tier in tiers" :key="tier.id" class="tier-card" :class="[tier.id,{ selected: activeTier === tier.id }]" @click="activeTier = tier.id">
            <div class="tier-top"><span>{{ tier.kicker }}</span><strong>{{ tier.name }}</strong><p>{{ tier.topUp }}</p></div>
            <div class="rates"><div><span>Q7</span><strong>${{ tier.q7 }}<small>/h</small></strong></div><div><span>Q8</span><strong>${{ tier.q8 }}<small>/h</small></strong></div></div>
            <ul><li v-for="benefit in tier.benefits" :key="benefit"><span>✓</span>{{ benefit }}</li></ul>
            <p class="validity">{{ tier.validity }}</p>
          </article>
        </div>
      </section>

      <section class="explain-grid">
        <article class="how-card">
          <p class="eyebrow">{{ isZh ? '如何加入' : 'HOW IT WORKS' }}</p><h2>{{ isZh ? '简单三步，权益立即生效' : 'Three simple steps' }}</h2>
          <ol>
            <li><b>1</b><div><strong>{{ isZh ? '注册 Joy Club' : 'Join Joy Club' }}</strong><span>{{ isZh ? 'Lite 免费注册并长期有效。' : 'Lite is free to join and remains active.' }}</span></div></li>
            <li><b>2</b><div><strong>{{ isZh ? '在门店充值' : 'Top up in venue' }}</strong><span>{{ isZh ? '充值金额决定 Plus、Pro 或 Pro Max 等级。' : 'Your top-up determines Plus, Pro or Pro Max.' }}</span></div></li>
            <li><b>3</b><div><strong>{{ isZh ? '享受会员价与积分' : 'Enjoy rates and rewards' }}</strong><span>{{ isZh ? '会员价全天适用，消费可获得会员积分。' : 'Member rates apply all day and eligible spending earns loyalty points.' }}</span></div></li>
          </ol>
        </article>
        <article class="clarity-card"><span class="clarity-mark">i</span><div><p class="eyebrow">MEMBER CLARITY</p><h2>{{ isZh ? '充值不是会费' : 'Your top-up stays yours' }}</h2><p>{{ isZh ? 'Plus、Pro 与 Pro Max 的充值金额会完整计入门店会员账户，可用于符合条件的球房消费。App 中的会员积分与排行榜积分是两套独立数据，也不等同于门店余额。' : 'Plus, Pro and Pro Max top-ups are fully credited to your in-venue member account for eligible venue purchases. App loyalty points and ranking points are separate systems and neither is your venue balance.' }}</p></div></article>
      </section>

      <section class="terms-card">
        <div class="section-heading"><p>{{ isZh ? '重要说明' : 'GOOD TO KNOW' }}</p><h2>{{ isZh ? '清楚、透明的会员规则' : 'Straightforward member rules' }}</h2></div>
        <div class="terms-grid">
          <div><strong>{{ isZh ? '会员价' : 'Member rates' }}</strong><span>{{ isZh ? '适用于全部营业时段，包括晚间与周末。' : 'Apply throughout opening hours, including evenings and weekends.' }}</span></div>
          <div><strong>{{ isZh ? '会员有效期' : 'Membership validity' }}</strong><span>{{ isZh ? 'Lite 长期有效；付费等级自充值起 12 个月。' : 'Lite remains active; paid tiers last 12 months from top-up.' }}</span></div>
          <div><strong>{{ isZh ? '免费时段券' : 'Free-hour rewards' }}</strong><span>{{ isZh ? '仅限周一至周五 12:30–17:00，赛事日及公共假期等除外。' : 'Mon–Fri, 12:30–5pm only; exclusions include event days and public holidays.' }}</span></div>
          <div><strong>{{ isZh ? '预约取消' : 'Booking cancellations' }}</strong><span>{{ isZh ? '少于 3 小时取消收取 50%；未到店收取 100%。每 12 个月首次可酌情豁免。' : 'Under 3 hours: 50%; no-show: 100%. The first occurrence in 12 months may be waived.' }}</span></div>
          <div><strong>{{ isZh ? '会员积分' : 'Loyalty points' }}</strong><span>{{ isZh ? '按滚动 12 个月有效；不等同于比赛排名积分。' : 'Valid on a rolling 12-month basis and separate from competition ranking points.' }}</span></div>
          <div><strong>{{ isZh ? '续期与等级' : 'Renewal and tier' }}</strong><span>{{ isZh ? '续期时的充值金额决定新一周期会员等级。' : 'Your renewal top-up determines your tier for the next period.' }}</span></div>
        </div>
        <p class="legal-note">{{ isZh ? '具体资格、库存、预约和服务条款以门店确认为准，并受新西兰消费者法律保障。' : 'Eligibility, availability, booking and service conditions are subject to venue confirmation and New Zealand consumer law.' }}</p>
      </section>

      <section class="cta"><div><p class="eyebrow">WELCOME TO JOY</p><h2>{{ isZh ? '准备加入了吗？' : 'Ready to join?' }}</h2><span>{{ isZh ? '先免费注册，之后可随时到店升级。' : 'Start free, then upgrade in venue whenever you are ready.' }}</span></div><div><router-link to="/join">{{ isZh ? '创建账号' : 'Create account' }}</router-link><a href="tel:+64221660688">{{ isZh ? '联系我们' : 'Contact us' }}</a></div></section>
      <PublicClubFooter />
    </div>
  </main>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import PublicClubHeader from '../components/PublicClubHeader.vue'
import PublicClubFooter from '../components/PublicClubFooter.vue'
import { useI18n } from '../i18n'
const { isZh } = useI18n()
const activeTier = ref('pro')
const tiers = computed(() => [
  { id:'lite', name:'Lite', kicker:isZh.value?'轻松开始':'START FREE', topUp:isZh.value?'免费注册':'Free to join', q7:23, q8:28, validity:isZh.value?'长期有效':'Ongoing membership', benefits:isZh.value?['1.0× 会员积分','提前 2 小时当天订台','每天点歌 3 首','基础公杆与数据']:['1.0× loyalty points','Same-day booking, 2h ahead','3 song requests daily','Standard cues & stats'] },
  { id:'plus', name:'Plus', kicker:isZh.value?'常打之选':'PLAY MORE', topUp:isZh.value?'充值 $200':'$200 top-up', q7:21, q8:26, validity:isZh.value?'自充值起 12 个月':'Valid for 12 months', benefits:isZh.value?['$200 计入门店账户','1.2× 会员积分','提前 6 小时订台','每天点歌 5 首']:['$200 venue account credit','1.2× loyalty points','Book 6 hours ahead','5 song requests daily'] },
  { id:'pro', name:'Pro', kicker:isZh.value?'最受欢迎':'MOST POPULAR', topUp:isZh.value?'充值 $500':'$500 top-up', q7:19, q8:24, validity:isZh.value?'自充值起 12 个月':'Valid for 12 months', benefits:isZh.value?['$500 计入门店账户','1.4× 会员积分','提前 12 小时订台','赛事优先名额']:['$500 venue account credit','1.4× loyalty points','Book 12 hours ahead','Tournament priority'] },
  { id:'pro-max', name:'Pro Max', kicker:isZh.value?'旗舰会员':'SIGNATURE TIER', topUp:isZh.value?'充值 $1,000':'$1,000 top-up', q7:17, q8:22, validity:isZh.value?'12 个月 · 名额有限':'12 months · Limited places', benefits:isZh.value?['$1,000 计入门店账户','1.6× 会员积分','提前 24 小时订台','生日礼遇与优先点歌']:['$1,000 venue account credit','1.6× loyalty points','Book 24 hours ahead','Birthday reward & priority songs'] }
])
onMounted(() => {
  document.title = isZh.value ? '会员体系 - Joy Billiards NZ' : 'Membership - Joy Billiards NZ'
  document.querySelector('meta[name="description"]')?.setAttribute('content', 'Compare Joy Billiards Lite, Plus, Pro and Pro Max membership rates and benefits in Hamilton, New Zealand.')
})
</script>

<style scoped>
.membership-page{--red:#d9212f;min-height:100svh;padding:0 20px 36px;background:radial-gradient(circle at 90% 4%,rgba(196,154,82,.11),transparent 25%),linear-gradient(180deg,#fbfaf8,#f1f0ee);color:#191817;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}.page-shell{width:min(100%,1120px);margin:auto}.eyebrow,.section-heading p{margin:0;color:#b78a43;font-size:10px;font-weight:900;letter-spacing:.19em}.hero{display:grid;grid-template-columns:1.25fr .75fr;gap:40px;align-items:center;padding:58px;border-radius:34px;background:linear-gradient(135deg,#26171a,#151517 74%);box-shadow:0 28px 70px rgba(27,20,21,.18);color:#fff}.hero h1{max-width:670px;margin:16px 0;font-size:clamp(40px,6vw,68px);line-height:1.02;letter-spacing:-.055em}.hero>div:first-child>p:last-of-type{max-width:660px;margin:0;color:#bbb7b7;font-size:14px;line-height:1.8}.hero-actions{display:flex;gap:10px;margin-top:27px}.hero-actions a{min-height:48px;padding:0 19px;border-radius:14px;display:inline-flex;align-items:center;color:#fff;font-size:13px;font-weight:850;text-decoration:none}.hero-actions a:first-child{background:var(--red)}.hero-actions a:last-child{border:1px solid rgba(255,255,255,.18)}.hero-stats{display:grid;gap:8px}.hero-stats div{display:flex;align-items:baseline;justify-content:space-between;padding:17px 20px;border:1px solid rgba(255,255,255,.08);border-radius:16px;background:rgba(255,255,255,.045)}.hero-stats strong{font-size:31px}.hero-stats span{color:#8f8a8b;font-size:8px;font-weight:900;letter-spacing:.14em}.tier-section,.terms-card{margin-top:22px;padding:42px;border:1px solid #e4e0dc;border-radius:30px;background:rgba(255,255,255,.88);box-shadow:0 16px 42px rgba(42,36,31,.05)}.section-heading{margin-bottom:23px}.section-heading h2{margin:7px 0 0;font-size:30px;letter-spacing:-.035em}.tier-tabs{display:none}.tier-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:12px}.tier-card{padding:22px 18px;border:1px solid #e6e2de;border-radius:22px;background:#fff;cursor:pointer}.tier-card.pro{border-color:rgba(217,33,47,.3);box-shadow:0 12px 30px rgba(217,33,47,.08)}.tier-card.pro-max{background:linear-gradient(150deg,#292019,#171717);color:#fff}.tier-top span{color:#a59f99;font-size:8px;font-weight:900;letter-spacing:.13em}.tier-top strong{display:block;margin-top:10px;font-size:25px}.tier-top p{min-height:34px;margin:3px 0 0;color:#c12531;font-size:12px;font-weight:800}.pro-max .tier-top p{color:#d4aa64}.rates{display:grid;grid-template-columns:1fr 1fr;gap:6px;margin:16px 0}.rates div{padding:11px;border-radius:13px;background:#f4f2ef}.pro-max .rates div{background:rgba(255,255,255,.075)}.rates span{display:block;color:#99938e;font-size:8px;font-weight:900}.rates strong{font-size:20px}.rates small{font-size:9px}.tier-card ul{display:flex;flex-direction:column;gap:10px;min-height:128px;margin:0;padding:0;list-style:none}.tier-card li{display:flex;gap:7px;color:#66625e;font-size:10px;line-height:1.45}.tier-card li span{color:#c62431}.pro-max li{color:#b9b4af}.validity{margin:17px 0 0;padding-top:13px;border-top:1px solid #ece8e4;color:#99938e;font-size:9px}.pro-max .validity{border-color:rgba(255,255,255,.08)}.explain-grid{display:grid;grid-template-columns:1fr 1fr;gap:18px;margin-top:22px}.how-card,.clarity-card{padding:36px;border-radius:28px}.how-card{border:1px solid #e4e0dc;background:#fff}.how-card h2,.clarity-card h2{margin:8px 0 22px;font-size:28px;letter-spacing:-.04em}.how-card ol{display:flex;flex-direction:column;gap:17px;margin:0;padding:0;list-style:none}.how-card li{display:flex;align-items:center;gap:13px}.how-card li>b{display:grid;place-items:center;flex:0 0 35px;height:35px;border-radius:12px;background:#f5e8e7;color:#c7222e}.how-card li div{display:flex;flex-direction:column}.how-card li strong{font-size:12px}.how-card li span{margin-top:3px;color:#8d8883;font-size:10px;line-height:1.5}.clarity-card{display:flex;align-items:flex-start;gap:22px;background:linear-gradient(140deg,#2a211a,#171719);color:#fff}.clarity-mark{display:grid;place-items:center;flex:0 0 48px;height:48px;border:1px solid #caa058;border-radius:16px;color:#caa058;font:italic 800 23px Georgia,serif}.clarity-card h2{margin-bottom:12px}.clarity-card div>p:last-child{margin:0;color:#aca7a3;font-size:11px;line-height:1.8}.terms-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}.terms-grid div{display:flex;flex-direction:column;padding:17px;border-radius:15px;background:#f6f4f1}.terms-grid strong{font-size:11px}.terms-grid span{margin-top:5px;color:#827d78;font-size:10px;line-height:1.55}.legal-note{margin:18px 3px 0;color:#98938d;font-size:9px;line-height:1.6}.cta{display:flex;align-items:center;justify-content:space-between;gap:24px;margin-top:22px;padding:33px 38px;border-radius:27px;background:#ede7df}.cta h2{margin:6px 0 4px;font-size:27px}.cta>div:first-child>span{color:#817b75;font-size:11px}.cta>div:last-child{display:flex;gap:9px}.cta a{min-height:45px;padding:0 18px;border-radius:13px;display:flex;align-items:center;background:#fff;color:#252321;font-size:12px;font-weight:850;text-decoration:none}.cta a:first-child{background:var(--red);color:#fff}@media(max-width:900px){.tier-grid{grid-template-columns:1fr 1fr}.tier-card ul{min-height:0}}@media(max-width:720px){.membership-page{padding:0 12px 28px}.hero{grid-template-columns:1fr;padding:34px 25px}.hero-stats{grid-template-columns:repeat(3,1fr)}.hero-stats div{align-items:center;flex-direction:column;padding:13px 5px}.hero-stats strong{font-size:23px}.hero-stats span{margin-top:4px;font-size:6px;text-align:center}.tier-section,.terms-card{padding:28px 20px}.tier-tabs{display:grid;grid-template-columns:repeat(4,1fr);gap:5px;margin-bottom:12px}.tier-tabs button{min-height:37px;border:0;border-radius:11px;background:#f0eeeb;color:#77716d;font-size:10px;font-weight:850}.tier-tabs button.active{background:#1d1b1b;color:#fff}.tier-grid{display:block}.tier-card{display:none}.tier-card.selected{display:block}.explain-grid{grid-template-columns:1fr}.terms-grid{grid-template-columns:1fr}.cta{align-items:flex-start;flex-direction:column;padding:28px 23px}.cta>div:last-child{width:100%}.cta a{flex:1;justify-content:center}}@media(max-width:390px){.hero{padding:30px 20px}.hero-actions{flex-direction:column}.hero-actions a{justify-content:center}.clarity-card{padding:28px 22px}.clarity-mark{display:none}}
</style>
