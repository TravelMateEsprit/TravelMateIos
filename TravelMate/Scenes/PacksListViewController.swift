import UIKit

class PacksListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    private var packs: [Offer] = []
    private var filteredPacks: [Offer] = []
    private var isSearching = false
    
    // Multi-select mode
    private var isEditingMode = false
    private var selectedPackIds: Set<String> = []
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Rechercher un pack..."
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(PackCell.self, forCellReuseIdentifier: PackCell.identifier)
        tv.showsVerticalScrollIndicator = false
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor(white: 0.96, alpha: 1)
        return tv
    }()
    
    private let refresh = UIRefreshControl()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Aucun pack\n\nAppuyez sur + pour créer votre premier pack"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mes Packs"
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)

        setupToolbar()
        setupTable()
        fetchPacks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPacks()
    }

    // MARK: - Setup
    
    private func setupToolbar() {
        // Messages button (conversation list)
        let messagesButton = UIBarButtonItem(
            image: UIImage(systemName: "message.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(messagesTopped)
        )
        
        // Create pack button
        let createButton = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(createPackTapped)
        )
        
        // Filter button
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )
        
        // Sort button
        let sortButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down.circle"),
            style: .plain,
            target: self,
            action: #selector(sortTapped)
        )
        
        navigationItem.rightBarButtonItems = [createButton, messagesButton, sortButton, filterButton]
        
        // Edit button on left side for multi-select
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Sélectionner",
            style: .plain,
            target: self,
            action: #selector(toggleEditMode)
        )
    }
    
    private func setupTable() {
        searchBar.delegate = self
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refresh
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    @objc private func refreshData() {
        fetchPacks()
    }

    // MARK: - Fetch packs
    private func fetchPacks() {
        Task {
            do {
                let result = try await PackService.shared.getAllPacks()
                
                // Filter only packs by current agency
                if let agencyId = AuthService.shared.currentUser?.id {
                    self.packs = result.filter { $0.id_agence == agencyId }
                } else {
                    self.packs = result
                }
                
                self.filteredPacks = self.packs
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refresh.endRefreshing()
                    self.emptyStateLabel.isHidden = !self.packs.isEmpty
                }
                
            } catch {
                print("❌ Failed to fetch packs: \(error)")
                DispatchQueue.main.async {
                    self.packs = []
                    self.tableView.reloadData()
                    self.refresh.endRefreshing()
                    self.emptyStateLabel.isHidden = false
                }
            }
        }
    }

    // MARK: - Table View Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredPacks.count : packs.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PackCell.identifier,
            for: indexPath
        ) as? PackCell else {
            return UITableViewCell()
        }

        let pack = isSearching ? filteredPacks[indexPath.row] : packs[indexPath.row]
        cell.configure(with: pack)

        // Hide chat button for agency's own packs
        cell.onChatTapped = nil
        
        // Show checkmark if selected in editing mode
        if isEditingMode {
            let isSelected = selectedPackIds.contains(pack.id ?? "")
            cell.accessoryType = isSelected ? .checkmark : .none
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    // MARK: - Select row → Details or Toggle Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pack = isSearching ? filteredPacks[indexPath.row] : packs[indexPath.row]
        
        if isEditingMode {
            // Multi-select mode: toggle selection
            guard let packId = pack.id else { return }
            
            if selectedPackIds.contains(packId) {
                selectedPackIds.remove(packId)
            } else {
                selectedPackIds.insert(packId)
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
            updateEditModeUI()
        } else {
            // Normal mode: navigate to details
            let detailsVC = PackDetailViewController(offer: pack)
            navigationController?.pushViewController(detailsVC, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    // MARK: - Swipe to delete
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let pack = isSearching ? filteredPacks[indexPath.row] : packs[indexPath.row]
            deletePack(pack)
        }
    }
    
    // MARK: - Search Bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredPacks = packs
        } else {
            isSearching = true
            filteredPacks = packs.filter { pack in
                pack.titre.lowercased().contains(searchText.lowercased()) ||
                (pack.destination?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        filteredPacks = packs
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc private func messagesTopped() {
        let messagesVC = ConversationsListViewController()
        navigationController?.pushViewController(messagesVC, animated: true)
    }
    
    @objc private func createPackTapped() {
        let createVC = CreatePackViewController()
        let navController = UINavigationController(rootViewController: createVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func filterTapped() {
        let alert = UIAlertController(title: "Filtrer par", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Tous", style: .default) { _ in
            self.isSearching = false
            self.filteredPacks = self.packs
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Prix < 1000 DT", style: .default) { _ in
            self.filterByPrice(max: 1000)
        })
        alert.addAction(UIAlertAction(title: "Prix 1000-2000 DT", style: .default) { _ in
            self.filterByPriceRange(min: 1000, max: 2000)
        })
        alert.addAction(UIAlertAction(title: "Prix > 2000 DT", style: .default) { _ in
            self.filterByPrice(min: 2000)
        })
        alert.addAction(UIAlertAction(title: "Actifs seulement", style: .default) { _ in
            self.filterByActive()
        })
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func sortTapped() {
        let alert = UIAlertController(title: "Trier par", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Prix: bas → haut", style: .default) { _ in
            self.packs.sort { $0.prix < $1.prix }
            self.filteredPacks = self.packs
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Prix: haut → bas", style: .default) { _ in
            self.packs.sort { $0.prix > $1.prix }
            self.filteredPacks = self.packs
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Alphabétique", style: .default) { _ in
            self.packs.sort { $0.titre < $1.titre }
            self.filteredPacks = self.packs
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Date de début", style: .default) { _ in
            self.packs.sort { $0.date_debut < $1.date_debut }
            self.filteredPacks = self.packs
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Filter Helpers
    
    private func filterByPrice(min: Double? = nil, max: Double? = nil) {
        isSearching = true
        filteredPacks = packs.filter { pack in
            if let min = min, pack.prix < min { return false }
            if let max = max, pack.prix > max { return false }
            return true
        }
        tableView.reloadData()
    }
    
    private func filterByPriceRange(min: Double, max: Double) {
        isSearching = true
        filteredPacks = packs.filter { $0.prix >= min && $0.prix <= max }
        tableView.reloadData()
    }
    
    private func filterByActive() {
        isSearching = true
        filteredPacks = packs.filter { $0.actif == true }
        tableView.reloadData()
    }
    
    // MARK: - Delete Pack
    
    private func deletePack(_ pack: Offer) {
        guard let id = pack.id else { return }
        
        let alert = UIAlertController(
            title: "Supprimer ce pack ?",
            message: "Cette action est irréversible.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "Supprimer", style: .destructive) { _ in
            Task {
                do {
                    try await PackService.shared.deletePack(id: id)
                    DispatchQueue.main.async {
                        self.fetchPacks()
                    }
                } catch {
                    print("❌ Failed to delete: \(error)")
                }
            }
        })
        present(alert, animated: true)
    }
    
    // MARK: - Multi-Select Mode
    
    @objc private func toggleEditMode() {
        isEditingMode.toggle()
        selectedPackIds.removeAll()
        
        if isEditingMode {
            // Entering edit mode
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Annuler",
                style: .plain,
                target: self,
                action: #selector(toggleEditMode)
            )
            
            // Add toolbar with delete and select all buttons
            let selectAllButton = UIBarButtonItem(
                title: "Tout sélectionner",
                style: .plain,
                target: self,
                action: #selector(selectAllPacks)
            )
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            let deleteButton = UIBarButtonItem(
                title: "Supprimer (0)",
                style: .plain,
                target: self,
                action: #selector(deleteSelectedPacks)
            )
            deleteButton.tintColor = .systemRed
            
            navigationController?.setToolbarHidden(false, animated: true)
            setToolbarItems([selectAllButton, flexSpace, deleteButton], animated: true)
        } else {
            // Exiting edit mode
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Sélectionner",
                style: .plain,
                target: self,
                action: #selector(toggleEditMode)
            )
            
            navigationController?.setToolbarHidden(true, animated: true)
            setToolbarItems(nil, animated: true)
        }
        
        tableView.reloadData()
    }
    
    @objc private func selectAllPacks() {
        let currentPacks = isSearching ? filteredPacks : packs
        
        if selectedPackIds.count == currentPacks.count {
            // Deselect all
            selectedPackIds.removeAll()
        } else {
            // Select all
            selectedPackIds = Set(currentPacks.compactMap { $0.id })
        }
        
        tableView.reloadData()
        updateEditModeUI()
    }
    
    @objc private func deleteSelectedPacks() {
        guard !selectedPackIds.isEmpty else { return }
        
        let count = selectedPackIds.count
        let alert = UIAlertController(
            title: "Supprimer \(count) pack(s) ?",
            message: "Cette action est irréversible.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "Supprimer", style: .destructive) { _ in
            Task {
                var successCount = 0
                for packId in self.selectedPackIds {
                    do {
                        try await PackService.shared.deletePack(id: packId)
                        successCount += 1
                    } catch {
                        print("❌ Failed to delete pack \(packId): \(error)")
                    }
                }
                
                DispatchQueue.main.async {
                    self.selectedPackIds.removeAll()
                    self.fetchPacks()
                    
                    if successCount > 0 {
                        let successAlert = UIAlertController(
                            title: "✅ Suppression réussie",
                            message: "\(successCount) pack(s) supprimé(s)",
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(successAlert, animated: true)
                    }
                    
                    // Exit edit mode
                    if self.isEditingMode {
                        self.toggleEditMode()
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    private func updateEditModeUI() {
        guard let deleteButton = toolbarItems?.last else { return }
        deleteButton.title = "Supprimer (\(selectedPackIds.count))"
        deleteButton.isEnabled = !selectedPackIds.isEmpty
    }
}
