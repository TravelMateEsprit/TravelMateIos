import UIKit

class AgencyDashboardViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = UIColor(white: 0.95, alpha: 1)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let agencyNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.9)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Déconnexion", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let menuStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(headerView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(menuStack)
        
        headerView.addSubview(welcomeLabel)
        headerView.addSubview(agencyNameLabel)
        headerView.addSubview(logoutButton)
        
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 200),
            
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            welcomeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: logoutButton.leadingAnchor, constant: -8),
            
            agencyNameLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 8),
            agencyNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            agencyNameLabel.trailingAnchor.constraint(equalTo: logoutButton.leadingAnchor, constant: -8),
            
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            logoutButton.widthAnchor.constraint(equalToConstant: 100),
            logoutButton.heightAnchor.constraint(equalToConstant: 40),
            
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            menuStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            menuStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            menuStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            menuStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        createMenuItems()
    }
    
    private func setupData() {
        if let user = AuthService.shared.currentUser {
            welcomeLabel.text = "Bonjour"
            agencyNameLabel.text = user.agencyName ?? user.name
        }
    }
    
    private func createMenuItems() {
        // Assurances
        let insurancesCard = createMenuCard(
            icon: "shield.fill",
            title: "Mes Assurances",
            subtitle: "Gérer vos assurances voyage",
            color: .systemBlue
        )
        insurancesCard.tag = 1
        let insurancesTap = UITapGestureRecognizer(target: self, action: #selector(menuItemTapped(_:)))
        insurancesCard.addGestureRecognizer(insurancesTap)
        
        // Demandes
        let requestsCard = createMenuCard(
            icon: "person.badge.plus",
            title: "Demandes d'adhésion",
            subtitle: "Gérer les demandes",
            color: .systemOrange
        )
        requestsCard.tag = 2
        let requestsTap = UITapGestureRecognizer(target: self, action: #selector(menuItemTapped(_:)))
        requestsCard.addGestureRecognizer(requestsTap)
        
        // Statistiques
        let statsCard = createMenuCard(
            icon: "chart.bar.fill",
            title: "Statistiques",
            subtitle: "Voir vos performances",
            color: .systemGreen
        )
        statsCard.tag = 3
        let statsTap = UITapGestureRecognizer(target: self, action: #selector(menuItemTapped(_:)))
        statsCard.addGestureRecognizer(statsTap)
        
        // Profil
        let profileCard = createMenuCard(
            icon: "person.circle.fill",
            title: "Mon Profil",
            subtitle: "Modifier vos informations",
            color: .systemPurple
        )
        profileCard.tag = 4
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(menuItemTapped(_:)))
        profileCard.addGestureRecognizer(profileTap)
        
        menuStack.addArrangedSubview(insurancesCard)
        menuStack.addArrangedSubview(requestsCard)
        menuStack.addArrangedSubview(statsCard)
        menuStack.addArrangedSubview(profileCard)
    }
    
    private func createMenuCard(icon: String, title: String, subtitle: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.1
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = color.withAlphaComponent(0.15)
        iconContainer.layer.cornerRadius = 28
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let chevron = UIImageView()
        chevron.image = UIImage(systemName: "chevron.right")
        chevron.tintColor = .systemGray3
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(iconView)
        container.addSubview(iconContainer)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 90),
            
            iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 56),
            iconContainer.heightAnchor.constraint(equalToConstant: 56),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            
            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 20),
            chevron.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return container
    }
    
    @objc private func menuItemTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            view.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = .identity
            }
        }
        
        switch view.tag {
        case 1: openInsurances()
        case 2: showComingSoon("Demandes d'adhésion")
        case 3: showComingSoon("Statistiques")
        case 4: showComingSoon("Mon Profil")
        default: break
        }
    }
    
    @objc private func openInsurances() {
        let insurancesVC = AgencyInsurancesViewController()
        let navVC = UINavigationController(rootViewController: insurancesVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Déconnexion",
            message: "Voulez-vous vraiment vous déconnecter?",
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
        let navVC = UINavigationController(rootViewController: loginVC)
        navVC.modalPresentationStyle = .fullScreen
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = navVC
            window.makeKeyAndVisible()
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    private func showComingSoon(_ feature: String) {
        let alert = UIAlertController(
            title: "Bientôt disponible",
            message: "\(feature) sera disponible prochainement.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
