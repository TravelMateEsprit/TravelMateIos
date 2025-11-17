import UIKit

class CreateReservationViewController: UIViewController {
    private let voyage: Voyage
    private let voyageService = VoyageService.shared
    
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
    
    private lazy var voyageInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var priceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Prix"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.keyboardType = .decimalPad
        textField.isEnabled = false // Disabled - price is calculated automatically
        textField.backgroundColor = UIColor.systemGray6
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return textField
    }()
    
    // Store base price per person from voyage
    private var basePricePerPerson: Double {
        return voyage.prix_estime ?? 0.0
    }
    
    // Computed property for total price
    private var totalPrice: Double {
        return basePricePerPerson * peopleStepper.value
    }
    
    // Reference to price info label for updates
    private var priceInfoLabel: UILabel?
    
    private lazy var peopleStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 20
        stepper.value = 1
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.addTarget(self, action: #selector(peopleStepperChanged), for: .valueChanged)
        return stepper
    }()
    
    private lazy var peopleLabel: UILabel = {
        let label = UILabel()
        label.text = "1 personne"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var notesTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.placeholder = "Notes (optionnel)"
        return textView
    }()
    
    private lazy var reserveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Réserver", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(reserveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(voyage: Voyage) {
        self.voyage = voyage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupVoyageInfo()
        updatePrice() // Initialize price from voyage
    }
    
    private func setupNavigationBar() {
        title = "Nouvelle réservation"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }
    
    private func setupVoyageInfo() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let destinationLabel = UILabel()
        destinationLabel.text = voyage.destination
        destinationLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        destinationLabel.textColor = .black
        
        let dateLabel = UILabel()
        dateLabel.text = voyage.dateRange()
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        dateLabel.textColor = .systemGray
        
        let typeLabel = UILabel()
        typeLabel.text = voyage.typeDisplayName()
        typeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        typeLabel.textColor = .systemGray
        
        stackView.addArrangedSubview(destinationLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(typeLabel)
        
        voyageInfoView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: voyageInfoView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: voyageInfoView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: voyageInfoView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: voyageInfoView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add top padding
        let topSpacer = UIView()
        topSpacer.translatesAutoresizingMaskIntoConstraints = false
        topSpacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
        stackView.addArrangedSubview(topSpacer)
        
        stackView.addArrangedSubview(createLabel("Voyage sélectionné"))
        stackView.addArrangedSubview(voyageInfoView)
        
        // Price section with info
        let priceContainer = UIView()
        priceContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let priceTitleLabel = createLabel("Prix total *")
        priceContainer.addSubview(priceTitleLabel)
        priceContainer.addSubview(priceTextField)
        
        let priceInfoLabel = UILabel()
        self.priceInfoLabel = priceInfoLabel
        priceInfoLabel.text = "Prix par personne: \(formatPrice(basePricePerPerson))"
        priceInfoLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        priceInfoLabel.textColor = .systemGray
        priceInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        priceContainer.addSubview(priceInfoLabel)
        
        NSLayoutConstraint.activate([
            priceTitleLabel.topAnchor.constraint(equalTo: priceContainer.topAnchor),
            priceTitleLabel.leadingAnchor.constraint(equalTo: priceContainer.leadingAnchor),
            priceTitleLabel.trailingAnchor.constraint(equalTo: priceContainer.trailingAnchor),
            
            priceTextField.topAnchor.constraint(equalTo: priceTitleLabel.bottomAnchor, constant: 8),
            priceTextField.leadingAnchor.constraint(equalTo: priceContainer.leadingAnchor),
            priceTextField.trailingAnchor.constraint(equalTo: priceContainer.trailingAnchor),
            
            priceInfoLabel.topAnchor.constraint(equalTo: priceTextField.bottomAnchor, constant: 4),
            priceInfoLabel.leadingAnchor.constraint(equalTo: priceContainer.leadingAnchor),
            priceInfoLabel.trailingAnchor.constraint(equalTo: priceContainer.trailingAnchor),
            priceInfoLabel.bottomAnchor.constraint(equalTo: priceContainer.bottomAnchor)
        ])
        
        stackView.addArrangedSubview(priceContainer)
        
        // People stepper with better layout
        let peopleContainer = UIView()
        peopleContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let peopleTitleLabel = createLabel("Nombre de personnes *")
        peopleContainer.addSubview(peopleTitleLabel)
        
        // Container for stepper and label
        let stepperContainer = UIView()
        stepperContainer.translatesAutoresizingMaskIntoConstraints = false
        stepperContainer.layer.borderWidth = 1
        stepperContainer.layer.borderColor = UIColor.systemGray5.cgColor
        stepperContainer.layer.cornerRadius = 8
        stepperContainer.backgroundColor = .systemGray6
        
        // Add stepper and label to container
        stepperContainer.addSubview(peopleLabel)
        stepperContainer.addSubview(peopleStepper)
        
        // Style the stepper
        peopleStepper.tintColor = .systemBlue
        
        // Style the label
        peopleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        peopleLabel.textAlignment = .center
        
        peopleContainer.addSubview(stepperContainer)
        
        NSLayoutConstraint.activate([
            // Title
            peopleTitleLabel.topAnchor.constraint(equalTo: peopleContainer.topAnchor),
            peopleTitleLabel.leadingAnchor.constraint(equalTo: peopleContainer.leadingAnchor),
            peopleTitleLabel.trailingAnchor.constraint(equalTo: peopleContainer.trailingAnchor),
            
            // Stepper container
            stepperContainer.topAnchor.constraint(equalTo: peopleTitleLabel.bottomAnchor, constant: 8),
            stepperContainer.leadingAnchor.constraint(equalTo: peopleContainer.leadingAnchor),
            stepperContainer.trailingAnchor.constraint(equalTo: peopleContainer.trailingAnchor),
            stepperContainer.heightAnchor.constraint(equalToConstant: 50),
            stepperContainer.bottomAnchor.constraint(equalTo: peopleContainer.bottomAnchor),
            
            // Label and stepper inside container
            peopleLabel.leadingAnchor.constraint(equalTo: stepperContainer.leadingAnchor, constant: 16),
            peopleLabel.centerYAnchor.constraint(equalTo: stepperContainer.centerYAnchor),
            
            peopleStepper.trailingAnchor.constraint(equalTo: stepperContainer.trailingAnchor, constant: -16),
            peopleStepper.centerYAnchor.constraint(equalTo: stepperContainer.centerYAnchor)
        ])
        
        stackView.addArrangedSubview(peopleContainer)
        
        stackView.addArrangedSubview(createLabel("Notes"))
        stackView.addArrangedSubview(notesTextView)
        
        contentView.addSubview(stackView)
        contentView.addSubview(reserveButton)
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
            
            notesTextView.heightAnchor.constraint(equalToConstant: 100),
            
            reserveButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            reserveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            reserveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            reserveButton.heightAnchor.constraint(equalToConstant: 50),
            reserveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: reserveButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: reserveButton.centerYAnchor)
        ])
    }
    
    private func createLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: false)
        return toolbar
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func peopleStepperChanged() {
        let count = Int(peopleStepper.value)
        peopleLabel.text = count == 1 ? "1 personne" : "\(count) personnes"
        updatePrice() // Recalculate price when number of people changes
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func updatePrice() {
        let total = totalPrice
        let peopleCount = Int(peopleStepper.value)
        priceTextField.text = formatPrice(total)
        
        // Update price info label if it exists
        if let priceInfoLabel = priceInfoLabel {
            priceInfoLabel.text = "\(formatPrice(basePricePerPerson)) × \(peopleCount) personne\(peopleCount > 1 ? "s" : "") = \(formatPrice(total))"
        }
        
        // Update the price field with animation
        UIView.animate(withDuration: 0.2) {
            self.priceTextField.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.priceTextField.transform = .identity
            }
        }
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        if let formatted = formatter.string(from: NSNumber(value: price)) {
            return "\(formatted)€"
        }
        return "\(Int(price))€"
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func reserveButtonTapped() {
        guard validateForm() else { return }
        
        // Ensure we have a valid price
        guard totalPrice > 0 else {
            showErrorAlert(message: "Le prix du voyage n'est pas disponible")
            return
        }
        
        // Ensure we have a valid number of people (at least 1)
        let numberOfPeople = max(1, Int(peopleStepper.value))
        
        let dto = CreateReservationDto(
            id_voyage: voyage.id,
            prix: totalPrice,
            nombre_personnes: numberOfPeople,
            notes: notesTextView.text.isEmpty ? nil : notesTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        print("📤 [CREATE RESERVATION] Creating reservation:")
        print("   - Voyage ID: \(dto.id_voyage)")
        print("   - Is valid MongoDB ID: \(dto.id_voyage.count == 24)")
        print("   - Prix: \(dto.prix)")
        print("   - Nombre personnes: \(dto.nombre_personnes ?? 1)")
        print("   - Notes: \(dto.notes ?? "nil")")
        
        reserveButton.isEnabled = false
        loadingIndicator.startAnimating()
        
        Task {
            print("🚀 [CREATE RESERVATION] Starting reservation creation...")
            do {
                try await voyageService.createReservation(dto)
                print("✅ [CREATE RESERVATION] Reservation created successfully")
                
                // Refresh reservations list to show the new reservation
                print("🔄 [CREATE RESERVATION] Refreshing reservations list...")
                await voyageService.fetchReservations()
                
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.reserveButton.isEnabled = true
                    
                    let alert = UIAlertController(
                        title: "Succès",
                        message: "Réservation créée avec succès !",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.dismiss(animated: true)
                    })
                    self.present(alert, animated: true)
                }
            } catch {
                print("❌ [CREATE RESERVATION] Error creating reservation:")
                print("   - Error type: \(type(of: error))")
                print("   - Error: \(error)")
                
                var errorMessage = error.localizedDescription
                if let networkError = error as? NetworkService.NetworkError {
                    errorMessage = networkError.localizedDescription
                } else if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        errorMessage = "Pas de connexion Internet. Vérifiez votre connexion réseau."
                    case .timedOut:
                        errorMessage = "La requête a expiré. Veuillez réessayer."
                    case .cannotFindHost, .cannotConnectToHost:
                        errorMessage = "Impossible de se connecter au serveur. Vérifiez votre connexion."
                    default:
                        errorMessage = "Erreur réseau: \(urlError.localizedDescription)"
                    }
                }
                
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.reserveButton.isEnabled = true
                    self.showErrorAlert(message: errorMessage)
                }
            }
        }
    }
    
    private func validateForm() -> Bool {
        // Validate that we have a valid price (should always be true since it's auto-calculated)
        guard totalPrice > 0 else {
            showErrorAlert(message: "Le prix du voyage n'est pas disponible")
            return false
        }
        
        // Validate number of people
        guard peopleStepper.value >= 1 else {
            showErrorAlert(message: "Le nombre de personnes doit être au moins 1")
            return false
        }
        
        return true
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextView Placeholder Extension
extension UITextView {
    var placeholder: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.placeholder) as? String
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.placeholder, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(textViewDidChange),
                    name: UITextView.textDidChangeNotification,
                    object: self
                )
                
                updatePlaceholder()
            }
        }
    }
    
    @objc private func textViewDidChange() {
        updatePlaceholder()
    }
    
    private func updatePlaceholder() {
        if let placeholder = placeholder {
            if text.isEmpty {
                if subviews.contains(where: { $0.tag == 999 }) {
                    return
                }
                
                let label = UILabel()
                label.text = placeholder
                label.font = font
                label.textColor = .systemGray3
                label.tag = 999
                label.translatesAutoresizingMaskIntoConstraints = false
                addSubview(label)
                
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: topAnchor, constant: textContainerInset.top),
                    label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: textContainerInset.left + 4),
                    label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -textContainerInset.right)
                ])
            } else {
                subviews.first(where: { $0.tag == 999 })?.removeFromSuperview()
            }
        }
    }
}

private struct AssociatedKeys {
    static var placeholder = "placeholder"
}

