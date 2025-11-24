import UIKit

class EditGroupViewController: UIViewController {
    private let group: Group
    private let groupService = GroupService.shared
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
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
        button.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = createTextField(placeholder: "Nom du groupe")
        return textField
    }()
    
    private lazy var destinationTextField: UITextField = {
        let textField = createTextField(placeholder: "Destination")
        return textField
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return textView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enregistrer", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var selectedImageUrl: String?
    
    // MARK: - Initialization
    init(group: Group) {
        self.group = group
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
        populateFields()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Modifier le groupe"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }
    
    private func populateFields() {
        nameTextField.text = group.nom
        destinationTextField.text = group.destination
        descriptionTextView.text = group.description ?? ""
        selectedImageUrl = group.photoUrl
        
        if let photoUrl = group.photoUrl, let url = URL(string: photoUrl) {
            loadImage(from: url)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(createLabel("Photo du groupe"))
        stackView.addArrangedSubview(photoButton)
        stackView.addArrangedSubview(createLabel("Nom du groupe"))
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(createLabel("Destination"))
        stackView.addArrangedSubview(destinationTextField)
        stackView.addArrangedSubview(createLabel("Description"))
        stackView.addArrangedSubview(descriptionTextView)
        
        contentView.addSubview(stackView)
        contentView.addSubview(saveButton)
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
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            saveButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return textField
    }
    
    private func createLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemGray
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
        
        alert.addTextField { [weak self] textField in
            textField.placeholder = "https://example.com/image.jpg"
            textField.text = self?.selectedImageUrl
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak alert] _ in
            if let urlText = alert?.textFields?.first?.text, !urlText.isEmpty {
                self?.selectedImageUrl = urlText
                if let url = URL(string: urlText) {
                    self?.loadImage(from: url)
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard validateForm() else { return }
        
        let dto = UpdateGroupDto(
            nom: nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            destination: destinationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            description: descriptionTextView.text.isEmpty ? nil : descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines),
            photoUrl: selectedImageUrl
        )
                
                saveButton.isEnabled = false
                loadingIndicator.startAnimating()
                saveButton.setTitle("", for: .normal)
                
                Task {
                    do {
                        let updatedGroup = try await groupService.updateGroup(id: group.id, dto)
                        print("✅ Group updated: \(updatedGroup.id)")
                        
                        await groupService.fetchGroups()
                        
                        DispatchQueue.main.async {
                            self.loadingIndicator.stopAnimating()
                            self.saveButton.isEnabled = true
                            self.saveButton.setTitle("Enregistrer", for: .normal)
                            self.dismiss(animated: true)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.loadingIndicator.stopAnimating()
                            self.saveButton.isEnabled = true
                            self.saveButton.setTitle("Enregistrer", for: .normal)
                            self.showErrorAlert(message: error.localizedDescription)
                        }
                    }
                }
            }
            
            private func validateForm() -> Bool {
                guard let name = nameTextField.text, !name.isEmpty else {
                    showErrorAlert(message: "Veuillez saisir un nom pour le groupe")
                    return false
                }
                
                guard let destination = destinationTextField.text, !destination.isEmpty else {
                    showErrorAlert(message: "Veuillez saisir une destination")
                    return false
                }
                
                return true
            }
            
            private func loadImage(from url: URL) {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let data = data, let image = UIImage(data: data) else {
                        DispatchQueue.main.async {
                            self?.photoButton.setImage(UIImage(systemName: "person.3.fill"), for: .normal)
                            self?.photoButton.tintColor = .systemBlue
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self?.photoButton.setImage(image, for: .normal)
                        self?.photoButton.imageView?.contentMode = .scaleAspectFill
                    }
                }.resume()
            }
            
            private func showErrorAlert(message: String) {
                let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
