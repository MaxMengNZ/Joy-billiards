import { EVENT_UUID, EVENT_REFERENCE, eventSharePath, safeEventBanner } from '../src/utils/eventShare.js';

export const PUBLIC_ORIGIN = 'https://club.joybilliards.co.nz';
const escape = (value) => String(value ?? '').replace(/[&<>"']/g, (c) => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));

// Parse paths, never payment/auth/query parameters. Accept the internal rewrite too.
export function eventShareTarget(pathname) {
  const match = /^\/(?:app|api\/event-share)\/(e|event)\/([^/]+)\/?$/.exec(pathname);
  if (!match) return null;
  const [, kind, value] = match;
  if (!(kind === 'e' ? EVENT_REFERENCE : EVENT_UUID).test(value)) return null;
  return { kind, value };
}

export function eventShareMetadata(event, venue = {}) {
  if (!EVENT_UUID.test(event?.id || '') || !event?.name || event.status === 'draft') return null;
  const url = `${PUBLIC_ORIGIN}${eventSharePath(event)}`;
  let date = '时间待确认 · Date to be confirmed';
  if (venue.timezone && Number.isFinite(Date.parse(event.start_date))) {
    try {
      const parts = new Intl.DateTimeFormat('en-GB', { year:'numeric', month:'2-digit', day:'2-digit', hour:'2-digit', minute:'2-digit', hourCycle:'h23', timeZone:venue.timezone }).formatToParts(new Date(event.start_date));
      const part = (type) => parts.find(item => item.type === type)?.value;
      date = `${part('year')}-${part('month')}-${part('day')} ${part('hour')}:${part('minute')}`;
    } catch { /* Do not invent a timezone if the venue is incomplete. */ }
  }
  // Put date and venue before the CTA so small chat cards retain the useful facts.
  const place = venue.name || '门店待确认 · Venue to be confirmed';
  const ended = ['completed', 'cancelled', 'canceled'].includes(event.status);
  const suffix = event.status === 'completed' ? '赛事已结束 · Event completed'
    : ended ? '赛事已取消 · Event cancelled' : '查看赛事与报名 · View event & entry';
  return {
    title: event.name, description: `${date} · ${place} · ${suffix}`,
    url, image: safeEventBanner(event.event_options?.bannerUrl) || `${PUBLIC_ORIGIN}/icons/icon-512x512.png`,
    imageAlt: `${event.name} · ${venue.name || 'JOY CLUB'}`,
  };
}

export function injectEventShareMetadata(template, metadata) {
  if (!metadata) return template;
  const {title, description, image, imageAlt, url} = metadata;
  const tag = (name, value, attribute = 'property') => `<meta ${attribute}="${name}" content="${escape(value)}">`;
  const head = [
    `<title>${escape(title)} · JOY CLUB</title>`,
    tag('description', description, 'name'), tag('og:type', 'website'),
    tag('og:site_name', 'JOY CLUB'), tag('og:title', title), tag('og:description', description),
    tag('og:url', url), tag('og:image', image), tag('og:image:secure_url', image), tag('og:image:alt', imageAlt),
    tag('twitter:card', 'summary_large_image', 'name'), tag('twitter:title', title, 'name'),
    tag('twitter:description', description, 'name'), tag('twitter:image', image, 'name'),
    `<link rel="canonical" href="${escape(url)}">`,
  ].join('\n');
  // No body replacement, redirect, inline event JSON, or changes to SPA scripts.
  return template.replace(/<title\b[^>]*>[\s\S]*?<\/title>/gi, '')
    .replace(/<meta\b(?=[^>]*\bname=["']description["'])[^>]*>/gi, '')
    .replace('</head>', `${head}\n</head>`);
}

export async function readEventShareMetadata(target, { env, fetcher = fetch, signal }) {
  if (!target || !env.VITE_SUPABASE_URL || !env.VITE_SUPABASE_ANON_KEY) return null;
  // Only the same public anon key used by the website, never a service-role key or user cookie.
  const base = new URL('/rest/v1/', env.VITE_SUPABASE_URL);
  if (base.protocol !== 'https:') return null;
  const read = async (table, params) => {
    const url = new URL(table, base);
    url.search = new URLSearchParams({ ...params, limit: '1' }).toString();
    const response = await fetcher(url, {
      method: 'GET', signal, headers: { apikey: env.VITE_SUPABASE_ANON_KEY, Authorization: `Bearer ${env.VITE_SUPABASE_ANON_KEY}` },
    });
    if (!response.ok) throw new Error('PUBLIC_METADATA_UNAVAILABLE');
    const rows = await response.json();
    return Array.isArray(rows) ? rows[0] : null;
  };
  const event = await read('tournaments', {
    select: 'id,name,start_date,status,venue_id,event_options,share_code,share_alias',
    ...(target.kind === 'event' ? {id: `eq.${target.value}`} : {or: `(share_code.eq.${target.value.toUpperCase()},share_alias.eq.${target.value.toLowerCase()})`}),
    status: 'in.(registration,upcoming,in_progress,completed,cancelled)',
  });
  if (!event) return null;
  const venue = event.venue_id ? await read('venues', { select: 'name,address,timezone', id: `eq.${event.venue_id}` }) : null;
  return eventShareMetadata(event, venue || {});
}

export async function eventShareHtml(template, pathname, env, options = {}) {
  const target = eventShareTarget(pathname);
  if (!target) return {html: template, enriched: false};
  try {
    const metadata = await readEventShareMetadata(target, {env, signal: AbortSignal.timeout(1500), ...options});
    return {html: injectEventShareMetadata(template, metadata), enriched: Boolean(metadata)};
  } catch {
    // Sharing must never make the existing registration page unavailable.
    return {html: template, enriched: false};
  }
}
