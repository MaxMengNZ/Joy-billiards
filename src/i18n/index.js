/**
 * Lightweight i18n — zh / en only.
 * Device language auto-detect; default English; manual override in localStorage.
 */
import { computed, ref } from 'vue'
import en from './locales/en'
import zh from './locales/zh'

export const STORAGE_KEY = 'joy_locale'
export const SUPPORTED = ['en', 'zh']

const messages = { en, zh }

function readStoredLocale() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY)
    if (saved === 'zh' || saved === 'en') return saved
  } catch {
    /* ignore */
  }
  return null
}

/** zh* → Chinese; everything else → English (default). */
export function detectDeviceLocale() {
  try {
    const candidates = [
      ...(navigator.languages || []),
      navigator.language,
      navigator.userLanguage
    ].filter(Boolean)
    for (const raw of candidates) {
      if (String(raw).toLowerCase().startsWith('zh')) return 'zh'
    }
  } catch {
    /* ignore */
  }
  return 'en'
}

function initialLocale() {
  return readStoredLocale() || detectDeviceLocale() || 'en'
}

export const locale = ref(initialLocale())

function applyDocumentLang(code) {
  try {
    document.documentElement.lang = code === 'zh' ? 'zh-CN' : 'en'
  } catch {
    /* ignore */
  }
}

applyDocumentLang(locale.value)

export function setLocale(code) {
  const next = code === 'zh' ? 'zh' : 'en'
  locale.value = next
  try {
    localStorage.setItem(STORAGE_KEY, next)
  } catch {
    /* ignore */
  }
  applyDocumentLang(next)
}

function lookup(dict, path) {
  if (!dict || !path) return undefined
  return path.split('.').reduce((obj, key) => (obj && obj[key] != null ? obj[key] : undefined), dict)
}

/**
 * Translate a dotted key. Reads `locale` so Vue tracks changes.
 * Supports `{name}` interpolation via params.
 */
export function t(key, params = {}) {
  const loc = locale.value
  let str = lookup(messages[loc], key)
  if (str == null) str = lookup(messages.en, key)
  if (str == null) return key
  if (typeof str !== 'string') return String(str)
  return str.replace(/\{(\w+)\}/g, (_, name) =>
    params[name] != null ? String(params[name]) : `{${name}}`
  )
}

export function useI18n() {
  const isZh = computed(() => locale.value === 'zh')
  return {
    locale,
    isZh,
    t,
    setLocale,
    toggleLocale() {
      setLocale(locale.value === 'zh' ? 'en' : 'zh')
    }
  }
}

export function installI18n(app) {
  app.config.globalProperties.$t = t
  app.config.globalProperties.$locale = locale
  app.config.globalProperties.$setLocale = setLocale
  app.provide('i18n', { locale, t, setLocale })
}
