import Foundation

enum UserType: String, Codable {
    case user = "user"
    case agence = "agence"
    case admin = "admin"
}

enum UserStatus: String, Codable {
    case active = "active"
    case suspended = "suspended"
    case pending = "pending"
}

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let userType: UserType
    let status: UserStatus
    let phone: String?
    let address: String?
    let city: String?
    let country: String?
    let agencyName: String?
    let agencyLicense: String?
    let agencyWebsite: String?
    let agencyDescription: String?
    let isAgencyVerified: Bool?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, email, userType, status, phone, address, city, country
        case agencyName, agencyLicense, agencyWebsite, agencyDescription
        case isAgencyVerified, createdAt
    }
}

struct SignupRequest: Codable {
    let name: String
    let email: String
    let password: String
}

struct SignupAgencyRequest: Codable {
    let name: String
    let email: String
    let password: String
    let agencyName: String
    let agencyLicense: String
    let agencyWebsite: String?
    let phone: String
    let address: String
    let city: String
    let country: String
    let agencyDescription: String?
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let userId: String
    let user: User
}

struct ErrorResponse: Codable {
    let statusCode: Int
    let message: String
    let error: String?
}
