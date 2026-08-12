import Foundation

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var favorites: [Favorite] = []
    @Published private(set) var lastPlayed: String?

    private let sync = ICloudSyncManager()

    init() {
        let doc = sync.load()
        favorites = doc.favorites
        lastPlayed = doc.lastPlayed
    }

    func isFavorite(_ stationId: String) -> Bool {
        favorites.contains { $0.stationId == stationId }
    }

    func add(stationId: String) {
        guard !isFavorite(stationId) else { return }
        favorites.append(Favorite(stationId: stationId, addedAt: Date()))
        persist()
    }

    // tombstone 없이 목록에서 필터링
    func remove(stationId: String) {
        favorites.removeAll { $0.stationId == stationId }
        persist()
    }

    // TODO: PlayerStore.play(id:) 호출 시점에 연결
    func markPlayed(_ stationId: String) {
        lastPlayed = stationId
        persist()
    }

    private func persist() {
        sync.save(FavoritesDocument(updatedAt: Date(), favorites: favorites, lastPlayed: lastPlayed))
    }
}
