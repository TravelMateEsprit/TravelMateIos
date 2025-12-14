import Foundation
import SocketIO

class WebSocketService {
    static let shared = WebSocketService()
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    private let wsURL: String
    
    var isConnected: Bool {
        return socket?.status == .connected
    }
    
    private init() {
        self.wsURL = Config.wsBaseURL
    }
    
    func connect(token: String) {
        guard let url = URL(string: wsURL) else {
            print("Invalid WebSocket URL")
            return
        }
        
        let config: SocketIOClientConfiguration = [
            .log(false),
            .compress,
            .forceWebsockets(true),
            .connectParams(["token": token]),
            .path("/ws/socket.io/")
        ]
        
        manager = SocketManager(socketURL: url, config: config)
        socket = manager?.socket(forNamespace: "/ws")
        
        setupEventHandlers()
        socket?.connect()
    }
    
    private func setupEventHandlers() {
        socket?.on(clientEvent: .connect) { [weak self] data, ack in
            print("WebSocket connected")
        }
        
        socket?.on(clientEvent: .disconnect) { data, ack in
            print("WebSocket disconnected")
        }
        
        socket?.on(clientEvent: .error) { data, ack in
            print("WebSocket error: \(data)")
        }
        
        socket?.on("connection:established") { data, ack in
            print("Connection established: \(data)")
        }
        
        socket?.on("subscription:confirmed") { data, ack in
            print("Subscription confirmed: \(data)")
        }
        
        socket?.on("voyage:created") { data, ack in
            print("Voyage created: \(data)")
        }
        
        socket?.on("voyage:updated") { data, ack in
            print("Voyage updated: \(data)")
        }
        
        socket?.on("voyage:deleted") { data, ack in
            print("Voyage deleted: \(data)")
        }
        
        socket?.on("reservation:created") { data, ack in
            print("Reservation created: \(data)")
        }
        
        socket?.on("reservation:updated") { data, ack in
            print("Reservation updated: \(data)")
        }
        
        socket?.on("reservation:deleted") { data, ack in
            print("Reservation deleted: \(data)")
        }
    }
    
    func subscribeToVoyages() {
        socket?.emit("subscribe:voyages")
    }
    
    func subscribeToReservations() {
        socket?.emit("subscribe:reservations")
    }
    
    func unsubscribeFromVoyages() {
        socket?.emit("unsubscribe:voyages")
    }
    
    func unsubscribeFromReservations() {
        socket?.emit("unsubscribe:reservations")
    }
    
    func disconnect() {
        socket?.disconnect()
        manager = nil
        socket = nil
    }
    // MARK: - Public Emit & Listen for any channel (for Packs module)

    func listen(event: String, callback: @escaping ([Any]) -> Void) {
        socket?.on(event) { data, ack in
            callback(data)
        }
    }

    func emit(event: String, data: [String: Any]) {
        socket?.emit(event, data)
    }
    
    // MARK: - Chat-Specific Methods
    
    /// Join a conversation room
    func joinConversation(conversationId: String) {
        socket?.emit("join:conversation", ["conversationId": conversationId])
        print("📱 Joined conversation: \(conversationId)")
    }
    
    /// Leave a conversation room
    func leaveConversation(conversationId: String) {
        socket?.emit("leave:conversation", ["conversationId": conversationId])
        print("📱 Left conversation: \(conversationId)")
    }
    
    /// Send a message via WebSocket
    func sendMessage(conversationId: String, content: String) {
        let data: [String: Any] = [
            "conversationId": conversationId,
            "content": content
        ]
        socket?.emit("message:send", data)
    }
    
    /// Listen for incoming messages
    func onMessageReceived(callback: @escaping ([String: Any]) -> Void) {
        socket?.on("message:received") { data, ack in
            guard let messageData = data.first as? [String: Any] else { return }
            callback(messageData)
        }
    }
    
    /// Listen for typing indicators
    func onUserTyping(callback: @escaping ([String: Any]) -> Void) {
        socket?.on("user:typing") { data, ack in
            guard let typingData = data.first as? [String: Any] else { return }
            callback(typingData)
        }
    }
    
    /// Send typing indicator
    func sendTypingIndicator(conversationId: String, isTyping: Bool) {
        let data: [String: Any] = [
            "conversationId": conversationId,
            "isTyping": isTyping
        ]
        socket?.emit("user:typing", data)
    }
    
    /// Remove specific event listener
    func removeListener(event: String) {
        socket?.off(event)
    }

}
