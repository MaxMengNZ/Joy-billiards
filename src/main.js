import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import App from './App.vue'
import './assets/styles/main.css'
import { logStorageReport, getStorageReport, clearAllCaches } from './utils/storageMonitor'

// Register Service Worker for PWA
if ('serviceWorker' in navigator) {
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


