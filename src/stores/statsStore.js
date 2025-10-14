import { defineStore } from 'pinia'
import { supabase } from '../config/supabase'

export const useStatsStore = defineStore('stats', {
  state: () => ({
    stats: {
      total_players: { value: 0, isManual: false, notes: '' },
      total_tournaments: { value: 0, isManual: false, notes: '' },
      total_matches: { value: 0, isManual: false, notes: '' },
      total_break_and_run: { value: 0, isManual: true, notes: '' }
    },
    loading: false,
    error: null
  }),

  getters: {
    totalPlayers: (state) => state.stats.total_players.value,
    totalTournaments: (state) => state.stats.total_tournaments.value,
    totalMatches: (state) => state.stats.total_matches.value,
    totalBreakAndRun: (state) => state.stats.total_break_and_run.value,
    
    isPlayersManual: (state) => state.stats.total_players.isManual,
    isTournamentsManual: (state) => state.stats.total_tournaments.isManual,
    isMatchesManual: (state) => state.stats.total_matches.isManual,
    isBreakAndRunManual: (state) => state.stats.total_break_and_run.isManual
  },

  actions: {
    async fetchStats() {
      this.loading = true
      this.error = null
      try {
        // Get actual counts from database
        const [playersResult, tournamentsResult, usersDataResult] = await Promise.all([
          supabase.from('users').select('id', { count: 'exact', head: true }),
          supabase.from('tournaments').select('id', { count: 'exact', head: true }),
          supabase.from('users').select('wins, losses, break_and_run_count')
        ])

        // Calculate total Break and Run count from all players
        const totalBreakAndRun = usersDataResult.data?.reduce((sum, user) => {
          return sum + (user.break_and_run_count || 0)
        }, 0) || 0

        // Calculate total Matches Played (all players' wins + losses)
        const totalMatchesPlayed = usersDataResult.data?.reduce((sum, user) => {
          return sum + (user.wins || 0) + (user.losses || 0)
        }, 0) || 0

        // Update stats with actual counts (no manual overrides)
        this.stats.total_players = {
          value: playersResult.count || 0,
          isManual: false,
          notes: 'Auto-calculated from users table'
        }
        
        this.stats.total_tournaments = {
          value: tournamentsResult.count || 0,
          isManual: false,
          notes: 'Auto-calculated from tournaments table'
        }
        
        this.stats.total_matches = {
          value: totalMatchesPlayed,
          isManual: false,
          notes: 'Auto-calculated from all players wins + losses'
        }
        
        this.stats.total_break_and_run = {
          value: totalBreakAndRun,
          isManual: false,
          notes: 'Auto-calculated from users.break_and_run_count'
        }

      } catch (err) {
        this.error = err.message
        console.error('Error fetching stats:', err)
      } finally {
        this.loading = false
      }
    },

    // Note: Manual stat overrides are no longer supported
    // All stats are now auto-calculated from the database

    // Auto-refresh functionality
    startAutoRefresh(intervalMs = 30000) {
      // Refresh every 30 seconds by default
      if (this.refreshInterval) {
        clearInterval(this.refreshInterval)
      }
      
      this.refreshInterval = setInterval(() => {
        this.fetchStats()
      }, intervalMs)
    },

    stopAutoRefresh() {
      if (this.refreshInterval) {
        clearInterval(this.refreshInterval)
        this.refreshInterval = null
      }
    }
  }
})

