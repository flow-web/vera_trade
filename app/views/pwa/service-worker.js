const CACHE_VERSION = "vt-v1";
const STATIC_CACHE = `static-${CACHE_VERSION}`;
const PAGES_CACHE = `pages-${CACHE_VERSION}`;
const IMAGES_CACHE = `images-${CACHE_VERSION}`;

const STATIC_ASSETS = [
  "/offline",
  "/icons/icon-192x192.png",
  "/icons/icon-512x512.png"
];

// Install: pre-cache shell
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE).then((cache) => cache.addAll(STATIC_ASSETS))
  );
  self.skipWaiting();
});

// Activate: clean old caches
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((k) => k !== STATIC_CACHE && k !== PAGES_CACHE && k !== IMAGES_CACHE)
          .map((k) => caches.delete(k))
      )
    )
  );
  self.clients.claim();
});

// Fetch strategy
self.addEventListener("fetch", (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip non-GET and cross-origin
  if (request.method !== "GET" || url.origin !== self.location.origin) return;

  // Skip Turbo Stream requests
  if (request.headers.get("Accept")?.includes("text/vnd.turbo-stream.html")) return;

  // Static assets (CSS, JS, fonts) — cache-first
  if (isStaticAsset(url.pathname)) {
    event.respondWith(cacheFirst(request, STATIC_CACHE));
    return;
  }

  // Images — cache-first with 90-day expiry
  if (isImage(url.pathname)) {
    event.respondWith(cacheFirst(request, IMAGES_CACHE));
    return;
  }

  // HTML pages — network-first with offline fallback
  if (request.headers.get("Accept")?.includes("text/html")) {
    event.respondWith(networkFirstWithOffline(request));
    return;
  }
});

// Cache-first: check cache, fallback to network (and update cache)
async function cacheFirst(request, cacheName) {
  const cached = await caches.match(request);
  if (cached) return cached;

  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(cacheName);
      cache.put(request, response.clone());
    }
    return response;
  } catch {
    return new Response("", { status: 503 });
  }
}

// Network-first: try network, cache successful responses, fallback to cache then offline
async function networkFirstWithOffline(request) {
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(PAGES_CACHE);
      cache.put(request, response.clone());
    }
    return response;
  } catch {
    const cached = await caches.match(request);
    if (cached) return cached;
    return caches.match("/offline");
  }
}

function isStaticAsset(pathname) {
  return /\.(css|js|woff2?|ttf|eot)(\?|$)/.test(pathname) ||
         pathname.startsWith("/assets/");
}

function isImage(pathname) {
  return /\.(png|jpg|jpeg|gif|webp|avif|svg|ico)(\?|$)/.test(pathname) ||
         pathname.startsWith("/icons/");
}

// Push notifications (ready for future use)
self.addEventListener("push", async (event) => {
  const { title, options } = await event.data.json();
  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  event.waitUntil(
    self.clients.matchAll({ type: "window" }).then((clientList) => {
      for (const client of clientList) {
        if (new URL(client.url).pathname === event.notification.data?.path && "focus" in client) {
          return client.focus();
        }
      }
      if (self.clients.openWindow) {
        return self.clients.openWindow(event.notification.data?.path || "/");
      }
    })
  );
});
