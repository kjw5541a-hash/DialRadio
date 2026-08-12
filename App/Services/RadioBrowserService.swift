import Foundation

// https://api.radio-browser.info — 서버 3개 로드밸런싱, 실패 시 다음 서버로 fallback
final class RadioBrowserService {
    private let hosts = ["de1.api.radio-browser.info", "at1.api.radio-browser.info", "fr1.api.radio-browser.info"]
    private let userAgent = "DialRadio"

    private var cache: [String: (stations: [Station], cachedAt: Date)] = [:]
    private let cacheTTL: TimeInterval = 5 * 60 // 5분 메모리 캐시

    func search(name: String, limit: Int = 50) async throws -> [Station] {
        try await fetch(path: "/json/stations/search", query: ["name": name, "limit": "\(limit)"])
    }

    func topStations(limit: Int = 50) async throws -> [Station] {
        try await fetch(path: "/json/stations/topclick/\(limit)", query: [:])
    }

    private func fetch(path: String, query: [String: String]) async throws -> [Station] {
        let cacheKey = path + query.description
        if let cached = cache[cacheKey], Date().timeIntervalSince(cached.cachedAt) < cacheTTL {
            return cached.stations
        }

        var lastError: Error = URLError(.cannotConnectToHost)
        for host in hosts {
            var components = URLComponents()
            components.scheme = "https"
            components.host = host
            components.path = path
            if !query.isEmpty {
                components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
            }
            guard let url = components.url else { continue }

            var request = URLRequest(url: url)
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent") // 없으면 403

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                let stations = try JSONDecoder().decode([Station].self, from: data)
                cache[cacheKey] = (stations, Date())
                return stations
            } catch {
                lastError = error
                continue // 다음 서버로 fallback
            }
        }
        throw lastError
    }
}
