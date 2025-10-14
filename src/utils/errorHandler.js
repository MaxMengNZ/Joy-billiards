/**
 * Error Handler Utility
 * Centralized error handling, logging, and user notification
 */

import { ref } from 'vue'

// Error log storage (in production, this would be sent to an error tracking service)
const errorLog = ref([])

/**
 * Error types for categorization
 */
export const ErrorTypes = {
  NETWORK: 'network',
  AUTHENTICATION: 'authentication',
  AUTHORIZATION: 'authorization',
  VALIDATION: 'validation',
  NOT_FOUND: 'not_found',
  SERVER: 'server',
  CLIENT: 'client',
  UNKNOWN: 'unknown'
}

/**
 * Categorize error based on error object
 */
export function categorizeError(error) {
  if (!error) return ErrorTypes.UNKNOWN

  const message = error.message?.toLowerCase() || ''
  const status = error.status || error.response?.status

  // Network errors
  if (
    message.includes('network') ||
    message.includes('fetch') ||
    message.includes('timeout') ||
    status === 0 ||
    error.name === 'NetworkError'
  ) {
    return ErrorTypes.NETWORK
  }

  // Authentication errors
  if (
    status === 401 ||
    message.includes('unauthorized') ||
    message.includes('authentication')
  ) {
    return ErrorTypes.AUTHENTICATION
  }

  // Authorization errors
  if (
    status === 403 ||
    message.includes('forbidden') ||
    message.includes('permission') ||
    message.includes('access denied')
  ) {
    return ErrorTypes.AUTHORIZATION
  }

  // Not found errors
  if (status === 404 || message.includes('not found')) {
    return ErrorTypes.NOT_FOUND
  }

  // Validation errors
  if (
    status === 400 ||
    status === 422 ||
    message.includes('validation') ||
    message.includes('invalid')
  ) {
    return ErrorTypes.VALIDATION
  }

  // Server errors
  if (status >= 500 && status < 600) {
    return ErrorTypes.SERVER
  }

  // Client errors
  if (status >= 400 && status < 500) {
    return ErrorTypes.CLIENT
  }

  return ErrorTypes.UNKNOWN
}

/**
 * Get user-friendly error message
 */
export function getUserFriendlyMessage(error) {
  const type = categorizeError(error)

  const messages = {
    [ErrorTypes.NETWORK]: 'Unable to connect to the server. Please check your internet connection and try again.',
    [ErrorTypes.AUTHENTICATION]: 'Your session has expired. Please log in again.',
    [ErrorTypes.AUTHORIZATION]: 'You do not have permission to perform this action.',
    [ErrorTypes.VALIDATION]: 'Please check your input and try again.',
    [ErrorTypes.NOT_FOUND]: 'The requested resource could not be found.',
    [ErrorTypes.SERVER]: 'A server error occurred. Our team has been notified. Please try again later.',
    [ErrorTypes.CLIENT]: 'An error occurred while processing your request. Please try again.',
    [ErrorTypes.UNKNOWN]: 'An unexpected error occurred. Please try again later.'
  }

  return messages[type] || messages[ErrorTypes.UNKNOWN]
}

/**
 * Log error for debugging and monitoring
 */
export function logError(error, context = {}) {
  const errorEntry = {
    timestamp: new Date().toISOString(),
    type: categorizeError(error),
    message: error.message || 'Unknown error',
    stack: error.stack,
    context: {
      ...context,
      userAgent: navigator.userAgent,
      url: window.location.href,
      viewport: {
        width: window.innerWidth,
        height: window.innerHeight
      }
    }
  }

  // Add to local error log
  errorLog.value.push(errorEntry)

  // Keep only last 50 errors
  if (errorLog.value.length > 50) {
    errorLog.value = errorLog.value.slice(-50)
  }

  // Log to console in development
  if (import.meta.env.DEV) {
    console.error('Error logged:', errorEntry)
  }

  // In production, send to error tracking service (e.g., Sentry)
  if (import.meta.env.PROD) {
    // TODO: Send to error tracking service
    // Example: Sentry.captureException(error, { extra: context })
  }

  return errorEntry
}

/**
 * Handle API errors from Supabase
 */
export function handleSupabaseError(error, customMessage = null) {
  console.error('Supabase error:', error)

  const errorData = {
    type: categorizeError(error),
    message: customMessage || getUserFriendlyMessage(error),
    originalError: error
  }

  logError(error, { source: 'supabase' })

  return errorData
}

/**
 * Create a safe async function wrapper with error handling
 */
export function withErrorHandling(fn, options = {}) {
  const {
    onError = null,
    defaultValue = null,
    showNotification = true,
    context = {}
  } = options

  return async (...args) => {
    try {
      return await fn(...args)
    } catch (error) {
      logError(error, { ...context, function: fn.name })

      if (onError) {
        onError(error)
      }

      if (showNotification) {
        // Show user notification (would integrate with notification system)
        console.warn('Error:', getUserFriendlyMessage(error))
      }

      return defaultValue
    }
  }
}

/**
 * Retry mechanism for failed operations
 */
export async function retryOperation(
  operation,
  options = {}
) {
  const {
    maxRetries = 3,
    delay = 1000,
    backoff = 2,
    onRetry = null
  } = options

  let lastError = null

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await operation()
    } catch (error) {
      lastError = error

      if (attempt < maxRetries) {
        // Calculate delay with exponential backoff
        const retryDelay = delay * Math.pow(backoff, attempt)

        if (onRetry) {
          onRetry(attempt + 1, retryDelay, error)
        }

        console.log(`Retry attempt ${attempt + 1}/${maxRetries} after ${retryDelay}ms`)

        // Wait before retrying
        await new Promise(resolve => setTimeout(resolve, retryDelay))
      }
    }
  }

  // All retries failed
  logError(lastError, { maxRetries, operation: operation.name })
  throw lastError
}

/**
 * Check if error is retryable
 */
export function isRetryableError(error) {
  const type = categorizeError(error)
  return type === ErrorTypes.NETWORK || type === ErrorTypes.SERVER
}

/**
 * Get error log for debugging
 */
export function getErrorLog() {
  return errorLog.value
}

/**
 * Clear error log
 */
export function clearErrorLog() {
  errorLog.value = []
}

/**
 * Export error log as JSON
 */
export function exportErrorLog() {
  const data = JSON.stringify(errorLog.value, null, 2)
  const blob = new Blob([data], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `error-log-${new Date().toISOString()}.json`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
}

/**
 * Global error handler for uncaught errors
 */
export function setupGlobalErrorHandler() {
  // Handle unhandled promise rejections
  window.addEventListener('unhandledrejection', (event) => {
    console.error('Unhandled promise rejection:', event.reason)
    logError(event.reason, { type: 'unhandledRejection' })
    event.preventDefault()
  })

  // Handle global errors
  window.addEventListener('error', (event) => {
    console.error('Global error:', event.error)
    logError(event.error, { type: 'globalError' })
  })
}

export default {
  ErrorTypes,
  categorizeError,
  getUserFriendlyMessage,
  logError,
  handleSupabaseError,
  withErrorHandling,
  retryOperation,
  isRetryableError,
  getErrorLog,
  clearErrorLog,
  exportErrorLog,
  setupGlobalErrorHandler
}


