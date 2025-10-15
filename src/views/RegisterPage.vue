<template>
  <div class="register-page">
    <div class="register-container">
      <div class="register-card card">
        <div class="register-header">
          <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards" class="register-logo">
          <p>Create Your Account</p>
        </div>

        <div class="register-body">
          <h2>Sign Up</h2>

          <div v-if="authStore.error" class="alert alert-danger">
            {{ authStore.error }}
          </div>

          <div v-if="registrationSuccess" class="alert alert-success">
            Registration successful! Please check your email to verify your account.
          </div>

          <div v-if="registrationError" class="alert alert-danger">
            {{ registrationError }}
          </div>

          <form @submit.prevent="handleSignUp" v-if="!registrationSuccess">
            <div class="form-group">
              <label class="form-label">Full Name *</label>
              <input
                type="text"
                class="form-control"
                v-model="fullName"
                placeholder="Enter your full name"
                required
                :disabled="authStore.loading"
              >
            </div>

            <div class="form-group">
              <label class="form-label">Email *</label>
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
              <label class="form-label">Password *</label>
              <input
                type="password"
                class="form-control"
                v-model="password"
                placeholder="Min 6 characters"
                required
                minlength="6"
                :disabled="authStore.loading"
              >
              <small class="form-text">Password must be at least 6 characters</small>
            </div>

            <div class="form-group">
              <label class="form-label">Confirm Password *</label>
              <input
                type="password"
                class="form-control"
                v-model="confirmPassword"
                placeholder="Re-enter your password"
                required
                :disabled="authStore.loading"
              >
            </div>

            <!-- Role is hidden, all public registrations are Players -->
            <!-- Admins must be created through Supabase Dashboard or by existing admins -->

            <div class="form-actions">
              <button
                type="submit"
                class="btn btn-primary btn-lg"
                :disabled="authStore.loading || password !== confirmPassword"
              >
                {{ authStore.loading ? 'Creating Account...' : 'Sign Up' }}
              </button>
            </div>

            <div v-if="password && confirmPassword && password !== confirmPassword" class="alert alert-warning mt-2">
              Passwords do not match
            </div>
          </form>

          <div class="register-footer">
            <p>
              Already have an account?
              <router-link to="/login" class="link">Sign In</router-link>
            </p>
          </div>
        </div>
      </div>

      <div class="venue-info">
        <p>📍 88 Tristram Street, Hamilton Central</p>
        <p>📞 022 166 0688</p>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/authStore'

export default {
  name: 'RegisterPage',
  setup() {
    const router = useRouter()
    const authStore = useAuthStore()

    const fullName = ref('')
    const email = ref('')
    const password = ref('')
    const confirmPassword = ref('')
    const role = ref('player')
    const registrationSuccess = ref(false)
    const registrationError = ref('')

    const handleSignUp = async () => {
      // Clear previous errors
      registrationError.value = ''
      
      if (password.value !== confirmPassword.value) {
        registrationError.value = 'Passwords do not match'
        return
      }

      if (password.value.length < 6) {
        registrationError.value = 'Password must be at least 6 characters'
        return
      }

      const result = await authStore.signUp({
        email: email.value,
        password: password.value,
        fullName: fullName.value,
        role: role.value
      })

      if (result.success) {
        registrationSuccess.value = true
        registrationError.value = ''
        setTimeout(() => {
          router.push('/login')
        }, 3000)
      } else {
        registrationError.value = result.error || 'Registration failed. Please try again.'
      }
    }

    return {
      authStore,
      fullName,
      email,
      password,
      confirmPassword,
      role,
      registrationSuccess,
      registrationError,
      handleSignUp
    }
  }
}
</script>

<style scoped>
.register-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1a1a2e 0%, #0f3460 100%);
  padding: 2rem;
}

.register-container {
  width: 100%;
  max-width: 500px;
}

.register-card {
  background: white;
  padding: 0;
  overflow: hidden;
}

.register-header {
  background: linear-gradient(135deg, #1a1a2e, #0f3460);
  color: white;
  padding: 2rem;
  text-align: center;
}

.register-logo {
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

.register-header p {
  opacity: 0.9;
  margin: 0;
}

.register-body {
  padding: 2rem;
}

.register-body h2 {
  font-size: 1.5rem;
  margin-bottom: 1.5rem;
  color: var(--dark-color);
}

.form-text {
  display: block;
  margin-top: 0.25rem;
  font-size: 0.875rem;
  color: var(--text-secondary);
}

.form-actions {
  margin-top: 1.5rem;
}

.form-actions .btn {
  width: 100%;
}

.register-footer {
  margin-top: 1.5rem;
  text-align: center;
  padding-top: 1.5rem;
  border-top: 1px solid var(--border-color);
}

.register-footer p {
  margin: 0;
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
  .register-page {
    padding: 1rem;
    align-items: flex-start;
    padding-top: 2rem;
  }

  .register-header {
    padding: 1.5rem;
  }

  .register-logo {
    height: 100px;
    max-width: 240px;
    padding: 10px 20px;
  }

  .register-header p {
    font-size: 0.875rem;
  }

  .register-body {
    padding: 1.5rem;
  }

  .register-body h2 {
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

  .form-group {
    margin-bottom: 1.25rem;
  }

  /* 大注册按钮 */
  .btn-lg {
    min-height: 52px;
    font-size: 17px;
    font-weight: 700;
  }

  /* 优化链接大小 */
  .register-footer {
    margin-top: 1.25rem;
    padding-top: 1.25rem;
  }

  .register-footer p {
    font-size: 14px;
    margin: 0.75rem 0;
  }

  .link {
    font-size: 15px;
    font-weight: 600;
  }

  /* Select 下拉框优化 */
  select.form-control {
    min-height: 48px;
    font-size: 16px;
  }

  /* 帮助文本 */
  .form-help {
    font-size: 12px;
    margin-top: 4px;
  }

  /* 场馆信息 */
  .venue-info {
    margin-top: 1.25rem;
    font-size: 14px;
  }

  .venue-info p {
    margin: 0.5rem 0;
  }
}
</style>


