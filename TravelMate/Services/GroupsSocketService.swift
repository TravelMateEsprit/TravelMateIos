import Foundation
import SocketIO

class GroupsSocketService {
    static let shared = GroupsSocketService()
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    private init() {}
    
    func connect() {
        guard let token = AuthService.shared.accessToken else { return }
        guard let url = URL(string: Config.wsBaseURL) else { return }
        
        let config: SocketIOClientConfiguration = [
            .log(false),
            .compress,
            .forceWebsockets(true),
            .extraHeaders(["Authorization": "Bearer \(token)"]),
            .path("/groups/socket.io/")
        ]
        
        manager = SocketManager(socketURL: url, config: config)
        socket = manager?.socket(forNamespace: "/groups")
        setupHandlers()
        socket?.connect()
    }
    
    private func setupHandlers() {
        socket?.on(clientEvent: .connect) { data, ack in
            print("[GroupsSocket] connected")
        }
        
        socket?.on(clientEvent: .disconnect) { data, ack in
            print("[GroupsSocket] disconnected")
        }
    }
    
    func disconnect() {
        socket?.disconnect()
        manager = nil
        socket = nil
    }
    
    // MARK: - Join / Leave
    func joinGroup(groupId: String) {
        socket?.emit("joinGroup", ["groupId": groupId])
    }
    
    func leaveGroup(groupId: String) {
        socket?.emit("leaveGroup", ["groupId": groupId])
    }
    
    // MARK: - Messages
    func sendMessage(groupId: String, content: String?, images: [String]) {
        let payload: [String: Any] = [
            "groupId": groupId,
            "content": content as Any,
            "images": images
        ]
        socket?.emit("sendMessage", payload)
    }
    
    func deleteMessage(groupId: String, messageId: String) {
        socket?.emit("deleteMessage", [
            "groupId": groupId,
            "messageId": messageId
        ])
    }
    
    func updateMessage(groupId: String, messageId: String, content: String?) {
        socket?.emit("updateMessage", [
            "groupId": groupId,
            "messageId": messageId,
            "content": content as Any
        ])
    }
    
    func reactToMessage(groupId: String, messageId: String, emoji: String) {
        socket?.emit("reactToMessage", [
            "groupId": groupId,
            "messageId": messageId,
            "emoji": emoji
        ])
    }
    
    // MARK: - Typing
    func sendTyping(groupId: String, isTyping: Bool) {
        socket?.emit("typing", [
            "groupId": groupId,
            "isTyping": isTyping
        ])
    }
    
    // MARK: - Listeners
    func onNewMessage(_ callback: @escaping ([String: Any]) -> Void) {
        socket?.on("newMessage") { data, ack in
            guard let dict = data.first as? [String: Any] else { return }
            callback(dict)
        }
    }
    
    func onMessageDeleted(_ callback: @escaping ([String: Any]) -> Void) {
        socket?.on("messageDeleted") { data, ack in
            guard let dict = data.first as? [String: Any] else { return }
            callback(dict)
        }
    }
    
    func onMessageUpdated(_ callback: @escaping ([String: Any]) -> Void) {
        socket?.on("messageUpdated") { data, ack in
            guard let dict = data.first as? [String: Any] else { return }
            callback(dict)
        }
    }
    
    func onMessageReacted(_ callback: @escaping ([String: Any]) -> Void) {
        socket?.on("messageReacted") { data, ack in
            guard let dict = data.first as? [String: Any] else { return }
            callback(dict)
        }
    }
    
    func onUserTyping(_ callback: @escaping ([String: Any]) -> Void) {
        socket?.on("userTyping") { data, ack in
            guard let dict = data.first as? [String: Any] else { return }
            callback(dict)
        }
    }
}
