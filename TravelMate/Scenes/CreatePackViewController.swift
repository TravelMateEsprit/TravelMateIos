import UIKit
import PhotosUI

class CreatePackViewController: UIViewController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    private var selectedImages: [UIImage] = []
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = true
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Text Fields
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
    
    // Image Upload
    private let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGray6
        cv.layer.cornerRadius = 8
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        return cv
    }()
    
    private let addImageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("📸 Ajouter des photos", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // Submit Button
    private let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("✅ Créer le Pack", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.backgroundColor = .systemGreen
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Créer un Pack"
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        setupUI()
        setupActions()
        setupDelegates()
        
        // Cancel button
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
        
        // Add all form fields
        stackView.addArrangedSubview(createSection(title: "Informations générales", views: [
            titreField,
            descriptionContainer(),
            destinationField
        ]))
        
        stackView.addArrangedSubview(createSection(title: "Dates", views: [
            createDateField(label: "Date de début *", picker: dateDebutPicker),
            createDateField(label: "Date de fin *", picker: dateFinPicker)
        ]))
        
        stackView.addArrangedSubview(createSection(title: "Prix", views: [
            prixField,
            prixAdulteField,
            prixEnfantField
        ]))
        
        stackView.addArrangedSubview(createSection(title: "Hébergement", views: [
            hotelField,
            createLabeledControl(label: "Étoiles de l'hôtel *", control: etoilesControl),
            nuitsField
        ]))
        
        stackView.addArrangedSubview(createSection(title: "Services", views: [
            createLabeledControl(label: "Type de pension *", control: pensionControl),
            createLabeledControl(label: "Transport *", control: transportControl),
            placesField
        ]))
        
        stackView.addArrangedSubview(createSection(title: "Photos", views: [
            addImageButton,
            imageCollectionView
        ]))
        
        imageCollectionView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        
        stackView.addArrangedSubview(submitButton)
        submitButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        addImageButton.addTarget(self, action: #selector(addImageTapped), for: .touchUpInside)
        descriptionTextView.delegate = self
    }
    
    private func setupDelegates() {
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
        dateDebutPicker.datePickerMode = .date
        dateFinPicker.datePickerMode = .date
        dateDebutPicker.minimumDate = Date()
        dateFinPicker.minimumDate = Date()
    }
    
    private func createSection(title: String, views: [UIView]) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.05
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func descriptionContainer() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(descriptionTextView)
        container.addSubview(descriptionPlaceholder)
        
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: container.topAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 14),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 12)
        ])
        
        return container
    }
    
    private func createDateField(label labelText: String, picker: UIDatePicker) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = labelText
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        container.addSubview(picker)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            picker.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    private func createLabeledControl(label: String, control: UIControl) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 14, weight: .medium)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(labelView)
        container.addSubview(control)
        
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: container.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            labelView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            control.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 8),
            control.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            control.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            control.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func addImageTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func submitTapped() {
        // Debug: Check authentication
        print("🔐 [CREATE PACK] Checking authentication...")
        print("   - Is authenticated: \(AuthService.shared.isAuthenticated)")
        print("   - Has token: \(AuthService.shared.accessToken != nil)")
        print("   - Current user: \(AuthService.shared.currentUser?.name ?? "nil")")
        print("   - User type: \(AuthService.shared.currentUser?.userType.rawValue ?? "nil")")
        
        guard AuthService.shared.isAuthenticated else {
            showError("Vous devez être connecté pour créer un pack")
            return
        }
        
        guard validateForm() else { return }
        
        loadingIndicator.startAnimating()
        submitButton.isEnabled = false
        
        Task {
            do {
                let dto = createPackDTO()
                print("📦 [CREATE PACK] Sending request...")
                let newPack = try await PackService.shared.createPack(dto)
                
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.submitButton.isEnabled = true
                    
                    let alert = UIAlertController(
                        title: "✅ Pack créé!",
                        message: "Le pack \"\(newPack.titre)\" a été créé avec succès.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.dismiss(animated: true)
                    })
                    self.present(alert, animated: true)
                }
            } catch {
                print("❌ [CREATE PACK] Error: \(error)")
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.submitButton.isEnabled = true
                    self.showError("Impossible de créer le pack: \(error.localizedDescription)")
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
        guard !destinationField.text.isNilOrEmpty else {
            showError("Veuillez entrer une destination")
            return false
        }
        guard !prixField.text.isNilOrEmpty, let _ = Double(prixField.text!) else {
            showError("Veuillez entrer un prix valide")
            return false
        }
        
        return true
    }
    
    private func createPackDTO() -> CreateOfferDto {
        let starIndex = etoilesControl.selectedSegmentIndex + 3  // 3,4,5 stars
        let mealTypes = ["Petit-déjeuner", "Demi-pension", "Pension complète", "All Inclusive"]
        let meal = mealTypes[pensionControl.selectedSegmentIndex]
        let transportOptions = ["Avion", "Bus", "Voiture"]
        let transportType = transportOptions[transportControl.selectedSegmentIndex]
        
        return CreateOfferDto(
            titre: titreField.text ?? "",
            description: descriptionTextView.text,
            prix: Double(prixField.text ?? "0") ?? 0,
            date_debut: ISO8601DateFormatter().string(from: dateDebutPicker.date),
            date_fin: ISO8601DateFormatter().string(from: dateFinPicker.date),
            destination: destinationField.text,
            images: [],
            hotel: hotelField.text,
            nights: Int(nuitsField.text ?? "0"),
            included_activities: nil,
            places_to_visit: nil,
            transport: transportType,
            price_per_person: Double(prixField.text ?? "0"),
            child_price: Double(prixEnfantField.text ?? "0"),
            adult_price: Double(prixAdulteField.text ?? "0"),
            hotel_stars: starIndex,
            meal_type: meal
        )
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self?.selectedImages.append(image)
                        self?.imageCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - UITextViewDelegate
extension CreatePackViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension CreatePackViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.configure(with: selectedImages[indexPath.item])
        return cell
    }
}

// MARK: - Image Cell
class ImageCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
}

// MARK: - String Extension
extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}
