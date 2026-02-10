<template>
  <div class="room-card" :class="room.status">
    <div class="room-header">
      <div class="room-name">{{ room.room_name }}</div>
      <div class="room-status-badge" :class="room.status">
        {{ statusText }}
      </div>
    </div>

    <div class="room-players">
      <div class="player-info player-left">
        <div class="player-avatar">
          <img
            v-if="room.player1?.avatar_url"
            :src="room.player1.avatar_url"
            :alt="room.player1?.name"
            class="avatar-image"
          />
          <span v-else class="avatar-icon">🎱</span>
        </div>
        <div class="player-label">Player 1</div>
        <div class="player-name">{{ room.player1?.name || 'Loading...' }}</div>
      </div>
      <div class="vs-divider">VS</div>
      <div class="player-info player-right">
        <div class="player-avatar">
          <img
            v-if="room.player2?.avatar_url"
            :src="room.player2.avatar_url"
            :alt="room.player2?.name"
            class="avatar-image"
          />
          <span v-else class="avatar-icon">🎱</span>
        </div>
        <div class="player-label">Player 2</div>
        <div class="player-name">
          {{ room.player2?.name || 'Waiting...' }}
        </div>
      </div>
    </div>

    <div class="room-info">
      <div v-if="room.table_number" class="info-item">
        <span class="info-label">Table:</span>
        <span class="info-value table-number">Table {{ room.table_number }}</span>
      </div>
      <div class="info-item">
        <span class="info-label">Race to:</span>
        <span class="info-value">{{ room.race_to_score }}</span>
      </div>
      <div class="info-item">
        <span class="info-label">Break:</span>
        <span class="info-value">
          {{ room.break_option === 'alternating' ? 'Alternating' : 'Winner' }}
        </span>
      </div>
      <div v-if="room.match_type" class="info-item">
        <span class="info-label">Type:</span>
        <span class="info-value match-type" :class="room.match_type">
          {{ room.match_type === 'matchmaking' ? 'Matchmaking' : 'Challenge' }}
        </span>
      </div>
    </div>

    <div v-if="room.status === 'in_progress'" class="room-score">
      <div class="score-display">
        <span class="score-value">{{ room.player1_score || 0 }}</span>
        <span class="score-separator">-</span>
        <span class="score-value">{{ room.player2_score || 0 }}</span>
      </div>
    </div>

    <div class="room-actions">
      <button 
        v-if="canJoin"
        class="btn-action btn-join"
        @click="$emit('join-room', room)"
      >
        Join
      </button>
      <button 
        class="btn-action btn-enter"
        @click="$emit('enter-room', room)"
      >
        {{ room.status === 'in_progress' ? 'View' : 'Enter' }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  room: {
    type: Object,
    required: true
  },
  currentUser: {
    type: Object,
    default: null
  }
})

defineEmits(['enter-room', 'join-room'])

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

const canJoin = computed(() => {
  if (!props.currentUser) return false
  if (props.room.status !== 'waiting') return false
  if (!props.room.player2_id) return true
  return false
})
</script>

<style scoped>
.room-card {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border: 2px solid rgba(255, 255, 255, 0.2);
  border-radius: 16px;
  padding: 1.5rem;
  transition: all 0.3s;
  cursor: pointer;
}

.room-card:hover {
  background: rgba(255, 255, 255, 0.25);
  border-color: rgba(255, 255, 255, 0.4);
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
}

.room-card.in_progress {
  border-color: #4ade80;
  box-shadow: 0 0 20px rgba(74, 222, 128, 0.3);
}

.room-card.waiting {
  border-color: #fbbf24;
}

.room-card.ready {
  border-color: #60a5fa;
}

.room-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.room-name {
  font-size: 1.25rem;
  font-weight: 600;
  color: white;
}

.room-status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
}

.room-status-badge.waiting {
  background: rgba(251, 191, 36, 0.3);
  color: #fbbf24;
}

.room-status-badge.ready {
  background: rgba(96, 165, 250, 0.3);
  color: #60a5fa;
}

.room-status-badge.in_progress {
  background: rgba(74, 222, 128, 0.3);
  color: #4ade80;
}

.room-players {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
  padding: 1rem;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
}

.player-info {
  flex: 1;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.player-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.avatar-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}

.avatar-icon {
  font-size: 2rem;
}

.player-label {
  font-size: 0.85rem;
  opacity: 0.8;
  margin-bottom: 0;
}

.player-name {
  font-size: 1rem;
  font-weight: 600;
  color: white;
}

.vs-divider {
  font-size: 1.5rem;
  font-weight: 700;
  color: rgba(255, 255, 255, 0.6);
  flex-shrink: 0;
  padding: 0 0.5rem;
}

.room-info {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
  row-gap: 0.75rem;
  margin-bottom: 1rem;
  padding: 0.75rem;
  background: rgba(0, 0, 0, 0.1);
  border-radius: 8px;
}

.info-item {
  display: flex;
  gap: 0.5rem;
  align-items: center;
  min-width: 140px;
}

.info-label {
  font-size: 0.9rem;
  opacity: 0.8;
}

.info-value {
  font-size: 0.9rem;
  font-weight: 600;
  color: white;
  min-width: 0;
}

.match-type {
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  font-size: 0.85rem;
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.match-type.matchmaking {
  background: rgba(96, 165, 250, 0.3);
  color: #60a5fa;
}

.match-type.challenge {
  background: rgba(251, 191, 36, 0.3);
  color: #fbbf24;
}

.room-score {
  margin-bottom: 1rem;
  padding: 1rem;
  background: rgba(74, 222, 128, 0.2);
  border-radius: 12px;
  text-align: center;
}

.score-display {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
}

.score-value {
  font-size: 2rem;
  font-weight: 700;
  color: white;
}

.score-separator {
  font-size: 1.5rem;
  opacity: 0.6;
}

.room-actions {
  display: flex;
  gap: 0.75rem;
}

.btn-action {
  flex: 1;
  padding: 0.75rem;
  border: none;
  border-radius: 10px;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-join {
  background: rgba(251, 191, 36, 0.3);
  color: #fbbf24;
  border: 2px solid rgba(251, 191, 36, 0.5);
}

.btn-join:hover {
  background: rgba(251, 191, 36, 0.5);
  border-color: #fbbf24;
}

.btn-enter {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.btn-enter:hover {
  background: rgba(255, 255, 255, 0.3);
  border-color: rgba(255, 255, 255, 0.5);
}

/* Mobile Responsive */
@media (max-width: 768px) {
  .room-card {
    padding: 1.25rem;
  }

  .room-name {
    font-size: 1.1rem;
  }

  .room-status-badge {
    font-size: 0.8rem;
    padding: 0.2rem 0.6rem;
  }

  .room-players {
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    gap: 0.5rem;
    padding: 1rem;
  }

  .player-info {
    flex: 1;
    min-width: 0; /* Allow text truncation */
  }

  .player-left {
    text-align: left;
    align-items: flex-start;
  }

  .player-right {
    text-align: right;
    align-items: flex-end;
  }

  .player-avatar {
    width: 50px;
    height: 50px;
    margin-bottom: 0.25rem;
  }

  .avatar-icon {
    font-size: 1.5rem;
  }

  .vs-divider {
    font-size: 1.25rem;
    flex-shrink: 0;
    padding: 0 0.25rem;
  }

  .player-label {
    font-size: 0.75rem;
    margin-bottom: 0.125rem;
  }

  .player-name {
    font-size: 0.9rem;
    word-break: break-word;
  }

  .room-info {
    flex-direction: column;
    gap: 0.75rem;
    padding: 0.625rem;
  }

  .info-item {
    justify-content: space-between;
    width: 100%;
  }

  .info-label {
    font-size: 0.85rem;
  }

  .info-value {
    font-size: 0.85rem;
  }

  .room-score {
    padding: 0.875rem;
  }

  .score-value {
    font-size: 1.75rem;
  }

  .score-separator {
    font-size: 1.25rem;
  }

  .room-actions {
    flex-direction: column;
    gap: 0.5rem;
  }

  .btn-action {
    width: 100%;
    padding: 0.875rem;
    font-size: 0.95rem;
    min-height: 44px; /* Touch-friendly */
  }
}

@media (max-width: 480px) {
  .room-card {
    padding: 1rem;
  }

  .room-name {
    font-size: 1rem;
  }

  .room-players {
    padding: 0.875rem;
    gap: 0.375rem;
  }

  .player-avatar {
    width: 45px;
    height: 45px;
  }

  .avatar-icon {
    font-size: 1.25rem;
  }

  .vs-divider {
    font-size: 1.1rem;
  }

  .player-label {
    font-size: 0.7rem;
  }

  .player-name {
    font-size: 0.85rem;
  }

  .score-value {
    font-size: 1.5rem;
  }
}
</style>
