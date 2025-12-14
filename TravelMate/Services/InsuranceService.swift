import Foundation

class InsuranceService {
    static let shared = InsuranceService()
    private let networkService = NetworkService.shared
    
    private init() {}
    
    // MARK: - User Endpoints
    
    /// Récupérer toutes les assurances actives
    func getAllInsurances(filters: InsuranceSearchFilters? = nil) async throws -> [Insurance] {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        
        var endpoint = "/insurances"
        if let filters = filters {
            let queryItems = filters.toQueryItems()
            if !queryItems.isEmpty {
                var components = URLComponents(string: Config.apiBaseURL + endpoint)
                components?.queryItems = queryItems
                if let url = components?.url {
                    endpoint = url.path + (url.query.map { "?" + $0 } ?? "")
                }
            }
        }
        
        return try await networkService.request(
            endpoint: endpoint,
            method: .get,
            headers: headers
        )
    }
    
    /// Récupérer une assurance par son ID
    func getInsurance(id: String) async throws -> Insurance {
        guard let token = AuthService.shared.accessToken else {
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
        guard let token = AuthService.shared.accessToken else {
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
        guard let token = AuthService.shared.accessToken else {
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
        guard let token = AuthService.shared.accessToken else {
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
        guard let token = AuthService.shared.accessToken else {
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
        guard let token = AuthService.shared.accessToken else {
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
        guard let token = AuthService.shared.accessToken else {
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
        guard let token = AuthService.shared.accessToken else {
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
        guard let token = AuthService.shared.accessToken else {
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
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/agency/\(insuranceId)/subscribers-details",
            method: .get,
            headers: headers
        )
    }
    
    func createRating(insuranceId: String, request: CreateRatingRequest) async throws -> Rating {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/\(insuranceId)/rating",
            method: .post,
            body: request,
            headers: headers
        )
    }
    
    func updateRating(insuranceId: String, request: UpdateRatingRequest) async throws -> Rating {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/\(insuranceId)/rating",
            method: .patch,
            body: request,
            headers: headers
        )
    }
    
    func deleteRating(insuranceId: String) async throws -> RatingDeleteResponse {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/\(insuranceId)/rating",
            method: .delete,
            headers: headers
        )
    }
    
    func getInsuranceRatings(insuranceId: String) async throws -> InsuranceRatingsResponse {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/\(insuranceId)/ratings",
            method: .get,
            headers: headers
        )
    }
    
    func getMyRating(insuranceId: String) async throws -> Rating? {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/\(insuranceId)/my-rating",
            method: .get,
            headers: headers
        )
    }
    
    func getAllRatingsForAgency() async throws -> AgencyRatingsResponse {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/agency/all-ratings",
            method: .get,
            headers: headers
        )
    }
    
    // MARK: - Insurance Applications
    
    /// Soumettre une demande d'assurance
    func submitApplication(insuranceId: String, request: CreateInsuranceApplicationRequest) async throws -> InsuranceApplication {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/\(insuranceId)/application",
            method: .post,
            body: request,
            headers: headers
        )
    }
    
    /// Récupérer mes demandes d'assurance
    func getMyApplications() async throws -> [InsuranceApplication] {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/my-applications",
            method: .get,
            headers: headers
        )
    }
    
    /// Récupérer toutes les demandes pour toutes les assurances de l'agence
    func getAllAgencyApplications() async throws -> [InsuranceApplication] {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/agency/applications",
            method: .get,
            headers: headers
        )
    }
    
    /// Récupérer les demandes pour une assurance spécifique
    func getInsuranceApplications(insuranceId: String) async throws -> [InsuranceApplication] {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/agency/\(insuranceId)/applications",
            method: .get,
            headers: headers
        )
    }
    
    /// Récupérer une demande par son ID
    func getApplicationById(applicationId: String) async throws -> InsuranceApplication {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/application/\(applicationId)",
            method: .get,
            headers: headers
        )
    }
    
    /// Approuver ou rejeter une demande (Agence)
    func reviewApplication(applicationId: String, request: ReviewApplicationRequest) async throws -> InsuranceApplication {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/agency/application/\(applicationId)/review",
            method: .patch,
            body: request,
            headers: headers
        )
    }
    
    /// Annuler une demande (Utilisateur)
    func cancelApplication(applicationId: String) async throws -> ApplicationCancelResponse {
        guard let token = AuthService.shared.accessToken else {
            throw NetworkService.NetworkError.unauthorized
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        return try await networkService.request(
            endpoint: "/insurances/application/\(applicationId)/cancel",
            method: .delete,
            headers: headers
        )
    }
}
