import Foundation

struct Rating: Codable, Identifiable {
    let id: String
    let insuranceId: InsuranceIdInfo?
    let userId: RatingUserInfo?
    let rating: Int
    let comment: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case insuranceId, userId, rating, comment, createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        rating = try container.decode(Int.self, forKey: .rating)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        
        if let insuranceInfo = try? container.decode(InsuranceIdInfo.self, forKey: .insuranceId) {
            insuranceId = insuranceInfo
        } else {
            insuranceId = nil
        }
        
        if let userInfo = try? container.decode(RatingUserInfo.self, forKey: .userId) {
            userId = userInfo
        } else {
            userId = nil
        }
    }
}

struct InsuranceIdInfo: Codable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}

struct RatingUserInfo: Codable {
    let id: String
    let name: String
    let avatar: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, avatar, email
    }
}

struct CreateRatingRequest: Codable {
    let rating: Int
    let comment: String?
}

struct UpdateRatingRequest: Codable {
    let rating: Int?
    let comment: String?
}

struct InsuranceRatingsResponse: Codable {
    let insuranceName: String
    let averageRating: Double
    let totalRatings: Int
    let ratings: [Rating]
}

struct AgencyRatingsResponse: Codable {
    let insurances: [InsuranceRatingInfo]
    let allRatings: [Rating]
}

struct InsuranceRatingInfo: Codable {
    let insuranceId: String
    let insuranceName: String
    let averageRating: Double
    let totalRatings: Int
}

struct RatingDeleteResponse: Codable {
    let message: String
}
