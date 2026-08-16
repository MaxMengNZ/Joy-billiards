<template>
  <main class="info-page">
    <div class="page-shell">
      <PublicClubHeader />
      <section class="hero">
        <div class="hero-copy">
          <p class="eyebrow">JOY BILLIARDS · HAMILTON</p>
          <h1>{{ isZh ? '清楚价格，轻松开局。' : 'Clear pricing. Better play.' }}</h1>
          <p>{{ isZh ? '乔氏银腿与金腿球台，会员价全天适用。所有价格均为新西兰元并包含 GST。' : 'JOY Q7 Silver Leg and Q8 Gold Leg tables, with member rates available throughout opening hours. All prices are NZD and include GST.' }}</p>
          <div class="hero-actions">
            <router-link class="primary" to="/membership">{{ isZh ? '查看会员体系' : 'Explore membership' }}</router-link>
            <a class="secondary" href="tel:+64221660688">{{ isZh ? '致电球房' : 'Call the venue' }}</a>
          </div>
        </div>
        <div class="rate-spotlight">
          <span>{{ isZh ? '台费低至' : 'TABLES FROM' }}</span><strong><small>$</small>17</strong><em>{{ isZh ? '/ 小时' : '/ hour' }}</em>
          <p>{{ isZh ? 'Pro Max · Q7 银腿' : 'Pro Max · Q7 Silver Leg' }}</p>
        </div>
      </section>

      <section class="section">
        <div class="section-heading"><p>{{ isZh ? '球台价格' : 'TABLE RATES' }}</p><h2>{{ isZh ? '选择适合你的球台' : 'Choose your table' }}</h2></div>
        <div class="table-cards">
          <article class="table-card silver"><div class="table-mark">Q7</div><div><span>{{ isZh ? '乔氏银腿' : 'Silver Leg' }}</span><strong>$23<small>/h</small></strong><p>{{ isZh ? 'Lite 标准会员价' : 'Lite standard member rate' }}</p></div></article>
          <article class="table-card gold"><div class="table-mark">Q8</div><div><span>{{ isZh ? '乔氏金腿' : 'Gold Leg' }}</span><strong>$28<small>/h</small></strong><p>{{ isZh ? 'Lite 标准会员价' : 'Lite standard member rate' }}</p></div></article>
        </div>
        <div class="rate-grid" role="table" :aria-label="isZh ? '会员台费比较' : 'Member rate comparison'">
          <div class="rate-row rate-head" role="row"><span>{{ isZh ? '会员等级' : 'Tier' }}</span><span>Q7</span><span>Q8</span><span>{{ isZh ? '每小时最多节省' : 'Save up to' }}</span></div>
          <div v-for="tier in tiers" :key="tier.name" class="rate-row" role="row"><span><i :class="tier.class"></i><strong>{{ tier.name }}</strong></span><span>${{ tier.q7 }}</span><span>${{ tier.q8 }}</span><span>{{ tier.save }}</span></div>
        </div>
        <p class="fine-print">{{ isZh ? '会员价适用于全部营业时段。会员资格、充值门槛及完整权益请查看会员体系页面。' : 'Member rates apply throughout opening hours. See Membership for eligibility, top-up thresholds and full benefits.' }}</p>
      </section>

      <section class="section split-section">
        <div>
          <div class="section-heading compact"><p>{{ isZh ? '球杆服务' : 'CUE SERVICES' }}</p><h2>{{ isZh ? '专业维护与维修' : 'Care for your cue' }}</h2></div>
          <div class="service-list"><div v-for="service in services" :key="service.en"><span>{{ isZh ? service.zh : service.en }}</span><strong>{{ service.price }}</strong></div></div>
          <p class="fine-print">{{ isZh ? '“起”价格会根据材料与实际工况调整；报价项目会在开始维修前与顾客确认。' : '“From” pricing varies by materials and condition. Quote services are confirmed with you before work begins.' }}</p>
        </div>
        <aside class="visit-card">
          <p class="eyebrow">PLAN YOUR VISIT</p><h2>{{ isZh ? '今天来打一场' : 'Come play today' }}</h2>
          <div><span>{{ isZh ? '周一至周四' : 'Mon – Thu' }}</span><strong>12:30 PM – 1:00 AM</strong></div>
          <div><span>{{ isZh ? '周五至周六' : 'Fri – Sat' }}</span><strong>12:30 PM – 2:00 AM</strong></div>
          <div><span>{{ isZh ? '周日' : 'Sunday' }}</span><strong>12:30 PM – 1:00 AM</strong></div>
          <a href="https://maps.google.com/?q=88+Tristram+Street+Hamilton+Central" target="_blank" rel="noopener">88 Tristram Street, Hamilton Central <b>↗</b></a>
        </aside>
      </section>
      <PublicClubFooter />
    </div>
  </main>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import PublicClubHeader from '../components/PublicClubHeader.vue'
import PublicClubFooter from '../components/PublicClubFooter.vue'
import { useI18n } from '../i18n'
const { isZh } = useI18n()
const tiers = computed(() => [
  { name: 'Lite', q7: 23, q8: 28, save: '—', class: 'lite' },
  { name: 'Plus', q7: 21, q8: 26, save: isZh.value ? '$2 / 小时' : '$2 / hour', class: 'plus' },
  { name: 'Pro', q7: 19, q8: 24, save: isZh.value ? '$4 / 小时' : '$4 / hour', class: 'pro' },
  { name: 'Pro Max', q7: 17, q8: 22, save: isZh.value ? '$6 / 小时' : '$6 / hour', class: 'max' }
])
const services = [
  { en: 'Cue tip replacement', zh: '更换皮头', price: 'From $40' }, { en: 'Cue cleaning & care', zh: '球杆清洁保养', price: 'From $30' },
  { en: 'Shaft inspection & repair', zh: '前节检测维修', price: 'Quote' }, { en: 'Customisation & modification', zh: '定制与改装', price: 'Quote' },
  { en: 'Grip replacement', zh: '更换皮把', price: 'Quote' }
]
onMounted(() => {
  document.title = isZh.value ? '价格与服务 - Joy Billiards NZ' : 'Pricing & Services - Joy Billiards NZ'
  document.querySelector('meta[name="description"]')?.setAttribute('content', 'Joy Billiards Hamilton table rates, membership pricing, cue services and opening hours.')
})
</script>

<style scoped>
.info-page{--red:#d9212f;min-height:100svh;padding:0 20px 36px;background:radial-gradient(circle at 8% 4%,rgba(217,33,47,.08),transparent 25%),linear-gradient(180deg,#fbfaf8,#f1f0ee);color:#191817;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}.page-shell{width:min(100%,1120px);margin:auto}.hero{display:grid;grid-template-columns:1.4fr .6fr;gap:20px;align-items:stretch;padding:54px;border-radius:34px;background:linear-gradient(130deg,#211417,#141416 72%);box-shadow:0 28px 70px rgba(27,20,21,.18);color:#fff}.hero-copy{max-width:670px}.eyebrow,.section-heading p{margin:0;color:#c59a57;font-size:10px;font-weight:900;letter-spacing:.19em}.hero h1{max-width:660px;margin:16px 0;font-size:clamp(39px,6vw,70px);line-height:1.01;letter-spacing:-.055em}.hero-copy>p:not(.eyebrow){max-width:630px;margin:0;color:#bab6b6;font-size:14px;line-height:1.8}.hero-actions{display:flex;gap:10px;margin-top:28px}.hero-actions a{min-height:48px;padding:0 19px;border-radius:14px;display:inline-flex;align-items:center;justify-content:center;font-size:13px;font-weight:850;text-decoration:none}.primary{background:var(--red);color:#fff}.secondary{border:1px solid rgba(255,255,255,.18);color:#fff}.rate-spotlight{display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:270px;border:1px solid rgba(255,255,255,.09);border-radius:25px;background:radial-gradient(circle at 50% 30%,rgba(184,138,66,.25),rgba(255,255,255,.045) 60%);text-align:center}.rate-spotlight span{color:#c9c4c3;font-size:9px;font-weight:900;letter-spacing:.18em}.rate-spotlight strong{margin-top:8px;font-size:78px;line-height:1}.rate-spotlight strong small{font-size:25px;vertical-align:top}.rate-spotlight em{color:#d1ab6f;font-size:12px;font-style:normal;font-weight:800}.rate-spotlight p{margin:18px 0 0;color:#8f8989;font-size:10px}.section{margin-top:22px;padding:42px;border:1px solid #e5e1dc;border-radius:30px;background:rgba(255,255,255,.86);box-shadow:0 16px 42px rgba(42,36,31,.055)}.section-heading{margin-bottom:24px}.section-heading h2{margin:7px 0 0;font-size:30px;letter-spacing:-.035em}.compact{margin-bottom:17px}.table-cards{display:grid;grid-template-columns:1fr 1fr;gap:14px}.table-card{display:flex;align-items:center;gap:18px;padding:23px;border:1px solid #e5e2df;border-radius:21px}.table-mark{display:grid;place-items:center;width:62px;height:62px;border-radius:18px;font-size:21px;font-weight:950}.silver .table-mark{background:linear-gradient(145deg,#e9ecf0,#b8bec6);color:#353b43}.gold .table-mark{background:linear-gradient(145deg,#f7e2a9,#b78b36);color:#4d3917}.table-card>div:last-child{display:grid;grid-template-columns:1fr auto;align-items:end;flex:1}.table-card span{color:#6e6a66;font-size:12px;font-weight:750}.table-card strong{grid-row:1/3;grid-column:2;font-size:28px}.table-card strong small{font-size:12px}.table-card p{margin:4px 0 0;color:#a09b96;font-size:10px}.rate-grid{margin-top:18px;border:1px solid #e7e3df;border-radius:19px;overflow:hidden}.rate-row{display:grid;grid-template-columns:1.2fr .7fr .7fr 1fr;align-items:center;min-height:57px;padding:0 20px;border-top:1px solid #edeae6;font-size:13px}.rate-row:first-child{border-top:0}.rate-row>span:first-child{display:flex;align-items:center;gap:9px}.rate-row i{width:9px;height:9px;border-radius:50%}.rate-row i.lite{background:#92979e}.rate-row i.plus{background:#2875be}.rate-row i.pro{background:#c52531}.rate-row i.max{background:#d1a249}.rate-head{min-height:40px;background:#f5f3f0;color:#96918c;font-size:9px;font-weight:900;letter-spacing:.1em}.fine-print{margin:14px 2px 0;color:#98938d;font-size:10px;line-height:1.65}.split-section{display:grid;grid-template-columns:1.1fr .9fr;gap:32px}.service-list{border-top:1px solid #dedbd7}.service-list div{display:flex;justify-content:space-between;gap:20px;padding:15px 2px;border-bottom:1px solid #ebe8e4;font-size:13px}.service-list strong{color:#bd2833}.visit-card{padding:28px;border-radius:23px;background:#171719;color:#fff}.visit-card h2{margin:8px 0 20px;font-size:28px}.visit-card>div{display:flex;justify-content:space-between;gap:10px;padding:12px 0;border-bottom:1px solid rgba(255,255,255,.08);font-size:11px}.visit-card>div span{color:#898687}.visit-card a{display:flex;justify-content:space-between;gap:15px;margin-top:21px;color:#d7ae6e;font-size:11px;line-height:1.5;text-decoration:none}@media(max-width:760px){.info-page{padding:0 12px 28px}.hero{grid-template-columns:1fr;padding:34px 25px}.rate-spotlight{min-height:190px}.table-cards,.split-section{grid-template-columns:1fr}.section{padding:28px 20px}.rate-row{grid-template-columns:1.1fr .55fr .55fr .9fr;padding:0 12px;font-size:11px}.rate-head{font-size:8px}.split-section{gap:22px}}@media(max-width:390px){.hero{padding:30px 20px}.hero-actions{flex-direction:column}.table-card{padding:18px 14px}.table-mark{width:52px;height:52px}.rate-row{font-size:10px}.rate-row i{display:none}}
</style>
