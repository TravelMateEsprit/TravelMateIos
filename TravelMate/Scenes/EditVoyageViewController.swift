import UIKit

class EditVoyageViewController: UIViewController {
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
    
    private lazy var destinationTextField: UITextField = {
        let textField = createTextField(placeholder: "Destination")
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
        let textField = createTextField(placeholder: "Type de voyage")
        textField.inputView = typePicker
        textField.inputAccessoryView = createToolbar()
        return textField
    }()
    
    private lazy var departDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var departTextField: UITextField = {
        let textField = createTextField(placeholder: "Date de départ")
        textField.inputView = departDatePicker
        textField.inputAccessoryView = createToolbar()
        return textField
    }()
    
    private lazy var retourDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var retourTextField: UITextField = {
        let textField = createTextField(placeholder: "Date de retour")
        textField.inputView = retourDatePicker
        textField.inputAccessoryView = createToolbar()
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
    
    private lazy var priceTextField: UITextField = {
        let textField = createTextField(placeholder: "Prix estimé (optionnel)")
        textField.keyboardType = .decimalPad
        textField.inputAccessoryView = createToolbar()
        return textField
    }()
    
    private lazy var placesStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 100
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.addTarget(self, action: #selector(placesStepperChanged), for: .valueChanged)
        return stepper
    }()
    
    private lazy var placesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imageUrlTextField: UITextField = {
        let textField = createTextField(placeholder: "URL de l'image (optionnel)")
        textField.keyboardType = .URL
        textField.autocapitalizationType = .none
        textField.inputAccessoryView = createToolbar()
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enregistrer", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemOrange
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
    
    // Backend expects lowercase values: vol, hotel, voiture
    private let voyageTypes = ["vol", "hotel", "voiture"]
    private let voyageTypeDisplayNames = ["Vol", "Hôtel", "Location voiture"]
    
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
        populateFields()
    }
    
    private func setupNavigationBar() {
        title = "Modifier le voyage"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }
    
    private func populateFields() {
        destinationTextField.text = voyage.destination
        descriptionTextView.text = voyage.description ?? ""
        
        if let price = voyage.prix_estime {
            priceTextField.text = String(format: "%.0f", price)
        }
        
        if let places = voyage.nombre_places {
            placesStepper.value = Double(places)
            placesLabel.text = "\(places) places"
        }
        
        imageUrlTextField.text = voyage.imageUrl
        
        // Set type picker - backend sends lowercase: vol, hotel, voiture
        let voyageTypeLower = voyage.type.lowercased()
        if let typeIndex = voyageTypes.firstIndex(of: voyageTypeLower) {
            typePicker.selectRow(typeIndex, inComponent: 0, animated: false)
            typeTextField.text = voyageTypeDisplayNames[typeIndex]
        } else {
            // Fallback: try to match "location_voiture" -> "voiture"
            if voyageTypeLower == "location_voiture" || voyageTypeLower.contains("voiture") {
                if let voitureIndex = voyageTypes.firstIndex(of: "voiture") {
                    typePicker.selectRow(voitureIndex, inComponent: 0, animated: false)
                    typeTextField.text = voyageTypeDisplayNames[voitureIndex]
                }
            } else {
                // Default to first option if no match
                typePicker.selectRow(0, inComponent: 0, animated: false)
                typeTextField.text = voyageTypeDisplayNames[0]
            }
        }
        
        // Set dates
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let departDate = formatter.date(from: voyage.date_depart) {
            departDatePicker.date = departDate
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd MMM yyyy, HH:mm"
            displayFormatter.locale = Locale(identifier: "fr_FR")
            departTextField.text = displayFormatter.string(from: departDate)
        }
        
        if let retourDate = formatter.date(from: voyage.date_retour) {
            retourDatePicker.date = retourDate
            retourDatePicker.minimumDate = departDatePicker.date
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd MMM yyyy, HH:mm"
            displayFormatter.locale = Locale(identifier: "fr_FR")
            retourTextField.text = displayFormatter.string(from: retourDate)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 21 // Increased spacing between attributes
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add spacing views between major sections for better visual separation
        stackView.addArrangedSubview(createLabel("Destination *"))
        stackView.addArrangedSubview(destinationTextField)
        stackView.addArrangedSubview(createSpacingView(height: 8))
        
        stackView.addArrangedSubview(createLabel("Type *"))
        stackView.addArrangedSubview(typeTextField)
        stackView.addArrangedSubview(createSpacingView(height: 8))
        
        stackView.addArrangedSubview(createLabel("Date de départ *"))
        stackView.addArrangedSubview(departTextField)
        stackView.addArrangedSubview(createSpacingView(height: 8))
        
        stackView.addArrangedSubview(createLabel("Date de retour *"))
        stackView.addArrangedSubview(retourTextField)
        stackView.addArrangedSubview(createSpacingView(height: 8))
        
        stackView.addArrangedSubview(createLabel("Description"))
        stackView.addArrangedSubview(descriptionTextView)
        stackView.addArrangedSubview(createSpacingView(height: 8))
        
        stackView.addArrangedSubview(createLabel("Prix estimé"))
        stackView.addArrangedSubview(priceTextField)
        stackView.addArrangedSubview(createSpacingView(height: 8))
        
        let placesContainer = UIView()
        placesContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Store the label in a variable to reuse it
        let placesTitleLabel = createLabel("Nombre de places")
        placesContainer.addSubview(placesTitleLabel)
        placesContainer.addSubview(placesLabel)
        placesContainer.addSubview(placesStepper)
        
        NSLayoutConstraint.activate([
            placesTitleLabel.topAnchor.constraint(equalTo: placesContainer.topAnchor),
            placesTitleLabel.leadingAnchor.constraint(equalTo: placesContainer.leadingAnchor),
            
            placesLabel.centerYAnchor.constraint(equalTo: placesStepper.centerYAnchor),
            placesLabel.leadingAnchor.constraint(equalTo: placesContainer.leadingAnchor),
            
            placesStepper.centerYAnchor.constraint(equalTo: placesLabel.centerYAnchor),
            placesStepper.leadingAnchor.constraint(equalTo: placesLabel.trailingAnchor, constant: 16),
            placesStepper.trailingAnchor.constraint(equalTo: placesContainer.trailingAnchor),
            placesStepper.bottomAnchor.constraint(equalTo: placesContainer.bottomAnchor)
        ])
        
        stackView.addArrangedSubview(placesContainer)
        
        stackView.addArrangedSubview(createLabel("URL de l'image"))
        stackView.addArrangedSubview(imageUrlTextField)
        
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
            
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            saveButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ])
        
        departDatePicker.addTarget(self, action: #selector(departDateChanged), for: .valueChanged)
        retourDatePicker.addTarget(self, action: #selector(retourDateChanged), for: .valueChanged)
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
    
    private func createSpacingView(height: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
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
    
    @objc private func departDateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "fr_FR")
        departTextField.text = formatter.string(from: departDatePicker.date)
        retourDatePicker.minimumDate = departDatePicker.date
    }
    
    @objc private func retourDateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "fr_FR")
        retourTextField.text = formatter.string(from: retourDatePicker.date)
    }
    
    @objc private func placesStepperChanged() {
        placesLabel.text = "\(Int(placesStepper.value)) places"
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard validateForm() else { return }
        
        // Date formatter - must match backend format exactly: "YYYY-MM-DD HH:mm"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent formatting
        
        // Parse prix_estime - only if text is not empty and valid
        let prixEstime: Double? = {
            guard let priceText = priceTextField.text, !priceText.isEmpty,
                  let price = Double(priceText), price >= 0 else {
                return nil
            }
            return price
        }()
        
        // Parse nombre_places - always send as number (stepper always has a value)
        let nombrePlaces = Int(placesStepper.value)
        
        // Validate and parse imageUrl - must be valid URL if provided
        let imageUrl: String? = {
            guard let urlText = imageUrlTextField.text, !urlText.isEmpty else {
                return nil
            }
            // Basic URL validation
            if urlText.hasPrefix("http://") || urlText.hasPrefix("https://") {
                return urlText
            }
            // If no protocol, add https://
            return "https://\(urlText)"
        }()
        
        // Ensure we have all required fields for update
        let destination = destinationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? voyage.destination
        let dateDepart = formatter.string(from: departDatePicker.date)
        let dateRetour = formatter.string(from: retourDatePicker.date)
        let selectedType = voyageTypes[typePicker.selectedRow(inComponent: 0)]
        let description = descriptionTextView.text.isEmpty ? (voyage.description ?? "") : descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let prixEstimeFinal = prixEstime ?? voyage.prix_estime ?? 0.0
        
        print("📋 [EDIT VOYAGE] Update values:")
        print("   - Destination: '\(destination)'")
        print("   - Date depart: '\(dateDepart)'")
        print("   - Date retour: '\(dateRetour)'")
        print("   - Type: '\(selectedType)'")
        print("   - Description: '\(description)' (length: \(description.count))")
        print("   - Prix estimé: \(prixEstimeFinal)")
        print("   - Nombre places: \(nombrePlaces)")
        print("   - Image URL: \(imageUrl ?? "nil")")
        
        let dto = UpdateVoyageDto(
            destination: destination,
            date_depart: dateDepart,
            date_retour: dateRetour,
            type: selectedType,
            description: description.isEmpty ? nil : description,
            prix_estime: prixEstimeFinal,
            nombre_places: nombrePlaces,
            imageUrl: imageUrl
        )
        
        // Debug: Print the DTO being sent
        print("🔄 [EDIT VOYAGE] Preparing to update voyage ID: \(voyage.id)")
        if let jsonData = try? JSONEncoder().encode(dto),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 [EDIT VOYAGE] Update DTO JSON: \(jsonString)")
        } else {
            print("⚠️ [EDIT VOYAGE] Could not encode DTO to JSON")
        }
        
        saveButton.isEnabled = false
        loadingIndicator.startAnimating()
        saveButton.setTitle("", for: .normal)
        
        Task {
            print("🚀 [EDIT VOYAGE] Starting update task...")
            do {
                let updatedVoyage = try await voyageService.updateVoyage(id: voyage.id, dto)
                print("✅ [EDIT VOYAGE] Voyage updated successfully!")
                print("   - Updated voyage ID: \(updatedVoyage.id)")
                
                // Refresh voyages list to ensure we have latest data
                print("🔄 [EDIT VOYAGE] Refreshing voyages list...")
                await voyageService.fetchVoyages()
                
                DispatchQueue.main.async {
                    print("✅ [EDIT VOYAGE] UI update - success")
                    self.loadingIndicator.stopAnimating()
                    self.saveButton.isEnabled = true
                    self.saveButton.setTitle("Enregistrer", for: .normal)
                    self.dismiss(animated: true)
                }
            } catch {
                print("❌ [EDIT VOYAGE] Error occurred:")
                print("   - Error type: \(type(of: error))")
                print("   - Error description: \(error.localizedDescription)")
                print("   - Full error: \(error)")
                
                // Extract better error message
                var errorMessage = error.localizedDescription
                
                if let networkError = error as? NetworkService.NetworkError {
                    print("   - Network error: \(networkError)")
                    errorMessage = networkError.localizedDescription
                } else if let urlError = error as? URLError {
                    print("   - URL Error code: \(urlError.code.rawValue)")
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
                    self.saveButton.isEnabled = true
                    self.saveButton.setTitle("Enregistrer", for: .normal)
                    print("❌ [EDIT VOYAGE] Showing error alert: \(errorMessage)")
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
        
        guard departTextField.text != nil, !departTextField.text!.isEmpty else {
            showErrorAlert(message: "Veuillez sélectionner une date de départ")
            return false
        }
        
        guard retourTextField.text != nil, !retourTextField.text!.isEmpty else {
            showErrorAlert(message: "Veuillez sélectionner une date de retour")
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
        
        return true
    }
    
    private func showErrorAlert(message: String) {
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
            if let _ = Int(afterError.trimmingCharacters(in: .whitespacesAndNewlines)) {
                cleanMessage = String(cleanMessage[..<range.lowerBound])
            }
        }
        
        cleanMessage = cleanMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanMessage.isEmpty || cleanMessage.count < 3 {
            cleanMessage = "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer."
        }
        
        let alert = UIAlertController(title: "Erreur", message: cleanMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDataSource & Delegate
extension EditVoyageViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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

