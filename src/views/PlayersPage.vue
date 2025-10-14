<template>
  <div class="players-page">
    <div class="page-header">
      <h1>👥 Players Management</h1>
      <button class="btn btn-primary" @click="showCreateModal = true">
        Add New Player
      </button>
    </div>

    <div v-if="playerStore.loading" class="loading">
      <div class="spinner"></div>
    </div>

    <div v-else-if="playerStore.error" class="alert alert-danger">
      {{ playerStore.error }}
    </div>

    <div v-else>
      <!-- Filter Controls -->
      <div class="filter-section card">
        <div class="row">
          <div class="col col-3">
            <div class="form-group">
              <label class="form-label">Search by Name</label>
              <input 
                type="text" 
                class="form-control" 
                v-model="searchQuery"
                placeholder="Enter player name..."
              >
            </div>
          </div>
          <div class="col col-3">
            <div class="form-group">
              <label class="form-label">Filter by Ranking Level</label>
              <select class="form-control" v-model="skillFilter">
                <option value="">All Levels</option>
                <option value="hall_of_fame">👑 殿堂 Hall of Fame</option>
                <option value="pro_level">💎 职业段 Pro Level</option>
                <option value="grand_master">🌟 特级大师 Grand Master</option>
                <option value="master">⭐ 大师 Master</option>
                <option value="elite">🔷 精英 Elite</option>
                <option value="expert">🔶 专家 Expert</option>
                <option value="advance">🔺 高阶 Advance</option>
                <option value="intermediate">🔸 进阶 Intermediate</option>
                <option value="beginner">⚪ 初学 Beginner</option>
              </select>
            </div>
          </div>
          <div class="col col-3">
            <div class="form-group">
              <label class="form-label">Filter by Membership</label>
              <select class="form-control" v-model="membershipFilter">
                <option value="">All Memberships</option>
                <option value="pro_max">🌟 Pro Max</option>
                <option value="pro">💎 Pro</option>
                <option value="plus">⭐ Plus</option>
                <option value="lite">🎱 Lite</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Players Table -->
      <div class="table-container">
        <table class="table">
          <thead>
            <tr>
              <th>Card #</th>
              <th>Name</th>
              <th>W / L</th>
              <th>Matches Played</th>
              <th>Win Rate</th>
              <th>Break & Run</th>
              <th>B&R Rate</th>
              <th>Ranking Points</th>
              <th>Rank Level</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="player in filteredPlayers" :key="player.id">
              <td><span class="badge badge-info">{{ player.membership_card_number || 'N/A' }}</span></td>
              <td><strong>{{ player.name }}</strong></td>
              <td>
                <span class="win-loss-display">
                  <span class="text-success">{{ player.wins || 0 }}W</span> / 
                  <span class="text-danger">{{ player.losses || 0 }}L</span>
                </span>
              </td>
              <td>
                <strong>{{ (player.wins || 0) + (player.losses || 0) }}</strong>
              </td>
              <td>
                <span class="win-rate-display" :class="getWinRateClass(player)">
                  {{ calculateWinRate(player) }}%
                </span>
              </td>
              <td>
                <strong class="break-run-count">🎯 {{ player.break_and_run_count || 0 }}</strong>
              </td>
              <td>
                <span class="break-run-rate-display" :class="getBreakRunRateClass(player)">
                  {{ calculateBreakRunRate(player) }}%
                </span>
              </td>
              <td>
                <strong class="points-display">{{ player.current_year_points || 0 }}</strong>
              </td>
              <td>
                <span class="badge" :class="getRankBadgeClass(player.ranking_level)">
                  {{ formatRankLevel(player.ranking_level) }}
                </span>
              </td>
              <td>
                <span class="badge" :class="player.is_active ? 'badge-success' : 'badge-secondary'">
                  {{ player.is_active ? 'Active' : 'Inactive' }}
                </span>
              </td>
              <td>
                <div class="action-buttons">
                  <button class="btn btn-sm btn-info" @click="openStatsModal(player)" title="Edit Stats">
                    📊 Stats
                  </button>
                  <button class="btn btn-sm btn-warning" @click="openPointsModal(player)" title="Add/Subtract Points">
                    🏆 Points
                  </button>
                  <button class="btn btn-sm btn-primary" @click="editPlayer(player)">
                    Edit
                  </button>
                  <button class="btn btn-sm btn-danger" @click="confirmDelete(player)">
                    Delete
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        <div v-if="filteredPlayers.length === 0" class="text-center p-4">
          <p class="text-secondary">No players found</p>
        </div>
      </div>
    </div>

    <!-- Stats Management Modal -->
    <div v-if="showStatsModal" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>📊 Edit Statistics: {{ selectedPlayer?.name }}</h2>
          <button class="btn btn-secondary btn-sm" @click="closeStatsModal">Close</button>
        </div>
        <div class="modal-body">
          <div class="player-info-box">
            <p><strong>Current Stats:</strong></p>
            <p>Wins: <span class="text-success">{{ selectedPlayer?.wins || 0 }}</span></p>
            <p>Losses: <span class="text-danger">{{ selectedPlayer?.losses || 0 }}</span></p>
            <p>Matches Played: <strong>{{ (selectedPlayer?.wins || 0) + (selectedPlayer?.losses || 0) }}</strong></p>
            <p>Break and Run: <strong>🎯 {{ selectedPlayer?.break_and_run_count || 0 }}</strong></p>
          </div>
          
          <div class="stats-form">
            <div class="form-group">
              <label class="form-label">Wins</label>
              <input 
                type="number" 
                class="form-control" 
                v-model.number="statsForm.wins"
                min="0"
                placeholder="Number of wins"
              >
            </div>
            
            <div class="form-group">
              <label class="form-label">Losses</label>
              <input 
                type="number" 
                class="form-control" 
                v-model.number="statsForm.losses"
                min="0"
                placeholder="Number of losses"
              >
            </div>
            
            <div class="form-group">
              <label class="form-label">🎯 Break and Run Count</label>
              <input 
                type="number" 
                class="form-control" 
                v-model.number="statsForm.break_and_run_count"
                min="0"
                placeholder="Number of Break and Run achievements"
              >
              <small class="form-text text-muted">Perfect clears - Opening break followed by running the table</small>
            </div>
          </div>
          
          <div v-if="statsChanged" class="points-preview">
            <p><strong>Preview Changes:</strong></p>
            <p>Wins: {{ selectedPlayer?.wins || 0 }} → {{ statsForm.wins }}</p>
            <p>Losses: {{ selectedPlayer?.losses || 0 }} → {{ statsForm.losses }}</p>
            <p>Matches Played: {{ (selectedPlayer?.wins || 0) + (selectedPlayer?.losses || 0) }} → {{ statsForm.wins + statsForm.losses }}</p>
            <p>Break and Run: 🎯 {{ selectedPlayer?.break_and_run_count || 0 }} → {{ statsForm.break_and_run_count }}</p>
            <p>Win Rate: {{ calculateWinRate(selectedPlayer) }}% → {{ calculateNewWinRate() }}%</p>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeStatsModal">Cancel</button>
          <button 
            class="btn btn-success" 
            @click="updateStats"
          >
            Update Statistics
          </button>
        </div>
      </div>
    </div>

    <!-- Points Management Modal -->
    <div v-if="showPointsModal" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>🏆 Manage Points: {{ selectedPlayer?.name }}</h2>
          <button class="btn btn-secondary btn-sm" @click="closePointsModal">Close</button>
        </div>
        <div class="modal-body">
          <div class="player-info-box">
            <p><strong>Current Rank:</strong> <span class="badge" :class="getRankBadgeClass(selectedPlayer?.ranking_level)">{{ formatRankLevel(selectedPlayer?.ranking_level) }}</span></p>
            <p><strong>Current Points ({{ currentYear }}):</strong> <span class="current-points">{{ getCurrentYearPoints(selectedPlayer) }}</span></p>
          </div>
          
          <div class="form-group">
            <label class="form-label">Points Change</label>
            <input 
              type="number" 
              class="form-control" 
              v-model.number="pointsChange"
              placeholder="Enter positive or negative number (e.g., 20 or -10)"
            >
            <small class="form-text">Use positive numbers to add points, negative to subtract</small>
          </div>
          
          <div class="form-group">
            <label class="form-label">Reason (Optional)</label>
            <input 
              type="text" 
              class="form-control" 
              v-model="pointsReason"
              placeholder="e.g., Won tournament"
            >
          </div>
          
          <div v-if="pointsChange !== 0" class="points-preview">
            <p><strong>Points Change:</strong> {{ pointsChange > 0 ? '+' : '' }}{{ pointsChange }}</p>
            <p v-if="pointsChange > 0" class="text-success">⬆️ Adding {{ pointsChange }} points</p>
            <p v-else class="text-danger">⬇️ Subtracting {{ Math.abs(pointsChange) }} points</p>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closePointsModal">Cancel</button>
          <button 
            class="btn btn-success" 
            @click="updatePoints"
            :disabled="pointsChange === 0"
          >
            Update Points
          </button>
        </div>
      </div>
    </div>

    <!-- Create/Edit Player Modal -->
    <div v-if="showCreateModal || editingPlayer" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>{{ editingPlayer ? 'Edit Player' : 'Add New Player' }}</h2>
          <button class="btn btn-secondary btn-sm" @click="closeModal">Close</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Name *</label>
            <input type="text" class="form-control" v-model="playerForm.name" required>
          </div>
          <div class="form-group">
            <label class="form-label">Email</label>
            <input type="email" class="form-control" v-model="playerForm.email">
          </div>
          <div class="form-group">
            <label class="form-label">Phone</label>
            <input type="tel" class="form-control" v-model="playerForm.phone">
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeModal">Cancel</button>
          <button class="btn btn-success" @click="savePlayer">
            {{ editingPlayer ? 'Update' : 'Create' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { usePlayerStore } from '../stores/playerStore'
import { supabase } from '../config/supabase'

export default {
  name: 'PlayersPage',
  setup() {
    const playerStore = usePlayerStore()
    
    const showCreateModal = ref(false)
    const editingPlayer = ref(null)
    const searchQuery = ref('')
    const skillFilter = ref('')
    const membershipFilter = ref('')
    const pointHistory = ref([])
    const currentYear = new Date().getFullYear()
    
    // Stats Modal
    const showStatsModal = ref(false)
    const statsForm = ref({
      wins: 0,
      losses: 0,
      break_and_run_count: 0
    })
    
    // Points Modal
    const showPointsModal = ref(false)
    const selectedPlayer = ref(null)
    const pointsChange = ref(0)
    const pointsReason = ref('')
    
    const playerForm = ref({
      name: '',
      email: '',
      phone: ''
    })

    const filteredPlayers = computed(() => {
      let players = playerStore.sortedPlayers
      
      // Get current year for ranking points calculation
      const currentYear = new Date().getFullYear()
      
      // Add current_year_points to each player
      players = players.map(player => ({
        ...player,
        current_year_points: pointHistory.value
          .filter(p => p.user_id === player.id && p.year === currentYear)
          .reduce((sum, p) => sum + (p.points_change || 0), 0)
      }))
      
      if (searchQuery.value) {
        players = players.filter(p => 
          p.name.toLowerCase().includes(searchQuery.value.toLowerCase())
        )
      }
      
      if (skillFilter.value) {
        players = players.filter(p => p.ranking_level === skillFilter.value)
      }
      
      if (membershipFilter.value) {
        players = players.filter(p => p.membership_level === membershipFilter.value)
      }
      
      return players
    })

    const getRankBadgeClass = (level) => {
      const classes = {
        'beginner': 'badge-secondary',
        'intermediate': 'badge-info',
        'advance': 'badge-primary',
        'expert': 'badge-warning',
        'elite': 'badge-warning',
        'master': 'badge-danger',
        'grand_master': 'badge-danger',
        'pro_level': 'badge-danger',
        'hall_of_fame': 'badge-danger'
      }
      return classes[level] || 'badge-secondary'
    }

    const formatRankLevel = (level) => {
      if (!level) return 'Beginner'
      return level.split('_').map(word => 
        word.charAt(0).toUpperCase() + word.slice(1)
      ).join(' ')
    }

    const calculateWinRate = (player) => {
      const total = (player?.wins || 0) + (player?.losses || 0)
      if (total === 0) return 0
      return ((player.wins / total) * 100).toFixed(1)
    }

    const calculateNewWinRate = () => {
      const total = statsForm.value.wins + statsForm.value.losses
      if (total === 0) return 0
      return ((statsForm.value.wins / total) * 100).toFixed(1)
    }

    const calculateBreakRunRate = (player) => {
      const totalMatches = (player?.wins || 0) + (player?.losses || 0)
      if (totalMatches === 0) return '0.0'
      const breakRunCount = player?.break_and_run_count || 0
      return ((breakRunCount / totalMatches) * 100).toFixed(1)
    }

    const getWinRateClass = (player) => {
      const rate = parseFloat(calculateWinRate(player))
      if (rate >= 70) return 'rate-excellent'
      if (rate >= 55) return 'rate-good'
      if (rate >= 45) return 'rate-average'
      return 'rate-below'
    }

    const getBreakRunRateClass = (player) => {
      const rate = parseFloat(calculateBreakRunRate(player))
      if (rate >= 20) return 'rate-excellent'
      if (rate >= 10) return 'rate-good'
      if (rate >= 5) return 'rate-average'
      return 'rate-below'
    }

    const getCurrentYearPoints = (player) => {
      if (!player) return 0
      return pointHistory.value
        .filter(p => p.user_id === player.id && p.year === currentYear)
        .reduce((sum, p) => sum + (p.points_change || 0), 0)
    }

    const statsChanged = computed(() => {
      if (!selectedPlayer.value) return false
      return statsForm.value.wins !== (selectedPlayer.value.wins || 0) ||
             statsForm.value.losses !== (selectedPlayer.value.losses || 0) ||
             statsForm.value.break_and_run_count !== (selectedPlayer.value.break_and_run_count || 0)
    })

    const openStatsModal = (player) => {
      selectedPlayer.value = player
      statsForm.value = {
        wins: player.wins || 0,
        losses: player.losses || 0,
        break_and_run_count: player.break_and_run_count || 0
      }
      showStatsModal.value = true
    }

    const closeStatsModal = () => {
      showStatsModal.value = false
      selectedPlayer.value = null
      statsForm.value = {
        wins: 0,
        losses: 0,
        break_and_run_count: 0
      }
    }

    const updateStats = async () => {
      if (!selectedPlayer.value) {
        alert('No player selected')
        return
      }

      if (statsForm.value.wins < 0 || statsForm.value.losses < 0 || statsForm.value.break_and_run_count < 0) {
        alert('Statistics cannot be negative')
        return
      }

      const confirmMsg = `Update ${selectedPlayer.value.name}'s statistics?\n\nWins: ${selectedPlayer.value.wins || 0} → ${statsForm.value.wins}\nLosses: ${selectedPlayer.value.losses || 0} → ${statsForm.value.losses}\nBreak and Run: ${selectedPlayer.value.break_and_run_count || 0} → ${statsForm.value.break_and_run_count}`
      
      if (!confirm(confirmMsg)) return

      try {
        const { error } = await supabase
          .from('users')
          .update({
            wins: statsForm.value.wins,
            losses: statsForm.value.losses,
            break_and_run_count: statsForm.value.break_and_run_count
          })
          .eq('id', selectedPlayer.value.id)

        if (error) throw error

        alert(`✅ Successfully updated ${selectedPlayer.value.name}'s statistics!`)
        closeStatsModal()
        await playerStore.fetchPlayers()
      } catch (err) {
        console.error('Error updating stats:', err)
        alert('Error updating statistics: ' + err.message)
      }
    }

    const openPointsModal = (player) => {
      selectedPlayer.value = player
      pointsChange.value = 0
      pointsReason.value = ''
      showPointsModal.value = true
    }

    const closePointsModal = () => {
      showPointsModal.value = false
      selectedPlayer.value = null
      pointsChange.value = 0
      pointsReason.value = ''
    }

    const updatePoints = async () => {
      if (!selectedPlayer.value || pointsChange.value === 0) {
        alert('Please enter a points value')
        return
      }

      const confirmMsg = `Update ${selectedPlayer.value.name}'s points by ${pointsChange.value}?\n\n${pointsReason.value ? `Reason: ${pointsReason.value}` : 'No reason provided'}`
      
      if (!confirm(confirmMsg)) return

      try {
        // Get current admin user
        const { data: { user } } = await supabase.auth.getUser()
        
        // Call the database function to add points with NZ timezone
        const { data, error } = await supabase.rpc('add_player_points', {
          p_user_id: selectedPlayer.value.id,
          p_points_change: pointsChange.value,
          p_reason: pointsReason.value || 'No reason provided',
          p_admin_id: user?.id || null
        })

        if (error) throw error

        alert(`✅ Successfully updated ${selectedPlayer.value.name}'s points!\n\nPoints Change: ${pointsChange.value > 0 ? '+' : ''}${pointsChange.value}\nNew Year Total: ${data.current_year_total}\nNew Rank: ${data.new_ranking_level}\n\nRecorded for: ${data.year}-${data.month}`)
        closePointsModal()
        await playerStore.fetchPlayers()
        
        // Reload point history
        const { data: historyData } = await supabase.from('point_history').select('*')
        if (historyData) pointHistory.value = historyData
      } catch (err) {
        console.error('Error updating points:', err)
        alert('Error updating points: ' + err.message)
      }
    }

    const editPlayer = (player) => {
      editingPlayer.value = player
      playerForm.value = {
        name: player.name,
        email: player.email || '',
        phone: player.phone || ''
      }
    }

    const closeModal = () => {
      showCreateModal.value = false
      editingPlayer.value = null
      playerForm.value = {
        name: '',
        email: '',
        phone: ''
      }
    }

    const savePlayer = async () => {
      if (!playerForm.value.name) {
        alert('Please fill in all required fields')
        return
      }

      let result
      if (editingPlayer.value) {
        result = await playerStore.updatePlayer(editingPlayer.value.id, playerForm.value)
      } else {
        result = await playerStore.createPlayer(playerForm.value)
      }

      if (result.success) {
        closeModal()
        await playerStore.fetchPlayers()
      } else {
        alert('Error: ' + result.error)
      }
    }

    const confirmDelete = async (player) => {
      if (confirm(`Are you sure you want to delete ${player.name}?`)) {
        const result = await playerStore.deletePlayer(player.id)
        if (result.success) {
          await playerStore.fetchPlayers()
        } else {
          alert('Error: ' + result.error)
        }
      }
    }

    onMounted(async () => {
      await playerStore.fetchPlayers()
      
      // Load point history for ranking points calculation
      try {
        const { data, error } = await supabase
          .from('point_history')
          .select('*')
        
        if (error) throw error
        pointHistory.value = data || []
      } catch (err) {
        console.error('Error loading point history:', err)
      }
    })

    return {
      playerStore,
      showCreateModal,
      editingPlayer,
      searchQuery,
      skillFilter,
      membershipFilter,
      playerForm,
      filteredPlayers,
      getRankBadgeClass,
      formatRankLevel,
      calculateWinRate,
      calculateNewWinRate,
      calculateBreakRunRate,
      getWinRateClass,
      getBreakRunRateClass,
      getCurrentYearPoints,
      currentYear,
      statsChanged,
      showStatsModal,
      statsForm,
      openStatsModal,
      closeStatsModal,
      updateStats,
      openPointsModal,
      closePointsModal,
      showPointsModal,
      selectedPlayer,
      pointsChange,
      pointsReason,
      updatePoints,
      editPlayer,
      closeModal,
      savePlayer,
      confirmDelete
    }
  }
}
</script>

<style scoped>
.players-page {
  max-width: 100%;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.page-header h1 {
  font-size: 2rem;
  font-weight: 600;
  color: #1a1a2e;
}

.filter-section {
  margin-bottom: 1.5rem;
}

.action-buttons {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.points-display {
  font-size: 1.2rem;
  color: #f39c12;
}

.win-loss-display {
  font-size: 0.95rem;
  white-space: nowrap;
}

.stats-form {
  margin-top: 1rem;
}

.player-info-box {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 1rem;
  margin-bottom: 1.5rem;
}

.player-info-box p {
  margin: 0.5rem 0;
  font-size: 1rem;
}

.current-points {
  font-size: 1.5rem;
  font-weight: bold;
  color: #f39c12;
}

.points-preview {
  background: #e3f2fd;
  border-left: 4px solid #2196f3;
  padding: 1rem;
  border-radius: 4px;
  margin-top: 1rem;
}

.points-preview p {
  margin: 0.5rem 0;
}

.text-success {
  color: #28a745;
  font-weight: bold;
}

.text-danger {
  color: #dc3545;
  font-weight: bold;
}

.form-text {
  display: block;
  margin-top: 0.25rem;
  font-size: 0.875rem;
  color: #6c757d;
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
  border-radius: 12px;
  max-width: 600px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

.modal-header {
  padding: 1.5rem;
  border-bottom: 2px solid #dee2e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h2 {
  font-size: 1.5rem;
  font-weight: 600;
  margin: 0;
}

.modal-body {
  padding: 1.5rem;
}

.modal-footer {
  padding: 1.5rem;
  border-top: 2px solid #dee2e6;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: stretch;
  }

  .page-header h1 {
    font-size: 1.5rem;
  }

  .action-buttons {
    flex-direction: column;
  }

  .action-buttons .btn {
    width: 100%;
  }
}

/* Win Rate and Break Run Rate Styles */
.win-rate-display,
.break-run-rate-display {
  padding: 0.375rem 0.75rem;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.875rem;
  display: inline-block;
}

.rate-excellent {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
}

.rate-good {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  color: white;
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
}

.rate-average {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  color: white;
  box-shadow: 0 2px 8px rgba(245, 158, 11, 0.3);
}

.rate-below {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  box-shadow: 0 2px 8px rgba(239, 68, 68, 0.3);
}

.break-run-count {
  color: #667eea;
  font-size: 1.1rem;
}
</style>


