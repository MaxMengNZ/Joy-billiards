<template>
  <div class="battle-rooms-page">
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

      <!-- Floating Create Room Button (Mobile Only) -->
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
import { ref, computed, onMounted, watch } from 'vue'
import { useBattleStore } from '../stores/battleStore'
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

// Computed
const isAdmin = computed(() => {
  return battleStore.currentUser?.role === 'admin'
})

// Computed
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
  // Filter completed rooms from today only
  // Use completed_at if available, otherwise use created_at
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const tomorrow = new Date(today)
  tomorrow.setDate(tomorrow.getDate() + 1)

  return battleStore.rooms.filter(r => {
    if (r.status !== 'completed') return false
    // Use completed_at if available, otherwise fall back to created_at
    const roomDate = new Date(r.completed_at || r.created_at)
    return roomDate >= today && roomDate < tomorrow
  })
})

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

const handleRoomCreated = async () => {
  showCreateRoomModal.value = false
  await loadRooms()
}

const refreshRooms = async () => {
  await loadRooms()
  if (selectedRoom.value) {
    await battleStore.setCurrentRoom(selectedRoom.value.id)
    const updatedRoom = battleStore.rooms.find(r => r.id === selectedRoom.value.id)
    if (updatedRoom) {
      selectedRoom.value = updatedRoom
    }
  }
}

// Lifecycle
onMounted(async () => {
  await battleStore.initCurrentUser()
  await loadRooms()
  
  // Auto-refresh every 5 seconds
  setInterval(() => {
    loadRooms()
  }, 5000)
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
