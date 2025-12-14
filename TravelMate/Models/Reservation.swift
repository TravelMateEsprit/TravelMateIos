import Foundation
import UIKit    

struct Reservation: Codable, Identifiable {
    let _id: String
    let voyage_id: VoyageInfo
    let user_id: ReservationUserInfo
    let prix: Double
    let nombre_personnes: Int
    let notes: String?
    let statut: String  // "en_attente", "confirmee", "annulee"
    let createdAt: String?
    let updatedAt: String?
    
    var id: String { _id }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case voyage_id
        case user_id
        case prix
        case nombre_personnes
        case notes
        case statut
        case createdAt
        case updatedAt
    }
}

struct VoyageInfo: Codable {
    let _id: String
    let destination: String
    let date_depart: String
    let date_retour: String
    let type: String
    let imageUrl: String?
}

struct ReservationUserInfo: Codable {
    let _id: String
    let name: String
    let email: String
}

// MARK: - Helpers
extension Reservation {
    func formattedPrice() -> String {
        return String(format: "%.0f€", prix)
    }
    
    func statusDisplayName() -> String {
        switch statut.lowercased() {
        case "en_attente": return "En attente"
        case "confirmee": return "Confirmée"
        case "annulee": return "Annulée"
        default: return statut.capitalized
        }
    }
    
    func statusColor() -> UIColor {
        switch statut.lowercased() {
        case "en_attente": return .systemOrange
        case "confirmee": return .systemGreen
        case "annulee": return .systemRed
        default: return .systemGray
        }
    }
    
    func formattedDateRange() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        guard let departDate = formatter.date(from: voyage_id.date_depart),
              let retourDate = formatter.date(from: voyage_id.date_retour) else {
            return "\(voyage_id.date_depart) - \(voyage_id.date_retour)"
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        displayFormatter.locale = Locale(identifier: "fr_FR")
        
        return "\(displayFormatter.string(from: departDate)) - \(displayFormatter.string(from: retourDate))"
    }
    
    func typeDisplayName() -> String {
        switch voyage_id.type.lowercased() {
        case "vol": return "Vol"
        case "hotel": return "Hôtel"
        case "voiture": return "Location voiture"
        default: return voyage_id.type.capitalized
        }
    }
}

