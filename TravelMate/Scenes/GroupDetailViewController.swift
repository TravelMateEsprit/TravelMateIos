import UIKit

class GroupDetailViewController: UIViewController {
    private let group: Group
    private let groupService = GroupService.shared
    private var currentGroup: Group
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Header card
    private let headerCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let groupImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let destinationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Description card
    private let descriptionCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "DESCRIPTION"
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Members card
    private let membersCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let membersTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let membersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Creator card
    private let creatorCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let creatorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "CRÉATEUR"
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let creatorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Action buttons
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initialization
    init(group: Group) {
        self.group = group
        self.currentGroup = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        Task {
            await refreshGroup()
        }
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Détails du groupe"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerCard)
        headerCard.addSubview(groupImageView)
        headerCard.addSubview(nameLabel)
        headerCard.addSubview(destinationLabel)
        
        contentView.addSubview(descriptionCard)
        descriptionCard.addSubview(descriptionTitleLabel)
        descriptionCard.addSubview(descriptionLabel)
        
        contentView.addSubview(membersCard)
        membersCard.addSubview(membersTitleLabel)
        membersCard.addSubview(membersStackView)
        
        contentView.addSubview(creatorCard)
        creatorCard.addSubview(creatorTitleLabel)
        creatorCard.addSubview(creatorLabel)
        
        contentView.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header card
            headerCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            groupImageView.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 16),
            groupImageView.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            groupImageView.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            groupImageView.heightAnchor.constraint(equalToConstant: 180),
            
            nameLabel.topAnchor.constraint(equalTo: groupImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            
            destinationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            destinationLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            destinationLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            destinationLabel.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -16),
            
            // Description card
            descriptionCard.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 16),
            descriptionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: descriptionCard.topAnchor, constant: 16),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: descriptionCard.leadingAnchor, constant: 16),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: descriptionCard.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionCard.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionCard.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionCard.bottomAnchor, constant: -16),
            
            // Members card
            membersCard.topAnchor.constraint(equalTo: descriptionCard.bottomAnchor, constant: 16),
            membersCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            membersCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            membersTitleLabel.topAnchor.constraint(equalTo: membersCard.topAnchor, constant: 16),
            membersTitleLabel.leadingAnchor.constraint(equalTo: membersCard.leadingAnchor, constant: 16),
            membersTitleLabel.trailingAnchor.constraint(equalTo: membersCard.trailingAnchor, constant: -16),
            
            membersStackView.topAnchor.constraint(equalTo: membersTitleLabel.bottomAnchor, constant: 16),
            membersStackView.leadingAnchor.constraint(equalTo: membersCard.leadingAnchor, constant: 16),
            membersStackView.trailingAnchor.constraint(equalTo: membersCard.trailingAnchor, constant: -16),
            membersStackView.bottomAnchor.constraint(equalTo: membersCard.bottomAnchor, constant: -16),
            
            // Creator card
            creatorCard.topAnchor.constraint(equalTo: membersCard.bottomAnchor, constant: 16),
            creatorCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            creatorCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            creatorTitleLabel.topAnchor.constraint(equalTo: creatorCard.topAnchor, constant: 16),
            creatorTitleLabel.leadingAnchor.constraint(equalTo: creatorCard.leadingAnchor, constant: 16),
            creatorTitleLabel.trailingAnchor.constraint(equalTo: creatorCard.trailingAnchor, constant: -16),
            
            creatorLabel.topAnchor.constraint(equalTo: creatorTitleLabel.bottomAnchor, constant: 12),
            creatorLabel.leadingAnchor.constraint(equalTo: creatorCard.leadingAnchor, constant: 16),
            creatorLabel.trailingAnchor.constraint(equalTo: creatorCard.trailingAnchor, constant: -16),
            creatorLabel.bottomAnchor.constraint(equalTo: creatorCard.bottomAnchor, constant: -16),
            
            // Buttons
            buttonsStackView.topAnchor.constraint(equalTo: creatorCard.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func configureUI() {
        nameLabel.text = currentGroup.nom
        destinationLabel.text = "📍 \(currentGroup.destination)"
        descriptionLabel.text = currentGroup.description ?? "Aucune description disponible"
        
        // Load image
        if let photoUrl = currentGroup.photoUrl, let url = URL(string: photoUrl) {
            loadImage(from: url)
        } else {
            groupImageView.image = UIImage(systemName: "person.3.fill")
            groupImageView.tintColor = .systemBlue
            groupImageView.contentMode = .scaleAspectFit
        }
        
        // Members
        membersTitleLabel.text = "MEMBRES (\(currentGroup.membres.count))"
        membersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if currentGroup.membres.isEmpty {
            let label = UILabel()
            label.text = "Aucun membre pour le moment"
            label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            label.textColor = .systemGray
            membersStackView.addArrangedSubview(label)
        } else {
            for member in currentGroup.membres {
                let memberView = createMemberView(name: member.name, email: member.email)
                membersStackView.addArrangedSubview(memberView)
            }
        }
        
        // Creator
        creatorLabel.text = "\(currentGroup.createur_id.name)\n\(currentGroup.createur_id.email)"
        
        // Buttons
        setupConditionalButtons()
    }
    
    private func createMemberView(name: String, email: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let emailLabel = UILabel()
        emailLabel.text = email
        emailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        emailLabel.textColor = .systemGray
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconView)
        container.addSubview(nameLabel)
        container.addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            
            emailLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            emailLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupConditionalButtons() {
        buttonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let currentUserId = groupService.currentUserId else { return }
        
        let isCreator = currentGroup.isCreator(userId: currentUserId)
        let isMember = currentGroup.isMember(userId: currentUserId)
        
        if isCreator {
            let modifyButton = createButton(title: "Modifier", color: .systemBlue, action: #selector(modifyButtonTapped))
            let deleteButton = createButton(title: "Supprimer", color: .systemRed, action: #selector(deleteButtonTapped))
            
            buttonsStackView.addArrangedSubview(modifyButton)
            buttonsStackView.addArrangedSubview(deleteButton)
        } else {
            if isMember {
                let leaveButton = createButton(title: "Quitter le groupe", color: .systemRed, action: #selector(leaveButtonTapped), style: .outline)
                buttonsStackView.addArrangedSubview(leaveButton)
            } else {
                let joinButton = createButton(title: "Rejoindre", color: .systemGreen, action: #selector(joinButtonTapped))
                buttonsStackView.addArrangedSubview(joinButton)
            }
        }
    }
    
    private func createButton(title: String, color: UIColor, action: Selector?, style: ButtonStyle = .filled) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        
        if style == .filled {
            button.backgroundColor = color
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(color, for: .normal)
            button.layer.borderWidth = 2
            button.layer.borderColor = color.cgColor
        }
        
        if let action = action {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        return button
    }
    
    enum ButtonStyle {
        case filled
        case outline
    }
    
    // MARK: - Actions
        @objc private func modifyButtonTapped() {
            let editVC = EditGroupViewController(group: currentGroup)
            let navController = UINavigationController(rootViewController: editVC)
            navController.modalPresentationStyle = .pageSheet
            present(navController, animated: true)
        }
        
        @objc private func deleteButtonTapped() {
            let alert = UIAlertController(
                title: "Supprimer le groupe",
                message: "Êtes-vous sûr de vouloir supprimer ce groupe ? Cette action est irréversible.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
            alert.addAction(UIAlertAction(title: "Supprimer", style: .destructive) { [weak self] _ in
                self?.performDelete()
            })
            
            present(alert, animated: true)
        }
        
        private func performDelete() {
            Task {
                do {
                    try await groupService.deleteGroup(id: currentGroup.id)
                    await groupService.fetchGroups()
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: error.localizedDescription)
                    }
                }
            }
        }
        
        @objc private func joinButtonTapped() {
            Task {
                do {
                    let updatedGroup = try await groupService.joinGroup(id: currentGroup.id)
                    currentGroup = updatedGroup
                    DispatchQueue.main.async {
                        self.configureUI()
                        self.showSuccessAlert(message: "Vous avez rejoint le groupe avec succès !")
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: error.localizedDescription)
                    }
                }
            }
        }
        
        @objc private func leaveButtonTapped() {
            let alert = UIAlertController(
                title: "Quitter le groupe",
                message: "Êtes-vous sûr de vouloir quitter ce groupe ?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
            alert.addAction(UIAlertAction(title: "Quitter", style: .destructive) { [weak self] _ in
                self?.performLeave()
            })
            
            present(alert, animated: true)
        }
        
        private func performLeave() {
            Task {
                do {
                    let updatedGroup = try await groupService.leaveGroup(id: currentGroup.id)
                    currentGroup = updatedGroup
                    DispatchQueue.main.async {
                        self.configureUI()
                        self.showSuccessAlert(message: "Vous avez quitté le groupe.")
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: error.localizedDescription)
                    }
                }
            }
        }
        
        // MARK: - Helpers
        private func refreshGroup() async {
            do {
                let group = try await groupService.fetchGroup(id: currentGroup.id)
                currentGroup = group
                DispatchQueue.main.async {
                    self.configureUI()
                }
            } catch {
                print("Error refreshing group: \(error)")
            }
        }
        
        private func loadImage(from url: URL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        self?.groupImageView.image = UIImage(systemName: "person.3.fill")
                        self?.groupImageView.tintColor = .systemBlue
                        self?.groupImageView.contentMode = .scaleAspectFit
                    }
                    return
                }
                DispatchQueue.main.async {
                    self?.groupImageView.image = image
                    self?.groupImageView.contentMode = .scaleAspectFill
                    self?.groupImageView.tintColor = nil
                }
            }.resume()
        }
        
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
