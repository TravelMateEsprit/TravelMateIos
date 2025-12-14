import UIKit

class AgencyRatingsViewController: UIViewController {
    private let insuranceService = InsuranceService.shared
    private var ratingsData: AgencyRatingsResponse?
    
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
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Tous les avis"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let insurancesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let ratingsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRatings()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        title = "Avis des clients"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerLabel)
        contentView.addSubview(insurancesStackView)
        contentView.addSubview(ratingsStackView)
        
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
            
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            insurancesStackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            insurancesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            insurancesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            ratingsStackView.topAnchor.constraint(equalTo: insurancesStackView.bottomAnchor, constant: 30),
            ratingsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ratingsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            ratingsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadRatings() {
        Task {
            do {
                ratingsData = try await insuranceService.getAllRatingsForAgency()
                updateUI()
            } catch {
                showAlert(title: "Erreur", message: "Impossible de charger les avis")
            }
        }
    }
    
    private func updateUI() {
        guard let data = ratingsData else { return }
        
        insurancesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let sectionTitle = UILabel()
        sectionTitle.text = "Resume par assurance"
        sectionTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        insurancesStackView.addArrangedSubview(sectionTitle)
        
        if data.insurances.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Aucune assurance pour le moment"
            emptyLabel.textColor = .systemGray
            emptyLabel.textAlignment = .center
            insurancesStackView.addArrangedSubview(emptyLabel)
        } else {
            for insurance in data.insurances {
                let card = createInsuranceRatingCard(insurance: insurance)
                insurancesStackView.addArrangedSubview(card)
            }
        }
        
        ratingsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let ratingsSectionTitle = UILabel()
        ratingsSectionTitle.text = "Tous les commentaires"
        ratingsSectionTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        ratingsStackView.addArrangedSubview(ratingsSectionTitle)
        
        if data.allRatings.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Aucun avis pour le moment"
            emptyLabel.textColor = .systemGray
            emptyLabel.textAlignment = .center
            ratingsStackView.addArrangedSubview(emptyLabel)
        } else {
            for rating in data.allRatings {
                let card = createRatingCard(rating: rating)
                ratingsStackView.addArrangedSubview(card)
            }
        }
    }
    
    private func createInsuranceRatingCard(insurance: InsuranceRatingInfo) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 6
        card.layer.shadowOpacity = 0.1
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = insurance.insuranceName
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let ratingLabel = UILabel()
        ratingLabel.text = String(format: "%.1f", insurance.averageRating)
        ratingLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        ratingLabel.textColor = .primaryColor
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let starsStack = UIStackView()
        starsStack.axis = .horizontal
        starsStack.spacing = 2
        starsStack.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 1...5 {
            let star = UIImageView(image: UIImage(systemName: i <= Int(insurance.averageRating.rounded()) ? "star.fill" : "star"))
            star.tintColor = .systemYellow
            star.widthAnchor.constraint(equalToConstant: 16).isActive = true
            star.heightAnchor.constraint(equalToConstant: 16).isActive = true
            starsStack.addArrangedSubview(star)
        }
        
        let countLabel = UILabel()
        countLabel.text = "\(insurance.totalRatings) avis"
        countLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        countLabel.textColor = .systemGray
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(nameLabel)
        card.addSubview(ratingLabel)
        card.addSubview(starsStack)
        card.addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: ratingLabel.leadingAnchor, constant: -16),
            
            ratingLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            starsStack.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            starsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            
            countLabel.centerYAnchor.constraint(equalTo: starsStack.centerYAnchor),
            countLabel.leadingAnchor.constraint(equalTo: starsStack.trailingAnchor, constant: 8),
            countLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return card
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
        
        let insuranceLabel = UILabel()
        insuranceLabel.text = rating.insuranceId?.name ?? "Assurance"
        insuranceLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        insuranceLabel.textColor = .primaryColor
        insuranceLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        card.addSubview(insuranceLabel)
        card.addSubview(nameLabel)
        card.addSubview(starsStack)
        
        NSLayoutConstraint.activate([
            insuranceLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            insuranceLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            
            nameLabel.topAnchor.constraint(equalTo: insuranceLabel.bottomAnchor, constant: 8),
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
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
