import UIKit

class GroupsViewController: UIViewController {
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
        imageView.image = UIImage(systemName: "person.3.fill")
        imageView.tintColor = UIColor.systemPurple.withAlphaComponent(0.3)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Mes Groupes"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Voyagez en groupe et partagez vos expériences"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createGroupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Créer un nouveau groupe", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemPurple
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.systemPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var groupsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadGroups()
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
        title = "Groupes"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(createGroupButton)
        contentView.addSubview(groupsStackView)
        
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
            
            createGroupButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            createGroupButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            createGroupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            createGroupButton.heightAnchor.constraint(equalToConstant: 56),
            
            groupsStackView.topAnchor.constraint(equalTo: createGroupButton.bottomAnchor, constant: 32),
            groupsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            groupsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            groupsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        createGroupButton.addTarget(self, action: #selector(createGroupTapped), for: .touchUpInside)
        createGroupButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        createGroupButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside])
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
    
    @objc private func createGroupTapped() {
        showAlert(title: "Nouveau groupe", message: "Fonctionnalité à venir")
    }
    
    private func loadGroups() {
        let groups = [
            ("Voyage Tokyo 2024", "8 membres", "15 Mai - 25 Mai", UIColor.systemPink),
            ("Road Trip Europe", "12 membres", "1 Juin - 20 Juin", UIColor.systemBlue),
            ("Safari Kenya", "6 membres", "10 Juil - 22 Juil", UIColor.systemGreen)
        ]
        
        for group in groups {
            let card = createGroupCard(name: group.0, members: group.1, dates: group.2, color: group.3)
            groupsStackView.addArrangedSubview(card)
        }
    }
    
    private func createGroupCard(name: String, members: String, dates: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.1
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let colorStrip = UIView()
        colorStrip.backgroundColor = color
        colorStrip.layer.cornerRadius = 4
        colorStrip.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let membersIcon = UIImageView(image: UIImage(systemName: "person.2.fill"))
        membersIcon.tintColor = .systemGray
        membersIcon.contentMode = .scaleAspectFit
        membersIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let membersLabel = UILabel()
        membersLabel.text = members
        membersLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        membersLabel.textColor = .systemGray
        membersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let calendarIcon = UIImageView(image: UIImage(systemName: "calendar"))
        calendarIcon.tintColor = .systemGray
        calendarIcon.contentMode = .scaleAspectFit
        calendarIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let datesLabel = UILabel()
        datesLabel.text = dates
        datesLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        datesLabel.textColor = .systemGray
        datesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let viewButton = UIButton(type: .system)
        viewButton.setTitle("Voir", for: .normal)
        viewButton.setTitleColor(color, for: .normal)
        viewButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        viewButton.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(colorStrip)
        container.addSubview(nameLabel)
        container.addSubview(membersIcon)
        container.addSubview(membersLabel)
        container.addSubview(calendarIcon)
        container.addSubview(datesLabel)
        container.addSubview(viewButton)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 120),
            
            colorStrip.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            colorStrip.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            colorStrip.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            colorStrip.widthAnchor.constraint(equalToConstant: 4),
            
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: colorStrip.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: viewButton.leadingAnchor, constant: -8),
            
            membersIcon.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            membersIcon.leadingAnchor.constraint(equalTo: colorStrip.trailingAnchor, constant: 16),
            membersIcon.widthAnchor.constraint(equalToConstant: 16),
            membersIcon.heightAnchor.constraint(equalToConstant: 16),
            
            membersLabel.centerYAnchor.constraint(equalTo: membersIcon.centerYAnchor),
            membersLabel.leadingAnchor.constraint(equalTo: membersIcon.trailingAnchor, constant: 6),
            
            calendarIcon.topAnchor.constraint(equalTo: membersIcon.bottomAnchor, constant: 8),
            calendarIcon.leadingAnchor.constraint(equalTo: colorStrip.trailingAnchor, constant: 16),
            calendarIcon.widthAnchor.constraint(equalToConstant: 16),
            calendarIcon.heightAnchor.constraint(equalToConstant: 16),
            
            datesLabel.centerYAnchor.constraint(equalTo: calendarIcon.centerYAnchor),
            datesLabel.leadingAnchor.constraint(equalTo: calendarIcon.trailingAnchor, constant: 6),
            
            viewButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            viewButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        
        return container
    }
}
