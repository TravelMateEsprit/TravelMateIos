import UIKit

protocol AIRecommendationViewControllerDelegate: AnyObject {
    func didSubmitAI(dest: String, budget: Double, type: String)
}

class AIRecommendationViewController: UIViewController {
    weak var delegate: AIRecommendationViewControllerDelegate?
    private var initialType: String
    private let voyageService = VoyageService.shared
    private struct AIRecommendation: Decodable { let voyageId: String; let score: Double; let reason: String }
    private var currentResults: [Voyage] = []
    private var reasonById: [String: String] = [:]
    private var lastSearchBudget: Double = 0
    private var lastSearchDestination: String = ""
    private var lastSearchType: String = ""

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

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "🤖 Recommandation AI"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choisis ta destination, ton budget et le type"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var destinationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Destination"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        let iconView = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
        iconView.tintColor = .systemGray
        iconView.frame = CGRect(x: 0, y: 0, width: 40, height: 24)
        iconView.contentMode = .center
        textField.leftView = iconView
        textField.leftViewMode = .always
        return textField
    }()

    private lazy var budgetTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Budget max (TND)"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        let iconView = UIImageView(image: UIImage(systemName: "dollarsign.circle"))
        iconView.tintColor = .systemGray
        iconView.frame = CGRect(x: 0, y: 0, width: 40, height: 24)
        iconView.contentMode = .center
        textField.leftView = iconView
        textField.leftViewMode = .always
        textField.inputAccessoryView = createToolbar()
        return textField
    }()

    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Type"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var typeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["vol", "hotel", "location de voiture"])
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔍 Rechercher", for: .normal)
        button.backgroundColor = .systemOrange
        button.tintColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        return button
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var resultsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Résultats"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    private lazy var resultsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(initialType: String) {
        self.initialType = initialType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        preloadValues()
    }

    private func setupNavigationBar() {
        title = "AI"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Annuler",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Rechercher",
            style: .done,
            target: self,
            action: #selector(submitTapped)
        )
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(destinationTextField)
        contentView.addSubview(budgetTextField)
        contentView.addSubview(typeLabel)
        contentView.addSubview(typeSegmentedControl)
        contentView.addSubview(submitButton)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(resultsTitleLabel)
        contentView.addSubview(resultsStackView)

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
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            destinationTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            destinationTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            destinationTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            destinationTextField.heightAnchor.constraint(equalToConstant: 44),

            budgetTextField.topAnchor.constraint(equalTo: destinationTextField.bottomAnchor, constant: 12),
            budgetTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            budgetTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            budgetTextField.heightAnchor.constraint(equalToConstant: 44),

            typeLabel.topAnchor.constraint(equalTo: budgetTextField.bottomAnchor, constant: 24),
            typeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            typeSegmentedControl.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 12),
            typeSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            typeSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            submitButton.topAnchor.constraint(equalTo: typeSegmentedControl.bottomAnchor, constant: 30),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            loadingIndicator.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 16),
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            resultsTitleLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 16),
            resultsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            resultsStackView.topAnchor.constraint(equalTo: resultsTitleLabel.bottomAnchor, constant: 12),
            resultsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            resultsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    private func preloadValues() {
        destinationTextField.text = "Paris"
        budgetTextField.text = "2500"
        let items = ["vol", "hotel", "location de voiture"]
        if let idx = items.firstIndex(of: initialType) {
            typeSegmentedControl.selectedSegmentIndex = idx
        } else {
            typeSegmentedControl.selectedSegmentIndex = 0
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func submitTapped() {
        let dest = destinationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let budget = Double(budgetTextField.text ?? "") ?? 0
        let typeIndex = max(typeSegmentedControl.selectedSegmentIndex, 0)
        let type = ["vol", "hotel", "location de voiture"][typeIndex]

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        lastSearchDestination = dest
        lastSearchBudget = budget
        lastSearchType = type
        fetchRecommendations(dest: dest, budget: budget, type: type)
    }

    private func fetchRecommendations(dest: String, budget: Double, type: String) {
        resultsTitleLabel.isHidden = true
        clearResults()
        loadingIndicator.startAnimating()
        Task {
            guard let url = URL(string: Config.apiBaseURL + "/voyages/recommend") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = AuthService.shared.accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let body: [String: Any] = ["destination": dest, "maxBudget": budget, "type": type]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                if let http = response as? HTTPURLResponse, http.statusCode == 401 {
                    await MainActor.run {
                        loadingIndicator.stopAnimating()
                        let alert = UIAlertController(title: "Non autorisé", message: "Votre session a expiré. Veuillez vous reconnecter.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        present(alert, animated: true)
                    }
                    return
                }
                var recs: [AIRecommendation] = []
                do {
                    recs = try JSONDecoder().decode([AIRecommendation].self, from: data)
                } catch {
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        recs = json.compactMap { dict in
                            let id = (dict["voyageId"] as? String)
                                ?? (dict["voyage_id"] as? String)
                                ?? (dict["id_voyage"] as? String)
                                ?? (dict["_id"] as? String)
                            let scoreVal: Double = {
                                if let d = dict["score"] as? Double { return d }
                                if let i = dict["score"] as? Int { return Double(i) }
                                if let s = dict["score"] as? String { return Double(s) ?? 0 }
                                return 0
                            }()
                            let reason = (dict["reason"] as? String) ?? ""
                            if let id = id { return AIRecommendation(voyageId: id, score: scoreVal, reason: reason) }
                            return nil
                        }
                    } else {
                        throw NSError(domain: "AI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Format inattendu: \(responseString)"])
                    }
                }
                let idsOrdered = recs.map { $0.voyageId }
                let scoreById = Dictionary(uniqueKeysWithValues: recs.map { ($0.voyageId, $0.score) })
                var voyages: [Voyage] = []
                for id in idsOrdered {
                    if let local = voyageService.voyages.first(where: { $0._id == id }) {
                        voyages.append(local)
                    } else {
                        if let fetched = try? await voyageService.fetchVoyage(id: id) {
                            voyages.append(fetched)
                        }
                    }
                }
                let sorted = voyages.sorted { (v1, v2) -> Bool in
                    (scoreById[v1._id] ?? 0) > (scoreById[v2._id] ?? 0)
                }
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    resultsTitleLabel.isHidden = false
                    currentResults = sorted
                    reasonById = Dictionary(uniqueKeysWithValues: recs.map { ($0.voyageId, $0.reason) })
                    renderResults(sorted)
                }
            } catch {
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    let alert = UIAlertController(title: "Erreur AI", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
                }
            }
        }
    }

    private func clearResults() {
        for v in resultsStackView.arrangedSubviews { v.removeFromSuperview() }
    }

    private func renderResults(_ voyages: [Voyage]) {
        clearResults()
        for voyage in voyages {
            let card = UIView()
            card.translatesAutoresizingMaskIntoConstraints = false
            card.backgroundColor = .white
            card.layer.cornerRadius = 12
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOffset = CGSize(width: 0, height: 2)
            card.layer.shadowRadius = 8
            card.layer.shadowOpacity = 0.1

            let title = UILabel()
            title.translatesAutoresizingMaskIntoConstraints = false
            title.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            title.textColor = .black
            title.text = voyage.destination

            let subtitle = UILabel()
            subtitle.translatesAutoresizingMaskIntoConstraints = false
            subtitle.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            subtitle.textColor = .secondaryLabel
            subtitle.text = voyage.typeDisplayName()

            let reasonLabel = UILabel()
            reasonLabel.translatesAutoresizingMaskIntoConstraints = false
            reasonLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            reasonLabel.textColor = .secondaryLabel
            reasonLabel.numberOfLines = 0
            let reasonText = reasonById[voyage._id]
            reasonLabel.text = reasonText == nil || reasonText == "" ? "Raison AI indisponible" : "Raison AI: \(reasonText!)"

            let detailsLabel = UILabel()
            detailsLabel.translatesAutoresizingMaskIntoConstraints = false
            detailsLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            detailsLabel.textColor = .secondaryLabel
            detailsLabel.numberOfLines = 0
            let budgetText = lastSearchBudget > 0 ? String(format: "%.0f", lastSearchBudget) : "N/A"
            let priceText = voyage.formattedPrice() ?? "N/A"
            let durationText = voyage.formattedDuration()
            let placesText = voyage.placesInfo()
            detailsLabel.text = "Plus de détails:\n• Budget max: \(budgetText)\n• Prix estimé: \(priceText)\n• Durée: \(durationText)\n• Places: \(placesText)"

            let price = UILabel()
            price.translatesAutoresizingMaskIntoConstraints = false
            price.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            price.textColor = .systemOrange
            price.text = voyage.formattedPrice() ?? "Sur demande"

            card.addSubview(title)
            card.addSubview(subtitle)
            card.addSubview(reasonLabel)
            card.addSubview(detailsLabel)
            card.addSubview(price)

            NSLayoutConstraint.activate([
                title.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
                title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

                subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
                subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
                subtitle.trailingAnchor.constraint(equalTo: title.trailingAnchor),

                reasonLabel.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 8),
                reasonLabel.leadingAnchor.constraint(equalTo: title.leadingAnchor),
                reasonLabel.trailingAnchor.constraint(equalTo: title.trailingAnchor),

                detailsLabel.topAnchor.constraint(equalTo: reasonLabel.bottomAnchor, constant: 8),
                detailsLabel.leadingAnchor.constraint(equalTo: title.leadingAnchor),
                detailsLabel.trailingAnchor.constraint(equalTo: title.trailingAnchor),

                price.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 10),
                price.leadingAnchor.constraint(equalTo: title.leadingAnchor),
                price.trailingAnchor.constraint(equalTo: title.trailingAnchor),
                price.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
            ])

            resultsStackView.addArrangedSubview(card)
        }
    }

    private func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: false)
        return toolbar
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
