<template>
  <div class="email-confirm-page">
    <div class="confirm-container">
      <div class="confirm-card card">
        <div class="confirm-header">
          <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards" class="confirm-logo">
          <p>Email Confirmation</p>
        </div>

        <div class="confirm-body">
          <div v-if="loading" class="loading-state">
            <div class="spinner"></div>
            <p>Confirming your email...</p>
          </div>

          <div v-else-if="success" class="success-state">
            <div class="success-icon">✅</div>
            <h2>Email Confirmed Successfully!</h2>
            <p>Your account has been verified. You can now sign in.</p>
            <router-link to="/login" class="btn btn-primary btn-lg">
              Go to Sign In
            </router-link>
          </div>

          <div v-else-if="error" class="error-state">
            <div class="error-icon">❌</div>
            <h2>Confirmation Failed</h2>
            <p>{{ error }}</p>
            <div class="error-actions">
              <router-link to="/login" class="btn btn-secondary">
                Back to Sign In
              </router-link>
              <router-link to="/register" class="btn btn-primary">
                Try Again
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../config/supabase'

export default {
  name: 'EmailConfirmPage',
  setup() {
    const router = useRouter()
    const loading = ref(true)
    const success = ref(false)
    const error = ref(null)

    const handleEmailConfirmation = async () => {
      try {
        // Get URL parameters
        const urlParams = new URLSearchParams(window.location.hash.substring(1))
        const accessToken = urlParams.get('access_token')
        const refreshToken = urlParams.get('refresh_token')
        const type = urlParams.get('type')

        if (!accessToken || !refreshToken || type !== 'signup') {
          throw new Error('Invalid confirmation link')
        }

        // Set session with tokens
        const { error: sessionError } = await supabase.auth.setSession({
          access_token: accessToken,
          refresh_token: refreshToken
        })

        if (sessionError) {
          throw sessionError
        }

        // Clear URL hash
        window.history.replaceState({}, document.title, window.location.pathname)
        
        success.value = true
        loading.value = false

        // Auto redirect to login after 3 seconds
        setTimeout(() => {
          router.push('/login')
        }, 3000)

      } catch (err) {
        console.error('Email confirmation error:', err)
        error.value = err.message || 'Failed to confirm email'
        loading.value = false
      }
    }

    onMounted(() => {
      handleEmailConfirmation()
    })

    return {
      loading,
      success,
      error
    }
  }
}
</script>

<style scoped>
.email-confirm-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1a1a2e 0%, #0f3460 100%);
  padding: 2rem;
}

.confirm-container {
  width: 100%;
  max-width: 500px;
}

.confirm-card {
  background: white;
  padding: 0;
  overflow: hidden;
}

.confirm-header {
  background: linear-gradient(135deg, #1a1a2e, #0f3460);
  color: white;
  padding: 2rem;
  text-align: center;
}

.confirm-logo {
  height: 120px;
  width: auto;
  max-width: 280px;
  object-fit: contain;
  margin-bottom: 1rem;
  /* 白色背景，让黑色 Logo 清晰可见 */
  background: white;
  padding: 12px 24px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.confirm-header p {
  opacity: 0.9;
  margin: 0;
}

.confirm-body {
  padding: 3rem 2rem;
  text-align: center;
}

.loading-state, .success-state, .error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #0f3460;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.success-icon, .error-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.success-state h2 {
  color: #28a745;
  margin-bottom: 1rem;
}

.error-state h2 {
  color: #dc3545;
  margin-bottom: 1rem;
}

.error-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-top: 1.5rem;
}

.btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 0.5rem;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.3s ease;
}

.btn-primary {
  background: linear-gradient(135deg, #1a1a2e, #0f3460);
  color: white;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(15, 52, 96, 0.3);
}

.btn-secondary {
  background: #6c757d;
  color: white;
}

.btn-secondary:hover {
  background: #5a6268;
}

.btn-lg {
  padding: 1rem 2rem;
  font-size: 1.1rem;
}
</style>
