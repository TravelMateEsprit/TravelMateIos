import Foundation

struct Config {
    static var apiBaseURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String else {
            // For iOS Simulator: use localhost:3000
            return "http://localhost:3000"
            // For Physical Device on same network: use your Mac's IP
            // return "http://192.168.1.18:3000"
            // Note: 10.0.2.2 is for Android emulators only, not iOS
        }
        return url
    }
    
    static var wsBaseURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "WS_BASE_URL") as? String else {
            // For iOS Simulator: use localhost:3000
            return "http://localhost:3000"
            // For Physical Device on same network: use your Mac's IP
            // return "http://192.168.1.18:3000"
        }
        return url
    }
    
    static let tokenKey = "com.travelmate.token"
    static let refreshTokenKey = "com.travelmate.refreshToken"
    static let userKey = "com.travelmate.user"
}
