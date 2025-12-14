import UIKit

protocol InsuranceFiltersDelegate: AnyObject {
    func didApplyFilters(_ filters: InsuranceSearchFilters)
}

class InsuranceFiltersViewController: UIViewController {
    weak var delegate: InsuranceFiltersDelegate?
    private var currentFilters: InsuranceSearchFilters
    
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
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Rechercher par nom..."
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let minPriceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Prix minimum"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let maxPriceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Prix maximum"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let durationPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let durationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Duree"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let minRatingSegment: UISegmentedControl = {
        let items = ["Tous", "1+", "2+", "3+", "4+", "5"]
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    private let sortBySegment: UISegmentedControl = {
        let items = ["Recent", "Prix", "Note", "Nom"]
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    private let sortOrderSegment: UISegmentedControl = {
        let items = ["Croissant", "Decroissant"]
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Appliquer", for: .normal)
        button.backgroundColor = .primaryColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reinitialiser", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let durations = ["", "1 mois", "3 mois", "6 mois", "1 an", "voyage unique"]
    
    init(currentFilters: InsuranceSearchFilters = InsuranceSearchFilters()) {
        self.currentFilters = currentFilters
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPicker()
        loadCurrentFilters()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        title = "Filtres"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(createSectionLabel(text: "Recherche"))
        contentView.addSubview(searchTextField)
        
        contentView.addSubview(createSectionLabel(text: "Prix"))
        contentView.addSubview(minPriceTextField)
        contentView.addSubview(maxPriceTextField)
        
        contentView.addSubview(createSectionLabel(text: "Duree"))
        contentView.addSubview(durationTextField)
        
        contentView.addSubview(createSectionLabel(text: "Note minimum"))
        contentView.addSubview(minRatingSegment)
        
        contentView.addSubview(createSectionLabel(text: "Trier par"))
        contentView.addSubview(sortBySegment)
        
        contentView.addSubview(createSectionLabel(text: "Ordre"))
        contentView.addSubview(sortOrderSegment)
        
        contentView.addSubview(resetButton)
        contentView.addSubview(applyButton)
        
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupPicker() {
        durationPicker.delegate = self
        durationPicker.dataSource = self
        durationTextField.inputView = durationPicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(durationDoneTapped))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: false)
        durationTextField.inputAccessoryView = toolbar
    }
    
    private func createSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func setupConstraints() {
        let labels = contentView.subviews.compactMap { $0 as? UILabel }
        
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
        ])
        
        var previousView: UIView = contentView
        var isFirstLabel = true
        
        for subview in contentView.subviews {
            if let label = subview as? UILabel {
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: isFirstLabel ? contentView.topAnchor : previousView.bottomAnchor, constant: isFirstLabel ? 20 : 24),
                    label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
                ])
                isFirstLabel = false
                previousView = label
            } else if subview == searchTextField {
                NSLayoutConstraint.activate([
                    searchTextField.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 8),
                    searchTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    searchTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    searchTextField.heightAnchor.constraint(equalToConstant: 44)
                ])
                previousView = searchTextField
            } else if subview == minPriceTextField {
                NSLayoutConstraint.activate([
                    minPriceTextField.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 8),
                    minPriceTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    minPriceTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.43),
                    minPriceTextField.heightAnchor.constraint(equalToConstant: 44)
                ])
                previousView = minPriceTextField
            } else if subview == maxPriceTextField {
                NSLayoutConstraint.activate([
                    maxPriceTextField.centerYAnchor.constraint(equalTo: minPriceTextField.centerYAnchor),
                    maxPriceTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    maxPriceTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.43),
                    maxPriceTextField.heightAnchor.constraint(equalToConstant: 44)
                ])
            } else if subview == durationTextField {
                NSLayoutConstraint.activate([
                    durationTextField.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 8),
                    durationTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    durationTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    durationTextField.heightAnchor.constraint(equalToConstant: 44)
                ])
                previousView = durationTextField
            } else if subview == minRatingSegment {
                NSLayoutConstraint.activate([
                    minRatingSegment.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 8),
                    minRatingSegment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    minRatingSegment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
                ])
                previousView = minRatingSegment
            } else if subview == sortBySegment {
                NSLayoutConstraint.activate([
                    sortBySegment.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 8),
                    sortBySegment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    sortBySegment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
                ])
                previousView = sortBySegment
            } else if subview == sortOrderSegment {
                NSLayoutConstraint.activate([
                    sortOrderSegment.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 8),
                    sortOrderSegment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    sortOrderSegment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
                ])
                previousView = sortOrderSegment
            }
        }
        
        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 30),
            resetButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            applyButton.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 16),
            applyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            applyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            applyButton.heightAnchor.constraint(equalToConstant: 50),
            applyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func loadCurrentFilters() {
        searchTextField.text = currentFilters.search
        
        if let minPrice = currentFilters.minPrice {
            minPriceTextField.text = String(format: "%.0f", minPrice)
        }
        
        if let maxPrice = currentFilters.maxPrice {
            maxPriceTextField.text = String(format: "%.0f", maxPrice)
        }
        
        durationTextField.text = currentFilters.duration
        
        if let minRating = currentFilters.minRating {
            minRatingSegment.selectedSegmentIndex = minRating
        }
        
        if let sortBy = currentFilters.sortBy {
            switch sortBy {
            case "createdAt": sortBySegment.selectedSegmentIndex = 0
            case "price": sortBySegment.selectedSegmentIndex = 1
            case "averageRating": sortBySegment.selectedSegmentIndex = 2
            case "name": sortBySegment.selectedSegmentIndex = 3
            default: sortBySegment.selectedSegmentIndex = 0
            }
        }
        
        if let sortOrder = currentFilters.sortOrder {
            sortOrderSegment.selectedSegmentIndex = sortOrder == "asc" ? 0 : 1
        }
    }
    
    @objc private func durationDoneTapped() {
        durationTextField.resignFirstResponder()
    }
    
    @objc private func applyTapped() {
        var filters = InsuranceSearchFilters()
        
        let search = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let search = search, !search.isEmpty {
            filters.search = search
        }
        
        if let minPriceText = minPriceTextField.text, let minPrice = Double(minPriceText) {
            filters.minPrice = minPrice
        }
        
        if let maxPriceText = maxPriceTextField.text, let maxPrice = Double(maxPriceText) {
            filters.maxPrice = maxPrice
        }
        
        let duration = durationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let duration = duration, !duration.isEmpty {
            filters.duration = duration
        }
        
        if minRatingSegment.selectedSegmentIndex > 0 {
            filters.minRating = minRatingSegment.selectedSegmentIndex
        }
        
        switch sortBySegment.selectedSegmentIndex {
        case 0: filters.sortBy = "createdAt"
        case 1: filters.sortBy = "price"
        case 2: filters.sortBy = "averageRating"
        case 3: filters.sortBy = "name"
        default: filters.sortBy = "createdAt"
        }
        
        filters.sortOrder = sortOrderSegment.selectedSegmentIndex == 0 ? "asc" : "desc"
        
        delegate?.didApplyFilters(filters)
        dismiss(animated: true)
    }
    
    @objc private func resetTapped() {
        searchTextField.text = ""
        minPriceTextField.text = ""
        maxPriceTextField.text = ""
        durationTextField.text = ""
        minRatingSegment.selectedSegmentIndex = 0
        sortBySegment.selectedSegmentIndex = 0
        sortOrderSegment.selectedSegmentIndex = 0
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

extension InsuranceFiltersViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return durations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return durations[row].isEmpty ? "Toutes" : durations[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        durationTextField.text = durations[row]
    }
}
