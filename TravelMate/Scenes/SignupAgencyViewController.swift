import UIKit

class SignupAgencyViewController: UIViewController {
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
        imageView.image = UIImage(systemName: "building.2.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Compte Agence"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Inscrivez votre agence de voyage"
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
        textField.placeholder = "Nom du responsable"
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        // Padding handled by leftView and rightView
        
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
        // Padding handled by leftView and rightView
        
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
        // Padding handled by leftView and rightView
        
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
    
    private let agencyNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Nom de l'agence"
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        // Padding handled by leftView and rightView
        
        let iconView = UIImageView(image: UIImage(systemName: "building.2.fill"))
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
    
    private let agencyLicenseTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Numéro de licence"
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        // Padding handled by leftView and rightView
        
        let iconView = UIImageView(image: UIImage(systemName: "number"))
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
    
    private let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Téléphone"
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textField.borderStyle = .none
        textField.keyboardType = .phonePad
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        // Padding handled by leftView and rightView
        
        let iconView = UIImageView(image: UIImage(systemName: "phone.fill"))
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
    
    private let addressTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Adresse"
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        // Padding handled by leftView and rightView
        
        let iconView = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
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
    
    private let cityTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Ville"
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        // Padding handled by leftView and rightView
        
        let iconView = UIImageView(image: UIImage(systemName: "building.2"))
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
    
    private let countryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Pays"
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        // Padding handled by leftView and rightView
        
        let iconView = UIImageView(image: UIImage(systemName: "globe"))
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
    
    private let websiteTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Site web (optionnel)"
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textField.borderStyle = .none
        textField.keyboardType = .URL
        textField.autocapitalizationType = .none
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        // Padding handled by leftView and rightView
        
        let iconView = UIImageView(image: UIImage(systemName: "link"))
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
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return textView
    }()
    
    private let descriptionPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Description de l'agence (optionnel)"
        label.font = UIFont.systemFont(ofSize: 16)
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
            UIColor(red: 0.09, green: 0.45, blue: 0.82, alpha: 1.0).cgColor,
            UIColor(red: 0.40, green: 0.23, blue: 0.72, alpha: 1.0).cgColor
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
        formContainerView.addSubview(agencyNameTextField)
        formContainerView.addSubview(agencyLicenseTextField)
        formContainerView.addSubview(phoneTextField)
        formContainerView.addSubview(addressTextField)
        formContainerView.addSubview(cityTextField)
        formContainerView.addSubview(countryTextField)
        formContainerView.addSubview(websiteTextField)
        formContainerView.addSubview(descriptionTextView)
        descriptionTextView.addSubview(descriptionPlaceholder)
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
            
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 12),
            emailTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12),
            passwordTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            agencyNameTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12),
            agencyNameTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            agencyNameTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            agencyLicenseTextField.topAnchor.constraint(equalTo: agencyNameTextField.bottomAnchor, constant: 12),
            agencyLicenseTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            agencyLicenseTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            phoneTextField.topAnchor.constraint(equalTo: agencyLicenseTextField.bottomAnchor, constant: 12),
            phoneTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            phoneTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            addressTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 12),
            addressTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            addressTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            cityTextField.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: 12),
            cityTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            cityTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            countryTextField.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 12),
            countryTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            countryTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            websiteTextField.topAnchor.constraint(equalTo: countryTextField.bottomAnchor, constant: 12),
            websiteTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            websiteTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            descriptionTextView.topAnchor.constraint(equalTo: websiteTextField.bottomAnchor, constant: 12),
            descriptionTextView.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            descriptionTextView.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 14),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 16),
            
            signupButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 24),
            signupButton.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 24),
            signupButton.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -24),
            signupButton.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: -40)
        ])
        
        descriptionTextView.delegate = self
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
            showAlert(title: "Erreur", message: "Veuillez entrer le nom du responsable")
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Erreur", message: "Veuillez entrer l'email")
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
        
        guard let agencyName = agencyNameTextField.text, !agencyName.isEmpty else {
            showAlert(title: "Erreur", message: "Veuillez entrer le nom de l'agence")
            return
        }
        
        guard let agencyLicense = agencyLicenseTextField.text, !agencyLicense.isEmpty else {
            showAlert(title: "Erreur", message: "Veuillez entrer le numéro de licence")
            return
        }
        
        guard let phone = phoneTextField.text, !phone.isEmpty else {
            showAlert(title: "Erreur", message: "Veuillez entrer le numéro de téléphone")
            return
        }
        
        guard let address = addressTextField.text, !address.isEmpty else {
            showAlert(title: "Erreur", message: "Veuillez entrer l'adresse")
            return
        }
        
        guard let city = cityTextField.text, !city.isEmpty else {
            showAlert(title: "Erreur", message: "Veuillez entrer la ville")
            return
        }
        
        guard let country = countryTextField.text, !country.isEmpty else {
            showAlert(title: "Erreur", message: "Veuillez entrer le pays")
            return
        }
        
        let website = websiteTextField.text?.isEmpty == false ? websiteTextField.text : nil
        let description = descriptionTextView.text?.isEmpty == false ? descriptionTextView.text : nil
        
        Task {
            let loading = showLoading()
            
            do {
                _ = try await AuthService.shared.signupAgency(
                    name: name,
                    email: email,
                    password: password,
                    agencyName: agencyName,
                    agencyLicense: agencyLicense,
                    agencyWebsite: website,
                    phone: phone,
                    address: address,
                    city: city,
                    country: country,
                    agencyDescription: description
                )
                
                await MainActor.run {
                    loading.dismiss(animated: true) { [weak self] in
                        self?.showAlert(title: "Succès", message: "Compte agence créé avec succès! Votre compte est en attente de vérification. Vous pourrez vous connecter une fois votre compte vérifié.") {
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

extension SignupAgencyViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
    }
}
