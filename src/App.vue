<template>
  <ErrorBoundary>
    <div id="app" class="app-container">
      <header class="app-header" v-if="!isAuthPage">
        <div class="header-content">
          <div class="logo-section">
            <router-link to="/" class="logo-link">
              <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards NZ" class="logo-image">
            </router-link>
          </div>
          
          <!-- Mobile menu button -->
          <button class="mobile-menu-btn" @click="toggleMobileMenu" :class="{ active: isMobileMenuOpen }">
            <span class="hamburger-line"></span>
            <span class="hamburger-line"></span>
            <span class="hamburger-line"></span>
          </button>
          
          <!-- Desktop Navigation -->
          <nav class="main-nav desktop-nav">
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
          
          <!-- Mobile Navigation -->
          <nav class="main-nav mobile-nav" :class="{ open: isMobileMenuOpen }">
            <router-link to="/" class="nav-link" @click="closeMobileMenu">Home</router-link>
            <router-link to="/membership" class="nav-link" @click="closeMobileMenu">💳 Membership</router-link>
            <router-link to="/leaderboard" class="nav-link" @click="closeMobileMenu">🏆 Rankings</router-link>
            <router-link to="/tournaments" class="nav-link" @click="closeMobileMenu">Tournaments</router-link>
            <router-link v-if="authStore.isAdmin" to="/players" class="nav-link" @click="closeMobileMenu">Players</router-link>
            <router-link v-if="authStore.isAdmin" to="/admin" class="nav-link" @click="closeMobileMenu">Admin</router-link>
            
            <!-- Mobile Auth buttons -->
            <div class="auth-nav mobile-auth">
              <template v-if="authStore.isAuthenticated">
                <router-link to="/profile" class="nav-link user-info" @click="closeMobileMenu">
                  👤 {{ authStore.userName }}
                  <span v-if="authStore.isAdmin" class="role-badge">👑</span>
                </router-link>
                <button class="nav-link btn-logout" @click="handleLogout">Logout</button>
              </template>
              <template v-else>
                <router-link to="/login" class="nav-link" @click="closeMobileMenu">Login</router-link>
                <router-link to="/register" class="nav-link btn-register" @click="closeMobileMenu">Sign Up</router-link>
              </template>
            </div>
          </nav>
        </div>
      </header>

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
            
            <!-- Social Media Icons -->
            <div class="social-media-links">
              <a href="https://www.facebook.com/profile.php?id=61578291092113" target="_blank" rel="noopener noreferrer" class="social-icon facebook" title="Follow us on Facebook">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                </svg>
              </a>
              <a href="https://www.instagram.com/joybilliardsnz" target="_blank" rel="noopener noreferrer" class="social-icon instagram" title="Follow us on Instagram">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
                </svg>
              </a>
              <router-link to="/wechat" class="social-icon wechat" title="Follow us on WeChat">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M8.691 2.188C3.891 2.188 0 5.476 0 9.53c0 2.212 1.17 4.203 3.002 5.55a.59.59 0 0 1 .213.665l-.39 1.48c-.019.07-.048.141-.048.213 0 .163.13.295.29.295a.326.326 0 0 0 .167-.054l1.903-1.114a.864.864 0 0 1 .717-.098 10.16 10.16 0 0 0 2.837.403c.276 0 .543-.027.811-.05-.857-2.578.157-4.972 2.733-6.518C10.76 7.688 8.691 2.188 8.691 2.188zm-2.328 5.49c.42 0 .761.34.761.76 0 .42-.34.761-.76.761-.42 0-.761-.34-.761-.76 0-.42.34-.761.76-.761zm4.68 0c.42 0 .761.34.761.76 0 .42-.34.761-.761.761-.42 0-.761-.34-.761-.76 0-.42.34-.761.761-.761zm3.326 1.983c-4.028 0-7.268 2.682-7.268 5.99 0 1.852 1.018 3.513 2.59 4.64a.548.548 0 0 1 .195.615l-.333 1.288c-.014.061-.038.123-.038.185 0 .142.11.256.25.256a.29.29 0 0 0 .144-.047l1.635-.967a.752.752 0 0 1 .616-.085 8.846 8.846 0 0 0 2.209.342c4.028 0 7.268-2.683 7.268-5.99 0-3.308-3.24-5.99-7.268-5.99zm-2.772 3.993c.39 0 .707.317.707.707a.707.707 0 1 1-1.414 0c0-.39.317-.707.707-.707zm4.438 0c.39 0 .707.317.707.707a.707.707 0 1 1-1.414 0c0-.39.317-.707.707-.707z"/>
                </svg>
              </router-link>
              <a href="https://xhslink.com/m/2CwhEpZgtub" target="_blank" rel="noopener noreferrer" class="social-icon xiaohongshu" title="Follow us on 小红书">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 2C6.477 2 2 6.477 2 12s4.477 10 10 10 10-4.477 10-10S17.523 2 12 2zm3.5 13.5h-7v-7h7v7z"/>
                  <rect x="9" y="8.5" width="6" height="6" rx="1"/>
                </svg>
              </a>
            </div>
            
            <!-- Connection status hidden from users but still monitored in background -->
            <p class="connection-status" :class="{ connected: isConnected, disconnected: !isConnected }" style="display: none;">
              {{ isConnected ? '🟢 Database Connected' : '🔴 Database Disconnected' }}
            </p>
          </div>
        </div>
      </footer>

      <!-- Mobile Bottom Navigation -->
      <MobileBottomNav v-if="!isAuthPage" />
      
      <!-- Floating Social Media Button (Mobile Only) -->
      <TestFloatingButton v-if="!isAuthPage" />
    </div>
  </ErrorBoundary>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { testConnection } from './config/supabase'
import { useAuthStore } from './stores/authStore'
import ErrorBoundary from './components/ErrorBoundary.vue'
import MobileBottomNav from './components/MobileBottomNav.vue'
import TestFloatingButton from './components/TestFloatingButton.vue'
import { setupGlobalErrorHandler } from './utils/errorHandler'
import { ConnectionMonitor } from './utils/supabaseWithRetry'

export default {
  name: 'App',
  components: {
    ErrorBoundary,
    MobileBottomNav,
    TestFloatingButton
  },
  setup() {
    const route = useRoute()
    const router = useRouter()
    const authStore = useAuthStore()
    
    const isConnected = ref(false)
    const isMobileMenuOpen = ref(false)
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

    const toggleMobileMenu = () => {
      isMobileMenuOpen.value = !isMobileMenuOpen.value
    }

    const closeMobileMenu = () => {
      isMobileMenuOpen.value = false
    }

    const handleLogout = async () => {
      console.log('Logout button clicked')
      const userConfirmed = confirm('Are you sure you want to logout?')
      if (userConfirmed) {
        console.log('User confirmed logout')
        closeMobileMenu()
        
        try {
          console.log('Calling signOut...')
          const result = await authStore.signOut()
          console.log('SignOut result:', result)
        } catch (error) {
          console.error('Logout exception:', error)
        }
        
        // Always force redirect regardless of success/failure
        console.log('Forcing redirect to home...')
        window.location.href = '/'
      } else {
        console.log('User cancelled logout')
      }
    }

    return {
      authStore,
      isConnected,
      isMobileMenuOpen,
      currentYear,
      isAuthPage,
      toggleMobileMenu,
      closeMobileMenu,
      handleLogout
    }
  }
}
</script>

<style>
@import './assets/styles/main.css';
</style>

<style scoped>
/* Logo Link */
.logo-link {
  display: inline-block;
  cursor: pointer;
  transition: transform 0.2s ease, opacity 0.2s ease;
}

.logo-link:hover {
  transform: translateY(-2px);
  opacity: 0.9;
}

/* Social Media Links */
.social-media-links {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 16px;
  margin-top: 16px;
  margin-bottom: 8px;
}

.social-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: rgba(255, 255, 255, 0.1);
  color: white;
  transition: all 0.3s ease;
  text-decoration: none;
}

.social-icon:hover {
  transform: translateY(-4px) scale(1.1);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.social-icon.facebook:hover {
  background-color: #1877f2;
  color: white;
}

.social-icon.instagram:hover {
  background: linear-gradient(45deg, #f09433 0%, #e6683c 25%, #dc2743 50%, #cc2366 75%, #bc1888 100%);
  color: white;
}

.social-icon.wechat:hover {
  background-color: #09b83e;
  color: white;
}

.social-icon.xiaohongshu:hover {
  background-color: #ff2442;
  color: white;
}

.social-icon svg {
  width: 20px;
  height: 20px;
  transition: transform 0.3s ease;
}

.social-icon:hover svg {
  transform: scale(1.1);
}

/* Mobile Optimization for Social Icons */
@media (max-width: 768px) {
  .social-media-links {
    gap: 12px;
    margin-top: 12px;
  }
  
  .social-icon {
    width: 36px;
    height: 36px;
  }
  
  .social-icon svg {
    width: 18px;
    height: 18px;
  }
}

.logo-link:active {
  transform: translateY(0);
}

/* Logo Image */
.logo-image {
  height: 80px;
  width: auto;
  object-fit: contain;
  display: block;
  /* 白色背景，圆角，让黑色 Logo 清晰可见 */
  background: white;
  padding: 8px 16px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  transition: box-shadow 0.2s ease;
}

.logo-link:hover .logo-image {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25);
}

@media (max-width: 768px) {
  .logo-image {
    height: 60px;
    padding: 6px 12px;
  }
}

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

