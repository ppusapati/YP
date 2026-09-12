// YieldPoint Service Worker
// Cache-first for static assets, network-first for API calls.

const CACHE_VERSION = 'yp-cache-v1';

const STATIC_ASSETS = [
  '/',
  '/manifest.json',
  '/icons/icon-192x192.png',
  '/icons/icon-512x512.png',
];

// Patterns that identify API requests (network-first).
const API_PATTERNS = [
  '/api/',
  '/connect/',
  '/grpc/',
];

// ---------------------------------------------------------------------------
// Install — pre-cache static assets
// ---------------------------------------------------------------------------

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(CACHE_VERSION)
      .then((cache) => cache.addAll(STATIC_ASSETS))
      .then(() => self.skipWaiting())
  );
});

// ---------------------------------------------------------------------------
// Activate — clean up old caches
// ---------------------------------------------------------------------------

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) =>
      Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_VERSION)
          .map((name) => caches.delete(name))
      )
    ).then(() => self.clients.claim())
  );
});

// ---------------------------------------------------------------------------
// Fetch — route requests to the appropriate strategy
// ---------------------------------------------------------------------------

self.addEventListener('fetch', (event) => {
  const { request } = event;

  // Skip non-GET requests (mutations should always go to the network).
  if (request.method !== 'GET') return;

  // API calls use network-first.
  if (isApiRequest(request.url)) {
    event.respondWith(networkFirst(request));
    return;
  }

  // Everything else (static assets, pages) uses cache-first.
  event.respondWith(cacheFirst(request));
});

// ---------------------------------------------------------------------------
// Strategies
// ---------------------------------------------------------------------------

/**
 * Cache-first: serve from cache if available, otherwise fetch from the
 * network and cache the response for next time.
 */
async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) return cached;

  try {
    const response = await fetch(request);

    // Only cache successful, same-origin responses.
    if (response.ok && response.type === 'basic') {
      const cache = await caches.open(CACHE_VERSION);
      cache.put(request, response.clone());
    }

    return response;
  } catch {
    // If both cache and network fail, return a basic offline fallback.
    return new Response('Offline', {
      status: 503,
      statusText: 'Service Unavailable',
      headers: { 'Content-Type': 'text/plain' },
    });
  }
}

/**
 * Network-first: try the network, fall back to cache. API responses are
 * cached so that previously-fetched data is available offline.
 */
async function networkFirst(request) {
  try {
    const response = await fetch(request);

    // Cache successful API responses for offline fallback.
    if (response.ok) {
      const cache = await caches.open(CACHE_VERSION);
      cache.put(request, response.clone());
    }

    return response;
  } catch {
    // Network failed — try the cache.
    const cached = await caches.match(request);
    if (cached) return cached;

    return new Response(
      JSON.stringify({ error: 'offline', message: 'No cached data available' }),
      {
        status: 503,
        statusText: 'Service Unavailable',
        headers: { 'Content-Type': 'application/json' },
      }
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Returns true if the URL matches any of the API path patterns.
 */
function isApiRequest(url) {
  const path = new URL(url).pathname;
  return API_PATTERNS.some((pattern) => path.startsWith(pattern));
}
