import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    private var favorites: [Offer] = []
    private var filteredFavorites: [Offer] = []
    private var isSearching = false
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Rechercher un pack..."
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(PackCell.self, forCellReuseIdentifier: PackCell.identifier)
        tv.separatorStyle = .none
        tv.backgroundColor = .backgroundLight
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Aucun favori\n\nAjoutez des packs à vos favoris pour les retrouver ici"
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
        title = "Mes Favoris"
        view.backgroundColor = .backgroundLight
        
        setupUI()
        setupToolbar()
        loadFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    private func setupUI() {
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
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
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupToolbar() {
        // Filter and Sort buttons
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )
        filterButton.tintColor = .primaryColor
        
        let sortButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down.circle"),
            style: .plain,
            target: self,
            action: #selector(sortTapped)
        )
        sortButton.tintColor = .primaryColor
        
        navigationItem.rightBarButtonItems = [sortButton, filterButton]
    }
    
    private func loadFavorites() {
        // Using local storage (FavoritesService will be enabled after adding to Xcode project)
        favorites = FavoritesManager.shared.getFavorites()
        filteredFavorites = favorites
        emptyStateLabel.isHidden = !favorites.isEmpty
        tableView.reloadData()
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredFavorites.count : favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PackCell.identifier,
            for: indexPath
        ) as? PackCell else {
            return UITableViewCell()
        }
        
        let pack = isSearching ? filteredFavorites[indexPath.row] : favorites[indexPath.row]
        cell.configure(with: pack)
        
        // Hide chat button in favorites
        cell.onChatTapped = nil
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pack = isSearching ? filteredFavorites[indexPath.row] : favorites[indexPath.row]
        let detailVC = PackDetailViewController(offer: pack)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let pack = isSearching ? filteredFavorites[indexPath.row] : favorites[indexPath.row]
            if let id = pack.id {
                // Remove from local storage (backend sync will be enabled after adding FavoritesService to Xcode)
                FavoritesManager.shared.removeFavorite(id: id)
                loadFavorites()
            }
        }
    }
    
    // MARK: - Search Bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredFavorites = favorites
        } else {
            isSearching = true
            filteredFavorites = favorites.filter { pack in
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
        filteredFavorites = favorites
        tableView.reloadData()
    }
    
    // MARK: - Filter & Sort
    
    @objc private func filterTapped() {
        let alert = UIAlertController(title: "Filtrer par", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Prix croissant", style: .default) { _ in
            self.applyFilter(type: .priceLow)
        })
        alert.addAction(UIAlertAction(title: "Prix décroissant", style: .default) { _ in
            self.applyFilter(type: .priceHigh)
        })
        alert.addAction(UIAlertAction(title: "Destination", style: .default) { _ in
            self.applyFilter(type: .destination)
        })
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func sortTapped() {
        let alert = UIAlertController(title: "Trier par", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Prix: bas → haut", style: .default) { _ in
            self.favorites.sort { $0.prix < $1.prix }
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Prix: haut → bas", style: .default) { _ in
            self.favorites.sort { $0.prix > $1.prix }
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Alphabétique", style: .default) { _ in
            self.favorites.sort { $0.titre < $1.titre }
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        
        present(alert, animated: true)
    }
    
    enum FilterType {
        case priceLow, priceHigh, destination
    }
    
    private func applyFilter(type: FilterType) {
        switch type {
        case .priceLow:
            favorites.sort { $0.prix < $1.prix }
        case .priceHigh:
            favorites.sort { $0.prix > $1.prix }
        case .destination:
            favorites.sort { ($0.destination ?? "") < ($1.destination ?? "") }
        }
        tableView.reloadData()
    }
}
