import Foundation

struct Config {
    static var apiBaseURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String else {
            // Fallback: For iOS Simulator on same Mac, use localhost
            // For Physical Device or Simulator on different machine: use Mac's IP from Info.plist
            return "http://127.0.0.1:3000"
        }
        return url
    }
    
    static var wsBaseURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "WS_BASE_URL") as? String else {
            // Fallback: For iOS Simulator on same Mac, use localhost
            // For Physical Device or Simulator on different machine: use Mac's IP from Info.plist
            return "http://127.0.0.1:3000"
        }
        return url
    }
    
    static let tokenKey = "com.travelmate.token"
    static let refreshTokenKey = "com.travelmate.refreshToken"
    static let userKey = "com.travelmate.user"
}
