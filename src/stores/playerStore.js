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
    async fetchPlayers() {
      this.loading = true
      this.error = null
      try {
        const { data, error } = await supabase
          .from('users')
          .select('*')
          .order('wins', { ascending: false })
        
        if (error) throw error
        this.players = data || []
      } catch (err) {
        this.error = err.message
        console.error('Error fetching players:', err)
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


