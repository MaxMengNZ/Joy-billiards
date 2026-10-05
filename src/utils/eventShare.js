export const EVENT_UUID =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
export const EVENT_REFERENCE = /^[a-z0-9][a-z0-9-]{2,46}[a-z0-9]$/i;

export function publicEventCounts(data) {
  const count = (value) =>
    typeof value === 'number' && Number.isSafeInteger(value) && value >= 0
      ? value : null;
  return {
    confirmedCount: count(data?.confirmedCount),
    pendingCount: count(data?.pendingCount),
    waitlistedCount: count(data?.waitlistedCount),
  };
}

export function eventSharePath(event) {
  if (!EVENT_UUID.test(event?.id || "")) return null;
  const reference = event.share_alias || event.share_code;
  return EVENT_REFERENCE.test(reference || "")
    ? `/app/e/${reference}`
    : `/app/event/${event.id}`;
}

export function eventAppRoute(id, query = {}) {
  if (!EVENT_UUID.test(id)) return "/login";
  const params = new URLSearchParams({
    entrySource: "share",
    entryAction: "register",
  });
  if (query.payment === "success" || query.payment === "cancelled")
    params.set("payment", query.payment);
  // Only forward a validated Checkout reference; never treat the URL as proof of payment.
  if (
    /^cs_(?:test_|live_)?[a-z0-9]{10,240}$/i.test(
      query.checkout_session_id || "",
    )
  ) {
    params.set("checkoutSessionId", query.checkout_session_id);
  }
  return `/tournament/${id}?${params}`;
}

export function eventRegistrationState(event, entry, count, now = Date.now()) {
  if (event?.status === "in_progress") return "live";
  if (event?.status === "completed") return "completed";
  if (!["registration", "upcoming"].includes(event?.status)) return "closed";
  if (
    entry?.registrationClosesAt &&
    Date.parse(entry.registrationClosesAt) <= now
  )
    return "closed";
  if (entry?.registrationOpensAt && Date.parse(entry.registrationOpensAt) > now)
    return "soon";
  if (event?.max_players && count != null && count >= event.max_players)
    return "full";
  return "open";
}

export function safeEventBanner(value) {
  try {
    const url = new URL(value);
    return url.protocol === "https:" ? url.href : "";
  } catch {
    return "";
  }
}
