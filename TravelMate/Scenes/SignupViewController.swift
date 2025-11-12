import UIKit

class SignupViewController: UIViewController {
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
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "person.badge.plus.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Créer un compte"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rejoignez TravelMate"
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
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Nom complet"
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        let iconView = UIImageView(image: UIImage(systemName: "person.fill"))
        iconView.tintColor = .systemGray
        iconView.frame = CGRect(x: 0, y: 0, width: 40, height: 24)
        iconView.contentMode = .center
        textField.leftView = iconView
        textField.leftViewMode = .always
        
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
        textField.rightView = rightPadding
        textField.rightViewMode = .always
        
        return textField
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
        
        let iconView = UIImageView(image: UIImage(systemName: "envelope.fill"))
        iconView.tintColor = .systemGray
        iconView.frame = CGRect(x: 0, y: 0, width: 40, height: 24)
        iconView.contentMode = .center
        textField.leftView = iconView
        textField.leftViewMode = .always
        
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
        textField.rightView = rightPadding
        textField.rightViewMode = .always
        
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
        
        let iconView = UIImageView(image: UIImage(systemName: "lock.fill"))
        iconView.tintColor = .systemGray
        iconView.frame = CGRect(x: 0, y: 0, width: 40, height: 24)
        iconView.contentMode = .center
        textField.leftView = iconView
        textField.leftViewMode = .always
        
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
        textField.rightView = rightPadding
        textField.rightViewMode = .always
        
        return textField
    }()
    
    private let passwordHintLabel: UILabel = {
        let label = UILabel()
        label.text = "Min. 6 caractères, 1 chiffre"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("S'inscrire", for: .normal)
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
            UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0).cgColor,
            UIColor(red: 0.1, green: 0.4, blue: 0.7, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        backButton.layer.cornerRadius = 20
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        view.addSubview(scrollView)
        view.addSubview(backButton)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        headerView.addSubview(logoImageView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        contentView.addSubview(formContainerView)
        formContainerView.addSubview(nameTextField)
        formContainerView.addSubview(emailTextField)
        formContainerView.addSubview(passwordTextField)
        formContainerView.addSubview(passwordHintLabel)
        formContainerView.addSubview(signupButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            logoImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 60),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -32),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -32),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            formContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 40),
            formContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            formContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            formContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: formContainerView.topAnchor, constant: 32),
            nameTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            nameTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            passwordHintLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 8),
            passwordHintLabel.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 40),
            
            signupButton.topAnchor.constraint(equalTo: passwordHintLabel.bottomAnchor, constant: 24),
            signupButton.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            signupButton.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            signupButton.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupActions() {
        signupButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
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
    
    @objc private func handleSignup() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Erreur", message: "Veuillez entrer votre nom")
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Erreur", message: "Veuillez entrer votre email")
            return
        }
        
        guard Validators.isValidEmail(email) else {
            showAlert(title: "Erreur", message: "Email invalide")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Erreur", message: "Veuillez entrer un mot de passe")
            return
        }
        
        let (isValid, errorMessage) = Validators.isValidPassword(password)
        guard isValid else {
            showAlert(title: "Erreur", message: errorMessage ?? "Mot de passe invalide")
            return
        }
        
        Task {
            let loading = showLoading()
            
            do {
                _ = try await AuthService.shared.signup(name: name, email: email, password: password)
                
                await MainActor.run {
                    loading.dismiss(animated: true) { [weak self] in
                        self?.showAlert(title: "Succès", message: "Compte créé avec succès! Vous pouvez maintenant vous connecter.") {
                            self?.navigationController?.popViewController(animated: true)
                        }
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
}
