import UIKit

class InsuranceRatingsViewController: UIViewController {
    private let insuranceId: String
    private let insuranceName: String
    private let insuranceService = InsuranceService.shared
    
    private var ratingsData: InsuranceRatingsResponse?
    private var myRating: Rating?
    
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
    
    private let summaryCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let averageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = .primaryColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addRatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Donner mon avis", for: .normal)
        button.backgroundColor = .primaryColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let ratingsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    init(insuranceId: String, insuranceName: String) {
        self.insuranceId = insuranceId
        self.insuranceName = insuranceName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRatings()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        title = "Avis"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(summaryCard)
        contentView.addSubview(addRatingButton)
        contentView.addSubview(ratingsStackView)
        
        summaryCard.addSubview(averageLabel)
        summaryCard.addSubview(starsView)
        summaryCard.addSubview(totalLabel)
        
        addRatingButton.addTarget(self, action: #selector(addRatingTapped), for: .touchUpInside)
        
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
            
            summaryCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            summaryCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summaryCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            averageLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 20),
            averageLabel.centerXAnchor.constraint(equalTo: summaryCard.centerXAnchor),
            
            starsView.topAnchor.constraint(equalTo: averageLabel.bottomAnchor, constant: 8),
            starsView.centerXAnchor.constraint(equalTo: summaryCard.centerXAnchor),
            
            totalLabel.topAnchor.constraint(equalTo: starsView.bottomAnchor, constant: 8),
            totalLabel.centerXAnchor.constraint(equalTo: summaryCard.centerXAnchor),
            totalLabel.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -20),
            
            addRatingButton.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 20),
            addRatingButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addRatingButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addRatingButton.heightAnchor.constraint(equalToConstant: 50),
            
            ratingsStackView.topAnchor.constraint(equalTo: addRatingButton.bottomAnchor, constant: 20),
            ratingsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ratingsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            ratingsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadRatings() {
        Task {
            do {
                ratingsData = try await insuranceService.getInsuranceRatings(insuranceId: insuranceId)
                
                if let user = AuthService.shared.currentUser, user.userType == .user {
                    myRating = try? await insuranceService.getMyRating(insuranceId: insuranceId)
                }
                
                updateUI()
            } catch {
                showAlert(title: "Erreur", message: "Impossible de charger les avis")
            }
        }
    }
    
    private func updateUI() {
        guard let data = ratingsData else { return }
        
        averageLabel.text = String(format: "%.1f", data.averageRating)
        totalLabel.text = "\(data.totalRatings) avis"
        
        starsView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for i in 1...5 {
            let star = UIImageView(image: UIImage(systemName: i <= Int(data.averageRating.rounded()) ? "star.fill" : "star"))
            star.tintColor = .systemYellow
            star.widthAnchor.constraint(equalToConstant: 24).isActive = true
            star.heightAnchor.constraint(equalToConstant: 24).isActive = true
            starsView.addArrangedSubview(star)
        }
        
        if myRating != nil {
            addRatingButton.setTitle("Modifier mon avis", for: .normal)
        }
        
        ratingsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if data.ratings.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Aucun avis pour le moment"
            emptyLabel.textAlignment = .center
            emptyLabel.textColor = .systemGray
            emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            ratingsStackView.addArrangedSubview(emptyLabel)
        } else {
            for rating in data.ratings {
                let ratingView = createRatingCard(rating: rating)
                ratingsStackView.addArrangedSubview(ratingView)
            }
        }
    }
    
    private func createRatingCard(rating: Rating) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 1)
        card.layer.shadowRadius = 4
        card.layer.shadowOpacity = 0.1
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = rating.userId?.name ?? "Utilisateur"
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let starsStack = UIStackView()
        starsStack.axis = .horizontal
        starsStack.spacing = 2
        starsStack.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 1...5 {
            let star = UIImageView(image: UIImage(systemName: i <= rating.rating ? "star.fill" : "star"))
            star.tintColor = .systemYellow
            star.widthAnchor.constraint(equalToConstant: 16).isActive = true
            star.heightAnchor.constraint(equalToConstant: 16).isActive = true
            starsStack.addArrangedSubview(star)
        }
        
        card.addSubview(nameLabel)
        card.addSubview(starsStack)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            
            starsStack.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            starsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
        ])
        
        var lastAnchor = nameLabel.bottomAnchor
        
        if let comment = rating.comment, !comment.isEmpty {
            let commentLabel = UILabel()
            commentLabel.text = comment
            commentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            commentLabel.textColor = .darkGray
            commentLabel.numberOfLines = 0
            commentLabel.translatesAutoresizingMaskIntoConstraints = false
            
            card.addSubview(commentLabel)
            
            NSLayoutConstraint.activate([
                commentLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
                commentLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                commentLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
            ])
            
            lastAnchor = commentLabel.bottomAnchor
        }
        
        NSLayoutConstraint.activate([
            lastAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return card
    }
    
    @objc private func addRatingTapped() {
        let ratingVC = AddRatingViewController(insuranceId: insuranceId, existingRating: myRating)
        ratingVC.delegate = self
        let navController = UINavigationController(rootViewController: ratingVC)
        present(navController, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension InsuranceRatingsViewController: AddRatingDelegate {
    func didAddOrUpdateRating() {
        loadRatings()
    }
}
