<template>
  <div class="admin-dashboard">
    <div class="page-header">
      <h1>🔐 Admin Dashboard</h1>
      <p>Welcome, {{ authStore?.userName || 'Administrator' }}</p>
    </div>

    <!-- System Statistics Management - Moved to Top -->
    <section class="section-statistics">
      <div class="card">
        <div class="card-header">
          <h2 class="card-title">📊 System Statistics Management</h2>
          <p class="card-subtitle">Control and monitor key metrics displayed on the homepage</p>
        </div>
        <div class="card-body">
          <div class="stats-management-grid">
            <!-- Total Players Stat -->
            <div class="stat-management-card stat-players-card">
              <div class="stat-header">
                <div class="stat-icon-large">👥</div>
                <div class="stat-info">
                  <h3 class="stat-title">Registered Players</h3>
                  <div class="stat-mode">
                    <span class="badge badge-success">
                      🔄 Auto-Count
                    </span>
                  </div>
                </div>
              </div>
              <div class="stat-value-display">
                <div class="current-value">{{ statsStore?.totalPlayers || 0 }}</div>
                <div class="stat-note">Auto-calculated from database</div>
              </div>
            </div>

            <!-- Break and Run Stat -->
            <div class="stat-management-card stat-winners-card">
              <div class="stat-header">
                <div class="stat-icon-large">🎯</div>
                <div class="stat-info">
                  <h3 class="stat-title">Break and Run</h3>
                  <div class="stat-mode">
                    <span class="badge badge-success">
                      🔄 Auto-Count
                    </span>
                  </div>
                </div>
              </div>
              <div class="stat-value-display">
                <div class="current-value">{{ statsStore?.totalBreakAndRun || 0 }}</div>
                <div class="stat-note">Auto-calculated from database</div>
              </div>
            </div>

            <!-- Total Tournaments Stat -->
            <div class="stat-management-card stat-tournaments-card">
              <div class="stat-header">
                <div class="stat-icon-large">🏆</div>
                <div class="stat-info">
                  <h3 class="stat-title">Tournaments Held</h3>
                  <div class="stat-mode">
                    <span 
                      class="badge" 
                      :class="statsStore?.isTournamentsManual ? 'badge-warning' : 'badge-success'"
                    >
                      {{ statsStore?.isTournamentsManual ? '✏️ Manual Override' : '🔄 Auto-Count' }}
                    </span>
                  </div>
                </div>
              </div>
              <div class="stat-value-display">
                <div class="current-value">{{ statsStore?.totalTournaments || 0 }}</div>
                <div class="stat-note">
                  {{ statsStore?.isTournamentsManual ? 'Includes offline events set by admin' : 'Auto-calculated from tournaments table' }}
                </div>
                <button 
                  class="btn btn-outline-primary btn-sm mt-2" 
                  @click="openStatModal('total_tournaments')"
                >
                  {{ statsStore?.isTournamentsManual ? 'Edit Manual Value' : 'Add Offline Count' }}
                </button>
              </div>
            </div>

            <!-- Total Matches Stat -->
            <div class="stat-management-card stat-matches-card">
              <div class="stat-header">
                <div class="stat-icon-large">🎮</div>
                <div class="stat-info">
                  <h3 class="stat-title">Matches Played</h3>
                  <div class="stat-mode">
                    <span class="badge badge-success">
                      🔄 Auto-Count
                    </span>
                  </div>
                </div>
              </div>
              <div class="stat-value-display">
                <div class="current-value">{{ statsStore?.totalMatches || 0 }}</div>
                <div class="stat-note">Auto-calculated from database</div>
              </div>
            </div>
          </div>

          <div class="stats-management-info mt-3">
            <div class="info-box">
              <strong>💡 How it works:</strong>
              <p>All statistics are automatically calculated from the database in real-time. Use the “Add Offline Count” button to include tournaments that were hosted offline and not published on the website.</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Stat Override Modal -->
    <div v-if="showStatModal" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Adjust {{ statModal.title }}</h2>
          <button class="btn btn-secondary btn-sm" @click="closeStatModal">Close</button>
        </div>
        <div class="modal-body">
          <p class="text-muted">{{ statModal.description }}</p>
          <div class="form-group">
            <label class="form-label">Manual Value</label>
            <input 
              type="number" 
              class="form-control"
              min="0"
              v-model.number="statModal.manualValue"
              placeholder="Enter total count"
            >
            <small class="form-text text-muted">
              Current auto-count: {{ statModal.autoValue }} {{ statModal.autoValue === 1 ? 'event' : 'events' }}
            </small>
          </div>
          <div class="form-group">
            <label class="form-label">Notes (optional)</label>
            <textarea 
              class="form-control" 
              rows="2" 
              v-model="statModal.notes"
              placeholder="e.g., Added 4 offline university tournaments"
            ></textarea>
          </div>
          <div class="info-box">
            <p class="mb-0">
              Leave the field empty and click <strong>Reset to Auto</strong> to use the automatic count from website tournaments only.
            </p>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeStatModal" :disabled="savingStat">Cancel</button>
          <button class="btn btn-warning" @click="resetStatOverride" :disabled="savingStat">
            Reset to Auto
          </button>
          <button class="btn btn-success" @click="saveStatOverride" :disabled="savingStat">
            {{ savingStat ? 'Saving...' : 'Save Manual Value' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Quick Actions Section -->
    <section class="section-quick-actions">
      <div class="card">
        <div class="card-header">
          <h2 class="card-title">⚡ Quick Actions</h2>
          <p class="card-subtitle">Frequently used admin operations</p>
        </div>
        <div class="card-body">
          <div class="quick-actions-grid">
            <router-link to="/tournaments" class="action-card action-create-tournament">
              <div class="action-icon">🎯</div>
              <div class="action-content">
                <h3 class="action-title">Create Tournament</h3>
                <p class="action-description">Start a new competition event</p>
              </div>
              <div class="action-arrow">→</div>
            </router-link>

            <router-link to="/players" class="action-card action-manage-players">
              <div class="action-icon">👥</div>
              <div class="action-content">
                <h3 class="action-title">Manage Players</h3>
                <p class="action-description">Edit stats, points, and profiles</p>
              </div>
              <div class="action-arrow">→</div>
            </router-link>

            <router-link to="/monitoring" class="action-card action-monitoring">
              <div class="action-icon">📊</div>
              <div class="action-content">
                <h3 class="action-title">Registration Monitoring</h3>
                <p class="action-description">Monitor duplicates and suspicious registrations</p>
              </div>
              <div class="action-arrow">→</div>
            </router-link>

            <router-link to="/unverified-users" class="action-card action-unverified">
              <div class="action-icon">📧</div>
              <div class="action-content">
                <h3 class="action-title">Unverified Users</h3>
                <p class="action-description">Manage users with unverified email addresses</p>
              </div>
              <div class="action-arrow">→</div>
            </router-link>

            <router-link to="/tv-display" class="action-card action-tv-display" target="_blank">
              <div class="action-icon">📺</div>
              <div class="action-content">
                <h3 class="action-title">TV Display</h3>
                <p class="action-description">Live leaderboard for TV screen (55" optimized)</p>
              </div>
              <div class="action-arrow">→</div>
            </router-link>

            <button @click="showErrorLog = true" class="action-card action-view-errors">
              <div class="action-icon">🐛</div>
              <div class="action-content">
                <h3 class="action-title">Error Logs</h3>
                <p class="action-description">View and export error logs</p>
              </div>
              <div class="action-arrow">→</div>
            </button>

            <router-link to="/leaderboard" class="action-card action-view-rankings">
              <div class="action-icon">📊</div>
              <div class="action-content">
                <h3 class="action-title">View Rankings</h3>
                <p class="action-description">Check current leaderboard</p>
              </div>
              <div class="action-arrow">→</div>
            </router-link>

            <div class="action-card action-system-info" @click="showSystemInfo">
              <div class="action-icon">⚙️</div>
              <div class="action-content">
                <h3 class="action-title">System Info</h3>
                <p class="action-description">View system status and logs</p>
              </div>
              <div class="action-arrow">→</div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- User Management Section -->
    <section class="section-user-management">
    <div class="card">
      <div class="card-header">
        <h2 class="card-title">👥 User Management</h2>
      </div>
      <div class="card-body">
        <!-- Search and Filter Bar -->
        <div class="search-filter-bar">
          <div class="search-box">
            <input 
              type="text" 
              class="form-control search-input" 
              v-model="searchQuery"
              placeholder="🔍 Search by name, email, card number, or phone..."
            >
            <button 
              v-if="searchQuery" 
              class="btn btn-sm btn-secondary clear-search"
              @click="clearSearch"
              title="Clear search"
            >
              ✕
            </button>
          </div>
          <div class="filter-group">
            <select class="form-control filter-select" v-model="filterMembership">
              <option value="">All Memberships</option>
              <option value="lite">🎱 Lite</option>
              <option value="plus">⭐ Plus</option>
              <option value="pro">💎 Pro</option>
              <option value="pro_max">🌟 Pro Max</option>
            </select>
            <select class="form-control filter-select" v-model="filterRole">
              <option value="">All Roles</option>
              <option value="player">🎯 Player</option>
              <option value="admin">👑 Admin</option>
            </select>
            <select class="form-control filter-select" v-model="filterStatus">
              <option value="">All Status</option>
              <option value="active">✅ Active</option>
              <option value="inactive">⛔ Inactive</option>
            </select>
          </div>
          <div class="search-results-info">
            <span class="results-count">
              Showing {{ filteredUsers.length }} of {{ users.length }} users
            </span>
          </div>
        </div>

        <div v-if="loading" class="loading">
          <div class="spinner"></div>
        </div>

        <div v-else-if="filteredUsers.length === 0" class="no-results">
          <p>😕 No users found matching your search criteria.</p>
          <button class="btn btn-secondary btn-sm" @click="clearAllFilters">Clear All Filters</button>
        </div>

        <template v-else>
          <!-- Desktop Table View -->
          <div class="table-container admin-table-container">
            <table class="table admin-users-table">
              <thead>
                <tr>
                  <th class="col-name">Name</th>
                  <th class="col-contact">Contact</th>
                  <th class="col-membership">Membership</th>
                  <th class="col-rank">Rank</th>
                  <th class="col-points">Pro/Stu Pts</th>
                  <th class="col-loyalty">Loyalty Pts</th>
                  <th class="col-role">Role</th>
                  <th class="col-status">Status</th>
                  <th class="col-actions">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="user in filteredUsers" :key="user.id">
                  <td class="col-name">
                    <div class="user-name-cell">
                      <strong>{{ user.name || 'N/A' }}</strong>
                      <span class="card-number-small">{{ user.membership_card_number || 'No Card' }}</span>
                    </div>
                  </td>
                  <td class="col-contact">
                    <div class="contact-cell">
                      <div class="contact-item">📧 {{ user.email }}</div>
                      <div class="contact-item" v-if="user.phone">📱 {{ user.phone }}</div>
                    </div>
                  </td>
                  <td class="col-membership">
                    <span class="membership-badge" :class="`membership-${user.membership_level}`">
                      <span v-if="user.membership_level === 'pro_max'">🌟</span>
                      <span v-else-if="user.membership_level === 'pro'">💎</span>
                      <span v-else-if="user.membership_level === 'plus'">⭐</span>
                      <span v-else>🎱</span>
                      {{ formatMembershipLevel(user.membership_level) }}
                    </span>
                  </td>
                  <td class="col-rank">
                    <span class="rank-badge-small" :class="`rank-${user.ranking_level}`">
                      {{ formatRankLevel(user.ranking_level) }}
                    </span>
                  </td>
                  <td class="col-points">
                    <div class="dual-points-cell">
                      <div class="points-row">
                        <span class="points-label-mini">👔</span>
                        <span class="points-value-mini">{{ user.pro_ranking_points || 0 }}</span>
                      </div>
                      <div class="points-row">
                        <span class="points-label-mini">🎓</span>
                        <span class="points-value-mini">{{ user.student_ranking_points || 0 }}</span>
                      </div>
                    </div>
                  </td>
                  <td class="col-loyalty">
                    <strong class="loyalty-points-value">
                      {{ user.loyalty_points?.toFixed(0) || '0' }}
                    </strong>
                  </td>
                  <td class="col-role">
                    <span class="badge" :class="user.role === 'admin' ? 'badge-warning' : 'badge-info'">
                      {{ user.role === 'admin' ? '👑' : '🎯' }}
                    </span>
                  </td>
                  <td class="col-status">
                    <span class="badge" :class="user.is_active ? 'badge-success' : 'badge-danger'">
                      {{ user.is_active ? '✅' : '⛔' }}
                    </span>
                  </td>
                  <td class="col-actions">
                    <div class="action-buttons">
                      <button 
                        class="btn btn-sm btn-primary" 
                        @click="viewUserDetails(user)"
                        title="View/Edit Details"
                      >
                        📝 Edit
                      </button>
                      <button 
                        class="btn btn-sm btn-warning" 
                        @click="openMembershipModal(user)"
                        title="Manage Membership"
                        :disabled="isCurrentUser(user)"
                      >
                        💳 Card
                      </button>
                      <button 
                        class="btn btn-sm btn-success" 
                        @click="openLoyaltyPointsModal(user)"
                        title="Manage Loyalty Points"
                      >
                        💰 Loyalty
                      </button>
                      <button 
                        class="btn btn-sm" 
                        :class="user.role === 'admin' ? 'btn-secondary' : 'btn-info'"
                        @click="toggleRole(user)"
                        :disabled="isCurrentUser(user)"
                        :title="user.role === 'admin' ? 'Make Player' : 'Make Admin'"
                      >
                        {{ user.role === 'admin' ? '👑 Admin' : '🎯 Player' }}
                      </button>
                      <button 
                        class="btn btn-sm" 
                        :class="user.is_active ? 'btn-danger' : 'btn-secondary'"
                        @click="toggleStatus(user)"
                        :disabled="isCurrentUser(user)"
                        :title="user.is_active ? 'Deactivate' : 'Activate'"
                      >
                        {{ user.is_active ? '⛔ Deactivate' : '✅ Activate' }}
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Mobile Card View -->
          <div class="mobile-users-grid">
          <div v-for="user in filteredUsers" :key="user.id" class="mobile-user-card" :class="`membership-card-${user.membership_level}`">
            <!-- Card Header: Name, Email, Status Badge -->
            <div class="mobile-user-header">
              <div class="mobile-user-info">
                <div class="mobile-user-name">{{ user.name || 'N/A' }}</div>
                <div class="mobile-user-email">{{ user.email }}</div>
              </div>
              <div class="mobile-user-badges">
                <span class="badge" :class="user.is_active ? 'badge-success' : 'badge-danger'">
                  {{ user.is_active ? '✅' : '⛔' }}
                </span>
                <span class="badge" :class="user.role === 'admin' ? 'badge-warning' : 'badge-info'">
                  {{ user.role === 'admin' ? '👑' : '🎯' }}
                </span>
              </div>
            </div>

            <!-- Card Details: 2x2 Grid -->
            <div class="mobile-user-details">
              <div class="mobile-detail-item">
                <span class="mobile-detail-label">Card #</span>
                <span class="mobile-detail-value">{{ user.membership_card_number || 'N/A' }}</span>
              </div>
              <div class="mobile-detail-item">
                <span class="mobile-detail-label">Phone</span>
                <span class="mobile-detail-value">{{ user.phone || 'N/A' }}</span>
              </div>
              <div class="mobile-detail-item">
                <span class="mobile-detail-label">Membership</span>
                <span class="mobile-detail-value">
                  {{ formatMembershipLevel(user.membership_level) }}
                  <span v-if="user.membership_level === 'pro_max'">🌟</span>
                  <span v-else-if="user.membership_level === 'pro'">💎</span>
                  <span v-else-if="user.membership_level === 'plus'">⭐</span>
                  <span v-else>🎱</span>
                </span>
              </div>
              <div class="mobile-detail-item">
                <span class="mobile-detail-label">Rank</span>
                <span class="mobile-detail-value">{{ formatRankLevel(user.ranking_level) }}</span>
              </div>
              <div class="mobile-detail-item">
                <span class="mobile-detail-label">Loyalty Points</span>
                <span class="mobile-detail-value">{{ user.loyalty_points?.toFixed(2) || '0.00' }}</span>
              </div>
            </div>

            <!-- Action Buttons: 2x2 Grid -->
            <div class="mobile-user-actions">
              <button 
                class="mobile-action-btn primary" 
                @click="viewUserDetails(user)"
              >
                📝 Edit
              </button>
              <button 
                class="mobile-action-btn warning" 
                @click="openMembershipModal(user)"
                :disabled="isCurrentUser(user)"
              >
                💳 Card
              </button>
              <button 
                class="mobile-action-btn secondary" 
                @click="openLoyaltyPointsModal(user)"
              >
                💰 Loyalty
              </button>
              <button 
                class="mobile-action-btn" 
                :class="user.is_active ? 'danger' : 'secondary'"
                @click="toggleStatus(user)"
                :disabled="isCurrentUser(user)"
              >
                {{ user.is_active ? '⛔ Block' : '✅ Allow' }}
              </button>
            </div>
          </div>
        </div>
        </template>
      </div>
    </div>
    </section>

    <!-- User Details Modal -->
    <div v-if="showUserModal" class="modal">
      <div class="modal-content modal-large">
        <div class="modal-header">
          <h2>👤 User Details: {{ selectedUser?.name }}</h2>
          <button class="btn btn-secondary btn-sm" @click="closeUserModal">Close</button>
        </div>
        <div class="modal-body">
          <div class="user-detail-grid">
            <div class="detail-section">
              <h3>📋 Basic Information</h3>
              <div class="form-group">
                <label class="form-label">Name</label>
                <input type="text" class="form-control" v-model="userForm.name">
              </div>
              <div class="form-group">
                <label class="form-label">Email</label>
                <input type="email" class="form-control" v-model="userForm.email">
              </div>
              <div class="form-group">
                <label class="form-label">Phone</label>
                <input type="tel" class="form-control" v-model="userForm.phone">
              </div>
              <div class="form-group">
                <label class="form-label">Date of Birth</label>
                <input type="text" class="form-control" v-model="userForm.birthday" placeholder="DD/MM/YYYY">
                <small class="form-text">Format: DD/MM/YYYY (e.g., 15/03/2000)</small>
              </div>
              <div class="form-group">
                <label class="form-label">Address</label>
                <textarea 
                  class="form-control" 
                  v-model="userForm.address"
                  rows="2"
                  placeholder="Enter address"
                ></textarea>
              </div>
              <div class="form-group">
                <label class="form-label">ID Card / Driver License</label>
                <input 
                  type="text" 
                  class="form-control" 
                  v-model="userForm.id_card"
                  placeholder="e.g., AA123456 or DL12345678"
                >
                <small class="form-text">For verification and VIP services</small>
              </div>
            </div>

            <div class="detail-section">
              <h3>💳 Membership Information</h3>
              <div class="membership-preview">
                <div class="membership-card" :class="`card-${selectedUser?.membership_level}`">
                  <div class="card-header-mini">
                    <span class="card-title-mini">Joy Billiards NZ</span>
                  </div>
                  <div class="card-number">{{ selectedUser?.membership_card_number }}</div>
                  <div class="card-member-name">{{ selectedUser?.name }}</div>
                  <div class="card-level">
                    {{ formatMembershipLevel(selectedUser?.membership_level) }} Member
                  </div>
                </div>
              </div>
              <div class="form-group">
                <label class="form-label">Card Number</label>
                <input type="text" class="form-control" v-model="userForm.membership_card_number" disabled>
              </div>
              <div class="form-group">
                <label class="form-label">Expires At</label>
                <input type="date" class="form-control" v-model="userForm.membership_expires_at">
              </div>
            </div>

            <div class="detail-section">
              <h3>📊 Statistics</h3>
              <div class="stats-grid">
                <div class="stat-box">
                  <div class="stat-value">{{ getUserCurrentYearPoints(selectedUser) }}</div>
                  <div class="stat-label">Ranking Points ({{ currentYear }})</div>
                </div>
                <div class="stat-box">
                  <div class="stat-label">Overall W/L</div>
                  <div class="stat-value">{{ selectedUser?.wins || 0 }}W / {{ selectedUser?.losses || 0 }}L</div>
                  <div class="stat-subtext">Matches: {{ (selectedUser?.wins || 0) + (selectedUser?.losses || 0) }}</div>
                </div>
                <div class="stat-box">
                  <div class="stat-value">
                    <span :class="getWinRateClass(selectedUser)">
                      {{ calculateWinRate(selectedUser) }}%
                    </span>
                  </div>
                  <div class="stat-label">📈 Win Rate</div>
                </div>
                <div class="stat-box">
                  <div class="stat-value">{{ selectedUser?.break_and_run_count || 0 }}</div>
                  <div class="stat-label">🎯 Break & Run</div>
                </div>
                <div class="stat-box stat-box-division pro">
                  <div class="stat-label">👔 Pro Division</div>
                  <div class="stat-value-small">{{ getDivisionValue(selectedUser, 'pro', 'wins') }}W / {{ getDivisionValue(selectedUser, 'pro', 'losses') }}L</div>
                  <div class="stat-subtext">Win Rate: {{ calculateDivisionWinRate(selectedUser, 'pro') }}%</div>
                  <div class="stat-subtext">Matches: {{ getDivisionMatches(selectedUser, 'pro') }}</div>
                  <div class="stat-subtext">Break & Run: {{ getDivisionValue(selectedUser, 'pro', 'break_and_run_count') }}</div>
                </div>
                <div class="stat-box stat-box-division student">
                  <div class="stat-label">🎓 Student Division</div>
                  <div class="stat-value-small">{{ getDivisionValue(selectedUser, 'student', 'wins') }}W / {{ getDivisionValue(selectedUser, 'student', 'losses') }}L</div>
                  <div class="stat-subtext">Win Rate: {{ calculateDivisionWinRate(selectedUser, 'student') }}%</div>
                  <div class="stat-subtext">Matches: {{ getDivisionMatches(selectedUser, 'student') }}</div>
                  <div class="stat-subtext">Break & Run: {{ getDivisionValue(selectedUser, 'student', 'break_and_run_count') }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeUserModal">Cancel</button>
          <button class="btn btn-success" @click="saveUserDetails">Save Changes</button>
        </div>
      </div>
    </div>

    <!-- Membership Management Modal -->
    <div v-if="showMembershipModal" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>💳 Manage Membership: {{ selectedUser?.name }}</h2>
          <button class="btn btn-secondary btn-sm" @click="closeMembershipModal">Close</button>
        </div>
        <div class="modal-body">
          <div class="current-membership-info">
            <p><strong>Current Level:</strong> 
              <span class="membership-badge" :class="`membership-${selectedUser?.membership_level}`">
                {{ formatMembershipLevel(selectedUser?.membership_level) }}
              </span>
            </p>
            <p><strong>Card Number:</strong> {{ selectedUser?.membership_card_number }}</p>
            <p><strong>Expires:</strong> {{ formatDate(selectedUser?.membership_expires_at) }}</p>
          </div>

          <div class="form-group">
            <label class="form-label">Membership Level</label>
            <select class="form-control" v-model="membershipForm.level">
              <option value="lite">🎱 Lite (Free - Permanent)</option>
              <option value="plus">⭐ Plus (≥200 NZD - 12 months)</option>
              <option value="pro">💎 Pro (≥500 NZD - 12 months)</option>
              <option value="pro_max">🌟 Pro Max (≥1000 NZD - 12 months)</option>
            </select>
            <small class="form-text">Expiry date will be automatically set to 12 months from today for Plus/Pro/Pro Max</small>
          </div>

          <div class="membership-preview-box">
            <h4>Preview:</h4>
            <div class="membership-card-mini" :class="`card-${membershipForm.level}`">
              <div class="card-level-label">{{ formatMembershipLevel(membershipForm.level) }}</div>
              <div class="card-icon">
                <span v-if="membershipForm.level === 'pro_max'">🌟</span>
                <span v-else-if="membershipForm.level === 'pro'">💎</span>
                <span v-else-if="membershipForm.level === 'plus'">⭐</span>
                <span v-else>🎱</span>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeMembershipModal">Cancel</button>
          <button class="btn btn-success" @click="updateMembership">Update Membership</button>
        </div>
      </div>
    </div>


    <!-- Loyalty Points Modal -->
    <div v-if="showLoyaltyPointsModal" class="modal">
      <div class="modal-overlay" @click="closeLoyaltyPointsModal"></div>
      <div class="modal-content modal-lg">
        <div class="modal-header">
          <h3 class="modal-title">💰 Manage Loyalty Points</h3>
          <button class="btn btn-secondary btn-sm" @click="closeLoyaltyPointsModal">Close</button>
        </div>
        <div class="modal-body">
          <!-- User Info -->
          <div class="loyalty-user-info">
            <div class="user-avatar">
              <div class="avatar-circle">{{ selectedUser?.name?.charAt(0) || '?' }}</div>
            </div>
            <div class="user-details">
              <h4>{{ selectedUser?.name }}</h4>
              <p class="user-email">{{ selectedUser?.email }}</p>
              <div class="user-membership">
                <span class="membership-badge" :class="`membership-${selectedUser?.membership_level}`">
                  {{ formatMembershipLevel(selectedUser?.membership_level) }}
                </span>
                <span class="multiplier-badge">
                  {{ getMembershipMultiplier(selectedUser?.membership_level) }}x Points
                </span>
              </div>
              <div class="current-balance">
                <strong>Current Balance:</strong>
                <span class="balance-amount">{{ selectedUser?.loyalty_points || 0 }} Points</span>
              </div>
            </div>
          </div>

          <!-- Operation Type -->
          <div class="form-group">
            <label class="form-label">Operation Type</label>
            <div class="radio-group">
              <label class="radio-option">
                <input type="radio" v-model="loyaltyForm.type" value="add" />
                <span class="radio-label">➕ Add Loyalty Points (Record Consumption)</span>
              </label>
              <label class="radio-option">
                <input type="radio" v-model="loyaltyForm.type" value="deduct" />
                <span class="radio-label">➖ Deduct Loyalty Points (Redemption)</span>
              </label>
            </div>
          </div>

          <!-- Add Points Form -->
          <template v-if="loyaltyForm.type === 'add'">
            <div class="form-group">
              <label class="form-label">Consumption Amount (NZD)</label>
              <input 
                type="number" 
                class="form-control form-control-lg" 
                v-model.number="loyaltyForm.amountNZD"
                min="0"
                step="0.01"
                placeholder="Enter amount spent (e.g., 50.00)"
                @input="calculateLoyaltyPoints"
              >
              <small class="form-text">Enter the amount customer spent in NZD</small>
            </div>

            <div class="points-calculation" v-if="loyaltyForm.amountNZD > 0">
              <div class="calculation-row">
                <span>Amount:</span>
                <strong>NZD ${{ loyaltyForm.amountNZD.toFixed(2) }}</strong>
              </div>
              <div class="calculation-row">
                <span>Multiplier:</span>
                <strong>{{ getMembershipMultiplier(selectedUser?.membership_level) }}x</strong>
              </div>
              <div class="calculation-row calculation-total">
                <span>Loyalty Points to Add:</span>
                <strong class="points-earned">{{ loyaltyForm.pointsEarned.toFixed(2) }} Points</strong>
              </div>
            </div>
          </template>

          <!-- Deduct Points Form -->
          <template v-else>
            <div class="form-group">
              <label class="form-label">Loyalty Points to Deduct</label>
              <input 
                type="number" 
                class="form-control form-control-lg" 
                v-model.number="loyaltyForm.pointsToDeduct"
                min="0"
                step="0.01"
                :max="selectedUser?.loyalty_points || 0"
                placeholder="Enter points to deduct"
              >
              <small class="form-text">
                Available: {{ selectedUser?.loyalty_points || 0 }} Loyalty Points
              </small>
            </div>
          </template>

          <!-- Description -->
          <div class="form-group">
            <label class="form-label">Description</label>
            <textarea 
              class="form-control" 
              v-model="loyaltyForm.description"
              rows="3"
              :placeholder="loyaltyForm.type === 'add' ? 'e.g., Table rental + drinks' : 'e.g., Redeemed for 1 hour free play'"
            ></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeLoyaltyPointsModal" :disabled="loading">Cancel</button>
          <button 
            class="btn" 
            :class="loyaltyForm.type === 'add' ? 'btn-success' : 'btn-warning'"
            @click="recordLoyaltyPoints"
            :disabled="!isLoyaltyFormValid || loading"
          >
            <span v-if="loading">⏳ Processing...</span>
            <span v-else>{{ loyaltyForm.type === 'add' ? '💰 Add Loyalty Points' : '🎁 Deduct Loyalty Points' }}</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Error Log Viewer -->
    <ErrorLogViewer v-model="showErrorLog" />
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '../stores/authStore'
import { usePlayerStore } from '../stores/playerStore'
import { useTournamentStore } from '../stores/tournamentStore'
import { useStatsStore } from '../stores/statsStore'
import { supabase } from '../config/supabase'
import ErrorLogViewer from '../components/ErrorLogViewer.vue'

export default {
  name: 'AdminDashboard',
  components: {
    ErrorLogViewer
  },
  setup() {
    const authStore = useAuthStore()
    const showErrorLog = ref(false)
    const playerStore = usePlayerStore()
    const tournamentStore = useTournamentStore()
    const statsStore = useStatsStore()

    const users = ref([])
    const loading = ref(true)
    const pointHistory = ref([])
    const currentYear = new Date().getFullYear()
    
    // User Details Modal
    const showUserModal = ref(false)
    const selectedUser = ref(null)
    const userForm = ref({
      name: '',
      email: '',
      phone: '',
      birthday: '',
      address: '',
      id_card: '',
      membership_card_number: '',
      membership_expires_at: ''
    })
    
    // Membership Modal
    const showMembershipModal = ref(false)
    const membershipForm = ref({
      level: 'bronze',
      expires_at: ''
    })

    // Loyalty Points Management
    const showLoyaltyPointsModal = ref(false)
    const loyaltyForm = ref({
      type: 'add', // 'add' or 'deduct'
      amountNZD: 0,
      pointsEarned: 0,
      pointsToDeduct: 0,
      description: ''
    })

    const showStatModal = ref(false)
    const statModal = ref({
      metric: '',
      title: '',
      description: '',
      manualValue: 0,
      notes: '',
      autoValue: 0,
      isManual: false
    })
    const savingStat = ref(false)

    const statMeta = {
      total_tournaments: {
        title: 'Tournaments Held',
        description: 'Include offline tournaments that were not published on the website.'
      }
    }

    // Search and Filter
    const searchQuery = ref('')
    const filterMembership = ref('')
    const filterRole = ref('')
    const filterStatus = ref('')

    // Computed: Filtered Users
    const filteredUsers = computed(() => {
      let result = users.value

      // Search filter
      if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase().trim()
        result = result.filter(user => {
          return (
            user.name?.toLowerCase().includes(query) ||
            user.email?.toLowerCase().includes(query) ||
            user.phone?.toLowerCase().includes(query) ||
            user.membership_card_number?.toLowerCase().includes(query)
          )
        })
      }

      // Membership filter
      if (filterMembership.value) {
        result = result.filter(user => user.membership_level === filterMembership.value)
      }

      // Role filter
      if (filterRole.value) {
        result = result.filter(user => user.role === filterRole.value)
      }

      // Status filter
      if (filterStatus.value) {
        if (filterStatus.value === 'active') {
          result = result.filter(user => user.is_active === true)
        } else if (filterStatus.value === 'inactive') {
          result = result.filter(user => user.is_active === false)
        }
      }

      return result
    })

    const clearSearch = () => {
      searchQuery.value = ''
    }

    const clearAllFilters = () => {
      searchQuery.value = ''
      filterMembership.value = ''
      filterRole.value = ''
      filterStatus.value = ''
    }

    const getStatState = (metric) => {
      return statsStore?.stats?.[metric] || { value: 0, notes: '', autoValue: 0, isManual: false }
    }

    const openStatModal = (metric) => {
      const meta = statMeta[metric]
      if (!meta) return
      const statState = getStatState(metric)
      statModal.value = {
        metric,
        title: meta.title,
        description: meta.description,
        manualValue: statState.value ?? 0,
        notes: statState.notes || '',
        autoValue: statState.autoValue ?? statState.value ?? 0,
        isManual: statState.isManual || false
      }
      showStatModal.value = true
    }

    const closeStatModal = () => {
      showStatModal.value = false
      statModal.value = {
        metric: '',
        title: '',
        description: '',
        manualValue: 0,
        notes: '',
        autoValue: 0,
        isManual: false
      }
    }

    const saveStatOverride = async () => {
      if (!statModal.value.metric) return
      if (statModal.value.manualValue === '' || statModal.value.manualValue === null) {
        alert('Please enter a manual value')
        return
      }
      const manualValue = Number(statModal.value.manualValue)
      if (Number.isNaN(manualValue) || manualValue < 0) {
        alert('Manual value must be a number greater than or equal to 0')
        return
      }

      savingStat.value = true
      try {
        const { error } = await supabase.rpc('admin_set_stat_override', {
          p_metric: statModal.value.metric,
          p_manual_value: Math.round(manualValue),
          p_notes: statModal.value.notes || null
        })

        if (error) throw error
        await statsStore.fetchStats()
        closeStatModal()
        alert('✅ Manual value saved!')
      } catch (err) {
        console.error('Error saving stat override:', err)
        alert('Error saving manual value: ' + err.message)
      } finally {
        savingStat.value = false
      }
    }

    const resetStatOverride = async () => {
      if (!statModal.value.metric) return
      if (!confirm('Reset this statistic to the automatic count?')) return

      savingStat.value = true
      try {
        const { error } = await supabase.rpc('admin_set_stat_override', {
          p_metric: statModal.value.metric,
          p_manual_value: null,
          p_notes: null
        })
        if (error) throw error
        await statsStore.fetchStats()
        closeStatModal()
        alert('✅ Statistic reset to auto-count')
      } catch (err) {
        console.error('Error resetting stat override:', err)
        alert('Error resetting statistic: ' + err.message)
      } finally {
        savingStat.value = false
      }
    }

    const getDivisionStatKey = (division, field) => {
      const prefix = division === 'student' ? 'student' : 'pro'
      if (field === 'break_and_run_count') {
        return `${prefix}_break_and_run_count`
      }
      return `${prefix}_${field}`
    }

    const getDivisionValue = (user, division, field) => {
      if (!user) return 0
      const key = getDivisionStatKey(division, field)
      return user[key] ?? 0
    }

    const getDivisionMatches = (user, division) => {
      return getDivisionValue(user, division, 'wins') + getDivisionValue(user, division, 'losses')
    }

    const calculateDivisionWinRate = (user, division) => {
      const wins = getDivisionValue(user, division, 'wins')
      const losses = getDivisionValue(user, division, 'losses')
      const total = wins + losses
      if (total === 0) return '0.0'
      return ((wins / total) * 100).toFixed(1)
    }

    const loadData = async () => {
      loading.value = true
      
      try {
        // Load stats and point history
        await Promise.all([
          playerStore.fetchPlayers(),
          tournamentStore.fetchTournaments(),
          statsStore.fetchStats()
        ])

        // Load users with fresh data using secure RPC function
        const { data, error } = await supabase
          .rpc('admin_get_all_users')

        if (error) throw error

        users.value = data || []
        console.log('Loaded users:', users.value.length)

        // Load ranking point history for ranking points calculation
        const { data: historyData, error: historyError } = await supabase
          .from('ranking_point_history')  // 改为新表名
          .select('*')

        if (historyError) throw historyError
        pointHistory.value = historyData || []
      } catch (err) {
        console.error('Error loading data:', err)
      } finally {
        loading.value = false
      }
    }

    const isCurrentUser = (user) => {
      return user.auth_id === authStore.user?.id || user.email === authStore.user?.email
    }

    const toggleRole = async (user) => {
      const newRole = user.role === 'admin' ? 'player' : 'admin'
      const confirmMsg = `Change ${user.name || user.email}'s role to ${newRole}?`
      
      if (!window.confirm(confirmMsg)) return

      try {
        // Direct database update
        const { data, error } = await supabase
          .from('users')
          .update({ role: newRole })
          .eq('id', user.id)
          .select()

        if (error) throw error

        // Update local state immediately
        const index = users.value.findIndex(u => u.id === user.id)
        if (index !== -1 && data && data[0]) {
          users.value[index] = data[0]
        }

        alert('Role updated successfully!')
      } catch (err) {
        console.error('Error updating role:', err)
        alert('Error updating role: ' + err.message)
      }
    }

    const toggleStatus = async (user) => {
      const newStatus = !user.is_active
      const action = newStatus ? 'activate' : 'deactivate'
      const confirmMsg = `Are you sure you want to ${action} ${user.name || user.email}?`
      
      if (!window.confirm(confirmMsg)) return

      try {
        // Direct database update
        const { data, error } = await supabase
          .from('users')
          .update({ is_active: newStatus })
          .eq('id', user.id)
          .select()

        if (error) throw error

        // Update local state immediately
        const index = users.value.findIndex(u => u.id === user.id)
        if (index !== -1 && data && data[0]) {
          users.value[index] = data[0]
        }

        alert(`User ${action}d successfully!`)
      } catch (err) {
        console.error('Error updating status:', err)
        alert('Error updating status: ' + err.message)
      }
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

    const formatMembershipLevel = (level) => {
      const levels = {
        'lite': 'Lite',
        'plus': 'Plus',
        'pro': 'Pro',
        'pro_max': 'Pro Max'
      }
      return levels[level] || 'Lite'
    }

    const formatRankLevel = (level) => {
      if (!level) return 'Beginner'
      return level.split('_').map(word => 
        word.charAt(0).toUpperCase() + word.slice(1)
      ).join(' ')
    }

    const viewUserDetails = (user) => {
      selectedUser.value = user
      // Format birthday from YYYY-MM-DD to DD/MM/YYYY
      let formattedBirthday = ''
      if (user.birthday) {
        const date = new Date(user.birthday)
        const day = String(date.getDate()).padStart(2, '0')
        const month = String(date.getMonth() + 1).padStart(2, '0')
        const year = date.getFullYear()
        formattedBirthday = `${day}/${month}/${year}`
      }
      
      userForm.value = {
        name: user.name || '',
        email: user.email || '',
        phone: user.phone || '',
        birthday: formattedBirthday,
        address: user.address || '',
        id_card: user.id_card || '',
        membership_card_number: user.membership_card_number || '',
        membership_expires_at: user.membership_expires_at ? 
          new Date(user.membership_expires_at).toISOString().split('T')[0] : ''
      }
      showUserModal.value = true
    }

    const closeUserModal = () => {
      showUserModal.value = false
      selectedUser.value = null
    }

    const saveUserDetails = async () => {
      if (!selectedUser.value) return

      try {
        // Convert DD/MM/YYYY to YYYY-MM-DD for database
        let birthdayISO = null
        if (userForm.value.birthday) {
          const parts = userForm.value.birthday.split('/')
          if (parts.length === 3) {
            const day = parts[0].padStart(2, '0')
            const month = parts[1].padStart(2, '0')
            const year = parts[2]
            birthdayISO = `${year}-${month}-${day}`
          }
        }
        
        const { error } = await supabase
          .from('users')
          .update({
            name: userForm.value.name,
            email: userForm.value.email,
            phone: userForm.value.phone,
            birthday: birthdayISO,
            address: userForm.value.address,
            id_card: userForm.value.id_card,
            membership_expires_at: userForm.value.membership_expires_at || null
          })
          .eq('id', selectedUser.value.id)

        if (error) throw error

        alert(`✅ Successfully updated ${userForm.value.name}'s details!`)
        closeUserModal()
        await loadData()
      } catch (err) {
        console.error('Error updating user:', err)
        alert('Error updating user: ' + err.message)
      }
    }

    const openMembershipModal = (user) => {
      selectedUser.value = user
      membershipForm.value = {
        level: user.membership_level || 'lite',
        expires_at: user.membership_expires_at ? 
          new Date(user.membership_expires_at).toISOString().split('T')[0] : ''
      }
      showMembershipModal.value = true
    }

    const closeMembershipModal = () => {
      showMembershipModal.value = false
      selectedUser.value = null
    }

    const updateMembership = async () => {
      if (!selectedUser.value) return

      const confirmMsg = `Update ${selectedUser.value.name}'s membership to ${formatMembershipLevel(membershipForm.value.level)}?`
      if (!confirm(confirmMsg)) return

      try {
        // Calculate expiry date based on membership level
        let expiresAt = null
        
        if (membershipForm.value.level !== 'lite') {
          // Plus, Pro, and Pro Max all have 12 months validity
          const expiryDate = new Date()
          expiryDate.setFullYear(expiryDate.getFullYear() + 1) // Add 12 months
          expiresAt = expiryDate.toISOString()
        }
        // Lite membership has no expiry (null)

        const { error } = await supabase
          .from('users')
          .update({
            membership_level: membershipForm.value.level,
            membership_expires_at: expiresAt
          })
          .eq('id', selectedUser.value.id)

        if (error) throw error

        const expiryMsg = expiresAt ? `\nExpires: ${new Date(expiresAt).toLocaleDateString()}` : '\nExpires: Never (Permanent)'
        alert(`✅ Membership updated to ${formatMembershipLevel(membershipForm.value.level)}!${expiryMsg}`)
        closeMembershipModal()
        await loadData()
      } catch (err) {
        console.error('Error updating membership:', err)
        alert('Error updating membership: ' + err.message)
      }
    }

    // Helper function to get user's current year points
    const getUserCurrentYearPoints = (user) => {
      if (!user) return 0
      return pointHistory.value
        .filter(p => p.user_id === user.id && p.year === currentYear)
        .reduce((sum, p) => sum + (p.points_change || 0), 0)
    }

    // Calculate Win Rate
    const calculateWinRate = (user) => {
      if (!user) return '0.0'
      const wins = user.wins || 0
      const losses = user.losses || 0
      const total = wins + losses
      if (total === 0) return '0.0'
      return ((wins / total) * 100).toFixed(1)
    }

    // Get Win Rate Class for color coding
    const getWinRateClass = (user) => {
      const rate = parseFloat(calculateWinRate(user))
      if (rate >= 60) return 'win-rate-high'
      if (rate >= 40) return 'win-rate-medium'
      return 'win-rate-low'
    }

    // Loyalty Points Functions
    const getMembershipMultiplier = (level) => {
      const multipliers = {
        'lite': 1.0,
        'plus': 1.2,
        'pro': 1.4,
        'pro_max': 1.6
      }
      return multipliers[level] || 1.0
    }

    const calculateLoyaltyPoints = () => {
      if (loyaltyForm.value.amountNZD > 0 && selectedUser.value) {
        const multiplier = getMembershipMultiplier(selectedUser.value.membership_level)
        loyaltyForm.value.pointsEarned = loyaltyForm.value.amountNZD * multiplier
      } else {
        loyaltyForm.value.pointsEarned = 0
      }
    }

    const isLoyaltyFormValid = computed(() => {
      if (loyaltyForm.value.type === 'add') {
        return loyaltyForm.value.amountNZD > 0
      } else {
        return loyaltyForm.value.pointsToDeduct > 0 && 
               loyaltyForm.value.pointsToDeduct <= (selectedUser.value?.loyalty_points || 0)
      }
    })

    const openLoyaltyPointsModal = (user) => {
      selectedUser.value = user
      loyaltyForm.value = {
        type: 'add',
        amountNZD: 0,
        pointsEarned: 0,
        pointsToDeduct: 0,
        description: ''
      }
      showLoyaltyPointsModal.value = true
    }

    const closeLoyaltyPointsModal = () => {
      showLoyaltyPointsModal.value = false
      selectedUser.value = null
    }

    const recordLoyaltyPoints = async () => {
      if (!selectedUser.value) return

      // 添加 loading 状态，防止重复点击
      if (loading.value) {
        console.log('Already processing, please wait...')
        return
      }

      loading.value = true

      try {
        if (loyaltyForm.value.type === 'add') {
          // Record consumption and add loyalty points
          const { data, error } = await supabase.rpc('admin_record_loyalty_points', {
            p_user_id: selectedUser.value.id,
            p_amount_nzd: loyaltyForm.value.amountNZD,
            p_description: loyaltyForm.value.description || 'Consumption',
            p_recorded_by: authStore.user.id
          })

          if (error) throw error

          alert(`✅ Successfully added ${data.points_earned.toFixed(2)} Loyalty Points!\nNew balance: ${data.new_balance.toFixed(2)} Loyalty Points`)
        } else {
          // Deduct loyalty points
          const { data, error } = await supabase.rpc('admin_deduct_loyalty_points', {
            p_user_id: selectedUser.value.id,
            p_points_to_deduct: loyaltyForm.value.pointsToDeduct,
            p_description: loyaltyForm.value.description || 'Loyalty Points redemption',
            p_recorded_by: authStore.user.id
          })

          if (error) throw error

          alert(`✅ Successfully deducted ${data.points_deducted.toFixed(2)} Loyalty Points!\nNew balance: ${data.new_balance.toFixed(2)} Loyalty Points`)
        }

        closeLoyaltyPointsModal()
        await loadData()
      } catch (err) {
        console.error('Error recording loyalty points:', err)
        alert('Error: ' + err.message)
      } finally {
        // 确保 loading 状态被重置
        loading.value = false
      }
    }

    // System Info
    const showSystemInfo = () => {
      alert('📊 System Information\n\nVersion: 4.0\nStatus: Production Ready\nDatabase: Supabase\nFramework: Vue 3 + Vite\n\nAll statistics are auto-calculated in real-time.\n\nFor detailed logs and monitoring, check your Supabase dashboard.')
    }

    onMounted(() => {
      loadData()
    })

    return {
      authStore,
      playerStore,
      tournamentStore,
      statsStore,
      users,
      loading,
      pointHistory,
      currentYear,
      getUserCurrentYearPoints,
      calculateWinRate,
      calculateDivisionWinRate,
      getWinRateClass,
      getDivisionValue,
      getDivisionMatches,
      isCurrentUser,
      toggleRole,
      toggleStatus,
      formatDate,
      formatMembershipLevel,
      formatRankLevel,
      showUserModal,
      selectedUser,
      userForm,
      viewUserDetails,
      closeUserModal,
      saveUserDetails,
      showMembershipModal,
      membershipForm,
      openMembershipModal,
      closeMembershipModal,
      updateMembership,
      showSystemInfo,
      showErrorLog,
      showLoyaltyPointsModal,
      loyaltyForm,
      getMembershipMultiplier,
      calculateLoyaltyPoints,
      isLoyaltyFormValid,
      openLoyaltyPointsModal,
      closeLoyaltyPointsModal,
      recordLoyaltyPoints,
      // Search and Filter
      searchQuery,
      filterMembership,
      filterRole,
      filterStatus,
      filteredUsers,
      clearSearch,
      clearAllFilters,
      showStatModal,
      statModal,
      openStatModal,
      closeStatModal,
      saveStatOverride,
      resetStatOverride,
      savingStat
    }
  }
}
</script>

<style scoped>
.admin-dashboard {
  max-width: 100%;
}

.page-header {
  margin-bottom: 2rem;
}

.page-header h1 {
  font-size: 2rem;
  font-weight: 600;
  color: var(--dark-color);
  margin-bottom: 0.5rem;
}

.page-header p {
  color: var(--text-secondary);
  font-size: 1.125rem;
}

.dashboard-stats {
  margin-bottom: 2rem;
}

.stat-card {
  text-align: center;
  padding: 2rem;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

.stat-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.stat-number {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--primary-color);
  margin-bottom: 0.5rem;
}

.stat-label {
  font-size: 1rem;
  color: var(--text-secondary);
  font-weight: 500;
}

.action-buttons {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

@media (max-width: 768px) {
  .page-header h1 {
    font-size: 1.5rem;
  }

  .stat-card {
    padding: 1.5rem;
  }

  .stat-number {
    font-size: 2rem;
  }

  .action-buttons {
    flex-direction: column;
  }

  .action-buttons .btn {
    width: 100%;
  }
}

/* Membership Badge */
.membership-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.25rem 0.75rem;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.875rem;
}

.membership-badge.membership-pro_max {
  background: linear-gradient(135deg, #FF6B6B, #4ECDC4);
  color: white;
  font-weight: 700;
}

.membership-badge.membership-pro {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
}

.membership-badge.membership-plus {
  background: linear-gradient(135deg, #f093fb, #f5576c);
  color: white;
}

.membership-badge.membership-lite {
  background: linear-gradient(135deg, #a8edea, #fed6e3);
  color: #1a1a2e;
}

/* Dual Points Cell */
.dual-points-cell {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  align-items: center;
}

.points-row {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.875rem;
}

.points-label-mini {
  font-size: 0.75rem;
}

.points-value-mini {
  font-weight: 600;
  color: #1a1a2e;
}

.rank-badge-small {
  display: inline-block;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
  color: white;
}

.rank-badge-small.rank-hall_of_fame { background: #FFD700; color: #1a1a2e; }
.rank-badge-small.rank-pro_level { background: #DC3545; }
.rank-badge-small.rank-grand_master { background: #6F42C1; }
.rank-badge-small.rank-master { background: #E83E8C; }
.rank-badge-small.rank-elite { background: #FD7E14; }
.rank-badge-small.rank-expert { background: #FFC107; color: #1a1a2e; }
.rank-badge-small.rank-advance { background: #28A745; }
.rank-badge-small.rank-intermediate { background: #17A2B8; }
.rank-badge-small.rank-beginner { background: #6C757D; }

.points-display {
  font-size: 1.1rem;
  font-weight: 700;
  color: #667eea;
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
  border-radius: 16px;
  max-width: 600px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.3);
}

.modal-content.modal-large {
  max-width: 900px;
}

.modal-header {
  padding: 1.5rem;
  border-bottom: 2px solid #dee2e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  border-radius: 16px 16px 0 0;
}

.modal-header h2 {
  font-size: 1.5rem;
  font-weight: 600;
  margin: 0;
}

.modal-body {
  padding: 2rem;
}

.modal-footer {
  padding: 1.5rem;
  border-top: 2px solid #dee2e6;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  background: #f8f9fa;
  border-radius: 0 0 16px 16px;
}

/* User Detail Grid */
.user-detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
}

.detail-section {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 12px;
  border: 2px solid #e9ecef;
}

.detail-section h3 {
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 1rem;
  color: #1a1a2e;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

.stat-box {
  background: white;
  padding: 1rem;
  border-radius: 8px;
  text-align: center;
  border: 2px solid #e9ecef;
}

.stat-box .stat-value {
  font-size: 1.75rem;
  font-weight: 700;
  color: #667eea;
}

.stat-value-small {
  font-size: 1.2rem;
  font-weight: 700;
  color: #1a1a2e;
}

.stat-subtext {
  margin-top: 0.35rem;
  font-size: 0.9rem;
  color: #6c757d;
}

.stat-box-division {
  text-align: left;
  border: 2px solid #dfe7ff;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08), rgba(118, 75, 162, 0.12));
}

.stat-box-division.pro {
  border-color: rgba(102, 126, 234, 0.4);
}

.stat-box-division.student {
  border-color: rgba(76, 175, 80, 0.4);
  background: linear-gradient(135deg, rgba(76, 175, 80, 0.08), rgba(102, 187, 106, 0.12));
}

.stat-box-division .stat-label {
  text-align: left;
  font-size: 0.85rem;
  color: #1a1a2e;
  margin-bottom: 0.25rem;
}

/* Win Rate Color Classes */
.win-rate-high {
  color: #10b981 !important;
  font-weight: 700;
}

.win-rate-medium {
  color: #f59e0b !important;
  font-weight: 700;
}

.win-rate-low {
  color: #ef4444 !important;
  font-weight: 700;
}

.stat-box .stat-label {
  font-size: 0.75rem;
  color: #6c757d;
  margin-top: 0.25rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* Membership Preview */
.membership-preview {
  margin-bottom: 1.5rem;
}

.membership-card {
  width: 100%;
  aspect-ratio: 1.586;
  border-radius: 16px;
  padding: 1.5rem;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
  position: relative;
  overflow: hidden;
}

.membership-card.card-pro_max {
  background: linear-gradient(135deg, #FF6B6B 0%, #4ECDC4 100%);
  color: white;
}

.membership-card.card-pro {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.membership-card.card-plus {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.membership-card.card-lite {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  color: #1a1a2e;
}

.card-header-mini {
  font-size: 0.75rem;
  font-weight: 600;
  margin-bottom: 1rem;
  opacity: 0.9;
}

.card-number {
  font-size: 1.25rem;
  font-weight: 700;
  letter-spacing: 2px;
  margin-bottom: 1rem;
}

.card-member-name {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.card-level {
  font-size: 0.875rem;
  font-weight: 500;
  opacity: 0.9;
}

.current-membership-info {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 1.5rem;
}

.current-membership-info p {
  margin: 0.5rem 0;
}

/* Stats Management Styles */
.stats-management-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-management-card {
  background: white;
  border: 2px solid #e9ecef;
  border-radius: 12px;
  padding: 1.5rem;
  transition: all 0.3s ease;
}

.stat-management-card:hover {
  border-color: #0066cc;
  box-shadow: 0 4px 12px rgba(0, 102, 204, 0.1);
}

.stat-header {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.stat-icon-large {
  font-size: 3rem;
  line-height: 1;
}

.stat-info {
  flex: 1;
}

.stat-title {
  font-size: 1.125rem;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
  color: #1a1a2e;
}

.stat-mode {
  margin-top: 0.5rem;
}

.stat-value-display {
  text-align: center;
  padding: 1.5rem 0;
  margin: 1rem 0;
  background: #f8f9fa;
  border-radius: 8px;
}

.current-value {
  font-size: 3rem;
  font-weight: 700;
  color: #0066cc;
  line-height: 1;
}

.actual-value {
  font-size: 0.875rem;
  color: #6c757d;
  margin-top: 0.5rem;
}

.stat-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
}

.stats-management-info {
  background: #f0f8ff;
  border-left: 4px solid #0066cc;
  padding: 1.5rem;
  border-radius: 8px;
}

.info-box ul {
  margin: 0.5rem 0 0 1.5rem;
  padding: 0;
}

.info-box li {
  margin: 0.5rem 0;
}

.preview-box {
  background: #f0f8ff;
  padding: 1rem;
  border-radius: 8px;
  text-align: center;
  margin-top: 1rem;
}

.preview-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #0066cc;
}

.card-subtitle {
  color: #6c757d;
  font-size: 0.875rem;
  margin-top: 0.5rem;
}

/* Special styling for Winners stat card */
.stat-winners-card {
  background: linear-gradient(135deg, #FFF9E6 0%, #FFFBF0 100%);
  border: 2px solid #FFD700;
}

.stat-winners-card:hover {
  border-color: #FFA500;
  box-shadow: 0 6px 20px rgba(255, 215, 0, 0.2);
}

.stat-winners-card .stat-icon-large {
  animation: trophy-shine 2s ease-in-out infinite;
  filter: drop-shadow(0 2px 4px rgba(255, 215, 0, 0.5));
}

.stat-winners-card .current-value {
  background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

@keyframes trophy-shine {
  0%, 100% {
    transform: scale(1);
    filter: drop-shadow(0 2px 4px rgba(255, 215, 0, 0.5));
  }
  50% {
    transform: scale(1.05);
    filter: drop-shadow(0 4px 8px rgba(255, 215, 0, 0.8));
  }
}

.membership-preview-box {
  margin-top: 1.5rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
}

.membership-preview-box h4 {
  font-size: 1rem;
  margin-bottom: 1rem;
  color: #1a1a2e;
}

.membership-card-mini {
  width: 200px;
  height: 120px;
  border-radius: 12px;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  margin: 0 auto;
}

.membership-card-mini.card-pro_max {
  background: linear-gradient(135deg, #FF6B6B, #4ECDC4);
  color: white;
}

.membership-card-mini.card-pro {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
}

.membership-card-mini.card-plus {
  background: linear-gradient(135deg, #f093fb, #f5576c);
  color: white;
}

.membership-card-mini.card-lite {
  background: linear-gradient(135deg, #a8edea, #fed6e3);
  color: #1a1a2e;
}

.card-level-label {
  font-weight: 700;
  font-size: 0.875rem;
}

.card-icon {
  font-size: 2rem;
  text-align: center;
}

.form-text {
  display: block;
  margin-top: 0.25rem;
  font-size: 0.875rem;
  color: #6c757d;
}

/* Section Spacing */
.section-statistics,
.section-quick-actions,
.section-user-management {
  margin-bottom: 3rem;
}

/* Quick Actions Grid */
.quick-actions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.action-card {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 1.5rem;
  background: white;
  border: 2px solid #e9ecef;
  border-radius: 16px;
  text-decoration: none;
  color: inherit;
  transition: all 0.3s ease;
  cursor: pointer;
  position: relative;
  overflow: hidden;
}

.action-card::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: linear-gradient(
    45deg,
    transparent 30%,
    rgba(102, 126, 234, 0.1) 50%,
    transparent 70%
  );
  transform: translateX(-100%) translateY(-100%) rotate(45deg);
  transition: transform 0.6s ease;
}

.action-card:hover::before {
  transform: translateX(100%) translateY(100%) rotate(45deg);
}

.action-card:hover {
  transform: translateY(-4px);
  border-color: #667eea;
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.2);
}

.action-icon {
  font-size: 3rem;
  flex-shrink: 0;
  transition: transform 0.3s ease;
}

.action-card:hover .action-icon {
  transform: scale(1.1) rotate(5deg);
}

.action-content {
  flex: 1;
  position: relative;
  z-index: 1;
}

.action-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1a1a2e;
  margin-bottom: 0.25rem;
}

.action-description {
  font-size: 0.875rem;
  color: #6c757d;
  margin: 0;
}

.action-arrow {
  font-size: 1.5rem;
  color: #dee2e6;
  transition: all 0.3s ease;
  position: relative;
  z-index: 1;
}

.action-card:hover .action-arrow {
  color: #667eea;
  transform: translateX(5px);
}

/* Specific Action Card Colors */
.action-create-tournament:hover {
  border-color: #28a745;
}

.action-create-tournament:hover .action-arrow {
  color: #28a745;
}

.action-manage-players:hover {
  border-color: #17a2b8;
}

.action-manage-players:hover .action-arrow {
  color: #17a2b8;
}

.action-monitoring {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border: 2px solid #6c757d;
}

.action-monitoring:hover {
  border-color: #6c757d;
}

.action-monitoring:hover .action-arrow {
  color: #6c757d;
}

.action-unverified {
  background: linear-gradient(135deg, #fff8e1 0%, #ffecb3 100%);
  border: 2px solid #ff9800;
}

.action-unverified:hover {
  border-color: #ff9800;
}

.action-unverified:hover .action-arrow {
  color: #ff9800;
}

.action-view-rankings:hover {
  border-color: #ffc107;
}

.action-view-rankings:hover .action-arrow {
  color: #ffc107;
}

.action-system-info:hover {
  border-color: #6c757d;
}

.action-system-info:hover .action-arrow {
  color: #6c757d;
}

/* Stats Management Grid - Enhanced */
.stats-management-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-management-card {
  background: white;
  border: 2px solid #e9ecef;
  border-radius: 16px;
  padding: 1.5rem;
  transition: all 0.3s ease;
}

.stat-management-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
}

.stat-players-card:hover {
  border-color: #2196F3;
  box-shadow: 0 8px 24px rgba(33, 150, 243, 0.2);
}

.stat-winners-card:hover {
  border-color: #FFD700;
  box-shadow: 0 8px 24px rgba(255, 215, 0, 0.2);
}

.stat-tournaments-card:hover {
  border-color: #9C27B0;
  box-shadow: 0 8px 24px rgba(156, 39, 176, 0.2);
}

.stat-matches-card:hover {
  border-color: #F44336;
  box-shadow: 0 8px 24px rgba(244, 67, 54, 0.2);
}

.stat-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.stat-icon-large {
  font-size: 2.5rem;
  flex-shrink: 0;
}

.stat-info {
  flex: 1;
}

.stat-title {
  font-size: 1.125rem;
  font-weight: 700;
  color: #1a1a2e;
  margin-bottom: 0.5rem;
}

.stat-mode {
  display: flex;
  gap: 0.5rem;
}

.stat-value-display {
  margin-bottom: 1rem;
}

.current-value {
  font-size: 2.5rem;
  font-weight: 800;
  color: #667eea;
  margin-bottom: 0.25rem;
}

.actual-value {
  font-size: 0.875rem;
  color: #6c757d;
}

.stat-actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.stats-management-info {
  margin-top: 2rem;
}

.info-box {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 12px;
  border-left: 4px solid #667eea;
}

.info-box strong {
  color: #1a1a2e;
}

.info-box ul {
  margin: 0.75rem 0 0 0;
  padding-left: 1.5rem;
}

.info-box li {
  margin-bottom: 0.5rem;
  color: #495057;
}

.card-subtitle {
  font-size: 0.875rem;
  color: #6c757d;
  margin-top: 0.5rem;
}

/* Loyalty Points Modal Styles */
.loyalty-user-info {
  display: flex;
  gap: 1.5rem;
  padding: 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  color: white;
  margin-bottom: 2rem;
}

.user-avatar .avatar-circle {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  font-weight: 700;
  border: 3px solid white;
}

.user-details {
  flex: 1;
}

.user-details h4 {
  margin: 0 0 0.5rem 0;
  font-size: 1.5rem;
}

.user-email {
  margin: 0 0 1rem 0;
  opacity: 0.9;
}

.user-membership {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.multiplier-badge {
  padding: 0.5rem 1rem;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.875rem;
}

.current-balance {
  padding: 0.75rem 1rem;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 8px;
  display: inline-block;
}

.balance-amount {
  margin-left: 0.5rem;
  font-size: 1.25rem;
  font-weight: 700;
  color: #ffd700;
}

.radio-group {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.radio-option {
  flex: 1;
  min-width: 200px;
  padding: 1rem;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.radio-option:hover {
  border-color: #667eea;
  background: #f8f9ff;
}

.radio-option input[type="radio"] {
  width: 20px;
  height: 20px;
  cursor: pointer;
}

.radio-option input[type="radio"]:checked + .radio-label {
  font-weight: 600;
  color: #667eea;
}

.radio-label {
  flex: 1;
  cursor: pointer;
}

.points-calculation {
  background: linear-gradient(135deg, #f0f9ff 0%, #f0fdf4 100%);
  border: 2px solid #10b981;
  border-radius: 12px;
  padding: 1.5rem;
  margin-top: 1rem;
}

.calculation-row {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem 0;
  font-size: 1rem;
}

.calculation-total {
  border-top: 2px solid #10b981;
  margin-top: 0.5rem;
  padding-top: 1rem;
  font-size: 1.25rem;
}

.points-earned {
  color: #10b981;
  font-size: 1.5rem;
}

.loyalty-points-value {
  color: #667eea;
  font-size: 1.1rem;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* Search and Filter Bar Styles */
.search-filter-bar {
  margin-bottom: 1.5rem;
  padding: 1.5rem;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-radius: 12px;
  border: 1px solid #dee2e6;
}

.search-box {
  position: relative;
  margin-bottom: 1rem;
}

.search-input {
  width: 100%;
  padding: 0.75rem 3rem 0.75rem 1rem;
  font-size: 1rem;
  border: 2px solid #ced4da;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.search-input:focus {
  border-color: #667eea;
  box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
  outline: none;
}

.clear-search {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  padding: 0.25rem 0.5rem;
  background: #6c757d;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.875rem;
  transition: background 0.2s ease;
}

.clear-search:hover {
  background: #5a6268;
}

.filter-group {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}

.filter-select {
  padding: 0.5rem;
  font-size: 0.875rem;
  border: 2px solid #ced4da;
  border-radius: 6px;
  background: white;
  cursor: pointer;
  transition: all 0.2s ease;
}

.filter-select:focus {
  border-color: #667eea;
  box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.15);
  outline: none;
}

.search-results-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 1rem;
  border-top: 1px solid #dee2e6;
}

.results-count {
  font-size: 0.875rem;
  color: #6c757d;
  font-weight: 600;
}

.no-results {
  text-align: center;
  padding: 3rem 1rem;
  color: #6c757d;
}

.no-results p {
  font-size: 1.125rem;
  margin-bottom: 1rem;
}

/* Mobile users grid - hidden by default, shown on mobile */
.mobile-users-grid {
  display: none;
}

/* ============================================
   MOBILE OPTIMIZATION (≤768px)
   ============================================ */

@media (max-width: 768px) {
  /* 页面标题 */
  .page-header h1 {
    font-size: 20px;
  }

  .page-header p {
    font-size: 13px;
  }

  /* 统计卡片：单列堆叠 */
  .stats-management-grid {
    grid-template-columns: 1fr !important;
    gap: 12px;
  }

  .stat-management-card {
    padding: 16px;
  }

  .stat-icon-large {
    font-size: 2rem;
    width: 48px;
    height: 48px;
  }

  .stat-title {
    font-size: 14px;
  }

  .current-value {
    font-size: 24px;
  }

  .stat-note {
    font-size: 11px;
  }

  /* 搜索筛选栏：垂直堆叠 */
  .search-filter-bar {
    padding: 1rem;
    flex-direction: column;
    gap: 12px;
  }

  .search-box {
    width: 100%;
  }

  .filter-group {
    grid-template-columns: 1fr;
    width: 100%;
  }

  .search-input {
    font-size: 14px;
    min-height: 44px;
  }

  .filter-select {
    width: 100%;
    min-height: 44px;
    font-size: 14px;
  }

  .clear-search {
    position: absolute;
    right: 8px;
    top: 50%;
    transform: translateY(-50%);
    min-height: 36px;
    min-width: 36px;
    width: 36px;
    height: 36px;
    padding: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    border-radius: 50%;
    background: rgba(108, 117, 125, 0.9);
  }

  .clear-search:hover {
    background: rgba(90, 98, 104, 1);
  }

  /* 输入框右侧留空间给清除按钮 */
  .search-input {
    padding-right: 48px !important;
  }

  /* 用户表格：响应式优化 */
  .admin-table-container {
    overflow-x: auto;
    margin: 0 -1rem;
    padding: 0 1rem;
  }
  
  /* 表格列宽优化 */
  .admin-users-table {
    width: 100%;
    table-layout: fixed;  /* 固定布局，防止过宽 */
  }
  
  .admin-users-table th,
  .admin-users-table td {
    padding: 0.75rem 0.5rem;
    font-size: 0.875rem;
  }
  
  /* 各列宽度控制（百分比分配） */
  .col-name { width: 15%; }
  .col-contact { width: 20%; }
  .col-membership { width: 9%; text-align: center; }
  .col-rank { width: 8%; text-align: center; }
  .col-points { width: 9%; text-align: center; }
  .col-loyalty { width: 7%; text-align: center; }
  .col-role { width: 7%; text-align: center; }
  .col-status { width: 7%; text-align: center; }
  .col-actions { width: 24%; }  /* Actions 列 */
  
  /* Contact 列内容可以换行 */
  .col-contact {
    white-space: normal;
    word-break: break-word;
  }
  
  /* Name 列内容 */
  .col-name {
    white-space: normal;
    word-break: break-word;
  }
  
  /* 用户名单元格 */
  .user-name-cell {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }
  
  .card-number-small {
    font-size: 0.75rem;
    color: #6c757d;
    font-weight: normal;
  }
  
  /* 联系信息单元格 */
  .contact-cell {
    display: flex;
    flex-direction: column;
    gap: 4px;
    font-size: 0.875rem;
  }
  
  .contact-item {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 250px;
  }
  
  /* 操作按钮紧凑布局 */
  /* Actions 列按钮样式 - 使用带文字按钮（像 Players 页面） */
  .col-actions .action-buttons {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
    justify-content: flex-start;
  }
  
  .col-actions .btn-sm {
    font-size: 0.875rem;
    padding: 0.375rem 0.75rem;
    white-space: nowrap;
    min-width: auto;
  }
  
  /* 移动端隐藏表格，显示卡片 */
  @media (max-width: 1200px) {
    .admin-table-container {
      display: none !important;
    }
  }

  /* 用户卡片布局（仅移动端） */
  .mobile-users-grid {
    display: grid !important;
    grid-template-columns: 1fr;
    gap: 12px;
    margin-top: 16px;
  }

  .mobile-user-card {
    border: 2px solid;
    border-radius: 12px;
    padding: 16px;
    transition: all 0.2s;
    position: relative;
    overflow: hidden;
  }

  /* 会员等级卡片底色 */
  .mobile-user-card.membership-card-lite {
    background: linear-gradient(135deg, #f3f4f6 0%, #e5e7eb 100%);
    border-color: #9ca3af;
  }

  .mobile-user-card.membership-card-plus {
    background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
    border-color: #f59e0b;
  }

  .mobile-user-card.membership-card-pro {
    background: linear-gradient(135deg, #ddd6fe 0%, #c4b5fd 100%);
    border-color: #8b5cf6;
  }

  .mobile-user-card.membership-card-pro_max {
    background: linear-gradient(135deg, #fce7f3 0%, #fbcfe8 100%);
    border-color: #ec4899;
    box-shadow: 0 0 20px rgba(236, 72, 153, 0.3);
  }

  .mobile-user-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  }

  /* Pro Max 会员卡片添加闪光效果 */
  .mobile-user-card.membership-card-pro_max::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: linear-gradient(
      45deg,
      transparent,
      rgba(255, 255, 255, 0.3),
      transparent
    );
    transform: rotate(45deg);
    animation: shine 3s infinite;
  }

  @keyframes shine {
    0% {
      left: -50%;
    }
    100% {
      left: 150%;
    }
  }

  .mobile-user-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 12px;
    padding-bottom: 12px;
    border-bottom: 1px solid var(--color-border);
  }

  .mobile-user-info {
    flex: 1;
  }

  .mobile-user-name {
    font-size: 16px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 4px;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.5);
  }

  .mobile-user-email {
    font-size: 13px;
    color: #374151;
    word-break: break-all;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.5);
  }

  .mobile-user-badges {
    display: flex;
    flex-direction: column;
    gap: 4px;
    align-items: flex-end;
  }

  .mobile-user-details {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
    margin-bottom: 12px;
  }

  .mobile-detail-item {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .mobile-detail-label {
    font-size: 11px;
    color: #6b7280;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: 600;
  }

  .mobile-detail-value {
    font-size: 14px;
    font-weight: 700;
    color: #111827;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.5);
  }

  .mobile-user-actions {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
  }

  .mobile-action-btn {
    min-height: 44px;
    padding: 10px 12px;
    font-size: 13px;
    font-weight: 600;
    border-radius: 8px;
    border: none;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
  }

  .mobile-action-btn.primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
  }

  .mobile-action-btn.primary:hover {
    background: linear-gradient(135deg, #5568d3 0%, #6a3f8f 100%);
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
  }

  .mobile-action-btn.secondary {
    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
    color: white;
    box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
  }

  .mobile-action-btn.secondary:hover {
    background: linear-gradient(135deg, #059669 0%, #047857 100%);
    box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
  }

  .mobile-action-btn.danger {
    background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
    color: white;
    box-shadow: 0 2px 8px rgba(239, 68, 68, 0.3);
  }

  .mobile-action-btn.danger:hover {
    background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
    box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
  }

  .mobile-action-btn.warning {
    background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
    color: white;
    box-shadow: 0 2px 8px rgba(245, 158, 11, 0.3);
  }

  .mobile-action-btn.warning:hover {
    background: linear-gradient(135deg, #d97706 0%, #b45309 100%);
    box-shadow: 0 4px 12px rgba(245, 158, 11, 0.4);
  }

  /* 模态框优化 */
  .modal-content {
    width: 95vw;
    max-width: 95vw;
    margin: 20px auto;
    max-height: 90vh;
    overflow-y: auto;
  }

  .modal-header h3 {
    font-size: 18px;
  }

  .form-group label {
    font-size: 13px;
  }

  .form-control {
    min-height: 44px;
    font-size: 14px;
  }

  .modal-actions {
    flex-direction: column;
    gap: 8px;
  }

  .modal-actions .btn {
    width: 100%;
    min-height: 48px;
  }
}
</style>


