<template>
  <ErrorBoundary>
    <div id="app" class="app-container">
      <header class="app-header" v-if="!isAuthPage">
        <div class="header-content">
          <div class="logo-section">
            <h1 class="logo-title">🎱 Joy Billiards NZ</h1>
            <p class="logo-subtitle">Tournament Management System</p>
          </div>
          <nav class="main-nav">
            <router-link to="/" class="nav-link">Home</router-link>
            <router-link to="/membership" class="nav-link">💳 Membership</router-link>
            <router-link to="/leaderboard" class="nav-link">🏆 Rankings</router-link>
            <router-link to="/tournaments" class="nav-link">Tournaments</router-link>
            <router-link v-if="authStore.isAdmin" to="/players" class="nav-link">Players</router-link>
            <router-link v-if="authStore.isAdmin" to="/admin" class="nav-link">Admin</router-link>
            
            <!-- Auth buttons -->
            <div class="auth-nav">
              <template v-if="authStore.isAuthenticated">
                <router-link to="/profile" class="nav-link user-info">
                  👤 {{ authStore.userName }}
                  <span v-if="authStore.isAdmin" class="role-badge">👑</span>
                </router-link>
                <button class="nav-link btn-logout" @click="handleLogout">Logout</button>
              </template>
              <template v-else>
                <router-link to="/login" class="nav-link">Login</router-link>
                <router-link to="/register" class="nav-link btn-register">Sign Up</router-link>
              </template>
            </div>
          </nav>
        </div>
      </header>

      <!-- Announcement Bar (Below Header) -->
      <div class="announcement-bar" v-if="!isAuthPage">
        <div class="announcement-content">
          <span class="announcement-icon">🎱</span>
          <span class="announcement-text">
            <strong>COMING SOON</strong> — Late October 2025 | Hamilton Central
          </span>
          <span class="announcement-divider">·</span>
          <span class="announcement-cta">Join our community for updates</span>
        </div>
      </div>

      <main class="app-main">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </main>

      <footer class="app-footer">
        <div class="footer-content">
          <div class="contact-info">
            <h3>Joy Billiards New Zealand</h3>
            <p>📍 88 Tristram Street, Hamilton Central</p>
            <p>📞 <a href="tel:0221660688">022 166 0688</a></p>
          </div>
          <div class="footer-links">
            <p>&copy; {{ currentYear }} Joy Billiards NZ. All rights reserved.</p>
            <p class="connection-status" :class="{ connected: isConnected, disconnected: !isConnected }">
              {{ isConnected ? '🟢 Database Connected' : '🔴 Database Disconnected' }}
            </p>
          </div>
        </div>
      </footer>
    </div>
  </ErrorBoundary>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { testConnection } from './config/supabase'
import { useAuthStore } from './stores/authStore'
import ErrorBoundary from './components/ErrorBoundary.vue'
import { setupGlobalErrorHandler } from './utils/errorHandler'
import { ConnectionMonitor } from './utils/supabaseWithRetry'

export default {
  name: 'App',
  components: {
    ErrorBoundary
  },
  setup() {
    const route = useRoute()
    const router = useRouter()
    const authStore = useAuthStore()
    
    const isConnected = ref(false)
    const currentYear = computed(() => new Date().getFullYear())
    const isAuthPage = computed(() => {
      return route.path === '/login' || route.path === '/register'
    })

    onMounted(async () => {
      // Setup global error handler
      setupGlobalErrorHandler()
      
      // Initialize auth
      await authStore.initialize()
      
      // Test connection
      isConnected.value = await testConnection()
      
      // Start connection monitor
      const monitor = new ConnectionMonitor({
        interval: 30000, // Check every 30 seconds
        onStatusChange: (connected) => {
          isConnected.value = connected
        }
      })
      monitor.start()
    })

    const handleLogout = async () => {
      const confirm = window.confirm('Are you sure you want to logout?')
      if (confirm) {
        const result = await authStore.signOut()
        if (result.success) {
          router.push('/login')
        }
      }
    }

    return {
      authStore,
      isConnected,
      currentYear,
      isAuthPage,
      handleLogout
    }
  }
}
</script>

<style>
@import './assets/styles/main.css';
</style>

<style scoped>
/* Announcement Bar */
.announcement-bar {
  background: linear-gradient(90deg, #FFD700 0%, #FFA500 50%, #FFD700 100%);
  background-size: 200% 100%;
  padding: 0.875rem 2rem;
  text-align: center;
  box-shadow: 0 2px 8px rgba(255, 215, 0, 0.3);
  animation: announcement-shine 3s ease-in-out infinite;
}

@keyframes announcement-shine {
  0%, 100% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
}

.announcement-content {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  flex-wrap: wrap;
  font-size: 0.9375rem;
  color: #1a1a2e;
  font-weight: 500;
}

.announcement-icon {
  font-size: 1.25rem;
  animation: bounce-icon 2s ease-in-out infinite;
}

@keyframes bounce-icon {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-4px); }
}

.announcement-text strong {
  font-weight: 700;
  letter-spacing: 1px;
}

.announcement-divider {
  color: rgba(26, 26, 46, 0.5);
  font-weight: 300;
}

.announcement-cta {
  color: #1a1a2e;
  font-style: italic;
}

@media (max-width: 768px) {
  .announcement-bar {
    padding: 0.75rem 1rem;
  }
  
  .announcement-content {
    font-size: 0.8125rem;
    gap: 0.5rem;
  }
}
</style>

