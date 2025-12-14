import UIKit

class ComparisonViewController: UIViewController {
    private let voyages: [Voyage]
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        scroll.showsVerticalScrollIndicator = true
        return scroll
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Best values
    private var lowestPrice: Double?
    private var mostSeats: Int?
    private var shortestDuration: TimeInterval?
    
    init(voyages: [Voyage]) {
        self.voyages = voyages
        super.init(nibName: nil, bundle: nil)
        print("ComparisonViewController initialized with \(voyages.count) voyages")
        for (index, voyage) in voyages.enumerated() {
            print("Voyage \(index + 1): \(voyage.destination)")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ComparisonViewController viewDidLoad called")
        calculateBestValues()
        setupUI()
        buildComparisonView()
        print("ComparisonViewController UI built with \(voyages.count) voyages")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ComparisonViewController viewDidAppear called")
        print("View bounds: \(view.bounds)")
        print("ScrollView content size: \(scrollView.contentSize)")
        print("Content stack view arranged subviews: \(contentStackView.arrangedSubviews.count)")
    }
    
    private func setupUI() {
        title = "Comparaison"
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func calculateBestValues() {
        let prices = voyages.compactMap { $0.prix_estime }
        lowestPrice = prices.min()
        
        let seats = voyages.compactMap { $0.nombre_places }
        mostSeats = seats.max()
        
        let durations = voyages.compactMap { $0.duration() }
        shortestDuration = durations.min()
    }
    
    private func buildComparisonView() {
        print("Building comparison view with \(voyages.count) voyages")
        // Add preview cards section
        let previewSection = createPreviewSection()
        contentStackView.addArrangedSubview(previewSection)
        
        // Add comparison rows
        addComparisonRow(title: "Destination", key: "destination")
        addComparisonRow(title: "Type", key: "type")
        addComparisonRow(title: "Départ", key: "departure")
        addComparisonRow(title: "Retour", key: "return")
        addComparisonRow(title: "Durée", key: "duration")
        addComparisonRow(title: "Prix", key: "price")
        addComparisonRow(title: "Places disponibles", key: "seats")
        print("Finished building comparison view")
    }
    
    private func createPreviewSection() -> UIView {
        print("Creating preview section with \(voyages.count) cards")
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, voyage) in voyages.enumerated() {
            let card = createPreviewCard(for: voyage, index: index)
            stackView.addArrangedSubview(card)
        }
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        return container
    }
    
    private func createPreviewCard(for voyage: Voyage, index: Int) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOpacity = 0.1
        cardView.clipsToBounds = false
        
        // Header with gradient
        let headerView = UIView()
        headerView.backgroundColor = .systemOrange
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let headerLabel = UILabel()
        headerLabel.text = "Option \(index + 1)"
        headerLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        headerLabel.textColor = .white
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(headerLabel)
        
        // Image container
        let imageContainer = UIView()
        imageContainer.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        imageContainer.layer.cornerRadius = 8
        imageContainer.clipsToBounds = true
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let imageUrl = voyage.imageUrl, let url = URL(string: imageUrl) {
            loadImage(from: url, into: imageView)
        } else {
            imageView.image = UIImage(systemName: voyage.typeIcon())
            imageView.tintColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
            imageView.contentMode = .scaleAspectFit
        }
        
        imageContainer.addSubview(imageView)
        
        // Destination
        let destinationLabel = UILabel()
        destinationLabel.text = voyage.destination
        destinationLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        destinationLabel.textAlignment = .center
        destinationLabel.numberOfLines = 2
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Type badge
        let typeBadge = UILabel()
        typeBadge.text = "✈️ " + voyage.typeDisplayName()
        typeBadge.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        typeBadge.textColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        typeBadge.textAlignment = .center
        typeBadge.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 0.12)
        typeBadge.layer.cornerRadius = 10
        typeBadge.clipsToBounds = true
        typeBadge.translatesAutoresizingMaskIntoConstraints = false
        
        // Price with better formatting
        let priceLabel = UILabel()
        if let price = voyage.prix_estime {
            let priceValue = Int(price)
            let attributedString = NSMutableAttributedString()
            
            // Price number
            let priceString = NSAttributedString(
                string: "\(priceValue)",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                    .foregroundColor: UIColor.systemOrange
                ]
            )
            attributedString.append(priceString)
            
            // Euro symbol
            let euroString = NSAttributedString(
                string: "€",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                    .foregroundColor: UIColor.systemOrange
                ]
            )
            attributedString.append(euroString)
            
            priceLabel.attributedText = attributedString
            
            // Add checkmark if best price
            if price == lowestPrice {
                let checkString = NSAttributedString(
                    string: " ✓",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                        .foregroundColor: UIColor.systemGreen
                    ]
                )
                attributedString.append(checkString)
                priceLabel.attributedText = attributedString
            }
        } else {
            priceLabel.text = "Sur demande"
            priceLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            priceLabel.textColor = .systemGray
        }
        priceLabel.textAlignment = .center
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(headerView)
        cardView.addSubview(imageContainer)
        cardView.addSubview(destinationLabel)
        cardView.addSubview(typeBadge)
        cardView.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: cardView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 36),
            
            headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            imageContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            imageContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            imageContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            imageContainer.heightAnchor.constraint(equalToConstant: 70),
            
            imageView.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: imageContainer.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: imageContainer.heightAnchor),
            
            destinationLabel.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 10),
            destinationLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            destinationLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            
            typeBadge.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 8),
            typeBadge.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            typeBadge.heightAnchor.constraint(equalToConstant: 20),
            typeBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            priceLabel.topAnchor.constraint(equalTo: typeBadge.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            priceLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12)
        ])
        
        return cardView
    }
    
    private func addComparisonRow(title: String, key: String) {
        print("Adding comparison row: \(title) with \(voyages.count) values")
        let rowView = UIView()
        rowView.backgroundColor = .white
        rowView.layer.cornerRadius = 12
        rowView.layer.shadowColor = UIColor.black.cgColor
        rowView.layer.shadowOffset = CGSize(width: 0, height: 1)
        rowView.layer.shadowRadius = 4
        rowView.layer.shadowOpacity = 0.08
        rowView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .systemGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valuesStack = UIStackView()
        valuesStack.axis = .horizontal
        valuesStack.distribution = .fillEqually
        valuesStack.spacing = 8
        valuesStack.translatesAutoresizingMaskIntoConstraints = false
        
        for voyage in voyages {
            let valueContainer = createValueLabel(for: voyage, key: key)
            valuesStack.addArrangedSubview(valueContainer)
        }
        
        rowView.addSubview(titleLabel)
        rowView.addSubview(valuesStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: rowView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
            
            valuesStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            valuesStack.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 16),
            valuesStack.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
            valuesStack.bottomAnchor.constraint(equalTo: rowView.bottomAnchor, constant: -14),
            valuesStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        
        contentStackView.addArrangedSubview(rowView)
    }
    
    private func createValueLabel(for voyage: Voyage, key: String) -> UIView {
        let container = UIView()
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var isBest = false
        var text = ""
        
        switch key {
        case "destination":
            text = voyage.destination
        case "type":
            text = voyage.typeDisplayName()
        case "departure":
            text = formatDate(voyage.date_depart)
        case "return":
            text = formatDate(voyage.date_retour)
        case "duration":
            text = voyage.formattedDuration()
            if let duration = voyage.duration(), duration == shortestDuration {
                isBest = true
            }
        case "price":
            if let price = voyage.prix_estime {
                text = String(format: "%.0f €", price)
                if price == lowestPrice {
                    isBest = true
                }
            } else {
                text = "N/A"
                valueLabel.textColor = .systemGray
            }
        case "seats":
            if let seats = voyage.nombre_places {
                text = "\(seats) places"
                if seats == mostSeats {
                    isBest = true
                }
            } else {
                text = "N/A"
                valueLabel.textColor = .systemGray
            }
        default:
            text = "N/A"
        }
        
        valueLabel.text = text
        container.addSubview(valueLabel)
        
        if isBest {
            valueLabel.textColor = .systemGreen
            valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            
            let checkmark = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            checkmark.tintColor = .systemGreen
            checkmark.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubview(checkmark)
            
            NSLayoutConstraint.activate([
                checkmark.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
                checkmark.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
                checkmark.widthAnchor.constraint(equalToConstant: 20),
                checkmark.heightAnchor.constraint(equalToConstant: 20)
            ])
        } else if valueLabel.textColor != .systemGray {
            valueLabel.textColor = .label
        }
        
        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -8)
        ])
        
        return container
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = formatter.date(from: dateString) else {
            return "N/A"
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd MMM.\nHH:mm"
        displayFormatter.locale = Locale(identifier: "fr_FR")
        
        return displayFormatter.string(from: date)
    }
    
    private func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                imageView.image = image
                imageView.contentMode = .scaleAspectFill
            }
        }.resume()
    }
    
    deinit {
        print("ComparisonViewController deinit")
    }
}
