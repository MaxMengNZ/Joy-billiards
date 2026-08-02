<template>
  <main class="club-page">
    <div class="glow glow-red"></div>
    <div class="glow glow-gold"></div>

    <section class="club-shell">
      <header class="brand">
        <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards New Zealand" class="brand-logo">
        <div class="brand-copy">
          <strong>JOY CLUB</strong>
          <span>PLAY · ENJOY · BELONG</span>
        </div>
      </header>

      <article class="hero-card">
        <p class="eyebrow">THE OFFICIAL JOY BILLIARDS APP</p>
        <h1>你的比赛、荣耀<br><em>与球房生活。</em></h1>
        <p class="intro">报名 JOY 赛事、查看排名与个人战绩，使用记分牌、点歌、会员积分、卡包和门店服务。</p>

        <div class="feature-grid">
          <div><strong>赛事</strong><span>报名与个人记录</span></div>
          <div><strong>排名</strong><span>Pro 与 Student</span></div>
          <div><strong>卡包</strong><span>积分兑换与权益</span></div>
        </div>
      </article>

      <section class="action-card">
        <button type="button" class="primary" @click="openApp">
          <span>打开 Joy Club App</span><span aria-hidden="true">↗</span>
        </button>
        <router-link class="secondary" to="/register">创建 JOY 账号</router-link>
        <a class="store" href="https://apps.apple.com/app/id6796553031" target="_blank" rel="noopener">
          <span class="apple">●</span>
          <span><small>Download on the</small>App Store</span>
        </a>
        <p>受邀测试用户请通过 TestFlight 安装。Joy Club 账号与门店赛事及会员系统相连。</p>
      </section>

      <footer>
        <strong>JOY BILLIARDS NEW ZEALAND</strong>
        <span>88 Tristram Street, Hamilton Central</span>
        <nav>
          <router-link to="/privacy-policy">隐私政策</router-link>
          <router-link to="/terms-of-service">用户协议</router-link>
          <router-link to="/account-deletion">删除账号</router-link>
        </nav>
      </footer>
    </section>
  </main>
</template>

<script setup>
const openApp = () => {
  window.location.href = 'joybilliardsapp:///login'
}
</script>

<style scoped>
.club-page{--red:#e52b36;min-height:100svh;position:relative;overflow:hidden;padding:32px 18px 42px;background:radial-gradient(circle at 50% -8%,#fff 0,#f8f5f1 38%,#eff1f4 100%);color:#17191d;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}.club-shell{position:relative;z-index:1;width:min(100%,540px);margin:0 auto}.glow{position:absolute;border-radius:50%;pointer-events:none}.glow-red{width:360px;height:360px;left:-230px;top:15%;background:rgba(229,43,54,.055)}.glow-gold{width:380px;height:380px;right:-260px;bottom:2%;border:52px solid rgba(198,151,70,.055)}.brand{display:flex;align-items:center;justify-content:center;gap:16px;margin:2px 0 27px}.brand-logo{width:112px;height:58px;object-fit:contain}.brand-copy{display:flex;flex-direction:column;padding-left:16px;border-left:1px solid #d4d7dc}.brand-copy strong{font-size:18px;letter-spacing:.14em}.brand-copy span{margin-top:5px;color:#8b8f97;font-size:8px;font-weight:800;letter-spacing:.18em}.hero-card{position:relative;overflow:hidden;padding:36px 27px 29px;border-radius:32px;background:linear-gradient(145deg,#29171b,#111318 72%);box-shadow:0 25px 58px rgba(24,18,20,.2);color:#fff}.hero-card:after{content:"8";position:absolute;right:-17px;bottom:-96px;color:rgba(255,255,255,.035);font:800 260px Georgia,serif}.eyebrow{position:relative;z-index:1;margin:0;color:#d5aa60;font-size:9px;font-weight:900;letter-spacing:.2em}.hero-card h1{position:relative;z-index:1;margin:17px 0 15px;font-size:clamp(34px,9vw,48px);line-height:1.12;letter-spacing:-.045em}.hero-card h1 em{color:#f03a44;font-style:normal}.intro{position:relative;z-index:1;max-width:430px;margin:0;color:#aeb1b8;font-size:13px;line-height:1.8}.feature-grid{position:relative;z-index:1;display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-top:27px}.feature-grid div{padding:13px 8px;border:1px solid rgba(255,255,255,.075);border-radius:13px;background:rgba(255,255,255,.055);text-align:center}.feature-grid strong,.feature-grid span{display:block}.feature-grid strong{font-size:14px}.feature-grid span{margin-top:4px;color:#777c85;font-size:8px}.action-card{margin-top:14px;padding:23px 21px;border:1px solid rgba(255,255,255,.92);border-radius:27px;background:rgba(255,255,255,.88);box-shadow:0 16px 40px rgba(29,34,43,.08);backdrop-filter:blur(18px)}.primary,.secondary,.store{box-sizing:border-box;width:100%;min-height:54px;border-radius:16px;display:flex;align-items:center;justify-content:center;text-decoration:none;font-weight:850}.primary{justify-content:space-between;padding:0 20px;border:0;background:linear-gradient(110deg,#ef1f2c,#d91d29);box-shadow:0 12px 24px rgba(229,43,54,.22);color:#fff;font-size:15px;cursor:pointer}.secondary{margin-top:10px;border:1px solid #dfe1e5;background:#fff;color:#202227;font-size:14px}.store{gap:10px;margin-top:10px;border:1px solid #1d1f23;color:#17191d;font-size:15px;line-height:1}.store small{display:block;margin-bottom:3px;font-size:8px;font-weight:500}.apple{font-size:19px}.action-card p{margin:13px 8px 0;color:#969aa2;font-size:10px;line-height:1.6;text-align:center}footer{display:flex;flex-direction:column;gap:4px;margin-top:26px;color:#898d95;font-size:10px;letter-spacing:.04em;text-align:center}footer strong{color:#555960;font-size:9px;letter-spacing:.12em}footer nav{display:flex;justify-content:center;gap:17px;margin-top:7px}footer a{color:#757982;text-decoration:none}@media(max-width:380px){.club-page{padding-left:12px;padding-right:12px}.hero-card{padding:30px 20px 25px}.brand-logo{width:94px}.feature-grid{gap:5px}.feature-grid span{font-size:7px}.action-card{padding:20px 17px}}
</style>
