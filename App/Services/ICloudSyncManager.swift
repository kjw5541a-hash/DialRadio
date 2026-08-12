import Foundation

// Scriptable(FileManager.iCloud())이 읽을 수 있도록 iCloud Documents에 favorites.json 저장.
// 주의: Playgrounds 프로젝트 설정에서 iCloud 기능을 켜야 컨테이너가 생성됨(코드로 불가).
final class ICloudSyncManager {
    private let fileName = "favorites.json"

    private var fileURL: URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
            .appendingPathComponent(fileName)
    }

    private var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }

    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    func load() -> FavoritesDocument {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url),
              let doc = try? decoder.decode(FavoritesDocument.self, from: data)
        else {
            return FavoritesDocument(updatedAt: Date(), favorites: [], lastPlayed: nil)
        }
        return doc
    }

    // lastWrite wins — 항상 현재 상태 전체로 덮어씀. 삭제는 tombstone 없이 목록에서 필터링된 상태로 저장.
    func save(_ document: FavoritesDocument) {
        guard let url = fileURL else { return }
        var doc = document
        doc.updatedAt = Date()
        guard let data = try? encoder.encode(doc) else { return }
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? data.write(to: url, options: .atomic)
    }
}
