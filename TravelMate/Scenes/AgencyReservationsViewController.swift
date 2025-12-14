import UIKit

class AgencyReservationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
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
        label.text = "Aucune réservation\n\nLes réservations de vos packs apparaîtront ici"
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
        title = "Réservations"
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
        let sortButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down.circle"),
            style: .plain,
            target: self,
            action: #selector(sortTapped)
        )
        
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )
        
        let refreshButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshData)
        )
        
        navigationItem.rightBarButtonItems = [refreshButton, sortButton, filterButton]
    }
    
    @objc private func refreshData() {
        fetchReservations()
    }
    
    private func fetchReservations() {
        loadingIndicator.startAnimating()
        emptyStateLabel.isHidden = true
        
        Task {
            do {
                let result = try await ReservationService.shared.getAgencyReservations()
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
        config.text = "\(reservation.pack?.titre ?? "Pack") - \(reservation.user?.name ?? "Utilisateur")"
        config.secondaryText = "\(reservation.travelersSummary) • \(reservation.formattedPrice)"
        
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        
        // Status badge
        let badge = UILabel()
        badge.text = reservation.status.displayName
        badge.font = .systemFont(ofSize: 12, weight: .bold)
        badge.textColor = .white
        badge.backgroundColor = reservation.status.color
        badge.textAlignment = .center
        badge.layer.cornerRadius = 10
        badge.clipsToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(badge)
        NSLayoutConstraint.activate([
            badge.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            badge.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            badge.widthAnchor.constraint(equalToConstant: 90),
            badge.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let reservation = isSearching ? filteredReservations[indexPath.row] : reservations[indexPath.row]
        showReservationActions(reservation)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - Search
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredReservations = reservations
        } else {
            isSearching = true
            filteredReservations = reservations.filter { reservation in
                (reservation.pack?.titre.lowercased().contains(searchText.lowercased()) ?? false) ||
                (reservation.user?.name.lowercased().contains(searchText.lowercased()) ?? false)
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
        alert.addAction(UIAlertAction(title: "En attente", style: .default) { _ in
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
    
    // MARK: - Sort
    
    @objc private func sortTapped() {
        let alert = UIAlertController(title: "Trier par", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Date: récent → ancien", style: .default) { _ in
            self.reservations.sort { reservation1, reservation2 in
                guard let date1 = reservation1.createdAt, let date2 = reservation2.createdAt else { return false }
                return date1 > date2
            }
            self.filteredReservations = self.reservations
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Date: ancien → récent", style: .default) { _ in
            self.reservations.sort { reservation1, reservation2 in
                guard let date1 = reservation1.createdAt, let date2 = reservation2.createdAt else { return false }
                return date1 < date2
            }
            self.filteredReservations = self.reservations
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Prix: bas → haut", style: .default) { _ in
            self.reservations.sort { $0.totalPrice < $1.totalPrice }
            self.filteredReservations = self.reservations
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Prix: haut → bas", style: .default) { _ in
            self.reservations.sort { $0.totalPrice > $1.totalPrice }
            self.filteredReservations = self.reservations
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Statut (en attente en premier)", style: .default) { _ in
            self.reservations.sort { reservation1, reservation2 in
                if reservation1.status == .pending && reservation2.status != .pending {
                    return true
                }
                return false
            }
            self.filteredReservations = self.reservations
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    private func showReservationActions(_ reservation: PackReservation) {
        let alert = UIAlertController(
            title: reservation.pack?.titre ?? "Réservation",
            message: """
            Client: \(reservation.user?.name ?? "N/A")
            Statut: \(reservation.status.displayName)
            Voyageurs: \(reservation.travelersSummary)
            Prix total: \(reservation.formattedPrice)
            Date: \(reservation.formattedDate)
            """,
            preferredStyle: .alert
        )
        
        if reservation.canBeAccepted {
            alert.addAction(UIAlertAction(title: "✅ Accepter", style: .default) { _ in
                self.acceptReservation(reservation)
            })
            
            alert.addAction(UIAlertAction(title: "❌ Refuser", style: .destructive) { _ in
                self.rejectReservation(reservation)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Fermer", style: .cancel))
        present(alert, animated: true)
    }
    
    private func acceptReservation(_ reservation: PackReservation) {
        guard let id = reservation.id else { return }
        
        Task {
            do {
                _ = try await ReservationService.shared.acceptReservation(id: id)
                DispatchQueue.main.async {
                    self.fetchReservations()
                    let alert = UIAlertController(
                        title: "✅ Réservation acceptée",
                        message: "Le client a été notifié et peut procéder au paiement.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            } catch {
                print("❌ Failed to accept: \(error)")
                self.showError("Impossible d'accepter la réservation")
            }
        }
    }
    
    private func rejectReservation(_ reservation: PackReservation) {
        guard let id = reservation.id else { return }
        
        Task {
            do {
                _ = try await ReservationService.shared.rejectReservation(id: id)
                DispatchQueue.main.async {
                    self.fetchReservations()
                    let alert = UIAlertController(
                        title: "❌ Réservation refusée",
                        message: "Le client a été notifié.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            } catch {
                print("❌ Failed to reject: \(error)")
                self.showError("Impossible de refuser la réservation")
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
