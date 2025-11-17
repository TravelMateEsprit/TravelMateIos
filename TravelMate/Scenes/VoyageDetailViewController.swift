import UIKit

class VoyageDetailViewController: UIViewController {
    private let voyage: Voyage
    private let voyageService = VoyageService.shared
    private var currentVoyage: Voyage
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Main ticket container
    private let ticketView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 16
        view.layer.shadowOpacity = 0.2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Ticket header (airline style)
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let destinationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Dashed separator line
    private let dashedLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Flight details section
    private let flightDetailsCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let flightDetailsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Description section
    private let descriptionCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "DESCRIPTION"
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Participants section
    private let participantsCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let participantsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let participantsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Creator section
    private let creatorCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let creatorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "CRÉATEUR"
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let creatorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Action buttons
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    init(voyage: Voyage) {
        self.voyage = voyage
        self.currentVoyage = voyage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        Task {
            await refreshVoyage()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawDashedLine()
    }
    
    private func setupNavigationBar() {
        title = "Détails du voyage"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(ticketView)
        
        // Header
        ticketView.addSubview(headerView)
        headerView.addSubview(destinationLabel)
        headerView.addSubview(typeBadge)
        typeBadge.addSubview(typeLabel)
        
        // Dashed line
        ticketView.addSubview(dashedLineView)
        
        // Flight details
        ticketView.addSubview(flightDetailsCard)
        flightDetailsCard.addSubview(flightDetailsStack)
        
        // Description
        ticketView.addSubview(descriptionCard)
        descriptionCard.addSubview(descriptionTitleLabel)
        descriptionCard.addSubview(descriptionLabel)
        
        // Participants
        ticketView.addSubview(participantsCard)
        participantsCard.addSubview(participantsTitleLabel)
        participantsCard.addSubview(participantsStackView)
        
        // Creator
        ticketView.addSubview(creatorCard)
        creatorCard.addSubview(creatorTitleLabel)
        creatorCard.addSubview(creatorLabel)
        
        // Buttons
        contentView.addSubview(buttonsStackView)
        
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
            
            // Ticket view
            ticketView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            ticketView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ticketView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Header
            headerView.topAnchor.constraint(equalTo: ticketView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: ticketView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 140),
            
            destinationLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            destinationLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            destinationLabel.trailingAnchor.constraint(lessThanOrEqualTo: typeBadge.leadingAnchor, constant: -16),
            
            typeBadge.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            typeBadge.centerYAnchor.constraint(equalTo: destinationLabel.centerYAnchor),
            typeBadge.heightAnchor.constraint(equalToConstant: 32),
            typeBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            typeLabel.topAnchor.constraint(equalTo: typeBadge.topAnchor, constant: 6),
            typeLabel.leadingAnchor.constraint(equalTo: typeBadge.leadingAnchor, constant: 16),
            typeLabel.trailingAnchor.constraint(equalTo: typeBadge.trailingAnchor, constant: -16),
            typeLabel.bottomAnchor.constraint(equalTo: typeBadge.bottomAnchor, constant: -6),
            
            // Dashed line
            dashedLineView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            dashedLineView.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor, constant: 24),
            dashedLineView.trailingAnchor.constraint(equalTo: ticketView.trailingAnchor, constant: -24),
            dashedLineView.heightAnchor.constraint(equalToConstant: 1),
            
            // Flight details
            flightDetailsCard.topAnchor.constraint(equalTo: dashedLineView.bottomAnchor, constant: 24),
            flightDetailsCard.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor, constant: 20),
            flightDetailsCard.trailingAnchor.constraint(equalTo: ticketView.trailingAnchor, constant: -20),
            
            flightDetailsStack.topAnchor.constraint(equalTo: flightDetailsCard.topAnchor, constant: 20),
            flightDetailsStack.leadingAnchor.constraint(equalTo: flightDetailsCard.leadingAnchor, constant: 20),
            flightDetailsStack.trailingAnchor.constraint(equalTo: flightDetailsCard.trailingAnchor, constant: -20),
            flightDetailsStack.bottomAnchor.constraint(equalTo: flightDetailsCard.bottomAnchor, constant: -20),
            
            // Description
            descriptionCard.topAnchor.constraint(equalTo: flightDetailsCard.bottomAnchor, constant: 16),
            descriptionCard.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor, constant: 20),
            descriptionCard.trailingAnchor.constraint(equalTo: ticketView.trailingAnchor, constant: -20),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: descriptionCard.topAnchor, constant: 20),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: descriptionCard.leadingAnchor, constant: 20),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: descriptionCard.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionCard.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionCard.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionCard.bottomAnchor, constant: -20),
            
            // Participants
            participantsCard.topAnchor.constraint(equalTo: descriptionCard.bottomAnchor, constant: 16),
            participantsCard.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor, constant: 20),
            participantsCard.trailingAnchor.constraint(equalTo: ticketView.trailingAnchor, constant: -20),
            
            participantsTitleLabel.topAnchor.constraint(equalTo: participantsCard.topAnchor, constant: 20),
            participantsTitleLabel.leadingAnchor.constraint(equalTo: participantsCard.leadingAnchor, constant: 20),
            participantsTitleLabel.trailingAnchor.constraint(equalTo: participantsCard.trailingAnchor, constant: -20),
            
            participantsStackView.topAnchor.constraint(equalTo: participantsTitleLabel.bottomAnchor, constant: 16),
            participantsStackView.leadingAnchor.constraint(equalTo: participantsCard.leadingAnchor, constant: 20),
            participantsStackView.trailingAnchor.constraint(equalTo: participantsCard.trailingAnchor, constant: -20),
            participantsStackView.bottomAnchor.constraint(equalTo: participantsCard.bottomAnchor, constant: -20),
            
            // Creator
            creatorCard.topAnchor.constraint(equalTo: participantsCard.bottomAnchor, constant: 16),
            creatorCard.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor, constant: 20),
            creatorCard.trailingAnchor.constraint(equalTo: ticketView.trailingAnchor, constant: -20),
            creatorCard.bottomAnchor.constraint(equalTo: ticketView.bottomAnchor, constant: -24),
            
            creatorTitleLabel.topAnchor.constraint(equalTo: creatorCard.topAnchor, constant: 20),
            creatorTitleLabel.leadingAnchor.constraint(equalTo: creatorCard.leadingAnchor, constant: 20),
            creatorTitleLabel.trailingAnchor.constraint(equalTo: creatorCard.trailingAnchor, constant: -20),
            
            creatorLabel.topAnchor.constraint(equalTo: creatorTitleLabel.bottomAnchor, constant: 12),
            creatorLabel.leadingAnchor.constraint(equalTo: creatorCard.leadingAnchor, constant: 20),
            creatorLabel.trailingAnchor.constraint(equalTo: creatorCard.trailingAnchor, constant: -20),
            creatorLabel.bottomAnchor.constraint(equalTo: creatorCard.bottomAnchor, constant: -20),
            
            // Buttons
            buttonsStackView.topAnchor.constraint(equalTo: ticketView.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func drawDashedLine() {
        dashedLineView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.systemGray4.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [8, 4]
        
        let path = CGMutablePath()
        path.addLines(between: [
            CGPoint(x: 0, y: 0),
            CGPoint(x: dashedLineView.bounds.width, y: 0)
        ])
        shapeLayer.path = path
        dashedLineView.layer.addSublayer(shapeLayer)
    }
    
    private func configureUI() {
        // Header
        destinationLabel.text = currentVoyage.destination.uppercased()
        typeLabel.text = currentVoyage.typeDisplayName().uppercased()
        
        // Flight details
        flightDetailsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let displayDateFormatter = DateFormatter()
        displayDateFormatter.dateFormat = "EEEE, dd MMMM yyyy"
        displayDateFormatter.locale = Locale(identifier: "fr_FR")
        
        let displayTimeFormatter = DateFormatter()
        displayTimeFormatter.dateFormat = "HH:mm"
        
        if let departDate = formatter.date(from: currentVoyage.date_depart) {
            addFlightDetailRow(
                title: "DÉPART",
                date: displayDateFormatter.string(from: departDate),
                time: displayTimeFormatter.string(from: departDate),
                icon: "airplane.departure"
            )
        }
        
        if let returnDate = formatter.date(from: currentVoyage.date_retour) {
            addFlightDetailRow(
                title: "RETOUR",
                date: displayDateFormatter.string(from: returnDate),
                time: displayTimeFormatter.string(from: returnDate),
                icon: "airplane.arrival"
            )
        }
        
        if let price = currentVoyage.formattedPrice() {
            addInfoRow(icon: "dollarsign.circle.fill", title: "Prix estimé", value: price)
        }
        
        addInfoRow(icon: "person.3.fill", title: "Places disponibles", value: currentVoyage.placesInfo())
        
        // Description
        descriptionLabel.text = currentVoyage.description ?? "Aucune description disponible"
        
        // Participants
        participantsTitleLabel.text = "PARTICIPANTS (\(currentVoyage.participants.count))"
        participantsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if currentVoyage.participants.isEmpty {
            let label = UILabel()
            label.text = "Aucun participant pour le moment"
            label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            label.textColor = .systemGray
            participantsStackView.addArrangedSubview(label)
        } else {
            for participant in currentVoyage.participants {
                let participantView = createParticipantView(name: participant.name, email: participant.email)
                participantsStackView.addArrangedSubview(participantView)
            }
        }
        
        // Creator
        creatorLabel.text = "\(currentVoyage.createur_id.name)\n\(currentVoyage.createur_id.email)"
        creatorLabel.numberOfLines = 0
        
        // Buttons
        setupConditionalButtons()
    }
    
    private func addFlightDetailRow(title: String, date: String, time: String, icon: String) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        titleLabel.textColor = .systemGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        dateLabel.text = date.capitalized
        dateLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        dateLabel.textColor = .black
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        timeLabel.textColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(dateLabel)
        container.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.topAnchor.constraint(equalTo: container.topAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            
            timeLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            timeLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        flightDetailsStack.addArrangedSubview(container)
    }
    
    private func addInfoRow(icon: String, title: String, value: String) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title + ":"
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        valueLabel.textColor = .systemGray
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor)
        ])
        
        flightDetailsStack.addArrangedSubview(container)
    }
    
    private func createParticipantView(name: String, email: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        iconView.tintColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let emailLabel = UILabel()
        emailLabel.text = email
        emailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        emailLabel.textColor = .systemGray
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconView)
        container.addSubview(nameLabel)
        container.addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            
            emailLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            emailLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupConditionalButtons() {
        buttonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let currentUserId = voyageService.currentUserId
        let isCreator = currentVoyage.createur_id._id == currentUserId
        let isParticipant = currentVoyage.participants.contains(where: { $0._id == currentUserId })
        let hasAvailablePlaces = currentVoyage.hasAvailablePlaces()
        
        if isCreator {
            let modifyButton = createButton(title: "Modifier", color: .systemOrange, action: #selector(modifyButtonTapped))
            let deleteButton = createButton(title: "Supprimer", color: .systemRed, action: #selector(deleteButtonTapped))
            
            buttonsStackView.addArrangedSubview(modifyButton)
            buttonsStackView.addArrangedSubview(deleteButton)
        } else {
            if isParticipant {
                let leaveButton = createButton(title: "Quitter le voyage", color: .systemRed, action: #selector(leaveButtonTapped), style: .outline)
                buttonsStackView.addArrangedSubview(leaveButton)
            } else {
                if hasAvailablePlaces {
                    let joinButton = createButton(title: "Participer", color: .systemGreen, action: #selector(joinButtonTapped))
                    buttonsStackView.addArrangedSubview(joinButton)
                } else {
                    let fullButton = createButton(title: "Complet", color: .systemGray, action: nil)
                    fullButton.isEnabled = false
                    buttonsStackView.addArrangedSubview(fullButton)
                }
            }
            
            let reserveButton = createButton(title: "Réserver ce voyage", color: UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0), action: #selector(reserveButtonTapped))
            buttonsStackView.addArrangedSubview(reserveButton)
        }
    }
    
    private func createButton(title: String, color: UIColor, action: Selector?, style: ButtonStyle = .filled) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        
        if style == .filled {
            button.backgroundColor = color
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(color, for: .normal)
            button.layer.borderWidth = 2
            button.layer.borderColor = color.cgColor
        }
        
        if let action = action {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        return button
    }
    
    enum ButtonStyle {
        case filled
        case outline
    }
    
    private func refreshVoyage() async {
        do {
            let updatedVoyage = try await voyageService.fetchVoyage(id: currentVoyage.id)
            currentVoyage = updatedVoyage
            DispatchQueue.main.async {
                self.configureUI()
            }
        } catch {
            print("Error refreshing voyage: \(error)")
        }
    }
    
    // MARK: - Button Actions
    @objc private func modifyButtonTapped() {
        let editVC = EditVoyageViewController(voyage: currentVoyage)
        let navController = UINavigationController(rootViewController: editVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "Supprimer le voyage",
            message: "Êtes-vous sûr de vouloir supprimer ce voyage ? Cette action est irréversible.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "Supprimer", style: .destructive) { [weak self] _ in
            self?.performDelete()
        })
        
        present(alert, animated: true)
    }
    
    private func performDelete() {
        print("🗑️ [DELETE VOYAGE] Starting delete for voyage ID: \(currentVoyage.id)")
        Task {
            do {
                try await voyageService.deleteVoyage(id: currentVoyage.id)
                print("✅ [DELETE VOYAGE] Delete successful, refreshing list...")
                await voyageService.fetchVoyages()
                DispatchQueue.main.async {
                    print("✅ [DELETE VOYAGE] Navigating back...")
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("❌ [DELETE VOYAGE] Error occurred:")
                print("   - Error type: \(type(of: error))")
                print("   - Error description: \(error.localizedDescription)")
                print("   - Full error: \(error)")
                
                var errorMessage = error.localizedDescription
                if let networkError = error as? NetworkService.NetworkError {
                    print("   - Network error: \(networkError)")
                    errorMessage = networkError.localizedDescription
                } else if let urlError = error as? URLError {
                    print("   - URL Error code: \(urlError.code.rawValue)")
                    switch urlError.code {
                    case .notConnectedToInternet:
                        errorMessage = "Pas de connexion Internet. Vérifiez votre connexion réseau."
                    case .timedOut:
                        errorMessage = "La requête a expiré. Veuillez réessayer."
                    case .cannotFindHost, .cannotConnectToHost:
                        errorMessage = "Impossible de se connecter au serveur. Vérifiez votre connexion."
                    default:
                        errorMessage = "Erreur réseau: \(urlError.localizedDescription)"
                    }
                }
                DispatchQueue.main.async {
                    print("❌ [DELETE VOYAGE] Showing error alert: \(errorMessage)")
                    self.showErrorAlert(message: errorMessage)
                }
            }
        }
    }
    
    @objc private func joinButtonTapped() {
        Task {
            do {
                let updatedVoyage = try await voyageService.joinVoyage(id: currentVoyage.id)
                currentVoyage = updatedVoyage
                DispatchQueue.main.async {
                    self.configureUI()
                    self.showSuccessAlert(message: "Vous avez rejoint le voyage avec succès !")
                }
            } catch {
                var errorMessage = error.localizedDescription
                if let networkError = error as? NetworkService.NetworkError {
                    errorMessage = networkError.localizedDescription
                } else if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        errorMessage = "Pas de connexion Internet. Vérifiez votre connexion réseau."
                    case .timedOut:
                        errorMessage = "La requête a expiré. Veuillez réessayer."
                    case .cannotFindHost, .cannotConnectToHost:
                        errorMessage = "Impossible de se connecter au serveur. Vérifiez votre connexion."
                    default:
                        errorMessage = "Erreur réseau: \(urlError.localizedDescription)"
                    }
                }
                DispatchQueue.main.async {
                    self.showErrorAlert(message: errorMessage)
                }
            }
        }
    }
    
    @objc private func leaveButtonTapped() {
        Task {
            do {
                let updatedVoyage = try await voyageService.leaveVoyage(id: currentVoyage.id)
                currentVoyage = updatedVoyage
                DispatchQueue.main.async {
                    self.configureUI()
                    self.showSuccessAlert(message: "Vous avez quitté le voyage.")
                }
            } catch {
                var errorMessage = error.localizedDescription
                if let networkError = error as? NetworkService.NetworkError {
                    errorMessage = networkError.localizedDescription
                } else if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        errorMessage = "Pas de connexion Internet. Vérifiez votre connexion réseau."
                    case .timedOut:
                        errorMessage = "La requête a expiré. Veuillez réessayer."
                    case .cannotFindHost, .cannotConnectToHost:
                        errorMessage = "Impossible de se connecter au serveur. Vérifiez votre connexion."
                    default:
                        errorMessage = "Erreur réseau: \(urlError.localizedDescription)"
                    }
                }
                DispatchQueue.main.async {
                    self.showErrorAlert(message: errorMessage)
                }
            }
        }
    }
    
    @objc private func reserveButtonTapped() {
        let reserveVC = CreateReservationViewController(voyage: currentVoyage)
        let navController = UINavigationController(rootViewController: reserveVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        var cleanMessage = message
        
        let prefixesToRemove = [
            "travelMate.",
            "networkService.",
            "NetworkService.",
            "NetworkError.",
            "Network error",
            "error "
        ]
        
        for prefix in prefixesToRemove {
            if let range = cleanMessage.range(of: prefix, options: .caseInsensitive) {
                cleanMessage = String(cleanMessage[range.upperBound...])
            }
        }
        
        if let range = cleanMessage.range(of: "error ", options: .caseInsensitive) {
            let afterError = String(cleanMessage[range.upperBound...])
            if let _ = Int(afterError.trimmingCharacters(in: .whitespacesAndNewlines)) {
                cleanMessage = String(cleanMessage[..<range.lowerBound])
            }
        }
        
        cleanMessage = cleanMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanMessage.isEmpty || cleanMessage.count < 3 {
            cleanMessage = "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer."
        }
        
        let alert = UIAlertController(title: "Erreur", message: cleanMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Succès", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
