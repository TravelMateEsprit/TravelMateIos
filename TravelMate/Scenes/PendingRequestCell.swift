import UIKit

protocol PendingRequestCellDelegate: AnyObject {
    func didTapApprove(userId: String)
    func didTapReject(userId: String)
}

class PendingRequestCell: UITableViewCell {
    weak var delegate: PendingRequestCellDelegate?
    private var userId: String?
    
    // MARK: - UI Components
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Accepter", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(approveTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var rejectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Refuser", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(rejectTapped), for: .touchUpInside)
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
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(approveButton)
        contentView.addSubview(rejectButton)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: approveButton.leadingAnchor, constant: -8),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: approveButton.leadingAnchor, constant: -8),
            emailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            rejectButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rejectButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rejectButton.widthAnchor.constraint(equalToConstant: 80),
            rejectButton.heightAnchor.constraint(equalToConstant: 36),
            
            approveButton.trailingAnchor.constraint(equalTo: rejectButton.leadingAnchor, constant: -8),
            approveButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            approveButton.widthAnchor.constraint(equalToConstant: 80),
            approveButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    // MARK: - Configuration
    func configure(with request: GroupMember, delegate: PendingRequestCellDelegate) {
        self.userId = request.userId.id
        self.delegate = delegate
        nameLabel.text = request.userId.nom
        emailLabel.text = request.userId.email
    }
    
    // MARK: - Actions
    @objc private func approveTapped() {
        guard let userId = userId else { return }
        delegate?.didTapApprove(userId: userId)
    }
    
    @objc private func rejectTapped() {
        guard let userId = userId else { return }
        delegate?.didTapReject(userId: userId)
    }
}
