<template>
  <div class="home-page">
    <!-- Trial Opening Announcement Banner -->
    <div class="trial-banner" v-if="showTrialBanner">
      <div class="trial-banner-content">
        <div class="trial-banner-icon">🎉</div>
        <div class="trial-banner-text">
          <strong>Trial Opening Now!</strong> Welcome to Joy Billiards NZ - New Zealand's first professional Heyball venue!
        </div>
        <div class="trial-banner-close" @click="hideTrialBanner">×</div>
      </div>
    </div>

    <!-- Hero Section -->
    <section class="hero-section">
      <div class="hero-background">
        <div class="hero-pattern"></div>
        <div class="hero-glow"></div>
      </div>
      <div class="hero-content">
        <div class="hero-badge">
          <span class="badge-icon">🎱</span>
          <span class="badge-text">Now Open - Trial Operation</span>
        </div>
        <h1 class="hero-title">
          Experience the Future of<br>
          <span class="hero-title-highlight">Heyball</span> in New Zealand
        </h1>
        <p class="hero-subtitle">
          Joy Billiards NZ is the <strong>first and only professional Heyball venue</strong> and the 
          <strong>exclusive official distributor of JOY Billiards</strong> in New Zealand.
        </p>
        <p class="hero-tagline">
          Premium, tournament-grade tables. Pro-level atmosphere. <strong>Now Open in Hamilton!</strong>
        </p>
        <div class="hero-actions">
          <router-link to="/tournaments" class="btn btn-primary btn-lg hero-btn-primary">
            🏆 View Tournaments
          </router-link>
          <router-link to="/leaderboard" class="btn btn-secondary btn-lg hero-btn-secondary">
            🏅 View Rankings
          </router-link>
          <router-link to="/membership" class="btn btn-outline btn-lg hero-btn-outline">
            💳 Explore Memberships
          </router-link>
        </div>
        <div class="hero-features">
          <div class="hero-feature-item">
            <span class="feature-check">✓</span>
            <span>Official JOY Distributor</span>
          </div>
          <div class="hero-feature-item">
            <span class="feature-check">✓</span>
            <span>Tournament-Grade Tables</span>
          </div>
          <div class="hero-feature-item">
            <span class="feature-check">✓</span>
            <span>Professional Environment</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Stats Section -->
    <section class="stats-section">
      <div class="stats-background">
        <div class="stats-pattern"></div>
        <div class="stats-glow stats-glow-top"></div>
        <div class="stats-glow stats-glow-bottom"></div>
      </div>
      <div class="stats-content">
        <div class="stats-header">
          <div class="stats-badge">
            <span class="badge-icon">📊</span>
            <span class="badge-text">Live Statistics Dashboard</span>
          </div>
          <h2 class="stats-title">
            Our <span class="title-highlight">Community</span> at a Glance
          </h2>
          <p class="stats-subtitle">
            Real-time statistics updated every 30 seconds
          </p>
        </div>
        
        <div class="stats-grid">
          <div class="stat-card stat-card-players">
            <div class="stat-card-shine"></div>
            <div class="stat-card-glow"></div>
            <div class="stat-icon">👥</div>
            <div class="stat-number">{{ stats.totalPlayers }}</div>
            <div class="stat-label">Registered Players</div>
            <div class="stat-badge-mini">Active</div>
          </div>
          <div class="stat-card stat-card-winners">
            <div class="stat-card-shine"></div>
            <div class="stat-card-glow"></div>
            <div class="stat-icon">🎯</div>
            <div class="stat-number">{{ stats.totalBreakAndRun }}</div>
            <div class="stat-label">Break and Run</div>
            <div class="stat-badge-mini">Perfect</div>
          </div>
          <div class="stat-card stat-card-tournaments">
            <div class="stat-card-shine"></div>
            <div class="stat-card-glow"></div>
            <div class="stat-icon">🏆</div>
            <div class="stat-number">{{ stats.totalTournaments }}</div>
            <div class="stat-label">Tournaments Held</div>
            <div class="stat-badge-mini">Events</div>
          </div>
          <div class="stat-card stat-card-matches">
            <div class="stat-card-shine"></div>
            <div class="stat-card-glow"></div>
            <div class="stat-icon">⚔️</div>
            <div class="stat-number">{{ stats.totalMatches }}</div>
            <div class="stat-label">Matches Played</div>
            <div class="stat-badge-mini">Games</div>
          </div>
        </div>
      </div>
    </section>

    <!-- Membership Preview Section -->
    <section class="membership-preview-section">
      <div class="membership-background">
        <div class="membership-pattern"></div>
        <div class="membership-glow membership-glow-center"></div>
      </div>
      <div class="membership-content">
        <div class="membership-header">
          <div class="membership-badge">
            <span class="badge-icon">💳</span>
            <span class="badge-text">Exclusive Member Benefits</span>
          </div>
          <h2 class="membership-title">
            Join Our <span class="title-highlight">Premium</span> Membership
          </h2>
          <p class="membership-subtitle">
            Unlock exclusive benefits, discounts, and VIP access to tournaments
          </p>
        </div>
        
        <div class="membership-tiers-preview">
        <router-link to="/membership" class="tier-preview-card tier-lite">
          <div class="tier-card-glow-effect"></div>
          <div class="tier-icon-wrapper">
            <div class="tier-icon">🎱</div>
          </div>
          <h3 class="tier-name">Lite</h3>
          <p class="tier-price">Free</p>
          <div class="tier-highlights">
            <p>✅ Free registration</p>
            <p>📋 Standard rates</p>
          </div>
          <div class="tier-arrow">→</div>
        </router-link>

        <router-link to="/membership" class="tier-preview-card tier-plus">
          <div class="tier-card-glow-effect"></div>
          <div class="tier-icon-wrapper">
            <div class="tier-icon">⭐</div>
          </div>
          <h3 class="tier-name">Plus</h3>
          <p class="tier-price">≥ $200 NZD</p>
          <div class="tier-highlights">
            <p>💰 Discounted rates</p>
            <p>🎁 +5% bonus</p>
          </div>
          <div class="tier-arrow">→</div>
        </router-link>

        <router-link to="/membership" class="tier-preview-card tier-pro">
          <div class="tier-card-glow-effect"></div>
          <div class="tier-icon-wrapper">
            <div class="tier-icon">💎</div>
          </div>
          <h3 class="tier-name">Pro</h3>
          <p class="tier-price">≥ $500 NZD</p>
          <div class="tier-highlights">
            <p>💰 Pro rates</p>
            <p>🎟️ Monthly voucher</p>
          </div>
          <div class="tier-arrow">→</div>
        </router-link>

        <router-link to="/membership" class="tier-preview-card tier-pro-max featured">
          <div class="tier-badge">🌟 VIP</div>
          <div class="tier-card-glow-effect"></div>
          <div class="tier-icon-wrapper">
            <div class="tier-icon">🌟</div>
          </div>
          <h3 class="tier-name">Pro Max</h3>
          <p class="tier-price">≥ $1000 NZD</p>
          <div class="tier-highlights">
            <p>👑 VIP access</p>
            <p>🎁 Gift box</p>
          </div>
          <div class="tier-arrow">→</div>
        </router-link>
      </div>

        <div class="membership-cta text-center">
          <router-link to="/membership" class="btn btn-primary btn-lg membership-detail-btn">
            📖 View Full Membership Details & Benefits
          </router-link>
          <p class="cta-hint">Compare all tiers, see pricing examples, and learn more about how it works</p>
        </div>
      </div>
    </section>

    <!-- Tournament System Features -->
    <section class="features-section">
      <div class="features-background">
        <div class="features-pattern"></div>
        <div class="features-glow features-glow-left"></div>
        <div class="features-glow features-glow-right"></div>
      </div>
      <div class="features-content">
        <div class="features-header">
          <div class="features-badge">
            <span class="badge-icon">⚡</span>
            <span class="badge-text">Powered by Advanced Technology</span>
          </div>
          <h2 class="features-title">
            🎯 Tournament System <span class="title-highlight">Features</span>
          </h2>
          <p class="features-subtitle">
            State-of-the-art tournament management with real-time tracking and automated workflows
          </p>
        </div>
        
        <div class="features-grid">
          <div class="feature-card feature-card-stats">
            <div class="feature-card-glow"></div>
            <div class="feature-icon-wrapper">
              <div class="feature-icon">📊</div>
            </div>
            <h3>Player Statistics</h3>
            <p>Track wins, losses, and performance metrics for all players with real-time updates and detailed analytics</p>
            <div class="feature-arrow">→</div>
          </div>
          
          <div class="feature-card feature-card-types">
            <div class="feature-card-glow"></div>
            <div class="feature-icon-wrapper">
              <div class="feature-icon">🎯</div>
            </div>
            <h3>Tournament Types</h3>
            <p>Single elimination, double elimination, round robin, and Swiss formats with automatic bracket generation</p>
            <div class="feature-arrow">→</div>
          </div>
          
          <div class="feature-card feature-card-schedule">
            <div class="feature-card-glow"></div>
            <div class="feature-icon-wrapper">
              <div class="feature-icon">📅</div>
            </div>
            <h3>Schedule Management</h3>
            <p>Automated match scheduling and real-time bracket updates for seamless tournament organization</p>
            <div class="feature-arrow">→</div>
          </div>
          
          <div class="feature-card feature-card-ranking">
            <div class="feature-card-glow"></div>
            <div class="feature-icon-wrapper">
              <div class="feature-icon">🏅</div>
            </div>
            <h3>Ranking System</h3>
            <p>9-tier ranking system with automatic level progression, monthly and annual leaderboards</p>
            <div class="feature-arrow">→</div>
          </div>
        </div>
      </div>
    </section>

    <!-- Visit Us & Hours Section -->
    <section class="contact-section">
      <div class="contact-background">
        <div class="contact-pattern"></div>
        <div class="contact-glow contact-glow-left"></div>
        <div class="contact-glow contact-glow-right"></div>
      </div>
      <div class="contact-content-wrapper">
        <div class="contact-header">
          <div class="contact-badge">
            <span class="badge-icon">📍</span>
            <span class="badge-text">Hamilton's Premier Billiards Venue</span>
          </div>
          <h2 class="contact-main-title">
            Visit <span class="title-highlight">Joy Billiards</span> NZ
          </h2>
          <p class="contact-main-subtitle">
            Experience world-class Heyball in the heart of Hamilton - <strong>Now Open for Trial Operation!</strong>
          </p>
        </div>
        
        <div class="contact-grid">
          <div class="contact-card contact-card-location">
            <div class="contact-card-glow"></div>
            <div class="contact-icon-wrapper">
              <div class="contact-icon">🏢</div>
            </div>
            <h3 class="contact-title">Location</h3>
            <div class="contact-info">
              <p class="location-text">88 Tristram Street</p>
              <p class="location-text">Hamilton Central</p>
              <p class="location-text">New Zealand</p>
            </div>
            <div class="contact-action">
              <button class="btn-contact btn-contact-primary" @click="openMaps">
                <span class="btn-icon">🗺️</span>
                <span>Get Directions</span>
              </button>
            </div>
          </div>

          <div class="contact-card contact-card-info">
            <div class="contact-card-glow"></div>
            <div class="contact-icon-wrapper">
              <div class="contact-icon">📞</div>
            </div>
            <h3 class="contact-title">Contact Us</h3>
            <div class="contact-info">
              <div class="contact-item">
                <span class="contact-label">Phone</span>
                <a href="tel:0221660688" class="contact-link">022 166 0688</a>
              </div>
              <div class="contact-item">
                <span class="contact-label">Email</span>
                <a href="mailto:info@joybilliards.co.nz" class="contact-link">info@joybilliards.co.nz</a>
              </div>
            </div>
          </div>

          <div class="contact-card contact-card-hours">
            <div class="contact-card-glow"></div>
            <div class="contact-icon-wrapper">
              <div class="contact-icon">⏰</div>
            </div>
            <h3 class="contact-title">Opening Hours</h3>
            <div class="contact-info">
              <div class="hours-list">
                <div class="hours-item">
                  <span class="hours-day">Mon - Thu</span>
                  <span class="hours-time">10:00 AM - 1:00 AM</span>
                </div>
                <div class="hours-item">
                  <span class="hours-day">Fri - Sat</span>
                  <span class="hours-time">10:00 AM - 2:00 AM</span>
                </div>
                <div class="hours-item hours-item-highlight">
                  <span class="hours-day">Sunday</span>
                  <span class="hours-time">10:00 AM - 1:00 AM</span>
                </div>
              </div>
            </div>
            <div class="hours-note">
              <span class="note-icon">✨</span>
              <span>Extended hours on weekends</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useStatsStore } from '../stores/statsStore'

export default {
  name: 'HomePage',
  setup() {
    const statsStore = useStatsStore()
    const lastRefreshTime = ref(new Date())
    const isRefreshing = ref(false)
    const showTrialBanner = ref(true)

    // Use computed properties to get reactive stats
    const stats = computed(() => ({
      totalPlayers: statsStore.totalPlayers,
      totalTournaments: statsStore.totalTournaments,
      totalMatches: statsStore.totalMatches,
      totalBreakAndRun: statsStore.totalBreakAndRun
    }))

    onMounted(async () => {
      // Initial fetch
      isRefreshing.value = true
      await statsStore.fetchStats()
      isRefreshing.value = false
      lastRefreshTime.value = new Date()

      // Start auto-refresh every 30 seconds
      statsStore.startAutoRefresh(30000)
    })

    onUnmounted(() => {
      // Stop auto-refresh when component is destroyed
      statsStore.stopAutoRefresh()
    })

    const openMaps = () => {
      const address = '88 Tristram Street, Hamilton Central, New Zealand'
      const url = `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(address)}`
      window.open(url, '_blank')
    }

    const manualRefresh = async () => {
      isRefreshing.value = true
      await statsStore.fetchStats()
      isRefreshing.value = false
      lastRefreshTime.value = new Date()
    }

    const formatLastRefresh = () => {
      const now = new Date()
      const diff = Math.floor((now - lastRefreshTime.value) / 1000)
      if (diff < 60) return `${diff}s ago`
      return `${Math.floor(diff / 60)}m ago`
    }

    const hideTrialBanner = () => {
      showTrialBanner.value = false
    }

    return {
      stats,
      openMaps,
      isRefreshing,
      lastRefreshTime,
      manualRefresh,
      formatLastRefresh,
      showTrialBanner,
      hideTrialBanner
    }
  }
}
</script>

<style scoped>
.home-page {
  max-width: 100%;
}

/* Trial Opening Banner */
.trial-banner {
  background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
  color: #1a1a2e;
  padding: 1rem 2rem;
  text-align: center;
  position: relative;
  box-shadow: 0 4px 12px rgba(255, 215, 0, 0.3);
  animation: banner-pulse 2s ease-in-out infinite;
}

@keyframes banner-pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.01); }
}

.trial-banner-content {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  max-width: 1200px;
  margin: 0 auto;
  position: relative;
}

.trial-banner-icon {
  font-size: 1.5rem;
  animation: bounce 1s ease-in-out infinite;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-5px); }
}

.trial-banner-text {
  font-size: 1.125rem;
  font-weight: 600;
  flex: 1;
}

.trial-banner-text strong {
  color: #1a1a2e;
  font-weight: 800;
}

.trial-banner-close {
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  font-size: 1.5rem;
  font-weight: bold;
  cursor: pointer;
  padding: 0.25rem 0.5rem;
  border-radius: 50%;
  transition: all 0.3s ease;
  background: rgba(26, 26, 46, 0.1);
}

.trial-banner-close:hover {
  background: rgba(26, 26, 46, 0.2);
  transform: translateY(-50%) scale(1.1);
}

@media (max-width: 768px) {
  .trial-banner {
    padding: 0.75rem 1rem;
  }
  
  .trial-banner-content {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .trial-banner-text {
    font-size: 1rem;
  }
  
  .trial-banner-close {
    position: static;
    transform: none;
    margin-top: 0.5rem;
  }
}

/* Hero Section */
.hero-section {
  position: relative;
  color: white;
  padding: 6rem 2rem;
  margin-bottom: 2rem;
  text-align: center;
  overflow: hidden;
  min-height: 600px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.hero-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #0a0a0a 0%, #1a1a2e 25%, #0f3460 50%, #16213e 75%, #0a0a0a 100%);
  z-index: 0;
}

.hero-pattern {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(circle at 25% 25%, rgba(102, 126, 234, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 75% 75%, rgba(78, 205, 196, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 50% 50%, rgba(255, 215, 0, 0.05) 0%, transparent 50%);
  animation: pattern-drift 20s ease-in-out infinite;
}

@keyframes pattern-drift {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(20px, 20px) scale(1.05); }
}

.hero-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 600px;
  height: 600px;
  background: radial-gradient(circle, rgba(102, 126, 234, 0.2) 0%, transparent 70%);
  filter: blur(60px);
  animation: glow-pulse 4s ease-in-out infinite;
}

@keyframes glow-pulse {
  0%, 100% { opacity: 0.5; transform: translate(-50%, -50%) scale(1); }
  50% { opacity: 0.8; transform: translate(-50%, -50%) scale(1.1); }
}

.hero-content {
  position: relative;
  z-index: 1;
  max-width: 900px;
  margin: 0 auto;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1.25rem;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 50px;
  margin-bottom: 2rem;
  font-size: 0.875rem;
  font-weight: 600;
  letter-spacing: 0.5px;
  animation: badge-float 3s ease-in-out infinite;
}

@keyframes badge-float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
}

.badge-icon {
  font-size: 1.125rem;
}

.badge-text {
  background: linear-gradient(90deg, #4ECDC4, #FFD700);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero-title {
  font-size: 3.75rem;
  font-weight: 800;
  margin-bottom: 1.5rem;
  line-height: 1.2;
  letter-spacing: -1px;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
  animation: title-fade-in 1s ease-out;
}

@keyframes title-fade-in {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.hero-title-highlight {
  background: linear-gradient(135deg, #FFD700 0%, #4ECDC4 50%, #667eea 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  display: inline-block;
  animation: gradient-shift 3s ease-in-out infinite;
  background-size: 200% 200%;
}

@keyframes gradient-shift {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

.hero-subtitle {
  font-size: 1.25rem;
  margin-bottom: 1rem;
  line-height: 1.8;
  color: rgba(255, 255, 255, 0.95);
  max-width: 800px;
  margin-left: auto;
  margin-right: auto;
}

.hero-subtitle strong {
  color: #4ECDC4;
  font-weight: 600;
}

.hero-tagline {
  font-size: 1.125rem;
  margin-bottom: 2.5rem;
  color: rgba(255, 255, 255, 0.8);
  font-style: italic;
  letter-spacing: 0.5px;
}

.hero-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
  margin-bottom: 3rem;
}

.hero-btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  padding: 1rem 2.5rem;
  font-size: 1.125rem;
  font-weight: 600;
  border-radius: 50px;
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
  transition: all 0.3s ease;
}

.hero-btn-primary:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 30px rgba(102, 126, 234, 0.6);
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
}

.hero-btn-secondary {
  background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
  border: none;
  padding: 1rem 2.5rem;
  font-size: 1.125rem;
  font-weight: 600;
  border-radius: 50px;
  color: #1a1a2e;
  box-shadow: 0 6px 20px rgba(255, 215, 0, 0.4);
  transition: all 0.3s ease;
}

.hero-btn-secondary:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 30px rgba(255, 215, 0, 0.6);
  background: linear-gradient(135deg, #FFA500 0%, #FFD700 100%);
}

.hero-btn-outline {
  background: transparent;
  border: 2px solid rgba(255, 255, 255, 0.5);
  padding: 1rem 2.5rem;
  font-size: 1.125rem;
  font-weight: 600;
  border-radius: 50px;
  color: white;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
}

.hero-btn-outline:hover {
  background: rgba(255, 255, 255, 0.1);
  border-color: white;
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(255, 255, 255, 0.2);
}

.hero-features {
  display: flex;
  gap: 2rem;
  justify-content: center;
  flex-wrap: wrap;
  margin-top: 3rem;
}

.hero-feature-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1rem;
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
}

.feature-check {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  background: linear-gradient(135deg, #4ECDC4, #45B7AF);
  border-radius: 50%;
  font-size: 0.875rem;
  font-weight: 700;
  color: #1a1a2e;
  box-shadow: 0 2px 8px rgba(78, 205, 196, 0.5);
}

/* Stats Section - Hero Style */
.stats-section {
  position: relative;
  margin-bottom: 4rem;
  padding: 6rem 2rem;
  overflow: hidden;
  min-height: 550px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stats-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 25%, #a8b8d8 50%, #c3cfe2 75%, #f5f7fa 100%);
  z-index: 0;
}

.stats-pattern {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(circle at 25% 25%, rgba(102, 126, 234, 0.08) 0%, transparent 50%),
    radial-gradient(circle at 75% 75%, rgba(78, 205, 196, 0.08) 0%, transparent 50%),
    radial-gradient(circle at 50% 50%, rgba(255, 215, 0, 0.05) 0%, transparent 50%);
  animation: pattern-drift 22s ease-in-out infinite;
}

.stats-glow {
  position: absolute;
  width: 600px;
  height: 600px;
  border-radius: 50%;
  filter: blur(100px);
  animation: glow-pulse 5.5s ease-in-out infinite;
}

.stats-glow-top {
  top: -10%;
  left: 50%;
  transform: translateX(-50%);
  background: radial-gradient(circle, rgba(102, 126, 234, 0.15) 0%, transparent 70%);
}

.stats-glow-bottom {
  bottom: -10%;
  left: 50%;
  transform: translateX(-50%);
  background: radial-gradient(circle, rgba(78, 205, 196, 0.15) 0%, transparent 70%);
  animation-delay: 2.75s;
}

.stats-content {
  position: relative;
  z-index: 1;
  max-width: 1200px;
  width: 100%;
}

.stats-header {
  text-align: center;
  margin-bottom: 4rem;
}

.stats-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1.5rem;
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(102, 126, 234, 0.3);
  border-radius: 50px;
  margin-bottom: 1.5rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: #667eea;
  letter-spacing: 0.5px;
  animation: badge-float 3s ease-in-out infinite;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

.stats-title {
  font-size: 3rem;
  font-weight: 800;
  color: #1a1a2e;
  margin-bottom: 1rem;
  line-height: 1.2;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.stats-title .title-highlight {
  background: linear-gradient(135deg, #667eea 0%, #4ECDC4 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: gradient-shift 3s ease-in-out infinite;
  background-size: 200% 200%;
}

.stats-subtitle {
  font-size: 1.125rem;
  color: #6c757d;
  font-style: italic;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin-top: 3rem;
}

.stat-card {
  background: white;
  padding: 2.5rem 2rem;
  border-radius: 20px;
  text-align: center;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
  transition: all 0.4s ease;
  position: relative;
  overflow: hidden;
  border: 2px solid transparent;
}

.stat-card-shine {
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: linear-gradient(
    45deg,
    transparent 30%,
    rgba(255, 255, 255, 0.3) 50%,
    transparent 70%
  );
  transform: translateX(-100%) translateY(-100%) rotate(45deg);
  transition: transform 0.6s ease;
}

.stat-card:hover .stat-card-shine {
  transform: translateX(100%) translateY(100%) rotate(45deg);
}

.stat-card-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 150px;
  height: 150px;
  border-radius: 50%;
  opacity: 0;
  filter: blur(40px);
  transition: opacity 0.4s ease;
}

.stat-card:hover {
  transform: translateY(-12px) scale(1.03);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
}

.stat-card:hover .stat-card-glow {
  opacity: 0.6;
}

/* Stat card individual colors */
.stat-card-players {
  background: linear-gradient(135deg, #E3F2FD 0%, #E8EAF6 100%);
  border-color: #2196F3;
}

.stat-card-players .stat-card-glow {
  background: radial-gradient(circle, rgba(33, 150, 243, 0.5) 0%, transparent 70%);
}

.stat-card-players:hover {
  border-color: #1976D2;
  box-shadow: 0 20px 40px rgba(33, 150, 243, 0.3);
}

.stat-card-players .stat-icon {
  animation: float-gentle 3s ease-in-out infinite;
  filter: drop-shadow(0 4px 8px rgba(33, 150, 243, 0.6));
}

.stat-card-players .stat-number {
  background: linear-gradient(135deg, #2196F3 0%, #3F51B5 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-card-players .stat-label {
  color: #1565C0;
  font-weight: 600;
}

.stat-card-winners {
  background: linear-gradient(135deg, #FFF9E6 0%, #FFFBF0 100%);
  border-color: #FFD700;
}

.stat-card-winners .stat-card-glow {
  background: radial-gradient(circle, rgba(255, 215, 0, 0.5) 0%, transparent 70%);
}

.stat-card-winners:hover {
  border-color: #FFA500;
  box-shadow: 0 20px 40px rgba(255, 215, 0, 0.4);
}

.stat-card-winners .stat-icon {
  animation: trophy-pulse 2s ease-in-out infinite;
  filter: drop-shadow(0 4px 8px rgba(255, 215, 0, 0.6));
}

.stat-card-winners .stat-number {
  background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-card-winners .stat-label {
  color: #B8860B;
  font-weight: 600;
}

.stat-card-tournaments {
  background: linear-gradient(135deg, #F3E5F5 0%, #EDE7F6 100%);
  border-color: #9C27B0;
}

.stat-card-tournaments .stat-card-glow {
  background: radial-gradient(circle, rgba(156, 39, 176, 0.5) 0%, transparent 70%);
}

.stat-card-tournaments:hover {
  border-color: #7B1FA2;
  box-shadow: 0 20px 40px rgba(156, 39, 176, 0.3);
}

.stat-card-tournaments .stat-icon {
  animation: bounce-subtle 2.5s ease-in-out infinite;
  filter: drop-shadow(0 4px 8px rgba(156, 39, 176, 0.6));
}

.stat-card-tournaments .stat-number {
  background: linear-gradient(135deg, #9C27B0 0%, #673AB7 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-card-tournaments .stat-label {
  color: #6A1B9A;
  font-weight: 600;
}

.stat-card-matches {
  background: linear-gradient(135deg, #FFEBEE 0%, #FCE4EC 100%);
  border-color: #F44336;
}

.stat-card-matches .stat-card-glow {
  background: radial-gradient(circle, rgba(244, 67, 54, 0.5) 0%, transparent 70%);
}

.stat-card-matches:hover {
  border-color: #D32F2F;
  box-shadow: 0 20px 40px rgba(244, 67, 54, 0.3);
}

.stat-card-matches .stat-icon {
  animation: rotate-subtle 4s linear infinite;
  filter: drop-shadow(0 4px 8px rgba(244, 67, 54, 0.6));
}

.stat-card-matches .stat-number {
  background: linear-gradient(135deg, #F44336 0%, #E91E63 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-card-matches .stat-label {
  color: #C62828;
  font-weight: 600;
}

/* Stat card mini badges */
.stat-badge-mini {
  position: absolute;
  top: 1rem;
  right: 1rem;
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  opacity: 0;
  transform: translateY(-10px);
  transition: all 0.3s ease;
}

.stat-card:hover .stat-badge-mini {
  opacity: 1;
  transform: translateY(0);
}

.stat-card-players .stat-badge-mini {
  background: linear-gradient(135deg, #2196F3, #1976D2);
  color: white;
}

.stat-card-winners .stat-badge-mini {
  background: linear-gradient(135deg, #FFD700, #FFA500);
  color: #1a1a2e;
}

.stat-card-tournaments .stat-badge-mini {
  background: linear-gradient(135deg, #9C27B0, #7B1FA2);
  color: white;
}

.stat-card-matches .stat-badge-mini {
  background: linear-gradient(135deg, #F44336, #D32F2F);
  color: white;
}

/* Animations */
@keyframes float-gentle {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-6px);
  }
}

@keyframes trophy-pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}

@keyframes bounce-subtle {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-8px);
  }
}

@keyframes rotate-subtle {
  0% {
    transform: rotate(0deg);
  }
  25% {
    transform: rotate(-5deg);
  }
  75% {
    transform: rotate(5deg);
  }
  100% {
    transform: rotate(0deg);
  }
}

.stat-icon {
  font-size: 3.5rem;
  margin-bottom: 1rem;
  transition: transform 0.3s ease;
}

.stat-card:hover .stat-icon {
  transform: scale(1.15);
}

.stat-number {
  font-size: 3rem;
  font-weight: 700;
  color: #0066cc;
  margin-bottom: 0.5rem;
  line-height: 1;
}

.stat-label {
  font-size: 1rem;
  color: #6c757d;
  font-weight: 500;
  letter-spacing: 0.5px;
}

@media (max-width: 768px) {
  .hero-section {
    padding: 4rem 1.5rem;
    min-height: 500px;
  }
  
  .hero-title {
    font-size: 2.25rem;
    margin-bottom: 1.25rem;
  }
  
  .hero-subtitle {
    font-size: 1rem;
    padding: 0 1rem;
  }
  
  .hero-tagline {
    font-size: 1rem;
  }
  
  .hero-actions {
    flex-direction: column;
    gap: 0.75rem;
  }
  
  .hero-actions .btn {
    width: 100%;
    max-width: 300px;
  }
  
  .hero-features {
    flex-direction: column;
    gap: 1rem;
    margin-top: 2rem;
  }
  
  .stats-grid {
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
  }
  
  .stat-card {
    padding: 1.5rem;
  }
  
  .stat-icon {
    font-size: 2.5rem;
  }
  
  .stat-number {
    font-size: 2rem;
  }
}

/* Features Section - Hero Style */
.features-section {
  position: relative;
  padding: 6rem 2rem;
  margin-bottom: 4rem;
  overflow: hidden;
  min-height: 600px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.features-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 25%, #667eea 50%, #4a5568 75%, #667eea 100%);
  z-index: 0;
}

.features-pattern {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(circle at 20% 30%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 80% 70%, rgba(78, 205, 196, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 50% 50%, rgba(255, 215, 0, 0.05) 0%, transparent 50%);
  animation: pattern-drift 25s ease-in-out infinite;
}

.features-glow {
  position: absolute;
  width: 500px;
  height: 500px;
  border-radius: 50%;
  filter: blur(80px);
  animation: glow-pulse 5s ease-in-out infinite;
}

.features-glow-left {
  top: 20%;
  left: 10%;
  background: radial-gradient(circle, rgba(78, 205, 196, 0.3) 0%, transparent 70%);
}

.features-glow-right {
  bottom: 20%;
  right: 10%;
  background: radial-gradient(circle, rgba(255, 215, 0, 0.3) 0%, transparent 70%);
  animation-delay: 2.5s;
}

.features-content {
  position: relative;
  z-index: 1;
  max-width: 1200px;
  width: 100%;
}

.features-header {
  text-align: center;
  margin-bottom: 4rem;
}

.features-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1.5rem;
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 50px;
  margin-bottom: 1.5rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: white;
  letter-spacing: 0.5px;
  animation: badge-float 3s ease-in-out infinite;
}

.features-title {
  font-size: 3rem;
  font-weight: 800;
  color: white;
  margin-bottom: 1rem;
  line-height: 1.2;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
}

.features-title .title-highlight {
  background: linear-gradient(135deg, #FFD700 0%, #4ECDC4 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: gradient-shift 3s ease-in-out infinite;
  background-size: 200% 200%;
}

.features-subtitle {
  font-size: 1.125rem;
  color: rgba(255, 255, 255, 0.9);
  max-width: 700px;
  margin: 0 auto;
  line-height: 1.7;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 2rem;
  margin-top: 3rem;
}

.feature-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  padding: 2.5rem 2rem;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  text-align: center;
  transition: all 0.4s ease;
  position: relative;
  overflow: hidden;
}

.feature-card-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 200px;
  height: 200px;
  border-radius: 50%;
  opacity: 0;
  transition: opacity 0.4s ease;
}

.feature-card-stats .feature-card-glow {
  background: radial-gradient(circle, rgba(33, 150, 243, 0.4) 0%, transparent 70%);
}

.feature-card-types .feature-card-glow {
  background: radial-gradient(circle, rgba(156, 39, 176, 0.4) 0%, transparent 70%);
}

.feature-card-schedule .feature-card-glow {
  background: radial-gradient(circle, rgba(78, 205, 196, 0.4) 0%, transparent 70%);
}

.feature-card-ranking .feature-card-glow {
  background: radial-gradient(circle, rgba(255, 215, 0, 0.4) 0%, transparent 70%);
}

.feature-card:hover {
  transform: translateY(-10px) scale(1.02);
  background: rgba(255, 255, 255, 0.15);
  border-color: rgba(255, 255, 255, 0.5);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
}

.feature-card:hover .feature-card-glow {
  opacity: 1;
}

.feature-icon-wrapper {
  position: relative;
  margin-bottom: 1.5rem;
}

.feature-icon {
  font-size: 4rem;
  transition: all 0.4s ease;
  display: inline-block;
  filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.3));
}

.feature-card:hover .feature-icon {
  transform: scale(1.2) rotate(10deg);
}

.feature-card h3 {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 1rem;
  color: white;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.feature-card p {
  color: rgba(255, 255, 255, 0.85);
  line-height: 1.7;
  font-size: 0.9375rem;
  margin-bottom: 1.5rem;
}

.feature-arrow {
  color: rgba(255, 255, 255, 0.5);
  font-size: 1.5rem;
  font-weight: 300;
  transition: all 0.3s ease;
}

.feature-card:hover .feature-arrow {
  color: #4ECDC4;
  transform: translateX(5px);
}

/* Contact Section - Hero Style */
.contact-section {
  position: relative;
  margin-bottom: 2rem;
  padding: 6rem 2rem;
  overflow: hidden;
  min-height: 600px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.contact-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #0a0a0a 0%, #1a1a2e 25%, #16213e 50%, #0f3460 75%, #0a0a0a 100%);
  z-index: 0;
}

.contact-pattern {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(circle at 30% 40%, rgba(78, 205, 196, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 70% 60%, rgba(102, 126, 234, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 50% 50%, rgba(255, 215, 0, 0.05) 0%, transparent 50%);
  animation: pattern-drift 30s ease-in-out infinite reverse;
}

.contact-glow {
  position: absolute;
  width: 500px;
  height: 500px;
  border-radius: 50%;
  filter: blur(80px);
  animation: glow-pulse 6s ease-in-out infinite;
}

.contact-glow-left {
  top: 30%;
  left: 15%;
  background: radial-gradient(circle, rgba(78, 205, 196, 0.25) 0%, transparent 70%);
}

.contact-glow-right {
  bottom: 30%;
  right: 15%;
  background: radial-gradient(circle, rgba(102, 126, 234, 0.25) 0%, transparent 70%);
  animation-delay: 3s;
}

.contact-content-wrapper {
  position: relative;
  z-index: 1;
  max-width: 1200px;
  width: 100%;
}

.contact-header {
  text-align: center;
  margin-bottom: 4rem;
}

.contact-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1.5rem;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 50px;
  margin-bottom: 1.5rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: white;
  letter-spacing: 0.5px;
  animation: badge-float 3s ease-in-out infinite;
}

.contact-main-title {
  font-size: 3rem;
  font-weight: 800;
  color: white;
  margin-bottom: 1rem;
  line-height: 1.2;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.contact-main-title .title-highlight {
  background: linear-gradient(135deg, #4ECDC4 0%, #FFD700 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: gradient-shift 3s ease-in-out infinite;
  background-size: 200% 200%;
}

.contact-main-subtitle {
  font-size: 1.125rem;
  color: rgba(255, 255, 255, 0.85);
  margin-bottom: 2rem;
}

.contact-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin-top: 3rem;
}

.contact-card {
  background: rgba(255, 255, 255, 0.08);
  backdrop-filter: blur(15px);
  padding: 3rem 2.5rem;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.15);
  transition: all 0.4s ease;
  position: relative;
  overflow: hidden;
}

.contact-card-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 250px;
  height: 250px;
  border-radius: 50%;
  opacity: 0;
  transition: opacity 0.4s ease;
}

.contact-card-location .contact-card-glow {
  background: radial-gradient(circle, rgba(78, 205, 196, 0.3) 0%, transparent 70%);
}

.contact-card-info .contact-card-glow {
  background: radial-gradient(circle, rgba(102, 126, 234, 0.3) 0%, transparent 70%);
}

.contact-card-hours .contact-card-glow {
  background: radial-gradient(circle, rgba(255, 215, 0, 0.3) 0%, transparent 70%);
}

.contact-card:hover {
  transform: translateY(-10px) scale(1.02);
  background: rgba(255, 255, 255, 0.12);
  border-color: rgba(255, 255, 255, 0.4);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
}

.contact-card:hover .contact-card-glow {
  opacity: 1;
}

.contact-icon-wrapper {
  position: relative;
  margin-bottom: 1.5rem;
}

.contact-icon {
  font-size: 4rem;
  text-align: center;
  transition: all 0.4s ease;
  display: inline-block;
  filter: drop-shadow(0 4px 12px rgba(0, 0, 0, 0.4));
}

.contact-card:hover .contact-icon {
  transform: scale(1.2) rotate(-10deg);
}

.contact-title {
  font-size: 1.625rem;
  font-weight: 700;
  text-align: center;
  margin-bottom: 2rem;
  color: white;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.contact-info {
  text-align: center;
}

.location-text {
  font-size: 1.125rem;
  line-height: 1.8;
  margin: 0.5rem 0;
  color: rgba(255, 255, 255, 0.9);
}

.contact-item {
  margin: 1.5rem 0;
}

.contact-label {
  display: block;
  font-size: 0.875rem;
  color: rgba(255, 255, 255, 0.6);
  margin-bottom: 0.5rem;
  text-transform: uppercase;
  letter-spacing: 1px;
  font-weight: 600;
}

.contact-link {
  color: #4ECDC4;
  text-decoration: none;
  font-size: 1.375rem;
  font-weight: 700;
  transition: all 0.3s ease;
  display: inline-block;
  text-shadow: 0 2px 8px rgba(78, 205, 196, 0.5);
}

.contact-link:hover {
  color: #FFD700;
  transform: scale(1.08);
  text-shadow: 0 2px 12px rgba(255, 215, 0, 0.6);
}

.contact-action {
  margin-top: 2rem;
}

.btn-contact {
  display: inline-flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 2rem;
  border-radius: 50px;
  font-size: 1.0625rem;
  font-weight: 600;
  transition: all 0.3s ease;
  border: none;
  cursor: pointer;
}

.btn-contact-primary {
  background: linear-gradient(135deg, #4ECDC4 0%, #45B7AF 100%);
  color: white;
  box-shadow: 0 6px 20px rgba(78, 205, 196, 0.4);
}

.btn-contact-primary:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 30px rgba(78, 205, 196, 0.6);
  background: linear-gradient(135deg, #45B7AF 0%, #4ECDC4 100%);
}

.btn-icon {
  font-size: 1.25rem;
}

.hours-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.hours-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.25rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  border-left: 4px solid #4ECDC4;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.hours-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, rgba(78, 205, 196, 0.1) 0%, transparent 100%);
  transform: translateX(-100%);
  transition: transform 0.3s ease;
}

.hours-item:hover::before {
  transform: translateX(0);
}

.hours-item:hover {
  background: rgba(255, 255, 255, 0.12);
  border-left-color: #FFD700;
  transform: translateX(8px);
  box-shadow: 0 4px 12px rgba(78, 205, 196, 0.2);
}

.hours-item-highlight {
  background: rgba(255, 215, 0, 0.12);
  border-left-color: #FFD700;
  border-left-width: 5px;
}

.hours-item-highlight::before {
  background: linear-gradient(90deg, rgba(255, 215, 0, 0.15) 0%, transparent 100%);
}

.hours-day {
  font-weight: 700;
  font-size: 1.0625rem;
  color: rgba(255, 255, 255, 0.95);
  letter-spacing: 0.5px;
}

.hours-time {
  font-size: 1.0625rem;
  color: #4ECDC4;
  font-weight: 600;
  text-shadow: 0 2px 4px rgba(78, 205, 196, 0.3);
}

.hours-item-highlight .hours-time {
  color: #FFD700;
  text-shadow: 0 2px 4px rgba(255, 215, 0, 0.4);
}

.hours-note {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-top: 1.5rem;
  padding: 0.75rem;
  background: rgba(78, 205, 196, 0.1);
  border-radius: 10px;
  color: rgba(255, 255, 255, 0.8);
  font-size: 0.875rem;
  font-style: italic;
}

.note-icon {
  font-size: 1rem;
  animation: sparkle 2s ease-in-out infinite;
}

@keyframes sparkle {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

/* Membership Preview Section - Hero Style */
.membership-preview-section {
  position: relative;
  padding: 6rem 2rem;
  margin: 4rem 0;
  overflow: hidden;
  min-height: 600px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.membership-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 25%, #f093fb 50%, #764ba2 75%, #667eea 100%);
  z-index: 0;
}

.membership-pattern {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(circle at 30% 30%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 70% 70%, rgba(255, 215, 0, 0.08) 0%, transparent 50%),
    radial-gradient(circle at 50% 50%, rgba(78, 205, 196, 0.08) 0%, transparent 50%);
  animation: pattern-drift 28s ease-in-out infinite;
}

.membership-glow-center {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 800px;
  height: 800px;
  background: radial-gradient(circle, rgba(255, 215, 0, 0.2) 0%, transparent 70%);
  border-radius: 50%;
  filter: blur(100px);
  animation: glow-pulse 7s ease-in-out infinite;
}

.membership-content {
  position: relative;
  z-index: 1;
  max-width: 1200px;
  width: 100%;
}

.membership-header {
  text-align: center;
  margin-bottom: 4rem;
}

.membership-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1.5rem;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 50px;
  margin-bottom: 1.5rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: white;
  letter-spacing: 0.5px;
  animation: badge-float 3s ease-in-out infinite;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.membership-title {
  font-size: 3rem;
  font-weight: 800;
  color: white;
  margin-bottom: 1rem;
  line-height: 1.2;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
}

.membership-title .title-highlight {
  background: linear-gradient(135deg, #FFD700 0%, #4ECDC4 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: gradient-shift 3s ease-in-out infinite;
  background-size: 200% 200%;
}

.membership-subtitle {
  font-size: 1.125rem;
  color: rgba(255, 255, 255, 0.9);
  max-width: 700px;
  margin: 0 auto;
  line-height: 1.7;
}

.membership-tiers-preview {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 2rem;
  margin-bottom: 3rem;
}

.tier-preview-card {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(15px);
  border-radius: 20px;
  padding: 2.5rem 2rem;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  transition: all 0.4s ease;
  position: relative;
  text-align: center;
  cursor: pointer;
  text-decoration: none;
  color: inherit;
  display: block;
  border: 2px solid rgba(255, 255, 255, 0.25);
  overflow: hidden;
}

.tier-card-glow-effect {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 200px;
  height: 200px;
  border-radius: 50%;
  opacity: 0;
  filter: blur(50px);
  transition: opacity 0.4s ease;
}

.tier-lite .tier-card-glow-effect {
  background: radial-gradient(circle, rgba(168, 237, 234, 0.6) 0%, transparent 70%);
}

.tier-plus .tier-card-glow-effect {
  background: radial-gradient(circle, rgba(240, 147, 251, 0.6) 0%, transparent 70%);
}

.tier-pro .tier-card-glow-effect {
  background: radial-gradient(circle, rgba(102, 126, 234, 0.6) 0%, transparent 70%);
}

.tier-pro-max .tier-card-glow-effect {
  background: radial-gradient(circle, rgba(255, 107, 107, 0.6) 0%, transparent 70%);
}

.tier-preview-card:hover {
  transform: translateY(-12px) scale(1.04);
  box-shadow: 0 24px 48px rgba(0, 0, 0, 0.25);
  background: rgba(255, 255, 255, 0.25);
  border-color: rgba(255, 255, 255, 0.5);
}

.tier-preview-card:hover .tier-card-glow-effect {
  opacity: 1;
}

.tier-preview-card.featured {
  border: 2px solid rgba(255, 215, 0, 0.6);
  box-shadow: 0 12px 32px rgba(255, 215, 0, 0.3);
}

.tier-preview-card.featured:hover {
  border-color: #FFD700;
  box-shadow: 0 24px 48px rgba(255, 215, 0, 0.5);
}

.tier-preview-card .tier-badge {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: linear-gradient(135deg, #FFD700, #FFA500);
  color: #1a1a2e;
  padding: 0.3rem 0.75rem;
  border-radius: 15px;
  font-size: 0.75rem;
  font-weight: 700;
  animation: pulse-badge 2s infinite;
  box-shadow: 0 4px 12px rgba(255, 215, 0, 0.4);
}

@keyframes pulse-badge {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.08); }
}

.tier-icon-wrapper {
  position: relative;
  margin-bottom: 1rem;
}

.tier-preview-card .tier-icon {
  font-size: 3.5rem;
  margin-bottom: 0;
  transition: all 0.4s ease;
  filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.2));
}

.tier-preview-card:hover .tier-icon {
  transform: scale(1.15) rotate(10deg);
}

.tier-preview-card .tier-name {
  font-size: 1.625rem;
  font-weight: 800;
  margin-bottom: 0.75rem;
  color: white;
  text-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
}

.tier-preview-card .tier-price {
  font-size: 1.125rem;
  font-weight: 700;
  color: #FFD700;
  margin-bottom: 1.25rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid rgba(255, 255, 255, 0.2);
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.tier-highlights {
  text-align: left;
  padding-left: 0.5rem;
  margin-bottom: 1rem;
}

.tier-highlights p {
  margin: 0.625rem 0;
  font-size: 0.9375rem;
  color: rgba(255, 255, 255, 0.9);
  line-height: 1.7;
  font-weight: 500;
}

.tier-arrow {
  color: rgba(255, 255, 255, 0.4);
  font-size: 1.5rem;
  font-weight: 300;
  transition: all 0.3s ease;
  margin-top: 0.5rem;
}

.tier-preview-card:hover .tier-arrow {
  color: #FFD700;
  transform: translateX(8px);
}

.membership-cta {
  margin-top: 3rem;
}

.membership-detail-btn {
  font-size: 1.25rem;
  padding: 1.25rem 3rem;
  border-radius: 50px;
  background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
  border: 2px solid rgba(255, 255, 255, 0.5);
  color: #1a1a2e;
  text-decoration: none;
  display: inline-block;
  transition: all 0.4s ease;
  box-shadow: 0 8px 24px rgba(255, 215, 0, 0.5);
  font-weight: 700;
  letter-spacing: 0.5px;
}

.membership-detail-btn:hover {
  transform: translateY(-4px) scale(1.05);
  box-shadow: 0 12px 36px rgba(255, 215, 0, 0.7);
  background: linear-gradient(135deg, #FFA500 0%, #FFD700 100%);
  border-color: white;
}

.cta-hint {
  margin-top: 1.5rem;
  color: rgba(255, 255, 255, 0.8);
  font-size: 1rem;
  font-style: italic;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.features-section {
  margin-bottom: 2rem;
}

.section-title {
  font-size: 2rem;
  font-weight: 600;
  color: #1a1a2e;
}

.feature-card {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  text-align: center;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  height: 100%;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.feature-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
}

.feature-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.feature-card h3 {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
  color: #1a1a2e;
}

.feature-card p {
  color: #6c757d;
  line-height: 1.6;
}

@media (max-width: 768px) {
  .hero-title {
    font-size: 2rem;
  }

  .hero-subtitle {
    font-size: 1.25rem;
  }

  .hero-actions {
    flex-direction: column;
  }

  .hero-actions .btn {
    width: 100%;
  }

  .stat-number {
    font-size: 2rem;
  }
}
</style>


