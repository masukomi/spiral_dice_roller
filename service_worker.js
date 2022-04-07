const cacheName = "spiralDiceRollerCache-v2";
const assets = [
    "spiral_dice_roller.html"
];

self.addEventListener('install', function() {
    console.log('Install!');
    event.waitUntil(
        caches
            .open(cacheName)
            .then(cache => {
                return cache.addAll(assets);
            })
            .catch(err => console.log(err))
    );
});
self.addEventListener("activate", event => {
    console.log('Activate!');
});
self.addEventListener('fetch', event => {
  console.log('Fetch intercepted for:', event.request.url);
  event.respondWith(caches.match(event.request)
    .then(cachedResponse => {
        if (cachedResponse) {
          return cachedResponse;
        }
        return fetch(event.request);
      })
    );
});
