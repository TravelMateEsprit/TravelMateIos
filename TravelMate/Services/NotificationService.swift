import Foundation
import UserNotifications
import UIKit
import UserNotificationsUI

@MainActor
class NotificationService: NSObject {
    static let shared = NotificationService()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Request Notification Permission
    func requestPermission() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        return try await withCheckedThrowingContinuation { continuation in
            center.requestAuthorization(options: options) { granted, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    // MARK: - Register for Remote Notifications
    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // MARK: - Local Notifications (for testing and offline scenarios)
    
    func scheduleReservationNotification(packTitle: String, status: String, isAccepted: Bool) {
        let content = UNMutableNotificationContent()
        content.title = "Réservation \(isAccepted ? "Acceptée" : "Refusée")"
        content.body = "Votre réservation pour \(packTitle) a été \(status)."
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            } else {
                print("✅ Notification scheduled")
            }
        }
    }
    
    func scheduleNewMessageNotification(from: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Nouveau message de \(from)"
        content.body = message
        content.sound = .default
        content.badge = NSNumber(value: getBadgeCount() + 1)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            }
        }
    }
    
    func scheduleNewReservationNotification(packTitle: String, clientName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Nouvelle réservation"
        content.body = "\(clientName) souhaite réserver \(packTitle)"
        content.sound = .default
        content.badge = NSNumber(value: getBadgeCount() + 1)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            }
        }
    }
    
    // MARK: - Badge Management
    
    func setBadgeCount(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
    func getBadgeCount() -> Int {
        return UIApplication.shared.applicationIconBadgeNumber
    }
    
    func incrementBadge() {
        setBadgeCount(getBadgeCount() + 1)
    }
    
    func decrementBadge() {
        let current = getBadgeCount()
        setBadgeCount(max(0, current - 1))
    }
    
    func clearBadge() {
        setBadgeCount(0)
    }
    
    // MARK: - Clear Notifications
    
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        clearBadge()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    
    // Called when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Called when user taps on notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped: \(userInfo)")
        
        completionHandler()
    }
}
