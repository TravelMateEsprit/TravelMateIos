import UIKit

class InsuranceApplicationFormViewController: UIViewController {
    
    private let insurance: Insurance
    private let insuranceService = InsuranceService.shared
    
    private var currentStep = 1
    private let totalSteps = 3
    
    // Form Data
    private var fullName = ""
    private var email = ""
    private var phone = ""
    private var dateOfBirth: Date?
    private var departureDate: Date?
    private var arrivalDate: Date?
    private var destination = ""
    private var travelReason: TravelReason = .tourism
    private var customTravelReason = ""
    private var passportNumber = ""
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = .primaryColor
        progress.trackTintColor = UIColor.primaryColor.withAlphaComponent(0.2)
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        progress.layer.sublayers?[1].cornerRadius = 4
        progress.subviews[1].clipsToBounds = true
        return progress
    }()
    
    private let stepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .primaryColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let formStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .primaryColor
        button.setTitle("Suivant", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGray5
        button.setTitle("Retour", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .primaryColor
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    init(insurance: Insurance) {
        self.insurance = insurance
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStep1()
        updateProgress()
        
        // Pré-remplir avec les données utilisateur si disponibles
        if let user = AuthService.shared.currentUser {
            email = user.email
        }
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "Demande d'assurance"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Annuler",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(progressView)
        contentView.addSubview(stepLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(formStackView)
        contentView.addSubview(backButton)
        contentView.addSubview(nextButton)
        view.addSubview(loadingIndicator)
        
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
            
            progressView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            stepLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 12),
            stepLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stepLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            formStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            formStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            formStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            backButton.topAnchor.constraint(equalTo: formStackView.bottomAnchor, constant: 30),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            backButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            backButton.heightAnchor.constraint(equalToConstant: 54),
            
            nextButton.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            nextButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 54),
            nextButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        // Hide keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Step 1: Informations Personnelles
    
    private func setupStep1() {
        titleLabel.text = "Informations personnelles"
        subtitleLabel.text = "Veuillez renseigner vos informations personnelles"
        
        formStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let nameField = createTextField(placeholder: "Nom complet *", text: fullName)
        nameField.tag = 101
        
        let emailField = createTextField(placeholder: "Email *", text: email, keyboardType: .emailAddress)
        emailField.tag = 102
        
        let phoneField = createTextField(placeholder: "Téléphone *", text: phone, keyboardType: .phonePad)
        phoneField.tag = 103
        
        let dobPicker = createDatePicker(
            label: "Date de naissance *",
            selectedDate: dateOfBirth,
            maximumDate: Date(),
            tag: 104
        )
        
        formStackView.addArrangedSubview(nameField)
        formStackView.addArrangedSubview(emailField)
        formStackView.addArrangedSubview(phoneField)
        formStackView.addArrangedSubview(dobPicker)
        
        backButton.isHidden = true
        nextButton.setTitle("Suivant", for: .normal)
    }
    
    // MARK: - Step 2: Informations de Voyage
    
    private func setupStep2() {
        titleLabel.text = "Informations de voyage"
        subtitleLabel.text = "Renseignez les détails de votre voyage"
        
        formStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let departurePicker = createDatePicker(
            label: "Date de départ *",
            selectedDate: departureDate,
            minimumDate: Date(),
            tag: 201
        )
        
        let arrivalPicker = createDatePicker(
            label: "Date d'arrivée *",
            selectedDate: arrivalDate,
            minimumDate: departureDate ?? Date(),
            tag: 202
        )
        
        let destinationField = createTextField(placeholder: "Destination *", text: destination)
        destinationField.tag = 203
        
        formStackView.addArrangedSubview(departurePicker)
        formStackView.addArrangedSubview(arrivalPicker)
        formStackView.addArrangedSubview(destinationField)
        
        backButton.isHidden = false
        nextButton.setTitle("Suivant", for: .normal)
    }
    
    // MARK: - Step 3: Informations Complémentaires
    
    private func setupStep3() {
        titleLabel.text = "Informations complémentaires"
        subtitleLabel.text = "Dernières informations avant l'envoi"
        
        formStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let reasonPicker = createTravelReasonPicker(selectedReason: travelReason)
        reasonPicker.tag = 301
        
        let passportField = createTextField(placeholder: "Numéro de passeport *", text: passportNumber)
        passportField.tag = 302
        
        formStackView.addArrangedSubview(reasonPicker)
        
        // Add custom reason field if "other" is selected
        if travelReason == .other {
            let customReasonField = createTextField(placeholder: "Précisez le motif *", text: customTravelReason)
            customReasonField.tag = 303
            formStackView.addArrangedSubview(customReasonField)
        }
        
        formStackView.addArrangedSubview(passportField)
        
        backButton.isHidden = false
        nextButton.setTitle("Envoyer la demande", for: .normal)
    }
    
    // MARK: - Helper Methods
    
    private func createTextField(placeholder: String, text: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .none
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 50))
        textField.leftViewMode = .always
        textField.delegate = self
        return textField
    }
    
    private func createDatePicker(label: String, selectedDate: Date?, minimumDate: Date? = nil, maximumDate: Date? = nil, tag: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        labelView.textColor = .darkGray
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = selectedDate ?? Date()
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        datePicker.tag = tag
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        container.addSubview(labelView)
        container.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: container.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            
            datePicker.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        return container
    }
    
    private func createTravelReasonPicker(selectedReason: TravelReason) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let labelView = UILabel()
        labelView.text = "Motif du voyage *"
        labelView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        labelView.textColor = .darkGray
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let picker = UIPickerView()
        picker.tag = 301
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        // Select current reason
        if let index = TravelReason.allCases.firstIndex(of: selectedReason) {
            picker.selectRow(index, inComponent: 0, animated: false)
        }
        
        container.addSubview(labelView)
        container.addSubview(picker)
        
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: container.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            
            picker.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 8),
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            picker.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            picker.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        return container
    }
    
    private func updateProgress() {
        let progress = Float(currentStep) / Float(totalSteps)
        progressView.setProgress(progress, animated: true)
        stepLabel.text = "Étape \(currentStep) sur \(totalSteps)"
    }
    
    private func saveStep1Data() {
        if let nameField = view.viewWithTag(101) as? UITextField {
            fullName = nameField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        }
        if let emailField = view.viewWithTag(102) as? UITextField {
            email = emailField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        }
        if let phoneField = view.viewWithTag(103) as? UITextField {
            phone = phoneField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        }
    }
    
    private func saveStep2Data() {
        if let destField = view.viewWithTag(203) as? UITextField {
            destination = destField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        }
    }
    
    private func saveStep3Data() {
        if let passportField = view.viewWithTag(302) as? UITextField {
            passportNumber = passportField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        }
        if travelReason == .other {
            if let customField = view.viewWithTag(303) as? UITextField {
                customTravelReason = customField.text?.trimmingCharacters(in: .whitespaces) ?? ""
            }
        }
    }
    
    private func validateStep1() -> Bool {
        saveStep1Data()
        
        guard !fullName.isEmpty else {
            showAlert(message: "Veuillez entrer votre nom complet")
            return false
        }
        
        guard !email.isEmpty, email.contains("@") else {
            showAlert(message: "Veuillez entrer une adresse email valide")
            return false
        }
        
        guard !phone.isEmpty else {
            showAlert(message: "Veuillez entrer votre numéro de téléphone")
            return false
        }
        
        guard dateOfBirth != nil else {
            showAlert(message: "Veuillez sélectionner votre date de naissance")
            return false
        }
        
        return true
    }
    
    private func validateStep2() -> Bool {
        saveStep2Data()
        
        guard departureDate != nil else {
            showAlert(message: "Veuillez sélectionner la date de départ")
            return false
        }
        
        guard arrivalDate != nil else {
            showAlert(message: "Veuillez sélectionner la date d'arrivée")
            return false
        }
        
        if let departure = departureDate, let arrival = arrivalDate {
            guard arrival > departure else {
                showAlert(message: "La date d'arrivée doit être après la date de départ")
                return false
            }
        }
        
        guard !destination.isEmpty else {
            showAlert(message: "Veuillez entrer votre destination")
            return false
        }
        
        return true
    }
    
    private func validateStep3() -> Bool {
        saveStep3Data()
        
        if travelReason == .other {
            guard !customTravelReason.isEmpty else {
                showAlert(message: "Veuillez préciser le motif de votre voyage")
                return false
            }
        }
        
        guard !passportNumber.isEmpty else {
            showAlert(message: "Veuillez entrer votre numéro de passeport")
            return false
        }
        
        return true
    }
    
    // MARK: - Actions
    
    @objc private func nextTapped() {
        switch currentStep {
        case 1:
            if validateStep1() {
                currentStep = 2
                setupStep2()
                updateProgress()
                scrollView.setContentOffset(.zero, animated: true)
            }
        case 2:
            if validateStep2() {
                currentStep = 3
                setupStep3()
                updateProgress()
                scrollView.setContentOffset(.zero, animated: true)
            }
        case 3:
            if validateStep3() {
                submitApplication()
            }
        default:
            break
        }
    }
    
    @objc private func backTapped() {
        if currentStep > 1 {
            currentStep -= 1
            switch currentStep {
            case 1:
                setupStep1()
            case 2:
                setupStep2()
            default:
                break
            }
            updateProgress()
            scrollView.setContentOffset(.zero, animated: true)
        }
    }
    
    @objc private func cancelTapped() {
        let alert = UIAlertController(
            title: "Annuler la demande",
            message: "Êtes-vous sûr de vouloir annuler? Toutes les données saisies seront perdues.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Non", style: .cancel))
        alert.addAction(UIAlertAction(title: "Oui", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        switch sender.tag {
        case 104:
            dateOfBirth = sender.date
        case 201:
            departureDate = sender.date
            // Update arrival date minimum
            if let arrivalPicker = view.viewWithTag(202) as? UIDatePicker {
                arrivalPicker.minimumDate = sender.date
                if let arrival = arrivalDate, arrival <= sender.date {
                    arrivalDate = Calendar.current.date(byAdding: .day, value: 1, to: sender.date)
                    arrivalPicker.date = arrivalDate!
                }
            }
        case 202:
            arrivalDate = sender.date
        default:
            break
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Submit Application
    
    private func submitApplication() {
        guard let dob = dateOfBirth,
              let departure = departureDate,
              let arrival = arrivalDate else {
            print("❌ Missing required dates")
            return
        }
        
        let dateFormatter = ISO8601DateFormatter()
        
        let request = CreateInsuranceApplicationRequest(
            fullName: fullName,
            email: email,
            phone: phone,
            dateOfBirth: dateFormatter.string(from: dob),
            departureDate: dateFormatter.string(from: departure),
            arrivalDate: dateFormatter.string(from: arrival),
            destination: destination,
            travelReason: travelReason,
            customTravelReason: travelReason == .other ? customTravelReason : nil,
            passportNumber: passportNumber
        )
        
        print("🚀 Submitting insurance application:")
        print("   Insurance ID: \(insurance.id)")
        print("   Full Name: \(fullName)")
        print("   Email: \(email)")
        print("   Destination: \(destination)")
        
        loadingIndicator.startAnimating()
        nextButton.isEnabled = false
        backButton.isEnabled = false
        
        Task {
            do {
                print("📤 Calling submitApplication API...")
                let result = try await insuranceService.submitApplication(insuranceId: insurance.id, request: request)
                print("✅ Application submitted successfully: \(result.id)")
                
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    nextButton.isEnabled = true
                    backButton.isEnabled = true
                    
                    let alert = UIAlertController(
                        title: "✅ Demande envoyée!",
                        message: "Votre demande d'assurance a été envoyée avec succès. L'agence va la examiner sous peu.",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                        self?.navigationController?.popViewController(animated: true)
                    })
                    
                    present(alert, animated: true)
                }
            } catch {
                print("❌ Failed to submit application: \(error)")
                print("   Error type: \(type(of: error))")
                print("   Error description: \(error.localizedDescription)")
                
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    nextButton.isEnabled = true
                    backButton.isEnabled = true
                    showAlert(message: "Erreur lors de l'envoi: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension InsuranceApplicationFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIPickerViewDelegate & DataSource

extension InsuranceApplicationFormViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TravelReason.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return TravelReason.allCases[row].displayName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedReason = TravelReason.allCases[row]
        if selectedReason != travelReason {
            travelReason = selectedReason
            // Refresh step 3 to show/hide custom reason field
            if currentStep == 3 {
                setupStep3()
            }
        }
    }
}
