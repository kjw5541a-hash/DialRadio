import Foundation

// API 연동 전 UI 테스트용 하드코딩 샘플
extension Station {
    static let samples: [Station] = [
        Station(id: "kbs-1fm", name: "KBS 1FM 클래식", streamUrl: URL(string: "https://cdn.kbs.co.kr/kbs1fm.stream")!,
                faviconUrl: nil, country: "South Korea", tags: ["classical", "kbs"], bitrate: 128, lastCheckOk: true),
        Station(id: "bbc-radio1", name: "BBC Radio 1", streamUrl: URL(string: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_one")!,
                faviconUrl: nil, country: "United Kingdom", tags: ["pop", "bbc"], bitrate: 128, lastCheckOk: true),
        Station(id: "nhk-radio1", name: "NHK Radio 1", streamUrl: URL(string: "https://radio-stream.nhk.jp/hls/live/2023516/nhkradiruakr1/master.m3u8")!,
                faviconUrl: nil, country: "Japan", tags: ["talk", "nhk"], bitrate: 96, lastCheckOk: true),
        Station(id: "fip-radio", name: "FIP", streamUrl: URL(string: "https://icecast.radiofrance.fr/fip-hifi.aac")!,
                faviconUrl: nil, country: "France", tags: ["eclectic", "music"], bitrate: 192, lastCheckOk: true),
        Station(id: "swiss-jazz", name: "Radio Swiss Jazz", streamUrl: URL(string: "https://stream.srg-ssr.ch/m/rsj/mp3_128")!,
                faviconUrl: nil, country: "Switzerland", tags: ["jazz"], bitrate: 128, lastCheckOk: true),
    ]
}
