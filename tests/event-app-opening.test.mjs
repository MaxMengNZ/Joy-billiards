import assert from "node:assert/strict";
import test from "node:test";
import { openAppRouteWithDownloadFallback } from "../src/utils/appDownload.js";
import { eventAppRoute } from "../src/utils/eventShare.js";

test("WeChat keeps the event context rather than forcing a blocked app/store link", () => {
  const nav = Object.getOwnPropertyDescriptor(globalThis, "navigator");
  const win = Object.getOwnPropertyDescriptor(globalThis, "window");
  try {
    Object.defineProperty(globalThis, "navigator", {
      configurable: true,
      value: { userAgent: "iPhone MicroMessenger" },
    });
    Object.defineProperty(globalThis, "window", {
      configurable: true,
      value: { location: { href: "/app/event/original" } },
    });
    assert.equal(openAppRouteWithDownloadFallback("/login", "ios"), false);
    assert.equal(window.location.href, "/app/event/original");
  } finally {
    if (nav) Object.defineProperty(globalThis, "navigator", nav);
    else delete globalThis.navigator;
    if (win) Object.defineProperty(globalThis, "window", win);
    else delete globalThis.window;
  }
});
test("Android forwards a safe checkout reference to the event, not a new payment", () => {
  const nav = Object.getOwnPropertyDescriptor(globalThis, "navigator");
  const win = Object.getOwnPropertyDescriptor(globalThis, "window");
  try {
    Object.defineProperty(globalThis, "navigator", {
      configurable: true,
      value: { userAgent: "Android" },
    });
    Object.defineProperty(globalThis, "window", {
      configurable: true,
      value: { location: { href: "" } },
    });
    const path = eventAppRoute("d02b933c-6491-4fbb-846f-29a788c8ace6", {
      payment: "success",
      checkout_session_id: "cs_live_0123456789abcdef",
    });
    assert.equal(openAppRouteWithDownloadFallback(path, "android"), true);
    assert.match(
      window.location.href,
      /payment=success&checkoutSessionId=cs_live_0123456789abcdef/,
    );
    assert.match(window.location.href, /package=nz.co.joybilliards.app/);
  } finally {
    if (nav) Object.defineProperty(globalThis, "navigator", nav);
    else delete globalThis.navigator;
    if (win) Object.defineProperty(globalThis, "window", win);
    else delete globalThis.window;
  }
});
