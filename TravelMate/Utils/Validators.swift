import Foundation
import UIKit

class Validators {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func isValidPassword(_ password: String) -> (Bool, String?) {
        if password.count < 6 {
            return (false, "Le mot de passe doit contenir au moins 6 caractères")
        }
        
        let numberRegex = ".*[0-9]+.*"
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        if !numberPredicate.evaluate(with: password) {
            return (false, "Le mot de passe doit contenir au moins un chiffre")
        }
        
        return (true, nil)
    }
    
    static func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
}
