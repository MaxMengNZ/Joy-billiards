import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '../views/HomePage.vue'
import { useAuthStore } from '../stores/authStore'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: HomePage,
    meta: { title: 'Joy Billiards Tournament System' }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/LoginPage.vue'),
    meta: { title: 'Sign In', requiresGuest: true }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('../views/RegisterPage.vue'),
    meta: { title: 'Sign Up', requiresGuest: true }
  },
  {
    path: '/auth/callback',
    name: 'EmailConfirm',
    component: () => import('../views/EmailConfirmPage.vue'),
    meta: { title: 'Email Confirmation' }
  },
  {
    path: '/admin',
    name: 'AdminDashboard',
    component: () => import('../views/AdminDashboard.vue'),
    meta: { title: 'Admin Dashboard', requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/players',
    name: 'Players',
    component: () => import('../views/PlayersPage.vue'),
    meta: { title: 'Players Management', requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/tournaments',
    name: 'Tournaments',
    component: () => import('../views/TournamentsPage.vue'),
    meta: { title: 'Tournaments' }
  },
  {
    path: '/tournaments/:id',
    name: 'TournamentDetail',
    component: () => import('../views/TournamentDetailPage.vue'),
    meta: { title: 'Tournament Details' },
    props: true
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('../views/ProfilePage.vue'),
    meta: { title: 'My Profile', requiresAuth: true }
  },
  {
    path: '/leaderboard',
    name: 'Leaderboard',
    component: () => import('../views/LeaderboardPage.vue'),
    meta: { title: 'Heyball Rankings' }
  },
  {
    path: '/membership',
    name: 'Membership',
    component: () => import('../views/MembershipPage.vue'),
    meta: { title: 'Membership Benefits' }
  },
  {
    path: '/error/:type?',
    name: 'Error',
    component: () => import('../views/ErrorPage.vue'),
    meta: { title: 'Error' },
    props: true
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('../views/ErrorPage.vue'),
    meta: { title: '404 - Page Not Found' },
    props: { errorType: '404' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    // Always scroll to top when navigating to a new page
    if (savedPosition) {
      return savedPosition
    } else {
      return { top: 0, behavior: 'smooth' }
    }
  }
})

router.beforeEach(async (to, from, next) => {
  document.title = `${to.meta.title} - Joy Billiards NZ` || 'Joy Billiards Tournament System'
  
  // Check if route requires authentication
  if (to.meta.requiresAuth) {
    const { useAuthStore } = await import('../stores/authStore')
    const authStore = useAuthStore()
    
    // If not logged in, redirect to home
    if (!authStore.user) {
      alert('Please login to access this page')
      next('/')
      return
    }
    
    // Check if route requires admin role
    if (to.meta.requiresAdmin) {
      // If not admin, redirect to home
      if (authStore.userRole !== 'admin') {
        alert('⛔ Access Denied: This page is only accessible to administrators')
        next('/')
        return
      }
    }
  }
  
  next()
})

export default router

