import { eventSharePath } from './eventShare.js'

export const PUBLIC_EVENT_FIELDS = 'id,venue_id,name,start_date,status,entry_fee,currency,event_options,share_alias,share_code'
export const PUBLIC_EVENT_STATUSES = ['in_progress', 'registration', 'upcoming']
export const EVENT_PAGE_SIZE = 12
export const EVENT_KINDS = ['all', 'weekly_pro', 'weekly_student', 'open', 'custom']

export function isDiscoverableEvent(event, now = Date.now()) {
  const date = Date.parse(event?.start_date)
  return !!eventSharePath(event) && PUBLIC_EVENT_STATUSES.includes(event?.status)
    && Number.isFinite(date) && (event.status === 'in_progress' || date >= now)
}

export function orderPublicEvents(events, now = Date.now()) {
  return events.filter(event => isDiscoverableEvent(event, now)).sort((a, b) =>
    Number(b.status === 'in_progress') - Number(a.status === 'in_progress')
      || Date.parse(a.start_date) - Date.parse(b.start_date)
      || a.id.localeCompare(b.id))
}

export function publicEventGroup(event, now = Date.now()) {
  if (event.status === 'in_progress') return 'live'
  return Date.parse(event.start_date) < now + 7 * 86400000 ? 'soon' : 'later'
}

export function publicEventKind(event) {
  const kind = event?.event_options?.kind
  return kind === 'weekly_pro' || kind === 'weekly_student' ? kind
    : ['open', 'qualifier', 'individual'].includes(kind) ? 'open' : 'custom'
}

export function publicEventFee(event, venue, language = 'en') {
  const value = event?.entry_fee
  if (value === null || value === undefined || value === '' || !Number.isFinite(Number(value)) || Number(value) < 0)
    return language === 'zh' ? '费用待确认' : 'Fee to be confirmed'
  if (Number(value) === 0) return language === 'zh' ? '免费报名' : 'Free entry'
  const currency = String(event.currency || venue?.currency || '').toUpperCase()
  if (!['NZD', 'AUD'].includes(currency)) return language === 'zh' ? '费用见详情' : 'See entry details'
  return new Intl.NumberFormat(language === 'zh' ? 'zh-CN' : 'en-NZ', {
    style: 'currency', currency, currencyDisplay: 'code', maximumFractionDigits: 2,
  }).format(Number(value))
}

export function publicEventDate(event, venue, language = 'en') {
  const timeZone = venue?.timezone
  if (!timeZone) return { date: language === 'zh' ? '时间见赛事详情' : 'See event for local time', zone: '' }
  try {
    const date = new Intl.DateTimeFormat(language === 'zh' ? 'zh-CN' : 'en-NZ', {
      timeZone, month: 'short', day: 'numeric', weekday: 'short', hour: '2-digit', minute: '2-digit', hour12: language !== 'zh',
    }).format(new Date(event.start_date))
    return { date, zone: timeZone }
  } catch {
    return { date: language === 'zh' ? '时间见赛事详情' : 'See event for local time', zone: '' }
  }
}
