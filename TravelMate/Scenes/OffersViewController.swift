import UIKit

class OffersViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "tag.fill")
        imageView.tintColor = UIColor.systemOrange.withAlphaComponent(0.3)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Offres Spéciales"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Découvrez nos meilleures offres du moment"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var offersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadOffers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .primaryColor
        navigationItem.leftBarButtonItem = backButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        title = "Offres"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(offersStackView)
        
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
            
            headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerImageView.widthAnchor.constraint(equalToConstant: 100),
            headerImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            offersStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            offersStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            offersStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            offersStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadOffers() {
        // No example voyages - data comes from backend
    }
    
    private func createOfferCard(destination: String, description: String, discount: String, price: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.1
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let discountBadge = UIView()
        discountBadge.backgroundColor = color
        discountBadge.layer.cornerRadius = 8
        discountBadge.translatesAutoresizingMaskIntoConstraints = false
        
        let discountLabel = UILabel()
        discountLabel.text = discount
        discountLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        discountLabel.textColor = .white
        discountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let destinationLabel = UILabel()
        destinationLabel.text = destination
        destinationLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        destinationLabel.textColor = .black
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .systemGray
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let priceLabel = UILabel()
        priceLabel.text = "À partir de"
        priceLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        priceLabel.textColor = .systemGray2
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let amountLabel = UILabel()
        amountLabel.text = price
        amountLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        amountLabel.textColor = color
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let bookButton = UIButton(type: .system)
        bookButton.setTitle("Réserver", for: .normal)
        bookButton.setTitleColor(.white, for: .normal)
        bookButton.backgroundColor = color
        bookButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        bookButton.layer.cornerRadius = 20
        bookButton.translatesAutoresizingMaskIntoConstraints = false
        
        discountBadge.addSubview(discountLabel)
        container.addSubview(discountBadge)
        container.addSubview(destinationLabel)
        container.addSubview(descriptionLabel)
        container.addSubview(priceLabel)
        container.addSubview(amountLabel)
        container.addSubview(bookButton)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 160),
            
            discountBadge.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            discountBadge.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            discountBadge.heightAnchor.constraint(equalToConstant: 32),
            
            discountLabel.topAnchor.constraint(equalTo: discountBadge.topAnchor, constant: 6),
            discountLabel.leadingAnchor.constraint(equalTo: discountBadge.leadingAnchor, constant: 12),
            discountLabel.trailingAnchor.constraint(equalTo: discountBadge.trailingAnchor, constant: -12),
            discountLabel.bottomAnchor.constraint(equalTo: discountBadge.bottomAnchor, constant: -6),
            
            destinationLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            destinationLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            destinationLabel.trailingAnchor.constraint(equalTo: discountBadge.leadingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            priceLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            amountLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2),
            amountLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            amountLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            
            bookButton.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor),
            bookButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            bookButton.heightAnchor.constraint(equalToConstant: 40),
            bookButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        return container
    }
}
