import Foundation

// iCloud Drive: /MyRadio/favorites.json
struct FavoritesDocument: Codable {
    var updatedAt: Date
    var favorites: [Favorite]
    var lastPlayed: String?
}
