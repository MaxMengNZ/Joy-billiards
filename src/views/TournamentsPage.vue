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
          <span class="badge-text">Tournaments & Events Calendar</span>
        </div>
        <h1 class="hero-title">
          Tournament <span class="title-highlight">Calendar</span>
        </h1>
        <p class="hero-subtitle">
          View all tournaments and events at a glance. Register with one click.
        </p>
        <div class="hero-actions" v-if="authStore.isAdmin">
          <button class="btn-hero btn-hero-primary" @click="showCreateModal = true">
            <span class="btn-icon">➕</span>
            <span>Add Event</span>
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
            <span class="btn-nav-text">Prev</span>
          </button>
          <h2 class="calendar-month-title">
            {{ currentMonthName }} {{ currentYear }}
          </h2>
          <button class="btn-nav btn-nav-next" @click="nextMonth" :disabled="isLoading" aria-label="Next month">
            <span class="btn-nav-text">Next</span>
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
          <button class="btn btn-secondary btn-sm btn-close-modal" @click="closeEventModal" aria-label="Close modal">Close</button>
        </div>
        <div class="modal-body">
          <div class="event-details">
            <div class="detail-item">
              <span class="detail-label">📅 Date:</span>
              <span class="detail-value">{{ formatEventDate(selectedEvent.start_date) }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">⏰ Time:</span>
              <span class="detail-value">{{ formatEventTime(selectedEvent.start_date) }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">💰 Entry Fee:</span>
              <span class="detail-value">${{ selectedEvent.entry_fee }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">👥 Registered:</span>
              <span class="detail-value">
                {{ getRegistrationCount(selectedEvent.id) }}
                <span v-if="selectedEvent.min_players">
                  / Min: {{ selectedEvent.min_players }}
                </span>
              </span>
            </div>
            <div class="detail-item">
              <span class="detail-label">📊 Status:</span>
              <span class="detail-value badge" :class="getStatusBadgeClass(selectedEvent.status)">
                {{ formatStatus(selectedEvent.status) }}
              </span>
            </div>
            <div class="detail-item" v-if="selectedEvent.description">
              <span class="detail-label">📝 Description:</span>
              <span class="detail-value">{{ selectedEvent.description }}</span>
            </div>

            <!-- Minimum Players Warning -->
            <div
              v-if="getRegistrationCount(selectedEvent.id) < (selectedEvent.min_players || 8)"
              class="alert alert-warning"
            >
              ⚠️ Minimum {{ selectedEvent.min_players || 8 }} players required to start
            </div>
            <div
              v-else-if="selectedEvent.status !== 'completed'"
              class="alert alert-success"
            >
              ✅ Tournament confirmed ({{ selectedEvent.min_players || 8 }}+ players)
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
                🎯 Join Tournament
              </button>
              <p class="join-tournament-note">Please login to register for this tournament</p>
            </div>

            <!-- Participants List -->
            <div class="participants-section">
              <h3>👥 Participants ({{ participantsList.length }})</h3>
              <div v-if="loadingParticipants" class="text-center p-2">
                <div class="spinner-small"></div>
              </div>
              <div v-else-if="participantsList.length === 0" class="text-muted p-2">
                No participants yet.
              </div>
              <div v-else class="participants-list">
                <div
                  v-for="(participant, idx) in participantsList"
                  :key="participant.id"
                  class="participant-item"
                  :class="{ 'is-current-user': participant.user_id === currentUserId }"
                >
                  <span class="participant-number">{{ idx + 1 }}.</span>
                  <span class="participant-name">{{ participant.user?.name || 'Unknown' }}</span>
                  <span v-if="participant.user_id === currentUserId" class="badge badge-success">You</span>
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
                {{ isRegistering ? 'Registering...' : 'Register' }}
              </button>
              <button
                v-else
                class="btn btn-danger btn-lg"
                @click="cancelRegistration"
                :disabled="isCancelling || selectedEvent.status === 'completed'"
              >
                {{ isCancelling ? 'Cancelling...' : 'Cancel Registration' }}
              </button>
            </div>

            <!-- Admin Actions -->
            <div class="admin-actions" v-if="authStore.isAdmin">
              <button
                class="btn btn-success btn-lg"
                @click="completeTournament"
                :disabled="selectedEvent.status === 'completed'"
              >
                ✅ Complete Tournament
              </button>
              <button class="btn btn-secondary btn-lg" @click="editEvent">
                Edit
              </button>
              <button class="btn btn-danger btn-lg" @click="confirmDeleteEvent">
                Delete
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Create/Edit Event Modal -->
    <div v-if="showCreateModal || editingEvent" class="modal" @click.self="closeCreateModal">
      <div class="modal-content modal-large">
        <div class="modal-header">
          <h2>{{ editingEvent ? 'Edit Event' : 'Create New Event' }}</h2>
          <button class="btn btn-secondary btn-sm" @click="closeCreateModal">Close</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Event Name *</label>
            <input type="text" class="form-control" v-model="eventForm.name" required>
          </div>
          <div class="form-group">
            <label class="form-label">Description</label>
            <textarea class="form-control" v-model="eventForm.description" rows="3"></textarea>
          </div>
          <div class="row">
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">Date *</label>
                <input type="date" class="form-control" v-model="eventForm.date" required>
              </div>
            </div>
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">Time *</label>
                <input type="time" class="form-control" v-model="eventForm.time" required>
              </div>
            </div>
          </div>
          <div class="row">
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">Event Type *</label>
                <select class="form-control" v-model="eventForm.event_type" required>
                  <option value="custom">Custom Event</option>
                  <option value="weekly_pro">Weekly Pro Tournament</option>
                  <option value="weekly_student">Weekly Student Tournament</option>
                </select>
              </div>
            </div>
            <div class="col col-2">
              <div class="form-group">
                <label class="form-label">Category *</label>
                <select class="form-control" v-model="eventForm.participant_category" required>
                  <option value="adult">Adult (Pro)</option>
                  <option value="student">Student</option>
                </select>
              </div>
            </div>
          </div>
          <div class="row">
            <div class="col col-3">
              <div class="form-group">
                <label class="form-label">Entry Fee ($)</label>
                <input type="number" class="form-control" v-model="eventForm.entry_fee" min="0" step="0.01">
              </div>
            </div>
            <div class="col col-3">
              <div class="form-group">
                <label class="form-label">Min Players</label>
                <input type="number" class="form-control" v-model="eventForm.min_players" min="1" value="8">
              </div>
            </div>
            <div class="col col-3">
              <div class="form-group">
                <label class="form-label">Max Players</label>
                <input type="number" class="form-control" v-model="eventForm.max_players" min="1">
              </div>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">Status *</label>
            <select class="form-control" v-model="eventForm.status" required>
              <option value="upcoming">Upcoming</option>
              <option value="registration">Registration Open</option>
              <option value="in_progress">In Progress</option>
              <option value="completed">Completed</option>
              <option value="cancelled">Cancelled</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeCreateModal">Cancel</button>
          <button class="btn btn-success" @click="saveEvent">
            {{ editingEvent ? 'Update' : 'Create' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Complete Tournament Confirmation Modal -->
    <div v-if="showCompleteModal" class="modal" @click.self="showCompleteModal = false">
      <div class="modal-content">
        <div class="modal-header">
          <h2>✅ Complete Tournament?</h2>
        </div>
        <div class="modal-body">
          <p>Are you sure you want to mark this tournament as completed?</p>
          <div class="complete-details">
            <p><strong>Tournament:</strong> {{ selectedEvent?.name }}</p>
            <p><strong>Date:</strong> {{ selectedEvent ? formatEventDate(selectedEvent.start_date) : '' }}</p>
            <p><strong>Participants:</strong> {{ getRegistrationCount(selectedEvent?.id) }}</p>
          </div>
          <div class="alert alert-warning">
            ⚠️ This action will:
            <ul>
              <li>Update status to "Completed"</li>
              <li>Sync to homepage statistics</li>
              <li>Cannot be undone easily</li>
            </ul>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showCompleteModal = false">Cancel</button>
          <button class="btn btn-success" @click="confirmCompleteTournament">Confirm Complete</button>
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
import { formatNZDate } from '../utils/timezone'
import { supabase } from '../config/supabase'

export default {
  name: 'TournamentsPage',
  setup() {
    const router = useRouter()
    const tournamentStore = useTournamentStore()
    const authStore = useAuthStore()
    
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
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

    // Computed: Current month name
    const currentMonthName = computed(() => {
      const date = new Date(currentYear.value, currentMonth.value, 1)
      return date.toLocaleDateString('en-US', { month: 'long' })
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
      if (event.event_type === 'weekly_pro') return 'Weekly'
      if (event.event_type === 'weekly_student') return 'Student'
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
      return new Intl.DateTimeFormat('en-NZ', {
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
      return new Intl.DateTimeFormat('en-NZ', {
        timeZone: 'Pacific/Auckland',
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
      }).format(d)
    }

    // Format status
    const formatStatus = (status) => {
      return status.split('_').map(word => 
        word.charAt(0).toUpperCase() + word.slice(1)
      ).join(' ')
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
      if (!eventForm.value.name || !eventForm.value.date || !eventForm.value.time) {
        alert('Please fill in all required fields')
        return
      }

      const startDateTime = new Date(`${eventForm.value.date}T${eventForm.value.time}`)
      const data = {
        name: eventForm.value.name,
        description: eventForm.value.description || '',
        tournament_type: 'single_elimination',
        start_date: startDateTime.toISOString(),
        participant_category: eventForm.value.participant_category,
        event_type: eventForm.value.event_type,
        entry_fee: parseFloat(eventForm.value.entry_fee) || 20,
        min_players: parseInt(eventForm.value.min_players) || 8,
        max_players: eventForm.value.max_players ? parseInt(eventForm.value.max_players) : null,
        status: eventForm.value.status
      }

      let result
      if (editingEvent.value) {
        result = await tournamentStore.updateTournament(editingEvent.value.id, data)
      } else {
        result = await tournamentStore.createTournament(data)
      }

      if (result.success) {
        closeCreateModal()
        await tournamentStore.fetchTournaments()
        await loadRegistrationCounts()
      } else {
        alert('Error: ' + result.error)
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
      goToLogin
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

