import { defineStore } from 'pinia'
import { supabase } from '../config/supabase'
import { useAuthStore } from './authStore'

function sortQueue(rows) {
  return [...(rows || [])].sort((a, b) => {
    if (a.status === 'playing' && b.status !== 'playing') return -1
    if (b.status === 'playing' && a.status !== 'playing') return 1
    if (a.is_priority !== b.is_priority) return a.is_priority ? -1 : 1
    return new Date(a.created_at) - new Date(b.created_at)
  })
}

function isMockTrackId(id) {
  return !id || String(id).startsWith('mock_track_')
}

function requireAdmin() {
  const auth = useAuthStore()
  if (!auth.isAdmin) {
    throw new Error('Admin access required for playback controls.')
  }
}

export const useSongQueueStore = defineStore('songQueue', {
  state: () => ({
    queue: [],
    searchResults: [],
    searchMock: false,
    searchMessage: null,
    priorityQuota: { used: 0, limit: 5, remaining: 5, is_pro_max: false },
    loading: false,
    searching: false,
    submitting: false,
    actionBusyId: null,
    error: null,
    channel: null,
    _autoCompleteTimer: null,
    _playbackPollTimer: null,
    playback: {
      synced: false,
      is_playing: false,
      track_id: null,
      track_name: null,
      artist_name: null,
      progress_ms: null,
      duration_ms: null
    }
  }),

  getters: {
    nowPlaying: (state) => state.queue.find((r) => r.status === 'playing') || null,
    pendingQueue: (state) => state.queue.filter((r) => r.status === 'pending'),
    nextUp: (state) => {
      const pending = state.queue.filter((r) => r.status === 'pending')
      return pending[0] || null
    },
    myPending: (state) => state.queue.filter((r) => r.status === 'pending' && r.is_mine),
    pendingCount: (state) => state.queue.filter((r) => r.status === 'pending').length
  },

  actions: {
    clearAutoCompleteTimer() {
      if (this._autoCompleteTimer) {
        clearTimeout(this._autoCompleteTimer)
        this._autoCompleteTimer = null
      }
    },

    async syncPlayback() {
      try {
        const { data, error } = await supabase.functions.invoke('spotify-sync-playback', {
          body: {}
        })
        if (error || !data?.success) {
          // Venue token missing or Spotify unreachable — duration fallback still applies
          this.playback = { ...this.playback, synced: false }
          return
        }
        const s = data.spotify || {}
        this.playback = {
          synced: true,
          is_playing: !!s.is_playing,
          track_id: s.track_id || null,
          track_name: s.track_name || null,
          artist_name: s.artist_name || null,
          progress_ms: s.progress_ms ?? null,
          duration_ms: s.duration_ms ?? null
        }
        // If the sync changed any request statuses, refresh the queue view
        if (Array.isArray(data.changes) && data.changes.length) {
          await this.fetchQueue({ silent: true })
        }
      } catch (err) {
        console.warn('syncPlayback failed:', err?.message || err)
        this.playback = { ...this.playback, synced: false }
      }
    },

    startPlaybackPoll(intervalMs = 10000) {
      if (this._playbackPollTimer) return
      this.syncPlayback()
      this._playbackPollTimer = setInterval(() => {
        this.syncPlayback()
      }, intervalMs)
    },

    stopPlaybackPoll() {
      if (this._playbackPollTimer) {
        clearInterval(this._playbackPollTimer)
        this._playbackPollTimer = null
      }
    },

    scheduleAutoComplete() {
      this.clearAutoCompleteTimer()
      const playing = this.queue.find((r) => r.status === 'playing')
      if (!playing) return

      const startedAt = new Date(playing.played_at || playing.created_at).getTime()
      if (!Number.isFinite(startedAt)) return

      const durationMs = Number(playing.duration_ms)
      const trackMs = Number.isFinite(durationMs) && durationMs > 0 ? durationMs : 240000
      const graceMs = 8000
      const remaining = startedAt + trackMs + graceMs - Date.now()

      if (remaining <= 0) {
        // Already due — refresh immediately so RPC can finalize
        this.fetchQueue({ silent: true })
        return
      }

      this._autoCompleteTimer = setTimeout(() => {
        this.fetchQueue({ silent: true })
      }, Math.min(remaining, 30 * 60 * 1000))
    },

    async fetchQueue({ silent = false } = {}) {
      if (!silent) {
        this.loading = true
      }
      this.error = null
      try {
        // Sanitized public RPC — no emails / membership / raw user ids
        // Also auto-marks finished "playing" tracks as played.
        const { data, error } = await supabase.rpc('get_live_song_queue')
        if (error) throw error
        const rows = Array.isArray(data) ? data : []
        this.queue = sortQueue(
          rows.map((r) => ({
            ...r,
            // Compatibility aliases for older UI helpers
            user: { name: r.requester_label || 'Member' },
            user_id: r.is_mine ? '__mine__' : null
          }))
        )
        this.scheduleAutoComplete()
      } catch (err) {
        console.error('fetchQueue', err)
        this.error = err.message || String(err)
      } finally {
        if (!silent) this.loading = false
      }
    },

    async fetchPriorityQuota() {
      try {
        const { data, error } = await supabase.rpc('get_song_priority_quota')
        if (error) throw error
        if (data) {
          this.priorityQuota = {
            used: data.used ?? 0,
            limit: data.limit ?? 5,
            remaining: data.remaining ?? 0,
            is_pro_max: !!data.is_pro_max
          }
        }
      } catch (err) {
        console.error('fetchPriorityQuota', err)
      }
    },

    async searchTracks(query) {
      const q = (query || '').trim()
      if (!q) {
        this.searchResults = []
        this.searchMock = false
        this.searchMessage = null
        return
      }

      this.searching = true
      this.error = null
      try {
        if (import.meta.env.DEV) {
          const localRes = await fetch(
            `/api/spotify-search?q=${encodeURIComponent(q)}&limit=10`
          )
          const localPayload = await localRes.json().catch(() => null)
          if (localRes.ok && localPayload && Array.isArray(localPayload.tracks) && !localPayload.mock) {
            this.searchResults = localPayload.tracks
            this.searchMock = false
            this.searchMessage = null
            return
          }
          if (localPayload?.missing_secrets?.length) {
            this.searchResults = []
            this.searchMock = true
            this.searchMessage = localPayload.message || 'Spotify secrets missing in .env.local'
            return
          }
          if (localPayload?.error) {
            this.searchResults = []
            this.searchMock = false
            this.searchMessage = localPayload.error
            return
          }
        }

        const { data, error } = await supabase.functions.invoke('spotify-search', {
          body: { q, limit: 10 }
        })

        let payload = data
        if (!payload && error?.context && typeof error.context.json === 'function') {
          try {
            payload = await error.context.json()
          } catch {
            payload = null
          }
        }

        if (payload && (Array.isArray(payload.tracks) || payload.error || payload.message || payload.missing_secrets)) {
          this.searchResults = payload.tracks || []
          this.searchMock = !!payload.mock
          this.searchMessage = payload.message || payload.error || null
          if (Array.isArray(payload.missing_secrets) && payload.missing_secrets.length) {
            this.searchMessage =
              (payload.message || 'Spotify secrets missing.') +
              ` Missing: ${payload.missing_secrets.join(', ')}`
          }
          return
        }

        if (error) throw error
        this.searchResults = []
        this.searchMock = false
        this.searchMessage = null
      } catch (err) {
        console.warn('spotify-search unavailable:', err.message || err)
        this.searchResults = []
        this.searchMock = false
        this.searchMessage =
          `Spotify search failed: ${err.message || err}. ` +
          'Put SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET in .env.local and restart npm run dev.'
      } finally {
        this.searching = false
      }
    },

    async submitRequest(track, { isPriority = false } = {}) {
      const auth = useAuthStore()
      if (!auth.isMember) {
        throw new Error('Active membership required to request songs.')
      }
      if (isPriority && !auth.isProMax) {
        throw new Error('Priority queue is for Pro Max members only.')
      }

      this.submitting = true
      this.error = null
      try {
        const { data, error } = await supabase.rpc('submit_song_request', {
          p_spotify_track_id: track.spotify_track_id,
          p_track_name: track.track_name,
          p_artist_name: track.artist_name,
          p_album_name: track.album_name || null,
          p_album_art_url: track.album_art_url || null,
          p_duration_ms: track.duration_ms || null,
          p_preview_url: track.preview_url || null,
          p_is_priority: !!isPriority && auth.isProMax
        })

        if (error) throw error
        if (data?.priority_left_today != null) {
          this.priorityQuota.remaining = data.priority_left_today
          this.priorityQuota.used = this.priorityQuota.limit - data.priority_left_today
        }
        // Optimistic insert if RPC returned the row
        if (data?.request) {
          const exists = this.queue.some((r) => r.id === data.request.id)
          if (!exists) {
            this.queue = sortQueue([...this.queue, data.request])
          }
        }
        await this.fetchQueue({ silent: true })
        await this.fetchPriorityQuota()
        return data
      } catch (err) {
        const msg = err.message || String(err)
        this.error = msg
        throw new Error(msg)
      } finally {
        this.submitting = false
      }
    },

    async cancelMyRequest(requestId) {
      const prev = this.queue
      this.actionBusyId = requestId
      // Optimistic remove
      this.queue = this.queue.filter((r) => r.id !== requestId)
      try {
        const { error } = await supabase.rpc('cancel_my_song_request', {
          p_request_id: requestId
        })
        if (error) throw error
        await this.fetchQueue({ silent: true })
        await this.fetchPriorityQuota()
      } catch (err) {
        this.queue = prev
        throw err
      } finally {
        this.actionBusyId = null
      }
    },

    async adminUpdateStatus(requestId, status) {
      requireAdmin()
      const prev = this.queue.map((r) => ({ ...r }))
      this.actionBusyId = requestId

      // Optimistic UI so staff see instant feedback
      if (status === 'playing') {
        this.queue = sortQueue(
          this.queue.map((r) => {
            if (r.id === requestId) return { ...r, status: 'playing' }
            if (r.status === 'playing') return { ...r, status: 'played' }
            return r
          }).filter((r) => r.status === 'pending' || r.status === 'playing')
        )
      } else if (['played', 'skipped', 'cancelled'].includes(status)) {
        this.queue = this.queue.filter((r) => r.id !== requestId)
      }

      try {
        const { error } = await supabase.rpc('admin_update_song_request_status', {
          p_request_id: requestId,
          p_status: status
        })
        if (error) throw error
        await this.fetchQueue({ silent: true })
      } catch (err) {
        this.queue = prev
        throw err
      } finally {
        this.actionBusyId = null
      }
    },

    async pushToSpotify(request) {
      requireAdmin()
      if (isMockTrackId(request.spotify_track_id)) {
        throw new Error(
          'This track is a mock/demo ID and cannot be sent to Spotify. Search again and add a real Spotify track.'
        )
      }

      this.actionBusyId = request.id
      try {
        // Prefer local Vite proxy in development (uses .env.local refresh token).
        // If local token is bad, fall through to Edge Function instead of hard-failing.
        if (import.meta.env.DEV) {
          try {
            const localRes = await fetch('/api/spotify-push-queue', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                request_id: request.id,
                spotify_track_id: request.spotify_track_id
              })
            })
            const localPayload = await localRes.json().catch(() => null)
            if (localPayload?.skipped) {
              // Missing local refresh token — try Edge next
            } else if (localPayload?.success) {
              this.actionBusyId = null
              await this.adminUpdateStatus(request.id, 'playing')
              return localPayload
            } else if (localPayload?.error) {
              const msg = String(localPayload.error)
              const canFallback =
                /invalid_grant|refresh failed|Invalid refresh token|missing/i.test(msg)
              if (!canFallback) {
                throw new Error(
                  localPayload.hint ? `${msg} ${localPayload.hint}` : msg
                )
              }
              console.warn('Local Spotify push failed, trying Edge Function:', msg)
            }
          } catch (localErr) {
            const msg = localErr?.message || String(localErr)
            if (!/invalid_grant|refresh failed|Invalid refresh token|Failed to fetch/i.test(msg)) {
              throw localErr
            }
            console.warn('Local Spotify push error, trying Edge Function:', msg)
          }
        }

        const { data, error } = await supabase.functions.invoke('spotify-push-queue', {
          body: {
            request_id: request.id,
            spotify_track_id: request.spotify_track_id
          }
        })

        let payload = data
        if (!payload && error?.context && typeof error.context.json === 'function') {
          try {
            payload = await error.context.json()
          } catch {
            payload = null
          }
        }

        if (error && !payload) throw error
        if (payload?.error && !payload?.skipped) {
          throw new Error(
            payload.hint ? `${payload.error} ${payload.hint}` : payload.error
          )
        }
        if (payload?.success) {
          // Edge may mark playing; refresh silently. Also optimistic.
          this.queue = sortQueue(
            this.queue
              .map((r) => {
                if (r.id === request.id) return { ...r, status: 'playing' }
                if (r.status === 'playing') return { ...r, status: 'played' }
                return r
              })
              .filter((r) => r.status === 'pending' || r.status === 'playing')
          )
          await this.fetchQueue({ silent: true })
          return payload
        }
        return (
          payload || {
            skipped: true,
            message: 'No response from Spotify push function.'
          }
        )
      } finally {
        this.actionBusyId = null
      }
    },

    async playNowOnSpotify(request) {
      requireAdmin()
      if (isMockTrackId(request.spotify_track_id)) {
        throw new Error(
          'This track is a mock/demo ID and cannot be played on Spotify. Add a real Spotify track.'
        )
      }

      this.actionBusyId = request.id
      try {
        const invokeEdge = async () => {
          const { data, error } = await supabase.functions.invoke('spotify-push-queue', {
            body: {
              action: 'play_now',
              request_id: request.id,
              spotify_track_id: request.spotify_track_id
            }
          })
          let payload = data
          if (!payload && error?.context && typeof error.context.json === 'function') {
            try {
              payload = await error.context.json()
            } catch {
              payload = null
            }
          }
          if (error && !payload) throw error
          return payload
        }

        const payload = await invokeEdge()

        if (payload?.skipped) return payload
        if (!payload?.success) {
          const message = payload?.hint
            ? `${payload.error || payload.message} ${payload.hint}`
            : payload?.error || payload?.message || 'Spotify play failed.'
          throw new Error(message)
        }

        // Reflect "now playing" in the website queue
        this.queue = sortQueue(
          this.queue
            .map((r) => {
              if (r.id === request.id) return { ...r, status: 'playing' }
              if (r.status === 'playing') return { ...r, status: 'played' }
              return r
            })
            .filter((r) => r.status === 'pending' || r.status === 'playing')
        )
        await this.fetchQueue({ silent: true })
        return payload
      } finally {
        this.actionBusyId = null
      }
    },

    async skipCurrentOnSpotify(requestId) {
      requireAdmin()
      this.actionBusyId = requestId
      try {
        const { data, error } = await supabase.functions.invoke('spotify-push-queue', {
          body: {
            action: 'skip_current',
            request_id: requestId
          }
        })

        let payload = data
        if (!payload && error?.context && typeof error.context.json === 'function') {
          try {
            payload = await error.context.json()
          } catch {
            payload = null
          }
        }

        if (error && !payload) throw error
        if (!payload?.success) {
          const message = payload?.hint
            ? `${payload.error || payload.message} ${payload.hint}`
            : payload?.error || payload?.message || 'Spotify skip failed.'
          throw new Error(message)
        }

        this.queue = this.queue.filter((r) => r.id !== requestId)
        await this.fetchQueue({ silent: true })
        return payload
      } finally {
        this.actionBusyId = null
      }
    },

    subscribeRealtime() {
      if (this.channel) return
      this.channel = supabase
        .channel('song_requests_live')
        .on(
          'postgres_changes',
          { event: '*', schema: 'public', table: 'song_requests' },
          () => {
            this.fetchQueue({ silent: true })
            // Quota is member-only; ignore failures for guests
            this.fetchPriorityQuota()
          }
        )
        .subscribe()
    },

    unsubscribeRealtime() {
      this.clearAutoCompleteTimer()
      this.stopPlaybackPoll()
      if (this.channel) {
        supabase.removeChannel(this.channel)
        this.channel = null
      }
    }
  }
})
