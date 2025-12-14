import Foundation

@MainActor
class FavoritesService {
    static let shared = FavoritesService()
    private let network = NetworkService.shared
    
    private init() {}
    
    // MARK: - Get User's Favorites
    func getFavorites() async throws -> [Offer] {
        let favorites: [Offer] = try await network.request(
            endpoint: "/favorites",
            method: .get,
            requiresAuth: true
        )
        return favorites
    }
    
    // MARK: - Add to Favorites
    func addFavorite(packId: String) async throws -> FavoriteResponse {
        let dto = AddFavoriteDto(packId: packId)
        
        let response: FavoriteResponse = try await network.request(
            endpoint: "/favorites",
            method: .post,
            body: dto,
            requiresAuth: true
        )
        return response
    }
    
    // MARK: - Remove from Favorites
    func removeFavorite(packId: String) async throws {
        let _: EmptyResponse = try await network.request(
            endpoint: "/favorites/\(packId)",
            method: .delete,
            requiresAuth: true
        )
    }
    
    // MARK: - Check if Pack is Favorite
    func isFavorite(packId: String) async throws -> Bool {
        let favorites = try await getFavorites()
        return favorites.contains { $0.id == packId }
    }
}

// MARK: - DTOs

struct AddFavoriteDto: Codable {
    let packId: String
}

struct FavoriteResponse: Codable {
    let id: String
    let userId: String
    let packId: String
    let createdAt: Date?
}
