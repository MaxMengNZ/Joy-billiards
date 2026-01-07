// Service Worker for Joy Billiards PWA
const CACHE_NAME = 'joy-billiards-v1'
const RUNTIME_CACHE = 'joy-billiards-runtime-v1'
const MAX_CACHE_SIZE = 50 * 1024 * 1024 // 50 MB limit
const MAX_CACHE_AGE = 7 * 24 * 60 * 60 * 1000 // 7 days

// Assets to cache on install
const PRECACHE_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icons/icon-192x192.png',
  '/icons/icon-512x512.png'
]

// Cacheable file types (only cache static assets)
const CACHEABLE_TYPES = [
  'image',
  'font',
  'script',
  'style',
  'manifest'
]

// Helper: Get cache size
async function getCacheSize(cacheName) {
  const cache = await caches.open(cacheName)
  const keys = await cache.keys()
  let totalSize = 0
  
  for (const key of keys) {
    const response = await cache.match(key)
    if (response) {
      const blob = await response.blob()
      totalSize += blob.size
    }
  }
  
  return totalSize
}

// Helper: Clean old cache entries (LRU strategy)
async function cleanOldCache(cacheName, maxSize) {
  const cache = await caches.open(cacheName)
  const keys = await cache.keys()
  
  if (keys.length === 0) return
  
  // Get all entries with timestamps
  const entries = []
  for (const key of keys) {
    const response = await cache.match(key)
    if (response) {
      const blob = await response.blob()
      const timestamp = response.headers.get('sw-cached-at') || Date.now()
      entries.push({
        key,
        size: blob.size,
        timestamp: parseInt(timestamp)
      })
    }
  }
  
  // Sort by timestamp (oldest first)
  entries.sort((a, b) => a.timestamp - b.timestamp)
  
  // Calculate total size
  let totalSize = entries.reduce((sum, entry) => sum + entry.size, 0)
  
  // Remove oldest entries until under limit
  while (totalSize > maxSize && entries.length > 0) {
    const entry = entries.shift()
    await cache.delete(entry.key)
    totalSize -= entry.size
    console.log('[Service Worker] Removed old cache entry:', entry.key.url)
  }
}

// Helper: Check if request should be cached
function shouldCache(request) {
  const url = new URL(request.url)
  
  // Don't cache API requests
  if (url.pathname.startsWith('/api/') || url.pathname.includes('supabase')) {
    return false
  }
  
  // Only cache static assets
  const destination = request.destination
  return CACHEABLE_TYPES.includes(destination)
}

// Install event - cache assets
self.addEventListener('install', (event) => {
  console.log('[Service Worker] Installing...')
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[Service Worker] Caching app shell')
        return cache.addAll(PRECACHE_ASSETS)
      })
      .then(() => self.skipWaiting())
  )
})

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('[Service Worker] Activating...')
  event.waitUntil(
    caches.keys().then(async (cacheNames) => {
      // Delete old cache versions
      await Promise.all(
        cacheNames
          .filter((cacheName) => {
            return cacheName !== CACHE_NAME && cacheName !== RUNTIME_CACHE
          })
          .map((cacheName) => {
            console.log('[Service Worker] Deleting old cache:', cacheName)
            return caches.delete(cacheName)
          })
      )
      
      // Clean runtime cache if too large
      try {
        const runtimeSize = await getCacheSize(RUNTIME_CACHE)
        if (runtimeSize > MAX_CACHE_SIZE) {
          console.log('[Service Worker] Runtime cache too large, cleaning...')
          await cleanOldCache(RUNTIME_CACHE, MAX_CACHE_SIZE * 0.8)
        }
      } catch (err) {
        console.error('[Service Worker] Error cleaning cache:', err)
      }
      
      return self.clients.claim()
    })
  )
})

// Fetch event - serve from cache, fallback to network
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url)
  
  // CRITICAL: Never intercept ANY requests - let browser handle everything
  // This prevents caching issues that break the website
  // Only intercept static assets if explicitly needed
  
  // NEVER intercept:
  // - Supabase requests
  // - API requests
  // - HTML files (always fetch fresh)
  // - JavaScript files (always fetch fresh to avoid stale code)
  if (url.hostname.includes('supabase.co') || 
      url.hostname.includes('supabase') ||
      url.pathname.includes('/rest/v1/') ||
      url.pathname.includes('/auth/v1/') ||
      url.pathname.includes('/storage/v1/') ||
      url.pathname.includes('/realtime/v1/') ||
      url.pathname.startsWith('/api/') ||
      url.pathname.endsWith('.html') ||
      url.pathname.endsWith('.js') ||
      url.pathname.endsWith('.mjs') ||
      url.pathname.includes('/src/') ||
      url.pathname.includes('/assets/')) {
    return // Don't intercept - let browser handle normally
  }
  
  // Skip non-GET requests - let browser handle normally
  if (event.request.method !== 'GET') {
    return
  }

  // Skip cross-origin requests - let browser handle normally
  if (!event.request.url.startsWith(self.location.origin)) {
    return
  }

  // Skip API and Supabase requests - let browser handle normally (don't intercept)
  if (!shouldCache(event.request)) {
    return
  }

  // Only intercept requests we want to cache
  event.respondWith(
    caches.match(event.request)
      .then(async (cachedResponse) => {
        // Return cached version if available and not expired
        if (cachedResponse) {
          const cachedAt = cachedResponse.headers.get('sw-cached-at')
          if (cachedAt) {
            const age = Date.now() - parseInt(cachedAt)
            if (age < MAX_CACHE_AGE) {
              return cachedResponse
            }
            // Cache expired, remove it
            try {
              const cache = await caches.open(RUNTIME_CACHE)
              await cache.delete(event.request)
            } catch (err) {
              console.error('[Service Worker] Error deleting expired cache:', err)
            }
          } else {
            return cachedResponse
          }
        }

        // Otherwise fetch from network
        try {
          const response = await fetch(event.request)
          
          // Don't cache if not a valid response
          if (!response || response.status !== 200 || response.type !== 'basic') {
            return response
          }

          // Clone the response for caching
          const responseToCache = response.clone()
          
          // Cache the fetched response (async, don't block response)
          caches.open(RUNTIME_CACHE).then(async (cache) => {
            try {
              // Check cache size before adding
              const currentSize = await getCacheSize(RUNTIME_CACHE)
              const blob = await responseToCache.blob()
              const responseSize = blob.size
              
              // Clean old cache if needed
              if (currentSize + responseSize > MAX_CACHE_SIZE) {
                await cleanOldCache(RUNTIME_CACHE, MAX_CACHE_SIZE * 0.8)
              }
              
              // Only cache if still under limit
              const newSize = await getCacheSize(RUNTIME_CACHE)
              if (newSize + responseSize <= MAX_CACHE_SIZE) {
                // Add timestamp header for expiration tracking
                const headers = new Headers(responseToCache.headers)
                headers.set('sw-cached-at', Date.now().toString())
                const modifiedResponse = new Response(blob, {
                  status: responseToCache.status,
                  statusText: responseToCache.statusText,
                  headers: headers
                })
                await cache.put(event.request, modifiedResponse)
              } else {
                console.log('[Service Worker] Cache full, skipping:', event.request.url)
              }
            } catch (cacheErr) {
              console.error('[Service Worker] Error caching response:', cacheErr)
              // Don't fail the request if caching fails
            }
          }).catch((cacheErr) => {
            console.error('[Service Worker] Error opening cache:', cacheErr)
            // Don't fail the request if cache open fails
          })

          return response
        } catch (fetchErr) {
          console.error('[Service Worker] Fetch failed:', fetchErr)
          // If fetch fails, try to return cached version or offline page
          const fallbackCache = await caches.match(event.request)
          if (fallbackCache) {
            return fallbackCache
          }
          // If it's a document request, return offline page
          if (event.request.destination === 'document') {
            const offlinePage = await caches.match('/index.html')
            if (offlinePage) {
              return offlinePage
            }
          }
          // Last resort: return error response
          return new Response('Network error', {
            status: 408,
            statusText: 'Request Timeout'
          })
        }
      })
      .catch((err) => {
        console.error('[Service Worker] Cache match error:', err)
        // Fallback to network fetch
        return fetch(event.request).catch(() => {
          return new Response('Service unavailable', {
            status: 503,
            statusText: 'Service Unavailable'
          })
        })
      })
  )
})

