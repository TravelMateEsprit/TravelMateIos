import UIKit

class VoyageListViewController: UIViewController {
    private let voyageService = VoyageService.shared
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VoyageCardTableViewCell.self, forCellReuseIdentifier: "VoyageCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        tableView.refreshControl = refreshControl
        // Add bottom content inset to prevent content from going under the button
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshVoyages), for: .valueChanged)
        return control
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Rechercher une destination..."
        return controller
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .systemOrange
        button.tintColor = .white
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        // Ensure button is above other views
        button.layer.zPosition = 1000
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        let imageView = UIImageView(image: UIImage(systemName: "airplane"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Aucun voyage disponible"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        return view
    }()
    
    private var filteredVoyages: [Voyage] = []
    private var isSearching: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    private var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadVoyages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setupNavigationBar()
        // Refresh data when returning from detail view
        if !voyageService.isLoading {
            Task {
                await voyageService.fetchVoyages()
                updateUI()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Ensure button is always on top
        view.bringSubviewToFront(createButton)
    }
    
    private func setupNavigationBar() {
        title = "Voyages Disponibles"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Add reservations button
        let reservationsButton = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(reservationsButtonTapped)
        )
        reservationsButton.tintColor = .systemOrange
        navigationItem.rightBarButtonItem = reservationsButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @objc private func reservationsButtonTapped() {
        let reservationsVC = ReservationListViewController()
        navigationController?.pushViewController(reservationsVC, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0) // Lighter background for ticket contrast
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateView)
        view.addSubview(createButton)
        
        // Bring button to front to ensure it's above other views
        view.bringSubviewToFront(createButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80), // Position above tab bar
            createButton.widthAnchor.constraint(equalToConstant: 56),
            createButton.heightAnchor.constraint(equalToConstant: 56),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadVoyages() {
        Task {
            await voyageService.fetchVoyages()
            updateUI()
        }
    }
    
    @objc private func refreshVoyages() {
        Task {
            await voyageService.fetchVoyages()
            updateUI()
            refreshControl.endRefreshing()
        }
    }
    
    @objc private func createButtonTapped() {
        print("Create button tapped!")
        let createVC = CreateVoyageViewController()
        let navController = UINavigationController(rootViewController: createVC)
        navController.modalPresentationStyle = .pageSheet
        
        // Ensure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            self?.present(navController, animated: true, completion: {
                print("Create voyage modal presented")
            })
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.voyageService.isLoading {
                self.loadingIndicator.startAnimating()
                self.tableView.isHidden = true
            } else {
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = false
                
                let voyages = self.isSearching ? self.filteredVoyages : self.voyageService.voyages
                self.emptyStateView.isHidden = !voyages.isEmpty
                self.tableView.reloadData()
            }
        }
    }
    
    private func filterVoyages(for searchText: String) {
        filteredVoyages = voyageService.voyages.filter { voyage in
            return voyage.destination.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension VoyageListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let voyages = isSearching ? filteredVoyages : voyageService.voyages
        return voyages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoyageCell", for: indexPath) as! VoyageCardTableViewCell
        let voyages = isSearching ? filteredVoyages : voyageService.voyages
        cell.configure(with: voyages[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension VoyageListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let voyages = isSearching ? filteredVoyages : voyageService.voyages
        let voyage = voyages[indexPath.row]
        
        let detailVC = VoyageDetailViewController(voyage: voyage)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200 // Optimized height for new design
    }
}

// MARK: - UISearchResultsUpdating
extension VoyageListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterVoyages(for: searchBar.text ?? "")
    }
}

// MARK: - VoyageCardTableViewCell (New Professional Flight Ticket Design)
class VoyageCardTableViewCell: UITableViewCell {
    // Main ticket card
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Left side - Image and destination
    private let leftSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let voyageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 0.1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let destinationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 0.15)
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Center section - Flight details
    private let centerSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let departSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let departTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "DÉPART"
        label.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let departDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let departTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.right"))
        imageView.tintColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let returnSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let returnTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "RETOUR"
        label.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let returnDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let returnTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Right section - Price and places
    private let rightSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let placesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        voyageImageView.image = nil
    }
    
    private func setupUI() {
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        
        // Left section
        cardView.addSubview(leftSection)
        leftSection.addSubview(voyageImageView)
        leftSection.addSubview(destinationLabel)
        leftSection.addSubview(typeBadge)
        typeBadge.addSubview(typeLabel)
        
        // Center section
        cardView.addSubview(centerSection)
        centerSection.addSubview(departSection)
        centerSection.addSubview(arrowIcon)
        centerSection.addSubview(returnSection)
        
        departSection.addSubview(departTitleLabel)
        departSection.addSubview(departDateLabel)
        departSection.addSubview(departTimeLabel)
        
        returnSection.addSubview(returnTitleLabel)
        returnSection.addSubview(returnDateLabel)
        returnSection.addSubview(returnTimeLabel)
        
        // Right section
        cardView.addSubview(rightSection)
        rightSection.addSubview(priceLabel)
        rightSection.addSubview(placesLabel)
        rightSection.addSubview(chevronIcon)
        
        NSLayoutConstraint.activate([
            // Card view
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Left section
            leftSection.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            leftSection.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            leftSection.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            leftSection.widthAnchor.constraint(equalToConstant: 100),
            
            voyageImageView.topAnchor.constraint(equalTo: leftSection.topAnchor),
            voyageImageView.leadingAnchor.constraint(equalTo: leftSection.leadingAnchor),
            voyageImageView.trailingAnchor.constraint(equalTo: leftSection.trailingAnchor),
            voyageImageView.heightAnchor.constraint(equalToConstant: 70),
            
            destinationLabel.topAnchor.constraint(equalTo: voyageImageView.bottomAnchor, constant: 8),
            destinationLabel.leadingAnchor.constraint(equalTo: leftSection.leadingAnchor),
            destinationLabel.trailingAnchor.constraint(equalTo: leftSection.trailingAnchor),
            
            typeBadge.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 6),
            typeBadge.leadingAnchor.constraint(equalTo: leftSection.leadingAnchor),
            typeBadge.heightAnchor.constraint(equalToConstant: 20),
            typeBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            typeLabel.topAnchor.constraint(equalTo: typeBadge.topAnchor, constant: 4),
            typeLabel.leadingAnchor.constraint(equalTo: typeBadge.leadingAnchor, constant: 8),
            typeLabel.trailingAnchor.constraint(equalTo: typeBadge.trailingAnchor, constant: -8),
            typeLabel.bottomAnchor.constraint(equalTo: typeBadge.bottomAnchor, constant: -4),
            
            // Center section
            centerSection.leadingAnchor.constraint(equalTo: leftSection.trailingAnchor, constant: 16),
            centerSection.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            centerSection.widthAnchor.constraint(equalToConstant: 140),
            
            // Depart section
            departSection.leadingAnchor.constraint(equalTo: centerSection.leadingAnchor),
            departSection.topAnchor.constraint(equalTo: centerSection.topAnchor),
            departSection.trailingAnchor.constraint(equalTo: centerSection.trailingAnchor),
            
            departTitleLabel.topAnchor.constraint(equalTo: departSection.topAnchor),
            departTitleLabel.leadingAnchor.constraint(equalTo: departSection.leadingAnchor),
            
            departDateLabel.topAnchor.constraint(equalTo: departTitleLabel.bottomAnchor, constant: 4),
            departDateLabel.leadingAnchor.constraint(equalTo: departSection.leadingAnchor),
            departDateLabel.trailingAnchor.constraint(equalTo: departSection.trailingAnchor),
            
            departTimeLabel.topAnchor.constraint(equalTo: departDateLabel.bottomAnchor, constant: 2),
            departTimeLabel.leadingAnchor.constraint(equalTo: departSection.leadingAnchor),
            departTimeLabel.bottomAnchor.constraint(equalTo: departSection.bottomAnchor),
            
            // Arrow
            arrowIcon.centerXAnchor.constraint(equalTo: centerSection.centerXAnchor),
            arrowIcon.centerYAnchor.constraint(equalTo: centerSection.centerYAnchor),
            arrowIcon.widthAnchor.constraint(equalToConstant: 20),
            arrowIcon.heightAnchor.constraint(equalToConstant: 20),
            
            // Return section
            returnSection.leadingAnchor.constraint(equalTo: centerSection.leadingAnchor),
            returnSection.topAnchor.constraint(equalTo: departSection.bottomAnchor, constant: 20),
            returnSection.trailingAnchor.constraint(equalTo: centerSection.trailingAnchor),
            returnSection.bottomAnchor.constraint(equalTo: centerSection.bottomAnchor),
            
            returnTitleLabel.topAnchor.constraint(equalTo: returnSection.topAnchor),
            returnTitleLabel.leadingAnchor.constraint(equalTo: returnSection.leadingAnchor),
            
            returnDateLabel.topAnchor.constraint(equalTo: returnTitleLabel.bottomAnchor, constant: 4),
            returnDateLabel.leadingAnchor.constraint(equalTo: returnSection.leadingAnchor),
            returnDateLabel.trailingAnchor.constraint(equalTo: returnSection.trailingAnchor),
            
            returnTimeLabel.topAnchor.constraint(equalTo: returnDateLabel.bottomAnchor, constant: 2),
            returnTimeLabel.leadingAnchor.constraint(equalTo: returnSection.leadingAnchor),
            returnTimeLabel.bottomAnchor.constraint(equalTo: returnSection.bottomAnchor),
            
            // Right section
            rightSection.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            rightSection.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            rightSection.widthAnchor.constraint(equalToConstant: 100),
            
            priceLabel.topAnchor.constraint(equalTo: rightSection.topAnchor),
            priceLabel.leadingAnchor.constraint(equalTo: rightSection.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: rightSection.trailingAnchor),
            
            placesLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            placesLabel.leadingAnchor.constraint(equalTo: rightSection.leadingAnchor),
            placesLabel.trailingAnchor.constraint(equalTo: rightSection.trailingAnchor),
            
            chevronIcon.topAnchor.constraint(equalTo: placesLabel.bottomAnchor, constant: 12),
            chevronIcon.centerXAnchor.constraint(equalTo: rightSection.centerXAnchor),
            chevronIcon.bottomAnchor.constraint(lessThanOrEqualTo: rightSection.bottomAnchor),
            chevronIcon.widthAnchor.constraint(equalToConstant: 16),
            chevronIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with voyage: Voyage) {
        // Destination and type
        destinationLabel.text = voyage.destination
        typeLabel.text = voyage.typeDisplayName().uppercased()
        
        // Load image
        if let imageUrl = voyage.imageUrl, let url = URL(string: imageUrl) {
            loadImage(from: url)
        } else {
            voyageImageView.image = UIImage(systemName: voyage.typeIcon())
            voyageImageView.tintColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
            voyageImageView.contentMode = .scaleAspectFit
        }
        
        // Parse and format dates
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        dateFormatter.locale = Locale(identifier: "fr_FR")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        if let departDate = formatter.date(from: voyage.date_depart) {
            departDateLabel.text = dateFormatter.string(from: departDate).uppercased()
            departTimeLabel.text = timeFormatter.string(from: departDate)
        } else {
            departDateLabel.text = "N/A"
            departTimeLabel.text = "N/A"
        }
        
        if let returnDate = formatter.date(from: voyage.date_retour) {
            returnDateLabel.text = dateFormatter.string(from: returnDate).uppercased()
            returnTimeLabel.text = timeFormatter.string(from: returnDate)
        } else {
            returnDateLabel.text = "N/A"
            returnTimeLabel.text = "N/A"
        }
        
        // Price and places
        if let price = voyage.formattedPrice() {
            priceLabel.text = price
            priceLabel.isHidden = false
        } else {
            priceLabel.text = "Sur demande"
            priceLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
        
        placesLabel.text = voyage.placesInfo()
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.voyageImageView.image = UIImage(systemName: "airplane")
                    self?.voyageImageView.tintColor = UIColor(red: 0.0, green: 0.48, blue: 0.73, alpha: 1.0)
                    self?.voyageImageView.contentMode = .scaleAspectFit
                }
                return
            }
            DispatchQueue.main.async {
                self?.voyageImageView.image = image
                self?.voyageImageView.contentMode = .scaleAspectFill
                self?.voyageImageView.tintColor = nil
            }
        }.resume()
    }
}
