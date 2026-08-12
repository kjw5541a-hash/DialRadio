// Scriptable 위젯 — 무료 계정 WidgetKit 불가 우회.
// iCloud Drive가 유일한 IPC: 앱이 쓴 /MyRadio/favorites.json을 여기서 읽음.
// 위젯 탭 시 오디오 직접 재생 불가 → myradio:// 딥링크로 앱 핸드오프.

const fm = FileManager.iCloud()
const scriptableDir = fm.documentsDirectory() // .../iCloud Drive/Scriptable
const iCloudDriveRoot = fm.joinPath(scriptableDir, "..")
const favoritesPath = fm.joinPath(iCloudDriveRoot, "MyRadio/favorites.json")

function loadFavorites() {
  try {
    if (!fm.fileExists(favoritesPath)) return { favorites: [], lastPlayed: null }
    if (!fm.isFileDownloaded(favoritesPath)) fm.downloadFileFromiCloud(favoritesPath)
    const raw = fm.readString(favoritesPath)
    return JSON.parse(raw)
  } catch (e) {
    return { favorites: [], lastPlayed: null }
  }
}

function deepLink(stationId) {
  return `myradio://play?id=${encodeURIComponent(stationId)}`
}

function buildSmallWidget(doc, widget) {
  // 마지막 재생, 없으면 즐겨찾기 1번째
  const stationId = doc.lastPlayed || (doc.favorites[0] && doc.favorites[0].stationId)
  widget.url = stationId ? deepLink(stationId) : undefined

  const title = widget.addText("DialRadio")
  title.font = Font.mediumSystemFont(12)
  title.textColor = Color.gray()

  widget.addSpacer(6)
  const label = widget.addText(stationId ? `▶ ${stationId}` : "즐겨찾기 없음")
  label.font = Font.boldSystemFont(15)
}

function buildMediumWidget(doc, widget) {
  const title = widget.addText("DialRadio")
  title.font = Font.mediumSystemFont(12)
  title.textColor = Color.gray()
  widget.addSpacer(6)

  const presets = doc.favorites.slice(0, 3)
  if (presets.length === 0) {
    widget.addText("즐겨찾기 없음")
    return
  }

  const row = widget.addStack()
  row.layoutHorizontally()

  presets.forEach((fav, i) => {
    if (i > 0) row.addSpacer(8)
    const stack = row.addStack()
    stack.layoutVertically()
    stack.url = deepLink(fav.stationId) // 개별 프리셋 탭 → 해당 스테이션 재생
    stack.cornerRadius = 8
    stack.backgroundColor = fav.stationId === doc.lastPlayed ? Color.gray().withAlpha(0.2) : Color.clear()

    const playing = fav.stationId === doc.lastPlayed ? "● " : ""
    const text = stack.addText(`${playing}${fav.stationId}`)
    text.font = Font.systemFont(13)
  })
}

async function run() {
  const doc = loadFavorites()
  const widget = new ListWidget()
  widget.backgroundColor = Color.black()

  const family = config.widgetFamily
  if (family === "medium") {
    buildMediumWidget(doc, widget)
  } else {
    // small, 또는 앱 내 미리보기 기본값
    buildSmallWidget(doc, widget)
  }

  if (config.runsInWidget) {
    Script.setWidget(widget)
  } else {
    await widget.presentSmall()
  }
  Script.complete()
}

await run()
