import UIKit

class GroupMessageCell: UITableViewCell {
    static let reuseIdentifier = "GroupMessageCell"
    
    private let bubbleView = UIView()
    private let messageImageView = UIImageView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let reactionsLabel = UILabel()
    
    private static let imageCache = NSCache<NSURL, UIImage>()
    private var currentImageURL: URL?
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var imageHeightConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        bubbleView.layer.cornerRadius = 16
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)
        
        messageImageView.contentMode = .scaleAspectFill
        messageImageView.clipsToBounds = true
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageImageView)
        
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)
        
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .systemGray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(timeLabel)
        
        reactionsLabel.font = UIFont.systemFont(ofSize: 12)
        reactionsLabel.textColor = .systemGray
        reactionsLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(reactionsLabel)
        
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        imageHeightConstraint = messageImageView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            
            leadingConstraint,
            trailingConstraint,
            
            messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            imageHeightConstraint,
            
            messageLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            reactionsLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 2),
            reactionsLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            reactionsLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            reactionsLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -4)
        ])
    }
    
    func configure(with message: GroupMessage) {
        if let firstImage = message.images.first, let url = URL(string: firstImage) {
            imageHeightConstraint.constant = 160
            messageImageView.isHidden = false
            loadImage(from: url)
            messageLabel.text = ""
        } else {
            imageHeightConstraint.constant = 0
            messageImageView.isHidden = true
            messageImageView.image = nil
            messageLabel.text = message.content ?? ""
        }
        
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: message.createdAt) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            timeLabel.text = formatter.string(from: date)
        } else {
            timeLabel.text = ""
        }
        
        if let reactions = message.reactions, !reactions.isEmpty {
            reactionsLabel.isHidden = false
            var counts: [String: Int] = [:]
            for reaction in reactions {
                counts[reaction.emoji, default: 0] += 1
            }
            let parts = counts.map { emoji, count in
                count > 1 ? "\(emoji) x\(count)" : emoji
            }.sorted()
            reactionsLabel.text = parts.joined(separator: "  ")
        } else {
            reactionsLabel.isHidden = true
        }
        
        if message.isMine {
            bubbleView.backgroundColor = .systemBlue
            messageLabel.textColor = .white
            timeLabel.textColor = UIColor.white.withAlphaComponent(0.8)
            reactionsLabel.textColor = UIColor.white.withAlphaComponent(0.8)
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
        } else {
            bubbleView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            messageLabel.textColor = .label
            timeLabel.textColor = .systemGray
            reactionsLabel.textColor = .systemGray
            trailingConstraint.isActive = false
            leadingConstraint.isActive = true
        }
    }
    
    private func loadImage(from url: URL) {
        currentImageURL = url
        if let cached = GroupMessageCell.imageCache.object(forKey: url as NSURL) {
            messageImageView.image = cached
            return
        }
        messageImageView.image = nil
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data, let image = UIImage(data: data) else { return }
            GroupMessageCell.imageCache.setObject(image, forKey: url as NSURL)
            DispatchQueue.main.async {
                if self.currentImageURL == url {
                    self.messageImageView.image = image
                }
            }
        }.resume()
    }
}
