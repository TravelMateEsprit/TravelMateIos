import Foundation
import PassKit

class PaymentService {
    static let shared = PaymentService()
    
    private let merchantIdentifier = "merchant.com.travelmate" // TODO: Configure with your Apple Pay merchant ID
    
    private init() {}
    
    // MARK: - Payment Methods
    
    /// Check if Apple Pay is available
    func isApplePayAvailable() -> Bool {
        return PKPaymentAuthorizationController.canMakePayments()
    }
    
    
    // Store delegate to prevent deallocation
    private var paymentDelegate: PaymentDelegate?
    
    /// Process payment for a reservation
    func processPayment(
        for reservation: PackReservation,
        completion: @escaping (Result<PaymentResult, Error>) -> Void
    ) {
        // Create payment request
        let request = createPaymentRequest(for: reservation)
        
        // Create and store delegate
        paymentDelegate = PaymentDelegate(completion: completion)
        
        // Show Apple Pay sheet
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = paymentDelegate
        controller.present { presented in
            if !presented {
                completion(.failure(PaymentError.presentationFailed))
            }
        }
    }
    
    /// Process payment with custom integration (Stripe, PayPal, etc.)
    func processWebPayment(
        for reservation: PackReservation,
        completion: @escaping (Result<PaymentResult, Error>) -> Void
    ) {
        // TODO: Integrate with  your payment gateway (Stripe, PayPal, etc.)
        // For now, simulate payment process
        
        Task {
            do {
                // Call backend to create payment session
                let paymentData = try await NetworkService.shared.request(
                    endpoint: "/payments/create",
                    method: .post,
                    body: [
                        "reservationId": reservation.id ?? "",
                        "amount": String(reservation.totalPrice),
                        "currency": "TND"
                    ],
                    requiresAuth: true
                ) as PaymentSessionResponse
                
                // Open payment URL in Safari or WebView
                if let url = URL(string: paymentData.paymentUrl) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url)
                        completion(.success(PaymentResult(
                            transactionId: paymentData.sessionId,
                            status: "pending",
                            method: "web"
                        )))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createPaymentRequest(for reservation: PackReservation) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantIdentifier
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "TN"  // Tunisia
        request.currencyCode = "TND"  // Tunisian Dinar
        
        // Payment summary items
        let packItem = PKPaymentSummaryItem(
            label: reservation.pack?.titre ?? "Pack Voyage",
            amount: NSDecimalNumber(value: reservation.totalPrice)
        )
        
        let total = PKPaymentSummaryItem(
            label: "TravelMate",
            amount: NSDecimalNumber(value: reservation.totalPrice)
        )
        
        request.paymentSummaryItems = [packItem, total]
        
        return request
    }
}

// MARK: - Payment Delegate
private class PaymentDelegate: NSObject, PKPaymentAuthorizationControllerDelegate {
    private let completion: (Result<PaymentResult, Error>) -> Void
    
    init(completion: @escaping (Result<PaymentResult, Error>) -> Void) {
        self.completion = completion
    }
    
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        // Process payment with backend
        Task {
            do {
                // Send payment token to backend
                let paymentToken = String(data: payment.token.paymentData, encoding: .utf8) ?? ""
                
                let result = try await NetworkService.shared.request(
                    endpoint: "/payments/process",
                    method: .post,
                    body: [
                        "paymentToken": paymentToken,
                        "paymentMethod": "apple_pay"
                    ],
                    requiresAuth: true
                ) as PaymentProcessResponse
                
                self.completion(.success(PaymentResult(
                    transactionId: result.transactionId,
                    status: result.status,
                    method: "apple_pay"
                )))
                
                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            } catch {
                self.completion(.failure(error))
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
            }
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss()
    }
}

// MARK: - Data Models

struct PaymentResult {
    let transactionId: String
    let status: String
    let method: String
}

struct PaymentSessionResponse: Codable {
    let sessionId: String
    let paymentUrl: String
}

struct PaymentProcessResponse: Codable {
    let transactionId: String
    let status: String
}

enum PaymentError: Error {
    case presentationFailed
    case cancelled
    case processingFailed
    case invalidAmount
    
    var localizedDescription: String {
        switch self {
        case .presentationFailed:
            return "Impossible d'afficher le paiement"
        case .cancelled:
            return "Paiement annulé"
        case .processingFailed:
            return "Échec du traitement du paiement"
        case .invalidAmount:
            return "Montant de paiement invalide"
        }
    }
}
