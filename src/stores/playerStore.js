import { defineStore } from 'pinia'
import { supabase } from '../config/supabase'

export const usePlayerStore = defineStore('player', {
  state: () => ({
    players: [],
    loading: false,
    error: null
  }),

  getters: {
    sortedPlayers: (state) => {
      return [...state.players].sort((a, b) => b.wins - a.wins)
    },
    
    getPlayerById: (state) => (id) => {
      return state.players.find(player => player.id === id)
    },

    playersBySkillLevel: (state) => (level) => {
      return state.players.filter(player => player.skill_level === level)
    }
  },

  actions: {
    async fetchPlayers(useAdminRPC = false) {
      this.loading = true
      this.error = null
      try {
        let data, error
        
        if (useAdminRPC) {
          // Security: Use admin RPC for admin pages (includes email, phone, etc.)
          // This function has built-in admin permission check at database level
          // Frontend should also verify admin access before calling this
          const result = await supabase.rpc('admin_get_all_users')
          data = result.data
          error = result.error
        } else {
          // Use public_users view for public player information (no sensitive data)
          // This view does NOT include email, phone, or other sensitive fields
          const result = await supabase
            .from('public_users')
            .select('*')
            .order('wins', { ascending: false })
          data = result.data
          error = result.error
        }
        
        if (error) throw error
        this.players = data || []
      } catch (err) {
        this.error = err.message
        // Security: Don't log sensitive error details
        console.error('Error fetching players')
      } finally {
        this.loading = false
      }
    },

    async createPlayer(playerData) {
      this.loading = true
      this.error = null
      try {
        const { data, error } = await supabase
          .from('users')
          .insert([playerData])
          .select()
        
        if (error) throw error
        if (data && data[0]) {
          this.players.push(data[0])
        }
        return { success: true, data: data[0] }
      } catch (err) {
        this.error = err.message
        console.error('Error creating player:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async updatePlayer(id, updates) {
      this.loading = true
      this.error = null
      try {
        const { data, error} = await supabase
          .from('users')
          .update(updates)
          .eq('id', id)
          .select()
        
        if (error) throw error
        
        const index = this.players.findIndex(p => p.id === id)
        if (index !== -1 && data && data[0]) {
          this.players[index] = data[0]
        }
        return { success: true }
      } catch (err) {
        this.error = err.message
        console.error('Error updating player:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async deletePlayer(id) {
      this.loading = true
      this.error = null
      try {
        const { error } = await supabase
          .from('users')
          .delete()
          .eq('id', id)
        
        if (error) throw error
        
        this.players = this.players.filter(p => p.id !== id)
        return { success: true }
      } catch (err) {
        this.error = err.message
        console.error('Error deleting player:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    }
  }
})


