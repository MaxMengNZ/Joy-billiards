<template>
  <div v-if="room" class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content room-detail">
      <div class="modal-header">
        <h2>{{ room.room_name }}</h2>
        <button class="btn-close" @click="$emit('close')">✕</button>
      </div>

      <div class="modal-body">
        <!-- Room Info -->
        <div class="room-info-section">
          <div class="info-grid">
            <div class="info-item">
              <span class="info-label">Status:</span>
              <span class="info-value" :class="room.status">{{ statusText }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Race To:</span>
              <span class="info-value">{{ room.race_to_score }}</span>
            </div>
            <div v-if="room.scheduled_start_time" class="info-item">
              <span class="info-label">Start Time:</span>
              <span class="info-value">{{ formatDateTime(room.scheduled_start_time) }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Break Option:</span>
              <span class="info-value">
                {{ room.break_option === 'alternating' ? 'Alternating Break' : 'Winner Breaks' }}
              </span>
            </div>
            <div v-if="room.match_type" class="info-item">
              <span class="info-label">Match Type:</span>
              <span class="info-value match-type-badge" :class="room.match_type">
                {{ room.match_type === 'matchmaking' ? 'Matchmaking' : 'Challenge' }}
              </span>
            </div>
          </div>
        </div>

        <!-- Room Notes -->
        <div v-if="room.room_notes" class="room-notes-section">
          <h3>Room Notes</h3>
          <div class="notes-content">
            {{ room.room_notes }}
          </div>
        </div>

        <!-- Player Statistics (when both players are in room) -->
        <div v-if="room.player2_id && (player1Stats || player2Stats)" class="player-stats-section">
          <h3>Player Statistics</h3>
          <div class="stats-grid">
            <!-- Player 1 Stats -->
            <div class="player-stats-card">
              <div class="stats-player-header">
                <h4>{{ room.player1?.name }}</h4>
              </div>
              <div v-if="player1Stats" class="stats-content">
                <div class="stat-item">
                  <span class="stat-label">Win Rate:</span>
                  <span class="stat-value">{{ player1Stats.win_rate || 0 }}%</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">Break & Run:</span>
                  <span class="stat-value">{{ player1Stats.break_and_run_count || 0 }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">Rack Run:</span>
                  <span class="stat-value">{{ player1Stats.rack_run_count || 0 }}</span>
                </div>
                <div class="recent-matches">
                  <div class="matches-label">Recent 5 Matches:</div>
                  <div v-if="player1Stats.recent_matches && player1Stats.recent_matches.length > 0" class="matches-list">
                    <div
                      v-for="(match, index) in player1Stats.recent_matches"
                      :key="index"
                      class="match-item"
                      :class="{ won: match.won, lost: !match.won }"
                    >
                      <span class="match-result">{{ match.won ? 'W' : 'L' }}</span>
                      <span class="match-opponent">vs {{ match.opponent_name }}</span>
                      <span class="match-score">{{ match.player_score }}-{{ match.opponent_score }}</span>
                    </div>
                  </div>
                  <div v-else class="no-matches">No recent matches</div>
                </div>
              </div>
              <div v-else class="stats-loading">Loading...</div>
            </div>

            <!-- Player 2 Stats -->
            <div class="player-stats-card">
              <div class="stats-player-header">
                <h4>{{ room.player2?.name }}</h4>
              </div>
              <div v-if="player2Stats" class="stats-content">
                <div class="stat-item">
                  <span class="stat-label">Win Rate:</span>
                  <span class="stat-value">{{ player2Stats.win_rate || 0 }}%</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">Break & Run:</span>
                  <span class="stat-value">{{ player2Stats.break_and_run_count || 0 }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">Rack Run:</span>
                  <span class="stat-value">{{ player2Stats.rack_run_count || 0 }}</span>
                </div>
                <div class="recent-matches">
                  <div class="matches-label">Recent 5 Matches:</div>
                  <div v-if="player2Stats.recent_matches && player2Stats.recent_matches.length > 0" class="matches-list">
                    <div
                      v-for="(match, index) in player2Stats.recent_matches"
                      :key="index"
                      class="match-item"
                      :class="{ won: match.won, lost: !match.won }"
                    >
                      <span class="match-result">{{ match.won ? 'W' : 'L' }}</span>
                      <span class="match-opponent">vs {{ match.opponent_name }}</span>
                      <span class="match-score">{{ match.player_score }}-{{ match.opponent_score }}</span>
                    </div>
                  </div>
                  <div v-else class="no-matches">No recent matches</div>
                </div>
              </div>
              <div v-else class="stats-loading">Loading...</div>
            </div>
          </div>
        </div>

        <!-- Room Actions (Edit & Cancel) -->
        <div v-if="canEditRoom || canCancelRoom" class="room-actions-section">
          <div class="actions-header">
            <h3>Room Management</h3>
            <div class="action-buttons">
              <button 
                v-if="canEditRoom && !isEditing"
                class="btn-edit"
                @click="startEditing"
              >
                Edit Room
              </button>
              <button 
                v-if="canCancelRoom"
                class="btn-cancel-room"
                :class="{ 'btn-cancel-room-warning': room.status === 'in_progress' }"
                @click="handleCancelRoom"
                :disabled="loading"
              >
                {{ room.status === 'in_progress' ? 'Cancel Match' : 'Cancel Room' }}
              </button>
            </div>
          </div>

          <!-- Edit Form -->
          <div v-if="isEditing" class="edit-form">
            <div class="form-group">
              <label>Room Name:</label>
              <input
                v-model="editForm.roomName"
                type="text"
                class="form-input"
                placeholder="Enter room name"
              />
            </div>
            <div class="form-group">
              <label>Race To:</label>
              <div class="wheel-selector">
                <button 
                  class="wheel-btn wheel-up"
                  @click="decreaseRaceTo"
                  :disabled="editForm.raceToScore <= 2"
                >
                  ▲
                </button>
                <div class="wheel-display">
                  <span class="wheel-value">{{ editForm.raceToScore }}</span>
                </div>
                <button 
                  class="wheel-btn wheel-down"
                  @click="increaseRaceTo"
                  :disabled="editForm.raceToScore >= 21"
                >
                  ▼
                </button>
              </div>
            </div>
            <div class="form-group">
              <label>Start Time (Optional):</label>
              <input
                v-model="editForm.scheduledStartTime"
                type="datetime-local"
                class="form-input"
              />
            </div>
            <div class="form-group">
              <label>Break Option</label>
              <div class="break-option-selector">
                <button
                  class="break-option-btn"
                  :class="{ active: editForm.breakOption === 'alternating' }"
                  @click="editForm.breakOption = 'alternating'"
                >
                  Alternating Break
                </button>
                <button
                  class="break-option-btn"
                  :class="{ active: editForm.breakOption === 'winner' }"
                  @click="editForm.breakOption = 'winner'"
                >
                  Winner Breaks
                </button>
              </div>
            </div>
            <div class="form-group">
              <label>Room Notes (Optional)</label>
              <textarea
                v-model="editForm.roomNotes"
                class="form-textarea"
                placeholder="Add a message or notes for this room..."
                rows="3"
              ></textarea>
            </div>
            <div class="edit-form-actions">
              <button class="btn-save" @click="handleUpdateRoom" :disabled="loading">
                Save Changes
              </button>
              <button class="btn-cancel-edit" @click="cancelEditing">
                Cancel
              </button>
            </div>
          </div>
        </div>

        <!-- Players -->
        <div class="players-section">
          <div class="player-card">
            <div class="player-header">
              <span class="player-label">Player 1</span>
              <span v-if="room.player1_ready" class="ready-badge">✓ Ready</span>
              <button
                v-if="canRemovePlayer && room.player1_id && (room.status === 'waiting' || room.status === 'ready')"
                class="btn-remove-player"
                @click="handleRemovePlayer('player1')"
                title="Remove Player 1"
              >
                ✕
              </button>
            </div>
            <div class="player-name">{{ room.player1?.name }}</div>
            <div v-if="room.status === 'in_progress'" class="player-score">
              Score: {{ room.player1_score || 0 }}
            </div>
          </div>

          <div class="vs-divider">VS</div>

          <div class="player-card">
            <div class="player-header">
              <span class="player-label">Player 2</span>
              <span v-if="room.player2_ready" class="ready-badge">✓ Ready</span>
              <button
                v-if="canRemovePlayer && room.player2_id && (room.status === 'waiting' || room.status === 'ready')"
                class="btn-remove-player"
                @click="handleRemovePlayer('player2')"
                title="Remove Player 2"
              >
                ✕
              </button>
            </div>
            <div class="player-name">{{ room.player2?.name || 'Waiting...' }}</div>
            <div v-if="room.status === 'in_progress'" class="player-score">
              Score: {{ room.player2_score || 0 }}
            </div>
          </div>
        </div>

        <!-- Ready to Start -->
        <div v-if="room.status === 'waiting' && canConfirmReady" class="action-section">
          <button 
            class="btn-confirm-ready"
            @click="handleConfirmReady"
            :disabled="isPlayerReady"
          >
            {{ isPlayerReady ? 'Waiting for opponent...' : 'Confirm Ready' }}
          </button>
        </div>

        <!-- Start Match -->
        <div v-if="room.status === 'ready' && canStartMatch" class="action-section">
          <button class="btn-start-match" @click="handleStartMatch">
            Start Match
          </button>
        </div>

        <!-- Complete Match -->
        <div v-if="room.status === 'in_progress' && canCompleteMatch" class="complete-section">
          <h3>Complete Match</h3>
          <div class="complete-form">
            <div class="form-group">
              <label>Winner:</label>
              <select v-model="completeForm.winnerId" class="form-input">
                <option :value="null">Select winner</option>
                <option :value="room.player1_id">{{ room.player1?.name }}</option>
                <option :value="room.player2_id">{{ room.player2?.name }}</option>
              </select>
            </div>
            <div class="form-group">
              <label>Final Score:</label>
              <div class="final-score-inputs">
                <input
                  v-model.number="completeForm.finalPlayer1Score"
                  type="number"
                  min="0"
                  :max="room.race_to_score"
                  class="form-input-small"
                  :placeholder="room.player1?.name"
                />
                <span>-</span>
                <input
                  v-model.number="completeForm.finalPlayer2Score"
                  type="number"
                  min="0"
                  :max="room.race_to_score"
                  class="form-input-small"
                  :placeholder="room.player2?.name"
                />
              </div>
            </div>

            <!-- Player Statistics Input -->
            <div class="player-stats-input-section">
              <h4>Player Statistics</h4>
              
              <!-- Player 1 Stats -->
              <div class="player-stats-input-card">
                <div class="player-stats-header">
                  <strong>{{ room.player1?.name }}</strong>
                </div>
                <div class="stats-input-grid">
                  <div class="stat-input-item">
                    <label>Break & Run:</label>
                    <input
                      v-model.number="completeForm.player1BreakAndRun"
                      type="number"
                      min="0"
                      class="stat-input"
                      placeholder="0"
                    />
                  </div>
                  <div class="stat-input-item">
                    <label>Rack Run:</label>
                    <input
                      v-model.number="completeForm.player1RackRun"
                      type="number"
                      min="0"
                      class="stat-input"
                      placeholder="0"
                    />
                  </div>
                </div>
              </div>

              <!-- Player 2 Stats -->
              <div class="player-stats-input-card">
                <div class="player-stats-header">
                  <strong>{{ room.player2?.name }}</strong>
                </div>
                <div class="stats-input-grid">
                  <div class="stat-input-item">
                    <label>Break & Run:</label>
                    <input
                      v-model.number="completeForm.player2BreakAndRun"
                      type="number"
                      min="0"
                      class="stat-input"
                      placeholder="0"
                    />
                  </div>
                  <div class="stat-input-item">
                    <label>Rack Run:</label>
                    <input
                      v-model.number="completeForm.player2RackRun"
                      type="number"
                      min="0"
                      class="stat-input"
                      placeholder="0"
                    />
                  </div>
                </div>
              </div>
            </div>

            <button 
              class="btn-complete"
              @click="handleCompleteMatch"
              :disabled="!canSubmitComplete"
            >
              Complete Match
            </button>
          </div>
        </div>

        <!-- Error Message -->
        <div v-if="error" class="error-message">
          ⚠️ {{ error }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { useBattleStore } from '../stores/battleStore'

const props = defineProps({
  room: {
    type: Object,
    required: true
  },
  scores: {
    type: Array,
    default: () => []
  },
  currentUser: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['close', 'refresh'])

const battleStore = useBattleStore()

// State
const error = ref('')
const loading = ref(false)
const isEditing = ref(false)
const player1Stats = ref(null)
const player2Stats = ref(null)
const loadingStats = ref(false)

const completeForm = ref({
  winnerId: null,
  finalPlayer1Score: 0,
  finalPlayer2Score: 0,
  player1BreakAndRun: 0,
  player1RackRun: 0,
  player2BreakAndRun: 0,
  player2RackRun: 0
})

const editForm = ref({
  roomName: '',
  raceToScore: 5,
  scheduledStartTime: null,
  breakOption: 'alternating',
  roomNotes: ''
})

// Computed / 计算属性
const statusText = computed(() => {
  const statusMap = {
    waiting: 'Waiting',
    ready: 'Ready',
    in_progress: 'In Progress',
    completed: 'Completed',
    cancelled: 'Cancelled'
  }
  return statusMap[props.room.status] || props.room.status
})

const isPlayer1 = computed(() => {
  return props.currentUser && props.room.player1_id === props.currentUser.id
})

const isPlayer2 = computed(() => {
  return props.currentUser && props.room.player2_id === props.currentUser.id
})

const isAdmin = computed(() => {
  return props.currentUser && props.currentUser.role === 'admin'
})

const isPlayerReady = computed(() => {
  if (isPlayer1.value) return props.room.player1_ready
  if (isPlayer2.value) return props.room.player2_ready
  return false
})

const canConfirmReady = computed(() => {
  return (isPlayer1.value || isPlayer2.value) && props.room.status === 'waiting'
})

const canStartMatch = computed(() => {
  return (isPlayer1.value || isPlayer2.value || isAdmin.value) && 
         props.room.status === 'ready' &&
         props.room.player1_ready &&
         props.room.player2_ready
})

const canCompleteMatch = computed(() => {
  return (isPlayer1.value || isPlayer2.value || isAdmin.value) && 
         props.room.status === 'in_progress'
})

const canSubmitComplete = computed(() => {
  return completeForm.value.winnerId !== null &&
         completeForm.value.finalPlayer1Score >= 0 &&
         completeForm.value.finalPlayer2Score >= 0
})

const isCreator = computed(() => {
  return props.currentUser && props.room.created_by === props.currentUser.id
})

const canEditRoom = computed(() => {
  // Only creator can edit, and only if match hasn't started
  return isCreator.value && 
         props.room.status !== 'in_progress' && 
         props.room.status !== 'completed' &&
         props.room.status !== 'cancelled'
})

const canCancelRoom = computed(() => {
  // Creator or admin can cancel room at any time (except if already completed or cancelled)
  return (isCreator.value || isAdmin.value) && 
         props.room.status !== 'completed' &&
         props.room.status !== 'cancelled'
})

const canRemovePlayer = computed(() => {
  // Only creator or admin can remove players
  return (isCreator.value || isAdmin.value)
})

// Methods / 方法
const handleConfirmReady = async () => {
  error.value = ''
  loading.value = true

  try {
    const result = await battleStore.confirmReady(props.room.id)
    if (result.success) {
      emit('refresh')
    } else {
      error.value = result.error || 'Failed to confirm ready'
    }
  } catch (err) {
    error.value = err.message || 'An error occurred'
  } finally {
    loading.value = false
  }
}

const handleStartMatch = async () => {
  error.value = ''
  loading.value = true

  try {
    const result = await battleStore.startMatch(props.room.id)
    if (result.success) {
      emit('refresh')
    } else {
      error.value = result.error || 'Failed to start match'
    }
  } catch (err) {
    error.value = err.message || 'An error occurred'
  } finally {
    loading.value = false
  }
}

const handleCompleteMatch = async () => {
  error.value = ''
  
  if (!canSubmitComplete.value) {
    error.value = 'Please fill in all required fields'
    return
  }

  loading.value = true

  try {
    const result = await battleStore.completeMatch(props.room.id, {
      winnerId: completeForm.value.winnerId,
      finalPlayer1Score: completeForm.value.finalPlayer1Score,
      finalPlayer2Score: completeForm.value.finalPlayer2Score,
      player1BreakAndRun: completeForm.value.player1BreakAndRun || 0,
      player1RackRun: completeForm.value.player1RackRun || 0,
      player2BreakAndRun: completeForm.value.player2BreakAndRun || 0,
      player2RackRun: completeForm.value.player2RackRun || 0
    })

    if (result.success) {
      // Reset form
      completeForm.value = {
        winnerId: null,
        finalPlayer1Score: 0,
        finalPlayer2Score: 0,
        player1BreakAndRun: 0,
        player1RackRun: 0,
        player2BreakAndRun: 0,
        player2RackRun: 0
      }
      emit('refresh')
    } else {
      error.value = result.error || 'Failed to complete match'
    }
  } catch (err) {
    error.value = err.message || 'An error occurred'
  } finally {
    loading.value = false
  }
}

const formatDateTime = (timestamp) => {
  if (!timestamp) return ''
  const date = new Date(timestamp)
  return date.toLocaleString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Edit room methods
const startEditing = () => {
  editForm.value = {
    roomName: props.room.room_name,
    raceToScore: props.room.race_to_score,
    scheduledStartTime: props.room.scheduled_start_time 
      ? new Date(props.room.scheduled_start_time).toISOString().slice(0, 16)
      : null,
    breakOption: props.room.break_option || 'alternating',
    roomNotes: props.room.room_notes || ''
  }
  isEditing.value = true
}

const cancelEditing = () => {
  isEditing.value = false
  editForm.value = {
    roomName: '',
    raceToScore: 5,
    scheduledStartTime: null,
    breakOption: 'alternating',
    roomNotes: ''
  }
}

const increaseRaceTo = () => {
  if (editForm.value.raceToScore < 21) {
    editForm.value.raceToScore++
  }
}

const decreaseRaceTo = () => {
  if (editForm.value.raceToScore > 2) {
    editForm.value.raceToScore--
  }
}

const handleUpdateRoom = async () => {
  error.value = ''
  loading.value = true

  try {
    const result = await battleStore.updateRoom(props.room.id, {
      roomName: editForm.value.roomName,
      raceToScore: editForm.value.raceToScore,
      scheduledStartTime: editForm.value.scheduledStartTime || null,
      breakOption: editForm.value.breakOption,
      roomNotes: editForm.value.roomNotes || null
    })

    if (result.success) {
      isEditing.value = false
      emit('refresh')
    } else {
      error.value = result.error || 'Failed to update room'
    }
  } catch (err) {
    error.value = err.message || 'An error occurred'
  } finally {
    loading.value = false
  }
}

const handleCancelRoom = async () => {
  const isInProgress = props.room.status === 'in_progress'
  const confirmMessage = isInProgress
    ? 'Are you sure you want to cancel this match? All progress will be lost and this action cannot be undone.'
    : 'Are you sure you want to cancel this room? This action cannot be undone.'
  
  if (!confirm(confirmMessage)) {
    return
  }

  error.value = ''
  loading.value = true

  try {
    const result = await battleStore.cancelRoom(props.room.id)
    if (result.success) {
      emit('refresh')
      emit('close')
    } else {
      error.value = result.error || 'Failed to cancel room'
    }
  } catch (err) {
    error.value = err.message || 'An error occurred'
  } finally {
    loading.value = false
  }
}

const handleRemovePlayer = async (playerToRemove) => {
  const playerName = playerToRemove === 'player1' 
    ? props.room.player1?.name 
    : props.room.player2?.name
  
  if (!confirm(`Are you sure you want to remove ${playerName} from this room?`)) {
    return
  }

  error.value = ''
  loading.value = true

  try {
    const result = await battleStore.removePlayer(props.room.id, playerToRemove)
    if (result.success) {
      emit('refresh')
    } else {
      error.value = result.error || 'Failed to remove player'
    }
  } catch (err) {
    error.value = err.message || 'An error occurred'
  } finally {
    loading.value = false
  }
}

// Load player statistics
const loadPlayerStats = async () => {
  if (!props.room || !props.room.player2_id) {
    player1Stats.value = null
    player2Stats.value = null
    return
  }

  loadingStats.value = true
  try {
    // Load Player 1 stats
    if (props.room.player1_id) {
      const result1 = await battleStore.getPlayerBattleStats(props.room.player1_id)
      if (result1.success && result1.data) {
        // Handle JSONB array response - data is an array with one object
        const statsData = Array.isArray(result1.data) ? result1.data[0] : result1.data
        // Parse recent_matches if it's a string
        if (statsData.recent_matches && typeof statsData.recent_matches === 'string') {
          statsData.recent_matches = JSON.parse(statsData.recent_matches)
        }
        player1Stats.value = statsData
      }
    }

    // Load Player 2 stats
    if (props.room.player2_id) {
      const result2 = await battleStore.getPlayerBattleStats(props.room.player2_id)
      if (result2.success && result2.data) {
        // Handle JSONB array response - data is an array with one object
        const statsData = Array.isArray(result2.data) ? result2.data[0] : result2.data
        // Parse recent_matches if it's a string
        if (statsData.recent_matches && typeof statsData.recent_matches === 'string') {
          statsData.recent_matches = JSON.parse(statsData.recent_matches)
        }
        player2Stats.value = statsData
      }
    }
  } catch (err) {
    console.error('Error loading player stats:', err)
  } finally {
    loadingStats.value = false
  }
}

// Watch room changes from props
watch(() => props.room, (newRoom) => {
  if (newRoom) {
    // Load player stats when both players are in room
    if (newRoom.player2_id) {
      loadPlayerStats()
    }
    // Ensure we're subscribed to this room's updates
    battleStore.setCurrentRoom(newRoom.id)
  }
}, { immediate: true })

// Watch battleStore.currentRoom for real-time updates
watch(() => battleStore.currentRoom, (updatedRoom) => {
  if (updatedRoom && updatedRoom.id === props.room?.id) {
    // Emit refresh to update parent component
    emit('refresh')
  }
}, { deep: true })

// Lifecycle hooks
onMounted(() => {
  // Ensure we're subscribed to this room's updates
  if (props.room?.id) {
    battleStore.setCurrentRoom(props.room.id)
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
  max-width: 800px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  color: white;
  overflow: hidden; /* Prevent double scrollbars */
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 2px solid rgba(255, 255, 255, 0.2);
  flex-shrink: 0; /* Prevent header from shrinking */
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
  overflow-y: auto;
  flex: 1;
  min-height: 0; /* Important for flex scrolling */
}

.room-info-section {
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-label {
  font-size: 0.85rem;
  opacity: 0.8;
}

.info-value {
  font-size: 1rem;
  font-weight: 600;
}

.match-type-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
}

.match-type-badge.matchmaking {
  background: rgba(96, 165, 250, 0.3);
  color: #60a5fa;
}

.match-type-badge.challenge {
  background: rgba(251, 191, 36, 0.3);
  color: #fbbf24;
}

.players-section {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
  padding: 1.5rem;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
}

.player-card {
  flex: 1;
  text-align: center;
}

.player-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
  gap: 0.5rem;
}

.player-label {
  font-size: 0.85rem;
  opacity: 0.8;
}

.ready-badge {
  background: rgba(74, 222, 128, 0.3);
  color: #4ade80;
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 600;
}

.btn-remove-player {
  background: rgba(239, 68, 68, 0.2);
  color: #ef4444;
  border: 1px solid rgba(239, 68, 68, 0.4);
  border-radius: 6px;
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
  min-width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-remove-player:hover {
  background: rgba(239, 68, 68, 0.3);
  border-color: rgba(239, 68, 68, 0.6);
  transform: scale(1.1);
}

.player-name {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.player-score {
  font-size: 1.5rem;
  font-weight: 700;
  color: #4ade80;
}

.vs-divider {
  font-size: 2rem;
  font-weight: 700;
  opacity: 0.6;
}

.action-section {
  margin-bottom: 1.5rem;
}

.btn-confirm-ready,
.btn-start-match {
  width: 100%;
  padding: 1rem;
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}

.btn-confirm-ready:hover:not(:disabled),
.btn-start-match:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

.btn-confirm-ready:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.complete-section {
  margin-bottom: 1.5rem;
  padding: 1.5rem;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
}

.complete-section h3 {
  margin: 0 0 1rem 0;
  font-size: 1.25rem;
}

.complete-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.form-row label {
  font-size: 0.9rem;
  min-width: 120px;
}

.form-input,
.form-input-small {
  flex: 1;
  padding: 0.75rem;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.1);
  color: white;
}

.form-input-small {
  max-width: 100px;
}

.btn-complete {
  padding: 0.75rem;
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s;
}

.btn-complete:hover:not(:disabled) {
  transform: translateY(-2px);
}

.btn-complete:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.error-message {
  background: rgba(255, 0, 0, 0.2);
  border: 2px solid rgba(255, 0, 0, 0.5);
  color: white;
  padding: 0.75rem;
  border-radius: 10px;
  margin-top: 1rem;
}

.final-score-inputs {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.final-score-inputs span {
  font-size: 1.5rem;
  font-weight: 700;
}

/* Room Actions Section */
.room-actions-section {
  margin-bottom: 1.5rem;
  padding: 1.5rem;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
}

.actions-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.actions-header h3 {
  margin: 0;
  font-size: 1.25rem;
}

.action-buttons {
  display: flex;
  gap: 0.75rem;
}

.btn-edit,
.btn-cancel-room {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 10px;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-edit {
  background: rgba(96, 165, 250, 0.3);
  color: #60a5fa;
  border: 2px solid rgba(96, 165, 250, 0.5);
}

.btn-edit:hover {
  background: rgba(96, 165, 250, 0.5);
  border-color: #60a5fa;
}

.btn-cancel-room {
  background: rgba(239, 68, 68, 0.3);
  color: #ef4444;
  border: 2px solid rgba(239, 68, 68, 0.5);
}

.btn-cancel-room:hover:not(:disabled) {
  background: rgba(239, 68, 68, 0.5);
  border-color: #ef4444;
}

.btn-cancel-room:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-cancel-room-warning {
  background: rgba(239, 68, 68, 0.4) !important;
  border-color: rgba(239, 68, 68, 0.7) !important;
  box-shadow: 0 0 10px rgba(239, 68, 68, 0.3);
}

.btn-cancel-room-warning:hover:not(:disabled) {
  background: rgba(239, 68, 68, 0.6) !important;
  border-color: #ef4444 !important;
  box-shadow: 0 0 15px rgba(239, 68, 68, 0.5);
}

/* Edit Form */
.edit-form {
  margin-top: 1rem;
  padding: 1.5rem;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 12px;
}

.edit-form .form-group {
  margin-bottom: 1.5rem;
}

.edit-form .form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  font-size: 0.95rem;
}

.wheel-selector {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: rgba(0, 0, 0, 0.2);
  padding: 1rem;
  border-radius: 12px;
}

.wheel-btn {
  background: rgba(255, 255, 255, 0.2);
  border: 2px solid rgba(255, 255, 255, 0.3);
  color: white;
  width: 50px;
  height: 50px;
  border-radius: 10px;
  cursor: pointer;
  font-size: 1.2rem;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.wheel-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.3);
  border-color: rgba(255, 255, 255, 0.5);
}

.wheel-btn:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.wheel-display {
  flex: 1;
  text-align: center;
  background: rgba(255, 255, 255, 0.1);
  padding: 1rem;
  border-radius: 10px;
}

.wheel-value {
  font-size: 2.5rem;
  font-weight: 700;
  color: white;
}

.edit-form-actions {
  display: flex;
  gap: 1rem;
  margin-top: 1.5rem;
}

.btn-save,
.btn-cancel-edit {
  flex: 1;
  padding: 0.75rem;
  border: none;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-save {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.btn-save:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

.btn-save:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-cancel-edit {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.btn-cancel-edit:hover {
  background: rgba(255, 255, 255, 0.3);
  border-color: rgba(255, 255, 255, 0.5);
}

/* Break Option Selector */
.break-option-selector {
  display: flex;
  gap: 0.75rem;
}

.break-option-btn {
  flex: 1;
  padding: 0.75rem;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.break-option-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  border-color: rgba(255, 255, 255, 0.5);
}

.break-option-btn.active {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  border-color: transparent;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

/* Form Textarea */
.form-textarea {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  font-size: 1rem;
  font-family: inherit;
  resize: vertical;
  transition: all 0.2s;
}

.form-textarea:focus {
  outline: none;
  border-color: rgba(255, 255, 255, 0.6);
  background: rgba(255, 255, 255, 0.15);
}

.form-textarea::placeholder {
  color: rgba(255, 255, 255, 0.6);
}

/* Room Notes Section */
.room-notes-section {
  margin-bottom: 1.5rem;
  padding: 1.5rem;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
}

.room-notes-section h3 {
  margin: 0 0 1rem 0;
  font-size: 1.25rem;
}

.notes-content {
  padding: 1rem;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 10px;
  white-space: pre-wrap;
  word-wrap: break-word;
  line-height: 1.6;
}

/* Player Statistics Section */
.player-stats-section {
  margin-bottom: 1.5rem;
  padding: 1.5rem;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
}

.player-stats-section h3 {
  margin: 0 0 1.5rem 0;
  font-size: 1.25rem;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.player-stats-card {
  padding: 1.5rem;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 12px;
  border: 2px solid rgba(255, 255, 255, 0.1);
}

.stats-player-header {
  margin-bottom: 1rem;
  padding-bottom: 0.75rem;
  border-bottom: 2px solid rgba(255, 255, 255, 0.2);
}

.stats-player-header h4 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: white;
}

.stats-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0;
}

.stat-label {
  font-size: 0.9rem;
  opacity: 0.8;
}

.stat-value {
  font-size: 1rem;
  font-weight: 600;
  color: white;
}

.recent-matches {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 2px solid rgba(255, 255, 255, 0.1);
}

.matches-label {
  font-size: 0.9rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
  opacity: 0.9;
}

.matches-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.match-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 8px;
  font-size: 0.85rem;
}

.match-item.won {
  border-left: 3px solid #4ade80;
}

.match-item.lost {
  border-left: 3px solid #ef4444;
}

.match-result {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.75rem;
}

.match-item.won .match-result {
  background: rgba(74, 222, 128, 0.3);
  color: #4ade80;
}

.match-item.lost .match-result {
  background: rgba(239, 68, 68, 0.3);
  color: #ef4444;
}

.match-opponent {
  flex: 1;
  opacity: 0.9;
}

.match-score {
  font-weight: 600;
  opacity: 0.8;
}

.no-matches {
  padding: 1rem;
  text-align: center;
  opacity: 0.6;
  font-size: 0.9rem;
}

.stats-loading {
  padding: 1rem;
  text-align: center;
  opacity: 0.6;
  font-size: 0.9rem;
}

/* Player Statistics Input Section */
.player-stats-input-section {
  margin-top: 1.5rem;
  padding: 1.5rem;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
}

.player-stats-input-section h4 {
  margin: 0 0 1rem 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.player-stats-input-card {
  margin-bottom: 1rem;
  padding: 1rem;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 10px;
  border: 2px solid rgba(255, 255, 255, 0.1);
}

.player-stats-input-card:last-child {
  margin-bottom: 0;
}

.player-stats-header {
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  font-size: 1rem;
}

.stats-input-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

.stat-input-item {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.stat-input-item label {
  font-size: 0.85rem;
  font-weight: 600;
  opacity: 0.9;
}

.stat-input {
  padding: 0.5rem;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  font-size: 1rem;
  text-align: center;
  transition: all 0.2s;
}

.stat-input:focus {
  outline: none;
  border-color: rgba(255, 255, 255, 0.6);
  background: rgba(255, 255, 255, 0.15);
}

.stat-input::placeholder {
  color: rgba(255, 255, 255, 0.5);
}

/* Mobile Responsive */
@media (max-width: 768px) {
  .modal-overlay {
    align-items: flex-start;
    padding-top: 1rem;
    padding-bottom: calc(80px + 1rem + env(safe-area-inset-bottom)); /* Space for bottom nav */
    overflow-y: auto;
  }

  .modal-content {
    width: 95vw;
    max-width: 95vw;
    max-height: calc(100vh - 80px - 2rem - env(safe-area-inset-bottom)); /* Account for bottom nav */
    border-radius: 16px;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    margin: auto 0; /* Center vertically in available space */
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
    padding-bottom: calc(1.25rem + env(safe-area-inset-bottom)); /* Extra padding for safe area */
    overflow-y: auto;
    flex: 1;
    min-height: 0;
  }

  .room-info-section,
  .room-notes-section,
  .player-stats-section,
  .room-actions-section,
  .ready-section,
  .complete-section,
  .action-section {
    margin-bottom: 1.5rem;
    padding-bottom: calc(1.5rem + env(safe-area-inset-bottom)); /* Extra padding for safe area */
  }

  .info-grid {
    grid-template-columns: 1fr;
    gap: 0.75rem;
  }

  .info-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.25rem;
  }

  .info-label {
    font-size: 0.85rem;
  }

  .info-value {
    font-size: 0.9rem;
  }

  .notes-content {
    font-size: 0.9rem;
    padding: 0.875rem;
  }

  .stats-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .player-stats-card {
    padding: 1rem;
  }

  .stats-player-header h4 {
    font-size: 1rem;
  }

  .stat-item {
    padding: 0.4rem 0;
  }

  .stat-label {
    font-size: 0.85rem;
  }

  .stat-value {
    font-size: 0.95rem;
  }

  .matches-list {
    gap: 0.4rem;
  }

  .match-item {
    padding: 0.625rem;
    font-size: 0.8rem;
    min-height: 44px;
  }

  .match-result {
    width: 28px;
    height: 28px;
    font-size: 0.8rem;
  }

  .actions-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }

  .action-buttons {
    flex-direction: column;
    gap: 0.75rem;
    width: 100%;
  }

  .btn-edit,
  .btn-cancel-room,
  .btn-confirm-ready,
  .btn-start-match,
  .btn-complete,
  .btn-save-edit {
    width: 100%;
    padding: 0.875rem;
    font-size: 1rem;
    min-height: 48px;
  }

  .ready-players {
    flex-direction: column;
    gap: 1rem;
  }

  .ready-player-card {
    padding: 1rem;
  }

  .player-stats-input-section {
    padding: 1.25rem;
  }

  .player-stats-input-card {
    padding: 0.875rem;
  }

  .stats-input-grid {
    grid-template-columns: 1fr;
    gap: 0.75rem;
  }

  .stat-input {
    padding: 0.75rem;
    font-size: 16px; /* Prevent zoom on iOS */
    min-height: 44px;
  }

  .complete-form-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .form-group {
    margin-bottom: 1rem;
  }

  .form-group label {
    font-size: 0.9rem;
    margin-bottom: 0.4rem;
  }

  .form-input,
  .form-select {
    padding: 0.875rem;
    font-size: 16px;
    min-height: 44px;
  }

  .modal-footer {
    padding: 1.25rem;
    flex-direction: column;
    gap: 0.75rem;
  }

  .modal-footer button {
    width: 100%;
    min-height: 48px;
  }
}

@media (max-width: 480px) {
  .modal-overlay {
    padding-top: 0;
    padding-bottom: calc(80px + env(safe-area-inset-bottom)); /* Space for bottom nav */
  }

  .modal-content {
    width: 100vw;
    max-width: 100vw;
    max-height: calc(100vh - 80px - env(safe-area-inset-bottom)); /* Account for bottom nav */
    border-radius: 0;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    margin: 0; /* Full height minus nav */
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

  .room-info-section h3,
  .room-notes-section h3,
  .player-stats-section h3,
  .room-actions-section h3 {
    font-size: 1rem;
  }
}
</style>
