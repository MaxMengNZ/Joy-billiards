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
              <label class="form-label">Date of Birth *</label>
              <input
                type="text"
                class="form-control"
                v-model="birthday"
                placeholder="DD/MM/YYYY (e.g., 15/03/2000)"
                required
                :disabled="authStore.loading"
                @input="formatBirthdayInput"
              >
              <small class="form-text">Format: DD/MM/YYYY (You must be at least 13 years old)</small>
            </div>

            <div class="form-group">
              <label class="form-label">Email *</label>
              <input
                type="email"
                class="form-control"
                :class="{ 'is-invalid': emailError }"
                v-model="email"
                placeholder="your.email@example.com"
                required
                :disabled="authStore.loading"
                @blur="validateEmail"
                @input="clearEmailError"
              >
              <div v-if="emailError" class="invalid-feedback">
                {{ emailError }}
              </div>
              <div v-if="emailChecking" class="form-text text-info">
                <i class="fas fa-spinner fa-spin"></i> Checking email availability...
              </div>
              <div v-if="emailValid && !emailChecking" class="form-text text-success">
                <i class="fas fa-check"></i> Email is available
              </div>
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

            <div class="form-group">
              <label class="form-label">Phone Number *</label>
              <input
                type="tel"
                class="form-control"
                v-model="phoneNumber"
                placeholder="022 123 4567"
                required
                :disabled="authStore.loading"
              >
              <small class="form-text">Please enter your phone number</small>
            </div>

            <!-- Role is hidden, all public registrations are Players -->
            <!-- Admins must be created through Supabase Dashboard or by existing admins -->

            <div class="form-actions">
              <button
                type="submit"
                class="btn btn-primary btn-lg"
                :disabled="authStore.loading || password !== confirmPassword || !emailValid || emailChecking"
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
import { createClient } from '@supabase/supabase-js'

// Initialize Supabase client
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY
const supabase = createClient(supabaseUrl, supabaseKey)

export default {
  name: 'RegisterPage',
  setup() {
    const router = useRouter()
    const authStore = useAuthStore()

    const fullName = ref('')
    const email = ref('')
    const password = ref('')
    const confirmPassword = ref('')
    const phoneNumber = ref('')
    const birthday = ref('')
    const role = ref('player')
    const registrationSuccess = ref(false)
    const registrationError = ref('')
    
    // Email validation states
    const emailError = ref('')
    const emailValid = ref(false)
    const emailChecking = ref(false)

    // Get today's date for age validation
    const today = new Date()

    // Email validation functions
    const validateEmailFormat = (email) => {
      const emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
      return emailRegex.test(email)
    }

    const checkEmailExists = async (email) => {
      try {
        console.log('Checking email:', email) // 调试日志
        
        // 直接测试 RPC 调用
        const response = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/rest/v1/rpc/check_email_exists`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'apikey': import.meta.env.VITE_SUPABASE_ANON_KEY,
            'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`
          },
          body: JSON.stringify({ email })
        })
        
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`)
        }
        
        const data = await response.json()
        console.log('RPC result:', data) // 调试日志
        
        return { exists: data, error: null }
      } catch (err) {
        console.error('RPC error:', err) // 调试日志
        return { exists: false, error: err }
      }
    }

    const validateEmail = async () => {
      if (!email.value.trim()) {
        emailError.value = ''
        emailValid.value = false
        return
      }

      // Check email format first
      if (!validateEmailFormat(email.value)) {
        emailError.value = 'Please enter a valid email address'
        emailValid.value = false
        return
      }

      // Check for common invalid domains
      const invalidDomains = ['example.com', 'test.com', 'fake.com', 'temp.com']
      const domain = email.value.split('@')[1]?.toLowerCase()
      if (invalidDomains.includes(domain)) {
        emailError.value = 'Please use a real email address'
        emailValid.value = false
        return
      }

      // Check if email already exists
      emailChecking.value = true
      emailError.value = ''
      
      try {
        // 添加超时机制
        const timeoutPromise = new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Request timeout')), 10000)
        )
        
        const { exists, error } = await Promise.race([
          checkEmailExists(email.value),
          timeoutPromise
        ])
        
        if (error && error.code !== 'PGRST116') { // PGRST116 = no rows returned
          emailError.value = 'Error checking email availability'
          emailValid.value = false
        } else if (exists) {
          emailError.value = 'This email is already registered'
          emailValid.value = false
        } else {
          emailError.value = ''
          emailValid.value = true
        }
      } catch (err) {
        console.error('Email validation error:', err)
        emailError.value = 'Error checking email availability'
        emailValid.value = false
      } finally {
        emailChecking.value = false
      }
    }

    const clearEmailError = () => {
      if (emailError.value) {
        emailError.value = ''
        emailValid.value = false
      }
    }

    // Format birthday input as user types (DD/MM/YYYY)
    const formatBirthdayInput = (event) => {
      let value = event.target.value.replace(/\D/g, '') // Remove non-digits
      
      if (value.length >= 2) {
        value = value.slice(0, 2) + '/' + value.slice(2)
      }
      if (value.length >= 5) {
        value = value.slice(0, 5) + '/' + value.slice(5, 9)
      }
      
      birthday.value = value
    }

    // Parse DD/MM/YYYY to Date object
    const parseBirthday = (dateString) => {
      const parts = dateString.split('/')
      if (parts.length !== 3) return null
      
      const day = parseInt(parts[0], 10)
      const month = parseInt(parts[1], 10) - 1 // Month is 0-indexed
      const year = parseInt(parts[2], 10)
      
      const date = new Date(year, month, day)
      
      // Validate the date is real
      if (date.getDate() !== day || date.getMonth() !== month || date.getFullYear() !== year) {
        return null
      }
      
      return date
    }

    // Convert DD/MM/YYYY to YYYY-MM-DD for database
    const convertToISODate = (ddmmyyyy) => {
      const parts = ddmmyyyy.split('/')
      if (parts.length !== 3) return null
      
      const day = parts[0].padStart(2, '0')
      const month = parts[1].padStart(2, '0')
      const year = parts[2]
      
      return `${year}-${month}-${day}`
    }

    const handleSignUp = async () => {
      // Clear previous errors
      registrationError.value = ''
      
      // Validate all required fields
      if (!fullName.value.trim()) {
        registrationError.value = 'Please enter your full name'
        return
      }

      if (!email.value.trim()) {
        registrationError.value = 'Please enter your email address'
        return
      }

      // Check email validation
      if (emailError.value || !emailValid.value) {
        registrationError.value = 'Please fix the email validation errors'
        return
      }

      if (!password.value) {
        registrationError.value = 'Please enter a password'
        return
      }

      if (!confirmPassword.value) {
        registrationError.value = 'Please confirm your password'
        return
      }

      if (password.value !== confirmPassword.value) {
        registrationError.value = 'Passwords do not match'
        return
      }

      if (password.value.length < 6) {
        registrationError.value = 'Password must be at least 6 characters'
        return
      }

      if (!phoneNumber.value.trim()) {
        registrationError.value = 'Please enter your phone number'
        return
      }

      if (!birthday.value) {
        registrationError.value = 'Please enter your date of birth'
        return
      }

      // Validate birthday format (DD/MM/YYYY)
      const birthdayRegex = /^\d{2}\/\d{2}\/\d{4}$/
      if (!birthdayRegex.test(birthday.value)) {
        registrationError.value = 'Please enter date of birth in DD/MM/YYYY format (e.g., 15/03/2000)'
        return
      }

      // Parse and validate the date
      const birthDate = parseBirthday(birthday.value)
      if (!birthDate) {
        registrationError.value = 'Please enter a valid date of birth (e.g., 15/03/2000)'
        return
      }

      // Check if date is not in the future
      if (birthDate > today) {
        registrationError.value = 'Date of birth cannot be in the future'
        return
      }

      // Validate age (must be at least 13 years old)
      const age = today.getFullYear() - birthDate.getFullYear()
      const monthDiff = today.getMonth() - birthDate.getMonth()
      const actualAge = monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate()) ? age - 1 : age

      if (actualAge < 13) {
        registrationError.value = 'You must be at least 13 years old to register'
        return
      }

      // Convert to ISO format for database (YYYY-MM-DD)
      const isoDate = convertToISODate(birthday.value)

      const result = await authStore.signUp({
        email: email.value,
        password: password.value,
        fullName: fullName.value,
        phoneNumber: phoneNumber.value,
        birthday: isoDate,
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
      phoneNumber,
      birthday,
      role,
      registrationSuccess,
      registrationError,
      emailError,
      emailValid,
      emailChecking,
      handleSignUp,
      formatBirthdayInput,
      validateEmail,
      clearEmailError
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

/* Email validation styles */
.is-invalid {
  border-color: #dc3545 !important;
}

.invalid-feedback {
  display: block;
  width: 100%;
  margin-top: 0.25rem;
  font-size: 0.875rem;
  color: #dc3545;
}

.text-success {
  color: #28a745 !important;
}

.text-info {
  color: #17a2b8 !important;
}

.fa-spinner {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>


