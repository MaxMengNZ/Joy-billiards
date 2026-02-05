import { defineStore } from 'pinia'
import { supabase } from '../config/supabase'

// Timeout so loading never sticks forever on slow/hung requests
const REQUEST_TIMEOUT_MS = 15000
const withTimeout = (promise, ms = REQUEST_TIMEOUT_MS) => {
  let timeoutId
  const timeoutPromise = new Promise((_, reject) => {
    timeoutId = setTimeout(() => reject(new Error('Request timeout')), ms)
  })
  return Promise.race([promise, timeoutPromise]).finally(() => clearTimeout(timeoutId))
}

export const useBattleStore = defineStore('battle', {
  state: () => ({
    rooms: [],
    currentRoom: null,
    roomScores: [],
    loading: false,
    error: null,
    currentUser: null,
    roomsSubscription: null, // Realtime subscription for rooms
    roomSubscription: null // Realtime subscription for current room
  }),

  getters: {
    activeRooms: (state) => state.rooms.filter(r => 
      ['waiting', 'ready', 'in_progress'].includes(r.status)
    ),
    
    waitingRooms: (state) => state.rooms.filter(r => r.status === 'waiting'),
    
    inProgressRooms: (state) => state.rooms.filter(r => r.status === 'in_progress'),
    
    completedRooms: (state) => state.rooms.filter(r => r.status === 'completed'),
    
    myRooms: (state) => {
      if (!state.currentUser) return []
      return state.rooms.filter(r => 
        r.created_by === state.currentUser.id ||
        r.player1_id === state.currentUser.id ||
        r.player2_id === state.currentUser.id
      )
    }
  },

  actions: {
    // Initialize current user
    async initCurrentUser() {
      try {
        const { data: { user } } = await withTimeout(supabase.auth.getUser(), 10000)
        if (user) {
          const { data } = await withTimeout(
            supabase
              .from('users')
              .select('id, name, email, role')
              .eq('auth_id', user.id)
              .single(),
            10000
          )
          if (data) {
            this.currentUser = data
          }
        }
      } catch (err) {
        console.error('Error initializing current user:', err)
      }
    },

    // Search users by name or ID (secure RPC function)
    // Only returns: id, name, elo_rating (unified Battle Elo)
    // NO email or sensitive data
    async searchUsers(query) {
      try {
        if (!query || query.trim().length < 2) {
          return { success: true, data: [] }
        }

        // Use secure RPC function - only returns id, name, battle_elo_rating
        // NO email, phone, or other sensitive data
        const { data, error } = await supabase
          .rpc('search_battle_opponents', {
            search_query: query.trim()
          })

        if (error) {
          console.error('Search error:', error)
          // Fallback to direct query if RPC fails (for backward compatibility)
          // But still only select safe fields
          const { data: fallbackData, error: fallbackError } = await supabase
            .from('users')
            .select('id, name, battle_elo_rating')
            .or(`name.ilike.%${query}%,id.eq.${query}`)
            .eq('is_active', true)
            .limit(20)

          if (fallbackError) {
            throw fallbackError
          }

          const result = (fallbackData || []).map(user => ({
            id: user.id,
            name: user.name,
            elo_rating: user.battle_elo_rating || 1000
          }))

          return { success: true, data: result }
        }

        // RPC function already returns properly formatted data (no email)
        return { success: true, data: data || [] }
      } catch (err) {
        console.error('Error searching users:', err)
        return { success: false, error: err.message, data: [] }
      }
    },

    // Create a new battle room (admin can create with any players)
    async createRoomAsAdmin({ roomName, player1Id, player2Id, raceToScore, breakOption, roomNotes, tableNumber }) {
      this.loading = true
      this.error = null

      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Not authenticated')

        // Get user ID and role from users table
        const { data: userData } = await supabase
          .from('users')
          .select('id, role')
          .eq('auth_id', user.id)
          .single()

        if (!userData) throw new Error('User not found')
        if (userData.role !== 'admin') {
          throw new Error('Only admins can use this function')
        }

        if (!player1Id || !player2Id) {
          throw new Error('Both players must be selected')
        }

        if (player1Id === player2Id) {
          throw new Error('Players must be different')
        }

        const { data, error } = await supabase
          .from('battle_rooms')
          .insert({
            room_name: roomName,
            created_by: userData.id,
            player1_id: player1Id,
            player2_id: player2Id,
            race_to_score: raceToScore,
            break_option: breakOption || 'alternating',
            room_notes: roomNotes || null,
            table_number: tableNumber || null,
            status: 'waiting',
            player1_ready: false,
            player2_ready: false
          })
          .select(`
            *,
            player1:users!battle_rooms_player1_id_fkey(id, name, email, avatar_url),
            player2:users!battle_rooms_player2_id_fkey(id, name, email, avatar_url),
            created_by_user:users!battle_rooms_created_by_fkey(id, name)
          `)
          .single()

        if (error) throw error

        await this.loadRooms()
        return { success: true, data }
      } catch (err) {
        this.error = err.message
        console.error('Error creating room as admin:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    // Create a new battle room
    async createRoom({ roomName, player2Id, raceToScore, scheduledStartTime, breakOption, roomNotes, tableNumber }) {
      this.loading = true
      this.error = null

      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Not authenticated')

        // Get user ID from users table
        const { data: userData } = await supabase
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .single()

        if (!userData) throw new Error('User not found')

        const { data, error } = await supabase
          .from('battle_rooms')
          .insert({
            room_name: roomName,
            created_by: userData.id,
            player1_id: userData.id,
            player2_id: player2Id,
            race_to_score: raceToScore,
            scheduled_start_time: scheduledStartTime || null,
            break_option: breakOption || 'alternating',
            room_notes: roomNotes || null,
            table_number: tableNumber || null,
            status: player2Id ? 'waiting' : 'waiting',
            match_type: 'matchmaking' // Will be set by trigger
          })
          .select(`
            *,
            player1:users!battle_rooms_player1_id_fkey(id, name, email, avatar_url),
            player2:users!battle_rooms_player2_id_fkey(id, name, email, avatar_url),
            created_by_user:users!battle_rooms_created_by_fkey(id, name)
          `)
          .single()

        if (error) throw error

        await this.loadRooms()
        return { success: true, data }
      } catch (err) {
        this.error = err.message
        console.error('Error creating room:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    // Join a room (player2 joins)
    async joinRoom(roomId) {
      this.loading = true
      this.error = null

      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Not authenticated')

        const { data: userData } = await supabase
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .single()

        if (!userData) throw new Error('User not found')

        // First check if room exists and player2 is null
        const { data: roomCheck, error: checkError } = await supabase
          .from('battle_rooms')
          .select('id, player1_id, player2_id, status')
          .eq('id', roomId)
          .single()

        if (checkError) throw checkError
        if (!roomCheck) throw new Error('Room not found')
        if (roomCheck.player2_id) throw new Error('Room already has a player2')
        if (roomCheck.player1_id === userData.id) throw new Error('You are already player1 in this room')
        if (roomCheck.status !== 'waiting') throw new Error('Room is not available to join')

        // Update room with player2
        const { error: updateError } = await supabase
          .from('battle_rooms')
          .update({
            player2_id: userData.id,
            status: 'waiting' // Will change to 'ready' when both confirm
          })
          .eq('id', roomId)
          .is('player2_id', null)

        if (updateError) throw updateError

        // Reload rooms to get updated data
        await this.loadRooms()
        
        // Find the updated room
        const updatedRoom = this.rooms.find(r => r.id === roomId)
        return { success: true, data: updatedRoom }
      } catch (err) {
        this.error = err.message
        console.error('Error joining room:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    // Confirm ready to start (player1 or player2, or admin can confirm for both)
    async confirmReady(roomId) {
      this.loading = true
      this.error = null

      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Not authenticated')

        const { data: userData } = await supabase
          .from('users')
          .select('id, role')
          .eq('auth_id', user.id)
          .single()

        if (!userData) throw new Error('User not found')

        // Get current room state
        const { data: room } = await supabase
          .from('battle_rooms')
          .select('*')
          .eq('id', roomId)
          .single()

        if (!room) throw new Error('Room not found')

        const isAdmin = userData.role === 'admin'
        
        // Admin can confirm both players, regular users can only confirm themselves
        let updateData
        if (isAdmin) {
          // Admin confirms both players
          updateData = { 
            player1_ready: true,
            player2_ready: true
          }
        } else {
          // Determine which player is confirming
          const isPlayer1 = room.player1_id === userData.id
          const isPlayer2 = room.player2_id === userData.id

          if (!isPlayer1 && !isPlayer2) {
            throw new Error('You are not in this room')
          }

          updateData = isPlayer1 
            ? { player1_ready: true }
            : { player2_ready: true }
        }

        const { data, error } = await supabase
          .from('battle_rooms')
          .update(updateData)
          .eq('id', roomId)
          .select(`
            *,
            player1:users!battle_rooms_player1_id_fkey(id, name, email, avatar_url),
            player2:users!battle_rooms_player2_id_fkey(id, name, email, avatar_url),
            created_by_user:users!battle_rooms_created_by_fkey(id, name)
          `)
          .single()

        if (error) throw error

        // If both players are ready, change status to 'ready'
        if (data.player1_ready && data.player2_ready && data.status === 'waiting') {
          const { data: updatedRoom, error: updateError } = await supabase
            .from('battle_rooms')
            .update({
              status: 'ready'
            })
            .eq('id', roomId)
            .select(`
              *,
              player1:users!battle_rooms_player1_id_fkey(id, name, email),
              player2:users!battle_rooms_player2_id_fkey(id, name, email),
              created_by_user:users!battle_rooms_created_by_fkey(id, name)
            `)
            .single()

          if (updateError) throw updateError
          await this.loadRooms()
          return { success: true, data: updatedRoom }
        }

        await this.loadRooms()
        return { success: true, data }
      } catch (err) {
        this.error = err.message
        console.error('Error confirming ready:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    // Start match (change status to in_progress)
    async startMatch(roomId) {
      this.loading = true
      this.error = null

      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Not authenticated')

        const { data: userData } = await supabase
          .from('users')
          .select('id, role')
          .eq('auth_id', user.id)
          .single()

        if (!userData) throw new Error('User not found')

        // Get room
        const { data: room } = await supabase
          .from('battle_rooms')
          .select('*')
          .eq('id', roomId)
          .single()

        if (!room) throw new Error('Room not found')

        // Check permission: must be player1, player2, or admin
        const isPlayer = room.player1_id === userData.id || room.player2_id === userData.id
        const isAdmin = userData.role === 'admin'

        if (!isPlayer && !isAdmin) {
          throw new Error('Permission denied')
        }

        // Admin can start match even if not ready, regular users need ready status
        if (!isAdmin && room.status !== 'ready') {
          throw new Error('Room is not ready to start')
        }
        
        // If admin is starting, ensure both players are marked as ready
        if (isAdmin && (!room.player1_ready || !room.player2_ready)) {
          // Update both players as ready first
          await supabase
            .from('battle_rooms')
            .update({
              player1_ready: true,
              player2_ready: true
            })
            .eq('id', roomId)
        }

        const { data, error } = await supabase
          .from('battle_rooms')
          .update({
            status: 'in_progress',
            started_at: new Date().toISOString()
          })
          .eq('id', roomId)
          .select(`
            *,
            player1:users!battle_rooms_player1_id_fkey(id, name, email, avatar_url),
            player2:users!battle_rooms_player2_id_fkey(id, name, email, avatar_url),
            created_by_user:users!battle_rooms_created_by_fkey(id, name)
          `)
          .single()

        if (error) throw error

        await this.loadRooms()
        if (this.currentRoom?.id === roomId) {
          await this.loadRoomScores(roomId)
        }
        return { success: true, data }
      } catch (err) {
        this.error = err.message
        console.error('Error starting match:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    // Record score (only players in room or admin)
    async recordScore(roomId, { player1Score, player2Score, frameNumber, notes }) {
      this.loading = true
      this.error = null

      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Not authenticated')

        const { data: userData } = await supabase
          .from('users')
          .select('id, role')
          .eq('auth_id', user.id)
          .single()

        if (!userData) throw new Error('User not found')

        // Check permission using RPC function
        const { data: hasPermission, error: permError } = await supabase
          .rpc('check_score_recording_permission', {
            p_room_id: roomId,
            p_user_id: userData.id
          })

        if (permError) throw permError
        if (!hasPermission) {
          throw new Error('Permission denied: Only players in room or admin can record scores')
        }

        // Get current room
        const { data: room } = await supabase
          .from('battle_rooms')
          .select('*')
          .eq('id', roomId)
          .single()

        if (!room) throw new Error('Room not found')
        if (room.status !== 'in_progress') {
          throw new Error('Match is not in progress')
        }

        // Insert score record
        const { data, error } = await supabase
          .from('battle_match_scores')
          .insert({
            room_id: roomId,
            recorded_by: userData.id,
            player1_current_score: player1Score,
            player2_current_score: player2Score,
            frame_number: frameNumber || 1,
            notes: notes || null
          })
          .select()
          .single()

        if (error) throw error

        // Update room scores
        const { error: updateError } = await supabase
          .from('battle_rooms')
          .update({
            player1_score: player1Score,
            player2_score: player2Score,
            updated_at: new Date().toISOString()
          })
          .eq('id', roomId)

        if (updateError) throw updateError

        await this.loadRoomScores(roomId)
        return { success: true, data }
      } catch (err) {
        this.error = err.message
        console.error('Error recording score:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    // Complete match (set winner and finalize, update stats)
    async completeMatch(roomId, { 
      winnerId, 
      finalPlayer1Score, 
      finalPlayer2Score,
      player1BreakAndRun = 0,
      player1RackRun = 0,
      player2BreakAndRun = 0,
      player2RackRun = 0
    }) {
      this.loading = true
      this.error = null

      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Not authenticated')

        const { data: userData } = await supabase
          .from('users')
          .select('id, role')
          .eq('auth_id', user.id)
          .single()

        if (!userData) throw new Error('User not found')

        // Get room
        const { data: room } = await supabase
          .from('battle_rooms')
          .select('*')
          .eq('id', roomId)
          .single()

        if (!room) throw new Error('Room not found')

        // Check permission
        const isPlayer = room.player1_id === userData.id || room.player2_id === userData.id
        const isAdmin = userData.role === 'admin'

        if (!isPlayer && !isAdmin) {
          throw new Error('Permission denied')
        }

        if (room.status !== 'in_progress') {
          throw new Error('Match is not in progress')
        }

        // Update room status
        const { data, error } = await supabase
          .from('battle_rooms')
          .update({
            status: 'completed',
            winner_id: winnerId,
            player1_score: finalPlayer1Score,
            player2_score: finalPlayer2Score,
            completed_at: new Date().toISOString()
          })
          .eq('id', roomId)
          .select(`
            *,
            player1:users!battle_rooms_player1_id_fkey(id, name, email, avatar_url),
            player2:users!battle_rooms_player2_id_fkey(id, name, email, avatar_url),
            created_by_user:users!battle_rooms_created_by_fkey(id, name)
          `)
          .single()

        if (error) throw error

        // Update player statistics (Break & Run and Rack Run)
        if (player1BreakAndRun > 0 || player1RackRun > 0) {
          const { error: statsError1 } = await supabase.rpc('update_player_battle_stats', {
            p_user_id: room.player1_id,
            p_break_and_run: player1BreakAndRun || 0,
            p_rack_run: player1RackRun || 0
          })
          if (statsError1) {
            console.error('Error updating player1 stats:', statsError1)
            // Don't throw, just log - match completion should still succeed
          }
        }

        if (player2BreakAndRun > 0 || player2RackRun > 0) {
          const { error: statsError2 } = await supabase.rpc('update_player_battle_stats', {
            p_user_id: room.player2_id,
            p_break_and_run: player2BreakAndRun || 0,
            p_rack_run: player2RackRun || 0
          })
          if (statsError2) {
            console.error('Error updating player2 stats:', statsError2)
            // Don't throw, just log - match completion should still succeed
          }
        }

        // Update battle positions
        await supabase.rpc('update_battle_positions')

        await this.loadRooms()
        return { success: true, data }
      } catch (err) {
        this.error = err.message
        console.error('Error completing match:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    // Load all rooms
    async loadRooms() {
      this.loading = true
      this.error = null

      try {
        // Get today's date range (start and end of day in UTC)
        const now = new Date()
        const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        const todayEnd = new Date(todayStart)
        todayEnd.setDate(todayEnd.getDate() + 1)
        const todayStartISO = todayStart.toISOString()
        const todayEndISO = todayEnd.toISOString()

        // Load rooms: all active rooms (waiting, ready, in_progress) + today's completed rooms
        // Use separate queries and combine them; wrap in timeout so loading never sticks
        const [activeRoomsResult, completedRoomsResult] = await withTimeout(
          Promise.all([
            // Active rooms
            supabase
              .from('battle_rooms')
              .select(`
                *,
                player1:users!battle_rooms_player1_id_fkey(id, name, email, avatar_url),
                player2:users!battle_rooms_player2_id_fkey(id, name, email, avatar_url),
                created_by_user:users!battle_rooms_created_by_fkey(id, name)
              `)
              .in('status', ['waiting', 'ready', 'in_progress'])
              .order('created_at', { ascending: false }),
            
            // Today's completed rooms - check both completed_at and created_at
            supabase
              .from('battle_rooms')
              .select(`
                *,
                player1:users!battle_rooms_player1_id_fkey(id, name, email, avatar_url),
                player2:users!battle_rooms_player2_id_fkey(id, name, email, avatar_url),
                created_by_user:users!battle_rooms_created_by_fkey(id, name)
              `)
              .eq('status', 'completed')
              .gte('created_at', todayStartISO)
              .lt('created_at', todayEndISO)
              .order('completed_at', { ascending: false, nullsFirst: false })
          ])
        )

        if (activeRoomsResult.error) throw activeRoomsResult.error
        if (completedRoomsResult.error) throw completedRoomsResult.error

        // Combine results and sort by created_at (most recent first)
        this.rooms = [
          ...(activeRoomsResult.data || []),
          ...(completedRoomsResult.data || [])
        ].sort((a, b) => {
          // Sort by completed_at if available, otherwise created_at
          const dateA = new Date(a.completed_at || a.created_at)
          const dateB = new Date(b.completed_at || b.created_at)
          return dateB - dateA
        })
      } catch (err) {
        this.error = err?.message === 'Request timeout'
          ? 'Load timed out. Please refresh the page.'
          : (err?.message || 'Failed to load rooms.')
        console.error('Error loading rooms:', err)
      } finally {
        this.loading = false
      }
    },

    // Load room scores
    async loadRoomScores(roomId) {
      this.loading = true
      this.error = null

      try {
        const { data, error } = await supabase
          .from('battle_match_scores')
          .select(`
            *,
            recorded_by_user:users!battle_match_scores_recorded_by_fkey(id, name)
          `)
          .eq('room_id', roomId)
          .order('recorded_at', { ascending: true })

        if (error) throw error
        this.roomScores = data || []
      } catch (err) {
        this.error = err.message
        console.error('Error loading room scores:', err)
      } finally {
        this.loading = false
      }
    },

    // Set current room
    async setCurrentRoom(roomId) {
      try {
        // Unsubscribe from previous room if exists
        if (this.roomSubscription) {
          await supabase.removeChannel(this.roomSubscription)
          this.roomSubscription = null
        }

        const { data, error } = await supabase
          .from('battle_rooms')
          .select(`
            *,
            player1:users!battle_rooms_player1_id_fkey(id, name, email, avatar_url),
            player2:users!battle_rooms_player2_id_fkey(id, name, email, avatar_url),
            created_by_user:users!battle_rooms_created_by_fkey(id, name)
          `)
          .eq('id', roomId)
          .single()

        if (error) throw error
        this.currentRoom = data

        if (data && data.status === 'in_progress') {
          await this.loadRoomScores(roomId)
        }

        // Subscribe to real-time updates for this room
        this.subscribeToRoom(roomId)
      } catch (err) {
        this.error = err.message
        console.error('Error setting current room:', err)
      }
    },

    // Subscribe to real-time updates for a specific room
    subscribeToRoom(roomId) {
      // Unsubscribe from previous room if exists
      if (this.roomSubscription) {
        supabase.removeChannel(this.roomSubscription)
      }

      const channel = supabase
        .channel(`room:${roomId}`)
        .on(
          'postgres_changes',
          {
            event: 'UPDATE',
            schema: 'public',
            table: 'battle_rooms',
            filter: `id=eq.${roomId}`
          },
          async (payload) => {
            console.log('Room updated:', payload)
            // Reload the room data
            const { data, error } = await supabase
              .from('battle_rooms')
              .select(`
                *,
                player1:users!battle_rooms_player1_id_fkey(id, name, email, avatar_url),
                player2:users!battle_rooms_player2_id_fkey(id, name, email, avatar_url),
                created_by_user:users!battle_rooms_created_by_fkey(id, name)
              `)
              .eq('id', roomId)
              .single()

            if (!error && data) {
              this.currentRoom = data
              // If room is in progress, reload scores
              if (data.status === 'in_progress') {
                await this.loadRoomScores(roomId)
              }
            }
          }
        )
        .subscribe()

      this.roomSubscription = channel
    },

    // Subscribe to real-time updates for all rooms
    subscribeToRooms() {
      // Unsubscribe from previous subscription if exists
      if (this.roomsSubscription) {
        supabase.removeChannel(this.roomsSubscription)
      }

      const channel = supabase
        .channel('battle_rooms')
        .on(
          'postgres_changes',
          {
            event: '*', // Listen to all events (INSERT, UPDATE, DELETE)
            schema: 'public',
            table: 'battle_rooms'
          },
          async (payload) => {
            console.log('Rooms changed:', payload.eventType)
            // Reload rooms when any change occurs
            await this.loadRooms()
          }
        )
        .subscribe()

      this.roomsSubscription = channel
    },

    // Unsubscribe from all real-time updates
    unsubscribe() {
      if (this.roomsSubscription) {
        supabase.removeChannel(this.roomsSubscription)
        this.roomsSubscription = null
      }
      if (this.roomSubscription) {
        supabase.removeChannel(this.roomSubscription)
        this.roomSubscription = null
      }
    },

    // Get player battle statistics (recent 5 matches, win rate, break and run)
    async getPlayerBattleStats(playerId) {
      try {
        const { data, error } = await supabase
          .rpc('get_player_battle_stats', {
            player_id: playerId
          })

        if (error) throw error
        return { success: true, data: data?.[0] || null }
      } catch (err) {
        console.error('Error getting player battle stats:', err)
        return { success: false, error: err.message, data: null }
      }
    },

    // Cancel room (only creator can cancel, and only if match hasn't started)
    async cancelRoom(roomId) {
      this.loading = true
      this.error = null

      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Not authenticated')

        const { data: userData } = await supabase
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .single()

        if (!userData) throw new Error('User not found')

        // Get room to verify creator and status
        const { data: room } = await supabase
          .from('battle_rooms')
          .select('*')
          .eq('id', roomId)
          .single()

        if (!room) throw new Error('Room not found')

        // Check if user is creator or admin
        const { data: currentUserData } = await supabase
          .from('users')
          .select('role')
          .eq('id', userData.id)
          .single()

        const isCreator = room.created_by === userData.id
        const isAdmin = currentUserData?.role === 'admin'

        // Only creator or admin can cancel
        if (!isCreator && !isAdmin) {
          throw new Error('Only room creator or admin can cancel the room')
        }

        // Cannot cancel if already completed or cancelled
        if (room.status === 'completed' || room.status === 'cancelled') {
          throw new Error('Cannot cancel room: match is already completed or cancelled')
        }

        const { data, error } = await supabase
          .from('battle_rooms')
          .update({
            status: 'cancelled',
            updated_at: new Date().toISOString()
          })
          .eq('id', roomId)
          .select(`
            *,
            player1:users!battle_rooms_player1_id_fkey(id, name, email, avatar_url),
            player2:users!battle_rooms_player2_id_fkey(id, name, email, avatar_url),
            created_by_user:users!battle_rooms_created_by_fkey(id, name)
          `)
          .single()

        if (error) throw error

        await this.loadRooms()
        return { success: true, data }
      } catch (err) {
        this.error = err.message
        console.error('Error cancelling room:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    // Update room (only creator can update, and only if match hasn't started)
    async updateRoom(roomId, { roomName, raceToScore, scheduledStartTime, breakOption, roomNotes }) {
      this.loading = true
      this.error = null

      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Not authenticated')

        const { data: userData } = await supabase
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .single()

        if (!userData) throw new Error('User not found')

        // Get room to verify creator and status
        const { data: room } = await supabase
          .from('battle_rooms')
          .select('*')
          .eq('id', roomId)
          .single()

        if (!room) throw new Error('Room not found')

        // Only creator can update
        if (room.created_by !== userData.id) {
          throw new Error('Only room creator can update the room')
        }

        // Can only update if match hasn't started
        if (room.status === 'in_progress' || room.status === 'completed') {
          throw new Error('Cannot update room: match has already started or completed')
        }

        const updateData = {
          updated_at: new Date().toISOString()
        }

        if (roomName !== undefined) updateData.room_name = roomName
        if (raceToScore !== undefined) updateData.race_to_score = raceToScore
        if (scheduledStartTime !== undefined) {
          updateData.scheduled_start_time = scheduledStartTime || null
        }
        if (breakOption !== undefined) updateData.break_option = breakOption
        if (roomNotes !== undefined) updateData.room_notes = roomNotes || null

        const { data, error } = await supabase
          .from('battle_rooms')
          .update(updateData)
          .eq('id', roomId)
          .select(`
            *,
            player1:users!battle_rooms_player1_id_fkey(id, name, email, avatar_url),
            player2:users!battle_rooms_player2_id_fkey(id, name, email, avatar_url),
            created_by_user:users!battle_rooms_created_by_fkey(id, name)
          `)
          .single()

        if (error) throw error

        await this.loadRooms()
        return { success: true, data }
      } catch (err) {
        this.error = err.message
        console.error('Error updating room:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    // Remove player from room (room creator or admin only)
    async removePlayer(roomId, playerToRemove) {
      this.loading = true
      this.error = null

      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Not authenticated')

        const { data: userData } = await supabase
          .from('users')
          .select('id, role')
          .eq('auth_id', user.id)
          .single()

        if (!userData) throw new Error('User not found')

        // Check if user is room creator or admin
        const { data: room, error: roomError } = await supabase
          .from('battle_rooms')
          .select('id, created_by, player1_id, player2_id, status')
          .eq('id', roomId)
          .single()

        if (roomError) throw roomError
        if (!room) throw new Error('Room not found')

        const isCreator = room.created_by === userData.id
        const isAdmin = userData.role === 'admin'

        if (!isCreator && !isAdmin) {
          throw new Error('Only room creator or admin can remove players')
        }

        // Can only remove players if room is waiting or ready (not in progress or completed)
        if (room.status === 'in_progress' || room.status === 'completed') {
          throw new Error('Cannot remove players from a match in progress or completed')
        }

        // Determine which player to remove
        let updateData = {}
        if (playerToRemove === 'player1') {
          if (!room.player1_id) throw new Error('Player1 is not in the room')
          // If removing player1, we need to handle this carefully
          // For now, we'll just clear player1_id and reset ready status
          updateData = {
            player1_id: null,
            player1_ready: false
          }
        } else if (playerToRemove === 'player2') {
          if (!room.player2_id) throw new Error('Player2 is not in the room')
          updateData = {
            player2_id: null,
            player2_ready: false,
            status: 'waiting' // Reset to waiting if player2 is removed
          }
        } else {
          throw new Error('Invalid player to remove')
        }

        // Update room
        const { error: updateError } = await supabase
          .from('battle_rooms')
          .update(updateData)
          .eq('id', roomId)

        if (updateError) throw updateError

        // Reload rooms
        await this.loadRooms()
        return { success: true }
      } catch (err) {
        this.error = err.message
        console.error('Error removing player:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    }
  }
})
