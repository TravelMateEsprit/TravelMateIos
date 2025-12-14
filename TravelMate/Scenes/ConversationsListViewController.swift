import UIKit

class ConversationsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    private var conversations: [Conversation] = []
    private var filteredConversations: [Conversation] = []
    private var isSearching = false
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Rechercher une conversation..."
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
        label.text = "Aucune conversation\n\nVos conversations apparaîtront ici"
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
        title = "Messages"
        view.backgroundColor = .white
        
        setupUI()
        setupToolbar()
        fetchConversations()
        setupWebSocketListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchConversations()
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
        let refreshButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshData)
        )
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    @objc private func refreshData() {
        fetchConversations()
    }
    
    private func fetchConversations() {
        loadingIndicator.startAnimating()
        emptyStateLabel.isHidden = true
        
        Task {
            do {
                let result = try await ChatService.shared.getConversations()
                self.conversations = result
                self.filteredConversations = result
                
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.emptyStateLabel.isHidden = !self.conversations.isEmpty
                    self.tableView.reloadData()
                }
            } catch {
                print("❌ Failed to fetch conversations: \(error)")
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.emptyStateLabel.isHidden = false
                }
            }
        }
    }
    
    private func setupWebSocketListeners() {
        // Listen for new messages
        WebSocketService.shared.onMessageReceived { [weak self] messageData in
            // Reload conversations when new message received
            DispatchQueue.main.async {
                self?.fetchConversations()
            }
        }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredConversations.count : conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let conversation = isSearching ? filteredConversations[indexPath.row] : conversations[indexPath.row]
        
        // Configure cell
        var config = cell.defaultContentConfiguration()
        config.text = conversation.displayName
        config.secondaryText = conversation.subtitle
        
        // Add time label
        config.secondaryTextProperties.color = .systemGray
        config.secondaryTextProperties.font = .systemFont(ofSize: 14)
        
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        
        // Unread badge
        if conversation.hasUnread {
            let badge = UIView()
            badge.backgroundColor = .systemBlue
            badge.layer.cornerRadius = 8
            badge.translatesAutoresizingMaskIntoConstraints = false
            
            let countLabel = UILabel()
            countLabel.text = "\(conversation.unreadCount ?? 0)"
            countLabel.textColor = .white
            countLabel.font = .systemFont(ofSize: 12, weight: .bold)
            countLabel.textAlignment = .center
            countLabel.translatesAutoresizingMaskIntoConstraints = false
            
            badge.addSubview(countLabel)
            cell.contentView.addSubview(badge)
            
            NSLayoutConstraint.activate([
                badge.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -40),
                badge.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                badge.widthAnchor.constraint(equalToConstant: 24),
                badge.heightAnchor.constraint(equalToConstant: 24),
                
                countLabel.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
                countLabel.centerYAnchor.constraint(equalTo: badge.centerYAnchor)
            ])
        }
        
        // Time label
        let timeLabel = UILabel()
        timeLabel.text = conversation.formattedLastMessageTime
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .systemGray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(timeLabel)
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            timeLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 12)
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = isSearching ? filteredConversations[indexPath.row] : conversations[indexPath.row]
        openChat(conversation)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - Search
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredConversations = conversations
        } else {
            isSearching = true
            filteredConversations = conversations.filter { conversation in
                conversation.displayName.lowercased().contains(searchText.lowercased()) ||
                (conversation.lastMessage?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        filteredConversations = conversations
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    private func openChat(_ conversation: Conversation) {
        // If we have the pack, use existing ChatViewController
        if let pack = conversation.pack {
            let chatVC = ChatViewController(offer: pack)
            navigationController?.pushViewController(chatVC, animated: true)
        } else {
            // Show generic message view
            let alert = UIAlertController(
                title: "Chat",
                message: "Opening chat...",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
