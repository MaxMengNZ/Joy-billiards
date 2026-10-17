# Event sharing metadata — local preview only

## Scope

Preserve the existing event, registration, account and payment implementation.
Only `/app/e/:reference` and `/app/event/:id` acquire server-rendered head metadata.
Both humans and crawlers receive the same existing SPA body and assets; no bot-only
content, automatic redirects, private registration results, payment calls or writes.

## Preview

`http://127.0.0.1:8096/event-sharing-preview` is a dev-server-only page. It reads
the actual first-response Open Graph tags from real event links and simulates
WeChat small-image and Facebook large-image layouts. It is not an actual platform
capture. Student, weekly and U21 links are available in the selector.

The existing event pages are unchanged visually. Date and venue appear before the
CTA in the description so compact shares retain the important facts. Dates are
formatted in the venue timezone, never the viewer/server timezone. Missing date,
timezone, venue or banner does not fabricate a value; missing banners use JOY's
existing PNG icon. Completed/cancelled events do not advertise fresh entry.

## Safety and performance

- Same public anon key and RLS as the website, no service-role key/user token.
- Two bounded GETs (public tournament, its venue); no roster or user data.
- A 1.5-second combined upstream budget, then unchanged SPA shell on data failure.
- Names/descriptions/URLs escaped; canonical uses the fixed official origin and
  existing safe share path, never cookies, host headers or checkout parameters.
- No change to browser URL or query string; original payment return handling stays.
- Browser responses no-store. At release, Vercel CDN may cache only successfully
  enriched query-free/cookie-free/auth-free public HTML for 300 seconds plus 60s SWR.
  This caches metadata and the generic app shell, not fees, rosters or personal state.
- Existing client still loads current event and registration data normally.
- Runtime file inclusion must package `dist/index.html`. Missing deployment template
  returns 503 with Retry-After, never redirects a checkout return to the home page.

## Verification / release gate

Run `npm run build` then `node --test tests/*.test.mjs` (adapter smoke test reads
the real compiled index). Verify both short/UUID routes, HEAD/GET, public key-only
reads, canonical stripping, escaping, Melbourne time, no-body changes and fallback.
Local initial HTML checked with both normal and Facebook crawler User-Agents.

Before any production promotion, verify Vercel's actual rewrite/catch-all handling,
function environment and packaged template against the staged build. This cannot
be proven by Vite's dev middleware alone. Then repeat registration-return and
checkout-query smoke checks without creating accounts or initiating payment.

After public deployment, use Facebook Sharing Debugger and actual WeChat sharing.
Localhost cannot be scraped by either platform. Older shares may keep platform
cache entries. Neither final layout nor cache refresh can be guaranteed by local
metadata tests. WeChat's rich-card behaviour can also vary by sharing method and
account configuration; do not promise every pasted text URL becomes a rich card.

No production deployment, database changes, App OTA or real social posting is
authorized or performed for this local-preview request.
