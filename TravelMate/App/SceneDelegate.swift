import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Initialize language manager (will load saved language)
        _ = LanguageManager.shared
        
        window = UIWindow(windowScene: windowScene)
        
        let splashVC = SplashViewController()
        window?.rootViewController = splashVC
        window?.makeKeyAndVisible()
    }
}
