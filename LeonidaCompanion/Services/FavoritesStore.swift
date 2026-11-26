import Foundation

/// Favorites / bookmarks across all domains, persisted locally in
/// UserDefaults as a plain list of record IDs. Simple, reviewable,
/// no account, no sync in v1.
@MainActor
final class FavoritesStore: ObservableObject {
    static let storageKey = "leonida-companion.favoriteIds.v1"

    @Published private(set) var favoriteIds: Set<String> = [] {
        didSet { persist() }
    }

    init() {
        if let saved = UserDefaults.standard.array(forKey: Self.storageKey) as? [String] {
            favoriteIds = Set(saved)
        }
    }

    func isFavorite(_ id: String) -> Bool {
        favoriteIds.contains(id)
    }

    func toggle(_ id: String) {
        if favoriteIds.contains(id) {
            favoriteIds.remove(id)
        } else {
            favoriteIds.insert(id)
        }
    }

    func remove(_ id: String) {
        favoriteIds.remove(id)
    }

    private func persist() {
        UserDefaults.standard.set(Array(favoriteIds), forKey: Self.storageKey)
    }
}
