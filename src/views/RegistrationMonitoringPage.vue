<template>
  <div class="monitoring-page">
    <div class="monitoring-container">
      <div class="monitoring-header">
        <h1>📊 Registration Monitoring Dashboard</h1>
        <p>Monitor and manage user registrations to prevent email bounce issues</p>
      </div>

      <div class="monitoring-stats">
        <div class="stat-card">
          <div class="stat-icon">👥</div>
          <div class="stat-content">
            <h3>{{ totalUsers }}</h3>
            <p>Total Users</p>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon">⚠️</div>
          <div class="stat-content">
            <h3>{{ duplicateCount }}</h3>
            <p>Duplicate Registrations</p>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon">🚨</div>
          <div class="stat-content">
            <h3>{{ suspiciousCount }}</h3>
            <p>Suspicious Registrations</p>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon">✅</div>
          <div class="stat-content">
            <h3>{{ verifiedCount }}</h3>
            <p>Verified Emails</p>
          </div>
        </div>
      </div>

      <div class="monitoring-tabs">
        <button 
          @click="activeTab = 'duplicates'" 
          :class="{ active: activeTab === 'duplicates' }"
          class="tab-button"
        >
          🔄 Duplicate Registrations
        </button>
        <button 
          @click="activeTab = 'suspicious'" 
          :class="{ active: activeTab === 'suspicious' }"
          class="tab-button"
        >
          🚨 Suspicious Registrations
        </button>
        <button 
          @click="activeTab = 'recent'" 
          :class="{ active: activeTab === 'recent' }"
          class="tab-button"
        >
          📅 Recent Registrations
        </button>
      </div>

      <div class="monitoring-content">
        <!-- Duplicate Registrations Tab -->
        <div v-if="activeTab === 'duplicates'" class="tab-content">
          <div class="content-header">
            <h2>Duplicate Registrations</h2>
            <button @click="cleanupDuplicates" class="btn btn-danger" :disabled="cleaning">
              {{ cleaning ? 'Cleaning...' : 'Clean Up Duplicates' }}
            </button>
          </div>
          
          <div v-if="duplicates.length === 0" class="empty-state">
            <p>✅ No duplicate registrations found!</p>
          </div>
          
          <div v-else class="table-container">
            <table class="monitoring-table">
              <thead>
                <tr>
                  <th>Email</th>
                  <th>Name</th>
                  <th>Phone</th>
                  <th>Count</th>
                  <th>First Registration</th>
                  <th>Last Registration</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="duplicate in duplicates" :key="duplicate.email">
                  <td>{{ duplicate.email }}</td>
                  <td>{{ duplicate.name }}</td>
                  <td>{{ duplicate.phone }}</td>
                  <td><span class="badge badge-warning">{{ duplicate.duplicate_count }}</span></td>
                  <td>{{ formatDate(duplicate.first_registration) }}</td>
                  <td>{{ formatDate(duplicate.last_registration) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Suspicious Registrations Tab -->
        <div v-if="activeTab === 'suspicious'" class="tab-content">
          <div class="content-header">
            <h2>Suspicious Registrations</h2>
            <button @click="loadSuspiciousRegistrations" class="btn btn-primary">
              Refresh
            </button>
          </div>
          
          <div v-if="suspicious.length === 0" class="empty-state">
            <p>✅ No suspicious registrations found!</p>
          </div>
          
          <div v-else class="table-container">
            <table class="monitoring-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Phone</th>
                  <th>Reason</th>
                  <th>Registration Date</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="susp in suspicious" :key="susp.id">
                  <td>{{ susp.name }}</td>
                  <td>{{ susp.email }}</td>
                  <td>{{ susp.phone || 'N/A' }}</td>
                  <td><span class="badge badge-danger">{{ susp.suspicious_reason }}</span></td>
                  <td>{{ formatDate(susp.created_at) }}</td>
                  <td>
                    <button @click="deleteSuspiciousUser(susp.id)" class="btn btn-sm btn-outline-danger">
                      Delete
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Recent Registrations Tab -->
        <div v-if="activeTab === 'recent'" class="tab-content">
          <div class="content-header">
            <h2>Recent Registrations (Last 7 Days)</h2>
            <button @click="loadRecentRegistrations" class="btn btn-primary">
              Refresh
            </button>
          </div>
          
          <div class="table-container">
            <table class="monitoring-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Phone</th>
                  <th>Birthday</th>
                  <th>Registration Date</th>
                  <th>Email Verified</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="user in recentUsers" :key="user.id">
                  <td>{{ user.name }}</td>
                  <td>{{ user.email }}</td>
                  <td>{{ user.phone || 'N/A' }}</td>
                  <td>{{ user.birthday || 'N/A' }}</td>
                  <td>{{ formatDate(user.created_at) }}</td>
                  <td>
                    <span :class="user.email_verified ? 'badge badge-success' : 'badge badge-warning'">
                      {{ user.email_verified ? 'Verified' : 'Pending' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { createClient } from '@supabase/supabase-js'

// Initialize Supabase client
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY
const supabase = createClient(supabaseUrl, supabaseKey)

export default {
  name: 'RegistrationMonitoringPage',
  setup() {
    const activeTab = ref('duplicates')
    const duplicates = ref([])
    const suspicious = ref([])
    const recentUsers = ref([])
    const cleaning = ref(false)
    
    // Stats
    const totalUsers = ref(0)
    const duplicateCount = ref(0)
    const suspiciousCount = ref(0)
    const verifiedCount = ref(0)

    const loadDuplicates = async () => {
      try {
        const { data, error } = await supabase.rpc('detect_duplicate_registrations')
        if (error) throw error
        duplicates.value = data || []
        duplicateCount.value = data?.length || 0
      } catch (err) {
        console.error('Error loading duplicates:', err)
      }
    }

    const loadSuspiciousRegistrations = async () => {
      try {
        const { data, error } = await supabase.rpc('detect_suspicious_registrations')
        if (error) throw error
        suspicious.value = data || []
        suspiciousCount.value = data?.length || 0
      } catch (err) {
        console.error('Error loading suspicious registrations:', err)
      }
    }

    const loadRecentRegistrations = async () => {
      try {
        const { data, error } = await supabase
          .from('users')
          .select('*')
          .gte('created_at', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString())
          .order('created_at', { ascending: false })
        
        if (error) throw error
        recentUsers.value = data || []
      } catch (err) {
        console.error('Error loading recent registrations:', err)
      }
    }

    const loadStats = async () => {
      try {
        // Total users
        const { count: total } = await supabase
          .from('users')
          .select('*', { count: 'exact', head: true })
        totalUsers.value = total || 0

        // Verified emails
        const { count: verified } = await supabase
          .from('users')
          .select('*', { count: 'exact', head: true })
          .eq('email_verified', true)
        verifiedCount.value = verified || 0
      } catch (err) {
        console.error('Error loading stats:', err)
      }
    }

    const cleanupDuplicates = async () => {
      cleaning.value = true
      try {
        const { data, error } = await supabase.rpc('cleanup_duplicate_registrations')
        if (error) throw error
        
        alert(`✅ Cleaned up ${data} duplicate registrations!`)
        await loadDuplicates()
        await loadStats()
      } catch (err) {
        console.error('Error cleaning up duplicates:', err)
        alert('❌ Error cleaning up duplicates')
      } finally {
        cleaning.value = false
      }
    }

    const deleteSuspiciousUser = async (userId) => {
      if (!confirm('Are you sure you want to delete this user?')) return
      
      try {
        const { error } = await supabase
          .from('users')
          .delete()
          .eq('id', userId)
        
        if (error) throw error
        
        alert('✅ User deleted successfully!')
        await loadSuspiciousRegistrations()
        await loadStats()
      } catch (err) {
        console.error('Error deleting user:', err)
        alert('❌ Error deleting user')
      }
    }

    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleString('en-NZ', { timeZone: 'Pacific/Auckland', hour12: false })
    }

    onMounted(async () => {
      await Promise.all([
        loadDuplicates(),
        loadSuspiciousRegistrations(),
        loadRecentRegistrations(),
        loadStats()
      ])
    })

    return {
      activeTab,
      duplicates,
      suspicious,
      recentUsers,
      cleaning,
      totalUsers,
      duplicateCount,
      suspiciousCount,
      verifiedCount,
      loadDuplicates,
      loadSuspiciousRegistrations,
      loadRecentRegistrations,
      cleanupDuplicates,
      deleteSuspiciousUser,
      formatDate
    }
  }
}
</script>

<style scoped>
.monitoring-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #1a1a2e 0%, #0f3460 100%);
  padding: 2rem;
}

.monitoring-container {
  max-width: 1200px;
  margin: 0 auto;
}

.monitoring-header {
  text-align: center;
  color: white;
  margin-bottom: 2rem;
}

.monitoring-header h1 {
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
}

.monitoring-header p {
  font-size: 1.1rem;
  opacity: 0.9;
}

.monitoring-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 1rem;
}

.stat-icon {
  font-size: 2rem;
}

.stat-content h3 {
  font-size: 2rem;
  margin: 0;
  color: var(--primary-color);
}

.stat-content p {
  margin: 0;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.monitoring-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
}

.tab-button {
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: none;
  padding: 1rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.tab-button:hover {
  background: rgba(255, 255, 255, 0.2);
}

.tab-button.active {
  background: white;
  color: var(--primary-color);
}

.monitoring-content {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.content-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.content-header h2 {
  margin: 0;
  color: var(--dark-color);
}

.table-container {
  overflow-x: auto;
}

.monitoring-table {
  width: 100%;
  border-collapse: collapse;
}

.monitoring-table th,
.monitoring-table td {
  padding: 0.75rem;
  text-align: left;
  border-bottom: 1px solid var(--border-color);
}

.monitoring-table th {
  background: var(--light-bg);
  font-weight: 600;
  color: var(--dark-color);
}

.badge {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
}

.badge-warning {
  background: #fff3cd;
  color: #856404;
}

.badge-danger {
  background: #f8d7da;
  color: #721c24;
}

.badge-success {
  background: #d4edda;
  color: #155724;
}

.empty-state {
  text-align: center;
  padding: 3rem;
  color: var(--text-secondary);
}

.btn {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
}

.btn-primary {
  background: var(--primary-color);
  color: white;
}

.btn-danger {
  background: #dc3545;
  color: white;
}

.btn-outline-danger {
  background: transparent;
  color: #dc3545;
  border: 1px solid #dc3545;
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.btn:hover {
  opacity: 0.9;
  transform: translateY(-1px);
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

/* Mobile Optimization */
@media (max-width: 768px) {
  .monitoring-page {
    padding: 1rem;
  }

  .monitoring-header h1 {
    font-size: 2rem;
  }

  .monitoring-stats {
    grid-template-columns: repeat(2, 1fr);
  }

  .stat-card {
    padding: 1rem;
  }

  .stat-icon {
    font-size: 1.5rem;
  }

  .stat-content h3 {
    font-size: 1.5rem;
  }

  .monitoring-tabs {
    flex-wrap: wrap;
  }

  .tab-button {
    padding: 0.75rem 1rem;
    font-size: 0.9rem;
  }

  .monitoring-content {
    padding: 1rem;
  }

  .content-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }

  .monitoring-table {
    font-size: 0.875rem;
  }

  .monitoring-table th,
  .monitoring-table td {
    padding: 0.5rem;
  }
}
</style>
