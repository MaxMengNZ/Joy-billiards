import { defineStore } from 'pinia'
import { supabase } from '../config/supabase'

export const useTournamentStore = defineStore('tournament', {
  state: () => ({
    tournaments: [],
    currentTournament: null,
    participants: [],
    loading: false,
    error: null
  }),

  getters: {
    upcomingTournaments: (state) => {
      return state.tournaments.filter(t => 
        t.status === 'upcoming' || t.status === 'registration'
      )
    },

    activeTournaments: (state) => {
      return state.tournaments.filter(t => t.status === 'in_progress')
    },

    completedTournaments: (state) => {
      return state.tournaments.filter(t => t.status === 'completed')
    }
  },

  actions: {
    async fetchTournaments() {
      this.loading = true
      this.error = null
      try {
        const { data, error } = await supabase
          .from('tournaments')
          .select('*')
          .order('start_date', { ascending: false })
        
        if (error) throw error
        this.tournaments = data || []
      } catch (err) {
        this.error = err.message
        console.error('Error fetching tournaments:', err)
      } finally {
        this.loading = false
      }
    },

    async fetchTournamentById(id) {
      this.loading = true
      this.error = null
      try {
        const { data, error } = await supabase
          .from('tournaments')
          .select('*')
          .eq('id', id)
          .single()
        
        if (error) throw error
        this.currentTournament = data
        return data
      } catch (err) {
        this.error = err.message
        console.error('Error fetching tournament:', err)
        return null
      } finally {
        this.loading = false
      }
    },

    async createTournament(tournamentData) {
      this.loading = true
      this.error = null
      
      console.log('[TournamentStore] Creating tournament with data:', tournamentData)
      
      try {
        // Add timeout wrapper (30 seconds)
        const insertPromise = supabase
          .from('tournaments')
          .insert([tournamentData])
          .select()
        
        const timeoutPromise = new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Tournament creation timeout after 30 seconds')), 30000)
        )
        
        console.log('[TournamentStore] Sending insert request to Supabase...')
        const { data, error } = await Promise.race([insertPromise, timeoutPromise])
        
        console.log('[TournamentStore] Supabase response received:', { data, error })
        
        if (error) {
          console.error('[TournamentStore] Supabase error:', error)
          throw error
        }
        
        if (!data || !data[0]) {
          console.error('[TournamentStore] No data returned from insert')
          throw new Error('No data returned from database')
        }
        
        console.log('[TournamentStore] Tournament created successfully:', data[0])
        
        // Add to local state
        this.tournaments.unshift(data[0])
        
        return { success: true, data: data[0] }
      } catch (err) {
        console.error('[TournamentStore] Error creating tournament:', err)
        this.error = err.message || 'Failed to create tournament'
        return { success: false, error: this.error }
      } finally {
        this.loading = false
        console.log('[TournamentStore] createTournament completed, loading set to false')
      }
    },

    async updateTournament(id, updates) {
      this.loading = true
      this.error = null
      try {
        const { data, error } = await supabase
          .from('tournaments')
          .update(updates)
          .eq('id', id)
          .select()
        
        if (error) throw error
        
        const index = this.tournaments.findIndex(t => t.id === id)
        if (index !== -1 && data && data[0]) {
          this.tournaments[index] = data[0]
        }
        return { success: true }
      } catch (err) {
        this.error = err.message
        console.error('Error updating tournament:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async deleteTournament(id) {
      this.loading = true
      this.error = null
      try {
        const { error } = await supabase
          .from('tournaments')
          .delete()
          .eq('id', id)
        
        if (error) throw error
        
        this.tournaments = this.tournaments.filter(t => t.id !== id)
        return { success: true }
      } catch (err) {
        this.error = err.message
        console.error('Error deleting tournament:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async fetchParticipants(tournamentId) {
      // Participants are now determined by who has matches in the tournament
      this.loading = true
      this.error = null
      try {
        const { data, error } = await supabase
          .from('matches')
          .select(`
            player1_id,
            player2_id,
            player1:users!matches_player1_id_fkey(id, name, email, skill_level, wins, losses),
            player2:users!matches_player2_id_fkey(id, name, email, skill_level, wins, losses)
          `)
          .eq('tournament_id', tournamentId)
        
        if (error) throw error
        
        // Extract unique participants
        const participantsMap = new Map()
        data?.forEach(match => {
          if (match.player1) {
            participantsMap.set(match.player1.id, {
              id: match.player1.id,
              player_id: match.player1.id,
              player: match.player1
            })
          }
          if (match.player2) {
            participantsMap.set(match.player2.id, {
              id: match.player2.id,
              player_id: match.player2.id,
              player: match.player2
            })
          }
        })
        
        this.participants = Array.from(participantsMap.values())
        return this.participants
      } catch (err) {
        this.error = err.message
        console.error('Error fetching participants:', err)
        return []
      } finally {
        this.loading = false
      }
    },

    // Note: Participants are now managed through matches
    // To add a participant, create a match with that player
    async addParticipant(tournamentId, playerId) {
      return { 
        success: false, 
        error: 'Please create a match to add participants' 
      }
    },

    async removeParticipant(tournamentId, playerId) {
      return { 
        success: false, 
        error: 'Please delete matches to remove participants' 
      }
    }
  }
})


