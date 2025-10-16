<template>
  <div class="tournament-detail-page">
    <div v-if="loading" class="loading">
      <div class="spinner"></div>
    </div>

    <div v-else-if="!tournament" class="alert alert-danger">
      Tournament not found
    </div>

    <div v-else>
      <!-- Tournament Header -->
      <div class="tournament-header-section">
        <div class="header-content">
          <button class="btn btn-secondary" @click="$router.back()">← Back</button>
          <h1>{{ tournament.name }}</h1>
          <span class="badge badge-lg" :class="getStatusBadgeClass(tournament.status)">
            {{ formatStatus(tournament.status) }}
          </span>
        </div>
      </div>

      <!-- Tournament Info -->
      <div class="row">
        <div class="col col-2">
          <div class="card">
            <div class="card-header">
              <h2 class="card-title">Tournament Information</h2>
            </div>
            <div class="card-body">
              <div class="info-grid">
                <div class="info-item">
                  <span class="info-label">Type:</span>
                  <span class="info-value">{{ formatTournamentType(tournament.tournament_type) }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Start Date:</span>
                  <span class="info-value">{{ formatDate(tournament.start_date) }}</span>
                </div>
                <div class="info-item" v-if="tournament.end_date">
                  <span class="info-label">End Date:</span>
                  <span class="info-value">{{ formatDate(tournament.end_date) }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Max Players:</span>
                  <span class="info-value">{{ tournament.max_players || 'Unlimited' }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Entry Fee:</span>
                  <span class="info-value">${{ tournament.entry_fee }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Prize Pool:</span>
                  <span class="info-value prize">${{ tournament.prize_pool }}</span>
                </div>
              </div>
              <p v-if="tournament.description" class="mt-3">
                <strong>Description:</strong><br>
                {{ tournament.description }}
              </p>
            </div>
          </div>
        </div>

        <div class="col col-2">
          <div class="card">
            <div class="card-header">
              <h2 class="card-title">Quick Stats</h2>
            </div>
            <div class="card-body">
              <div class="stats-grid">
                <div class="stat-box">
                  <div class="stat-number">{{ registrations.length }}</div>
                  <div class="stat-label">Participants</div>
                </div>
                <div class="stat-box">
                  <div class="stat-number">{{ matches.length }}</div>
                  <div class="stat-label">Total Matches</div>
                </div>
                <div class="stat-box">
                  <div class="stat-number">{{ completedMatches }}</div>
                  <div class="stat-label">Completed</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Participants Section -->
      <div class="card">
        <div class="card-header">
          <h2 class="card-title">👥 Registered Players ({{ registrations.length }})</h2>
          
          <!-- Player Registration Button -->
          <button 
            v-if="authStore.isAuthenticated && !authStore.isAdmin && canRegister"
            class="btn btn-success btn-sm" 
            @click="registerForTournament"
            :disabled="isRegistered || isFull"
          >
            {{ isRegistered ? '✅ Registered' : 'Register' }}
          </button>
          
          <!-- Player Cancel Registration Button -->
          <button 
            v-if="authStore.isAuthenticated && !authStore.isAdmin && isRegistered"
            class="btn btn-danger btn-sm" 
            @click="cancelRegistration"
          >
            Cancel Registration
          </button>
          
          <!-- Admin Add Participant Button -->
          <button 
            v-if="authStore.isAdmin && canRegister"
            class="btn btn-primary btn-sm" 
            @click="showAddParticipant = true"
          >
            Add Player
          </button>
        </div>
        <div class="card-body">
          <div v-if="registrations.length === 0" class="text-center p-3">
            <p class="text-secondary">No registrations yet. Be the first to register!</p>
          </div>
          <div v-else class="participants-grid">
            <div v-for="registration in registrations" :key="registration.id" class="participant-card">
              <div class="participant-info">
                <strong>{{ registration.user?.name || 'Unknown Player' }}</strong>
                <span class="rank-badge badge-sm" :class="`rank-${registration.user?.ranking_level || 'beginner'}`">
                  {{ formatRankBadge(registration.user?.ranking_level || 'beginner') }}
                </span>
              </div>
              <div class="participant-stats">
                <span>Rank Level: {{ formatRankBadge(registration.user?.ranking_level || 'beginner') }}</span>
                <span>W/L: {{ registration.user?.wins || 0 }}/{{ registration.user?.losses || 0 }}</span>
              </div>
              <div class="participant-date">
                <small>Registered: {{ formatDate(registration.registered_at) }}</small>
              </div>
              <button 
                v-if="authStore.isAdmin"
                class="btn btn-danger btn-sm"
                @click="removeParticipant(registration)"
              >
                Remove
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tournament Bracket -->
      <TournamentBracket
        v-if="matches.length > 0"
        :matches="matches"
        :players="allPlayersForBracket"
        :tournament-type="tournament.tournament_type"
        :is-admin="authStore.isAdmin"
        :race-to-score="raceToScore"
        @update-score="handleScoreUpdate"
        @advance-winner="handleAdvanceWinner"
        @set-winner="handleSetWinner"
      />

      <!-- Bracket Actions Section -->
      <div class="card">
        <div class="card-header">
          <h2 class="card-title">🏆 Tournament Bracket Management</h2>
          <div class="bracket-actions-header">
            <button 
              v-if="authStore.isAdmin && registrations.length >= 2 && matches.length === 0"
              class="btn btn-warning btn-sm" 
              @click="autoGenerateMatches"
            >
              ⚡ Auto Generate Matches
            </button>
            <button 
              v-if="authStore.isAdmin && matches.length > 0"
              class="btn btn-danger btn-sm" 
              @click="clearAllMatches"
            >
              🗑️ Clear All Matches
            </button>
          </div>
        </div>
        <div class="card-body">
          <!-- Race to X Setting -->
          <div v-if="authStore.isAdmin" class="race-setting mb-3">
            <div class="row align-items-center">
              <div class="col-md-6">
                <label class="form-label">
                  <strong>🎯 Race to X (Match Format)</strong>
                </label>
                <p class="text-muted small mb-0">First player to reach this score wins the match</p>
              </div>
              <div class="col-md-6">
                <div class="input-group">
                  <input 
                    type="number" 
                    class="form-control" 
                    v-model="raceToScore"
                    min="1"
                    max="21"
                    :disabled="matches.length > 0"
                  >
                  <span class="input-group-text">points</span>
                  <button 
                    v-if="matches.length > 0"
                    class="btn btn-outline-secondary btn-sm"
                    @click="updateRaceToScore"
                    title="Update race score for all matches"
                  >
                    Update
                  </button>
                </div>
                <small class="text-muted">
                  {{ matches.length > 0 ? 'Update will apply to all matches' : 'Set before generating matches' }}
                </small>
              </div>
            </div>
          </div>

          <div v-if="matches.length === 0" class="text-center p-3">
            <p class="text-secondary">No matches generated yet. Click "Auto Generate Matches" to create the bracket.</p>
            <div v-if="raceToScore > 0" class="alert alert-info">
              <strong>Match Format:</strong> Race to {{ raceToScore }} points
            </div>
          </div>
          <div v-else class="text-center p-3">
            <p class="text-success">
              <strong>{{ matches.length }} matches generated!</strong><br>
              <small class="text-muted">Click on player scores in the bracket above to update results.</small>
            </p>
            <div class="alert alert-info">
              <strong>Current Format:</strong> Race to {{ raceToScore }} points
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Add Participant Modal -->
    <div v-if="showAddParticipant" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Add Participant</h2>
          <button class="btn btn-secondary btn-sm" @click="showAddParticipant = false">Close</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Select Player</label>
            <select class="form-control" v-model="selectedPlayerId">
              <option value="">-- Select a player --</option>
              <option 
                v-for="player in availablePlayers" 
                :key="player.id"
                :value="player.id"
              >
                {{ player.name }} ({{ formatSkillLevel(player.skill_level) }})
              </option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showAddParticipant = false">Cancel</button>
          <button class="btn btn-success" @click="addParticipant">Add</button>
        </div>
      </div>
    </div>

    <!-- Create/Edit Match Modal -->
    <div v-if="showCreateMatch || editingMatch" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>{{ editingMatch ? 'Update Match' : 'Schedule Match' }}</h2>
          <button class="btn btn-secondary btn-sm" @click="closeMatchModal">Close</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Round Number</label>
            <input type="number" class="form-control" v-model="matchForm.round_number" min="1">
          </div>
          <div class="form-group">
            <label class="form-label">Match Number</label>
            <input type="number" class="form-control" v-model="matchForm.match_number" min="1">
          </div>
          <div class="form-group">
            <label class="form-label">Player 1</label>
            <select class="form-control" v-model="matchForm.player1_id">
              <option value="">-- Select Player 1 --</option>
              <option v-for="p in participants" :key="p.id" :value="p.player_id">
                {{ p.player.name }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Player 2</label>
            <select class="form-control" v-model="matchForm.player2_id">
              <option value="">-- Select Player 2 --</option>
              <option v-for="p in participants" :key="p.id" :value="p.player_id">
                {{ p.player.name }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Status</label>
            <select class="form-control" v-model="matchForm.status">
              <option value="scheduled">Scheduled</option>
              <option value="in_progress">In Progress</option>
              <option value="completed">Completed</option>
              <option value="cancelled">Cancelled</option>
            </select>
          </div>
          <div class="row" v-if="matchForm.status === 'completed'">
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">Player 1 Score</label>
                <input type="number" class="form-control" v-model="matchForm.player1_score" min="0">
              </div>
            </div>
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">Player 2 Score</label>
                <input type="number" class="form-control" v-model="matchForm.player2_score" min="0">
              </div>
            </div>
          </div>
          <div class="form-group" v-if="matchForm.status === 'completed'">
            <label class="form-label">Winner</label>
            <select class="form-control" v-model="matchForm.winner_id">
              <option value="">-- Select Winner --</option>
              <option v-if="matchForm.player1_id" :value="matchForm.player1_id">
                {{ getPlayerName(matchForm.player1_id) }}
              </option>
              <option v-if="matchForm.player2_id" :value="matchForm.player2_id">
                {{ getPlayerName(matchForm.player2_id) }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Table Number</label>
            <input type="number" class="form-control" v-model="matchForm.table_number" min="1">
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeMatchModal">Cancel</button>
          <button class="btn btn-success" @click="saveMatch">
            {{ editingMatch ? 'Update' : 'Create' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useTournamentStore } from '../stores/tournamentStore'
import { usePlayerStore } from '../stores/playerStore'
import { useMatchStore } from '../stores/matchStore'
import { useAuthStore } from '../stores/authStore'
import { supabase } from '../config/supabase'
import TournamentBracket from '../components/TournamentBracket.vue'
import { generateTournamentMatches } from '../utils/bracketGenerator'

export default {
  name: 'TournamentDetailPage',
  components: {
    TournamentBracket
  },
  setup() {
    const route = useRoute()
    const tournamentStore = useTournamentStore()
    const playerStore = usePlayerStore()
    const matchStore = useMatchStore()
    const authStore = useAuthStore()

    const loading = ref(true)
    const tournament = ref(null)
    const participants = ref([])
    const registrations = ref([])
    const matches = ref([])
    const showAddParticipant = ref(false)
    const showCreateMatch = ref(false)
    const editingMatch = ref(null)
    const selectedPlayerId = ref('')
    const raceToScore = ref(5) // Default race to 5

    const matchForm = ref({
      round_number: 1,
      match_number: 1,
      player1_id: '',
      player2_id: '',
      status: 'scheduled',
      player1_score: 0,
      player2_score: 0,
      winner_id: '',
      table_number: null
    })

    const completedMatches = computed(() => {
      return matches.value.filter(m => m.status === 'completed').length
    })

    const canRegister = computed(() => {
      return tournament.value && 
        (tournament.value.status === 'registration' || tournament.value.status === 'upcoming')
    })

    const isRegistered = computed(() => {
      if (!authStore.profile) return false
      return registrations.value.some(r => r.user_id === authStore.profile.id)
    })

    const isFull = computed(() => {
      if (!tournament.value || !tournament.value.max_players) return false
      return registrations.value.length >= tournament.value.max_players
    })

    const availablePlayers = computed(() => {
      const participantIds = participants.value.map(p => p.player_id)
      return playerStore.players.filter(p => !participantIds.includes(p.id))
    })

    const allPlayersForBracket = computed(() => {
      // Combine registered players for bracket display
      const players = registrations.value.map(reg => ({
        id: reg.user?.id,
        name: reg.user?.name || 'Unknown Player',
        ranking_level: reg.user?.ranking_level || 'beginner'
      })).filter(player => player.id) // Filter out null users
      return players
    })

    const loadData = async () => {
      loading.value = true
      try {
        tournament.value = await tournamentStore.fetchTournamentById(route.params.id)
        
        // Load registrations
        const { data: regData, error: regError } = await supabase
          .from('tournament_registrations')
          .select(`
            *,
            user:public_users(id, name, skill_level, ranking_level)
          `)
          .eq('tournament_id', route.params.id)
          .eq('status', 'registered')
        
        if (!regError) {
          registrations.value = regData || []
        }
        
        matches.value = await matchStore.fetchMatchesByTournament(route.params.id)
        await playerStore.fetchPlayers()
      } catch (error) {
        console.error('Error loading tournament details:', error)
      } finally {
        loading.value = false
      }
    }

    const registerForTournament = async () => {
      if (!authStore.profile) {
        alert('Please login to register')
        return
      }

      try {
        const { error } = await supabase
          .from('tournament_registrations')
          .insert([{
            tournament_id: route.params.id,
            user_id: authStore.profile.id,
            status: 'registered'
          }])

        if (error) throw error

        alert('Successfully registered for tournament!')
        await loadData()
      } catch (err) {
        alert('Error registering: ' + err.message)
      }
    }

    const cancelRegistration = async () => {
      if (!confirm('Are you sure you want to cancel your registration?')) return

      try {
        const { error } = await supabase
          .from('tournament_registrations')
          .delete()
          .eq('tournament_id', route.params.id)
          .eq('user_id', authStore.profile.id)

        if (error) throw error

        alert('Registration cancelled')
        await loadData()
      } catch (err) {
        alert('Error cancelling: ' + err.message)
      }
    }

    const selectTournamentMode = () => {
      return new Promise((resolve) => {
        // Create modal HTML
        const modalHtml = `
          <div id="tournament-mode-modal" style="
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.8);
            z-index: 10000;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          ">
            <div style="
              background: #333;
              border: 2px solid #555;
              border-radius: 12px;
              padding: 2rem;
              max-width: 500px;
              width: 90%;
              color: white;
              text-align: center;
            ">
              <h2 style="margin: 0 0 1.5rem 0; color: #fff; font-size: 1.5rem;">
                🏆 Select Tournament Format
              </h2>
              <p style="margin: 0 0 2rem 0; color: #ccc; font-size: 1rem;">
                Choose the tournament format for ${registrations.value.length} players:
              </p>
              
              <div style="display: flex; flex-direction: column; gap: 1rem;">
                <button onclick="selectMode('single_elimination')" style="
                  background: linear-gradient(135deg, #007bff, #0056b3);
                  border: none;
                  border-radius: 8px;
                  padding: 1rem 1.5rem;
                  color: white;
                  font-size: 1rem;
                  font-weight: 600;
                  cursor: pointer;
                  transition: all 0.2s ease;
                " onmouseover="this.style.transform='scale(1.05)'" onmouseout="this.style.transform='scale(1)'">
                  🥇 Single Elimination
                  <div style="font-size: 0.875rem; font-weight: 400; margin-top: 0.25rem; opacity: 0.9;">
                    Standard knockout tournament
                  </div>
                </button>
                
                <button onclick="selectMode('double_elimination')" style="
                  background: linear-gradient(135deg, #28a745, #1e7e34);
                  border: none;
                  border-radius: 8px;
                  padding: 1rem 1.5rem;
                  color: white;
                  font-size: 1rem;
                  font-weight: 600;
                  cursor: pointer;
                  transition: all 0.2s ease;
                " onmouseover="this.style.transform='scale(1.05)'" onmouseout="this.style.transform='scale(1)'">
                  🏆 Double Elimination
                  <div style="font-size: 0.875rem; font-weight: 400; margin-top: 0.25rem; opacity: 0.9;">
                    Winners bracket + Losers bracket
                  </div>
                </button>
                
                <button onclick="selectMode('round_robin')" style="
                  background: linear-gradient(135deg, #ffc107, #e0a800);
                  border: none;
                  border-radius: 8px;
                  padding: 1rem 1.5rem;
                  color: white;
                  font-size: 1rem;
                  font-weight: 600;
                  cursor: pointer;
                  transition: all 0.2s ease;
                " onmouseover="this.style.transform='scale(1.05)'" onmouseout="this.style.transform='scale(1)'">
                  🔄 Round Robin
                  <div style="font-size: 0.875rem; font-weight: 400; margin-top: 0.25rem; opacity: 0.9;">
                    Everyone plays everyone
                  </div>
                </button>
              </div>
              
              <button onclick="selectMode(null)" style="
                background: #6c757d;
                border: none;
                border-radius: 6px;
                padding: 0.75rem 1.5rem;
                color: white;
                font-size: 0.875rem;
                cursor: pointer;
                margin-top: 1.5rem;
              ">
                Cancel
              </button>
            </div>
          </div>
        `
        
        // Add modal to page
        document.body.insertAdjacentHTML('beforeend', modalHtml)
        
        // Global function for mode selection
        window.selectMode = (mode) => {
          document.getElementById('tournament-mode-modal').remove()
          delete window.selectMode
          resolve(mode)
        }
      })
    }

    const autoGenerateMatches = async () => {
      if (registrations.value.length < 2) {
        alert('Need at least 2 registered players to generate matches')
        return
      }

      // Show tournament mode selection
      const selectedMode = await selectTournamentMode()
      if (!selectedMode) return

      const confirmMsg = `Auto-generate matches for ${registrations.value.length} players using ${formatTournamentType(selectedMode)} format?`
      if (!confirm(confirmMsg)) return

      try {
        // Get players from registrations
        const players = registrations.value.map(reg => ({
          id: reg.user.id,
          name: reg.user.name,
          ranking_level: reg.user.ranking_level
        }))

        // Generate matches using bracket generator
        const result = generateTournamentMatches(selectedMode, players)

        if (result.error) {
          alert('Error: ' + result.error)
          return
        }

        // Add tournament_id and race_to_score to all matches
        const matchesToCreate = result.matches.map(match => ({
          ...match,
          tournament_id: route.params.id,
          player1_score: 0,
          player2_score: 0,
          status: 'scheduled',
          race_to_score: raceToScore.value
        }))

        // Insert all matches
        const { data, error } = await supabase
          .from('matches')
          .insert(matchesToCreate)
          .select()

        if (error) throw error

        alert(`✅ Successfully generated ${matchesToCreate.length} matches!\nTotal Rounds: ${result.totalRounds || 1}`)
        await loadData()
      } catch (err) {
        alert('Error generating matches: ' + err.message)
        console.error('Auto-generate error:', err)
      }
    }

    const clearAllMatches = async () => {
      const confirmMsg = `⚠️ WARNING: This will delete ALL ${matches.value.length} matches for this tournament!\n\nThis action cannot be undone. Continue?`
      if (!confirm(confirmMsg)) return

      try {
        const { error } = await supabase
          .from('matches')
          .delete()
          .eq('tournament_id', route.params.id)

        if (error) throw error

        alert(`✅ Successfully deleted ${matches.value.length} matches. You can now re-generate the bracket.`)
        await loadData()
      } catch (err) {
        alert('Error clearing matches: ' + err.message)
        console.error('Clear matches error:', err)
      }
    }

    const handleAdvanceWinner = async (completedMatch) => {
      try {
        const winnerId = completedMatch.winner_id
        if (!winnerId) {
          alert('No winner found for this match')
          return
        }

        const winnerName = getPlayerName(winnerId)
        const confirmMsg = `Advance ${winnerName} to the next round?`
        if (!confirm(confirmMsg)) return

        await advanceWinnerToNextRound(completedMatch, winnerId)
        
        alert(`✅ ${winnerName} advanced to next round!`)
      } catch (err) {
        alert('Error: ' + err.message)
        console.error('Advance error:', err)
      }
    }

    const handleSetWinner = async ({ match, playerType }) => {
      if (!authStore.isAdmin) {
        alert('Only administrators can set winners')
        return
      }

      const playerId = match[`${playerType}_id`]
      const playerName = getPlayerName(playerId)

      try {
        const updateData = {
          winner_id: playerId,
          status: 'completed'
        }

        // Set a default score if no score is set
        if (!match[`${playerType}_score`]) {
          updateData[`${playerType}_score`] = raceToScore.value
        }

        const { error } = await supabase
          .from('matches')
          .update(updateData)
          .eq('id', match.id)

        if (error) throw error
        
        await loadData()
        
        alert(`🏆 ${playerName} declared as winner!`)
      } catch (err) {
        alert('Error setting winner: ' + err.message)
        console.error('Set winner error:', err)
      }
    }

    const advanceWinnerToNextRound = async (completedMatch, winnerId) => {
      try {
        const currentMatchNumber = completedMatch.match_number
        const bracketType = completedMatch.bracket_type
        const loserId = completedMatch.player1_id === winnerId ? completedMatch.player2_id : completedMatch.player1_id
        
        console.log(`🎯 Advancing from ${bracketType} Match ${currentMatchNumber}`)
        console.log(`   Winner: ${getPlayerName(winnerId)}`)
        console.log(`   Loser: ${getPlayerName(loserId)}`)
        
        // Standard 16-player Double Elimination Mapping
        const advancementMap = {
          // Winners Bracket
          winners: {
            // Match 1-8 → Match 13-16
            1: { next: 13, field: 'player1_id', loserTo: 9, loserField: 'player1_id' },
            2: { next: 13, field: 'player2_id', loserTo: 9, loserField: 'player2_id' },
            3: { next: 14, field: 'player1_id', loserTo: 10, loserField: 'player1_id' },
            4: { next: 14, field: 'player2_id', loserTo: 10, loserField: 'player2_id' },
            5: { next: 15, field: 'player1_id', loserTo: 11, loserField: 'player1_id' },
            6: { next: 15, field: 'player2_id', loserTo: 11, loserField: 'player2_id' },
            7: { next: 16, field: 'player1_id', loserTo: 12, loserField: 'player1_id' },
            8: { next: 16, field: 'player2_id', loserTo: 12, loserField: 'player2_id' },
            // Match 13-16 → Match 21-22
            13: { next: 21, field: 'player1_id', loserTo: 20, loserField: 'player1_id' },
            14: { next: 21, field: 'player2_id', loserTo: 19, loserField: 'player1_id' },
            15: { next: 22, field: 'player1_id', loserTo: 18, loserField: 'player1_id' },
            16: { next: 22, field: 'player2_id', loserTo: 17, loserField: 'player1_id' },
            // Match 21-22 → Match 27
            21: { next: 27, field: 'player1_id', loserTo: 25, loserField: 'player1_id' },
            22: { next: 27, field: 'player2_id', loserTo: 26, loserField: 'player1_id' },
            // Match 27 → Match 30 (Grand Final)
            27: { next: 30, field: 'player1_id', loserTo: 29, loserField: 'player1_id' }
          },
          // Losers Bracket
          losers: {
            // Match 9-12 → Match 17-20
            9: { next: 17, field: 'player2_id' },
            10: { next: 18, field: 'player2_id' },
            11: { next: 19, field: 'player2_id' },
            12: { next: 20, field: 'player2_id' },
            // Match 17-20 → Match 23-24
            17: { next: 23, field: 'player1_id' },
            18: { next: 23, field: 'player2_id' },
            19: { next: 24, field: 'player1_id' },
            20: { next: 24, field: 'player2_id' },
            // Match 23-24 → Match 25-26
            23: { next: 25, field: 'player2_id' },
            24: { next: 26, field: 'player2_id' },
            // Match 25-26 → Match 28
            25: { next: 28, field: 'player1_id' },
            26: { next: 28, field: 'player2_id' },
            // Match 28 → Match 29
            28: { next: 29, field: 'player2_id' },
            // Match 29 → Match 30 (Grand Final)
            29: { next: 30, field: 'player2_id' }
          }
        }
        
        const advancement = advancementMap[bracketType]?.[currentMatchNumber]
        
        if (!advancement) {
          console.log('No advancement rule found or final match')
          await loadData()
          return
        }
        
        // Advance winner
        if (advancement.next) {
          const nextMatch = matches.value.find(m => 
            m.match_number === advancement.next &&
            m.tournament_id === completedMatch.tournament_id
          )
          
          if (nextMatch) {
            const { error } = await supabase
              .from('matches')
              .update({ [advancement.field]: winnerId })
              .eq('id', nextMatch.id)
            
            if (error) {
              console.error('Error updating winner:', error)
              throw error
            }
            
            console.log(`✅ Winner advanced to Match ${advancement.next} (${advancement.field})`)
          } else {
            console.error(`❌ Could not find next match: Match ${advancement.next}`)
            alert(`Error: Could not find Match ${advancement.next} to advance winner`)
          }
        }
        
        // Send loser to losers bracket (winners bracket only)
        if (bracketType === 'winners' && advancement.loserTo && loserId) {
          const loserMatch = matches.value.find(m => 
            m.match_number === advancement.loserTo &&
            m.bracket_type === 'losers' &&
            m.tournament_id === completedMatch.tournament_id
          )
          
          if (loserMatch) {
            const { error } = await supabase
              .from('matches')
              .update({ [advancement.loserField]: loserId })
              .eq('id', loserMatch.id)
            
            if (error) {
              console.error('Error updating loser:', error)
              throw error
            }
            
            console.log(`↘️ Loser sent to Losers Match ${advancement.loserTo} (${advancement.loserField})`)
          } else {
            console.error(`❌ Could not find loser match: Match ${advancement.loserTo}`)
          }
        } else if (bracketType === 'losers') {
          console.log(`❌ Loser ${getPlayerName(loserId)} is eliminated`)
        }
        
        // Reload data to show changes
        await loadData()
        
      } catch (err) {
        console.error('Error advancing winner:', err)
        alert('Error advancing winner to next round: ' + err.message)
      }
    }

    const updateRaceToScore = async () => {
      if (!authStore.isAdmin) {
        alert('Only administrators can update race settings')
        return
      }

      if (raceToScore.value < 1 || raceToScore.value > 21) {
        alert('Race to score must be between 1 and 21')
        return
      }

      const confirmMsg = `Update race to ${raceToScore.value} for all ${matches.value.length} matches?\n\nThis will not affect completed matches.`
      if (!confirm(confirmMsg)) return

      try {
        // Update all non-completed matches
        const { error } = await supabase
          .from('matches')
          .update({ race_to_score: raceToScore.value })
          .eq('tournament_id', route.params.id)
          .neq('status', 'completed')

        if (error) throw error

        alert(`✅ Race to ${raceToScore.value} updated for all active matches!`)
        await loadData()
      } catch (err) {
        alert('Error updating race score: ' + err.message)
        console.error('Race score update error:', err)
      }
    }

    const handleScoreUpdate = async ({ match, playerType }) => {
      if (!authStore.isAdmin) {
        alert('Only administrators can update scores')
        return
      }

      const currentScore = playerType === 'player1' ? match.player1_score : match.player2_score
      const playerName = playerType === 'player1' 
        ? getPlayerName(match.player1_id) 
        : getPlayerName(match.player2_id)

      const newScore = prompt(`Enter new score for ${playerName} (Race to ${raceToScore.value}):`, currentScore || 0)
      
      if (newScore === null) return // User cancelled
      
      const score = parseInt(newScore)
      if (isNaN(score) || score < 0) {
        alert('Please enter a valid non-negative number')
        return
      }

      // Check if player reached race to X score
      if (score >= raceToScore.value) {
        const confirmWin = confirm(`${playerName} reached ${score} points (Race to ${raceToScore.value})!\n\nDeclare ${playerName} as the winner?`)
        if (!confirmWin) return
      }

      try {
        const updateData = {}
        updateData[`${playerType}_score`] = score
        
        // Check for race to X completion
        if (score >= raceToScore.value) {
          // Player reached race to X, they win
          updateData.winner_id = match[`${playerType}_id`]
          updateData.status = 'completed'
        } else {
          // Check if other player also has a score
          const otherScoreField = playerType === 'player1' ? 'player2_score' : 'player1_score'
          const otherScore = match[otherScoreField] || 0
          
          if (otherScore >= raceToScore.value) {
            // Other player already won
            updateData.status = 'completed'
            // Don't change winner_id, other player already won
          } else if (otherScore > 0) {
            // Both players have scores but neither reached race to X
            updateData.status = 'in_progress'
          } else {
            // Only one score set, mark as in progress
            updateData.status = 'in_progress'
          }
        }

        const { error } = await supabase
          .from('matches')
          .update(updateData)
          .eq('id', match.id)

        if (error) throw error
        
        await loadData()
        
        if (score >= raceToScore.value) {
          alert(`🏆 ${playerName} wins! (${score} points - Race to ${raceToScore.value})\n\nUse "Advance Winner" button to promote to next round.`)
        } else {
          alert(`✅ Score updated for ${playerName}: ${score}`)
        }
      } catch (err) {
        alert('Error updating score: ' + err.message)
        console.error('Score update error:', err)
      }
    }

    const addParticipant = async () => {
      if (!selectedPlayerId.value) {
        alert('Please select a player')
        return
      }

      try {
        const { error } = await supabase
          .from('tournament_registrations')
          .insert([{
            tournament_id: route.params.id,
            user_id: selectedPlayerId.value,
            status: 'registered'
          }])

        if (error) throw error

        await loadData()
        showAddParticipant.value = false
        selectedPlayerId.value = ''
        alert('Player added to tournament')
      } catch (err) {
        alert('Error: ' + err.message)
      }
    }

    const removeParticipant = async (registration) => {
      if (confirm(`Remove ${registration.user.name} from this tournament?`)) {
        try {
          const { error } = await supabase
            .from('tournament_registrations')
            .delete()
            .eq('id', registration.id)

          if (error) throw error

          alert('Player removed from tournament')
          await loadData()
        } catch (err) {
          alert('Error: ' + err.message)
        }
      }
    }

    const editMatch = (match) => {
      editingMatch.value = match
      matchForm.value = {
        round_number: match.round_number,
        match_number: match.match_number,
        player1_id: match.player1_id,
        player2_id: match.player2_id,
        status: match.status,
        player1_score: match.player1_score || 0,
        player2_score: match.player2_score || 0,
        winner_id: match.winner_id || '',
        table_number: match.table_number
      }
    }

    const closeMatchModal = () => {
      showCreateMatch.value = false
      editingMatch.value = null
      matchForm.value = {
        round_number: 1,
        match_number: 1,
        player1_id: '',
        player2_id: '',
        status: 'scheduled',
        player1_score: 0,
        player2_score: 0,
        winner_id: '',
        table_number: null
      }
    }

    const saveMatch = async () => {
      if (!matchForm.value.player1_id || !matchForm.value.player2_id) {
        alert('Please select both players')
        return
      }

      const data = {
        tournament_id: route.params.id,
        ...matchForm.value,
        player1_score: parseInt(matchForm.value.player1_score) || 0,
        player2_score: parseInt(matchForm.value.player2_score) || 0,
        table_number: matchForm.value.table_number ? parseInt(matchForm.value.table_number) : null
      }

      let result
      if (editingMatch.value) {
        result = await matchStore.updateMatch(editingMatch.value.id, data)
      } else {
        result = await matchStore.createMatch(data)
      }

      if (result.success) {
        await loadData()
        closeMatchModal()
      } else {
        alert('Error: ' + result.error)
      }
    }

    const getPlayerName = (playerId) => {
      if (!playerId) return 'TBD'
      // First try to find in allPlayersForBracket (registered players)
      const player = allPlayersForBracket.value.find(p => p.id === playerId)
      if (player) return player.name
      
      // Fallback: try to find in all users
      const allUsers = availablePlayers.value
      const fallbackPlayer = allUsers.find(u => u.id === playerId)
      return fallbackPlayer ? fallbackPlayer.name : 'Unknown'
    }

    const getStatusBadgeClass = (status) => {
      const classes = {
        upcoming: 'badge-secondary',
        registration: 'badge-info',
        in_progress: 'badge-primary',
        completed: 'badge-success',
        cancelled: 'badge-danger'
      }
      return classes[status] || 'badge-secondary'
    }

    const getMatchStatusBadgeClass = (status) => {
      const classes = {
        scheduled: 'badge-secondary',
        in_progress: 'badge-warning',
        completed: 'badge-success',
        cancelled: 'badge-danger'
      }
      return classes[status] || 'badge-secondary'
    }

    const getSkillBadgeClass = (level) => {
      const classes = {
        beginner: 'badge-secondary',
        intermediate: 'badge-info',
        advanced: 'badge-primary',
        professional: 'badge-warning'
      }
      return classes[level] || 'badge-secondary'
    }

    const formatStatus = (status) => {
      return status.split('_').map(word => 
        word.charAt(0).toUpperCase() + word.slice(1)
      ).join(' ')
    }

    const formatTournamentType = (type) => {
      return type.split('_').map(word => 
        word.charAt(0).toUpperCase() + word.slice(1)
      ).join(' ')
    }

    const formatSkillLevel = (level) => {
      if (!level) return 'N/A'
      return level.charAt(0).toUpperCase() + level.slice(1)
    }

    const formatDate = (dateString) => {
      if (!dateString) return 'N/A'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-NZ', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    const formatRankBadge = (level) => {
      const badges = {
        hall_of_fame: '👑',
        pro_level: '💎',
        grand_master: '🌟',
        master: '⭐',
        elite: '🔷',
        expert: '🔶',
        advance: '🔺',
        intermediate: '🔸',
        beginner: '⚪'
      }
      return badges[level] || '⚪'
    }

    onMounted(() => {
      loadData()
    })

    return {
      authStore,
      loading,
      tournament,
      participants,
      registrations,
      matches,
      completedMatches,
      canRegister,
      isRegistered,
      isFull,
      availablePlayers,
      allPlayersForBracket,
      showAddParticipant,
      showCreateMatch,
      editingMatch,
      selectedPlayerId,
      raceToScore,
      matchForm,
      registerForTournament,
      cancelRegistration,
      selectTournamentMode,
      autoGenerateMatches,
      clearAllMatches,
      handleAdvanceWinner,
      handleSetWinner,
      advanceWinnerToNextRound,
      updateRaceToScore,
      handleScoreUpdate,
      addParticipant,
      removeParticipant,
      editMatch,
      closeMatchModal,
      saveMatch,
      getPlayerName,
      getStatusBadgeClass,
      getMatchStatusBadgeClass,
      getSkillBadgeClass,
      formatStatus,
      formatTournamentType,
      formatSkillLevel,
      formatDate,
      formatRankBadge
    }
  }
}
</script>

<style scoped>
.tournament-detail-page {
  max-width: 100%;
}

.tournament-header-section {
  margin-bottom: 2rem;
}

.header-content {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}

.header-content h1 {
  flex: 1;
  font-size: 2rem;
  font-weight: 600;
  color: #1a1a2e;
}

.badge-lg {
  padding: 0.5rem 1rem;
  font-size: 1rem;
}

.info-grid, .stats-grid {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.info-item {
  display: flex;
  justify-content: space-between;
  padding: 0.75rem;
  background: #f8f9fa;
  border-radius: 6px;
}

.info-label {
  font-weight: 500;
  color: #6c757d;
}

.info-value {
  font-weight: 600;
  color: #1a1a2e;
}

.info-value.prize {
  color: #28a745;
}

.stats-grid {
  flex-direction: row;
  justify-content: space-around;
}

.stat-box {
  text-align: center;
  padding: 1rem;
}

.stat-number {
  font-size: 2rem;
  font-weight: 700;
  color: #0066cc;
}

.stat-label {
  font-size: 0.875rem;
  color: #6c757d;
  margin-top: 0.25rem;
}

.participants-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 1rem;
}

.participant-card {
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.participant-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.participant-stats {
  display: flex;
  gap: 1rem;
  font-size: 0.875rem;
  color: #6c757d;
}

.matches-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.match-card {
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid #0066cc;
}

.match-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.75rem;
}

.match-body {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  gap: 1rem;
  align-items: center;
  margin-bottom: 0.75rem;
}

.match-player {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.match-vs {
  font-weight: 700;
  color: #6c757d;
  text-align: center;
}

.score {
  font-size: 1.5rem;
  font-weight: 700;
  color: #0066cc;
}

.match-footer {
  padding-top: 0.75rem;
  border-top: 1px solid #dee2e6;
  margin-bottom: 0.75rem;
}

.winner-label {
  color: #28a745;
  font-weight: 500;
}

.match-actions {
  display: flex;
  gap: 0.5rem;
}

.match-actions-header {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

@media (max-width: 768px) {
  /* 头部区域优化 */
  .tournament-header-section {
    padding: 1rem;
  }

  .header-content {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }

  .header-content h1 {
    font-size: 20px;
    order: 1;
  }

  .header-content .btn-secondary {
    order: 0;
    min-height: 44px;
    font-size: 15px;
    align-self: flex-start;
    padding: 10px 20px;
  }

  .header-content .badge-lg {
    order: 2;
    align-self: flex-start;
    font-size: 14px;
    padding: 8px 16px;
  }

  /* 信息卡片单列显示 */
  .row {
    flex-direction: column;
  }

  .col {
    width: 100% !important;
  }

  /* 信息网格优化 */
  .info-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .info-item {
    padding: 12px;
    background: rgba(102, 126, 234, 0.05);
    border-radius: 8px;
  }

  .info-label {
    font-size: 12px;
    font-weight: 600;
  }

  .info-value {
    font-size: 16px;
    font-weight: 700;
  }

  /* 统计卡片优化 */
  .stats-grid {
    flex-direction: row;
    gap: 8px;
  }

  .stat-box {
    flex: 1;
    padding: 12px;
  }

  .stat-number {
    font-size: 24px;
  }

  .stat-label {
    font-size: 11px;
  }

  /* 参赛玩家卡片优化 */
  .card-header {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }

  .card-header .btn {
    width: 100%;
    min-height: 48px;
    font-size: 16px;
    font-weight: 700;
  }

  /* Add Player 按钮特殊样式 */
  .card-header .btn-primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
  }

  .card-header .btn-primary::before {
    content: '➕';
    font-size: 18px;
  }

  /* Register 按钮特殊样式 */
  .card-header .btn-success {
    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
    border: none;
    box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
  }

  /* Cancel Registration 按钮特殊样式 */
  .card-header .btn-danger {
    background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
    border: none;
    box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
  }

  .card-title {
    font-size: 18px;
  }

  .participants-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .participant-card {
    padding: 16px;
    border: 2px solid var(--color-border);
    border-radius: 12px;
    background: var(--color-card-bg);
  }

  .participant-info {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
    margin-bottom: 8px;
  }

  .participant-info strong {
    font-size: 16px;
  }

  .participant-stats {
    font-size: 13px;
    margin-bottom: 8px;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .participant-date {
    margin-bottom: 8px;
  }

  .participant-card .btn {
    width: 100%;
    min-height: 44px;
  }

  /* Bracket Actions 优化 */
  .bracket-actions-header {
    width: 100%;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .bracket-actions-header .btn {
    width: 100%;
    min-height: 48px;
    font-size: 16px;
  }

  /* Race to X 设置优化 */
  .race-setting .row {
    flex-direction: column;
  }

  .race-setting .form-label {
    font-size: 14px;
    margin-bottom: 8px;
  }

  .race-setting .input-group {
    width: 100%;
  }

  .race-setting input {
    min-height: 48px;
    font-size: 16px;
  }

  .race-setting .btn {
    min-height: 48px;
    font-size: 14px;
  }

  /* 对阵表横向滚动 */
  .bracket-container {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    padding: 16px 0;
  }

  /* 添加滚动提示 */
  .bracket-container::before {
    content: '👈 Swipe to view bracket 👉';
    display: block;
    text-align: center;
    font-size: 12px;
    color: var(--color-text-secondary);
    margin-bottom: 12px;
    padding: 8px;
    background: rgba(102, 126, 234, 0.1);
    border-radius: 6px;
  }

  /* 比赛卡片优化 */
  .match-body {
    grid-template-columns: 1fr;
    gap: 8px;
  }

  .match-vs {
    order: -1;
    font-size: 16px;
    padding: 8px 0;
  }

  .match-player {
    padding: 12px;
  }

  .player-name {
    font-size: 15px;
  }

  .match-score input {
    min-height: 44px;
    width: 60px;
    font-size: 18px;
  }

  .match-actions {
    flex-direction: column;
    gap: 8px;
  }

  .match-actions .btn {
    width: 100%;
    min-height: 44px;
  }

  /* 模态框优化 */
  .modal {
    position: fixed !important;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.6);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    overflow-y: auto;
    padding: 20px;
  }

  .modal-content {
    width: 92vw;
    max-width: 92vw;
    margin: 0 auto;
    max-height: 85vh;
    overflow-y: auto;
    background: white;
    border-radius: 16px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    -webkit-overflow-scrolling: touch;
  }

  .modal-header {
    padding: 1.25rem;
    border-bottom: 2px solid #dee2e6;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-direction: row !important;
  }

  .modal-header h2 {
    font-size: 18px;
    margin: 0;
    flex: 1;
  }

  .modal-header .btn {
    min-height: 36px;
    min-width: 36px;
    padding: 8px 12px;
    font-size: 14px;
  }

  .modal-body {
    padding: 1.5rem;
  }

  .modal-body .form-group {
    margin-bottom: 1.25rem;
  }

  .modal-body .form-label {
    font-size: 15px;
    font-weight: 700;
    margin-bottom: 10px;
    display: block;
    color: var(--color-text-primary);
  }

  .modal-body .form-control,
  .modal-body select {
    min-height: 52px;
    font-size: 17px;
    padding: 12px 16px;
    border: 2px solid #ced4da;
    border-radius: 8px;
  }

  .modal-body select {
    background-color: white;
    cursor: pointer;
  }

  .modal-footer {
    padding: 1.25rem;
    border-top: 2px solid #dee2e6;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .modal-footer .btn {
    width: 100%;
    min-height: 52px;
    font-size: 17px;
    font-weight: 700;
    border: none;
    border-radius: 8px;
  }

  .modal-footer .btn-success {
    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
    color: white;
    box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
    order: -1;
  }

  .modal-footer .btn-secondary {
    background: linear-gradient(135deg, #6c757d 0%, #5a6268 100%);
    color: white;
    box-shadow: 0 2px 8px rgba(108, 117, 125, 0.3);
  }
}
</style>


