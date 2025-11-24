import Foundation

class InsuranceService {
    static let shared = InsuranceService()
    private let networkService = NetworkService.shared
    
    private init() {}
    
    // MARK: - User Endpoints
    
    /// Récupérer toutes les assurances actives
    func getAllInsurances() async throws -> [Insurance] {
        guard let token = AuthService.shared.getAccessToken() else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances",
            method: .get,
            headers: headers
        )
    }
    
    /// Récupérer une assurance par son ID
    func getInsurance(id: String) async throws -> Insurance {
        guard let token = AuthService.shared.getAccessToken() else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/\(id)",
            method: .get,
            headers: headers
        )
    }
    
    /// Récupérer mes assurances souscrites
    func getMySubscriptions() async throws -> [Insurance] {
        guard let token = AuthService.shared.getAccessToken() else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/my-subscriptions",
            method: .get,
            headers: headers
        )
    }
    
    /// S'inscrire à une assurance
    func subscribe(insuranceId: String) async throws -> Insurance {
        guard let token = AuthService.shared.getAccessToken() else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/\(insuranceId)/subscribe",
            method: .post,
            headers: headers
        )
    }
    
    /// Se désinscrire d'une assurance
    func unsubscribe(insuranceId: String) async throws -> Insurance {
        guard let token = AuthService.shared.getAccessToken() else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/\(insuranceId)/unsubscribe",
            method: .post,
            headers: headers
        )
    }
    
    // MARK: - Agency Endpoints
    
    /// Créer une nouvelle assurance (Agence uniquement)
    func createInsurance(request: CreateInsuranceRequest) async throws -> Insurance {
        guard let token = AuthService.shared.getAccessToken() else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/agency",
            method: .post,
            body: request,
            headers: headers
        )
    }
    
    /// Récupérer toutes les assurances de mon agence
    func getMyAgencyInsurances() async throws -> [Insurance] {
        guard let token = AuthService.shared.getAccessToken() else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/agency/my-insurances",
            method: .get,
            headers: headers
        )
    }
    
    /// Modifier une assurance (Agence uniquement)
    func updateInsurance(id: String, request: UpdateInsuranceRequest) async throws -> Insurance {
        guard let token = AuthService.shared.getAccessToken() else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/agency/\(id)",
            method: .patch,
            body: request,
            headers: headers
        )
    }
    
    /// Supprimer une assurance (Agence uniquement)
    func deleteInsurance(id: String) async throws -> InsuranceDeleteResponse {
        guard let token = AuthService.shared.getAccessToken() else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/agency/\(id)",
            method: .delete,
            headers: headers
        )
    }
    
    /// Activer/Désactiver une assurance (Agence uniquement)
    func toggleInsuranceStatus(id: String) async throws -> Insurance {
        guard let token = AuthService.shared.getAccessToken() else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/agency/\(id)/toggle-active",
            method: .patch,
            headers: headers
        )
    }
    
    /// Voir les inscrits à une assurance (Agence uniquement)
    func getInsuranceSubscribers(insuranceId: String) async throws -> InsuranceSubscribersResponse {
        guard let token = AuthService.shared.getAccessToken() else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/agency/\(insuranceId)/subscribers-details",
            method: .get,
            headers: headers
        )
    }
}
