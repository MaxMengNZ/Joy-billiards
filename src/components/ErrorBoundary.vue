<template>
  <div v-if="hasError" class="error-boundary">
    <div class="error-container">
      <div class="error-icon">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
      </div>
      <h1 class="error-title">{{ errorTitle }}</h1>
      <p class="error-message">{{ errorMessage }}</p>
      
      <div class="error-details" v-if="isDevelopment && errorDetails">
        <details>
          <summary>Error Details (Development Only)</summary>
          <pre>{{ errorDetails }}</pre>
        </details>
      </div>
      
      <div class="error-actions">
        <button @click="retry" class="btn-primary">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
          Try Again
        </button>
        <button @click="goHome" class="btn-secondary">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
          </svg>
          Go Home
        </button>
      </div>
      
      <p class="error-help">
        If this problem persists, please contact support at 
        <a href="mailto:info@joybilliardsnz.com">info@joybilliardsnz.com</a>
      </p>
    </div>
  </div>
  <slot v-else></slot>
</template>

<script setup>
import { ref, onErrorCaptured, computed } from 'vue'
import { useRouter } from 'vue-router'
import { logError } from '@/utils/errorHandler'

const router = useRouter()

const hasError = ref(false)
const error = ref(null)
const errorInfo = ref(null)

const isDevelopment = computed(() => import.meta.env.DEV)

const errorTitle = computed(() => {
  if (!error.value) return 'Something went wrong'
  
  // Categorize errors
  if (error.value.message?.includes('Network')) {
    return 'Network Error'
  }
  if (error.value.message?.includes('Permission') || error.value.message?.includes('Access')) {
    return 'Permission Denied'
  }
  if (error.value.message?.includes('Not Found') || error.value.message?.includes('404')) {
    return 'Resource Not Found'
  }
  
  return 'Application Error'
})

const errorMessage = computed(() => {
  if (!error.value) return 'An unexpected error occurred'
  
  // User-friendly messages
  if (error.value.message?.includes('Network')) {
    return 'Unable to connect to the server. Please check your internet connection and try again.'
  }
  if (error.value.message?.includes('Permission') || error.value.message?.includes('Access')) {
    return 'You do not have permission to access this resource. Please contact an administrator if you believe this is a mistake.'
  }
  if (error.value.message?.includes('Not Found')) {
    return 'The requested resource could not be found. It may have been moved or deleted.'
  }
  
  return error.value.message || 'An unexpected error occurred. Please try again later.'
})

const errorDetails = computed(() => {
  if (!error.value) return null
  
  return {
    message: error.value.message,
    stack: error.value.stack,
    info: errorInfo.value,
    time: new Date().toISOString()
  }
})

// Capture errors from child components
onErrorCaptured((err, instance, info) => {
  hasError.value = true
  error.value = err
  errorInfo.value = info
  
  // Log error to console and error tracking service
  logError(err, { component: instance?.$options?.name, info })
  
  // Prevent error from propagating
  return false
})

const retry = () => {
  hasError.value = false
  error.value = null
  errorInfo.value = null
  
  // Force component re-render
  window.location.reload()
}

const goHome = () => {
  hasError.value = false
  error.value = null
  errorInfo.value = null
  router.push('/')
}
</script>

<style scoped>
.error-boundary {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 2rem;
}

.error-container {
  max-width: 600px;
  width: 100%;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 24px;
  padding: 3rem;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  text-align: center;
  animation: slideUp 0.5s ease-out;
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

.error-icon {
  width: 80px;
  height: 80px;
  margin: 0 auto 2rem;
  color: #ef4444;
  animation: pulse 2s infinite;
}

.error-icon svg {
  width: 100%;
  height: 100%;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.8;
    transform: scale(1.1);
  }
}

.error-title {
  font-size: 2rem;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 1rem;
}

.error-message {
  font-size: 1.125rem;
  color: #6b7280;
  line-height: 1.7;
  margin-bottom: 2rem;
}

.error-details {
  margin: 2rem 0;
  text-align: left;
}

.error-details details {
  background: #f3f4f6;
  border-radius: 8px;
  padding: 1rem;
}

.error-details summary {
  cursor: pointer;
  font-weight: 600;
  color: #4b5563;
  user-select: none;
}

.error-details pre {
  margin-top: 1rem;
  padding: 1rem;
  background: #1f2937;
  color: #f9fafb;
  border-radius: 6px;
  overflow-x: auto;
  font-size: 0.875rem;
  line-height: 1.5;
  white-space: pre-wrap;
  word-break: break-word;
}

.error-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 2rem;
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
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
}

.btn-secondary {
  background: #f3f4f6;
  color: #4b5563;
}

.btn-secondary:hover {
  background: #e5e7eb;
  transform: translateY(-2px);
}

.error-help {
  color: #6b7280;
  font-size: 0.875rem;
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
  .error-container {
    padding: 2rem;
  }
  
  .error-title {
    font-size: 1.5rem;
  }
  
  .error-message {
    font-size: 1rem;
  }
  
  .error-actions {
    flex-direction: column;
  }
  
  .error-actions button {
    width: 100%;
  }
}
</style>


