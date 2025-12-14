import UIKit

class PackCell: UITableViewCell {
    
    static let identifier = "PackCell"
    var onChatTapped: (() -> Void)?
    
    private var offer: Offer?
    
    // MARK: - UI Elements
    
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 8
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let packImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let priceBadge: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .boldSystemFont(ofSize: 16)
        lbl.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        lbl.layer.cornerRadius = 12
        lbl.clipsToBounds = true
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let typeBadge: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        lbl.layer.cornerRadius = 10
        lbl.clipsToBounds = true
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 18)
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let nightsLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .darkGray
        lbl.font = .systemFont(ofSize: 14)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let destinationLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.systemBlue
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let favoriteButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = .systemRed
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup UI
    private func setupCell() {
        contentView.addSubview(cardView)
        cardView.addSubview(packImage)
        cardView.addSubview(priceBadge)
        cardView.addSubview(typeBadge)
        cardView.addSubview(titleLabel)
        cardView.addSubview(nightsLabel)
        cardView.addSubview(destinationLabel)
        cardView.addSubview(favoriteButton)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            packImage.topAnchor.constraint(equalTo: cardView.topAnchor),
            packImage.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            packImage.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            packImage.heightAnchor.constraint(equalToConstant: 190),
            
            priceBadge.trailingAnchor.constraint(equalTo: packImage.trailingAnchor, constant: -10),
            priceBadge.bottomAnchor.constraint(equalTo: packImage.bottomAnchor, constant: -10),
            priceBadge.heightAnchor.constraint(equalToConstant: 28),
            priceBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            typeBadge.leadingAnchor.constraint(equalTo: packImage.leadingAnchor, constant: 10),
            typeBadge.topAnchor.constraint(equalTo: packImage.topAnchor, constant: 10),
            typeBadge.heightAnchor.constraint(equalToConstant: 24),
            typeBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),
            
            titleLabel.topAnchor.constraint(equalTo: packImage.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -10),
            
            favoriteButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),
            
            nightsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            nightsLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
            destinationLabel.topAnchor.constraint(equalTo: nightsLabel.bottomAnchor, constant: 6),
            destinationLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            destinationLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
        
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
    }

    // MARK: - Configure cell
    func configure(with offer: Offer) {
        self.offer = offer
        
        titleLabel.text = offer.titre
        nightsLabel.text = offer.nightsText
        destinationLabel.text = offer.destination ?? "Destination inconnue"
        
        priceBadge.text = "\(offer.baseAdultPrice) DT"
        typeBadge.text = offer.type_offre?.capitalized ?? "Pack"
        
        if FavoritesManager.shared.isFavorite(id: offer.id ?? "") {
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        if let url = offer.firstImageURL {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.packImage.image = UIImage(data: data)
                }
            }.resume()
        } else {
            packImage.image = UIImage(named: "placeholder")
        }
    }
    
    // MARK: - Favorite toggle
    @objc private func toggleFavorite() {
        guard let offer = offer else { return }
        
        if FavoritesManager.shared.isFavorite(id: offer.id ?? "") {
            FavoritesManager.shared.removeFavorite(id: offer.id ?? "")
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        } else {
            FavoritesManager.shared.addFavorite(offer)
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
    }
}
