import UIKit

extension UIColor {
    // MARK: - Primary Brand Colors (Blue theme inspired by travel apps)
    static let primaryColor = UIColor(hex: "#1E88E5") // Modern blue
    static let primaryDark = UIColor(hex: "#1565C0") // Darker blue
    static let primaryLight = UIColor(hex: "#64B5F6") // Light blue
    
    // MARK: - Secondary Colors (Warm accent)
    static let secondaryColor = UIColor(hex: "#FF9800") // Warm orange
    static let secondaryLight = UIColor(hex: "#FFB74D") // Light orange
    
    // MARK: - Neutral Colors
    static let accentColor = UIColor(hex: "#00BCD4") // Cyan accent
    
    // MARK: - Favorite Colors
    static let favoriteColor = UIColor(hex: "#FFC107") // Amber
    static let favoriteFilledColor = UIColor(hex: "#FF9800") // Orange
    
    // MARK: - Background Colors
    static let backgroundLight = UIColor(hex: "#F5F7FA")
    static let backgroundDark = UIColor(hex: "#1A1A2E")
    static let cardBackground = UIColor.white
    static let surfaceColor = UIColor(hex: "#FFFFFF")
    
    // MARK: - Text Colors
    static let textPrimary = UIColor(hex: "#2C3E50")
    static let textSecondary = UIColor(hex: "#7F8C8D")
    static let textTertiary = UIColor(hex: "#BDC3C7")
    static let textLight = UIColor.white
    
    // MARK: - Status Colors (No red, using alternatives)
    static let successColor = UIColor(hex: "#4CAF50") // Green
    static let warningColor = UIColor(hex: "#FF9800") // Orange
    static let pendingColor = UIColor(hex: "#FFC107") // Amber
    static let infoColor = UIColor(hex: "#2196F3") // Blue
    static let cancelColor = UIColor(hex: "#9E9E9E") // Grey instead of red
    
    // MARK: - Gradient Colors
    static let gradientStart = UIColor(hex: "#1E88E5")
    static let gradientEnd = UIColor(hex: "#1565C0")
    
    // MARK: - Shadow & Border
    static let shadowColor = UIColor.black.withAlphaComponent(0.1)
    static let borderColor = UIColor(hex: "#E0E0E0")
    
    // MARK: - Helper Methods
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func lighter(by percentage: CGFloat = 0.2) -> UIColor {
        return adjustBrightness(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 0.2) -> UIColor {
        return adjustBrightness(by: -abs(percentage))
    }
    
    private func adjustBrightness(by percentage: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue,
                          saturation: saturation,
                          brightness: min(brightness + percentage, 1.0),
                          alpha: alpha)
        }
        return self
    }
}
