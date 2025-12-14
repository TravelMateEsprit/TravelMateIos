import Foundation

@MainActor
class GroupChatService {
    static let shared = GroupChatService()
    
    private let network = NetworkService.shared
    
    private init() {}
    
    func fetchMessages(groupId: String) async throws -> [GroupMessage] {
        let messages: [GroupMessage] = try await network.request(
            endpoint: "/groups/\(groupId)/messages",
            method: .get,
            requiresAuth: true
        )
        return messages
    }
    
    func sendMessage(groupId: String, dto: CreateGroupMessageDto) async throws -> GroupMessage {
        let message: GroupMessage = try await network.request(
            endpoint: "/groups/\(groupId)/messages",
            method: .post,
            body: dto,
            requiresAuth: true
        )
        return message
    }
    
    func updateMessage(groupId: String, messageId: String, dto: UpdateGroupMessageDto) async throws -> GroupMessage {
        let message: GroupMessage = try await network.request(
            endpoint: "/groups/\(groupId)/messages/\(messageId)",
            method: .put,
            body: dto,
            requiresAuth: true
        )
        return message
    }
    
    func deleteMessage(groupId: String, messageId: String) async throws {
        let _: EmptyResponse = try await network.request(
            endpoint: "/groups/\(groupId)/messages/\(messageId)",
            method: .delete,
            requiresAuth: true
        )
    }
    
    func reactToMessage(groupId: String, messageId: String, emoji: String) async throws {
        let dto = ReactToMessageDto(emoji: emoji)
        let _: EmptyResponse = try await network.request(
            endpoint: "/groups/\(groupId)/messages/\(messageId)/react",
            method: .post,
            body: dto,
            requiresAuth: true
        )
    }
}
