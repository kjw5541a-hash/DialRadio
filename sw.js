const VERSION = "1786517933"; // pre-commit 훅이 커밋 시각으로 자동 치환
const CACHE_NAME = `dialradio-${VERSION}`;
const APP_SHELL = ["./", "index.html", "style.css", "app.js", "manifest.json"];

self.addEventListener("install", (event) => {
  self.skipWaiting(); // 새 SW를 대기 없이 바로 설치
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL))
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k))))
      .then(() => self.clients.claim()) // 열려있는 탭도 바로 새 SW가 제어
  );
});

self.addEventListener("fetch", (event) => {
  // 앱 셸만 캐시. API/스트림 요청은 항상 네트워크로.
  if (event.request.url.includes("api.radio-browser.info")) return;

  event.respondWith(
    caches.match(event.request).then((cached) => cached || fetch(event.request))
  );
});
