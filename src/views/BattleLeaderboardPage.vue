<template>
  <div class="battle-leaderboard-page">
    <!-- Loading State -->
    <div v-if="loading && !players.length" class="loading-container">
      <div class="spinner"></div>
      <p>Loading rankings...</p>
    </div>

    <!-- Main Content -->
    <template v-else>
      <!-- Hero Section -->
      <section class="battle-leaderboard-hero">
        <div class="hero-background">
          <div class="hero-pattern"></div>
          <div class="hero-glow"></div>
        </div>
        <div class="hero-content">
          <div class="hero-badge">
            <span class="badge-icon">🎱</span>
            <span class="badge-text">Battle Ranking System</span>
          </div>
          <h1 class="hero-title">
            Battle Tier <span class="title-highlight">Leaderboard</span>
          </h1>
          <p class="hero-subtitle">
            Compete, Rank Up, Become a Legend!
          </p>
          <div class="hero-actions">
            <button 
              v-if="battleStore.currentUser"
              class="btn-hero"
              @click="showProfileModal = true"
            >
              👤 My Profile
            </button>
            <router-link to="/battle" class="btn-hero btn-hero-secondary">
              ⚔️ Create Match
            </router-link>
          </div>
        </div>
      </section>

      <!-- Top 3 Podium -->
      <div class="top3-podium">
        <div 
          v-for="(player, index) in topThree" 
          :key="player ? player.id : `podium-${index}`"
          class="podium-item"
          :class="[
            `podium-${index + 1}`,
            { 'empty-podium': !player }
          ]"
        >
          <div class="podium-medal">
            <span v-if="index === 0">🥇</span>
            <span v-else-if="index === 1">🥈</span>
            <span v-else>🥉</span>
          </div>
          <div v-if="player" class="podium-player">
            <div class="podium-avatar">
              <img 
                v-if="player.avatar_url" 
                :src="player.avatar_url" 
                :alt="player.name"
                class="avatar-img"
              />
              <span v-else class="avatar-default">🎱</span>
            </div>
            <h3 class="podium-name">{{ player.name }}</h3>
            <TierBadge 
              :tier="player.battle_tier" 
              :stars="player.battle_stars || 0"
              size="large"
            />
            <div class="podium-stats">
              <div class="stat-item">
                <span class="stat-label">Elo:</span>
                <span class="stat-value">{{ player.battle_elo_rating || 1000 }}</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">Rank:</span>
                <span class="stat-value">#{{ player.battle_position || 'N/A' }}</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">Wins:</span>
                <span class="stat-value">{{ player.battle_wins || 0 }}</span>
              </div>
            </div>
          </div>
          <div v-else class="podium-empty">
            <span class="empty-text">No player</span>
          </div>
        </div>
      </div>

      <!-- Filters & Search -->
      <div class="filters-section">
        <div class="search-box">
          <span class="search-icon">🔍</span>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search by name..."
            class="search-input"
          />
        </div>
        <div class="filter-controls">
          <select v-model="sortBy" class="filter-select">
            <option value="position">Sort by Rank</option>
            <option value="elo">Sort by Elo</option>
            <option value="wins">Sort by Wins</option>
            <option value="winrate">Sort by Win Rate</option>
          </select>
          <select v-model="tierFilter" class="filter-select">
            <option value="all">All Tiers</option>
            <option value="bronze">Bronze</option>
            <option value="silver">Silver</option>
            <option value="gold">Gold</option>
            <option value="platinum">Platinum</option>
            <option value="diamond">Diamond</option>
            <option value="master">Master</option>
            <option value="grand_master">Grand Master+</option>
          </select>
        </div>
      </div>

      <!-- Leaderboard List -->
      <div class="leaderboard-list">
        <!-- Desktop Table View -->
        <table class="leaderboard-table desktop-only">
          <thead>
            <tr>
              <th class="col-rank">Rank</th>
              <th class="col-avatar">Avatar</th>
              <th class="col-name">Name</th>
              <th class="col-tier">Tier</th>
              <th class="col-elo">Elo</th>
              <th class="col-wins">Wins</th>
              <th class="col-winrate">Win Rate</th>
              <th class="col-streak">Streak</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(player, index) in filteredAndSortedPlayers"
              :key="player.id"
              class="leaderboard-row"
              :class="{ 'current-user': battleStore.currentUser?.id === player.id }"
              @click="viewPlayerProfile(player)"
            >
              <td class="col-rank">
                <span class="rank-number">#{{ player.battle_position || index + 4 }}</span>
              </td>
              <td class="col-avatar">
                <div class="player-avatar">
                  <img 
                    v-if="player.avatar_url" 
                    :src="player.avatar_url" 
                    :alt="player.name"
                    class="avatar-img-small"
                  />
                  <span v-else class="avatar-default-small">🎱</span>
                </div>
              </td>
              <td class="col-name">
                <span class="player-name">{{ player.name }}</span>
              </td>
              <td class="col-tier">
                <TierBadge 
                  :tier="player.battle_tier" 
                  :stars="player.battle_stars || 0"
                  size="small"
                />
              </td>
              <td class="col-elo">
                <span class="elo-value">{{ player.battle_elo_rating || 1000 }}</span>
              </td>
              <td class="col-wins">
                <span class="wins-value">{{ player.battle_wins || 0 }}</span>
              </td>
              <td class="col-winrate">
                <span class="winrate-value">{{ calculateWinRate(player) }}%</span>
              </td>
              <td class="col-streak">
                <span 
                  v-if="player.current_win_streak > 0"
                  class="streak-value streak-positive"
                  :title="getStreakLabel(player.current_win_streak)"
                >
                  {{ getStreakIcon(player.current_win_streak) }} x{{ player.current_win_streak }}
                </span>
                <span v-else class="streak-value">-</span>
              </td>
            </tr>
          </tbody>
        </table>

        <!-- Mobile Card View -->
        <div class="leaderboard-cards mobile-only">
          <div
            v-for="(player, index) in filteredAndSortedPlayers"
            :key="player.id"
            class="leaderboard-card"
            :class="{ 'current-user': battleStore.currentUser?.id === player.id }"
            @click="viewPlayerProfile(player)"
          >
            <div class="card-rank">
              <span class="rank-number">#{{ player.battle_position || index + 4 }}</span>
            </div>
            <div class="card-avatar">
              <img 
                v-if="player.avatar_url" 
                :src="player.avatar_url" 
                :alt="player.name"
                class="avatar-img-card"
              />
              <span v-else class="avatar-default-card">🎱</span>
            </div>
            <div class="card-info">
              <h3 class="card-name">{{ player.name }}</h3>
              <TierBadge 
                :tier="player.battle_tier" 
                :stars="player.battle_stars || 0"
                size="medium"
              />
              <div class="card-stats">
                <div class="card-stat-item">
                  <span class="stat-label">Elo:</span>
                  <span class="stat-value">{{ player.battle_elo_rating || 1000 }}</span>
                </div>
                <div class="card-stat-item">
                  <span class="stat-label">Wins:</span>
                  <span class="stat-value">{{ player.battle_wins || 0 }}</span>
                </div>
                <div class="card-stat-item">
                  <span class="stat-label">Win Rate:</span>
                  <span class="stat-value">{{ calculateWinRate(player) }}%</span>
                </div>
                <div 
                  v-if="player.current_win_streak > 0"
                  class="card-stat-item"
                >
                  <span class="stat-label">Win Streak:</span>
                  <span 
                    class="stat-value streak-positive"
                    :title="getStreakLabel(player.current_win_streak)"
                  >
                    {{ getStreakIcon(player.current_win_streak) }} x{{ player.current_win_streak }}
                  </span>
                </div>
                <div 
                  v-if="player.season_best_win_streak > 0"
                  class="card-stat-item"
                >
                  <span class="stat-label">Season Best:</span>
                  <span class="stat-value streak-positive">
                    🏆 x{{ player.season_best_win_streak }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Empty State -->
        <div v-if="filteredAndSortedPlayers.length === 0" class="empty-state">
          <div class="empty-icon">🎱</div>
          <p class="empty-text">No players found</p>
          <p class="empty-hint">Try adjusting your search or filters</p>
        </div>
      </div>
    </template>

    <!-- Battle Profile Modal -->
    <BattleProfileModal
      v-if="showProfileModal"
      :show="showProfileModal"
      @close="showProfileModal = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useBattleStore } from '../stores/battleStore'
import { supabase } from '../config/supabase'
import BattleProfileModal from '../components/BattleProfileModal.vue'
import TierBadge from '../components/TierBadge.vue'

const battleStore = useBattleStore()

// State
const loading = ref(true)
const players = ref([])
const searchQuery = ref('')
const sortBy = ref('position')
const tierFilter = ref('all')
const showProfileModal = ref(false)
const selectedPlayer = ref(null)

// Computed
const topThree = computed(() => {
  // Sort players: first by position, then by Elo (for tie-breaking)
  const sorted = [...players.value]
    .sort((a, b) => {
      // First sort by position if available
      if (a.battle_position && b.battle_position) {
        const posDiff = a.battle_position - b.battle_position
        // If same position, sort by Elo (higher Elo first)
        if (posDiff === 0) {
          return (b.battle_elo_rating || 0) - (a.battle_elo_rating || 0)
        }
        return posDiff
      }
      if (a.battle_position) return -1
      if (b.battle_position) return 1
      // If no position, sort by Elo
      return (b.battle_elo_rating || 0) - (a.battle_elo_rating || 0)
    })
    .slice(0, 3) // Take top 3
  
  // Simply place players in order (index 0, 1, 2)
  // Don't use battle_position as index to avoid conflicts when multiple players have same position
  const result = [null, null, null]
  sorted.forEach((player, index) => {
    if (player && index < 3) {
      result[index] = player
    }
  })
  return result
})

const filteredAndSortedPlayers = computed(() => {
  let filtered = [...players.value]

  // Filter by search query
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase().trim()
    filtered = filtered.filter(p => {
      const name = (p.name || '').toLowerCase()
      return name.includes(query)
    })
    // Only log in development mode
    if (import.meta.env.DEV) {
      console.log(`[BattleLeaderboard] Search "${searchQuery.value}": ${filtered.length} results`)
    }
  }

  // Filter by tier
  if (tierFilter.value !== 'all') {
    filtered = filtered.filter(p => {
      const tier = (p.battle_tier || '').toLowerCase()
      if (tierFilter.value === 'grand_master') {
        return tier.includes('king') || tier.includes('grand_master') || tier.includes('legend') || tier.includes('hall_of_fame')
      }
      return tier.startsWith(tierFilter.value)
    })
  }

  // Sort
  filtered.sort((a, b) => {
    switch (sortBy.value) {
      case 'elo':
        return (b.battle_elo_rating || 0) - (a.battle_elo_rating || 0)
      case 'wins':
        return (b.battle_wins || 0) - (a.battle_wins || 0)
      case 'winrate':
        return calculateWinRate(b) - calculateWinRate(a)
      case 'position':
      default:
        return (a.battle_position || 999) - (b.battle_position || 999)
    }
  })

  // Exclude top 3 from list (they're shown in podium)
  // BUT: If user is searching or filtering, show all results including top 3
  const isFiltering = searchQuery.value.trim() || tierFilter.value !== 'all'
  
  if (!isFiltering) {
    // Get top 3 players (by position or Elo if no position)
    const top3Players = [...players.value]
      .sort((a, b) => {
        if (a.battle_position && b.battle_position) {
          const posDiff = a.battle_position - b.battle_position
          if (posDiff === 0) {
            return (b.battle_elo_rating || 0) - (a.battle_elo_rating || 0)
          }
          return posDiff
        }
        if (a.battle_position) return -1
        if (b.battle_position) return 1
        return (b.battle_elo_rating || 0) - (a.battle_elo_rating || 0)
      })
      .slice(0, 3)
      .map(p => p.id)
    
    // Exclude top 3 players from the list (only when not filtering)
    return filtered.filter(p => !top3Players.includes(p.id))
  }
  
  // When filtering/searching, show all matching results
  return filtered
})

// Streak display functions
const getStreakIcon = (streak) => {
  if (streak >= 10) return '👑'
  if (streak >= 7) return '🔥🔥🔥'
  if (streak >= 5) return '🔥🔥'
  if (streak >= 3) return '🔥'
  return ''
}

const getStreakLabel = (streak) => {
  if (streak >= 10) return '👑 Legendary'
  if (streak >= 7) return '🔥🔥🔥 Dominating'
  if (streak >= 5) return '🔥🔥 On Fire'
  if (streak >= 3) return '🔥 Hot Streak'
  return 'Normal'
}

// Methods
const formatTierName = (tier) => {
  if (!tier) return 'Unranked'
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

const calculateWinRate = (player) => {
  const wins = player.battle_wins || 0
  const losses = player.battle_losses || 0
  const total = wins + losses
  if (total === 0) return 0
  return ((wins / total) * 100).toFixed(1)
}

const viewPlayerProfile = (player) => {
  selectedPlayer.value = player
  // If viewing own profile, show modal
  if (battleStore.currentUser?.id === player.id) {
    showProfileModal.value = true
  } else {
    // TODO: Show other player's profile modal or navigate
    console.log('View player:', player.name)
  }
}

const loadLeaderboard = async () => {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('users')
      .select(`
        id,
        name,
        avatar_url,
        battle_position,
        battle_elo_rating,
        battle_tier,
        battle_stars,
        battle_wins,
        battle_losses,
        current_win_streak,
        season_best_win_streak
      `)
      .not('battle_elo_rating', 'is', null)
      .or('battle_wins.gt.0,battle_losses.gt.0') // Only show players who have played at least one match
      // Note: We'll sort by Elo in the frontend, not by battle_position from database

    if (error) throw error

    // Filter: only show players who have played matches
    // Exclude players with Elo = 1000 who only have losses (data inconsistency - they should have lower Elo after losing)
    // Note: Players who lost should have Elo < 1000 (unless tier protection applies, but even then Elo should update)
    let filteredPlayers = (data || []).filter(player => {
      const totalMatches = (player.battle_wins || 0) + (player.battle_losses || 0)
      const elo = player.battle_elo_rating || 1000
      
      // Must have played at least one match
      if (totalMatches === 0) return false
      
      // Exclude players who lost but Elo is still exactly 1000 (initial Elo)
      // This indicates data inconsistency - if they lost, their Elo should be < 1000
      // (Even with tier protection, the Elo value should change, just not below tier minimum)
      if (elo === 1000 && player.battle_wins === 0 && player.battle_losses > 0) {
        // Only log in development mode
        if (import.meta.env.DEV) {
          console.warn(`[BattleLeaderboard] Excluding ${player.name}: Elo=1000 (initial) but has ${player.battle_losses} loss(es) - data inconsistency`)
        }
        return false
      }
      
      return true
    })
    
    // Recalculate positions based on Elo (ignore database battle_position which may be incorrect)
    // Sort by Elo descending, then by wins descending, then by losses ascending
    filteredPlayers.sort((a, b) => {
      const eloA = a.battle_elo_rating || 0
      const eloB = b.battle_elo_rating || 0
      
      // First sort by Elo
      if (eloB !== eloA) {
        return eloB - eloA
      }
      
      // If Elo is same, sort by wins
      const winsA = a.battle_wins || 0
      const winsB = b.battle_wins || 0
      if (winsB !== winsA) {
        return winsB - winsA
      }
      
      // If wins are same, sort by losses (fewer losses is better)
      const lossesA = a.battle_losses || 0
      const lossesB = b.battle_losses || 0
      return lossesA - lossesB
    })
    
    // Assign positions based on sorted order
    filteredPlayers.forEach((player, index) => {
      player.battle_position = index + 1
    })
    
    players.value = filteredPlayers
    
    // Only log in development mode (security: don't expose user data in production)
    if (import.meta.env.DEV) {
      console.log(`[BattleLeaderboard] Loaded ${players.value.length} players (positions recalculated by Elo):`, players.value.map(p => `${p.name} (Position: ${p.battle_position}, Elo: ${p.battle_elo_rating}, W: ${p.battle_wins}, L: ${p.battle_losses})`))
    }
  } catch (err) {
    console.error('[BattleLeaderboard] Error loading leaderboard:', err)
  } finally {
    loading.value = false
  }
}

// Real-time subscriptions
let roomsSubscription = null
let usersSubscription = null

const subscribeToUpdates = () => {
  // Subscribe to battle_rooms table changes (when matches complete)
  roomsSubscription = supabase
    .channel('battle_leaderboard_rooms')
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'battle_rooms',
        filter: 'status=eq.completed'
      },
      (payload) => {
        // Only log in development mode
        if (import.meta.env.DEV) {
          console.log('[BattleLeaderboard] Battle room completed')
        }
        // Reload leaderboard when a match completes
        loadLeaderboard()
      }
    )
    .subscribe()

  // Also subscribe to users table changes (when Elo/position updates)
  usersSubscription = supabase
    .channel('battle_leaderboard_users')
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'users'
      },
      (payload) => {
        // Only reload if battle-related fields changed
        const oldData = payload.old
        const newData = payload.new
        
        const battleFieldsChanged = 
          oldData?.battle_elo_rating !== newData?.battle_elo_rating ||
          oldData?.battle_position !== newData?.battle_position ||
          oldData?.battle_wins !== newData?.battle_wins ||
          oldData?.battle_losses !== newData?.battle_losses ||
          oldData?.battle_tier !== newData?.battle_tier
        
        if (battleFieldsChanged) {
          // Only log in development mode (security: don't expose user data)
          if (import.meta.env.DEV) {
            console.log('[BattleLeaderboard] User battle data updated:', newData?.name)
          }
          loadLeaderboard()
        }
      }
    )
    .subscribe()
}

// Lifecycle
onMounted(async () => {
  await battleStore.initCurrentUser()
  await loadLeaderboard()
  subscribeToUpdates()
})

onUnmounted(() => {
  if (roomsSubscription) {
    supabase.removeChannel(roomsSubscription)
  }
  if (usersSubscription) {
    supabase.removeChannel(usersSubscription)
  }
})
</script>

<style scoped>
.battle-leaderboard-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  color: white;
  padding-bottom: 2rem;
}

/* Loading */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 80vh;
  gap: 1rem;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Hero Section */
.battle-leaderboard-hero {
  position: relative;
  padding: 4rem 2rem;
  overflow: hidden;
}

.hero-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  opacity: 0.3;
}

.hero-pattern {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: radial-gradient(circle, rgba(255,255,255,0.1) 1px, transparent 1px);
  background-size: 30px 30px;
}

.hero-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 500px;
  height: 500px;
  background: radial-gradient(circle, rgba(102, 126, 234, 0.4) 0%, transparent 70%);
  border-radius: 50%;
}

.hero-content {
  position: relative;
  z-index: 1;
  text-align: center;
  max-width: 800px;
  margin: 0 auto;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  margin-bottom: 1rem;
  font-size: 0.9rem;
}

.badge-icon {
  font-size: 1.2rem;
}

.hero-title {
  font-size: 3rem;
  font-weight: 700;
  margin: 1rem 0;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.title-highlight {
  background: linear-gradient(135deg, #ffd700 0%, #ffed4e 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero-subtitle {
  font-size: 1.2rem;
  opacity: 0.9;
  margin-bottom: 2rem;
}

.hero-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.btn-hero {
  padding: 0.75rem 2rem;
  background: rgba(255, 255, 255, 0.2);
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 25px;
  color: white;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  text-decoration: none;
  display: inline-block;
}

.btn-hero:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
}

.btn-hero-secondary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
}

/* Top 3 Podium */
.top3-podium {
  display: flex;
  justify-content: center;
  align-items: flex-end;
  gap: 1rem;
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.podium-item {
  flex: 1;
  max-width: 300px;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  padding: 2rem 1.5rem;
  text-align: center;
  position: relative;
  transition: transform 0.3s;
  border: 2px solid rgba(255, 255, 255, 0.2);
}

.podium-item:hover {
  transform: translateY(-5px);
}

.podium-1 {
  order: 2;
  transform: scale(1.1);
  background: linear-gradient(135deg, rgba(255, 215, 0, 0.2) 0%, rgba(255, 223, 0, 0.1) 100%);
  border-color: rgba(255, 215, 0, 0.5);
  box-shadow: 0 10px 30px rgba(255, 215, 0, 0.3);
}

.podium-2 {
  order: 1;
  background: linear-gradient(135deg, rgba(192, 192, 192, 0.2) 0%, rgba(192, 192, 192, 0.1) 100%);
  border-color: rgba(192, 192, 192, 0.5);
}

.podium-3 {
  order: 3;
  background: linear-gradient(135deg, rgba(205, 127, 50, 0.2) 0%, rgba(205, 127, 50, 0.1) 100%);
  border-color: rgba(205, 127, 50, 0.5);
}

.podium-medal {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.podium-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  margin: 0 auto 1rem;
  overflow: hidden;
  border: 3px solid rgba(255, 255, 255, 0.3);
}

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-default {
  font-size: 3rem;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
}

.podium-name {
  font-size: 1.3rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.podium-tier-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border-radius: 15px;
  margin-bottom: 1rem;
  font-weight: 600;
}

.tier-name {
  font-size: 0.9rem;
}

.tier-stars {
  font-size: 0.8rem;
}

.podium-stats {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-top: 1rem;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  font-size: 0.9rem;
}

.stat-label {
  opacity: 0.8;
}

.stat-value {
  font-weight: 600;
}

.podium-empty {
  padding: 2rem;
  opacity: 0.5;
}

.empty-text {
  font-size: 0.9rem;
}

/* Filters */
.filters-section {
  max-width: 1200px;
  margin: 2rem auto;
  padding: 0 2rem;
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  align-items: center;
}

.search-box {
  flex: 1;
  min-width: 200px;
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 1rem;
  font-size: 1.2rem;
}

.search-input {
  width: 100%;
  padding: 0.75rem 1rem 0.75rem 3rem;
  background: rgba(255, 255, 255, 0.1);
  border: 2px solid rgba(255, 255, 255, 0.2);
  border-radius: 25px;
  color: white;
  font-size: 1rem;
}

.search-input::placeholder {
  color: rgba(255, 255, 255, 0.5);
}

.filter-controls {
  display: flex;
  gap: 1rem;
}

.filter-select {
  padding: 0.75rem 1rem;
  background: rgba(255, 255, 255, 0.1);
  border: 2px solid rgba(255, 255, 255, 0.2);
  border-radius: 25px;
  color: white;
  font-size: 1rem;
  cursor: pointer;
}

.filter-select option {
  background: #1a1a2e;
  color: white;
}

/* Leaderboard */
.leaderboard-list {
  max-width: 1200px;
  margin: 2rem auto;
  padding: 0 2rem;
}

/* Desktop Table */
.leaderboard-table {
  width: 100%;
  border-collapse: collapse;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 15px;
  overflow: hidden;
}

.leaderboard-table thead {
  background: rgba(255, 255, 255, 0.1);
}

.leaderboard-table th {
  padding: 1rem;
  text-align: left;
  font-weight: 600;
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.leaderboard-row {
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  cursor: pointer;
  transition: background 0.2s;
}

.leaderboard-row:hover {
  background: rgba(255, 255, 255, 0.1);
}

.leaderboard-row.current-user {
  background: rgba(102, 126, 234, 0.2);
  border-left: 4px solid #667eea;
}

.leaderboard-table td {
  padding: 1rem;
}

.col-rank {
  width: 80px;
  font-weight: 700;
  color: #ffd700;
}

.col-avatar {
  width: 60px;
}

.player-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.avatar-img-small {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-default-small {
  font-size: 1.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
}

.col-name {
  font-weight: 600;
}

.tier-badge-small {
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
  padding: 0.3rem 0.6rem;
  border-radius: 10px;
  font-size: 0.85rem;
  font-weight: 600;
}

.tier-stars-small {
  font-size: 0.7rem;
}

.elo-value {
  font-weight: 600;
  color: #4ade80;
}

.wins-value {
  font-weight: 600;
}

.winrate-value {
  font-weight: 600;
  color: #60a5fa;
}

.streak-value {
  font-weight: 600;
}

.streak-positive {
  color: #fbbf24;
}

.streak-negative {
  color: #60a5fa;
}

/* Mobile Cards */
.leaderboard-cards {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.leaderboard-card {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 15px;
  padding: 1.5rem;
  display: flex;
  gap: 1rem;
  align-items: center;
  cursor: pointer;
  transition: all 0.2s;
  border: 2px solid rgba(255, 255, 255, 0.1);
}

.leaderboard-card:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateX(5px);
}

.leaderboard-card.current-user {
  background: rgba(102, 126, 234, 0.2);
  border-color: #667eea;
}

.card-rank {
  font-size: 1.5rem;
  font-weight: 700;
  color: #ffd700;
  min-width: 50px;
}

.card-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  overflow: hidden;
  border: 2px solid rgba(255, 255, 255, 0.3);
  flex-shrink: 0;
}

.avatar-img-card {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-default-card {
  font-size: 2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
}

.card-info {
  flex: 1;
}

.card-name {
  font-size: 1.1rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.card-tier-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
  padding: 0.3rem 0.6rem;
  border-radius: 10px;
  font-size: 0.85rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.tier-name-card {
  font-size: 0.85rem;
}

.tier-stars-card {
  font-size: 0.7rem;
}

.card-stats {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-top: 0.5rem;
}

.card-stat-item {
  display: flex;
  gap: 0.3rem;
  font-size: 0.85rem;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  opacity: 0.6;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
}

.empty-text {
  font-size: 1.2rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.empty-hint {
  font-size: 0.9rem;
  opacity: 0.8;
}

/* Tier Colors */
.tier-bronze_iii, .tier-bronze_ii, .tier-bronze_i {
  background: rgba(205, 127, 50, 0.3);
  color: #CD7F32;
}

.tier-silver_iii, .tier-silver_ii, .tier-silver_i {
  background: rgba(192, 192, 192, 0.3);
  color: #C0C0C0;
}

.tier-gold_iv, .tier-gold_iii, .tier-gold_ii, .tier-gold_i {
  background: rgba(255, 215, 0, 0.3);
  color: #FFD700;
}

.tier-platinum_iv, .tier-platinum_iii, .tier-platinum_ii, .tier-platinum_i {
  background: rgba(229, 228, 226, 0.3);
  color: #E5E4E2;
}

.tier-diamond_v, .tier-diamond_iv, .tier-diamond_iii, .tier-diamond_ii, .tier-diamond_i {
  background: rgba(185, 242, 255, 0.3);
  color: #B9F2FF;
}

.tier-star_glory_v, .tier-star_glory_iv, .tier-star_glory_iii, .tier-star_glory_ii, .tier-star_glory_i {
  background: rgba(155, 89, 182, 0.3);
  color: #9B59B6;
}

.tier-king_strongest, .tier-king_peerless, .tier-king_glory, .tier-king_legendary {
  background: rgba(255, 107, 107, 0.3);
  color: #FF6B6B;
}

/* Responsive */
@media (max-width: 1024px) {
  .desktop-only {
    display: none;
  }
  
  .mobile-only {
    display: block;
  }
}

@media (min-width: 1025px) {
  .desktop-only {
    display: table;
  }
  
  .mobile-only {
    display: none;
  }
}

@media (max-width: 768px) {
  .hero-title {
    font-size: 2rem;
  }
  
  .top3-podium {
    flex-direction: column;
    align-items: center;
  }
  
  .podium-item {
    max-width: 100%;
    width: 100%;
  }
  
  .podium-1 {
    order: 1;
    transform: scale(1);
  }
  
  .podium-2 {
    order: 2;
  }
  
  .podium-3 {
    order: 3;
  }
  
  .filters-section {
    flex-direction: column;
  }
  
  .filter-controls {
    width: 100%;
    flex-direction: column;
  }
  
  .filter-select {
    width: 100%;
  }
}
</style>
