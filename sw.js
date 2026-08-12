const CACHE_NAME = "dialradio-v1";
const APP_SHELL = ["./", "index.html", "style.css", "app.js", "manifest.json"];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL))
  );
});

self.addEventListener("fetch", (event) => {
  // 앱 셸만 캐시. API/스트림 요청은 항상 네트워크로.
  if (event.request.url.includes("api.radio-browser.info")) return;

  event.respondWith(
    caches.match(event.request).then((cached) => cached || fetch(event.request))
  );
});
