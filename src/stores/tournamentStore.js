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
      console.log('[TournamentStore] Data keys:', Object.keys(tournamentData))
      console.log('[TournamentStore] Data values:', Object.values(tournamentData))
      
      try {
        // Try using fetch API directly to bypass any Supabase client issues
        console.log('[TournamentStore] Attempting insert via direct REST API call...')
        console.log('[TournamentStore] Insert payload:', JSON.stringify(tournamentData, null, 2))
        const insertStartTime = Date.now()
        
        // Get Supabase URL and key from environment
        const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
        const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY
        
        if (!supabaseUrl || !supabaseKey) {
          throw new Error('Missing Supabase environment variables')
        }
        
        // Get current session token with timeout
        console.log('[TournamentStore] Getting session...')
        let authToken = null
        try {
          const sessionPromise = supabase.auth.getSession()
          const sessionTimeout = new Promise((_, reject) => 
            setTimeout(() => reject(new Error('Session timeout')), 3000)
          )
          
          const { data: { session }, error: sessionError } = await Promise.race([
            sessionPromise,
            sessionTimeout
          ])
          
          if (sessionError) {
            console.error('[TournamentStore] Session error:', sessionError)
          } else if (session) {
            authToken = session.access_token
            console.log('[TournamentStore] Session obtained, token length:', authToken?.length || 0)
          } else {
            console.log('[TournamentStore] No session found, using anon key')
          }
        } catch (sessionErr) {
          console.warn('[TournamentStore] Session fetch failed or timed out, using anon key:', sessionErr.message)
          // Continue without auth token - RLS policy should allow
        }
        
        console.log('[TournamentStore] Supabase URL:', supabaseUrl)
        console.log('[TournamentStore] Has auth token:', !!authToken)
        console.log('[TournamentStore] Payload size:', JSON.stringify(tournamentData).length, 'bytes')
        
        // Use fetch API directly with timeout
        const controller = new AbortController()
        const timeoutId = setTimeout(() => {
          console.error('[TournamentStore] ⚠️ Request timeout triggered!')
          controller.abort()
        }, 15000) // 15 second timeout
        
        const fetchUrl = `${supabaseUrl}/rest/v1/tournaments`
        console.log('[TournamentStore] Fetch URL:', fetchUrl)
        console.log('[TournamentStore] Starting fetch request...')
        
        let response
        try {
          const fetchStartTime = Date.now()
          console.log('[TournamentStore] Fetch call initiated at:', new Date().toISOString())
          
          // Try fetch with shorter timeout first (10 seconds)
          const quickController = new AbortController()
          const quickTimeout = setTimeout(() => {
            console.warn('[TournamentStore] ⚠️ Quick timeout (10s), trying Supabase client...')
            quickController.abort()
          }, 10000)
          
          try {
            response = await fetch(fetchUrl, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'apikey': supabaseKey,
                'Authorization': authToken ? `Bearer ${authToken}` : `Bearer ${supabaseKey}`,
                'Prefer': 'return=representation'
              },
              body: JSON.stringify(tournamentData),
              signal: quickController.signal
            })
            clearTimeout(quickTimeout)
            clearTimeout(timeoutId)
            
            const fetchDuration = Date.now() - fetchStartTime
            console.log(`[TournamentStore] ✅ Fetch completed after ${fetchDuration}ms`)
          } catch (quickErr) {
            clearTimeout(quickTimeout)
            if (quickErr.name === 'AbortError') {
              console.log('[TournamentStore] Fetch timeout, falling back to Supabase client...')
              // Fallback to Supabase client
              const { data, error } = await supabase
                .from('tournaments')
                .insert([tournamentData])
                .select()
              
              if (error) throw error
              if (!data || !data[0]) throw new Error('No data returned')
              
              console.log('[TournamentStore] ✅ Tournament created via Supabase client fallback')
              this.tournaments.unshift(data[0])
              return { success: true, data: data[0] }
            }
            throw quickErr
          }
        } catch (fetchErr) {
          clearTimeout(timeoutId)
          console.error('[TournamentStore] ❌ Fetch error:', fetchErr)
          console.error('[TournamentStore] Fetch error name:', fetchErr.name)
          console.error('[TournamentStore] Fetch error message:', fetchErr.message)
          
          // Final fallback: try Supabase client
          if (fetchErr.name === 'AbortError' || fetchErr.message?.includes('timeout')) {
            console.log('[TournamentStore] Attempting final fallback to Supabase client...')
            try {
              const { data, error } = await supabase
                .from('tournaments')
                .insert([tournamentData])
                .select()
              
              if (error) throw error
              if (!data || !data[0]) throw new Error('No data returned')
              
              console.log('[TournamentStore] ✅ Tournament created via Supabase client (final fallback)')
              this.tournaments.unshift(data[0])
              return { success: true, data: data[0] }
            } catch (fallbackErr) {
              console.error('[TournamentStore] Fallback also failed:', fallbackErr)
              throw new Error('Request timeout after 15 seconds')
            }
          }
          throw fetchErr
        }
        
        const insertDuration = Date.now() - insertStartTime
        console.log(`[TournamentStore] REST API call completed after ${insertDuration}ms`)
        console.log('[TournamentStore] Response status:', response.status)
        console.log('[TournamentStore] Response ok:', response.ok)
        
        if (!response.ok) {
          const errorText = await response.text()
          console.error('[TournamentStore] REST API error response:', errorText)
          let errorData
          try {
            errorData = JSON.parse(errorText)
          } catch {
            errorData = { message: errorText }
          }
          throw new Error(errorData.message || `HTTP ${response.status}: ${response.statusText}`)
        }
        
        const data = await response.json()
        console.log('[TournamentStore] Response data:', data)
        
        // REST API returns array
        const insertedData = Array.isArray(data) ? data[0] : data
        
        if (!insertedData) {
          console.error('[TournamentStore] No data returned from insert')
          throw new Error('No data returned from database')
        }
        
        console.log('[TournamentStore] Tournament created successfully:', insertedData)
        
        // Add to local state
        this.tournaments.unshift(insertedData)
        
        return { success: true, data: insertedData }
      } catch (err) {
        console.error('[TournamentStore] Error creating tournament:', err)
        console.error('[TournamentStore] Error stack:', err.stack)
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


