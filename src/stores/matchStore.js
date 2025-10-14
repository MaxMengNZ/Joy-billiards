import { defineStore } from 'pinia'
import { supabase } from '../config/supabase'

export const useMatchStore = defineStore('match', {
  state: () => ({
    matches: [],
    loading: false,
    error: null
  }),

  getters: {
    scheduledMatches: (state) => {
      return state.matches.filter(m => m.status === 'scheduled')
    },

    inProgressMatches: (state) => {
      return state.matches.filter(m => m.status === 'in_progress')
    },

    completedMatches: (state) => {
      return state.matches.filter(m => m.status === 'completed')
    },

    matchesByTournament: (state) => (tournamentId) => {
      return state.matches.filter(m => m.tournament_id === tournamentId)
    }
  },

  actions: {
    async fetchMatches() {
      this.loading = true
      this.error = null
      try {
        const { data, error } = await supabase
          .from('matches')
          .select(`
            *,
            tournaments(name),
            user1:users!player1_id(name),
            user2:users!player2_id(name),
            winner_user:users!winner_id(name)
          `)
          .order('round_number', { ascending: true })
          .order('match_number', { ascending: true })
        
        if (error) throw error
        this.matches = data || []
      } catch (err) {
        this.error = err.message
        console.error('Error fetching matches:', err)
      } finally {
        this.loading = false
      }
    },

    async fetchMatchesByTournament(tournamentId) {
      this.loading = true
      this.error = null
      try {
        const { data, error } = await supabase
          .from('matches')
          .select(`
            *,
            player1:player1_id(name),
            player2:player2_id(name),
            winner:winner_id(name)
          `)
          .eq('tournament_id', tournamentId)
          .order('round_number', { ascending: true })
          .order('match_number', { ascending: true })
        
        if (error) throw error
        return data || []
      } catch (err) {
        this.error = err.message
        console.error('Error fetching tournament matches:', err)
        return []
      } finally {
        this.loading = false
      }
    },

    async createMatch(matchData) {
      this.loading = true
      this.error = null
      try {
        const { data, error } = await supabase
          .from('matches')
          .insert([matchData])
          .select()
        
        if (error) throw error
        if (data && data[0]) {
          this.matches.push(data[0])
        }
        return { success: true, data: data[0] }
      } catch (err) {
        this.error = err.message
        console.error('Error creating match:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async updateMatch(id, updates) {
      this.loading = true
      this.error = null
      try {
        const { data, error } = await supabase
          .from('matches')
          .update(updates)
          .eq('id', id)
          .select()
        
        if (error) throw error
        
        const index = this.matches.findIndex(m => m.id === id)
        if (index !== -1 && data && data[0]) {
          this.matches[index] = data[0]
        }

        // Update player win/loss records if match is completed
        if (updates.status === 'completed' && updates.winner_id) {
          await this.updatePlayerRecords(updates.player1_id, updates.player2_id, updates.winner_id)
        }

        return { success: true }
      } catch (err) {
        this.error = err.message
        console.error('Error updating match:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async updatePlayerRecords(player1Id, player2Id, winnerId) {
      try {
        // Increment wins for winner
        const { error: winError } = await supabase.rpc('increment_wins', {
          player_id: winnerId
        })
        if (winError) throw winError

        // Increment losses for loser
        const loserId = winnerId === player1Id ? player2Id : player1Id
        const { error: lossError } = await supabase.rpc('increment_losses', {
          player_id: loserId
        })
        if (lossError) throw lossError
      } catch (err) {
        console.error('Error updating player records:', err)
      }
    },

    async deleteMatch(id) {
      this.loading = true
      this.error = null
      try {
        const { error } = await supabase
          .from('matches')
          .delete()
          .eq('id', id)
        
        if (error) throw error
        
        this.matches = this.matches.filter(m => m.id !== id)
        return { success: true }
      } catch (err) {
        this.error = err.message
        console.error('Error deleting match:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    }
  }
})


