// Kamikaze Service Worker — D1 / fix/sw-kamikaze
//
// WHY THIS EXISTS
// ---------------
// Before `veratrade.fr` was rewired to serve Vera Trade, the domain served
// FlowMotor, which shipped a PWA Service Worker registered at scope "/".
// That worker got cached in every visitor's browser and keeps intercepting
// requests for `veratrade.fr`, so early testers can still land on a stale
// FlowMotor page even though the backend now serves Vera Trade.
//
// This file replaces the previous cache-first worker with a minimal
// "suicide" worker whose only job is to:
//
//   1. Delete every Cache Storage bucket created by any previous worker
//      (FlowMotor-era or Vera Trade M1 cache-first versions).
//   2. Unregister itself, which frees the "/" scope for the browser.
//   3. Force every open client tab to reload so the user sees the real
//      Vera Trade HTML served directly from the network — no SW in the way.
//
// The Rails controller (`PwaController#service_worker`) additionally sets
// `Clear-Site-Data: "cache", "storage"` on this response, which instructs
// modern browsers to wipe HTTP cache, Cache Storage, and Service Worker
// registrations for the origin. Between the HTTP header and this script,
// any visitor whose browser still talks to /service-worker.js will be
// cleaned up on their next SW update check.
//
// IMPORTANT: the layout (`application.html.erb`) no longer calls
// `navigator.serviceWorker.register(...)`. That means new tabs never
// install this worker again. Combined with the kamikaze activate step,
// the whole scope goes clean and stays clean.
//
// TO RE-ENABLE PWA LATER
// ----------------------
// When we actually want a PWA (offline fallback, installable shell, push
// notifications), we will:
//   - restore the `navigator.serviceWorker.register("/service-worker.js")`
//     block in the layout
//   - replace this kamikaze body with the real worker (network-first HTML,
//     cache-first images, etc.)
//   - drop the Clear-Site-Data header from PwaController#service_worker
//
// Until then, this file stays intentionally boring.

self.addEventListener("install", () => {
  // Skip the standard "waiting" phase so the new worker takes control
  // immediately instead of waiting for all existing tabs to close.
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    (async () => {
      // 1. Nuke every Cache Storage bucket on this origin.
      const cacheKeys = await caches.keys();
      await Promise.all(cacheKeys.map((key) => caches.delete(key)));

      // 2. Unregister this worker. Once no client is controlled by us,
      //    the scope "/" becomes SW-free.
      await self.registration.unregister();

      // 3. Force every open tab/window on this origin to reload. Because
      //    the registration is already marked for removal, the reload
      //    fetches HTML straight from the network — no SW interception.
      const windowClients = await self.clients.matchAll({
        type: "window",
        includeUncontrolled: true
      });
      await Promise.all(
        windowClients.map((client) => {
          try {
            return client.navigate(client.url);
          } catch (_err) {
            // Some browsers throw on cross-origin or detached clients.
            // Silently ignore — the next manual refresh will pick up
            // the clean state.
            return Promise.resolve();
          }
        })
      );
    })()
  );
});

// No `fetch` handler on purpose: with no fetch listener registered, the
// browser routes every request directly to the network, which is exactly
// what we want while the old FlowMotor ghost is being exorcised.
