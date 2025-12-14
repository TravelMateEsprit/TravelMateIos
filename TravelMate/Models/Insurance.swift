import Foundation

// MARK: - Insurance Models

struct Insurance: Codable, Identifiable {
    let id: String
    let agencyId: AgencyInfo?
    let name: String
    let description: String
    let price: Double
    let duration: String
    let coverage: [String]
    let isActive: Bool
    let subscribers: [String]
    let imageUrl: String?
    let conditions: InsuranceConditions?
    let createdAt: String?
    let updatedAt: String?
    let averageRating: Double?
    let totalRatings: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case agencyId, name, description, price, duration, coverage
        case isActive, subscribers, imageUrl, conditions, createdAt, updatedAt
        case averageRating, totalRatings
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        price = try container.decode(Double.self, forKey: .price)
        duration = try container.decode(String.self, forKey: .duration)
        coverage = try container.decode([String].self, forKey: .coverage)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        subscribers = try container.decode([String].self, forKey: .subscribers)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        conditions = try container.decodeIfPresent(InsuranceConditions.self, forKey: .conditions)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        averageRating = try container.decodeIfPresent(Double.self, forKey: .averageRating)
        totalRatings = try container.decodeIfPresent(Int.self, forKey: .totalRatings)
        
        // Décodage flexible pour agencyId (peut être String ou AgencyInfo)
        if let agencyInfo = try? container.decode(AgencyInfo.self, forKey: .agencyId) {
            agencyId = agencyInfo
        } else if let _ = try? container.decode(String.self, forKey: .agencyId) {
            // Si c'est juste un String (ID), on met nil car on n'a pas les détails
            agencyId = nil
        } else {
            agencyId = nil
        }
    }
    
    var subscribersCount: Int {
        return subscribers.count
    }
    
    var formattedPrice: String {
        return String(format: "%.2f TND", price)
    }
}

struct InsuranceConditions: Codable {
    let ageMin: Int?
    let ageMax: Int?
    let destination: [String]?
    let other: String?
}

struct AgencyInfo: Codable {
    let id: String
    let agencyName: String?
    let name: String
    let email: String
    let phone: String?
    let city: String?
    let country: String?
    let avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case agencyName, name, email, phone, city, country, avatar
    }
}

// MARK: - Insurance Request DTOs

struct CreateInsuranceRequest: Codable {
    let name: String
    let description: String
    let price: Double
    let duration: String
    let coverage: [String]
    let imageUrl: String?
    let conditions: InsuranceConditions?
    let isActive: Bool?
}

struct UpdateInsuranceRequest: Codable {
    let name: String?
    let description: String?
    let price: Double?
    let duration: String?
    let coverage: [String]?
    let imageUrl: String?
    let conditions: InsuranceConditions?
    let isActive: Bool?
}

// MARK: - Subscribers Response

struct InsuranceSubscribersResponse: Codable {
    let insuranceName: String
    let subscribersCount: Int
    let subscribers: [Subscriber]
}

struct Subscriber: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let userType: String
    let status: String
    let avatar: String?
    let city: String?
    let country: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, email, phone, userType, status, avatar, city, country
    }
}

// MARK: - Response Messages

struct InsuranceDeleteResponse: Codable {
    let message: String
}
