import UIKit
import PhotosUI

class GroupChatViewController: UIViewController {
    private let groupId: String
    private let groupName: String
    
    private let chatService = GroupChatService.shared
    private let imageUploadService = ImageUploadService.shared
    private let socketService = GroupsSocketService.shared
    
    private var messages: [GroupMessage] = []
    private var isSending = false
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GroupMessageCell.self, forCellReuseIdentifier: GroupMessageCell.reuseIdentifier)
        tableView.keyboardDismissMode = .interactive
        return tableView
    }()
    
    private let inputContainerView = UIView()
    private let messageTextView = UITextView()
    private let sendButton = UIButton(type: .system)
    private let imageButton = UIButton(type: .system)
    private let typingLabel = UILabel()
    
    private var bottomConstraint: NSLayoutConstraint!
    private var typingTimer: Timer?
    private var isCurrentlyTyping = false
    
    init(groupId: String, groupName: String) {
        self.groupId = groupId
        self.groupName = groupName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        setupSocket()
        loadMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        socketService.leaveGroup(groupId: groupId)
    }
    
    private func setupUI() {
        title = groupName
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        view.addSubview(tableView)
        view.addSubview(typingLabel)
        view.addSubview(inputContainerView)
        
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.backgroundColor = .systemBackground
        inputContainerView.layer.borderWidth = 0.5
        inputContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        
        messageTextView.font = UIFont.systemFont(ofSize: 16)
        messageTextView.isScrollEnabled = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.delegate = self
        
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = .systemBlue
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        imageButton.setImage(UIImage(systemName: "photo"), for: .normal)
        imageButton.tintColor = .systemBlue
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        imageButton.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
        
        inputContainerView.addSubview(messageTextView)
        inputContainerView.addSubview(sendButton)
        inputContainerView.addSubview(imageButton)
        
        typingLabel.font = UIFont.systemFont(ofSize: 12)
        typingLabel.textColor = .systemGray
        typingLabel.translatesAutoresizingMaskIntoConstraints = false
        typingLabel.isHidden = true
        
        bottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: typingLabel.topAnchor),
            
            typingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            typingLabel.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -4),
            
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
            
            imageButton.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 8),
            imageButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            imageButton.widthAnchor.constraint(equalToConstant: 32),
            imageButton.heightAnchor.constraint(equalToConstant: 32),
            
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32),
            
            messageTextView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 8),
            messageTextView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -8),
            messageTextView.leadingAnchor.constraint(equalTo: imageButton.trailingAnchor, constant: 8),
            messageTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            messageTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36)
        ])
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupSocket() {
        socketService.connect()
        socketService.joinGroup(groupId: groupId)
        
        socketService.onNewMessage { [weak self] dict in
            guard let self = self else { return }
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
               let message = try? JSONDecoder().decode(GroupMessage.self, from: data) {
                Task { @MainActor in
                    if let id = message.id, self.messages.contains(where: { $0.id == id }) {
                        return
                    }
                    self.messages.append(message)
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            }
        }
        
        socketService.onMessageReacted { [weak self] dict in
            guard let self = self else { return }
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
               let updatedMessage = try? JSONDecoder().decode(GroupMessage.self, from: data),
               let id = updatedMessage.id,
               let index = self.messages.firstIndex(where: { $0.id == id }) {
                Task { @MainActor in
                    self.messages[index] = updatedMessage
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
            }
        }

        socketService.onMessageUpdated { [weak self] dict in
            guard let self = self else { return }
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
               let updatedMessage = try? JSONDecoder().decode(GroupMessage.self, from: data),
               let id = updatedMessage.id,
               let index = self.messages.firstIndex(where: { $0.id == id }) {
                Task { @MainActor in
                    self.messages[index] = updatedMessage
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
            }
        }

        socketService.onMessageDeleted { [weak self] dict in
            guard let self = self else { return }
            var deletedId: String?
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
               let deletedMessage = try? JSONDecoder().decode(GroupMessage.self, from: data),
               let id = deletedMessage.id {
                deletedId = id
            } else if let id = dict["messageId"] as? String {
                deletedId = id
            }
            guard let finalId = deletedId else { return }
            Task { @MainActor in
                if let index = self.messages.firstIndex(where: { $0.id == finalId }) {
                    self.messages.remove(at: index)
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        }
        
        socketService.onUserTyping { [weak self] dict in
            guard let self = self else { return }
            guard let userId = dict["userId"] as? String,
                  let isTyping = dict["isTyping"] as? Bool else { return }
            
            if userId == AuthService.shared.currentUser?.id { return }
            
            Task { @MainActor in
                self.typingLabel.isHidden = !isTyping
                if isTyping {
                    self.typingLabel.text = "Un membre est en train d'écrire..."
                }
            }
        }
    }
    
    private func loadMessages() {
        Task {
            do {
                let fetched = try await chatService.fetchMessages(groupId: groupId)
                await MainActor.run {
                    self.messages = fetched
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            } catch {
                print("Error loading messages: \(error)")
            }
        }
    }
    
    @objc private func sendButtonTapped() {
        guard !isSending else { return }
        let text = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        isSending = true
        let dto = CreateGroupMessageDto(content: text, images: [])
        
        Task {
            do {
                let message = try await chatService.sendMessage(groupId: groupId, dto: dto)
                await MainActor.run {
                    if let id = message.id, !self.messages.contains(where: { $0.id == id }) {
                        self.messages.append(message)
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    }
                    self.messageTextView.text = ""
                    self.isSending = false
                }
            } catch {
                await MainActor.run {
                    self.isSending = false
                }
                print("Error sending message: \(error)")
            }
        }
    }
    
    @objc private func imageButtonTapped() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    private func presentReactionPicker(for index: Int) {
        guard index < messages.count else { return }
        let message = messages[index]
        guard let messageId = message.id else { return }
        
        let alert = UIAlertController(title: "Réagir", message: "Choisissez un emoji", preferredStyle: .actionSheet)
        let emojis = ["👍", "❤️", "😂", "👏", "😮"]
        
        for emoji in emojis {
            alert.addAction(UIAlertAction(title: emoji, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.socketService.reactToMessage(groupId: self.groupId, messageId: messageId, emoji: emoji)
                
                let userId = AuthService.shared.currentUser?.id ?? "local-user"
                guard index < self.messages.count else { return }
                let original = self.messages[index]
                var reactions = original.reactions ?? []
                if let existingIndex = reactions.firstIndex(where: { $0.userId == userId && $0.emoji == emoji }) {
                    reactions.remove(at: existingIndex)
                } else {
                    let formatter = ISO8601DateFormatter()
                    let reaction = GroupReaction(id: nil, userId: userId, emoji: emoji, reactedAt: formatter.string(from: Date()))
                    reactions.append(reaction)
                }
                let updated = GroupMessage(
                    id: original.id,
                    groupId: original.groupId,
                    authorId: original.authorId,
                    content: original.content,
                    images: original.images,
                    reactions: reactions,
                    status: original.status,
                    createdAt: original.createdAt,
                    updatedAt: original.updatedAt
                )
                self.messages[index] = updated
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY - 100, width: 0, height: 0)
        }
        present(alert, animated: true)
    }

    private func presentMessageActions(for index: Int) {
        guard index < messages.count else { return }
        let message = messages[index]
        let isMine = message.isMine
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Réagir", style: .default, handler: { [weak self] _ in
            self?.presentReactionPicker(for: index)
        }))
        
        if isMine, let messageId = message.id {
            alert.addAction(UIAlertAction(title: "Modifier le message", style: .default, handler: { [weak self] _ in
                self?.presentEditMessageAlert(messageId: messageId, currentContent: message.content, index: index)
            }))
            
            alert.addAction(UIAlertAction(title: "Supprimer le message", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                Task {
                    do {
                        try await self.chatService.deleteMessage(groupId: self.groupId, messageId: messageId)
                        await MainActor.run {
                            if index < self.messages.count, self.messages[index].id == messageId {
                                self.messages.remove(at: index)
                                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            } else if let idx = self.messages.firstIndex(where: { $0.id == messageId }) {
                                self.messages.remove(at: idx)
                                self.tableView.deleteRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
                            }
                        }
                    } catch {
                        print("Error deleting message: \(error)")
                    }
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY - 100, width: 0, height: 0)
        }
        present(alert, animated: true)
    }
    
    private func presentEditMessageAlert(messageId: String, currentContent: String?, index: Int) {
        let alert = UIAlertController(title: "Modifier le message", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Nouveau message"
            textField.text = currentContent ?? ""
        }
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "Enregistrer", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            guard let newText = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newText.isEmpty else { return }
            
            Task {
                do {
                    let dto = UpdateGroupMessageDto(content: newText)
                    let updated = try await self.chatService.updateMessage(groupId: self.groupId, messageId: messageId, dto: dto)
                    DispatchQueue.main.async {
                        if let idx = self.messages.firstIndex(where: { $0.id == updated.id }) {
                            self.messages[idx] = updated
                            self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
                        } else if index < self.messages.count {
                            self.messages[index] = updated
                            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                    }
                } catch {
                    print("Error updating message: \(error)")
                }
            }
        }))
        present(alert, animated: true)
    }
    
    @objc private func handleKeyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        let keyboardFrame = frameValue.cgRectValue
        bottomConstraint.constant = -keyboardFrame.height + view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
            self.scrollToBottom()
        }
    }
    
    @objc private func handleKeyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        bottomConstraint.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}

extension GroupChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupMessageCell.reuseIdentifier, for: indexPath) as! GroupMessageCell
        let message = messages[indexPath.row]
        cell.configure(with: message)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentMessageActions(for: indexPath.row)
    }
}

extension GroupChatViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        let provider = result.itemProvider
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let self = self, let image = object as? UIImage, error == nil else { return }
                
                Task {
                    do {
                        let url = try await self.imageUploadService.uploadMessageImage(image)
                        let dto = CreateGroupMessageDto(content: "Image", images: [url])
                        let message = try await self.chatService.sendMessage(groupId: self.groupId, dto: dto)
                        await MainActor.run {
                            if let id = message.id, !self.messages.contains(where: { $0.id == id }) {
                                self.messages.append(message)
                                self.tableView.reloadData()
                                self.scrollToBottom()
                            }
                        }
                    } catch {
                        print("Error uploading/sending image message: \(error)")
                    }
                }
            }
        }
    }
}

extension GroupChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        sendTypingEvent()
    }
    
    private func sendTypingEvent() {
        if !isCurrentlyTyping {
            socketService.sendTyping(groupId: groupId, isTyping: true)
            isCurrentlyTyping = true
        }
        
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.socketService.sendTyping(groupId: self.groupId, isTyping: false)
            self.isCurrentlyTyping = false
        }
    }
}
