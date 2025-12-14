import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    
    private let userDefaultsKey = "favorites_cache"
    private var cachedFavorites: [Offer] = []
    
    private init() {
        loadCachedFavorites()
    }
    
    // MARK: - Public API
    
    /// Get all favorites from cache
    func getFavorites() -> [Offer] {
        return cachedFavorites
    }
    
    /// Check if pack is favorited
    func isFavorite(id: String) -> Bool {
        return cachedFavorites.contains(where: { $0.id == id })
    }
    
    /// Add pack to favorites cache
    func addFavorite(_ offer: Offer) {
        guard let packId = offer.id else { return }
        
        // Add to cache if not already present
        if !cachedFavorites.contains(where: { $0.id == packId }) {
            cachedFavorites.append(offer)
            saveToCache()
        }
    }
    
    /// Remove pack from favorites cache
    func removeFavorite(id: String) {
        cachedFavorites.removeAll { $0.id == id }
        saveToCache()
    }
    
    // MARK: - Cache Management
    
    private func loadCachedFavorites() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let favorites = try? JSONDecoder().decode([Offer].self, from: data) else {
            cachedFavorites = []
            return
        }
        cachedFavorites = favorites
    }
    
    private func saveToCache() {
        guard let data = try? JSONEncoder().encode(cachedFavorites) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
}
