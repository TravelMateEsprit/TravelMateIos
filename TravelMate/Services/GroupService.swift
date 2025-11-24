import Foundation

@MainActor
class GroupService {
    static let shared = GroupService()
    
    var groups: [Group] = []  // ← Group doit être reconnu ici
    var isLoading = false
    var errorMessage: String?
    
    private let networkService = NetworkService.shared
    
    private init() {}
    
    var currentUserId: String? {
        return AuthService.shared.currentUser?.id
    }
    
    // MARK: - Fetch all groups
    func fetchGroups() async {
        print("🚀 [GROUP SERVICE] fetchGroups called")
        print("📍 [GROUP SERVICE] API Base URL: \(Config.apiBaseURL)")
        print("📍 [GROUP SERVICE] Endpoint: /groupes")
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let fetchedGroups: [Group] = try await networkService.request(
                endpoint: "/groupes",
                method: .get,
                requiresAuth: true
            )
            print("✅ [GROUP SERVICE] Fetched \(fetchedGroups.count) groups")
            groups = fetchedGroups
        } catch {
            errorMessage = error.localizedDescription
            print("❌ [GROUP SERVICE] Error fetching groups:")
            print("   - Error type: \(type(of: error))")
            print("   - Error: \(error)")
            if let networkError = error as? NetworkService.NetworkError {
                print("   - Network error: \(networkError.localizedDescription)")
            }
        }
    }
    
    // MARK: - Fetch single group
    func fetchGroup(id: String) async throws -> Group {
        print("🚀 [GROUP SERVICE] fetchGroup called for ID: \(id)")
        print("📍 [GROUP SERVICE] Endpoint: /groupes/\(id)")
        
        let group: Group = try await networkService.request(
            endpoint: "/groupes/\(id)",
            method: .get,
            requiresAuth: true
        )
        print("✅ [GROUP SERVICE] Group fetched: \(group.id)")
        return group
    }
    
    // MARK: - Create group
    func createGroup(_ dto: CreateGroupDto) async throws -> Group {
        print("🚀 [GROUP SERVICE] createGroup called")
        print("📍 [GROUP SERVICE] API Base URL: \(Config.apiBaseURL)")
        print("📍 [GROUP SERVICE] Endpoint: /groupes")
        print("📦 [GROUP SERVICE] DTO:")
        print("   - nom: \(dto.nom)")
        print("   - destination: \(dto.destination)")
        print("   - description: \(dto.description ?? "nil")")
        print("   - photoUrl: \(dto.photoUrl ?? "nil")")
        
        // Vérifier l'authentification
        guard let userId = currentUserId else {
            print("❌ [GROUP SERVICE] No user ID - user not authenticated")
            throw NetworkService.NetworkError.unauthorized
        }
        print("🔐 [GROUP SERVICE] User ID: \(userId)")
        
        guard let token = AuthService.shared.accessToken else {
            print("❌ [GROUP SERVICE] No access token")
            throw NetworkService.NetworkError.unauthorized
        }
        print("🔐 [GROUP SERVICE] Token present: \(String(token.prefix(20)))...")
        
        do {
            let group: Group = try await networkService.request(
                endpoint: "/groupes",
                method: .post,
                body: dto,
                requiresAuth: true
            )
            print("✅ [GROUP SERVICE] Group created successfully")
            print("   - Group ID: \(group.id)")
            print("   - Group name: \(group.nom)")
            groups.insert(group, at: 0)
            return group
        } catch {
            print("❌ [GROUP SERVICE] Error creating group:")
            print("   - Error type: \(type(of: error))")
            print("   - Error: \(error)")
            if let networkError = error as? NetworkService.NetworkError {
                print("   - Network error: \(networkError.localizedDescription)")
            } else if let urlError = error as? URLError {
                print("   - URL Error code: \(urlError.code.rawValue)")
                print("   - URL Error: \(urlError.localizedDescription)")
                
                // Donner des messages d'erreur plus clairs
                switch urlError.code {
                case .notConnectedToInternet:
                    throw NetworkService.NetworkError.serverError("Pas de connexion Internet")
                case .cannotConnectToHost, .cannotFindHost:
                    throw NetworkService.NetworkError.serverError("Impossible de se connecter au serveur. Vérifiez que le backend est démarré sur \(Config.apiBaseURL)")
                case .timedOut:
                    throw NetworkService.NetworkError.serverError("La requête a expiré. Le serveur ne répond pas.")
                default:
                    throw NetworkService.NetworkError.serverError("Erreur réseau: \(urlError.localizedDescription)")
                }
            }
            throw error
        }
    }
    
    // MARK: - Update group
    func updateGroup(id: String, _ dto: UpdateGroupDto) async throws -> Group {
        print("🚀 [GROUP SERVICE] updateGroup called for ID: \(id)")
        print("📍 [GROUP SERVICE] Endpoint: /groupes/\(id)")
        print("📦 [GROUP SERVICE] Update DTO:")
        print("   - nom: \(dto.nom ?? "nil")")
        print("   - destination: \(dto.destination ?? "nil")")
        print("   - description: \(dto.description ?? "nil")")
        print("   - photoUrl: \(dto.photoUrl ?? "nil")")
        
        do {
            let group: Group = try await networkService.request(
                endpoint: "/groupes/\(id)",
                method: .patch,
                body: dto,
                requiresAuth: true
            )
            print("✅ [GROUP SERVICE] Group updated successfully")
            
            if let index = groups.firstIndex(where: { $0.id == id }) {
                groups[index] = group
                print("✅ [GROUP SERVICE] Group updated in local list")
            }
            return group
        } catch {
            print("❌ [GROUP SERVICE] Error updating group:")
            print("   - Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Delete group
    func deleteGroup(id: String) async throws {
        print("🚀 [GROUP SERVICE] deleteGroup called for ID: \(id)")
        print("📍 [GROUP SERVICE] Endpoint: /groupes/\(id)")
        
        do {
            let _: EmptyResponse = try await networkService.request(
                endpoint: "/groupes/\(id)",
                method: .delete,
                requiresAuth: true
            )
            
            groups.removeAll { $0.id == id }
            print("✅ [GROUP SERVICE] Group deleted and removed from list")
        } catch {
            print("❌ [GROUP SERVICE] Error deleting group:")
            print("   - Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Join group
    func joinGroup(id: String) async throws -> Group {
        print("🚀 [GROUP SERVICE] joinGroup called for ID: \(id)")
        print("📍 [GROUP SERVICE] Endpoint: /groupes/\(id)/rejoindre")
        
        do {
            let group: Group = try await networkService.request(
                endpoint: "/groupes/\(id)/rejoindre",
                method: .post,
                requiresAuth: true
            )
            print("✅ [GROUP SERVICE] Successfully joined group")
            
            if let index = groups.firstIndex(where: { $0.id == id }) {
                groups[index] = group
            }
            return group
        } catch {
            print("❌ [GROUP SERVICE] Error joining group:")
            print("   - Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Leave group
    func leaveGroup(id: String) async throws -> Group {
        print("🚀 [GROUP SERVICE] leaveGroup called for ID: \(id)")
        print("📍 [GROUP SERVICE] Endpoint: /groupes/\(id)/quitter")
        
        do {
            let group: Group = try await networkService.request(
                endpoint: "/groupes/\(id)/quitter",
                method: .post,
                requiresAuth: true
            )
            print("✅ [GROUP SERVICE] Successfully left group")
            
            if let index = groups.firstIndex(where: { $0.id == id }) {
                groups[index] = group
            }
            return group
        } catch {
            print("❌ [GROUP SERVICE] Error leaving group:")
            print("   - Error: \(error)")
            throw error
        }
    }
}
