import UIKit

class EditPackViewController: UIViewController {
    
    // MARK: - Properties
    private let pack: Offer
    
    // MARK: - UI Components (same as CreatePackViewController)
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Text Fields - using lazy vars
    private lazy var titreField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Titre du pack *"
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }()
    
    private lazy var destinationField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Destination *"
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }()
    
    private lazy var hotelField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nom de l'hôtel *"
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }()
    
    private lazy var prixField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Prix total (DT) *"
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.keyboardType = .decimalPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }()
    
    private lazy var prixAdulteField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Prix par adulte (DT) *"
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.keyboardType = .decimalPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }()
    
    private lazy var prixEnfantField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Prix par enfant (DT) *"
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.keyboardType = .decimalPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }()
    
    private lazy var nuitsField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nombre de nuits *"
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }()
    
    private lazy var placesField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nombre de places *"
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }()
    
    // Text View
    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let descriptionPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Description du pack *"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Date Pickers
    private let dateDebutPicker = UIDatePicker()
    private let dateFinPicker = UIDatePicker()
    
    // Segmented Controls
    private let etoilesControl: UISegmentedControl = {
        let items = ["3★", "4★", "5★"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 1
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let pensionControl: UISegmentedControl = {
        let items = ["Petit-déj", "Demi-pension", "Pension complète", "All Inclusive"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 2
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let transportControl: UISegmentedControl = {
        let items = ["Avion", "Bus", "Voiture"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    // Submit Button
    private let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("💾 Enregistrer les modifications", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.backgroundColor = .systemOrange
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Init
    init(pack: Offer) {
        self.pack = pack
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Modifier le Pack"
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        setupUI()
        prefillForm()
        setupActions()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Annuler",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
    }
    
    // MARK: - Setup
   private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // Create description container
        let descContainer = UIView()
        descContainer.translatesAutoresizingMaskIntoConstraints = false
        descContainer.addSubview(descriptionTextView)
        descContainer.addSubview(descriptionPlaceholder)
        
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: descContainer.topAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: descContainer.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: descContainer.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: descContainer.bottomAnchor),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 14),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 12)
        ])
        
        // Add all form fields (simplified, reusing structure from CreatePackViewController)
        [titreField, descContainer, destinationField, prixField, prixAdulteField, prixEnfantField, 
         hotelField, nuitsField, placesField].forEach { stackView.addArrangedSubview($0) }
        
        stackView.addArrangedSubview(submitButton)
        submitButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func prefillForm() {
        titreField.text = pack.titre
        descriptionTextView.text = pack.description
        descriptionPlaceholder.isHidden = true
        destinationField.text = pack.destination
        prixField.text = String(pack.prix)
        prixAdulteField.text = String(pack.adult_price ?? pack.prix)
        prixEnfantField.text = String(pack.child_price ?? pack.prix /  2)
        hotelField.text = pack.hotel
        nuitsField.text = String(pack.nights ?? 0)
        placesField.text = String(pack.places_disponibles ?? 0)
        
        // Parse dates
        let formatter = ISO8601DateFormatter()
        if let startDate = formatter.date(from: pack.date_debut) {
            dateDebutPicker.date = startDate
        }
        if let endDate = formatter.date(from: pack.date_fin) {
            dateFinPicker.date = endDate
        }
    }
    
    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        descriptionTextView.delegate = self
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func submitTapped() {
        guard let packId = pack.id else { return }
        guard validateForm() else { return }
        
        loadingIndicator.startAnimating()
        submitButton.isEnabled = false
        
        Task {
            do {
                let dto = createUpdateDTO()
                let updatedPack = try await PackService.shared.updatePack(id: packId, dto)
                
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.submitButton.isEnabled = true
                    
                    let alert = UIAlertController(
                        title: "✅ Pack modifié!",
                        message: "Le pack a été mis à jour avec succès.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.dismiss(animated: true)
                    })
                    self.present(alert, animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.submitButton.isEnabled = true
                    self.showError("Impossible de modifier le pack: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func validateForm() -> Bool {
        guard !titreField.text.isNilOrEmpty else {
            showError("Veuillez entrer un titre")
            return false
        }
        guard !descriptionTextView.text.isEmpty else {
            showError("Veuillez entrer une description")
            return false
        }
        return true
    }
    
    private func createUpdateDTO() -> UpdateOfferDto {
        return UpdateOfferDto(
            titre: titreField.text,
            description: descriptionTextView.text.isEmpty ? nil : descriptionTextView.text,
            prix: Double(prixField.text ?? "0"),
            date_debut: ISO8601DateFormatter().string(from: dateDebutPicker.date),
            date_fin: ISO8601DateFormatter().string(from: dateFinPicker.date),
            destination: destinationField.text,
            images: nil,
            hotel: hotelField.text,
            nights: Int(nuitsField.text ?? "0"),
            included_activities: nil,
            places_to_visit: nil,
            transport: nil,
            price_per_person: Double(prixField.text ?? "0"),
            child_price: Double(prixEnfantField.text ?? "0"),
            adult_price: Double(prixAdulteField.text ?? "0"),
            hotel_stars: nil,
            meal_type: nil
        )
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension EditPackViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
    }
}
