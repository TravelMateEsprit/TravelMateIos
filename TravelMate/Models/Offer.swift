import Foundation

struct Offer: Codable, Identifiable {
    let id: String?
    let id_agence: String
    let titre: String
    let description: String
    let prix: Double
    let date_debut: String
    let date_fin: String
    let actif: Bool?
    let images: [String]?
    let destination: String?
    let places_disponibles: Int?
    let type_offre: String?
    
    // MARK: - PACK FIELDS
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

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case id_agence
        case titre
        case description
        case prix
        case date_debut
        case date_fin
        case actif
        case images
        case destination
        case places_disponibles
        case type_offre
        
        case hotel
        case nights
        case included_activities
        case places_to_visit
        case transport
        case price_per_person
        case child_price
        case adult_price
        case hotel_stars
        case meal_type
    }
}

// MARK: - UI COMPUTED PROPERTIES
extension Offer {
    static let mock = Offer.exampleGoldenTulip

    var formattedPrice: String { String(format: "%.0f DT", prix) }

    var baseAdultPrice: Double { adult_price ?? price_per_person ?? prix }
    var baseChildPrice: Double { child_price ?? price_per_person ?? prix }
    
    // DATES
    private func formatDate(_ dateString: String) -> String {
        let iso = ISO8601DateFormatter()
        if let d = iso.date(from: dateString) {
            let f = DateFormatter()
            f.dateFormat = "dd MMM yyyy"
            f.locale = Locale(identifier: "fr_FR")
            return f.string(from: d)
        }
        return dateString
    }
    
    var formattedStartDate: String { formatDate(date_debut) }
    var formattedEndDate: String { formatDate(date_fin) }
    
    // HOTEL
    var hotelDisplayName: String { hotel ?? "Hôtel non spécifié" }
    var hotelStarsText: String { hotel_stars != nil ? String(repeating: "★", count: hotel_stars!) : "" }
    var nightsText: String {
        guard let n = nights else { return "" }
        return n <= 1 ? "1 nuit" : "\(n) nuits"
    }
    var mealTypeText: String { meal_type ?? "Pension non spécifiée" }
    
    // TRANSPORT
    var transportDisplay: String { transport ?? "Transport non détaillé" }

    // ACTIVITIES
    var activitiesListString: String {
        guard let list = included_activities, !list.isEmpty else {
            return "Aucune activité spécifiée"
        }
        return list.map { "• \($0)" }.joined(separator: "\n")
    }
    
    // PLACES
    var placesListString: String {
        guard let list = places_to_visit, !list.isEmpty else {
            return "Aucun lieu spécifié"
        }
        return list.map { "• \($0)" }.joined(separator: "\n")
    }

    // IMAGE
    var firstImageURL: URL? {
        guard let first = images?.first else { return nil }
        return URL(string: "\(Config.apiBaseURL)/uploads/\(first)")
        
    
    }
}

// MARK: - Mock EXAMPLE
extension Offer {
    static let exampleGoldenTulip = Offer(
        id: "example-1",
        id_agence: "ag123",
        titre: "Séjour Golden Tulip - Tunis",
        description: "Pack complet 7 nuits avec vol + excursions",
        prix: 1500,
        date_debut: "2025-02-23T00:00:00Z",
        date_fin: "2025-03-02T00:00:00Z",
        actif: true,
        images: nil,
        destination: "Gammarth",
        places_disponibles: 20,
        type_offre: "package",
        hotel: "Golden Tulip",
        nights: 7,
        included_activities: [
            "Croisière La Goulette",
            "Sidi Bou Saïd",
            "Carthage"
        ],
        places_to_visit: [
            "Carthage",
            "La Marsa"
        ],
        transport: "Vol A/R + Transfert",
        price_per_person: 1500,
        child_price: 950,
        adult_price: 1500,
        hotel_stars: 4,
        meal_type: "Petit déjeuner"
    )
}
