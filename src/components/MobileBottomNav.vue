<template>
  <nav class="mobile-bottom-nav" v-if="isMobile">
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
      to="/tournaments" 
      class="nav-item"
      :class="{ active: isActive('/tournaments') }"
    >
      <span class="nav-icon">🎯</span>
      <span class="nav-label">Calendar</span>
    </router-link>

    <router-link 
      to="/membership" 
      class="nav-item"
      :class="{ active: isActive('/membership') }"
    >
      <span class="nav-icon">💳</span>
      <span class="nav-label">Card</span>
    </router-link>

    <!-- Admin link - only for admins -->
    <router-link 
      v-if="authStore.isAdmin"
      to="/admin" 
      class="nav-item"
      :class="{ active: isActive('/admin') }"
    >
      <span class="nav-icon">👑</span>
      <span class="nav-label">Admin</span>
    </router-link>

    <router-link 
      to="/profile" 
      class="nav-item"
      :class="{ active: isActive('/profile') }"
    >
      <span class="nav-icon">👤</span>
      <span class="nav-label">Me</span>
    </router-link>
  </nav>
</template>

<script>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '../stores/authStore'

export default {
  name: 'MobileBottomNav',
  setup() {
    const route = useRoute()
    const authStore = useAuthStore()
    const isMobile = ref(false)

    const checkMobile = () => {
      isMobile.value = window.innerWidth <= 768
    }

    const isActive = (path) => {
      if (path === '/') {
        return route.path === '/'
      }
      return route.path.startsWith(path)
    }

    onMounted(() => {
      checkMobile()
      window.addEventListener('resize', checkMobile)
    })

    onUnmounted(() => {
      window.removeEventListener('resize', checkMobile)
    })

    return {
      isMobile,
      isActive,
      authStore
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
}

.nav-item:active {
  transform: scale(0.95);
}

.nav-icon {
  font-size: 24px;
  margin-bottom: 2px;
  transition: all 0.3s ease;
}

.nav-label {
  font-size: 11px;
  font-weight: 500;
  transition: all 0.3s ease;
  white-space: nowrap;
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

/* Safe area support for iPhone X and newer */
@supports (padding-bottom: env(safe-area-inset-bottom)) {
  .mobile-bottom-nav {
    padding-bottom: calc(8px + env(safe-area-inset-bottom));
  }
}
</style>

