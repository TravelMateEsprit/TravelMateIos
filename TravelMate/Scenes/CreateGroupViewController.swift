import UIKit

class CreateGroupViewController: UIViewController {
    private let groupService = GroupService.shared
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var photoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.systemGray6
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGray4.cgColor
        
        let imageView = UIImageView(image: UIImage(systemName: "photo.badge.plus"))
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Cliquez pour choisir une photo"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(imageView)
        button.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: button.topAnchor, constant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16)
        ])
        
        button.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = createStyledTextField(placeholder: "Ex: Voyageurs solo en Asie")
        return textField
    }()
    
    private lazy var destinationTextField: UITextField = {
        let textField = createStyledTextField(placeholder: "Ex: Thaïlande")
        return textField
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .systemBackground
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.text = "Décrivez votre groupe..."
        textView.textColor = .placeholderText
        textView.delegate = self
        return textView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Créer le groupe", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.layer.shadowColor = UIColor.systemBlue.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    private var selectedImageUrl: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🧪 [CREATE GROUP VC] Configuration Debug")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📍 API Base URL: \(Config.apiBaseURL)")
        print("🔐 Authenticated: \(AuthService.shared.isAuthenticated)")
        
        if let user = AuthService.shared.currentUser {
            print("👤 User: \(user.name) (ID: \(user.id))")
            print("📧 Email: \(user.email)")
        } else {
            print("❌ No current user")
        }
        
        if let token = AuthService.shared.accessToken {
            print("🔑 Token: \(String(token.prefix(30)))...")
        } else {
            print("❌ No access token")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
        
        testBackendConnection()
    }
    
    // MARK: - Backend Connection Test
    private func testBackendConnection() {
        Task {
            do {
                print("🔍 Testing backend connection...")
                let url = URL(string: "\(Config.apiBaseURL)/groupes")!
                let (_, response) = try await URLSession.shared.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("✅ Backend reachable - Status: \(httpResponse.statusCode)")
                }
            } catch {
                print("❌ Backend connection test failed:")
                print("   Error: \(error.localizedDescription)")
                
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .cannotConnectToHost, .cannotFindHost:
                        print("   ⚠️ Le serveur backend ne répond pas sur \(Config.apiBaseURL)")
                        print("   💡 Vérifiez que le backend est démarré")
                    case .notConnectedToInternet:
                        print("   ⚠️ Pas de connexion Internet")
                    default:
                        print("   ⚠️ Erreur réseau: \(urlError.code.rawValue)")
                    }
                }
            }
        }
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Créer un groupe"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .systemBlue
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(createSectionTitle("Photo du groupe"))
        stackView.addArrangedSubview(photoButton)
        stackView.addArrangedSubview(createSectionTitle("Nom du groupe"))
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(createSectionTitle("Destination"))
        stackView.addArrangedSubview(destinationTextField)
        stackView.addArrangedSubview(createSectionTitle("Description"))
        stackView.addArrangedSubview(descriptionTextView)
        
        contentView.addSubview(stackView)
        contentView.addSubview(createButton)
        contentView.addSubview(loadingIndicator)
        
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
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            photoButton.heightAnchor.constraint(equalToConstant: 180),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 120),
            
            createButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 32),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 56),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: createButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: createButton.centerYAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func createStyledTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 12
        textField.borderStyle = .none
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
        
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        return textField
    }
    
    private func createSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func photoButtonTapped() {
        let alert = UIAlertController(
            title: "Photo du groupe",
            message: "Entrez l'URL d'une image",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "https://example.com/image.jpg"
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak alert] _ in
            if let urlText = alert?.textFields?.first?.text, !urlText.isEmpty {
                self?.selectedImageUrl = urlText
                self?.updatePhotoButton(with: urlText)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func updatePhotoButton(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.photoButton.subviews.forEach { $0.removeFromSuperview() }
                
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.translatesAutoresizingMaskIntoConstraints = false
                
                self?.photoButton.addSubview(imageView)
                
                NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: self!.photoButton.topAnchor, constant: 8),
                    imageView.leadingAnchor.constraint(equalTo: self!.photoButton.leadingAnchor, constant: 8),
                    imageView.trailingAnchor.constraint(equalTo: self!.photoButton.trailingAnchor, constant: -8),
                    imageView.bottomAnchor.constraint(equalTo: self!.photoButton.bottomAnchor, constant: -8)
                ])
            }
        }.resume()
    }
    
    @objc private func createButtonTapped() {
        print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔵 [CREATE] Button tapped - Starting creation")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        guard AuthService.shared.isAuthenticated else {
            print("❌ [CREATE] User not authenticated")
            showErrorAlert(
                title: "Non authentifié",
                message: "Vous devez être connecté pour créer un groupe.\n\nVeuillez vous reconnecter."
            )
            return
        }
        
        guard let user = AuthService.shared.currentUser else {
            print("❌ [CREATE] No current user")
            showErrorAlert(
                title: "Erreur",
                message: "Utilisateur non trouvé.\n\nVeuillez vous reconnecter."
            )
            return
        }
        
        guard let token = AuthService.shared.accessToken else {
            print("❌ [CREATE] No access token")
            showErrorAlert(
                title: "Erreur",
                message: "Token d'authentification manquant.\n\nVeuillez vous reconnecter."
            )
            return
        }
        
        print("✅ [CREATE] User authenticated")
        print("   User ID: \(user.id)")
        print("   User name: \(user.name)")
        print("   Token: \(String(token.prefix(20)))...")
        
        guard validateForm() else {
            print("❌ [CREATE] Form validation failed")
            return
        }
        
        let descriptionText: String?
        if descriptionTextView.textColor == .placeholderText || descriptionTextView.text == "Décrivez votre groupe..." {
            descriptionText = nil
        } else {
            descriptionText = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let dto = CreateGroupDto(
            nom: nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines),
            destination: destinationTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines),
            description: descriptionText,
            photoUrl: selectedImageUrl
        )
        
        print("\n📦 [CREATE] DTO prepared:")
        print("   Nom: '\(dto.nom)'")
        print("   Destination: '\(dto.destination)'")
        print("   Description: '\(dto.description ?? "nil")'")
        print("   PhotoUrl: '\(dto.photoUrl ?? "nil")'")
        print("   Target URL: \(Config.apiBaseURL)/groupes")
        
        createButton.isEnabled = false
        loadingIndicator.startAnimating()
        createButton.setTitle("", for: .normal)
        
        Task {
            print("\n🚀 [CREATE] Sending request...")
            do {
                let group = try await groupService.createGroup(dto)
                print("✅ [CREATE] Group created successfully!")
                print("   Group ID: \(group.id)")
                print("   Group name: \(group.nom)")
                
                await groupService.fetchGroups()
                
                await MainActor.run {
                    print("✅ [CREATE] UI updated, dismissing view")
                    self.loadingIndicator.stopAnimating()
                    self.createButton.isEnabled = true
                    self.createButton.setTitle("Créer le groupe", for: .normal)
                    self.dismiss(animated: true)
                }
            } catch {
                print("\n❌ [CREATE] Error occurred:")
                print("   Error type: \(type(of: error))")
                print("   Error: \(error)")
                
                var errorTitle = "Erreur"
                var errorMessage = "Une erreur s'est produite"
                
                if let networkError = error as? NetworkService.NetworkError {
                    print("   Network error: \(networkError)")
                    errorMessage = networkError.localizedDescription
                } else if let urlError = error as? URLError {
                    print("   URL Error code: \(urlError.code.rawValue)")
                    
                    switch urlError.code {
                    case .notConnectedToInternet:
                        errorTitle = "Pas de connexion"
                        errorMessage = "Vérifiez votre connexion Internet."
                    case .cannotConnectToHost, .cannotFindHost:
                        errorTitle = "Serveur inaccessible"
                        errorMessage = "Impossible de se connecter au serveur.\n\n" +
                                     "URL: \(Config.apiBaseURL)\n\n" +
                                     "Vérifications:\n" +
                                     "• Le backend est-il démarré ?\n" +
                                     "• L'URL est-elle correcte ?\n" +
                                     "• Le pare-feu bloque-t-il la connexion ?"
                    case .timedOut:
                        errorTitle = "Délai expiré"
                        errorMessage = "Le serveur ne répond pas.\n\nEssayez de redémarrer le backend."
                    default:
                        errorTitle = "Erreur réseau"
                        errorMessage = urlError.localizedDescription
                    }
                }
                
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.createButton.isEnabled = true
                    self.createButton.setTitle("Créer le groupe", for: .normal)
                    self.showErrorAlert(title: errorTitle, message: errorMessage)
                }
            }
        }
    }
    
    private func validateForm() -> Bool {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            showErrorAlert(
                title: "Champ requis",
                message: "Veuillez saisir un nom pour le groupe."
            )
            return false
        }
        
        guard let destination = destinationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !destination.isEmpty else {
            showErrorAlert(
                title: "Champ requis",
                message: "Veuillez saisir une destination."
            )
            return false
        }
        
        return true
    }
    
    private func showErrorAlert(title: String = "Erreur", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension CreateGroupViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Décrivez votre groupe..."
            textView.textColor = .placeholderText
        }
    }
}
