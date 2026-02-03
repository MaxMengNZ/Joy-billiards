<template>
  <nav class="mobile-bottom-nav" v-if="isMobile">
    <!-- Core 5 Items -->
    <router-link 
      to="/" 
      class="nav-item"
      :class="{ active: isActive('/') }"
    >
      <span class="nav-icon">🏠</span>
      <span class="nav-label">Home</span>
    </router-link>

    <router-link 
      to="/leaderboard" 
      class="nav-item"
      :class="{ active: isActive('/leaderboard') }"
    >
      <span class="nav-icon">🏆</span>
      <span class="nav-label">Leader</span>
    </router-link>

    <router-link 
      to="/battle" 
      class="nav-item"
      :class="{ active: isActive('/battle') }"
    >
      <span class="nav-icon">⚔️</span>
      <span class="nav-label">Battle</span>
    </router-link>

    <router-link 
      to="/tournaments" 
      class="nav-item"
      :class="{ active: isActive('/tournaments') }"
    >
      <span class="nav-icon">🎯</span>
      <span class="nav-label">Calendar</span>
    </router-link>

    <!-- More Menu Button -->
    <button 
      class="nav-item nav-more"
      :class="{ active: showMoreMenu }"
      @click="toggleMoreMenu"
      @blur="closeMoreMenu"
    >
      <span class="nav-icon">⋮</span>
      <span class="nav-label">More</span>
    </button>

    <!-- More Menu Dropdown -->
    <div v-if="showMoreMenu" class="more-menu" @click.stop>
      <router-link 
        to="/membership" 
        class="more-menu-item"
        :class="{ active: isActive('/membership') }"
        @click="handleMoreNavClick('/membership')"
      >
        <span class="more-icon">💳</span>
        <span class="more-label">Membership</span>
      </router-link>

      <router-link 
        v-if="authStore.isAdmin"
        to="/admin" 
        class="more-menu-item"
        :class="{ active: isActive('/admin') }"
        @click="handleMoreNavClick('/admin')"
      >
        <span class="more-icon">👑</span>
        <span class="more-label">Admin</span>
      </router-link>

      <router-link 
        to="/profile" 
        class="more-menu-item"
        :class="{ active: isActive('/profile') }"
        @click="handleMoreNavClick('/profile')"
      >
        <span class="more-icon">👤</span>
        <span class="more-label">Profile</span>
      </router-link>
    </div>
  </nav>
</template>

<script>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/authStore'

export default {
  name: 'MobileBottomNav',
  setup() {
    const route = useRoute()
    const router = useRouter()
    const authStore = useAuthStore()
    const isMobile = ref(false)
    const showMoreMenu = ref(false)

    const checkMobile = () => {
      isMobile.value = window.innerWidth <= 768
    }

    const isActive = (path) => {
      if (path === '/') {
        return route.path === '/'
      }
      return route.path.startsWith(path)
    }

    const toggleMoreMenu = () => {
      showMoreMenu.value = !showMoreMenu.value
    }

    const closeMoreMenu = () => {
      // Delay to allow click events to process
      setTimeout(() => {
        showMoreMenu.value = false
      }, 200)
    }

    const handleMoreNavClick = async (path) => {
      showMoreMenu.value = false
      
      // For profile route, check if user is authenticated
      if (path === '/profile') {
        // Wait a bit for auth to initialize if needed
        if (!authStore.isAuthenticated) {
          // Give auth store a moment to initialize
          await new Promise(resolve => setTimeout(resolve, 100))
          
          if (!authStore.isAuthenticated) {
            console.log('Not authenticated, navigation will be handled by router guard')
            // Router guard will redirect to login
          }
        }
      }
      
      // Navigate to the path
      router.push(path)
    }

    // Close menu when route changes
    watch(() => route.path, () => {
      showMoreMenu.value = false
    })

    // Close menu when clicking outside
    let handleClickOutside = null

    onMounted(() => {
      checkMobile()
      window.addEventListener('resize', checkMobile)
      
      handleClickOutside = (e) => {
        if (!e.target.closest('.nav-more') && !e.target.closest('.more-menu')) {
          showMoreMenu.value = false
        }
      }
      
      document.addEventListener('click', handleClickOutside)
    })

    onUnmounted(() => {
      window.removeEventListener('resize', checkMobile)
      if (handleClickOutside) {
        document.removeEventListener('click', handleClickOutside)
      }
    })

    return {
      isMobile,
      isActive,
      authStore,
      showMoreMenu,
      toggleMoreMenu,
      closeMoreMenu,
      handleMoreNavClick
    }
  }
}
</script>

<style scoped>
.mobile-bottom-nav {
  display: none;
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(180deg, rgba(26, 26, 46, 0.95) 0%, rgba(26, 26, 46, 0.98) 100%);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-top: 1px solid rgba(102, 126, 234, 0.2);
  box-shadow: 0 -2px 20px rgba(0, 0, 0, 0.3);
  padding: 8px 0 calc(8px + env(safe-area-inset-bottom));
  z-index: 1000;
  display: flex;
  justify-content: space-around;
  align-items: center;
}

@media (max-width: 768px) {
  .mobile-bottom-nav {
    display: flex;
  }
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  color: rgba(255, 255, 255, 0.6);
  transition: all 0.3s ease;
  padding: 8px 12px;
  min-width: 56px;
  min-height: 56px;
  border-radius: 12px;
  position: relative;
  /* Mobile touch optimization */
  touch-action: manipulation;
  -webkit-tap-highlight-color: transparent;
  user-select: none;
  -webkit-user-select: none;
  cursor: pointer;
  /* Ensure clickable area */
  pointer-events: auto;
}

.nav-item:active {
  transform: scale(0.95);
}

.nav-icon {
  font-size: 24px;
  margin-bottom: 2px;
  transition: all 0.3s ease;
  pointer-events: none; /* Allow clicks to pass through to parent */
}

.nav-label {
  font-size: 11px;
  font-weight: 500;
  transition: all 0.3s ease;
  white-space: nowrap;
  pointer-events: none; /* Allow clicks to pass through to parent */
}

.nav-item.active {
  color: #ffffff;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.2) 0%, rgba(118, 75, 162, 0.2) 100%);
}

.nav-item.active .nav-icon {
  transform: scale(1.1);
  filter: drop-shadow(0 0 8px rgba(102, 126, 234, 0.6));
}

.nav-item.active .nav-label {
  font-weight: 700;
  color: #667eea;
}

/* Active indicator dot */
.nav-item.active::before {
  content: '';
  position: absolute;
  top: 4px;
  width: 4px;
  height: 4px;
  background: #667eea;
  border-radius: 50%;
  box-shadow: 0 0 8px rgba(102, 126, 234, 0.8);
}

/* Hover effect for desktop testing */
@media (hover: hover) {
  .nav-item:hover:not(.active) {
    color: rgba(255, 255, 255, 0.9);
    background: rgba(255, 255, 255, 0.05);
  }
}

/* More Menu Button */
.nav-more {
  background: none;
  border: none;
  cursor: pointer;
}

.nav-more.active {
  color: #ffffff;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.2) 0%, rgba(118, 75, 162, 0.2) 100%);
}

.nav-more.active .nav-icon {
  transform: scale(1.1);
  filter: drop-shadow(0 0 8px rgba(102, 126, 234, 0.6));
}

.nav-more.active .nav-label {
  font-weight: 700;
  color: #667eea;
}

/* More Menu Dropdown */
.more-menu {
  position: absolute;
  bottom: calc(100% + 12px);
  left: 50%;
  transform: translateX(-50%);
  background: linear-gradient(180deg, rgba(26, 26, 46, 0.98) 0%, rgba(26, 26, 46, 0.95) 100%);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(102, 126, 234, 0.3);
  border-radius: 16px;
  box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.4);
  padding: 8px;
  min-width: 160px;
  z-index: 1001;
  animation: slideUp 0.2s ease-out;
  white-space: nowrap;
}

/* Ensure menu doesn't go off screen on small devices */
@media (max-width: 360px) {
  .more-menu {
    left: auto;
    right: 8px;
    transform: none;
  }
  
  .more-menu::after {
    left: auto;
    right: 24px;
    transform: none;
  }
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateX(-50%) translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateX(-50%) translateY(0);
  }
}

.more-menu::after {
  content: '';
  position: absolute;
  bottom: -8px;
  left: 50%;
  transform: translateX(-50%);
  width: 0;
  height: 0;
  border-left: 8px solid transparent;
  border-right: 8px solid transparent;
  border-top: 8px solid rgba(26, 26, 46, 0.98);
}

.more-menu-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  color: rgba(255, 255, 255, 0.8);
  text-decoration: none;
  border-radius: 12px;
  transition: all 0.2s ease;
  font-size: 14px;
  font-weight: 500;
  white-space: nowrap;
}

.more-menu-item:hover {
  background: rgba(102, 126, 234, 0.2);
  color: #ffffff;
}

.more-menu-item.active {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.3) 0%, rgba(118, 75, 162, 0.3) 100%);
  color: #ffffff;
}

.more-icon {
  font-size: 20px;
  width: 24px;
  text-align: center;
}

.more-label {
  flex: 1;
}

/* Adjust nav item positioning for More button */
.nav-more {
  position: relative;
}

/* Safe area support for iPhone X and newer */
@supports (padding-bottom: env(safe-area-inset-bottom)) {
  .mobile-bottom-nav {
    padding-bottom: calc(8px + env(safe-area-inset-bottom));
  }
  
  .more-menu {
    bottom: calc(100% + 8px + env(safe-area-inset-bottom));
  }
}
</style>

