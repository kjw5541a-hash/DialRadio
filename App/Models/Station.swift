import Foundation

// Radio Browser API 응답 매핑 (https://api.radio-browser.info)
struct Station: Codable, Identifiable, Hashable {
    let id: String          // stationuuid
    let name: String
    let streamUrl: URL      // url_resolved
    let faviconUrl: URL?
    let country: String
    let tags: [String]
    let bitrate: Int
    let lastCheckOk: Bool

    enum CodingKeys: String, CodingKey {
        case id = "stationuuid"
        case name
        case streamUrl = "url_resolved"
        case faviconUrl = "favicon"
        case country
        case tags
        case bitrate
        case lastCheckOk = "lastcheckok"
    }
}
