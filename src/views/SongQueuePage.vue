<template>
  <div class="song-queue-page">
    <section class="song-hero">
      <div class="song-hero-inner">
        <p class="eyebrow">Member Jukebox</p>
        <h1>Song Queue</h1>
        <p class="subtitle">
          Watch the live venue queue. Members can search and add Spotify tracks. Pro Max gets priority jumps (5 per NZ day).
        </p>
        <div class="hero-chips" v-if="authStore.isAuthenticated">
          <span class="chip" v-if="authStore.isMember">
            {{ membershipLabel }}
          </span>
          <span class="chip chip-priority" v-if="authStore.isProMax">
            Priority left today: {{ songStore.priorityQuota.remaining }}/{{ songStore.priorityQuota.limit }}
          </span>
          <span class="chip chip-warn" v-else-if="authStore.isMember">
            Upgrade to Pro Max for priority queue
          </span>
        </div>
      </div>
    </section>

    <div class="song-content">
      <!-- Live queue: visible to everyone (guests + members) -->
      <div class="panel">
        <div class="panel-header-row">
          <h2 class="panel-title">Live queue</h2>
          <button class="btn btn-ghost btn-sm" type="button" @click="refreshQueue" :disabled="songStore.loading">
            Refresh
          </button>
        </div>

        <p v-if="actionMessage" class="inline-toast" :class="actionMessageType" role="status">
          {{ actionMessage }}
        </p>

        <div v-if="mySpotSummary.length" class="my-spots" aria-live="polite">
          <div v-for="spot in mySpotSummary" :key="spot.id" class="my-spot">
            <strong>Your song</strong>
            <span class="my-spot-track">{{ spot.track_name }}</span>
            <span class="my-spot-pos">{{ spot.positionLabel }}</span>
          </div>
        </div>

        <div v-if="songStore.loading && !songStore.queue.length" class="empty-inline">Loading queue…</div>

        <div v-if="songStore.nowPlaying" class="now-playing" :class="{ mine: songStore.nowPlaying.is_mine }">
          <span class="badge playing">Now playing</span>
          <span v-if="songStore.nowPlaying.is_mine" class="badge yours">Your song</span>
          <div class="queue-row">
            <img
              v-if="songStore.nowPlaying.album_art_url"
              :src="songStore.nowPlaying.album_art_url"
              alt=""
              class="album-art"
            />
            <div class="result-meta">
              <div class="track-name">{{ songStore.nowPlaying.track_name }}</div>
              <div class="artist-name">{{ songStore.nowPlaying.artist_name }}</div>
              <div class="requester">Requested by {{ requesterName(songStore.nowPlaying) }}</div>
            </div>
            <div class="result-actions" v-if="authStore.isAdmin">
              <button
                class="btn btn-secondary btn-sm"
                :disabled="songStore.actionBusyId === songStore.nowPlaying.id"
                @click="setStatus(songStore.nowPlaying.id, 'played')"
              >
                Mark played
              </button>
              <button
                class="btn btn-ghost btn-sm"
                :disabled="songStore.actionBusyId === songStore.nowPlaying.id"
                @click="skipCurrentSpotify(songStore.nowPlaying.id)"
              >
                {{ songStore.actionBusyId === songStore.nowPlaying.id ? 'Skipping…' : 'Skip current on Spotify' }}
              </button>
            </div>
          </div>
        </div>

        <div v-if="!songStore.pendingQueue.length && !songStore.nowPlaying" class="empty-inline">
          Queue is empty. Be the first to add a song.
        </div>

        <p v-else-if="songStore.pendingQueue.length" class="queue-count-hint">
          {{ songStore.pendingCount }} waiting
          <span v-if="songStore.nowPlaying"> · 1 now playing</span>
        </p>

        <ol class="queue-list" v-if="songStore.pendingQueue.length">
          <li
            v-for="item in songStore.pendingQueue"
            :key="item.id"
            class="queue-item"
            :class="{ mine: item.is_mine }"
          >
            <span class="pos" :title="'Queue position #' + (item.queue_position || '')">
              #{{ item.queue_position || '—' }}
            </span>
            <img v-if="item.album_art_url" :src="item.album_art_url" alt="" class="album-art" />
            <div class="result-meta">
              <div class="track-name">
                {{ item.track_name }}
                <span v-if="item.is_priority" class="badge priority">Priority</span>
                <span v-if="item.is_mine" class="badge yours">Yours</span>
              </div>
              <div class="artist-name">{{ item.artist_name }}</div>
              <div class="requester">
                Requested by {{ requesterName(item) }}
                <span v-if="item.is_mine" class="pos-inline"> · {{ positionHint(item) }}</span>
              </div>
            </div>
            <div class="result-actions">
              <button
                v-if="item.is_mine && authStore.isMember"
                class="btn btn-ghost btn-sm"
                :disabled="songStore.actionBusyId === item.id"
                @click="cancelMine(item.id)"
              >
                {{ songStore.actionBusyId === item.id ? 'Working…' : 'Cancel' }}
              </button>
              <template v-if="authStore.isAdmin">
                <button
                  class="btn btn-primary btn-sm"
                  :disabled="!!songStore.actionBusyId"
                  @click="setStatus(item.id, 'playing')"
                >
                  {{ songStore.actionBusyId === item.id ? '…' : 'Play' }}
                </button>
                <button
                  class="btn btn-secondary btn-sm"
                  :disabled="!!songStore.actionBusyId"
                  @click="pushSpotify(item)"
                >
                  {{ songStore.actionBusyId === item.id ? 'Sending…' : 'Queue on Spotify' }}
                </button>
                <button
                  class="btn btn-ghost btn-sm"
                  :disabled="!!songStore.actionBusyId"
                  @click="setStatus(item.id, 'cancelled')"
                >
                  Cancel
                </button>
              </template>
            </div>
          </li>
        </ol>
      </div>

      <!-- Guest / non-member CTA -->
      <div v-if="!authStore.isAuthenticated" class="gate-card">
        <h2>Want to add a song?</h2>
        <p>Sign in with an active membership to request tracks.</p>
        <router-link to="/login" class="btn btn-primary">Sign in</router-link>
      </div>

      <div v-else-if="!authStore.isMember" class="gate-card">
        <h2>Membership required to request</h2>
        <p>You can watch the live queue above. Only active members can add songs.</p>
        <router-link to="/membership" class="btn btn-primary">View Membership</router-link>
      </div>

      <template v-else>
        <!-- Search (members only) -->
        <div class="panel">
          <h2 class="panel-title">Search songs</h2>
          <div class="search-row">
            <div class="search-input-wrap">
              <input
                v-model="searchQuery"
                type="search"
                class="search-input"
                placeholder="Start typing a song name, e.g. rolling…"
                aria-label="Search songs"
                autocomplete="off"
                @input="onSearchInput"
                @keydown.enter.prevent="runSearch"
              />
              <span v-if="songStore.searching" class="search-spinner" aria-hidden="true">…</span>
            </div>
            <button type="button" class="btn btn-primary" :disabled="songStore.searching || !searchQuery.trim()" @click="runSearch">
              {{ songStore.searching ? 'Searching…' : 'Search' }}
            </button>
          </div>
          <p class="hint">Suggestions appear as you type (after 2+ characters).</p>
          <p v-if="songStore.searchMessage" class="hint" :class="{ 'mock-hint': songStore.searchMock || songStore.searchMessage }">
            {{ songStore.searchMessage }}
          </p>

          <div v-if="songStore.searchResults.length" class="results-list">
            <div v-for="track in songStore.searchResults" :key="track.spotify_track_id" class="result-card">
              <img
                v-if="track.album_art_url"
                :src="track.album_art_url"
                :alt="track.album_name || track.track_name"
                class="album-art"
              />
              <div class="result-meta">
                <div class="track-name" v-html="highlightMatch(track.track_name)"></div>
                <div class="artist-name">{{ track.artist_name }}</div>
                <div class="album-name" v-if="track.album_name">{{ track.album_name }}</div>
              </div>
              <div class="result-actions">
                <button
                  class="btn btn-secondary btn-sm"
                  :disabled="songStore.submitting"
                  @click="addTrack(track, false)"
                >
                  Add to queue
                </button>
                <button
                  v-if="authStore.isProMax"
                  class="btn btn-priority btn-sm"
                  :disabled="songStore.submitting || songStore.priorityQuota.remaining <= 0"
                  :title="songStore.priorityQuota.remaining <= 0 ? 'Daily priority limit reached' : 'Jump ahead of normal requests'"
                  @click="addTrack(track, true)"
                >
                  Priority queue
                </button>
              </div>
            </div>
          </div>
          <p v-else-if="searched && !songStore.searching && searchQuery.trim().length >= 2" class="empty-inline">
            No tracks found. Try another spelling.
          </p>
        </div>

        <!-- Admin strip -->
        <div v-if="authStore.isAdmin" class="panel admin-panel">
          <h2 class="panel-title">Staff controls</h2>
          <p class="hint">
            “Queue on Spotify” adds the track to the venue Premium queue. Spotify does not provide an
            API to remove one specific queued track, so this cannot be undone from the website. Remove
            it manually in the Spotify app if needed. “Skip current on Spotify” only advances the track
            that is currently playing.
          </p>
          <button
            v-if="songStore.nextUp"
            class="btn btn-primary"
            type="button"
            :disabled="!!songStore.actionBusyId"
            @click="playNext"
          >
            Play next: {{ songStore.nextUp.track_name }}
          </button>
        </div>
      </template>

      <p v-if="songStore.error" class="toast error" role="alert">{{ songStore.error }}</p>
    </div>
  </div>
</template>

<script>
import { ref, computed, watch, onUnmounted } from 'vue'
import { useAuthStore } from '../stores/authStore'
import { useSongQueueStore } from '../stores/songQueueStore'
import { formatMembershipLevel } from '../utils/membershipDisplay'

export default {
  name: 'SongQueuePage',
  setup() {
    const authStore = useAuthStore()
    const songStore = useSongQueueStore()
    const searchQuery = ref('')
    const searched = ref(false)
    const actionMessage = ref('')
    const actionMessageType = ref('ok')
    let searchTimer = null
    let searchSeq = 0
    let flashTimer = null
    let queueBooted = false

    const membershipLabel = computed(() =>
      formatMembershipLevel(authStore.membershipLevel || 'lite')
    )

    const flash = (msg, type = 'ok') => {
      actionMessage.value = msg
      actionMessageType.value = type
      if (flashTimer) clearTimeout(flashTimer)
      flashTimer = setTimeout(() => {
        if (actionMessage.value === msg) actionMessage.value = ''
      }, 6000)
    }

    const requesterName = (item) => {
      if (item?.is_mine) return 'You'
      return item?.requester_label || item?.user?.name || 'Member'
    }

    const positionHint = (item) => {
      const pos = Number(item?.queue_position)
      if (!Number.isFinite(pos) || pos < 1) return ''
      if (pos === 1) return 'You’re next'
      return `#${pos} in line · ${pos - 1} ahead`
    }

    const mySpotSummary = computed(() =>
      songStore.myPending.map((item) => {
        const pos = Number(item.queue_position)
        let positionLabel = 'In queue'
        if (pos === 1) positionLabel = 'You’re next up'
        else if (pos > 1) {
          positionLabel = `#${pos} in queue · ${pos - 1} song${pos - 1 === 1 ? '' : 's'} ahead`
        }
        return {
          id: item.id,
          track_name: item.track_name,
          positionLabel
        }
      })
    )

    const escapeHtml = (value) =>
      String(value || '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')

    const highlightMatch = (title) => {
      const safe = escapeHtml(title)
      const q = searchQuery.value.trim()
      if (q.length < 2) return safe
      try {
        const re = new RegExp(`(${q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'ig')
        return safe.replace(re, '<mark>$1</mark>')
      } catch {
        return safe
      }
    }

    const refreshQueue = async () => {
      await songStore.fetchQueue()
      if (authStore.isMember) await songStore.fetchPriorityQuota()
    }

    const refreshAll = refreshQueue

    const runSearch = async () => {
      const q = searchQuery.value.trim()
      if (q.length < 2) {
        songStore.searchResults = []
        searched.value = false
        return
      }
      const seq = ++searchSeq
      searched.value = true
      await songStore.searchTracks(q)
      if (seq !== searchSeq) return
    }

    const onSearchInput = () => {
      if (searchTimer) clearTimeout(searchTimer)
      const q = searchQuery.value.trim()
      if (q.length < 2) {
        songStore.searchResults = []
        songStore.searchMessage = null
        searched.value = false
        return
      }
      searchTimer = setTimeout(() => {
        runSearch()
      }, 320)
    }

    const addTrack = async (track, isPriority) => {
      try {
        const data = await songStore.submitRequest(track, { isPriority })
        const pos = data?.queue_position_estimate
        flash(
          isPriority
            ? `Added with priority${pos ? ` — you are #${pos} in line` : ''}.`
            : `Added to queue${pos ? ` — you are #${pos} in line` : ''}.`
        )
      } catch (err) {
        flash(err.message || 'Failed to add song', 'error')
      }
    }

    const setStatus = async (id, status) => {
      try {
        flash(
          status === 'playing'
            ? 'Marking as now playing…'
            : status === 'cancelled'
              ? 'Cancelling…'
              : `Updating to ${status}…`,
          'ok'
        )
        await songStore.adminUpdateStatus(id, status)
        flash(
          status === 'playing'
            ? 'Now playing updated.'
            : status === 'cancelled'
              ? 'Cancelled.'
              : `Updated to ${status}.`
        )
      } catch (err) {
        flash(err.message || 'Update failed', 'error')
      }
    }

    const cancelMine = async (id) => {
      try {
        flash('Cancelling…')
        await songStore.cancelMyRequest(id)
        flash('Request cancelled.')
      } catch (err) {
        flash(err.message || 'Cancel failed', 'error')
      }
    }

    const pushSpotify = async (item) => {
      const confirmed = window.confirm(
        'Queue this track on Spotify?\n\nSpotify does not let websites remove one specific queued track. If you change your mind after sending, remove it manually in the Spotify app.'
      )
      if (!confirmed) return

      try {
        const data = await songStore.pushToSpotify(item)
        if (data?.skipped) {
          flash(
            data.message ||
              'Spotify venue token not configured (SPOTIFY_REFRESH_TOKEN). Website Live queue still works.',
            'warn'
          )
        } else if (data?.success) {
          const device = data.device_name ? ` on “${data.device_name}”` : ''
          flash(
            `Added to venue Spotify Queue${device}. Spotify does not support undoing this from the website.`,
            'ok'
          )
        } else {
          flash(data?.message || data?.error || 'Spotify push did not confirm success.', 'warn')
        }
      } catch (err) {
        flash(err.message || 'Spotify push failed', 'error')
      }
    }

    const skipCurrentSpotify = async (id) => {
      try {
        const data = await songStore.skipCurrentOnSpotify(id)
        flash(data?.message || 'Skipped the track currently playing on Spotify.')
      } catch (err) {
        flash(err.message || 'Spotify skip failed', 'error')
      }
    }

    const playNext = async () => {
      if (!songStore.nextUp) return
      await setStatus(songStore.nextUp.id, 'playing')
    }

    // Live queue is public — boot for everyone; refresh is_mine after login
    let pollTimer = null
    const startGuestPoll = () => {
      if (pollTimer) return
      pollTimer = setInterval(() => {
        songStore.fetchQueue({ silent: true })
      }, 8000)
    }
    const stopGuestPoll = () => {
      if (pollTimer) {
        clearInterval(pollTimer)
        pollTimer = null
      }
    }

    watch(
      () => [authStore.isAuthenticated, authStore.profile?.id],
      async () => {
        await songStore.fetchQueue({ silent: queueBooted })
        if (authStore.isMember) await songStore.fetchPriorityQuota()
        if (!queueBooted) {
          queueBooted = true
          songStore.subscribeRealtime()
        }
        // Guests may miss Realtime auth; light poll keeps queue fresh
        if (!authStore.isAuthenticated) startGuestPoll()
        else stopGuestPoll()
      },
      { immediate: true }
    )

    onUnmounted(() => {
      if (searchTimer) clearTimeout(searchTimer)
      if (flashTimer) clearTimeout(flashTimer)
      stopGuestPoll()
      songStore.unsubscribeRealtime()
    })

    return {
      authStore,
      songStore,
      searchQuery,
      searched,
      actionMessage,
      actionMessageType,
      membershipLabel,
      requesterName,
      positionHint,
      mySpotSummary,
      highlightMatch,
      refreshQueue,
      refreshAll,
      runSearch,
      onSearchInput,
      addTrack,
      cancelMine,
      setStatus,
      pushSpotify,
      skipCurrentSpotify,
      playNext
    }
  }
}
</script>

<style scoped>
.song-queue-page {
  min-height: 100vh;
  background: linear-gradient(180deg, #0b1220 0%, #121a2b 40%, #0d1422 100%);
  color: #e8eef8;
}

.song-hero {
  padding: 2.5rem 1.25rem 1.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  background:
    radial-gradient(ellipse at top right, rgba(29, 185, 84, 0.18), transparent 50%),
    radial-gradient(ellipse at bottom left, rgba(59, 130, 246, 0.12), transparent 45%);
}

.song-hero-inner {
  max-width: 960px;
  margin: 0 auto;
}

.eyebrow {
  text-transform: uppercase;
  letter-spacing: 0.12em;
  font-size: 0.75rem;
  color: #1db954;
  margin: 0 0 0.5rem;
  font-weight: 600;
}

.song-hero h1 {
  margin: 0 0 0.5rem;
  font-size: clamp(1.75rem, 4vw, 2.5rem);
  font-weight: 700;
}

.subtitle {
  margin: 0;
  color: #9fb0c9;
  max-width: 40rem;
  line-height: 1.5;
}

.hero-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-top: 1rem;
}

.chip {
  display: inline-flex;
  align-items: center;
  padding: 0.35rem 0.75rem;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.1);
  font-size: 0.85rem;
}

.chip-priority {
  background: rgba(250, 204, 21, 0.15);
  border-color: rgba(250, 204, 21, 0.35);
  color: #fde68a;
}

.chip-warn {
  color: #cbd5e1;
}

.song-content {
  max-width: 960px;
  margin: 0 auto;
  padding: 1.5rem 1.25rem 4rem;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.panel,
.gate-card {
  background: rgba(18, 26, 43, 0.9);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 16px;
  padding: 1.25rem;
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.25);
}

.gate-card {
  text-align: center;
}

.panel-title {
  margin: 0 0 1rem;
  font-size: 1.15rem;
}

.panel-header-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 0.5rem;
}

.panel-header-row .panel-title {
  margin: 0;
}

.search-row {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.search-input-wrap {
  flex: 1;
  min-width: 200px;
  position: relative;
}

.search-input {
  width: 100%;
  padding: 0.75rem 1rem;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(0, 0, 0, 0.35);
  color: #fff;
  font-size: 1rem;
  box-sizing: border-box;
}

.search-spinner {
  position: absolute;
  right: 0.75rem;
  top: 50%;
  transform: translateY(-50%);
  color: #1db954;
}

.track-name :deep(mark) {
  background: rgba(29, 185, 84, 0.35);
  color: #fff;
  border-radius: 3px;
  padding: 0 2px;
}

.search-input:focus {
  outline: 2px solid rgba(29, 185, 84, 0.5);
  outline-offset: 1px;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.35rem;
  padding: 0.65rem 1rem;
  border-radius: 10px;
  border: none;
  cursor: pointer;
  font-weight: 600;
  text-decoration: none;
  color: #fff;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-sm {
  padding: 0.45rem 0.75rem;
  font-size: 0.85rem;
}

.btn-primary {
  background: linear-gradient(135deg, #1db954, #169c46);
}

.btn-secondary {
  background: rgba(59, 130, 246, 0.85);
}

.btn-priority {
  background: linear-gradient(135deg, #f59e0b, #d97706);
  color: #111;
}

.btn-ghost {
  background: transparent;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #cbd5e1;
}

.hint {
  color: #9fb0c9;
  font-size: 0.9rem;
  margin: 0.75rem 0 0;
}

.mock-hint {
  color: #fbbf24;
}

.results-list,
.queue-list {
  list-style: none;
  margin: 1rem 0 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.result-card,
.queue-row,
.queue-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.06);
  flex-wrap: wrap;
}

.album-art {
  width: 56px;
  height: 56px;
  border-radius: 8px;
  object-fit: cover;
  flex-shrink: 0;
  background: #222;
}

.result-meta {
  flex: 1;
  min-width: 140px;
}

.track-name {
  font-weight: 600;
}

.artist-name,
.album-name,
.requester {
  color: #9fb0c9;
  font-size: 0.85rem;
}

.result-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.badge {
  display: inline-block;
  margin-left: 0.4rem;
  padding: 0.15rem 0.45rem;
  border-radius: 999px;
  font-size: 0.7rem;
  font-weight: 700;
  vertical-align: middle;
}

.badge.priority {
  background: rgba(245, 158, 11, 0.25);
  color: #fcd34d;
}

.badge.yours {
  background: rgba(96, 165, 250, 0.25);
  color: #bfdbfe;
  margin-left: 0.35rem;
}

.badge.playing {
  background: rgba(29, 185, 84, 0.25);
  color: #86efac;
  margin: 0 0.35rem 0.5rem 0;
}

.my-spots {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin: 0.75rem 0 1rem;
}

.my-spot {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 0.4rem 0.75rem;
  padding: 0.65rem 0.85rem;
  border-radius: 10px;
  border: 1px solid rgba(96, 165, 250, 0.35);
  background: rgba(59, 130, 246, 0.12);
  font-size: 0.9rem;
}

.my-spot-track {
  font-weight: 600;
}

.my-spot-pos {
  color: #93c5fd;
}

.queue-count-hint {
  color: #94a3b8;
  font-size: 0.85rem;
  margin: 0.5rem 0 0;
}

.pos-inline {
  color: #93c5fd;
}

.queue-item.mine,
.now-playing.mine {
  border-color: rgba(96, 165, 250, 0.4);
  background: rgba(59, 130, 246, 0.08);
}

.pos {
  width: 2.25rem;
  text-align: center;
  font-weight: 700;
  color: #94a3b8;
  font-variant-numeric: tabular-nums;
}

.now-playing {
  margin-bottom: 1rem;
  padding: 0.75rem;
  border-radius: 12px;
  border: 1px solid rgba(29, 185, 84, 0.35);
  background: rgba(29, 185, 84, 0.08);
}

.empty-inline {
  color: #94a3b8;
  margin: 0.75rem 0 0;
}

.admin-panel {
  border-color: rgba(250, 204, 21, 0.25);
}

.inline-toast {
  margin: 0.5rem 0 0.75rem;
  padding: 0.65rem 0.85rem;
  border-radius: 10px;
  background: rgba(15, 23, 42, 0.95);
  border: 1px solid rgba(255, 255, 255, 0.12);
  font-size: 0.9rem;
  line-height: 1.4;
}

.inline-toast.ok {
  border-color: rgba(29, 185, 84, 0.45);
  color: #bbf7d0;
}

.inline-toast.warn {
  border-color: rgba(251, 191, 36, 0.5);
  color: #fde68a;
}

.inline-toast.error {
  border-color: rgba(239, 68, 68, 0.5);
  color: #fca5a5;
}

.toast {
  position: sticky;
  bottom: 5rem;
  z-index: 20;
  padding: 0.75rem 1rem;
  border-radius: 10px;
  background: rgba(15, 23, 42, 0.95);
  border: 1px solid rgba(255, 255, 255, 0.12);
}

.toast.error {
  border-color: rgba(239, 68, 68, 0.5);
  color: #fca5a5;
}

@media (max-width: 640px) {
  .result-actions {
    width: 100%;
  }

  .result-actions .btn {
    flex: 1;
  }
}
</style>
