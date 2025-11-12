import UIKit

class SplashViewController: UIViewController {
    private let gradientLayer = CAGradientLayer()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "airplane.departure")
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
            UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0).cgColor,
            UIColor(red: 0.1, green: 0.4, blue: 0.7, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        view.addSubview(logoImageView)
        view.addSubview(logoLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(activityIndicator)
        
        logoImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            logoLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            logoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            subtitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 12),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            activityIndicator.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func animateAppearance() {
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.logoImageView.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.4) {
            self.logoLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.6) {
            self.subtitleLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 0.4, delay: 1.0) {
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
        let mainTabBar = MainTabBarController()
        mainTabBar.modalPresentationStyle = .fullScreen
        mainTabBar.modalTransitionStyle = .crossDissolve
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = mainTabBar
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
        
        if let token = AuthService.shared.accessToken {
            WebSocketService.shared.connect(token: token)
        }
    }
}
