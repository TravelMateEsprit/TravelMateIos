import UIKit
import Foundation

// MARK: - Sort Option
extension VoyageListViewController {
    enum SortOption: String, CaseIterable {
        case dateAscending = "Date croissante"
        case dateDescending = "Date décroissante"
        case priceAscending = "Prix croissant"
        case priceDescending = "Prix décroissant"
    }
}

class VoyageListViewController: UIViewController {
    private let voyageService = VoyageService.shared
    
    // Filter properties
    private var filterButton: UIBarButtonItem!
    private var currentSortOption: SortOption = .dateAscending
    private var currentTypeFilter: String? = nil
    private var minPrice: Double? = nil
    private var maxPrice: Double? = nil
    
    // AI Recommendation selected type
    private var selectedAIType = "vol"
    private var isShowingAIResults = false
    private struct AIRecommendation: Decodable {
        let voyageId: String
        let score: Double
        let reason: String
    }
    
    // Selection mode properties
    private var isSelectionMode = false {
        didSet {
            updateSelectionModeUI()
        }
    }
    private var selectedVoyages: [Voyage] = []
    
    // Navigation bar buttons
    private var compareButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    private var reservationsButton: UIBarButtonItem!
    
    // AI Recommendation Card
    private lazy var aiRecommendationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.isHidden = false
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        
        let titleLabel = UILabel()
        titleLabel.text = "🤖 Recommandation AI"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .systemBlue
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Choisir destination, budget, type"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .systemBlue.withAlphaComponent(0.7)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(aiRecommendationTapped))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VoyageCardTableViewCell.self, forCellReuseIdentifier: "VoyageCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        tableView.refreshControl = refreshControl
        // Add bottom content inset to prevent content from going under the button
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshVoyages), for: .valueChanged)
        return control
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Rechercher une destination..."
        return controller
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .systemOrange
        button.tintColor = .white
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        // Ensure button is above other views
        button.layer.zPosition = 1000
        return button
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
        
        let imageView = UIImageView(image: UIImage(systemName: "airplane"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Aucun voyage disponible"
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
    
    private var filteredVoyages: [Voyage] = []
    private var isSearching: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    private var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad called")
        
        // Debug: Check if view is embedded in navigation controller
        if navigationController != nil {
            print("View is embedded in navigation controller")
        } else {
            print("View is NOT embedded in navigation controller")
        }
        
        setupUI()
        loadVoyages()
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(voyageSelectionChanged),
            name: NSNotification.Name("VoyageSelectionChanged"),
            object: nil
        )
    }
    
    @objc private func voyageSelectionChanged() {
        // Update selected voyages based on cell states
        selectedVoyages.removeAll()
        
        for index in 0..<tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? VoyageCardTableViewCell,
               cell.isSelectedForComparison {
                let voyage = getVoyage(at: indexPath)
                selectedVoyages.append(voyage)
            }
        }
        
        // Update toolbar button and navigation bar button states
        updateToolbarButton()
        if isSelectionMode {
            compareButton.isEnabled = selectedVoyages.count >= 2 && selectedVoyages.count <= 4
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func getVoyage(at indexPath: IndexPath) -> Voyage {
        if isSearching {
            return filteredVoyages[indexPath.row]
        } else {
            if currentTypeFilter != nil || minPrice != nil || maxPrice != nil || currentSortOption != .dateAscending {
                return filteredVoyages[indexPath.row]
            } else {
                return voyageService.voyages[indexPath.row]
            }
        }
    }
    
    @objc private func compareButtonTapped() {
        if isSelectionMode {
            // If already in selection mode, proceed to comparison if valid selection
            if selectedVoyages.count >= 2 && selectedVoyages.count <= 4 {
                print("Navigating to comparison with \(selectedVoyages.count) voyages:")
                for (index, voyage) in selectedVoyages.enumerated() {
                    print("  \(index + 1): \(voyage.destination)")
                }
                // Create a copy of selected voyages for the comparison view
                let voyagesToCompare = selectedVoyages
                // Exit selection mode before navigating to comparison
                exitSelectionMode()
                // Clear selected voyages after creating copy
                selectedVoyages.removeAll()
                // Navigate to comparison view
                let comparisonVC = ComparisonViewController(voyages: voyagesToCompare)
                navigationController?.pushViewController(comparisonVC, animated: true)
            } else if selectedVoyages.count < 2 {
                // Show alert if less than 2 selected
                let alert = UIAlertController(
                    title: "Sélection requise",
                    message: "Veuillez sélectionner au moins 2 voyages pour les comparer.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            } else {
                // Show alert if more than 4 selected
                let alert = UIAlertController(
                    title: "Limite dépassée",
                    message: "Vous ne pouvez comparer que 4 voyages maximum.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        } else {
            // Enter selection mode
            isSelectionMode = true
        }
    }
    
    @objc private func cancelSelectionButtonTapped() {
        exitSelectionMode()
    }
    
    private func updateSelectionModeUI() {
        // Update navigation bar
        updateNavigationBarItems()
        
        if isSelectionMode {
            // In selection mode, enable compare button only when 2-4 voyages are selected
            compareButton.isEnabled = selectedVoyages.count >= 2 && selectedVoyages.count <= 4
            filterButton.isEnabled = false
        } else {
            // In normal mode, enable all buttons
            compareButton.isEnabled = true
            filterButton.isEnabled = true
        }
        
        // Update all cells
        for index in 0..<tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? VoyageCardTableViewCell {
                cell.isSelectionModeEnabled = isSelectionMode
            }
        }
        
        // Update toolbar button
        updateToolbarButton()
    }
    
    private func updateToolbarButton() {
        // Check selection limits
        if selectedVoyages.count > 4 {
            let alert = UIAlertController(
                title: "Limite atteinte",
                message: "Vous ne pouvez comparer que 4 voyages maximum.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
            // Deselect the last selected voyage
            selectedVoyages.removeLast()
        }
        
        // Update compare button enable state based on selection count
        if isSelectionMode {
            compareButton.isEnabled = selectedVoyages.count >= 2 && selectedVoyages.count <= 4
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        view.addSubview(aiRecommendationView)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateView)
        view.addSubview(createButton)
        
        // Bring button to front to ensure it's above other views
        view.bringSubviewToFront(createButton)
        
        NSLayoutConstraint.activate([
            aiRecommendationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            aiRecommendationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            aiRecommendationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            aiRecommendationView.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: aiRecommendationView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            createButton.widthAnchor.constraint(equalToConstant: 56),
            createButton.heightAnchor.constraint(equalToConstant: 56),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear called")
        print("Navigation bar hidden: \(navigationController?.isNavigationBarHidden ?? false)")
        navigationController?.setNavigationBarHidden(false, animated: animated)
        print("Navigation bar hidden after set: \(navigationController?.isNavigationBarHidden ?? false)")
        
        setupNavigationBar()
        updateNavigationBarItems()
        // Refresh data when returning from detail view
        if !voyageService.isLoading {
            Task {
                await voyageService.fetchVoyages()
                updateUI()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Ensure button is always on top
        view.bringSubviewToFront(createButton)
        // Ensure we're in the correct state
        updateNavigationBarItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Reset selection mode when navigating away
        exitSelectionMode()
    }

    private func setupNavigationBar() {
        print("setupNavigationBar called")
        title = "Voyages Disponibles"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Debug: Check if navigation controller exists
        if let navController = navigationController {
            print("Navigation controller exists: \(navController)")
        } else {
            print("Navigation controller is nil")
            return
        }
        
        // Create all navigation bar buttons
        if compareButton == nil {
            compareButton = UIBarButtonItem(
                image: UIImage(systemName: "chart.bar.xaxis"),
                style: .plain,
                target: self,
                action: #selector(compareButtonTapped)
            )
            compareButton.tintColor = .systemOrange
        }
        
        if cancelButton == nil {
            cancelButton = UIBarButtonItem(
                title: "Cancel",
                style: .plain,
                target: self,
                action: #selector(cancelSelectionButtonTapped)
            )
            cancelButton.tintColor = .systemOrange
        }
        
        if reservationsButton == nil {
            reservationsButton = UIBarButtonItem(
                image: UIImage(systemName: "calendar"),
                style: .plain,
                target: self,
                action: #selector(reservationsButtonTapped)
            )
            reservationsButton.tintColor = .systemOrange
        }
        
        if filterButton == nil {
            filterButton = UIBarButtonItem(
                image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
                style: .plain,
                target: self,
                action: #selector(filterButtonTapped)
            )
            filterButton.tintColor = .systemOrange
        }
        
        // AI Recommendations button removed since we're using the card view approach
        
        // Set initial navigation bar state
        updateNavigationBarItems()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func updateNavigationBarItems() {
        if isSelectionMode {
            // In selection mode, show the compare button (to navigate to comparison) and cancel button
            navigationItem.rightBarButtonItems = [compareButton, cancelButton]
            print("Navigation bar items set to selection mode: compareButton, cancelButton")
        } else {
            // In normal mode, show all standard buttons (without AI button since we're using the card view)
            navigationItem.rightBarButtonItems = [reservationsButton, filterButton, compareButton]
            print("Navigation bar items set to normal mode: reservationsButton, filterButton, compareButton")
        }
    }
    
    @objc private func reservationsButtonTapped() {
        let reservationsVC = ReservationListViewController()
        navigationController?.pushViewController(reservationsVC, animated: true)
    }
    
    @objc private func filterButtonTapped() {
        let filterVC = FilterViewController(
            currentSortOption: currentSortOption,
            currentTypeFilter: currentTypeFilter,
            minPrice: minPrice,
            maxPrice: maxPrice
        )
        filterVC.delegate = self
        let navController = UINavigationController(rootViewController: filterVC)
        present(navController, animated: true)
    }
    
    private func updateFilterButtonAppearance() {
        let hasActiveFilters = currentTypeFilter != nil || minPrice != nil || maxPrice != nil
        let imageName = hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
        filterButton.image = UIImage(systemName: imageName)
    }
    
    private func applyFiltersAndSort() {
        var voyages = voyageService.voyages
        
        // Apply type filter
        if let typeFilter = currentTypeFilter {
            voyages = voyages.filter { $0.type == typeFilter }
        }
        
        // Apply price filters
        if let minPrice = minPrice {
            voyages = voyages.filter { ($0.prix_estime ?? 0) >= minPrice }
        }
        if let maxPrice = maxPrice {
            voyages = voyages.filter { ($0.prix_estime ?? 0) <= maxPrice }
        }
        
        // Apply sorting
        voyages = voyages.sorted { voyage1, voyage2 in
            switch currentSortOption {
            case .dateAscending:
                return voyage1.date_depart < voyage2.date_depart
            case .dateDescending:
                return voyage1.date_depart > voyage2.date_depart
            case .priceAscending:
                return (voyage1.prix_estime ?? 0) < (voyage2.prix_estime ?? 0)
            case .priceDescending:
                return (voyage1.prix_estime ?? 0) > (voyage2.prix_estime ?? 0)
            }
        }
        
        self.filteredVoyages = voyages
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func loadVoyages() {
        Task {
            await voyageService.fetchVoyages()
            updateUI()
        }
    }
    
    @objc private func refreshVoyages() {
        Task {
            await voyageService.fetchVoyages()
            updateUI()
            refreshControl.endRefreshing()
        }
    }
    
    @objc private func createButtonTapped() {
        print("Create button tapped!")
        let createVC = CreateVoyageViewController()
        let navController = UINavigationController(rootViewController: createVC)
        navController.modalPresentationStyle = .pageSheet
        
        // Ensure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            self?.present(navController, animated: true, completion: {
                print("Create voyage modal presented")
            })
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.voyageService.isLoading {
                self.loadingIndicator.startAnimating()
                self.tableView.isHidden = true
            } else {
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = false
                
                if !self.isSearching {
                    self.applyFiltersAndSort()
                } else {
                    self.filterVoyages(for: self.searchController.searchBar.text ?? "")
                }
                self.updateEmptyState()
            }
        }
    }
    
    private func updateEmptyState() {
        let count: Int
        if isSearching {
            count = filteredVoyages.count
        } else {
            if isShowingAIResults {
                count = filteredVoyages.count
            } else if currentTypeFilter != nil || minPrice != nil || maxPrice != nil || currentSortOption != .dateAscending {
                count = filteredVoyages.count
            } else {
                count = voyageService.voyages.count
            }
        }
        emptyStateView.isHidden = count > 0
    }
    
    private func filterVoyages(for searchText: String) {
        var filtered = voyageService.voyages
        
        if !searchText.isEmpty {
            filtered = filtered.filter { voyage in
                return voyage.destination.lowercased().contains(searchText.lowercased()) ||
                       (voyage.description?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        
        if let typeFilter = currentTypeFilter {
            filtered = filtered.filter { $0.type == typeFilter }
        }
        
        if let minPrice = minPrice {
            filtered = filtered.filter { ($0.prix_estime ?? 0) >= minPrice }
        }
        if let maxPrice = maxPrice {
            filtered = filtered.filter { ($0.prix_estime ?? 0) <= maxPrice }
        }
        
        // FIX: Use sorted(by:) instead of sort
        filtered = filtered.sorted { voyage1, voyage2 in
            switch currentSortOption {
            case .dateAscending:
                return voyage1.date_depart < voyage2.date_depart
            case .dateDescending:
                return voyage1.date_depart > voyage2.date_depart
            case .priceAscending:
                return (voyage1.prix_estime ?? 0) < (voyage2.prix_estime ?? 0)
            case .priceDescending:
                return (voyage1.prix_estime ?? 0) > (voyage2.prix_estime ?? 0)
            }
        }
        
        filteredVoyages = filtered
        tableView.reloadData()
    }
    
    private func exitSelectionMode() {
        print("Exiting selection mode with \(selectedVoyages.count) selected voyages")
        isSelectionMode = false
        // Clear selected voyages when exiting selection mode
        selectedVoyages.removeAll()
        
        // Update all cells to deselect them
        for index in 0..<tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? VoyageCardTableViewCell {
                cell.isSelectedForComparison = false
            }
        }
        
        // Ensure navigation bar is reset
        updateNavigationBarItems()
        compareButton.isEnabled = true
        filterButton.isEnabled = true
    }
    
    @objc private func aiTapped() {
        print("🧠 AI button tapped!")
        Task {
            let url = URL(string: Config.apiBaseURL + "/voyages/recommend")!
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = #"{"destination":"Paris","maxBudget":2000,"type":"Aventure"}"#.data(using: .utf8)!
            
            do {
                let (data, _) = try await URLSession.shared.data(for: req)
                print("✅ AI Recommendations: \(String(data: data, encoding: .utf8) ?? "Error")")
            } catch {
                print("❌ AI Error: \(error)")
            }
        }
    }
    
    @objc private func aiRecommendationTapped() {
        let vc = AIRecommendationViewController(initialType: selectedAIType)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    func searchAI(dest: String, budget: Double, type: String) async {
        print("🧠 searchAI called with dest=\(dest), budget=\(budget), type=\(type)")
        
        guard let url = URL(string: Config.apiBaseURL + "/voyages/recommend") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = AuthService.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body: [String: Any] = [
            "destination": dest,
            "maxBudget": budget,
            "type": type
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 401 {
                    let alert = UIAlertController(title: "Non autorisé", message: "Votre session a expiré. Veuillez vous reconnecter.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
                    return
                }
            }
            var recs: [AIRecommendation] = []
            do {
                recs = try JSONDecoder().decode([AIRecommendation].self, from: data)
            } catch {
                let responseString = String(data: data, encoding: .utf8) ?? ""
                if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    recs = json.compactMap { dict in
                        let id = (dict["voyageId"] as? String)
                            ?? (dict["voyage_id"] as? String)
                            ?? (dict["id_voyage"] as? String)
                            ?? (dict["_id"] as? String)
                        let scoreVal: Double = {
                            if let d = dict["score"] as? Double { return d }
                            if let i = dict["score"] as? Int { return Double(i) }
                            if let s = dict["score"] as? String { return Double(s) ?? 0 }
                            return 0
                        }()
                        let reason = (dict["reason"] as? String) ?? ""
                        if let id = id { return AIRecommendation(voyageId: id, score: scoreVal, reason: reason) }
                        return nil
                    }
                } else {
                    print("AI decode failed; raw=\(responseString)")
                }
            }
            DispatchQueue.main.async {
                self.applyAIResults(recs)
            }
        } catch {
            print("AI Error = \(error)")
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Erreur AI", message: "\(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    private func applyAIResults(_ recommendations: [AIRecommendation]) {
        Task {
            let idsOrdered = recommendations.map { $0.voyageId }
            let scoreById = Dictionary(uniqueKeysWithValues: recommendations.map { ($0.voyageId, $0.score) })
            var voyages: [Voyage] = []
            for id in idsOrdered {
                if let local = voyageService.voyages.first(where: { $0._id == id }) {
                    voyages.append(local)
                } else {
                    if let fetched = try? await voyageService.fetchVoyage(id: id) {
                        voyages.append(fetched)
                    }
                }
            }
            let sorted = voyages.sorted { (v1, v2) -> Bool in
                (scoreById[v1._id] ?? 0) > (scoreById[v2._id] ?? 0)
            }
            DispatchQueue.main.async {
                self.filteredVoyages = sorted
                self.isShowingAIResults = true
                self.tableView.reloadData()
                self.updateEmptyState()
                let alert = UIAlertController(title: "Recommandations AI", message: "\(sorted.count) résultat(s)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}

extension VoyageListViewController: AIRecommendationViewControllerDelegate {
    func didSubmitAI(dest: String, budget: Double, type: String) {
        selectedAIType = type
        Task {
            await searchAI(dest: dest, budget: budget, type: type)
        }
    }
}

// MARK: - Filter Delegate
extension VoyageListViewController: FilterViewControllerDelegate {
    func didApplyFilters(sortOption: SortOption, typeFilter: String?, minPrice: Double?, maxPrice: Double?) {
        print("🔍 Filters applied:")
        print("   Sort: \(sortOption.rawValue)")
        print("   Type: \(typeFilter ?? "none")")
        print("   Min Price: \(minPrice ?? 0)")
        print("   Max Price: \(maxPrice ?? 0)")
        
        self.currentSortOption = sortOption
        self.currentTypeFilter = typeFilter
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        
        updateFilterButtonAppearance()
        
        if isSearching {
            filterVoyages(for: searchController.searchBar.text ?? "")
        } else {
            applyFiltersAndSort()
        }
        
        print("   Result count: \(filteredVoyages.count)")
    }
}

// MARK: - UITableViewDataSource
extension VoyageListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredVoyages.count
        } else {
            if isShowingAIResults {
                return filteredVoyages.count
            }
            if currentTypeFilter != nil || minPrice != nil || maxPrice != nil || currentSortOption != .dateAscending {
                return filteredVoyages.count
            }
            return voyageService.voyages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoyageCell", for: indexPath) as! VoyageCardTableViewCell
        
        let voyage: Voyage
        if isSearching {
            voyage = filteredVoyages[indexPath.row]
        } else {
            if isShowingAIResults {
                voyage = filteredVoyages[indexPath.row]
            } else if currentTypeFilter != nil || minPrice != nil || maxPrice != nil || currentSortOption != .dateAscending {
                voyage = filteredVoyages[indexPath.row]
            } else {
                voyage = voyageService.voyages[indexPath.row]
            }
        }
        
        cell.configure(with: voyage)
        cell.isSelectionModeEnabled = isSelectionMode
        return cell
    }
}

// MARK: - UITableViewDelegate
extension VoyageListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let voyage: Voyage
        if isSearching {
            voyage = filteredVoyages[indexPath.row]
        } else {
            if isShowingAIResults {
                voyage = filteredVoyages[indexPath.row]
            } else if currentTypeFilter != nil || minPrice != nil || maxPrice != nil || currentSortOption != .dateAscending {
                voyage = filteredVoyages[indexPath.row]
            } else {
                voyage = voyageService.voyages[indexPath.row]
            }
        }
        
        let detailVC = VoyageDetailViewController(voyage: voyage)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

// MARK: - UISearchResultsUpdating
extension VoyageListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterVoyages(for: searchBar.text ?? "")
    }
}

// MARK: - VoyageCardTableViewCell
class VoyageCardTableViewCell: UITableViewCell {
    // Main ticket card
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
    
    // Left side - Image and destination
    private let leftSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let voyageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 0.1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let destinationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 0.15)
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Center section - Flight details
    private let centerSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let departSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let departTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "DÉPART"
        label.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let departDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let departTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.right"))
        imageView.tintColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let returnSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let returnTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "RETOUR"
        label.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let returnDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let returnTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Right section - Price and places
    private let rightSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let placesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Selection mode elements
    private let selectionOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemOrange.cgColor
        button.layer.cornerRadius = 12
        button.backgroundColor = UIColor.white
        return button
    }()
    
    // Properties for selection state
    var isSelectedForComparison = false {
        didSet {
            updateSelectionUI()
        }
    }
    
    var isSelectionModeEnabled = false {
        didSet {
            selectionOverlay.isHidden = !isSelectionModeEnabled
            checkboxButton.isHidden = !isSelectionModeEnabled
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        voyageImageView.image = nil
        isSelectedForComparison = false
        isSelectionModeEnabled = false
    }
    
    private func setupUI() {
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(selectionOverlay)
        
        // Add checkbox button
        contentView.addSubview(checkboxButton)
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        
        // Left section
        cardView.addSubview(leftSection)
        leftSection.addSubview(voyageImageView)
        leftSection.addSubview(destinationLabel)
        leftSection.addSubview(typeBadge)
        typeBadge.addSubview(typeLabel)
        
        // Center section
        cardView.addSubview(centerSection)
        centerSection.addSubview(departSection)
        centerSection.addSubview(arrowIcon)
        centerSection.addSubview(returnSection)
        
        departSection.addSubview(departTitleLabel)
        departSection.addSubview(departDateLabel)
        departSection.addSubview(departTimeLabel)
        
        returnSection.addSubview(returnTitleLabel)
        returnSection.addSubview(returnDateLabel)
        returnSection.addSubview(returnTimeLabel)
        
        // Right section
        cardView.addSubview(rightSection)
        rightSection.addSubview(priceLabel)
        rightSection.addSubview(placesLabel)
        rightSection.addSubview(chevronIcon)
        
        NSLayoutConstraint.activate([
            // Card view
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Selection overlay
            selectionOverlay.topAnchor.constraint(equalTo: cardView.topAnchor),
            selectionOverlay.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            selectionOverlay.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            selectionOverlay.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            
            // Checkbox button
            checkboxButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            checkboxButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Left section
            leftSection.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            leftSection.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            leftSection.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            leftSection.widthAnchor.constraint(equalToConstant: 100),
            
            voyageImageView.topAnchor.constraint(equalTo: leftSection.topAnchor),
            voyageImageView.leadingAnchor.constraint(equalTo: leftSection.leadingAnchor),
            voyageImageView.trailingAnchor.constraint(equalTo: leftSection.trailingAnchor),
            voyageImageView.heightAnchor.constraint(equalToConstant: 70),
            
            destinationLabel.topAnchor.constraint(equalTo: voyageImageView.bottomAnchor, constant: 8),
            destinationLabel.leadingAnchor.constraint(equalTo: leftSection.leadingAnchor),
            destinationLabel.trailingAnchor.constraint(equalTo: leftSection.trailingAnchor),
            
            typeBadge.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 6),
            typeBadge.leadingAnchor.constraint(equalTo: leftSection.leadingAnchor),
            typeBadge.heightAnchor.constraint(equalToConstant: 20),
            typeBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            typeLabel.topAnchor.constraint(equalTo: typeBadge.topAnchor, constant: 4),
            typeLabel.leadingAnchor.constraint(equalTo: typeBadge.leadingAnchor, constant: 8),
            typeLabel.trailingAnchor.constraint(equalTo: typeBadge.trailingAnchor, constant: -8),
            typeLabel.bottomAnchor.constraint(equalTo: typeBadge.bottomAnchor, constant: -4),
            
            // Center section
            centerSection.leadingAnchor.constraint(equalTo: leftSection.trailingAnchor, constant: 16),
            centerSection.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            centerSection.widthAnchor.constraint(equalToConstant: 140),
            
            // Depart section
            departSection.leadingAnchor.constraint(equalTo: centerSection.leadingAnchor),
            departSection.topAnchor.constraint(equalTo: centerSection.topAnchor),
            departSection.trailingAnchor.constraint(equalTo: centerSection.trailingAnchor),
            
            departTitleLabel.topAnchor.constraint(equalTo: departSection.topAnchor),
            departTitleLabel.leadingAnchor.constraint(equalTo: departSection.leadingAnchor),
            
            departDateLabel.topAnchor.constraint(equalTo: departTitleLabel.bottomAnchor, constant: 4),
            departDateLabel.leadingAnchor.constraint(equalTo: departSection.leadingAnchor),
            departDateLabel.trailingAnchor.constraint(equalTo: departSection.trailingAnchor),
            
            departTimeLabel.topAnchor.constraint(equalTo: departDateLabel.bottomAnchor, constant: 2),
            departTimeLabel.leadingAnchor.constraint(equalTo: departSection.leadingAnchor),
            departTimeLabel.bottomAnchor.constraint(equalTo: departSection.bottomAnchor),
            
            // Arrow
            arrowIcon.centerXAnchor.constraint(equalTo: centerSection.centerXAnchor),
            arrowIcon.centerYAnchor.constraint(equalTo: centerSection.centerYAnchor),
            arrowIcon.widthAnchor.constraint(equalToConstant: 20),
            arrowIcon.heightAnchor.constraint(equalToConstant: 20),
            
            // Return section
            returnSection.leadingAnchor.constraint(equalTo: centerSection.leadingAnchor),
            returnSection.topAnchor.constraint(equalTo: departSection.bottomAnchor, constant: 20),
            returnSection.trailingAnchor.constraint(equalTo: centerSection.trailingAnchor),
            returnSection.bottomAnchor.constraint(equalTo: centerSection.bottomAnchor),
            
            returnTitleLabel.topAnchor.constraint(equalTo: returnSection.topAnchor),
            returnTitleLabel.leadingAnchor.constraint(equalTo: returnSection.leadingAnchor),
            
            returnDateLabel.topAnchor.constraint(equalTo: returnTitleLabel.bottomAnchor, constant: 4),
            returnDateLabel.leadingAnchor.constraint(equalTo: returnSection.leadingAnchor),
            returnDateLabel.trailingAnchor.constraint(equalTo: returnSection.trailingAnchor),
            
            returnTimeLabel.topAnchor.constraint(equalTo: returnDateLabel.bottomAnchor, constant: 2),
            returnTimeLabel.leadingAnchor.constraint(equalTo: returnSection.leadingAnchor),
            returnTimeLabel.bottomAnchor.constraint(equalTo: returnSection.bottomAnchor),
            
            // Right section
            rightSection.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            rightSection.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            rightSection.widthAnchor.constraint(equalToConstant: 100),
            
            priceLabel.topAnchor.constraint(equalTo: rightSection.topAnchor),
            priceLabel.leadingAnchor.constraint(equalTo: rightSection.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: rightSection.trailingAnchor),
            
            placesLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            placesLabel.leadingAnchor.constraint(equalTo: rightSection.leadingAnchor),
            placesLabel.trailingAnchor.constraint(equalTo: rightSection.trailingAnchor),
            
            chevronIcon.topAnchor.constraint(equalTo: placesLabel.bottomAnchor, constant: 12),
            chevronIcon.centerXAnchor.constraint(equalTo: rightSection.centerXAnchor),
            chevronIcon.bottomAnchor.constraint(lessThanOrEqualTo: rightSection.bottomAnchor),
            chevronIcon.widthAnchor.constraint(equalToConstant: 16),
            chevronIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with voyage: Voyage) {
        // Destination and type
        destinationLabel.text = voyage.destination
        typeLabel.text = voyage.typeDisplayName().uppercased()
        
        // Load image
        if let imageUrl = voyage.imageUrl, let url = URL(string: imageUrl) {
            loadImage(from: url)
        } else {
            voyageImageView.image = UIImage(systemName: voyage.typeIcon())
            voyageImageView.tintColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
            voyageImageView.contentMode = .scaleAspectFit
        }
        
        // Parse and format dates
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        dateFormatter.locale = Locale(identifier: "fr_FR")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        if let departDate = formatter.date(from: voyage.date_depart) {
            departDateLabel.text = dateFormatter.string(from: departDate).uppercased()
            departTimeLabel.text = timeFormatter.string(from: departDate)
        } else {
            departDateLabel.text = "N/A"
            departTimeLabel.text = "N/A"
        }
        
        if let returnDate = formatter.date(from: voyage.date_retour) {
            returnDateLabel.text = dateFormatter.string(from: returnDate).uppercased()
            returnTimeLabel.text = timeFormatter.string(from: returnDate)
        } else {
            returnDateLabel.text = "N/A"
            returnTimeLabel.text = "N/A"
        }
        
        // Price and places
        if let price = voyage.formattedPrice() {
            priceLabel.text = price
            priceLabel.isHidden = false
        } else {
            priceLabel.text = "Sur demande"
            priceLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
        
        placesLabel.text = voyage.placesInfo()
        
        // Update selection UI
        updateSelectionUI()
    }
    
    private func updateSelectionUI() {
        if isSelectedForComparison {
            checkboxButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            checkboxButton.tintColor = .systemOrange
            checkboxButton.backgroundColor = .systemOrange
        } else {
            checkboxButton.setImage(nil, for: .normal)
            checkboxButton.tintColor = .systemOrange
            checkboxButton.backgroundColor = .white
        }
    }
    
    @objc private func checkboxTapped() {
        isSelectedForComparison.toggle()
        // Notify the view controller about the selection change
        NotificationCenter.default.post(name: NSNotification.Name("VoyageSelectionChanged"), object: nil)
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.voyageImageView.image = UIImage(systemName: "airplane")
                    self?.voyageImageView.tintColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
                    self?.voyageImageView.contentMode = .scaleAspectFit
                }
                return
            }
            DispatchQueue.main.async {
                self?.voyageImageView.image = image
                self?.voyageImageView.contentMode = .scaleAspectFill
                self?.voyageImageView.tintColor = nil
            }
        }.resume()
    }
    
    @objc private func aiTapped() {
        Task {
            print("🧠 AI clicked!")
            let url = URL(string: Config.apiBaseURL + "/voyages/recommend")!
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = #"{"destination":"Paris","maxBudget":2000,"type":"Aventure"}"#.data(using: .utf8)!
            
            do {
                let (data, _) = try await URLSession.shared.data(for: req)
                print("✅ AI Recommendations: \(String(data: data, encoding: .utf8) ?? "Error")")
            } catch {
                print("❌ AI Error: \(error)")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
