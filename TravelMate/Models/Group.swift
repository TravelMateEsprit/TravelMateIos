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

// MARK: - GroupMember (pour l'API /groupes/:id/members)
struct GroupMember: Codable, Identifiable {
    let _id: String
    let groupId: String
    let userId: GroupMemberUser
    let role: String
    let status: String
    let joinedAt: String
    let createdAt: String?
    let updatedAt: String?
    
    var id: String { _id }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case groupId
        case userId
        case role
        case status
        case joinedAt
        case createdAt
        case updatedAt
    }
}

struct GroupMemberUser: Codable {
    let _id: String
    let nom: String
    let prenom: String?
    let email: String
    let avatar: String?
    
    var id: String { _id }
    var displayName: String {
        if let prenom = prenom {
            return "\(prenom) \(nom)"
        }
        return nom
    }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case nom = "name"
        case prenom
        case email
        case avatar
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
    
    // ✅ NOUVELLE MÉTHODE : Vérifier si l'utilisateur a une demande en attente
    func isPending(userId: String) async -> Bool {
        do {
            let members: [GroupMember] = try await NetworkService.shared.request(
                endpoint: "/groups/\(id)/members",
                method: .get,
                requiresAuth: true
            )
            
            // Vérifier si l'utilisateur a un statut "pending"
            return members.contains {
                $0.userId._id == userId && $0.status == "pending"
            }
        } catch {
            print("❌ Error checking pending status: \(error)")
            return false
        }
    }
    
    func memberCount() -> String {
        let count = membres.count
        return "\(count) membre\(count > 1 ? "s" : "")"
    }
}

// MARK: - Member Status Extension
extension GroupMember {
    enum Status: String {
        case pending = "pending"
        case active = "active"
        case left = "left"
        case banned = "banned"
    }
    
    var memberStatus: Status {
        return Status(rawValue: status) ?? .active
    }
    
    var isActive: Bool {
        return status == "active"
    }
    
    var isPending: Bool {
        return status == "pending"
    }
}
