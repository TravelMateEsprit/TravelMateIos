import UIKit

class InsurancesViewController: UIViewController {
    private let insuranceService = InsuranceService.shared
    private var insurances: [Insurance] = []
    private var mySubscriptions: [Insurance] = []
    private var currentFilters = InsuranceSearchFilters()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Toutes", "Mes souscriptions"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
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
        label.text = "Aucune assurance disponible"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
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
        setupNavigationBar()
        
        // Recharger les données à chaque fois qu'on revient sur cet écran
        loadInsurances()
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .primaryColor
        navigationItem.leftBarButtonItem = backButton
        
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped)
        )
        filterButton.tintColor = .primaryColor
        navigationItem.rightBarButtonItem = filterButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        title = "Assurances"
        
        view.addSubview(segmentedControl)
        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentView)
        contentView.addSubview(insuranceStackView)
        contentView.addSubview(emptyStateLabel)
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
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
    
    @objc private func segmentChanged() {
        updateDisplay()
    }
    
    private func loadInsurances() {
        loadingIndicator.startAnimating()
        
        Task {
            do {
                async let allInsurances = insuranceService.getAllInsurances(filters: segmentedControl.selectedSegmentIndex == 0 ? currentFilters : nil)
                async let subscriptions = insuranceService.getMySubscriptions()
                
                self.insurances = try await allInsurances
                self.mySubscriptions = try await subscriptions
                
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.updateDisplay()
                }
            } catch {
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.displayError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func updateDisplay() {
        insuranceStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let displayInsurances = segmentedControl.selectedSegmentIndex == 0 ? insurances : mySubscriptions
        
        if displayInsurances.isEmpty {
            emptyStateLabel.isHidden = false
            emptyStateLabel.text = segmentedControl.selectedSegmentIndex == 0 ? "Aucune assurance disponible" : "Aucune souscription"
        } else {
            emptyStateLabel.isHidden = true
            for insurance in displayInsurances {
                let card = createInsuranceCard(insurance: insurance)
                insuranceStackView.addArrangedSubview(card)
            }
        }
    }
    
    private func createInsuranceCard(insurance: Insurance) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.1
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: "shield.lefthalf.filled"))
        iconView.tintColor = .primaryColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = insurance.name
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let priceLabel = UILabel()
        priceLabel.text = insurance.formattedPrice
        priceLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        priceLabel.textColor = .primaryColor
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let durationLabel = UILabel()
        durationLabel.text = insurance.duration
        durationLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        durationLabel.textColor = .systemGray
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = insurance.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .systemGray
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let detailButton = UIButton(type: .system)
        detailButton.setTitle("Voir détails", for: .normal)
        detailButton.setTitleColor(.primaryColor, for: .normal)
        detailButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        detailButton.tag = insurances.firstIndex(where: { $0.id == insurance.id }) ?? 0
        detailButton.addTarget(self, action: #selector(detailButtonTapped(_:)), for: .touchUpInside)
        
        container.addSubview(iconView)
        container.addSubview(nameLabel)
        container.addSubview(priceLabel)
        container.addSubview(durationLabel)
        container.addSubview(descriptionLabel)
        container.addSubview(detailButton)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 160),
            
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            priceLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            durationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            
            descriptionLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            detailButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            detailButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            detailButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    @objc private func detailButtonTapped(_ sender: UIButton) {
        let displayInsurances = segmentedControl.selectedSegmentIndex == 0 ? insurances : mySubscriptions
        guard sender.tag < displayInsurances.count else { return }
        
        let insurance = displayInsurances[sender.tag]
        let detailVC = InsuranceDetailViewController(insurance: insurance)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func displayError(message: String) {
        let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func filterButtonTapped() {
        let filtersVC = InsuranceFiltersViewController(currentFilters: currentFilters)
        filtersVC.delegate = self
        let navController = UINavigationController(rootViewController: filtersVC)
        present(navController, animated: true)
    }
}

extension InsurancesViewController: InsuranceFiltersDelegate {
    func didApplyFilters(_ filters: InsuranceSearchFilters) {
        currentFilters = filters
        loadInsurances()
    }
}

extension InsurancesViewController: InsuranceDetailDelegate {
    func didUpdateInsurance() {
        loadInsurances()
    }
}
