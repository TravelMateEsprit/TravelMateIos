import Foundation
import UIKit

// MARK: - Pack Reservation Models

struct PackReservation: Codable, Identifiable {
    let id: String?
    let packId: String
    let userId: String
    let agencyId: String
    let status: ReservationStatus
    let adultsCount: Int
    let childrenCount: Int
    let totalPrice: Double
    let createdAt: String?
    let updatedAt: String?
    
    // Populated fields from backend
    let pack: Offer?
    let user: User?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case packId, userId, agencyId, status
        case adultsCount, childrenCount, totalPrice
        case createdAt, updatedAt
        case pack, user
    }
}

enum ReservationStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "En attente"
        case .accepted: return "Acceptée"
        case .rejected: return "Refusée"
        case .cancelled: return "Annulée"
        }
    }
    
    var color: UIColor {
        switch self {
        case .pending: return .systemOrange
        case .accepted: return .systemGreen
        case .rejected: return .systemRed
        case .cancelled: return .systemGray
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .accepted: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .cancelled: return "slash.circle.fill"
        }
    }
}

// MARK: - Helpers
extension PackReservation {
    var formattedPrice: String {
        return String(format: "%.0f DT", totalPrice)
    }
    
    var travelersSummary: String {
        var parts: [String] = []
        if adultsCount > 0 {
            parts.append("\(adultsCount) adulte\(adultsCount > 1 ? "s" : "")")
        }
        if childrenCount > 0 {
            parts.append("\(childrenCount) enfant\(childrenCount > 1 ? "s" : "")")
        }
        return parts.joined(separator: " + ")
    }
    
    var formattedDate: String {
        guard let dateString = createdAt else { return "" }
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy, HH:mm"
            formatter.locale = Locale(identifier: "fr_FR")
            return formatter.string(from: date)
        }
        return dateString
    }
    
    var canBeCancelled: Bool {
        return status == .pending
    }
    
    var canBeAccepted: Bool {
        return status == .pending
    }
    
    var canBeRejected: Bool {
        return status == .pending
    }
    
    var showPaymentButton: Bool {
        return status == .accepted
    }
}

// MARK: - Create/Update DTOs
struct CreatePackReservationDto: Codable {
    let packId: String
    let adultsCount: Int
    let childrenCount: Int
    let totalPrice: Double
}

struct UpdateReservationStatusDto: Codable {
    let status: ReservationStatus
}
