<template>
  <div class="leaderboard-page">
    <!-- Loading Skeleton -->
    <SkeletonLeaderboard v-if="loading" />
    
    <!-- Content -->
    <template v-else>
      <!-- Hero Header with Dynamic Background -->
      <section class="leaderboard-hero">
        <div class="leaderboard-hero-background">
          <div class="leaderboard-hero-pattern"></div>
          <div class="leaderboard-hero-glow"></div>
        </div>
        <div class="leaderboard-hero-content">
          <div class="hero-badge">
            <span class="badge-icon">🏆</span>
            <span class="badge-text">Live Ranking System</span>
          </div>
          <h1 class="hero-title">
            Heyball Ranking <span class="title-highlight">Leaderboard</span>
          </h1>
          <p class="hero-subtitle">
            Compete, climb the ranks, and earn your place among the elite
          </p>
        </div>
      </section>

      <div class="leaderboard-content">

    <!-- Tabs for Monthly and Annual -->
    <div class="tabs">
      <button 
        class="tab-button"
        :class="{ active: activeTab === 'current' }"
        @click="activeTab = 'current'"
      >
        🔥 Current Season ({{ currentYear }})
      </button>
      <button 
        class="tab-button"
        :class="{ active: activeTab === 'monthly' }"
        @click="activeTab = 'monthly'"
      >
        📅 Monthly ({{ currentMonthName }} {{ currentYear }})
      </button>
      <button 
        class="tab-button"
        :class="{ active: activeTab === 'annual' }"
        @click="activeTab = 'annual'"
      >
        🏅 Annual
      </button>
    </div>

    <!-- Year Selector for Annual Tab -->
    <div v-if="activeTab === 'annual'" class="year-selector">
      <label class="year-label">Select Year:</label>
      <select v-model="selectedYear" @change="loadAnnualRankings" class="year-select">
        <option v-for="year in availableYears" :key="year" :value="year">
          {{ year }}
        </option>
      </select>
    </div>

    <!-- Leaderboard -->
    <div v-if="loading" class="loading">
      <div class="spinner"></div>
    </div>

    <div v-else class="leaderboard-container">
      <!-- Top 3 Podium - Always show structure -->
      <div class="podium">
        <div class="podium-item second">
          <div class="trophy">🥈</div>
          <div class="player-card" :class="{ 'empty-card': !topThree[1] }">
            <template v-if="topThree[1]">
              <div class="rank-badge-large" :class="`rank-${topThree[1].ranking_level}`">
                {{ formatRankBadge(topThree[1].ranking_level) }}
              </div>
              <h3>{{ topThree[1].name }}</h3>
              <p class="points">{{ getDisplayPoints(topThree[1]) }} pts</p>
            </template>
            <template v-else>
              <div class="empty-placeholder">
                <div class="empty-icon">🥈</div>
                <div class="empty-text">No Data</div>
              </div>
            </template>
          </div>
        </div>

        <div class="podium-item first">
          <div class="trophy">🏆</div>
          <div class="player-card champion" :class="{ 'empty-card': !topThree[0] }">
            <template v-if="topThree[0]">
              <div class="rank-badge-large" :class="`rank-${topThree[0].ranking_level}`">
                {{ formatRankBadge(topThree[0].ranking_level) }}
              </div>
              <h3>{{ topThree[0].name }}</h3>
              <p class="points">{{ getDisplayPoints(topThree[0]) }} pts</p>
            </template>
            <template v-else>
              <div class="empty-placeholder">
                <div class="empty-icon">🏆</div>
                <div class="empty-text">No Data</div>
              </div>
            </template>
          </div>
        </div>

        <div class="podium-item third">
          <div class="trophy">🥉</div>
          <div class="player-card" :class="{ 'empty-card': !topThree[2] }">
            <template v-if="topThree[2]">
              <div class="rank-badge-large" :class="`rank-${topThree[2].ranking_level}`">
                {{ formatRankBadge(topThree[2].ranking_level) }}
              </div>
              <h3>{{ topThree[2].name }}</h3>
              <p class="points">{{ getDisplayPoints(topThree[2]) }} pts</p>
            </template>
            <template v-else>
              <div class="empty-placeholder">
                <div class="empty-icon">🥉</div>
                <div class="empty-text">No Data</div>
              </div>
            </template>
          </div>
        </div>
      </div>

      <!-- Full Rankings List -->
      <div class="card mt-4">
        <div class="card-header">
          <h2 class="card-title">🎖️ Full Rankings</h2>
          <div class="season-info">
            <span>Season {{ currentYear }}</span>
          </div>
        </div>
        <div class="card-body">
          <div class="rankings-list">
            <div 
              v-for="(player, index) in rankedPlayers" 
              :key="player.id"
              class="player-rank-card"
              :class="[getRankClass(index + 1), `level-${player.ranking_level}`]"
              :style="{ animationDelay: `${index * 0.05}s` }"
            >
              <!-- Rank Number -->
              <div class="rank-number-section">
                <div class="rank-number" :class="getRankClass(index + 1)">
                  <span class="rank-text">{{ index + 1 }}</span>
                  <div v-if="index < 3" class="rank-crown">
                    <span v-if="index === 0">👑</span>
                    <span v-if="index === 1">🥈</span>
                    <span v-if="index === 2">🥉</span>
                  </div>
                </div>
              </div>

              <!-- Player Info -->
              <div class="player-main-info">
                <div class="player-name-section">
                  <div class="player-name">
                    {{ player.name }}
                    <span v-if="player.membership_level === 'pro_max'" class="member-badge pro-max">🌟</span>
                    <span v-else-if="player.membership_level === 'pro'" class="member-badge pro">💎</span>
                    <span v-else-if="player.membership_level === 'plus'" class="member-badge plus">⭐</span>
                  </div>
                  <div class="player-stats-mini">
                    <span class="stat-item">
                      <span class="stat-label">W/L:</span>
                      <span class="stat-value">{{ player.wins }}/{{ player.losses }}</span>
                    </span>
                    <span class="stat-item">
                      <span class="stat-label">Win Rate:</span>
                      <span class="stat-value">{{ calculateWinRate(player) }}%</span>
                    </span>
                    <span class="stat-item">
                      <span class="stat-label">Matches:</span>
                      <span class="stat-value">N/A</span>
                    </span>
                  </div>
                </div>
              </div>

              <!-- Rank Badge and Points -->
              <div class="player-rank-info">
                <div class="rank-badge-large" :class="`rank-${player.ranking_level}`">
                  <span class="badge-emoji">{{ formatRankBadge(player.ranking_level) }}</span>
                  <span class="badge-name">{{ formatRankName(player.ranking_level) }}</span>
                </div>
                <div class="points-section">
                  <div class="points-value">{{ getDisplayPoints(player) }}</div>
                  <div class="points-label">points</div>
                </div>
              </div>

              <!-- Progress Bar -->
              <div class="rank-progress">
                <div class="progress-bar">
                  <div 
                    class="progress-fill" 
                    :class="`rank-${player.ranking_level}`"
                    :style="{ width: `${calculateRankProgress(player)}%` }"
                  >
                    <span class="progress-label">{{ calculateRankProgress(player) }}%</span>
                  </div>
                </div>
                <div class="progress-info">
                  <span class="next-rank-label">{{ getNextRankLabel(player) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Rules Card -->
      <div class="card mt-4">
        <div class="card-header">
          <h2 class="card-title">📋 Weekly Tournament Point System</h2>
        </div>
        <div class="card-body">
          <!-- Ranking System - Enhanced -->
          <div class="ranking-system-section mb-4">
            <div class="ranking-system-header">
              <h3>📊 Ranking System</h3>
              <p class="ranking-subtitle">Climb the ladder, prove your skills</p>
            </div>
            <div class="ranking-levels-grid">
              <div 
                class="rank-card" 
                v-for="(rank, index) in rankingLevels" 
                :key="rank.level" 
                :class="`rank-${rank.level}`"
                :style="{ '--rank-index': index }"
              >
                <div class="rank-card-inner">
                  <div class="rank-badge-large">{{ rank.badge }}</div>
                  <div class="rank-info">
                    <div class="rank-name">{{ rank.name }}</div>
                    <div class="rank-points">{{ rank.points }} pts</div>
                  </div>
                  <div class="rank-glow"></div>
                </div>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col col-2">
              <h3>Points Allocation</h3>
              <ul class="rules-list">
                <li>🏆 Champion: <strong>+20 points</strong></li>
                <li>🥈 Runner-up: <strong>+15 points</strong></li>
                <li>🎯 Top 4: <strong>+10 points</strong></li>
                <li>⚔️ Top 8: <strong>+6 points</strong></li>
                <li>✅ Participation: <strong>+3 points</strong></li>
                <li>❌ 4 weeks inactive: <strong>-20 points</strong></li>
              </ul>
            </div>
            <div class="col col-2">
              <h3>Handicap Rules</h3>
              <table class="handicap-table">
                <thead>
                  <tr>
                    <th>Rank Gap</th>
                    <th>Frames</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>0-1 levels</td><td>0 frames</td></tr>
                  <tr><td>2-3 levels</td><td>1 frame</td></tr>
                  <tr><td>4-5 levels</td><td>2 frames</td></tr>
                  <tr><td>6+ levels</td><td>3 frames</td></tr>
                </tbody>
              </table>
            </div>
          </div>
          <div class="annual-reset-info mt-3">
            <p><strong>🔄 Annual Reset:</strong> Points reset at end of December. Your ranking level is preserved, and you start new season at that level's minimum points.</p>
          </div>
        </div>
      </div>
    </div>
    </div>
    </template>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../config/supabase'
import SkeletonLeaderboard from '../components/skeleton/SkeletonLeaderboard.vue'

export default {
  name: 'LeaderboardPage',
  components: {
    SkeletonLeaderboard
  },
  setup() {
    const loading = ref(true)
    const players = ref([])
    const activeTab = ref('current')
    
    // Get NZ timezone date
    const nzDate = new Date(new Date().toLocaleString("en-US", { timeZone: "Pacific/Auckland" }))
    const currentYear = nzDate.getFullYear()
    const currentMonth = nzDate.getMonth() + 1
    
    const currentMonthName = nzDate.toLocaleString('en-US', { month: 'long', timeZone: 'Pacific/Auckland' })
    
    // For Annual Rankings - show current year and last year only
    const selectedYear = ref(currentYear)
    const availableYears = [currentYear, currentYear - 1]

    const rankingLevels = [
      { level: 'hall_of_fame', name: 'Hall of Fame', badge: '👑', points: '550+' },
      { level: 'pro_level', name: 'Pro Level', badge: '💎', points: '450-549' },
      { level: 'grand_master', name: 'Grand Master', badge: '🌟', points: '350-449' },
      { level: 'master', name: 'Master', badge: '⭐', points: '250-349' },
      { level: 'elite', name: 'Elite', badge: '🔷', points: '150-249' },
      { level: 'expert', name: 'Expert', badge: '🔶', points: '80-149' },
      { level: 'advance', name: 'Advance', badge: '🔺', points: '40-79' },
      { level: 'intermediate', name: 'Intermediate', badge: '🔸', points: '15-39' },
      { level: 'beginner', name: 'Beginner', badge: '⚪', points: '0-14' }
    ]

    const rankedPlayers = computed(() => {
      // Filter out players with 0 points for the current view
      const playersWithPoints = players.value.filter(player => {
        const points = getDisplayPoints(player)
        return points > 0
      })
      
      const sorted = playersWithPoints.sort((a, b) => {
        const aPoints = getDisplayPoints(a)
        const bPoints = getDisplayPoints(b)
        if (bPoints !== aPoints) return bPoints - aPoints
        return b.wins - a.wins
      })
      return sorted
    })

    const topThree = computed(() => {
      return rankedPlayers.value.slice(0, 3)
    })

    const getDisplayPoints = (player) => {
      switch (activeTab.value) {
        case 'monthly':
          return player.current_month_points || 0
        case 'annual':
          return player.selected_year_points || 0
        default:
          return player.current_year_points || 0
      }
    }

    const loadLeaderboard = async () => {
      loading.value = true
      try {
        // Get current NZ timezone date
        const nzDate = new Date(new Date().toLocaleString("en-US", { timeZone: "Pacific/Auckland" }))
        const currentYear = nzDate.getFullYear()
        const currentMonth = nzDate.getMonth() + 1 // JavaScript months are 0-indexed
        
        // Get all users
        const { data: usersData, error: usersError } = await supabase
          .from('users')
          .select('*')
        
        if (usersError) throw usersError
        
        // Get all point history
        const { data: pointHistory, error: pointError } = await supabase
          .from('point_history')
          .select('*')
        
        if (pointError) throw pointError
        
        // Calculate points for each user
        const playersWithPoints = usersData.map(user => {
          // Calculate current year total (for Current Season)
          const yearPoints = pointHistory
            .filter(p => p.user_id === user.id && p.year === currentYear)
            .reduce((sum, p) => sum + (p.points_change || 0), 0)
          
          // Calculate current month total (for Monthly)
          const monthPoints = pointHistory
            .filter(p => p.user_id === user.id && p.year === currentYear && p.month === currentMonth)
            .reduce((sum, p) => sum + (p.points_change || 0), 0)
          
          // Calculate selected year total (for Annual)
          const selectedYearPoints = pointHistory
            .filter(p => p.user_id === user.id && p.year === selectedYear.value)
            .reduce((sum, p) => sum + (p.points_change || 0), 0)
          
          return {
            ...user,
            current_year_points: yearPoints,
            current_month_points: monthPoints,
            selected_year_points: selectedYearPoints
          }
        })
        
        players.value = playersWithPoints
      } catch (err) {
        console.error('Error loading leaderboard:', err)
      } finally {
        loading.value = false
      }
    }

    const loadAnnualRankings = async () => {
      // Reload leaderboard when year selection changes
      await loadLeaderboard()
    }

    const formatRankBadge = (level) => {
      const rank = rankingLevels.find(r => r.level === level)
      return rank ? rank.badge : '⚪'
    }

    const formatRankName = (level) => {
      const rank = rankingLevels.find(r => r.level === level)
      return rank ? rank.name : 'Beginner'
    }

    const getRankClass = (position) => {
      if (position === 1) return 'rank-first'
      if (position === 2) return 'rank-second'
      if (position === 3) return 'rank-third'
      return ''
    }

    const calculateWinRate = (player) => {
      const total = player.wins + player.losses
      if (total === 0) return '0.0'
      return ((player.wins / total) * 100).toFixed(1)
    }

    const formatDate = (dateString) => {
      if (!dateString) return 'Never'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-NZ', {
        month: 'short',
        day: 'numeric'
      })
    }

    const calculateRankProgress = (player) => {
      const points = getDisplayPoints(player)
      const currentRank = rankingLevels.find(r => r.level === player.ranking_level)
      
      if (!currentRank) return 0
      
      // Parse points range
      const pointsRange = currentRank.points
      if (pointsRange.includes('+')) {
        // Max level, show 100%
        return 100
      }
      
      const [min, max] = pointsRange.split('-').map(p => parseInt(p))
      const progress = ((points - min) / (max - min + 1)) * 100
      return Math.min(Math.max(progress, 0), 100).toFixed(0)
    }

    const getNextRankLabel = (player) => {
      const points = getDisplayPoints(player)
      const currentRankIndex = rankingLevels.findIndex(r => r.level === player.ranking_level)
      
      if (currentRankIndex === 0) {
        return '🏆 Max Level Achieved!'
      }
      
      const nextRank = rankingLevels[currentRankIndex - 1]
      if (!nextRank) return 'Keep Going!'
      
      const nextRankPoints = parseInt(nextRank.points.split('-')[0])
      const pointsNeeded = nextRankPoints - points
      
      if (pointsNeeded <= 0) {
        return `🎉 Ready to advance to ${nextRank.name}!`
      }
      
      return `${pointsNeeded} pts to ${nextRank.name}`
    }

    onMounted(() => {
      loadLeaderboard()
    })

    return {
      loading,
      players,
      activeTab,
      currentYear,
      currentMonthName,
      selectedYear,
      availableYears,
      rankingLevels,
      rankedPlayers,
      topThree,
      getDisplayPoints,
      formatRankBadge,
      formatRankName,
      getRankClass,
      calculateWinRate,
      formatDate,
      calculateRankProgress,
      getNextRankLabel,
      loadAnnualRankings
    }
  }
}
</script>

<style scoped>
.leaderboard-page {
  max-width: 100%;
  margin: 0;
  padding: 0;
}

/* Leaderboard Hero Section */
.leaderboard-hero {
  position: relative;
  padding: 5rem 2rem 4rem;
  overflow: hidden;
  text-align: center;
  margin-bottom: 3rem;
}

.leaderboard-hero-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #FFD700 0%, #FFA500 25%, #FF6B6B 50%, #FFA500 75%, #FFD700 100%);
  z-index: 0;
}

.leaderboard-hero-pattern {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(circle at 20% 30%, rgba(255, 255, 255, 0.15) 0%, transparent 50%),
    radial-gradient(circle at 80% 70%, rgba(255, 107, 107, 0.15) 0%, transparent 50%),
    radial-gradient(circle at 50% 50%, rgba(78, 205, 196, 0.1) 0%, transparent 50%);
  animation: pattern-drift 18s ease-in-out infinite;
}

@keyframes pattern-drift {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(15px, 15px) scale(1.05); }
}

.leaderboard-hero-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 700px;
  height: 700px;
  background: radial-gradient(circle, rgba(255, 215, 0, 0.3) 0%, transparent 70%);
  filter: blur(80px);
  animation: glow-pulse 4.5s ease-in-out infinite;
}

@keyframes glow-pulse {
  0%, 100% { opacity: 0.6; transform: translate(-50%, -50%) scale(1); }
  50% { opacity: 0.9; transform: translate(-50%, -50%) scale(1.1); }
}

.leaderboard-hero-content {
  position: relative;
  z-index: 1;
  max-width: 800px;
  margin: 0 auto;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1.5rem;
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.4);
  border-radius: 50px;
  margin-bottom: 1.5rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: #1a1a2e;
  letter-spacing: 0.5px;
  animation: badge-float 3s ease-in-out infinite;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

@keyframes badge-float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
}

.badge-icon {
  font-size: 1.125rem;
}

.badge-text {
  font-weight: 700;
}

.hero-title {
  font-size: 3.5rem;
  font-weight: 800;
  color: #1a1a2e;
  margin-bottom: 1rem;
  line-height: 1.2;
  text-shadow: 0 4px 16px rgba(255, 215, 0, 0.5);
  animation: title-fade-in 1s ease-out;
}

@keyframes title-fade-in {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.title-highlight {
  background: linear-gradient(135deg, #FF6B6B 0%, #4ECDC4 50%, #667eea 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: gradient-shift 3s ease-in-out infinite;
  background-size: 200% 200%;
}

@keyframes gradient-shift {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

.hero-subtitle {
  font-size: 1.25rem;
  color: rgba(26, 26, 46, 0.85);
  font-weight: 500;
  line-height: 1.7;
  text-shadow: 0 2px 4px rgba(255, 255, 255, 0.5);
}

.leaderboard-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 2rem;
}

.page-header {
  text-align: center;
  margin-bottom: 2rem;
}

.page-header h1 {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--dark-color);
  margin-bottom: 0.5rem;
}

.subtitle {
  color: var(--text-secondary);
  font-size: 1.125rem;
}

/* Ranking Levels Display */
.ranking-info {
  margin-bottom: 2rem;
}

.ranking-system-section {
  padding-bottom: 1.5rem;
  border-bottom: 2px solid var(--border-color);
}

.ranking-system-section h3 {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--dark-color);
  margin-bottom: 1rem;
}

.ranking-levels {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 0.75rem;
}

.rank-item {
  padding: 0.75rem 1rem;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  background: linear-gradient(135deg, #f8f9fa, #e9ecef);
  border-left: 4px solid;
  transition: transform 0.3s ease;
}

.rank-item:hover {
  transform: translateX(4px);
}

.rank-beginner { border-color: #6c757d; }
.rank-intermediate { border-color: #17a2b8; }
.rank-advance { border-color: #28a745; }
.rank-expert { border-color: #ffc107; }
.rank-elite { border-color: #fd7e14; }
.rank-master { border-color: #e83e8c; }
.rank-grand_master { border-color: #6f42c1; }
.rank-pro_level { border-color: #dc3545; }
.rank-hall_of_fame { border-color: #ffd700; background: linear-gradient(135deg, #fff9e6, #ffe4b3); }

.rank-badge {
  font-size: 1.5rem;
}

.rank-name {
  flex: 1;
  font-weight: 500;
  font-size: 0.875rem;
}

.rank-points {
  font-weight: 600;
  color: var(--text-secondary);
  font-size: 0.875rem;
}

/* Tabs */
/* Tabs - Enhanced */
.tabs {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 3rem;
  flex-wrap: wrap;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  max-width: 800px;
  margin-left: auto;
  margin-right: auto;
}

.tab-button {
  padding: 1rem 2.5rem;
  border: 2px solid transparent;
  background: white;
  border-radius: 50px;
  font-size: 1.0625rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
  color: #6c757d;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.tab-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.2);
  color: #667eea;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(78, 205, 196, 0.05) 100%);
}

.tab-button.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: transparent;
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
  transform: translateY(-3px) scale(1.05);
}

/* Year Selector */
.year-selector {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 2rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
}

.year-label {
  font-size: 1rem;
  font-weight: 600;
  color: #1a1a2e;
}

.year-select {
  padding: 0.625rem 1.25rem;
  border: 2px solid #667eea;
  background: white;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: 600;
  color: #667eea;
  cursor: pointer;
  transition: all 0.3s ease;
  outline: none;
}

.year-select:hover {
  border-color: #764ba2;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

.year-select:focus {
  border-color: #764ba2;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

/* Podium - Enhanced */
.podium {
  display: flex;
  justify-content: center;
  align-items: flex-end;
  gap: 2rem;
  margin-bottom: 4rem;
  padding: 3rem 2rem;
  background: linear-gradient(135deg, rgba(255, 215, 0, 0.1) 0%, rgba(255, 255, 255, 0.5) 50%, rgba(255, 215, 0, 0.1) 100%);
  backdrop-filter: blur(10px);
  border-radius: 24px;
  border: 2px solid rgba(255, 215, 0, 0.3);
  box-shadow: 0 8px 32px rgba(255, 215, 0, 0.2);
  position: relative;
  overflow: hidden;
}

.podium::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at 50% 50%, rgba(255, 215, 0, 0.1) 0%, transparent 70%);
  animation: podium-glow 4s ease-in-out infinite;
}

@keyframes podium-glow {
  0%, 100% { opacity: 0.5; }
  50% { opacity: 1; }
}

.podium-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
  position: relative;
  z-index: 1;
}

.podium-item.first {
  order: 2;
  transform: translateY(-20px);
}

.podium-item.second {
  order: 1;
}

.podium-item.third {
  order: 3;
}

.trophy {
  font-size: 4rem;
  animation: trophy-bounce 2s ease-in-out infinite;
  filter: drop-shadow(0 4px 12px rgba(255, 215, 0, 0.6));
  position: relative;
}

.podium-item.first .trophy {
  font-size: 5rem;
  animation: trophy-rotate 3s ease-in-out infinite;
}

@keyframes trophy-bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-15px); }
}

@keyframes trophy-rotate {
  0%, 100% { transform: translateY(0) rotate(0deg) scale(1); }
  25% { transform: translateY(-10px) rotate(-5deg) scale(1.05); }
  50% { transform: translateY(-20px) rotate(0deg) scale(1.1); }
  75% { transform: translateY(-10px) rotate(5deg) scale(1.05); }
}

.player-card {
  background: white;
  padding: 2rem 1.75rem;
  border-radius: 20px;
  text-align: center;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  min-width: 220px;
  position: relative;
  overflow: visible;
  border: 2px solid transparent;
  transition: all 0.4s ease;
}

.player-card::before {
  content: '';
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
  z-index: 1;
}

.player-card:hover::before {
  transform: translateX(100%) translateY(100%) rotate(45deg);
}

.player-card:hover {
  transform: translateY(-8px) scale(1.05);
  box-shadow: 0 16px 40px rgba(0, 0, 0, 0.2);
}

.player-card.champion {
  background: linear-gradient(135deg, #FFF9E6 0%, #FFFBF0 100%);
  box-shadow: 0 12px 32px rgba(255, 215, 0, 0.4);
  border: 3px solid #FFD700;
  animation: champion-pulse 2s ease-in-out infinite;
}

@keyframes champion-pulse {
  0%, 100% {
    box-shadow: 0 12px 32px rgba(255, 215, 0, 0.4);
    border-color: #FFD700;
  }
  50% {
    box-shadow: 0 16px 48px rgba(255, 215, 0, 0.6);
    border-color: #FFA500;
  }
}

.player-card.champion:hover {
  animation: none;
  box-shadow: 0 20px 60px rgba(255, 215, 0, 0.7) !important;
}

.player-card h3 {
  font-size: 1.25rem;
  margin: 0.5rem 0;
  color: var(--dark-color);
}

.player-card .points {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--primary-color);
  margin: 0;
}


.rank-badge-large {
  font-size: 2rem;
  padding: 0.5rem;
}

/* Empty Card State */
.player-card.empty-card {
  background: rgba(255, 255, 255, 0.5);
  border: 2px dashed #dee2e6;
  opacity: 0.7;
}

.empty-placeholder {
  text-align: center;
  padding: 2rem 1rem;
}

.empty-icon {
  font-size: 3rem;
  opacity: 0.3;
  margin-bottom: 0.5rem;
}

.empty-text {
  font-size: 1rem;
  color: #6c757d;
  font-weight: 600;
}

/* Leaderboard Table */
.leaderboard-table {
  font-size: 0.9375rem;
}

.leaderboard-table tbody tr {
  transition: all 0.3s ease;
}

.leaderboard-table tbody tr:hover {
  background: rgba(0, 102, 204, 0.05);
  transform: translateX(4px);
}

.rank-position {
  display: inline-block;
  font-weight: 700;
  font-size: 1.125rem;
  min-width: 35px;
  text-align: center;
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
}

.rank-first {
  background: linear-gradient(135deg, #ffd700, #ffed4e);
  color: #8b6914;
}

.rank-second {
  background: linear-gradient(135deg, #c0c0c0, #e8e8e8);
  color: #4a4a4a;
}

.rank-third {
  background: linear-gradient(135deg, #cd7f32, #e6a157);
  color: #5c3a1a;
}

.player-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.member-badge {
  font-size: 1rem;
}

.rank-badge {
  display: inline-block;
  padding: 0.375rem 0.75rem;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.8125rem;
  white-space: nowrap;
}

.points-value {
  font-size: 1.125rem;
  color: var(--primary-color);
}

.season-info {
  padding: 0.5rem 1rem;
  background: var(--light-color);
  border-radius: 6px;
  font-weight: 500;
  color: var(--text-secondary);
}

/* Rules */
.rules-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.rules-list li {
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--border-color);
}

.rules-list li:last-child {
  border-bottom: none;
}

.handicap-table {
  width: 100%;
  font-size: 0.9375rem;
}

.handicap-table th,
.handicap-table td {
  padding: 0.5rem;
  text-align: left;
}

.annual-reset-info {
  padding: 1rem;
  background: rgba(255, 193, 7, 0.1);
  border-left: 4px solid var(--warning-color);
  border-radius: 6px;
}

/* Responsive */
@media (max-width: 768px) {
  .page-header h1 {
    font-size: 1.75rem;
  }

  .podium {
    flex-direction: column;
    align-items: center;
  }

  .podium-item {
    width: 100%;
    max-width: 250px;
  }

  .podium-item.first {
    order: 1;
  }
  
  .podium-item.second {
    order: 2;
  }
  
  .podium-item.third {
    order: 3;
  }

  .ranking-levels {
    grid-template-columns: 1fr;
  }

  .leaderboard-table {
    font-size: 0.8125rem;
  }

  .leaderboard-table th,
  .leaderboard-table td {
    padding: 0.5rem;
  }
}

/* New Rankings List Styles */
.rankings-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.player-rank-card {
  display: grid;
  grid-template-columns: auto 1fr auto auto;
  align-items: center;
  gap: 1.5rem;
  padding: 1.5rem;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-radius: 16px;
  border-left: 5px solid #dee2e6;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  transition: all 0.3s ease;
  animation: slideIn 0.5s ease backwards;
}

.player-rank-card:hover {
  transform: translateX(8px);
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
}

.player-rank-card.rank-first {
  border-left-color: #FFD700;
  background: linear-gradient(135deg, #FFF9E6 0%, #FFEDD5 100%);
}

.player-rank-card.rank-second {
  border-left-color: #C0C0C0;
  background: linear-gradient(135deg, #F0F4F8 0%, #E2E8F0 100%);
}

.player-rank-card.rank-third {
  border-left-color: #CD7F32;
  background: linear-gradient(135deg, #FEF3E2 0%, #FCE7CC 100%);
}

.player-rank-card.level-hall_of_fame { border-left-color: #FFD700; }
.player-rank-card.level-pro_level { border-left-color: #DC3545; }
.player-rank-card.level-grand_master { border-left-color: #6F42C1; }
.player-rank-card.level-master { border-left-color: #E83E8C; }
.player-rank-card.level-elite { border-left-color: #FD7E14; }
.player-rank-card.level-expert { border-left-color: #FFC107; }
.player-rank-card.level-advance { border-left-color: #28A745; }
.player-rank-card.level-intermediate { border-left-color: #17A2B8; }
.player-rank-card.level-beginner { border-left-color: #6C757D; }

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.rank-number-section {
  min-width: 80px;
}

.rank-number {
  position: relative;
  width: 70px;
  height: 70px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.rank-number.rank-first {
  background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
  box-shadow: 0 4px 16px rgba(255, 215, 0, 0.6);
  animation: pulse 2s infinite;
}

.rank-number.rank-second {
  background: linear-gradient(135deg, #E0E0E0 0%, #A0A0A0 100%);
  box-shadow: 0 4px 16px rgba(192, 192, 192, 0.6);
}

.rank-number.rank-third {
  background: linear-gradient(135deg, #CD7F32 0%, #B87333 100%);
  box-shadow: 0 4px 16px rgba(205, 127, 50, 0.6);
}

@keyframes pulse {
  0%, 100% { transform: scale(1); box-shadow: 0 4px 16px rgba(255, 215, 0, 0.6); }
  50% { transform: scale(1.05); box-shadow: 0 6px 24px rgba(255, 215, 0, 0.8); }
}

.rank-text {
  font-size: 1.75rem;
  font-weight: 800;
  color: white;
  text-shadow: 0 2px 4px rgba(0,0,0,0.2);
}

.rank-crown {
  position: absolute;
  top: -10px;
  right: -5px;
  font-size: 1.5rem;
  filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));
  animation: float 2s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-5px); }
}

.player-main-info {
  flex: 1;
}

.player-name-section {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.player-name {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1a1a2e;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.member-badge {
  font-size: 1.25rem;
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.8; transform: scale(1.1); }
}

.player-stats-mini {
  display: flex;
  gap: 1.5rem;
  flex-wrap: wrap;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.875rem;
}

.stat-label {
  color: #6c757d;
  font-weight: 500;
}

.stat-value {
  color: #1a1a2e;
  font-weight: 600;
}

.player-rank-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  min-width: 180px;
}

.rank-badge-large {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 1rem 1.5rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  border: 3px solid;
  transition: transform 0.3s ease;
}

.rank-badge-large:hover {
  transform: scale(1.05);
}

.rank-badge-large.rank-hall_of_fame { border-color: #FFD700; background: linear-gradient(135deg, #FFF9E6, #FFEDD5); }
.rank-badge-large.rank-pro_level { border-color: #DC3545; background: linear-gradient(135deg, #FFF5F5, #FED7D7); }
.rank-badge-large.rank-grand_master { border-color: #6F42C1; background: linear-gradient(135deg, #F8F5FF, #E9D8FD); }
.rank-badge-large.rank-master { border-color: #E83E8C; background: linear-gradient(135deg, #FFF5F9, #FED7E2); }
.rank-badge-large.rank-elite { border-color: #FD7E14; background: linear-gradient(135deg, #FFF7ED, #FED7AA); }
.rank-badge-large.rank-expert { border-color: #FFC107; background: linear-gradient(135deg, #FFFBEB, #FEF3C7); }
.rank-badge-large.rank-advance { border-color: #28A745; background: linear-gradient(135deg, #F0FDF4, #DCFCE7); }
.rank-badge-large.rank-intermediate { border-color: #17A2B8; background: linear-gradient(135deg, #F0FDFA, #CCFBF1); }
.rank-badge-large.rank-beginner { border-color: #6C757D; background: linear-gradient(135deg, #F8F9FA, #E9ECEF); }

.badge-emoji {
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
}

.badge-name {
  font-size: 0.875rem;
  font-weight: 600;
  text-align: center;
  line-height: 1.2;
}

.points-section {
  text-align: center;
}

.points-value {
  font-size: 2rem;
  font-weight: 800;
  color: #667eea;
  text-shadow: 0 2px 4px rgba(102, 126, 234, 0.3);
}

.points-label {
  font-size: 0.75rem;
  color: #6c757d;
  text-transform: uppercase;
  letter-spacing: 1px;
  font-weight: 600;
}

.rank-progress {
  min-width: 200px;
}

.progress-bar {
  height: 24px;
  background: #e9ecef;
  border-radius: 12px;
  overflow: hidden;
  position: relative;
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.1);
}

.progress-fill {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  transition: width 0.8s ease;
  position: relative;
  overflow: hidden;
}

.progress-fill::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
  animation: shimmerBar 2s infinite;
}

@keyframes shimmerBar {
  0% { left: -100%; }
  100% { left: 100%; }
}

.progress-fill.rank-hall_of_fame { background: linear-gradient(90deg, #FFD700, #FFA500); }
.progress-fill.rank-pro_level { background: linear-gradient(90deg, #DC3545, #C82333); }
.progress-fill.rank-grand_master { background: linear-gradient(90deg, #6F42C1, #5A32A3); }
.progress-fill.rank-master { background: linear-gradient(90deg, #E83E8C, #D63384); }
.progress-fill.rank-elite { background: linear-gradient(90deg, #FD7E14, #E8590C); }
.progress-fill.rank-expert { background: linear-gradient(90deg, #FFC107, #E0A800); }
.progress-fill.rank-advance { background: linear-gradient(90deg, #28A745, #218838); }
.progress-fill.rank-intermediate { background: linear-gradient(90deg, #17A2B8, #117A8B); }
.progress-fill.rank-beginner { background: linear-gradient(90deg, #6C757D, #545B62); }

.progress-label {
  font-size: 0.75rem;
  font-weight: 700;
  color: white;
  text-shadow: 0 1px 2px rgba(0,0,0,0.3);
  z-index: 1;
}

.progress-info {
  margin-top: 0.5rem;
  text-align: center;
}

.next-rank-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: #667eea;
}

@media (max-width: 1024px) {
  .player-rank-card {
    grid-template-columns: auto 1fr;
    gap: 1rem;
  }
  
  .player-rank-info {
    grid-column: 1 / -1;
    flex-direction: row;
    justify-content: space-between;
    width: 100%;
  }
  
  .rank-progress {
    grid-column: 1 / -1;
    width: 100%;
  }
}

@media (max-width: 768px) {
  .player-rank-card {
    grid-template-columns: auto 1fr;
    padding: 1rem;
  }
  
  .player-name {
    font-size: 1.25rem;
  }
  
  .rank-number {
    width: 60px;
    height: 60px;
  }
  
  .rank-text {
    font-size: 1.5rem;
  }
  
  .badge-emoji {
    font-size: 2rem;
  }
  
  .points-value {
    font-size: 1.5rem;
  }
}

/* Enhanced Ranking System Styles */
.ranking-system-section {
  padding: 2rem 0;
}

.ranking-system-header {
  text-align: center;
  margin-bottom: 2.5rem;
}

.ranking-system-header h3 {
  font-size: 2rem;
  font-weight: 800;
  color: #1a1a2e;
  margin-bottom: 0.5rem;
}

.ranking-subtitle {
  font-size: 1rem;
  color: #6c757d;
  font-weight: 500;
  margin: 0;
}

.ranking-levels-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
}

.rank-card {
  position: relative;
  background: white;
  border-radius: 20px;
  overflow: hidden;
  border: 3px solid transparent;
  transition: all 0.4s ease;
  cursor: pointer;
  animation: rank-fade-in 0.6s ease-out;
  animation-delay: calc(var(--rank-index) * 0.08s);
  animation-fill-mode: backwards;
}

@keyframes rank-fade-in {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.rank-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  z-index: 2;
}

/* Top stripe colors for each rank */
.rank-card.rank-hall_of_fame::before { 
  background: linear-gradient(90deg, #FFD700, #FFA500, #FF6B6B);
}
.rank-card.rank-pro_level::before { 
  background: linear-gradient(90deg, #667eea, #764ba2);
}
.rank-card.rank-grand_master::before { 
  background: linear-gradient(90deg, #4ECDC4, #44A08D);
}
.rank-card.rank-master::before { 
  background: linear-gradient(90deg, #F093FB, #F5576C);
}
.rank-card.rank-elite::before { 
  background: linear-gradient(90deg, #5B86E5, #36D1DC);
}
.rank-card.rank-expert::before { 
  background: linear-gradient(90deg, #FF9966, #FF5E62);
}
.rank-card.rank-advance::before { 
  background: linear-gradient(90deg, #A8EDEA, #FED6E3);
}
.rank-card.rank-intermediate::before { 
  background: linear-gradient(90deg, #C2E9FB, #A1C4FD);
}
.rank-card.rank-beginner::before { 
  background: linear-gradient(90deg, #E0E0E0, #C0C0C0);
}

/* Shine effect */
.rank-card::after {
  content: '';
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
  z-index: 1;
}

.rank-card:hover::after {
  transform: translateX(100%) translateY(100%) rotate(45deg);
}

.rank-card:hover {
  transform: translateY(-8px) scale(1.03);
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.15);
}

/* Border colors on hover */
.rank-card.rank-hall_of_fame:hover { border-color: #FFD700; box-shadow: 0 15px 40px rgba(255, 215, 0, 0.3); }
.rank-card.rank-pro_level:hover { border-color: #667eea; box-shadow: 0 15px 40px rgba(102, 126, 234, 0.3); }
.rank-card.rank-grand_master:hover { border-color: #4ECDC4; box-shadow: 0 15px 40px rgba(78, 205, 196, 0.3); }
.rank-card.rank-master:hover { border-color: #F093FB; box-shadow: 0 15px 40px rgba(240, 147, 251, 0.3); }
.rank-card.rank-elite:hover { border-color: #5B86E5; box-shadow: 0 15px 40px rgba(91, 134, 229, 0.3); }
.rank-card.rank-expert:hover { border-color: #FF9966; box-shadow: 0 15px 40px rgba(255, 153, 102, 0.3); }
.rank-card.rank-advance:hover { border-color: #A8EDEA; box-shadow: 0 15px 40px rgba(168, 237, 234, 0.3); }
.rank-card.rank-intermediate:hover { border-color: #C2E9FB; box-shadow: 0 15px 40px rgba(194, 233, 251, 0.3); }
.rank-card.rank-beginner:hover { border-color: #E0E0E0; box-shadow: 0 15px 40px rgba(224, 224, 224, 0.3); }

.rank-card-inner {
  position: relative;
  z-index: 2;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.rank-badge-large {
  font-size: 3rem;
  flex-shrink: 0;
  transition: transform 0.3s ease;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
}

.rank-card:hover .rank-badge-large {
  transform: scale(1.15) rotate(5deg);
}

.rank-info {
  flex: 1;
  min-width: 0;
}

.rank-card .rank-name {
  font-size: 1rem;
  font-weight: 700;
  color: #1a1a2e;
  margin-bottom: 0.25rem;
  line-height: 1.3;
}

.rank-card .rank-points {
  font-size: 0.875rem;
  font-weight: 600;
  color: #6c757d;
}

.rank-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 120px;
  height: 120px;
  border-radius: 50%;
  opacity: 0;
  filter: blur(30px);
  transition: opacity 0.3s ease;
  pointer-events: none;
}

.rank-card.rank-hall_of_fame .rank-glow { background: radial-gradient(circle, rgba(255, 215, 0, 0.4) 0%, transparent 70%); }
.rank-card.rank-pro_level .rank-glow { background: radial-gradient(circle, rgba(102, 126, 234, 0.4) 0%, transparent 70%); }
.rank-card.rank-grand_master .rank-glow { background: radial-gradient(circle, rgba(78, 205, 196, 0.4) 0%, transparent 70%); }
.rank-card.rank-master .rank-glow { background: radial-gradient(circle, rgba(240, 147, 251, 0.4) 0%, transparent 70%); }
.rank-card.rank-elite .rank-glow { background: radial-gradient(circle, rgba(91, 134, 229, 0.4) 0%, transparent 70%); }
.rank-card.rank-expert .rank-glow { background: radial-gradient(circle, rgba(255, 153, 102, 0.4) 0%, transparent 70%); }
.rank-card.rank-advance .rank-glow { background: radial-gradient(circle, rgba(168, 237, 234, 0.4) 0%, transparent 70%); }
.rank-card.rank-intermediate .rank-glow { background: radial-gradient(circle, rgba(194, 233, 251, 0.4) 0%, transparent 70%); }
.rank-card.rank-beginner .rank-glow { background: radial-gradient(circle, rgba(224, 224, 224, 0.4) 0%, transparent 70%); }

.rank-card:hover .rank-glow {
  opacity: 1;
}

/* Responsive Design */
@media (max-width: 1024px) {
  .ranking-levels-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 1.25rem;
  }
}

@media (max-width: 640px) {
  .ranking-levels-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .ranking-system-header h3 {
    font-size: 1.75rem;
  }
  
  .rank-card-inner {
    padding: 1.25rem;
  }
  
  .rank-badge-large {
    font-size: 2.5rem;
  }
  
  .rank-card .rank-name {
    font-size: 0.9rem;
  }
}
</style>

