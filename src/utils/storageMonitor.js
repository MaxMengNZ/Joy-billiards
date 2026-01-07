/**
 * Storage Monitor Utility
 * Helps monitor and manage browser storage usage
 */

/**
 * Get localStorage size and details
 */
export function getLocalStorageInfo() {
  let totalSize = 0
  const items = []
  
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i)
    const value = localStorage.getItem(key)
    const size = new Blob([value]).size
    totalSize += size
    items.push({
      key,
      size,
      sizeFormatted: formatBytes(size),
      value: value.length > 100 ? value.substring(0, 100) + '...' : value
    })
  }
  
  return {
    totalSize,
    totalSizeFormatted: formatBytes(totalSize),
    itemCount: localStorage.length,
    items,
    usage: (totalSize / (5 * 1024 * 1024) * 100).toFixed(2) // 5MB is typical limit
  }
}

/**
 * Get sessionStorage size and details
 */
export function getSessionStorageInfo() {
  let totalSize = 0
  const items = []
  
  for (let i = 0; i < sessionStorage.length; i++) {
    const key = sessionStorage.key(i)
    const value = sessionStorage.getItem(key)
    const size = new Blob([value]).size
    totalSize += size
    items.push({
      key,
      size,
      sizeFormatted: formatBytes(size),
      value: value.length > 100 ? value.substring(0, 100) + '...' : value
    })
  }
  
  return {
    totalSize,
    totalSizeFormatted: formatBytes(totalSize),
    itemCount: sessionStorage.length,
    items
  }
}

/**
 * Get Service Worker cache info
 */
export async function getCacheStorageInfo() {
  if (!('caches' in window)) {
    return {
      available: false,
      message: 'Cache Storage API not available'
    }
  }
  
  try {
    const cacheNames = await caches.keys()
    const cacheInfo = []
    let totalSize = 0
    
    for (const cacheName of cacheNames) {
      const cache = await caches.open(cacheName)
      const keys = await cache.keys()
      let cacheSize = 0
      
      for (const key of keys) {
        const response = await cache.match(key)
        if (response) {
          const blob = await response.blob()
          cacheSize += blob.size
        }
      }
      
      totalSize += cacheSize
      cacheInfo.push({
        name: cacheName,
        size: cacheSize,
        sizeFormatted: formatBytes(cacheSize),
        itemCount: keys.length
      })
    }
    
    return {
      available: true,
      totalSize,
      totalSizeFormatted: formatBytes(totalSize),
      cacheCount: cacheNames.length,
      caches: cacheInfo
    }
  } catch (err) {
    console.error('Error getting cache info:', err)
    return {
      available: false,
      error: err.message
    }
  }
}

/**
 * Get IndexedDB info (if available)
 */
export async function getIndexedDBInfo() {
  if (!('indexedDB' in window)) {
    return {
      available: false,
      message: 'IndexedDB not available'
    }
  }
  
  try {
    const databases = await indexedDB.databases()
    return {
      available: true,
      databaseCount: databases.length,
      databases: databases.map(db => ({
        name: db.name,
        version: db.version
      }))
    }
  } catch (err) {
    return {
      available: false,
      error: err.message
    }
  }
}

/**
 * Get complete storage report
 */
export async function getStorageReport() {
  const [localStorage, sessionStorage, cacheStorage, indexedDB] = await Promise.all([
    Promise.resolve(getLocalStorageInfo()),
    Promise.resolve(getSessionStorageInfo()),
    getCacheStorageInfo(),
    getIndexedDBInfo()
  ])
  
  return {
    localStorage,
    sessionStorage,
    cacheStorage,
    indexedDB,
    timestamp: new Date().toISOString()
  }
}

/**
 * Clear all caches (Service Worker)
 */
export async function clearAllCaches() {
  if (!('caches' in window)) {
    return { success: false, error: 'Cache Storage API not available' }
  }
  
  try {
    const cacheNames = await caches.keys()
    await Promise.all(cacheNames.map(name => caches.delete(name)))
    return { success: true, cleared: cacheNames.length }
  } catch (err) {
    return { success: false, error: err.message }
  }
}

/**
 * Clear specific cache
 */
export async function clearCache(cacheName) {
  if (!('caches' in window)) {
    return { success: false, error: 'Cache Storage API not available' }
  }
  
  try {
    const deleted = await caches.delete(cacheName)
    return { success: deleted }
  } catch (err) {
    return { success: false, error: err.message }
  }
}

/**
 * Format bytes to human readable format
 */
function formatBytes(bytes, decimals = 2) {
  if (bytes === 0) return '0 Bytes'
  
  const k = 1024
  const dm = decimals < 0 ? 0 : decimals
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i]
}

/**
 * Log storage report to console
 */
export async function logStorageReport() {
  const report = await getStorageReport()
  
  console.group('📊 Storage Report')
  console.log('LocalStorage:', report.localStorage)
  console.log('SessionStorage:', report.sessionStorage)
  console.log('Cache Storage:', report.cacheStorage)
  console.log('IndexedDB:', report.indexedDB)
  console.groupEnd()
  
  return report
}

