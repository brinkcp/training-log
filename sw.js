/* Minimal offline support: the page must open at the gym even with no signal.
   Network-first so a republished page or program is picked up as soon as there's
   a connection, with the cache as fallback when there isn't.
   Bump CACHE when you change index.html and want clients to drop the old copy. */

const CACHE = "training-log-v3";
const SHELL = ["./", "./index.html", "./program.json"];

self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(CACHE)
      .then(c => c.addAll(SHELL))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", event => {
  const { request } = event;
  if(request.method !== "GET" || new URL(request.url).origin !== location.origin) return;

  // cache:"no-store" bypasses the *HTTP* cache. Without it, GitHub Pages' 10
  // minute max-age on HTML meant a freshly published page or program could keep
  // serving the old copy even with a connection. The app is ~30 KB, so always
  // asking the network is cheap, and the SW cache below still covers offline.
  event.respondWith(
    fetch(new Request(request, { cache:"no-store" }))
      .then(response => {
        if(response && response.ok){
          const copy = response.clone();
          caches.open(CACHE).then(c => c.put(request, copy));
        }
        return response;
      })
      .catch(() => caches.match(request).then(hit => hit || caches.match("./index.html")))
  );
});
