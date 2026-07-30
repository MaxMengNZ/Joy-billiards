<template>
  <div class="reset-password-page">
    <div class="reset-container">
      <div class="reset-card card">
        <div class="reset-header">
          <div class="reset-lang">
            <LanguageSwitcher />
          </div>
          <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards" class="reset-logo" />
          <p>{{ t('auth.system') }}</p>
        </div>

        <div class="reset-body">
          <div v-if="loadingLink" class="state-block">
            <div class="spinner" aria-hidden="true"></div>
            <p>{{ t('auth.resetVerifying') }}</p>
          </div>

          <div v-else-if="done" class="state-block success">
            <div class="state-icon">✅</div>
            <h2>{{ t('auth.resetDoneTitle') }}</h2>
            <p>{{ t('auth.passwordUpdated') }}</p>
            <router-link to="/login?passwordChanged=1" class="btn btn-primary btn-lg">
              {{ t('auth.goLogin') }}
            </router-link>
          </div>

          <div v-else-if="linkError" class="state-block error">
            <div class="state-icon">❌</div>
            <h2>{{ t('auth.resetLinkInvalid') }}</h2>
            <p>{{ linkError }}</p>
            <router-link to="/login" class="btn btn-primary">
              {{ t('auth.backToLogin') }}
            </router-link>
          </div>

          <template v-else>
            <h2>{{ t('auth.resetChooseTitle') }}</h2>
            <p class="hint">{{ t('auth.resetChooseDesc') }}</p>

            <p v-if="formError" class="alert alert-danger" role="alert">{{ formError }}</p>

            <form @submit.prevent="submitNewPassword">
              <div class="form-group">
                <label class="form-label" for="new-password">{{ t('auth.newPassword') }}</label>
                <input
                  id="new-password"
                  v-model="password"
                  type="password"
                  class="form-control"
                  :placeholder="t('auth.minPassword')"
                  autocomplete="new-password"
                  required
                  minlength="6"
                  :disabled="saving"
                />
              </div>

              <div class="form-group">
                <label class="form-label" for="confirm-password">{{ t('auth.confirmPassword') }}</label>
                <input
                  id="confirm-password"
                  v-model="confirmPassword"
                  type="password"
                  class="form-control"
                  :placeholder="t('auth.confirmPasswordPlaceholder')"
                  autocomplete="new-password"
                  required
                  minlength="6"
                  :disabled="saving"
                />
              </div>

              <button type="submit" class="btn btn-primary btn-lg" :disabled="saving">
                {{ saving ? t('auth.updatingPassword') : t('auth.saveNewPassword') }}
              </button>
            </form>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { onMounted, onUnmounted, ref } from 'vue'
import { supabase } from '../config/supabase'
import { useAuthStore } from '../stores/authStore'
import { useI18n } from '../i18n'
import LanguageSwitcher from '../components/LanguageSwitcher.vue'

export default {
  name: 'ResetPasswordPage',
  components: { LanguageSwitcher },
  setup() {
    const { t } = useI18n()
    const authStore = useAuthStore()
    const loadingLink = ref(true)
    const linkError = ref('')
    const password = ref('')
    const confirmPassword = ref('')
    const formError = ref('')
    const saving = ref(false)
    const done = ref(false)
    let authSub = null

    const markReady = () => {
      loadingLink.value = false
      linkError.value = ''
    }

    const markInvalid = (message) => {
      loadingLink.value = false
      linkError.value = message || t('auth.resetLinkExpired')
    }

    const trySetSessionFromUrl = async () => {
      // Implicit flow: tokens in hash
      const hash = window.location.hash?.startsWith('#')
        ? window.location.hash.substring(1)
        : ''
      if (hash) {
        const params = new URLSearchParams(hash)
        const accessToken = params.get('access_token')
        const refreshToken = params.get('refresh_token')
        const type = params.get('type')
        if (accessToken && refreshToken && (type === 'recovery' || !type)) {
          const { error } = await supabase.auth.setSession({
            access_token: accessToken,
            refresh_token: refreshToken
          })
          if (error) throw error
          // Clean sensitive tokens from the URL bar
          window.history.replaceState({}, document.title, '/reset-password')
          return true
        }
      }

      // PKCE / query code exchange (if configured)
      const search = new URLSearchParams(window.location.search)
      const code = search.get('code')
      if (code) {
        const { error } = await supabase.auth.exchangeCodeForSession(code)
        if (error) throw error
        window.history.replaceState({}, document.title, '/reset-password')
        return true
      }

      const { data } = await supabase.auth.getSession()
      return !!data?.session
    }

    onMounted(async () => {
      const { data } = supabase.auth.onAuthStateChange((event) => {
        if (event === 'PASSWORD_RECOVERY') {
          markReady()
        }
      })
      authSub = data?.subscription || null

      try {
        const ok = await trySetSessionFromUrl()
        if (ok) {
          markReady()
        } else {
          markInvalid(t('auth.resetLinkExpired'))
        }
      } catch (err) {
        markInvalid(err?.message || t('auth.resetLinkExpired'))
      }
    })

    onUnmounted(() => {
      authSub?.unsubscribe?.()
    })

    const submitNewPassword = async () => {
      formError.value = ''
      if (!password.value || password.value.length < 6) {
        formError.value = t('auth.passwordHint')
        return
      }
      if (password.value !== confirmPassword.value) {
        formError.value = t('auth.passwordsMismatch')
        return
      }

      saving.value = true
      try {
        const result = await authStore.updatePassword(password.value)
        if (!result.success) {
          throw new Error(result.error || t('auth.resetUpdateFailed'))
        }
        done.value = true
        // End recovery session so next login is clean
        try {
          await supabase.auth.signOut()
        } catch {
          /* ignore */
        }
      } catch (err) {
        formError.value = err?.message || t('auth.resetUpdateFailed')
      } finally {
        saving.value = false
      }
    }

    return {
      t,
      loadingLink,
      linkError,
      password,
      confirmPassword,
      formError,
      saving,
      done,
      submitNewPassword
    }
  }
}
</script>

<style scoped>
.reset-password-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
  background: linear-gradient(160deg, #0f172a 0%, #1e293b 50%, #0f3460 100%);
}

.reset-container {
  width: 100%;
  max-width: 440px;
}

.reset-card {
  overflow: hidden;
  border-radius: 16px;
  background: #fff;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.35);
}

.reset-header {
  position: relative;
  background: linear-gradient(135deg, #1a1a2e, #0f3460);
  color: white;
  padding: 2rem;
  text-align: center;
}

.reset-lang {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
}

.reset-logo {
  height: 96px;
  max-width: 220px;
  object-fit: contain;
}

.reset-header p {
  margin: 0.75rem 0 0;
  opacity: 0.9;
}

.reset-body {
  padding: 1.75rem 1.5rem 2rem;
}

.reset-body h2 {
  margin: 0 0 0.5rem;
  font-size: 1.35rem;
  color: #0f172a;
}

.hint {
  margin: 0 0 1.25rem;
  color: #64748b;
  font-size: 0.95rem;
}

.form-group {
  margin-bottom: 1rem;
}

.form-label {
  display: block;
  margin-bottom: 0.35rem;
  font-weight: 600;
  color: #334155;
  font-size: 0.9rem;
}

.form-control {
  width: 100%;
  box-sizing: border-box;
  padding: 0.7rem 0.85rem;
  border: 1px solid #cbd5e1;
  border-radius: 10px;
  font-size: 1rem;
}

.form-control:focus {
  outline: 2px solid rgba(15, 52, 96, 0.35);
  border-color: #0f3460;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  margin-top: 0.5rem;
  padding: 0.8rem 1rem;
  border: none;
  border-radius: 10px;
  font-weight: 700;
  text-decoration: none;
  cursor: pointer;
}

.btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.btn-primary {
  background: linear-gradient(135deg, #0f3460, #1a1a2e);
  color: #fff;
}

.btn-lg {
  font-size: 1.05rem;
}

.alert-danger {
  background: #fef2f2;
  color: #b91c1c;
  border: 1px solid #fecaca;
  border-radius: 10px;
  padding: 0.75rem 0.9rem;
  margin-bottom: 1rem;
  font-size: 0.92rem;
}

.state-block {
  text-align: center;
  padding: 0.5rem 0 0.25rem;
}

.state-block p {
  color: #64748b;
  line-height: 1.5;
}

.state-icon {
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
}

.spinner {
  width: 36px;
  height: 36px;
  margin: 0 auto 1rem;
  border: 3px solid #e2e8f0;
  border-top-color: #0f3460;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
