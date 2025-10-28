<template>
  <div class="verification-page">
    <div class="verification-container">
      <div class="verification-card card">
        <div class="verification-header">
          <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards" class="verification-logo">
          <h2>Email Verification</h2>
        </div>

        <div class="verification-body">
          <div v-if="verificationSuccess" class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            <strong>Email Verified Successfully!</strong>
            <p>Your email has been verified. You can now access all features.</p>
            <router-link to="/login" class="btn btn-primary">Go to Login</router-link>
          </div>

          <div v-else-if="verificationError" class="alert alert-danger">
            <i class="fas fa-exclamation-triangle"></i>
            <strong>Verification Failed</strong>
            <p>{{ verificationError }}</p>
            <button @click="resendVerification" class="btn btn-outline-primary" :disabled="resending">
              {{ resending ? 'Sending...' : 'Resend Verification Email' }}
            </button>
          </div>

          <div v-else class="verification-pending">
            <div class="spinner-container">
              <i class="fas fa-spinner fa-spin"></i>
            </div>
            <h3>Verifying your email...</h3>
            <p>Please wait while we verify your email address.</p>
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
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { createClient } from '@supabase/supabase-js'

// Initialize Supabase client
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY
const supabase = createClient(supabaseUrl, supabaseKey)

export default {
  name: 'EmailVerificationPage',
  setup() {
    const route = useRoute()
    const router = useRouter()
    
    const verificationSuccess = ref(false)
    const verificationError = ref('')
    const resending = ref(false)

    const verifyEmail = async (token) => {
      try {
        const { data, error } = await supabase.rpc('verify_email', { token })
        
        if (error) {
          throw error
        }
        
        if (data) {
          verificationSuccess.value = true
          verificationError.value = ''
        } else {
          verificationError.value = 'Invalid or expired verification token. Please request a new verification email.'
        }
      } catch (err) {
        console.error('Email verification error:', err)
        verificationError.value = 'Verification failed. Please try again or request a new verification email.'
      }
    }

    const resendVerification = async () => {
      resending.value = true
      try {
        const { error } = await supabase.rpc('send_email_verification', { 
          user_email: route.query.email || '' 
        })
        
        if (error) {
          throw error
        }
        
        verificationError.value = 'Verification email sent! Please check your inbox.'
      } catch (err) {
        console.error('Resend verification error:', err)
        verificationError.value = 'Failed to resend verification email. Please try again.'
      } finally {
        resending.value = false
      }
    }

    onMounted(() => {
      const token = route.query.token
      if (token) {
        verifyEmail(token)
      } else {
        verificationError.value = 'No verification token provided.'
      }
    })

    return {
      verificationSuccess,
      verificationError,
      resending,
      resendVerification
    }
  }
}
</script>

<style scoped>
.verification-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1a1a2e 0%, #0f3460 100%);
  padding: 2rem;
}

.verification-container {
  width: 100%;
  max-width: 500px;
}

.verification-card {
  background: white;
  padding: 0;
  overflow: hidden;
}

.verification-header {
  background: linear-gradient(135deg, #1a1a2e, #0f3460);
  color: white;
  padding: 2rem;
  text-align: center;
}

.verification-logo {
  height: 120px;
  width: auto;
  max-width: 280px;
  object-fit: contain;
  margin-bottom: 1rem;
  background: white;
  padding: 12px 24px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.verification-header h2 {
  margin: 0;
  font-size: 1.5rem;
}

.verification-body {
  padding: 2rem;
  text-align: center;
}

.verification-pending {
  padding: 2rem 0;
}

.spinner-container {
  margin-bottom: 1rem;
}

.spinner-container i {
  font-size: 3rem;
  color: var(--primary-color);
}

.verification-pending h3 {
  color: var(--dark-color);
  margin-bottom: 1rem;
}

.verification-pending p {
  color: var(--text-secondary);
  margin: 0;
}

.alert {
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 1rem;
}

.alert-success {
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  color: #155724;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c6cb;
  color: #721c24;
}

.alert i {
  margin-right: 0.5rem;
}

.alert p {
  margin: 0.5rem 0 0 0;
}

.btn {
  margin-top: 1rem;
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
  .verification-page {
    padding: 1rem;
    align-items: flex-start;
    padding-top: 2rem;
  }

  .verification-header {
    padding: 1.5rem;
  }

  .verification-logo {
    height: 100px;
    max-width: 240px;
    padding: 10px 20px;
  }

  .verification-header h2 {
    font-size: 1.25rem;
  }

  .verification-body {
    padding: 1.5rem;
  }

  .spinner-container i {
    font-size: 2.5rem;
  }

  .verification-pending h3 {
    font-size: 1.25rem;
  }

  .alert {
    padding: 1.25rem;
  }

  .venue-info {
    margin-top: 1.25rem;
    font-size: 14px;
  }
}
</style>
