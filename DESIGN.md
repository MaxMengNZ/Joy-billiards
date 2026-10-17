---
name: JOY public club pages
description: Extracted incumbent public-site style; not a replacement identity or a management-app theme.
colors:
  joy-red: "#d9212f"
  warm-white: "#f7f5f2"
  charcoal: "#191719"
  ink: "#191817"
  white: "#fff"
  card-border: "#e2ddd7"
  muted-copy: "#d1ccca"
typography:
  display:
    fontFamily: '-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif'
    fontSize: "clamp(32px,4.2vw,54px)"
    fontWeight: 800
    lineHeight: 1.1
    letterSpacing: "-.035em"
  body:
    fontFamily: '-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif'
    fontSize: "14px"
    lineHeight: 1.8
rounded:
  control: "12px"
  event-card: "16px"
  intro: "30px"
spacing:
  filter-gap: "8px"
  card-gap: "18px"
  card-padding: "20px"
  intro-padding: "42px"
components:
  event-primary-link:
    backgroundColor: "{colors.joy-red}"
    textColor: "{colors.white}"
    rounded: "{rounded.control}"
    padding: "13px 18px"
  event-card:
    backgroundColor: "{colors.white}"
    textColor: "{colors.ink}"
    rounded: "{rounded.event-card}"
  event-filter-selected:
    backgroundColor: "{colors.charcoal}"
    textColor: "{colors.white}"
    rounded: "{rounded.control}"
    padding: "0 16px"
---

# Design System: JOY public club pages

## Overview

This is a source-extracted record of the existing public club style and its
Events extension, not a newly chosen visual world. The user pinned the existing
JOY identity and bilingual Chinese/English experience. No creative north star,
new font family, or global theme replacement was commissioned.

Scope: `PublicClubHeader.vue`, `PublicClubFooter.vue`, `PricingPage.vue`, and
`PublicEventsPage.vue`. The frontmatter describes observed Events values; it does
not assert that these are already centralized application-wide tokens. The
Events page's schedule-first strategy belongs in `docs/public-events-preview.md`.

## Colors

JOY red provides the primary action and live-status accent. Warm neutral grounds,
dark introductory panels, white cards, and subdued metadata continue the public
site's established palette. The frontmatter records Events' exact values.

Pricing uses a gradient warm ground rather than Events' solid warm-white ground,
and a near-black gradient rather than Events' solid charcoal panel. Its gold
eyebrows and metallic table marks are existing details, not a new secondary
palette. Events uses small gold-toned labels and fallback lettering; their varying
values are local treatments, not a consolidated gold token scale.

## Typography

System sans-serif is shared by these public surfaces; no font download is needed.
The display and body roles above describe the Events intro, not all headings or
paragraphs. Its mobile display override is (36px) at widths up to (600px).
Pricing's display is larger, using `clamp(39px,6vw,70px)` with (1.01) line height.
Navigation is compact and bold; event names have stronger hierarchy than venue
and timezone metadata. Both locales retain the same information structure.

## Layout

The public shell, header, and footer share a maximum width of (1120px). Events
uses horizontal page padding of (20px), reducing to (12px) at (600px). The intro
has two equal columns and stacks on mobile. Its schedule grid moves from three
columns to two at (1000px), then one at (600px). Category controls become a
horizontally scrollable row on mobile. The shared header keeps Pricing,
Membership, Events, and language switching visible rather than introducing a new
navigation pattern; the brand descriptor hides at (520px). The footer stacks at
(640px). Pricing has its own (760px) and (390px) adjustments.

## Elevation & Depth

Events cards are flat at rest, separated with fine borders, and lift (3px) on
hover with a (180ms ease-out) transition. Reduced-motion preference removes that
lift and transition. The featured campaign image uses a dark overlay for legible
text. Pricing already has gradients and diffuse hero/section shadows; those
remain unchanged. Neither flatness nor Pricing's heavier elevation is imposed as
a new site-wide rule.

## Shapes

Events uses gently rounded controls, clipped event cards, and a larger rounded
intro, as recorded in frontmatter. The intro reduces to (24px) on mobile. Pricing
has a broader local radius vocabulary, including (14px) action links, a (34px)
hero, and (30px) section containers. This variation is documented, not normalized.

## Components

The shared header supplies the existing SVG logo, public links, locale toggle,
and active-link tint; the shared footer supplies club/contact/legal links.
Reuse these components rather than creating Events-specific replacements.

Events' primary link is red with white text. Native venue selection and category
buttons use white, bordered surfaces; the selected category is charcoal with
white text and an `aria-pressed` state. Event cards are whole-card links to the
existing detail flow, with cropped campaign imagery, status, name, local date,
venue/timezone, and explicit fee currency. Loading, empty, retry, and missing-image
states retain the same shell. Events supplies a red (3px) keyboard focus outline
with a (4px) offset.

Campaign imagery is data-supplied, not a new global art direction. See the surface
brief for provenance and fallback behavior. The sidecar previews representative
source-extracted primitives; it does not replace the Vue components.

## Do's and Don'ts

- Do retain the existing public header/footer, JOY logo, locale behavior, and
  public-site palette when extending this surface.
- Do keep page strategy separate from global visual identity.
- Do check inherited global CSS when evaluating computed control styles.
- Don't apply this public-page record to management, account, or payment screens.
- Don't interpret Pricing's gradient/shadow vocabulary or existing radius
  variation as approval to restyle either page.
- Don't replace campaign assets, fabricate event imagery or availability, or
  claim an unverified image license.

Known incumbent gap: the public pages use local literals while
`src/assets/styles/main.css` contains a separate blue/purple management-oriented
palette, broad element rules, and global focus effects. There is no single
centralized public token implementation. This documentation records the gap;
it does not canonize every inherited effect or authorize a global CSS cleanup.
