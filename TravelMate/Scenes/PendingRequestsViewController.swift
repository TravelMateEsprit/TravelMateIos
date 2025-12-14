import UIKit

class PendingRequestsViewController: UIViewController {
    private let groupId: String
    private let groupService = GroupService.shared
    private var pendingRequests: [GroupMember] = []
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PendingRequestCell.self, forCellReuseIdentifier: "PendingRequestCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Aucune demande en attente"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Initialization
    init(groupId: String) {
        self.groupId = groupId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadPendingRequests()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Demandes en attente"
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Data Loading
    private func loadPendingRequests() {
        Task {
            do {
                pendingRequests = try await groupService.getPendingRequests(groupId: groupId)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.emptyStateLabel.isHidden = !self.pendingRequests.isEmpty
                }
            } catch {
                print("Error loading pending requests: \(error)")
                DispatchQueue.main.async {
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Actions
    private func approveRequest(userId: String) {
        Task {
            do {
                try await groupService.approveMemberRequest(groupId: groupId, userId: userId)
                loadPendingRequests()
                showSuccessAlert(message: "Membre approuvé !")
            } catch {
                showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func rejectRequest(userId: String) {
        Task {
            do {
                try await groupService.rejectMemberRequest(groupId: groupId, userId: userId)
                loadPendingRequests()
                showSuccessAlert(message: "Demande refusée")
            } catch {
                showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Helpers
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Succès", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension PendingRequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingRequestCell", for: indexPath) as! PendingRequestCell
        let request = pendingRequests[indexPath.row]
        cell.configure(with: request, delegate: self)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PendingRequestsViewController: UITableViewDelegate {
    // Optional: Handle selection if needed
}

// MARK: - PendingRequestCellDelegate
extension PendingRequestsViewController: PendingRequestCellDelegate {
    func didTapApprove(userId: String) {
        approveRequest(userId: userId)
    }
    
    func didTapReject(userId: String) {
        rejectRequest(userId: userId)
    }
}
