import Foundation

// Empty response type for endpoints that don't return data
struct EmptyResponse: Decodable {}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL: String
    
    private init() {
        self.baseURL = Config.apiBaseURL
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    enum NetworkError: LocalizedError {
        case invalidURL
        case noData
        case decodingError
        case serverError(String)
        case unauthorized
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "URL invalide"
            case .noData:
                return "Aucune donnée reçue"
            case .decodingError:
                return "Erreur de décodage des données"
            case .serverError(let message):
                return message
            case .unauthorized:
                return "Non autorisé. Veuillez vous reconnecter."
            }
        }
    }
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        headers: [String: String]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            print("❌ [NETWORK] Invalid URL: \(baseURL + endpoint)")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if required
        if requiresAuth {
            if let token = AuthService.shared.accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                print("🔐 [NETWORK] Authorization header added")
            } else {
                print("⚠️ [NETWORK] Auth required but no token available!")
                print("⚠️ [NETWORK] This might be a login/signup endpoint that should have requiresAuth: false")
                throw NetworkError.unauthorized
            }
        } else {
            print("🔓 [NETWORK] No authentication required for this request")
        }
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Log request details
        print("🌐 [NETWORK] ========================================")
        print("🌐 [NETWORK] Request Details:")
        print("   - Base URL: \(baseURL)")
        print("   - Method: \(method.rawValue)")
        print("   - Full URL: \(url.absoluteString)")
        print("   - Endpoint: \(endpoint)")
        print("   - Requires Auth: \(requiresAuth)")
        
        // Log headers
        if requiresAuth, let token = AuthService.shared.accessToken {
            let tokenPreview = token.count > 20 ? String(token.prefix(20)) + "..." : token
            print("   - Authorization: Bearer \(tokenPreview)")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
                if let jsonData = request.httpBody,
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("🌐 [NETWORK] Request Body:")
                    print("   \(jsonString)")
                    print("   - Body size: \(jsonData.count) bytes")
                }
            } catch {
                print("❌ [NETWORK] Error encoding body: \(error)")
                throw error
            }
        } else {
            print("🌐 [NETWORK] No request body")
        }
        
        print("🌐 [NETWORK] Sending request...")
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print("❌ [NETWORK] Network request failed:")
            print("   - Error type: \(type(of: error))")
            print("   - Error: \(error)")
            if let urlError = error as? URLError {
                print("   - URL Error code: \(urlError.code.rawValue)")
                print("   - URL Error description: \(urlError.localizedDescription)")
            }
            print("🌐 [NETWORK] ========================================")
            throw error
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [NETWORK] Invalid HTTP response")
            throw NetworkError.noData
        }
        
        print("✅ [NETWORK] Received response (HTTP \(httpResponse.statusCode))")
        
        // Log response headers
        print("   - Response Headers:")
        httpResponse.allHeaderFields.forEach { (key, value) in
            print("     \(key): \(value)")
        }
        
        // Handle HTTP errors
        if httpResponse.statusCode == 401 {
            print("❌ [NETWORK] Unauthorized (401)")
            throw NetworkError.unauthorized
        }
        
        if httpResponse.statusCode >= 400 {
            let errorMessage = "Erreur serveur: \(httpResponse.statusCode)"
            print("❌ [NETWORK] \(errorMessage)")
            
            if let errorString = String(data: data, encoding: .utf8), !errorString.isEmpty {
                print("   - Raw error response: \(errorString)")
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let message = json["message"] as? String {
                            print("   - Error message: \(message)")
                            throw NetworkError.serverError(message)
                        } else if let errors = json["errors"] as? [String: [String]] {
                            let errorMessages = errors.values.flatMap { $0 }.joined(separator: ", ")
                            print("   - Error messages: \(errorMessages)")
                            throw NetworkError.serverError(errorMessages)
                        }
                    }
                } catch {
                    print("   - Could not parse error JSON: \(error)")
                }
                
                throw NetworkError.serverError(errorString)
            }
            
            throw NetworkError.serverError(errorMessage)
        }
        
        print("✅ [NETWORK] Success (HTTP \(httpResponse.statusCode))")
        
        // Handle empty responses (204 No Content or empty body)
        if httpResponse.statusCode == 204 || data.isEmpty {
            print("⚠️ [NETWORK] Empty response body (status \(httpResponse.statusCode))")
            // For empty responses, try to return a default instance if possible
            if T.self == EmptyResponse.self || T.self == Void.self {
                print("✅ [NETWORK] Returning empty response for status \(httpResponse.statusCode)")
                print("🌐 [NETWORK] ========================================")
                if T.self == Void.self {
                    return () as! T
                } else {
                    return EmptyResponse() as! T
                }
            } else {
                print("❌ [NETWORK] Expected non-empty response but got empty body")
                print("🌐 [NETWORK] ========================================")
                throw NetworkError.noData
            }
        }
        
        do {
            let decoder = JSONDecoder()
            // Don't use convertFromSnakeCase since we're using explicit CodingKeys with snake_case
            // decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedObject = try decoder.decode(T.self, from: data)
            print("✅ [NETWORK] Response decoded successfully")
            return decodedObject
        } catch let decodingError as DecodingError {
            print("❌ [NETWORK] Decoding error:")
            print("   - Error type: \(type(of: decodingError))")
            
            // Print detailed decoding error
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("   - Type mismatch: Expected \(type), found at: \(context.codingPath)")
                print("   - Context: \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("   - Value not found: Expected \(type) at: \(context.codingPath)")
                print("   - Context: \(context.debugDescription)")
            case .keyNotFound(let key, let context):
                print("   - Key not found: '\(key.stringValue)' at: \(context.codingPath)")
                print("   - Context: \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("   - Data corrupted at: \(context.codingPath)")
                print("   - Context: \(context.debugDescription)")
            @unknown default:
                print("   - Unknown decoding error: \(decodingError)")
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                    print("   - Response JSON: \(jsonString)")
            }
            print("🌐 [NETWORK] ========================================")
            throw NetworkError.decodingError
        } catch {
            print("❌ [NETWORK] Decoding error:")
            print("   - Error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("   - Response data: \(jsonString)")
            }
            throw NetworkError.decodingError
        }
    }
}
