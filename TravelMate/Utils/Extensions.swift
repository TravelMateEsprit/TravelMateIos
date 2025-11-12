import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    func showError(_ error: Error) {
        showAlert(title: "Erreur", message: error.localizedDescription)
    }
    
    func showLoading() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Chargement...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true)
        return alert
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
}

extension UIColor {
    static let primaryColor = UIColor(red: 0.2, green: 0.6, blue: 0.86, alpha: 1.0)
    static let secondaryColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
}
