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
  // Skip non-GET requests
  if (event.request.method !== 'GET') {
    return
  }

  // Skip cross-origin requests
  if (!event.request.url.startsWith(self.location.origin)) {
    return
  }

  // Skip API and Supabase requests (don't cache)
  if (!shouldCache(event.request)) {
    return // Let browser handle normally
  }

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
            const cache = await caches.open(RUNTIME_CACHE)
            await cache.delete(event.request)
          } else {
            return cachedResponse
          }
        }

        // Otherwise fetch from network
        return fetch(event.request)
          .then(async (response) => {
            // Don't cache if not a valid response
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response
            }

            // Clone the response and add timestamp header
            const responseToCache = response.clone()
            const headers = new Headers(responseToCache.headers)
            headers.set('sw-cached-at', Date.now().toString())
            const modifiedResponse = new Response(responseToCache.body, {
              status: responseToCache.status,
              statusText: responseToCache.statusText,
              headers: headers
            })

            // Cache the fetched response
            const cache = await caches.open(RUNTIME_CACHE)
            
            // Check cache size before adding
            const currentSize = await getCacheSize(RUNTIME_CACHE)
            const responseSize = (await responseToCache.blob()).size
            
            // Clean old cache if needed
            if (currentSize + responseSize > MAX_CACHE_SIZE) {
              await cleanOldCache(RUNTIME_CACHE, MAX_CACHE_SIZE * 0.8) // Keep at 80% of max
            }
            
            // Only cache if still under limit
            const newSize = await getCacheSize(RUNTIME_CACHE)
            if (newSize + responseSize <= MAX_CACHE_SIZE) {
              await cache.put(event.request, modifiedResponse)
            } else {
              console.log('[Service Worker] Cache full, skipping:', event.request.url)
            }

            return response
          })
          .catch(() => {
            // If fetch fails, return offline page if available
            if (event.request.destination === 'document') {
              return caches.match('/index.html')
            }
          })
      })
  )
})

