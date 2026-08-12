const RADIO_HOSTS = [
  "de1.api.radio-browser.info",
  "at1.api.radio-browser.info",
  "fr1.api.radio-browser.info",
];

const audio = document.getElementById("audio");
const stationListEl = document.getElementById("station-list");
const countryFilterEl = document.getElementById("country-filter");
const searchEl = document.getElementById("search");
const playPauseBtn = document.getElementById("play-pause-btn");
const playerStationName = document.getElementById("player-station-name");
const tabButtons = document.querySelectorAll(".tabs button");

let stations = [];
let selectedCountry = null;
let currentTab = "list";
let currentStation = null;

// ---- 즐겨찾기 (localStorage, station 전체 저장) ----
function getFavorites() {
  return JSON.parse(localStorage.getItem("favorites") || "[]");
}

function isFavorite(id) {
  return getFavorites().some((s) => s.id === id);
}

function toggleFavorite(station) {
  const favs = getFavorites();
  const idx = favs.findIndex((s) => s.id === station.id);
  if (idx >= 0) {
    favs.splice(idx, 1);
  } else {
    favs.push({ ...station, addedAt: new Date().toISOString() });
  }
  localStorage.setItem("favorites", JSON.stringify(favs));
  render();
}

// ---- Radio Browser API — 3서버 fallback ----
async function fetchFromApi(path, params = {}) {
  const query = new URLSearchParams(params).toString();
  let lastError;
  for (const host of RADIO_HOSTS) {
    try {
      const res = await fetch(`https://${host}${path}?${query}`, {
        headers: { "User-Agent": "DialRadio" },
      });
      if (!res.ok) throw new Error(`status ${res.status}`);
      return await res.json();
    } catch (e) {
      lastError = e;
    }
  }
  throw lastError;
}

function mapStation(raw) {
  return {
    id: raw.stationuuid,
    name: raw.name,
    streamUrl: raw.url_resolved,
    faviconUrl: raw.favicon || "",
    country: raw.country,
    bitrate: raw.bitrate,
  };
}

async function loadTopStations() {
  const raw = await fetchFromApi("/json/stations/topclick/50");
  stations = raw.map(mapStation);
  render();
}

async function searchStations(name) {
  if (!name) return loadTopStations();
  const raw = await fetchFromApi("/json/stations/search", { name, limit: 50 });
  stations = raw.map(mapStation);
  render();
}

// ---- 재생 ----
const playIcon = document.getElementById("play-icon");
const pauseIcon = document.getElementById("pause-icon");

function setPlayIcon(isPlaying) {
  playIcon.hidden = isPlaying;
  pauseIcon.hidden = !isPlaying;
}

function play(station) {
  currentStation = station;
  audio.src = station.streamUrl;
  audio.play();
  setPlayIcon(true);
  playerStationName.textContent = station.name;
  render();
}

playPauseBtn.addEventListener("click", () => {
  if (!currentStation) return;
  if (audio.paused) {
    audio.play();
    setPlayIcon(true);
  } else {
    audio.pause();
    setPlayIcon(false);
  }
});

// ---- 렌더링 ----
function render() {
  const source = currentTab === "favorites" ? getFavorites() : stations;
  const filtered = selectedCountry
    ? source.filter((s) => s.country === selectedCountry)
    : source;

  stationListEl.innerHTML = "";
  filtered.forEach((station) => {
    const li = document.createElement("li");

    const img = document.createElement("img");
    img.src = station.faviconUrl || "icons/icon-192.png";
    img.loading = "lazy";

    const info = document.createElement("div");
    info.className = "station-info";
    info.innerHTML = `<div class="name">${station.name}</div><div class="meta">${station.country} · ${station.bitrate}kbps</div>`;
    info.addEventListener("click", () => play(station));

    const favBtn = document.createElement("button");
    favBtn.className = "fav-btn" + (isFavorite(station.id) ? " active" : "");
    favBtn.textContent = isFavorite(station.id) ? "★" : "☆";
    favBtn.addEventListener("click", (e) => {
      e.stopPropagation();
      toggleFavorite(station);
    });

    li.append(img, info, favBtn);
    stationListEl.append(li);
  });

  renderCountryChips(source);
}

function renderCountryChips(source) {
  const countries = [...new Set(source.map((s) => s.country))].filter(Boolean).sort();
  countryFilterEl.innerHTML = "";

  const allBtn = document.createElement("button");
  allBtn.textContent = "전체";
  allBtn.className = selectedCountry === null ? "active" : "";
  allBtn.addEventListener("click", () => { selectedCountry = null; render(); });
  countryFilterEl.append(allBtn);

  countries.forEach((country) => {
    const btn = document.createElement("button");
    btn.textContent = country;
    btn.className = selectedCountry === country ? "active" : "";
    btn.addEventListener("click", () => { selectedCountry = country; render(); });
    countryFilterEl.append(btn);
  });
}

// ---- 탭 ----
tabButtons.forEach((btn) => {
  btn.addEventListener("click", () => {
    tabButtons.forEach((b) => b.classList.remove("active"));
    btn.classList.add("active");
    currentTab = btn.dataset.tab;
    selectedCountry = null;
    render();
  });
});

// ---- 검색 ----
let searchDebounce;
searchEl.addEventListener("input", () => {
  clearTimeout(searchDebounce);
  searchDebounce = setTimeout(() => searchStations(searchEl.value.trim()), 400);
});

// ---- PWA 서비스워커 등록 ----
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("sw.js");
}

loadTopStations();
