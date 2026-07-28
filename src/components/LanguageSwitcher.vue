<template>
  <div class="lang-switch" role="group" :aria-label="t('lang.label')">
    <button
      type="button"
      class="lang-btn"
      :class="{ active: locale === 'en' }"
      :aria-pressed="locale === 'en'"
      @click="setLocale('en')"
    >
      {{ t('lang.en') }}
    </button>
    <button
      type="button"
      class="lang-btn"
      :class="{ active: locale === 'zh' }"
      :aria-pressed="locale === 'zh'"
      @click="setLocale('zh')"
    >
      {{ t('lang.zh') }}
    </button>
  </div>
</template>

<script>
import { useI18n } from '../i18n'

export default {
  name: 'LanguageSwitcher',
  setup() {
    const { locale, t, setLocale } = useI18n()
    return { locale, t, setLocale }
  }
}
</script>

<style scoped>
.lang-switch {
  display: inline-flex;
  align-items: center;
  gap: 2px;
  padding: 2px;
  border-radius: 999px;
  border: 1px solid rgba(255, 255, 255, 0.18);
  background: rgba(15, 23, 42, 0.45);
}

.lang-btn {
  appearance: none;
  border: 0;
  background: transparent;
  color: rgba(255, 255, 255, 0.72);
  font-size: 0.75rem;
  font-weight: 600;
  letter-spacing: 0.02em;
  padding: 0.28rem 0.55rem;
  border-radius: 999px;
  cursor: pointer;
  line-height: 1.2;
}

.lang-btn.active {
  background: rgba(250, 204, 21, 0.92);
  color: #0f172a;
}

.lang-btn:focus-visible {
  outline: 2px solid rgba(250, 204, 21, 0.9);
  outline-offset: 1px;
}
</style>
