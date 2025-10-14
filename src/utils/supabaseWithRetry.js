/**
 * Supabase Client with Retry Mechanism
 * Automatically retries failed operations with exponential backoff
 */

import { supabase } from '@/config/supabase'
import { retryOperation, isRetryableError, logError } from './errorHandler'

/**
 * Wrap Supabase query with retry logic
 */
export async function queryWithRetry(queryFn, options = {}) {
  const {
    maxRetries = 3,
    delay = 1000,
    context = {}
  } = options

  return retryOperation(queryFn, {
    maxRetries,
    delay,
    backoff: 2,
    onRetry: (attempt, retryDelay, error) => {
      console.log(`Retrying Supabase query (attempt ${attempt}/${maxRetries})...`)
      logError(error, { ...context, retry: attempt })
    }
  })
}

/**
 * Enhanced Supabase select with retry
 */
export async function selectWithRetry(table, options = {}) {
  const {
    columns = '*',
    filters = {},
    orderBy = null,
    limit = null,
    single = false,
    maxRetries = 3
  } = options

  return queryWithRetry(async () => {
    let query = supabase.from(table).select(columns)

    // Apply filters
    Object.entries(filters).forEach(([key, value]) => {
      if (value !== null && value !== undefined) {
        query = query.eq(key, value)
      }
    })

    // Apply ordering
    if (orderBy) {
      const { column, ascending = true } = orderBy
      query = query.order(column, { ascending })
    }

    // Apply limit
    if (limit) {
      query = query.limit(limit)
    }

    // Single vs multiple
    if (single) {
      query = query.single()
    }

    const { data, error } = await query

    if (error) {
      // Only retry if error is retryable
      if (isRetryableError(error)) {
        throw error
      } else {
        // Non-retryable error, log and throw immediately
        logError(error, { table, options })
        throw error
      }
    }

    return data
  }, { maxRetries, context: { table, operation: 'select' } })
}

/**
 * Enhanced Supabase insert with retry
 */
export async function insertWithRetry(table, data, options = {}) {
  const { maxRetries = 3, returning = true } = options

  return queryWithRetry(async () => {
    let query = supabase.from(table).insert(data)

    if (returning) {
      query = query.select()
    }

    const { data: result, error } = await query

    if (error) {
      if (isRetryableError(error)) {
        throw error
      } else {
        logError(error, { table, operation: 'insert', data })
        throw error
      }
    }

    return result
  }, { maxRetries, context: { table, operation: 'insert' } })
}

/**
 * Enhanced Supabase update with retry
 */
export async function updateWithRetry(table, id, data, options = {}) {
  const { maxRetries = 3, idColumn = 'id' } = options

  return queryWithRetry(async () => {
    const { data: result, error } = await supabase
      .from(table)
      .update(data)
      .eq(idColumn, id)
      .select()

    if (error) {
      if (isRetryableError(error)) {
        throw error
      } else {
        logError(error, { table, operation: 'update', id, data })
        throw error
      }
    }

    return result
  }, { maxRetries, context: { table, operation: 'update' } })
}

/**
 * Enhanced Supabase delete with retry
 */
export async function deleteWithRetry(table, id, options = {}) {
  const { maxRetries = 3, idColumn = 'id' } = options

  return queryWithRetry(async () => {
    const { data: result, error } = await supabase
      .from(table)
      .delete()
      .eq(idColumn, id)
      .select()

    if (error) {
      if (isRetryableError(error)) {
        throw error
      } else {
        logError(error, { table, operation: 'delete', id })
        throw error
      }
    }

    return result
  }, { maxRetries, context: { table, operation: 'delete' } })
}

/**
 * Enhanced Supabase RPC call with retry
 */
export async function rpcWithRetry(functionName, params = {}, options = {}) {
  const { maxRetries = 3 } = options

  return queryWithRetry(async () => {
    const { data, error } = await supabase.rpc(functionName, params)

    if (error) {
      if (isRetryableError(error)) {
        throw error
      } else {
        logError(error, { functionName, operation: 'rpc', params })
        throw error
      }
    }

    return data
  }, { maxRetries, context: { functionName, operation: 'rpc' } })
}

/**
 * Batch operations with transaction-like behavior
 */
export async function batchOperations(operations, options = {}) {
  const { maxRetries = 3, stopOnError = true } = options

  return queryWithRetry(async () => {
    const results = []
    const errors = []

    for (const operation of operations) {
      try {
        const result = await operation()
        results.push({ success: true, data: result })
      } catch (error) {
        errors.push({ success: false, error })
        
        if (stopOnError) {
          logError(error, { operation: 'batchOperations', stopOnError })
          throw error
        }
      }
    }

    if (errors.length > 0 && !stopOnError) {
      console.warn(`Batch operations completed with ${errors.length} errors`)
    }

    return { results, errors }
  }, { maxRetries, context: { operation: 'batch' } })
}

/**
 * Check connection health
 */
export async function checkConnection() {
  try {
    const { error } = await supabase
      .from('users')
      .select('id', { count: 'exact', head: true })
      .limit(1)

    if (error) {
      logError(error, { operation: 'checkConnection' })
      return false
    }

    return true
  } catch (error) {
    logError(error, { operation: 'checkConnection' })
    return false
  }
}

/**
 * Connection status monitor
 */
export class ConnectionMonitor {
  constructor(options = {}) {
    this.interval = options.interval || 30000 // 30 seconds
    this.onStatusChange = options.onStatusChange || (() => {})
    this.isConnected = true
    this.timer = null
  }

  start() {
    this.check()
    this.timer = setInterval(() => this.check(), this.interval)
  }

  stop() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }

  async check() {
    const wasConnected = this.isConnected
    this.isConnected = await checkConnection()

    if (wasConnected !== this.isConnected) {
      this.onStatusChange(this.isConnected)
      
      if (this.isConnected) {
        console.log('✅ Connection restored')
      } else {
        console.warn('❌ Connection lost')
      }
    }
  }
}

export default {
  queryWithRetry,
  selectWithRetry,
  insertWithRetry,
  updateWithRetry,
  deleteWithRetry,
  rpcWithRetry,
  batchOperations,
  checkConnection,
  ConnectionMonitor
}


