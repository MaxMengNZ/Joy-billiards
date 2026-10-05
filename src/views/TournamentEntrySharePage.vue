<template>
  <main class="event-page">
    <section class="event-shell">
      <header class="top-bar">
        <a href="/" class="brand" aria-label="Joy Club">JOY CLUB</a>
        <LanguageSwitcher />
      </header>
      <article v-if="loading" class="state-card" role="status">
        <div class="spinner"></div>
        <h1>{{ text.loading }}</h1>
      </article>
      <article v-else-if="error || !event" class="state-card" role="alert">
        <h1>{{ text.notFound }}</h1>
        <p>{{ text.notFoundHint }}</p>
        <button class="secondary" type="button" @click="loadEvent">
          {{ text.retry }}
        </button>
      </article>
      <template v-else>
        <div class="event-actions">
          <span class="status" :class="{ live: state === 'live' }">{{
            statusText
          }}</span>
          <button class="share" type="button" @click="shareEvent">
            {{ text.share }}
          </button>
        </div>
        <p v-if="shareNotice" role="status" class="notice">{{ shareNotice }}</p>
        <div class="poster">
          <img
            v-if="banner && !bannerFailed"
            :src="banner"
            :alt="event.name"
            @error="bannerFailed = true"
          />
          <div v-else class="poster-fallback">
            <strong>JOY CLUB</strong><span>Play · Enjoy · Belong</span>
          </div>
        </div>
        <article class="intro">
          <p class="kind">{{ eventKind }}</p>
          <h1>{{ event.name }}</h1>
          <p class="date">{{ eventDate }}</p>
          <p class="local-time">
            {{ text.localTime }} · {{ venue.timezone || "Pacific/Auckland" }}
          </p>
          <strong class="venue">{{
            venue.name || text.venueUnavailable
          }}</strong>
          <p class="address">{{ venue.address || "" }}</p>
        </article>
        <section class="facts">
          <div>
            <span>{{ text.entryFee }}</span
            ><strong>{{ entryFee }}</strong>
          </div>
          <div>
            <span>{{ text.players }}</span
            ><strong>{{ playerCount }}</strong>
          </div>
        </section>
        <p v-if="counts.pendingCount !== null" class="fee-note" role="status">
          {{ text.pending }} {{ counts.pendingCount }} · {{ text.waitlisted }} {{ counts.waitlistedCount ?? '—' }}
        </p>
        <p v-if="registrationCount === null" class="fee-note" role="status">
          {{ text.countUnavailable }}
          <button class="share" type="button" @click="loadEvent({ quiet: true })">{{ text.retry }}</button>
        </p>
        <p
          v-if="
            publicEntry?.onlinePaymentEnabled && Number(event.entry_fee) > 0
          "
          class="fee-note"
        >
          {{ text.feeNote }}
        </p>
        <article class="details">
          <h2>{{ text.details }}</h2>
          <p class="description">
            {{ event.description || text.defaultDescription }}
          </p>
          <template
            v-if="
              publicEntry?.eligibilityKind === 'u21' ||
              publicEntry?.eligibilityKind === 'women'
            "
          >
            <h2>{{ text.eligibility }}</h2>
            <p>
              {{
                publicEntry.eligibilityKind === "women" ? text.women : text.u21
              }}<template
                v-if="
                  publicEntry.eligibilityKind === 'u21' &&
                  publicEntry.ageCutoffDate
                "
              >
                · {{ publicEntry.ageCutoffDate }}</template
              >
            </p>
          </template>
          <h2>{{ text.confirmation }}</h2>
          <p>{{ text.security }}</p>
        </article>
        <aside
          v-if="paymentReturned"
          class="notice payment-notice"
          role="status"
        >
          <strong>{{
            route.query.payment === "success"
              ? text.paymentReturn
              : text.paymentCancelled
          }}</strong>
          <p>{{ text.paymentHint }}</p>
        </aside>
        <aside v-if="inWeChat" class="notice" role="note">
          {{ text.wechat }}
        </aside>
        <section class="entry-card">
          <button class="primary" type="button" @click="openApp">
            {{
              paymentReturned
                ? text.checkEntry
                : canEnter
                  ? text.openAndEnter
                  : text.openEvent
            }}
          </button>
          <button
            v-if="canEnter && !paymentReturned"
            class="secondary"
            type="button"
            @click="createAccount"
          >
            {{ text.createAndEnter }}
          </button>
          <p v-else class="closed-note">{{ statusText }}</p>
          <p class="app-hint">{{ text.appHint }}</p>
          <div class="stores">
            <a
              v-for="option in downloadOptions"
              :key="option.platform"
              :href="option.url"
              target="_blank"
              rel="noopener noreferrer"
              >{{ option.label }}</a
            >
          </div>
        </section>
        <footer>
          <strong>{{ venue.name || "JOY CLUB" }}</strong
          ><span>{{ venue.address || "" }}</span
          ><span>Play · Enjoy · Belong</span>
        </footer>
      </template>
    </section>
  </main>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import LanguageSwitcher from "../components/LanguageSwitcher.vue";
import { publicEventCounts } from '../utils/eventShare.js';
import { supabase } from "../config/supabase";
import { useI18n } from "../i18n";
import {
  downloadOptionsForClient,
  openAppRouteWithDownloadFallback,
} from "../utils/appDownload";
import {
  EVENT_UUID,
  EVENT_REFERENCE,
  eventAppRoute,
  eventSharePath,
  eventRegistrationState,
  safeEventBanner,
} from "../utils/eventShare";

const route = useRoute();
const router = useRouter();
const { locale } = useI18n();
const event = ref(null),
  publicEntry = ref(null),
  venue = ref({}),
  registrationCount = ref(null);
const counts = ref(publicEventCounts(null));
const loading = ref(true),
  error = ref(""),
  bannerFailed = ref(false),
  shareNotice = ref("");
const downloadOptions = downloadOptionsForClient();
const inWeChat = /MicroMessenger/i.test(navigator.userAgent);
let request = 0;
const copy = {
  zh: {
    loading: "正在载入赛事",
    notFound: "暂时无法打开赛事",
    notFoundHint: "请检查网络或分享链接，然后重试。",
    retry: "重新加载",
    share: "分享赛事",
    entryFee: "报名费",
    players: "已确认参赛",
    pending: "待付款／确认",
    waitlisted: "候补",
    countUnavailable: "报名人数暂未载入，不影响打开 App 查看赛事。",
    free: "免费报名",
    open: "接受报名",
    full: "名额已满",
    soon: "即将开放",
    closed: "报名已结束",
    live: "正在进行",
    completed: "已结束",
    details: "赛事详情",
    defaultDescription: "完整赛事安排和报名信息请在 Joy Club App 内查看。",
    eligibility: "参赛资格",
    women: "女子赛事；资格由赛事主办方核验。",
    u21: "U21 赛事，须按主办方规定的年龄截止日核验。",
    confirmation: "报名确认",
    security:
      "在线支付须经服务器确认；银行转账须由门店管理员核实到账。未完成确认前不代表正式报名成功。",
    createAndEnter: "没有账户？创建账户",
    openAndEnter: "在 App 中查看并报名",
    openEvent: "在 App 中查看赛事",
    appHint:
      "创建并验证账户后，请从原赛事链接返回。下载 App 不会自动完成报名。",
    weekly: "周赛",
    student: "学生赛",
    official: "公开赛事",
    localTime: "门店当地时间",
    venueUnavailable: "门店信息暂未载入",
    feeNote: "在线支付的手续费会在付款前列明；最终金额以结账页面为准。",
    wechat:
      "微信内可能无法打开 App 或应用商店。请点右上角「…」，选择在浏览器打开，再继续报名。",
    copied: "赛事链接已复制",
    shareFailed: "暂时无法分享，请复制浏览器地址。",
    desktop: "请在手机上打开此赛事链接；尚无 App 可从下方下载。",
    paymentReturn: "已从付款页面返回",
    paymentCancelled: "付款未完成",
    paymentHint:
      "返回链接不是付款凭证。请打开 App 查看服务器确认后的个人报名状态；不要重复付款。",
    checkEntry: "打开 App 核对报名",
  },
  en: {
    loading: "Loading event details",
    notFound: "Unable to open this event",
    notFoundHint: "Check your connection or shared link, then try again.",
    retry: "Try again",
    share: "Share event",
    entryFee: "Entry fee",
    players: "Confirmed players",
    pending: "Awaiting payment / confirmation",
    waitlisted: "Waitlisted",
    countUnavailable: "Entry counts are unavailable. You can still open the event in the App.",
    free: "Free entry",
    open: "Registration open",
    full: "Full",
    soon: "Opening soon",
    closed: "Registration closed",
    live: "Live now",
    completed: "Completed",
    details: "Event details",
    defaultDescription:
      "View the full event arrangements and entry information in Joy Club.",
    eligibility: "Eligibility",
    women: "Women’s event. Eligibility is verified by the organiser.",
    u21: "U21 event. Age is checked against the organiser’s eligibility cutoff.",
    confirmation: "Entry confirmation",
    security:
      "Online payments require server confirmation. Bank transfers require the venue administrator to verify receipt. Your entry is not confirmed before this step.",
    createAndEnter: "New to Joy Club? Create account",
    openAndEnter: "Open App to view & enter",
    openEvent: "Open event in App",
    appHint:
      "After creating and verifying your account, return using this event link. Downloading the App does not complete your entry.",
    weekly: "Weekly tournament",
    student: "Student tournament",
    official: "Public event",
    localTime: "Venue local time",
    venueUnavailable: "Venue information unavailable",
    feeNote:
      "Online processing fees are shown before payment. The final total is displayed at checkout.",
    wechat:
      "WeChat may block App and store links. Tap “…” at the top right and open this page in your browser to continue.",
    copied: "Event link copied",
    shareFailed: "Sharing unavailable. Copy the address from your browser.",
    desktop:
      "Open this event link on your phone. Download Joy Club below if needed.",
    paymentReturn: "Returned from checkout",
    paymentCancelled: "Payment not completed",
    paymentHint:
      "The return link is not proof of payment. Open the App to check your server-confirmed entry status. Do not pay again.",
    checkEntry: "Open App to check entry",
  },
};
const text = computed(() => copy[locale.value] || copy.en);
const options = computed(() => event.value?.event_options || {});
const eventKind = computed(() =>
  options.value.kind === "weekly_pro"
    ? text.value.weekly
    : options.value.kind === "weekly_student"
      ? text.value.student
      : (locale.value === "zh"
          ? options.value.customLabel
          : options.value.customLabelEn) || text.value.official,
);
const eventDate = computed(() => {
  if (!event.value || !Number.isFinite(Date.parse(event.value.start_date)))
    return "—";
  try {
    return new Intl.DateTimeFormat(
      locale.value === "zh"
        ? "zh-CN"
        : event.value.currency === "aud"
          ? "en-AU"
          : "en-NZ",
      {
        dateStyle: "long",
        timeStyle: "short",
        timeZone: venue.value.timezone || "Pacific/Auckland",
      },
    ).format(new Date(event.value.start_date));
  } catch {
    return "—";
  }
});
const entryFee = computed(() => {
  const fee = Number(publicEntry.value?.entryFeeNzd ?? event.value?.entry_fee);
  if (!Number.isFinite(fee)) return "—";
  return fee > 0
    ? `${String(publicEntry.value?.currency || event.value?.currency || "nzd").toUpperCase()} $${fee.toFixed(2)}`
    : text.value.free;
});
const playerCount = computed(
  () =>
    `${registrationCount.value ?? "—"}${event.value?.max_players ? ` / ${event.value.max_players}` : ""}`,
);
const state = computed(() =>
  eventRegistrationState(
    event.value,
    publicEntry.value,
    registrationCount.value,
  ),
);
const canEnter = computed(() => state.value === "open");
const statusText = computed(() => text.value[state.value]);
const banner = computed(() => safeEventBanner(options.value.bannerUrl));
const paymentReturned = computed(() =>
  ["success", "cancelled"].includes(route.query.payment),
);
const createAccount = () =>
  router.push({
    path: "/join",
    query: { event: event.value.id, venue: event.value.venue_id || undefined },
  });
const openApp = () => {
  if (inWeChat) {
    shareNotice.value = text.value.wechat;
    return;
  }
  if (
    !openAppRouteWithDownloadFallback(
      eventAppRoute(event.value.id, route.query),
    )
  ) {
    shareNotice.value = text.value.desktop;
    document.querySelector(".stores")?.scrollIntoView({ behavior: "smooth" });
  }
};
const shareEvent = async () => {
  const url = new URL(eventSharePath(event.value), window.location.origin).href;
  try {
    if (navigator.share && !inWeChat)
      await navigator.share({
        title: event.value.name,
        text: event.value.name,
        url,
      });
    else {
      await navigator.clipboard.writeText(url);
      shareNotice.value = text.value.copied;
    }
  } catch (reason) {
    if (reason?.name !== "AbortError")
      shareNotice.value = text.value.shareFailed;
  }
};
async function loadEvent({ quiet = false } = {}) {
  const seq = ++request;
  if (!quiet) loading.value = true;
  error.value = "";
  try {
    let id = String(route.params.id || "");
    if (!EVENT_UUID.test(id)) {
      const reference = String(route.params.reference || "");
      if (!EVENT_REFERENCE.test(reference)) throw new Error("INVALID_LINK");
      const resolved = await supabase
        .from("tournaments")
        .select("id")
        .or(
          `share_code.eq.${reference.toUpperCase()},share_alias.eq.${reference.toLowerCase()}`,
        )
        .maybeSingle();
      if (resolved.error || !resolved.data?.id) throw new Error("NOT_FOUND");
      id = resolved.data.id;
    }
    const [eventResult, entryResult, countResult] = await Promise.all([
      supabase
        .from("tournaments")
        .select(
          "id,venue_id,name,description,event_options,start_date,status,max_players,entry_fee,currency,share_alias,share_code",
        )
        .eq("id", id)
        .maybeSingle(),
      supabase.rpc("app_get_public_tournament_entry", { p_tournament_id: id }),
      supabase.rpc("app_get_public_tournament_counts", { p_tournament_id: id }),
    ]);
    if (eventResult.error || !eventResult.data) throw new Error("NOT_FOUND");
    const venueResult = await supabase
      .from("venues")
      .select("id,name,address,timezone,currency")
      .eq("id", eventResult.data.venue_id)
      .maybeSingle();
    if (seq !== request) return;
    event.value = eventResult.data;
    publicEntry.value = entryResult.error ? null : entryResult.data;
    // Do not query private roster rows or invent a zero if counts are unavailable.
    counts.value = publicEventCounts(countResult.error ? null : countResult.data);
    registrationCount.value = counts.value.confirmedCount ?? publicEventCounts(
      entryResult.error ? null : entryResult.data,
    ).confirmedCount;
    venue.value = venueResult.error ? {} : venueResult.data || {};
    bannerFailed.value = false;
    document.title = `${event.value.name} · JOY CLUB`;
  } catch {
    if (seq === request) error.value = "LOAD_FAILED";
  } finally {
    if (seq === request) loading.value = false;
  }
}
const resume = () => {
  if (document.visibilityState === "visible" && !loading.value)
    void loadEvent({ quiet: true });
};
watch(
  () => route.fullPath,
  () => {
    event.value = null;
    void loadEvent();
  },
);
onMounted(() => {
  void loadEvent();
  document.addEventListener("visibilitychange", resume);
});
onUnmounted(() => {
  request++;
  document.removeEventListener("visibilitychange", resume);
});
</script>

<style scoped>
.event-page,
.event-page * {
  box-sizing: border-box;
}
.event-page {
  --red: #d32235;
  min-height: 100svh;
  padding: 24px 20px 36px;
  background: #f5f6f8;
  color: #202127;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}
.event-shell {
  max-width: 720px;
  margin: auto;
}
.top-bar,
.event-actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 24px;
}
.brand {
  color: #202127;
  font-size: 20px;
  font-weight: 850;
  text-decoration: none;
}
.event-actions {
  margin-bottom: 16px;
}
.status {
  background: #fce9ec;
  color: #a9182a;
  padding: 8px 12px;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 750;
}
.status.live {
  background: var(--red);
  color: white;
}
.share {
  min-height: 44px;
  padding: 10px 14px;
  border: 1px solid #dedfe4;
  border-radius: 12px;
  background: white;
  color: var(--red);
  font: inherit;
  font-size: 14px;
  font-weight: 750;
  cursor: pointer;
}
.poster {
  aspect-ratio: 1.65;
  overflow: hidden;
  border-radius: 16px;
  background: #eceef1;
}
.poster img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: contain;
}
.poster-fallback {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
  background: #202127;
  color: white;
}
.poster-fallback strong {
  font-size: clamp(28px, 6vw, 48px);
}
.poster-fallback span {
  font-size: 15px;
  color: #e2e5eb;
}
.intro {
  padding: 24px 0;
}
.kind {
  margin: 0 0 8px;
  color: #a9182a;
  font-size: 14px;
  font-weight: 750;
}
h1 {
  margin: 0;
  font-size: clamp(28px, 6vw, 38px);
  line-height: 1.16;
  letter-spacing: -0.025em;
  overflow-wrap: anywhere;
}
.date {
  margin: 20px 0 4px;
  font-size: 18px;
  font-weight: 750;
  line-height: 1.5;
}
.local-time {
  margin: 0 0 18px;
  font-size: 13px;
  color: #626774;
}
.venue {
  font-size: 16px;
  line-height: 1.5;
}
.address {
  margin: 4px 0 0;
  font-size: 14px;
  color: #626774;
  line-height: 1.6;
}
.facts {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}
.facts > div {
  padding: 18px;
  border: 1px solid #e2e5eb;
  border-radius: 16px;
  background: white;
}
.facts span,
.facts strong {
  display: block;
}
.facts span {
  font-size: 13px;
  color: #626774;
}
.facts strong {
  font-size: 23px;
  margin-top: 8px;
  font-variant-numeric: tabular-nums;
  overflow-wrap: anywhere;
}
.fee-note {
  color: #626774;
  font-size: 13px;
  line-height: 1.6;
}
.details {
  margin-top: 28px;
  padding: 0 0 20px;
}
h2 {
  font-size: 19px;
  margin: 24px 0 10px;
}
.details p {
  margin: 0;
  color: #525863;
  font-size: 15px;
  line-height: 1.75;
  max-width: 70ch;
}
.description {
  white-space: pre-line;
}
.notice {
  padding: 16px;
  margin: 16px 0;
  border-radius: 12px;
  background: #fff0f2;
  color: #8e1b2c;
  font-size: 14px;
  line-height: 1.65;
}
.payment-notice p {
  margin: 8px 0;
}
.entry-card {
  position: sticky;
  bottom: 0;
  padding: 18px 0 max(14px, env(safe-area-inset-bottom));
  border-top: 1px solid #dedfe4;
  background: #f5f6f8;
}
.primary,
.secondary {
  width: 100%;
  min-height: 52px;
  padding: 14px 18px;
  border-radius: 14px;
  font: inherit;
  font-size: 16px;
  font-weight: 750;
  cursor: pointer;
}
.primary {
  border: 0;
  background: var(--red);
  color: white;
}
.secondary {
  margin-top: 10px;
  border: 1px solid #dedfe4;
  background: white;
  color: var(--red);
}
.app-hint,
.closed-note {
  font-size: 13px;
  line-height: 1.6;
  color: #626774;
  margin: 12px 0;
}
.stores {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}
.stores a {
  color: #a9182a;
  font-size: 14px;
  line-height: 1.7;
  text-underline-offset: 4px;
}
footer {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-top: 30px;
  color: #626774;
  font-size: 12px;
  text-align: center;
  line-height: 1.5;
}
.state-card {
  min-height: 400px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  gap: 18px;
}
.state-card p {
  font-size: 15px;
  line-height: 1.7;
  color: #626774;
}
.state-card .secondary {
  max-width: 240px;
}
.spinner {
  width: 44px;
  height: 44px;
  border: 3px solid #dedfe4;
  border-top-color: var(--red);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}
button:focus-visible,
a:focus-visible {
  outline: 3px solid #8e1b2c;
  outline-offset: 4px;
}
::selection {
  background: #fbd9df;
  color: #202127;
}
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
@media (prefers-reduced-motion: reduce) {
  .spinner {
    animation: none;
  }
}
@media (max-width: 390px) {
  .event-page {
    padding: 18px 16px 28px;
  }
  .facts > div {
    padding: 15px;
  }
  .facts strong {
    font-size: 20px;
  }
}
</style>
