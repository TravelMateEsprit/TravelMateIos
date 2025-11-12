import Foundation

class AuthService {
    static let shared = AuthService()
    private let networkService = NetworkService.shared
    
    private init() {}
    
    var currentUser: User? {
        get {
            guard let data = UserDefaults.standard.data(forKey: Config.userKey),
                  let user = try? JSONDecoder().decode(User.self, from: data) else {
                return nil
            }
            return user
        }
        set {
            if let user = newValue,
               let data = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(data, forKey: Config.userKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Config.userKey)
            }
        }
    }
    
    var accessToken: String? {
        get {
            UserDefaults.standard.string(forKey: Config.tokenKey)
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: Config.tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Config.tokenKey)
            }
        }
    }
    
    var refreshToken: String? {
        get {
            UserDefaults.standard.string(forKey: Config.refreshTokenKey)
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: Config.refreshTokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Config.refreshTokenKey)
            }
        }
    }
    
    var isAuthenticated: Bool {
        return accessToken != nil && currentUser != nil
    }
    
    func signup(name: String, email: String, password: String) async throws -> User {
        let request = SignupRequest(name: name, email: email, password: password)
        let user: User = try await networkService.request(
            endpoint: "/auth/signup",
            method: .post,
            body: request
        )
        return user
    }
    
    func signupAgency(
        name: String,
        email: String,
        password: String,
        agencyName: String,
        agencyLicense: String,
        agencyWebsite: String?,
        phone: String,
        address: String,
        city: String,
        country: String,
        agencyDescription: String?
    ) async throws -> User {
        let request = SignupAgencyRequest(
            name: name,
            email: email,
            password: password,
            agencyName: agencyName,
            agencyLicense: agencyLicense,
            agencyWebsite: agencyWebsite,
            phone: phone,
            address: address,
            city: city,
            country: country,
            agencyDescription: agencyDescription
        )
        let user: User = try await networkService.request(
            endpoint: "/auth/signup/agency",
            method: .post,
            body: request
        )
        return user
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        let request = LoginRequest(email: email, password: password)
        let response: LoginResponse = try await networkService.request(
            endpoint: "/auth/login",
            method: .post,
            body: request
        )
        
        accessToken = response.accessToken
        refreshToken = response.refreshToken
        currentUser = response.user
        
        return response
    }
    
    func logout() {
        accessToken = nil
        refreshToken = nil
        currentUser = nil
        WebSocketService.shared.disconnect()
    }
}
