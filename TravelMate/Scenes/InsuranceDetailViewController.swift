import UIKit

protocol InsuranceDetailDelegate: AnyObject {
    func didUpdateInsurance()
}

class InsuranceDetailViewController: UIViewController {
    private var insurance: Insurance
    private let insuranceService = InsuranceService.shared
    weak var delegate: InsuranceDetailDelegate?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerCard: UIView = {
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
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .primaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let coverageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let agencyInfoCard: UIView = {
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
    
    private let subscribeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .primaryColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(insurance: Insurance) {
        self.insurance = insurance
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithInsurance()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        title = "Détails de l'assurance"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerCard)
        contentView.addSubview(agencyInfoCard)
        contentView.addSubview(subscribeButton)
        
        headerCard.addSubview(nameLabel)
        headerCard.addSubview(priceLabel)
        headerCard.addSubview(durationLabel)
        headerCard.addSubview(descriptionLabel)
        headerCard.addSubview(coverageStackView)
        
        subscribeButton.addTarget(self, action: #selector(subscribeButtonTapped), for: .touchUpInside)
        
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
            
            headerCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            nameLabel.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -20),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 20),
            
            durationLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -20),
            
            coverageStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            coverageStackView.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 20),
            coverageStackView.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -20),
            coverageStackView.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -20),
            
            agencyInfoCard.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 20),
            agencyInfoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            agencyInfoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subscribeButton.topAnchor.constraint(equalTo: agencyInfoCard.bottomAnchor, constant: 20),
            subscribeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subscribeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            subscribeButton.heightAnchor.constraint(equalToConstant: 50),
            subscribeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func configureWithInsurance() {
        nameLabel.text = insurance.name
        priceLabel.text = insurance.formattedPrice
        durationLabel.text = insurance.duration
        descriptionLabel.text = insurance.description
        
        // Coverage
        let coverageTitle = UILabel()
        coverageTitle.text = "Couvertures incluses:"
        coverageTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        coverageTitle.textColor = .black
        coverageStackView.addArrangedSubview(coverageTitle)
        
        for coverage in insurance.coverage {
            let coverageView = createCoverageRow(text: coverage)
            coverageStackView.addArrangedSubview(coverageView)
        }
        
        // Agency info
        if let agency = insurance.agencyId {
            setupAgencyInfo(agency: agency)
        }
        
        // Subscribe button - seulement pour les utilisateurs
        if let user = AuthService.shared.currentUser, user.userType == .user {
            updateSubscribeButton()
        } else {
            // Cacher le bouton pour les agences
            subscribeButton.isHidden = true
        }
    }
    
    private func createCoverageRow(text: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let checkIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkIcon.tintColor = .systemGreen
        checkIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(checkIcon)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            checkIcon.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            checkIcon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            checkIcon.widthAnchor.constraint(equalToConstant: 20),
            checkIcon.heightAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: checkIcon.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupAgencyInfo(agency: AgencyInfo) {
        let titleLabel = UILabel()
        titleLabel.text = "Proposé par:"
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .systemGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let agencyNameLabel = UILabel()
        agencyNameLabel.text = agency.agencyName ?? agency.name
        agencyNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        agencyNameLabel.textColor = .black
        agencyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let locationLabel = UILabel()
        var location = ""
        if let city = agency.city { location += city }
        if let country = agency.country {
            location += location.isEmpty ? country : ", \(country)"
        }
        locationLabel.text = location.isEmpty ? "Non spécifié" : location
        locationLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        locationLabel.textColor = .systemGray
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        agencyInfoCard.addSubview(titleLabel)
        agencyInfoCard.addSubview(agencyNameLabel)
        agencyInfoCard.addSubview(locationLabel)
        
        NSLayoutConstraint.activate([
            agencyInfoCard.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: agencyInfoCard.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: agencyInfoCard.leadingAnchor, constant: 20),
            
            agencyNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            agencyNameLabel.leadingAnchor.constraint(equalTo: agencyInfoCard.leadingAnchor, constant: 20),
            agencyNameLabel.trailingAnchor.constraint(equalTo: agencyInfoCard.trailingAnchor, constant: -20),
            
            locationLabel.topAnchor.constraint(equalTo: agencyNameLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: agencyInfoCard.leadingAnchor, constant: 20),
            locationLabel.trailingAnchor.constraint(equalTo: agencyInfoCard.trailingAnchor, constant: -20)
        ])
    }
    
    private func updateSubscribeButton() {
        guard let userId = AuthService.shared.getCurrentUserId() else { return }
        
        let isSubscribed = insurance.subscribers.contains(userId)
        
        if isSubscribed {
            subscribeButton.setTitle("Se désinscrire", for: .normal)
            subscribeButton.backgroundColor = .systemRed
        } else {
            subscribeButton.setTitle("S'inscrire", for: .normal)
            subscribeButton.backgroundColor = .primaryColor
        }
    }
    
    @objc private func subscribeButtonTapped() {
        guard let userId = AuthService.shared.getCurrentUserId() else { return }
        guard let user = AuthService.shared.currentUser else { return }
        
        // Vérifier que c'est un utilisateur et pas une agence
        if user.userType == .agence {
            showError(message: "Les agences ne peuvent pas s'inscrire aux assurances. Cette fonctionnalité est réservée aux utilisateurs.")
            return
        }
        
        let isSubscribed = insurance.subscribers.contains(userId)
        
        let action = isSubscribed ? "désinscrire" : "inscrire"
        let alert = UIAlertController(
            title: "Confirmation",
            message: "Voulez-vous vraiment vous \(action) à cette assurance?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirmer", style: .default) { [weak self] _ in
            self?.performSubscriptionAction(isSubscribed: isSubscribed)
        })
        
        present(alert, animated: true)
    }
    
    private func performSubscriptionAction(isSubscribed: Bool) {
        subscribeButton.isEnabled = false
        subscribeButton.alpha = 0.6
        subscribeButton.setTitle(isSubscribed ? "Désinscription..." : "Inscription...", for: .normal)
        
        Task {
            var actionSucceeded = false
            var finalIsSubscribed = isSubscribed
            var errorMessage = ""
            
            do {
                let updatedInsurance: Insurance
                
                if isSubscribed {
                    updatedInsurance = try await insuranceService.unsubscribe(insuranceId: insurance.id)
                } else {
                    updatedInsurance = try await insuranceService.subscribe(insuranceId: insurance.id)
                }
                
                // Succès immédiat
                insurance = updatedInsurance
                
                // Vérifier le nouvel état
                if let userId = AuthService.shared.getCurrentUserId() {
                    finalIsSubscribed = updatedInsurance.subscribers.contains(userId)
                    
                    // Vérifier que l'action a bien eu l'effet attendu
                    if isSubscribed {
                        // On voulait se désinscrire
                        actionSucceeded = !finalIsSubscribed
                    } else {
                        // On voulait s'inscrire  
                        actionSucceeded = finalIsSubscribed
                    }
                }
                
            } catch {
                // En cas d'erreur, on vérifie quand même le résultat
                print("⚠️ Erreur détectée: \(error.localizedDescription)")
                
                do {
                    // Recharger l'assurance pour vérifier le vrai statut
                    let refreshedInsurance = try await insuranceService.getInsurance(id: insurance.id)
                    insurance = refreshedInsurance
                    
                    // Vérifier si l'action a réussi malgré l'erreur
                    if let userId = AuthService.shared.getCurrentUserId() {
                        finalIsSubscribed = refreshedInsurance.subscribers.contains(userId)
                        
                        if isSubscribed {
                            // On voulait se désinscrire
                            actionSucceeded = !finalIsSubscribed  // Succès si on n'est plus inscrit
                        } else {
                            // On voulait s'inscrire
                            actionSucceeded = finalIsSubscribed  // Succès si on est maintenant inscrit
                        }
                        
                        if !actionSucceeded {
                            errorMessage = "L'opération a échoué. Veuillez réessayer."
                        }
                    }
                } catch {
                    actionSucceeded = false
                    errorMessage = "Impossible de vérifier le statut. Veuillez vérifier votre connexion."
                }
            }
            
            // Mise à jour de l'UI avec le bon message
            await MainActor.run {
                self.subscribeButton.isEnabled = true
                self.subscribeButton.alpha = 1.0
                self.updateSubscribeButton()
                self.delegate?.didUpdateInsurance()
                
                if actionSucceeded {
                    // Afficher le message selon l'action EFFECTUÉE
                    if isSubscribed {
                        // On était inscrit et on s'est désinscrit
                        self.showSuccess(message: "Désinscription réussie")
                    } else {
                        // On n'était pas inscrit et on s'est inscrit
                        self.showSuccess(message: "Inscription réussie")
                    }
                } else {
                    self.showError(message: errorMessage.isEmpty ? "Une erreur est survenue" : errorMessage)
                }
            }
        }
    }
    
    private func showSuccess(message: String) {
        let alert = UIAlertController(title: "Succès", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
