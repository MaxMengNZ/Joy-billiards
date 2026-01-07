import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import App from './App.vue'
import './assets/styles/main.css'
import { logStorageReport, getStorageReport, clearAllCaches } from './utils/storageMonitor'

// Register Service Worker for PWA
// TEMPORARILY DISABLED to fix website loading issues
// Users need to clear Service Worker cache manually
if (false && 'serviceWorker' in navigator) {
  // Unregister all existing service workers first
  navigator.serviceWorker.getRegistrations().then(registrations => {
    registrations.forEach(registration => {
      registration.unregister()
      console.log('Unregistered Service Worker:', registration.scope)
    })
  })
  
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then((registration) => {
        console.log('✅ Service Worker registered:', registration.scope)
        
        // Check for updates every hour
        setInterval(() => {
          registration.update()
        }, 3600000) // 1 hour
      })
      .catch((error) => {
        console.warn('⚠️ Service Worker registration failed:', error)
      })
  })
}

// Auto-clear Service Worker cache on page load (temporary fix)
if ('serviceWorker' in navigator) {
  window.addEventListener('load', async () => {
    try {
      const registrations = await navigator.serviceWorker.getRegistrations()
      for (const registration of registrations) {
        await registration.unregister()
        console.log('✅ Cleared Service Worker:', registration.scope)
      }
      
      // Clear all caches
      const cacheNames = await caches.keys()
      await Promise.all(cacheNames.map(name => caches.delete(name)))
      console.log('✅ Cleared all caches')
    } catch (err) {
      console.warn('⚠️ Error clearing Service Worker:', err)
    }
  })
}

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.mount('#app')

// Add storage monitoring tools to window (for debugging)
if (import.meta.env.DEV) {
  window.checkStorage = async () => {
    console.log('📊 Checking storage usage...')
    return await logStorageReport()
  }
  
  window.getStorageReport = getStorageReport
  window.clearAllCaches = clearAllCaches
  
  console.log('💡 Storage tools available:')
  console.log('  - checkStorage() - View storage report in console')
  console.log('  - getStorageReport() - Get storage report as object')
  console.log('  - clearAllCaches() - Clear all Service Worker caches')
}


