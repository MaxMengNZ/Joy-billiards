<template>
  <div class="players-page">
    <div class="page-header">
      <h1>👥 Players Management</h1>
      <div class="header-actions">
        <button class="btn btn-warning" @click="checkDuplicates">
          🔍 Check Duplicates
        </button>
        <button class="btn btn-primary" @click="showCreateModal = true">
          Add New Player
        </button>
      </div>
    </div>

    <div v-if="playerStore?.loading" class="loading">
      <div class="spinner"></div>
    </div>

    <div v-else-if="playerStore?.error" class="alert alert-danger">
      {{ playerStore?.error }}
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
          <div class="col col-3">
            <div class="form-group">
              <label class="form-label">Filter by Last Modified</label>
              <select class="form-control" v-model="recentModifiedFilter">
                <option value="">All Players</option>
                <option value="24h">🕐 Modified in 24h</option>
                <option value="today">📅 Modified Today</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Desktop Players Table -->
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
              <th>Last Modified</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="player in (filteredPlayers || [])" :key="player.id" :class="{ 'recently-modified': isRecentlyModified(player) }">
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
                <div class="last-modified-cell">
                  <span v-if="getLastModified(player)" class="last-modified-time" :class="{ 'recent': isRecentlyModified(player) }">
                    {{ formatLastModified(getLastModified(player)) }}
                  </span>
                  <span v-else class="text-muted">Never</span>
                </div>
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
        <div v-if="!filteredPlayers || filteredPlayers.length === 0" class="text-center p-4">
          <p class="text-secondary">No players found</p>
        </div>
      </div>

      <!-- Mobile Players Cards -->
      <div class="mobile-players-grid">
        <div v-for="player in (filteredPlayers || [])" :key="player.id" class="mobile-player-card">
          <!-- Card Header: Name + Badges -->
          <div class="mobile-player-header">
            <div class="mobile-player-info">
              <div class="mobile-player-name">{{ player.name }}</div>
              <div class="mobile-player-card-num">Card #{{ player.membership_card_number || 'N/A' }}</div>
            </div>
            <div class="mobile-player-badges">
              <span class="rank-badge-small" :class="`rank-${player.ranking_level}`">
                {{ formatRankLevel(player.ranking_level) }}
              </span>
              <span class="badge" :class="player.is_active ? 'badge-success' : 'badge-danger'">
                {{ player.is_active ? '✅' : '⛔' }}
              </span>
            </div>
          </div>

          <!-- Stats Grid: 2x3 -->
          <div class="mobile-player-stats">
            <div class="mobile-stat-item">
              <div class="mobile-stat-label">W/L</div>
              <div class="mobile-stat-value">
                <span style="color: #10b981;">{{ player.wins || 0 }}</span> / 
                <span style="color: #ef4444;">{{ player.losses || 0 }}</span>
              </div>
            </div>
            <div class="mobile-stat-item">
              <div class="mobile-stat-label">Win Rate</div>
              <div class="mobile-stat-value">{{ calculateWinRate(player) }}%</div>
            </div>
            <div class="mobile-stat-item">
              <div class="mobile-stat-label">Break & Run</div>
              <div class="mobile-stat-value" style="color: #667eea;">{{ player.break_and_run || 0 }}</div>
            </div>
            <div class="mobile-stat-item">
              <div class="mobile-stat-label">B&R Rate</div>
              <div class="mobile-stat-value">{{ calculateBreakRunRate(player) }}%</div>
            </div>
            <div class="mobile-stat-item">
              <div class="mobile-stat-label">Rank Points</div>
              <div class="mobile-stat-value">{{ player.ranking_points || 0 }}</div>
            </div>
            <div class="mobile-stat-item">
              <div class="mobile-stat-label">Matches</div>
              <div class="mobile-stat-value">{{ (player.wins || 0) + (player.losses || 0) }}</div>
            </div>
          </div>

          <!-- Action Buttons: 2x2 -->
          <div class="mobile-player-actions">
            <button class="mobile-action-btn view" @click="openStatsModal(player)">
              📊 Stats
            </button>
            <button class="mobile-action-btn edit" @click="openPointsModal(player)">
              🏆 Points
            </button>
            <button class="mobile-action-btn edit" @click="editPlayer(player)">
              ✏️ Edit
            </button>
            <button class="mobile-action-btn delete" @click="confirmDelete(player)">
              🗑️ Delete
            </button>
          </div>
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
            <p><strong>Overall Totals:</strong></p>
            <p>Wins: <span class="text-success">{{ selectedPlayer?.wins || 0 }}</span></p>
            <p>Losses: <span class="text-danger">{{ selectedPlayer?.losses || 0 }}</span></p>
            <p>Matches Played: <strong>{{ (selectedPlayer?.wins || 0) + (selectedPlayer?.losses || 0) }}</strong></p>
            <p>Break and Run: <strong>🎯 {{ selectedPlayer?.break_and_run_count || 0 }}</strong></p>

            <div class="dual-stats-display">
              <div class="stats-item">
                <div class="stats-title">👔 Pro Division</div>
                <div class="stats-row"><span>Wins:</span><strong>{{ getDivisionValue(selectedPlayer, 'pro', 'wins') }}</strong></div>
                <div class="stats-row"><span>Losses:</span><strong>{{ getDivisionValue(selectedPlayer, 'pro', 'losses') }}</strong></div>
                <div class="stats-row"><span>Matches:</span><strong>{{ getDivisionMatches(selectedPlayer, 'pro') }}</strong></div>
                <div class="stats-row"><span>Win Rate:</span><strong>{{ calculateDivisionWinRate(selectedPlayer, 'pro') }}%</strong></div>
              </div>
              <div class="stats-item">
                <div class="stats-title">🎓 Student Division</div>
                <div class="stats-row"><span>Wins:</span><strong>{{ getDivisionValue(selectedPlayer, 'student', 'wins') }}</strong></div>
                <div class="stats-row"><span>Losses:</span><strong>{{ getDivisionValue(selectedPlayer, 'student', 'losses') }}</strong></div>
                <div class="stats-row"><span>Matches:</span><strong>{{ getDivisionMatches(selectedPlayer, 'student') }}</strong></div>
                <div class="stats-row"><span>Win Rate:</span><strong>{{ calculateDivisionWinRate(selectedPlayer, 'student') }}%</strong></div>
              </div>
            </div>
          </div>

          <!-- 🎯 组别选择 -->
          <div class="form-group division-selector">
            <label class="form-label">🎯 Select Division</label>
            <div class="radio-group">
              <label class="radio-option">
                <input 
                  type="radio" 
                  v-model="statsDivision" 
                  value="pro" 
                  name="statsDivision"
                >
                <span class="radio-label">
                  <strong>👔 Pro Division</strong>
                  <small>Weekly / Open tournaments</small>
                </span>
              </label>
              <label class="radio-option">
                <input 
                  type="radio" 
                  v-model="statsDivision" 
                  value="student" 
                  name="statsDivision"
                >
                <span class="radio-label">
                  <strong>🎓 Student Division</strong>
                  <small>Student-only events</small>
                </span>
              </label>
            </div>
          </div>
          
          <!-- 修改模式选择 -->
          <div class="form-group mode-selector">
            <label class="form-label">📝 Modification Mode</label>
            <div class="radio-group">
              <label class="radio-option">
                <input 
                  type="radio" 
                  v-model="statsMode" 
                  value="increment"
                  name="statsMode"
                >
                <span class="radio-label">
                  <strong>➕ Increment Mode (Recommended)</strong>
                  <small>Add results from today's matches</small>
                </span>
              </label>
              <label class="radio-option">
                <input 
                  type="radio" 
                  v-model="statsMode" 
                  value="absolute"
                  name="statsMode"
                >
                <span class="radio-label">
                  <strong>🔢 Absolute Mode</strong>
                  <small>Set total stats directly (for corrections)</small>
                </span>
              </label>
            </div>
          </div>

          <!-- 增量模式表单 -->
          <div v-if="statsMode === 'increment'" class="stats-form">
            <div class="increment-hint">
              <p>💡 Enter the results from today's {{ statsDivision === 'student' ? 'student' : 'pro' }} matches:</p>
            </div>
            
            <div class="form-row">
              <div class="form-group col-6">
                <label class="form-label">➕ Wins to Add</label>
                <input 
                  type="number" 
                  class="form-control" 
                  v-model.number="incrementForm.wins"
                  min="0"
                  placeholder="0"
                >
              </div>
              
              <div class="form-group col-6">
                <label class="form-label">➕ Losses to Add</label>
                <input 
                  type="number" 
                  class="form-control" 
                  v-model.number="incrementForm.losses"
                  min="0"
                  placeholder="0"
                >
              </div>
            </div>
            
            <div class="form-group">
              <label class="form-label">🎯 Break and Run to Add</label>
              <input 
                type="number" 
                class="form-control" 
                v-model.number="incrementForm.break_and_run_count"
                min="0"
                placeholder="0"
              >
              <small class="form-text text-muted">Perfect clears from today's matches</small>
            </div>

            <!-- 增量模式预览 -->
            <div v-if="incrementChanged" class="stats-preview increment-preview">
              <p><strong>📊 Preview New Stats:</strong></p>
              <div class="preview-row">
                <span class="preview-label">Wins:</span>
                <span class="preview-calc">{{ getDivisionValue(selectedPlayer, statsDivision, 'wins') }} + {{ incrementForm.wins }} = <strong class="text-success">{{ getNewWins() }}</strong></span>
              </div>
              <div class="preview-row">
                <span class="preview-label">Losses:</span>
                <span class="preview-calc">{{ getDivisionValue(selectedPlayer, statsDivision, 'losses') }} + {{ incrementForm.losses }} = <strong class="text-danger">{{ getNewLosses() }}</strong></span>
              </div>
              <div class="preview-row">
                <span class="preview-label">Matches Played:</span>
                <span class="preview-calc">{{ getDivisionMatches(selectedPlayer, statsDivision) }} → <strong>{{ getNewWins() + getNewLosses() }}</strong></span>
              </div>
              <div class="preview-row">
                <span class="preview-label">Break and Run:</span>
                <span class="preview-calc">{{ getDivisionValue(selectedPlayer, statsDivision, 'break_and_run_count') }} + {{ incrementForm.break_and_run_count }} = <strong>🎯 {{ getNewBreakAndRun() }}</strong></span>
              </div>
              <div class="preview-row">
                <span class="preview-label">Win Rate:</span>
                <span class="preview-calc">{{ calculateDivisionWinRate(selectedPlayer, statsDivision) }}% → <strong>{{ calculateIncrementWinRate() }}%</strong></span>
              </div>
              <div class="preview-row overall-row">
                <span class="preview-label">Overall Totals:</span>
                <span class="preview-calc">
                  {{ selectedPlayer?.wins || 0 }}W/{{ selectedPlayer?.losses || 0 }}L → 
                  <strong>{{ getProjectedOverallStat('wins') }}W/{{ getProjectedOverallStat('losses') }}L</strong>
                </span>
              </div>
            </div>
          </div>

          <!-- 绝对值模式表单 -->
          <div v-else class="stats-form">
            <div class="form-group">
              <label class="form-label">Total Wins</label>
              <input 
                type="number" 
                class="form-control" 
                v-model.number="statsForm.wins"
                min="0"
                placeholder="Number of wins"
              >
            </div>
            
            <div class="form-group">
              <label class="form-label">Total Losses</label>
              <input 
                type="number" 
                class="form-control" 
                v-model.number="statsForm.losses"
                min="0"
                placeholder="Number of losses"
              >
            </div>
            
            <div class="form-group">
              <label class="form-label">🎯 Total Break and Run Count</label>
              <input 
                type="number" 
                class="form-control" 
                v-model.number="statsForm.break_and_run_count"
                min="0"
                placeholder="Number of Break and Run achievements"
              >
              <small class="form-text text-muted">Perfect clears - Opening break followed by running the table</small>
            </div>

            <!-- 绝对值模式预览 -->
            <div v-if="statsChanged" class="stats-preview">
              <p><strong>📊 Preview Changes:</strong></p>
              <p>Wins: {{ getDivisionValue(selectedPlayer, statsDivision, 'wins') }} → {{ statsForm.wins }}</p>
              <p>Losses: {{ getDivisionValue(selectedPlayer, statsDivision, 'losses') }} → {{ statsForm.losses }}</p>
              <p>Matches Played: {{ getDivisionMatches(selectedPlayer, statsDivision) }} → {{ statsForm.wins + statsForm.losses }}</p>
              <p>Break and Run: 🎯 {{ getDivisionValue(selectedPlayer, statsDivision, 'break_and_run_count') }} → {{ statsForm.break_and_run_count }}</p>
              <p>Win Rate: {{ calculateDivisionWinRate(selectedPlayer, statsDivision) }}% → {{ calculateNewWinRate() }}%</p>
              <p class="overall-summary">
                Overall Totals: {{ selectedPlayer?.wins || 0 }}W/{{ selectedPlayer?.losses || 0 }}L → 
                {{ getProjectedOverallStat('wins') }}W/{{ getProjectedOverallStat('losses') }}L
              </p>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Reason (Optional)</label>
            <input 
              type="text"
              class="form-control"
              v-model="statsReason"
              placeholder="e.g., Weekly tournament results"
            >
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeStatsModal" :disabled="isUpdatingStats">Cancel</button>
          <button 
            class="btn btn-success" 
            @click="updateStats"
            :disabled="isUpdatingStats || (statsMode === 'increment' ? !incrementChanged : !statsChanged)"
            :aria-busy="isUpdatingStats"
          >
            <span v-if="isUpdatingStats">Saving...</span>
            <span v-else>Update Statistics</span>
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
            <div class="dual-points-display">
              <div class="points-item">
                <span class="points-label">👔 Pro Points:</span>
                <span class="points-value">{{ selectedPlayer?.pro_ranking_points || 0 }}</span>
              </div>
              <div class="points-item">
                <span class="points-label">🎓 Student Points:</span>
                <span class="points-value">{{ selectedPlayer?.student_ranking_points || 0 }}</span>
              </div>
            </div>
          </div>
          
          <!-- 🎯 组别选择（新增） -->
          <div class="form-group division-selector">
            <label class="form-label">🎯 Select Division</label>
            <div class="radio-group">
              <label class="radio-option">
                <input type="radio" v-model="pointsDivision" value="pro" name="pointsDivision">
                <span class="radio-label">
                  <strong>👔 Pro Division</strong>
                  <small>For Pro tournaments (Weekly, China Masters, etc.)</small>
                </span>
              </label>
              <label class="radio-option">
                <input type="radio" v-model="pointsDivision" value="student" name="pointsDivision">
                <span class="radio-label">
                  <strong>🎓 Student Division</strong>
                  <small>For Student tournaments (Student Challenge, etc.)</small>
                </span>
              </label>
            </div>
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
              placeholder="e.g., Won Pro Weekly Tournament"
            >
          </div>
          
          <div v-if="pointsChange !== 0" class="points-preview">
            <p><strong>Points Change:</strong> {{ pointsChange > 0 ? '+' : '' }}{{ pointsChange }}</p>
            <p v-if="pointsChange > 0" class="text-success">⬆️ Adding {{ pointsChange }} points</p>
            <p v-else class="text-danger">⬇️ Subtracting {{ Math.abs(pointsChange) }} points</p>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closePointsModal" :disabled="isUpdatingPoints">Cancel</button>
          <button 
            class="btn btn-success" 
            @click="updatePoints"
            :disabled="isUpdatingPoints || pointsChange === 0"
            :aria-busy="isUpdatingPoints"
          >
            <span v-if="isUpdatingPoints">Saving...</span>
            <span v-else>Update Points</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Duplicate Check Modal -->
    <div v-if="showDuplicateModal" class="modal">
      <div class="modal-content" style="max-width: 900px; max-height: 90vh; overflow-y: auto;">
        <div class="modal-header">
          <h2>🔍 Duplicate Member Information Check</h2>
          <button class="btn btn-secondary btn-sm" @click="closeDuplicateModal">Close</button>
        </div>
        <div class="modal-body">
          <div v-if="(!duplicateResults.membershipCards || duplicateResults.membershipCards.length === 0) && 
                     (!duplicateResults.emails || duplicateResults.emails.length === 0) && 
                     (!duplicateResults.phones || duplicateResults.phones.length === 0) && 
                     (!duplicateResults.names || duplicateResults.names.length === 0)" 
               class="alert alert-success">
            ✅ No duplicates found! All member information is unique.
          </div>

          <!-- Duplicate Membership Cards -->
          <div v-if="duplicateResults.membershipCards && duplicateResults.membershipCards.length > 0" class="duplicate-section">
            <h3 class="duplicate-title">⚠️ Duplicate Membership Cards ({{ duplicateResults.membershipCards?.length || 0 }})</h3>
            <div v-for="item in (duplicateResults.membershipCards || [])" :key="'card-' + item.value" class="duplicate-group">
              <div class="duplicate-value">
                Card Number: <strong>{{ item.value }}</strong> ({{ item.players?.length || 0 }} players)
                <button class="btn btn-sm btn-warning" @click="deleteOldDuplicates(item.players, 'membershipCard')" style="margin-left: 1rem;">
                  🗑️ Delete Oldest (Keep Newest)
                </button>
              </div>
              <div class="duplicate-players">
                <div v-for="(player, idx) in getSortedPlayersByDate(item.players)" :key="player.id" 
                     class="duplicate-player-item" 
                     :class="{ 'keep-newest': idx === 0, 'delete-oldest': idx > 0 }">
                  <span class="player-name">
                    {{ player.name }}
                    <span v-if="idx === 0" class="badge badge-success">✓ Keep (Newest)</span>
                    <span v-else class="badge badge-warning">⚠ Old (Will Delete)</span>
                  </span>
                  <span class="player-info">ID: {{ player.id.substring(0, 8) }}...</span>
                  <span class="player-info" v-if="authStore.isAdmin">Email: {{ player.email || 'N/A' }}</span>
                  <span class="player-info" v-if="authStore.isAdmin">Phone: {{ player.phone || 'N/A' }}</span>
                  <span class="player-info">Registered: {{ formatDate(player.created_at) }}</span>
                  <button v-if="idx > 0" class="btn btn-sm btn-danger" @click="deleteDuplicatePlayer(player)" title="Delete this duplicate">
                    🗑️ Delete
                  </button>
                  <span v-else class="text-success">✓ Keeping</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Duplicate Emails -->
          <div v-if="duplicateResults.emails && duplicateResults.emails.length > 0" class="duplicate-section">
            <h3 class="duplicate-title">⚠️ Duplicate Emails ({{ duplicateResults.emails?.length || 0 }})</h3>
            <div v-for="item in (duplicateResults.emails || [])" :key="'email-' + item.value" class="duplicate-group">
              <div class="duplicate-value">
                Email: <strong>{{ item.value }}</strong> ({{ item.players?.length || 0 }} players)
                <button class="btn btn-sm btn-warning" @click="deleteOldDuplicates(item.players, 'email')" style="margin-left: 1rem;">
                  🗑️ Delete Oldest (Keep Newest)
                </button>
              </div>
              <div class="duplicate-players">
                <div v-for="(player, idx) in getSortedPlayersByDate(item.players)" :key="player.id" 
                     class="duplicate-player-item" 
                     :class="{ 'keep-newest': idx === 0, 'delete-oldest': idx > 0 }">
                  <span class="player-name">
                    {{ player.name }}
                    <span v-if="idx === 0" class="badge badge-success">✓ Keep (Newest)</span>
                    <span v-else class="badge badge-warning">⚠ Old (Will Delete)</span>
                  </span>
                  <span class="player-info">ID: {{ player.id.substring(0, 8) }}...</span>
                  <span class="player-info">Card: {{ player.membership_card_number || 'N/A' }}</span>
                  <span class="player-info" v-if="authStore.isAdmin">Phone: {{ player.phone || 'N/A' }}</span>
                  <span class="player-info">Registered: {{ formatDate(player.created_at) }}</span>
                  <button v-if="idx > 0" class="btn btn-sm btn-danger" @click="deleteDuplicatePlayer(player)" title="Delete this duplicate">
                    🗑️ Delete
                  </button>
                  <span v-else class="text-success">✓ Keeping</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Duplicate Phones -->
          <div v-if="duplicateResults.phones && duplicateResults.phones.length > 0" class="duplicate-section">
            <h3 class="duplicate-title">⚠️ Duplicate Phone Numbers ({{ duplicateResults.phones?.length || 0 }})</h3>
            <div v-for="item in (duplicateResults.phones || [])" :key="'phone-' + item.value" class="duplicate-group">
              <div class="duplicate-value">Phone: <strong>{{ item.value }}</strong> ({{ item.players?.length || 0 }} players)</div>
              <div class="duplicate-players">
                <div v-for="player in (item.players || [])" :key="player.id" class="duplicate-player-item">
                  <span class="player-name">{{ player.name }}</span>
                  <span class="player-info">ID: {{ player.id.substring(0, 8) }}...</span>
                  <span class="player-info">Card: {{ player.membership_card_number || 'N/A' }}</span>
                  <span class="player-info">Email: {{ player.email || 'N/A' }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Duplicate Names -->
          <div v-if="duplicateResults.names && duplicateResults.names.length > 0" class="duplicate-section">
            <h3 class="duplicate-title">ℹ️ Duplicate Names ({{ duplicateResults.names?.length || 0 }})</h3>
            <p class="duplicate-note">Note: Same names may be legitimate if they are different people. Please verify before deleting.</p>
            <div v-for="item in (duplicateResults.names || [])" :key="'name-' + item.value" class="duplicate-group">
              <div class="duplicate-value">
                Name: <strong>{{ item.value }}</strong> ({{ item.players?.length || 0 }} players)
                <button class="btn btn-sm btn-warning" @click="deleteOldDuplicates(item.players, 'name')" style="margin-left: 1rem;">
                  🗑️ Delete Oldest (Keep Newest)
                </button>
              </div>
              <div class="duplicate-players">
                <div v-for="(player, idx) in getSortedPlayersByDate(item.players)" :key="player.id" 
                     class="duplicate-player-item" 
                     :class="{ 'keep-newest': idx === 0, 'delete-oldest': idx > 0 }">
                  <span class="player-name">
                    {{ player.name }}
                    <span v-if="idx === 0" class="badge badge-success">✓ Keep (Newest)</span>
                    <span v-else class="badge badge-warning">⚠ Old (Will Delete)</span>
                  </span>
                  <span class="player-info">ID: {{ player.id.substring(0, 8) }}...</span>
                  <span class="player-info">Card: {{ player.membership_card_number || 'N/A' }}</span>
                  <span class="player-info" v-if="authStore.isAdmin">Email: {{ player.email || 'N/A' }}</span>
                  <span class="player-info" v-if="authStore.isAdmin">Phone: {{ player.phone || 'N/A' }}</span>
                  <span class="player-info">Registered: {{ formatDate(player.created_at) }}</span>
                  <button v-if="idx > 0" class="btn btn-sm btn-danger" @click="deleteDuplicatePlayer(player)" title="Delete this duplicate">
                    🗑️ Delete
                  </button>
                  <span v-else class="text-success">✓ Keeping</span>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeDuplicateModal">Close</button>
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
import { ref, computed, onMounted, watch } from 'vue'
import { usePlayerStore } from '../stores/playerStore'
import { useAuthStore } from '../stores/authStore'
import { supabase } from '../config/supabase'

export default {
  name: 'PlayersPage',
  setup() {
    const playerStore = usePlayerStore()
    const authStore = useAuthStore()
    
    const showCreateModal = ref(false)
    const editingPlayer = ref(null)
    const searchQuery = ref('')
    const skillFilter = ref('')
    const membershipFilter = ref('')
    const recentModifiedFilter = ref('') // 'all', 'today', '24h'
    const pointHistory = ref([])
    const currentYear = new Date().getFullYear()
    const lastModifiedMap = ref({}) // 存储每个选手的最后修改时间 { playerId: { time, action, admin } }
    
    // Duplicate Check Modal
    const showDuplicateModal = ref(false)
    const duplicateResults = ref({
      membershipCards: [],
      emails: [],
      phones: [],
      names: []
    })
    
    // Stats Modal
    const showStatsModal = ref(false)
    const isUpdatingStats = ref(false)
    const statsMode = ref('increment') // 'increment' or 'absolute'
    const statsDivision = ref('pro') // 'pro' or 'student'
    const statsForm = ref({
      wins: 0,
      losses: 0,
      break_and_run_count: 0
    })
    const incrementForm = ref({
      wins: 0,
      losses: 0,
      break_and_run_count: 0
    })
    const statsReason = ref('')
    
    // Points Modal
    const showPointsModal = ref(false)
    const isUpdatingPoints = ref(false)
    const selectedPlayer = ref(null)
    const pointsChange = ref(0)
    const pointsReason = ref('')
    const pointsDivision = ref('pro') // 🎯 新增：组别选择（默认 Pro）
    
    const playerForm = ref({
      name: '',
      email: '',
      phone: ''
    })

    const getDivisionStatKey = (division, field) => {
      const prefix = division === 'student' ? 'student' : 'pro'
      if (field === 'break_and_run_count') {
        return `${prefix}_break_and_run_count`
      }
      return `${prefix}_${field}`
    }

    const getDivisionValue = (player, division, field) => {
      if (!player) return 0
      const key = getDivisionStatKey(division, field)
      return player[key] ?? 0
    }

    const filteredPlayers = computed(() => {
      if (!playerStore || !playerStore.sortedPlayers || !Array.isArray(playerStore.sortedPlayers)) return []
      let players = playerStore.sortedPlayers
      
      // Get current year for ranking points calculation
      const currentYear = new Date().getFullYear()
      
      // Add current_year_points to each player
      const pointHistoryArray = Array.isArray(pointHistory.value) ? pointHistory.value : []
      players = players.map(player => ({
        ...player,
        current_year_points: pointHistoryArray
          .filter(p => p && p.user_id === player.id && p.year === currentYear)
          .reduce((sum, p) => sum + (p.points_change || 0), 0)
      }))
      
      if (!Array.isArray(players)) {
        return []
      }
      
      if (searchQuery.value) {
        players = players.filter(p => 
          p && p.name && p.name.toLowerCase().includes(searchQuery.value.toLowerCase())
        )
      }
      
      if (skillFilter.value) {
        players = players.filter(p => p && p.ranking_level === skillFilter.value)
      }
      
      if (membershipFilter.value) {
        players = players.filter(p => p && p.membership_level === membershipFilter.value)
      }
      
      // Filter by last modified time
      if (recentModifiedFilter.value === '24h') {
        const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000)
        players = players.filter(p => {
          const lastModified = getLastModified(p)
          return lastModified && new Date(lastModified.time) > twentyFourHoursAgo
        })
      } else if (recentModifiedFilter.value === 'today') {
        const todayStart = new Date()
        todayStart.setHours(0, 0, 0, 0)
        players = players.filter(p => {
          const lastModified = getLastModified(p)
          return lastModified && new Date(lastModified.time) >= todayStart
        })
      }
      
      return Array.isArray(players) ? players : []
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

    const calculateDivisionWinRate = (player, division) => {
      const wins = getDivisionValue(player, division, 'wins')
      const losses = getDivisionValue(player, division, 'losses')
      const total = wins + losses
      if (total === 0) return 0
      return ((wins / total) * 100).toFixed(1)
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

    // 获取选手的最后修改时间
    const getLastModified = (player) => {
      if (!player || !player.id) return null
      return lastModifiedMap.value[player.id] || null
    }

    // 格式化最后修改时间
    const formatLastModified = (lastModified) => {
      if (!lastModified || !lastModified.time) return 'Never'
      const modifiedDate = new Date(lastModified.time)
      const now = new Date()
      const diffMs = now - modifiedDate
      const diffMins = Math.floor(diffMs / 60000)
      const diffHours = Math.floor(diffMs / 3600000)
      const diffDays = Math.floor(diffMs / 86400000)

      if (diffMins < 1) return 'Just now'
      if (diffMins < 60) return `${diffMins}m ago`
      if (diffHours < 24) return `${diffHours}h ago`
      if (diffDays === 1) return 'Yesterday'
      if (diffDays < 7) return `${diffDays}d ago`
      
      // 超过一周显示具体日期
      return modifiedDate.toLocaleDateString('en-NZ', {
        month: 'short',
        day: 'numeric',
        year: modifiedDate.getFullYear() !== now.getFullYear() ? 'numeric' : undefined
      })
    }

    // 判断是否在最近24小时内修改过
    const isRecentlyModified = (player) => {
      const lastModified = getLastModified(player)
      if (!lastModified) return false
      const modifiedDate = new Date(lastModified.time)
      const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000)
      return modifiedDate > twentyFourHoursAgo
    }

    // 加载所有选手的最后修改时间
    const loadLastModifiedTimes = async () => {
      // Security: Only admins can load audit log
      if (!authStore.isAdmin) {
        console.warn('Non-admin user attempted to load audit log')
        return
      }
      
      try {
        const { data, error } = await supabase
          .from('admin_audit_log')
          .select('target_user_id, action, created_at, details')
          .in('action', ['update_division_stats', 'add_pro_points', 'add_student_points'])
          .order('created_at', { ascending: false })

        if (error) {
          console.error('Error loading last modified times:', error)
          return
        }

        // 为每个选手找到最新的修改记录
        const map = {}
        if (data && Array.isArray(data)) {
          data.forEach(log => {
            if (log && log.target_user_id) {
              if (!map[log.target_user_id] || new Date(log.created_at) > new Date(map[log.target_user_id].time)) {
                map[log.target_user_id] = {
                  time: log.created_at,
                  action: log.action,
                  details: log.details
                }
              }
            }
          })
        }
        lastModifiedMap.value = map
      } catch (err) {
        console.error('Error loading last modified times:', err)
      }
    }

    const getCurrentYearPoints = (player) => {
      if (!player) return 0
      const pointHistoryArray = Array.isArray(pointHistory.value) ? pointHistory.value : []
      return pointHistoryArray
        .filter(p => p && p.user_id === player.id && p.year === currentYear)
        .reduce((sum, p) => sum + (p.points_change || 0), 0)
    }

    const statsChanged = computed(() => {
      if (!selectedPlayer.value) return false
      const baseWins = getDivisionValue(selectedPlayer.value, statsDivision.value, 'wins')
      const baseLosses = getDivisionValue(selectedPlayer.value, statsDivision.value, 'losses')
      const baseBreak = getDivisionValue(selectedPlayer.value, statsDivision.value, 'break_and_run_count')
      return statsForm.value.wins !== baseWins ||
             statsForm.value.losses !== baseLosses ||
             statsForm.value.break_and_run_count !== baseBreak
    })

    const incrementChanged = computed(() => {
      return incrementForm.value.wins > 0 || 
             incrementForm.value.losses > 0 || 
             incrementForm.value.break_and_run_count > 0
    })

    const getNewWins = () => {
      const base = getDivisionValue(selectedPlayer.value, statsDivision.value, 'wins')
      return base + incrementForm.value.wins
    }

    const getNewLosses = () => {
      const base = getDivisionValue(selectedPlayer.value, statsDivision.value, 'losses')
      return base + incrementForm.value.losses
    }

    const getNewBreakAndRun = () => {
      const base = getDivisionValue(selectedPlayer.value, statsDivision.value, 'break_and_run_count')
      return base + incrementForm.value.break_and_run_count
    }

    const calculateIncrementWinRate = () => {
      const newWins = getNewWins()
      const newLosses = getNewLosses()
      const total = newWins + newLosses
      if (total === 0) return 0
      return ((newWins / total) * 100).toFixed(2)
    }

    const resetStatsForms = () => {
      if (!selectedPlayer.value) return
      statsForm.value = {
        wins: getDivisionValue(selectedPlayer.value, statsDivision.value, 'wins'),
        losses: getDivisionValue(selectedPlayer.value, statsDivision.value, 'losses'),
        break_and_run_count: getDivisionValue(selectedPlayer.value, statsDivision.value, 'break_and_run_count')
      }
      incrementForm.value = {
        wins: 0,
        losses: 0,
        break_and_run_count: 0
      }
    }

    const openStatsModal = (player) => {
      selectedPlayer.value = player
      statsDivision.value = 'pro'
      statsMode.value = 'increment' // 默认使用增量模式
      statsReason.value = ''
      isUpdatingStats.value = false
      resetStatsForms()
      showStatsModal.value = true
    }

    const closeStatsModal = () => {
      showStatsModal.value = false
      selectedPlayer.value = null
      statsMode.value = 'increment'
      statsDivision.value = 'pro'
      statsReason.value = ''
      statsForm.value = {
        wins: 0,
        losses: 0,
        break_and_run_count: 0
      }
      incrementForm.value = {
        wins: 0,
        losses: 0,
        break_and_run_count: 0
      }
    }

    watch(statsDivision, () => {
      if (selectedPlayer.value) {
        resetStatsForms()
      }
    })

    const getDivisionMatches = (player, division) => {
      return getDivisionValue(player, division, 'wins') + getDivisionValue(player, division, 'losses')
    }

    const getProjectedDivisionStat = (stat) => {
      if (statsMode.value === 'increment') {
        if (stat === 'wins') return getNewWins()
        if (stat === 'losses') return getNewLosses()
        return getNewBreakAndRun()
      }
      if (stat === 'break_and_run_count') {
        return statsForm.value.break_and_run_count
      }
      return statsForm.value[stat]
    }

    const getProjectedOverallStat = (stat) => {
      if (!selectedPlayer.value) return 0
      const updatedDivisionValue = getProjectedDivisionStat(stat)
      const otherDivision = statsDivision.value === 'pro' ? 'student' : 'pro'
      const otherValue = getDivisionValue(selectedPlayer.value, otherDivision, stat)
      return updatedDivisionValue + otherValue
    }

    const updateStats = async () => {
      if (isUpdatingStats.value) return
      if (!selectedPlayer.value) {
        alert('No player selected')
        return
      }

      const divisionName = statsDivision.value === 'student' ? '🎓 Student Division' : '👔 Pro Division'
      let newWins, newLosses, newBreakAndRun, confirmMsg

      if (statsMode.value === 'increment') {
        if (!incrementChanged.value) {
          alert('Please enter at least one change')
          return
        }

        newWins = getNewWins()
        newLosses = getNewLosses()
        newBreakAndRun = getNewBreakAndRun()

        const lastModified = getLastModified(selectedPlayer.value)
        const lastModifiedInfo = lastModified ? `\n\n📝 Last modified: ${formatLastModified(lastModified)}` : ''
        confirmMsg = `Update ${selectedPlayer.value.name}'s ${divisionName} statistics?${lastModifiedInfo}\n\n` +
          `Wins: ${getDivisionValue(selectedPlayer.value, statsDivision.value, 'wins')} + ${incrementForm.value.wins} = ${newWins}\n` +
          `Losses: ${getDivisionValue(selectedPlayer.value, statsDivision.value, 'losses')} + ${incrementForm.value.losses} = ${newLosses}\n` +
          `Break and Run: ${getDivisionValue(selectedPlayer.value, statsDivision.value, 'break_and_run_count')} + ${incrementForm.value.break_and_run_count} = ${newBreakAndRun}`
      } else {
        if (statsForm.value.wins < 0 || statsForm.value.losses < 0 || statsForm.value.break_and_run_count < 0) {
          alert('Statistics cannot be negative')
          return
        }

        if (!statsChanged.value) {
          alert('No changes detected')
          return
        }

        newWins = statsForm.value.wins
        newLosses = statsForm.value.losses
        newBreakAndRun = statsForm.value.break_and_run_count

        const lastModified = getLastModified(selectedPlayer.value)
        const lastModifiedInfo = lastModified ? `\n\n📝 Last modified: ${formatLastModified(lastModified)}` : ''
        confirmMsg = `Update ${selectedPlayer.value.name}'s ${divisionName} statistics?${lastModifiedInfo}\n\n` +
          `Wins: ${getDivisionValue(selectedPlayer.value, statsDivision.value, 'wins')} → ${newWins}\n` +
          `Losses: ${getDivisionValue(selectedPlayer.value, statsDivision.value, 'losses')} → ${newLosses}\n` +
          `Break and Run: ${getDivisionValue(selectedPlayer.value, statsDivision.value, 'break_and_run_count')} → ${newBreakAndRun}`
      }
      
      if (!confirm(confirmMsg)) return

      try {
        isUpdatingStats.value = true
        const payload = statsMode.value === 'increment' ? incrementForm.value : statsForm.value

        const rpcPayload = {
          p_user_id: selectedPlayer.value.id,
          p_division: statsDivision.value,
          p_wins: payload.wins,
          p_losses: payload.losses,
          p_break_and_run: payload.break_and_run_count,
          p_mode: statsMode.value,
          p_reason: statsReason.value || null
        }

        // Security: Don't log sensitive payload data

        // 添加超时机制
        const timeoutPromise = new Promise((_, reject) => {
          setTimeout(() => reject(new Error('Request timeout: The operation took too long. Please try again.')), 30000)
        })

        // 让后端函数自行解析当前管理员 ID，避免传入 auth.users UUID 触发外键错误
        const rpcPromise = supabase.rpc('admin_update_division_stats', rpcPayload)
        const { data, error } = await Promise.race([rpcPromise, timeoutPromise])

        if (error) {
          console.error('RPC error:', error)
          throw error
        }

        if (!data) {
          throw new Error('No data returned from server')
        }

        // Security: Don't log sensitive response data

        const updatedDivisionStats = data?.stats?.[statsDivision.value] || {}
        const overallStats = data?.stats?.overall || {}
        const modeLabel = statsMode.value === 'increment' ? 'increment mode' : 'absolute mode'

        // Optimistically update selected player and store BEFORE closing modal
        if (selectedPlayer.value) {
          const prefix = statsDivision.value === 'student' ? 'student' : 'pro'
          selectedPlayer.value[`${prefix}_wins`] = updatedDivisionStats.wins ?? newWins
          selectedPlayer.value[`${prefix}_losses`] = updatedDivisionStats.losses ?? newLosses
          selectedPlayer.value[`${prefix}_break_and_run_count`] = updatedDivisionStats.break_and_run ?? newBreakAndRun
          // overall totals if provided
          if (overallStats && typeof overallStats.wins === 'number') {
            selectedPlayer.value.wins = overallStats.wins
          }
          if (overallStats && typeof overallStats.losses === 'number') {
            selectedPlayer.value.losses = overallStats.losses
          }
          if (overallStats && typeof overallStats.break_and_run_count === 'number') {
            selectedPlayer.value.break_and_run_count = overallStats.break_and_run_count
          }
        }
        const idx2 = playerStore.players.findIndex(p => p.id === selectedPlayer.value?.id)
        if (idx2 !== -1) {
          const prefix2 = statsDivision.value === 'student' ? 'student' : 'pro'
          playerStore.players[idx2] = {
            ...playerStore.players[idx2],
            [`${prefix2}_wins`]: selectedPlayer.value?.[`${prefix2}_wins`],
            [`${prefix2}_losses`]: selectedPlayer.value?.[`${prefix2}_losses`],
            [`${prefix2}_break_and_run_count`]: selectedPlayer.value?.[`${prefix2}_break_and_run_count`],
            wins: selectedPlayer.value?.wins ?? playerStore.players[idx2].wins,
            losses: selectedPlayer.value?.losses ?? playerStore.players[idx2].losses,
            break_and_run_count: selectedPlayer.value?.break_and_run_count ?? playerStore.players[idx2].break_and_run_count
          }
        }

        // 显示成功消息
        alert(
          `✅ Updated ${selectedPlayer.value.name}'s ${divisionName} stats via ${modeLabel}!\n\n` +
          `New ${divisionName} totals:\n` +
          `• Wins: ${updatedDivisionStats.wins ?? newWins}\n` +
          `• Losses: ${updatedDivisionStats.losses ?? newLosses}\n` +
          `• Break & Run: ${updatedDivisionStats.break_and_run ?? newBreakAndRun}\n\n` +
          `Overall totals now: ${overallStats.wins ?? '-'}W / ${overallStats.losses ?? '-'}L`
        )

        // 关闭模态框并重置状态
        closeStatsModal()
        isUpdatingStats.value = false

        // 在后台刷新数据，不阻塞 UI
        playerStore.fetchPlayers(true).catch(err => {
          console.error('Error refreshing players after stats update:', err)
        })
      } catch (err) {
        console.error('Error updating stats:', err)
        const errorMessage = err.message || err.toString() || 'Unknown error occurred. Please check the console for details.'
        alert('Error updating statistics: ' + errorMessage)
        // 确保状态被重置
        isUpdatingStats.value = false
      }
    }

    const openPointsModal = (player) => {
      selectedPlayer.value = player
      pointsChange.value = 0
      pointsReason.value = ''
      pointsDivision.value = 'pro' // 默认 Pro 组
      isUpdatingPoints.value = false
      showPointsModal.value = true
    }

    const closePointsModal = () => {
      showPointsModal.value = false
      selectedPlayer.value = null
      pointsChange.value = 0
      pointsReason.value = ''
      pointsDivision.value = 'pro'
    }

    const updatePoints = async () => {
      if (isUpdatingPoints.value) return
      if (!selectedPlayer.value || pointsChange.value === 0) {
        alert('Please enter a points value')
        return
      }

      const divisionName = pointsDivision.value === 'pro' ? '👔 Pro' : '🎓 Student'
      const lastModified = getLastModified(selectedPlayer.value)
      const lastModifiedInfo = lastModified ? `\n\n📝 Last modified: ${formatLastModified(lastModified)}` : ''
      const confirmMsg = `Update ${selectedPlayer.value.name}'s ${divisionName} points by ${pointsChange.value}?${lastModifiedInfo}\n\n${pointsReason.value ? `Reason: ${pointsReason.value}` : 'No reason provided'}`
      
      if (!confirm(confirmMsg)) return

      try {
        isUpdatingPoints.value = true
        // 🎯 根据组别调用不同的函数
        const functionName = pointsDivision.value === 'pro' ? 'admin_add_pro_points' : 'admin_add_student_points'
        
        const rpcPayload = {
          p_user_id: selectedPlayer.value.id,
          p_points_change: pointsChange.value,
          p_reason: pointsReason.value || 'No reason provided'
        }

        // Security: Don't log sensitive function calls

        // 添加超时机制
        const timeoutPromise = new Promise((_, reject) => {
          setTimeout(() => reject(new Error('Request timeout: The operation took too long. Please try again.')), 30000)
        })

        // 让后端函数自行解析当前管理员 ID，避免传入 auth.users UUID 触发外键错误
        const rpcPromise = supabase.rpc(functionName, rpcPayload)
        const { data, error } = await Promise.race([rpcPromise, timeoutPromise])

        if (error) {
          console.error('RPC error:', error)
          throw error
        }

        if (!data) {
          throw new Error('No data returned from server')
        }

        // Security: Don't log sensitive response data

        // Optimistically update UI: selected player and store list BEFORE showing alert
        const divisionKey = pointsDivision.value === 'pro' ? 'pro_ranking_points' : 'student_ranking_points'
        if (selectedPlayer.value) {
          selectedPlayer.value[divisionKey] = data.current_total ?? ((selectedPlayer.value[divisionKey] || 0) + pointsChange.value)
        }
        const idx = playerStore.players.findIndex(p => p.id === selectedPlayer.value?.id)
        if (idx !== -1) {
          playerStore.players[idx] = {
            ...playerStore.players[idx],
            [divisionKey]: selectedPlayer.value?.[divisionKey]
          }
        }

        // 显示成功消息
        alert(`✅ Successfully updated ${selectedPlayer.value.name}'s ${divisionName} points!\n\nPoints Change: ${pointsChange.value > 0 ? '+' : ''}${pointsChange.value}\nNew Total (${divisionName}): ${data.current_total}\n\nRecorded for: ${data.year}-${data.month}`)

        // 更新最后修改时间
        if (selectedPlayer.value?.id) {
          lastModifiedMap.value[selectedPlayer.value.id] = {
            time: new Date().toISOString(),
            action: pointsDivision.value === 'pro' ? 'add_pro_points' : 'add_student_points',
            details: { points_change: pointsChange.value }
          }
        }

        // 关闭模态框并重置状态
        closePointsModal()
        isUpdatingPoints.value = false

        // 在后台刷新数据，不阻塞 UI
        Promise.all([
          playerStore.fetchPlayers(true).catch(err => {
            console.error('Error refreshing players after points update:', err)
          }),
          supabase.from('ranking_point_history').select('*').then(({ data: historyData }) => {
            if (historyData) pointHistory.value = historyData
          }).catch(err => {
            console.error('Error refreshing point history:', err)
          }),
          loadLastModifiedTimes().catch(err => {
            console.error('Error refreshing last modified times:', err)
          })
        ]).catch(err => {
          console.error('Error refreshing data after points update:', err)
        })
      } catch (err) {
        console.error('Error updating points:', err)
        const errorMessage = err.message || err.toString() || 'Unknown error occurred. Please check the console for details.'
        alert('Error updating points: ' + errorMessage)
        // 确保状态被重置
        isUpdatingPoints.value = false
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
        await playerStore.fetchPlayers(true)
      } else {
        alert('Error: ' + result.error)
      }
    }

    const confirmDelete = async (player) => {
      if (confirm(`Are you sure you want to delete ${player.name}?`)) {
        const result = await playerStore.deletePlayer(player.id)
        if (result.success) {
          await playerStore.fetchPlayers(true)
        } else {
          alert('Error: ' + result.error)
        }
      }
    }

    // 检查重复的会员信息
    const checkDuplicates = () => {
      // Security: Verify admin access
      if (!authStore.isAdmin) {
        alert('⛔ Access Denied: This function is only available to administrators')
        return
      }
      
      if (!playerStore || !playerStore.players || !Array.isArray(playerStore.players)) {
        alert('Player data not loaded yet. Please wait...')
        return
      }
      const players = playerStore.players
      if (!players || players.length === 0) {
        alert('No players found.')
        return
      }
      const duplicates = {
        membershipCards: {},
        emails: {},
        phones: {},
        names: {}
      }

      // 检查会员卡号重复
      players.forEach(player => {
        const cardNumber = player.membership_card_number
        if (cardNumber && cardNumber !== 'N/A') {
          if (!duplicates.membershipCards[cardNumber]) {
            duplicates.membershipCards[cardNumber] = []
          }
          duplicates.membershipCards[cardNumber].push(player)
        }
      })

      // 检查邮箱重复
      players.forEach(player => {
        const email = player.email
        if (email) {
          if (!duplicates.emails[email]) {
            duplicates.emails[email] = []
          }
          duplicates.emails[email].push(player)
        }
      })

      // 检查手机号重复
      players.forEach(player => {
        const phone = player.phone
        if (phone) {
          if (!duplicates.phones[phone]) {
            duplicates.phones[phone] = []
          }
          duplicates.phones[phone].push(player)
        }
      })

      // 检查姓名重复（完全相同的姓名）
      players.forEach(player => {
        const name = player.name?.toLowerCase().trim()
        if (name) {
          if (!duplicates.names[name]) {
            duplicates.names[name] = []
          }
          duplicates.names[name].push(player)
        }
      })

      // 过滤出真正的重复项（至少2个）
      duplicateResults.value = {
        membershipCards: Object.entries(duplicates.membershipCards || {})
          .filter(([_, players]) => players && Array.isArray(players) && players.length > 1)
          .map(([cardNumber, players]) => ({ value: cardNumber, players: players || [] })),
        emails: Object.entries(duplicates.emails || {})
          .filter(([_, players]) => players && Array.isArray(players) && players.length > 1)
          .map(([email, players]) => ({ value: email, players: players || [] })),
        phones: Object.entries(duplicates.phones || {})
          .filter(([_, players]) => players && Array.isArray(players) && players.length > 1)
          .map(([phone, players]) => ({ value: phone, players: players || [] })),
        names: Object.entries(duplicates.names || {})
          .filter(([_, players]) => players && Array.isArray(players) && players.length > 1)
          .map(([name, players]) => ({ value: name, players: players || [] }))
      }

      showDuplicateModal.value = true
    }

    const closeDuplicateModal = () => {
      showDuplicateModal.value = false
    }

    // 按注册日期排序选手（最新的在前）
    const getSortedPlayersByDate = (players) => {
      if (!players || !Array.isArray(players) || players.length === 0) {
        return []
      }
      return [...players].sort((a, b) => {
        const dateA = new Date(a.created_at || a.updated_at || 0)
        const dateB = new Date(b.created_at || b.updated_at || 0)
        return dateB - dateA // 降序：最新的在前
      })
    }

    // 格式化日期
    const formatDate = (dateString) => {
      if (!dateString) return 'Unknown'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-NZ', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    // 删除重复的选手
    const deleteDuplicatePlayer = async (player) => {
      const confirmMsg = `Are you sure you want to delete this duplicate player?\n\n` +
        `Name: ${player.name}\n` +
        `Card: ${player.membership_card_number || 'N/A'}\n` +
        `Email: ${player.email || 'N/A'}\n` +
        `Phone: ${player.phone || 'N/A'}\n` +
        `Registered: ${formatDate(player.created_at)}\n\n` +
        `⚠️ This action cannot be undone!`
      
      if (!confirm(confirmMsg)) return

      try {
        const result = await playerStore.deletePlayer(player.id)
        if (result.success) {
          // 刷新选手列表
          await playerStore.fetchPlayers(true)
          // 重新检查重复项
          checkDuplicates()
          alert(`✅ Successfully deleted ${player.name}`)
        } else {
          alert('Error deleting player: ' + result.error)
        }
      } catch (err) {
        console.error('Error deleting duplicate player:', err)
        alert('Error deleting player: ' + err.message)
      }
    }

    // 批量删除最旧的重复项（保留最新的）
    const deleteOldDuplicates = async (players, type) => {
      // Security: Verify admin access
      if (!authStore.isAdmin) {
        alert('⛔ Access Denied: This function is only available to administrators')
        return
      }
      
      if (!players || !Array.isArray(players) || players.length === 0) {
        alert('Invalid players data')
        return
      }
      
      const sorted = getSortedPlayersByDate(players)
      if (!sorted || sorted.length === 0) {
        alert('No players to process')
        return
      }
      
      const newest = sorted[0]
      const oldOnes = sorted.slice(1)

      if (oldOnes.length === 0) {
        alert('No old records to delete')
        return
      }

      const typeName = type === 'membershipCard' ? 'Membership Card' : 
                      type === 'email' ? 'Email' : 'Phone'
      
      const confirmMsg = `Delete ${oldOnes.length} old duplicate record(s) and keep the newest?\n\n` +
        `✅ KEEPING (Newest):\n` +
        `   ${newest.name} - Registered: ${formatDate(newest.created_at)}\n\n` +
        `🗑️ DELETING (Old):\n` +
        oldOnes.map(p => `   ${p.name} - Registered: ${formatDate(p.created_at)}`).join('\n') +
        `\n\n⚠️ This action cannot be undone!`
      
      if (!confirm(confirmMsg)) return

      let successCount = 0
      let errorCount = 0
      const errors = []

      for (const player of oldOnes) {
        try {
          const result = await playerStore.deletePlayer(player.id)
          if (result.success) {
            successCount++
          } else {
            errorCount++
            errors.push(`${player.name}: ${result.error}`)
          }
        } catch (err) {
          errorCount++
          errors.push(`${player.name}: ${err.message}`)
        }
      }

          // 刷新选手列表
          await playerStore.fetchPlayers(true)
          // 重新检查重复项
          checkDuplicates()

      if (errorCount === 0) {
        alert(`✅ Successfully deleted ${successCount} old duplicate record(s)!\n\nKept: ${newest.name}`)
      } else {
        alert(`⚠️ Deleted ${successCount} record(s), but ${errorCount} failed:\n\n${errors.join('\n')}`)
      }
    }

    onMounted(async () => {
      await playerStore.fetchPlayers()
      await loadLastModifiedTimes()
      
      // Load point history for ranking points calculation
      try {
        const { data, error } = await supabase
          .from('ranking_point_history')
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
      recentModifiedFilter,
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
      getLastModified,
      formatLastModified,
      isRecentlyModified,
      showStatsModal,
      isUpdatingStats,
      statsMode,
      statsForm,
      statsDivision,
      statsReason,
      incrementForm,
      incrementChanged,
      getNewWins,
      getNewLosses,
      getNewBreakAndRun,
      calculateIncrementWinRate,
      getDivisionValue,
      getDivisionMatches,
      calculateDivisionWinRate,
      getProjectedOverallStat,
      openStatsModal,
      closeStatsModal,
      updateStats,
      openPointsModal,
      closePointsModal,
      showPointsModal,
      isUpdatingPoints,
      selectedPlayer,
      pointsChange,
      pointsReason,
      pointsDivision, // 🎯 新增：组别选择
      updatePoints,
      editPlayer,
      closeModal,
      savePlayer,
      confirmDelete,
      checkDuplicates,
      showDuplicateModal,
      duplicateResults,
      closeDuplicateModal,
      deleteDuplicatePlayer,
      deleteOldDuplicates,
      getSortedPlayersByDate,
      formatDate,
      authStore
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

.header-actions {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
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

/* 双积分显示 */
.dual-points-display {
  display: flex;
  gap: 1.5rem;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #dee2e6;
}

.points-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.points-label {
  font-size: 0.875rem;
  font-weight: 600;
  color: #6c757d;
}

.points-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1a1a2e;
}

/* 双组别战绩显示 */
.dual-stats-display {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 1rem;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #dee2e6;
}

.stats-item {
  background: #ffffff;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  padding: 0.75rem 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.stats-title {
  font-weight: 600;
  color: #1a1a2e;
}

.stats-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.95rem;
  color: #495057;
}

.stats-row strong {
  color: #1a1a2e;
}

.overall-row {
  border-top: 1px dashed #cfe2ff;
  margin-top: 0.5rem;
  padding-top: 0.5rem;
}

.overall-summary {
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px dashed #dee2e6;
  font-weight: 500;
  color: #0a58ca;
}

/* 组别选择器 */
.division-selector {
  margin-bottom: 1.5rem;
  padding-bottom: 1.5rem;
  border-bottom: 2px solid #e9ecef;
}

/* 模式选择器样式 */
.mode-selector {
  margin-bottom: 1.5rem;
  padding-bottom: 1.5rem;
  border-bottom: 2px solid #e9ecef;
}

.radio-group {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-top: 0.5rem;
}

.radio-option {
  display: flex;
  align-items: flex-start;
  padding: 1rem;
  border: 2px solid #dee2e6;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.radio-option:hover {
  border-color: #0d6efd;
  background: #f8f9ff;
}

.radio-option input[type="radio"] {
  margin-top: 0.25rem;
  margin-right: 0.75rem;
  cursor: pointer;
}

.radio-option input[type="radio"]:checked + .radio-label {
  color: #0d6efd;
}

.radio-option:has(input:checked) {
  border-color: #0d6efd;
  background: #e7f1ff;
}

.radio-label {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.radio-label strong {
  font-size: 1rem;
  color: #1a1a2e;
}

.radio-label small {
  font-size: 0.875rem;
  color: #6c757d;
}

/* 增量模式提示 */
.increment-hint {
  background: #e7f3ff;
  border-left: 4px solid #0d6efd;
  padding: 0.75rem 1rem;
  margin-bottom: 1rem;
  border-radius: 4px;
}

.increment-hint p {
  margin: 0;
  color: #0a58ca;
  font-weight: 500;
}

/* 表单行布局 */
.form-row {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-row .form-group {
  flex: 1;
  margin-bottom: 0;
}

.col-6 {
  flex: 0 0 calc(50% - 0.5rem);
}

/* 增量预览样式 */
.increment-preview {
  background: #f0f9ff;
  border: 2px solid #0d6efd;
  padding: 1rem;
  border-radius: 8px;
  margin-top: 1rem;
}

.increment-preview p {
  margin-bottom: 0.75rem;
  font-weight: 600;
  color: #0a58ca;
}

.preview-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0;
  border-bottom: 1px solid #cfe2ff;
}

.preview-row:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.preview-label {
  font-weight: 500;
  color: #495057;
  min-width: 120px;
}

.preview-calc {
  font-family: 'Courier New', monospace;
  color: #212529;
  font-size: 0.95rem;
}

.preview-calc strong {
  font-size: 1.1rem;
  margin-left: 0.5rem;
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

/* Mobile players grid - hidden by default, shown on mobile */
.mobile-players-grid {
  display: none;
}

.modal-footer {
  padding: 1.5rem;
  border-top: 2px solid #dee2e6;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

@media (max-width: 768px) {
  /* 页面标题优化 */
  .page-header {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }

  .page-header h1 {
    font-size: 20px;
  }

  .page-header .btn-primary {
    width: 100%;
    min-height: 48px;
    font-size: 16px;
    font-weight: 600;
  }

  /* 筛选栏优化 */
  .filter-section .row {
    flex-direction: column;
  }

  .col {
    width: 100% !important;
  }

  .form-control {
    min-height: 48px;
    font-size: 16px;
  }

  .form-label {
    font-size: 14px;
    font-weight: 600;
  }

  /* 隐藏表格，显示卡片 */
  .table-container {
    display: none;
  }

  /* 最近修改的行高亮 */
  .table tbody tr.recently-modified {
    background-color: rgba(102, 126, 234, 0.08) !important;
    border-left: 4px solid #667eea;
  }

  .table tbody tr.recently-modified:hover {
    background-color: rgba(102, 126, 234, 0.15) !important;
  }

  .last-modified-cell {
    font-size: 0.875rem;
  }

  .last-modified-time {
    color: #6c757d;
    font-weight: 500;
  }

  .last-modified-time.recent {
    color: #667eea;
    font-weight: 600;
  }

  /* 玩家卡片布局 */
  .mobile-players-grid {
    display: grid !important;
    grid-template-columns: 1fr;
    gap: 12px;
    margin-top: 16px;
  }

  .mobile-player-card {
    background: var(--color-card-bg);
    border: 2px solid var(--color-border);
    border-radius: 12px;
    padding: 16px;
    transition: all 0.2s;
  }

  .mobile-player-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  }

  .mobile-player-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 12px;
    padding-bottom: 12px;
    border-bottom: 1px solid var(--color-border);
  }

  .mobile-player-info {
    flex: 1;
  }

  .mobile-player-name {
    font-size: 18px;
    font-weight: 700;
    color: var(--color-text-primary);
    margin-bottom: 4px;
  }

  .mobile-player-card-num {
    font-size: 12px;
    color: var(--color-text-secondary);
  }

  .mobile-player-badges {
    display: flex;
    flex-direction: column;
    gap: 4px;
    align-items: flex-end;
  }

  .mobile-player-stats {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
    margin-bottom: 12px;
  }

  .mobile-stat-item {
    background: rgba(102, 126, 234, 0.05);
    padding: 10px;
    border-radius: 8px;
    text-align: center;
  }

  .mobile-stat-label {
    font-size: 11px;
    color: var(--color-text-secondary);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
  }

  .mobile-stat-value {
    font-size: 16px;
    font-weight: 700;
    color: var(--color-text-primary);
  }

  .mobile-player-actions {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
  }

  .mobile-action-btn {
    min-height: 44px;
    padding: 10px;
    font-size: 14px;
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

  .mobile-action-btn.view {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
  }

  .mobile-action-btn.edit {
    background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
    color: white;
  }

  .mobile-action-btn.delete {
    background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
    color: white;
  }

  .action-buttons {
    flex-direction: column;
  }

  .action-buttons .btn {
    width: 100%;
  }

  /* 模态框移动端优化 */
  .modal-content {
    width: 95vw;
    max-width: 95vw;
    margin: 20px auto;
    max-height: 90vh;
    overflow-y: auto;
  }

  .modal-header h2 {
    font-size: 18px;
  }

  .modal-body .form-control {
    min-height: 48px;
    font-size: 16px;
  }

  .modal-body .form-label {
    font-size: 14px;
    font-weight: 600;
  }

  .modal-footer {
    flex-direction: column;
    gap: 8px;
  }

  .modal-footer .btn {
    width: 100%;
    min-height: 48px;
    font-size: 16px;
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

/* Duplicate Check Modal Styles */
.duplicate-section {
  margin-bottom: 2rem;
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid #ffc107;
}

.duplicate-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1a1a2e;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.duplicate-note {
  font-size: 0.875rem;
  color: #6c757d;
  font-style: italic;
  margin-bottom: 1rem;
}

.duplicate-group {
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: white;
  border-radius: 6px;
  border: 1px solid #dee2e6;
}

.duplicate-value {
  font-size: 1rem;
  font-weight: 600;
  color: #dc3545;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #ffc107;
}

.duplicate-players {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.duplicate-player-item {
  display: grid;
  grid-template-columns: 2fr 1fr 1.5fr 1.5fr 1.5fr auto;
  gap: 1rem;
  padding: 0.75rem;
  background: #f8f9fa;
  border-radius: 4px;
  border-left: 3px solid #667eea;
  align-items: center;
}

.duplicate-player-item.keep-newest {
  background: #f0fdf4;
  border-left-color: #10b981;
}

.duplicate-player-item.delete-oldest {
  background: #fef2f2;
  border-left-color: #ef4444;
  opacity: 0.8;
}

.player-name {
  font-weight: 600;
  color: #1a1a2e;
}

.player-info {
  font-size: 0.875rem;
  color: #6c757d;
}

@media (max-width: 768px) {
  .duplicate-player-item {
    grid-template-columns: 1fr;
    gap: 0.5rem;
  }
  
  .player-info {
    font-size: 0.8125rem;
  }
}

.break-run-count {
  color: #667eea;
  font-size: 1.1rem;
}
</style>


