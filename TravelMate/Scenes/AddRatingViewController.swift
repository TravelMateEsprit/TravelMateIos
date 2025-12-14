import UIKit

protocol AddRatingDelegate: AnyObject {
    func didAddOrUpdateRating()
}

class AddRatingViewController: UIViewController {
    private let insuranceId: String
    private var existingRating: Rating?
    private let insuranceService = InsuranceService.shared
    
    weak var delegate: AddRatingDelegate?
    
    private var selectedRating: Int = 0
    
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Votre avis"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Comment evaluez-vous cette assurance ?"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let commentTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let commentPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Partagez votre experience (optionnel)"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .systemGray3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enregistrer", for: .normal)
        button.backgroundColor = .primaryColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Supprimer mon avis", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(insuranceId: String, existingRating: Rating?) {
        self.insuranceId = insuranceId
        self.existingRating = existingRating
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStars()
        
        if let existing = existingRating {
            selectedRating = existing.rating
            commentTextView.text = existing.comment
            updateStars()
            
            if let comment = existing.comment, !comment.isEmpty {
                commentPlaceholder.isHidden = true
            }
        }
        
        commentTextView.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        title = existingRating == nil ? "Donner mon avis" : "Modifier mon avis"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(starsStackView)
        contentView.addSubview(commentTextView)
        commentTextView.addSubview(commentPlaceholder)
        contentView.addSubview(saveButton)
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            starsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            starsStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            starsStackView.heightAnchor.constraint(equalToConstant: 50),
            
            commentTextView.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 30),
            commentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            commentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            commentTextView.heightAnchor.constraint(equalToConstant: 120),
            
            commentPlaceholder.topAnchor.constraint(equalTo: commentTextView.topAnchor, constant: 12),
            commentPlaceholder.leadingAnchor.constraint(equalTo: commentTextView.leadingAnchor, constant: 16),
            
            saveButton.topAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        if existingRating != nil {
            contentView.addSubview(deleteButton)
            deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                deleteButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
                deleteButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
            ])
        } else {
            NSLayoutConstraint.activate([
                saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
            ])
        }
    }
    
    private func setupStars() {
        for i in 1...5 {
            let starButton = UIButton(type: .system)
            starButton.tag = i
            starButton.setImage(UIImage(systemName: "star"), for: .normal)
            starButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
            starButton.tintColor = .systemYellow
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starsStackView.addArrangedSubview(starButton)
        }
    }
    
    private func updateStars() {
        for (index, view) in starsStackView.arrangedSubviews.enumerated() {
            if let button = view as? UIButton {
                button.isSelected = (index + 1) <= selectedRating
            }
        }
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStars()
    }
    
    @objc private func saveTapped() {
        guard selectedRating > 0 else {
            showAlert(title: "Erreur", message: "Veuillez selectionner une note")
            return
        }
        
        let comment = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            do {
                if existingRating != nil {
                    let request = UpdateRatingRequest(
                        rating: selectedRating,
                        comment: comment.isEmpty ? nil : comment
                    )
                    _ = try await insuranceService.updateRating(insuranceId: insuranceId, request: request)
                } else {
                    let request = CreateRatingRequest(
                        rating: selectedRating,
                        comment: comment.isEmpty ? nil : comment
                    )
                    _ = try await insuranceService.createRating(insuranceId: insuranceId, request: request)
                }
                
                delegate?.didAddOrUpdateRating()
                dismiss(animated: true)
            } catch {
                showAlert(title: "Erreur", message: "Impossible d'enregistrer votre avis")
            }
        }
    }
    
    @objc private func deleteTapped() {
        let alert = UIAlertController(title: "Confirmation", message: "Voulez-vous vraiment supprimer votre avis ?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "Supprimer", style: .destructive) { [weak self] _ in
            self?.performDelete()
        })
        
        present(alert, animated: true)
    }
    
    private func performDelete() {
        Task {
            do {
                _ = try await insuranceService.deleteRating(insuranceId: insuranceId)
                delegate?.didAddOrUpdateRating()
                dismiss(animated: true)
            } catch {
                showAlert(title: "Erreur", message: "Impossible de supprimer votre avis")
            }
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddRatingViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        commentPlaceholder.isHidden = !textView.text.isEmpty
    }
}
