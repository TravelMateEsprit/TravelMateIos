import UIKit

class MyApplicationsViewController: UIViewController {
    
    private let insuranceService = InsuranceService.shared
    private var applications: [InsuranceApplication] = []
    private var filteredApplications: [InsuranceApplication] = []
    private var selectedFilter: ApplicationStatus?
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.backgroundColor = .systemGroupedBackground
        return table
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .primaryColor
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "doc.text.magnifyingglass")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Aucune demande"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Toutes", "En attente", "Approuvées", "Rejetées"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadApplications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadApplications()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "Mes demandes"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyImageView)
        emptyStateView.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalToConstant: 200),
            
            emptyImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 16),
            emptyLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ApplicationCell.self, forCellReuseIdentifier: "ApplicationCell")
        
        segmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshTapped)
        )
    }
    
    // MARK: - Load Data
    
    private func loadApplications() {
        loadingIndicator.startAnimating()
        tableView.isHidden = true
        emptyStateView.isHidden = true
        
        Task {
            do {
                let apps = try await insuranceService.getMyApplications()
                
                await MainActor.run {
                    applications = apps
                    applyFilter()
                    loadingIndicator.stopAnimating()
                    updateUI()
                }
            } catch {
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    showAlert(message: "Erreur lors du chargement: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func applyFilter() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            selectedFilter = nil
            filteredApplications = applications
        case 1:
            selectedFilter = .pending
            filteredApplications = applications.filter { $0.status == .pending }
        case 2:
            selectedFilter = .approved
            filteredApplications = applications.filter { $0.status == .approved }
        case 3:
            selectedFilter = .rejected
            filteredApplications = applications.filter { $0.status == .rejected }
        default:
            filteredApplications = applications
        }
    }
    
    private func updateUI() {
        if filteredApplications.isEmpty {
            tableView.isHidden = true
            emptyStateView.isHidden = false
        } else {
            tableView.isHidden = false
            emptyStateView.isHidden = true
            tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @objc private func filterChanged() {
        applyFilter()
        updateUI()
    }
    
    @objc private func refreshTapped() {
        loadApplications()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension MyApplicationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredApplications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApplicationCell", for: indexPath) as! ApplicationCell
        cell.configure(with: filteredApplications[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let application = filteredApplications[indexPath.row]
        let detailVC = ApplicationDetailViewController(application: application)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - Application Cell

class ApplicationCell: UITableViewCell {
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.08
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let insuranceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let destinationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(insuranceNameLabel)
        cardView.addSubview(statusBadge)
        statusBadge.addSubview(statusLabel)
        cardView.addSubview(destinationLabel)
        cardView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            insuranceNameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            insuranceNameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            insuranceNameLabel.trailingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: -8),
            
            statusBadge.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            statusBadge.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            statusBadge.heightAnchor.constraint(equalToConstant: 24),
            
            statusLabel.topAnchor.constraint(equalTo: statusBadge.topAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: -10),
            statusLabel.bottomAnchor.constraint(equalTo: statusBadge.bottomAnchor, constant: -4),
            
            destinationLabel.topAnchor.constraint(equalTo: insuranceNameLabel.bottomAnchor, constant: 8),
            destinationLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            destinationLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with application: InsuranceApplication) {
        insuranceNameLabel.text = application.insuranceId?.name ?? "Assurance"
        destinationLabel.text = "📍 \(application.destination)"
        dateLabel.text = "Du \(application.formattedDepartureDate) au \(application.formattedArrivalDate)"
        
        statusLabel.text = application.status.displayName
        statusBadge.backgroundColor = application.status.color
    }
}
