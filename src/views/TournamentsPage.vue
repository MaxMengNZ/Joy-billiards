<template>
  <div class="tournaments-page">
    <!-- Hero Header with Dynamic Background -->
    <section class="tournaments-hero">
      <div class="tournaments-hero-background">
        <div class="tournaments-hero-pattern"></div>
        <div class="tournaments-hero-glow tournaments-glow-left"></div>
        <div class="tournaments-hero-glow tournaments-glow-right"></div>
      </div>
      <div class="tournaments-hero-content">
        <div class="hero-badge">
          <span class="badge-icon">🏆</span>
          <span class="badge-text">Competitive Gaming Events</span>
        </div>
        <h1 class="hero-title">
          Heyball <span class="title-highlight">Tournaments</span>
        </h1>
        <p class="hero-subtitle">
          Join competitive events, test your skills, and compete for glory
        </p>
        <div class="hero-actions" v-if="authStore.isAdmin">
          <button class="btn-hero btn-hero-primary" @click="showCreateModal = true">
            <span class="btn-icon">➕</span>
            <span>Create Tournament</span>
          </button>
        </div>
      </div>
    </section>

    <div class="tournaments-content">

    <div v-if="tournamentStore.loading" class="loading">
      <div class="spinner"></div>
    </div>

    <div v-else-if="tournamentStore.error" class="alert alert-danger">
      {{ tournamentStore.error }}
    </div>

    <div v-else>
      <!-- Tournament Status Tabs -->
      <div class="tabs">
        <button 
          class="tab-button"
          :class="{ active: activeTab === 'all' }"
          @click="activeTab = 'all'"
        >
          All Tournaments
        </button>
        <button 
          class="tab-button"
          :class="{ active: activeTab === 'upcoming' }"
          @click="activeTab = 'upcoming'"
        >
          Upcoming ({{ tournamentStore.upcomingTournaments.length }})
        </button>
        <button 
          class="tab-button"
          :class="{ active: activeTab === 'active' }"
          @click="activeTab = 'active'"
        >
          In Progress ({{ tournamentStore.activeTournaments.length }})
        </button>
        <button 
          class="tab-button"
          :class="{ active: activeTab === 'completed' }"
          @click="activeTab = 'completed'"
        >
          Completed ({{ tournamentStore.completedTournaments.length }})
        </button>
      </div>

      <!-- Tournaments Grid -->
      <div class="tournaments-grid">
        <div 
          v-for="tournament in displayedTournaments" 
          :key="tournament.id"
          class="tournament-card card"
        >
          <div class="tournament-header">
            <div class="tournament-title-row">
              <h3>{{ tournament.name }}</h3>
              <span class="category-badge-small" :class="`category-${tournament.participant_category || 'adult'}`">
                {{ tournament.participant_category === 'student' ? '🎓 Student' : '👔 Adult' }}
              </span>
            </div>
            <span class="badge" :class="getStatusBadgeClass(tournament.status)">
              {{ formatStatus(tournament.status) }}
            </span>
          </div>
          
          <div class="tournament-body">
            <p class="tournament-description">{{ tournament.description || 'No description' }}</p>
            
            <div class="tournament-details">
              <div class="detail-row">
                <span class="detail-label">Type:</span>
                <span class="detail-value">{{ formatTournamentType(tournament.tournament_type) }}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Start Date:</span>
                <span class="detail-value">{{ formatDate(tournament.start_date) }}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Max Players:</span>
                <span class="detail-value">{{ tournament.max_players || 'Unlimited' }}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Entry Fee:</span>
                <span class="detail-value">${{ tournament.entry_fee }}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Prize Pool:</span>
                <span class="detail-value prize">${{ tournament.prize_pool }}</span>
              </div>
              <div class="detail-row registration-row">
                <span class="detail-label">Registered:</span>
                <span class="detail-value registration-count">
                  👥 {{ getRegistrationCount(tournament.id) }}
                  <span v-if="tournament.max_players">/ {{ tournament.max_players }}</span>
                  <span v-if="tournament.max_players && getRegistrationCount(tournament.id) >= tournament.max_players" class="full-badge">FULL</span>
                </span>
              </div>
            </div>
          </div>

          <div class="tournament-actions">
            <router-link 
              :to="`/tournaments/${tournament.id}`" 
              class="btn btn-primary btn-sm"
            >
              View Details
            </router-link>
            <button 
              v-if="authStore.isAdmin"
              class="btn btn-secondary btn-sm" 
              @click="editTournament(tournament)"
            >
              Edit
            </button>
            <button 
              v-if="authStore.isAdmin"
              class="btn btn-danger btn-sm" 
              @click="confirmDelete(tournament)"
            >
              Delete
            </button>
          </div>
        </div>
      </div>

      <div v-if="displayedTournaments.length === 0" class="text-center p-4">
        <p class="text-secondary">No tournaments found in this category</p>
      </div>
    </div>

    <!-- Create/Edit Tournament Modal -->
    <div v-if="showCreateModal || editingTournament" class="modal">
      <div class="modal-content modal-large">
        <div class="modal-header">
          <h2>{{ editingTournament ? 'Edit Tournament' : 'Create New Tournament' }}</h2>
          <button class="btn btn-secondary btn-sm" @click="closeModal">Close</button>
        </div>
        <div class="modal-body">
          <div class="row">
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">Tournament Name *</label>
                <input type="text" class="form-control" v-model="tournamentForm.name" required>
              </div>
            </div>
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">Tournament Type *</label>
                <select class="form-control" v-model="tournamentForm.tournament_type" required>
                  <option value="single_elimination">Single Elimination</option>
                  <option value="double_elimination">Double Elimination</option>
                  <option value="round_robin">Round Robin</option>
                  <option value="swiss">Swiss System</option>
                </select>
              </div>
            </div>
          </div>
          
          <div class="form-group">
            <label class="form-label">Description</label>
            <textarea class="form-control" v-model="tournamentForm.description" rows="3"></textarea>
          </div>

          <div class="row">
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">Start Date *</label>
                <input type="datetime-local" class="form-control" v-model="tournamentForm.start_date" required>
              </div>
            </div>
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">End Date</label>
                <input type="datetime-local" class="form-control" v-model="tournamentForm.end_date">
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col col-3">
              <div class="form-group">
                <label class="form-label">Max Players</label>
                <input type="number" class="form-control" v-model="tournamentForm.max_players" min="2">
              </div>
            </div>
            <div class="col col-3">
              <div class="form-group">
                <label class="form-label">Entry Fee ($)</label>
                <input type="number" class="form-control" v-model="tournamentForm.entry_fee" min="0" step="0.01">
              </div>
            </div>
            <div class="col col-3">
              <div class="form-group">
                <label class="form-label">Prize Pool ($)</label>
                <input type="number" class="form-control" v-model="tournamentForm.prize_pool" min="0" step="0.01">
              </div>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Status *</label>
            <select class="form-control" v-model="tournamentForm.status" required>
              <option value="upcoming">Upcoming</option>
              <option value="registration">Registration Open</option>
              <option value="in_progress">In Progress</option>
              <option value="completed">Completed</option>
              <option value="cancelled">Cancelled</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeModal">Cancel</button>
          <button class="btn btn-success" @click="saveTournament">
            {{ editingTournament ? 'Update' : 'Create' }}
          </button>
        </div>
      </div>
    </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useTournamentStore } from '../stores/tournamentStore'
import { useAuthStore } from '../stores/authStore'
import { formatNZDate, formatNZDateTimeFull, toNZDateTimeLocalValue, fromNZDateTimeLocalValue } from '../utils/timezone'
import { supabase } from '../config/supabase'

export default {
  name: 'TournamentsPage',
  setup() {
    const tournamentStore = useTournamentStore()
    const authStore = useAuthStore()
    
    const showCreateModal = ref(false)
    const editingTournament = ref(null)
    const activeTab = ref('all')
    const registrationCounts = ref({})
    
    const tournamentForm = ref({
      name: '',
      description: '',
      tournament_type: 'single_elimination',
      start_date: '',
      end_date: '',
      max_players: null,
      entry_fee: 0,
      prize_pool: 0,
      status: 'upcoming'
    })

    const displayedTournaments = computed(() => {
      switch (activeTab.value) {
        case 'upcoming':
          return tournamentStore.upcomingTournaments
        case 'active':
          return tournamentStore.activeTournaments
        case 'completed':
          return tournamentStore.completedTournaments
        default:
          return tournamentStore.tournaments
      }
    })

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

    const formatDate = (dateString) => {
      // 使用新西兰时区统一显示时间
      return formatNZDate(dateString, {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    const editTournament = (tournament) => {
      editingTournament.value = tournament
      tournamentForm.value = {
        name: tournament.name,
        description: tournament.description || '',
        tournament_type: tournament.tournament_type,
        // 使用新西兰时区转换，避免时区偏移
        start_date: tournament.start_date ? toNZDateTimeLocalValue(tournament.start_date) : '',
        end_date: tournament.end_date ? toNZDateTimeLocalValue(tournament.end_date) : '',
        max_players: tournament.max_players,
        entry_fee: tournament.entry_fee,
        prize_pool: tournament.prize_pool,
        status: tournament.status
      }
    }

    const closeModal = () => {
      showCreateModal.value = false
      editingTournament.value = null
      tournamentForm.value = {
        name: '',
        description: '',
        tournament_type: 'single_elimination',
        start_date: '',
        end_date: '',
        max_players: null,
        entry_fee: 0,
        prize_pool: 0,
        status: 'upcoming'
      }
    }

    const saveTournament = async () => {
      if (!tournamentForm.value.name || !tournamentForm.value.start_date) {
        alert('Please fill in all required fields')
        return
      }

      const data = {
        ...tournamentForm.value,
        // 将新西兰时区的输入转换为UTC存储（Supabase格式）
        start_date: fromNZDateTimeLocalValue(tournamentForm.value.start_date),
        end_date: tournamentForm.value.end_date ? fromNZDateTimeLocalValue(tournamentForm.value.end_date) : null,
        entry_fee: parseFloat(tournamentForm.value.entry_fee) || 0,
        prize_pool: parseFloat(tournamentForm.value.prize_pool) || 0,
        max_players: tournamentForm.value.max_players ? parseInt(tournamentForm.value.max_players) : null
      }

      let result
      if (editingTournament.value) {
        result = await tournamentStore.updateTournament(editingTournament.value.id, data)
      } else {
        result = await tournamentStore.createTournament(data)
      }

      if (result.success) {
        closeModal()
        await tournamentStore.fetchTournaments()
      } else {
        alert('Error: ' + result.error)
      }
    }

    const confirmDelete = async (tournament) => {
      if (confirm(`Are you sure you want to delete "${tournament.name}"?`)) {
        const result = await tournamentStore.deleteTournament(tournament.id)
        if (result.success) {
          await tournamentStore.fetchTournaments()
        } else {
          alert('Error: ' + result.error)
        }
      }
    }

    const loadRegistrationCounts = async () => {
      try {
        const { data, error } = await supabase
          .from('tournament_registrations')
          .select('tournament_id')
          .eq('status', 'registered')

        if (error) throw error

        // Count registrations per tournament
        const counts = {}
        data.forEach(reg => {
          counts[reg.tournament_id] = (counts[reg.tournament_id] || 0) + 1
        })

        registrationCounts.value = counts
      } catch (err) {
        console.error('Error loading registration counts:', err)
      }
    }

    const getRegistrationCount = (tournamentId) => {
      return registrationCounts.value[tournamentId] || 0
    }

    onMounted(async () => {
      await tournamentStore.fetchTournaments()
      await loadRegistrationCounts()
    })

    return {
      tournamentStore,
      authStore,
      showCreateModal,
      editingTournament,
      activeTab,
      tournamentForm,
      displayedTournaments,
      registrationCounts,
      getRegistrationCount,
      getStatusBadgeClass,
      formatStatus,
      formatTournamentType,
      formatDate,
      editTournament,
      closeModal,
      saveTournament,
      confirmDelete
    }
  }
}
</script>

<style scoped>
.tournaments-page {
  max-width: 100%;
  margin: 0;
  padding: 0;
}

/* Tournaments Hero Section */
.tournaments-hero {
  position: relative;
  padding: 5rem 2rem 4rem;
  overflow: hidden;
  text-align: center;
  margin-bottom: 3rem;
}

.tournaments-hero-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #9C27B0 0%, #673AB7 25%, #4A148C 50%, #673AB7 75%, #9C27B0 100%);
  z-index: 0;
}

.tournaments-hero-pattern {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(circle at 25% 35%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 75% 65%, rgba(78, 205, 196, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 50% 50%, rgba(255, 215, 0, 0.08) 0%, transparent 50%);
  animation: pattern-drift 20s ease-in-out infinite;
}

@keyframes pattern-drift {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(18px, 18px) scale(1.05); }
}

.tournaments-hero-glow {
  position: absolute;
  width: 500px;
  height: 500px;
  border-radius: 50%;
  filter: blur(90px);
  animation: glow-pulse 5s ease-in-out infinite;
}

.tournaments-glow-left {
  top: 20%;
  left: 10%;
  background: radial-gradient(circle, rgba(78, 205, 196, 0.3) 0%, transparent 70%);
}

.tournaments-glow-right {
  bottom: 20%;
  right: 10%;
  background: radial-gradient(circle, rgba(255, 215, 0, 0.3) 0%, transparent 70%);
  animation-delay: 2.5s;
}

@keyframes glow-pulse {
  0%, 100% { opacity: 0.6; transform: scale(1); }
  50% { opacity: 0.9; transform: scale(1.1); }
}

.tournaments-hero-content {
  position: relative;
  z-index: 1;
  max-width: 800px;
  margin: 0 auto;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1.5rem;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 50px;
  margin-bottom: 1.5rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: white;
  letter-spacing: 0.5px;
  animation: badge-float 3s ease-in-out infinite;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

@keyframes badge-float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
}

.badge-icon {
  font-size: 1.125rem;
}

.hero-title {
  font-size: 3.5rem;
  font-weight: 800;
  color: white;
  margin-bottom: 1rem;
  line-height: 1.2;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
  animation: title-fade-in 1s ease-out;
}

@keyframes title-fade-in {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.title-highlight {
  background: linear-gradient(135deg, #FFD700 0%, #4ECDC4 50%, #FF6B6B 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: gradient-shift 3s ease-in-out infinite;
  background-size: 200% 200%;
}

@keyframes gradient-shift {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

.hero-subtitle {
  font-size: 1.25rem;
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
  line-height: 1.7;
  margin-bottom: 2rem;
}

.hero-actions {
  margin-top: 2rem;
}

.btn-hero {
  display: inline-flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1.125rem 2.5rem;
  border-radius: 50px;
  font-size: 1.125rem;
  font-weight: 700;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  letter-spacing: 0.5px;
}

.btn-hero-primary {
  background: linear-gradient(135deg, #4ECDC4 0%, #45B7AF 100%);
  color: white;
  box-shadow: 0 6px 20px rgba(78, 205, 196, 0.4);
}

.btn-hero-primary:hover {
  transform: translateY(-3px) scale(1.05);
  box-shadow: 0 8px 30px rgba(78, 205, 196, 0.6);
  background: linear-gradient(135deg, #45B7AF 0%, #4ECDC4 100%);
}

.btn-icon {
  font-size: 1.25rem;
}

.tournaments-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 2rem 3rem;
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

/* Tabs */
/* Tabs - Enhanced */
.tabs {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 3rem;
  flex-wrap: wrap;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  max-width: 900px;
  margin-left: auto;
  margin-right: auto;
}

.tab-button {
  padding: 1rem 2rem;
  border: 2px solid transparent;
  background: white;
  border-radius: 50px;
  font-size: 1rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
  color: #6c757d;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.tab-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 16px rgba(156, 39, 176, 0.2);
  color: #9C27B0;
  background: linear-gradient(135deg, rgba(156, 39, 176, 0.05) 0%, rgba(103, 58, 183, 0.05) 100%);
}

.tab-button.active {
  background: linear-gradient(135deg, #9C27B0 0%, #673AB7 100%);
  color: white;
  border-color: transparent;
  box-shadow: 0 6px 20px rgba(156, 39, 176, 0.4);
  transform: translateY(-3px) scale(1.05);
}

/* Tournament Grid */
.tournaments-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 2rem;
  margin-bottom: 3rem;
}

.tournament-card {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: white;
  border-radius: 20px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
  transition: all 0.4s ease;
  position: relative;
  overflow: hidden;
  border: 2px solid transparent;
}

.tournament-card::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: linear-gradient(
    45deg,
    transparent 30%,
    rgba(156, 39, 176, 0.1) 50%,
    transparent 70%
  );
  transform: translateX(-100%) translateY(-100%) rotate(45deg);
  transition: transform 0.6s ease;
}

.tournament-card:hover::before {
  transform: translateX(100%) translateY(100%) rotate(45deg);
}

.tournament-card:hover {
  transform: translateY(-10px) scale(1.02);
  box-shadow: 0 20px 40px rgba(156, 39, 176, 0.2);
  border-color: #9C27B0;
}

.tournament-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
  gap: 1rem;
}

.tournament-title-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex: 1;
  flex-wrap: wrap;
}

.tournament-header h3 {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1a1a2e;
  margin: 0;
}

/* Category Badge Small */
.category-badge-small {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.25rem 0.75rem;
  border-radius: 50px;
  font-weight: 600;
  font-size: 0.875rem;
  white-space: nowrap;
}

.category-badge-small.category-adult {
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
  color: white;
}

.category-badge-small.category-student {
  background: linear-gradient(135deg, #10b981, #059669);
  color: white;
}

.tournament-body {
  flex: 1;
  margin-bottom: 1rem;
}

.tournament-description {
  color: #6c757d;
  margin-bottom: 1rem;
  line-height: 1.6;
}

.tournament-details {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem;
  background: #f8f9fa;
  border-radius: 6px;
}

.detail-label {
  font-weight: 500;
  color: #6c757d;
}

.detail-value {
  font-weight: 600;
  color: #1a1a2e;
}

.detail-value.prize {
  color: #28a745;
}

.registration-row {
  background: linear-gradient(135deg, rgba(0, 102, 204, 0.05), rgba(0, 102, 204, 0.1));
  border-left: 3px solid var(--primary-color);
}

.registration-count {
  font-weight: 700;
  color: var(--primary-color);
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.full-badge {
  padding: 0.25rem 0.5rem;
  background: var(--danger-color);
  color: white;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 700;
}

.tournament-actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.modal-large {
  max-width: 800px;
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: stretch;
  }

  .page-header h1 {
    font-size: 1.5rem;
  }

  .tournaments-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .tournament-card {
    padding: 20px;
    border-radius: 16px;
  }

  .tournament-header h3 {
    font-size: 18px;
    margin-bottom: 8px;
  }

  .tournament-details {
    font-size: 14px;
  }

  .tournament-actions {
    flex-direction: column;
    gap: 8px;
  }

  .tournament-actions .btn {
    width: 100%;
    min-height: 48px;
    font-size: 15px;
    font-weight: 600;
  }

  /* Optimize tabs for mobile */
  .tabs {
    display: flex;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    gap: 8px;
    margin-bottom: 20px;
  }

  .tab-button {
    flex-shrink: 0;
    min-width: auto;
    padding: 10px 16px;
    font-size: 13px;
    white-space: nowrap;
  }

  /* 模态框固定居中 */
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
    flex-direction: row !important;
  }

  .modal-header h2 {
    font-size: 18px;
  }

  .modal-body {
    padding: 1.5rem;
  }

  .modal-body .form-control,
  .modal-body select,
  .modal-body input,
  .modal-body textarea {
    min-height: 52px;
    font-size: 17px;
  }

  .modal-body textarea {
    min-height: 100px;
  }

  .modal-body .form-label {
    font-size: 15px;
    font-weight: 700;
  }

  .modal-footer {
    padding: 1.25rem;
    flex-direction: column;
    gap: 10px;
  }

  .modal-footer .btn {
    width: 100%;
    min-height: 52px;
    font-size: 17px;
    font-weight: 700;
  }
}
</style>


