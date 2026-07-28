<template>
  <div class="profile-page">
    <div v-if="loading" class="loading">
      <div class="spinner"></div>
    </div>

    <div v-else>
      <!-- Hero Header with Dynamic Background -->
      <section class="profile-hero">
        <div class="profile-hero-background">
          <div class="profile-hero-pattern"></div>
          <div class="profile-hero-glow"></div>
        </div>
        <div class="profile-hero-content">
          <div class="hero-badge">
            <span class="badge-icon">👤</span>
            <span class="badge-text">{{ t('profilePage.badge') }}</span>
          </div>
          <h1 class="hero-title">
            {{ t('profilePage.welcome') }}<span class="title-highlight">{{ profile?.name }}</span>
          </h1>
          <p class="hero-subtitle">
            {{ t('profilePage.subtitle') }}
          </p>
        </div>
      </section>

      <div class="profile-content">

      <!-- Membership Card Display -->
      <div class="membership-section">
        <div class="membership-card" :class="`membership-${profile?.membership_level || 'lite'}`">
          <div class="card-header-section">
            <div class="card-logo">
              <img src="/JoyBilliards-Logo.svg" alt="Joy Billiards" class="membership-card-logo">
              <p>New Zealand</p>
            </div>
            <div class="card-level">
              <span class="level-badge" :class="`level-${profile?.membership_level || 'lite'}`">
                {{ formatMembershipLevel(profile?.membership_level) }}
              </span>
            </div>
          </div>

          <div class="card-number">
            <p class="card-label">{{ t('profilePage.cardNumber') }}</p>
            <p class="card-number-value">{{ profile?.membership_card_number || 'JB-XXXX-XXXXXX' }}</p>
          </div>

          <div class="card-info">
            <div class="info-item">
              <p class="info-label">{{ t('profilePage.memberName') }}</p>
              <p class="info-value">{{ profile?.name }}</p>
            </div>
            <div class="info-item">
              <p class="info-label">{{ t('profilePage.memberSince') }}</p>
              <p class="info-value">{{ formatDate(profile?.created_at) }}</p>
            </div>
          </div>

          <div class="card-footer-section">
            <div class="points">
              <span class="points-icon">💎</span>
              <span class="points-value">{{ profile?.loyalty_points?.toFixed(2) || '0.00' }} {{ t('profilePage.points') }}</span>
            </div>
            <div class="expires">
              <span>{{ t('profilePage.validUntil') }} {{ formatExpiry(profile?.membership_expires_at) }}</span>
            </div>
          </div>
        </div>

        <!-- Membership Benefits -->
        <div class="membership-benefits card">
          <div class="card-header">
            <h2 class="card-title">{{ t('profilePage.benefits', { level: formatMembershipLevel(profile?.membership_level) }) }}</h2>
          </div>
          <div class="card-body">
            <ul class="benefits-list">
              <li v-for="(benefit, index) in membershipBenefits" :key="index">✓ {{ benefit }}</li>
            </ul>
            <div class="upgrade-section" v-if="profile?.membership_level !== 'pro_max'">
              <p class="upgrade-text">
                💎 {{ t('profilePage.upgrade', { level: getNextMembershipLevel(profile?.membership_level) }) }}
              </p>
              <button class="btn btn-warning" @click="showUpgradeInfo">
                {{ t('profilePage.learnMore') }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Personal Information -->
      <div class="row personal-info-section">
        <div class="col col-2">
          <div class="card">
            <div class="card-header">
              <h2 class="card-title">📋 {{ t('profilePage.personalInfo') }}</h2>
              <button 
                class="btn btn-primary btn-sm" 
                @click="isEditing = !isEditing"
              >
                {{ isEditing ? t('common.cancel') : t('profilePage.edit') }}
              </button>
            </div>
            <div class="card-body">
              <form @submit.prevent="saveProfile">
                <div class="form-group">
                  <label for="profile-name" class="form-label">{{ t('auth.fullName') }}</label>
                  <input
                    id="profile-name"
                    name="profile-name"
                    type="text"
                    class="form-control"
                    v-model="editForm.name"
                    :disabled="!isEditing"
                    required
                  >
                </div>

                <div class="form-group">
                  <label for="profile-email" class="form-label">{{ t('auth.email') }}</label>
                  <input
                    id="profile-email"
                    name="profile-email"
                    type="email"
                    class="form-control"
                    v-model="editForm.email"
                    disabled
                  >
                  <small class="form-text">{{ t('profilePage.emailLocked') }}</small>
                </div>

                <div class="form-group">
                  <label for="profile-phone" class="form-label">{{ t('auth.phone') }}</label>
                  <input
                    id="profile-phone"
                    name="profile-phone"
                    type="tel"
                    class="form-control"
                    v-model="editForm.phone"
                    :disabled="!isEditing"
                  >
                </div>

                <div class="form-group">
                  <label for="profile-birthday" class="form-label">{{ t('auth.birthday') }}</label>
                  <input
                    id="profile-birthday"
                    name="profile-birthday"
                    type="text"
                    class="form-control"
                    v-model="editForm.birthday"
                    :disabled="!isEditing"
                    placeholder="DD/MM/YYYY"
                  >
                  <small class="form-text">{{ t('auth.birthdayHint') }}</small>
                </div>

                <div class="form-group">
                  <label for="profile-address" class="form-label">{{ t('profilePage.address') }}</label>
                  <textarea
                    id="profile-address"
                    name="profile-address"
                    class="form-control"
                    v-model="editForm.address"
                    :disabled="!isEditing"
                    rows="2"
                    :placeholder="t('profilePage.addressPlaceholder')"
                  ></textarea>
                </div>

                <div class="form-group">
                  <label for="profile-id-card" class="form-label">{{ t('profilePage.idCard') }}</label>
                  <input
                    id="profile-id-card"
                    name="profile-id-card"
                    type="text"
                    class="form-control"
                    v-model="editForm.id_card"
                    :disabled="!isEditing"
                    :placeholder="t('profilePage.idPlaceholder')"
                  >
                  <small class="form-text">{{ t('profilePage.idHint') }}</small>
                </div>

                <div class="form-actions" v-if="isEditing">
                  <button type="submit" class="btn btn-success">
                    {{ t('profilePage.saveChanges') }}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>

        <div class="col col-2">
          <div class="card">
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
              <h2 class="card-title">📊 {{ t('profilePage.statistics') }}</h2>
              <div class="year-selector-profile">
                <label for="profile-year-select" class="selector-label" style="margin-right: 10px;">{{ t('profilePage.view') }}</label>
                <select 
                  id="profile-year-select" 
                  name="profile-year-select" 
                  v-model="statsYearFilter" 
                  class="year-select"
                  style="padding: 5px 10px; border-radius: 4px; border: 1px solid #ddd;"
                >
                  <option value="all">{{ t('profilePage.allYears') }}</option>
                  <option :value="currentYear">{{ currentYear }}（{{ t('profilePage.currentYear') }}）</option>
                </select>
              </div>
            </div>
            <div class="card-body">
              <div class="stats-grid">
                <div class="stat-item">
                  <div class="stat-icon">🏆</div>
                  <div class="stat-content">
                    <div class="stat-value">{{ statsYearFilter === 'all' ? (profile?.wins || 0) : ((profile?.year_stats?.filter(s => s.year === parseInt(statsYearFilter)).reduce((sum, s) => sum + (s.wins || 0), 0)) || 0) }}</div>
                    <div class="stat-label">{{ t('profilePage.wins') }} {{ statsYearFilter === 'all' ? `(${t('profilePage.total')})` : `(${statsYearFilter})` }}</div>
                  </div>
                </div>
                <div class="stat-item">
                  <div class="stat-icon">📉</div>
                  <div class="stat-content">
                    <div class="stat-value">{{ statsYearFilter === 'all' ? (profile?.losses || 0) : ((profile?.year_stats?.filter(s => s.year === parseInt(statsYearFilter)).reduce((sum, s) => sum + (s.losses || 0), 0)) || 0) }}</div>
                    <div class="stat-label">{{ t('profilePage.losses') }} {{ statsYearFilter === 'all' ? `(${t('profilePage.total')})` : `(${statsYearFilter})` }}</div>
                  </div>
                </div>
                <div class="stat-item">
                  <div class="stat-icon">🎮</div>
                  <div class="stat-content">
                    <div class="stat-value">{{ statsYearFilter === 'all' ? ((profile?.wins || 0) + (profile?.losses || 0)) : ((profile?.year_stats?.filter(s => s.year === parseInt(statsYearFilter)).reduce((sum, s) => sum + (s.wins || 0) + (s.losses || 0), 0)) || 0) }}</div>
                    <div class="stat-label">{{ t('profilePage.matches') }} {{ statsYearFilter === 'all' ? `(${t('profilePage.total')})` : `(${statsYearFilter})` }}</div>
                  </div>
                </div>
                <div class="stat-item">
                  <div class="stat-icon">📈</div>
                  <div class="stat-content">
                    <div class="stat-value">{{ calculateWinRate }}%</div>
                    <div class="stat-label">{{ t('profilePage.winRate') }} {{ statsYearFilter === 'all' ? `(${t('profilePage.total')})` : `(${statsYearFilter})` }}</div>
                  </div>
                </div>
                <div class="stat-item">
                  <div class="stat-icon">🎯</div>
                  <div class="stat-content">
                    <div class="stat-value">{{ statsYearFilter === 'all' ? (profile?.break_and_run_count || 0) : ((profile?.year_stats?.filter(s => s.year === parseInt(statsYearFilter)).reduce((sum, s) => sum + (s.break_and_run_count || 0), 0)) || 0) }}</div>
                    <div class="stat-label">{{ t('profilePage.breakRun') }} {{ statsYearFilter === 'all' ? `(${t('profilePage.total')})` : `(${statsYearFilter})` }}</div>
                  </div>
                </div>
                <div class="stat-item">
                  <div class="stat-icon">⭐</div>
                  <div class="stat-content">
                    <div class="stat-value">{{ currentYearPoints }}</div>
                    <div class="stat-label">{{ t('profilePage.rankingPoints') }}（{{ currentYear }}）</div>
                  </div>
                </div>
                <div class="stat-item">
                  <div class="stat-icon">📅</div>
                  <div class="stat-content">
                    <div class="stat-value">{{ tournamentsPlayedFiltered }}</div>
                    <div class="stat-label">{{ t('profilePage.eventsPlayed') }} {{ statsYearFilter === 'all' ? `(${t('profilePage.total')})` : `(${statsYearFilter})` }}</div>
                  </div>
                </div>
              </div>

              <div class="division-stats-grid">
                <div class="division-card pro">
                  <div class="division-header">👔 {{ t('profilePage.proDivision') }}</div>
                  <div class="division-body">
                    <div class="division-row">
                      <span>{{ t('profilePage.wins') }}</span>
                      <strong>{{ proStats.wins }}</strong>
                    </div>
                    <div class="division-row">
                      <span>{{ t('profilePage.losses') }}</span>
                      <strong>{{ proStats.losses }}</strong>
                    </div>
                    <div class="division-row">
                      <span>{{ t('profilePage.matches') }}</span>
                      <strong>{{ proStats.matches }}</strong>
                    </div>
                    <div class="division-row">
                      <span>{{ t('profilePage.winRate') }}</span>
                      <strong>{{ proStats.winRate }}%</strong>
                    </div>
                    <div class="division-row">
                      <span>{{ t('profilePage.breakRun') }}</span>
                      <strong>{{ proStats.breakAndRun }}</strong>
                    </div>
                  </div>
                </div>

                <div class="division-card student">
                  <div class="division-header">🎓 {{ t('profilePage.studentDivision') }}</div>
                  <div class="division-body">
                    <div class="division-row">
                      <span>{{ t('profilePage.wins') }}</span>
                      <strong>{{ studentStats.wins }}</strong>
                    </div>
                    <div class="division-row">
                      <span>{{ t('profilePage.losses') }}</span>
                      <strong>{{ studentStats.losses }}</strong>
                    </div>
                    <div class="division-row">
                      <span>{{ t('profilePage.matches') }}</span>
                      <strong>{{ studentStats.matches }}</strong>
                    </div>
                    <div class="division-row">
                      <span>{{ t('profilePage.winRate') }}</span>
                      <strong>{{ studentStats.winRate }}%</strong>
                    </div>
                    <div class="division-row">
                      <span>{{ t('profilePage.breakRun') }}</span>
                      <strong>{{ studentStats.breakAndRun }}</strong>
                    </div>
                  </div>
                </div>
              </div>

              <div class="skill-badge-section mt-3">
                <p class="stat-label">{{ t('profilePage.skillLevel') }}</p>
                <span class="badge badge-lg" :class="getSkillBadgeClass(profile?.skill_level)">
                  {{ formatSkillLevel(profile?.skill_level) }}
                </span>
              </div>
            </div>
          </div>

          <!-- Account Settings -->
          <div class="card mt-3">
            <div class="card-header">
              <h2 class="card-title">🔐 {{ t('profilePage.accountSettings') }}</h2>
            </div>
            <div class="card-body">
              <div class="setting-item">
                <span class="setting-label">{{ t('profilePage.role') }}</span>
                <span class="badge" :class="profile?.role === 'admin' ? 'badge-warning' : 'badge-info'">
                  {{ profile?.role === 'admin' ? `👑 ${t('profilePage.admin')}` : `🎯 ${t('profilePage.player')}` }}
                </span>
              </div>
              <div class="setting-item mt-2">
                <span class="setting-label">{{ t('profilePage.status') }}</span>
                <span class="badge" :class="profile?.is_active ? 'badge-success' : 'badge-danger'">
                  {{ profile?.is_active ? t('profilePage.active') : t('profilePage.inactive') }}
                </span>
              </div>
              <button class="btn btn-secondary btn-sm mt-3" @click="showChangePassword = true">
                {{ t('profilePage.changePassword') }}
              </button>
              <button class="btn btn-danger btn-sm mt-2" @click="handleLogout" style="width: 100%;">
                🚪 {{ t('profilePage.logout') }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- My Tournaments Section -->
      <div class="card mt-3 tournaments-section">
        <div class="card-header">
          <h2 class="card-title">🎯 {{ t('profilePage.myTournaments') }}</h2>
          <router-link to="/tournaments" class="btn btn-primary btn-sm">
            {{ t('profilePage.browseTournaments') }}
          </router-link>
        </div>
        <div class="card-body">
          <div v-if="upcomingTournaments.length === 0" class="text-center p-3">
            <p class="text-secondary">{{ t('profilePage.noTournaments') }}</p>
            <router-link to="/tournaments" class="btn btn-success mt-2">
              {{ t('profilePage.registerTournament') }}
            </router-link>
          </div>
          <div v-else class="tournaments-list">
            <div v-for="reg in upcomingTournaments" :key="reg.id" class="tournament-item">
              <div class="tournament-header">
                <h3>{{ reg.tournament.name }}</h3>
                <span class="badge" :class="getTournamentStatusClass(reg.tournament.status)">
                  {{ formatTournamentStatus(reg.tournament.status) }}
                </span>
              </div>
              <div class="tournament-details">
                <p><strong>📅 {{ t('profilePage.date') }}</strong> {{ formatTournamentDate(reg.tournament.start_date) }}</p>
                <p><strong>📍 {{ t('profilePage.type') }}</strong> {{ formatTournamentType(reg.tournament.tournament_type) }}</p>
                <p><strong>💰 {{ t('profilePage.entryFee') }}</strong> ${{ reg.tournament.entry_fee }}</p>
                <p><strong>🏆 {{ t('profilePage.prizePool') }}</strong> ${{ reg.tournament.prize_pool }}</p>
                <p><strong>✅ {{ t('profilePage.registered') }}</strong> {{ formatDate(reg.registered_at) }}</p>
              </div>
              <div class="tournament-actions">
                <router-link 
                  to="/tournaments" 
                  class="btn btn-primary btn-sm"
                >
                  {{ t('profilePage.viewCalendar') }}
                </router-link>
                <button 
                  class="btn btn-danger btn-sm"
                  @click="cancelTournamentReg(reg)"
                  v-if="reg.tournament.status === 'registration' || reg.tournament.status === 'upcoming'"
                >
                  {{ t('profilePage.cancelRegistration') }}
                </button>
              </div>
            </div>
          </div>

          <!-- Tournament Reminder -->
          <div v-if="upcomingTournaments.length > 0" class="tournament-reminder mt-3">
            <div class="alert alert-info">
              <strong>⏰ {{ t('profilePage.reminder') }}</strong> {{ t('profilePage.reminderText', { count: upcomingTournaments.length }) }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Change Password Modal -->
    <div v-if="showChangePassword" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>{{ t('profilePage.changePassword') }}</h2>
          <button class="btn btn-secondary btn-sm" @click="closePasswordModal">{{ t('auth.close') }}</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label for="new-password" class="form-label">{{ t('profilePage.newPassword') }}</label>
            <input
              id="new-password"
              name="new-password"
              type="password"
              class="form-control"
              v-model="newPassword"
              :placeholder="t('auth.minPassword')"
              minlength="6"
            >
          </div>
          <div class="form-group">
            <label for="confirm-new-password" class="form-label">{{ t('profilePage.confirmNewPassword') }}</label>
            <input
              id="confirm-new-password"
              name="confirm-new-password"
              type="password"
              class="form-control"
              v-model="confirmNewPassword"
              :placeholder="t('profilePage.confirmPlaceholder')"
            >
          </div>
          <div v-if="newPassword && confirmNewPassword && newPassword !== confirmNewPassword" class="alert alert-warning">
            {{ t('auth.passwordsMismatch') }}
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closePasswordModal" :disabled="isChangingPassword">{{ t('common.cancel') }}</button>
          <button 
            class="btn btn-success" 
            @click="handleChangePassword"
            :disabled="!newPassword || newPassword !== confirmNewPassword || isChangingPassword"
          >
            {{ isChangingPassword ? t('profilePage.updating') : t('profilePage.updatePassword') }}
          </button>
        </div>
      </div>
    </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/authStore'
import { supabase } from '../config/supabase'
import { useI18n } from '../i18n'

export default {
  name: 'ProfilePage',
  setup() {
    const authStore = useAuthStore()
    const router = useRouter()
    const { t, list } = useI18n()

    const loading = ref(true)
    const profile = ref(null)
    const pointHistory = ref([])
    const currentYear = new Date().getFullYear()
    const statsYearFilter = ref('all') // 'all' or currentYear
    const isEditing = ref(false)
    const showChangePassword = ref(false)
    const newPassword = ref('')
    const confirmNewPassword = ref('')
    const isChangingPassword = ref(false)
    const myRegistrations = ref([])
    const upcomingTournaments = ref([])
    const membershipBenefits = computed(() => {
      const level = profile.value?.membership_level || 'lite'
      const key = ['lite', 'plus', 'pro', 'pro_max'].includes(level) ? level : 'lite'
      return list(`profilePage.${key === 'pro_max' ? 'proMax' : key}Benefits`)
    })

    const editForm = ref({
      name: '',
      email: '',
      phone: '',
      birthday: '',
      address: '',
      id_card: ''
    })

    const getDivisionStatKey = (division, field) => {
      const prefix = division === 'student' ? 'student' : 'pro'
      if (field === 'break_and_run_count') {
        return `${prefix}_break_and_run_count`
      }
      return `${prefix}_${field}`
    }

    const getDivisionValue = (division, field) => {
      if (!profile.value) return 0
      const key = getDivisionStatKey(division, field)
      return profile.value[key] ?? 0
    }
    
    // Get year-specific division value
    const getDivisionValueForYear = (division, field, year) => {
      if (!profile.value) return 0
      
      // If year filter is set and year_stats available, use year-specific data
      if (statsYearFilter.value !== 'all' && profile.value.year_stats) {
        const year = parseInt(statsYearFilter.value)
        const yearStat = profile.value.year_stats.find(s => s.division === division && s.year === year)
        if (yearStat) {
          if (field === 'wins') return yearStat.wins || 0
          if (field === 'losses') return yearStat.losses || 0
          if (field === 'break_and_run_count') return yearStat.break_and_run_count || 0
        }
      }
      
      // Fallback to total stats
      return getDivisionValue(division, field)
    }

    const proStats = computed(() => {
      const wins = getDivisionValueForYear('pro', 'wins', statsYearFilter.value)
      const losses = getDivisionValueForYear('pro', 'losses', statsYearFilter.value)
      const matches = wins + losses
      const breakAndRun = getDivisionValueForYear('pro', 'break_and_run_count', statsYearFilter.value)
      return {
        wins,
        losses,
        matches,
        breakAndRun,
        winRate: matches === 0 ? '0.0' : ((wins / matches) * 100).toFixed(1)
      }
    })

    const studentStats = computed(() => {
      const wins = getDivisionValueForYear('student', 'wins', statsYearFilter.value)
      const losses = getDivisionValueForYear('student', 'losses', statsYearFilter.value)
      const matches = wins + losses
      const breakAndRun = getDivisionValueForYear('student', 'break_and_run_count', statsYearFilter.value)
      return {
        wins,
        losses,
        matches,
        breakAndRun,
        winRate: matches === 0 ? '0.0' : ((wins / matches) * 100).toFixed(1)
      }
    })

    const calculateWinRate = computed(() => {
      if (!profile.value) return 0
      
      // Use year-specific stats if filter is set
      if (statsYearFilter.value !== 'all' && profile.value.year_stats) {
        const year = parseInt(statsYearFilter.value)
        const proStats = profile.value.year_stats.find(s => s.division === 'pro' && s.year === year)
        const studentStats = profile.value.year_stats.find(s => s.division === 'student' && s.year === year)
        const wins = (proStats?.wins || 0) + (studentStats?.wins || 0)
        const losses = (proStats?.losses || 0) + (studentStats?.losses || 0)
        const total = wins + losses
        if (total === 0) return 0
        return ((wins / total) * 100).toFixed(1)
      }
      
      // Fallback to total stats
      const total = profile.value.wins + profile.value.losses
      if (total === 0) return 0
      return ((profile.value.wins / total) * 100).toFixed(1)
    })

    const currentYearPoints = computed(() => {
      if (!profile.value) return 0
      return pointHistory.value
        .filter(p => p.user_id === profile.value.id && p.year === currentYear)
        .reduce((sum, p) => sum + (p.points_change || 0), 0)
    })

    // Count tournaments played from point history
    // Simple approach: Events Played = Total Records in Point History
    const tournamentsPlayed = computed(() => {
      if (!profile.value || !pointHistory.value || pointHistory.value.length === 0) return 0
      
      // Simply return the total number of point history records
      return pointHistory.value.length
    })
    
    // Filtered tournaments played based on year filter
    const tournamentsPlayedFiltered = computed(() => {
      if (!profile.value || !pointHistory.value || pointHistory.value.length === 0) return 0
      
      if (statsYearFilter.value === 'all') {
        return pointHistory.value.length
      } else {
        // Filter by selected year
        const year = parseInt(statsYearFilter.value)
        return pointHistory.value.filter(p => p.year === year).length
      }
    })

    const retryCount = ref(0)
    const maxRetries = 5

    const loadProfile = async () => {
      if (!authStore.user) {
        loading.value = false
        return
      }

      loading.value = true
      try {
        const { data, error } = await supabase
          .from('users')
          .select('*')
          .eq('auth_id', authStore.user.id)
          .maybeSingle()

        if (error) throw error

        if (data) {
          profile.value = data
          
          // Load year-specific stats
          const { data: yearStatsData, error: yearStatsError } = await supabase
            .from('user_year_stats')
            .select('*')
            .eq('user_id', data.id)
          
          if (!yearStatsError && yearStatsData) {
            // Store year stats in profile for use in computed properties
            profile.value.year_stats = yearStatsData
          }
          // Format birthday from YYYY-MM-DD to DD/MM/YYYY
          let formattedBirthday = ''
          if (data.birthday) {
            const date = new Date(data.birthday)
            const day = String(date.getDate()).padStart(2, '0')
            const month = String(date.getMonth() + 1).padStart(2, '0')
            const year = date.getFullYear()
            formattedBirthday = `${day}/${month}/${year}`
          }
          
          editForm.value = {
            name: data.name,
            email: data.email,
            phone: data.phone || '',
            birthday: formattedBirthday,
            address: data.address || '',
            id_card: data.id_card || ''
          }

          // Load user's tournament registrations
          await loadMyRegistrations(data.id)
          
          // Load ranking point history for ranking points calculation
          const { data: historyData, error: historyError } = await supabase
            .from('ranking_point_history')
            .select('*')
            .eq('user_id', data.id)
            .order('awarded_at', { ascending: false }) // Order by date for easier debugging
          
          if (!historyError && historyData) {
            pointHistory.value = historyData
            console.log(`[ProfilePage] Loaded ${historyData.length} point history records for user ${data.name}`)
            // Log ALL records for debugging
            // Point history loaded successfully
            console.log(`[ProfilePage] Loaded ${historyData.length} point history records`)
          } else if (historyError) {
            console.error('[ProfilePage] Error loading point history:', historyError)
          }
          
          retryCount.value = 0 // Reset retry count on success
        } else {
          // Profile not found, retry with limit
          if (retryCount.value < maxRetries) {
            retryCount.value++
            console.warn(`Profile not found, retrying... (${retryCount.value}/${maxRetries})`)
            setTimeout(() => loadProfile(), 1000)
          } else {
            console.error('Profile not found after maximum retries')
            alert('Unable to load profile. Please contact support.')
            loading.value = false
          }
        }
      } catch (err) {
        console.error('Error loading profile:', err)
        alert('Error loading profile: ' + err.message)
        loading.value = false
      } finally {
        if (profile.value || retryCount.value >= maxRetries) {
          loading.value = false
        }
      }
    }

    const loadMyRegistrations = async (userId) => {
      try {
        const { data, error } = await supabase
          .from('tournament_registrations')
          .select(`
            *,
            tournament:tournaments(*)
          `)
          .eq('user_id', userId)
          .eq('status', 'registered')
          .order('registered_at', { ascending: false })

        if (error) throw error

        myRegistrations.value = data || []

        // Filter upcoming tournaments
        upcomingTournaments.value = myRegistrations.value.filter(reg => 
          reg.tournament && 
          (reg.tournament.status === 'upcoming' || 
           reg.tournament.status === 'registration' ||
           reg.tournament.status === 'in_progress')
        )
      } catch (err) {
        console.error('Error loading registrations:', err)
      }
    }

    const saveProfile = async () => {
      try {
        // Convert DD/MM/YYYY to YYYY-MM-DD for database
        let birthdayISO = null
        if (editForm.value.birthday) {
          const parts = editForm.value.birthday.split('/')
          if (parts.length === 3) {
            const day = parts[0].padStart(2, '0')
            const month = parts[1].padStart(2, '0')
            const year = parts[2]
            birthdayISO = `${year}-${month}-${day}`
          }
        }
        
        const { data, error } = await supabase
          .from('users')
          .update({
            name: editForm.value.name,
            phone: editForm.value.phone,
            birthday: birthdayISO,
            address: editForm.value.address,
            id_card: editForm.value.id_card
          })
          .eq('auth_id', authStore.user.id)
          .select()
          .single()

        if (error) throw error

        profile.value = data
        isEditing.value = false
        alert('Profile updated successfully!')
      } catch (err) {
        console.error('Error updating profile:', err)
        alert('Error updating profile: ' + err.message)
      }
    }

    const handleChangePassword = async () => {
      if (isChangingPassword.value) {
        console.log('Already changing password, ignoring...')
        return
      }
      
      console.log('=== PASSWORD CHANGE START ===')
      
      if (newPassword.value.length < 6) {
        alert('❌ Password must be at least 6 characters')
        return
      }

      if (newPassword.value !== confirmNewPassword.value) {
        alert('❌ Passwords do not match')
        return
      }

      isChangingPassword.value = true

      try {
        console.log('Step 1: Calling updatePassword with timeout...')
        
        // Add timeout to prevent hanging
        const updatePromise = authStore.updatePassword(newPassword.value)
        const timeoutPromise = new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Update timeout')), 10000)
        )
        
        const result = await Promise.race([updatePromise, timeoutPromise])
        console.log('Step 2: Result received:', result)
        
        if (result && result.success) {
          console.log('Step 3: Password updated successfully!')
          
          // Set flag first
          console.log('Step 4: Setting sessionStorage flag...')
          sessionStorage.setItem('passwordChanged', 'true')
          
          // Force redirect immediately (don't wait for logout)
          console.log('Step 5: Redirecting to /login...')
          window.location.href = '/login'
        } else {
          const errorMsg = result?.error || 'Unknown error occurred'
          console.error('Password update failed:', errorMsg)
          
          // Check if it's a timeout error
          if (errorMsg.includes('timeout')) {
            console.log('Timeout detected - assuming password was updated')
            alert('⚠️ Request timed out, but your password has likely been updated.\n\nYou will be redirected to the login page.\nPlease try logging in with your NEW password.')
            
            sessionStorage.setItem('passwordChanged', 'true')
            sessionStorage.setItem('passwordTimeout', 'true')
            
            setTimeout(() => {
              window.location.href = '/login'
            }, 1000)
            return
          }
          
          alert('❌ Error updating password: ' + errorMsg)
          isChangingPassword.value = false
        }
      } catch (error) {
        console.error('=== EXCEPTION ===', error)
        
        // If it's a timeout error, assume password was updated (Supabase behavior)
        if (error.message && error.message.includes('timeout')) {
          console.log('Timeout detected - assuming password was updated')
          alert('⚠️ Request timed out, but your password has likely been updated.\n\nYou will be redirected to the login page.\nPlease try logging in with your NEW password.')
          
          sessionStorage.setItem('passwordChanged', 'true')
          sessionStorage.setItem('passwordTimeout', 'true')
          
          setTimeout(() => {
            window.location.href = '/login'
          }, 1000)
          return
        }
        
        alert('❌ Error: ' + (error.message || 'Unknown error'))
        isChangingPassword.value = false
      }
    }

    const closePasswordModal = () => {
      showChangePassword.value = false
      newPassword.value = ''
      confirmNewPassword.value = ''
    }

    const showUpgradeInfo = () => {
      alert('Contact Joy Billiards staff to upgrade your membership!\n📞 022 166 0688')
    }

    const formatMembershipLevel = (level) => {
      const levels = {
        lite: '🎱 Lite',
        plus: '⭐ Plus',
        pro: '💎 Pro',
        pro_max: '🌟 Pro Max'
      }
      return levels[level] || '🎱 Lite'
    }

    const getNextMembershipLevel = (currentLevel) => {
      const upgrades = {
        lite: 'Plus',
        plus: 'Pro',
        pro: 'Pro Max'
      }
      return upgrades[currentLevel] || 'Pro Max'
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
        day: 'numeric'
      })
    }

    const formatExpiry = (dateString) => {
      if (!dateString) return 'Lifetime'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-NZ', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    }

    const formatTournamentDate = (dateString) => {
      if (!dateString) return 'TBD'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-NZ', {
        weekday: 'short',
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    const formatTournamentType = (type) => {
      if (!type) return 'N/A'
      return type.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')
    }

    const formatTournamentStatus = (status) => {
      if (!status) return 'N/A'
      return status.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')
    }

    const getTournamentStatusClass = (status) => {
      const classes = {
        upcoming: 'badge-secondary',
        registration: 'badge-info',
        in_progress: 'badge-warning',
        completed: 'badge-success',
        cancelled: 'badge-danger'
      }
      return classes[status] || 'badge-secondary'
    }

    const cancelTournamentReg = async (registration) => {
      if (!confirm(`Cancel registration for ${registration.tournament.name}?`)) return

      try {
        const { error } = await supabase
          .from('tournament_registrations')
          .delete()
          .eq('id', registration.id)

        if (error) throw error

        alert('Registration cancelled successfully!')
        await loadProfile()
      } catch (err) {
        alert('Error cancelling registration: ' + err.message)
      }
    }

    const handleLogout = async () => {
      if (confirm(t('nav.logoutConfirm'))) {
        await authStore.signOut()
        router.push('/login')
      }
    }

    onMounted(() => {
      loadProfile()
    })

    return {
      authStore,
      t,
      loading,
      profile,
      pointHistory,
      currentYear,
      currentYearPoints,
      tournamentsPlayed,
      proStats,
      studentStats,
      statsYearFilter,
      tournamentsPlayedFiltered,
      isEditing,
      editForm,
      showChangePassword,
      newPassword,
      confirmNewPassword,
      isChangingPassword,
      myRegistrations,
      upcomingTournaments,
      membershipBenefits,
      calculateWinRate,
      saveProfile,
      handleChangePassword,
      closePasswordModal,
      showUpgradeInfo,
      formatMembershipLevel,
      getNextMembershipLevel,
      getSkillBadgeClass,
      formatSkillLevel,
      formatDate,
      formatExpiry,
      formatTournamentDate,
      formatTournamentType,
      formatTournamentStatus,
      getTournamentStatusClass,
      cancelTournamentReg,
      handleLogout
    }
  }
}
</script>

<style scoped>
.profile-page {
  max-width: 100%;
  margin: 0;
  padding: 0;
}

/* Profile Hero Section */
.profile-hero {
  position: relative;
  padding: 5rem 2rem 4rem;
  overflow: hidden;
  text-align: center;
  margin-bottom: 3rem;
}

.profile-hero-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #4ECDC4 0%, #45B7AF 25%, #667eea 50%, #45B7AF 75%, #4ECDC4 100%);
  z-index: 0;
}

.profile-hero-pattern {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(circle at 30% 30%, rgba(255, 255, 255, 0.12) 0%, transparent 50%),
    radial-gradient(circle at 70% 70%, rgba(102, 126, 234, 0.12) 0%, transparent 50%),
    radial-gradient(circle at 50% 50%, rgba(255, 215, 0, 0.08) 0%, transparent 50%);
  animation: pattern-drift 24s ease-in-out infinite;
}

@keyframes pattern-drift {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(20px, 20px) scale(1.05); }
}

.profile-hero-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 650px;
  height: 650px;
  background: radial-gradient(circle, rgba(78, 205, 196, 0.25) 0%, transparent 70%);
  filter: blur(90px);
  animation: glow-pulse 5.5s ease-in-out infinite;
}

@keyframes glow-pulse {
  0%, 100% { opacity: 0.5; transform: translate(-50%, -50%) scale(1); }
  50% { opacity: 0.8; transform: translate(-50%, -50%) scale(1.1); }
}

.profile-hero-content {
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
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.4);
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
  font-size: 3.25rem;
  font-weight: 800;
  color: white;
  margin-bottom: 1rem;
  line-height: 1.2;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
  animation: title-fade-in 1s ease-out;
}

@keyframes title-fade-in {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.title-highlight {
  background: linear-gradient(135deg, #FFD700 0%, #4ECDC4 50%, #667eea 100%);
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
  font-size: 1.125rem;
  color: rgba(255, 255, 255, 0.95);
  font-weight: 500;
  line-height: 1.7;
}

.profile-content {
  max-width: 1200px;
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
  color: var(--dark-color);
}

/* Membership Card Styles */
.membership-section {
  margin-bottom: 2rem;
}

.membership-card {
  background: linear-gradient(135deg, #cd7f32 0%, #8b5a2b 100%);
  border-radius: 20px;
  padding: 2rem;
  color: white;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  margin-bottom: 2rem;
  position: relative;
  overflow: hidden;
}

.membership-card::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -20%;
  width: 400px;
  height: 400px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 50%;
}

/* Lite Card - 粉蓝渐变 */
.membership-lite {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  color: #1a1a2e;
}

/* Plus Card - 粉紫渐变 */
.membership-plus {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

/* Pro Card - 蓝紫渐变 */
.membership-pro {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

/* Pro Max Card - 红青渐变 */
.membership-pro_max {
  background: linear-gradient(135deg, #FF6B6B 0%, #4ECDC4 100%);
  color: white;
}

.card-header-section {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
}

.membership-card-logo {
  height: 70px;
  width: auto;
  max-width: 200px;
  object-fit: contain;
  /* 白色背景，让黑色 Logo 清晰可见 */
  background: white;
  padding: 8px 16px;
  border-radius: 8px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
}

.card-logo p {
  margin: 0;
  font-size: 0.875rem;
  opacity: 0.9;
}

.level-badge {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.875rem;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.card-number {
  margin-bottom: 1.5rem;
}

.card-label {
  font-size: 0.75rem;
  opacity: 0.8;
  margin: 0 0 0.25rem 0;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.card-number-value {
  font-size: 1.5rem;
  font-weight: 700;
  letter-spacing: 2px;
  margin: 0;
  font-family: 'Courier New', monospace;
}

.card-info {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.info-label {
  font-size: 0.75rem;
  opacity: 0.8;
  margin: 0 0 0.25rem 0;
  text-transform: uppercase;
}

.info-value {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
}

.card-footer-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 1rem;
  border-top: 1px solid rgba(255, 255, 255, 0.2);
}

.points {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.points-icon {
  font-size: 1.5rem;
}

.points-value {
  font-weight: 600;
  font-size: 1.125rem;
}

.expires {
  font-size: 0.875rem;
  opacity: 0.9;
}

/* Benefits Card */
.membership-benefits {
  background: white;
}

.benefits-list {
  list-style: none;
  padding: 0;
  margin: 0 0 1.5rem 0;
}

.benefits-list li {
  padding: 0.75rem;
  margin-bottom: 0.5rem;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid var(--success-color);
}

.upgrade-section {
  padding: 1.5rem;
  background: linear-gradient(135deg, rgba(255, 215, 0, 0.1), rgba(218, 165, 32, 0.1));
  border-radius: 10px;
  border: 2px solid #ffd700;
  text-align: center;
}

.upgrade-text {
  margin-bottom: 1rem;
  font-weight: 500;
  color: var(--dark-color);
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

.division-stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1rem;
  margin-top: 1.5rem;
}

.division-card {
  background: #f8f9ff;
  border: 1px solid #dfe3f0;
  border-radius: 12px;
  padding: 1rem 1.25rem;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.6);
  transition: transform 0.2s ease;
}

.division-card:hover {
  transform: translateY(-2px);
}

.division-card .division-header {
  font-weight: 600;
  font-size: 1rem;
  color: #1a1a2e;
  margin-bottom: 0.75rem;
}

.division-card.pro {
  border-left: 4px solid #4f46e5;
}

.division-card.student {
  border-left: 4px solid #16a34a;
  background: #f3fff5;
}

.division-body {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.division-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.95rem;
  color: #4b5563;
}

.division-row strong {
  color: #111827;
  font-weight: 600;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 10px;
}

.stat-icon {
  font-size: 2rem;
}

.stat-value {
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--primary-color);
}

.stat-label {
  font-size: 0.875rem;
  color: var(--text-secondary);
  font-weight: 500;
}

.skill-badge-section {
  text-align: center;
}

.badge-lg {
  padding: 0.75rem 1.5rem;
  font-size: 1.125rem;
}

/* Settings */
.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem;
  background: #f8f9fa;
  border-radius: 8px;
}

.setting-label {
  font-weight: 500;
  color: var(--text-secondary);
}

/* Responsive */
@media (max-width: 768px) {
  .page-header h1 {
    font-size: 1.5rem;
  }

  .membership-card {
    padding: 1.5rem;
  }

  .card-number-value {
    font-size: 1.125rem;
  }

  .card-info {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .division-stats-grid {
    grid-template-columns: 1fr;
  }

  .card-footer-section {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
}

/* Tournament List */
.tournaments-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.tournament-item {
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 10px;
  border-left: 4px solid var(--primary-color);
}

.tournament-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
  gap: 1rem;
}

.tournament-header h3 {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--dark-color);
  margin: 0;
  flex: 1;
}

.tournament-details {
  margin-bottom: 1rem;
}

.tournament-details p {
  margin: 0.5rem 0;
  color: var(--text-primary);
}

.tournament-actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.tournament-reminder {
  margin-top: 1rem;
}

.form-text {
  display: block;
  margin-top: 0.25rem;
  font-size: 0.875rem;
  color: #6c757d;
}

@media (max-width: 768px) {
  /* 调整移动端布局顺序 */
  .profile-content {
    display: flex;
    flex-direction: column;
  }

  /* My Registered Tournaments 放在最前面 */
  .tournaments-section {
    order: 1;
  }

  /* 个人信息和统计信息区域 */
  .personal-info-section {
    order: 2;
  }

  /* 优化退出登录按钮 */
  .btn-danger {
    min-height: 48px;
    font-size: 16px;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
  }

  /* 优化 Change Password 按钮 */
  .btn-secondary.btn-sm {
    min-height: 44px;
    font-size: 15px;
    width: 100%;
  }

  .tournament-actions {
    flex-direction: column;
  }

  .tournament-actions .btn {
    width: 100%;
    min-height: 44px;
  }

  /* 优化表单输入框 */
  .form-control {
    min-height: 48px;
    font-size: 16px;
  }

  textarea.form-control {
    min-height: 80px;
  }

  /* 优化卡片间距 */
  .card.mt-3,
  .row + .row {
    margin-top: 1rem !important;
  }
}

@media (max-width: 480px) {
  .membership-card {
    padding: 1rem;
  }

  .membership-card-logo {
    height: 55px;
    max-width: 180px;
    padding: 6px 12px;
  }

  .stat-item {
    padding: 0.75rem;
  }

  .stat-icon {
    font-size: 1.5rem;
  }

  .stat-value {
    font-size: 1.5rem;
  }

  .tournament-item {
    padding: 1rem;
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
}
</style>
