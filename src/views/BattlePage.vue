<template>
  <div class="battle-rooms-page">
    <!-- Desktop / Web layout (unchanged) -->
    <div class="hidden md:block">
      <!-- Loading State -->
      <div v-if="battleStore.loading && !battleStore.rooms.length" class="loading-container">
        <div class="spinner"></div>
        <p>Loading...</p>
      </div>

      <!-- Main Content / 主要内容 -->
      <template v-else>
        <!-- Header -->
        <div class="battle-header">
          <div class="header-content">
            <h1 class="battle-title">
              <span class="title-icon">🎱</span>
              Battle Rooms
            </h1>
            <div class="header-actions">
              <router-link 
                to="/battle/leaderboard"
                class="btn-leaderboard"
              >
                <span class="btn-icon">🏆</span>
                <span class="btn-text">Leaderboard</span>
              </router-link>
              <button 
                v-if="battleStore.currentUser"
                class="btn-profile"
                @click="showProfileModal = true"
              >
                <span class="btn-icon">👤</span>
                <span class="btn-text">My Profile</span>
              </button>
              <button 
                v-if="isAdmin"
                class="btn-admin-quick-match"
                @click="showAdminQuickMatchModal = true"
              >
                <span class="btn-icon">⚡</span>
                <span class="btn-text">Admin: Quick Start</span>
              </button>
              <!-- Desktop Create Room Button -->
              <button 
                class="btn-create-room btn-create-room-desktop"
                @click="showCreateRoomModal = true"
              >
                <span class="btn-icon">➕</span>
                <span class="btn-text">Create Room</span>
              </button>
            </div>
          </div>
        </div>

        <!-- Floating Create Room Button (Mobile Only, hidden on desktop) -->
        <button 
          class="btn-create-room-floating"
          @click="showCreateRoomModal = true"
          aria-label="Create Room"
          title="Create Room"
        >
          <span class="floating-icon">➕</span>
        </button>

        <!-- Error Message -->
        <div v-if="battleStore.error" class="error-message">
          ⚠️ {{ battleStore.error }}
        </div>

        <!-- Rooms Grid -->
        <div class="rooms-container">
          <!-- In Progress Rooms -->
          <div v-if="inProgressRooms.length > 0" class="room-section">
            <h2 class="section-title">
              <span class="status-badge in-progress">🟢</span>
              In Progress
            </h2>
            <div class="rooms-grid">
              <RoomCard
                v-for="room in inProgressRooms"
                :key="room.id"
                :room="room"
                :current-user="battleStore.currentUser"
                @enter-room="enterRoom"
              />
            </div>
          </div>

          <!-- Waiting Rooms -->
          <div v-if="waitingRooms.length > 0" class="room-section">
            <h2 class="section-title">
              <span class="status-badge waiting">🟡</span>
              Waiting
            </h2>
            <div class="rooms-grid">
              <RoomCard
                v-for="room in waitingRooms"
                :key="room.id"
                :room="room"
                :current-user="battleStore.currentUser"
                @enter-room="enterRoom"
                @join-room="joinRoom"
              />
            </div>
          </div>

          <!-- Ready Rooms -->
          <div v-if="readyRooms.length > 0" class="room-section">
            <h2 class="section-title">
              <span class="status-badge ready">🔵</span>
              Ready
            </h2>
            <div class="rooms-grid">
              <RoomCard
                v-for="room in readyRooms"
                :key="room.id"
                :room="room"
                :current-user="battleStore.currentUser"
                @enter-room="enterRoom"
              />
            </div>
          </div>

          <!-- Completed Rooms (Today) -->
          <div v-if="completedRooms.length > 0" class="room-section">
            <h2 class="section-title">
              <span class="status-badge completed">✅</span>
              Completed (Today)
            </h2>
            <div class="rooms-grid">
              <RoomCard
                v-for="room in completedRooms"
                :key="room.id"
                :room="room"
                :current-user="battleStore.currentUser"
                @enter-room="enterRoom"
              />
            </div>
          </div>

          <!-- Empty State -->
          <div v-if="battleStore.rooms.length === 0" class="empty-state">
            <div class="empty-icon">🎱</div>
            <p class="empty-text">No rooms available</p>
            <p class="empty-hint">Create a new room to start a battle!</p>
          </div>
        </div>
      </template>
    </div>

    <!-- Mobile layout (Stitch-style Battle UI) -->
    <div class="block md:hidden min-h-screen flex justify-center items-stretch">
      <!-- Mobile container (phone-style card on gradient background) -->
      <div
        class="w-full max-w-[430px] bg-background-light dark:bg-background-dark relative overflow-hidden flex flex-col rounded-[2rem] my-4 shadow-[0_20px_60px_rgba(0,0,0,0.45)]"
      >
      <!-- Status bar spacer -->
      <div class="h-12 w-full"></div>

      <!-- Loading State -->
      <div v-if="battleStore.loading && !battleStore.rooms.length" class="flex-1 flex flex-col items-center justify-center gap-4">
        <div class="spinner"></div>
        <p class="text-sm text-slate-200">Loading Battle rooms...</p>
      </div>

      <!-- Main Content -->
      <template v-else>
        <!-- Header Profile Card Section -->
        <header class="px-6 pt-2 pb-6">
          <div class="flex items-center justify-between mb-6">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-full border-2 border-primary overflow-hidden bg-slate-700 flex items-center justify-center">
                <img
                  v-if="heroStats?.avatar_url"
                  :src="heroStats.avatar_url"
                  :alt="heroStats.name"
                  class="w-full h-full object-cover"
                >
                <span v-else class="material-icons text-primary">sports_esports</span>
              </div>
              <div>
                <p class="text-xs text-slate-400 font-medium uppercase tracking-wider">Competitor</p>
                <h1 class="text-lg font-bold">
                  {{ heroStats?.name || battleStore.currentUser?.name || 'Joy Billiards Player' }}
                </h1>
              </div>
            </div>
            <button
              class="w-10 h-10 rounded-full glass-card flex items-center justify-center"
              @click="showProfileModal = true"
            >
              <span class="material-icons text-primary">person</span>
            </button>
          </div>

          <!-- Stats Hero Card (placeholder values for now) -->
          <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-primary via-primary/80 to-blue-900 p-6 shadow-2xl active-glow">
            <div class="absolute top-0 right-0 p-4 opacity-20">
              <span class="material-icons text-8xl rotate-12">sports_handball</span>
            </div>
            <div class="relative z-10 flex justify-between items-start">
              <div>
                <div class="flex items-center gap-2 mb-1">
                  <span class="text-xs font-bold uppercase tracking-widest text-blue-100">Battle Elo</span>
                  <span class="material-icons text-[14px] text-orange-400 streak-glow">local_fire_department</span>
                </div>
                <div class="text-5xl font-bold tracking-tight mb-4">
                  {{ battleEloLabel }}
                </div>
              </div>
              <div class="text-right">
                <div class="inline-flex items-center px-2 py-1 bg-white/20 rounded-lg backdrop-blur-sm mb-2">
                  <span class="material-icons text-sm mr-1 text-yellow-400">workspace_premium</span>
                  <span class="text-xs font-bold">{{ tierLabel }}</span>
                </div>
                <div class="flex gap-1 justify-end">
                  <span
                    v-for="n in 3"
                    :key="n"
                    class="material-icons text-xs"
                    :class="n <= tierStars ? 'text-yellow-300' : 'text-slate-400'"
                  >
                    {{ n <= tierStars ? 'star' : 'star_outline' }}
                  </span>
                </div>
              </div>
            </div>
            <div class="relative z-10 mt-4 flex items-center justify-between border-t border-white/10 pt-4">
              <div class="flex flex-col">
                <span class="text-[10px] uppercase font-bold text-blue-200">Win Streak</span>
                <div class="flex flex-col gap-1 mt-1">
                  <div class="flex gap-1">
                    <div
                      v-for="n in 5"
                      :key="`streak-top-${n}`"
                      class="w-6 h-1 rounded-full"
                      :class="n <= winStreakBars ? 'bg-neon-green' : 'bg-white/30'"
                    ></div>
                  </div>
                  <div class="flex gap-1">
                    <div
                      v-for="n in 5"
                      :key="`streak-bottom-${n}`"
                      class="w-6 h-1 rounded-full"
                      :class="(n + 5) <= winStreakBars ? 'bg-neon-green' : 'bg-white/30'"
                    ></div>
                  </div>
                </div>
              </div>
              <div class="flex flex-col text-right">
                <span class="text-[10px] uppercase font-bold text-blue-200">Hot Streak</span>
                <span class="text-sm font-bold flex items-center justify-end gap-1">
                  {{ winStreakLabel }}
                  <span class="material-icons text-[14px] text-orange-400">auto_awesome</span>
                </span>
              </div>
            </div>
          </div>
        </header>

        <!-- Navigation Tabs -->
        <div class="px-6 mb-6">
          <div class="bg-slate-200/50 dark:bg-slate-800/50 p-1.5 rounded-xl flex">
            <button class="flex-1 py-2 px-4 rounded-lg bg-white dark:bg-primary text-slate-900 dark:text-white font-bold text-sm shadow-sm">
              Join Room
            </button>
            <router-link
              to="/battle/leaderboard"
              class="flex-1 py-2 px-4 rounded-lg text-center text-slate-500 dark:text-slate-400 font-bold text-sm"
            >
              Leaderboard
            </router-link>
          </div>
        </div>

        <!-- Error Message -->
        <div v-if="battleStore.error" class="mx-6 mb-4 text-xs text-red-300 bg-red-900/40 border border-red-500/40 px-3 py-2 rounded-lg">
          ⚠️ {{ battleStore.error }}
        </div>

        <!-- Room List Section -->
        <div class="flex-1 px-6 overflow-y-auto pb-24">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-sm font-bold uppercase tracking-widest text-slate-400">Active Rooms</h2>
            <span class="text-[10px] font-medium bg-primary/10 text-primary px-2 py-0.5 rounded-full">
              {{ activeRooms.length }} Live
            </span>
          </div>

          <div class="space-y-4">
            <div
              v-for="room in activeRooms"
              :key="room.id"
              :class="[
                'glass-card rounded-xl p-4 flex flex-col gap-4 border',
                room.status === 'waiting' || room.status === 'ready'
                  ? 'border-l-4 border-l-neon-green bg-white/90 text-slate-900'
                  : 'border-slate-700 bg-slate-900/85 text-slate-50'
              ]"
            >
              <div class="flex justify-between items-start">
                <div>
                  <h3 class="font-bold text-lg truncate text-slate-900 dark:text-slate-50">
                    {{ room.room_name || 'Battle Room' }}
                  </h3>
                  <div class="flex items-center gap-3 mt-1 text-xs text-slate-500 dark:text-slate-300">
                    <span class="flex items-center gap-1">
                      <span class="material-icons text-xs">adjust</span>
                      9-Ball
                    </span>
                    <span class="flex items-center gap-1">
                      <span class="material-icons text-xs">format_list_numbered</span>
                      Race to {{ room.race_to_score || 5 }}
                    </span>
                    <span
                      v-if="room.table_number"
                      class="hidden sm:inline-flex items-center gap-1"
                    >
                      <span class="material-icons text-xs">table_bar</span>
                      Table {{ room.table_number }}
                    </span>
                  </div>
                </div>
                <div
                  class="text-[10px] font-black px-2 py-1 rounded-lg uppercase"
                  :class="{
                    'bg-neon-green/10 text-neon-green': room.status === 'waiting' || room.status === 'ready',
                    'bg-slate-700 text-slate-300': room.status === 'in_progress'
                  }"
                >
                  {{ statusLabel(room.status) }}
                </div>
              </div>

              <div class="flex justify-between items-center">
                <div class="flex -space-x-3">
                  <div class="w-8 h-8 rounded-full border-2 border-background-dark overflow-hidden bg-slate-700 flex items-center justify-center">
                    <img
                      v-if="room.player1?.avatar_url"
                      :src="room.player1.avatar_url"
                      :alt="room.player1?.name"
                      class="w-full h-full object-cover"
                    >
                    <span v-else class="material-icons text-xs text-slate-300">person</span>
                  </div>
                  <div
                    v-if="room.player2_id"
                    class="w-8 h-8 rounded-full border-2 border-background-dark overflow-hidden bg-slate-700 flex items-center justify-center"
                  >
                    <img
                      v-if="room.player2?.avatar_url"
                      :src="room.player2.avatar_url"
                      :alt="room.player2?.name"
                      class="w-full h-full object-cover"
                    >
                    <span v-else class="material-icons text-xs text-slate-300">person</span>
                  </div>
                  <div
                    v-else
                    class="w-8 h-8 rounded-full border-2 border-dashed border-slate-600 flex items-center justify-center bg-background-dark/50"
                  >
                    <span class="material-icons text-xs text-slate-400">person_add</span>
                  </div>
                </div>

                <!-- Actions -->
                <button
                  v-if="room.status === 'waiting' || room.status === 'ready'"
                  class="px-5 py-2 bg-primary text-white text-xs font-bold rounded-lg uppercase tracking-wide disabled:opacity-40 disabled:cursor-not-allowed"
                  :disabled="!canJoinRoom(room)"
                  @click="joinRoom(room)"
                >
                  Join Game
                </button>
                <button
                  v-else
                  class="px-5 py-2 bg-white/10 text-slate-200 text-xs font-bold rounded-lg uppercase tracking-wide"
                  @click="enterRoom(room)"
                >
                  View Room
                </button>
              </div>
            </div>
          </div>

          <!-- Completed Rooms (Today) -->
          <div v-if="completedRooms.length" class="mt-8">
            <h2 class="text-sm font-bold uppercase tracking-widest text-slate-400 mb-3">
              Completed (Today)
            </h2>
            <div class="space-y-3">
              <RoomCard
                v-for="room in completedRooms"
                :key="room.id"
                :room="room"
                :current-user="battleStore.currentUser"
                @enter-room="enterRoom"
              />
            </div>
          </div>

          <!-- Empty State -->
          <div
            v-if="!activeRooms.length && !completedRooms.length && !battleStore.loading"
            class="mt-10 text-center text-slate-400 text-sm"
          >
            <div class="text-4xl mb-2">🎱</div>
            <p class="font-semibold">No Battle rooms yet</p>
            <p class="text-xs mt-1">Tap the + button to create a new match.</p>
          </div>
        </div>

        <!-- Floating Action Button -->
        <button
          class="absolute bottom-24 right-6 w-14 h-14 bg-primary rounded-full shadow-lg shadow-primary/40 flex items-center justify-center transition-transform active:scale-90 z-20"
          @click="showCreateRoomModal = true"
          aria-label="Create Battle Room"
        >
          <span class="material-icons text-3xl text-white">add</span>
        </button>

        <!-- Bottom Navigation -->
        <nav class="absolute bottom-0 left-0 right-0 h-20 bg-background-dark/80 backdrop-blur-xl border-t border-white/5 flex items-center justify-around px-4 pb-2 z-10 text-slate-500">
          <div class="flex flex-col items-center gap-1 text-primary">
            <span class="material-icons">sports_esports</span>
            <span class="text-[10px] font-bold uppercase tracking-tighter">Battle</span>
          </div>
          <div class="flex flex-col items-center gap-1">
            <span class="material-icons">history</span>
            <span class="text-[10px] font-bold uppercase tracking-tighter">History</span>
          </div>
          <router-link
            to="/battle/leaderboard"
            class="flex flex-col items-center gap-1"
          >
            <span class="material-icons">emoji_events</span>
            <span class="text-[10px] font-bold uppercase tracking-tighter">Ranks</span>
          </router-link>
          <button
            class="flex flex-col items-center gap-1"
            @click="showProfileModal = true"
          >
            <span class="material-icons">person_outline</span>
            <span class="text-[10px] font-bold uppercase tracking-tighter">Profile</span>
          </button>
        </nav>
      </template>
      </div> <!-- end mobile container -->
    </div> <!-- end mobile wrapper -->

    <!-- Admin Quick Match Modal -->
    <AdminQuickMatchModal
      v-if="showAdminQuickMatchModal"
      :show="showAdminQuickMatchModal"
      @close="showAdminQuickMatchModal = false"
      @created="handleRoomCreated"
    />

    <!-- Create Room Modal -->
    <CreateRoomModal
      v-if="showCreateRoomModal"
      :show="showCreateRoomModal"
      @close="showCreateRoomModal = false"
      @created="handleRoomCreated"
    />

    <!-- Room Detail Modal -->
    <RoomDetailModal
      v-if="selectedRoom"
      :room="selectedRoom"
      :scores="battleStore.roomScores"
      :current-user="battleStore.currentUser"
      @close="selectedRoom = null"
      @refresh="refreshRooms"
    />

    <!-- Battle Profile Modal -->
    <BattleProfileModal
      v-if="showProfileModal"
      :show="showProfileModal"
      @close="showProfileModal = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useBattleStore } from '../stores/battleStore'
import { supabase } from '../config/supabase'
import { getTodayNZStartEnd } from '../utils/timezone'
import RoomCard from '../components/BattleRoomCard.vue'
import CreateRoomModal from '../components/CreateRoomModal.vue'
import RoomDetailModal from '../components/RoomDetailModal.vue'
import AdminQuickMatchModal from '../components/AdminQuickMatchModal.vue'
import BattleProfileModal from '../components/BattleProfileModal.vue'

const battleStore = useBattleStore()

// State
const showCreateRoomModal = ref(false)
const showAdminQuickMatchModal = ref(false)
const showProfileModal = ref(false)
const selectedRoom = ref(null)
const heroStats = ref(null)
const heroStatsLoading = ref(false)

// Computed
const isAdmin = computed(() => {
  return battleStore.currentUser?.role === 'admin'
})

// Computed
const activeRooms = computed(() => {
  return battleStore.rooms.filter(r => ['waiting', 'ready', 'in_progress'].includes(r.status))
})

const inProgressRooms = computed(() => {
  return battleStore.rooms.filter(r => r.status === 'in_progress')
})

const waitingRooms = computed(() => {
  return battleStore.rooms.filter(r => r.status === 'waiting')
})

const readyRooms = computed(() => {
  return battleStore.rooms.filter(r => r.status === 'ready')
})

const completedRooms = computed(() => {
  // Filter completed rooms from today only (New Zealand time)
  const { startISO, endISO } = getTodayNZStartEnd()
  const start = new Date(startISO).getTime()
  const end = new Date(endISO).getTime()
  return battleStore.rooms.filter(r => {
    if (r.status !== 'completed') return false
    // completed_at might be NULL for some older rows; fallback to updated_at
    const roomDate = new Date(r.completed_at || r.updated_at || r.created_at).getTime()
    return roomDate >= start && roomDate <= end
  })
})

// Map internal tier value to human-readable name
const formatTierName = (tier) => {
  if (!tier) return 'Unranked'
  const tierMap = {
    bronze_iii: 'Bronze III',
    bronze_ii: 'Bronze II',
    bronze_i: 'Bronze I',
    silver_iii: 'Silver III',
    silver_ii: 'Silver II',
    silver_i: 'Silver I',
    gold_iv: 'Gold IV',
    gold_iii: 'Gold III',
    gold_ii: 'Gold II',
    gold_i: 'Gold I',
    platinum_iv: 'Platinum IV',
    platinum_iii: 'Platinum III',
    platinum_ii: 'Platinum II',
    platinum_i: 'Platinum I',
    diamond_v: 'Diamond V',
    diamond_iv: 'Diamond IV',
    diamond_iii: 'Diamond III',
    diamond_ii: 'Diamond II',
    diamond_i: 'Diamond I',
    star_glory_v: 'Master V',
    star_glory_iv: 'Master IV',
    star_glory_iii: 'Master III',
    star_glory_ii: 'Master II',
    star_glory_i: 'Master I',
    king_strongest: 'Grand Master',
    king_peerless: 'The King',
    king_glory: 'Legend',
    king_legendary: 'Hall of Fame'
  }
  return tierMap[tier] || tier
}

// Stats for hero card (from users table Battle fields)
const battleEloLabel = computed(() => {
  if (heroStats.value?.battle_elo_rating) {
    return Math.round(heroStats.value.battle_elo_rating)
  }
  return 1000
})

const tierLabel = computed(() => {
  return formatTierName(heroStats.value?.battle_tier)
})

const tierStars = computed(() => {
  return heroStats.value?.battle_stars || 0
})

const currentStreak = computed(() => {
  return heroStats.value?.current_win_streak || 0
})

const winStreakBars = computed(() => {
  // Show up to 10 bars (2 rows of 5)
  const streak = currentStreak.value
  if (!streak) return 0
  return Math.min(10, streak)
})

const winStreakLabel = computed(() => {
  const streak = currentStreak.value
  if (!streak) return 'No streak yet'
  return `${streak} WINS`
})

const statusLabel = (status) => {
  const map = {
    waiting: 'Waiting',
    ready: 'Ready',
    in_progress: 'In Progress',
    completed: 'Completed',
    cancelled: 'Cancelled'
  }
  return map[status] || status
}

// Methods
const loadRooms = async () => {
  await battleStore.loadRooms()
}

const enterRoom = async (room) => {
  await battleStore.setCurrentRoom(room.id)
  selectedRoom.value = room
}

const joinRoom = async (room) => {
  const result = await battleStore.joinRoom(room.id)
  if (result.success) {
    await loadRooms()
  }
}

const canJoinRoom = (room) => {
  const user = battleStore.currentUser
  if (!user) return false
  if (room.status !== 'waiting') return false
  if (room.player2_id) return false
  if (room.player1_id === user.id) return false
  return true
}

// Load hero stats for current user (Battle Elo, tier, streak)
const loadHeroStats = async () => {
  try {
    heroStatsLoading.value = true
    // Ensure we have currentUser
    if (!battleStore.currentUser) {
      await battleStore.initCurrentUser()
    }
    if (!battleStore.currentUser?.id) return

    const { data, error } = await supabase
      .from('users')
      .select(`
        id,
        name,
        avatar_url,
        battle_elo_rating,
        battle_tier,
        battle_stars,
        current_win_streak,
        season_best_win_streak,
        battle_wins,
        battle_losses
      `)
      .eq('id', battleStore.currentUser.id)
      .single()

    if (!error && data) {
      heroStats.value = data
    }
  } catch (err) {
    console.error('[BattlePage] Failed to load hero stats:', err)
  } finally {
    heroStatsLoading.value = false
  }
}

const handleRoomCreated = async () => {
  showCreateRoomModal.value = false
  await loadRooms()
}

const refreshRooms = async () => {
  await loadRooms()
  if (selectedRoom.value) {
    // Find updated room from store
    const updatedRoom = battleStore.rooms.find(r => r.id === selectedRoom.value.id)
    if (updatedRoom) {
      selectedRoom.value = updatedRoom
    }
    // Also update currentRoom in store (this will trigger realtime subscription)
    await battleStore.setCurrentRoom(selectedRoom.value.id)
  }
}

// Lifecycle
onMounted(async () => {
  await battleStore.initCurrentUser()
  await loadRooms()
  await loadHeroStats()
  
  // Subscribe to real-time updates for all rooms
  battleStore.subscribeToRooms()
  
  // Keep auto-refresh as backup (every 10 seconds, less frequent since we have realtime)
  setInterval(() => {
    loadRooms()
  }, 10000)
})

// Cleanup on unmount
onUnmounted(() => {
  battleStore.unsubscribe()
})
</script>

<style scoped>
.battle-rooms-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 2rem;
  color: white;
}

/* Header / 头部 */
.battle-header {
  margin-bottom: 2rem;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1400px;
  margin: 0 auto;
}

.header-actions {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.battle-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.title-icon {
  font-size: 3rem;
}

.btn-admin-quick-match {
  background: linear-gradient(135deg, #4ade80 0%, #22c55e 100%);
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  transition: transform 0.2s, box-shadow 0.2s;
}

.btn-admin-quick-match:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

.btn-admin-quick-match:active {
  transform: translateY(0);
}

.btn-leaderboard {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: linear-gradient(135deg, #ffd700 0%, #ffed4e 100%);
  color: #1a1a2e;
  border: none;
  border-radius: 25px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  text-decoration: none;
  box-shadow: 0 4px 15px rgba(255, 215, 0, 0.3);
}

.btn-leaderboard:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(255, 215, 0, 0.4);
}

.btn-profile {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.3);
  padding: 1rem 2rem;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.2s;
}

.btn-profile:hover {
  background: rgba(255, 255, 255, 0.3);
  border-color: rgba(255, 255, 255, 0.5);
  transform: translateY(-2px);
}

.btn-create-room {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  transition: transform 0.2s, box-shadow 0.2s;
}

.btn-create-room:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

.btn-create-room:active {
  transform: translateY(0);
}

/* Error Message */
.error-message {
  background: rgba(255, 0, 0, 0.2);
  border: 2px solid rgba(255, 0, 0, 0.5);
  color: white;
  padding: 1rem;
  border-radius: 10px;
  margin-bottom: 2rem;
  max-width: 1400px;
  margin-left: auto;
  margin-right: auto;
}

/* Rooms Container / 房间容器 */
.rooms-container {
  max-width: 1400px;
  margin: 0 auto;
}

.room-section {
  margin-bottom: 3rem;
}

.section-title {
  font-size: 1.5rem;
  font-weight: 600;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.status-badge {
  font-size: 1.2rem;
}

.rooms-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 1.5rem;
}

/* Empty State / 空状态 */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 20px;
  backdrop-filter: blur(10px);
}

.empty-icon {
  font-size: 5rem;
  margin-bottom: 1rem;
}

.empty-text {
  font-size: 1.5rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.empty-hint {
  font-size: 1rem;
  opacity: 0.8;
}

/* Loading / 加载 */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
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

/* Floating Create Room Button (Mobile Only) */
.btn-create-room-floating {
  display: none; /* Hidden on desktop */
}

/* Responsive - Mobile */
@media (max-width: 768px) {
  .battle-rooms-page {
    padding: 1rem;
    padding-bottom: calc(100px + 1rem + env(safe-area-inset-bottom)); /* Space for bottom nav + floating button */
  }

  .header-content {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }

  .battle-title {
    font-size: 1.75rem;
  }

  .title-icon {
    font-size: 2rem;
  }

  .header-actions {
    flex-direction: column;
    gap: 0.75rem;
    width: 100%;
  }

  /* Hide desktop create room button on mobile */
  .btn-create-room-desktop {
    display: none;
  }

  .btn-profile,
  .btn-admin-quick-match {
    width: 100%;
    padding: 0.875rem 1.5rem;
    font-size: 1rem;
    min-height: 48px; /* Touch-friendly */
    justify-content: center;
  }

  .btn-icon {
    font-size: 1.2rem;
  }

  /* Show floating button on mobile */
  .btn-create-room-floating {
    display: flex;
    position: fixed;
    bottom: calc(80px + 16px + env(safe-area-inset-bottom)); /* Above bottom nav */
    right: 16px;
    width: 64px;
    height: 64px;
    border-radius: 50%;
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    color: white;
    border: 3px solid rgba(255, 255, 255, 0.3);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4), 0 0 0 4px rgba(240, 147, 251, 0.2);
    cursor: pointer;
    z-index: 1001; /* Higher than social button (1000) and bottom nav (1000) */
    align-items: center;
    justify-content: center;
    transition: all 0.3s ease;
    touch-action: manipulation;
    -webkit-tap-highlight-color: transparent;
  }

  .btn-create-room-floating:active {
    transform: scale(0.9);
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
  }

  .btn-create-room-floating:hover {
    transform: scale(1.05);
    box-shadow: 0 6px 25px rgba(0, 0, 0, 0.5), 0 0 0 6px rgba(240, 147, 251, 0.3);
  }

  .floating-icon {
    font-size: 28px;
    line-height: 1;
    font-weight: 300;
  }

  .rooms-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .section-title {
    font-size: 1.25rem;
    margin-bottom: 1rem;
  }

  .room-section {
    margin-bottom: 2rem;
  }

  .empty-state {
    padding: 3rem 1.5rem;
  }

  .empty-icon {
    font-size: 4rem;
  }

  .empty-text {
    font-size: 1.25rem;
  }

  .empty-hint {
    font-size: 0.9rem;
  }
}

/* Extra Small Mobile */
@media (max-width: 480px) {
  .battle-rooms-page {
    padding: 0.75rem;
    padding-bottom: calc(100px + 0.75rem + env(safe-area-inset-bottom));
  }

  .battle-title {
    font-size: 1.5rem;
  }

  .title-icon {
    font-size: 1.75rem;
  }

  .btn-leaderboard,
  .btn-profile,
  .btn-admin-quick-match {
    padding: 0.75rem 1.25rem;
    font-size: 0.95rem;
  }

  .btn-create-room-floating {
    width: 60px;
    height: 60px;
    bottom: calc(80px + 12px + env(safe-area-inset-bottom));
    right: 12px;
  }

  .floating-icon {
    font-size: 26px;
  }

  .section-title {
    font-size: 1.1rem;
  }

  .empty-state {
    padding: 2rem 1rem;
  }

  .empty-icon {
    font-size: 3.5rem;
  }

  .empty-text {
    font-size: 1.1rem;
  }
}
</style>
