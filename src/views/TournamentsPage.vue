<template>
  <div class="tournaments-page">
    <!-- Hero Header -->
    <section class="tournaments-hero">
      <div class="tournaments-hero-background">
        <div class="tournaments-hero-pattern"></div>
        <div class="tournaments-hero-glow tournaments-glow-left"></div>
        <div class="tournaments-hero-glow tournaments-glow-right"></div>
      </div>
      <div class="tournaments-hero-content">
        <div class="hero-badge">
          <span class="badge-icon">🏆</span>
          <span class="badge-text">{{ t('tournamentPage.badge') }}</span>
        </div>
        <h1 class="hero-title">
          {{ t('tournamentPage.titleBefore') }} <span class="title-highlight">{{ t('tournamentPage.titleHighlight') }}</span>
        </h1>
        <p class="hero-subtitle">
          {{ t('tournamentPage.subtitle') }}
        </p>
        <div class="hero-actions" v-if="authStore.isAdmin">
          <button class="btn-hero btn-hero-primary" @click="showCreateModal = true">
            <span class="btn-icon">➕</span>
            <span>{{ t('tournamentPage.addEvent') }}</span>
          </button>
        </div>
      </div>
    </section>

    <div class="tournaments-content">
      <!-- Loading State -->
      <div v-if="tournamentStore.loading" class="loading">
        <div class="spinner"></div>
      </div>

      <!-- Error State -->
      <div v-else-if="tournamentStore.error" class="alert alert-danger">
        {{ tournamentStore.error }}
      </div>

      <!-- Calendar View -->
      <div v-else class="calendar-container">
        <!-- Month Navigation -->
        <div class="calendar-header">
          <button class="btn-nav btn-nav-prev" @click="previousMonth" :disabled="isLoading" aria-label="Previous month">
            <span class="btn-nav-icon">←</span>
            <span class="btn-nav-text">{{ t('tournamentPage.previous') }}</span>
          </button>
          <h2 class="calendar-month-title">
            {{ currentMonthName }} {{ currentYear }}
          </h2>
          <button class="btn-nav btn-nav-next" @click="nextMonth" :disabled="isLoading" aria-label="Next month">
            <span class="btn-nav-text">{{ t('tournamentPage.next') }}</span>
            <span class="btn-nav-icon">→</span>
          </button>
        </div>

        <!-- Calendar Grid -->
        <div class="calendar-grid">
          <!-- Weekday Headers -->
          <div class="calendar-weekday" v-for="day in weekdays" :key="day">
            {{ day }}
          </div>

          <!-- Calendar Days -->
          <div
            v-for="(day, index) in calendarDays"
            :key="index"
            class="calendar-day"
            :class="{
              'other-month': !day.isCurrentMonth,
              'today': day.isToday,
              'has-events': day.events && day.events.length > 0
            }"
            @click="openDayDetails(day)"
          >
            <div class="day-number">{{ day.date }}</div>
            <div class="day-events">
              <div
                v-for="event in day.events"
                :key="event.id"
                class="event-badge"
                :class="getEventBadgeClass(event)"
                @click.stop="openEventDetails(event)"
              >
                <span class="event-icon">{{ getEventIcon(event) }}</span>
                <span class="event-name">{{ getEventName(event) }}</span>
                <span class="event-count">👥 {{ getRegistrationCount(event.id) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Event Details Modal -->
    <div v-if="showEventModal && selectedEvent" class="modal" @click.self="closeEventModal">
      <div class="modal-content event-modal">
        <div class="modal-header">
          <div class="modal-header-content">
            <h2>
              <span class="event-icon-large">{{ getEventIcon(selectedEvent) }}</span>
              {{ selectedEvent.name }}
            </h2>
          </div>
          <button class="btn btn-secondary btn-sm btn-close-modal" @click="closeEventModal" aria-label="Close modal">{{ t('tournamentPage.close') }}</button>
        </div>
        <div class="modal-body">
          <div class="event-details">
            <div class="detail-item">
              <span class="detail-label">📅 {{ t('tournamentPage.date') }}</span>
              <span class="detail-value">{{ formatEventDate(selectedEvent.start_date) }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">⏰ {{ t('tournamentPage.time') }}</span>
              <span class="detail-value">{{ formatEventTime(selectedEvent.start_date) }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">💰 {{ t('tournamentPage.entryFee') }}</span>
              <span class="detail-value">${{ selectedEvent.entry_fee }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">👥 {{ t('tournamentPage.registered') }}</span>
              <span class="detail-value">
                {{ getRegistrationCount(selectedEvent.id) }}
                <span v-if="selectedEvent.min_players">
                  / {{ t('tournamentPage.minimum') }} {{ selectedEvent.min_players }}
                </span>
              </span>
            </div>
            <div class="detail-item">
              <span class="detail-label">📊 {{ t('tournamentPage.status') }}</span>
              <span class="detail-value badge" :class="getStatusBadgeClass(selectedEvent.status)">
                {{ formatStatus(selectedEvent.status) }}
              </span>
            </div>
            <div class="detail-item" v-if="selectedEvent.description">
              <span class="detail-label">📝 {{ t('tournamentPage.description') }}</span>
              <span class="detail-value">{{ selectedEvent.description }}</span>
            </div>

            <!-- Minimum Players Warning -->
            <div
              v-if="getRegistrationCount(selectedEvent.id) < (selectedEvent.min_players || 8)"
              class="alert alert-warning"
            >
              ⚠️ {{ t('tournamentPage.minimumWarning', { count: selectedEvent.min_players || 8 }) }}
            </div>
            <div
              v-else-if="selectedEvent.status !== 'completed'"
              class="alert alert-success"
            >
              ✅ {{ t('tournamentPage.confirmed', { count: selectedEvent.min_players || 8 }) }}
            </div>

            <!-- Join Tournament Button (for non-logged-in users) - Desktop & Mobile -->
            <div 
              v-if="!authStore.isAuthenticated && selectedEvent.status !== 'completed'"
              class="join-tournament-section"
            >
              <button
                class="btn btn-primary btn-lg btn-join-tournament"
                @click="goToLogin"
              >
                🎯 {{ t('tournamentPage.join') }}
              </button>
              <p class="join-tournament-note">{{ t('tournamentPage.loginNote') }}</p>
            </div>

            <!-- Participants List -->
            <div class="participants-section">
              <div class="participants-header">
                <h3>👥 {{ t('tournamentPage.participants', { count: participantsList.length }) }}</h3>
                <!-- Admin: Add Player Button -->
                <button
                  v-if="authStore.isAdmin && selectedEvent.status !== 'completed'"
                  class="btn btn-primary btn-sm"
                  @click="openAddPlayerModal"
                  title="Add player manually"
                >
                  ➕ {{ t('tournamentPage.addPlayer') }}
                </button>
              </div>
              <div v-if="loadingParticipants" class="text-center p-2">
                <div class="spinner-small"></div>
              </div>
              <div v-else-if="participantsList.length === 0" class="text-muted p-2">
                {{ t('tournamentPage.noParticipants') }}
              </div>
              <div v-else class="participants-list">
                <div
                  v-for="(participant, idx) in participantsList"
                  :key="participant.id"
                  class="participant-item"
                  :class="{ 'is-current-user': participant.user_id === currentUserId }"
                >
                  <span class="participant-number">{{ idx + 1 }}.</span>
                  <span class="participant-name">{{ participant.user?.name || t('tournamentPage.unknown') }}</span>
                  <span v-if="participant.user_id === currentUserId" class="badge badge-success">{{ t('tournamentPage.you') }}</span>
                  <!-- Admin: Remove Player Button -->
                  <button
                    v-if="authStore.isAdmin && selectedEvent.status !== 'completed'"
                    class="btn btn-danger btn-sm btn-remove-player"
                    @click="removePlayer(participant.user_id)"
                    title="Remove player"
                  >
                    🗑️
                  </button>
                </div>
              </div>
            </div>

            <!-- Registration Actions -->
            <div class="event-actions" v-if="authStore.isAuthenticated && !authStore.isAdmin">
              <button
                v-if="!isRegistered"
                class="btn btn-primary btn-lg"
                @click="registerForEvent"
                :disabled="isRegistering || selectedEvent.status === 'completed'"
              >
                {{ isRegistering ? t('tournamentPage.registering') : t('tournamentPage.register') }}
              </button>
              <button
                v-else
                class="btn btn-danger btn-lg"
                @click="cancelRegistration"
                :disabled="isCancelling || selectedEvent.status === 'completed'"
              >
                {{ isCancelling ? t('tournamentPage.cancelling') : t('tournamentPage.cancelRegistration') }}
              </button>
            </div>

            <!-- Admin Actions -->
            <div class="admin-actions" v-if="authStore.isAdmin">
              <button
                v-if="selectedEvent.status !== 'completed'"
                class="btn btn-success btn-lg"
                @click="completeTournament"
              >
                ✅ {{ t('tournamentPage.complete') }}
              </button>
              <button
                v-if="selectedEvent.status === 'completed' && participantsList.length > 0"
                class="btn btn-primary btn-lg"
                @click="openResultEntryModal"
              >
                📊 {{ t('tournamentPage.enterResults') }}
              </button>
              <button class="btn btn-secondary btn-lg" @click="editEvent">
                {{ t('tournamentPage.edit') }}
              </button>
              <button class="btn btn-danger btn-lg" @click="confirmDeleteEvent">
                {{ t('tournamentPage.delete') }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tournament Results Entry Modal (Admin Only) -->
    <div v-if="showResultEntryModal" class="modal" @click.self="closeResultEntryModal">
      <div class="modal-content modal-large" style="max-width: 900px; max-height: 90vh;">
        <div class="modal-header">
          <h2>📊 {{ t('tournamentPage.resultTitle', { name: selectedEvent?.name }) }}</h2>
          <button class="btn btn-secondary btn-sm btn-close-modal" @click="closeResultEntryModal" aria-label="Close modal">{{ t('tournamentPage.close') }}</button>
        </div>
        <div class="modal-body">
          <div class="alert alert-info" style="margin-bottom: 1.5rem;">
            <strong>📋 {{ t('tournamentPage.instructions') }}</strong>
            <ul style="margin: 0.5rem 0 0 1.5rem; padding: 0;">
              <li>{{ t('tournamentPage.instruction1') }}</li>
              <li>{{ t('tournamentPage.instruction2') }}</li>
              <li>{{ t('tournamentPage.instruction3') }}</li>
              <li>{{ t('tournamentPage.instruction4') }}</li>
            </ul>
          </div>

          <div class="tournament-results-form">
            <div
              v-for="(participant, index) in resultEntryList"
              :key="participant.user_id"
              class="result-entry-item"
            >
              <div class="result-entry-header">
                <span class="result-entry-number">{{ index + 1 }}</span>
                <span class="result-entry-name">{{ participant.user?.name || t('tournamentPage.unknown') }}</span>
              </div>
              
              <div class="result-entry-fields">
                <div class="form-group" style="flex: 1;">
                  <label class="form-label">{{ t('tournamentPage.finalRanking') }}</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model.number="participant.ranking"
                    min="1"
                    :max="resultEntryList.length"
                    placeholder="1, 2, 3..."
                    @input="updateResultEntry(participant)"
                  />
                  <small class="form-text">{{ t('tournamentPage.rankingHint') }}</small>
                </div>
                
                <div class="form-group" style="flex: 1;">
                  <label class="form-label">{{ t('tournamentPage.wins') }}</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model.number="participant.wins"
                    min="0"
                    placeholder="0"
                  />
                  <small class="form-text">{{ t('tournamentPage.winsHint') }}</small>
                </div>
                
                <div class="form-group" style="flex: 1;">
                  <label class="form-label">{{ t('tournamentPage.losses') }}</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model.number="participant.losses"
                    min="0"
                    placeholder="0"
                  />
                  <small class="form-text">{{ t('tournamentPage.lossesHint') }}</small>
                </div>
                
                <div class="form-group" style="flex: 1;">
                  <label class="form-label">{{ t('tournamentPage.breakRun') }}</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model.number="participant.break_and_run"
                    min="0"
                    placeholder="0"
                  />
                </div>
              </div>

              <div class="result-entry-preview" v-if="participant.ranking">
                <div class="preview-item">
                  <span class="preview-label">{{ t('tournamentPage.points') }}</span>
                  <span class="preview-value points-positive">+{{ getPointsForRanking(participant.ranking) }}</span>
                </div>
                <div class="preview-item">
                  <span class="preview-label">{{ t('profilePage.wins') }}：</span>
                  <span class="preview-value">{{ participant.wins || 0 }}</span>
                </div>
                <div class="preview-item">
                  <span class="preview-label">{{ t('profilePage.losses') }}：</span>
                  <span class="preview-value">{{ participant.losses || 0 }}</span>
                </div>
                <div class="preview-item" v-if="participant.break_and_run > 0">
                  <span class="preview-label">{{ t('profilePage.breakRun') }}：</span>
                  <span class="preview-value">+{{ participant.break_and_run }}</span>
                </div>
              </div>
            </div>
          </div>

          <div class="result-entry-summary" v-if="resultEntryList.some(p => p.ranking)">
            <h4>📊 {{ t('tournamentPage.summary') }}</h4>
            <div class="summary-stats">
              <div class="summary-item">
                <span class="summary-label">{{ t('tournamentPage.totalPlayers') }}</span>
                <span class="summary-value">{{ resultEntryList.length }}</span>
              </div>
              <div class="summary-item">
                <span class="summary-label">{{ t('tournamentPage.rankingsEntered') }}</span>
                <span class="summary-value">{{ resultEntryList.filter(p => p.ranking).length }}</span>
              </div>
              <div class="summary-item">
                <span class="summary-label">{{ t('tournamentPage.division') }}</span>
                <span class="summary-value badge" :class="selectedEvent?.participant_category === 'adult' ? 'badge-primary' : 'badge-success'">
                  {{ selectedEvent?.participant_category === 'adult' ? 'Pro' : 'Student' }}
                </span>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeResultEntryModal" :disabled="isSubmittingResults">
            {{ t('common.cancel') }}
          </button>
          <button
            class="btn btn-success btn-lg"
            @click="submitTournamentResults"
            :disabled="isSubmittingResults || !canSubmitResults"
          >
            <span v-if="isSubmittingResults">{{ t('tournamentPage.processing') }}</span>
            <span v-else>✅ {{ t('tournamentPage.submitResults') }}</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Add Player Modal (Admin Only) -->
    <div v-if="showAddPlayerModal" class="modal" @click.self="closeAddPlayerModal">
      <div class="modal-content" style="max-width: 600px; max-height: 80vh;">
        <div class="modal-header">
          <h2>➕ {{ t('tournamentPage.addPlayerTitle') }}</h2>
          <button class="btn btn-secondary btn-sm btn-close-modal" @click="closeAddPlayerModal" aria-label="Close modal">{{ t('tournamentPage.close') }}</button>
        </div>
        <div class="modal-body">
          <div v-if="loadingPlayers" class="text-center p-4">
            <div class="spinner"></div>
            <p>{{ t('tournamentPage.loadingPlayers') }}</p>
          </div>
          <div v-else>
            <div class="form-group">
              <label class="form-label">{{ t('tournamentPage.searchPlayer') }}</label>
              <input
                type="text"
                class="form-control"
                v-model="playerSearchQuery"
                :placeholder="t('tournamentPage.searchPlaceholder')"
              />
            </div>
            <div class="players-list" style="max-height: 400px; overflow-y: auto; margin-top: 1rem;">
              <div v-if="filteredPlayersList.length === 0" class="text-muted p-2 text-center">
                {{ t('tournamentPage.noPlayers') }}
              </div>
              <div
                v-for="player in filteredPlayersList"
                :key="player.id"
                class="player-select-item"
                :class="{ 'already-registered': isPlayerRegistered(player.id) }"
              >
                <div class="player-select-info">
                  <span class="player-select-name">{{ player.name }}</span>
                  <span v-if="isPlayerRegistered(player.id)" class="badge badge-warning">{{ t('tournamentPage.alreadyRegistered') }}</span>
                </div>
                <button
                  v-if="!isPlayerRegistered(player.id)"
                  class="btn btn-primary btn-sm"
                  @click.stop="addPlayerToEvent(player)"
                  :disabled="isAddingPlayer"
                >
                  {{ t('tournamentPage.add') }}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Create/Edit Event Modal -->
    <div v-if="showCreateModal || editingEvent" class="modal" @click.self="closeCreateModal">
      <div class="modal-content modal-large">
        <div class="modal-header">
          <h2>{{ editingEvent ? t('tournamentPage.editEvent') : t('tournamentPage.createEvent') }}</h2>
          <button class="btn btn-secondary btn-sm" @click="closeCreateModal">{{ t('tournamentPage.close') }}</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">{{ t('tournamentPage.eventName') }}</label>
            <input type="text" class="form-control" v-model="eventForm.name" required>
          </div>
          <div class="form-group">
            <label class="form-label">{{ t('tournamentPage.description') }}</label>
            <textarea class="form-control" v-model="eventForm.description" rows="3"></textarea>
          </div>
          <div class="row">
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">{{ t('tournamentPage.date') }} *</label>
                <input type="date" class="form-control" v-model="eventForm.date" required>
              </div>
            </div>
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">{{ t('tournamentPage.time') }} *</label>
                <input type="time" class="form-control" v-model="eventForm.time" required>
              </div>
            </div>
          </div>
          <div class="row">
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">{{ t('tournamentPage.eventType') }}</label>
                <select class="form-control" v-model="eventForm.event_type" required>
                  <option value="custom">{{ t('tournamentPage.customEvent') }}</option>
                  <option value="weekly_pro">{{ t('tournamentPage.weeklyPro') }}</option>
                  <option value="weekly_student">{{ t('tournamentPage.weeklyStudent') }}</option>
                </select>
              </div>
            </div>
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">{{ t('tournamentPage.category') }}</label>
                <select class="form-control" v-model="eventForm.participant_category" required>
                  <option value="adult">{{ t('tournamentPage.adultPro') }}</option>
                  <option value="student">{{ t('tournamentPage.student') }}</option>
                </select>
              </div>
            </div>
          </div>
          <div class="row">
            <div class="col col-3">
              <div class="form-group">
                <label class="form-label">{{ t('tournamentPage.entryFee') }} ($)</label>
                <input type="number" class="form-control" v-model="eventForm.entry_fee" min="0" step="0.01">
              </div>
            </div>
            <div class="col col-3">
              <div class="form-group">
                <label class="form-label">{{ t('tournamentPage.minPlayers') }}</label>
                <input type="number" class="form-control" v-model="eventForm.min_players" min="1" value="8">
              </div>
            </div>
            <div class="col col-3">
              <div class="form-group">
                <label class="form-label">{{ t('tournamentPage.maxPlayers') }}</label>
                <input type="number" class="form-control" v-model="eventForm.max_players" min="1">
              </div>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">{{ t('tournamentPage.status') }} *</label>
            <select class="form-control" v-model="eventForm.status" required>
              <option value="upcoming">{{ t('tournamentPage.statuses.upcoming') }}</option>
              <option value="registration">{{ t('tournamentPage.statuses.registration') }}</option>
              <option value="in_progress">{{ t('tournamentPage.statuses.in_progress') }}</option>
              <option value="completed">{{ t('tournamentPage.statuses.completed') }}</option>
              <option value="cancelled">{{ t('tournamentPage.statuses.cancelled') }}</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button 
            class="btn btn-secondary" 
            @click="closeCreateModal"
            :disabled="isSavingEvent"
            type="button"
          >
            {{ t('common.cancel') }}
          </button>
          <button 
            class="btn btn-success" 
            @click="saveEvent"
            :disabled="isSavingEvent"
            type="button"
          >
            <span v-if="isSavingEvent" class="spinner-small"></span>
            <span v-else>{{ editingEvent ? t('tournamentPage.update') : t('tournamentPage.create') }}</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Complete Tournament Confirmation Modal -->
    <div v-if="showCompleteModal" class="modal" @click.self="showCompleteModal = false">
      <div class="modal-content">
        <div class="modal-header">
          <h2>✅ {{ t('tournamentPage.completeTitle') }}</h2>
        </div>
        <div class="modal-body">
          <p>{{ t('tournamentPage.completeQuestion') }}</p>
          <div class="complete-details">
            <p><strong>{{ t('tournamentPage.tournament') }}</strong> {{ selectedEvent?.name }}</p>
            <p><strong>{{ t('tournamentPage.date') }}</strong> {{ selectedEvent ? formatEventDate(selectedEvent.start_date) : '' }}</p>
            <p><strong>{{ t('tournamentPage.participantsLabel') }}</strong> {{ getRegistrationCount(selectedEvent?.id) }}</p>
          </div>
          <div class="alert alert-warning">
            ⚠️ {{ t('tournamentPage.completeWarning') }}
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showCompleteModal = false">{{ t('common.cancel') }}</button>
          <button class="btn btn-success" @click="confirmCompleteTournament">{{ t('tournamentPage.confirmComplete') }}</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useTournamentStore } from '../stores/tournamentStore'
import { useAuthStore } from '../stores/authStore'
import { usePlayerStore } from '../stores/playerStore'
import { formatNZDate } from '../utils/timezone'
import { supabase } from '../config/supabase'
import { useI18n } from '../i18n'

export default {
  name: 'TournamentsPage',
  setup() {
    const router = useRouter()
    const tournamentStore = useTournamentStore()
    const authStore = useAuthStore()
    const playerStore = usePlayerStore()
    const { t, list, isZh } = useI18n()
    
    // Calendar state
    const currentMonth = ref(new Date().getMonth())
    const currentYear = ref(new Date().getFullYear())
    const isLoading = ref(false)
    
    // Modal state
    const showEventModal = ref(false)
    const showCreateModal = ref(false)
    const showCompleteModal = ref(false)
    const selectedEvent = ref(null)
    const editingEvent = ref(null)
    const participantsList = ref([])
    const loadingParticipants = ref(false)
    const currentUserId = ref(null)
    
    // Registration state
    const isRegistered = ref(false)
    const isRegistering = ref(false)
    const isCancelling = ref(false)
    const registrationCounts = ref({})
    
    // Add Player Modal (Admin)
    const showAddPlayerModal = ref(false)
    const allPlayers = ref([])
    const loadingPlayers = ref(false)
    const playerSearchQuery = ref('')
    const isAddingPlayer = ref(false)
    
    // Tournament Results Entry Modal (Admin)
    const showResultEntryModal = ref(false)
    const resultEntryList = ref([])
    const isSubmittingResults = ref(false)
    
    // Event form saving state
    const isSavingEvent = ref(false)
    
    // Event form
    const eventForm = ref({
      name: '',
      description: '',
      date: '',
      time: '',
      event_type: 'custom',
      participant_category: 'adult',
      entry_fee: 20,
      min_players: 8,
      max_players: null,
      status: 'registration'
    })

    // Weekdays
    const weekdays = computed(() => list('tournamentPage.weekdays'))

    // Computed: Current month name
    const currentMonthName = computed(() => {
      const date = new Date(currentYear.value, currentMonth.value, 1)
      return date.toLocaleDateString(isZh.value ? 'zh-CN' : 'en-US', { month: 'long' })
    })

    // Computed: Calendar days
    const calendarDays = computed(() => {
      const days = []
      const firstDay = new Date(currentYear.value, currentMonth.value, 1)
      const lastDay = new Date(currentYear.value, currentMonth.value + 1, 0)
      const startDate = new Date(firstDay)
      startDate.setDate(startDate.getDate() - startDate.getDay()) // Start from Sunday
      
      const endDate = new Date(lastDay)
      endDate.setDate(endDate.getDate() + (6 - endDate.getDay())) // End on Saturday
      
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      
      for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
        const dayDate = new Date(d)
        dayDate.setHours(0, 0, 0, 0)
        const isCurrentMonth = d.getMonth() === currentMonth.value
        const isToday = dayDate.getTime() === today.getTime()
        
        // Get events for this day
        const dayEvents = tournamentStore.tournaments.filter(t => {
          if (!t.start_date) return false
          const eventDate = new Date(t.start_date)
          eventDate.setHours(0, 0, 0, 0)
          return eventDate.getTime() === dayDate.getTime()
        })
        
        days.push({
          date: d.getDate(),
          fullDate: new Date(d),
          isCurrentMonth,
          isToday,
          events: dayEvents
        })
      }
      
      return days
    })

    // Load current user ID
    const loadCurrentUserId = async () => {
      if (authStore.isAuthenticated) {
        const { data: { user } } = await supabase.auth.getUser()
        if (user) {
          const { data: userData } = await supabase
            .from('users')
            .select('id')
            .eq('auth_id', user.id)
            .single()
          if (userData) {
            currentUserId.value = userData.id
          }
        }
      }
    }

    // Load registration counts
    const loadRegistrationCounts = async () => {
      try {
        const { data, error } = await supabase
          .from('tournament_registrations')
          .select('tournament_id')
          .eq('status', 'registered')

        if (error) throw error

        const counts = {}
        data.forEach(reg => {
          counts[reg.tournament_id] = (counts[reg.tournament_id] || 0) + 1
        })

        registrationCounts.value = counts
      } catch (err) {
        console.error('Error loading registration counts:', err)
      }
    }

    // Get registration count
    const getRegistrationCount = (tournamentId) => {
      if (!tournamentId) return 0
      return registrationCounts.value[tournamentId] || 0
    }

    // Get event icon
    const getEventIcon = (event) => {
      if (!event) return '🏆'
      if (event.event_type === 'weekly_pro') return '🏆'
      if (event.event_type === 'weekly_student') return '🎓'
      return '🎉'
    }

    // Get event name
    const getEventName = (event) => {
      if (!event) return ''
      if (event.event_type === 'weekly_pro') return t('tournamentPage.weekly')
      if (event.event_type === 'weekly_student') return t('tournamentPage.student')
      return event.name.length > 10 ? event.name.substring(0, 10) + '...' : event.name
    }

    // Get event badge class
    const getEventBadgeClass = (event) => {
      if (!event) return ''
      if (event.status === 'completed') return 'event-completed'
      if (event.event_type === 'weekly_pro') return 'event-pro'
      if (event.event_type === 'weekly_student') return 'event-student'
      return 'event-custom'
    }

    // Format event date (only date, no time) - correctly handle NZ timezone
    const formatEventDate = (dateString) => {
      if (!dateString) return 'N/A'
      const d = new Date(dateString)
      return new Intl.DateTimeFormat(isZh.value ? 'zh-CN' : 'en-NZ', {
        timeZone: 'Pacific/Auckland',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      }).format(d)
    }

    // Format event time (only time, no date) - correctly handle NZ timezone
    const formatEventTime = (dateString) => {
      if (!dateString) return 'N/A'
      const d = new Date(dateString)
      return new Intl.DateTimeFormat(isZh.value ? 'zh-CN' : 'en-NZ', {
        timeZone: 'Pacific/Auckland',
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
      }).format(d)
    }

    // Format status
    const formatStatus = (status) => {
      return t(`tournamentPage.statuses.${status}`)
    }

    // Get status badge class
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

    // Navigation
    const previousMonth = () => {
      if (currentMonth.value === 0) {
        currentMonth.value = 11
        currentYear.value--
      } else {
        currentMonth.value--
      }
    }

    const nextMonth = () => {
      if (currentMonth.value === 11) {
        currentMonth.value = 0
        currentYear.value++
      } else {
        currentMonth.value++
      }
    }

    // Open day details
    const openDayDetails = (day) => {
      if (day.events && day.events.length > 0) {
        if (day.events.length === 1) {
          openEventDetails(day.events[0])
        } else {
          // Multiple events - show list or first one
          openEventDetails(day.events[0])
        }
      }
    }

    // Open event details
    const openEventDetails = async (event) => {
      selectedEvent.value = event
      showEventModal.value = true
      loadingParticipants.value = true
      
      // Load participants - Use public_users view for security (no email/phone exposure)
      try {
        const { data, error } = await supabase
          .from('tournament_registrations')
          .select(`
            id,
            user_id,
            user:public_users!tournament_registrations_user_id_fkey(id, name)
          `)
          .eq('tournament_id', event.id)
          .eq('status', 'registered')

        if (error) throw error
        participantsList.value = data || []
      } catch (err) {
        console.error('Error loading participants:', err)
        participantsList.value = []
      } finally {
        loadingParticipants.value = false
      }

      // Check if current user is registered
      if (currentUserId.value) {
        isRegistered.value = participantsList.value.some(p => p.user_id === currentUserId.value)
      }
    }

    // Close event modal
    const closeEventModal = () => {
      showEventModal.value = false
      selectedEvent.value = null
      participantsList.value = []
      isRegistered.value = false
    }

    // Register for event
    const registerForEvent = async () => {
      if (!authStore.isAuthenticated) {
        alert('Please login to register')
        return
      }

      if (!currentUserId.value) {
        await loadCurrentUserId()
      }

      if (!currentUserId.value) {
        alert('Unable to get user information')
        return
      }

      isRegistering.value = true
      try {
        const { error } = await supabase
          .from('tournament_registrations')
          .insert([{
            tournament_id: selectedEvent.value.id,
            user_id: currentUserId.value,
            status: 'registered'
          }])

        if (error) throw error

        // Update local state
        isRegistered.value = true
        registrationCounts.value[selectedEvent.value.id] = (registrationCounts.value[selectedEvent.value.id] || 0) + 1
        // Get user name from public_users view for security
        const { data: userData } = await supabase
          .from('public_users')
          .select('name')
          .eq('id', currentUserId.value)
          .single()
        
        participantsList.value.push({
          id: Date.now(),
          user_id: currentUserId.value,
          user: { name: userData?.name || authStore.userName || 'You' }
        })

        alert('Successfully registered!')
      } catch (err) {
        console.error('Error registering:', err)
        alert('Error: ' + err.message)
      } finally {
        isRegistering.value = false
      }
    }

    // Cancel registration
    const cancelRegistration = async () => {
      if (!currentUserId.value) {
        await loadCurrentUserId()
      }

      isCancelling.value = true
      try {
        const { error } = await supabase
          .from('tournament_registrations')
          .delete()
          .eq('tournament_id', selectedEvent.value.id)
          .eq('user_id', currentUserId.value)

        if (error) throw error

        // Update local state
        isRegistered.value = false
        registrationCounts.value[selectedEvent.value.id] = Math.max(0, (registrationCounts.value[selectedEvent.value.id] || 0) - 1)
        participantsList.value = participantsList.value.filter(p => p.user_id !== currentUserId.value)

        alert('Registration cancelled')
      } catch (err) {
        console.error('Error cancelling:', err)
        alert('Error: ' + err.message)
      } finally {
        isCancelling.value = false
      }
    }

    // Complete tournament
    const completeTournament = () => {
      showCompleteModal.value = true
    }

    // Confirm complete tournament
    const confirmCompleteTournament = async () => {
      try {
        const result = await tournamentStore.updateTournament(selectedEvent.value.id, {
          status: 'completed',
          end_date: new Date().toISOString()
        })

        if (result.success) {
          selectedEvent.value.status = 'completed'
          showCompleteModal.value = false
          alert('Tournament marked as completed!')
          await tournamentStore.fetchTournaments()
        } else {
          alert('Error: ' + result.error)
        }
      } catch (err) {
        console.error('Error completing tournament:', err)
        alert('Error: ' + err.message)
      }
    }

    // Edit event
    const editEvent = () => {
      editingEvent.value = selectedEvent.value
      const startDate = new Date(selectedEvent.value.start_date)
      eventForm.value = {
        name: selectedEvent.value.name,
        description: selectedEvent.value.description || '',
        date: startDate.toISOString().split('T')[0],
        time: startDate.toTimeString().slice(0, 5),
        event_type: selectedEvent.value.event_type || 'custom',
        participant_category: selectedEvent.value.participant_category || 'adult',
        entry_fee: selectedEvent.value.entry_fee || 20,
        min_players: selectedEvent.value.min_players || 8,
        max_players: selectedEvent.value.max_players || null,
        status: selectedEvent.value.status
      }
      closeEventModal()
      showCreateModal.value = true
    }

    // Delete event
    const confirmDeleteEvent = async () => {
      if (confirm(`Are you sure you want to delete "${selectedEvent.value.name}"?`)) {
        const result = await tournamentStore.deleteTournament(selectedEvent.value.id)
        if (result.success) {
          closeEventModal()
          await tournamentStore.fetchTournaments()
          await loadRegistrationCounts()
        } else {
          alert('Error: ' + result.error)
        }
      }
    }

    // Save event
    const saveEvent = async () => {
      // Prevent double submission
      if (isSavingEvent.value) {
        console.log('Already saving event, please wait...')
        return
      }

      // Validate required fields
      if (!eventForm.value.name || !eventForm.value.date || !eventForm.value.time) {
        alert('Please fill in all required fields (Name, Date, Time)')
        return
      }

      isSavingEvent.value = true
      console.log('Saving event...', eventForm.value)

      try {
        const startDateTime = new Date(`${eventForm.value.date}T${eventForm.value.time}`)
        
        // Validate date
        if (isNaN(startDateTime.getTime())) {
          throw new Error('Invalid date or time format')
        }

        // Build data object with fields that exist in database schema
        // Database tournaments table has: id, name, description, tournament_type, start_date, 
        // end_date, max_players, min_players, entry_fee, prize_pool, status, created_at, updated_at
        const data = {
          name: eventForm.value.name,
          description: eventForm.value.description || '',
          tournament_type: 'single_elimination',
          start_date: startDateTime.toISOString(),
          entry_fee: parseFloat(eventForm.value.entry_fee) || 20,
          max_players: eventForm.value.max_players ? parseInt(eventForm.value.max_players) : null,
          min_players: eventForm.value.min_players ? parseInt(eventForm.value.min_players) : 8,
          status: eventForm.value.status || 'registration',
          event_type: eventForm.value.event_type || 'custom',
          participant_category: eventForm.value.participant_category || 'adult'
        }
        
        // Optional: prize_pool (can be added later)
        // data.prize_pool = 0

        console.log('[TournamentsPage] Event data to save:', JSON.stringify(data, null, 2))

        // Check if user is admin before creating
        console.log('[TournamentsPage] Current user:', {
          isAuthenticated: authStore.isAuthenticated,
          isAdmin: authStore.isAdmin,
          userRole: authStore.userRole,
          userId: authStore.user?.id
        })
        
        if (!authStore.isAdmin) {
          alert('Only administrators can create tournaments')
          return
        }
        
        let result
        if (editingEvent.value) {
          console.log('[TournamentsPage] Updating tournament:', editingEvent.value.id)
          result = await tournamentStore.updateTournament(editingEvent.value.id, data)
        } else {
          console.log('[TournamentsPage] Creating new tournament, calling store...')
          const startTime = Date.now()
          result = await tournamentStore.createTournament(data)
          const duration = Date.now() - startTime
          console.log(`[TournamentsPage] Tournament creation took ${duration}ms`)
        }

        console.log('[TournamentsPage] Save result:', result)

        if (result && result.success) {
          closeCreateModal()
          await tournamentStore.fetchTournaments()
          await loadRegistrationCounts()
          console.log('✅ Event saved successfully')
        } else {
          const errorMsg = result?.error || 'Unknown error occurred'
          console.error('❌ Error saving event:', errorMsg)
          alert('Error saving event: ' + errorMsg)
        }
      } catch (err) {
        console.error('❌ Exception in saveEvent:', err)
        alert('Error: ' + (err.message || 'Failed to save event. Please try again.'))
      } finally {
        isSavingEvent.value = false
      }
    }

    // Close create modal
    const closeCreateModal = () => {
      showCreateModal.value = false
      editingEvent.value = null
      eventForm.value = {
        name: '',
        description: '',
        date: '',
        time: '',
        event_type: 'custom',
        participant_category: 'adult',
        entry_fee: 20,
        min_players: 8,
        max_players: null,
        status: 'registration'
      }
    }

    // Go to login page
    const goToLogin = () => {
      closeEventModal()
      router.push('/login')
    }

    // Filtered players list for add player modal
    const filteredPlayersList = computed(() => {
      if (!playerSearchQuery.value.trim()) {
        return allPlayers.value || []
      }
      const query = playerSearchQuery.value.toLowerCase()
      return (allPlayers.value || []).filter(player => 
        player.name?.toLowerCase().includes(query)
      )
    })

    // Check if player is already registered
    const isPlayerRegistered = (playerId) => {
      return participantsList.value.some(p => p.user_id === playerId)
    }

    // Open add player modal
    const openAddPlayerModal = async () => {
      if (!authStore.isAdmin) return
      
      showAddPlayerModal.value = true
      loadingPlayers.value = true
      playerSearchQuery.value = ''
      
      try {
        // Fetch all players using admin RPC (includes all user data)
        await playerStore.fetchPlayers(true) // useAdminRPC = true
        allPlayers.value = playerStore.players || []
      } catch (err) {
        console.error('Error loading players:', err)
        alert('Error loading players: ' + err.message)
        allPlayers.value = []
      } finally {
        loadingPlayers.value = false
      }
    }

    // Close add player modal
    const closeAddPlayerModal = () => {
      showAddPlayerModal.value = false
      playerSearchQuery.value = ''
    }

    // Add player to event (Admin only)
    const addPlayerToEvent = async (player) => {
      if (!authStore.isAdmin || !selectedEvent.value) return
      
      if (isPlayerRegistered(player.id)) {
        alert('This player is already registered for this tournament')
        return
      }

      isAddingPlayer.value = true
      try {
        const { error } = await supabase
          .from('tournament_registrations')
          .insert([{
            tournament_id: selectedEvent.value.id,
            user_id: player.id,
            status: 'registered'
          }])

        if (error) throw error

        // Update local state
        participantsList.value.push({
          id: Date.now(),
          user_id: player.id,
          user: { name: player.name || 'Unknown' }
        })
        
        registrationCounts.value[selectedEvent.value.id] = (registrationCounts.value[selectedEvent.value.id] || 0) + 1

        alert(`✅ Successfully added ${player.name} to the tournament!`)
      } catch (err) {
        console.error('Error adding player:', err)
        alert('Error: ' + err.message)
      } finally {
        isAddingPlayer.value = false
      }
    }

    // Remove player from event (Admin only)
    const removePlayer = async (userId) => {
      if (!authStore.isAdmin || !selectedEvent.value) return
      
      const player = participantsList.value.find(p => p.user_id === userId)
      const playerName = player?.user?.name || 'this player'
      
      if (!confirm(`Are you sure you want to remove ${playerName} from this tournament?`)) {
        return
      }

      try {
        const { error } = await supabase
          .from('tournament_registrations')
          .delete()
          .eq('tournament_id', selectedEvent.value.id)
          .eq('user_id', userId)

        if (error) throw error

        // Update local state
        participantsList.value = participantsList.value.filter(p => p.user_id !== userId)
        registrationCounts.value[selectedEvent.value.id] = Math.max(0, (registrationCounts.value[selectedEvent.value.id] || 0) - 1)

        alert(`✅ Successfully removed ${playerName} from the tournament`)
      } catch (err) {
        console.error('Error removing player:', err)
        alert('Error: ' + err.message)
      }
    }

    // Tournament Results Entry Functions
    // Points calculation based on ranking (from HEYBALL_RANKING_RULES.md)
    const getPointsForRanking = (ranking) => {
      if (!ranking || ranking < 1) return 0
      if (ranking === 1) return 20 // Champion
      if (ranking === 2) return 15 // Runner-up
      if (ranking >= 3 && ranking <= 4) return 10 // Top 4
      if (ranking >= 5 && ranking <= 8) return 6 // Top 8
      return 3 // Participation
    }

    // Calculate wins based on ranking (simplified for weekly tournaments)
    const getWinsForRanking = (ranking, totalPlayers) => {
      if (!ranking || ranking < 1) return 0
      // For weekly tournaments, we use a simplified approach:
      // Top players get more wins, lower players get fewer
      if (ranking === 1) return 3 // Champion typically wins 3+ matches
      if (ranking === 2) return 2 // Runner-up typically wins 2 matches
      if (ranking >= 3 && ranking <= 4) return 1 // Top 4 typically wins 1 match
      // Others: 0 wins (lost in first round)
      return 0
    }

    // Calculate losses based on ranking
    const getLossesForRanking = (ranking, totalPlayers) => {
      if (!ranking || ranking < 1) return 0
      // Champion has no losses
      if (ranking === 1) return 0
      // All others have at least 1 loss (the match they lost)
      return 1
    }

    // Open result entry modal
    const openResultEntryModal = () => {
      if (!authStore.isAdmin || !selectedEvent.value || selectedEvent.value.status !== 'completed') return
      
      // Initialize result entry list from participants
      resultEntryList.value = participantsList.value.map(p => ({
        user_id: p.user_id,
        user: p.user,
        ranking: null,
        break_and_run: 0,
        points: 0,
        wins: null,
        losses: null
      }))
      
      showResultEntryModal.value = true
    }

    // Close result entry modal
    const closeResultEntryModal = () => {
      showResultEntryModal.value = false
      resultEntryList.value = []
    }

    // Update result entry when ranking changes
    const updateResultEntry = (participant) => {
      if (participant.ranking) {
        participant.points = getPointsForRanking(participant.ranking)
        // Wins and losses are now manually entered, so we don't auto-calculate them
      }
    }

    // Check if can submit results
    const canSubmitResults = computed(() => {
      if (!resultEntryList.value.length) return false
      // Check if all participants have rankings, wins, and losses
      return resultEntryList.value.every(p => 
        p.ranking && p.ranking >= 1 &&
        (p.wins !== null && p.wins !== undefined && p.wins >= 0) &&
        (p.losses !== null && p.losses !== undefined && p.losses >= 0)
      )
    })

    // Submit tournament results
    const submitTournamentResults = async () => {
      if (!authStore.isAdmin || !selectedEvent.value) return
      
      if (!canSubmitResults.value) {
        alert('Please enter rankings for all participants')
        return
      }

      // Validate rankings are unique
      const rankings = resultEntryList.value.map(p => p.ranking).filter(r => r)
      const uniqueRankings = new Set(rankings)
      if (rankings.length !== uniqueRankings.size) {
        alert('⚠️ Rankings must be unique! Please check for duplicate rankings.')
        return
      }

      /** Load canonical start_date before confirm so month on leaderboard matches NZ calendar of the event */
      let awardAt = null
      try {
        const { data: tRow, error: tErr } = await supabase
          .from('tournaments')
          .select('start_date')
          .eq('id', selectedEvent.value.id)
          .single()
        if (tErr) throw tErr
        awardAt = tRow?.start_date || null
      } catch (e) {
        console.error('Could not load tournament start_date:', e)
        alert('无法读取比赛开赛时间，请刷新页面后重试。')
        return
      }
      if (!awardAt) {
        alert('该比赛在数据库中没有 start_date，无法记入正确月份。请先在比赛详情里编辑并保存日期，再提交成绩。')
        return
      }

      const nzAwardLabel = new Intl.DateTimeFormat('en-NZ', {
        timeZone: 'Pacific/Auckland',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      }).format(new Date(awardAt))

      const confirmMsg = `Submit tournament results for "${selectedEvent.value.name}"?\n\n` +
        `Points will count toward leaderboard month (NZ): ${nzAwardLabel}\n\n` +
        `This will:\n` +
        `- Add points to ${resultEntryList.value.length} players\n` +
        `- Update wins/losses statistics\n` +
        `- Record Break & Run counts\n\n` +
        `Division: ${selectedEvent.value.participant_category === 'adult' ? 'Pro' : 'Student'}\n\n` +
        `Continue?`

      if (!confirm(confirmMsg)) return

      isSubmittingResults.value = true

      const division = selectedEvent.value.participant_category === 'adult' ? 'pro' : 'student'
      const tournamentName = selectedEvent.value.name
      /** DB prefixes "Pro: " / "Student: " — omit duplicate prefix in p_reason */
      const pointsReasonBody = `${tournamentName} - Rank `
      let successCount = 0
      let errorCount = 0
      const errors = []

      try {
        // Process each participant with timeout protection
        for (let i = 0; i < resultEntryList.value.length; i++) {
          const participant = resultEntryList.value[i]
          const participantName = participant.user?.name || `Player ${i + 1}`
          
          try {
            console.log(`Processing ${participantName} (${i + 1}/${resultEntryList.value.length})...`)
            
            const points = getPointsForRanking(participant.ranking)
            const wins = participant.wins || 0
            const losses = participant.losses || 0
            const breakAndRun = participant.break_and_run || 0

            // Add points with timeout (p_award_at = tournament start → correct month on leaderboard)
            const pointsFunction = division === 'pro' ? 'admin_add_pro_points' : 'admin_add_student_points'
            const reasonForPoints = `${pointsReasonBody}${participant.ranking}`

            const pointsPromise = supabase.rpc(pointsFunction, {
              p_user_id: participant.user_id,
              p_points_change: points,
              p_reason: reasonForPoints,
              p_award_at: awardAt
            })

            const pointsTimeout = new Promise((_, reject) => 
              setTimeout(() => reject(new Error('Points update timeout (30s)')), 30000)
            )

            const { error: pointsError } = await Promise.race([pointsPromise, pointsTimeout])

            if (pointsError) {
              console.error(`Points error for ${participantName}:`, pointsError)
              throw new Error(`Points: ${pointsError.message || JSON.stringify(pointsError)}`)
            }

            console.log(`✅ Points added for ${participantName}`)

            // Update stats (wins, losses, break_and_run) with timeout
            const statsPromise = supabase.rpc('admin_update_division_stats', {
              p_user_id: participant.user_id,
              p_division: division,
              p_mode: 'increment',
              p_wins: wins,
              p_losses: losses,
              p_break_and_run: breakAndRun,
              p_reason: `${division === 'pro' ? 'Pro:' : 'Student:'} ${tournamentName} - Rank ${participant.ranking}`,
              p_award_at: awardAt
            })

            const statsTimeout = new Promise((_, reject) => 
              setTimeout(() => reject(new Error('Stats update timeout (30s)')), 30000)
            )

            const { error: statsError } = await Promise.race([statsPromise, statsTimeout])

            if (statsError) {
              console.error(`Stats error for ${participantName}:`, statsError)
              throw new Error(`Stats: ${statsError.message || JSON.stringify(statsError)}`)
            }

            console.log(`✅ Stats updated for ${participantName}`)
            successCount++
          } catch (err) {
            errorCount++
            const errorMsg = err.message || String(err)
            errors.push(`${participantName}: ${errorMsg}`)
            console.error(`❌ Error processing ${participantName}:`, err)
          }
        }

        // Show results
        console.log(`Results submission complete: ${successCount} success, ${errorCount} errors`)
        
        if (errorCount === 0) {
          alert(`✅ Successfully updated results for all ${successCount} players!`)
          closeResultEntryModal()
          // Refresh participants list to show updated data
          if (selectedEvent.value) {
            await openEventDetails(selectedEvent.value)
          }
        } else {
          const errorSummary = errors.slice(0, 5).join('\n')
          const moreErrors = errors.length > 5 ? `\n... and ${errors.length - 5} more errors` : ''
          alert(`⚠️ Updated ${successCount} players successfully.\n\nErrors (${errorCount}):\n${errorSummary}${moreErrors}\n\nCheck console for full details.`)
        }
      } catch (err) {
        console.error('❌ Fatal error submitting results:', err)
        const errorMsg = err.message || String(err) || 'Unknown error'
        alert(`❌ Error submitting results: ${errorMsg}\n\nCheck console for details.`)
      } finally {
        // Always reset loading state, even on error
        isSubmittingResults.value = false
        console.log('Submission process ended, loading state reset')
      }
    }

    // Initialize
    onMounted(async () => {
      isLoading.value = true
      await loadCurrentUserId()
      await tournamentStore.fetchTournaments()
      await loadRegistrationCounts()
      
      // Note: Weekly tournaments are generated automatically by the database function
      // when needed. We don't need to call it on every page load.
      // If you need to regenerate tournaments, call generate_weekly_tournaments() manually.
      
      isLoading.value = false
    })

    return {
      tournamentStore,
      t,
      isZh,
      authStore,
      currentMonth,
      currentYear,
      currentMonthName,
      calendarDays,
      weekdays,
      isLoading,
      showEventModal,
      showCreateModal,
      showCompleteModal,
      selectedEvent,
      editingEvent,
      participantsList,
      loadingParticipants,
      currentUserId,
      isRegistered,
      isRegistering,
      isCancelling,
      registrationCounts,
      eventForm,
      isSavingEvent,
      getRegistrationCount,
      getEventIcon,
      getEventName,
      getEventBadgeClass,
      formatEventDate,
      formatEventTime,
      formatStatus,
      getStatusBadgeClass,
      previousMonth,
      nextMonth,
      openDayDetails,
      openEventDetails,
      closeEventModal,
      registerForEvent,
      cancelRegistration,
      completeTournament,
      confirmCompleteTournament,
      editEvent,
      confirmDeleteEvent,
      saveEvent,
      closeCreateModal,
      goToLogin,
      showAddPlayerModal,
      allPlayers,
      loadingPlayers,
      playerSearchQuery,
      isAddingPlayer,
      openAddPlayerModal,
      closeAddPlayerModal,
      filteredPlayersList,
      isPlayerRegistered,
      addPlayerToEvent,
      removePlayer,
      showResultEntryModal,
      resultEntryList,
      isSubmittingResults,
      openResultEntryModal,
      closeResultEntryModal,
      getPointsForRanking,
      getWinsForRanking,
      getLossesForRanking,
      updateResultEntry,
      canSubmitResults,
      submitTournamentResults
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

/* Hero Section */
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
    radial-gradient(circle at 75% 65%, rgba(78, 205, 196, 0.1) 0%, transparent 50%);
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
}

.hero-title {
  font-size: 3.5rem;
  font-weight: 800;
  color: white;
  margin-bottom: 1rem;
  line-height: 1.2;
}

.title-highlight {
  background: linear-gradient(135deg, #FFD700 0%, #4ECDC4 50%, #FF6B6B 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero-subtitle {
  font-size: 1.25rem;
  color: rgba(255, 255, 255, 0.9);
  margin-bottom: 2rem;
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
}

.btn-hero-primary {
  background: linear-gradient(135deg, #4ECDC4 0%, #45B7AF 100%);
  color: white;
  box-shadow: 0 6px 20px rgba(78, 205, 196, 0.4);
}

.btn-hero-primary:hover {
  transform: translateY(-3px) scale(1.05);
  box-shadow: 0 8px 30px rgba(78, 205, 196, 0.6);
}

/* Calendar Container */
.tournaments-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 2rem 3rem;
}

.calendar-container {
  background: white;
  border-radius: 20px;
  padding: 2rem;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.btn-nav {
  padding: 0.75rem 1.5rem;
  background: linear-gradient(135deg, #9C27B0 0%, #673AB7 100%);
  color: white;
  border: none;
  border-radius: 50px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-nav-icon {
  font-size: 1.125rem;
}

.btn-nav-text {
  font-size: 0.875rem;
}

.btn-nav:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(156, 39, 176, 0.4);
}

.btn-nav:active:not(:disabled) {
  transform: translateY(0);
}

.btn-nav:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.calendar-month-title {
  font-size: 2rem;
  font-weight: 700;
  color: #1a1a2e;
}

/* Calendar Grid */
.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 1rem;
}

.calendar-weekday {
  text-align: center;
  font-weight: 700;
  color: #6c757d;
  padding: 1rem;
  font-size: 0.875rem;
  text-transform: uppercase;
}

.calendar-day {
  min-height: 120px;
  border: 2px solid #e9ecef;
  border-radius: 12px;
  padding: 0.75rem;
  cursor: pointer;
  transition: all 0.3s ease;
  background: white;
  position: relative;
}

.calendar-day:hover {
  border-color: #9C27B0;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(156, 39, 176, 0.2);
}

.calendar-day.other-month {
  opacity: 0.4;
  background: #f8f9fa;
}

.calendar-day.today {
  border-color: #4ECDC4;
  background: linear-gradient(135deg, rgba(78, 205, 196, 0.1) 0%, rgba(78, 205, 196, 0.05) 100%);
}

.calendar-day.has-events {
  border-color: #9C27B0;
}

.day-number {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1a1a2e;
  margin-bottom: 0.5rem;
}

.day-events {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.event-badge {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.375rem 0.5rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.event-badge:hover {
  transform: scale(1.05);
}

.event-pro {
  background: linear-gradient(135deg, #9C27B0 0%, #673AB7 100%);
  color: white;
}

.event-student {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
}

.event-custom {
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  color: white;
}

.event-completed {
  background: #6c757d;
  color: white;
  opacity: 0.7;
}

.event-icon {
  font-size: 0.875rem;
}

.event-name {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.event-count {
  font-size: 0.7rem;
  opacity: 0.9;
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
  align-items: center;
  justify-content: center;
  z-index: 2000;
  overflow-y: auto;
  padding: 20px;
  padding-bottom: calc(var(--mobile-nav-height, 80px) + 20px + env(safe-area-inset-bottom));
}

.modal-content {
  background: white;
  border-radius: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  max-width: 600px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-large {
  max-width: 800px;
}

.event-modal {
  max-width: 700px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 1.5rem;
  border-bottom: 2px solid #e9ecef;
  gap: 1rem;
}

.modal-header-content {
  flex: 1;
  min-width: 0; /* Allow text to wrap */
}

.modal-header h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.5rem;
  font-weight: 700;
  color: #1a1a2e;
  margin: 0;
  word-wrap: break-word;
  overflow-wrap: break-word;
}

.btn-close-modal {
  flex-shrink: 0;
  margin-left: auto;
}

.event-icon-large {
  font-size: 1.75rem;
}

.modal-body {
  padding: 1.5rem;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  padding: 1.5rem;
  border-top: 2px solid #e9ecef;
}

.event-details {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.detail-item {
  display: flex;
  gap: 1rem;
  padding: 0.75rem;
  background: #f8f9fa;
  border-radius: 8px;
}

.detail-label {
  font-weight: 600;
  color: #6c757d;
  min-width: 120px;
}

.detail-value {
  color: #1a1a2e;
  font-weight: 500;
}

.participants-section {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 2px solid #e9ecef;
}

.participants-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.participants-header h3 {
  margin: 0;
}

.participants-section h3 {
  font-size: 1.25rem;
  font-weight: 700;
  margin-bottom: 1rem;
  color: #1a1a2e;
}

.participants-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-height: 300px;
  overflow-y: auto;
}

.participant-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  background: #f8f9fa;
  border-radius: 8px;
  justify-content: space-between;
}

.btn-remove-player {
  margin-left: auto;
  padding: 0.25rem 0.5rem;
  min-width: auto;
}

.participant-item.is-current-user {
  background: linear-gradient(135deg, rgba(78, 205, 196, 0.1) 0%, rgba(78, 205, 196, 0.05) 100%);
  border: 2px solid #4ECDC4;
}

.participant-number {
  font-weight: 600;
  color: #6c757d;
  min-width: 24px;
}

.participant-name {
  flex: 1;
  font-weight: 500;
  color: #1a1a2e;
}

.event-actions,
.admin-actions {
  display: flex;
  gap: 1rem;
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 2px solid #e9ecef;
}

/* Join Tournament Section - Desktop & Mobile */
.join-tournament-section {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 2px solid #e9ecef;
  text-align: center;
}

.btn-join-tournament {
  width: 100%;
  max-width: 400px; /* Desktop: limit width for better appearance */
  margin: 0 auto; /* Center the button */
  background: linear-gradient(135deg, #9C27B0 0%, #673AB7 100%);
  color: white;
  font-weight: 700;
  padding: 1rem 2rem;
  font-size: 1.125rem;
  border-radius: 12px;
  transition: all 0.3s ease;
  cursor: pointer;
  border: none;
  display: block;
}

.btn-join-tournament:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(156, 39, 176, 0.4);
  background: linear-gradient(135deg, #8E24AA 0%, #5E35B1 100%);
}

.btn-join-tournament:active {
  transform: translateY(0);
}

.join-tournament-note {
  margin-top: 0.75rem;
  font-size: 0.875rem;
  color: #6c757d;
  text-align: center;
}

/* Add Player Modal Styles */
.players-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.player-select-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 1rem;
  background: #f8f9fa;
  border-radius: 8px;
  border: 2px solid transparent;
  cursor: pointer;
  transition: all 0.3s ease;
}

.player-select-item:hover:not(.already-registered) {
  background: #e9ecef;
  border-color: #9C27B0;
  transform: translateX(4px);
}

.player-select-item.already-registered {
  opacity: 0.6;
  cursor: not-allowed;
  background: #fff3cd;
}

.player-select-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex: 1;
}

.player-select-name {
  font-weight: 500;
  color: #1a1a2e;
  font-size: 1rem;
}

/* Mobile Optimization for Add Player Modal */
@media (max-width: 768px) {
  .player-select-item {
    padding: 1.25rem 1rem;
    flex-direction: row;
    align-items: center;
    gap: 1rem;
    min-height: 60px;
  }

  .player-select-info {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 0.25rem;
  }

  .player-select-name {
    font-size: 1.5rem !important;
    font-weight: 700 !important;
    color: #1a1a2e;
    line-height: 1.5;
    word-break: break-word;
    letter-spacing: 0.01em;
  }

  .player-select-item .btn {
    flex-shrink: 0;
    padding: 0.4rem 0.8rem;
    font-size: 0.8rem;
    min-width: 60px;
    min-height: 36px;
    font-weight: 600;
  }

  .player-select-item .btn-primary {
    margin: 0;
  }

  .players-list {
    gap: 0.75rem;
  }
}

/* Tournament Results Entry Styles */
.tournament-results-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  margin-top: 1rem;
}

.result-entry-item {
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 12px;
  border: 2px solid #e9ecef;
  transition: all 0.3s ease;
}

.result-entry-item:hover {
  border-color: #9C27B0;
  box-shadow: 0 4px 12px rgba(156, 39, 176, 0.1);
}

.result-entry-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
  padding-bottom: 0.75rem;
  border-bottom: 2px solid #dee2e6;
}

.result-entry-number {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, #9C27B0 0%, #673AB7 100%);
  color: white;
  border-radius: 50%;
  font-weight: 700;
  font-size: 0.875rem;
}

.result-entry-name {
  font-size: 1.125rem;
  font-weight: 600;
  color: #1a1a2e;
}

.result-entry-fields {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  margin-bottom: 1rem;
}

@media (max-width: 768px) {
  .result-entry-fields {
    grid-template-columns: 1fr;
  }
}

.result-entry-preview {
  display: flex;
  gap: 1.5rem;
  padding: 0.75rem;
  background: white;
  border-radius: 8px;
  border-left: 4px solid #9C27B0;
}

.preview-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.preview-label {
  font-size: 0.75rem;
  color: #6c757d;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.preview-value {
  font-size: 1.125rem;
  font-weight: 700;
  color: #1a1a2e;
}

.preview-value.points-positive {
  color: #28a745;
}

.result-entry-summary {
  margin-top: 2rem;
  padding: 1.5rem;
  background: linear-gradient(135deg, rgba(156, 39, 176, 0.1) 0%, rgba(102, 126, 234, 0.1) 100%);
  border-radius: 12px;
  border: 2px solid rgba(156, 39, 176, 0.2);
}

.result-entry-summary h4 {
  margin: 0 0 1rem 0;
  color: #1a1a2e;
  font-size: 1.25rem;
}

.summary-stats {
  display: flex;
  gap: 2rem;
  flex-wrap: wrap;
}

.summary-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.summary-label {
  font-size: 0.875rem;
  color: #6c757d;
  font-weight: 500;
}

.summary-value {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1a1a2e;
}

/* Mobile Responsive for Results Entry */
@media (max-width: 768px) {
  .result-entry-fields {
    flex-direction: column;
  }

  .result-entry-preview {
    flex-direction: column;
    gap: 0.75rem;
  }

  .summary-stats {
    flex-direction: column;
    gap: 1rem;
  }
}

.complete-details {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 8px;
  margin: 1rem 0;
}

.complete-details p {
  margin: 0.5rem 0;
  color: #1a1a2e;
}

/* Form Styles */
.form-group {
  margin-bottom: 1.5rem;
}

.form-label {
  display: block;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: #1a1a2e;
}

.form-control {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  font-size: 1rem;
  transition: all 0.3s ease;
}

.form-control:focus {
  outline: none;
  border-color: #9C27B0;
  box-shadow: 0 0 0 3px rgba(156, 39, 176, 0.1);
}

.row {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.col {
  flex: 1;
}

.col-2 {
  flex: 1;
}

.col-3 {
  flex: 1;
}

/* Loading & Spinner */
.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 4rem;
}

.spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #e9ecef;
  border-top-color: #9C27B0;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.spinner-small {
  width: 24px;
  height: 24px;
  border: 2px solid #e9ecef;
  border-top-color: #9C27B0;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Alert Styles */
.alert {
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 1rem;
}

.alert-warning {
  background: #fff3cd;
  border: 2px solid #ffc107;
  color: #856404;
}

.alert-success {
  background: #d4edda;
  border: 2px solid #28a745;
  color: #155724;
}

.alert-danger {
  background: #f8d7da;
  border: 2px solid #dc3545;
  color: #721c24;
}

.text-center {
  text-align: center;
}

.text-muted {
  color: #6c757d;
}

.p-2 {
  padding: 0.5rem;
}

.p-4 {
  padding: 1rem;
}

/* Badge Styles */
.badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 50px;
  font-size: 0.875rem;
  font-weight: 600;
}

.badge-secondary {
  background: #6c757d;
  color: white;
}

.badge-info {
  background: #17a2b8;
  color: white;
}

.badge-primary {
  background: #007bff;
  color: white;
}

.badge-success {
  background: #28a745;
  color: white;
}

.badge-danger {
  background: #dc3545;
  color: white;
}

/* Button Styles */
.btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-primary {
  background: linear-gradient(135deg, #9C27B0 0%, #673AB7 100%);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(156, 39, 176, 0.4);
}

.btn-secondary {
  background: #6c757d;
  color: white;
}

.btn-success {
  background: #28a745;
  color: white;
}

.btn-danger {
  background: #dc3545;
  color: white;
}

.btn-sm {
  padding: 0.5rem 1rem;
  font-size: 0.875rem;
}

.btn-lg {
  padding: 1rem 2rem;
  font-size: 1.125rem;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Responsive - Mobile Optimizations */
@media (max-width: 768px) {
  /* Hero Section Mobile */
  .tournaments-hero {
    padding: 3rem 1rem 2rem;
  }

  .hero-title {
    font-size: 2rem;
  }

  .hero-subtitle {
    font-size: 1rem;
  }

  .btn-hero {
    padding: 0.875rem 1.5rem;
    font-size: 1rem;
  }

  /* Calendar Container Mobile */
  .tournaments-content {
    padding: 0 1rem calc(var(--mobile-nav-height, 80px) + 2rem + env(safe-area-inset-bottom));
  }

  .calendar-container {
    padding: 1rem;
    border-radius: 16px;
  }

  /* Calendar Header Mobile */
  .calendar-header {
    flex-direction: column;
    gap: 1rem;
    margin-bottom: 1.5rem;
  }

  .calendar-month-title {
    font-size: 1.5rem;
    text-align: center;
  }

  .btn-nav {
    padding: 0.625rem 1.25rem;
    font-size: 0.875rem;
    width: 100%;
  }

  /* Calendar Grid Mobile */
  .calendar-grid {
    gap: 0.375rem;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    padding-bottom: 0.5rem;
  }

  .calendar-weekday {
    padding: 0.5rem 0.25rem;
    font-size: 0.75rem;
    min-width: 44px;
  }

  .calendar-day {
    min-height: 70px;
    padding: 0.5rem 0.25rem;
    min-width: 44px;
    border-radius: 8px;
  }

  .day-number {
    font-size: 1rem;
    margin-bottom: 0.25rem;
  }

  .day-events {
    gap: 0.25rem;
  }

  .event-badge {
    font-size: 0.6rem;
    padding: 0.25rem 0.3rem;
    border-radius: 4px;
    flex-direction: column;
    gap: 0.125rem;
    min-height: auto;
  }

  .event-icon {
    font-size: 0.75rem;
  }

  .event-name {
    display: none; /* Hide name on mobile, only show icon and count */
  }

  .event-count {
    font-size: 0.6rem;
  }

  /* Modal Mobile */
  .modal {
    padding: 10px;
    align-items: flex-start;
    padding-top: 20px;
  }

  .modal-content {
    max-width: 95vw;
    max-height: 90vh;
    margin: 0;
    border-radius: 16px;
  }

  .event-modal {
    max-width: 95vw;
  }

  .modal-header {
    padding: 1rem;
    flex-wrap: wrap;
  }

  .modal-header h2 {
    font-size: 1.25rem;
    flex: 1;
    min-width: 0;
  }

  .modal-body {
    padding: 1rem;
  }

  .event-details {
    gap: 0.75rem;
  }

  .detail-item {
    flex-direction: column;
    gap: 0.25rem;
    padding: 0.625rem;
  }

  .detail-label {
    min-width: auto;
    font-size: 0.875rem;
  }

  .detail-value {
    font-size: 0.875rem;
  }

  .participants-section {
    margin-top: 1rem;
    padding-top: 1rem;
  }

  .participants-section h3 {
    font-size: 1.125rem;
  }

  .participants-list {
    max-height: 200px;
  }

  .participant-item {
    padding: 0.625rem;
    font-size: 0.875rem;
  }

  .event-actions,
  .admin-actions {
    flex-direction: column;
    gap: 0.75rem;
    margin-top: 1rem;
    padding-top: 1rem;
  }

  /* Modal Header Mobile */
  .modal-header {
    flex-direction: column;
    align-items: stretch;
    padding: 1rem;
  }

  .modal-header-content {
    margin-bottom: 0.75rem;
  }

  .modal-header h2 {
    font-size: 1.125rem;
    line-height: 1.4;
  }

  .btn-close-modal {
    align-self: flex-end;
    margin-left: 0;
    margin-top: 0.5rem;
  }

  /* Join Tournament Section */
  .join-tournament-section {
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 2px solid #e9ecef;
  }

  .btn-join-tournament {
    width: 100%;
  }

  .join-tournament-note {
    margin-top: 0.5rem;
    font-size: 0.875rem;
    color: #6c757d;
    text-align: center;
  }

  .btn-lg {
    width: 100%;
    padding: 0.875rem 1.5rem;
    font-size: 1rem;
  }

  /* Form Mobile */
  .form-group {
    margin-bottom: 1.25rem;
  }

  .form-label {
    font-size: 0.875rem;
  }

  .form-control {
    padding: 0.875rem;
    font-size: 1rem; /* Prevent zoom on iOS */
    border-radius: 8px;
  }

  .row {
    flex-direction: column;
    gap: 0;
  }

  .col,
  .col-2,
  .col-3 {
    width: 100%;
  }

  /* Calendar Day Hover Effect - Disable on Mobile */
  .calendar-day:active {
    transform: scale(0.98);
  }

  .calendar-day:hover {
    transform: none;
  }
}

/* Small Mobile (iPhone SE, etc.) */
@media (max-width: 375px) {
  .calendar-weekday {
    font-size: 0.7rem;
    padding: 0.5rem 0.125rem;
    min-width: 40px;
  }

  .calendar-day {
    min-height: 60px;
    padding: 0.375rem 0.125rem;
    min-width: 40px;
  }

  .day-number {
    font-size: 0.875rem;
  }

  .event-badge {
    font-size: 0.55rem;
    padding: 0.2rem 0.25rem;
  }

  .event-icon {
    font-size: 0.7rem;
  }

  .event-count {
    font-size: 0.55rem;
  }

  .calendar-month-title {
    font-size: 1.25rem;
  }
}
</style>
