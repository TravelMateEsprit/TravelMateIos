import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupAppearance()
    }
    
    private func setupViewControllers() {
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: "Accueil",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        let insurancesVC = InsurancesViewController()
        insurancesVC.tabBarItem = UITabBarItem(
            title: "Assurances",
            image: UIImage(systemName: "shield"),
            selectedImage: UIImage(systemName: "shield.fill")
        )
        
        let offersVC = VoyageListViewController()
        offersVC.tabBarItem = UITabBarItem(
            title: "Offres",
            image: UIImage(systemName: "tag"),
            selectedImage: UIImage(systemName: "tag.fill")
        )
        
        let groupsVC = GroupsViewController()
        groupsVC.tabBarItem = UITabBarItem(
            title: "Groupes",
            image: UIImage(systemName: "person.3"),
            selectedImage: UIImage(systemName: "person.3.fill")
        )
        
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(
            title: "Profil",
            image: UIImage(systemName: "person.circle"),
            selectedImage: UIImage(systemName: "person.circle.fill")
        )
        
        let homeNav = UINavigationController(rootViewController: homeVC)
        let insurancesNav = UINavigationController(rootViewController: insurancesVC)
        let offersNav = UINavigationController(rootViewController: offersVC)
        let groupsNav = UINavigationController(rootViewController: groupsVC)
        let profileNav = UINavigationController(rootViewController: profileVC)
        
        setupNavigationBarAppearance(for: homeNav)
        setupNavigationBarAppearance(for: insurancesNav)
        setupNavigationBarAppearance(for: offersNav)
        setupNavigationBarAppearance(for: groupsNav)
        setupNavigationBarAppearance(for: profileNav)
        
        viewControllers = [homeNav, insurancesNav, offersNav, groupsNav, profileNav]
    }
    
    private func setupNavigationBarAppearance(for navController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        appearance.shadowColor = .clear
        
        navController.navigationBar.standardAppearance = appearance
        navController.navigationBar.scrollEdgeAppearance = appearance
        navController.navigationBar.tintColor = .primaryColor
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = .systemGray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        itemAppearance.selected.iconColor = .primaryColor
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.primaryColor]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowRadius = 4
        tabBar.layer.shadowOpacity = 0.1
    }
}
