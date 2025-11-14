import UIKit

class AgencyInsurancesViewController: UIViewController {
    private let insuranceService = InsuranceService.shared
    private var insurances: [Insurance] = []
    
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
    
    private lazy var insuranceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Aucune assurance\nAppuyez sur + pour en créer une"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 2
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadInsurances()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // Recharger les assurances à chaque fois qu'on revient
        loadInsurances()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        title = "Mes Assurances"
        
        // Close button si présenté modalement
        if presentingViewController != nil {
            let closeButton = UIBarButtonItem(
                image: UIImage(systemName: "xmark"),
                style: .plain,
                target: self,
                action: #selector(closeTapped)
            )
            closeButton.tintColor = .primaryColor
            navigationItem.leftBarButtonItem = closeButton
        }
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addInsurance)
        )
        addButton.tintColor = .primaryColor
        navigationItem.rightBarButtonItem = addButton
        
        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentView)
        contentView.addSubview(insuranceStackView)
        contentView.addSubview(emptyStateLabel)
        
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
            
            insuranceStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            insuranceStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            insuranceStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            insuranceStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func loadInsurances() {
        loadingIndicator.startAnimating()
        emptyStateLabel.isHidden = true
        
        Task {
            do {
                print("🔄 Chargement des assurances de l'agence...")
                self.insurances = try await insuranceService.getMyAgencyInsurances()
                print("✅ Assurances chargées: \(self.insurances.count)")
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.updateDisplay()
                }
            } catch {
                print("❌ Erreur chargement assurances: \(error)")
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.emptyStateLabel.isHidden = false
                    self.showError(message: "Erreur: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateDisplay() {
        insuranceStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if insurances.isEmpty {
            emptyStateLabel.isHidden = false
        } else {
            emptyStateLabel.isHidden = true
            for (index, insurance) in insurances.enumerated() {
                let card = createInsuranceCard(insurance: insurance, index: index)
                insuranceStackView.addArrangedSubview(card)
            }
        }
    }
    
    private func createInsuranceCard(insurance: Insurance, index: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.1
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let statusBadge = UIView()
        statusBadge.backgroundColor = insurance.isActive ? UIColor.systemGreen : UIColor.systemRed
        statusBadge.layer.cornerRadius = 4
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        
        let statusLabel = UILabel()
        statusLabel.text = insurance.isActive ? "Actif" : "Inactif"
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        statusLabel.textColor = .white
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = insurance.name
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let priceLabel = UILabel()
        priceLabel.text = insurance.formattedPrice
        priceLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        priceLabel.textColor = .primaryColor
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subscribersLabel = UILabel()
        subscribersLabel.text = "\(insurance.subscribersCount) inscrit(s)"
        subscribersLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subscribersLabel.textColor = .systemGray
        subscribersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let actionsStack = UIStackView()
        actionsStack.axis = .horizontal
        actionsStack.spacing = 8
        actionsStack.distribution = .fillEqually
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        
        let viewButton = createActionButton(title: "Voir", color: .systemBlue, tag: index, action: #selector(viewInsurance(_:)))
        let editButton = createActionButton(title: "Modifier", color: .systemOrange, tag: index, action: #selector(editInsurance(_:)))
        let deleteButton = createActionButton(title: "Supprimer", color: .systemRed, tag: index, action: #selector(deleteInsurance(_:)))
        
        actionsStack.addArrangedSubview(viewButton)
        actionsStack.addArrangedSubview(editButton)
        actionsStack.addArrangedSubview(deleteButton)
        
        statusBadge.addSubview(statusLabel)
        container.addSubview(statusBadge)
        container.addSubview(nameLabel)
        container.addSubview(priceLabel)
        container.addSubview(subscribersLabel)
        container.addSubview(actionsStack)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 160),
            
            statusBadge.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            statusBadge.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            statusBadge.heightAnchor.constraint(equalToConstant: 24),
            
            statusLabel.topAnchor.constraint(equalTo: statusBadge.topAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: -8),
            statusLabel.bottomAnchor.constraint(equalTo: statusBadge.bottomAnchor, constant: -4),
            
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            subscribersLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            subscribersLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            actionsStack.topAnchor.constraint(equalTo: subscribersLabel.bottomAnchor, constant: 16),
            actionsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            actionsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            actionsStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            actionsStack.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        return container
    }
    
    private func createActionButton(title: String, color: UIColor, tag: Int, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 8
        button.tag = tag
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func addInsurance() {
        let createVC = CreateInsuranceViewController()
        createVC.delegate = self
        let navVC = UINavigationController(rootViewController: createVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func viewInsurance(_ sender: UIButton) {
        guard sender.tag < insurances.count else { return }
        let insurance = insurances[sender.tag]
        
        let detailVC = AgencyInsuranceDetailViewController(insurance: insurance)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc private func editInsurance(_ sender: UIButton) {
        guard sender.tag < insurances.count else { return }
        let insurance = insurances[sender.tag]
        
        let editVC = EditInsuranceViewController(insurance: insurance)
        editVC.delegate = self
        let navVC = UINavigationController(rootViewController: editVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    @objc private func deleteInsurance(_ sender: UIButton) {
        guard sender.tag < insurances.count else { return }
        let insurance = insurances[sender.tag]
        
        let alert = UIAlertController(
            title: "Supprimer l'assurance",
            message: "Êtes-vous sûr de vouloir supprimer '\(insurance.name)'?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "Supprimer", style: .destructive) { [weak self] _ in
            self?.performDelete(insurance: insurance)
        })
        
        present(alert, animated: true)
    }
    
    private func performDelete(insurance: Insurance) {
        Task {
            do {
                _ = try await insuranceService.deleteInsurance(id: insurance.id)
                await MainActor.run {
                    self.loadInsurances()
                    self.showSuccess(message: "Assurance supprimée avec succès")
                }
            } catch {
                await MainActor.run {
                    self.showError(message: error.localizedDescription)
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

// MARK: - Delegates
extension AgencyInsurancesViewController: CreateInsuranceDelegate, EditInsuranceDelegate, AgencyInsuranceDetailDelegate {
    func didCreateInsurance() {
        loadInsurances()
    }
    
    func didUpdateInsurance() {
        loadInsurances()
    }
}
