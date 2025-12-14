import Foundation

@MainActor
class PackService {
    static let shared = PackService()
    private let network = NetworkService.shared

    private init() {}

    // MARK: - Get all packs (offers)
    func getAllPacks() async throws -> [Offer] {
        do {
            let packs: [Offer] = try await network.request(
                endpoint: "/offers",
                method: .get,
                requiresAuth: true
            )
            return packs
        } catch {
            print("⚠️ Erreur API, utilisation de l'exemple local")
            return [Offer.exampleGoldenTulip]   // fallback si backend vide
        }
    }

    // MARK: - Get one pack (offer)
    func getPack(id: String) async throws -> Offer {
        do {
            let pack: Offer = try await network.request(
                endpoint: "/offers/\(id)",
                method: .get,
                requiresAuth: true
            )
            return pack
        } catch {
            print("⚠️ Erreur API getPack : retour fallback")
            return Offer.exampleGoldenTulip      // toujours un objet valide
        }
    }

    // MARK: - Create pack (agency)
    func createPack(_ data: CreateOfferDto) async throws -> Offer {
        let pack: Offer = try await network.request(
            endpoint: "/offers",
            method: .post,
            body: data,
            requiresAuth: true
        )
        return pack
    }

    // MARK: - Update pack
    func updatePack(id: String, _ data: UpdateOfferDto) async throws -> Offer {
        let updated: Offer = try await network.request(
            endpoint: "/offers/\(id)",
            method: .patch,
            body: data,
            requiresAuth: true
        )
        return updated
    }

    // MARK: - Delete pack
    func deletePack(id: String) async throws {
        let _: EmptyResponse = try await network.request(
            endpoint: "/offers/\(id)",
            method: .delete,
            requiresAuth: true
        )
    }
}

// MARK: - DTOs (mis à jour selon Offer.swift)
struct CreateOfferDto: Codable {
    let titre: String
    let description: String
    let prix: Double
    let date_debut: String
    let date_fin: String
    let destination: String?
    let images: [String]?

    // Champs pack
    let hotel: String?
    let nights: Int?
    let included_activities: [String]?
    let places_to_visit: [String]?
    let transport: String?
    let price_per_person: Double?
    let child_price: Double?
    let adult_price: Double?
    let hotel_stars: Int?
    let meal_type: String?
}

struct UpdateOfferDto: Codable {
    let titre: String?
    let description: String?
    let prix: Double?
    let date_debut: String?
    let date_fin: String?
    let destination: String?
    let images: [String]?

    // Champs pack
    let hotel: String?
    let nights: Int?
    let included_activities: [String]?
    let places_to_visit: [String]?
    let transport: String?
    let price_per_person: Double?
    let child_price: Double?
    let adult_price: Double?
    let hotel_stars: Int?
    let meal_type: String?
}
