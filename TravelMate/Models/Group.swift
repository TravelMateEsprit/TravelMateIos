import Foundation

// MARK: - GroupCreator
struct GroupCreator: Codable {
    let _id: String
    let name: String
    let email: String
}

// MARK: - GroupMembre
struct GroupMembre: Codable {
    let _id: String
    let name: String
    let email: String
}

// MARK: - Group
struct Group: Codable, Identifiable {
    let _id: String
    let nom: String
    let destination: String
    let description: String?
    let photoUrl: String?
    let createur_id: GroupCreator
    let membres: [GroupMembre]
    let createdAt: String?
    let updatedAt: String?
    
    var id: String { _id }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case nom
        case destination
        case description
        case photoUrl
        case createur_id
        case membres
        case createdAt
        case updatedAt
    }
}

// MARK: - DTOs avec mapping vers l'API
struct CreateGroupDto: Codable {
    let nom: String
    let destination: String
    let description: String?
    let photoUrl: String?
    
    // ✅ Mapping: nom -> name, photoUrl -> image pour l'API
    enum CodingKeys: String, CodingKey {
        case nom = "name"
        case destination
        case description
        case photoUrl = "image"
    }
}

struct UpdateGroupDto: Codable {
    let nom: String?
    let destination: String?
    let description: String?
    let photoUrl: String?
    
    // ✅ Mapping: nom -> name, photoUrl -> image pour l'API
    enum CodingKeys: String, CodingKey {
        case nom = "name"
        case destination
        case description
        case photoUrl = "image"
    }
}

// MARK: - Helpers
extension Group {
    func isCreator(userId: String) -> Bool {
        return createur_id._id == userId
    }
    
    func isMember(userId: String) -> Bool {
        return membres.contains { $0._id == userId }
    }
    
    func memberCount() -> String {
        let count = membres.count
        return "\(count) membre\(count > 1 ? "s" : "")"
    }
}
