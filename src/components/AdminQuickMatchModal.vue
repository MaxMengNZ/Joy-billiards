<template>
  <div v-if="show" class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content">
      <div class="modal-header">
        <h2>Admin: Quick Start Match</h2>
        <button class="btn-close" @click="$emit('close')">✕</button>
      </div>

      <div class="modal-body">
        <!-- Room Name -->
        <div class="form-group">
          <label>Room Name</label>
          <input
            v-model="formData.roomName"
            type="text"
            class="form-input"
            placeholder="Enter room name"
          />
        </div>

        <!-- Player 1 Selection -->
        <div class="form-group">
          <label>Player 1</label>
          <div class="search-container">
            <input
              v-model="searchQuery1"
              type="text"
              placeholder="Search by name or ID"
              class="form-input"
              @input="handleSearch1"
            />
            <div v-if="searchResults1.length > 0" class="search-results">
              <div
                v-for="player in searchResults1"
                :key="player.id"
                class="search-result-item"
                :class="{ selected: selectedPlayer1?.id === player.id }"
                @click="selectPlayer1(player)"
              >
                <div class="player-name">{{ player.name }}</div>
                <div class="player-elo">
                  Elo: {{ Math.max(player.elo_rating_pro || 1000, player.elo_rating_student || 1000) }}
                </div>
              </div>
            </div>
            <div v-if="selectedPlayer1" class="selected-player">
              <span>Selected:</span>
              <strong>{{ selectedPlayer1.name }}</strong>
              <button class="btn-remove" @click="selectedPlayer1 = null">✕</button>
            </div>
          </div>
        </div>

        <!-- Player 2 Selection -->
        <div class="form-group">
          <label>Player 2</label>
          <div class="search-container">
            <input
              v-model="searchQuery2"
              type="text"
              placeholder="Search by name or ID"
              class="form-input"
              @input="handleSearch2"
            />
            <div v-if="searchResults2.length > 0" class="search-results">
              <div
                v-for="player in searchResults2"
                :key="player.id"
                class="search-result-item"
                :class="{ selected: selectedPlayer2?.id === player.id }"
                @click="selectPlayer2(player)"
              >
                <div class="player-name">{{ player.name }}</div>
                <div class="player-elo">
                  Elo: {{ Math.max(player.elo_rating_pro || 1000, player.elo_rating_student || 1000) }}
                </div>
              </div>
            </div>
            <div v-if="selectedPlayer2" class="selected-player">
              <span>Selected:</span>
              <strong>{{ selectedPlayer2.name }}</strong>
              <button class="btn-remove" @click="selectedPlayer2 = null">✕</button>
            </div>
          </div>
        </div>

        <!-- Race To Score -->
        <div class="form-group">
          <label>Race To</label>
          <div class="wheel-selector">
            <button 
              class="wheel-btn wheel-up"
              @click="decreaseRaceTo"
              :disabled="formData.raceToScore <= 4"
            >
              ▲
            </button>
            <div class="wheel-display">
              <span class="wheel-value">{{ formData.raceToScore }}</span>
            </div>
            <button 
              class="wheel-btn wheel-down"
              @click="increaseRaceTo"
              :disabled="formData.raceToScore >= 15"
            >
              ▼
            </button>
          </div>
        </div>

        <!-- Break Option -->
        <div class="form-group">
          <label>Break Option</label>
          <div class="break-option-selector">
            <button
              class="break-option-btn"
              :class="{ active: formData.breakOption === 'alternating' }"
              @click="formData.breakOption = 'alternating'"
            >
              Alternating Break
            </button>
            <button
              class="break-option-btn"
              :class="{ active: formData.breakOption === 'winner' }"
              @click="formData.breakOption = 'winner'"
            >
              Winner Breaks
            </button>
          </div>
        </div>

        <!-- Room Notes -->
        <div class="form-group">
          <label>Room Notes (Optional)</label>
          <textarea
            v-model="formData.roomNotes"
            class="form-textarea"
            placeholder="Add a message or notes for this room..."
            rows="3"
          ></textarea>
        </div>

        <!-- Error Message -->
        <div v-if="error" class="error-message">
          ⚠️ {{ error }}
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn-cancel" @click="$emit('close')">
          Cancel
        </button>
        <button 
          class="btn-create"
          @click="handleCreateAndStart"
          :disabled="!canCreate || loading"
        >
          <span v-if="loading">Creating...</span>
          <span v-else>Create & Start Match</span>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useBattleStore } from '../stores/battleStore'

const props = defineProps({
  show: {
    type: Boolean,
    required: true
  }
})

const emit = defineEmits(['close', 'created'])

const battleStore = useBattleStore()

// Form Data
const formData = ref({
  roomName: '',
  raceToScore: 5,
  breakOption: 'alternating',
  roomNotes: ''
})

// Search States
const searchQuery1 = ref('')
const searchQuery2 = ref('')
const searchResults1 = ref([])
const searchResults2 = ref([])
const selectedPlayer1 = ref(null)
const selectedPlayer2 = ref(null)

// UI State
const error = ref('')
const loading = ref(false)

// Computed
const canCreate = computed(() => {
  return formData.value.roomName.trim() && 
         selectedPlayer1.value && 
         selectedPlayer2.value &&
         selectedPlayer1.value.id !== selectedPlayer2.value.id
})

// Methods
const handleSearch1 = async () => {
  if (!searchQuery1.value.trim()) {
    searchResults1.value = []
    return
  }

  try {
    const result = await battleStore.searchUsers(searchQuery1.value)
    if (result.success) {
      searchResults1.value = result.data || []
    }
  } catch (err) {
    console.error('Search error:', err)
    searchResults1.value = []
  }
}

const handleSearch2 = async () => {
  if (!searchQuery2.value.trim()) {
    searchResults2.value = []
    return
  }

  try {
    const result = await battleStore.searchUsers(searchQuery2.value)
    if (result.success) {
      searchResults2.value = result.data || []
    }
  } catch (err) {
    console.error('Search error:', err)
    searchResults2.value = []
  }
}

const selectPlayer1 = (player) => {
  selectedPlayer1.value = player
  searchQuery1.value = ''
  searchResults1.value = []
}

const selectPlayer2 = (player) => {
  selectedPlayer2.value = player
  searchQuery2.value = ''
  searchResults2.value = []
}

const decreaseRaceTo = () => {
  if (formData.value.raceToScore > 4) {
    formData.value.raceToScore--
  }
}

const increaseRaceTo = () => {
  if (formData.value.raceToScore < 15) {
    formData.value.raceToScore++
  }
}

const handleCreateAndStart = async () => {
  if (!canCreate.value) return

  error.value = ''
  loading.value = true

  try {
    // Step 1: Create room with both players
    const createResult = await battleStore.createRoomAsAdmin({
      roomName: formData.value.roomName,
      player1Id: selectedPlayer1.value.id,
      player2Id: selectedPlayer2.value.id,
      raceToScore: formData.value.raceToScore,
      breakOption: formData.value.breakOption,
      roomNotes: formData.value.roomNotes || null
    })

    if (!createResult.success) {
      throw new Error(createResult.error || 'Failed to create room')
    }

    const roomId = createResult.data.id

    // Step 2: Mark both players as ready (admin can do this)
    const readyResult = await battleStore.confirmReady(roomId)
    if (!readyResult.success) {
      throw new Error(readyResult.error || 'Failed to mark players as ready')
    }
    
    // Step 3: Start the match immediately (admin can start even if not ready)
    const startResult = await battleStore.startMatch(roomId)
    
    if (!startResult.success) {
      throw new Error(startResult.error || 'Failed to start match')
    }

    // Reset form
    formData.value = {
      roomName: '',
      raceToScore: 5,
      breakOption: 'alternating',
      roomNotes: ''
    }
    selectedPlayer1.value = null
    selectedPlayer2.value = null
    searchQuery1.value = ''
    searchQuery2.value = ''
    searchResults1.value = []
    searchResults2.value = []

    emit('created', startResult.data)
    emit('close')
  } catch (err) {
    error.value = err.message || 'Failed to create and start match'
    console.error('Error creating and starting match:', err)
  } finally {
    loading.value = false
  }
}
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
  max-width: 600px;
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

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  font-size: 0.95rem;
}

.form-input {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  font-size: 1rem;
  transition: all 0.2s;
}

.form-input:focus {
  outline: none;
  border-color: rgba(255, 255, 255, 0.6);
  background: rgba(255, 255, 255, 0.15);
}

.form-input::placeholder {
  color: rgba(255, 255, 255, 0.6);
}

/* Search Results */
.search-container {
  position: relative;
}

.search-results {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: rgba(0, 0, 0, 0.9);
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  margin-top: 0.5rem;
  max-height: 200px;
  overflow-y: auto;
  z-index: 10;
}

.search-result-item {
  padding: 0.75rem;
  cursor: pointer;
  transition: background 0.2s;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.search-result-item:last-child {
  border-bottom: none;
}

.search-result-item:hover,
.search-result-item.selected {
  background: rgba(255, 255, 255, 0.2);
}

.player-name {
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.player-elo {
  font-size: 0.85rem;
  opacity: 0.8;
}

.selected-player {
  margin-top: 0.75rem;
  padding: 0.75rem;
  background: rgba(74, 222, 128, 0.2);
  border: 2px solid rgba(74, 222, 128, 0.5);
  border-radius: 10px;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-remove {
  margin-left: auto;
  background: rgba(255, 0, 0, 0.3);
  border: none;
  color: white;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Wheel Selector */
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

.error-message {
  background: rgba(255, 0, 0, 0.2);
  border: 2px solid rgba(255, 0, 0, 0.5);
  color: white;
  padding: 0.75rem;
  border-radius: 10px;
  margin-top: 1rem;
}

.modal-footer {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  border-top: 2px solid rgba(255, 255, 255, 0.2);
}

.btn-cancel,
.btn-create {
  flex: 1;
  padding: 0.75rem;
  border: none;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-cancel {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.btn-cancel:hover {
  background: rgba(255, 255, 255, 0.3);
}

.btn-create {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.btn-create:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

.btn-create:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Mobile Responsive */
@media (max-width: 768px) {
  .modal-overlay {
    padding: 0.5rem;
  }

  .modal-content {
    width: 95vw;
    max-width: 95vw;
    max-height: 95vh;
    border-radius: 16px;
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
  }

  .form-group {
    margin-bottom: 1.25rem;
  }

  .form-group label {
    font-size: 0.9rem;
    margin-bottom: 0.4rem;
  }

  .form-input,
  .form-textarea {
    padding: 0.875rem;
    font-size: 16px; /* Prevent zoom on iOS */
    min-height: 44px; /* Touch-friendly */
  }

  .search-results {
    max-height: 180px;
  }

  .search-result-item {
    padding: 0.625rem;
    min-height: 44px;
  }

  .player-name {
    font-size: 0.95rem;
  }

  .player-elo {
    font-size: 0.8rem;
  }

  .selected-player {
    padding: 0.625rem;
    font-size: 0.9rem;
    min-height: 44px;
  }

  .btn-remove {
    width: 28px;
    height: 28px;
    font-size: 0.85rem;
  }

  .wheel-selector {
    padding: 0.875rem;
    gap: 0.75rem;
  }

  .wheel-btn {
    width: 44px;
    height: 44px;
    font-size: 1.1rem;
  }

  .wheel-display {
    padding: 0.875rem;
  }

  .wheel-value {
    font-size: 2rem;
  }

  .break-option-selector {
    flex-direction: column;
    gap: 0.5rem;
  }

  .break-option-btn {
    width: 100%;
    padding: 0.875rem;
    font-size: 0.9rem;
    min-height: 44px;
  }

  .modal-footer {
    padding: 1.25rem;
    flex-direction: column;
    gap: 0.75rem;
  }

  .btn-cancel,
  .btn-create {
    width: 100%;
    padding: 0.875rem;
    font-size: 1rem;
    min-height: 48px; /* Touch-friendly */
  }

  .error-message {
    padding: 0.625rem;
    font-size: 0.9rem;
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

  .wheel-value {
    font-size: 1.75rem;
  }
}
</style>
