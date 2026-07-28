<template>
  <div class="venue-qr-page">
    <header class="venue-qr-header">
      <div>
        <p class="eyebrow">{{ t('venueQr.eyebrow') }}</p>
        <h1>{{ t('venueQr.title') }}</h1>
        <p class="subtitle">{{ t('venueQr.subtitle') }}</p>
      </div>
      <div class="header-actions">
        <button class="btn btn-ghost" type="button" :disabled="loading" @click="refresh(false)">
          {{ t('venueQr.refresh') }}
        </button>
        <button class="btn btn-primary" type="button" :disabled="loading" @click="refresh(true)">
          {{ t('venueQr.newCode') }}
        </button>
      </div>
    </header>

    <div class="venue-qr-card" v-if="checkinUrl">
      <p class="scan-banner">{{ t('venueQr.scanBanner') }}</p>
      <img
        class="qr-image"
        :src="qrImageUrl"
        alt="Venue song check-in QR code"
        width="360"
        height="360"
      />
      <p class="countdown" :class="{ urgent: secondsLeft <= 60 }">
        {{ countdownLabel }}
      </p>
      <div class="code-block">
        <p class="code-label">{{ t('venueQr.manualCode') }}</p>
        <p class="code-value">{{ code }}</p>
        <button class="btn btn-ghost btn-sm" type="button" @click="copyCode">
          {{ copied ? t('common.copied') : t('venueQr.copyCode') }}
        </button>
      </div>
      <p class="hint">{{ t('venueQr.hint') }}</p>
    </div>

    <p v-else-if="loading" class="status">{{ t('venueQr.loading') }}</p>
    <p v-else-if="error" class="status error">{{ error }}</p>

    <ol class="staff-steps">
      <li>{{ t('venueQr.step1') }}</li>
      <li>{{ t('venueQr.step2') }}</li>
      <li>{{ t('venueQr.step3') }}</li>
    </ol>
  </div>
</template>

<script>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useSongQueueStore } from '../stores/songQueueStore'
import { useI18n } from '../i18n'

export default {
  name: 'VenueCheckinQrPage',
  setup() {
    const songStore = useSongQueueStore()
    const { t } = useI18n()
    const loading = ref(false)
    const error = ref('')
    const code = ref('')
    const validUntil = ref(null)
    const nowTick = ref(Date.now())
    const copied = ref(false)
    let tickTimer = null
    let rotateTimer = null
    let copyTimer = null

    const checkinUrl = computed(() => {
      if (!code.value) return ''
      const origin = typeof window !== 'undefined' ? window.location.origin : ''
      return `${origin}/songs?checkin=${encodeURIComponent(code.value)}`
    })

    const qrImageUrl = computed(() => {
      if (!checkinUrl.value) return ''
      return `https://api.qrserver.com/v1/create-qr-code/?size=360x360&margin=12&data=${encodeURIComponent(checkinUrl.value)}`
    })

    const secondsLeft = computed(() => {
      if (!validUntil.value) return 0
      return Math.max(0, Math.floor((new Date(validUntil.value).getTime() - nowTick.value) / 1000))
    })

    const countdownLabel = computed(() => {
      const s = secondsLeft.value
      if (s <= 0) return t('venueQr.expired')
      const m = Math.floor(s / 60)
      const r = s % 60
      return t('venueQr.refreshesIn', { time: `${m}:${String(r).padStart(2, '0')}` })
    })

    const clearTimers = () => {
      if (tickTimer) {
        clearInterval(tickTimer)
        tickTimer = null
      }
      if (rotateTimer) {
        clearTimeout(rotateTimer)
        rotateTimer = null
      }
      if (copyTimer) {
        clearTimeout(copyTimer)
        copyTimer = null
      }
    }

    const scheduleRotate = () => {
      if (rotateTimer) clearTimeout(rotateTimer)
      const ms = Math.max(5_000, secondsLeft.value * 1000 - 2_000)
      rotateTimer = setTimeout(() => {
        refresh(true)
      }, ms)
    }

    const refresh = async (forceNew = false) => {
      loading.value = true
      error.value = ''
      try {
        const data = await songStore.fetchCheckinQr({ forceNew })
        code.value = data.code
        validUntil.value = data.valid_until
        nowTick.value = Date.now()
        scheduleRotate()
      } catch (err) {
        error.value = err.message || String(err)
      } finally {
        loading.value = false
      }
    }

    const copyCode = async () => {
      try {
        await navigator.clipboard.writeText(code.value)
        copied.value = true
        if (copyTimer) clearTimeout(copyTimer)
        copyTimer = setTimeout(() => {
          copied.value = false
        }, 2000)
      } catch {
        /* ignore */
      }
    }

    onMounted(async () => {
      tickTimer = setInterval(() => {
        nowTick.value = Date.now()
      }, 1000)
      await refresh(false)
    })

    onUnmounted(() => {
      clearTimers()
    })

    return {
      t,
      loading,
      error,
      code,
      checkinUrl,
      qrImageUrl,
      secondsLeft,
      countdownLabel,
      copied,
      refresh,
      copyCode
    }
  }
}
</script>

<style scoped>
.venue-qr-page {
  min-height: 100vh;
  padding: 1.5rem clamp(1rem, 3vw, 2.5rem) 3rem;
  background:
    radial-gradient(ellipse at top, rgba(34, 197, 94, 0.12), transparent 50%),
    linear-gradient(180deg, #0b1220 0%, #111827 100%);
  color: #e2e8f0;
}

.venue-qr-header {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1.5rem;
}

.eyebrow {
  margin: 0;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  font-size: 0.75rem;
  color: #86efac;
}

h1 {
  margin: 0.25rem 0;
  font-size: clamp(1.6rem, 3vw, 2.2rem);
}

.subtitle {
  margin: 0;
  max-width: 42rem;
  color: #94a3b8;
  line-height: 1.5;
}

.header-actions {
  display: flex;
  gap: 0.6rem;
  flex-wrap: wrap;
}

.venue-qr-card {
  max-width: 30rem;
  margin: 0 auto;
  padding: 1.5rem;
  border-radius: 1.25rem;
  background: rgba(15, 23, 42, 0.85);
  border: 1px solid rgba(148, 163, 184, 0.2);
  text-align: center;
}

.scan-banner {
  margin: 0 0 0.75rem;
  font-size: 1.15rem;
  font-weight: 700;
  color: #86efac;
}

.qr-image {
  width: min(360px, 100%);
  height: auto;
  border-radius: 0.75rem;
  background: #fff;
  padding: 0.85rem;
}

.countdown {
  margin: 1rem 0 0.5rem;
  font-size: 1.35rem;
  font-weight: 700;
  color: #86efac;
}

.countdown.urgent {
  color: #fbbf24;
}

.code-block {
  margin: 0.75rem 0;
  padding: 0.85rem;
  border-radius: 0.85rem;
  background: rgba(15, 23, 42, 0.9);
  border: 1px dashed rgba(148, 163, 184, 0.35);
}

.code-label {
  margin: 0;
  color: #94a3b8;
  font-size: 0.85rem;
}

.code-value {
  margin: 0.35rem 0 0.65rem;
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  font-size: clamp(1.1rem, 3vw, 1.45rem);
  letter-spacing: 0.04em;
  word-break: break-all;
  color: #f8fafc;
}

.hint {
  margin: 0;
  color: #94a3b8;
  font-size: 0.95rem;
}

.staff-steps {
  max-width: 40rem;
  margin: 1.75rem auto 0;
  padding-left: 1.25rem;
  color: #94a3b8;
  line-height: 1.55;
}

.status {
  text-align: center;
  color: #94a3b8;
}

.status.error {
  color: #fca5a5;
}

.btn {
  border: 0;
  border-radius: 0.65rem;
  padding: 0.65rem 1rem;
  font-weight: 600;
  cursor: pointer;
}

.btn-sm {
  padding: 0.4rem 0.75rem;
  font-size: 0.85rem;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-primary {
  background: #22c55e;
  color: #052e16;
}

.btn-ghost {
  background: rgba(148, 163, 184, 0.15);
  color: #e2e8f0;
}
</style>
