import UIKit

class PacksBrowseViewController: UIViewController {
    
    private var packs: [Offer] = []
    private var currentIndex = 0
    
    private let cardContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Aucun pack disponible\n\n✈️ Revenez plus tard pour découvrir de nouvelles destinations!"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .primaryColor
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Découvrir les packs"
        view.backgroundColor = .backgroundLight
        
        setupNavigationBar()
        setupUI()
        fetchPacks()
    }
    
    private func setupNavigationBar() {
        // Chat/Messages button
        let chatButton = UIBarButtonItem(
            image: UIImage(systemName: "message.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(openMessages)
        )
        chatButton.tintColor = .primaryColor
        
        // Favorites button
        let favoritesButton = UIBarButtonItem(
            image: UIImage(systemName: "heart.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(openFavorites)
        )
        favoritesButton.tintColor = .favoriteColor
        
        navigationItem.rightBarButtonItems = [chatButton, favoritesButton]
    }
    
    @objc private func openMessages() {
        let messagesVC = ConversationsListViewController()
        navigationController?.pushViewController(messagesVC, animated: true)
    }
    
    @objc private func openFavorites() {
        // Navigate to favorites tab immediately
        if let tabBarController = tabBarController {
            tabBarController.selectedIndex = 2 // Favorites tab
        }
    }
    
    private func setupUI() {
        view.addSubview(cardContainerView)
        view.addSubview(emptyStateLabel)
        view.addSubview(loadingIndicator)
        
        // Make card container full screen
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchPacks() {
        loadingIndicator.startAnimating()
        
        Task {
            do {
                let allPacks = try await PackService.shared.getAllPacks()
                // Filter only active packs
                self.packs = allPacks.filter { $0.actif == true }
                
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    if self.packs.isEmpty {
                        self.emptyStateLabel.isHidden = false
                    } else {
                        self.showCurrentCard()
                    }
                }
            } catch {
                print("❌ Failed to fetch packs: \(error)")
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.emptyStateLabel.isHidden = false
                }
            }
        }
    }
    
    private func showCurrentCard() {
        // Clear previous cards
        cardContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        guard currentIndex < packs.count else {
            // No more packs
            emptyStateLabel.text = "Plus de packs à découvrir! 🎉\n\nVous avez vu tous les packs disponibles"
            emptyStateLabel.isHidden = false
            return
        }
        
        let pack = packs[currentIndex]
        let cardView = createPackCard(for: pack)
        cardContainerView.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor)
        ])
        
        // Add swipe gestures
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        leftSwipe.direction = .left
        cardView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        rightSwipe.direction = .right
        cardView.addGestureRecognizer(rightSwipe)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        cardView.addGestureRecognizer(tapGesture)
    }
    
    private func createPackCard(for pack: Offer) -> UIView {
        let card = UIView()
        card.backgroundColor = .cardBackground
        card.layer.cornerRadius = 24
        card.addCardShadow()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.isUserInteractionEnabled = true
        
        // Image container with gradient overlay
        let imageContainer = UIView()
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.layer.cornerRadius = 24
        imageContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageContainer.clipsToBounds = true
        
        // Image
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Placeholder
        let placeholderLabel = UILabel()
        placeholderLabel.text = "📸"
        placeholderLabel.font = .systemFont(ofSize: 60)
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        if let url = pack.firstImageURL {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                        placeholderLabel.isHidden = true
                    }
                }
            }.resume()
        }
        
        // Gradient overlay on image
        let gradientOverlay = UIView()
        gradientOverlay.translatesAutoresizingMaskIntoConstraints = false
        gradientOverlay.backgroundColor = .clear
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            gradientOverlay.addGradient(
                colors: [UIColor.clear, UIColor.black.withAlphaComponent(0.3)],
                startPoint: CGPoint(x: 0.5, y: 0.5),
                endPoint: CGPoint(x: 0.5, y: 1)
            )
        }
        
        imageContainer.addSubview(imageView)
        imageContainer.addSubview(gradientOverlay)
        
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
        
        // Info container
        let infoStack = UIStackView()
        infoStack.axis = .vertical
        infoStack.spacing = 10
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = pack.titre
        titleLabel.font = .boldSystemFont(ofSize: 26)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .textPrimary
        
        // Destination with icon
        let destinationStack = UIStackView()
        destinationStack.axis = .horizontal
        destinationStack.spacing = 6
        destinationStack.alignment = .center
        
        let locationIcon = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        locationIcon.tintColor = .primaryColor
        locationIcon.contentMode = .scaleAspectFit
        locationIcon.translatesAutoresizingMaskIntoConstraints = false
        locationIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        locationIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let destinationLabel = UILabel()
        destinationLabel.text = pack.destination ?? "Destination"
        destinationLabel.font = .systemFont(ofSize: 16, weight: .medium)
        destinationLabel.textColor = .textSecondary
        
        destinationStack.addArrangedSubview(locationIcon)
        destinationStack.addArrangedSubview(destinationLabel)
        
        // Hotel info
        let hotelStack = UIStackView()
        hotelStack.axis = .horizontal
        hotelStack.spacing = 6
        hotelStack.alignment = .center
        
        let hotelIcon = UIImageView(image: UIImage(systemName: "building.2.fill"))
        hotelIcon.tintColor = .secondaryColor
        hotelIcon.contentMode = .scaleAspectFit
        hotelIcon.translatesAutoresizingMaskIntoConstraints = false
        hotelIcon.widthAnchor.constraint(equalToConstant: 18).isActive = true
        hotelIcon.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        let hotelLabel = UILabel()
        hotelLabel.text = "\(pack.hotelDisplayName) \(pack.hotelStarsText)"
        hotelLabel.font = .systemFont(ofSize: 14, weight: .medium)
        hotelLabel.textColor = .textSecondary
        
        hotelStack.addArrangedSubview(hotelIcon)
        hotelStack.addArrangedSubview(hotelLabel)
        
        // Price with background
        let priceContainer = UIView()
        priceContainer.backgroundColor = .primaryColor
        priceContainer.layer.cornerRadius = 12
        priceContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let priceLabel = UILabel()
        priceLabel.text = pack.formattedPrice
        priceLabel.font = .boldSystemFont(ofSize: 24)
        priceLabel.textColor = .white
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        priceContainer.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: priceContainer.topAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: priceContainer.leadingAnchor, constant: 16),
            priceLabel.trailingAnchor.constraint(equalTo: priceContainer.trailingAnchor, constant: -16),
            priceLabel.bottomAnchor.constraint(equalTo: priceContainer.bottomAnchor, constant: -8)
        ])
        
        infoStack.addArrangedSubview(titleLabel)
        infoStack.addArrangedSubview(destinationStack)
        infoStack.addArrangedSubview(hotelStack)
        infoStack.addArrangedSubview(priceContainer)
        
        // Action buttons with modern design
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        let favoriteBtn = createModernActionButton(
            icon: "star.fill",
            title: "Favoris",
            color: .favoriteColor
        )
        favoriteBtn.tag = 1
        favoriteBtn.addTarget(self, action: #selector(favoritePressed), for: .touchUpInside)
        favoriteBtn.addPressAnimation()
        
        let chatBtn = createModernActionButton(
            icon: "message.fill",
            title: "Discuter",
            color: .primaryColor
        )
        chatBtn.tag = 2
        chatBtn.addTarget(self, action: #selector(chatPressed), for: .touchUpInside)
        chatBtn.addPressAnimation()
        
        let reserveBtn = createModernActionButton(
            icon: "cart.fill",
            title: "Réserver",
            color: .successColor
        )
        reserveBtn.tag = 3
        reserveBtn.addTarget(self, action: #selector(reservePressed), for: .touchUpInside)
        reserveBtn.addPressAnimation()
        
        buttonStack.addArrangedSubview(favoriteBtn)
        buttonStack.addArrangedSubview(chatBtn)
        buttonStack.addArrangedSubview(reserveBtn)
        
        // Swipe hint label
        let swipeHint = UILabel()
        swipeHint.text = "← Swipe pour le suivant"
        swipeHint.font = .systemFont(ofSize: 12, weight: .light)
        swipeHint.textColor = .textTertiary
        swipeHint.textAlignment = .center
        swipeHint.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(imageContainer)
        card.addSubview(infoStack)
        card.addSubview(buttonStack)
        card.addSubview(swipeHint)
        
        NSLayoutConstraint.activate([
            imageContainer.topAnchor.constraint(equalTo: card.topAnchor),
            imageContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            imageContainer.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            imageContainer.heightAnchor.constraint(equalTo: card.heightAnchor, multiplier: 0.5),
            
            infoStack.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 20),
            infoStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            infoStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            buttonStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: swipeHint.topAnchor, constant: -12),
            buttonStack.heightAnchor.constraint(equalToConstant: 54),
            
            swipeHint.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            swipeHint.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            swipeHint.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        // Add fade in animation
        card.fadeIn(duration: 0.4)
        
        return card
    }
    
    private func createModernActionButton(icon: String, title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = color.withAlphaComponent(0.15)
        config.baseForegroundColor = color
        config.cornerStyle = .medium
        
        // Icon and title
        config.image = UIImage(systemName: icon)
        config.imagePlacement = .top
        config.imagePadding = 4
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 12, weight: .semibold)
            return outgoing
        }
        
        button.configuration = config
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1.5
        button.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        
        return button
    }
    
    
    @objc private func handleSwipeLeft() {
        // Next pack
        guard let cardView = cardContainerView.subviews.first else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            cardView.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
            cardView.alpha = 0
        }) { _ in
            self.currentIndex += 1
            self.showCurrentCard()
        }
    }
    
    @objc private func handleSwipeRight() {
        // Add to favorites with animation
        guard currentIndex < packs.count else { return }
        let pack = packs[currentIndex]
        guard let cardView = cardContainerView.subviews.first else { return }
        
        // Show heart animation
        let heartIcon = UIImageView(image: UIImage(systemName: "heart.fill"))
        heartIcon.tintColor = .favoriteFilledColor
        heartIcon.contentMode = .scaleAspectFit
        heartIcon.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        heartIcon.center = cardView.center
        heartIcon.alpha = 0
        heartIcon.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        view.addSubview(heartIcon)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            heartIcon.alpha = 1
            heartIcon.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                heartIcon.alpha = 0
                heartIcon.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            } completion: { _ in
                heartIcon.removeFromSuperview()
            }
        }
        
        // Add to favorites
        FavoritesManager.shared.addFavorite(pack)
        
        // Move to next pack
        UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
            cardView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            cardView.alpha = 0
        }) { _ in
            self.currentIndex += 1
            self.showCurrentCard()
        }
    }
    
    @objc private func cardTapped() {
        // Show full details
        guard currentIndex < packs.count else { return }
        let pack = packs[currentIndex]
        let detailVC = PackDetailViewController(offer: pack)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc private func favoritePressed() {
        guard currentIndex < packs.count else { return }
        let pack = packs[currentIndex]
        
        // Add to local storage
        FavoritesManager.shared.addFavorite(pack)
        
        // Show success feedback
        let alert = UIAlertController(title: "✅ Ajouté aux favoris", message: nil, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            alert.dismiss(animated: true) {
                // Navigate to favorites tab
                if let tabBarController = self.tabBarController {
                    tabBarController.selectedIndex = 2 // Favorites tab
                }
            }
        }
        
        // Pulse animation on button
        if let button = view.viewWithTag(1) {
            button.pulse()
        }
    }
    
    @objc private func chatPressed() {
        guard currentIndex < packs.count else { return }
        let pack = packs[currentIndex]
        let chatVC = ChatViewController(offer: pack)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc private func reservePressed() {
        guard currentIndex < packs.count else { return }
        let pack = packs[currentIndex]
        guard let packId = pack.id else { return }
        
        // Show loading
        let loadingAlert = UIAlertController(title: nil, message: "Création de la réservation...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: loadingAlert.view.topAnchor, constant: 50)
        ])
        present(loadingAlert, animated: true)
        
        // Create reservation with default values (2 adults, 0 children)
        let adults = 2
        let children = 0
        let totalPrice = Double(adults) * pack.baseAdultPrice + Double(children) * pack.baseChildPrice
        
        Task {
            do {
                let reservation = try await ReservationService.shared.createReservation(
                    packId: packId,
                    adultsCount: adults,
                    childrenCount: children,
                    totalPrice: totalPrice
                )
                
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        // Show success message
                        let successAlert = UIAlertController(
                            title: "🎉 Réservation créée!",
                            message: "Votre réservation pour \(adults) adultes a été envoyée à l'agence.\n\nStatut: \(reservation.status.displayName)\nPrix total: \(String(format: "%.0f", totalPrice)) DT",
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "Voir mes réservations", style: .default) { _ in
                            // Navigate to reservations tab
                            if let tabBarController = self.tabBarController {
                                tabBarController.selectedIndex = 3 // Reservations tab
                            }
                        })
                        successAlert.addAction(UIAlertAction(title: "Continuer", style: .cancel) { _ in
                            // Move to next pack
                            self.currentIndex += 1
                            self.showCurrentCard()
                        })
                        self.present(successAlert, animated: true)
                    }
                }
            } catch {
                print("❌ Failed to create reservation: \(error)")
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        let errorAlert = UIAlertController(
                            title: "Erreur",
                            message: "Impossible de créer la réservation. Veuillez réessayer.",
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        }
    }
}
