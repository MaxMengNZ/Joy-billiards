<template>
  <div class="unverified-users-page">
    <div class="unverified-container">
      <div class="page-header">
        <h1>📧 未验证用户管理</h1>
        <p>管理邮箱未验证的用户，帮助他们完成注册流程</p>
      </div>

      <div class="stats-cards">
        <div class="stat-card">
          <div class="stat-icon">👥</div>
          <div class="stat-content">
            <h3>{{ totalUnverified }}</h3>
            <p>未验证用户</p>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon">⏰</div>
          <div class="stat-content">
            <h3>{{ expiredTokens }}</h3>
            <p>过期令牌</p>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon">✅</div>
          <div class="stat-content">
            <h3>{{ validTokens }}</h3>
            <p>有效令牌</p>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon">📅</div>
          <div class="stat-content">
            <h3>{{ avgDaysUnverified }}</h3>
            <p>平均未验证天数</p>
          </div>
        </div>
      </div>

      <div class="action-buttons">
        <button @click="resendAllVerifications" class="btn btn-primary" :disabled="resending">
          <i class="fas fa-paper-plane"></i>
          {{ resending ? '发送中...' : '重新发送所有验证邮件' }}
        </button>
        <button @click="loadUnverifiedUsers" class="btn btn-secondary">
          <i class="fas fa-refresh"></i>
          刷新列表
        </button>
      </div>

      <div class="users-table-container">
        <div class="table-header">
          <h2>未验证用户列表</h2>
          <div class="table-filters">
            <select v-model="filterStatus" @change="filterUsers">
              <option value="all">所有状态</option>
              <option value="No Token">无令牌</option>
              <option value="Expired">已过期</option>
              <option value="Valid">有效</option>
            </select>
          </div>
        </div>

        <div v-if="loading" class="loading-state">
          <i class="fas fa-spinner fa-spin"></i>
          <p>加载中...</p>
        </div>

        <div v-else-if="filteredUsers.length === 0" class="empty-state">
          <p>✅ 没有未验证用户！</p>
        </div>

        <div v-else class="table-container">
          <table class="users-table">
            <thead>
              <tr>
                <th>姓名</th>
                <th>邮箱</th>
                <th>电话</th>
                <th>注册时间</th>
                <th>未验证天数</th>
                <th>令牌状态</th>
                <th>过期时间</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="user in filteredUsers" :key="user.id" :class="getRowClass(user)">
                <td>{{ user.name }}</td>
                <td>{{ user.email }}</td>
                <td>{{ user.phone || 'N/A' }}</td>
                <td>{{ formatDate(user.created_at) }}</td>
                <td>
                  <span :class="getDaysClass(user.days_since_registration)">
                    {{ user.days_since_registration }} 天
                  </span>
                </td>
                <td>
                  <span :class="getStatusClass(user.token_status)">
                    {{ user.token_status }}
                  </span>
                </td>
                <td>{{ user.email_verification_expires_at ? formatDate(user.email_verification_expires_at) : 'N/A' }}</td>
                <td>
                  <button 
                    @click="resendVerification(user.email)" 
                    class="btn btn-sm btn-outline-primary"
                    :disabled="resending"
                  >
                    <i class="fas fa-paper-plane"></i>
                    重发邮件
                  </button>
                  <button 
                    @click="deleteUser(user.id)" 
                    class="btn btn-sm btn-outline-danger"
                    :disabled="deleting"
                  >
                    <i class="fas fa-trash"></i>
                    删除
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="help-section">
        <h3>💡 帮助说明</h3>
        <div class="help-content">
          <div class="help-item">
            <strong>令牌状态说明：</strong>
            <ul>
              <li><span class="badge badge-success">有效</span> - 验证邮件已发送，7天内有效</li>
              <li><span class="badge badge-warning">已过期</span> - 验证邮件已过期，需要重新发送</li>
              <li><span class="badge badge-danger">无令牌</span> - 从未发送过验证邮件</li>
            </ul>
          </div>
          <div class="help-item">
            <strong>操作建议：</strong>
            <ul>
              <li>优先处理"无令牌"和"已过期"的用户</li>
              <li>超过7天未验证的用户建议联系确认邮箱地址</li>
              <li>可以批量重新发送验证邮件</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { createClient } from '@supabase/supabase-js'

// Initialize Supabase client
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY
const supabase = createClient(supabaseUrl, supabaseKey)

export default {
  name: 'UnverifiedUsersPage',
  setup() {
    const unverifiedUsers = ref([])
    const loading = ref(false)
    const resending = ref(false)
    const deleting = ref(false)
    const filterStatus = ref('all')

    const filteredUsers = computed(() => {
      if (filterStatus.value === 'all') {
        return unverifiedUsers.value
      }
      return unverifiedUsers.value.filter(user => user.token_status === filterStatus.value)
    })

    const totalUnverified = computed(() => unverifiedUsers.value.length)
    const expiredTokens = computed(() => unverifiedUsers.value.filter(u => u.token_status === 'Expired').length)
    const validTokens = computed(() => unverifiedUsers.value.filter(u => u.token_status === 'Valid').length)
    const avgDaysUnverified = computed(() => {
      if (unverifiedUsers.value.length === 0) return 0
      const totalDays = unverifiedUsers.value.reduce((sum, user) => sum + user.days_since_registration, 0)
      return Math.round(totalDays / unverifiedUsers.value.length)
    })

    const loadUnverifiedUsers = async () => {
      loading.value = true
      try {
        const { data, error } = await supabase.rpc('admin_get_unverified_users')
        if (error) throw error
        unverifiedUsers.value = data || []
      } catch (err) {
        console.error('Error loading unverified users:', err)
        alert('❌ 加载未验证用户失败')
      } finally {
        loading.value = false
      }
    }

    const resendVerification = async (email) => {
      resending.value = true
      try {
        // 调用 Edge Function 发送验证邮件
        const response = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/resend-verification-email`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`
          },
          body: JSON.stringify({ email })
        })

        const result = await response.json()

        if (!response.ok) {
          throw new Error(result.error || '发送失败')
        }

        alert(`✅ 验证邮件已重新发送到 ${email}`)
        await loadUnverifiedUsers()
      } catch (err) {
        console.error('Error resending verification:', err)
        alert('❌ 重新发送验证邮件失败: ' + err.message)
      } finally {
        resending.value = false
      }
    }

    const resendAllVerifications = async () => {
      if (!confirm('确定要重新发送所有验证邮件吗？')) return
      
      resending.value = true
      try {
        const { data, error } = await supabase.rpc('resend_verification_batch')
        if (error) throw error
        
        alert(`✅ 已重新发送 ${data} 个验证邮件`)
        await loadUnverifiedUsers()
      } catch (err) {
        console.error('Error resending all verifications:', err)
        alert('❌ 批量发送验证邮件失败')
      } finally {
        resending.value = false
      }
    }

    const deleteUser = async (userId) => {
      if (!confirm('确定要删除这个用户吗？此操作不可撤销！')) return
      
      deleting.value = true
      try {
        const { error } = await supabase
          .from('users')
          .delete()
          .eq('id', userId)
        
        if (error) throw error
        
        alert('✅ 用户已删除')
        await loadUnverifiedUsers()
      } catch (err) {
        console.error('Error deleting user:', err)
        alert('❌ 删除用户失败')
      } finally {
        deleting.value = false
      }
    }

    const filterUsers = () => {
      // Filter is handled by computed property
    }

    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleString('en-NZ', { timeZone: 'Pacific/Auckland', hour12: false })
    }

    const getRowClass = (user) => {
      if (user.days_since_registration > 7) return 'row-urgent'
      if (user.token_status === 'Expired') return 'row-expired'
      if (user.token_status === 'No Token') return 'row-no-token'
      return ''
    }

    const getDaysClass = (days) => {
      if (days > 7) return 'days-urgent'
      if (days > 3) return 'days-warning'
      return 'days-normal'
    }

    const getStatusClass = (status) => {
      switch (status) {
        case 'Valid': return 'badge badge-success'
        case 'Expired': return 'badge badge-warning'
        case 'No Token': return 'badge badge-danger'
        default: return 'badge badge-secondary'
      }
    }

    onMounted(() => {
      loadUnverifiedUsers()
    })

    return {
      unverifiedUsers,
      filteredUsers,
      loading,
      resending,
      deleting,
      filterStatus,
      totalUnverified,
      expiredTokens,
      validTokens,
      avgDaysUnverified,
      loadUnverifiedUsers,
      resendVerification,
      resendAllVerifications,
      deleteUser,
      filterUsers,
      formatDate,
      getRowClass,
      getDaysClass,
      getStatusClass
    }
  }
}
</script>

<style scoped>
.unverified-users-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #1a1a2e 0%, #0f3460 100%);
  padding: 2rem;
}

.unverified-container {
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  text-align: center;
  color: white;
  margin-bottom: 2rem;
}

.page-header h1 {
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
}

.page-header p {
  font-size: 1.1rem;
  opacity: 0.9;
}

.stats-cards {
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

.action-buttons {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  justify-content: center;
}

.btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-primary {
  background: var(--primary-color);
  color: white;
}

.btn-secondary {
  background: #6c757d;
  color: white;
}

.btn-outline-primary {
  background: transparent;
  color: var(--primary-color);
  border: 1px solid var(--primary-color);
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

.users-table-container {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  margin-bottom: 2rem;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.table-header h2 {
  margin: 0;
  color: var(--dark-color);
}

.table-filters select {
  padding: 0.5rem;
  border: 1px solid var(--border-color);
  border-radius: 6px;
}

.table-container {
  overflow-x: auto;
}

.users-table {
  width: 100%;
  border-collapse: collapse;
}

.users-table th,
.users-table td {
  padding: 0.75rem;
  text-align: left;
  border-bottom: 1px solid var(--border-color);
}

.users-table th {
  background: var(--light-bg);
  font-weight: 600;
  color: var(--dark-color);
}

.row-urgent {
  background-color: #fff5f5;
}

.row-expired {
  background-color: #fffbf0;
}

.row-no-token {
  background-color: #f8f9fa;
}

.days-urgent {
  color: #dc3545;
  font-weight: bold;
}

.days-warning {
  color: #ffc107;
  font-weight: bold;
}

.days-normal {
  color: #28a745;
}

.badge {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
}

.badge-success {
  background: #d4edda;
  color: #155724;
}

.badge-warning {
  background: #fff3cd;
  color: #856404;
}

.badge-danger {
  background: #f8d7da;
  color: #721c24;
}

.badge-secondary {
  background: #e2e3e5;
  color: #383d41;
}

.loading-state,
.empty-state {
  text-align: center;
  padding: 3rem;
  color: var(--text-secondary);
}

.loading-state i {
  font-size: 2rem;
  margin-bottom: 1rem;
}

.help-section {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.help-section h3 {
  margin-bottom: 1rem;
  color: var(--dark-color);
}

.help-content {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
}

.help-item ul {
  margin: 0.5rem 0;
  padding-left: 1.5rem;
}

.help-item li {
  margin: 0.25rem 0;
}

/* Mobile Optimization */
@media (max-width: 768px) {
  .unverified-users-page {
    padding: 1rem;
  }

  .page-header h1 {
    font-size: 2rem;
  }

  .stats-cards {
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

  .action-buttons {
    flex-direction: column;
  }

  .users-table-container {
    padding: 1rem;
  }

  .table-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }

  .users-table {
    font-size: 0.875rem;
  }

  .users-table th,
  .users-table td {
    padding: 0.5rem;
  }

  .help-content {
    grid-template-columns: 1fr;
  }
}
</style>
