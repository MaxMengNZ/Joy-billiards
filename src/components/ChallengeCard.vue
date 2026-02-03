<template>
  <div class="challenge-card" :class="challengeStatusClass">
    <div class="challenge-header">
      <div class="players-info">
        <div class="player">
          <strong>{{ challenge.challenger?.name || 'Unknown' }}</strong>
          <span class="player-label">Challenger / 挑战者</span>
        </div>
        <div class="vs">VS</div>
        <div class="player">
          <strong>{{ challenge.opponent?.name || 'Unknown' }}</strong>
          <span class="player-label">Opponent / 对手</span>
        </div>
      </div>
      <div class="challenge-status">
        <span :class="statusBadgeClass">{{ statusText }}</span>
      </div>
    </div>

    <div class="challenge-details">
      <div class="detail-item">
        <span class="detail-label">Type / 类型:</span>
        <span class="detail-value">{{ challenge.challenge_type === 'battle' ? 'Battle / 对战' : 'Friendly / 友谊赛' }}</span>
      </div>
      <div class="detail-item">
        <span class="detail-label">Division / 组别:</span>
        <span class="detail-value">{{ challenge.division === 'pro' ? 'Pro' : 'Student' }}</span>
      </div>
      <div class="detail-item">
        <span class="detail-label">Race to / 目标:</span>
        <span class="detail-value">{{ challenge.race_to_score }}</span>
      </div>
      <div class="detail-item" v-if="challenge.challenged_at">
        <span class="detail-label">Challenged / 挑战时间:</span>
        <span class="detail-value">{{ formatDate(challenge.challenged_at) }}</span>
      </div>
      <div class="detail-item" v-if="challenge.status === 'completed' && challenge.winner">
        <span class="detail-label">Winner / 胜者:</span>
        <span class="detail-value winner">{{ challenge.winner?.name }}</span>
      </div>
      <div class="detail-item" v-if="challenge.status === 'completed'">
        <span class="detail-label">Score / 比分:</span>
        <span class="detail-value">{{ challenge.player1_score }} - {{ challenge.player2_score }}</span>
      </div>
      <div class="detail-item" v-if="challenge.status === 'completed' && challenge.elo_change">
        <span class="detail-label">Elo Change / Elo变化:</span>
        <span class="detail-value" :class="challenge.elo_change > 0 ? 'positive' : 'negative'">
          {{ challenge.elo_change > 0 ? '+' : '' }}{{ challenge.elo_change }}
        </span>
      </div>
    </div>

    <div class="challenge-actions" v-if="showActions">
      <button 
        v-if="canAccept"
        class="btn btn-success"
        @click="$emit('accept', challenge.id)"
        :disabled="loading"
      >
        ✅ Accept / 接受
      </button>
      <button 
        v-if="canReject"
        class="btn btn-danger"
        @click="$emit('reject', challenge.id)"
        :disabled="loading"
      >
        ❌ Reject / 拒绝
      </button>
      <button 
        v-if="canComplete"
        class="btn btn-primary"
        @click="$emit('complete', challenge)"
        :disabled="loading"
      >
        📝 Enter Results / 录入结果
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useAuthStore } from '../stores/authStore'

const props = defineProps({
  challenge: {
    type: Object,
    required: true
  },
  loading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['accept', 'reject', 'complete'])

const authStore = useAuthStore()

const challengeStatusClass = computed(() => {
  return `status-${props.challenge.status}`
})

const statusText = computed(() => {
  const statusMap = {
    pending: 'Pending / 待处理',
    accepted: 'Accepted / 已接受',
    rejected: 'Rejected / 已拒绝',
    completed: 'Completed / 已完成',
    cancelled: 'Cancelled / 已取消'
  }
  return statusMap[props.challenge.status] || props.challenge.status
})

const statusBadgeClass = computed(() => {
  const classMap = {
    pending: 'badge-warning',
    accepted: 'badge-info',
    rejected: 'badge-secondary',
    completed: 'badge-success',
    cancelled: 'badge-danger'
  }
  return `badge ${classMap[props.challenge.status] || 'badge-secondary'}`
})

const showActions = computed(() => {
  return props.challenge.status === 'pending' || props.challenge.status === 'accepted'
})

const canAccept = computed(() => {
  if (!authStore.user) return false
  return props.challenge.status === 'pending' && 
         props.challenge.opponent_id === authStore.user.id
})

const canReject = computed(() => {
  if (!authStore.user) return false
  return props.challenge.status === 'pending' && 
         props.challenge.opponent_id === authStore.user.id
})

const canComplete = computed(() => {
  if (!authStore.user) return false
  return props.challenge.status === 'accepted' && 
         (props.challenge.challenger_id === authStore.user.id || 
          props.challenge.opponent_id === authStore.user.id)
})

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleString('en-NZ', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}
</script>

<style scoped>
.challenge-card {
  background: white;
  border: 2px solid #dee2e6;
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 1rem;
  transition: all 0.3s;
}

.challenge-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.status-pending {
  border-left: 4px solid #ffc107;
}

.status-accepted {
  border-left: 4px solid #17a2b8;
}

.status-completed {
  border-left: 4px solid #28a745;
}

.status-rejected,
.status-cancelled {
  border-left: 4px solid #dc3545;
  opacity: 0.7;
}

.challenge-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #dee2e6;
}

.players-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex: 1;
}

.player {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.player strong {
  font-size: 1.1rem;
  color: #1a1a2e;
}

.player-label {
  font-size: 0.75rem;
  color: #6c757d;
  margin-top: 0.25rem;
}

.vs {
  font-weight: 700;
  color: #667eea;
  font-size: 1.2rem;
}

.challenge-status {
  display: flex;
  align-items: center;
}

.badge {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: 600;
}

.badge-warning {
  background: #fff3cd;
  color: #856404;
}

.badge-info {
  background: #d1ecf1;
  color: #0c5460;
}

.badge-success {
  background: #d4edda;
  color: #155724;
}

.badge-danger {
  background: #f8d7da;
  color: #721c24;
}

.badge-secondary {
  background: #e2e3e5;
  color: #383d41;
}

.challenge-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.detail-label {
  font-size: 0.875rem;
  color: #6c757d;
  font-weight: 500;
}

.detail-value {
  font-size: 1rem;
  color: #1a1a2e;
  font-weight: 600;
}

.detail-value.winner {
  color: #28a745;
}

.detail-value.positive {
  color: #28a745;
}

.detail-value.negative {
  color: #dc3545;
}

.challenge-actions {
  display: flex;
  gap: 0.5rem;
  padding-top: 1rem;
  border-top: 1px solid #dee2e6;
}

.btn {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s;
}

.btn-success {
  background: #28a745;
  color: white;
}

.btn-danger {
  background: #dc3545;
  color: white;
}

.btn-primary {
  background: #667eea;
  color: white;
}

.btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .challenge-header {
    flex-direction: column;
    gap: 1rem;
  }

  .players-info {
    flex-direction: column;
    width: 100%;
  }

  .challenge-details {
    grid-template-columns: 1fr;
  }

  .challenge-actions {
    flex-direction: column;
  }

  .btn {
    width: 100%;
  }
}
</style>
