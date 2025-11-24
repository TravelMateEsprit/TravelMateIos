import UIKit

class GroupsViewController: UIViewController {
    private let groupService = GroupService.shared
   
    // MARK: - Sort Options
    enum SortOption: String {
        case mostRecent = "Plus récents"
        case oldest = "Plus anciens"
        case nameAZ = "Nom (A-Z)"
        case nameZA = "Nom (Z-A)"
        case mostMembers = "Plus de membres"
        case leastMembers = "Moins de membres"
    }
   
    // MARK: - Properties
    private var currentSortOption: SortOption = .mostRecent
    private var filteredGroups: [Group] = []
    private var isSearching: Bool = false
   
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GroupCardTableViewCell.self, forCellReuseIdentifier: "GroupCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        tableView.refreshControl = refreshControl
        return tableView
    }()
   
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshGroups), for: .valueChanged)
        return control
    }()
   
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Rechercher un groupe..."
        return controller
    }()
   
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
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
       
        let imageView = UIImageView(image: UIImage(systemName: "person.3"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
       
        let label = UILabel()
        label.text = "Aucun groupe disponible"
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
   
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadGroups()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setupNavigationBar()
       
        if !groupService.isLoading {
            Task {
                await groupService.fetchGroups()
                updateUI()
            }
        }
    }
   
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Groupes de voyage"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
       
        // Sort button
        let sortButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
        sortButton.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = sortButton
       
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
       
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
   
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
       
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateView)
        view.addSubview(createButton)
       
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
   
    // MARK: - Data Loading
    private func loadGroups() {
        Task {
            await groupService.fetchGroups()
            updateUI()
        }
    }
   
    @objc private func refreshGroups() {
        Task {
            await groupService.fetchGroups()
            updateUI()
            refreshControl.endRefreshing()
        }
    }
   
    // MARK: - Actions
    @objc private func createButtonTapped() {
        let createVC = CreateGroupViewController()
        let navController = UINavigationController(rootViewController: createVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
   
    @objc private func sortButtonTapped() {
        showSortOptions()
    }
   
    // MARK: - Sorting
    private func showSortOptions() {
        let alert = UIAlertController(title: "Trier par", message: nil, preferredStyle: .actionSheet)
       
        let options: [SortOption] = [.mostRecent, .oldest, .nameAZ, .nameZA, .mostMembers, .leastMembers]
       
        for option in options {
            let action = UIAlertAction(title: option.rawValue, style: .default) { [weak self] _ in
                self?.currentSortOption = option
                self?.applySorting()
            }
            if option == currentSortOption {
                action.setValue(UIImage(systemName: "checkmark"), forKey: "image")
            }
            alert.addAction(action)
        }
       
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
       
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
       
        present(alert, animated: true)
    }
   
    private func applySorting() {
        let groups = isSearching ? filteredGroups : groupService.groups
       
        let sorted: [Group]
        switch currentSortOption {
        case .mostRecent:
            sorted = groups.sorted { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
        case .oldest:
            sorted = groups.sorted { ($0.createdAt ?? "") < ($1.createdAt ?? "") }
        case .nameAZ:
            sorted = groups.sorted { $0.nom < $1.nom }
        case .nameZA:
            sorted = groups.sorted { $0.nom > $1.nom }
        case .mostMembers:
            sorted = groups.sorted { $0.membres.count > $1.membres.count }
        case .leastMembers:
            sorted = groups.sorted { $0.membres.count < $1.membres.count }
        }
       
        if isSearching {
            filteredGroups = sorted
        } else {
            groupService.groups = sorted
        }
       
        tableView.reloadData()
    }
   
    // MARK: - Search
    private func filterGroups(for searchText: String) {
        filteredGroups = groupService.groups.filter { group in
            return group.nom.lowercased().contains(searchText.lowercased()) ||
                   group.destination.lowercased().contains(searchText.lowercased())
        }
        applySorting()
    }
   
    // MARK: - UI Updates
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
           
            if self.groupService.isLoading {
                self.loadingIndicator.startAnimating()
                self.tableView.isHidden = true
            } else {
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = false
               
                let groups = self.isSearching ? self.filteredGroups : self.groupService.groups
                self.emptyStateView.isHidden = !groups.isEmpty
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension GroupsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let groups = isSearching ? filteredGroups : groupService.groups
        return groups.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCardTableViewCell
        let groups = isSearching ? filteredGroups : groupService.groups
        cell.configure(with: groups[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension GroupsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let groups = isSearching ? filteredGroups : groupService.groups
        let group = groups[indexPath.row]
       
        let detailVC = GroupDetailViewController(group: group)
        navigationController?.pushViewController(detailVC, animated: true)
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}

// MARK: - UISearchResultsUpdating
extension GroupsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        isSearching = !searchText.isEmpty
       
        if isSearching {
            filterGroups(for: searchText)
        } else {
            applySorting()
        }
    }
}
