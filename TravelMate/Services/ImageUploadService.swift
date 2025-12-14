import Foundation
import UIKit

@MainActor
class ImageUploadService {
    static let shared = ImageUploadService()
    
    private init() {}
    
    enum UploadType {
        case group
        case message
        
        var path: String {
            switch self {
            case .group:
                return "/groups/upload-image"
            case .message:
                return "/groups/upload-message-image"
            }
        }
    }
    
    private struct UploadResponse: Codable {
        let imageUrl: String
    }
    
    func uploadGroupImage(_ image: UIImage) async throws -> String {
        return try await uploadImage(image, type: .group)
    }
    
    func uploadMessageImage(_ image: UIImage) async throws -> String {
        return try await uploadImage(image, type: .message)
    }
    
    private func uploadImage(_ image: UIImage, type: UploadType) async throws -> String {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkService.NetworkError.serverError("Impossible de préparer l'image pour l'upload")
        }
        
        let urlString = Config.apiBaseURL + type.path
        guard let url = URL(string: urlString) else {
            throw NetworkService.NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        var body = Data()
        let fieldName = "image"
        let fileName = "image.jpg"
        let mimeType = "image/jpeg"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkService.NetworkError.serverError("Réponse invalide du serveur")
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Code d'erreur: \(httpResponse.statusCode)"
            throw NetworkService.NetworkError.serverError(errorMessage)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let uploadResponse = try decoder.decode(UploadResponse.self, from: data)
        return uploadResponse.imageUrl
    }
}
