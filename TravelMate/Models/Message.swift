import Foundation

// MARK: - Message Models

struct Message: Codable, Identifiable {
    let id: String?
    let conversationId: String
    let senderId: String
    let recipientId: String
    let content: String
    let createdAt: String
    let isRead: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case conversationId, senderId, recipientId
        case content, createdAt, isRead
    }
    
    var isMine: Bool {
        return senderId == AuthService.shared.currentUser?.id
    }
    
    var formattedTime: String {
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: createdAt) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        return ""
    }
    
    var formattedDate: String {
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: createdAt) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            formatter.locale = Locale(identifier: "fr_FR")
            return formatter.string(from: date)
        }
        return createdAt
    }
}

// MARK: - Conversation Model

struct Conversation: Codable, Identifiable {
    let id: String?
    let participants: [String] // User IDs
    let packId: String?
    let lastMessage: String?
    let lastMessageAt: String?
    let unreadCount: Int?
    
    // Populated fields
    let pack: Offer?
    let otherUser: User?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case participants, packId
        case lastMessage, lastMessageAt, unreadCount
        case pack, otherUser
    }
    
    var hasUnread: Bool {
        return (unreadCount ?? 0) > 0
    }
    
    var formattedLastMessageTime: String {
        guard let dateString = lastMessageAt else { return "" }
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: dateString) {
            let formatter = DateFormatter()
            let now = Date()
            let calendar = Calendar.current
            
            if calendar.isDateInToday(date) {
                formatter.dateFormat = "HH:mm"
                return formatter.string(from: date)
            } else if calendar.isDateInYesterday(date) {
                return "Hier"
            } else {
                formatter.dateFormat = "dd/MM"
                return formatter.string(from: date)
            }
        }
        return ""
    }
    
    var displayName: String {
        return otherUser?.name ?? "Utilisateur"
    }
    
    var subtitle: String {
        var text = lastMessage ?? "Aucun message"
        if text.count > 50 {
            text = String(text.prefix(50)) + "..."
        }
        return text
    }
}

// MARK: - Create DTOs

struct CreateConversationDto: Codable {
    let packId: String
    let recipientId: String
}

struct SendMessageDto: Codable {
    let conversationId: String
    let content: String
}
