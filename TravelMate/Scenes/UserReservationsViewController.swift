import UIKit

class UserReservationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    private var reservations: [PackReservation] = []
    private var filteredReservations: [PackReservation] = []
    private var isSearching = false
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Rechercher une réservation..."
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.separatorStyle = .singleLine
        tv.backgroundColor = UIColor(white: 0.96, alpha: 1)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Aucune réservation\n\nVos réservations apparaîtront ici"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mes Réservations"
        view.backgroundColor = .white
        
        setupUI()
        setupToolbar()
        fetchReservations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchReservations()
    }
    
    private func setupUI() {
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupToolbar() {
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )
        navigationItem.rightBarButtonItem = filterButton
    }
    
    private func fetchReservations() {
        loadingIndicator.startAnimating()
        emptyStateLabel.isHidden = true
        
        Task {
            do {
                let result = try await ReservationService.shared.getUserReservations()
                self.reservations = result
                self.filteredReservations = result
                
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.emptyStateLabel.isHidden = !self.reservations.isEmpty
                    self.tableView.reloadData()
                }
            } catch {
                print("❌ Failed to fetch reservations: \(error)")
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.emptyStateLabel.isHidden = false
                }
            }
        }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredReservations.count : reservations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let reservation = isSearching ? filteredReservations[indexPath.row] : reservations[indexPath.row]
        
        // Configure cell
        var config = cell.defaultContentConfiguration()
        config.text = reservation.pack?.titre ?? "Pack"
        config.secondaryText = "\(reservation.travelersSummary) • \(reservation.formattedPrice) • \(reservation.status.displayName)"
        
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        
        // Status badge
        let badge = UIView()
        badge.backgroundColor = reservation.status.color
        badge.layer.cornerRadius = 8
        badge.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(badge)
        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(equalToConstant: 16),
            badge.heightAnchor.constraint(equalToConstant: 16),
            badge.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            badge.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let reservation = isSearching ? filteredReservations[indexPath.row] : reservations[indexPath.row]
        showReservationDetails(reservation)
    }
    
    // MARK: - Search
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredReservations = reservations
        } else {
            isSearching = true
            filteredReservations = reservations.filter { reservation in
                reservation.pack?.titre.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Filter
    
    @objc private func filterTapped() {
        let alert = UIAlertController(title: "Filtrer par statut", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Tous", style: .default) { _ in
            self.filteredReservations = self.reservations
            self.isSearching = false
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "En  attente", style: .default) { _ in
            self.filterByStatus(.pending)
        })
        alert.addAction(UIAlertAction(title: "Acceptées", style: .default) { _ in
            self.filterByStatus(.accepted)
        })
        alert.addAction(UIAlertAction(title: "Refusées", style: .default) { _ in
            self.filterByStatus(.rejected)
        })
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func filterByStatus(_ status: ReservationStatus) {
        isSearching = true
        filteredReservations = reservations.filter { $0.status == status }
        tableView.reloadData()
    }
    
    private func showReservationDetails(_ reservation: PackReservation) {
        let alert = UIAlertController(
            title: reservation.pack?.titre ?? "Réservation",
            message: """
            Statut: \(reservation.status.displayName)
            Voyageurs: \(reservation.travelersSummary)
            Prix total: \(reservation.formattedPrice)
            Date: \(reservation.formattedDate)
            """,
            preferredStyle: .alert
        )
        
        if reservation.showPaymentButton {
            alert.addAction(UIAlertAction(title: "💳 Payer maintenant", style: .default) { _ in
                self.proceedToPayment(reservation)
            })
        }
        
        if reservation.canBeCancelled {
            alert.addAction(UIAlertAction(title: "Annuler la réservation", style: .destructive) { _ in
                self.cancelReservation(reservation)
            })
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    private func proceedToPayment(_ reservation: PackReservation) {
        let alert = UIAlertController(
            title: "Choisir la méthode de paiement",
            message: "Total à payer: \(reservation.formattedPrice)",
            preferredStyle: .actionSheet
        )
        
        // Apple Pay option
        if PaymentService.shared.isApplePayAvailable() {
            alert.addAction(UIAlertAction(title: " Apple Pay", style: .default) { _ in
                self.processApplePay(reservation)
            })
        }
        
        // Web Payment option
        alert.addAction(UIAlertAction(title: "💳 Carte bancaire", style: .default) { _ in
            self.processWebPayment(reservation)
        })
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        present(alert, animated: true)
    }
    
    private func processApplePay(_ reservation: PackReservation) {
        PaymentService.shared.processPayment(for: reservation) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paymentResult):
                    self?.showPaymentSuccess(paymentResult)
                case .failure(let error):
                    self?.showPaymentError(error)
                }
            }
        }
    }
    
    private func processWebPayment(_ reservation: PackReservation) {
        PaymentService.shared.processWebPayment(for: reservation) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paymentResult):
                    let alert = UIAlertController(
                        title: "✅ Paiement  en cours",
                        message: "Vous allez être redirigé vers la page de paiement.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                case .failure(let error):
                    self?.showPaymentError(error)
                }
            }
        }
    }
    
    private func showPaymentSuccess(_ result: PaymentResult) {
        let alert = UIAlertController(
            title: "✅ Paiement réussi!",
            message: "Transaction ID: \(result.transactionId)\nMéthode: \(result.method)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.fetchReservations()
        })
        present(alert, animated: true)
    }
    
    private func showPaymentError(_ error: Error) {
        let alert = UIAlertController(
            title: "❌ Erreur de paiement",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func cancelReservation(_ reservation: PackReservation) {
        guard let id = reservation.id else { return }
        
        Task {
            do {
                _ = try await ReservationService.shared.cancelReservation(id: id)
                DispatchQueue.main.async {
                    self.fetchReservations()
                    let alert = UIAlertController(title: "✅ Réservation annulée", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            } catch {
                print("❌ Failed to cancel: \(error)")
            }
        }
    }
}
