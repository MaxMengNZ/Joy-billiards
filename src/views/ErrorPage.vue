<template>
  <div class="error-page">
    <div class="error-content">
      <!-- 404 Not Found -->
      <div v-if="errorType === '404'" class="error-card">
        <div class="error-animation">
          <div class="billiard-balls">
            <div class="ball ball-1">4</div>
            <div class="ball ball-2">0</div>
            <div class="ball ball-3">4</div>
          </div>
        </div>
        <h1 class="error-title">Page Not Found</h1>
        <p class="error-description">
          The page you're looking for seems to have been scratched off the table.
        </p>
      </div>

      <!-- 403 Forbidden -->
      <div v-else-if="errorType === '403'" class="error-card">
        <div class="error-animation">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
          </svg>
        </div>
        <h1 class="error-title">Access Denied</h1>
        <p class="error-description">
          You don't have permission to access this area. Please contact an administrator if you believe this is a mistake.
        </p>
      </div>

      <!-- 500 Server Error -->
      <div v-else-if="errorType === '500'" class="error-card">
        <div class="error-animation">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
          </svg>
        </div>
        <h1 class="error-title">Server Error</h1>
        <p class="error-description">
          Something went wrong on our end. We're working to fix it. Please try again later.
        </p>
      </div>

      <!-- Network Error -->
      <div v-else-if="errorType === 'network'" class="error-card">
        <div class="error-animation">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 5.636a9 9 0 010 12.728m0 0l-2.829-2.829m2.829 2.829L21 21M15.536 8.464a5 5 0 010 7.072m0 0l-2.829-2.829m-4.243 2.829a4.978 4.978 0 01-1.414-2.83m-1.414 5.658a9 9 0 01-2.167-9.238m7.824 2.167a1 1 0 111.414 1.414m-1.414-1.414L3 3m8.293 8.293l1.414 1.414" />
          </svg>
        </div>
        <h1 class="error-title">Connection Lost</h1>
        <p class="error-description">
          Unable to connect to the server. Please check your internet connection and try again.
        </p>
      </div>

      <!-- Generic Error -->
      <div v-else class="error-card">
        <div class="error-animation">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <h1 class="error-title">Oops! Something Went Wrong</h1>
        <p class="error-description">
          {{ customMessage || 'An unexpected error occurred. Please try again later.' }}
        </p>
      </div>

      <!-- Action Buttons -->
      <div class="error-actions">
        <button @click="goBack" class="btn-primary">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          Go Back
        </button>
        <button @click="goHome" class="btn-secondary">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
          </svg>
          Home
        </button>
        <button v-if="isRetryable" @click="retry" class="btn-accent">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
          Try Again
        </button>
      </div>

      <p class="error-help">
        Need help? Contact us at 
        <a href="mailto:info@joybilliardsnz.com">info@joybilliardsnz.com</a>
      </p>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()

const props = defineProps({
  errorType: {
    type: String,
    default: 'generic'
  },
  customMessage: {
    type: String,
    default: null
  }
})

const isRetryable = computed(() => {
  return props.errorType === 'network' || props.errorType === '500'
})

const goBack = () => {
  if (window.history.length > 1) {
    router.back()
  } else {
    router.push('/')
  }
}

const goHome = () => {
  router.push('/')
}

const retry = () => {
  window.location.reload()
}
</script>

<style scoped>
.error-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  padding: 2rem;
  position: relative;
  overflow: hidden;
}

.error-page::before {
  content: '';
  position: absolute;
  width: 500px;
  height: 500px;
  background: radial-gradient(circle, rgba(102, 126, 234, 0.1) 0%, transparent 70%);
  border-radius: 50%;
  top: -250px;
  right: -250px;
  animation: pulse 4s ease-in-out infinite;
}

.error-page::after {
  content: '';
  position: absolute;
  width: 400px;
  height: 400px;
  background: radial-gradient(circle, rgba(118, 75, 162, 0.1) 0%, transparent 70%);
  border-radius: 50%;
  bottom: -200px;
  left: -200px;
  animation: pulse 4s ease-in-out infinite 2s;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
    opacity: 1;
  }
  50% {
    transform: scale(1.2);
    opacity: 0.8;
  }
}

.error-content {
  max-width: 600px;
  width: 100%;
  position: relative;
  z-index: 1;
}

.error-card {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 24px;
  padding: 3rem;
  text-align: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: slideUp 0.6s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.error-animation {
  width: 120px;
  height: 120px;
  margin: 0 auto 2rem;
  color: #667eea;
}

.error-animation svg {
  width: 100%;
  height: 100%;
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-20px);
  }
}

/* 404 Billiard Balls Animation */
.billiard-balls {
  display: flex;
  justify-content: center;
  gap: 1rem;
  height: 120px;
  align-items: center;
}

.ball {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  font-weight: 700;
  color: white;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
  animation: bounce 2s ease-in-out infinite;
}

.ball-1 {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  animation-delay: 0s;
}

.ball-2 {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  animation-delay: 0.2s;
}

.ball-3 {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  animation-delay: 0.4s;
}

@keyframes bounce {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-30px);
  }
}

.error-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: white;
  margin-bottom: 1rem;
  text-shadow: 0 4px 10px rgba(0, 0, 0, 0.5);
}

.error-description {
  font-size: 1.125rem;
  color: rgba(255, 255, 255, 0.8);
  line-height: 1.7;
  margin-bottom: 2rem;
}

.error-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.error-actions button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.875rem 1.75rem;
  border: none;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.error-actions button svg {
  width: 20px;
  height: 20px;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 14px rgba(102, 126, 234, 0.4);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.15);
  transform: translateY(-2px);
}

.btn-accent {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  box-shadow: 0 4px 14px rgba(245, 87, 108, 0.4);
}

.btn-accent:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(245, 87, 108, 0.6);
}

.error-help {
  color: rgba(255, 255, 255, 0.6);
  font-size: 0.875rem;
  margin-top: 2rem;
}

.error-help a {
  color: #667eea;
  text-decoration: none;
  font-weight: 600;
}

.error-help a:hover {
  text-decoration: underline;
}

@media (max-width: 640px) {
  .error-card {
    padding: 2rem;
  }
  
  .error-title {
    font-size: 1.75rem;
  }
  
  .error-description {
    font-size: 1rem;
  }
  
  .error-actions {
    flex-direction: column;
  }
  
  .error-actions button {
    width: 100%;
  }
  
  .billiard-balls {
    gap: 0.5rem;
  }
  
  .ball {
    width: 60px;
    height: 60px;
    font-size: 1.5rem;
  }
}
</style>


