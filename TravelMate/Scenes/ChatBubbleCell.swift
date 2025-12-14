import UIKit

class ChatBubbleCell: UITableViewCell {

    private let bubble = UIView()
    private let messageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        contentView.addSubview(bubble)
        bubble.addSubview(messageLabel)

        bubble.layer.cornerRadius = 16
        bubble.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(message: ChatMessage) {

        messageLabel.text = message.text

        NSLayoutConstraint.deactivate(bubble.constraints)

        if message.isMine {
            bubble.backgroundColor = UIColor.systemBlue
            messageLabel.textColor = .white

            NSLayoutConstraint.activate([
                bubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
                bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
                bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
                bubble.widthAnchor.constraint(lessThanOrEqualToConstant: 260),

                messageLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 12),
                messageLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -12),
                messageLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 8),
                messageLabel.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -8)
            ])

        } else {
            bubble.backgroundColor = UIColor.systemGray5
            messageLabel.textColor = .black

            NSLayoutConstraint.activate([
                bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
                bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
                bubble.widthAnchor.constraint(lessThanOrEqualToConstant: 260),

                messageLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 12),
                messageLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -12),
                messageLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 8),
                messageLabel.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -8)
            ])
        }
    }
}
