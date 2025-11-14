import UIKit

protocol CreateInsuranceDelegate: AnyObject {
    func didCreateInsurance()
}

class CreateInsuranceViewController: UIViewController {
    weak var delegate: CreateInsuranceDelegate?
    private let insuranceService = InsuranceService.shared
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Nom de l'assurance"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let priceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Prix (TND)"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let durationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Durée (ex: 1 an, 6 mois)"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let coverageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let imageUrlTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "URL de l'image (optionnel)"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let activeSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Créer l'assurance", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .primaryColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Nouvelle Assurance"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let descriptionLabel = createLabel(text: "Description:")
        let coverageLabel = createLabel(text: "Couvertures (une par ligne):")
        let activeLabel = createLabel(text: "Assurance active:")
        
        contentView.addSubview(nameTextField)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(priceTextField)
        contentView.addSubview(durationTextField)
        contentView.addSubview(coverageLabel)
        contentView.addSubview(coverageTextView)
        contentView.addSubview(imageUrlTextField)
        contentView.addSubview(activeLabel)
        contentView.addSubview(activeSwitch)
        contentView.addSubview(createButton)
        
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        
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
            
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            priceTextField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            priceTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            priceTextField.heightAnchor.constraint(equalToConstant: 44),
            
            durationTextField.topAnchor.constraint(equalTo: priceTextField.bottomAnchor, constant: 12),
            durationTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            durationTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            durationTextField.heightAnchor.constraint(equalToConstant: 44),
            
            coverageLabel.topAnchor.constraint(equalTo: durationTextField.bottomAnchor, constant: 20),
            coverageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            coverageTextView.topAnchor.constraint(equalTo: coverageLabel.bottomAnchor, constant: 8),
            coverageTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            coverageTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            coverageTextView.heightAnchor.constraint(equalToConstant: 120),
            
            imageUrlTextField.topAnchor.constraint(equalTo: coverageTextView.bottomAnchor, constant: 20),
            imageUrlTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageUrlTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageUrlTextField.heightAnchor.constraint(equalToConstant: 44),
            
            activeLabel.topAnchor.constraint(equalTo: imageUrlTextField.bottomAnchor, constant: 20),
            activeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            activeSwitch.centerYAnchor.constraint(equalTo: activeLabel.centerYAnchor),
            activeSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            createButton.topAnchor.constraint(equalTo: activeSwitch.bottomAnchor, constant: 30),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 50),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createTapped() {
        guard validateInputs() else { return }
        
        let coverage = coverageTextView.text.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let request = CreateInsuranceRequest(
            name: nameTextField.text!,
            description: descriptionTextView.text,
            price: Double(priceTextField.text!) ?? 0,
            duration: durationTextField.text!,
            coverage: coverage,
            imageUrl: imageUrlTextField.text?.isEmpty == false ? imageUrlTextField.text : nil,
            conditions: nil,
            isActive: activeSwitch.isOn
        )
        
        createButton.isEnabled = false
        
        Task {
            do {
                _ = try await insuranceService.createInsurance(request: request)
                await MainActor.run {
                    self.delegate?.didCreateInsurance()
                    self.dismiss(animated: true)
                }
            } catch {
                await MainActor.run {
                    self.createButton.isEnabled = true
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func validateInputs() -> Bool {
        guard let name = nameTextField.text, !name.isEmpty else {
            showError(message: "Veuillez entrer un nom")
            return false
        }
        
        guard !descriptionTextView.text.isEmpty else {
            showError(message: "Veuillez entrer une description")
            return false
        }
        
        guard let priceText = priceTextField.text, !priceText.isEmpty,
              let price = Double(priceText), price > 0 else {
            showError(message: "Veuillez entrer un prix valide")
            return false
        }
        
        guard let duration = durationTextField.text, !duration.isEmpty else {
            showError(message: "Veuillez entrer une durée")
            return false
        }
        
        guard !coverageTextView.text.isEmpty else {
            showError(message: "Veuillez entrer au moins une couverture")
            return false
        }
        
        return true
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
