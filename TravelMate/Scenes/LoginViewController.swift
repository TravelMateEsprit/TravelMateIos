import UIKit

class LoginViewController: UIViewController {
    private let gradientLayer = CAGradientLayer()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "airplane.departure")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Bienvenue"
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Connectez-vous pour continuer"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.9)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let formContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textField.borderStyle = .none
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        textField.addPadding(left: 16, right: 16)
        
        let iconView = UIImageView(image: UIImage(systemName: "envelope.fill"))
        iconView.tintColor = .systemGray
        iconView.frame = CGRect(x: 0, y: 0, width: 40, height: 24)
        iconView.contentMode = .center
        textField.leftView = iconView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Mot de passe"
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        textField.addPadding(left: 16, right: 16)
        
        let iconView = UIImageView(image: UIImage(systemName: "lock.fill"))
        iconView.tintColor = .systemGray
        iconView.frame = CGRect(x: 0, y: 0, width: 40, height: 24)
        iconView.contentMode = .center
        textField.leftView = iconView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Se connecter", for: .normal)
        button.backgroundColor = .primaryColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.primaryColor.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()
    
    private let dividerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let leftLine = UIView()
        leftLine.backgroundColor = .systemGray4
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        
        let rightLine = UIView()
        rightLine.backgroundColor = .systemGray4
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "ou"
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(leftLine)
        container.addSubview(rightLine)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            leftLine.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            leftLine.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            leftLine.heightAnchor.constraint(equalToConstant: 1),
            leftLine.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -12),
            
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            rightLine.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12),
            rightLine.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            rightLine.heightAnchor.constraint(equalToConstant: 1),
            rightLine.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            container.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return container
    }()
    
    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Créer un compte utilisateur", for: .normal)
        button.setTitleColor(.primaryColor, for: .normal)
        button.backgroundColor = .primaryColor.withAlphaComponent(0.1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 28
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.primaryColor.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()
    
    private let signupAgencyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Créer un compte agence", for: .normal)
        button.setTitleColor(.primaryColor, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupKeyboardHandling()
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
        
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(formContainerView)
        formContainerView.addSubview(emailTextField)
        formContainerView.addSubview(passwordTextField)
        formContainerView.addSubview(loginButton)
        formContainerView.addSubview(dividerView)
        formContainerView.addSubview(signupButton)
        formContainerView.addSubview(signupAgencyButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 70),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 70),
            logoImageView.heightAnchor.constraint(equalToConstant: 70),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            formContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 48),
            formContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            formContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            formContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: formContainerView.topAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
            loginButton.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            dividerView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 32),
            dividerView.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            dividerView.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            signupButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 32),
            signupButton.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            signupButton.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            signupAgencyButton.topAnchor.constraint(equalTo: signupButton.bottomAnchor, constant: 20),
            signupAgencyButton.centerXAnchor.constraint(equalTo: formContainerView.centerXAnchor),
            signupAgencyButton.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: -48)
        ])
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        signupAgencyButton.addTarget(self, action: #selector(handleSignupAgency), for: .touchUpInside)
        
        loginButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        loginButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside])
        
        signupButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        signupButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside])
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
    
    @objc private func handleLogin() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Erreur", message: "Veuillez entrer votre email")
            return
        }
        
        guard Validators.isValidEmail(email) else {
            showAlert(title: "Erreur", message: "Email invalide")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Erreur", message: "Veuillez entrer votre mot de passe")
            return
        }
        
        Task {
            let loading = showLoading()
            
            do {
                _ = try await AuthService.shared.login(email: email, password: password)
                
                await MainActor.run {
                    loading.dismiss(animated: true) { [weak self] in
                        self?.navigateToMain()
                    }
                }
            } catch {
                await MainActor.run {
                    loading.dismiss(animated: true) { [weak self] in
                        self?.showError(error)
                    }
                }
            }
        }
    }
    
    @objc private func handleSignup() {
        let signupVC = SignupViewController()
        navigationController?.pushViewController(signupVC, animated: true)
    }
    
    @objc private func handleSignupAgency() {
        let signupAgencyVC = SignupAgencyViewController()
        navigationController?.pushViewController(signupAgencyVC, animated: true)
    }
    
    private func navigateToMain() {
        guard let user = AuthService.shared.currentUser else {
            return
        }
        
        let destinationVC: UIViewController
        
        if user.userType == .agence {
            destinationVC = AgencyDashboardViewController()
        } else {
            destinationVC = MainTabBarController()
        }
        
        destinationVC.modalPresentationStyle = .fullScreen
        
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
