import Foundation

@MainActor
class ReservationService {
    static let shared = ReservationService()
    private let network = NetworkService.shared
    
    private init() {}
    
    // MARK: - Create Reservation (User)
    func createReservation(
        packId: String,
        adultsCount: Int,
        childrenCount: Int,
        totalPrice: Double
    ) async throws -> PackReservation {
        let dto = CreatePackReservationDto(
            packId: packId,
            adultsCount: adultsCount,
            childrenCount: childrenCount,
            totalPrice: totalPrice
        )
        
        let reservation: PackReservation = try await network.request(
            endpoint: "/reservations",
            method: .post,
            body: dto,
            requiresAuth: true
        )
        return reservation
    }
    
    // MARK: - Get User Reservations
    func getUserReservations() async throws -> [PackReservation] {
        let reservations: [PackReservation] = try await network.request(
            endpoint: "/reservations/user",
            method: .get,
            requiresAuth: true
        )
        return reservations
    }
    
    // MARK: - Get Agency Reservations
    func getAgencyReservations() async throws -> [PackReservation] {
        let reservations: [PackReservation] = try await network.request(
            endpoint: "/reservations/agency",
            method: .get,
            requiresAuth: true
        )
        return reservations
    }
    
    // MARK: - Accept Reservation
    func acceptReservation(id: String) async throws -> PackReservation {
        let reservation: PackReservation = try await network.request(
            endpoint: "/reservations/\(id)/accept",
            method: .put,
            requiresAuth: true
        )
        
        // TODO: Re-enable after adding NotificationService to Xcode project
        // await NotificationService.shared.scheduleReservationNotification(...)
        
        return reservation
    }
    
    // MARK: - Reject Reservation (Agency)
    func rejectReservation(id: String) async throws -> PackReservation {
        let dto = UpdateReservationStatusDto(status: .rejected)
        
        let reservation: PackReservation = try await network.request(
            endpoint: "/reservations/\(id)/reject",
            method: .put,
            body: dto,
            requiresAuth: true
        )
        
        // TODO: Re-enable after adding NotificationService to Xcode project
        // await NotificationService.shared.scheduleReservationNotification(...)
        
        return reservation
    }
    
    // MARK: - Cancel Reservation (User)
    func cancelReservation(id: String) async throws -> PackReservation {
        let dto = UpdateReservationStatusDto(status: .cancelled)
        
        let reservation: PackReservation = try await network.request(
            endpoint: "/reservations/\(id)/cancel",
            method: .put,
            body: dto,
            requiresAuth: true
        )
        return reservation
    }
    
    // MARK: - Get Single Reservation
    func getReservation(id: String) async throws -> PackReservation {
        let reservation: PackReservation = try await network.request(
            endpoint: "/reservations/\(id)",
            method: .get,
            requiresAuth: true
        )
        return reservation
    }
}

