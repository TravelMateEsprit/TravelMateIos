import Foundation

@MainActor
class ChatService {
    static let shared = ChatService()
    private let network = NetworkService.shared
    
    private init() {}
    
    // MARK: - Get All Conversations
    func getConversations() async throws -> [Conversation] {
        let conversations: [Conversation] = try await network.request(
            endpoint: "/conversations",
            method: .get,
            requiresAuth: true
        )
        return conversations
    }
    
    // MARK: - Get Messages for Conversation
    func getMessages(conversationId: String) async throws -> [Message] {
        let messages: [Message] = try await network.request(
            endpoint: "/conversations/\(conversationId)/messages",
            method: .get,
            requiresAuth: true
        )
        return messages
    }
    
    // MARK: - Create Conversation
    func createConversation(packId: String, recipientId: String) async throws -> Conversation {
        let dto = CreateConversationDto(packId: packId, recipientId: recipientId)
        
        let conversation: Conversation = try await network.request(
            endpoint: "/conversations",
            method: .post,
            body: dto,
            requiresAuth: true
        )
        return conversation
    }
    
    // MARK: - Send Message (REST API - for initial send, WebSocket for real-time)
    func sendMessage(conversationId: String, content: String) async throws -> Message {
        let dto = SendMessageDto(conversationId: conversationId, content: content)
        
        let message: Message = try await network.request(
            endpoint: "/messages",
            method: .post,
            body: dto,
            requiresAuth: true
        )
        return message
    }
    
    // MARK: - Mark Messages as Read
    func markAsRead(conversationId: String) async throws {
        let _: EmptyResponse = try await network.request(
            endpoint: "/conversations/\(conversationId)/read",
            method: .put,
            requiresAuth: true
        )
    }
    
    // MARK: - Get or Create Conversation for Pack
    /// Tries to find existing conversation for pack, or creates new one
    func getOrCreateConversation(packId: String, agencyId: String) async throws -> Conversation {
        // First try to get existing conversations
        let conversations = try await getConversations()
        
        // Find conversation for this pack
        if let existing = conversations.first(where: { $0.packId == packId }) {
            return existing
        }
        
        // Create new conversation
        return try await createConversation(packId: packId, recipientId: agencyId)
    }
}
