/*
 * The deployment script replaces __PWA_CACHE_VERSION__ for every release.
 * Core HTML stays network-first to discover new versions promptly; the large
 * Flutter JavaScript and CanvasKit files are cached as they are used.
 */
const CACHE_NAME = 'betterwaifu-pwa-__PWA_CACHE_VERSION__';
const APP_SHELL = [
  './',
  './index.html',
  './flutter_bootstrap.js',
  './manifest.json',
  './icons/icon.svg',
];

const isSameOriginGet = (request) =>
  request.method === 'GET' && new URL(request.url).origin === self.location.origin;

const isReleaseCheckRequest = (request) => {
  const url = new URL(request.url);
  return request.mode === 'navigate' ||
      url.pathname.endsWith('/index.html') ||
      url.pathname.endsWith('/flutter_bootstrap.js') ||
      url.pathname.endsWith('/pwa_cache_worker.js') ||
      url.pathname.endsWith('/version.json');
};

const cacheResponse = async (request, response) => {
  if (!response || !response.ok || response.type !== 'basic') return response;
  const cache = await caches.open(CACHE_NAME);
  await cache.put(request, response.clone());
  return response;
};

const networkFirst = async (request) => {
  try {
    return await cacheResponse(request, await fetch(request));
  } catch (_) {
    return (await caches.match(request)) || Response.error();
  }
};

const cacheFirst = async (request, event) => {
  const cached = await caches.match(request);
  if (cached) {
    // Keep a warm cache current without holding up the active page.
    event.waitUntil(
      fetch(request).then((response) => cacheResponse(request, response)).catch(() => {}),
    );
    return cached;
  }
  return networkFirst(request);
};

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(APP_SHELL))
      .catch(() => {})
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys
          .filter((key) => key.startsWith('betterwaifu-pwa-') && key !== CACHE_NAME)
          .map((key) => caches.delete(key)),
      ))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  if (!isSameOriginGet(event.request)) return;
  if (isReleaseCheckRequest(event.request)) {
    event.respondWith(networkFirst(event.request));
  } else {
    event.respondWith(cacheFirst(event.request, event));
  }
});
