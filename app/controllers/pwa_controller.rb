class PwaController < ApplicationController
  skip_before_action :authenticate_user!

  # PWA endpoints (`/service-worker.js`, `/manifest.webmanifest`) serve
  # public content with zero sensitive data, and MUST be readable in a
  # cross-origin context:
  #
  # - `/service-worker.js` is fetched by the browser's built-in Service
  #   Worker update mechanism, not by user-facing JavaScript. That fetch
  #   carries no `X-Requested-With: XMLHttpRequest` header and has no
  #   session tied to the calling page. Rails' default
  #   `protect_from_forgery` therefore treats it as a cross-origin JS
  #   load and raises `ActionController::InvalidCrossOriginRequest`,
  #   which the default handler maps to 422. That was the root cause of
  #   CI failing 5 times on PR #49 before this fix.
  # - `/manifest.webmanifest` is fetched by browsers, crawlers and OS
  #   app stores with the same bare headers.
  #
  # Disabling forgery protection on this controller is safe because no
  # action here performs any state-changing operation and no action
  # returns anything user-specific. It is exactly the stance Rails
  # recommends for publicly cacheable endpoints.
  skip_forgery_protection

  # Kamikaze Service Worker body (D1 / fix/sw-kamikaze)
  #
  # Inlined as a frozen Ruby constant rather than served from
  # app/views/pwa/service-worker.js. Rails 8's template resolver for
  # paths under app/views post-processes content and can strip custom
  # headers, which bit us twice in CI on PR #49. A constant loaded once
  # at class boot time gives us deterministic bytes and keeps the
  # controller test honest.
  #
  # What the kamikaze does:
  #   1. `install` → skipWaiting, take control without waiting for tabs
  #      to close.
  #   2. `activate` → delete every Cache Storage bucket, unregister
  #      itself (freeing the "/" scope), then force every open window
  #      client to reload straight from the network.
  #   3. No `fetch` handler on purpose: with no listener, the browser
  #      routes every request to the network, zero interception while
  #      the cleanup is in flight.
  #
  # The Rails-level `Clear-Site-Data: "cache", "storage"` header set in
  # #service_worker is the belt to the kamikaze's braces: supported
  # browsers wipe HTTP cache, Cache Storage AND Service Worker
  # registrations on receipt of this response. Cookies are deliberately
  # preserved (no `"cookies"` directive) so users stay signed in.
  #
  # When we reintroduce a real PWA, replace this constant with a proper
  # worker and restore navigator.serviceWorker.register(...) in the
  # layout. See the ERB comment in app/views/layouts/application.html.erb.
  KAMIKAZE_SERVICE_WORKER = <<~JS.freeze
    // Kamikaze Service Worker — D1 / fix/sw-kamikaze
    // This worker exists only to uninstall any previous Service Worker
    // (notably the legacy FlowMotor PWA worker that early veratrade.fr
    // visitors still have registered) and to wipe their Cache Storage.
    // Do NOT add a fetch handler — requests must pass straight to the
    // network while the cleanup is in flight.

    self.addEventListener("install", () => {
      self.skipWaiting();
    });

    self.addEventListener("activate", (event) => {
      event.waitUntil((async () => {
        // 1. Nuke every Cache Storage bucket on this origin.
        const cacheKeys = await caches.keys();
        await Promise.all(cacheKeys.map((key) => caches.delete(key)));

        // 2. Unregister this worker, freeing the "/" scope.
        await self.registration.unregister();

        // 3. Force every open tab on this origin to reload so they
        //    fetch HTML straight from the network, no SW in the middle.
        const windowClients = await self.clients.matchAll({
          type: "window",
          includeUncontrolled: true
        });
        await Promise.all(
          windowClients.map((client) => {
            try {
              return client.navigate(client.url);
            } catch (_err) {
              return Promise.resolve();
            }
          })
        );
      })());
    });
  JS

  def manifest
    render file: Rails.root.join("app/views/pwa/manifest.json.erb"),
           content_type: "application/manifest+json"
  end

  def service_worker
    # Clear-Site-Data wipes HTTP cache, Cache Storage AND Service Worker
    # registrations (but not cookies) on every supporting browser when
    # it fetches this response. Combined with the kamikaze body below,
    # this evicts the legacy FlowMotor worker from early visitors.
    headers["Clear-Site-Data"] = '"cache", "storage"'
    headers["Cache-Control"] = "no-store, max-age=0"
    headers["Service-Worker-Allowed"] = "/"

    render plain: KAMIKAZE_SERVICE_WORKER, content_type: "text/javascript"
  end

  def offline; end
end
