import Foundation

class LanguageManager {
    static let shared = LanguageManager()
    
    private let languageKey = "AppLanguage"
    
    // Notification name for language changes
    static let languageDidChangeNotification = Notification.Name("LanguageDidChange")
    
    // Bundle for the selected language
    private var languageBundle: Bundle?
    
    private init() {
        // Initialize with saved language
        updateLanguageBundle()
    }
    
    var currentLanguage: AppLanguage {
        get {
            if let languageString = UserDefaults.standard.string(forKey: languageKey),
               let language = AppLanguage(rawValue: languageString) {
                return language
            }
            return .french // Default to French
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: languageKey)
            UserDefaults.standard.synchronize()
            
            // Update the language bundle
            updateLanguageBundle()
            
            // Post notification to update UI
            NotificationCenter.default.post(name: LanguageManager.languageDidChangeNotification, object: nil)
        }
    }
    
    private func updateLanguageBundle() {
        let language = currentLanguage.localeIdentifier
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            languageBundle = bundle
        } else {
            languageBundle = Bundle.main
        }
    }
    
    func localizedString(_ key: String, comment: String = "") -> String {
        if let bundle = languageBundle {
            return bundle.localizedString(forKey: key, value: nil, table: nil)
        }
        return NSLocalizedString(key, comment: comment)
    }
}

// Extension to make NSLocalizedString use LanguageManager
extension String {
    var localized: String {
        return LanguageManager.shared.localizedString(self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: LanguageManager.shared.localizedString(self), arguments: arguments)
    }
}

// Global helper function for easy localization
func localized(_ key: String, comment: String = "") -> String {
    return LanguageManager.shared.localizedString(key, comment: comment)
}
