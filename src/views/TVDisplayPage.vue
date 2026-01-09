<template>
  <div class="tv-display-page">
    <!-- Header -->
    <div class="tv-header">
      <div class="tv-logo">
        <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards" class="logo-img">
        <h1 class="tv-title">Joy Billiards Tournament System</h1>
      </div>
      <div class="tv-time">
        <div class="current-date">{{ currentDate }}</div>
        <div class="current-time">{{ currentTime }}</div>
      </div>
    </div>

    <!-- Main Content Area -->
    <div class="tv-main-content">
      <!-- Left Side: Leaderboard List -->
      <div class="tv-leaderboard-section">
        <div class="section-header">
          <h2 class="section-title">
            <span class="division-icon">{{ divisionFilter === 'pro' ? '👔' : '🎓' }}</span>
            {{ divisionFilter === 'pro' ? 'PRO' : 'STUDENT' }} DIVISION LEADERBOARD
          </h2>
          <div class="year-badge">{{ displayYear }}</div>
        </div>

        <!-- Top 3 Horizontal Compact -->
        <div class="tv-top3-compact">
          <div class="top3-item" v-if="topThree[0]">
            <div class="top3-rank">🥇</div>
            <div class="top3-content">
              <div class="top3-name">{{ topThree[0].name }}</div>
              <div class="top3-points">{{ getDisplayPoints(topThree[0], displayYear) }}pts</div>
              <div class="top3-stats">
                <span>W/L: {{ getDivisionValueForYear(topThree[0], divisionFilter, 'wins', displayYear) }}/{{ getDivisionValueForYear(topThree[0], divisionFilter, 'losses', displayYear) }}</span>
                <span>Win: {{ calculateWinRateForYear(topThree[0], displayYear) }}%</span>
                <span>B&R: {{ getDivisionValueForYear(topThree[0], divisionFilter, 'break_and_run_count', displayYear) }}</span>
              </div>
            </div>
          </div>
          <div class="top3-item" v-if="topThree[1]">
            <div class="top3-rank">🥈</div>
            <div class="top3-content">
              <div class="top3-name">{{ topThree[1].name }}</div>
              <div class="top3-points">{{ getDisplayPoints(topThree[1], displayYear) }}pts</div>
              <div class="top3-stats">
                <span>W/L: {{ getDivisionValueForYear(topThree[1], divisionFilter, 'wins', displayYear) }}/{{ getDivisionValueForYear(topThree[1], divisionFilter, 'losses', displayYear) }}</span>
                <span>Win: {{ calculateWinRateForYear(topThree[1], displayYear) }}%</span>
                <span>B&R: {{ getDivisionValueForYear(topThree[1], divisionFilter, 'break_and_run_count', displayYear) }}</span>
              </div>
            </div>
          </div>
          <div class="top3-item" v-if="topThree[2]">
            <div class="top3-rank">🥉</div>
            <div class="top3-content">
              <div class="top3-name">{{ topThree[2].name }}</div>
              <div class="top3-points">{{ getDisplayPoints(topThree[2], displayYear) }}pts</div>
              <div class="top3-stats">
                <span>W/L: {{ getDivisionValueForYear(topThree[2], divisionFilter, 'wins', displayYear) }}/{{ getDivisionValueForYear(topThree[2], divisionFilter, 'losses', displayYear) }}</span>
                <span>Win: {{ calculateWinRateForYear(topThree[2], displayYear) }}%</span>
                <span>B&R: {{ getDivisionValueForYear(topThree[2], divisionFilter, 'break_and_run_count', displayYear) }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Top 10 List (Full List) -->
        <div class="tv-leaderboard-list">
          <div 
            class="leaderboard-item"
            v-for="(player, index) in players4to10"
            :key="player.id"
            :class="{ 'highlight': index < 3 }"
          >
            <div class="rank-number">{{ index + 4 }}</div>
            <div class="player-info">
              <div class="player-name">{{ player.name }}</div>
              <div class="player-stats">
                <span>{{ getDisplayPoints(player, displayYear) }} pts</span>
                <span>W/L: {{ getDivisionValueForYear(player, divisionFilter, 'wins', displayYear) }}/{{ getDivisionValueForYear(player, divisionFilter, 'losses', displayYear) }}</span>
                <span>Win: {{ calculateWinRateForYear(player, displayYear) }}%</span>
                <span>B&R: {{ getDivisionValueForYear(player, divisionFilter, 'break_and_run_count', displayYear) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Side: Highlights -->
      <div class="tv-highlights-section">
        <div class="section-header">
          <h2 class="section-title">🌟 WEEKLY HIGHLIGHTS</h2>
        </div>

        <!-- Highlight Cards -->
        <div class="highlights-grid">
          <!-- Best Performance -->
          <div class="highlight-card best-performance">
            <div class="highlight-icon">🏆</div>
            <div class="highlight-title">Best Performance</div>
            <div class="highlight-player" v-if="bestPerformance">
              <div class="highlight-name">{{ bestPerformance.name }}</div>
              <div class="highlight-stats">
                <div>Win Rate: <strong>{{ calculateWinRateForYear(bestPerformance, displayYear) }}%</strong></div>
                <div>Points: <strong>{{ getDisplayPoints(bestPerformance, displayYear) }}</strong></div>
                <div>Rank: <strong>#{{ getPlayerRank(bestPerformance) }}</strong></div>
              </div>
            </div>
          </div>

          <!-- Most Break & Run -->
          <div class="highlight-card most-br">
            <div class="highlight-icon">🎯</div>
            <div class="highlight-title">Most Break & Run</div>
            <div class="highlight-player" v-if="mostBreakAndRun">
              <div class="highlight-name">{{ mostBreakAndRun.name }}</div>
              <div class="highlight-stats">
                <div>B&R: <strong>{{ getDivisionValueForYear(mostBreakAndRun, divisionFilter, 'break_and_run_count', displayYear) }}</strong></div>
                <div>Total: <strong>{{ getDivisionValue(mostBreakAndRun, divisionFilter, 'break_and_run_count') }}</strong></div>
              </div>
            </div>
          </div>

          <!-- Fastest Riser -->
          <div class="highlight-card fastest-riser">
            <div class="highlight-icon">📈</div>
            <div class="highlight-title">Fastest Riser</div>
            <div class="highlight-player" v-if="fastestRiser">
              <div class="highlight-name">{{ fastestRiser.name }}</div>
              <div class="highlight-stats">
                <div>This Month: <strong>+{{ getCurrentMonthPoints(fastestRiser) }} pts</strong></div>
                <div v-if="getPlayerRank(fastestRiser) > 0">Rank: <strong>#{{ getPlayerRank(fastestRiser) }}</strong></div>
                <div v-else>Points: <strong>{{ getDisplayPoints(fastestRiser, displayYear) }} pts</strong></div>
              </div>
            </div>
            <div class="highlight-empty" v-else>
              <div class="empty-text">No Data</div>
            </div>
          </div>

          <!-- Winning Streak -->
          <div class="highlight-card winning-streak">
            <div class="highlight-icon">⚡</div>
            <div class="highlight-title">Winning Streak</div>
            <div class="highlight-player" v-if="winningStreak">
              <div class="highlight-name">{{ winningStreak.name }}</div>
              <div class="highlight-stats">
                <div>Wins: <strong>{{ getDivisionValueForYear(winningStreak, divisionFilter, 'wins', displayYear) }}</strong></div>
                <div>Win Rate: <strong>{{ calculateWinRateForYear(winningStreak, displayYear) }}%</strong></div>
              </div>
            </div>
            <div class="highlight-empty" v-else>
              <div class="empty-text">No Data</div>
            </div>
          </div>

          <!-- Most Events -->
          <div class="highlight-card most-events">
            <div class="highlight-icon">📅</div>
            <div class="highlight-title">Most Active</div>
            <div class="highlight-player" v-if="mostActive">
              <div class="highlight-name">{{ mostActive.name }}</div>
              <div class="highlight-stats">
                <div>Events: <strong>{{ getDivisionValueForYear(mostActive, divisionFilter, 'tournaments_played', displayYear) }}</strong></div>
                <div>This Year: <strong>{{ mostActive.tournaments_played_current_year || 0 }}</strong></div>
              </div>
            </div>
            <div class="highlight-empty" v-else>
              <div class="empty-text">No Data</div>
            </div>
          </div>

          <!-- Top Win Rate -->
          <div class="highlight-card top-winrate">
            <div class="highlight-icon">💯</div>
            <div class="highlight-title">Highest Win Rate</div>
            <div class="highlight-player" v-if="topWinRate">
              <div class="highlight-name">{{ topWinRate.name }}</div>
              <div class="highlight-stats">
                <div>Win Rate: <strong>{{ calculateWinRateForYear(topWinRate, displayYear) }}%</strong></div>
                <div>W/L: <strong>{{ getDivisionValueForYear(topWinRate, divisionFilter, 'wins', displayYear) }}/{{ getDivisionValueForYear(topWinRate, divisionFilter, 'losses', displayYear) }}</strong></div>
              </div>
            </div>
            <div class="highlight-empty" v-else>
              <div class="empty-text">No Data</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Footer Stats -->
    <div class="tv-footer">
      <div class="footer-stat">
        <span class="stat-icon">👥</span>
        <span class="stat-label">Total Players:</span>
        <span class="stat-value">{{ totalPlayers }}</span>
      </div>
      <div class="footer-stat">
        <span class="stat-icon">🎯</span>
        <span class="stat-label">Total Matches:</span>
        <span class="stat-value">{{ totalMatches }}</span>
      </div>
      <div class="footer-stat">
        <span class="stat-icon">🏆</span>
        <span class="stat-label">Total Events:</span>
        <span class="stat-value">{{ totalEvents }}</span>
      </div>
      <div class="footer-stat">
        <span class="stat-icon">🎯</span>
        <span class="stat-label">Total B&R:</span>
        <span class="stat-value">{{ totalBreakAndRun }}</span>
      </div>
      <div class="footer-stat">
        <span class="stat-label">Last Updated:</span>
        <span class="stat-value">{{ lastUpdateTime }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { supabase } from '../config/supabase'
import { useAuthStore } from '../stores/authStore'

const authStore = useAuthStore()

// Time display
const currentDate = ref('')
const currentTime = ref('')
const lastUpdateTime = ref('')

// Data
const loading = ref(true)
const players = ref([])
const yearStats = ref([])
const pointHistory = ref([])
const divisionFilter = ref('pro') // 'pro' or 'student'
const currentYear = new Date().getFullYear()
const displayYear = ref(currentYear) // Currently displayed year (2026 or 2025)

// Year rotation
const yearRotationInterval = ref(null)
const yearDisplayDuration = 30000 // Show each year for 30 seconds

// Scrolling state
const scrollIndex = ref(0)
const scrollInterval = ref(null)

// Auto page scroll state
const pageScrollInterval = ref(null)
const isScrollingDown = ref(true)
const scrollSpeed = 30 // pixels per scroll step (slower)
const scrollStepInterval = 150 // milliseconds between scroll steps (slower)
const pauseAtEnds = 3000 // pause 3 seconds at top/bottom

// Computed: Top 3
const topThree = computed(() => {
  const filtered = rankedPlayers.value.filter(p => {
    const points = getDisplayPoints(p, displayYear.value)
    return points > 0
  })
  return filtered.slice(0, 3)
})

// Computed: Players 4-10 for scrolling
const players4to10 = computed(() => {
  const filtered = rankedPlayers.value.filter(p => {
    const points = getDisplayPoints(p, displayYear.value)
    return points > 0
  })
  return filtered.slice(3, 10)
})

// Displayed players - Show all items (full page scroll)
const displayedPlayers = computed(() => {
  return players4to10.value // Show all players, use full page scroll
})

// Computed: Ranked players (based on displayYear)
const rankedPlayers = computed(() => {
  return players.value
    .filter(player => {
      const points = getDisplayPoints(player, displayYear.value)
      return points > 0
    })
    .sort((a, b) => {
      const aPoints = getDisplayPoints(a, displayYear.value)
      const bPoints = getDisplayPoints(b, displayYear.value)
      return bPoints - aPoints
    })
})

// Highlights computed
const bestPerformance = computed(() => {
  if (rankedPlayers.value.length === 0) return null
  return rankedPlayers.value[0] // Top ranked player
})

const mostBreakAndRun = computed(() => {
  if (players.value.length === 0) return null
  const result = players.value.reduce((max, player) => {
    const currentBR = getDivisionValueForYear(player, divisionFilter.value, 'break_and_run_count', displayYear.value)
    const maxBR = getDivisionValueForYear(max, divisionFilter.value, 'break_and_run_count', displayYear.value)
    return currentBR > maxBR ? player : max
  }, players.value[0])
  // Only return if B&R > 0
  const maxBR = getDivisionValueForYear(result, divisionFilter.value, 'break_and_run_count', displayYear.value)
  return maxBR > 0 ? result : null
})

const fastestRiser = computed(() => {
  // Find player with most points gained this month in current division
  if (players.value.length === 0) return null
  
  // Only consider players who have points in current division and year
  const eligiblePlayers = players.value.filter(player => {
    const points = getDisplayPoints(player, displayYear.value)
    return points > 0
  })
  
  if (eligiblePlayers.length === 0) return null
  
  const result = eligiblePlayers.reduce((max, player) => {
    const currentMonthPoints = getCurrentMonthPoints(player)
    const maxMonthPoints = getCurrentMonthPoints(max)
    return currentMonthPoints > maxMonthPoints ? player : max
  }, eligiblePlayers[0])
  
  // Only return if points gained > 0
  const maxPoints = getCurrentMonthPoints(result)
  return maxPoints > 0 ? result : null
})

const winningStreak = computed(() => {
  // Find player with highest win rate and most wins
  if (rankedPlayers.value.length === 0) return null
  const result = rankedPlayers.value.reduce((max, player) => {
    const currentWins = getDivisionValueForYear(player, divisionFilter.value, 'wins', displayYear.value)
    const maxWins = getDivisionValueForYear(max, divisionFilter.value, 'wins', displayYear.value)
    if (currentWins > maxWins) return player
    if (currentWins === maxWins) {
      const currentRate = parseFloat(calculateWinRateForYear(player, displayYear.value))
      const maxRate = parseFloat(calculateWinRateForYear(max, displayYear.value))
      return currentRate > maxRate ? player : max
    }
    return max
  }, rankedPlayers.value[0])
  // Only return if wins > 0
  const maxWins = getDivisionValueForYear(result, divisionFilter.value, 'wins', displayYear.value)
  return maxWins > 0 ? result : null
})

const mostActive = computed(() => {
  if (players.value.length === 0) return null
  const result = players.value.reduce((max, player) => {
    const currentEvents = getDivisionValueForYear(player, divisionFilter.value, 'tournaments_played', displayYear.value)
    const maxEvents = getDivisionValueForYear(max, divisionFilter.value, 'tournaments_played', displayYear.value)
    return currentEvents > maxEvents ? player : max
  }, players.value[0])
  // Only return if events > 0
  const maxEvents = getDivisionValueForYear(result, divisionFilter.value, 'tournaments_played', displayYear.value)
  return maxEvents > 0 ? result : null
})

const topWinRate = computed(() => {
  if (rankedPlayers.value.length === 0) return null
  const result = rankedPlayers.value.reduce((max, player) => {
    const currentRate = parseFloat(calculateWinRateForYear(player, displayYear.value))
    const maxRate = parseFloat(calculateWinRateForYear(max, displayYear.value))
    return currentRate > maxRate ? player : max
  }, rankedPlayers.value[0])
  // Only return if win rate > 0 and has matches
  const wins = getDivisionValueForYear(result, divisionFilter.value, 'wins', displayYear.value)
  const losses = getDivisionValueForYear(result, divisionFilter.value, 'losses', displayYear.value)
  const winRate = parseFloat(calculateWinRateForYear(result, displayYear.value))
  return (wins + losses > 0 && winRate > 0) ? result : null
})

// Stats
const totalPlayers = computed(() => players.value.length)
const totalMatches = computed(() => {
  return players.value.reduce((sum, player) => {
    const wins = getDivisionValueForYear(player, divisionFilter.value, 'wins', displayYear.value)
    const losses = getDivisionValueForYear(player, divisionFilter.value, 'losses', displayYear.value)
    return sum + wins + losses
  }, 0)
})
const totalEvents = computed(() => {
  return players.value.reduce((sum, player) => {
    return sum + (getDivisionValueForYear(player, divisionFilter.value, 'tournaments_played', displayYear.value) || 0)
  }, 0)
})
const totalBreakAndRun = computed(() => {
  return players.value.reduce((sum, player) => {
    return sum + (getDivisionValueForYear(player, divisionFilter.value, 'break_and_run_count', displayYear.value) || 0)
  }, 0)
})

// Helper functions
const getDivisionStatKey = (division, field) => {
  const prefix = division === 'student' ? 'student' : 'pro'
  if (field === 'break_and_run_count') {
    return `${prefix}_break_and_run_count`
  }
  return `${prefix}_${field}`
}

const getDivisionValue = (player, division, field) => {
  if (!player) return 0
  const key = getDivisionStatKey(division, field)
  return player[key] ?? 0
}

const getDivisionValueForYear = (player, division, field, year) => {
  if (!player) return 0
  
  // For Events Played, we have year-specific data
  if (field === 'tournaments_played') {
    if (year === currentYear) {
      return player.tournaments_played_current_year || 0
    }
    return player.tournaments_played || 0
  }
  
  // For wins/losses/break_and_run, use year-specific stats from user_year_stats table
  if (year === currentYear) {
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
  
  // Fallback to total stats if year-specific data not available
  return getDivisionValue(player, division, field)
}

const getDisplayPoints = (player, year = displayYear.value) => {
  if (!player) return 0
  const division = divisionFilter.value
  const divisionSuffix = division === 'pro' ? 'pro' : 'student'
  
  if (year === currentYear) {
    return player[`current_year_${divisionSuffix}_points`] || 0
  } else {
    // Calculate points for specific year from point history
    const userHistory = pointHistory.value.filter(p => 
      p.user_id === player.id && 
      p.year === year
    )
    const divisionHistory = filterByDivision(userHistory, division)
    return divisionHistory.reduce((sum, p) => sum + (p.points_change || 0), 0)
  }
}

const calculateWinRateForYear = (player, year, division = divisionFilter.value) => {
  if (!player) return '0.0'
  const wins = getDivisionValueForYear(player, division, 'wins', year)
  const losses = getDivisionValueForYear(player, division, 'losses', year)
  const total = wins + losses
  if (total === 0) return '0.0'
  return ((wins / total) * 100).toFixed(1)
}

const getPlayerRank = (player) => {
  if (!player) return 0
  const index = rankedPlayers.value.findIndex(p => p.id === player.id)
  // If player not found in ranked list, return 0 (will be handled in template)
  return index >= 0 ? index + 1 : 0
}

const getCurrentMonthPoints = (player) => {
  if (!player || !pointHistory.value) return 0
  const currentMonth = new Date().getMonth() + 1
  const userHistory = pointHistory.value.filter(p => 
    p.user_id === player.id && 
    p.year === displayYear.value && 
    p.month === currentMonth
  )
  // Filter by division
  const divisionHistory = filterByDivision(userHistory, divisionFilter.value)
  return divisionHistory.reduce((sum, p) => sum + (p.points_change || 0), 0)
}

// Filter by division helper
const filterByDivision = (history, division) => {
  if (division === 'pro') {
    return history.filter(p => {
      if (!p.reason) return false
      if (p.reason.startsWith('Pro:')) return true
      const reason = p.reason.toLowerCase()
      if (reason.includes('student')) return false
      return true
    })
  } else {
    return history.filter(p => {
      if (!p.reason) return false
      if (p.reason.startsWith('Student:')) return true
      const reason = p.reason.toLowerCase()
      if (reason.includes('student')) return true
      return false
    })
  }
}

// Load data
const loadData = async () => {
  loading.value = true
  try {
    // Reset scroll position to top when data changes
    const page = document.querySelector('.tv-display-page')
    if (page) {
      page.scrollTop = 0
      isScrollingDown.value = true
    }
    const nzDate = new Date(new Date().toLocaleString("en-US", { timeZone: "Pacific/Auckland" }))
    const currentYear = nzDate.getFullYear()
    const currentMonth = nzDate.getMonth() + 1

    // Load users
    const { data: usersData, error: usersError } = await supabase
      .from('public_users')
      .select('*')
    
    if (usersError) throw usersError

    // Load point history
    const { data: pointHistoryData, error: pointError } = await supabase
      .from('ranking_point_history')
      .select('*')
    
    if (pointError) throw pointError
    pointHistory.value = pointHistoryData || []

    // Load year stats
    const { data: yearStatsData, error: yearStatsError } = await supabase
      .from('user_year_stats')
      .select('*')
    
    if (yearStatsError) {
      console.warn('Year stats not available:', yearStatsError)
    }
    yearStats.value = yearStatsData || []

    // Count tournaments per user
    const tournamentsPerUser = {}
    const tournamentsPerUserCurrentYear = {}
    
    pointHistoryData.forEach(record => {
      const userId = record.user_id
      if (!tournamentsPerUser[userId]) {
        tournamentsPerUser[userId] = 0
      }
      tournamentsPerUser[userId]++
      
      if (record.year === currentYear) {
        if (!tournamentsPerUserCurrentYear[userId]) {
          tournamentsPerUserCurrentYear[userId] = 0
        }
        tournamentsPerUserCurrentYear[userId]++
      }
    })

    // Filter by division
    const filterByDivision = (history, division) => {
      if (division === 'pro') {
        return history.filter(p => {
          if (!p.reason) return false
          if (p.reason.startsWith('Pro:')) return true
          const reason = p.reason.toLowerCase()
          if (reason.includes('student')) return false
          return true
        })
      } else {
        return history.filter(p => {
          if (!p.reason) return false
          if (p.reason.startsWith('Student:')) return true
          const reason = p.reason.toLowerCase()
          if (reason.includes('student')) return true
          return false
        })
      }
    }

    // Process players
    const playersWithPoints = usersData.map(user => {
      const userHistory = pointHistoryData.filter(p => p.user_id === user.id)
      const proHistory = filterByDivision(userHistory, 'pro')
      const studentHistory = filterByDivision(userHistory, 'student')

      // Calculate current year points
      const proYearPoints = proHistory
        .filter(p => p.year === currentYear)
        .reduce((sum, p) => sum + (p.points_change || 0), 0)
      
      const studentYearPoints = studentHistory
        .filter(p => p.year === currentYear)
        .reduce((sum, p) => sum + (p.points_change || 0), 0)

      // Get year-specific stats
      const userYearStats = yearStatsData?.filter(s => s.user_id === user.id) || []
      const proYearStats = userYearStats.filter(s => s.division === 'pro' && s.year === currentYear)
      const studentYearStats = userYearStats.filter(s => s.division === 'student' && s.year === currentYear)

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

      return {
        ...user,
        current_year_pro_points: proYearPoints,
        current_year_student_points: studentYearPoints,
        tournaments_played: tournamentsPerUser[user.id] || 0,
        tournaments_played_current_year: tournamentsPerUserCurrentYear[user.id] || 0,
        pro_current_year_wins: proCurrentYearStats.wins,
        pro_current_year_losses: proCurrentYearStats.losses,
        pro_current_year_break_and_run: proCurrentYearStats.break_and_run_count,
        student_current_year_wins: studentCurrentYearStats.wins,
        student_current_year_losses: studentCurrentYearStats.losses,
        student_current_year_break_and_run: studentCurrentYearStats.break_and_run_count
      }
    })

    players.value = playersWithPoints
    lastUpdateTime.value = new Date().toLocaleTimeString('en-NZ', { 
      timeZone: 'Pacific/Auckland',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (err) {
    console.error('Error loading TV display data:', err)
  } finally {
    loading.value = false
  }
}

// Update time
const updateTime = () => {
  const now = new Date(new Date().toLocaleString("en-US", { timeZone: "Pacific/Auckland" }))
  currentDate.value = now.toLocaleDateString('en-NZ', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
  currentTime.value = now.toLocaleTimeString('en-NZ', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

// Auto scroll for leaderboard and highlights lists
const startAutoPageScroll = () => {
  let pauseTimeout = null
  let isPaused = false
  
  const scrollLists = () => {
    if (isPaused) return
    
    const leaderboardList = document.querySelector('.tv-leaderboard-list')
    const highlightsGrid = document.querySelector('.highlights-grid')
    
    let leaderboardAtEnd = false
    let highlightsAtEnd = false
    
    // Check if leaderboard needs to pause
    if (leaderboardList) {
      const leaderboardMaxScroll = leaderboardList.scrollHeight - leaderboardList.clientHeight
      const leaderboardCurrentScroll = leaderboardList.scrollTop
      
      if (isScrollingDown.value) {
        leaderboardAtEnd = leaderboardCurrentScroll >= leaderboardMaxScroll - 10
      } else {
        leaderboardAtEnd = leaderboardCurrentScroll <= 10
      }
    }
    
    // Check if highlights needs to pause
    if (highlightsGrid) {
      const highlightsMaxScroll = highlightsGrid.scrollHeight - highlightsGrid.clientHeight
      const highlightsCurrentScroll = highlightsGrid.scrollTop
      
      if (isScrollingDown.value) {
        highlightsAtEnd = highlightsCurrentScroll >= highlightsMaxScroll - 10
      } else {
        highlightsAtEnd = highlightsCurrentScroll <= 10
      }
    }
    
    // If either section reaches the end, pause both
    if (leaderboardAtEnd || highlightsAtEnd) {
      isPaused = true
      isScrollingDown.value = !isScrollingDown.value
      pauseTimeout = setTimeout(() => {
        isPaused = false
      }, pauseAtEnds)
      return
    }
    
    // Scroll both sections
    if (leaderboardList && !leaderboardAtEnd) {
      if (isScrollingDown.value) {
        leaderboardList.scrollTop += scrollSpeed
      } else {
        leaderboardList.scrollTop -= scrollSpeed
      }
    }
    
    if (highlightsGrid && !highlightsAtEnd) {
      if (isScrollingDown.value) {
        highlightsGrid.scrollTop += scrollSpeed
      } else {
        highlightsGrid.scrollTop -= scrollSpeed
      }
    }
  }
  
  pageScrollInterval.value = setInterval(scrollLists, scrollStepInterval)
}

// Auto refresh data
const startAutoRefresh = () => {
  setInterval(() => {
    loadData()
  }, 30000) // Refresh every 30 seconds
}

// Auto switch division
const startDivisionSwitch = () => {
  setInterval(() => {
    divisionFilter.value = divisionFilter.value === 'pro' ? 'student' : 'pro'
    loadData()
  }, 120000) // Switch every 2 minutes
}

// Auto rotate years (2026 -> 2025 -> 2026...)
const startYearRotation = () => {
  yearRotationInterval.value = setInterval(() => {
    if (displayYear.value === currentYear) {
      displayYear.value = 2025
    } else {
      displayYear.value = currentYear
    }
  }, yearDisplayDuration) // Switch every 30 seconds
}

// Debug function to show 2025 highlights data
const debug2025Highlights = () => {
  const year2025 = 2025
  console.log('=== 2025 Highlights Data Debug ===')
  console.log('Division:', divisionFilter.value)
  console.log('')
  
  // Best Performance
  const ranked2025 = players.value
    .filter(player => {
      const points = getDisplayPoints(player, year2025)
      return points > 0
    })
    .sort((a, b) => {
      const aPoints = getDisplayPoints(a, year2025)
      const bPoints = getDisplayPoints(b, year2025)
      return bPoints - aPoints
    })
  const bestPerf = ranked2025[0]
  console.log('🏆 Best Performance:')
  if (bestPerf) {
    console.log('  Name:', bestPerf.name)
    console.log('  Points:', getDisplayPoints(bestPerf, year2025))
    console.log('  Win Rate:', calculateWinRateForYear(bestPerf, year2025) + '%')
    console.log('  W/L:', getDivisionValueForYear(bestPerf, divisionFilter.value, 'wins', year2025) + '/' + getDivisionValueForYear(bestPerf, divisionFilter.value, 'losses', year2025))
  } else {
    console.log('  No Data')
  }
  console.log('')
  
  // Most Break & Run
  const mostBR = players.value.reduce((max, player) => {
    const currentBR = getDivisionValueForYear(player, divisionFilter.value, 'break_and_run_count', year2025)
    const maxBR = getDivisionValueForYear(max, divisionFilter.value, 'break_and_run_count', year2025)
    return currentBR > maxBR ? player : max
  }, players.value[0])
  const maxBR = getDivisionValueForYear(mostBR, divisionFilter.value, 'break_and_run_count', year2025)
  console.log('🎯 Most Break & Run:')
  if (maxBR > 0 && mostBR) {
    console.log('  Name:', mostBR.name)
    console.log('  B&R (2025):', maxBR)
    console.log('  Total B&R:', getDivisionValue(mostBR, divisionFilter.value, 'break_and_run_count'))
  } else {
    console.log('  No Data (max B&R:', maxBR + ')')
  }
  console.log('')
  
  // Fastest Riser (This Month - but for 2025, we'll check all months)
  const fastestRiser2025 = players.value.reduce((max, player) => {
    const userHistory = pointHistory.value.filter(p => 
      p.user_id === player.id && 
      p.year === year2025
    )
    const divisionHistory = filterByDivision(userHistory, divisionFilter.value)
    const yearPoints = divisionHistory.reduce((sum, p) => sum + (p.points_change || 0), 0)
    const maxHistory = pointHistory.value.filter(p => 
      p.user_id === max.id && 
      p.year === year2025
    )
    const maxDivisionHistory = filterByDivision(maxHistory, divisionFilter.value)
    const maxYearPoints = maxDivisionHistory.reduce((sum, p) => sum + (p.points_change || 0), 0)
    return yearPoints > maxYearPoints ? player : max
  }, players.value[0])
  const fastestPoints = pointHistory.value
    .filter(p => p.user_id === fastestRiser2025.id && p.year === year2025)
    .filter(p => {
      const divisionHistory = filterByDivision([p], divisionFilter.value)
      return divisionHistory.length > 0
    })
    .reduce((sum, p) => sum + (p.points_change || 0), 0)
  console.log('📈 Fastest Riser (2025):')
  if (fastestPoints > 0 && fastestRiser2025) {
    console.log('  Name:', fastestRiser2025.name)
    console.log('  Points Gained (2025):', fastestPoints)
  } else {
    console.log('  No Data (max points:', fastestPoints + ')')
  }
  console.log('')
  
  // Winning Streak
  const winningStreak2025 = ranked2025.reduce((max, player) => {
    const currentWins = getDivisionValueForYear(player, divisionFilter.value, 'wins', year2025)
    const maxWins = getDivisionValueForYear(max, divisionFilter.value, 'wins', year2025)
    if (currentWins > maxWins) return player
    if (currentWins === maxWins) {
      const currentRate = parseFloat(calculateWinRateForYear(player, year2025))
      const maxRate = parseFloat(calculateWinRateForYear(max, year2025))
      return currentRate > maxRate ? player : max
    }
    return max
  }, ranked2025[0])
  const maxWins = winningStreak2025 ? getDivisionValueForYear(winningStreak2025, divisionFilter.value, 'wins', year2025) : 0
  console.log('⚡ Winning Streak:')
  if (maxWins > 0 && winningStreak2025) {
    console.log('  Name:', winningStreak2025.name)
    console.log('  Wins (2025):', maxWins)
    console.log('  Win Rate:', calculateWinRateForYear(winningStreak2025, year2025) + '%')
  } else {
    console.log('  No Data (max wins:', maxWins + ')')
  }
  console.log('')
  
  // Most Active
  const mostActive2025 = players.value.reduce((max, player) => {
    const currentEvents = getDivisionValueForYear(player, divisionFilter.value, 'tournaments_played', year2025)
    const maxEvents = getDivisionValueForYear(max, divisionFilter.value, 'tournaments_played', year2025)
    return currentEvents > maxEvents ? player : max
  }, players.value[0])
  const maxEvents = mostActive2025 ? getDivisionValueForYear(mostActive2025, divisionFilter.value, 'tournaments_played', year2025) : 0
  console.log('📅 Most Active:')
  if (maxEvents > 0 && mostActive2025) {
    console.log('  Name:', mostActive2025.name)
    console.log('  Events (2025):', maxEvents)
  } else {
    console.log('  No Data (max events:', maxEvents + ')')
  }
  console.log('')
  
  // Top Win Rate
  const topWinRate2025 = ranked2025.reduce((max, player) => {
    const currentRate = parseFloat(calculateWinRateForYear(player, year2025))
    const maxRate = parseFloat(calculateWinRateForYear(max, year2025))
    return currentRate > maxRate ? player : max
  }, ranked2025[0])
  const topWins = topWinRate2025 ? getDivisionValueForYear(topWinRate2025, divisionFilter.value, 'wins', year2025) : 0
  const topLosses = topWinRate2025 ? getDivisionValueForYear(topWinRate2025, divisionFilter.value, 'losses', year2025) : 0
  const topRate = topWinRate2025 ? parseFloat(calculateWinRateForYear(topWinRate2025, year2025)) : 0
  console.log('💯 Highest Win Rate:')
  if ((topWins + topLosses > 0 && topRate > 0) && topWinRate2025) {
    console.log('  Name:', topWinRate2025.name)
    console.log('  Win Rate:', topRate + '%')
    console.log('  W/L:', topWins + '/' + topLosses)
  } else {
    console.log('  No Data (wins:', topWins + ', losses:', topLosses + ', rate:', topRate + '%)')
  }
  console.log('')
  console.log('=== End Debug ===')
}

onMounted(() => {
  updateTime()
  setInterval(updateTime, 1000) // Update time every second
  
  // Initialize display year to current year
  displayYear.value = currentYear
  
  loadData().then(() => {
    // Debug 2025 highlights
    setTimeout(() => {
      debug2025Highlights()
    }, 1000)
    
    // Start auto scroll after data is loaded
    setTimeout(() => {
      startAutoPageScroll()
    }, 2000) // Wait 2 seconds for page to render
  })
  startAutoRefresh()
  startDivisionSwitch()
  startYearRotation()

  // Try to enter fullscreen
  if (document.documentElement.requestFullscreen) {
    document.documentElement.requestFullscreen().catch(() => {
      console.log('Fullscreen not available')
    })
  }
})

onUnmounted(() => {
  if (scrollInterval.value) {
    clearInterval(scrollInterval.value)
  }
  if (pageScrollInterval.value) {
    clearInterval(pageScrollInterval.value)
  }
  if (yearRotationInterval.value) {
    clearInterval(yearRotationInterval.value)
  }
})
</script>

<style scoped>
.tv-display-page {
  width: 100vw;
  height: 100vh;
  background: linear-gradient(135deg, #0a0a0a 0%, #1a1a2e 50%, #16213e 100%);
  color: #FFFFFF;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  font-family: 'Arial', sans-serif;
  position: relative;
}

/* Header */
.tv-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 40px;
  background: rgba(0, 0, 0, 0.5);
  border-bottom: 3px solid #FFD700;
  z-index: 10;
}

.tv-logo {
  display: flex;
  align-items: center;
  gap: 20px;
}

.logo-img {
  height: 60px;
  width: auto;
}

.tv-title {
  font-size: 48px;
  font-weight: bold;
  margin: 0;
  background: linear-gradient(135deg, #FFD700 0%, #FF6B35 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.tv-time {
  text-align: right;
  font-size: 32px;
}

.current-date {
  font-size: 28px;
  color: #E0E0E0;
  margin-bottom: 5px;
}

.current-time {
  font-size: 48px;
  font-weight: bold;
  color: #FFD700;
  font-family: 'Courier New', monospace;
}

/* Main Content */
.tv-main-content {
  flex: 1;
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 30px;
  padding: 30px 40px;
  overflow: hidden;
  min-height: 0;
}

/* Leaderboard Section */
.tv-leaderboard-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
  min-height: 0;
  overflow: hidden;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.section-title {
  font-size: 42px;
  font-weight: bold;
  margin: 0;
  color: #FFD700;
  display: flex;
  align-items: center;
  gap: 15px;
}

.division-icon {
  font-size: 48px;
}

.year-badge {
  background: #FF6B35;
  color: #FFFFFF;
  padding: 10px 20px;
  border-radius: 8px;
  font-size: 32px;
  font-weight: bold;
}

/* Top 3 Compact Horizontal Layout (Scheme B) */
.tv-top3-compact {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
  margin: 20px 0;
  padding: 20px;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 12px;
  border: 2px solid rgba(255, 215, 0, 0.3);
}

.top3-item {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  transition: all 0.3s ease;
}

.top3-item:hover {
  background: rgba(255, 215, 0, 0.1);
  transform: translateY(-2px);
}

.top3-rank {
  font-size: 48px;
  min-width: 60px;
  text-align: center;
}

.top3-content {
  flex: 1;
}

.top3-name {
  font-size: 32px;
  font-weight: bold;
  color: #FFD700;
  margin-bottom: 8px;
}

.top3-points {
  font-size: 36px;
  font-weight: bold;
  color: #FF6B35;
  margin-bottom: 8px;
}

.top3-stats {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 20px;
  color: #E0E0E0;
}

/* Podium (Legacy - kept for compatibility) */
.tv-podium {
  display: flex;
  justify-content: center;
  align-items: flex-end;
  gap: 20px;
  margin: 20px 0;
  min-height: 300px;
}

.podium-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex: 1;
  max-width: 280px;
}

.podium-item.first {
  order: 2;
}

.podium-item.second {
  order: 1;
}

.podium-item.third {
  order: 3;
}

.podium-rank {
  font-size: 64px;
  margin-bottom: 10px;
  animation: pulse 2s infinite;
}

.podium-card {
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  border: 3px solid #FFD700;
  border-radius: 16px;
  padding: 20px;
  width: 100%;
  text-align: center;
  box-shadow: 0 8px 32px rgba(255, 215, 0, 0.3);
  transition: transform 0.3s ease;
}

.podium-card.champion {
  border-color: #FF6B35;
  box-shadow: 0 8px 32px rgba(255, 107, 53, 0.5);
  transform: scale(1.1);
  background: linear-gradient(135deg, #2a1a2e 0%, #26213e 100%);
}

.podium-name {
  font-size: 36px;
  font-weight: bold;
  margin-bottom: 10px;
  color: #FFD700;
}

.podium-points {
  font-size: 48px;
  font-weight: bold;
  color: #FF6B35;
  margin-bottom: 15px;
}

.podium-stats {
  display: flex;
  flex-direction: column;
  gap: 8px;
  font-size: 24px;
  color: #E0E0E0;
}

/* Leaderboard List */
.tv-leaderboard-list {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 12px;
  padding: 20px;
  min-height: 0;
}

.leaderboard-item {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 15px 20px;
  margin-bottom: 10px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border-left: 4px solid transparent;
  transition: all 0.3s ease;
  animation: slideIn 0.5s ease;
}

.leaderboard-item.highlight {
  border-left-color: #FFD700;
  background: rgba(255, 215, 0, 0.1);
}

.leaderboard-item:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateX(5px);
}

.rank-number {
  font-size: 36px;
  font-weight: bold;
  color: #FFD700;
  min-width: 50px;
  text-align: center;
}

.player-info {
  flex: 1;
}

.player-name {
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 8px;
  color: #FFFFFF;
}

.player-stats {
  display: flex;
  gap: 20px;
  font-size: 24px;
  color: #E0E0E0;
}

/* Highlights Section */
.tv-highlights-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
  min-height: 0;
  overflow: hidden;
}

.highlights-grid {
  display: flex;
  flex-direction: column;
  gap: 15px;
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  overflow-x: hidden;
}

.highlight-card {
  background: linear-gradient(135deg, rgba(26, 26, 46, 0.8) 0%, rgba(22, 33, 62, 0.8) 100%);
  border: 2px solid rgba(255, 215, 0, 0.3);
  border-radius: 12px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 15px;
  transition: all 0.3s ease;
  animation: fadeIn 0.5s ease;
}

.highlight-card:hover {
  border-color: #FFD700;
  box-shadow: 0 4px 16px rgba(255, 215, 0, 0.3);
  transform: translateY(-2px);
}

.highlight-card.best-performance {
  border-color: #FFD700;
  background: linear-gradient(135deg, rgba(255, 215, 0, 0.1) 0%, rgba(255, 107, 53, 0.1) 100%);
}

.highlight-card.most-br {
  border-color: #00FF88;
}

.highlight-card.fastest-riser {
  border-color: #4A90E2;
}

.highlight-card.winning-streak {
  border-color: #FF6B35;
}

.highlight-card.most-events {
  border-color: #9B59B6;
}

.highlight-card.top-winrate {
  border-color: #F39C12;
}

.highlight-icon {
  font-size: 48px;
  text-align: center;
}

.highlight-title {
  font-size: 28px;
  font-weight: bold;
  color: #FFD700;
  text-align: center;
}

.highlight-player {
  text-align: center;
}

.highlight-name {
  font-size: 32px;
  font-weight: bold;
  color: #FFFFFF;
  margin-bottom: 10px;
}

.highlight-stats {
  display: flex;
  flex-direction: column;
  gap: 8px;
  font-size: 24px;
  color: #E0E0E0;
}

.highlight-stats strong {
  color: #FFD700;
  font-size: 28px;
}

.highlight-empty {
  text-align: center;
  padding: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100px;
}

.empty-text {
  font-size: 48px;
  color: #888888;
  font-weight: bold;
}

/* Footer */
.tv-footer {
  display: flex;
  justify-content: space-around;
  align-items: center;
  padding: 20px 40px;
  background: rgba(0, 0, 0, 0.5);
  border-top: 3px solid #FFD700;
}

.footer-stat {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 28px;
}

.stat-icon {
  font-size: 32px;
}

.stat-label {
  color: #E0E0E0;
}

.stat-value {
  color: #FFD700;
  font-weight: bold;
  font-size: 32px;
}

/* Animations */
@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}

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

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

/* Optimized for 55" TV (1920x1080) - Landscape */
@media (min-width: 1920px) and (min-height: 1080px) {
  .tv-title {
    font-size: 72px;
  }
  
  .current-time {
    font-size: 64px;
  }
  
  .current-date {
    font-size: 36px;
  }
  
  .section-title {
    font-size: 64px;
  }
  
  .division-icon {
    font-size: 64px;
  }
  
  .year-badge {
    font-size: 40px;
    padding: 15px 30px;
  }
  
  .podium-rank {
    font-size: 80px;
  }
  
  .podium-name {
    font-size: 56px;
  }
  
  .podium-points {
    font-size: 72px;
  }
  
  .podium-stats {
    font-size: 32px;
  }
  
  .player-name {
    font-size: 48px;
  }
  
  .player-stats {
    font-size: 32px;
  }
  
  .rank-number {
    font-size: 48px;
    min-width: 70px;
  }
  
  .highlight-icon {
    font-size: 64px;
  }
  
  .highlight-title {
    font-size: 36px;
  }
  
  .highlight-name {
    font-size: 40px;
  }
  
  .highlight-stats {
    font-size: 28px;
  }
  
  .highlight-stats strong {
    font-size: 36px;
  }
  
  .footer-stat {
    font-size: 36px;
  }
  
  .stat-icon {
    font-size: 40px;
  }
  
  .stat-value {
    font-size: 40px;
  }
  
  .tv-podium {
    min-height: 400px;
    gap: 30px;
  }
  
  .podium-item {
    max-width: 380px;
  }
  
  .podium-card {
    padding: 30px;
  }
  
  .leaderboard-item {
    padding: 20px 30px;
    margin-bottom: 15px;
  }
  
  .highlight-card {
    padding: 25px;
  }
  
  .tv-header {
    padding: 30px 50px;
  }
  
  .tv-main-content {
    padding: 40px 50px;
    gap: 40px;
  }
  
  .tv-footer {
    padding: 30px 50px;
  }
}

/* Optimized for Samsung U8500 4K TV (3840x2160) - Landscape - Fit All Content */
@media (min-width: 3840px) and (min-height: 2160px) {
  .tv-display-page {
    height: 100vh;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }
  
  .tv-title {
    font-size: 64px;
  }
  
  .current-time {
    font-size: 52px;
  }
  
  .current-date {
    font-size: 32px;
  }
  
  .section-title {
    font-size: 48px;
  }
  
  .division-icon {
    font-size: 48px;
  }
  
  .year-badge {
    font-size: 36px;
    padding: 8px 16px;
    border-radius: 6px;
  }
  
  .tv-header {
    padding: 15px 30px;
    border-bottom-width: 2px;
    flex-shrink: 0;
  }
  
  .logo-img {
    height: 50px;
  }
  
  .tv-main-content {
    padding: 15px 30px;
    gap: 20px;
    flex: 1;
    overflow: hidden;
    display: grid;
    grid-template-columns: 2fr 1fr;
    min-height: 0;
  }
  
  .tv-leaderboard-section {
    gap: 8px;
    display: flex;
    flex-direction: column;
    min-height: 0;
    overflow: hidden;
  }
  
  .section-header {
    margin-bottom: 6px;
    flex-shrink: 0;
  }
  
  .tv-top3-compact {
    padding: 10px 15px;
    gap: 15px;
    margin: 6px 0;
    flex-shrink: 0;
  }
  
  .top3-rank {
    font-size: 40px;
    min-width: 50px;
  }
  
  .top3-name {
    font-size: 32px;
    margin-bottom: 2px;
  }
  
  .top3-points {
    font-size: 36px;
    margin-bottom: 2px;
  }
  
  .top3-stats {
    font-size: 22px;
    gap: 2px;
  }
  
  .top3-item {
    padding: 8px 12px;
  }
  
  .tv-leaderboard-list {
    padding: 10px;
    border-radius: 6px;
    flex: 1;
    overflow-y: auto;
    overflow-x: hidden;
    min-height: 0;
  }
  
  .leaderboard-item {
    padding: 8px 15px;
    margin-bottom: 6px;
    border-radius: 4px;
    border-left-width: 3px;
  }
  
  .rank-number {
    font-size: 32px;
    min-width: 50px;
  }
  
  .player-name {
    font-size: 28px;
    margin-bottom: 2px;
  }
  
  .player-stats {
    font-size: 20px;
    gap: 12px;
  }
  
  .tv-highlights-section {
    gap: 8px;
    display: flex;
    flex-direction: column;
    min-height: 0;
    overflow: hidden;
  }
  
  .highlights-grid {
    gap: 8px;
    flex: 1;
    overflow-y: auto;
    overflow-x: hidden;
    min-height: 0;
  }
  
  .highlight-card {
    padding: 12px;
    border-radius: 6px;
    border-width: 2px;
    flex-shrink: 0;
  }
  
  .highlight-icon {
    font-size: 36px;
  }
  
  .highlight-title {
    font-size: 22px;
  }
  
  .highlight-name {
    font-size: 26px;
    margin-bottom: 4px;
  }
  
  .highlight-stats {
    font-size: 18px;
    gap: 4px;
  }
  
  .highlight-stats strong {
    font-size: 22px;
  }
  
  .highlight-empty {
    padding: 12px;
    min-height: 50px;
  }
  
  .empty-text {
    font-size: 28px;
  }
  
  .tv-footer {
    padding: 12px 30px;
    border-top-width: 2px;
    flex-shrink: 0;
  }
  
  .footer-stat {
    font-size: 24px;
  }
  
  .stat-icon {
    font-size: 28px;
  }
  
  .stat-value {
    font-size: 28px;
  }
  
  .stat-label {
    font-size: 20px;
  }
}
</style>

