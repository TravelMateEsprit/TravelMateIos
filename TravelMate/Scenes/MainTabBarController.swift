import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupAppearance()
        
        // Observe language changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageDidChange),
            name: LanguageManager.languageDidChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func languageDidChange() {
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        guard let currentUser = AuthService.shared.currentUser else {
            print("⚠️ No logged in user found")
            return
        }
        
        // Common view controllers
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: localized("tab.home"),
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(
            title: localized("tab.profile"),
            image: UIImage(systemName: "person.circle"),
            selectedImage: UIImage(systemName: "person.circle.fill")
        )
        
        // Create navigation controllers based on user type
        if currentUser.userType == .agence {
            // AGENCY ROLE TABS
            setupAgencyTabs(homeVC: homeVC, profileVC: profileVC)
        } else {
            // USER ROLE TABS
            setupUserTabs(homeVC: homeVC, profileVC: profileVC)
        }
    }
    
    // MARK: - Agency Tabs Setup
    private func setupAgencyTabs(homeVC: UIViewController, profileVC: UIViewController) {
        // 1. Voyages/Offres (Colleague's module - keep it!)
        let offersVC = VoyageListViewController()
        offersVC.tabBarItem = UITabBarItem(
            title: localized("tab.voyages"),
            image: UIImage(systemName: "airplane"),
            selectedImage: UIImage(systemName: "airplane.fill")
        )
        
        // 2. Packs Management (YOUR module - Agency's own packs)
        let packsVC = PacksListViewController()
        packsVC.tabBarItem = UITabBarItem(
            title: localized("tab.myPacks"),
            image: UIImage(systemName: "suitcase"),
            selectedImage: UIImage(systemName: "suitcase.fill")
        )
        
        // 3. Reservations Management (YOUR module)
        let reservationsVC = AgencyReservationsViewController()
        reservationsVC.tabBarItem = UITabBarItem(
            title: localized("tab.reservations"),
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.badge.checkmark")
        )
        
        // 4. Groups (Colleague's module - keep it!)
        let groupsVC = GroupsViewController()
        groupsVC.tabBarItem = UITabBarItem(
            title: localized("tab.groups"),
            image: UIImage(systemName: "person.3"),
            selectedImage: UIImage(systemName: "person.3.fill")
        )
        
        // 5. Messages/Conversations (YOUR module)
        let messagesVC = ConversationsListViewController()
        messagesVC.tabBarItem = UITabBarItem(
            title: localized("tab.messages"),
            image: UIImage(systemName: "message"),
            selectedImage: UIImage(systemName: "message.fill")
        )
        
        // Navigation Controllers
        let homeNav = UINavigationController(rootViewController: homeVC)
        let offersNav = UINavigationController(rootViewController: offersVC)
        let packsNav = UINavigationController(rootViewController: packsVC)
        let reservationsNav = UINavigationController(rootViewController: reservationsVC)
        let groupsNav = UINavigationController(rootViewController: groupsVC)
        let messagesNav = UINavigationController(rootViewController: messagesVC)
        let profileNav = UINavigationController(rootViewController: profileVC)
        
        // Setup appearance
        [homeNav, offersNav, packsNav, reservationsNav, groupsNav, messagesNav, profileNav]
            .forEach { setupNavigationBarAppearance(for: $0) }
        
        // Set view controllers - ALL modules included!
        viewControllers = [homeNav, offersNav, packsNav, reservationsNav, groupsNav, messagesNav, profileNav]
    }
    
    // MARK: - User Tabs Setup
    private func setupUserTabs(homeVC: UIViewController, profileVC: UIViewController) {
        // 1. Voyages/Offres (Colleague's module - keep it!)
        let offersVC = VoyageListViewController()
        offersVC.tabBarItem = UITabBarItem(
            title: localized("tab.voyages"),
            image: UIImage(systemName: "airplane"),
            selectedImage: UIImage(systemName: "airplane.fill")
        )
        
        // 2. Pack Browsing (YOUR module - Tinder-style)
        let browseVC = PacksBrowseViewController()
        browseVC.tabBarItem = UITabBarItem(
            title: localized("tab.packs"),
            image: UIImage(systemName: "suitcase"),
            selectedImage: UIImage(systemName: "suitcase.fill")
        )
        
        // 3. Favorites (YOUR module)
        let favoritesVC = FavoritesViewController()
        favoritesVC.tabBarItem = UITabBarItem(
            title: localized("tab.favorites"),
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
        
        // 4. User's Reservations (YOUR module)
        let reservationsVC = UserReservationsViewController()
        reservationsVC.tabBarItem = UITabBarItem(
            title: localized("tab.reservations"),
            image: UIImage(systemName: "bag"),
            selectedImage: UIImage(systemName: "bag.fill")
        )
        
        // 5. Groups (Colleague's module - keep it!)
        let groupsVC = GroupsViewController()
        groupsVC.tabBarItem = UITabBarItem(
            title: localized("tab.groups"),
            image: UIImage(systemName: "person.3"),
            selectedImage: UIImage(systemName: "person.3.fill")
        )
        
        // 6. Insurances (Colleague's module - keep it!)
        let insurancesVC = InsurancesViewController()
        insurancesVC.tabBarItem = UITabBarItem(
            title: localized("tab.insurances"),
            image: UIImage(systemName: "shield"),
            selectedImage: UIImage(systemName: "shield.fill")
        )
        
        // 7. Messages/Conversations (YOUR module)
        let messagesVC = ConversationsListViewController()
        messagesVC.tabBarItem = UITabBarItem(
            title: localized("tab.messages"),
            image: UIImage(systemName: "message"),
            selectedImage: UIImage(systemName: "message.fill")
        )
        
        // Navigation Controllers
        let homeNav = UINavigationController(rootViewController: homeVC)
        let offersNav = UINavigationController(rootViewController: offersVC)
        let browseNav = UINavigationController(rootViewController: browseVC)
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)
        let reservationsNav = UINavigationController(rootViewController: reservationsVC)
        let groupsNav = UINavigationController(rootViewController: groupsVC)
        let insurancesNav = UINavigationController(rootViewController: insurancesVC)
        let messagesNav = UINavigationController(rootViewController: messagesVC)
        let profileNav = UINavigationController(rootViewController: profileVC)
        
        // Setup appearance
        [homeNav, offersNav, browseNav, favoritesNav, reservationsNav, groupsNav, insurancesNav, messagesNav, profileNav]
            .forEach { setupNavigationBarAppearance(for: $0) }
        
        // Set view controllers - ALL modules included!
        viewControllers = [homeNav, offersNav, browseNav, favoritesNav, reservationsNav, groupsNav, insurancesNav, messagesNav, profileNav]
    }

    
    
    // MARK: - NavigationBar Style
    private func setupNavigationBarAppearance(for navController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        
        navController.navigationBar.standardAppearance = appearance
        navController.navigationBar.scrollEdgeAppearance = appearance
        
        navController.navigationBar.tintColor = .primaryColor
    }
    
    
    // MARK: - TabBar Style
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = .systemGray
        itemAppearance.selected.iconColor = .primaryColor
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.primaryColor]
        
        appearance.stackedLayoutAppearance = itemAppearance
        
        tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
