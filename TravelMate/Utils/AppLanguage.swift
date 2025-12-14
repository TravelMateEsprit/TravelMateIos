import Foundation

enum AppLanguage: String, CaseIterable {
    case french = "fr"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .french:
            return "Français"
        case .english:
            return "English"
        }
    }
    
    var localeIdentifier: String {
        return self.rawValue
    }
}
