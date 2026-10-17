import { EVENT_PAGE_SIZE, PUBLIC_EVENT_FIELDS } from './publicEvents.js'

// Keep live and future paging independent: sorting by status before LIMIT would
// hide imminent "upcoming" events behind distant "registration" rows.
export function publicEventsQuery(client, { live, offset = 0, venueId = 'all', kind = 'all', now = new Date().toISOString(), signal }) {
  let query = client.from('tournaments').select(PUBLIC_EVENT_FIELDS)
  query = live ? query.eq('status', 'in_progress')
    : query.in('status', ['registration', 'upcoming']).gte('start_date', now)
  if (venueId !== 'all') query = query.eq('venue_id', venueId)
  if (kind === 'open') query = query.in('event_options->>kind', ['open', 'qualifier', 'individual'])
  else if (kind === 'custom') query = query.or('event_options->>kind.is.null,event_options->>kind.not.in.(weekly_pro,weekly_student,open,qualifier,individual)')
  else if (kind !== 'all') query = query.eq('event_options->>kind', kind)
  return query.order('start_date').order('id').range(offset, offset + EVENT_PAGE_SIZE - 1).abortSignal(signal)
}
