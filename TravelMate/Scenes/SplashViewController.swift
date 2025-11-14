import UIKit

class SplashViewController: UIViewController {
    private let gradientLayer = CAGradientLayer()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        if let logo = UIImage(named: "AppLogo") {
            imageView.image = logo
        }
        imageView.layer.cornerRadius = 75
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "TravelMate"
        label.font = UIFont.systemFont(ofSize: 52, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Votre compagnon de voyage"
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.alpha = 0
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        animateAppearance()
        checkAuthentication()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupUI() {
        gradientLayer.colors = [
            UIColor(red: 0.09, green: 0.45, blue: 0.82, alpha: 1.0).cgColor,
            UIColor(red: 0.40, green: 0.23, blue: 0.72, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        view.addSubview(logoImageView)
        view.addSubview(logoLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(activityIndicator)
        
        logoImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        logoImageView.alpha = 0
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.heightAnchor.constraint(equalToConstant: 150),
            
            logoLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            logoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            subtitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 12),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            activityIndicator.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 48),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func animateAppearance() {
        UIView.animate(withDuration: 1.0, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: .curveEaseOut) {
            self.logoImageView.transform = .identity
            self.logoImageView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.8, delay: 0.5) {
            self.logoLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 0.8, delay: 0.7) {
            self.subtitleLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 1.2) {
            self.activityIndicator.alpha = 1
            self.activityIndicator.startAnimating()
        }
    }
    
    private func checkAuthentication() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if AuthService.shared.isAuthenticated {
                self?.navigateToMain()
            } else {
                self?.navigateToLogin()
            }
        }
    }
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .crossDissolve
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = navController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    private func navigateToMain() {
        guard let user = AuthService.shared.currentUser else {
            navigateToLogin()
            return
        }
        
        let destinationVC: UIViewController
        
        if user.userType == .agence {
            destinationVC = AgencyDashboardViewController()
        } else {
            destinationVC = MainTabBarController()
        }
        
        destinationVC.modalPresentationStyle = .fullScreen
        destinationVC.modalTransitionStyle = .crossDissolve
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = destinationVC
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
        
        if let token = AuthService.shared.accessToken {
            WebSocketService.shared.connect(token: token)
        }
    }
}
