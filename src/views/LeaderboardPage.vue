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

    <!-- Division Tabs: Pro / Student -->
    <div class="category-tabs">
      <button 
        class="category-tab"
        :class="{ active: divisionFilter === 'pro' }"
        @click="divisionFilter = 'pro'"
      >
        👔 Pro Division
      </button>
      <button 
        class="category-tab"
        :class="{ active: divisionFilter === 'student' }"
        @click="divisionFilter = 'student'"
      >
        🎓 Student Division
      </button>
    </div>

    <!-- Tabs for Year, Monthly and Annual -->
    <div class="tabs">
      <button 
        class="tab-button"
        :class="{ active: activeTab === 'year' }"
        @click="activeTab = 'year'"
      >
        🏆 Current Year ({{ currentYear }})
      </button>
      <button 
        class="tab-button"
        :class="{ active: activeTab === 'monthly' }"
        @click="activeTab = 'monthly'"
      >
        📅 Monthly
      </button>
      <button 
        class="tab-button"
        :class="{ active: activeTab === 'annual' }"
        @click="activeTab = 'annual'"
      >
        🏅 Annual
      </button>
    </div>

    <!-- Month Selector for Monthly Tab -->
    <div v-if="activeTab === 'monthly'" class="month-selector">
      <label for="month-select" class="selector-label">Select Month:</label>
      <select id="month-select" name="month-select" v-model="selectedMonth" @change="loadMonthlyRankings" class="month-select">
        <option v-for="month in availableMonths" :key="month.value" :value="month.value">
          {{ month.label }}
        </option>
      </select>
    </div>

    <!-- Year Selector for Annual Tab -->
    <div v-if="activeTab === 'annual'" class="year-selector">
      <label for="year-select" class="selector-label">Select Year:</label>
      <select id="year-select" name="year-select" v-model="selectedYear" @change="loadAnnualRankings" class="year-select">
        <option v-for="year in availableYears" :key="year" :value="year">
          {{ year }}
        </option>
      </select>
    </div>

    <!-- Export Button (Admin Only) -->
    <div v-if="authStore.isAdmin" class="export-section">
      <div class="export-buttons">
        <button class="btn btn-primary" @click="exportToCSV" :disabled="loading || rankedPlayers.length === 0">
          📥 Export to CSV
        </button>
        <button class="btn btn-success" @click="exportToExcel" :disabled="loading || rankedPlayers.length === 0">
          📊 Export to Excel
        </button>
      </div>
      <p class="export-hint">Export current leaderboard data for {{ divisionFilter === 'pro' ? 'Pro' : 'Student' }} Division - {{ getPeriodLabel() }}</p>
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
                <img 
                  v-if="!iconErrors[`${topThree[1].id}-${topThree[1].ranking_level}`]"
                  :src="getRankIcon(topThree[1].ranking_level).src" 
                  :alt="getRankIcon(topThree[1].ranking_level).alt"
                  class="badge-icon"
                  @error="iconErrors[`${topThree[1].id}-${topThree[1].ranking_level}`] = true"
                />
                <span v-else class="badge-emoji">{{ getRankIcon(topThree[1].ranking_level).emoji }}</span>
                <span class="badge-name">{{ formatRankName(topThree[1].ranking_level) }}</span>
              </div>
              <h3>{{ topThree[1].name }}</h3>
              <p class="points">{{ getDisplayPoints(topThree[1]) }} pts</p>
              <div class="player-stats-top3">
                <div class="stat-row">
                  <span class="stat-label">W/L:</span>
                  <span class="stat-value">{{ getDivisionValueForYear(topThree[1], divisionFilter, 'wins', activeTab === 'year' ? currentYear : null) }}/{{ getDivisionValueForYear(topThree[1], divisionFilter, 'losses', activeTab === 'year' ? currentYear : null) }}</span>
                </div>
                <div class="stat-row">
                  <span class="stat-label">Win Rate:</span>
                  <span class="stat-value">{{ calculateWinRateForYear(topThree[1], activeTab === 'year' ? currentYear : null) }}%</span>
                </div>
                <div class="stat-row">
                  <span class="stat-label">🎯 Break & Run:</span>
                  <span class="stat-value">{{ getDivisionValueForYear(topThree[1], divisionFilter, 'break_and_run_count', activeTab === 'year' ? currentYear : null) }}</span>
                </div>
                <div class="stat-row">
                  <span class="stat-label">📅 Events:</span>
                  <span class="stat-value">{{ activeTab === 'year' ? (topThree[1].tournaments_played_current_year || 0) : (topThree[1].tournaments_played || 0) }}</span>
                </div>
              </div>
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
                <img 
                  v-if="!iconErrors[`${topThree[0].id}-${topThree[0].ranking_level}`]"
                  :src="getRankIcon(topThree[0].ranking_level).src" 
                  :alt="getRankIcon(topThree[0].ranking_level).alt"
                  class="badge-icon"
                  @error="iconErrors[`${topThree[0].id}-${topThree[0].ranking_level}`] = true"
                />
                <span v-else class="badge-emoji">{{ getRankIcon(topThree[0].ranking_level).emoji }}</span>
                <span class="badge-name">{{ formatRankName(topThree[0].ranking_level) }}</span>
              </div>
              <h3>{{ topThree[0].name }}</h3>
              <p class="points">{{ getDisplayPoints(topThree[0]) }} pts</p>
              <div class="player-stats-top3">
                <div class="stat-row">
                  <span class="stat-label">W/L:</span>
                  <span class="stat-value">{{ getDivisionValueForYear(topThree[0], divisionFilter, 'wins', activeTab === 'year' ? currentYear : null) }}/{{ getDivisionValueForYear(topThree[0], divisionFilter, 'losses', activeTab === 'year' ? currentYear : null) }}</span>
                </div>
                <div class="stat-row">
                  <span class="stat-label">Win Rate:</span>
                  <span class="stat-value">{{ calculateWinRateForYear(topThree[0], activeTab === 'year' ? currentYear : null) }}%</span>
                </div>
                <div class="stat-row">
                  <span class="stat-label">🎯 Break & Run:</span>
                  <span class="stat-value">{{ getDivisionValueForYear(topThree[0], divisionFilter, 'break_and_run_count', activeTab === 'year' ? currentYear : null) }}</span>
                </div>
                <div class="stat-row">
                  <span class="stat-label">📅 Events:</span>
                  <span class="stat-value">{{ activeTab === 'year' ? (topThree[0].tournaments_played_current_year || 0) : (topThree[0].tournaments_played || 0) }}</span>
                </div>
              </div>
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
                <img 
                  v-if="!iconErrors[`${topThree[2].id}-${topThree[2].ranking_level}`]"
                  :src="getRankIcon(topThree[2].ranking_level).src" 
                  :alt="getRankIcon(topThree[2].ranking_level).alt"
                  class="badge-icon"
                  @error="iconErrors[`${topThree[2].id}-${topThree[2].ranking_level}`] = true"
                />
                <span v-else class="badge-emoji">{{ getRankIcon(topThree[2].ranking_level).emoji }}</span>
                <span class="badge-name">{{ formatRankName(topThree[2].ranking_level) }}</span>
              </div>
              <h3>{{ topThree[2].name }}</h3>
              <p class="points">{{ getDisplayPoints(topThree[2]) }} pts</p>
              <div class="player-stats-top3">
                <div class="stat-row">
                  <span class="stat-label">W/L:</span>
                  <span class="stat-value">{{ getDivisionValueForYear(topThree[2], divisionFilter, 'wins', activeTab === 'year' ? currentYear : null) }}/{{ getDivisionValueForYear(topThree[2], divisionFilter, 'losses', activeTab === 'year' ? currentYear : null) }}</span>
                </div>
                <div class="stat-row">
                  <span class="stat-label">Win Rate:</span>
                  <span class="stat-value">{{ calculateWinRateForYear(topThree[2], activeTab === 'year' ? currentYear : null) }}%</span>
                </div>
                <div class="stat-row">
                  <span class="stat-label">🎯 Break & Run:</span>
                  <span class="stat-value">{{ getDivisionValueForYear(topThree[2], divisionFilter, 'break_and_run_count', activeTab === 'year' ? currentYear : null) }}</span>
                </div>
                <div class="stat-row">
                  <span class="stat-label">📅 Events:</span>
                  <span class="stat-value">{{ activeTab === 'year' ? (topThree[2].tournaments_played_current_year || 0) : (topThree[2].tournaments_played || 0) }}</span>
                </div>
              </div>
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
            <span v-if="activeTab === 'year'">Year {{ currentYear }}</span>
            <span v-else-if="activeTab === 'monthly'">
              {{ availableMonths.find(m => m.value === selectedMonth)?.label || (currentMonthName + ' ' + currentYear) }}
            </span>
            <span v-else-if="activeTab === 'annual'">Year {{ selectedYear }}</span>
          </div>
        </div>
        <div class="card-body">
          <div class="rankings-list">
            <div 
              v-for="(player, index) in rankedPlayers" 
              :key="player.id"
              class="player-rank-card-new"
              :class="[getRankClass(index + 1), `level-${player.ranking_level}`]"
            >
              <!-- Rank Number - Large and Prominent -->
              <div class="rank-number-large" :class="getRankClass(index + 1)">
                <span class="rank-medal" v-if="index < 3">
                  <span v-if="index === 0">🥇</span>
                  <span v-if="index === 1">🥈</span>
                  <span v-if="index === 2">🥉</span>
                </span>
                <span class="rank-text-large">{{ index + 1 }}</span>
              </div>

              <!-- Player Main Info -->
              <div class="player-info-main">
                <!-- Rank Badge -->
                <div class="rank-badge-compact" :class="`rank-${player.ranking_level}`">
                  <img 
                    v-if="!iconErrors[`${player.id}-${player.ranking_level}`]"
                    :src="getRankIcon(player.ranking_level).src" 
                    :alt="getRankIcon(player.ranking_level).alt"
                    class="badge-icon-small"
                    @error="iconErrors[`${player.id}-${player.ranking_level}`] = true"
                  />
                  <span v-else class="badge-emoji-small">{{ getRankIcon(player.ranking_level).emoji }}</span>
                </div>
                
                <!-- Player Name -->
                <div class="player-name-large">{{ player.name }}</div>
                
                <!-- Stats Row -->
                <div class="player-stats-row">
                  <span class="stat-badge">
                    <span class="stat-label">W/L:</span>
                    <span class="stat-value">{{ getDivisionValueForYear(player, divisionFilter, 'wins', activeTab === 'year' ? currentYear : null) }}/{{ getDivisionValueForYear(player, divisionFilter, 'losses', activeTab === 'year' ? currentYear : null) }}</span>
                  </span>
                  <span class="stat-badge">
                    <span class="stat-label">Win:</span>
                    <span class="stat-value">{{ calculateWinRateForYear(player, activeTab === 'year' ? currentYear : null) }}%</span>
                  </span>
                  <span class="stat-badge highlight">
                    <span class="stat-label">🎯 B&R:</span>
                    <span class="stat-value">{{ getDivisionValueForYear(player, divisionFilter, 'break_and_run_count', activeTab === 'year' ? currentYear : null) }}</span>
                  </span>
                  <span class="stat-badge">
                    <span class="stat-label">📅 Events:</span>
                    <span class="stat-value">{{ getDivisionValueForYear(player, divisionFilter, 'tournaments_played', activeTab === 'year' ? currentYear : null) }}</span>
                  </span>
                </div>
              </div>

              <!-- Points Section - Right Aligned -->
              <div class="points-section-large">
                <div class="points-value-large">{{ getDisplayPoints(player) }}</div>
                <div class="points-label-small">points</div>
                <button 
                  v-if="canViewHistory(player)"
                  class="btn-history" 
                  @click="openPointHistory(player)"
                  title="View Point History"
                >
                  📊 History
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Point History Modal -->
      <div v-if="showHistoryModal" class="modal" @click.self="closeHistoryModal">
        <div class="modal-content history-modal" style="max-width: 800px; max-height: 90vh; overflow-y: auto;">
          <div class="modal-header">
            <h2>📊 Point History - {{ selectedPlayerHistory?.name || 'Player' }}</h2>
            <button class="btn btn-secondary btn-sm" @click="closeHistoryModal">Close</button>
          </div>
          <div class="modal-body">
            <div v-if="loadingHistory" class="text-center p-4">
              <div class="spinner"></div>
              <p>Loading history...</p>
            </div>
            <div v-else-if="pointHistoryList.length === 0" class="text-center p-4">
              <p class="text-muted">No point history available for this player.</p>
            </div>
            <div v-else>
              <!-- Summary Stats -->
              <div class="history-summary">
                <div class="summary-item">
                  <span class="summary-label">Total Records:</span>
                  <span class="summary-value">{{ pointHistoryList.length }}</span>
                </div>
                <div class="summary-item">
                  <span class="summary-label">Total Points:</span>
                  <span class="summary-value positive">
                    +{{ pointHistoryList.filter(h => h.points_change > 0).reduce((sum, h) => sum + h.points_change, 0) }}
                  </span>
                </div>
                <div class="summary-item">
                  <span class="summary-label">Current Season:</span>
                  <span class="summary-value">{{ currentYear }}</span>
                </div>
              </div>

              <!-- History List -->
              <div class="history-list">
                <div 
                  v-for="(record, index) in pointHistoryList" 
                  :key="record.id"
                  class="history-item"
                  :class="{ 'positive': record.points_change > 0, 'negative': record.points_change < 0 }"
                >
                  <div class="history-date">
                    <div class="date-main">{{ formatHistoryDate(record.awarded_at) }}</div>
                    <div class="date-time">{{ formatHistoryTime(record.awarded_at) }}</div>
                  </div>
                  <div class="history-details">
                    <div class="history-reason">{{ record.reason || 'No reason provided' }}</div>
                    <div class="history-meta">
                      <span class="meta-item">{{ record.year }}-{{ String(record.month).padStart(2, '0') }}</span>
                    </div>
                  </div>
                  <div class="history-points">
                    <div class="points-change" :class="{ 'positive': record.points_change > 0, 'negative': record.points_change < 0 }">
                      <span v-if="record.points_change > 0">+</span>{{ record.points_change }}
                    </div>
                    <div class="points-cumulative">
                      Total: {{ calculateCumulativePoints(index) }}
                    </div>
                  </div>
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
                  <div class="rank-badge-large">
                    <img 
                      v-if="!iconErrors[`rank-${rank.level}`]"
                      :src="getRankIcon(rank.level).src" 
                      :alt="getRankIcon(rank.level).alt"
                      class="badge-icon"
                      @error="iconErrors[`rank-${rank.level}`] = true"
                    />
                    <span v-else class="badge-emoji">{{ getRankIcon(rank.level).emoji }}</span>
                  </div>
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
import { ref, computed, onMounted, watch } from 'vue'
import { supabase } from '../config/supabase'
import { useAuthStore } from '../stores/authStore'
import SkeletonLeaderboard from '../components/skeleton/SkeletonLeaderboard.vue'
import { getRankIcon } from '../utils/rankIcons'

export default {
  name: 'LeaderboardPage',
  components: {
    SkeletonLeaderboard
  },
  setup() {
    const authStore = useAuthStore()
    const loading = ref(true)
    const players = ref([])
    const activeTab = ref('year') // 默认显示 Current Year
    const divisionFilter = ref('pro') // 默认显示 Pro 组
    const iconErrors = ref({}) // 跟踪图标加载失败
    
    // Point History Modal
    const showHistoryModal = ref(false)
    const selectedPlayerHistory = ref(null)
    const pointHistoryList = ref([])
    const loadingHistory = ref(false)
    const currentUserId = ref(null) // Store current user's user_id (not auth_id)
    
    // Load current user's user_id on mount
    const loadCurrentUserId = async () => {
      if (!authStore.user) {
        currentUserId.value = null
        return
      }
      
      try {
        const { data, error } = await supabase
          .from('users')
          .select('id')
          .eq('auth_id', authStore.user.id)
          .maybeSingle()
        
        if (error) {
          console.error('Error loading current user ID:', error)
          return
        }
        
        currentUserId.value = data?.id || null
      } catch (err) {
        console.error('Error in loadCurrentUserId:', err)
      }
    }
    
    // Check if current user can view player's history
    const canViewHistory = (player) => {
      if (!authStore.user || !player) return false
      // Admin can view all
      if (authStore.isAdmin) return true
      // User can view their own history
      // Check if player's id matches current user's user_id
      return currentUserId.value && player.id === currentUserId.value
    }
    
    // Get NZ timezone date
    const nzDate = new Date(new Date().toLocaleString("en-US", { timeZone: "Pacific/Auckland" }))
    const currentYear = nzDate.getFullYear()
    const currentMonth = nzDate.getMonth() + 1
    
    const currentMonthName = nzDate.toLocaleString('en-US', { month: 'long', timeZone: 'Pacific/Auckland' })
    
    // For Annual Rankings - show current year and last year only
    const selectedYear = ref(currentYear)
    const availableYears = [currentYear, currentYear - 1]
    
    // For Monthly Rankings - show current month and previous months
    const selectedMonth = ref(`${currentYear}-${currentMonth}`)
    const availableMonths = computed(() => {
      const months = []
      const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 
                         'July', 'August', 'September', 'October', 'November', 'December']
      
      // Show current year's months from January to current month (most recent first)
      for (let m = currentMonth; m >= 1; m--) {
        months.push({
          month: m,
          year: currentYear,
          value: `${currentYear}-${m}`,
          label: `${monthNames[m - 1]} ${currentYear}`
        })
      }
      
      // Show previous year's months (from December to current month + 1)
      if (currentMonth < 12) {
        for (let m = 12; m > currentMonth; m--) {
          months.push({
            month: m,
            year: currentYear - 1,
            value: `${currentYear - 1}-${m}`,
            label: `${monthNames[m - 1]} ${currentYear - 1}`
          })
        }
      }
      
      return months
    })

    const getDivisionStatKey = (division, field) => {
      const prefix = division === 'student' ? 'student' : 'pro'
      if (field === 'break_and_run_count') {
        return `${prefix}_break_and_run_count`
      }
      return `${prefix}_${field}`
    }

    const getDivisionValue = (player, division, field) => {
      if (!player) return 0
      
      // For "Current Year" tab, we need to filter stats by year
      // Note: wins/losses/break_and_run_count are stored in user table as totals
      // We need to calculate year-specific stats from point history or match records
      // For now, we'll return total stats for all tabs except when we have year-specific data
      
      // If activeTab is 'year' (Current Year), we should ideally filter by year
      // But since wins/losses/break_and_run are not stored per year in the database,
      // we'll need to calculate them from point history or match records
      // For now, return total stats (this will be improved)
      
      const key = getDivisionStatKey(division, field)
      return player[key] ?? 0
    }
    
    // Get year-specific division value (for current year tab)
    const getDivisionValueForYear = (player, division, field, year) => {
      if (!player) return 0
      
      // For Events Played, we have year-specific data
      if (field === 'tournaments_played') {
        if (activeTab.value === 'year' && year === currentYear) {
          return player.tournaments_played_current_year || 0
        }
        return player.tournaments_played || 0
      }
      
      // For wins/losses/break_and_run, use year-specific stats from user_year_stats table
      if (activeTab.value === 'year' && year === currentYear) {
        if (division === 'pro') {
          if (field === 'wins') return player.pro_current_year_wins || 0
          if (field === 'losses') return player.pro_current_year_losses || 0
          if (field === 'break_and_run_count') return player.pro_current_year_break_and_run || 0
        } else {
          if (field === 'wins') return player.student_current_year_wins || 0
          if (field === 'losses') return player.student_current_year_losses || 0
          if (field === 'break_and_run_count') return player.student_current_year_break_and_run || 0
        }
      }
      
      // Fallback to total stats for other tabs or if year-specific data not available
      const key = getDivisionStatKey(division, field)
      return player[key] ?? 0
    }

    const getDivisionMatches = (player, division) => {
      return getDivisionValue(player, division, 'wins') + getDivisionValue(player, division, 'losses')
    }

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
      // 🎯 根据 activeTab 和组别获取对应的积分
      const playersWithPoints = players.value.filter(player => {
        const points = getDisplayPoints(player)
        return points > 0
      })
      
      const sorted = playersWithPoints.sort((a, b) => {
        const aPoints = getDisplayPoints(a)
        const bPoints = getDisplayPoints(b)
        
        if (bPoints !== aPoints) return bPoints - aPoints
        // 如果积分相同，按组别胜场数排序
        return getDivisionValue(b, divisionFilter.value, 'wins') - getDivisionValue(a, divisionFilter.value, 'wins')
      })
      return sorted
    })

    const topThree = computed(() => {
      return rankedPlayers.value.slice(0, 3)
    })

    const getDisplayPoints = (player) => {
      // 🎯 根据 activeTab、divisionFilter 和组别返回对应的积分
      const division = divisionFilter.value
      const divisionSuffix = division === 'pro' ? 'pro' : 'student'
      
      if (activeTab.value === 'year') {
        // Current Year: 显示当前年份的积分（按组别）
        return player[`current_year_${divisionSuffix}_points`] || 0
      } else if (activeTab.value === 'monthly') {
        // Monthly: 显示选中月份的积分（按组别）
        if (!selectedMonth.value) {
          // Fallback: use current month if not set
          const currentMonthData = availableMonths.value[0]
          if (currentMonthData) {
            const monthKey = `month_${currentMonthData.year}_${currentMonthData.month}_${divisionSuffix}_points`
            return player[monthKey] || 0
          }
          return 0
        }
        
        // Parse selectedMonth value (format: "YYYY-M")
        const [year, month] = selectedMonth.value.split('-').map(Number)
        const monthKey = `month_${year}_${month}_${divisionSuffix}_points`
        return player[monthKey] || 0
      } else if (activeTab.value === 'annual') {
        // Annual: 显示选中年份的积分（按组别）
        return player[`selected_year_${divisionSuffix}_points`] || 0
      }
      
      // Default: fallback to total points
      if (division === 'pro') {
        return player.pro_ranking_points || 0
      } else {
        return player.student_ranking_points || 0
      }
    }

    const loadLeaderboard = async () => {
      loading.value = true
      try {
        // Get current NZ timezone date
        const nzDate = new Date(new Date().toLocaleString("en-US", { timeZone: "Pacific/Auckland" }))
        const currentYear = nzDate.getFullYear()
        const currentMonth = nzDate.getMonth() + 1 // JavaScript months are 0-indexed
        
        // Get all users (using public_users view for public access)
        const { data: usersData, error: usersError } = await supabase
          .from('public_users')
          .select('*')
        
        if (usersError) throw usersError
        
        // Get RANKING point history (NOT loyalty points!)
        const { data: pointHistory, error: pointError } = await supabase
          .from('ranking_point_history')  // 改为 ranking_point_history
          .select('*')
        
        if (pointError) throw pointError
        
        // Get year-specific stats from user_year_stats table
        const { data: yearStats, error: yearStatsError } = await supabase
          .from('user_year_stats')
          .select('*')
        
        if (yearStatsError) {
          console.warn('Error loading year stats:', yearStatsError)
          // Continue without year stats if table doesn't exist yet
        }

        // Count point history records per user (Events Played = Total Records in History)
        // Calculate both total and current year counts
        const tournamentsPerUser = {} // Total events (all years)
        const tournamentsPerUserCurrentYear = {} // Current year events only
        
        pointHistory.forEach(record => {
          const userId = record.user_id
          if (!tournamentsPerUser[userId]) {
            tournamentsPerUser[userId] = 0
          }
          tournamentsPerUser[userId]++
          
          // Count current year events
          if (record.year === currentYear) {
            if (!tournamentsPerUserCurrentYear[userId]) {
              tournamentsPerUserCurrentYear[userId] = 0
            }
            tournamentsPerUserCurrentYear[userId]++
          }
        })
        
        // Calculate RANKING points for each user (段位积分，影响排名)
        // Helper function to filter by division
        // Compatible with old format (before division prefix was added)
        const filterByDivision = (history, division) => {
          if (division === 'pro') {
            return history.filter(p => {
              if (!p.reason) return false
              const reason = p.reason.toLowerCase()
              // New format: "Pro: ..."
              if (p.reason.startsWith('Pro:')) return true
              // Old format: exclude student-related records
              if (reason.includes('student')) return false
              // Default: old records without prefix are Pro (legacy data)
              return true
            })
          } else {
            return history.filter(p => {
              if (!p.reason) return false
              const reason = p.reason.toLowerCase()
              // New format: "Student: ..."
              if (p.reason.startsWith('Student:')) return true
              // Old format: include student-related records
              if (reason.includes('student')) return true
              // Exclude everything else
              return false
            })
          }
        }
        
        const playersWithPoints = usersData.map(user => {
          const userHistory = pointHistory.filter(p => p.user_id === user.id)
          
          // Get year-specific stats for this user
          const userYearStats = (yearStats || []).filter(s => s.user_id === user.id)
          const proYearStats = userYearStats.filter(s => s.division === 'pro' && s.year === currentYear)
          const studentYearStats = userYearStats.filter(s => s.division === 'student' && s.year === currentYear)
          
          // Calculate current year stats (sum all records for current year)
          const proCurrentYearStats = proYearStats.reduce((acc, s) => ({
            wins: acc.wins + (s.wins || 0),
            losses: acc.losses + (s.losses || 0),
            break_and_run_count: acc.break_and_run_count + (s.break_and_run_count || 0)
          }), { wins: 0, losses: 0, break_and_run_count: 0 })
          
          const studentCurrentYearStats = studentYearStats.reduce((acc, s) => ({
            wins: acc.wins + (s.wins || 0),
            losses: acc.losses + (s.losses || 0),
            break_and_run_count: acc.break_and_run_count + (s.break_and_run_count || 0)
          }), { wins: 0, losses: 0, break_and_run_count: 0 })
          
          // Filter by current division
          const proHistory = filterByDivision(userHistory, 'pro')
          const studentHistory = filterByDivision(userHistory, 'student')
          
          // Calculate current year total (for Current Year tab) - Pro
          const proYearPoints = proHistory
            .filter(p => p.year === currentYear)
            .reduce((sum, p) => sum + (p.points_change || 0), 0)
          
          // Calculate current year total (for Current Year tab) - Student
          const studentYearPoints = studentHistory
            .filter(p => p.year === currentYear)
            .reduce((sum, p) => sum + (p.points_change || 0), 0)
          
          // Calculate selected year total (for Annual tab) - Pro
          const proSelectedYearPoints = proHistory
            .filter(p => p.year === selectedYear.value)
            .reduce((sum, p) => sum + (p.points_change || 0), 0)
          
          // Calculate selected year total (for Annual tab) - Student
          const studentSelectedYearPoints = studentHistory
            .filter(p => p.year === selectedYear.value)
            .reduce((sum, p) => sum + (p.points_change || 0), 0)
          
          // Calculate points for each month (for Monthly tab) - Pro and Student separately
          const monthPointsData = {}
          
          // Calculate for current year months - Pro
          for (let month = 1; month <= 12; month++) {
            const proMonthPoints = proHistory
              .filter(p => p.year === currentYear && p.month === month)
              .reduce((sum, p) => sum + (p.points_change || 0), 0)
            monthPointsData[`month_${currentYear}_${month}_pro_points`] = proMonthPoints
            
            const studentMonthPoints = studentHistory
              .filter(p => p.year === currentYear && p.month === month)
              .reduce((sum, p) => sum + (p.points_change || 0), 0)
            monthPointsData[`month_${currentYear}_${month}_student_points`] = studentMonthPoints
          }
          
          // Calculate for previous year months (if needed) - Pro and Student
          if (currentYear > 2024) {
            for (let month = 1; month <= 12; month++) {
              const proMonthPoints = proHistory
                .filter(p => p.year === currentYear - 1 && p.month === month)
                .reduce((sum, p) => sum + (p.points_change || 0), 0)
              monthPointsData[`month_${currentYear - 1}_${month}_pro_points`] = proMonthPoints
              
              const studentMonthPoints = studentHistory
                .filter(p => p.year === currentYear - 1 && p.month === month)
                .reduce((sum, p) => sum + (p.points_change || 0), 0)
              monthPointsData[`month_${currentYear - 1}_${month}_student_points`] = studentMonthPoints
            }
          }
          
          // Calculate current year stats (wins, losses, break_and_run) from point history
          // For current year tab, we need to calculate stats from point history records
          const proYearHistory = proHistory.filter(p => p.year === currentYear)
          const studentYearHistory = studentHistory.filter(p => p.year === currentYear)
          
          // Calculate year-specific stats by grouping point history records by tournament
          // Each point history record with a tournament reason represents a tournament participation
          // We'll need to track wins/losses/break_and_run per tournament, but since we don't have
          // that data in point history, we'll use a simplified approach:
          // - Count unique tournaments per year (already done for tournaments_played_current_year)
          // - For wins/losses: Since we can't get exact data, we'll need to query matches table
          //   or create a year_stats table. For now, we'll calculate from point history patterns.
          
          // Group point history by tournament (extract tournament name from reason)
          const getTournamentName = (reason) => {
            if (!reason) return null
            // Reason format: "Pro: Tournament Name - Rank X" or "Student: Tournament Name - Rank X"
            const match = reason.match(/(?:Pro:|Student:)\s*(.+?)\s*-\s*Rank/)
            return match ? match[1].trim() : null
          }
          
          // Get unique tournaments for current year (Pro)
          const proYearTournaments = new Set()
          proYearHistory.forEach(p => {
            const tournamentName = getTournamentName(p.reason)
            if (tournamentName) proYearTournaments.add(tournamentName)
          })
          
          // Get unique tournaments for current year (Student)
          const studentYearTournaments = new Set()
          studentYearHistory.forEach(p => {
            const tournamentName = getTournamentName(p.reason)
            if (tournamentName) studentYearTournaments.add(tournamentName)
          })
          
          // For now, we can't accurately calculate year-specific wins/losses/break_and_run
          // without querying matches table or having a year_stats table
          // We'll store the point history for potential future calculation
          
          return {
            ...user,
            // Pro points
            current_year_pro_points: proYearPoints,
            selected_year_pro_points: proSelectedYearPoints,
            // Student points
            current_year_student_points: studentYearPoints,
            selected_year_student_points: studentSelectedYearPoints,
            // Combined for backward compatibility
            current_year_points: proYearPoints + studentYearPoints,
            selected_year_points: proSelectedYearPoints + studentSelectedYearPoints,
            ...monthPointsData,
            // ✅ 强制使用数据库的 ranking_points，不使用 loyalty_points
            ranking_points: user.ranking_points || 0,
            // ✅ Events/Tournaments Played count
            tournaments_played: tournamentsPerUser[user.id] || 0, // Total (all years)
            tournaments_played_current_year: tournamentsPerUserCurrentYear[user.id] || 0, // Current year only
            // Store point history for year-based stats calculation
            pro_year_history: proYearHistory,
            student_year_history: studentYearHistory,
            // Store unique tournaments for current year (for potential stats calculation)
            pro_year_tournaments: Array.from(proYearTournaments),
            student_year_tournaments: Array.from(studentYearTournaments),
            // ✅ Year-specific stats from user_year_stats table
            pro_current_year_wins: proCurrentYearStats.wins,
            pro_current_year_losses: proCurrentYearStats.losses,
            pro_current_year_break_and_run: proCurrentYearStats.break_and_run_count,
            student_current_year_wins: studentCurrentYearStats.wins,
            student_current_year_losses: studentCurrentYearStats.losses,
            student_current_year_break_and_run: studentCurrentYearStats.break_and_run_count
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

    const loadMonthlyRankings = async () => {
      // Reload leaderboard when month selection changes
      // The data is already loaded, just need to trigger recomputation
      // No need to reload, just update the selected month
    }

    // Point History Functions
    const openPointHistory = async (player) => {
      // Security: Check permissions
      if (!canViewHistory(player)) {
        alert('⛔ Access Denied: You can only view your own point history or you need admin privileges.')
        return
      }
      
      if (!player || !player.id) {
        console.error('Invalid player data:', player)
        alert('Invalid player data')
        return
      }
      
      selectedPlayerHistory.value = player
      showHistoryModal.value = true
      loadingHistory.value = true
      pointHistoryList.value = []

      try {
        // Load point history for this player
        const { data, error } = await supabase
          .from('ranking_point_history')
          .select('*')
          .eq('user_id', player.id)
          .order('awarded_at', { ascending: false })

        if (error) {
          console.error('Supabase error:', error)
          throw error
        }

        if (data) {
          // Filter by current division (Pro or Student)
          // Compatible with old format
          const division = divisionFilter.value
          if (division === 'pro') {
            pointHistoryList.value = data.filter(p => {
              if (!p.reason) return false
              const reason = p.reason.toLowerCase()
              // New format: "Pro: ..."
              if (p.reason.startsWith('Pro:')) return true
              // Old format: exclude student-related records
              if (reason.includes('student')) return false
              // Default: old records without prefix are Pro (legacy data)
              return true
            })
          } else {
            pointHistoryList.value = data.filter(p => {
              if (!p.reason) return false
              const reason = p.reason.toLowerCase()
              // New format: "Student: ..."
              if (p.reason.startsWith('Student:')) return true
              // Old format: include student-related records
              if (reason.includes('student')) return true
              // Exclude everything else
              return false
            })
          }
        }
      } catch (err) {
        console.error('Error loading point history:', err)
        alert('Failed to load point history: ' + err.message)
      } finally {
        loadingHistory.value = false
      }
    }

    const closeHistoryModal = () => {
      showHistoryModal.value = false
      selectedPlayerHistory.value = null
      pointHistoryList.value = []
    }

    const formatHistoryDate = (dateString) => {
      if (!dateString) return 'Unknown'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-NZ', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        timeZone: 'Pacific/Auckland'
      })
    }

    const formatHistoryTime = (dateString) => {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleTimeString('en-NZ', {
        hour: '2-digit',
        minute: '2-digit',
        timeZone: 'Pacific/Auckland'
      })
    }

    const calculateCumulativePoints = (index) => {
      // Calculate cumulative points from the beginning (oldest first)
      // Since list is sorted descending (newest first), we need to reverse
      const reversedList = [...pointHistoryList.value].reverse()
      let cumulative = 0
      // Sum from the beginning up to the current index (in reversed order)
      for (let i = 0; i <= (reversedList.length - 1 - index); i++) {
        cumulative += reversedList[i]?.points_change || 0
      }
      return cumulative
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

    const calculateWinRate = (player, division = divisionFilter.value) => {
      const wins = getDivisionValue(player, division, 'wins')
      const losses = getDivisionValue(player, division, 'losses')
      const total = wins + losses
      if (total === 0) return '0.0'
      return ((wins / total) * 100).toFixed(1)
    }
    
    // Calculate win rate for specific year (for Current Year tab)
    const calculateWinRateForYear = (player, year, division = divisionFilter.value) => {
      if (year === null || activeTab.value !== 'year') {
        return calculateWinRate(player, division)
      }
      
      // Use year-specific wins/losses from user_year_stats table
      const wins = getDivisionValueForYear(player, division, 'wins', year)
      const losses = getDivisionValueForYear(player, division, 'losses', year)
      const total = wins + losses
      if (total === 0) return '0.0'
      return ((wins / total) * 100).toFixed(1)
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

    // Watch for division filter changes and reload data
    watch(divisionFilter, () => {
      loadLeaderboard()
    })

    // Get period label for export filename
    const getPeriodLabel = () => {
      if (activeTab.value === 'year') {
        return `Year-${currentYear.value}`
      } else if (activeTab.value === 'monthly') {
        if (selectedMonth.value) {
          const [year, month] = selectedMonth.value.split('-')
          const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
          return `${year}-${monthNames[parseInt(month) - 1]}`
        }
        return `Month-${currentMonthName.value}`
      } else if (activeTab.value === 'annual') {
        return `Annual-${selectedYear.value}`
      }
      return 'Leaderboard'
    }

    // Export to CSV
    const exportToCSV = () => {
      if (!rankedPlayers.value.length) {
        alert('No data to export')
        return
      }

      const division = divisionFilter.value === 'pro' ? 'Pro' : 'Student'
      const period = getPeriodLabel()
      
      // CSV Headers
      const headers = [
        'Rank',
        'Name',
        'Points',
        'Wins',
        'Losses',
        'Win Rate (%)',
        'Break & Run',
        'Events Played',
        'Ranking Level',
        'Division',
        'Period'
      ]

      // CSV Rows
      const rows = rankedPlayers.value.map((player, index) => {
        const rank = index + 1
        const points = getDisplayPoints(player)
        const wins = getDivisionValue(player, divisionFilter.value, 'wins')
        const losses = getDivisionValue(player, divisionFilter.value, 'losses')
        const winRateStr = calculateWinRate(player, divisionFilter.value)
        const winRate = parseFloat(winRateStr) || 0
        const breakAndRun = getDivisionValue(player, divisionFilter.value, 'break_and_run_count')
        const tournamentsPlayed = player.tournaments_played || 0
        const rankingLevel = formatRankName(player.ranking_level || 'beginner')

        return [
          rank,
          player.name || 'N/A',
          points,
          wins,
          losses,
          winRate.toFixed(1),
          breakAndRun,
          tournamentsPlayed,
          rankingLevel,
          division,
          period
        ]
      })

      // Combine headers and rows
      const csvContent = [
        headers.join(','),
        ...rows.map(row => row.map(cell => {
          // Escape commas and quotes in cell values
          const cellStr = String(cell || '')
          if (cellStr.includes(',') || cellStr.includes('"') || cellStr.includes('\n')) {
            return `"${cellStr.replace(/"/g, '""')}"`
          }
          return cellStr
        }).join(','))
      ].join('\n')

      // Add BOM for Excel UTF-8 support
      const BOM = '\uFEFF'
      const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' })
      const link = document.createElement('a')
      const url = URL.createObjectURL(blob)
      
      link.setAttribute('href', url)
      link.setAttribute('download', `Joy-Billiards-Leaderboard-${division}-${period}-${new Date().toISOString().split('T')[0]}.csv`)
      link.style.visibility = 'hidden'
      
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      
      alert(`✅ Exported ${rankedPlayers.value.length} players to CSV`)
    }

    // Export to Excel (using CSV format that Excel can open)
    const exportToExcel = () => {
      // For now, we'll use CSV format which Excel can open
      // If you want true .xlsx format, we can add xlsx library later
      exportToCSV()
      
      // Future: Implement true Excel export using xlsx library
      // const XLSX = require('xlsx')
      // const ws = XLSX.utils.json_to_sheet(data)
      // const wb = XLSX.utils.book_new()
      // XLSX.utils.book_append_sheet(wb, ws, 'Leaderboard')
      // XLSX.writeFile(wb, filename)
    }

    onMounted(async () => {
      await loadCurrentUserId()
      loadLeaderboard()
    })

    return {
      loading,
      players,
      activeTab,
      divisionFilter, // 🎯 新增：组别过滤
      currentYear,
      currentMonthName,
      selectedYear,
      availableYears,
      selectedMonth,
      availableMonths,
      loadMonthlyRankings,
      rankingLevels,
      rankedPlayers,
      topThree,
      getDisplayPoints,
      getDivisionValue,
      getDivisionValueForYear,
      getDivisionMatches,
      formatRankBadge,
      formatRankName,
      getRankClass,
      calculateWinRate,
      calculateWinRateForYear,
      formatDate,
      calculateRankProgress,
      getNextRankLabel,
      loadAnnualRankings,
      getRankIcon,
      iconErrors,
      // Point History
      showHistoryModal,
      selectedPlayerHistory,
      pointHistoryList,
      loadingHistory,
      canViewHistory,
      openPointHistory,
      closeHistoryModal,
      formatHistoryDate,
      formatHistoryTime,
      calculateCumulativePoints,
      authStore,
      exportToCSV,
      exportToExcel,
      getPeriodLabel
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
/* Category Tabs (Adult/Student/All) */
.category-tabs {
  display: flex;
  gap: 0.75rem;
  justify-content: center;
  margin-bottom: 1.5rem;
  padding: 0.75rem;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}

.category-tab {
  padding: 0.75rem 2rem;
  border: 2px solid transparent;
  background: white;
  border-radius: 50px;
  font-size: 1rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
  color: #6c757d;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.category-tab:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
  color: #495057;
}

.category-tab.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: #667eea;
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
  transform: scale(1.05);
}

/* Time Period Tabs */
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
.year-selector,
.month-selector {
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

.selector-label,
.year-label {
  font-size: 1rem;
  font-weight: 600;
  color: #1a1a2e;
}

.year-select,
.month-select {
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
  min-width: 200px;
}

.year-select:hover,
.month-select:hover {
  border-color: #764ba2;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

.year-select:focus,
.month-select:focus {
  border-color: #764ba2;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

/* Export Section (Admin Only) */
.export-section {
  margin: 2rem 0;
  padding: 1.5rem;
  background: linear-gradient(135deg, rgba(156, 39, 176, 0.1) 0%, rgba(78, 205, 196, 0.1) 100%);
  border-radius: 16px;
  border: 2px solid rgba(156, 39, 176, 0.2);
  box-shadow: 0 4px 16px rgba(156, 39, 176, 0.1);
}

.export-buttons {
  display: flex;
  gap: 1rem;
  margin-bottom: 0.75rem;
  flex-wrap: wrap;
}

.export-buttons .btn {
  padding: 0.75rem 1.5rem;
  font-size: 1rem;
  font-weight: 600;
  border-radius: 12px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.export-buttons .btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.export-buttons .btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.export-buttons .btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  color: white;
}

.export-buttons .btn-success {
  background: linear-gradient(135deg, #4ECDC4 0%, #44A08D 100%);
  border: none;
  color: white;
}

.export-hint {
  margin: 0;
  font-size: 0.875rem;
  color: #6c757d;
  font-style: italic;
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

/* Top 3 Stats */
.player-stats-top3 {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.stat-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.9rem;
}

.stat-row .stat-label {
  color: #6c757d;
  font-weight: 500;
}

.stat-row .stat-value {
  color: #1a1a2e;
  font-weight: 700;
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
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-template-rows: auto auto;
    gap: 12px;
    max-width: 100%;
    margin: 0 auto;
    padding: 0 8px;
  }

  .podium-item.first {
    grid-column: 1 / 3;
    order: 1;
    width: 100%;
    max-width: none;
  }
  
  .podium-item.second {
    grid-column: 1;
    order: 2;
    width: 100%;
    max-width: none;
  }
  
  .podium-item.third {
    grid-column: 2;
    order: 3;
    width: 100%;
    max-width: none;
  }
  
  .podium-item.first .player-card {
    padding: 24px 16px;
  }
  
  .podium-item.second .player-card,
  .podium-item.third .player-card {
    padding: 16px 12px;
  }
  
  .podium-item.second .player-card h3,
  .podium-item.third .player-card h3 {
    font-size: 1rem;
    margin-bottom: 4px;
  }
  
  .podium-item.second .player-card .points,
  .podium-item.third .player-card .points {
    font-size: 0.875rem;
  }
  
  .podium-item.second .rank-badge-large,
  .podium-item.third .rank-badge-large {
    padding: 8px 12px;
    gap: 4px;
    margin-bottom: 8px;
  }

  .podium-item.second .rank-badge-large .badge-emoji,
  .podium-item.third .rank-badge-large .badge-emoji {
    font-size: 1.75rem;
  }

  .podium-item.second .rank-badge-large .badge-name,
  .podium-item.third .rank-badge-large .badge-name {
    font-size: 0.6rem;
    letter-spacing: 0.3px;
  }

  .podium-item.first .rank-badge-large {
    padding: 12px 16px;
    gap: 6px;
  }

  .podium-item.first .rank-badge-large .badge-emoji {
    font-size: 2.5rem;
  }

  .podium-item.first .rank-badge-large .badge-name {
    font-size: 0.75rem;
  }
  
  .podium-item.second .trophy,
  .podium-item.third .trophy {
    font-size: 2rem;
    margin-bottom: 8px;
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
  gap: 8px;
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

.rank-badge-large .badge-emoji {
  font-size: 2.5rem;
  line-height: 1;
}

.rank-badge-large .badge-name {
  font-size: 0.75rem;
  font-weight: 700;
  text-align: center;
  line-height: 1.2;
  color: inherit;
  text-transform: uppercase;
  letter-spacing: 0.5px;
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

/* Rank icon image styles */
.rank-badge-large .badge-icon,
.badge-icon {
  width: 2.5rem;
  height: 2.5rem;
  object-fit: contain;
  display: block;
  margin: 0 auto 0.5rem;
}

.rank-badge-large .badge-icon {
  width: 3rem;
  height: 3rem;
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

/* New Classic Leaderboard Style */
.player-rank-card-new {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 1.25rem 1.5rem;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-radius: 12px;
  border-left: 6px solid #dee2e6;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  margin-bottom: 0.75rem;
}

.player-rank-card-new:hover {
  transform: translateX(4px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}

.player-rank-card-new.rank-first {
  border-left-color: #FFD700;
  background: linear-gradient(135deg, #FFF9E6 0%, #FFEDD5 100%);
  box-shadow: 0 4px 16px rgba(255, 215, 0, 0.3);
}

.player-rank-card-new.rank-second {
  border-left-color: #C0C0C0;
  background: linear-gradient(135deg, #F0F4F8 0%, #E2E8F0 100%);
  box-shadow: 0 4px 16px rgba(192, 192, 192, 0.3);
}

.player-rank-card-new.rank-third {
  border-left-color: #CD7F32;
  background: linear-gradient(135deg, #FEF3E2 0%, #FCE7CC 100%);
  box-shadow: 0 4px 16px rgba(205, 127, 50, 0.3);
}

/* Rank Number - Large and Prominent */
.rank-number-large {
  min-width: 80px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.25rem;
}

.rank-text-large {
  font-size: 2.5rem;
  font-weight: 900;
  color: #1a1a2e;
  line-height: 1;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.rank-number-large.rank-first .rank-text-large {
  color: #FFD700;
  text-shadow: 0 2px 8px rgba(255, 215, 0, 0.5);
}

.rank-number-large.rank-second .rank-text-large {
  color: #C0C0C0;
  text-shadow: 0 2px 8px rgba(192, 192, 192, 0.5);
}

.rank-number-large.rank-third .rank-text-large {
  color: #CD7F32;
  text-shadow: 0 2px 8px rgba(205, 127, 50, 0.5);
}

.rank-medal {
  font-size: 2rem;
  line-height: 1;
}

/* Player Info Main */
.player-info-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.rank-badge-compact {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.25rem 0.75rem;
  border-radius: 8px;
  background: rgba(102, 126, 234, 0.1);
  width: fit-content;
  margin-bottom: 0.25rem;
}

.badge-icon-small {
  width: 24px;
  height: 24px;
  object-fit: contain;
}

.badge-emoji-small {
  font-size: 1.25rem;
}

.player-name-large {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1a1a2e;
  line-height: 1.2;
}

.player-stats-row {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  margin-top: 0.25rem;
}

.stat-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.375rem 0.75rem;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 6px;
  font-size: 0.875rem;
}

.stat-badge .stat-label {
  color: #6c757d;
  font-weight: 500;
}

.stat-badge .stat-value {
  color: #1a1a2e;
  font-weight: 700;
}

.stat-badge.highlight {
  background: rgba(255, 193, 7, 0.15);
  border: 1px solid rgba(255, 193, 7, 0.3);
}

.stat-badge.highlight .stat-value {
  color: #f57c00;
}

/* Points Section Large */
.points-section-large {
  text-align: right;
  min-width: 120px;
}

.points-value-large {
  font-size: 2.25rem;
  font-weight: 900;
  color: #667eea;
  line-height: 1;
  text-shadow: 0 2px 4px rgba(102, 126, 234, 0.2);
}

.points-label-small {
  font-size: 0.75rem;
  color: #6c757d;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-weight: 600;
  margin-top: 0.25rem;
}

/* Responsive for new layout */
@media (max-width: 768px) {
  .player-rank-card-new {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
    padding: 1rem;
  }

  .rank-number-large {
    flex-direction: row;
    gap: 0.5rem;
    width: 100%;
    justify-content: flex-start;
  }

  .rank-text-large {
    font-size: 2rem;
  }

  .player-info-main {
    width: 100%;
  }

  .points-section-large {
    width: 100%;
    text-align: left;
  }

  .points-value-large {
    font-size: 1.75rem;
  }

  .player-stats-row {
    flex-direction: column;
    gap: 0.5rem;
  }
}

/* History Button */
.btn-history {
  margin-top: 0.5rem;
  padding: 0.375rem 0.75rem;
  background: rgba(102, 126, 234, 0.1);
  border: 1px solid rgba(102, 126, 234, 0.3);
  border-radius: 6px;
  color: #667eea;
  font-size: 0.75rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-history:hover {
  background: rgba(102, 126, 234, 0.2);
  border-color: #667eea;
  transform: translateY(-1px);
}

/* Modal Styles */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 2000;
  padding: 1rem;
}

.modal-content {
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  max-width: 90%;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 2px solid #dee2e6;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 700;
  color: #1a1a2e;
}

.modal-body {
  padding: 1.5rem;
}

/* Point History Modal */
.history-modal {
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.history-summary {
  display: flex;
  gap: 1.5rem;
  padding: 1.5rem;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-radius: 12px;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
}

.summary-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.summary-label {
  font-size: 0.875rem;
  color: #6c757d;
  font-weight: 500;
}

.summary-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1a1a2e;
}

.summary-value.positive {
  color: #28a745;
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.history-item {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 1rem 1.25rem;
  background: #f8f9fa;
  border-radius: 12px;
  border-left: 4px solid #dee2e6;
  transition: all 0.3s ease;
}

.history-item:hover {
  background: #e9ecef;
  transform: translateX(4px);
}

.history-item.positive {
  border-left-color: #28a745;
  background: linear-gradient(135deg, #f0f9f4 0%, #e8f5e9 100%);
}

.history-item.negative {
  border-left-color: #dc3545;
  background: linear-gradient(135deg, #fff5f5 0%, #ffeaea 100%);
}

.history-date {
  min-width: 120px;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.date-main {
  font-size: 0.875rem;
  font-weight: 700;
  color: #1a1a2e;
}

.date-time {
  font-size: 0.75rem;
  color: #6c757d;
}

.history-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.history-reason {
  font-size: 1rem;
  font-weight: 600;
  color: #1a1a2e;
}

.history-meta {
  display: flex;
  gap: 1rem;
  font-size: 0.875rem;
  color: #6c757d;
}

.meta-item {
  padding: 0.25rem 0.5rem;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 4px;
}

.history-points {
  min-width: 120px;
  text-align: right;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.points-change {
  font-size: 1.5rem;
  font-weight: 900;
  line-height: 1;
}

.points-change.positive {
  color: #28a745;
}

.points-change.negative {
  color: #dc3545;
}

.points-cumulative {
  font-size: 0.75rem;
  color: #6c757d;
  font-weight: 500;
}

@media (max-width: 768px) {
  .history-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }

  .history-date {
    min-width: auto;
    width: 100%;
  }

  .history-points {
    min-width: auto;
    width: 100%;
    text-align: left;
  }

  .history-summary {
    flex-direction: column;
    gap: 1rem;
  }
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

