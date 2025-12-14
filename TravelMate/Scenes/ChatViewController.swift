import UIKit

struct ChatMessage {
    let id: String
    let senderId: String
    let text: String
    let createdAt: Date

    var isMine: Bool {
        AuthService.shared.currentUser?.id == senderId
    }
}

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let offer: Offer
    private var messages: [ChatMessage] = []

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.allowsSelection = false
        return tv
    }()

    private let inputContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowOffset = CGSize(width: 0, height: -1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Message..."
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        btn.tintColor = .systemBlue
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var inputBottomConstraint: NSLayoutConstraint!

    init(offer: Offer) {
        self.offer = offer
        super.init(nibName: nil, bundle: nil)
        title = "Chat • \(offer.titre)"
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupTable()
        setupInputBar()
        setupKeyboardObservers()
        setupWebSocketListeners()

        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }

    // MARK: - UI Setup

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatBubbleCell.self, forCellReuseIdentifier: "bubble")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupInputBar() {
        view.addSubview(inputContainer)
        inputContainer.addSubview(textField)
        inputContainer.addSubview(sendButton)

        inputBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBottomConstraint,
            inputContainer.heightAnchor.constraint(equalToConstant: 60),

            textField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 12),
            textField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 35)
        ])

        tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor).isActive = true
    }

    // MARK: - WebSocket

    private func setupWebSocketListeners() {

        let channel = "chat:\(offer.id)"

        WebSocketService.shared.listen(event: channel) { [weak self] data in
            guard let self = self else { return }
            guard let json = data.first as? [String: Any] else { return }

            guard let id = json["_id"] as? String,
                  let text = json["message"] as? String,
                  let senderId = json["senderId"] as? String else { return }

            let message = ChatMessage(
                id: id,
                senderId: senderId,
                text: text,
                createdAt: Date()
            )

            self.messages.append(message)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }

    @objc private func sendMessage() {
        guard let text = textField.text,
              !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let payload: [String: Any] = [
            "offerId": offer.id,
            "message": text
        ]

        WebSocketService.shared.emit(event: "chat:send", data: payload)

        textField.text = ""
    }

    // MARK: - Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let msg = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "bubble", for: indexPath) as! ChatBubbleCell
        cell.configure(message: msg)
        return cell
    }

    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        let index = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: index, at: .bottom, animated: true)
    }

    // MARK: - Keyboard

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func keyboardWillShow(_ notif: Notification) {
        if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            inputBottomConstraint.constant = -frame.height
            view.layoutIfNeeded()
            scrollToBottom()
        }
    }

    @objc private func keyboardWillHide(_ notif: Notification) {
        inputBottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
}
