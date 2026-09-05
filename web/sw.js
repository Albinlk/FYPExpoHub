// FYP Expo Hub — custom caching service worker.
//
// GitHub Pages cannot serve custom Cache-Control headers, so we implement
// the "immutable hashed assets + network-first documents" strategy here:
//
//  - Stale-while-revalidate + long-term cache for the big immutable build
//    artifacts (main.dart.wasm/.mjs/.js, canvaskit/* engines, fonts,
//    offline_fallback.json, icons, manifest, favicon). Each deploy
//    re-stamps {{BUILD_VERSION}} so old versions never collide.
//  - Network-first with cache fallback for the navigation documents
//    (index.html / 404.html) so new releases are picked up immediately,
//    while still booting offline.
//  - Pass-through for everything else (Supabase API traffic etc.).

const BUILD_VERSION = '{{BUILD_VERSION}}';
const DOC_CACHE = 'fyp-docs-v1';
const ASSET_CACHE = `fyp-assets-${BUILD_VERSION}`;

const LONG_CACHED = [
  // App entrypoints + engine
  /\/main\.dart\.(wasm|mjs|js)$/,
  /\/canvaskit\/[^/]+$/,
  /\/flutter\.js$/,
  /\/flutter_bootstrap\.js$/,
  /\/flutter_service_worker\.js$/,
  // Fonts
  /\/fonts\/[^/]+\.woff2$/,
  // Datasets + metadata
  /\/assets\/assets\/data\/[^/]+$/,
  /\/manifest\.json$/,
  /\/favicon\.png$/,
  /\/icons\/[^/]+$/,
];

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      // Remove every asset cache that isn't this build's version.
      const keys = await caches.keys();
      await Promise.all(
        keys
          .filter(
            (k) =>
              k.startsWith('fyp-assets-') &&
              k !== ASSET_CACHE,
          )
          .map((k) => caches.delete(k)),
      );
      await self.clients.claim();
    })(),
  );
});

function isLongCached(url) {
  return LONG_CACHED.some((re) => re.test(url.pathname));
}

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  // Same-origin only; Supabase and third parties handle their own caching.
  if (url.origin !== self.location.origin) return;

  if (isLongCached(url)) {
    // Stale-while-revalidate: serve instantly from cache, refresh in the
    // background.
    event.respondWith(
      (async () => {
        const cache = await caches.open(ASSET_CACHE);
        const cached = await cache.match(request);
        const network = fetch(request)
          .then((response) => {
            if (response && response.ok) cache.put(request, response.clone());
            return response;
          })
          .catch(() => null);
        return cached || (await network) || Response.error();
      })(),
    );
    return;
  }

  if (request.mode === 'navigate') {
    // Network-first for documents: deploys are visible immediately, with a
    // cached fallback when offline.
    event.respondWith(
      (async () => {
        const cache = await caches.open(DOC_CACHE);
        try {
          const response = await fetch(request);
          if (response && response.ok) cache.put(request, response.clone());
          return response;
        } catch (e) {
          const cached = await cache.match(request, { ignoreSearch: true });
          if (cached) return cached;
          // SPA fallback for deep links while offline.
          const index = await cache.match('/index.html', { ignoreSearch: true });
          if (index) return index;
          return Response.error();
        }
      })(),
    );
  }
});
