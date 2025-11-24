import UIKit

class GroupCardTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
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
    
    private let groupImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let destinationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let membersIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.2.fill"))
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let membersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
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
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Modifier", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // Caché par défaut, visible seulement si l'utilisateur est créateur
        return button
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        groupImageView.image = nil
        nameLabel.text = nil
        destinationLabel.text = nil
        membersLabel.text = nil
        actionButton.isHidden = true
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(groupImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(destinationLabel)
        cardView.addSubview(membersIcon)
        cardView.addSubview(membersLabel)
        cardView.addSubview(chevronIcon)
        cardView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            // Card view
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Group image
            groupImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            groupImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            groupImageView.widthAnchor.constraint(equalToConstant: 100),
            groupImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Name label
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: chevronIcon.leadingAnchor, constant: -8),
            
            // Destination label
            destinationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            destinationLabel.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 12),
            destinationLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // Members icon
            membersIcon.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 12),
            membersIcon.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 12),
            membersIcon.widthAnchor.constraint(equalToConstant: 16),
            membersIcon.heightAnchor.constraint(equalToConstant: 16),
            
            // Members label
            membersLabel.centerYAnchor.constraint(equalTo: membersIcon.centerYAnchor),
            membersLabel.leadingAnchor.constraint(equalTo: membersIcon.trailingAnchor, constant: 6),
            
            // Action button
            actionButton.topAnchor.constraint(equalTo: membersLabel.bottomAnchor, constant: 8),
            actionButton.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 12),
            actionButton.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16),
            
            // Chevron icon
            chevronIcon.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronIcon.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chevronIcon.widthAnchor.constraint(equalToConstant: 16),
            chevronIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    // MARK: - Configuration
    func configure(with group: Group) {
        nameLabel.text = group.nom
        destinationLabel.text = "📍 \(group.destination)"
        membersLabel.text = group.memberCount()
        
        // Load image
        if let photoUrl = group.photoUrl, let url = URL(string: photoUrl) {
            loadImage(from: url)
        } else {
            // Default icon for group
            groupImageView.image = UIImage(systemName: "person.3.fill")
            groupImageView.tintColor = .systemBlue
            groupImageView.contentMode = .scaleAspectFit
        }
        
        // Show action button only if user is creator
        if let userId = AuthService.shared.currentUser?.id {
            actionButton.isHidden = !group.isCreator(userId: userId)
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
}
