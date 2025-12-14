import UIKit

class HomeViewController: UIViewController {
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
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = localized("home.description")
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.9)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var quickActionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateWelcomeMessage()
        
        // Observe language changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageDidChange),
            name: LanguageManager.languageDidChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func languageDidChange() {
        refreshUI()
    }
    
    private func refreshUI() {
        // Update description label
        descriptionLabel.text = localized("home.description")
        
        // Update welcome message
        updateWelcomeMessage()
        
        // Recreate quick actions with new language
        quickActionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        setupQuickActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 300)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        
        gradientLayer.colors = [
            UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0).cgColor,
            UIColor(red: 0.1, green: 0.4, blue: 0.7, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        headerView.addSubview(welcomeLabel)
        headerView.addSubview(descriptionLabel)
        contentView.addSubview(quickActionsStackView)
        
        setupQuickActions()
        
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
            
            headerView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            welcomeLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            welcomeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            welcomeLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            descriptionLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            quickActionsStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 40),
            quickActionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            quickActionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            quickActionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupQuickActions() {
        let actions = [
            ("airplane", localized("home.action.voyages.title"), localized("home.action.voyages.subtitle"), UIColor.systemBlue),
            ("shield.fill", localized("home.action.insurances.title"), localized("home.action.insurances.subtitle"), UIColor.systemGreen),
            ("tag.fill", localized("home.action.packs.title"), localized("home.action.packs.subtitle"), UIColor.systemOrange),
            ("person.3.fill", localized("home.action.groups.title"), localized("home.action.groups.subtitle"), UIColor.systemPurple)
        ]
        
        for (index, action) in actions.enumerated() {
            let card = createActionCard(
                icon: action.0,
                title: action.1,
                subtitle: action.2,
                color: action.3,
                tag: index
            )
            quickActionsStackView.addArrangedSubview(card)
        }
    }
    
    private func createActionCard(
        icon: String,
        title: String,
        subtitle: String,
        color: UIColor,
        tag: Int
    ) -> UIView {
        
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.1
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainerView = UIView()
        iconContainerView.backgroundColor = color.withAlphaComponent(0.15)
        iconContainerView.layer.cornerRadius = 12
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
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
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronView.tintColor = .systemGray3
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainerView.addSubview(iconView)
        container.addSubview(iconContainerView)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(chevronView)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            iconContainerView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 56),
            iconContainerView.heightAnchor.constraint(equalToConstant: 56),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -8),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -8),
            
            chevronView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chevronView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 20),
            chevronView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
        container.tag = tag
        container.addGestureRecognizer(tap)
        
        return container
    }
    
    // MARK: - Navigation for cards
    @objc private func handleCardTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        UIView.animate(withDuration: 0.1) { view.transform = CGAffineTransform(scaleX: 0.97, y: 0.97) } completion: { _ in
            UIView.animate(withDuration: 0.1) { view.transform = .identity }
        }
        
        // 🔥 Correct navigation
        switch view.tag {
        case 0:
            tabBarController?.selectedIndex = 2   // Mes Voyages (VoyageListViewController)
        case 1:
            tabBarController?.selectedIndex = 1   // Assurances
        case 2:
            tabBarController?.selectedIndex = 2   // ⭐ Packs Voyages (ton module)
        case 3:
            tabBarController?.selectedIndex = 3   // Mes Groupes
        default:
            break
        }
    }
    
    private func updateWelcomeMessage() {
        if let user = AuthService.shared.currentUser {
            welcomeLabel.text = String(format: localized("home.welcome"), user.name)
        } else {
            welcomeLabel.text = localized("home.welcomeDefault")
        }
    }
}
