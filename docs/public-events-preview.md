# Events preview

Scope: /events, public navigation, read-only public event retrieval and tests.
Local preview only; no database migration, grants, API mutation or publication.

## Direction contract
THESIS: Find an appropriate real tournament immediately, without a promotional
wall before the schedule. Prioritize live and imminent events over distant dates.
OWN-WORLD: Extend Pricing's warm-white ground, charcoal panel, JOY red actions,
rounded corners, restrained gold accent, existing header/footer and system type.
STORY: Choose a venue/type, scan dates and currency, open existing event details.
FIRST VIEWPORT: Public header, compact charcoal introduction with the next event,
then labeled filters and the first image-led schedule rows. Desktop three-column
list; two columns at tablet width; single-column mobile with all navigation visible.
FORM: User-pinned extension of existing Pricing/Membership style; no concept seed
needed. Direct interactive implementation, not a replacement visual identity.
FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance

Data: anonymous public fields only, bounded pagination, no rosters or per-event
count RPC fan-out. UTC storage is formatted with each venue's actual timezone.
Banner images are existing public HTTPS campaign assets, not newly generated art.

## Inherited style and image provenance

`DESIGN.md` records source-extracted public-page values and explicitly distinguishes
the Events extension from Pricing's existing gradients, shadows, and varying
corner radii. No new visual identity, global token migration, or management-theme
change is authorized. `.impeccable/design.json` holds only supplementary observed
breakpoints, motion, and representative component previews.

The Events rasters come directly from each public event's
`event_options.bannerUrl`; `safeEventBanner` accepts syntactically valid HTTPS URLs
(it is a protocol check, not a host allowlist). Both the featured event and schedule card use that same
source field. The page does not generate, download, edit, upload, or relicense
these campaign assets. Their authorship and usage rights are not established by
this code and are not claimed here. Because the URLs are live event data, this is
a field-level provenance record rather than a fabricated static asset manifest.
For any future captured/exported asset manifest, record the actual event ID,
resolved source URL, and capture date at that time.

Missing, rejected, or failed images use a CSS/text JOY fallback; no replacement
raster ships. Schedule imagery is cropped with `object-fit: cover`, uses empty
alternative text alongside the accessible event link, and loads lazily; the
featured image uses a dark CSS overlay. The existing header identity asset is
`public/JoyBilliards-Logo.svg`, reused unchanged.

## Local verification outcome

22 tests and the production build passed. Existing student-event short link
opened the unchanged detail page with venue-local 15:00, NZD20 and original
registration controls; no entry or payment was submitted. Open and venue filters
were exercised; Challenges & more returned the real Friday series after its
null/unknown-kind correction. Read-only live and future retrieval use independent
chronological pagination; a >12 mixed-status regression protects imminent events.

Independent finish-review verdict: ship for local preview only; all three named
fixes resolved (pagination, category membership, desktop/mobile captures).
Evidence: .impeccable/review/desktop.png 1280x960, mobile.png 390x844, plus the
actual 795px user-width schedule capture. Documentation/provenance pass completed.
The detector's inherited App.vue bounce-icon warning is outside this scope and
was not changed. No remote push, deployment, database mutation or App OTA update.
