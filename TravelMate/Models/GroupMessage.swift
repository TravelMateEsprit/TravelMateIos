import Foundation

struct GroupReaction: Codable, Identifiable {
    let id: String?
    let userId: String
    let emoji: String
    let reactedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case emoji
        case reactedAt
    }
}

struct GroupMessageAuthor: Codable {
    let _id: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case _id
        case email
    }
}

struct GroupMessage: Codable, Identifiable {
    let id: String?
    let groupId: String
    let authorId: GroupMessageAuthor
    let content: String?
    let images: [String]
    let reactions: [GroupReaction]?
    let status: String
    let createdAt: String
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case groupId
        case authorId
        case content
        case images
        case reactions
        case status
        case createdAt
        case updatedAt
    }
    
    var isMine: Bool {
        return authorId._id == AuthService.shared.currentUser?.id
    }
}

struct CreateGroupMessageDto: Codable {
    let content: String?
    let images: [String]
}

struct UpdateGroupMessageDto: Codable {
    let content: String?
}

struct ReactToMessageDto: Codable {
    let emoji: String
}
