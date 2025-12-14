import UIKit

class PackDetailViewController: UIViewController {

    private let offer: Offer
    
    // Check if current user is the agency that owns this pack
    private var isAgencyOwner: Bool {
        guard let currentUser = AuthService.shared.currentUser,
              currentUser.userType == .agence else {
            return false
        }
        return offer.id_agence == currentUser.id
    }
    
    // MARK: - Booking quantities
    private var adults: Int = 1
    private var childrenCount: Int = 0
    
    private var totalPrice: Double {
        return Double(adults) * offer.baseAdultPrice
             + Double(childrenCount) * offer.baseChildPrice
    }

    // MARK: - Favorite
    private var isFavorite: Bool {
        get { FavoritesManager.shared.isFavorite(id: offer.id ?? "") }
        set {
            if newValue { FavoritesManager.shared.addFavorite(offer) }
            else { FavoritesManager.shared.removeFavorite(id: offer.id ?? "") }
            updateFavoriteIcon()
        }
    }

    // MARK: UI
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let infoCard = UIStackView()
    private let detailCard = UIStackView()
    private let travelerCard = UIStackView()
    private let totalCard = UIStackView()
    
    private let hotelLabel = UILabel()
    private let nightsLabel = UILabel()
    private let mealLabel = UILabel()
    private let dateLabel = UILabel()
    private let transportLabel = UILabel()
    private let activitiesLabel = UILabel()
    private let placesLabel = UILabel()
    private let totalPriceLabel = UILabel()

    // USER Buttons
    private let favoriteButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("⭐️ Favoris", for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 14)
        b.backgroundColor = .favoriteColor.withAlphaComponent(0.2)
        b.setTitleColor(.favoriteColor, for: .normal)
        b.layer.cornerRadius = 12
        b.layer.borderWidth = 1.5
        b.layer.borderColor = UIColor.favoriteColor.withAlphaComponent(0.3).cgColor
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let chatButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("💬 Discuter", for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 14)
        b.backgroundColor = .primaryColor.withAlphaComponent(0.2)
        b.setTitleColor(.primaryColor, for: .normal)
        b.layer.cornerRadius = 12
        b.layer.borderWidth = 1.5
        b.layer.borderColor = UIColor.primaryColor.withAlphaComponent(0.3).cgColor
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let reserveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("🛒 Réserver", for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 14)
        b.backgroundColor = .successColor.withAlphaComponent(0.2)
        b.setTitleColor(.successColor, for: .normal)
        b.layer.cornerRadius = 12
        b.layer.borderWidth = 1.5
        b.layer.borderColor = UIColor.successColor.withAlphaComponent(0.3).cgColor
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // AGENCY Buttons
    private let modifierButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("✏️ Modifier", for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 16)
        b.backgroundColor = .systemOrange
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let supprimerButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("🗑 Supprimer", for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 16)
        b.backgroundColor = .systemRed
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // Traveler pickers
    private let adultsLabel = UILabel()
    private let childrenLabel = UILabel()
    private let adultsStepper = UIStepper()
    private let childrenStepper = UIStepper()

    init(offer: Offer) {
        self.offer = offer
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLight

        title = "Détails du pack"
        setupFavoriteButton()
        setupUI()
        fillData()
    }

    // MARK: - Favorite Star
    private func setupFavoriteButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: isFavorite ? "heart.fill" : "heart"),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )
        navigationItem.rightBarButtonItem?.tintColor = .favoriteColor
    }

    @objc private func toggleFavorite() {
        // Toggle favorite using local storage
        if isFavorite {
            if let packId = offer.id {
                FavoritesManager.shared.removeFavorite(id: packId)
            }
        } else {
            FavoritesManager.shared.addFavorite(offer)
        }
        updateFavoriteIcon()
        
        // Navigate to favorites tab
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 2 // Favorites tab
            }
        }
    }

    private func updateFavoriteIcon() {
        navigationItem.rightBarButtonItem?.image =
            UIImage(systemName: isFavorite ? "heart.fill" : "heart")
        
        // Animate the icon change
        if let button = navigationItem.rightBarButtonItem {
            UIView.animate(withDuration: 0.2) {
                button.tintColor = self.isFavorite ? .favoriteFilledColor : .favoriteColor
            }
        }
    }

    // MARK: UI Setup
    private func setupUI() {
        
        // Create fixed footer for buttons
        let footerContainer = UIView()
        footerContainer.backgroundColor = .cardBackground
        footerContainer.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.addElevatedShadow()
        
        // Scroll container
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        view.addSubview(footerContainer) // Add footer after scroll so it's on top

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 20
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: footerContainer.topAnchor), // Stop before footer
            
            content.topAnchor.constraint(equalTo: scroll.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scroll.widthAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -20) // Add bottom padding
        ])
        
        // HEADER IMAGE with gradient overlay
        let imageContainer = UIView()
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Gradient overlay
        let gradientOverlay = UIView()
        gradientOverlay.translatesAutoresizingMaskIntoConstraints = false
        gradientOverlay.backgroundColor = .clear
        
        imageContainer.addSubview(imageView)
        imageContainer.addSubview(gradientOverlay)
        
        // Add gradient after layout
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            gradientOverlay.addGradient(
                colors: [UIColor.clear, UIColor.black.withAlphaComponent(0.4)],
                startPoint: CGPoint(x: 0.5, y: 0.3),
                endPoint: CGPoint(x: 0.5, y: 1)
            )
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            
            gradientOverlay.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            gradientOverlay.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            gradientOverlay.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor)
        ])
        
        imageContainer.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        // TITLE with better styling
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .textPrimary
        
        // CARDS with enhanced styling
        styleCard(infoCard)
        styleCard(detailCard)
        styleCard(travelerCard)
        styleCard(totalCard)

        content.addArrangedSubview(imageContainer)
        content.addArrangedSubview(padded(titleLabel))
        
        // HOTEL INFO CARD with icons
        let hotelStack = createInfoRow(icon: "building.2.fill", label: hotelLabel, color: .secondaryColor)
        let nightsStack = createInfoRow(icon: "moon.stars.fill", label: nightsLabel, color: .systemIndigo)
        let mealStack = createInfoRow(icon: "fork.knife", label: mealLabel, color: .systemOrange)
        let dateStack = createInfoRow(icon: "calendar", label: dateLabel, color: .systemRed)
        
        infoCard.addArrangedSubview(hotelStack)
        infoCard.addArrangedSubview(nightsStack)
        infoCard.addArrangedSubview(mealStack)
        infoCard.addArrangedSubview(dateStack)
        content.addArrangedSubview(infoCard)

        // TRANSPORT + ACTIVITIES + PLACES
        detailCard.addArrangedSubview(sectionTitle("✈️ Transport"))
        detailCard.addArrangedSubview(line(transportLabel))
        
        detailCard.addArrangedSubview(sectionTitle("🎟 Activités incluses"))
        detailCard.addArrangedSubview(line(activitiesLabel))
        
        detailCard.addArrangedSubview(sectionTitle("🗺 Lieux à visiter"))
        detailCard.addArrangedSubview(line(placesLabel))
        
        content.addArrangedSubview(detailCard)
        
        // TRAVELERS SECTION (only for users)
        if !isAgencyOwner {
            buildTravelerSection()
            content.addArrangedSubview(travelerCard)
            
            // TOTAL CARD
            totalPriceLabel.font = .boldSystemFont(ofSize: 22)
            totalPriceLabel.textColor = .systemGreen
            totalCard.addArrangedSubview(line(totalPriceLabel))
            content.addArrangedSubview(totalCard)
        }
        
        // STICKY FOOTER BUTTONS (role-based)
        if isAgencyOwner {
            // Agency buttons in footer
            let btnStack = UIStackView(arrangedSubviews: [modifierButton, supprimerButton])
            btnStack.axis = .horizontal
            btnStack.distribution = .fillEqually
            btnStack.spacing = 14
            btnStack.translatesAutoresizingMaskIntoConstraints = false
            
            footerContainer.addSubview(btnStack)
            
            NSLayoutConstraint.activate([
                footerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                footerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                footerContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                footerContainer.heightAnchor.constraint(equalToConstant: 86),
                
                btnStack.topAnchor.constraint(equalTo: footerContainer.topAnchor, constant: 12),
                btnStack.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 16),
                btnStack.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor, constant: -16),
                btnStack.bottomAnchor.constraint(equalTo: footerContainer.bottomAnchor, constant: -12)
            ])
            
            modifierButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            supprimerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            modifierButton.addTarget(self, action: #selector(modifierPressed), for: .touchUpInside)
            supprimerButton.addTarget(self, action: #selector(supprimerPressed), for: .touchUpInside)
        } else {
            // User buttons in footer - 3 buttons: Favoris, Discuter, Réserver
            let btnStack = UIStackView(arrangedSubviews: [favoriteButton, chatButton, reserveButton])
            btnStack.axis = .horizontal
            btnStack.distribution = .fillEqually
            btnStack.spacing = 10
            btnStack.translatesAutoresizingMaskIntoConstraints = false
            
            footerContainer.addSubview(btnStack)
            
            NSLayoutConstraint.activate([
                footerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                footerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                footerContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                footerContainer.heightAnchor.constraint(equalToConstant: 86),
                
                btnStack.topAnchor.constraint(equalTo: footerContainer.topAnchor, constant: 12),
                btnStack.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 16),
                btnStack.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor, constant: -16),
                btnStack.bottomAnchor.constraint(equalTo: footerContainer.bottomAnchor, constant: -12)
            ])
            
            favoriteButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            chatButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            reserveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
            favoriteButton.addPressAnimation()
            chatButton.addTarget(self, action: #selector(chatPressed), for: .touchUpInside)
            chatButton.addPressAnimation()
            reserveButton.addTarget(self, action: #selector(reservePressed), for: .touchUpInside)
            reserveButton.addPressAnimation()
        }
    }

    private func styleCard(_ card: UIStackView) {
        card.axis = .vertical
        card.spacing = 10
        card.backgroundColor = .cardBackground
        card.layer.cornerRadius = 16
        card.addCardShadow()
        card.isLayoutMarginsRelativeArrangement = true
        card.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
    }

    private func line(_ label: UILabel) -> UIView {
        label.numberOfLines = 0
        let v = UIView()
        v.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: v.topAnchor),
            label.bottomAnchor.constraint(equalTo: v.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: v.trailingAnchor)
        ])
        return v
    }

    private func padded(_ view: UIView) -> UIView {
        let container = UIView()
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        ])
        return container
    }

    
    private func createInfoRow(icon: String, label: UILabel, color: UIColor) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .textPrimary
        
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        
        return stack
    }

    private func sectionTitle(_ title: String) -> UILabel {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 19)
        lbl.text = title
        return lbl
    }

    // MARK: - Travelers
    private func buildTravelerSection() {
        let adultRow = row(
            label: adultsLabel,
            stepper: adultsStepper,
            title: "Adultes",
            value: adults
        )
        
        let childRow = row(
            label: childrenLabel,
            stepper: childrenStepper,
            title: "Enfants",
            value: childrenCount
        )
        
        travelerCard.addArrangedSubview(adultRow)
        travelerCard.addArrangedSubview(childRow)
    }

    private func row(label: UILabel, stepper: UIStepper, title: String, value: Int) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        let valueLabel = label
        valueLabel.text = "\(value)"
        valueLabel.font = .systemFont(ofSize: 16)
        
        stepper.value = Double(value)
        stepper.minimumValue = (title == "Adultes" ? 1 : 0)
        stepper.addTarget(self, action: #selector(updateTravelers), for: .valueChanged)
        
        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel, stepper])
        row.axis = .horizontal
        row.distribution = .equalSpacing
        return row
    }

    @objc private func updateTravelers() {
        adults = Int(adultsStepper.value)
        childrenCount = Int(childrenStepper.value)
        
        adultsLabel.text = "\(adults)"
        childrenLabel.text = "\(childrenCount)"
        totalPriceLabel.text = "Total : \(totalPrice) DT"
    }

    // MARK: Fill data
    private func fillData() {
        titleLabel.text = offer.titre
        
        hotelLabel.text = "🏨 \(offer.hotelDisplayName) \(offer.hotelStarsText)"
        nightsLabel.text = "🛏 \(offer.nightsText)"
        mealLabel.text = "🍽 \(offer.mealTypeText)"
        dateLabel.text = "📅 \(offer.formattedStartDate) → \(offer.formattedEndDate)"
        transportLabel.text = offer.transportDisplay
        
        activitiesLabel.text = offer.activitiesListString
        placesLabel.text = offer.placesListString
        
        totalPriceLabel.text = "Total : \(totalPrice) DT"
        
        if let url = offer.firstImageURL {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async { self.imageView.image = UIImage(data: data) }
                }
            }.resume()
        }
    }

    // MARK: Actions
    @objc private func favoriteButtonPressed() {
        toggleFavorite()
        
        // Update button appearance
        if isFavorite {
            favoriteButton.setTitle("⭐️ Favoris", for: .normal)
            favoriteButton.backgroundColor = .favoriteFilledColor.withAlphaComponent(0.3)
        } else {
            favoriteButton.setTitle("⭐️ Favoris", for: .normal)
            favoriteButton.backgroundColor = .favoriteColor.withAlphaComponent(0.2)
        }
        
        // Show feedback and navigate to favorites
        let message = isFavorite ? "Ajouté aux favoris ✅" : "Retiré des favoris"
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            alert.dismiss(animated: true) {
                // Navigate to favorites tab
                if let tabBarController = self.tabBarController {
                    tabBarController.selectedIndex = 2 // Favorites tab
                }
            }
        }
    }
    
    @objc private func chatPressed() {
        navigationController?.pushViewController(ChatViewController(offer: offer), animated: true)
    }

    @objc private func reservePressed() {
        // Create reservation via API
        guard let packId = offer.id else { return }
        
        Task {
            do {
                let reservation = try await ReservationService.shared.createReservation(
                    packId: packId,
                    adultsCount: adults,
                    childrenCount: childrenCount,
                    totalPrice: totalPrice
                )
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Réservation envoyée 🎉",
                        message: "Votre réservation pour \(self.adults) adulte(s) + \(self.childrenCount) enfant(s) a été envoyée.\n\nStatut: \(reservation.status.displayName)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            } catch {
                print("❌ Failed to create reservation: \(error)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Erreur",
                        message: "Impossible de créer la réservation. Veuillez réessayer.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    // MARK: - Agency Actions
    
    @objc private func modifierPressed() {
        let editVC = EditPackViewController(pack: offer)
        let navController = UINavigationController(rootViewController: editVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func supprimerPressed() {
        guard let packId = offer.id else { return }
        
        let confirmAlert = UIAlertController(
            title: "Supprimer ce pack ?",
            message: "Cette action est irréversible.",
            preferredStyle: .alert
        )
        
        confirmAlert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "Supprimer", style: .destructive) { _ in
            Task {
                do {
                    try await PackService.shared.deletePack(id: packId)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch {
                    print("❌ Failed to delete pack: \(error)")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(
                            title: "Erreur",
                            message: "Impossible de supprimer le pack.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        })
        
        present(confirmAlert, animated: true)
    }
}
