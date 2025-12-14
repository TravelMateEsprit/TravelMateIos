import UIKit

protocol AgencyApplicationDetailDelegate: AnyObject {
    func didUpdateApplication()
}

class AgencyApplicationDetailViewController: UIViewController {
    
    private var application: InsuranceApplication
    private let insuranceService = InsuranceService.shared
    weak var delegate: AgencyApplicationDetailDelegate?
    
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
    
    private let statusBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
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
    
    private let approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGreen
        button.setTitle("✓ Approuver", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let rejectButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemRed
        button.setTitle("✕ Rejeter", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
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
        statusCard.addSubview(statusBadge)
        statusBadge.addSubview(statusLabel)
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
            statusCard.heightAnchor.constraint(equalToConstant: 80),
            
            statusBadge.centerYAnchor.constraint(equalTo: statusCard.centerYAnchor),
            statusBadge.centerXAnchor.constraint(equalTo: statusCard.centerXAnchor),
            statusBadge.heightAnchor.constraint(equalToConstant: 40),
            
            statusLabel.topAnchor.constraint(equalTo: statusBadge.topAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(equalTo: statusBadge.bottomAnchor, constant: -8),
            
            infoStackView.topAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            infoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func populateData() {
        // Status
        statusLabel.text = application.status.displayName
        statusBadge.backgroundColor = application.status.color
        
        // Insurance info
        if let insurance = application.insuranceId {
            let insuranceSection = createSection(title: "Assurance demandée")
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
        
        // Action buttons (only if pending)
        if application.status == .pending {
            let buttonContainer = UIView()
            buttonContainer.translatesAutoresizingMaskIntoConstraints = false
            
            buttonContainer.addSubview(approveButton)
            buttonContainer.addSubview(rejectButton)
            
            NSLayoutConstraint.activate([
                approveButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
                approveButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
                approveButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
                approveButton.heightAnchor.constraint(equalToConstant: 54),
                
                rejectButton.topAnchor.constraint(equalTo: approveButton.bottomAnchor, constant: 12),
                rejectButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
                rejectButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
                rejectButton.heightAnchor.constraint(equalToConstant: 54),
                rejectButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor)
            ])
            
            infoStackView.addArrangedSubview(buttonContainer)
            
            approveButton.addTarget(self, action: #selector(approveTapped), for: .touchUpInside)
            rejectButton.addTarget(self, action: #selector(rejectTapped), for: .touchUpInside)
        }
        
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
    
    @objc private func approveTapped() {
        let alert = UIAlertController(
            title: "Approuver la demande",
            message: "Voulez-vous approuver cette demande d'assurance?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "Approuver", style: .default) { [weak self] _ in
            self?.reviewApplication(status: .approved, reason: nil)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func rejectTapped() {
        let alert = UIAlertController(
            title: "Rejeter la demande",
            message: "Veuillez indiquer la raison du rejet",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Raison du rejet"
        }
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "Rejeter", style: .destructive) { [weak self] _ in
            let reason = alert.textFields?.first?.text ?? ""
            if reason.isEmpty {
                self?.showAlert(message: "Veuillez indiquer une raison")
            } else {
                self?.reviewApplication(status: .rejected, reason: reason)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func reviewApplication(status: ApplicationStatus, reason: String?) {
        let loadingAlert = UIAlertController(title: "Traitement...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        let request = ReviewApplicationRequest(status: status, rejectionReason: reason)
        
        Task {
            do {
                _ = try await insuranceService.reviewApplication(
                    applicationId: application.id,
                    request: request
                )
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let message = status == .approved
                            ? "La demande a été approuvée avec succès"
                            : "La demande a été rejetée"
                        
                        let successAlert = UIAlertController(
                            title: "✅ Succès",
                            message: message,
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                            self?.delegate?.didUpdateApplication()
                            self?.navigationController?.popViewController(animated: true)
                        })
                        self.present(successAlert, animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        self.showAlert(message: "Erreur: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
