import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import {
  eventAppRoute,
  eventSharePath,
  eventRegistrationState,
  safeEventBanner,
  EVENT_REFERENCE,
} from "../src/utils/eventShare.js";
const id = "d02b933c-6491-4fbb-846f-29a788c8ace6";
test("sharing uses one canonical event path and strips checkout tracking", () => {
  assert.equal(
    eventSharePath({ id, share_code: "04FDEEEE" }),
    "/app/e/04FDEEEE",
  );
  assert.equal(eventSharePath({ id }), `/app/event/${id}`);
  assert.equal(eventSharePath({ id: "evil" }), null);
  assert.equal(EVENT_REFERENCE.test("foo,venue_id.eq.zz"), false);
});
test("checkout return preserves a validated reference but cannot mark an entry paid", () => {
  assert.equal(
    eventAppRoute(id, {
      payment: "success",
      checkout_session_id: "cs_live_0123456789abcdef",
    }),
    `/tournament/${id}?entrySource=share&entryAction=register&payment=success&checkoutSessionId=cs_live_0123456789abcdef`,
  );
  assert.equal(
    eventAppRoute(id, {
      payment: "success&redirect=evil",
      checkout_session_id: "not-checkout",
    }),
    `/tournament/${id}?entrySource=share&entryAction=register`,
  );
  assert.equal(eventAppRoute("evil"), "/login");
});
test("registration reflects actual status, capacity and deadline", () => {
  const event = { status: "registration", max_players: 16 };
  assert.equal(eventRegistrationState(event, {}, 16), "full");
  assert.equal(
    eventRegistrationState(event, { registrationClosesAt: "2020-01-01" }, 2),
    "closed",
  );
  assert.equal(
    eventRegistrationState(event, { registrationOpensAt: "2099-01-01" }, 2),
    "soon",
  );
  assert.equal(
    eventRegistrationState({ status: "in_progress" }, {}, 0),
    "live",
  );
  assert.equal(eventRegistrationState(event, null, null), "open");
});
test("only HTTPS poster assets are accepted", () => {
  assert.equal(safeEventBanner("javascript:alert(1)"), "");
  assert.equal(safeEventBanner("http://example.com/a.png"), "");
  assert.equal(
    safeEventBanner("https://example.com/a.png"),
    "https://example.com/a.png",
  );
});
test("website handles short links, event-return registration and does not read private rosters", async () => {
  const [router, page, signup, verify] = await Promise.all(
    [
      "../src/router/index.js",
      "../src/views/TournamentEntrySharePage.vue",
      "../src/views/AppInviteRegisterPage.vue",
      "../src/views/EmailVerificationPage.vue",
    ].map((p) => readFile(new URL(p, import.meta.url), "utf8")),
  );
  assert.match(router, /path: '\/app\/e\/:reference'/);
  assert.match(page, /venue\.timezone/);
  assert.doesNotMatch(page, /from\('tournament_registrations'\)/);
  assert.doesNotMatch(page, /HAMILTON CENTRAL|NZ\$/);
  assert.match(
    signup,
    /registration_venue_source: eventVenue\.value \? 'event_share'/,
  );
  assert.match(signup, /verify-email\?event=/);
  assert.match(verify, /window\.location\.pathname \+ \(requestedEvent/);
});
