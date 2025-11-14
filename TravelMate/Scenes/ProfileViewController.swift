import UIKit

class ProfileViewController: UIViewController {
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
        view.backgroundColor = UIColor(red: 0.09, green: 0.45, blue: 0.82, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 50
        view.layer.borderWidth = 4
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = UIColor(red: 0.09, green: 0.45, blue: 0.82, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.9)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let userTypeIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.badge.shield.checkmark.fill"))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let userTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Paramètres", for: .normal)
        button.setTitleColor(.primaryColor, for: .normal)
        button.backgroundColor = .primaryColor.withAlphaComponent(0.1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 28
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.primaryColor.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Se déconnecter", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.systemRed.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        updateUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.09, green: 0.45, blue: 0.82, alpha: 1.0)
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        title = "Profil"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        headerView.addSubview(profileImageContainer)
        profileImageContainer.addSubview(profileImageView)
        headerView.addSubview(nameLabel)
        headerView.addSubview(emailLabel)
        contentView.addSubview(infoCard)
        infoCard.addSubview(userTypeIconView)
        infoCard.addSubview(userTypeLabel)
        infoCard.addSubview(statusIconView)
        infoCard.addSubview(statusLabel)
        contentView.addSubview(settingsButton)
        contentView.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 240),
            
            profileImageContainer.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 30),
            profileImageContainer.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            profileImageContainer.widthAnchor.constraint(equalToConstant: 100),
            profileImageContainer.heightAnchor.constraint(equalToConstant: 100),
            
            profileImageView.topAnchor.constraint(equalTo: profileImageContainer.topAnchor, constant: 4),
            profileImageView.leadingAnchor.constraint(equalTo: profileImageContainer.leadingAnchor, constant: 4),
            profileImageView.trailingAnchor.constraint(equalTo: profileImageContainer.trailingAnchor, constant: -4),
            profileImageView.bottomAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: -4),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            emailLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            
            infoCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            infoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            userTypeIconView.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 20),
            userTypeIconView.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            userTypeIconView.widthAnchor.constraint(equalToConstant: 24),
            userTypeIconView.heightAnchor.constraint(equalToConstant: 24),
            
            userTypeLabel.centerYAnchor.constraint(equalTo: userTypeIconView.centerYAnchor),
            userTypeLabel.leadingAnchor.constraint(equalTo: userTypeIconView.trailingAnchor, constant: 12),
            userTypeLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),
            
            statusIconView.topAnchor.constraint(equalTo: userTypeIconView.bottomAnchor, constant: 16),
            statusIconView.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            statusIconView.widthAnchor.constraint(equalToConstant: 24),
            statusIconView.heightAnchor.constraint(equalToConstant: 24),
            statusIconView.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -20),
            
            statusLabel.centerYAnchor.constraint(equalTo: statusIconView.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: statusIconView.trailingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),
            
            settingsButton.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 24),
            settingsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            settingsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            settingsButton.heightAnchor.constraint(equalToConstant: 56),
            
            logoutButton.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 16),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            logoutButton.heightAnchor.constraint(equalToConstant: 56),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        
        logoutButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        logoutButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside])
        
        settingsButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        settingsButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside])
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
    
    @objc private func handleSettings() {
        showAlert(title: "Paramètres", message: "Fonctionnalité à venir")
    }
    
    private func updateUserInfo() {
        guard let user = AuthService.shared.currentUser else { return }
        
        nameLabel.text = user.name
        emailLabel.text = user.email
        
        switch user.userType {
        case .user:
            userTypeLabel.text = "Utilisateur"
            userTypeIconView.image = UIImage(systemName: "person.fill")
            userTypeIconView.tintColor = .systemBlue
        case .agence:
            userTypeLabel.text = "Agence de voyage"
            userTypeIconView.image = UIImage(systemName: "building.2.fill")
            userTypeIconView.tintColor = .systemPurple
        case .admin:
            userTypeLabel.text = "Administrateur"
            userTypeIconView.image = UIImage(systemName: "star.fill")
            userTypeIconView.tintColor = .systemYellow
        }
        
        switch user.status {
        case .active:
            statusLabel.text = "Compte Actif"
            statusLabel.textColor = .systemGreen
            statusIconView.image = UIImage(systemName: "checkmark.circle.fill")
            statusIconView.tintColor = .systemGreen
        case .pending:
            statusLabel.text = "En attente de vérification"
            statusLabel.textColor = .systemOrange
            statusIconView.image = UIImage(systemName: "clock.fill")
            statusIconView.tintColor = .systemOrange
        case .suspended:
            statusLabel.text = "Compte Suspendu"
            statusLabel.textColor = .systemRed
            statusIconView.image = UIImage(systemName: "xmark.circle.fill")
            statusIconView.tintColor = .systemRed
        }
    }
    
    @objc private func handleLogout() {
        let alert = UIAlertController(
            title: "Déconnexion",
            message: "Êtes-vous sûr de vouloir vous déconnecter?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "Déconnexion", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        AuthService.shared.logout()
        
        let loginVC = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = navController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}
