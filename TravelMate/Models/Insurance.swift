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
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case agencyId, name, description, price, duration, coverage
        case isActive, subscribers, imageUrl, conditions, createdAt, updatedAt
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
