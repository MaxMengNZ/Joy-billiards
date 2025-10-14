<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-card card">
        <div class="login-header">
          <h1>🎱 Joy Billiards</h1>
          <p>Tournament Management System</p>
        </div>

        <div class="login-body">
          <h2>Sign In</h2>

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
import { ref } from 'vue'
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

    const handleSignIn = async () => {
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

.login-header h1 {
  font-size: 2rem;
  margin-bottom: 0.5rem;
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

@media (max-width: 480px) {
  .login-page {
    padding: 1rem;
  }

  .login-header h1 {
    font-size: 1.5rem;
  }

  .login-body {
    padding: 1.5rem;
  }
}
</style>


