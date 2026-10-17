<template>
  <section class="entry-guide" aria-labelledby="entry-guide-title">
    <h2 id="entry-guide-title">{{ text.title }}</h2>
    <aside v-if="paymentReturned" class="return-note" role="status">
      <strong>{{ text.returnTitle }}</strong>
      <p>{{ text.returnHint }}</p>
    </aside>
    <p v-else class="intro">{{ canEnter ? text.intro : statusText }}</p>
    <p v-if="inWeChat" class="wechat" role="note">{{ text.wechat }}</p>
    <button class="primary" type="button" @click="$emit('open')">
      {{ paymentReturned ? text.check : canEnter ? text.open : text.view }}
    </button>
    <button v-if="canEnter && !paymentReturned" class="secondary" type="button" @click="$emit('create')">
      {{ text.create }}
    </button>
    <p class="personal-note">{{ text.personal }}</p>
    <details v-if="canEnter && !paymentReturned" class="help" :open="showSteps">
      <summary>{{ text.firstTime }}</summary>
      <ol>
        <li v-for="step in text.steps" :key="step">{{ step }}</li>
      </ol>
      <div class="stores">
        <a v-for="option in downloadOptions" :key="option.platform" :href="option.url" target="_blank" rel="noopener noreferrer">{{ option.label }}</a>
      </div>
      <button class="text-action" type="button" @click="$emit('copy')">{{ text.copy }}</button>
    </details>
    <details class="help">
      <summary>{{ text.statusTitle }}</summary>
      <p>{{ text.statusHint }}</p>
      <dl>
        <div v-for="item in text.statuses" :key="item[0]">
          <dt>{{ item[0] }}</dt><dd>{{ item[1] }}</dd>
        </div>
      </dl>
      <p class="safety">{{ text.safety }}</p>
    </details>
    <div v-if="!canEnter || paymentReturned" class="stores">
      <a v-for="option in downloadOptions" :key="option.platform" :href="option.url" target="_blank" rel="noopener noreferrer">{{ option.label }}</a>
    </div>
  </section>
</template>

<script setup>
import { computed } from 'vue';
const props = defineProps({ locale: String, canEnter: Boolean, paymentReturned: Boolean, inWeChat: Boolean, showSteps: Boolean, statusText: String, downloadOptions: Array });
defineEmits(['open', 'create', 'copy']);
const copy = {
  zh: {
    title: '报名与确认', intro: '已有 App？打开本场赛事，登录后继续报名。',
    open: '打开 App，继续报名', view: '在 App 中查看赛事', create: '首次参加？创建 JOY 账户',
    personal: '本页展示公开赛事信息；个人报名状态请在 App 内登录查看。',
    firstTime: '没有 App？查看报名步骤',
    steps: ['创建账户，并通过邮件完成邮箱验证。', '下载 App 并登录，然后回到本场赛事链接。', '打开 App 继续报名，完成付款或提交银行转账，核对报名状态。'],
    copy: '复制本场赛事链接，方便返回',
    statusTitle: '怎样才算报名成功？', statusHint: '以下为状态说明，不是你的个人报名结果。',
    statuses: [['待支付', '在线支付尚未确认完成，请先核对 App 内状态再继续付款。'], ['转账待确认', '按赛事提供的账户转账，附言填写选手姓名；管理员核实到账后确认。'], ['已确认', '本场赛事已正式确认你的参赛资格。'], ['已取消', '该笔报名不再有效；退款进度以管理员处理结果为准。']],
    safety: '下载 App、创建账户或返回付款页面，都不代表报名成功。',
    returnTitle: '请核对本场报名状态', returnHint: '你已返回赛事页面，支付结果仍以服务器确认为准。请打开 App 核对，勿重复付款。', check: '打开 App，核对报名状态',
    wechat: '微信内请点右上角「…」→ 在浏览器打开，再前往 App 或应用商店。',
  },
  en: {
    title: 'Entry & confirmation', intro: 'Have the App? Open this event and sign in to continue your entry.',
    open: 'Open App to continue entry', view: 'View event in App', create: 'First time? Create a JOY account',
    personal: 'This is a public event page. Sign in to the App to view your own entry status.',
    firstTime: 'No App yet? See the entry steps',
    steps: ['Create an account and verify your email.', 'Download the App and sign in, then return to this event link.', 'Open the event in the App, complete checkout or submit a bank transfer entry, and check your entry status.'],
    copy: 'Copy this event link for later',
    statusTitle: 'When is my entry confirmed?', statusHint: 'These explain the statuses; they are not your personal entry result.',
    statuses: [['Awaiting payment', 'Online payment has not been confirmed. Check your entry in the App before paying again.'], ['Transfer awaiting confirmation', 'Use the bank details supplied for this event and your player name as the reference. The organiser confirms receipt.'], ['Confirmed', 'Your place in this event has been formally confirmed.'], ['Cancelled', 'This entry is no longer active. Any refund depends on the organiser’s processing.']],
    safety: 'Installing the App, creating an account or returning from checkout does not confirm an entry.',
    returnTitle: 'Check your entry for this event', returnHint: 'You are back on the event page. Payment still requires server confirmation. Check in the App before paying again.', check: 'Open App to check entry status',
    wechat: 'In WeChat, tap “…” → Open in browser before opening the App or an app store.',
  },
};
const text = computed(() => copy[props.locale] || copy.en);
</script>

<style scoped>
.entry-guide{margin:24px 0 30px;padding:22px;background:#fff;border:1px solid #e2e5eb;border-radius:16px;color:#202127}
h2{margin:0 0 12px;font-size:21px;font-weight:750;line-height:1.3;letter-spacing:-.02em}
p,li,dd{font-size:14px;line-height:1.65;color:#626774}
.intro{margin:0 0 16px}.personal-note{margin:12px 0 18px;font-size:13px}
button{font:inherit;cursor:pointer;box-shadow:none;transform:none}
.primary,.secondary{width:100%;min-height:50px;padding:13px 16px;border-radius:12px;font-size:16px;font-weight:750;line-height:1.4}
.primary{margin:0;background:#d32235;color:#fff;border:0}.secondary{margin:10px 0 0;border:1px solid #dedfe4;background:#fff;color:#a9182a}
.primary:hover{background:#b81e2e}.secondary:hover{background:#fce9ec}
.help{border-top:1px solid #e2e5eb}.help summary{padding:16px 0;cursor:pointer;font-size:14px;font-weight:750;line-height:1.5}.help summary::marker{color:#a9182a}
.help p{margin:0 0 12px}ol{padding-left:22px;margin:0 0 16px}li+li{margin-top:8px}
dl{margin:0 0 16px}dl>div{padding:10px 0}dt{font-size:14px;font-weight:750}dd{margin:3px 0 0}
.help .safety{font-size:13px;margin-bottom:18px}.stores{display:flex;flex-wrap:wrap;gap:18px;margin:14px 0}
a,.text-action{color:#a9182a;font-size:14px;text-underline-offset:4px}.text-action{padding:10px 0;background:none;border:0;text-decoration:underline;min-height:44px}
.return-note,.wechat{background:#fce9ec;padding:14px;border-radius:12px;margin-bottom:16px}.return-note strong{font-size:16px}.return-note p{margin:6px 0 0;color:#722334}.wechat{color:#722334}
button:focus-visible,a:focus-visible,summary:focus-visible{outline:3px solid #8e1b2c;outline-offset:4px}
@media(max-width:390px){.entry-guide{padding:18px}}
</style>
