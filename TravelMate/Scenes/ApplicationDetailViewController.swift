import UIKit

class ApplicationDetailViewController: UIViewController {
    
    private var application: InsuranceApplication
    private let insuranceService = InsuranceService.shared
    
    // MARK: - UI Components
    
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
    
    private let statusCard: UIView = {
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
    
    private let statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemRed
        button.setTitle("Annuler la demande", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    init(application: InsuranceApplication) {
        self.application = application
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "Détails de la demande"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(statusCard)
        statusCard.addSubview(statusIcon)
        statusCard.addSubview(statusLabel)
        contentView.addSubview(infoStackView)
        
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
            
            statusCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            statusCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusIcon.topAnchor.constraint(equalTo: statusCard.topAnchor, constant: 24),
            statusIcon.centerXAnchor.constraint(equalTo: statusCard.centerXAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 60),
            statusIcon.heightAnchor.constraint(equalToConstant: 60),
            
            statusLabel.topAnchor.constraint(equalTo: statusIcon.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: statusCard.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: statusCard.trailingAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: -24),
            
            infoStackView.topAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            infoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func populateData() {
        // Status
        switch application.status {
        case .pending:
            statusIcon.image = UIImage(systemName: "clock.fill")
            statusIcon.tintColor = .systemOrange
            statusLabel.text = "En attente de validation"
            statusLabel.textColor = .systemOrange
            
            // Add cancel button
            contentView.addSubview(cancelButton)
            NSLayoutConstraint.activate([
                cancelButton.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 20),
                cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                cancelButton.heightAnchor.constraint(equalToConstant: 50),
                cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
            cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
            
        case .approved:
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = .systemGreen
            statusLabel.text = "Demande approuvée ✅"
            statusLabel.textColor = .systemGreen
            
        case .rejected:
            statusIcon.image = UIImage(systemName: "xmark.circle.fill")
            statusIcon.tintColor = .systemRed
            statusLabel.text = "Demande rejetée"
            statusLabel.textColor = .systemRed
        }
        
        // Insurance info
        if let insurance = application.insuranceId {
            let insuranceSection = createSection(title: "Assurance")
            insuranceSection.addArrangedSubview(createInfoRow(label: "Nom", value: insurance.name ?? "N/A"))
            insuranceSection.addArrangedSubview(createInfoRow(label: "Prix", value: String(format: "%.2f TND", insurance.price ?? 0)))
            insuranceSection.addArrangedSubview(createInfoRow(label: "Durée", value: insurance.duration ?? "N/A"))
            infoStackView.addArrangedSubview(insuranceSection)
        }
        
        // Personal info
        let personalSection = createSection(title: "Informations personnelles")
        personalSection.addArrangedSubview(createInfoRow(label: "Nom complet", value: application.fullName))
        personalSection.addArrangedSubview(createInfoRow(label: "Email", value: application.email))
        personalSection.addArrangedSubview(createInfoRow(label: "Téléphone", value: application.phone))
        personalSection.addArrangedSubview(createInfoRow(label: "Date de naissance", value: application.formattedDateOfBirth))
        infoStackView.addArrangedSubview(personalSection)
        
        // Travel info
        let travelSection = createSection(title: "Informations de voyage")
        travelSection.addArrangedSubview(createInfoRow(label: "Destination", value: application.destination))
        travelSection.addArrangedSubview(createInfoRow(label: "Date de départ", value: application.formattedDepartureDate))
        travelSection.addArrangedSubview(createInfoRow(label: "Date d'arrivée", value: application.formattedArrivalDate))
        
        let reasonValue = application.travelReason == .other && application.customTravelReason != nil
            ? application.customTravelReason!
            : application.travelReason.displayName
        travelSection.addArrangedSubview(createInfoRow(label: "Motif", value: reasonValue))
        infoStackView.addArrangedSubview(travelSection)
        
        // Additional info
        let additionalSection = createSection(title: "Informations complémentaires")
        additionalSection.addArrangedSubview(createInfoRow(label: "N° Passeport", value: application.passportNumber))
        infoStackView.addArrangedSubview(additionalSection)
        
        // Rejection reason if rejected
        if application.status == .rejected, let reason = application.rejectionReason {
            let rejectionSection = createSection(title: "Raison du rejet")
            let reasonLabel = UILabel()
            reasonLabel.text = reason
            reasonLabel.font = UIFont.systemFont(ofSize: 15)
            reasonLabel.textColor = .systemRed
            reasonLabel.numberOfLines = 0
            rejectionSection.addArrangedSubview(reasonLabel)
            infoStackView.addArrangedSubview(rejectionSection)
        }
    }
    
    private func createSection(title: String) -> UIStackView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        container.isLayoutMarginsRelativeArrangement = true
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .primaryColor
        
        container.addArrangedSubview(titleLabel)
        
        let separator = UIView()
        separator.backgroundColor = .systemGray5
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        container.addArrangedSubview(separator)
        
        return container
    }
    
    private func createInfoRow(label: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        labelView.textColor = .systemGray
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let valueView = UILabel()
        valueView.text = value
        valueView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        valueView.textColor = .black
        valueView.numberOfLines = 0
        valueView.textAlignment = .right
        valueView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(labelView)
        container.addSubview(valueView)
        
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: container.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            labelView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.4),
            labelView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            valueView.topAnchor.constraint(equalTo: container.topAnchor),
            valueView.leadingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: 8),
            valueView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        let alert = UIAlertController(
            title: "Annuler la demande",
            message: "Êtes-vous sûr de vouloir annuler cette demande?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Non", style: .cancel))
        alert.addAction(UIAlertAction(title: "Oui", style: .destructive) { [weak self] _ in
            self?.confirmCancel()
        })
        
        present(alert, animated: true)
    }
    
    private func confirmCancel() {
        let loadingAlert = UIAlertController(title: "Annulation...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        Task {
            do {
                _ = try await insuranceService.cancelApplication(applicationId: application.id)
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let successAlert = UIAlertController(
                            title: "Succès",
                            message: "Votre demande a été annulée",
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                            self?.navigationController?.popViewController(animated: true)
                        })
                        self.present(successAlert, animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let errorAlert = UIAlertController(
                            title: "Erreur",
                            message: "Impossible d'annuler: \(error.localizedDescription)",
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        }
    }
}
