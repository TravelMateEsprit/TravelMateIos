import UIKit

class ReservationListViewController: UIViewController {
    private let voyageService = VoyageService.shared
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ReservationCardTableViewCell.self, forCellReuseIdentifier: "ReservationCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshReservations), for: .valueChanged)
        return control
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        let imageView = UIImageView(image: UIImage(systemName: "calendar.badge.exclamationmark"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Aucune réservation"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadReservations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setupNavigationBar()
        // Refresh data when returning
        if !voyageService.isReservationsLoading {
            Task {
                await voyageService.fetchReservations()
                updateUI()
            }
        }
    }
    
    private func setupNavigationBar() {
        title = "Mes Réservations"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadReservations(showLoading: Bool = true) {
        print("🔄 [RESERVATION LIST] Loading reservations...")
        
        if showLoading {
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            emptyStateView.isHidden = true
        }
        
        Task {
            do {
                print("🔍 [RESERVATION LIST] Starting to fetch reservations...")
                try await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask { [weak self] in
                        guard let self = self else { return }
                        await self.voyageService.fetchReservations()
                    }
                    try await group.waitForAll()
                }
                
                print("✅ [RESERVATION LIST] Successfully fetched reservations")
                
                await MainActor.run {
                    if self.voyageService.reservations.isEmpty {
                        print("ℹ️ [RESERVATION LIST] No reservations found")
                        self.showEmptyState()
                    } else {
                        print("📱 [RESERVATION LIST] Updating UI with \(self.voyageService.reservations.count) reservations")
                        self.hideEmptyState()
                    }
                    self.updateUI()
                }
            } catch {
                print("❌ [RESERVATION LIST] Error loading reservations: \(error.localizedDescription)")
                
                // Log more details about the error
                if let networkError = error as? NetworkService.NetworkError {
                    print("   - Network error: \(networkError.localizedDescription)")
                } else if let decodingError = error as? DecodingError {
                    print("   - Decoding error: \(decodingError.localizedDescription)")
                }
                
                await MainActor.run {
                    self.showError(message: "Impossible de charger les réservations. Veuillez vérifier votre connexion et réessayer.")
                    self.hideLoading()
                    self.showEmptyState()
                }
            }
        }
    }
    
    @objc private func refreshReservations() {
        loadReservations(showLoading: false)
    }
    
    private func updateUI() {
        loadingIndicator.stopAnimating()
        refreshControl.endRefreshing()
        
        let reservations = voyageService.reservations
        emptyStateView.isHidden = !reservations.isEmpty
        tableView.isHidden = reservations.isEmpty
        
        if !reservations.isEmpty {
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    private func showEmptyState() {
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }
    
    private func hideEmptyState() {
        emptyStateView.isHidden = true
        tableView.isHidden = false
    }
    
    private func hideLoading() {
        loadingIndicator.stopAnimating()
        refreshControl.endRefreshing()
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Erreur",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ReservationListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voyageService.reservations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCell", for: indexPath) as! ReservationCardTableViewCell
        cell.configure(with: voyageService.reservations[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ReservationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Add navigation to reservation detail if needed
    }
}

// MARK: - ReservationCardTableViewCell
class ReservationCardTableViewCell: UITableViewCell {
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let voyageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let destinationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let peopleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
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
        cardView.addSubview(voyageImageView)
        cardView.addSubview(destinationLabel)
        cardView.addSubview(dateLabel)
        cardView.addSubview(typeLabel)
        cardView.addSubview(priceLabel)
        cardView.addSubview(peopleLabel)
        cardView.addSubview(statusBadge)
        statusBadge.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            voyageImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            voyageImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            voyageImageView.widthAnchor.constraint(equalToConstant: 100),
            voyageImageView.heightAnchor.constraint(equalToConstant: 100),
            
            destinationLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            destinationLabel.leadingAnchor.constraint(equalTo: voyageImageView.trailingAnchor, constant: 12),
            destinationLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusBadge.leadingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: voyageImageView.trailingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            typeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            typeLabel.leadingAnchor.constraint(equalTo: voyageImageView.trailingAnchor, constant: 12),
            
            priceLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: voyageImageView.trailingAnchor, constant: 12),
            
            peopleLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            peopleLabel.leadingAnchor.constraint(equalTo: voyageImageView.trailingAnchor, constant: 12),
            peopleLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16),
            
            statusBadge.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            statusBadge.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            statusBadge.heightAnchor.constraint(equalToConstant: 24),
            
            statusLabel.topAnchor.constraint(equalTo: statusBadge.topAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: -8),
            statusLabel.bottomAnchor.constraint(equalTo: statusBadge.bottomAnchor, constant: -4)
        ])
    }
    
    func configure(with reservation: Reservation) {
        destinationLabel.text = reservation.voyage_id.destination.uppercased()
        dateLabel.text = reservation.formattedDateRange()
        typeLabel.text = reservation.typeDisplayName()
        priceLabel.text = reservation.formattedPrice()
        peopleLabel.text = "\(reservation.nombre_personnes) \(reservation.nombre_personnes == 1 ? "personne" : "personnes")"
        
        statusLabel.text = reservation.statusDisplayName()
        statusBadge.backgroundColor = reservation.statusColor()
        
        // Load image
        if let imageUrl = reservation.voyage_id.imageUrl, let url = URL(string: imageUrl) {
            loadImage(from: url)
        } else {
            // Use type icon
            let iconName: String
            switch reservation.voyage_id.type.lowercased() {
            case "vol": iconName = "airplane"
            case "hotel": iconName = "bed.double.fill"
            case "voiture": iconName = "car.fill"
            default: iconName = "tag.fill"
            }
            voyageImageView.image = UIImage(systemName: iconName)
            voyageImageView.tintColor = .systemGray3
            voyageImageView.contentMode = .scaleAspectFit
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.voyageImageView.image = image
                self?.voyageImageView.contentMode = .scaleAspectFill
                self?.voyageImageView.tintColor = nil
            }
        }.resume()
    }
}

