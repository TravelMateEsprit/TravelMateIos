import Foundation

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
    
    enum NetworkError: Error {
        case invalidURL
        case noData
        case decodingError
        case serverError(String)
        case unauthorized
        case connectionRefused
        
        var localizedDescription: String {
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
                return "Non autorisé"
            case .connectionRefused:
                return "Impossible de se connecter au serveur. Vérifiez que le serveur est démarré."
            }
        }
    }
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            
            if httpResponse.statusCode >= 400 {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw NetworkError.serverError(errorResponse.message)
                }
                throw NetworkError.serverError("Erreur serveur: \(httpResponse.statusCode)")
            }
            
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response data: \(jsonString)")
                }
                throw NetworkError.decodingError
            }
        } catch let error as URLError {
            if error.code == .cannotConnectToHost || error.code == .networkConnectionLost {
                throw NetworkError.connectionRefused
            }
            throw error
        }
    }
}
