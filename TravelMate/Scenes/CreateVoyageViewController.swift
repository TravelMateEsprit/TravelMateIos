import UIKit

class CreateVoyageViewController: UIViewController {
    private let voyageService = VoyageService.shared
    
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
    
    private lazy var destinationTextField: UITextField = {
        let textField = createStyledTextField(placeholder: "Destination", icon: "mappin.circle.fill")
        return textField
    }()
    
    private lazy var typePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    private lazy var typeTextField: UITextField = {
        let textField = createStyledTextField(placeholder: "Type de voyage", icon: "tag.fill")
        textField.inputView = typePicker
        textField.inputAccessoryView = createToolbar()
        return textField
    }()
    
    private lazy var departDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        picker.minimumDate = Date()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(departDateChanged), for: .valueChanged)
        return picker
    }()
    
    private lazy var retourDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        // Set initial date to 1 day after departure
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        picker.date = tomorrow
        picker.minimumDate = tomorrow
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(retourDateChanged), for: .valueChanged)
        return picker
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .systemBackground
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return textView
    }()
    
    private lazy var descriptionPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Description du voyage"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .placeholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var priceTextField: UITextField = {
        let textField = createStyledTextField(placeholder: "Prix estimé", icon: "dollarsign.circle.fill")
        textField.keyboardType = .decimalPad
        textField.inputAccessoryView = createToolbar()
        return textField
    }()
    
    private lazy var placesStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 100
        stepper.value = 10
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.addTarget(self, action: #selector(placesStepperChanged), for: .valueChanged)
        stepper.tintColor = .systemOrange
        stepper.isEnabled = true
        stepper.isUserInteractionEnabled = true
        return stepper
    }()
    
    private lazy var placesLabel: UILabel = {
        let label = UILabel()
        label.text = "10 places"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imageUrlTextField: UITextField = {
        let textField = createStyledTextField(placeholder: "URL de l'image (optionnel)", icon: "photo.fill")
        textField.keyboardType = .URL
        textField.autocapitalizationType = .none
        textField.inputAccessoryView = createToolbar()
        return textField
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Créer le voyage", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.layer.shadowColor = UIColor.systemOrange.cgColor
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
    
    // Backend expects lowercase values: vol, hotel, voiture
    private let voyageTypes = ["vol", "hotel", "voiture"]
    private let voyageTypeDisplayNames = ["Vol", "Hôtel", "Location voiture"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupDescriptionPlaceholder()
    }
    
    private func setupDescriptionPlaceholder() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(descriptionTextChanged),
            name: UITextView.textDidChangeNotification,
            object: descriptionTextView
        )
        descriptionPlaceholderLabel.isHidden = !descriptionTextView.text.isEmpty
    }
    
    @objc private func descriptionTextChanged() {
        descriptionPlaceholderLabel.isHidden = !descriptionTextView.text.isEmpty
    }
    
    private func setupNavigationBar() {
        title = "Nouveau voyage"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .systemOrange
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Destination
        stackView.addArrangedSubview(createSectionTitle("Destination"))
        stackView.addArrangedSubview(destinationTextField)
        
        // Type
        stackView.addArrangedSubview(createSectionTitle("Type de voyage"))
        stackView.addArrangedSubview(typeTextField)
        
        // Dates
        stackView.addArrangedSubview(createSectionTitle("Dates"))
        
        let datesContainer = UIView()
        datesContainer.translatesAutoresizingMaskIntoConstraints = false
        datesContainer.backgroundColor = .systemBackground
        datesContainer.layer.cornerRadius = 12
        
        let departLabel = UILabel()
        departLabel.text = "Départ"
        departLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        departLabel.textColor = .secondaryLabel
        departLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let retourLabel = UILabel()
        retourLabel.text = "Retour"
        retourLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        retourLabel.textColor = .secondaryLabel
        retourLabel.translatesAutoresizingMaskIntoConstraints = false
        
        datesContainer.addSubview(departLabel)
        datesContainer.addSubview(departDatePicker)
        datesContainer.addSubview(retourLabel)
        datesContainer.addSubview(retourDatePicker)
        
        NSLayoutConstraint.activate([
            departLabel.topAnchor.constraint(equalTo: datesContainer.topAnchor, constant: 16),
            departLabel.leadingAnchor.constraint(equalTo: datesContainer.leadingAnchor, constant: 16),
            
            departDatePicker.topAnchor.constraint(equalTo: departLabel.bottomAnchor, constant: 8),
            departDatePicker.leadingAnchor.constraint(equalTo: datesContainer.leadingAnchor, constant: 16),
            departDatePicker.trailingAnchor.constraint(equalTo: datesContainer.trailingAnchor, constant: -16),
            
            retourLabel.topAnchor.constraint(equalTo: departDatePicker.bottomAnchor, constant: 20),
            retourLabel.leadingAnchor.constraint(equalTo: datesContainer.leadingAnchor, constant: 16),
            
            retourDatePicker.topAnchor.constraint(equalTo: retourLabel.bottomAnchor, constant: 8),
            retourDatePicker.leadingAnchor.constraint(equalTo: datesContainer.leadingAnchor, constant: 16),
            retourDatePicker.trailingAnchor.constraint(equalTo: datesContainer.trailingAnchor, constant: -16),
            retourDatePicker.bottomAnchor.constraint(equalTo: datesContainer.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(datesContainer)
        
        // Description (REQUIRED)
        stackView.addArrangedSubview(createSectionTitle("Description *"))
        
        let descriptionContainer = UIView()
        descriptionContainer.translatesAutoresizingMaskIntoConstraints = false
        descriptionContainer.backgroundColor = .systemBackground
        descriptionContainer.layer.cornerRadius = 12
        descriptionContainer.addSubview(descriptionTextView)
        descriptionContainer.addSubview(descriptionPlaceholderLabel)
        
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: descriptionContainer.topAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionContainer.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionContainer.bottomAnchor),
            
            descriptionPlaceholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 16),
            descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 20),
            descriptionPlaceholderLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(descriptionContainer)
        
        // Price and Places
        let pricePlacesContainer = UIView()
        pricePlacesContainer.translatesAutoresizingMaskIntoConstraints = false
        pricePlacesContainer.backgroundColor = .systemBackground
        pricePlacesContainer.layer.cornerRadius = 12
        
        let priceTitleLabel = createSectionTitle("Prix estimé *")
        priceTitleLabel.textAlignment = .left
        pricePlacesContainer.addSubview(priceTitleLabel)
        pricePlacesContainer.addSubview(priceTextField)
        
        let placesTitleLabel = createSectionTitle("Nombre de places")
        placesTitleLabel.textAlignment = .left
        pricePlacesContainer.addSubview(placesTitleLabel)
        pricePlacesContainer.addSubview(placesLabel)
        pricePlacesContainer.addSubview(placesStepper)
        
        NSLayoutConstraint.activate([
            priceTitleLabel.topAnchor.constraint(equalTo: pricePlacesContainer.topAnchor, constant: 16),
            priceTitleLabel.leadingAnchor.constraint(equalTo: pricePlacesContainer.leadingAnchor, constant: 16),
            priceTitleLabel.trailingAnchor.constraint(equalTo: pricePlacesContainer.trailingAnchor, constant: -16),
            
            priceTextField.topAnchor.constraint(equalTo: priceTitleLabel.bottomAnchor, constant: 12),
            priceTextField.leadingAnchor.constraint(equalTo: pricePlacesContainer.leadingAnchor, constant: 16),
            priceTextField.trailingAnchor.constraint(equalTo: pricePlacesContainer.trailingAnchor, constant: -16),
            
            placesTitleLabel.topAnchor.constraint(equalTo: priceTextField.bottomAnchor, constant: 24),
            placesTitleLabel.leadingAnchor.constraint(equalTo: pricePlacesContainer.leadingAnchor, constant: 16),
            
            placesLabel.centerYAnchor.constraint(equalTo: placesStepper.centerYAnchor),
            placesLabel.leadingAnchor.constraint(equalTo: pricePlacesContainer.leadingAnchor, constant: 16),
            placesLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            placesStepper.centerYAnchor.constraint(equalTo: placesLabel.centerYAnchor),
            placesStepper.leadingAnchor.constraint(equalTo: placesLabel.trailingAnchor, constant: 24),
            placesStepper.trailingAnchor.constraint(lessThanOrEqualTo: pricePlacesContainer.trailingAnchor, constant: -16),
            placesStepper.bottomAnchor.constraint(equalTo: pricePlacesContainer.bottomAnchor, constant: -16),
            placesStepper.widthAnchor.constraint(equalToConstant: 94) // Standard stepper width
        ])
        
        stackView.addArrangedSubview(pricePlacesContainer)
        
        // Image URL
        stackView.addArrangedSubview(createSectionTitle("Image"))
        stackView.addArrangedSubview(imageUrlTextField)
        
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
            
            descriptionContainer.heightAnchor.constraint(equalToConstant: 120),
            
            datesContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            pricePlacesContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 150),
            
            createButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 32),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 56),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: createButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: createButton.centerYAnchor)
        ])
    }
    
    private func createStyledTextField(placeholder: String, icon: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 12
        textField.borderStyle = .none
        
        // Add left icon view
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .systemOrange
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        leftView.addSubview(iconView)
        iconView.center = leftView.center
        
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
        textField.rightView = paddingView
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
    
    private func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        doneButton.tintColor = .systemOrange
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: false)
        return toolbar
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func departDateChanged() {
        // Ensure return date is always after departure date
        let minReturnDate = Calendar.current.date(byAdding: .minute, value: 1, to: departDatePicker.date) ?? departDatePicker.date
        retourDatePicker.minimumDate = minReturnDate
        
        // If return date is before or equal to departure, update it
        if retourDatePicker.date <= departDatePicker.date {
            retourDatePicker.date = minReturnDate
        }
    }
    
    @objc private func retourDateChanged() {
        // Validation handled in form validation
    }
    
    @objc private func placesStepperChanged() {
        placesLabel.text = "\(Int(placesStepper.value)) place\(Int(placesStepper.value) > 1 ? "s" : "")"
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        print("🔵 [CREATE VOYAGE] Button tapped")
        
        guard validateForm() else {
            print("❌ [CREATE VOYAGE] Form validation failed")
            return
        }
        
        print("✅ [CREATE VOYAGE] Form validation passed")
        
        // Date formatter - must match backend format exactly: "YYYY-MM-DD HH:mm"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent formatting
        
        // Debug: Log all field values before processing
        let destination = destinationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let departDate = departDatePicker.date
        let retourDate = retourDatePicker.date
        let selectedTypeIndex = typePicker.selectedRow(inComponent: 0)
        let selectedType = voyageTypes[selectedTypeIndex]
        let descriptionText = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let priceText = priceTextField.text ?? ""
        let placesValue = placesStepper.value
        let imageUrlText = imageUrlTextField.text ?? ""
        
        print("📋 [CREATE VOYAGE] Field values:")
        print("   - Destination: '\(destination)'")
        print("   - Depart Date: \(departDate)")
        print("   - Retour Date: \(retourDate)")
        print("   - Type Index: \(selectedTypeIndex)")
        print("   - Type: '\(selectedType)'")
        print("   - Description: '\(descriptionText)' (length: \(descriptionText.count))")
        print("   - Price Text: '\(priceText)'")
        print("   - Places: \(placesValue)")
        print("   - Image URL: '\(imageUrlText)'")
        
        // Format dates
        let dateDepartString = formatter.string(from: departDate)
        let dateRetourString = formatter.string(from: retourDate)
        print("   - Date Depart (formatted): '\(dateDepartString)'")
        print("   - Date Retour (formatted): '\(dateRetourString)'")
        
        // Parse prix_estime - REQUIRED, must be valid number >= 0
        guard let prixEstime = Double(priceText), prixEstime >= 0 else {
            print("❌ [CREATE VOYAGE] Invalid price: '\(priceText)'")
            showErrorAlert(message: "Veuillez saisir un prix estimé valide (nombre >= 0)")
            return
        }
        print("   - Prix estimé (parsed): \(prixEstime)")
        
        // Parse description - REQUIRED, must not be empty
        guard !descriptionText.isEmpty else {
            print("❌ [CREATE VOYAGE] Empty description")
            showErrorAlert(message: "Veuillez saisir une description")
            return
        }
        
        // Parse nombre_places - always send as number (stepper always has a value)
        let nombrePlaces = Int(placesValue)
        print("   - Nombre places (parsed): \(nombrePlaces)")
        
        // Validate and parse imageUrl - must be valid URL if provided
        let imageUrl: String? = {
            guard !imageUrlText.isEmpty else {
                return nil
            }
            // Basic URL validation
            if imageUrlText.hasPrefix("http://") || imageUrlText.hasPrefix("https://") {
                return imageUrlText
            }
            // If no protocol, add https://
            return "https://\(imageUrlText)"
        }()
        print("   - Image URL (final): \(imageUrl ?? "nil")")
        
        let dto = CreateVoyageDto(
            destination: destination,
            date_depart: dateDepartString,
            date_retour: dateRetourString,
            type: selectedType,
            description: descriptionText,
            prix_estime: prixEstime,
            nombre_places: nombrePlaces,
            imageUrl: imageUrl
        )
        
        // Debug: Print the DTO being sent
        print("📤 [CREATE VOYAGE] Creating DTO...")
        do {
            let jsonData = try JSONEncoder().encode(dto)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📦 [CREATE VOYAGE] DTO JSON: \(jsonString)")
            } else {
                print("⚠️ [CREATE VOYAGE] Could not convert DTO to string")
            }
            print("📦 [CREATE VOYAGE] DTO Data size: \(jsonData.count) bytes")
        } catch {
            print("❌ [CREATE VOYAGE] Error encoding DTO: \(error)")
            showErrorAlert(message: "Erreur lors de la préparation des données: \(error.localizedDescription)")
            return
        }
        
        createButton.isEnabled = false
        loadingIndicator.startAnimating()
        createButton.setTitle("", for: .normal)
        
        Task {
            print("🚀 [CREATE VOYAGE] Starting API call...")
            do {
                let voyage = try await voyageService.createVoyage(dto)
                print("✅ [CREATE VOYAGE] Voyage created successfully!")
                print("   - Voyage ID: \(voyage.id)")
                print("   - Destination: \(voyage.destination)")
                
                // Refresh voyages list to ensure we have latest data
                print("🔄 [CREATE VOYAGE] Refreshing voyages list...")
                await voyageService.fetchVoyages()
                
                DispatchQueue.main.async {
                    print("✅ [CREATE VOYAGE] UI update - success")
                    self.loadingIndicator.stopAnimating()
                    self.createButton.isEnabled = true
                    self.createButton.setTitle("Créer le voyage", for: .normal)
                    self.dismiss(animated: true)
                }
            } catch {
                print("❌ [CREATE VOYAGE] Error occurred:")
                print("   - Error type: \(type(of: error))")
                print("   - Error description: \(error.localizedDescription)")
                print("   - Full error: \(error)")
                
                // Extract better error message
                var errorMessage = error.localizedDescription
                
                // Try to get more details from NetworkError
                if let networkError = error as? NetworkService.NetworkError {
                    print("   - Network error case: \(networkError)")
                    errorMessage = networkError.localizedDescription
                } else if let urlError = error as? URLError {
                    print("   - URL Error code: \(urlError.code.rawValue)")
                    print("   - URL Error description: \(urlError.localizedDescription)")
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
                    self.createButton.isEnabled = true
                    self.createButton.setTitle("Créer le voyage", for: .normal)
                    print("❌ [CREATE VOYAGE] Showing error alert: \(errorMessage)")
                    self.showErrorAlert(message: errorMessage)
                }
            }
        }
    }
    
    private func validateForm() -> Bool {
        guard let destination = destinationTextField.text, !destination.isEmpty else {
            showErrorAlert(message: "Veuillez saisir une destination")
            return false
        }
        
        guard departDatePicker.date < retourDatePicker.date else {
            showErrorAlert(message: "La date de retour doit être après la date de départ")
            return false
        }
        
        guard typeTextField.text != nil, !typeTextField.text!.isEmpty else {
            showErrorAlert(message: "Veuillez sélectionner un type de voyage")
            return false
        }
        
        guard let priceText = priceTextField.text, !priceText.isEmpty,
              let price = Double(priceText), price >= 0 else {
            showErrorAlert(message: "Veuillez saisir un prix estimé valide")
            return false
        }
        
        guard !descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showErrorAlert(message: "Veuillez saisir une description")
            return false
        }
        
        return true
    }
    
    private func showErrorAlert(message: String) {
        print("🔴 [ERROR ALERT] Raw message: '\(message)'")
        
        // Clean up error message - remove technical details
        var cleanMessage = message
        
        // Remove common technical prefixes
        let prefixesToRemove = [
            "travelMate.",
            "networkService.",
            "NetworkService.",
            "NetworkError.",
            "Network error",
            "error "
        ]
        
        for prefix in prefixesToRemove {
            if let range = cleanMessage.range(of: prefix, options: .caseInsensitive) {
                cleanMessage = String(cleanMessage[range.upperBound...])
            }
        }
        
        // Remove any trailing error codes like "error 0"
        if let range = cleanMessage.range(of: "error ", options: .caseInsensitive) {
            let afterError = String(cleanMessage[range.upperBound...])
            // If it's just a number, remove it
            if let _ = Int(afterError.trimmingCharacters(in: .whitespacesAndNewlines)) {
                cleanMessage = String(cleanMessage[..<range.lowerBound])
            }
        }
        
        cleanMessage = cleanMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If message is empty or too technical, use a generic message
        if cleanMessage.isEmpty || cleanMessage.count < 3 {
            cleanMessage = "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer."
        }
        
        print("🔴 [ERROR ALERT] Cleaned message: '\(cleanMessage)'")
        
        let alert = UIAlertController(title: "Erreur", message: cleanMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDataSource & Delegate
extension CreateVoyageViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return voyageTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return voyageTypeDisplayNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTextField.text = voyageTypeDisplayNames[row]
    }
}

// Note: UITextView placeholder extension is defined in CreateReservationViewController.swift
