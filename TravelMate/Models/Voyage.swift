import Foundation

struct Voyage: Codable, Identifiable {
    let _id: String
    let destination: String
    let date_depart: String  // "YYYY-MM-DD HH:mm"
    let date_retour: String  // "YYYY-MM-DD HH:mm"
    let type: String  // "vol", "hotel", "voiture"
    let description: String?
    let prix_estime: Double?
    let nombre_places: Int?
    let imageUrl: String?
    let createur_id: Creator
    let participants: [Participant]
    
    var id: String { _id }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case destination
        case date_depart
        case date_retour
        case type
        case description
        case prix_estime
        case nombre_places
        case imageUrl
        case createur_id
        case participants
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required fields
        _id = try container.decode(String.self, forKey: ._id)
        destination = try container.decode(String.self, forKey: .destination)
        date_depart = try container.decode(String.self, forKey: .date_depart)
        date_retour = try container.decode(String.self, forKey: .date_retour)
        type = try container.decode(String.self, forKey: .type)
        
        // Decode optional fields
        description = try container.decodeIfPresent(String.self, forKey: .description)
        
        // Handle prix_estime - could be Double, Int, or String
        if let prixDouble = try? container.decodeIfPresent(Double.self, forKey: .prix_estime) {
            prix_estime = prixDouble
        } else if let prixInt = try? container.decodeIfPresent(Int.self, forKey: .prix_estime) {
            prix_estime = Double(prixInt)
        } else if let prixString = try? container.decodeIfPresent(String.self, forKey: .prix_estime), let prix = Double(prixString) {
            prix_estime = prix
        } else {
            prix_estime = nil
        }
        
        // Handle nombre_places - could be Int or String
        if let placesInt = try? container.decodeIfPresent(Int.self, forKey: .nombre_places) {
            nombre_places = placesInt
        } else if let placesString = try? container.decodeIfPresent(String.self, forKey: .nombre_places), let places = Int(placesString) {
            nombre_places = places
        } else {
            nombre_places = nil
        }
        
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        
        // Decode createur_id - handle both object and string ID
        if let creatorObject = try? container.decode(Creator.self, forKey: .createur_id) {
            createur_id = creatorObject
        } else if let creatorIdString = try? container.decode(String.self, forKey: .createur_id) {
            // If it's just an ID string, create a minimal Creator object
            createur_id = Creator(_id: creatorIdString, name: "", email: "")
        } else {
            // Fallback: try to decode as nested object with different key
            throw DecodingError.keyNotFound(CodingKeys.createur_id, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "createur_id not found and could not be decoded"))
        }
        
        // Decode participants - default to empty array if missing or null
        if let participantsArray = try? container.decodeIfPresent([Participant].self, forKey: .participants) {
            participants = participantsArray ?? []
        } else {
            participants = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(destination, forKey: .destination)
        try container.encode(date_depart, forKey: .date_depart)
        try container.encode(date_retour, forKey: .date_retour)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(prix_estime, forKey: .prix_estime)
        try container.encodeIfPresent(nombre_places, forKey: .nombre_places)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encode(createur_id, forKey: .createur_id)
        try container.encode(participants, forKey: .participants)
    }
}

struct Creator: Codable {
    let _id: String
    let name: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case _id
        case name
        case email
    }
    
    init(_id: String, name: String, email: String) {
        self._id = _id
        self.name = name
        self.email = email
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(String.self, forKey: ._id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
    }
}

struct Participant: Codable {
    let _id: String
    let name: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case _id
        case name
        case email
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(String.self, forKey: ._id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
    }
}

// MARK: - DTOs for API requests
struct CreateVoyageDto: Codable {
    let destination: String
    let date_depart: String
    let date_retour: String
    let type: String
    let description: String  // Required, not optional
    let prix_estime: Double  // Required, not optional
    let nombre_places: Int?
    let imageUrl: String?
}

struct UpdateVoyageDto: Codable {
    let destination: String?
    let date_depart: String?
    let date_retour: String?
    let type: String?
    let description: String?
    let prix_estime: Double?
    let nombre_places: Int?
    let imageUrl: String?
}

struct CreateReservationDto: Codable {
    let id_voyage: String  // Must match exactly with backend
    let prix: Double
    let nombre_personnes: Int
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id_voyage
        case prix
        case nombre_personnes
        case notes
    }
    
    init(id_voyage: String, prix: Double, nombre_personnes: Int, notes: String? = nil) {
        self.id_voyage = id_voyage
        self.prix = prix
        self.nombre_personnes = nombre_personnes
        self.notes = notes
    }
}

// MARK: - Date formatting helpers
extension Voyage {
    func formattedDepartureDate() -> String {
        return formatDate(date_depart)
    }
    
    func formattedReturnDate() -> String {
        return formatDate(date_retour)
    }
    
    func dateRange() -> String {
        let depart = formatDate(date_depart)
        let retour = formatDate(date_retour)
        return "\(depart) - \(retour)"
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        displayFormatter.locale = Locale(identifier: "fr_FR")
        
        return displayFormatter.string(from: date)
    }
    
    func formattedPrice() -> String? {
        guard let prix = prix_estime else { return nil }
        return String(format: "%.0f€", prix)
    }
    
    func placesInfo() -> String {
        guard let total = nombre_places else {
            return "\(participants.count) participants"
        }
        return "\(participants.count)/\(total) places"
    }
    
    func hasAvailablePlaces() -> Bool {
        guard let total = nombre_places else { return true }
        return participants.count < total
    }
    
    func isFull() -> Bool {
        guard let total = nombre_places else { return false }
        return participants.count >= total
    }
    
    func typeIcon() -> String {
        switch type.lowercased() {
        case "vol": return "airplane"
        case "hotel": return "bed.double.fill"
        case "voiture": return "car.fill"
        default: return "tag.fill"
        }
    }
    
    func typeDisplayName() -> String {
        switch type.lowercased() {
        case "vol": return "Vol"
        case "hotel": return "Hôtel"
        case "voiture": return "Location voiture"
        default: return type.capitalized
        }
    }
    
    // MARK: - Comparison Logic
    /// Calculate duration in seconds
    func duration() -> TimeInterval? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        guard let departDate = formatter.date(from: date_depart),
              let returnDate = formatter.date(from: date_retour) else {
            return nil
        }
        
        return returnDate.timeIntervalSince(departDate)
    }
    
    /// Format duration as "X days Y hours"
    func formattedDuration() -> String {
        guard let duration = duration() else {
            return "N/A"
        }
        
        let days = Int(duration / 86400)  // 86400 seconds in a day
        let hours = Int((duration.truncatingRemainder(dividingBy: 86400)) / 3600)
        
        if days > 0 {
            if hours > 0 {
                return "\(days)d \(hours)h"
            } else {
                return "\(days)d"
            }
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
            if minutes > 0 {
                return "\(minutes)min"
            } else {
                return "0min"
            }
        }
    }
}
