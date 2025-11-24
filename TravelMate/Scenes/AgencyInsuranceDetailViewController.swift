import UIKit

protocol AgencyInsuranceDetailDelegate: AnyObject {
    func didUpdateInsurance()
}

class AgencyInsuranceDetailViewController: UIViewController {
    private var insurance: Insurance
    private let insuranceService = InsuranceService.shared
    weak var delegate: AgencyInsuranceDetailDelegate?
    private var subscribers: [Subscriber] = []
    
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
    
    private let subscribersCard: UIView = {
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
    
    private let subscribersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
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
        loadSubscribers()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        title = "Détails"
        
        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerCard)
        contentView.addSubview(subscribersCard)
        contentView.addSubview(toggleButton)
        
        toggleButton.addTarget(self, action: #selector(toggleActiveTapped), for: .touchUpInside)
        
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
            
            subscribersCard.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 20),
            subscribersCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subscribersCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            toggleButton.topAnchor.constraint(equalTo: subscribersCard.bottomAnchor, constant: 20),
            toggleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            toggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            toggleButton.heightAnchor.constraint(equalToConstant: 50),
            toggleButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureWithInsurance() {
        // Header Card
        let nameLabel = UILabel()
        nameLabel.text = insurance.name
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let statusBadge = UIView()
        statusBadge.backgroundColor = insurance.isActive ? UIColor.systemGreen : UIColor.systemRed
        statusBadge.layer.cornerRadius = 4
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        
        let statusLabel = UILabel()
        statusLabel.text = insurance.isActive ? "Actif" : "Inactif"
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        statusLabel.textColor = .white
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let priceLabel = UILabel()
        priceLabel.text = insurance.formattedPrice
        priceLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        priceLabel.textColor = .primaryColor
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let durationLabel = UILabel()
        durationLabel.text = insurance.duration
        durationLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        durationLabel.textColor = .systemGray
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = insurance.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let coverageTitle = UILabel()
        coverageTitle.text = "Couvertures:"
        coverageTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        coverageTitle.textColor = .black
        coverageTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let coverageLabel = UILabel()
        coverageLabel.text = "• " + insurance.coverage.joined(separator: "\n• ")
        coverageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        coverageLabel.textColor = .darkGray
        coverageLabel.numberOfLines = 0
        coverageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statusBadge.addSubview(statusLabel)
        headerCard.addSubview(nameLabel)
        headerCard.addSubview(statusBadge)
        headerCard.addSubview(priceLabel)
        headerCard.addSubview(durationLabel)
        headerCard.addSubview(descriptionLabel)
        headerCard.addSubview(coverageTitle)
        headerCard.addSubview(coverageLabel)
        
        NSLayoutConstraint.activate([
            statusBadge.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 16),
            statusBadge.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            statusBadge.heightAnchor.constraint(equalToConstant: 24),
            
            statusLabel.topAnchor.constraint(equalTo: statusBadge.topAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: -8),
            statusLabel.bottomAnchor.constraint(equalTo: statusBadge.bottomAnchor, constant: -4),
            
            nameLabel.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            priceLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 20),
            
            durationLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -20),
            
            coverageTitle.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            coverageTitle.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 20),
            
            coverageLabel.topAnchor.constraint(equalTo: coverageTitle.bottomAnchor, constant: 8),
            coverageLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 20),
            coverageLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -20),
            coverageLabel.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -20)
        ])
        
        // Toggle button
        updateToggleButton()
    }
    
    private func loadSubscribers() {
        loadingIndicator.startAnimating()
        
        Task {
            do {
                let response = try await insuranceService.getInsuranceSubscribers(insuranceId: insurance.id)
                self.subscribers = response.subscribers
                
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.displaySubscribers()
                }
            } catch {
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func displaySubscribers() {
        subscribersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.text = "Inscrits (\(subscribers.count))"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subscribersCard.addSubview(titleLabel)
        subscribersCard.addSubview(subscribersStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: subscribersCard.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: subscribersCard.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: subscribersCard.trailingAnchor, constant: -20),
            
            subscribersStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subscribersStackView.leadingAnchor.constraint(equalTo: subscribersCard.leadingAnchor, constant: 20),
            subscribersStackView.trailingAnchor.constraint(equalTo: subscribersCard.trailingAnchor, constant: -20),
            subscribersStackView.bottomAnchor.constraint(equalTo: subscribersCard.bottomAnchor, constant: -20)
        ])
        
        if subscribers.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Aucun inscrit"
            emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            emptyLabel.textColor = .systemGray
            emptyLabel.textAlignment = .center
            subscribersStackView.addArrangedSubview(emptyLabel)
        } else {
            for subscriber in subscribers {
                let subscriberView = createSubscriberRow(subscriber: subscriber)
                subscribersStackView.addArrangedSubview(subscriberView)
            }
        }
    }
    
    private func createSubscriberRow(subscriber: Subscriber) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(white: 0.97, alpha: 1)
        container.layer.cornerRadius = 8
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = subscriber.name
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let emailLabel = UILabel()
        emailLabel.text = subscriber.email
        emailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        emailLabel.textColor = .systemGray
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let locationLabel = UILabel()
        var location = ""
        if let city = subscriber.city { location += city }
        if let country = subscriber.country {
            location += location.isEmpty ? country : ", \(country)"
        }
        locationLabel.text = location.isEmpty ? "Non spécifié" : location
        locationLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        locationLabel.textColor = .systemGray2
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(nameLabel)
        container.addSubview(emailLabel)
        container.addSubview(locationLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            emailLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            locationLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 2),
            locationLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            locationLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            locationLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    private func updateToggleButton() {
        if insurance.isActive {
            toggleButton.setTitle("Désactiver l'assurance", for: .normal)
            toggleButton.backgroundColor = .systemRed
        } else {
            toggleButton.setTitle("Activer l'assurance", for: .normal)
            toggleButton.backgroundColor = .systemGreen
        }
    }
    
    @objc private func toggleActiveTapped() {
        let action = insurance.isActive ? "désactiver" : "activer"
        let alert = UIAlertController(
            title: "Confirmation",
            message: "Voulez-vous vraiment \(action) cette assurance?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirmer", style: .default) { [weak self] _ in
            self?.performToggle()
        })
        
        present(alert, animated: true)
    }
    
    private func performToggle() {
        toggleButton.isEnabled = false
        let wasActive = insurance.isActive
        
        Task {
            do {
                insurance = try await insuranceService.toggleInsuranceStatus(id: insurance.id)
                print("✅ Statut modifié avec succès")
                await MainActor.run {
                    self.toggleButton.isEnabled = true
                    self.updateToggleButton()
                    self.delegate?.didUpdateInsurance()
                    self.updateStatusBadge()
                }
            } catch {
                print("❌ Erreur lors du toggle: \(error.localizedDescription)")
                
                // En cas d'erreur de décodage, recharger l'assurance pour vérifier le statut
                if error.localizedDescription.contains("décodage") || error.localizedDescription.contains("decoding") {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec
                    
                    do {
                        let insurances = try await insuranceService.getMyAgencyInsurances()
                        if let refreshed = insurances.first(where: { $0.id == insurance.id }) {
                            insurance = refreshed
                            
                            // Vérifier si le statut a changé
                            if refreshed.isActive != wasActive {
                                print("✅ Statut changé malgré l'erreur - succès")
                                await MainActor.run {
                                    self.toggleButton.isEnabled = true
                                    self.updateToggleButton()
                                    self.delegate?.didUpdateInsurance()
                                    self.updateStatusBadge()
                                }
                                return
                            }
                        }
                    } catch {
                        // Ignore, afficher l'erreur originale ci-dessous
                    }
                }
                
                await MainActor.run {
                    self.toggleButton.isEnabled = true
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func updateStatusBadge() {
        // Update status badge color and text
        for subview in headerCard.subviews {
            if let statusBadge = subview as? UIView, 
               let statusLabel = statusBadge.subviews.first as? UILabel,
               statusLabel.text == "Actif" || statusLabel.text == "Inactif" {
                statusBadge.backgroundColor = insurance.isActive ? UIColor.systemGreen : UIColor.systemRed
                statusLabel.text = insurance.isActive ? "Actif" : "Inactif"
                break
            }
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
