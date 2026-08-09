<template>
  <main class="join-page">
    <div class="ambient ambient-red"></div>
    <div class="ambient ambient-gold"></div>

    <section class="join-shell">
      <header class="brand-row">
        <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards New Zealand">
        <div>
          <strong>JOY CLUB</strong>
          <span>PLAY · ENJOY · BELONG</span>
        </div>
      </header>

      <section v-if="inviter.name" class="invitation-strip">
        <div class="inviter-avatar">
          <img v-if="inviter.avatar" :src="inviter.avatar" :alt="inviter.name">
          <span v-else>{{ inviterInitials }}</span>
        </div>
        <div>
          <span>{{ text.invitedBy }}</span>
          <strong>{{ inviter.name }} {{ text.invitesYou }}</strong>
        </div>
        <i>↗</i>
      </section>

      <article class="register-card">
        <div class="card-heading">
          <p>JOY MEMBERSHIP</p>
          <h1>{{ text.title }}</h1>
          <span>{{ text.intro }}</span>
        </div>

        <div v-if="success" class="success-panel">
          <div class="success-mark">✓</div>
          <h2>{{ text.successTitle }}</h2>
          <p>{{ text.successText }}</p>
          <strong>{{ email }}</strong>
          <p v-if="message" class="success-notice">{{ message }}</p>
          <button type="button" :disabled="resending || cooldown > 0" @click="resend">
            {{ resendLabel }}
          </button>
          <router-link to="/login">{{ text.goLogin }}</router-link>
        </div>

        <form v-else @submit.prevent="submit">
          <div class="field-grid">
            <label class="field full">
              <span>{{ text.name }}</span>
              <div class="input-shell">
                <b>人</b>
                <input v-model.trim="name" type="text" autocomplete="name" :placeholder="text.nameHint" required>
              </div>
            </label>

            <label class="field">
              <span>{{ text.birthday }}</span>
              <div class="input-shell">
                <b>日</b>
                <input v-model="birthday" inputmode="numeric" maxlength="10" autocomplete="bday" placeholder="DD/MM/YYYY" required @input="formatBirthday">
              </div>
              <small>{{ text.birthdayNote }}</small>
            </label>

            <label class="field">
              <span>{{ text.phone }}</span>
              <div class="input-shell">
                <b>☎</b>
                <input v-model.trim="phone" type="tel" autocomplete="tel" placeholder="022 123 4567" required>
              </div>
            </label>

            <label class="field full">
              <span>{{ text.email }}</span>
              <div class="input-shell" :class="{ invalid: emailError, valid: emailAvailable }">
                <b>@</b>
                <input v-model.trim="email" type="email" inputmode="email" autocomplete="email" placeholder="you@example.com" required @input="resetEmailState" @blur="checkEmail">
                <i v-if="checkingEmail" class="mini-spinner"></i>
                <i v-else-if="emailAvailable" class="valid-mark">✓</i>
              </div>
              <small :class="{ error: emailError, available: emailAvailable }">{{ emailStatus }}</small>
            </label>

            <label class="field full">
              <span>{{ text.password }}</span>
              <div class="input-shell">
                <b>◆</b>
                <input v-model="password" :type="showPassword ? 'text' : 'password'" autocomplete="new-password" :placeholder="text.passwordHint" required>
                <button class="eye" type="button" :aria-label="text.showPassword" @click="showPassword = !showPassword">
                  {{ showPassword ? '◉' : '◎' }}
                </button>
              </div>
            </label>

            <label class="field full">
              <span>{{ text.confirm }}</span>
              <div class="input-shell">
                <b>✓</b>
                <input v-model="confirm" :type="showConfirm ? 'text' : 'password'" autocomplete="new-password" :placeholder="text.confirmHint" required>
                <button class="eye" type="button" :aria-label="text.showPassword" @click="showConfirm = !showConfirm">
                  {{ showConfirm ? '◉' : '◎' }}
                </button>
              </div>
            </label>
          </div>

          <label class="agreement">
            <input v-model="agreed" type="checkbox">
            <span class="check-box">{{ agreed ? '✓' : '' }}</span>
            <p>
              {{ text.agree }}
              <router-link to="/terms-of-service">{{ text.terms }}</router-link>
              {{ text.and }}
              <router-link to="/privacy-policy">{{ text.privacy }}</router-link>
            </p>
          </label>

          <div v-if="message" class="notice">{{ message }}</div>

          <button class="submit" type="submit" :disabled="busy || checkingEmail">
            <span v-if="busy" class="button-spinner"></span>
            <template v-else><span>{{ text.submit }}</span><b>→</b></template>
          </button>
          <router-link class="login-link" to="/login">{{ text.hasAccount }}</router-link>
        </form>
      </article>

      <section class="benefits">
        <div><b>01</b><span>{{ text.memberId }}</span></div>
        <div><b>02</b><span>{{ text.tournaments }}</span></div>
        <div><b>03</b><span>{{ text.rewards }}</span></div>
      </section>

      <section class="download-card">
        <div>
          <p>{{ text.getApp }}</p>
          <span>{{ text.deviceHint }}</span>
        </div>
        <div class="store-buttons">
          <a v-for="option in downloadOptions" :key="option.platform" :href="option.url" target="_blank" rel="noopener">
            <b>{{ option.platform === 'ios' ? '●' : '▶' }}</b>
            <span><small>{{ option.platform === 'ios' ? 'Download on the' : 'GET IT ON' }}</small>{{ option.label }}</span>
          </a>
        </div>
      </section>

      <footer>
        <strong>JOY BILLIARDS NEW ZEALAND</strong>
        <span>88 Tristram Street, Hamilton Central</span>
      </footer>
    </section>
  </main>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, reactive, ref } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '../config/supabase'
import { downloadOptionsForClient } from '../utils/appDownload'

const route = useRoute()
const isZh = /^zh\b/i.test(navigator.language || '')
const copy = {
  zh: { invitedBy: '来自 JOY 球员的邀请', invitesYou: '邀请你加入 Joy Club', title: '创建会员账户', intro: '免费加入 Lite 会员，获得专属会员编号，开启你的 JOY 球员档案。', name: '真实姓名 *', nameHint: '用于赛事名单与球员档案', birthday: '出生日期 *', birthdayNote: '注册后不可自行修改', phone: '手机号码 *', email: '邮箱 *', emailHint: '用于登录与安全验证', emailChecking: '正在确认邮箱…', emailAvailable: '邮箱可以使用', password: '密码 *', passwordHint: '至少 8 位，包含字母和数字', confirm: '确认密码 *', confirmHint: '请再次输入密码', showPassword: '显示或隐藏密码', agree: '我已阅读并同意', terms: '《用户协议》', and: '与', privacy: '《隐私政策》', submit: '免费注册 Joy Club', hasAccount: '已有账户？返回登录', successTitle: '账户创建成功', successText: '验证邮件已经发送，请点击邮件中的链接完成验证后登录 App。', resend: '没有收到？重新发送验证邮件', resending: '正在发送…', resendIn: '秒后可重新发送', goLogin: '已完成验证？前往登录', memberId: '专属会员编号', tournaments: '赛事与球员档案', rewards: '积分与会员权益', getApp: '下载 Joy Club App', deviceHint: '已根据当前设备显示正确版本', invalidEmail: '请输入真实有效的邮箱地址', duplicateEmail: '该邮箱已经注册，请直接登录或使用忘记密码。', emailCheckFailed: '暂时无法检查邮箱，请稍后再试。', invalidBirthday: '请按 DD/MM/YYYY 填写真实生日，注册人须年满 13 周岁。', invalidPassword: '密码至少 8 位，并且必须同时包含字母和数字。', mismatch: '两次输入的密码不一致。', acceptTerms: '请先同意用户协议和隐私政策。', required: '请完整填写所有必填信息。', registerFailed: '注册失败，请稍后重试。', resendSuccess: '验证邮件已重新发送，请检查收件箱和垃圾邮件。' },
  en: { invitedBy: 'INVITED BY A JOY PLAYER', invitesYou: 'invited you to join Joy Club', title: 'Create your account', intro: 'Join as a free Lite member, receive your member number and start your official JOY player profile.', name: 'Legal name *', nameHint: 'Used for tournaments and your player profile', birthday: 'Date of birth *', birthdayNote: 'Cannot be changed after registration', phone: 'Phone number *', email: 'Email *', emailHint: 'Used for sign-in and security verification', emailChecking: 'Checking email…', emailAvailable: 'Email is available', password: 'Password *', passwordHint: '8+ characters with letters and numbers', confirm: 'Confirm password *', confirmHint: 'Enter your password again', showPassword: 'Show or hide password', agree: 'I have read and agree to the', terms: 'Terms of Service', and: 'and', privacy: 'Privacy Policy', submit: 'Create free Joy Club account', hasAccount: 'Already have an account? Sign in', successTitle: 'Account created', successText: 'We sent a verification email. Open the link in that email before signing in to the App.', resend: "Didn't receive it? Resend verification email", resending: 'Sending…', resendIn: 's before resend', goLogin: 'Verified your email? Sign in', memberId: 'Personal member number', tournaments: 'Events and player profile', rewards: 'Points and member benefits', getApp: 'Download Joy Club App', deviceHint: 'Showing the correct version for this device', invalidEmail: 'Enter a valid email address.', duplicateEmail: 'This email is already registered. Sign in or use Forgot Password.', emailCheckFailed: 'We could not check this email. Try again shortly.', invalidBirthday: 'Enter a real date as DD/MM/YYYY. You must be at least 13.', invalidPassword: 'Use at least 8 characters containing both letters and numbers.', mismatch: 'Passwords do not match.', acceptTerms: 'Accept the Terms and Privacy Policy to continue.', required: 'Complete all required fields.', registerFailed: 'Registration failed. Please try again.', resendSuccess: 'Verification email sent. Check your inbox and spam folder.' },
}
const text = computed(() => isZh ? copy.zh : copy.en)
const downloadOptions = downloadOptionsForClient()
const inviter = reactive({ name: '', avatar: '' })
const name = ref('')
const birthday = ref('')
const phone = ref('')
const email = ref('')
const password = ref('')
const confirm = ref('')
const agreed = ref(false)
const showPassword = ref(false)
const showConfirm = ref(false)
const busy = ref(false)
const checkingEmail = ref(false)
const emailAvailable = ref(false)
const emailError = ref('')
const message = ref('')
const success = ref(false)
const resending = ref(false)
const cooldown = ref(0)
let cooldownTimer

const inviterInitials = computed(() => inviter.name.trim().slice(0, 2).toUpperCase() || 'JOY')
const emailStatus = computed(() => emailError.value || (checkingEmail.value ? text.value.emailChecking : emailAvailable.value ? text.value.emailAvailable : text.value.emailHint))
const resendLabel = computed(() => resending.value ? text.value.resending : cooldown.value > 0 ? `${cooldown.value}${text.value.resendIn}` : text.value.resend)
const normalizedEmail = () => email.value.trim().toLowerCase().replace(/[\s\u200B-\u200D\uFEFF]/g, '')
const validEmail = (value) => /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(value)

const resetEmailState = () => {
  emailAvailable.value = false
  emailError.value = ''
}

const checkEmail = async () => {
  const value = normalizedEmail()
  email.value = value
  resetEmailState()
  if (!validEmail(value)) {
    emailError.value = text.value.invalidEmail
    return false
  }
  checkingEmail.value = true
  try {
    const { data, error } = await supabase.rpc('check_email_exists', { email: value })
    if (error) throw error
    if (data) {
      emailError.value = text.value.duplicateEmail
      return false
    }
    emailAvailable.value = true
    return true
  } catch {
    emailError.value = text.value.emailCheckFailed
    return false
  } finally {
    checkingEmail.value = false
  }
}

const formatBirthday = (event) => {
  const digits = event.target.value.replace(/\D/g, '').slice(0, 8)
  birthday.value = [digits.slice(0, 2), digits.slice(2, 4), digits.slice(4, 8)].filter(Boolean).join('/')
}

const birthdayIso = () => {
  const match = birthday.value.match(/^(\d{2})\/(\d{2})\/(\d{4})$/)
  if (!match) return null
  const day = Number(match[1]); const month = Number(match[2]); const year = Number(match[3])
  const date = new Date(year, month - 1, day)
  if (date.getFullYear() !== year || date.getMonth() !== month - 1 || date.getDate() !== day) return null
  const limit = new Date(); limit.setHours(0, 0, 0, 0); limit.setFullYear(limit.getFullYear() - 13)
  if (date > limit) return null
  return `${match[3]}-${match[2]}-${match[1]}`
}

const submit = async () => {
  if (busy.value) return
  message.value = ''
  if (!name.value || !phone.value || !birthday.value || !email.value || !password.value || !confirm.value) return (message.value = text.value.required)
  const isoBirthday = birthdayIso()
  if (!isoBirthday) return (message.value = text.value.invalidBirthday)
  if (!emailAvailable.value && !(await checkEmail())) return
  if (password.value.length < 8 || !/[A-Za-z]/.test(password.value) || !/\d/.test(password.value)) return (message.value = text.value.invalidPassword)
  if (password.value !== confirm.value) return (message.value = text.value.mismatch)
  if (!agreed.value) return (message.value = text.value.acceptTerms)
  busy.value = true
  try {
    const { data, error } = await supabase.auth.signUp({
      email: normalizedEmail(),
      password: password.value,
      options: {
        emailRedirectTo: 'https://club.joybilliards.co.nz/verify-email',
        data: {
          full_name: name.value,
          phone: phone.value,
          birthday: isoBirthday,
          role: 'player',
          terms_accepted_at: new Date().toISOString(),
          terms_version: '2026-08-01-v1',
          privacy_version: '2026-08-01-v1',
          referred_by: route.query.ref ? String(route.query.ref) : null,
        },
      },
    })
    if (error) throw error
    if (data.user?.identities?.length === 0) throw new Error(text.value.duplicateEmail)
    password.value = ''
    confirm.value = ''
    success.value = true
  } catch (error) {
    message.value = /already|exists|registered/i.test(error?.message || '') ? text.value.duplicateEmail : (error?.message || text.value.registerFailed)
  } finally {
    busy.value = false
  }
}

const startCooldown = () => {
  cooldown.value = 60
  clearInterval(cooldownTimer)
  cooldownTimer = setInterval(() => {
    cooldown.value -= 1
    if (cooldown.value <= 0) clearInterval(cooldownTimer)
  }, 1000)
}

const resend = async () => {
  if (resending.value || cooldown.value > 0) return
  resending.value = true
  const { error } = await supabase.auth.resend({ type: 'signup', email: normalizedEmail(), options: { emailRedirectTo: 'https://club.joybilliards.co.nz/verify-email' } })
  resending.value = false
  message.value = error?.message || text.value.resendSuccess
  if (!error) startCooldown()
}

onMounted(async () => {
  const referrer = route.query.ref ? String(route.query.ref) : ''
  if (!referrer) return
  const [{ data: player }, { data: avatars }] = await Promise.all([
    supabase.from('public_users').select('id,name').eq('id', referrer).maybeSingle(),
    supabase.rpc('get_public_member_avatars', { p_user_ids: [referrer] }),
  ])
  if (player?.name) inviter.name = player.name
  if (Array.isArray(avatars) && avatars[0]?.avatar_url) inviter.avatar = avatars[0].avatar_url
})

onBeforeUnmount(() => clearInterval(cooldownTimer))
</script>

<style scoped>
.join-page{min-height:100svh;position:relative;overflow:hidden;padding:26px 16px 44px;background:radial-gradient(circle at 50% -8%,#fff 0,#f8f5f1 35%,#f0f2f5 100%);color:#17191d;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}.join-shell{position:relative;z-index:2;width:min(100%,540px);margin:0 auto}.ambient{position:absolute;border-radius:50%;pointer-events:none}.ambient-red{width:330px;height:330px;left:-220px;top:19%;background:rgba(229,43,54,.055)}.ambient-gold{width:360px;height:360px;right:-250px;bottom:8%;border:48px solid rgba(202,155,74,.06)}.brand-row{display:flex;align-items:center;justify-content:center;gap:15px;margin-bottom:21px}.brand-row img{width:103px;height:53px;object-fit:contain}.brand-row>div{display:flex;flex-direction:column;padding-left:15px;border-left:1px solid #d5d8dc}.brand-row strong{font-size:17px;letter-spacing:.14em}.brand-row span{margin-top:4px;color:#999da4;font-size:7px;font-weight:900;letter-spacing:.18em}.invitation-strip{display:flex;align-items:center;gap:11px;margin-bottom:10px;padding:12px 14px;border:1px solid rgba(216,173,95,.25);border-radius:18px;background:linear-gradient(120deg,#25191a,#111318);box-shadow:0 12px 26px rgba(24,18,20,.14);color:#fff}.inviter-avatar{width:39px;height:39px;overflow:hidden;border:1.5px solid #d8ad5f;border-radius:50%;display:grid;place-items:center;background:#762630;font-size:11px;font-weight:900}.inviter-avatar img{width:100%;height:100%;object-fit:cover}.invitation-strip>div:nth-child(2){min-width:0;flex:1;display:flex;flex-direction:column}.invitation-strip span{color:#a79576;font-size:6px;font-weight:900;letter-spacing:.14em}.invitation-strip strong{margin-top:2px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:11px}.invitation-strip i{color:#d8ad5f;font-style:normal}.register-card{padding:29px 22px 24px;border:1px solid rgba(255,255,255,.95);border-radius:30px;background:rgba(255,255,255,.94);box-shadow:0 22px 55px rgba(31,36,44,.1);backdrop-filter:blur(18px)}.card-heading{text-align:center}.card-heading p{margin:0;color:#e52b36;font-size:7px;font-weight:1000;letter-spacing:.22em}.card-heading h1{margin:6px 0 7px;font-size:25px;letter-spacing:-.025em}.card-heading span{display:block;max-width:390px;margin:auto;color:#858a92;font-size:10px;line-height:1.65}.field-grid{display:grid;grid-template-columns:1fr 1fr;gap:0 9px;margin-top:24px}.field{display:block;margin-bottom:13px}.field.full{grid-column:1/-1}.field>span{display:block;margin:0 0 6px 3px;color:#52575e;font-size:8px;font-weight:900;letter-spacing:.04em}.input-shell{height:52px;display:flex;align-items:center;gap:10px;padding:0 13px;border:1px solid #e0e3e7;border-radius:15px;background:#fff;transition:border-color .2s,box-shadow .2s}.input-shell:focus-within{border-color:#d38b90;box-shadow:0 0 0 3px rgba(229,43,54,.07)}.input-shell.invalid{border-color:#d95a63}.input-shell.valid{border-color:#56a47b}.input-shell>b{width:18px;color:#d84650;font-size:10px;text-align:center}.input-shell input{min-width:0;flex:1;border:0;outline:0;background:transparent;color:#17191d;font:inherit;font-size:11px}.input-shell input::placeholder{color:#a7abb1}.field small{display:block;min-height:13px;margin:4px 4px 0;color:#9a9ea5;font-size:7px}.field small.error{color:#c63842}.field small.available{color:#36825d}.eye{padding:4px;border:0;background:transparent;color:#8f939a;font-size:15px;cursor:pointer}.valid-mark{color:#3e9368;font-style:normal;font-weight:900}.mini-spinner,.button-spinner{border:2px solid #e7e8ea;border-top-color:#e52b36;border-radius:50%;animation:spin .7s linear infinite}.mini-spinner{width:15px;height:15px}.agreement{display:flex;align-items:flex-start;gap:9px;margin:2px 2px 0;cursor:pointer}.agreement>input{position:absolute;opacity:0;pointer-events:none}.check-box{width:20px;height:20px;flex:0 0 auto;border:1px solid #bfc3c8;border-radius:7px;display:grid;place-items:center;background:#fff;color:#fff;font-size:11px;font-weight:900}.agreement>input:checked+.check-box{border-color:#e52b36;background:#e52b36}.agreement p{margin:2px 0 0;color:#7f848c;font-size:8px;line-height:1.5}.agreement a{color:#d93640;font-weight:850;text-decoration:none}.notice{margin-top:14px;padding:11px 12px;border-radius:12px;background:#fff0f1;color:#a43b43;font-size:9px;line-height:1.5;text-align:center}.submit{width:100%;height:56px;margin-top:18px;padding:0 19px;border:0;border-radius:16px;display:flex;align-items:center;justify-content:space-between;background:linear-gradient(110deg,#ef1f2c,#d91d29);box-shadow:0 12px 25px rgba(229,43,54,.22);color:#fff;font-size:12px;font-weight:900;letter-spacing:.04em;cursor:pointer}.submit:disabled{opacity:.6}.button-spinner{width:19px;height:19px;margin:auto;border-color:rgba(255,255,255,.35);border-top-color:#fff}.login-link{display:block;margin-top:17px;color:#d33b45;font-size:9px;font-weight:900;text-align:center;text-decoration:none}.success-panel{padding:29px 7px 9px;text-align:center}.success-mark{width:60px;height:60px;margin:auto;border-radius:50%;display:grid;place-items:center;background:#e8f6ef;color:#2e835b;font-size:25px;font-weight:1000}.success-panel h2{margin:14px 0 6px;font-size:22px}.success-panel p{max-width:350px;margin:0 auto;color:#7c8189;font-size:10px;line-height:1.65}.success-panel strong{display:block;margin:11px 0;color:#272a2f;font-size:11px}.success-panel button{width:100%;height:49px;margin-top:10px;border:0;border-radius:14px;background:#e52b36;color:#fff;font-size:10px;font-weight:900}.success-panel button:disabled{opacity:.55}.success-panel a{display:block;margin-top:15px;color:#d43d47;font-size:9px;font-weight:900;text-decoration:none}.benefits{display:grid;grid-template-columns:repeat(3,1fr);gap:7px;margin-top:12px}.benefits div{min-width:0;padding:13px 7px;border:1px solid #eceef1;border-radius:16px;background:rgba(255,255,255,.8);text-align:center}.benefits b{display:block;color:#e52b36;font-size:9px}.benefits span{display:block;margin-top:4px;color:#70757d;font-size:7px}.download-card{margin-top:12px;padding:17px;border-radius:20px;background:#17191d;color:#fff}.download-card>div:first-child{text-align:center}.download-card p{margin:0;font-size:12px;font-weight:900}.download-card>div:first-child span{color:#858991;font-size:7px}.store-buttons{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:8px;margin-top:12px}.store-buttons a{min-height:48px;border:1px solid rgba(255,255,255,.2);border-radius:13px;display:flex;align-items:center;justify-content:center;gap:9px;color:#fff;text-decoration:none}.store-buttons a>b{font-size:15px}.store-buttons a>span{font-size:11px;font-weight:850;line-height:1}.store-buttons small{display:block;margin-bottom:3px;color:#9a9da4;font-size:6px;font-weight:500}footer{display:flex;flex-direction:column;gap:3px;margin-top:22px;color:#8a8e95;font-size:8px;text-align:center}footer strong{color:#625b50;font-size:7px;letter-spacing:.13em}@keyframes spin{to{transform:rotate(360deg)}}@media(max-width:430px){.join-page{padding-left:10px;padding-right:10px}.register-card{padding-left:16px;padding-right:16px}.field-grid{grid-template-columns:1fr}.field.full{grid-column:auto}.brand-row img{width:90px}.store-buttons{grid-template-columns:1fr}}
.success-panel .success-notice{margin:8px auto;color:#2e835b}
</style>
