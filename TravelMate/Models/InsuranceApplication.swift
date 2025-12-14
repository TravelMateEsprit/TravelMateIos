import Foundation
import UIKit

// MARK: - Insurance Application Models

enum ApplicationStatus: String, Codable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
    
    var displayName: String {
        switch self {
        case .pending: return "En attente"
        case .approved: return "Approuvée"
        case .rejected: return "Rejetée"
        }
    }
    
    var color: UIColor {
        switch self {
        case .pending: return .systemOrange
        case .approved: return .systemGreen
        case .rejected: return .systemRed
        }
    }
}

enum TravelReason: String, Codable, CaseIterable {
    case tourism = "tourism"
    case business = "business"
    case studies = "studies"
    case medical = "medical"
    case family = "family"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .tourism: return "Tourisme"
        case .business: return "Affaires"
        case .studies: return "Études"
        case .medical: return "Médical"
        case .family: return "Famille"
        case .other: return "Autre"
        }
    }
}

struct InsuranceApplication: Codable, Identifiable {
    let id: String
    let insuranceId: InsuranceBasicInfo?
    let userId: UserBasicInfo?
    let agencyId: String?
    
    // Données personnelles
    let fullName: String
    let email: String
    let phone: String
    let dateOfBirth: String
    
    // Données de voyage
    let departureDate: String
    let arrivalDate: String
    let destination: String
    
    // Données supplémentaires
    let travelReason: TravelReason
    let customTravelReason: String?
    let passportNumber: String
    
    // Statut
    let status: ApplicationStatus
    let reviewedAt: String?
    let rejectionReason: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case insuranceId, userId, agencyId
        case fullName, email, phone, dateOfBirth
        case departureDate, arrivalDate, destination
        case travelReason, customTravelReason, passportNumber
        case status, reviewedAt, rejectionReason
        case createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        insuranceId = try? container.decode(InsuranceBasicInfo.self, forKey: .insuranceId)
        
        // userId peut être soit un String soit un objet UserBasicInfo
        if let userInfo = try? container.decode(UserBasicInfo.self, forKey: .userId) {
            userId = userInfo
        } else if let userIdString = try? container.decode(String.self, forKey: .userId) {
            userId = UserBasicInfo(id: userIdString, name: nil, email: nil)
        } else {
            userId = nil
        }
        
        // agencyId peut être soit un String soit un objet
        if let agencyIdString = try? container.decode(String.self, forKey: .agencyId) {
            agencyId = agencyIdString
        } else if let agencyInfo = try? container.decode(AgencyBasicInfo.self, forKey: .agencyId) {
            agencyId = agencyInfo.id
        } else {
            agencyId = nil
        }
        
        fullName = try container.decode(String.self, forKey: .fullName)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decode(String.self, forKey: .phone)
        dateOfBirth = try container.decode(String.self, forKey: .dateOfBirth)
        departureDate = try container.decode(String.self, forKey: .departureDate)
        arrivalDate = try container.decode(String.self, forKey: .arrivalDate)
        destination = try container.decode(String.self, forKey: .destination)
        travelReason = try container.decode(TravelReason.self, forKey: .travelReason)
        customTravelReason = try? container.decode(String.self, forKey: .customTravelReason)
        passportNumber = try container.decode(String.self, forKey: .passportNumber)
        status = try container.decode(ApplicationStatus.self, forKey: .status)
        reviewedAt = try? container.decode(String.self, forKey: .reviewedAt)
        rejectionReason = try? container.decode(String.self, forKey: .rejectionReason)
        createdAt = try? container.decode(String.self, forKey: .createdAt)
        updatedAt = try? container.decode(String.self, forKey: .updatedAt)
    }

    
    var formattedDateOfBirth: String {
        return formatDate(dateOfBirth)
    }
    
    var formattedDepartureDate: String {
        return formatDate(departureDate)
    }
    
    var formattedArrivalDate: String {
        return formatDate(arrivalDate)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.locale = Locale(identifier: "fr_FR")
        return displayFormatter.string(from: date)
    }
}

struct UserBasicInfo: Codable {
    let id: String?
    let name: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, email
    }
}

struct InsuranceBasicInfo: Codable {
    let id: String?
    let name: String?
    let price: Double?
    let duration: String?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, price, duration, imageUrl
    }
}

struct AgencyBasicInfo: Codable {
    let id: String?
    let name: String?
    let agencyName: String?
    let email: String?
    let phone: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, agencyName, email, phone
    }
}

// MARK: - Request DTOs

struct CreateInsuranceApplicationRequest: Codable {
    let fullName: String
    let email: String
    let phone: String
    let dateOfBirth: String
    let departureDate: String
    let arrivalDate: String
    let destination: String
    let travelReason: TravelReason
    let customTravelReason: String?
    let passportNumber: String
}

struct ReviewApplicationRequest: Codable {
    let status: ApplicationStatus
    let rejectionReason: String?
}

// MARK: - Response Messages

struct ApplicationCancelResponse: Codable {
    let message: String
}
