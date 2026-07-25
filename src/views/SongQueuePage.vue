<template>
  <div class="song-queue-page">
    <section class="song-hero">
      <div class="song-hero-inner">
        <p class="eyebrow">Member Jukebox</p>
        <h1>Song Queue</h1>
        <p class="subtitle">
          Anyone can watch the live queue. To request songs, members must scan the
          <strong>in-store Song Queue QR</strong> (shown on the venue TV / counter) — unlock lasts 4 hours.
        </p>
        <div class="hero-chips" v-if="authStore.isAuthenticated">
          <span class="chip" v-if="authStore.isMember">
            {{ membershipLabel }}
          </span>
          <span class="chip chip-ok" v-if="songStore.canRequestSongs && !songStore.venuePresence.bypass">
            Checked in{{ songStore.venueExpiresLabel ? ` · until ${songStore.venueExpiresLabel}` : '' }}
          </span>
          <span class="chip chip-ok" v-else-if="songStore.venuePresence.bypass">
            Staff · no check-in needed
          </span>
          <span class="chip chip-warn" v-else-if="authStore.isMember">
            Scan venue QR to request songs
          </span>
          <span class="chip chip-priority" v-if="authStore.isProMax && songStore.canRequestSongs">
            Priority left today: {{ songStore.priorityQuota.remaining }}/{{ songStore.priorityQuota.limit }}
          </span>
          <span class="chip chip-warn" v-else-if="authStore.isProMax && !songStore.canRequestSongs">
            Priority unlocks after venue check-in
          </span>
        </div>
      </div>
    </section>

    <div class="song-content">
      <!-- Check-in first: members who aren't present need clear in-store instructions -->
      <div
        v-if="authStore.isMember && !songStore.canRequestSongs"
        class="panel checkin-panel"
        id="venue-checkin"
      >
        <h2 class="panel-title">店内扫码后才能点歌 · Scan in-store to request</h2>
        <ol class="checkin-steps">
          <li>找店内电视 / 前台的 <strong>Song Queue QR</strong>（不是网站上的按钮）</li>
          <li>用手机 <strong>相机</strong> 或微信「扫一扫」扫描</li>
          <li>扫码后自动登录并解锁，<strong>4 小时内</strong>可自由点歌</li>
        </ol>
        <p class="hint">
          Look for the QR on the venue TV / counter. Use your phone camera (or WeChat Scan).
          There is no scan button on this website — the code is only shown in-store by staff.
        </p>

        <div class="manual-checkin">
          <label class="manual-label" for="manual-checkin-code">Or enter the code shown under the QR</label>
          <div class="manual-row">
            <input
              id="manual-checkin-code"
              v-model="manualCheckinCode"
              type="text"
              class="search-input"
              placeholder="Paste or type check-in code"
              autocomplete="off"
              @keydown.enter.prevent="submitManualCheckin"
            />
            <button
              class="btn btn-primary"
              type="button"
              :disabled="checkinSubmitting || !manualCheckinCode.trim()"
              @click="submitManualCheckin"
            >
              {{ checkinSubmitting ? 'Checking in…' : 'Check in' }}
            </button>
          </div>
        </div>

        <div class="checkin-actions">
          <button
            class="btn btn-secondary"
            type="button"
            :disabled="songStore.venuePresence.loading"
            @click="refreshPresence"
          >
            {{ songStore.venuePresence.loading ? 'Checking…' : 'I’ve scanned — refresh' }}
          </button>
          <router-link
            v-if="authStore.isAdmin"
            to="/songs/venue-qr"
            class="btn btn-primary"
            target="_blank"
          >
            Staff: open QR screen
          </router-link>
        </div>
      </div>

      <!-- Real Spotify player: currently playing + Spotify queue (public) -->
      <div class="panel spotify-panel">
        <div class="panel-header-row">
          <h2 class="panel-title">On Spotify</h2>
          <span class="spotify-live-hint" v-if="songStore.spotifyPlayer.updated_at">
            Live · updates ~10s
          </span>
        </div>
        <p class="hint">
          What the venue Spotify is actually playing and what’s already queued there.
          List shows the top 30 upcoming tracks.
          <template v-if="songStore.autoQueueEnabled">
            Website requests move here automatically, one at a time, in priority order.
          </template>
          <template v-else>
            Website requests only appear here after staff uses Play / Queue on Spotify.
          </template>
        </p>

        <div v-if="songStore.spotifyNowPlaying" class="now-playing spotify-now">
          <span class="badge playing">{{ songStore.spotifyPlayer.is_playing ? 'Playing now' : 'Paused' }}</span>
          <div class="queue-row">
            <img
              v-if="songStore.spotifyNowPlaying.album_art_url"
              :src="songStore.spotifyNowPlaying.album_art_url"
              alt=""
              class="album-art"
            />
            <div class="result-meta">
              <div class="track-name">{{ songStore.spotifyNowPlaying.track_name }}</div>
              <div class="artist-name">{{ songStore.spotifyNowPlaying.artist_name }}</div>
              <div v-if="playbackProgress" class="playback-progress">
                <div class="progress-track">
                  <div class="progress-fill" :style="{ width: playbackProgress.percent + '%' }"></div>
                </div>
                <span class="progress-time">{{ playbackProgress.label }}</span>
              </div>
            </div>
          </div>
        </div>
        <p v-else class="empty-inline">Nothing playing on the venue Spotify right now.</p>

        <p v-if="songStore.spotifyQueueCount" class="queue-count-hint">
          {{ songStore.spotifyQueueCount }}{{ songStore.spotifyPlayer.queue_may_have_more ? '+' : '' }} in Spotify queue
          <span v-if="songStore.spotifyQueueVisible.length < songStore.spotifyQueueCount" class="queue-count-sub">
            · showing top {{ songStore.spotifyQueueVisible.length }}
          </span>
        </p>
        <ol class="queue-list" v-if="songStore.spotifyQueueVisible.length">
          <li
            v-for="(item, index) in songStore.spotifyQueueVisible"
            :key="(item.spotify_track_id || item.track_name) + '-' + index"
            class="queue-item"
          >
            <span class="pos">#{{ index + 1 }}</span>
            <img v-if="item.album_art_url" :src="item.album_art_url" alt="" class="album-art" />
            <div class="result-meta">
              <div class="track-name">{{ item.track_name }}</div>
              <div class="artist-name">{{ item.artist_name }}</div>
            </div>
          </li>
        </ol>
        <p v-else class="empty-inline">Spotify queue is empty.</p>
      </div>

      <!-- Website Live queue: member requests -->
      <div class="panel">
        <div class="panel-header-row">
          <h2 class="panel-title">Website live queue</h2>
          <button class="btn btn-ghost btn-sm" type="button" @click="refreshQueue" :disabled="songStore.loading">
            Refresh
          </button>
        </div>
        <p class="hint">
          <template v-if="songStore.autoQueueEnabled">
            Songs requested on this website. They’re sent to Spotify automatically in priority order —
            Pro Max requests jump ahead. 自动送入 Spotify，无需管理员审核。
          </template>
          <template v-else>
            Songs requested on this website (waiting for staff to play or queue them on Spotify).
          </template>
        </p>

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
              <div v-if="playbackProgress" class="playback-progress">
                <div class="progress-track">
                  <div class="progress-fill" :style="{ width: playbackProgress.percent + '%' }"></div>
                </div>
                <span class="progress-time">{{ playbackProgress.label }}</span>
              </div>
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
                  @click="playNow(item)"
                >
                  {{ songStore.actionBusyId === item.id ? 'Playing…' : 'Play on Spotify' }}
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
                  @click="setStatus(item.id, 'playing')"
                  title="Only mark as playing on the website (does not control Spotify)"
                >
                  Mark playing
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

      <div v-else-if="!songStore.canRequestSongs" class="gate-card">
        <h2>Almost there</h2>
        <p>
          Scroll up to the check-in box, scan the in-store QR (or enter the code), then you can search
          and request songs for 4 hours.
        </p>
        <a class="btn btn-primary" href="#venue-checkin">Go to check-in</a>
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

          <div class="auto-mode" :class="{ on: songStore.autoQueueEnabled }">
            <div class="auto-mode-text">
              <strong>{{ songStore.autoQueueEnabled ? 'Auto mode: ON' : 'Auto mode: OFF' }}</strong>
              <span class="hint">
                {{
                  songStore.autoQueueEnabled
                    ? '自动模式：会员点的歌会按优先级自动进 Spotify，管理员无需逐首审核。'
                    : '手动模式：每一首都需要管理员点 Play / Queue on Spotify 才会进 Spotify。'
                }}
              </span>
            </div>
            <button
              class="btn btn-sm"
              :class="songStore.autoQueueEnabled ? 'btn-ghost' : 'btn-primary'"
              type="button"
              :disabled="songStore.autoQueue.saving"
              @click="toggleAutoMode"
            >
              {{
                songStore.autoQueue.saving
                  ? 'Saving…'
                  : songStore.autoQueueEnabled
                    ? 'Switch to manual'
                    : 'Switch to auto'
              }}
            </button>
          </div>

          <p class="hint">
            “Play on Spotify” starts that track now on the venue device. “Queue on Spotify” adds it to
            the queue — Spotify has no API to remove one specific queued track, so undo it manually in
            the Spotify app. “Skip current on Spotify” advances the currently playing track. “Mark
            playing” only updates the website (no Spotify control).
          </p>
          <button
            v-if="songStore.nextUp"
            class="btn btn-primary"
            type="button"
            :disabled="!!songStore.actionBusyId"
            @click="playNow(songStore.nextUp)"
          >
            Play next on Spotify: {{ songStore.nextUp.track_name }}
          </button>
        </div>
      </template>

      <p v-if="songStore.error" class="toast error" role="alert">{{ songStore.error }}</p>
    </div>
  </div>
</template>

<script>
import { ref, computed, watch, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/authStore'
import { useSongQueueStore } from '../stores/songQueueStore'
import { formatMembershipLevel } from '../utils/membershipDisplay'

const PENDING_CHECKIN_KEY = 'song_venue_checkin_code'

export default {
  name: 'SongQueuePage',
  setup() {
    const authStore = useAuthStore()
    const songStore = useSongQueueStore()
    const route = useRoute()
    const router = useRouter()
    const searchQuery = ref('')
    const searched = ref(false)
    const actionMessage = ref('')
    const actionMessageType = ref('ok')
    const manualCheckinCode = ref('')
    const checkinSubmitting = ref(false)
    let searchTimer = null
    let searchSeq = 0
    let flashTimer = null
    let queueBooted = false
    let checkinBusy = false

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

    // Real Spotify progress for the On Spotify card
    const playbackProgress = computed(() => {
      const now = songStore.spotifyNowPlaying
      const pb = songStore.playback
      if (!now || !pb.synced || !pb.is_playing) return null
      if (pb.track_id && now.spotify_track_id && pb.track_id !== now.spotify_track_id) return null
      const progress = pb.progress_ms ?? now.progress_ms
      const duration = pb.duration_ms ?? now.duration_ms
      if (progress == null || !duration) return null

      const fmt = (ms) => {
        const s = Math.max(0, Math.floor(ms / 1000))
        return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`
      }
      return {
        percent: Math.min(100, Math.round((progress / duration) * 100)),
        label: `${fmt(progress)} / ${fmt(duration)}`
      }
    })

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

    const refreshPresence = async () => {
      await songStore.fetchVenuePresence()
      if (songStore.canRequestSongs) {
        flash(
          songStore.venuePresence.bypass
            ? 'Staff access — you can request songs.'
            : `Checked in${songStore.venueExpiresLabel ? ` until ${songStore.venueExpiresLabel}` : ''}.`
        )
      } else {
        flash('Not checked in yet. Scan the venue QR, then try again.', 'warn')
      }
    }

    const clearCheckinQuery = async () => {
      if (!route.query.checkin) return
      const nextQuery = { ...route.query }
      delete nextQuery.checkin
      await router.replace({ path: '/songs', query: nextQuery })
    }

    const redeemCheckinCode = async (rawCode) => {
      const token = String(rawCode || '').trim()
      if (!token || checkinBusy) return
      checkinBusy = true
      checkinSubmitting.value = true
      try {
        if (!authStore.isAuthenticated) {
          try {
            sessionStorage.setItem(PENDING_CHECKIN_KEY, token)
          } catch {
            /* ignore */
          }
          flash('Sign in to complete venue check-in…', 'warn')
          await router.push({ path: '/login', query: { redirect: `/songs?checkin=${encodeURIComponent(token)}` } })
          return
        }
        const data = await songStore.redeemVenueCheckin(token)
        try {
          sessionStorage.removeItem(PENDING_CHECKIN_KEY)
        } catch {
          /* ignore */
        }
        manualCheckinCode.value = ''
        await clearCheckinQuery()
        flash(data?.message || 'Checked in. You can request songs for 4 hours.')
        if (authStore.isMember) await songStore.fetchPriorityQuota()
      } catch (err) {
        flash(err.message || 'Check-in failed', 'error')
      } finally {
        checkinBusy = false
        checkinSubmitting.value = false
      }
    }

    const submitManualCheckin = async () => {
      await redeemCheckinCode(manualCheckinCode.value)
    }

    const refreshQueue = async () => {
      await Promise.all([
        songStore.fetchQueue(),
        songStore.syncPlayback({ force: true }),
        songStore.fetchAutoQueueSettings(),
        authStore.isMember ? songStore.fetchPriorityQuota() : Promise.resolve(),
        authStore.isAuthenticated ? songStore.fetchVenuePresence() : Promise.resolve()
      ])
    }

    const toggleAutoMode = async () => {
      try {
        const enabled = await songStore.setAutoQueueEnabled(!songStore.autoQueueEnabled)
        flash(
          enabled
            ? 'Auto mode on — requests go to Spotify automatically.'
            : 'Manual mode on — you decide what reaches Spotify.',
          'success'
        )
      } catch (err) {
        flash(err.message || 'Could not change mode', 'error')
      }
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

    const playNow = async (item) => {
      try {
        flash('Starting playback on Spotify…')
        const data = await songStore.playNowOnSpotify(item)
        if (data?.skipped) {
          flash(
            data.message ||
              'Spotify venue token not configured. Use “Mark playing” for website-only.',
            'warn'
          )
        } else {
          const device = data?.device_name ? ` on “${data.device_name}”` : ''
          flash(`Now playing on Spotify${device}.`)
        }
      } catch (err) {
        flash(err.message || 'Spotify play failed', 'error')
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
    watch(
      () => [authStore.isAuthenticated, authStore.profile?.id, route.query.checkin],
      async () => {
        await songStore.fetchQueue({ silent: queueBooted })
        if (authStore.isAuthenticated) await songStore.fetchVenuePresence()
        if (authStore.isMember) await songStore.fetchPriorityQuota()
        if (!queueBooted) {
          queueBooted = true
          songStore.fetchAutoQueueSettings()
          songStore.subscribeRealtime()
          songStore.startPlaybackPoll(10000)
        }

        const fromQuery = typeof route.query.checkin === 'string' ? route.query.checkin : ''
        let pending = fromQuery
        if (!pending && authStore.isAuthenticated) {
          try {
            pending = sessionStorage.getItem(PENDING_CHECKIN_KEY) || ''
          } catch {
            pending = ''
          }
        }
        if (pending) await redeemCheckinCode(pending)
      },
      { immediate: true }
    )

    onUnmounted(() => {
      if (searchTimer) clearTimeout(searchTimer)
      if (flashTimer) clearTimeout(flashTimer)
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
      playbackProgress,
      highlightMatch,
      refreshQueue,
      refreshAll,
      toggleAutoMode,
      refreshPresence,
      submitManualCheckin,
      manualCheckinCode,
      checkinSubmitting,
      runSearch,
      onSearchInput,
      addTrack,
      cancelMine,
      setStatus,
      pushSpotify,
      playNow,
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

.chip-ok {
  background: rgba(34, 197, 94, 0.18);
  border-color: rgba(34, 197, 94, 0.35);
  color: #86efac;
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

.checkin-panel {
  border-color: rgba(34, 197, 94, 0.35);
  background: linear-gradient(180deg, rgba(34, 197, 94, 0.12), rgba(15, 23, 42, 0.7));
}

.checkin-steps {
  margin: 0.5rem 0 0.75rem;
  padding-left: 1.25rem;
  color: #e2e8f0;
  line-height: 1.55;
}

.checkin-steps li + li {
  margin-top: 0.35rem;
}

.manual-checkin {
  margin: 1rem 0;
}

.manual-label {
  display: block;
  margin-bottom: 0.4rem;
  color: #94a3b8;
  font-size: 0.9rem;
}

.manual-row {
  display: flex;
  gap: 0.6rem;
  flex-wrap: wrap;
}

.manual-row .search-input {
  flex: 1 1 220px;
}

.checkin-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.6rem;
  margin-top: 0.5rem;
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

.queue-count-sub {
  color: #64748b;
  font-size: 0.8rem;
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

.spotify-panel {
  border-color: rgba(29, 185, 84, 0.25);
}

.spotify-live-hint {
  font-size: 0.8rem;
  color: #86efac;
}

.spotify-now {
  margin-top: 0.75rem;
}

.now-playing {
  margin-bottom: 1rem;
  padding: 0.75rem;
  border-radius: 12px;
  border: 1px solid rgba(29, 185, 84, 0.35);
  background: rgba(29, 185, 84, 0.08);
}

.playback-progress {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-top: 0.4rem;
}

.progress-track {
  flex: 1;
  max-width: 260px;
  height: 5px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.12);
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  border-radius: 999px;
  background: #1db954;
  transition: width 1s linear;
}

.progress-time {
  font-size: 0.75rem;
  color: #9fb0c9;
  font-variant-numeric: tabular-nums;
}

.empty-inline {
  color: #94a3b8;
  margin: 0.75rem 0 0;
}

.admin-panel {
  border-color: rgba(250, 204, 21, 0.25);
}

.auto-mode {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  margin: 0.25rem 0 0.9rem;
  padding: 0.75rem 0.9rem;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(15, 23, 42, 0.6);
}

.auto-mode.on {
  border-color: rgba(34, 197, 94, 0.45);
  background: rgba(22, 163, 74, 0.12);
}

.auto-mode-text {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  min-width: min(100%, 18rem);
  flex: 1;
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
