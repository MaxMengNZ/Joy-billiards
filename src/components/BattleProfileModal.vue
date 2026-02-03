<template>
  <div v-if="show" class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content">
      <div class="modal-header">
        <h2>My Battle Profile</h2>
        <button class="btn-close" @click="$emit('close')">✕</button>
      </div>

      <div class="modal-body">
        <div v-if="loading" class="loading-state">
          <div class="spinner"></div>
          <p>Loading...</p>
        </div>

        <div v-else-if="error" class="error-message">
          ⚠️ {{ error }}
        </div>

        <div v-else-if="userData" class="profile-content">
          <!-- User Info -->
          <div class="profile-header">
            <div class="user-avatar">
              <span class="avatar-icon">🎱</span>
            </div>
            <div class="user-info">
              <h3>{{ userData.name }}</h3>
              <div class="user-badges">
                <div class="tier-badge" :class="`tier-${userData.battle_tier}`">
                  <span class="tier-name">{{ formatTierName(userData.battle_tier) }}</span>
                  <span v-if="userData.battle_stars > 0" class="tier-stars">
                    {{ userData.battle_stars }}⭐
                  </span>
                </div>
                <div class="elo-badge">
                  Elo: {{ userData.battle_elo_rating || 1000 }}
                </div>
                <div v-if="userData.battle_position" class="position-badge">
                  Rank: #{{ userData.battle_position }}
                </div>
              </div>
            </div>
          </div>

          <!-- Battle Statistics -->
          <div class="stats-section">
            <h4>Battle Statistics</h4>
            <div class="battle-stats-grid">
              <div class="stat-card">
                <div class="stat-icon">🏆</div>
                <div class="stat-info">
                  <div class="stat-label">Total Wins</div>
                  <div class="stat-value-large">{{ totalWins }}</div>
                </div>
              </div>
              <div class="stat-card">
                <div class="stat-icon">📉</div>
                <div class="stat-info">
                  <div class="stat-label">Total Losses</div>
                  <div class="stat-value-large">{{ totalLosses }}</div>
                </div>
              </div>
              <div class="stat-card">
                <div class="stat-icon">📊</div>
                <div class="stat-info">
                  <div class="stat-label">Win Rate</div>
                  <div class="stat-value-large">{{ overallWinRate }}%</div>
                </div>
              </div>
              <div class="stat-card">
                <div class="stat-icon">🎯</div>
                <div class="stat-info">
                  <div class="stat-label">Total Matches</div>
                  <div class="stat-value-large">{{ totalMatches }}</div>
                </div>
              </div>
              <div v-if="userData.battle_streak !== 0" class="stat-card">
                <div class="stat-icon">{{ userData.battle_streak > 0 ? '🔥' : '❄️' }}</div>
                <div class="stat-info">
                  <div class="stat-label">Streak</div>
                  <div class="stat-value-large" :class="{ positive: userData.battle_streak > 0, negative: userData.battle_streak < 0 }">
                    {{ userData.battle_streak > 0 ? '+' : '' }}{{ userData.battle_streak }}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Achievements -->
          <div class="stats-section">
            <h4>Achievements</h4>
            <div class="achievements-grid">
              <div class="achievement-card">
                <div class="achievement-icon">🎯</div>
                <div class="achievement-info">
                  <div class="achievement-label">Break & Run</div>
                  <div class="achievement-value">{{ userData.break_and_run_count || 0 }}</div>
                </div>
              </div>
              <div class="achievement-card">
                <div class="achievement-icon">⚡</div>
                <div class="achievement-info">
                  <div class="achievement-label">Rack Run</div>
                  <div class="achievement-value">{{ userData.rack_run_count || 0 }}</div>
                </div>
              </div>
            </div>
          </div>

          <!-- Recent Matches -->
          <div class="stats-section">
            <h4>Recent 10 Matches</h4>
            <div v-if="recentMatches.length > 0" class="matches-list">
              <div
                v-for="match in recentMatches"
                :key="match.id"
                class="match-item"
                :class="{ won: match.won, lost: !match.won }"
              >
                <div class="match-result-badge">
                  <span class="result-icon">{{ match.won ? '✓' : '✗' }}</span>
                </div>
                <div class="match-details">
                  <div class="match-opponent">
                    vs {{ match.opponent_name }}
                  </div>
                  <div class="match-score">
                    {{ match.player_score }} - {{ match.opponent_score }}
                  </div>
                  <div class="match-meta">
                    <span class="match-date">{{ formatDate(match.played_at) }}</span>
                  </div>
                </div>
                <div class="match-elo">
                  <div class="elo-change" :class="{ positive: match.elo_change > 0, negative: match.elo_change < 0 }">
                    {{ match.elo_change > 0 ? '+' : '' }}{{ match.elo_change }}
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="no-matches">
              <p>No recent matches</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, computed } from 'vue'
import { useBattleStore } from '../stores/battleStore'
import { supabase } from '../config/supabase'

const props = defineProps({
  show: {
    type: Boolean,
    required: true
  }
})

const emit = defineEmits(['close'])

const battleStore = useBattleStore()

// State
const loading = ref(false)
const error = ref('')
const userData = ref(null)
const recentMatches = ref([])

// Methods
const formatRankLevel = (level) => {
  if (!level) return 'Beginner'
  const levelMap = {
    beginner: 'Beginner',
    intermediate: 'Intermediate',
    advance: 'Advanced',
    advanced: 'Advanced',
    expert: 'Expert',
    elite: 'Elite',
    master: 'Master',
    grand_master: 'Grand Master',
    pro_level: 'Pro Level',
    hall_of_fame: 'Hall of Fame'
  }
  return levelMap[level.toLowerCase()] || level
}

const calculateWinRate = (wins, losses) => {
  const total = (wins || 0) + (losses || 0)
  if (total === 0) return 0
  return ((wins || 0) / total * 100).toFixed(1)
}

// Computed properties for Battle-only data
const totalWins = computed(() => {
  if (!userData.value) return 0
  return userData.value.battle_wins || 0
})

const totalLosses = computed(() => {
  if (!userData.value) return 0
  return userData.value.battle_losses || 0
})

const totalMatches = computed(() => {
  return totalWins.value + totalLosses.value
})

const overallWinRate = computed(() => {
  return calculateWinRate(totalWins.value, totalLosses.value)
})

const formatTierName = (tier) => {
  if (!tier) return 'Unranked'
  // Map tier names to display names (English)
  const tierMap = {
    'bronze_iii': 'Bronze III',
    'bronze_ii': 'Bronze II',
    'bronze_i': 'Bronze I',
    'silver_iii': 'Silver III',
    'silver_ii': 'Silver II',
    'silver_i': 'Silver I',
    'gold_iv': 'Gold IV',
    'gold_iii': 'Gold III',
    'gold_ii': 'Gold II',
    'gold_i': 'Gold I',
    'platinum_iv': 'Platinum IV',
    'platinum_iii': 'Platinum III',
    'platinum_ii': 'Platinum II',
    'platinum_i': 'Platinum I',
    'diamond_v': 'Diamond V',
    'diamond_iv': 'Diamond IV',
    'diamond_iii': 'Diamond III',
    'diamond_ii': 'Diamond II',
    'diamond_i': 'Diamond I',
    'star_glory_v': 'Master V',
    'star_glory_iv': 'Master IV',
    'star_glory_iii': 'Master III',
    'star_glory_ii': 'Master II',
    'star_glory_i': 'Master I',
    'king_strongest': 'Grand Master',
    'king_peerless': 'The King',
    'king_glory': 'Legend',
    'king_legendary': 'Hall of Fame'
  }
  return tierMap[tier] || tier
}

const formatDate = (timestamp) => {
  if (!timestamp) return ''
  const date = new Date(timestamp)
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  })
}

const loadUserData = async () => {
  console.log('[BattleProfile] loadUserData called')
  console.log('[BattleProfile] battleStore.currentUser:', battleStore.currentUser)
  
  // Ensure current user is initialized
  if (!battleStore.currentUser) {
    console.log('[BattleProfile] No currentUser, initializing...')
    await battleStore.initCurrentUser()
    console.log('[BattleProfile] After init, currentUser:', battleStore.currentUser)
  }

  if (!battleStore.currentUser) {
    console.error('[BattleProfile] Still no currentUser after init')
    error.value = 'User not found. Please try refreshing the page.'
    loading.value = false
    return
  }

  console.log('[BattleProfile] Starting to load data for user:', battleStore.currentUser.id)
  loading.value = true
  error.value = ''

  try {
    console.log('[BattleProfile] Loading data for user:', battleStore.currentUser.id)

    // Load user data (only Battle-related fields - unified, no pro/student)
    const { data: user, error: userError } = await supabase
      .from('users')
      .select(`
        id,
        name,
        battle_elo_rating,
        battle_tier,
        battle_stars,
        battle_wins,
        battle_losses,
        battle_position,
        battle_streak,
        break_and_run_count,
        rack_run_count
      `)
      .eq('id', battleStore.currentUser.id)
      .single()

    if (userError) {
      console.error('[BattleProfile] Error loading user data:', userError)
      throw userError
    }
    
    console.log('[BattleProfile] User data loaded:', user)
    userData.value = user

    // Load recent 10 matches
    const userId = battleStore.currentUser.id
    console.log('[BattleProfile] Loading matches for user:', userId)
    
    const { data: matches, error: matchesError } = await supabase
      .from('battle_match_history')
      .select(`
        id,
        player1_id,
        player2_id,
        winner_id,
        player1_score,
        player2_score,
        division,
        played_at,
        player1_elo_before,
        player1_elo_after,
        player2_elo_before,
        player2_elo_after
      `)
      .or(`player1_id.eq.${userId},player2_id.eq.${userId}`)
      .order('played_at', { ascending: false })
      .limit(10)

    if (matchesError) {
      console.error('[BattleProfile] Error loading matches:', matchesError)
      throw matchesError
    }
    
    console.log('[BattleProfile] Matches loaded:', matches)

    // Get all unique opponent IDs
    const opponentIds = [...new Set(
      (matches || []).map(match => {
        const isPlayer1 = match.player1_id === userId
        return isPlayer1 ? match.player2_id : match.player1_id
      })
    )]

    console.log('[BattleProfile] Opponent IDs:', opponentIds)

    // Batch fetch opponent names (only if there are opponents)
    let opponentMap = new Map()
    if (opponentIds.length > 0) {
      const { data: opponents, error: opponentsError } = await supabase
        .from('users')
        .select('id, name')
        .in('id', opponentIds)

      if (opponentsError) {
        console.error('[BattleProfile] Error loading opponents:', opponentsError)
      } else {
        opponentMap = new Map(
          (opponents || []).map(opp => [opp.id, opp.name])
        )
        console.log('[BattleProfile] Opponents loaded:', opponentMap)
      }
    }

    // Process matches to get opponent names and calculate Elo change
    const processedMatches = (matches || []).map((match) => {
      const isPlayer1 = match.player1_id === userId
      const opponentId = isPlayer1 ? match.player2_id : match.player1_id
      
      const won = match.winner_id === userId
      const eloBefore = isPlayer1 ? match.player1_elo_before : match.player2_elo_before
      const eloAfter = isPlayer1 ? match.player1_elo_after : match.player2_elo_after
      const eloChange = eloAfter - eloBefore

      return {
        id: match.id,
        opponent_name: opponentMap.get(opponentId) || 'Unknown',
        won,
        player_score: isPlayer1 ? match.player1_score : match.player2_score,
        opponent_score: isPlayer1 ? match.player2_score : match.player1_score,
        played_at: match.played_at,
        elo_change: eloChange || 0
      }
    })

    console.log('[BattleProfile] Processed matches:', processedMatches)
    recentMatches.value = processedMatches
  } catch (err) {
    error.value = err.message || 'Failed to load user data'
    console.error('[BattleProfile] Error loading user data:', err)
  } finally {
    loading.value = false
  }
}

// Watch for modal open
watch(() => props.show, async (newValue) => {
  console.log('[BattleProfile] Modal show changed:', newValue)
  if (newValue) {
    console.log('[BattleProfile] Modal opened, currentUser:', battleStore.currentUser)
    // Ensure user is initialized before loading data
    if (!battleStore.currentUser) {
      console.log('[BattleProfile] Initializing current user...')
      await battleStore.initCurrentUser()
      console.log('[BattleProfile] After init, currentUser:', battleStore.currentUser)
    }
    console.log('[BattleProfile] Calling loadUserData...')
    await loadUserData()
  } else {
    // Reset data when modal closes
    userData.value = null
    recentMatches.value = []
    error.value = ''
  }
})

// Also load data when component is mounted and show is true
onMounted(() => {
  console.log('[BattleProfile] Component mounted, show:', props.show)
  if (props.show) {
    loadUserData()
  }
})
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(5px);
  padding: 1rem;
}

.modal-content {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 20px;
  width: 100%;
  max-width: 900px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  color: white;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 2px solid rgba(255, 255, 255, 0.2);
}

.modal-header h2 {
  margin: 0;
  font-size: 1.5rem;
}

.btn-close {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 1.2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.2s;
}

.btn-close:hover {
  background: rgba(255, 255, 255, 0.3);
}

.modal-body {
  padding: 1.5rem;
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  gap: 1rem;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-message {
  background: rgba(255, 0, 0, 0.2);
  border: 2px solid rgba(255, 0, 0, 0.5);
  color: white;
  padding: 1rem;
  border-radius: 10px;
  text-align: center;
}

.profile-content {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

/* Profile Header */
.profile-header {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 1.5rem;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
}

.user-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.5rem;
}

.user-info {
  flex: 1;
}

.user-info h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.5rem;
}

.user-badges {
  display: flex;
  gap: 0.5rem;
}

.rank-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
  background: rgba(255, 255, 255, 0.2);
}

/* Stats Section */
.stats-section {
  padding: 1.5rem;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
}

.stats-section h4 {
  margin: 0 0 1rem 0;
  font-size: 1.25rem;
  font-weight: 600;
}

/* Points Grid */
.points-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
}

.point-card {
  padding: 1rem;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 10px;
  text-align: center;
}

.point-label {
  font-size: 0.85rem;
  opacity: 0.8;
  margin-bottom: 0.5rem;
}

.point-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #4ade80;
}

/* Battle Stats Grid */
.battle-stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 12px;
  border: 2px solid rgba(255, 255, 255, 0.1);
  transition: transform 0.2s, box-shadow 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.stat-icon {
  font-size: 2.5rem;
}

.stat-info {
  flex: 1;
}

.stat-label {
  font-size: 0.85rem;
  opacity: 0.8;
  margin-bottom: 0.25rem;
}

.stat-value-large {
  font-size: 1.75rem;
  font-weight: 700;
  color: #4ade80;
}

.stat-value-large.positive {
  color: #4ade80;
}

.stat-value-large.negative {
  color: #ef4444;
}

.elo-badge {
  padding: 0.5rem 1rem;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  background: rgba(255, 255, 255, 0.2);
  color: #fbbf24;
}

/* Achievements Grid */
.achievements-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.achievement-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 12px;
  border: 2px solid rgba(255, 255, 255, 0.1);
}

.achievement-icon {
  font-size: 2.5rem;
}

.achievement-info {
  flex: 1;
}

.achievement-label {
  font-size: 0.85rem;
  opacity: 0.8;
  margin-bottom: 0.25rem;
}

.achievement-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #fbbf24;
}

/* Matches List */
.matches-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.match-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 10px;
  border-left: 4px solid transparent;
  transition: all 0.2s;
}

.match-item.won {
  border-left-color: #4ade80;
}

.match-item.lost {
  border-left-color: #ef4444;
}

.match-result-badge {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1.2rem;
}

.match-item.won .match-result-badge {
  background: rgba(74, 222, 128, 0.3);
  color: #4ade80;
}

.match-item.lost .match-result-badge {
  background: rgba(239, 68, 68, 0.3);
  color: #ef4444;
}

.match-details {
  flex: 1;
}

.match-opponent {
  font-weight: 600;
  font-size: 1rem;
  margin-bottom: 0.25rem;
}

.match-score {
  font-size: 0.9rem;
  opacity: 0.9;
  margin-bottom: 0.25rem;
}

.match-meta {
  display: flex;
  gap: 1rem;
  font-size: 0.8rem;
  opacity: 0.7;
}

.match-elo {
  text-align: right;
}

.elo-change {
  font-size: 1rem;
  font-weight: 700;
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
}

.elo-change.positive {
  color: #4ade80;
  background: rgba(74, 222, 128, 0.2);
}

.elo-change.negative {
  color: #ef4444;
  background: rgba(239, 68, 68, 0.2);
}

.no-matches {
  padding: 2rem;
  text-align: center;
  opacity: 0.6;
}

/* Mobile Responsive */
@media (max-width: 768px) {
  .modal-content {
    width: 95vw;
    max-width: 95vw;
    max-height: 95vh;
    border-radius: 16px;
    margin: 0;
  }

  .modal-header {
    padding: 1.25rem;
  }

  .modal-header h2 {
    font-size: 1.25rem;
  }

  .btn-close {
    width: 36px;
    height: 36px;
    font-size: 1.1rem;
  }

  .modal-body {
    padding: 1.25rem;
    max-height: calc(95vh - 120px);
    overflow-y: auto;
  }

  .profile-header {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }

  .user-avatar {
    width: 80px;
    height: 80px;
  }

  .avatar-icon {
    font-size: 2.5rem;
  }

  .user-info h3 {
    font-size: 1.25rem;
  }

  .user-badges {
    flex-direction: column;
    gap: 0.75rem;
    align-items: center;
  }

  .tier-badge {
    padding: 0.625rem 1rem;
    font-size: 0.9rem;
  }

  .elo-badge,
  .position-badge {
    padding: 0.5rem 0.875rem;
    font-size: 0.85rem;
  }

  .stats-section {
    margin-bottom: 1.5rem;
  }

  .stats-section h4 {
    font-size: 1.1rem;
    margin-bottom: 1rem;
  }

  .battle-stats-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 0.75rem;
  }

  .stat-card {
    padding: 1rem;
  }

  .stat-icon {
    font-size: 1.5rem;
    width: 40px;
    height: 40px;
  }

  .stat-label {
    font-size: 0.85rem;
  }

  .stat-value-large {
    font-size: 1.5rem;
  }

  .achievements-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 0.75rem;
  }

  .achievement-card {
    padding: 1rem;
  }

  .achievement-icon {
    font-size: 1.5rem;
    width: 40px;
    height: 40px;
  }

  .achievement-label {
    font-size: 0.8rem;
  }

  .achievement-value {
    font-size: 1.25rem;
  }

  .matches-list {
    gap: 0.625rem;
  }

  .match-item {
    padding: 0.875rem;
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }

  .match-result-badge {
    width: 36px;
    height: 36px;
    font-size: 1rem;
  }

  .match-opponent {
    font-size: 0.95rem;
  }

  .match-score {
    font-size: 0.85rem;
  }

  .match-meta {
    flex-direction: column;
    gap: 0.5rem;
    font-size: 0.75rem;
  }

  .points-grid {
    grid-template-columns: 1fr;
    gap: 0.75rem;
  }
}

@media (max-width: 480px) {
  .modal-content {
    width: 100vw;
    max-width: 100vw;
    max-height: 100vh;
    border-radius: 0;
  }

  .modal-header {
    padding: 1rem;
  }

  .modal-header h2 {
    font-size: 1.1rem;
  }

  .modal-body {
    padding: 1rem;
  }

  .battle-stats-grid {
    grid-template-columns: 1fr;
  }

  .achievements-grid {
    grid-template-columns: 1fr;
  }

  .stat-value-large {
    font-size: 1.25rem;
  }

  .achievement-value {
    font-size: 1.1rem;
  }
}
</style>
