import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    func showError(message: String) {
        showModernAlert(title: "Erreur", message: message, type: .info)
    }
    
    func showError(_ error: Error) {
        showModernAlert(title: "Erreur", message: error.localizedDescription, type: .info)
    }
    
    func showSuccess(message: String, completion: (() -> Void)? = nil) {
        showModernAlert(title: "Succès", message: message, type: .success, completion: completion)
    }
    
    func showModernAlert(title: String, message: String, type: AlertType = .info, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.view.tintColor = type.color
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        
        present(alert, animated: true)
    }
    
    func showConfirmation(title: String, message: String, confirmTitle: String = "Confirmer", cancelTitle: String = "Annuler", onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default) { _ in
            onConfirm()
        })
        
        present(alert, animated: true)
    }
    
    func showLoading() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Chargement...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.color = .primaryColor
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true)
        return alert
    }
}

enum AlertType {
    case success
    case warning
    case info
    
    var color: UIColor {
        switch self {
        case .success: return .successColor
        case .warning: return .warningColor
        case .info: return .infoColor
        }
    }
}

extension UITextField {
    func addPadding(left: CGFloat = 12, right: CGFloat = 12) {
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: frame.height))
        self.leftView = leftView
        self.leftViewMode = .always
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: frame.height))
        self.rightView = rightView
        self.rightViewMode = .always
    }
    
    func styleModern() {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.borderColor.cgColor
        backgroundColor = .surfaceColor
        font = UIFont.systemFont(ofSize: 16)
        textColor = .textPrimary
        addPadding(left: 16, right: 16)
    }
}

extension UIButton {
    func stylePrimary() {
        backgroundColor = .primaryColor
        setTitleColor(.textLight, for: .normal)
        layer.cornerRadius = 12
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        layer.shadowColor = UIColor.primaryColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3
    }
    
    func styleSecondary() {
        backgroundColor = .surfaceColor
        setTitleColor(.primaryColor, for: .normal)
        layer.cornerRadius = 12
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.primaryColor.cgColor
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    func styleCancel() {
        backgroundColor = .backgroundLight
        setTitleColor(.textSecondary, for: .normal)
        layer.cornerRadius = 12
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
}

