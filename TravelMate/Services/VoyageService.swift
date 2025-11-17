import Foundation

@MainActor
class VoyageService {
    static let shared = VoyageService()
    
    var voyages: [Voyage] = []
    var reservations: [Reservation] = []
    var isLoading = false
    var isReservationsLoading = false
    var errorMessage: String?
    
    private let networkService = NetworkService.shared
    
    private init() {}
    
    var currentUserId: String? {
        return AuthService.shared.currentUser?.id
    }
    
    // MARK: - Fetch all voyages
    func fetchVoyages() async {
        print("🚀 [VOYAGE SERVICE] fetchVoyages called")
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let fetchedVoyages: [Voyage] = try await networkService.request(
                endpoint: "/voyages",
                method: .get,
                requiresAuth: true
            )
            print("✅ [VOYAGE SERVICE] Fetched \(fetchedVoyages.count) voyages")
            voyages = fetchedVoyages
        } catch {
            errorMessage = error.localizedDescription
            print("❌ [VOYAGE SERVICE] Error fetching voyages: \(error)")
        }
    }
    
    // MARK: - Fetch single voyage
    func fetchVoyage(id: String) async throws -> Voyage {
        let voyage: Voyage = try await networkService.request(
            endpoint: "/voyages/\(id)",
            method: .get,
            requiresAuth: true
        )
        return voyage
    }
    
    // MARK: - Create voyage
    func createVoyage(_ dto: CreateVoyageDto) async throws -> Voyage {
        print("🚀 [VOYAGE SERVICE] createVoyage called")
        print("📦 [VOYAGE SERVICE] DTO: \(dto)")
        
        do {
            let voyage: Voyage = try await networkService.request(
                endpoint: "/voyages",
                method: .post,
                body: dto,
                requiresAuth: true
            )
            print("✅ [VOYAGE SERVICE] Voyage created successfully: \(voyage.id)")
            // Add to list optimistically
            voyages.insert(voyage, at: 0)
            return voyage
        } catch {
            print("❌ [VOYAGE SERVICE] Error creating voyage: \(error)")
            throw error
        }
    }
    
    // MARK: - Update voyage
    func updateVoyage(id: String, _ dto: UpdateVoyageDto) async throws -> Voyage {
        print("🚀 [VOYAGE SERVICE] updateVoyage called for ID: \(id)")
        print("📦 [VOYAGE SERVICE] Update DTO: \(dto)")
        
        // Log the DTO being sent
        if let jsonData = try? JSONEncoder().encode(dto),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 [VOYAGE SERVICE] Sending update DTO: \(jsonString)")
        }
        
        do {
            let voyage: Voyage = try await networkService.request(
                endpoint: "/voyages/\(id)",
                method: .patch,
                body: dto,
                requiresAuth: true
            )
            print("✅ [VOYAGE SERVICE] Voyage updated successfully")
            print("   - Updated voyage ID: \(voyage.id)")
            print("   - Destination: \(voyage.destination)")
            
            // Update in list
            if let index = voyages.firstIndex(where: { $0.id == id }) {
                voyages[index] = voyage
                print("✅ [VOYAGE SERVICE] Voyage updated in local list")
            } else {
                print("⚠️ [VOYAGE SERVICE] Voyage not found in local list, adding it")
                voyages.insert(voyage, at: 0)
            }
            return voyage
        } catch {
            print("❌ [VOYAGE SERVICE] Error updating voyage:")
            print("   - Error type: \(type(of: error))")
            print("   - Error: \(error)")
            if let networkError = error as? NetworkService.NetworkError {
                print("   - Network error: \(networkError)")
            }
            throw error
        }
    }
    
    // MARK: - Delete voyage
    func deleteVoyage(id: String) async throws {
        print("🚀 [VOYAGE SERVICE] deleteVoyage called for ID: \(id)")
        do {
            // Backend might return empty response (204) or the deleted voyage
            // NetworkService handles 204 automatically for EmptyResponse
            // Using EmptyResponse for endpoints that might return empty responses
            let _: EmptyResponse = try await networkService.request(
                endpoint: "/voyages/\(id)",
                method: .delete,
                requiresAuth: true
            )
            print("✅ [VOYAGE SERVICE] Voyage deleted successfully")
            // Remove from list
            voyages.removeAll { $0.id == id }
            print("✅ [VOYAGE SERVICE] Voyage removed from local list")
        } catch let error as NetworkService.NetworkError {
            // If it's a decoding error and status was 200/204, consider it success
            if case .decodingError = error {
                print("⚠️ [VOYAGE SERVICE] Decoding error, but delete might have succeeded")
                // Still remove from list optimistically
                voyages.removeAll { $0.id == id }
                print("✅ [VOYAGE SERVICE] Voyage removed from local list (optimistic)")
                // Don't throw - consider it a success
                return
            }
            print("❌ [VOYAGE SERVICE] Error deleting voyage: \(error)")
            throw error
        } catch {
            print("❌ [VOYAGE SERVICE] Error deleting voyage:")
            print("   - Error type: \(type(of: error))")
            print("   - Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Join voyage
    func joinVoyage(id: String) async throws -> Voyage {
        let voyage: Voyage = try await networkService.request(
            endpoint: "/voyages/\(id)/join",
            method: .post,
            requiresAuth: true
        )
        
        // Update in list
        if let index = voyages.firstIndex(where: { $0.id == id }) {
            voyages[index] = voyage
        }
        
        return voyage
    }
    
    // MARK: - Leave voyage
    func leaveVoyage(id: String) async throws -> Voyage {
        let voyage: Voyage = try await networkService.request(
            endpoint: "/voyages/\(id)/leave",
            method: .post,
            requiresAuth: true
        )
        
        // Update in list
        if let index = voyages.firstIndex(where: { $0.id == id }) {
            voyages[index] = voyage
        }
        
        return voyage
    }
    
    // MARK: - Create reservation
    func createReservation(_ dto: CreateReservationDto) async throws {
        print("🚀 [VOYAGE SERVICE] createReservation called")
        print("📦 [VOYAGE SERVICE] Reservation DTO:")
        print("   - id_voyage: \(dto.id_voyage)")
        print("   - prix: \(dto.prix)")
        print("   - nombre_personnes: \(dto.nombre_personnes)")
        print("   - notes: \(dto.notes ?? "nil")")
        
        // Log the raw JSON being sent
        if let jsonData = try? JSONEncoder().encode(dto),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 [NETWORK] Sending JSON: \(jsonString)")
        }
        
        do {
            // Using EmptyResponse for endpoints that might return empty responses
            let _: EmptyResponse = try await networkService.request(
                endpoint: "/reservations",
                method: .post,
                body: dto,
                requiresAuth: true
            )
            print("✅ [VOYAGE SERVICE] Reservation created successfully")
            // Refresh reservations list after creation
            await fetchReservations()
        } catch {
            print("❌ [VOYAGE SERVICE] Error creating reservation:")
            print("   - Error type: \(type(of: error))")
            print("   - Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Fetch reservations
    func fetchReservations() async {
        print("🔍 [VOYAGE SERVICE] Fetching reservations...")
        isReservationsLoading = true
        errorMessage = nil
        defer { 
            isReservationsLoading = false
            print("✅ [VOYAGE SERVICE] Finished fetching reservations. Found \(reservations.count) reservations")
        }
        
        do {
            let fetchedReservations: [Reservation] = try await networkService.request(
                endpoint: "/reservations",
                method: .get,
                requiresAuth: true
            )
            
            print("📥 [VOYAGE SERVICE] Successfully fetched \(fetchedReservations.count) reservations")
            if fetchedReservations.isEmpty {
                print("ℹ️ [VOYAGE SERVICE] No reservations found. The list is empty.")
            } else {
                fetchedReservations.forEach { reservation in
                    print("   - ID: \(reservation.id), Voyage: \(reservation.voyage_id.destination), Status: \(reservation.statut)")
                }
            }
            
            // Update on main thread since we're using @Published
            await MainActor.run {
                self.reservations = fetchedReservations
            }
            
        } catch let error as NetworkService.NetworkError {
            let errorMessage: String
            
            switch error {
            case .unauthorized:
                errorMessage = "Session expirée. Veuillez vous reconnecter."
            case .serverError(let message):
                errorMessage = message
            case .decodingError:
                errorMessage = "Erreur de décodage des données reçues du serveur."
            default:
                errorMessage = error.localizedDescription
            }
            
            print("❌ [VOYAGE SERVICE] \(errorMessage)")
            
            await MainActor.run {
                self.errorMessage = errorMessage
            }
            
        } catch {
            let errorMessage = "Erreur inattendue: \(error.localizedDescription)"
            print("❌ [VOYAGE SERVICE] \(errorMessage)")
            print("   - Error type: \(type(of: error))")
            
            await MainActor.run {
                self.errorMessage = errorMessage
            }
        }
    }
    
    // MARK: - Refresh single voyage
    func refreshVoyage(id: String) async {
        do {
            let voyage = try await fetchVoyage(id: id)
            if let index = voyages.firstIndex(where: { $0.id == id }) {
                voyages[index] = voyage
            }
        } catch {
            print("Error refreshing voyage: \(error)")
        }
    }
}


