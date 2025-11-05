<template>
  <div class="debug-page">
    <h1>🔍 排行榜数据调试</h1>
    
    <button @click="loadData" class="btn btn-primary">🔄 刷新数据</button>
    
    <div v-if="loading" class="loading">加载中...</div>
    
    <div v-else>
      <h2>📊 数据库原始数据</h2>
      
      <h3>1. users 表数据（Penelope）</h3>
      <pre>{{ usersData }}</pre>
      
      <h3>2. public_users 视图数据（Penelope）</h3>
      <pre>{{ publicUsersData }}</pre>
      
      <h3>3. ranking_point_history 数据（Penelope）</h3>
      <pre>{{ historyData }}</pre>
      
      <h3>4. 所有有积分的玩家（从 public_users）</h3>
      <table class="table">
        <thead>
          <tr>
            <th>排名</th>
            <th>姓名</th>
            <th>积分</th>
            <th>战绩</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(player, index) in allPlayers" :key="player.id">
            <td>{{ index + 1 }}</td>
            <td>{{ player.name }}</td>
            <td>{{ player.ranking_points }}</td>
            <td>{{ player.wins }}W - {{ player.losses }}L</td>
          </tr>
        </tbody>
      </table>
      
      <h3>5. 排行榜页面计算的数据</h3>
      <p>当前年份: {{ currentYear }}</p>
      <p>当前月份: {{ currentMonth }}</p>
      <pre>{{ leaderboardData }}</pre>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { supabase } from '../config/supabase'

export default {
  name: 'DebugLeaderboard',
  setup() {
    const loading = ref(false)
    const usersData = ref(null)
    const publicUsersData = ref(null)
    const historyData = ref(null)
    const allPlayers = ref([])
    const leaderboardData = ref(null)
    
    const nzDate = new Date(new Date().toLocaleString("en-US", { timeZone: "Pacific/Auckland" }))
    const currentYear = nzDate.getFullYear()
    const currentMonth = nzDate.getMonth() + 1
    
    const loadData = async () => {
      loading.value = true
      try {
        // 1. 从 users 表读取 Penelope
        const { data: users, error: usersError } = await supabase
          .from('users')
          .select('*')
          .ilike('name', '%Penelope%')
        
        if (usersError) throw usersError
        usersData.value = users
        
        // 2. 从 public_users 视图读取 Penelope
        const { data: publicUsers, error: publicError } = await supabase
          .from('public_users')
          .select('*')
          .ilike('name', '%Penelope%')
        
        if (publicError) throw publicError
        publicUsersData.value = publicUsers
        
        // 3. 读取 Penelope 的积分历史
        const penelopeId = users[0]?.id
        if (penelopeId) {
          const { data: history, error: historyError } = await supabase
            .from('ranking_point_history')
            .select('*')
            .eq('user_id', penelopeId)
          
          if (historyError) throw historyError
          historyData.value = history
        }
        
        // 4. 读取所有有积分的玩家
        const { data: allPlayersData, error: allError } = await supabase
          .from('public_users')
          .select('*')
          .gt('ranking_points', 0)
          .order('ranking_points', { ascending: false })
        
        if (allError) throw allError
        allPlayers.value = allPlayersData
        
        // 5. 模拟排行榜页面的数据加载
        const { data: leaderboardUsers, error: leaderError } = await supabase
          .from('public_users')
          .select('*')
        
        if (leaderError) throw leaderError
        
        const { data: pointHistory, error: pointError } = await supabase
          .from('ranking_point_history')
          .select('*')
        
        if (pointError) throw pointError
        
        const playersWithPoints = leaderboardUsers.map(user => {
          const yearPoints = pointHistory
            .filter(p => p.user_id === user.id && p.year === currentYear)
            .reduce((sum, p) => sum + (p.points_change || 0), 0)
          
          return {
            name: user.name,
            ranking_points: user.ranking_points,
            current_year_points: yearPoints,
            wins: user.wins,
            losses: user.losses
          }
        }).filter(p => p.ranking_points > 0)
        .sort((a, b) => b.ranking_points - a.ranking_points)
        
        leaderboardData.value = playersWithPoints
        
      } catch (err) {
        console.error('Error:', err)
        alert('错误: ' + err.message)
      } finally {
        loading.value = false
      }
    }
    
    // 自动加载
    loadData()
    
    return {
      loading,
      usersData,
      publicUsersData,
      historyData,
      allPlayers,
      leaderboardData,
      currentYear,
      currentMonth,
      loadData
    }
  }
}
</script>

<style scoped>
.debug-page {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

h1 {
  color: #667eea;
  margin-bottom: 1rem;
}

h2 {
  color: #333;
  margin-top: 2rem;
  margin-bottom: 1rem;
  border-bottom: 2px solid #667eea;
  padding-bottom: 0.5rem;
}

h3 {
  color: #555;
  margin-top: 1.5rem;
  margin-bottom: 0.5rem;
}

pre {
  background: #f5f5f5;
  padding: 1rem;
  border-radius: 8px;
  overflow-x: auto;
  font-size: 14px;
  border: 1px solid #ddd;
}

.btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  margin-bottom: 1rem;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.loading {
  text-align: center;
  padding: 2rem;
  font-size: 18px;
  color: #667eea;
}

.table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.table th,
.table td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.table th {
  background: #667eea;
  color: white;
  font-weight: 600;
}

.table tr:hover {
  background: #f5f5f5;
}
</style>


