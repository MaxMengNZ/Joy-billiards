<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-card card">
        <div class="login-header">
          <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards" class="login-logo">
          <p>Tournament Management System</p>
        </div>

        <div class="login-body">
          <h2>Sign In</h2>

          <div v-if="passwordChangedMessage" class="alert alert-success">
            ✅ Password updated successfully! Please log in with your new password.
          </div>

          <div v-if="authStore.error" class="alert alert-danger">
            {{ authStore.error }}
          </div>

          <form @submit.prevent="handleSignIn">
            <div class="form-group">
              <label class="form-label">Email</label>
              <input
                type="email"
                class="form-control"
                v-model="email"
                placeholder="your.email@example.com"
                required
                :disabled="authStore.loading"
              >
            </div>

            <div class="form-group">
              <label class="form-label">Password</label>
              <input
                type="password"
                class="form-control"
                v-model="password"
                placeholder="Enter your password"
                required
                :disabled="authStore.loading"
              >
            </div>

            <div class="form-actions">
              <button
                type="submit"
                class="btn btn-primary btn-lg"
                :disabled="authStore.loading"
              >
                {{ authStore.loading ? 'Signing In...' : 'Sign In' }}
              </button>
            </div>
          </form>

          <div class="login-footer">
            <p>
              Don't have an account?
              <router-link to="/register" class="link">Sign Up</router-link>
            </p>
            <p>
              <a href="#" @click.prevent="showForgotPassword" class="link">
                Forgot Password?
              </a>
            </p>
          </div>
        </div>
      </div>

      <div class="venue-info">
        <p>📍 88 Tristram Street, Hamilton Central</p>
        <p>📞 022 166 0688</p>
      </div>
    </div>

    <!-- Forgot Password Modal -->
    <div v-if="showResetModal" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Reset Password</h2>
          <button class="btn btn-secondary btn-sm" @click="showResetModal = false">
            Close
          </button>
        </div>
        <div class="modal-body">
          <p>Enter your email address and we'll send you a password reset link.</p>
          <div class="form-group">
            <label class="form-label">Email</label>
            <input
              type="email"
              class="form-control"
              v-model="resetEmail"
              placeholder="your.email@example.com"
            >
          </div>
          <div v-if="resetSuccess" class="alert alert-success mt-2">
            Password reset email sent! Please check your inbox.
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showResetModal = false">
            Cancel
          </button>
          <button class="btn btn-primary" @click="handleResetPassword">
            Send Reset Link
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/authStore'

export default {
  name: 'LoginPage',
  setup() {
    const router = useRouter()
    const authStore = useAuthStore()

    const email = ref('')
    const password = ref('')
    const showResetModal = ref(false)
    const resetEmail = ref('')
    const resetSuccess = ref(false)
    const passwordChangedMessage = ref(false)

    onMounted(() => {
      // Check if password was just changed
      if (sessionStorage.getItem('passwordChanged') === 'true') {
        passwordChangedMessage.value = true
        sessionStorage.removeItem('passwordChanged')
        
        // Check if it was a timeout
        const wasTimeout = sessionStorage.getItem('passwordTimeout') === 'true'
        if (wasTimeout) {
          sessionStorage.removeItem('passwordTimeout')
        }
        
        // Auto-hide message after 8 seconds for timeout cases
        setTimeout(() => {
          passwordChangedMessage.value = false
        }, 8000)
      }
    })

    const handleSignIn = async () => {
      try {
        const result = await authStore.signIn({
          email: email.value,
          password: password.value
        })

        if (result.success) {
          // Redirect based on role
          if (authStore.isAdmin) {
            router.push('/admin')
          } else {
            router.push('/')
          }
        } else {
          // Handle timeout or other errors
          if (result.error && result.error.includes('timeout')) {
            const retry = confirm('⚠️ Login request timed out. This might be due to slow network or Supabase service.\n\nDo you want to try refreshing the page and login again?')
            if (retry) {
              window.location.reload()
            }
          }
        }
      } catch (error) {
        console.error('Login exception:', error)
        if (error.message && error.message.includes('timeout')) {
          const retry = confirm('⚠️ Login request timed out. This might be due to slow network or Supabase service.\n\nDo you want to try refreshing the page and login again?')
          if (retry) {
            window.location.reload()
          }
        }
      }
    }

    const showForgotPassword = () => {
      resetEmail.value = email.value
      resetSuccess.value = false
      showResetModal.value = true
    }

    const handleResetPassword = async () => {
      if (!resetEmail.value) {
        alert('Please enter your email address')
        return
      }

      const result = await authStore.resetPassword(resetEmail.value)
      if (result.success) {
        resetSuccess.value = true
        setTimeout(() => {
          showResetModal.value = false
        }, 3000)
      }
    }

    return {
      authStore,
      email,
      password,
      showResetModal,
      resetEmail,
      resetSuccess,
      passwordChangedMessage,
      handleSignIn,
      showForgotPassword,
      handleResetPassword
    }
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1a1a2e 0%, #0f3460 100%);
  padding: 2rem;
}

.login-container {
  width: 100%;
  max-width: 450px;
}

.login-card {
  background: white;
  padding: 0;
  overflow: hidden;
}

.login-header {
  background: linear-gradient(135deg, #1a1a2e, #0f3460);
  color: white;
  padding: 2rem;
  text-align: center;
}

.login-logo {
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

.login-header p {
  opacity: 0.9;
  margin: 0;
}

.login-body {
  padding: 2rem;
}

.login-body h2 {
  font-size: 1.5rem;
  margin-bottom: 1.5rem;
  color: var(--dark-color);
}

.form-actions {
  margin-top: 1.5rem;
}

.form-actions .btn {
  width: 100%;
}

.login-footer {
  margin-top: 1.5rem;
  text-align: center;
  padding-top: 1.5rem;
  border-top: 1px solid var(--border-color);
}

.login-footer p {
  margin: 0.5rem 0;
  color: var(--text-secondary);
}

.link {
  color: var(--primary-color);
  text-decoration: none;
  font-weight: 500;
}

.link:hover {
  text-decoration: underline;
}

.venue-info {
  text-align: center;
  margin-top: 1.5rem;
  color: white;
  opacity: 0.8;
}

.venue-info p {
  margin: 0.5rem 0;
}

/* Mobile Optimization */
@media (max-width: 768px) {
  .login-page {
    padding: 1rem;
    align-items: flex-start;
    padding-top: 2rem;
  }

  /* 模态框容器优化 */
  .modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    overflow-y: auto;
    padding: 20px;
  }

  .login-header {
    padding: 1.5rem;
  }

  .login-logo {
    height: 100px;
    max-width: 240px;
    padding: 10px 20px;
  }

  .login-header p {
    font-size: 0.875rem;
  }

  .login-body {
    padding: 1.5rem;
  }

  .login-body h2 {
    font-size: 1.25rem;
    margin-bottom: 1.25rem;
  }

  /* 大输入框 */
  .form-control {
    min-height: 48px;
    font-size: 16px;
    padding: 12px 16px;
  }

  .form-label {
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 8px;
  }

  /* 大登录按钮 */
  .btn-lg {
    min-height: 52px;
    font-size: 17px;
    font-weight: 700;
  }

  /* 优化链接大小 */
  .login-footer {
    margin-top: 1.25rem;
    padding-top: 1.25rem;
  }

  .login-footer p {
    font-size: 14px;
    margin: 0.75rem 0;
  }

  .link {
    font-size: 15px;
    font-weight: 600;
  }

  /* 场馆信息 */
  .venue-info {
    margin-top: 1.25rem;
    font-size: 14px;
  }

  .venue-info p {
    margin: 0.5rem 0;
  }

  /* 模态框优化 */
  .modal-content {
    width: 90vw;
    max-width: 90vw;
    max-height: 85vh;
    margin: 0 auto;
    padding: 1.25rem;
    overflow-y: auto;
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
    -webkit-overflow-scrolling: touch;
  }

  .modal-header {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }

  .modal-header h2 {
    font-size: 1.5rem;
    margin: 0;
  }

  .modal-header .btn {
    width: 100%;
    min-height: 44px;
  }

  .modal-body {
    padding: 1rem 0;
  }

  .modal-body p {
    font-size: 14px;
    line-height: 1.5;
    margin-bottom: 1rem;
  }

  .modal-body .form-control {
    min-height: 48px;
    font-size: 16px;
    padding: 12px 16px;
  }

  .modal-body .form-label {
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 8px;
  }

  .modal-footer {
    flex-direction: column;
    gap: 8px;
    padding-top: 1rem;
    border-top: 1px solid #dee2e6;
    margin-top: 0.5rem;
  }

  .modal-footer .btn {
    width: 100%;
    min-height: 48px;
    font-size: 16px;
    font-weight: 600;
  }

  /* 成功提示优化 */
  .alert {
    padding: 12px 16px;
    font-size: 14px;
    border-radius: 8px;
  }
}
</style>


