import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilters(sortOption: VoyageListViewController.SortOption,
                        typeFilter: String?,
                        minPrice: Double?,
                        maxPrice: Double?)
}

class FilterViewController: UIViewController {
    weak var delegate: FilterViewControllerDelegate?
    
    private var currentSortOption: VoyageListViewController.SortOption
    private var currentTypeFilter: String?
    private var minPrice: Double?
    private var maxPrice: Double?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Sort section
    private lazy var sortLabel: UILabel = {
        let label = UILabel()
        label.text = "Trier par"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var sortSegmentedControl: UISegmentedControl = {
        let items = VoyageListViewController.SortOption.allCases.map { $0.rawValue }
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // Type filter section
    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Type de voyage"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var typeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Tous", "Vol", "Croisière", "Circuit"])
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // Price filter section
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.text = "Fourchette de prix"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var minPriceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Prix minimum"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var maxPriceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Prix maximum"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    init(currentSortOption: VoyageListViewController.SortOption,
         currentTypeFilter: String?,
         minPrice: Double?,
         maxPrice: Double?) {
        self.currentSortOption = currentSortOption
        self.currentTypeFilter = currentTypeFilter
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadCurrentFilters()
    }
    
    private func setupNavigationBar() {
        title = "Filtres"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Annuler",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Appliquer",
            style: .done,
            target: self,
            action: #selector(applyTapped)
        )
        
        let resetButton = UIBarButtonItem(
            title: "Réinitialiser",
            style: .plain,
            target: self,
            action: #selector(resetTapped)
        )
        navigationItem.rightBarButtonItems = [navigationItem.rightBarButtonItem!, resetButton]
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(sortLabel)
        contentView.addSubview(sortSegmentedControl)
        contentView.addSubview(typeLabel)
        contentView.addSubview(typeSegmentedControl)
        contentView.addSubview(priceLabel)
        contentView.addSubview(minPriceTextField)
        contentView.addSubview(maxPriceTextField)
        
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
            
            sortLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            sortLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sortLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            sortSegmentedControl.topAnchor.constraint(equalTo: sortLabel.bottomAnchor, constant: 12),
            sortSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sortSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            typeLabel.topAnchor.constraint(equalTo: sortSegmentedControl.bottomAnchor, constant: 30),
            typeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            typeSegmentedControl.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 12),
            typeSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            typeSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            priceLabel.topAnchor.constraint(equalTo: typeSegmentedControl.bottomAnchor, constant: 30),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            minPriceTextField.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 12),
            minPriceTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            minPriceTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            minPriceTextField.heightAnchor.constraint(equalToConstant: 44),
            
            maxPriceTextField.topAnchor.constraint(equalTo: minPriceTextField.bottomAnchor, constant: 12),
            maxPriceTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            maxPriceTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            maxPriceTextField.heightAnchor.constraint(equalToConstant: 44),
            maxPriceTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func loadCurrentFilters() {
        // Set sort option
        if let index = VoyageListViewController.SortOption.allCases.firstIndex(of: currentSortOption) {
            sortSegmentedControl.selectedSegmentIndex = index
        }
        
        // Set type filter
        if let typeFilter = currentTypeFilter {
            switch typeFilter {
            case "Vol": typeSegmentedControl.selectedSegmentIndex = 1
            case "Croisière": typeSegmentedControl.selectedSegmentIndex = 2
            case "Circuit": typeSegmentedControl.selectedSegmentIndex = 3
            default: typeSegmentedControl.selectedSegmentIndex = 0
            }
        } else {
            typeSegmentedControl.selectedSegmentIndex = 0
        }
        
        // Set prices
        if let minPrice = minPrice {
            minPriceTextField.text = String(format: "%.0f", minPrice)
        }
        if let maxPrice = maxPrice {
            maxPriceTextField.text = String(format: "%.0f", maxPrice)
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func resetTapped() {
        sortSegmentedControl.selectedSegmentIndex = 0
        typeSegmentedControl.selectedSegmentIndex = 0
        minPriceTextField.text = ""
        maxPriceTextField.text = ""
    }
    
    @objc private func applyTapped() {
        print("🎯 Apply button tapped")
        print("   Sort segment index: \(sortSegmentedControl.selectedSegmentIndex)")
        print("   Type segment index: \(typeSegmentedControl.selectedSegmentIndex)")
        
        let sortOption = VoyageListViewController.SortOption.allCases[sortSegmentedControl.selectedSegmentIndex]
        print("   Sort option: \(sortOption.rawValue)")
        
        let typeFilter: String?
        switch typeSegmentedControl.selectedSegmentIndex {
        case 1:
            typeFilter = "Vol"
            print("   Selected type filter: 'Vol' (exact match)")
        case 2:
            typeFilter = "Croisière"
            print("   Selected type filter: 'Croisière' (exact match)")
        case 3:
            typeFilter = "Circuit"
            print("   Selected type filter: 'Circuit' (exact match)")
        default:
            typeFilter = nil
            print("   No type filter (showing all)")
        }
        
        let minPrice = Double(minPriceTextField.text ?? "")
        let maxPrice = Double(maxPriceTextField.text ?? "")
        print("   Min price: \(minPrice ?? 0)")
        print("   Max price: \(maxPrice ?? 0)")
        
        delegate?.didApplyFilters(
            sortOption: sortOption,
            typeFilter: typeFilter,
            minPrice: minPrice,
            maxPrice: maxPrice
        )
        
        dismiss(animated: true)
    }
}
