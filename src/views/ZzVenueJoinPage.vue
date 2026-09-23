<template>
  <main class="page">
    <div class="glow glow-red"></div>
    <div class="glow glow-gold"></div>
    <section class="shell">
      <header>
        <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards New Zealand" />
        <span>PLAY · ENJOY · BELONG</span>
      </header>

      <article class="hero">
        <div class="venue-mark">ZZ</div>
        <p class="eyebrow">OFFICIAL VENUE MEMBERSHIP</p>
        <h1>Join ZZ Joy<br />Billiards Club.</h1>
        <p class="lead">
          Scan once. Your Joy Club account will remember ZZ Melbourne as your
          home venue.
        </p>

        <div class="venue-card">
          <span>YOUR HOME VENUE</span>
          <strong>ZZ Joy Billiards Club</strong>
          <p>Unit 204/12 Heagney Passage<br />Melbourne VIC 3000, Australia</p>
          <small>Open daily · 12 pm–2 am</small>
        </div>

        <div class="actions">
          <button type="button" @click="openApp">
            Open Joy Club App <b>→</b>
          </button>
          <router-link to="/register?venue=zz-joy-melbourne"
            >Create an account</router-link
          >
        </div>
        <p class="note">
          Already a member? Opening the App will securely add ZZ and make it
          your selected venue. New members can create an account first.
        </p>
      </article>

      <section class="trust">
        <div><b>01</b><span>Official permanent venue link</span></div>
        <div><b>02</b><span>One Joy Club account</span></div>
        <div><b>03</b><span>Venue data stays separated</span></div>
      </section>

      <footer>
        <strong>JOY BILLIARDS NEW ZEALAND</strong>
        <span>Secure venue membership · Australia</span>
      </footer>
    </section>
  </main>
</template>

<script setup>
import { openAppRouteWithDownloadFallback } from "../utils/appDownload";

const openApp = () => {
  if (!openAppRouteWithDownloadFallback("/app/zz")) {
    window.location.href = "/register?venue=zz-joy-melbourne";
  }
};
</script>

<style scoped>
.page {
  min-height: 100vh;
  overflow: hidden;
  color: #17181b;
  background: #f4f3f1;
  font-family:
    Inter,
    -apple-system,
    BlinkMacSystemFont,
    "Segoe UI",
    sans-serif;
  position: relative;
}
.glow {
  position: fixed;
  width: 420px;
  height: 420px;
  border-radius: 50%;
  filter: blur(100px);
  opacity: 0.13;
  pointer-events: none;
}
.glow-red {
  top: -180px;
  right: -120px;
  background: #ed2939;
}
.glow-gold {
  bottom: -230px;
  left: -120px;
  background: #c79a43;
}
.shell {
  width: min(100% - 40px, 760px);
  margin: 0 auto;
  padding: 30px 0 42px;
  position: relative;
}
header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
}
header img {
  width: 82px;
  height: 48px;
  object-fit: contain;
}
header span,
.eyebrow,
.venue-card > span {
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.18em;
  color: #8c7751;
}
.hero {
  margin-top: 38px;
  padding: 38px;
  border: 1px solid rgba(31, 32, 35, 0.08);
  border-radius: 34px;
  background: rgba(255, 255, 255, 0.88);
  box-shadow: 0 24px 70px rgba(40, 35, 31, 0.1);
  backdrop-filter: blur(18px);
}
.venue-mark {
  float: right;
  width: 68px;
  height: 68px;
  display: grid;
  place-items: center;
  color: white;
  background: linear-gradient(145deg, #ed2939, #aa1523);
  border-radius: 22px;
  font-size: 25px;
  font-weight: 900;
  box-shadow: 0 13px 30px rgba(221, 31, 49, 0.24);
}
.eyebrow {
  margin: 8px 0 16px;
  color: #ed2939;
}
h1 {
  margin: 0;
  max-width: 570px;
  font-size: clamp(44px, 9vw, 74px);
  line-height: 0.94;
  letter-spacing: -0.065em;
}
.lead {
  max-width: 540px;
  margin: 25px 0 30px;
  color: #74716d;
  font-size: 18px;
  line-height: 1.55;
}
.venue-card {
  padding: 24px;
  border-radius: 23px;
  color: white;
  background: linear-gradient(145deg, #242529, #101113);
  box-shadow: inset 0 1px rgba(255, 255, 255, 0.12);
}
.venue-card strong {
  display: block;
  margin: 10px 0 8px;
  font-size: 23px;
}
.venue-card p {
  margin: 0;
  color: #d3d0cb;
  line-height: 1.5;
}
.venue-card small {
  display: block;
  margin-top: 16px;
  color: #d6ae61;
  font-weight: 700;
}
.actions {
  display: grid;
  gap: 12px;
  margin-top: 22px;
}
.actions button,
.actions a {
  min-height: 58px;
  border: 0;
  border-radius: 18px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 21px;
  font: inherit;
  font-weight: 800;
  text-decoration: none;
  cursor: pointer;
}
.actions button {
  color: white;
  background: #ed2939;
  box-shadow: 0 11px 25px rgba(221, 31, 49, 0.19);
}
.actions a {
  color: #222327;
  background: #eeece8;
}
.note {
  margin: 18px 4px 0;
  color: #898681;
  font-size: 13px;
  line-height: 1.55;
}
.trust {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin: 20px 0;
}
.trust div {
  padding: 18px;
  border-radius: 18px;
  background: rgba(255, 255, 255, 0.72);
}
.trust b {
  color: #c79a43;
}
.trust span {
  display: block;
  margin-top: 8px;
  font-size: 13px;
  font-weight: 700;
}
footer {
  display: flex;
  justify-content: space-between;
  gap: 15px;
  padding: 20px 4px 0;
  color: #97928b;
  font-size: 11px;
  letter-spacing: 0.06em;
}
@media (max-width: 600px) {
  .shell {
    width: min(100% - 24px, 760px);
    padding-top: 18px;
  }
  header span {
    display: none;
  }
  .hero {
    margin-top: 20px;
    padding: 25px 20px;
    border-radius: 28px;
  }
  .venue-mark {
    width: 56px;
    height: 56px;
    border-radius: 18px;
    font-size: 21px;
  }
  .trust {
    grid-template-columns: 1fr;
  }
  footer {
    flex-direction: column;
  }
}
</style>
