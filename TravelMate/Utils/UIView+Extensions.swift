import UIKit

extension UIView {
    // MARK: - Shadow
    func addShadow(
        color: UIColor = .black,
        opacity: Float = 0.1,
        offset: CGSize = CGSize(width: 0, height: 4),
        radius: CGFloat = 10
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    
    func addCardShadow() {
        addShadow(color: .black, opacity: 0.08, offset: CGSize(width: 0, height: 2), radius: 8)
    }
    
    func addElevatedShadow() {
        addShadow(color: .black, opacity: 0.15, offset: CGSize(width: 0, height: 6), radius: 12)
    }
    
    // MARK: - Gradient
    func addGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        
        // Remove existing gradient if any
        layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addPrimaryGradient() {
        addGradient(
            colors: [.gradientStart, .gradientEnd],
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 1, y: 1)
        )
    }
    
    // MARK: - Corner Radius
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func makeCircular() {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        clipsToBounds = true
    }
    
    // MARK: - Border
    func addBorder(color: UIColor, width: CGFloat = 1.0) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    // MARK: - Animations
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10, 10, -8, 8, -5, 5, 0]
        layer.add(animation, forKey: "shake")
    }
    
    func pulse(scale: CGFloat = 1.1, duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration, delay: 0, options: [.autoreverse, .curveEaseInOut], animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }) { _ in
            UIView.animate(withDuration: duration) {
                self.transform = .identity
            }
        }
    }
    
    func fadeIn(duration: TimeInterval = 0.3) {
        alpha = 0
        UIView.animate(withDuration: duration) {
            self.alpha = 1
        }
    }
    
    func fadeOut(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }) { _ in
            completion?()
        }
    }
    
    func slideInFromBottom(duration: TimeInterval = 0.4) {
        let originalTransform = transform
        transform = CGAffineTransform(translationX: 0, y: bounds.height)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.transform = originalTransform
        }
    }
    
    // MARK: - Loading Indicator
    func showLoadingIndicator(style: UIActivityIndicatorView.Style = .large) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .primaryColor
        addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        indicator.startAnimating()
        return indicator
    }
    
    // MARK: - Card Styling
    func styleAsCard() {
        backgroundColor = .cardBackground
        layer.cornerRadius = 16
        addCardShadow()
    }
    
    func styleAsModernCard() {
        backgroundColor = .surfaceColor
        layer.cornerRadius = 20
        addShadow(color: .shadowColor, opacity: 0.08, offset: CGSize(width: 0, height: 4), radius: 12)
    }
    
    // MARK: - Tap Feedback
    func addTapFeedback() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapFeedback))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTapFeedback() {
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.alpha = 1.0
            }
        }
    }
}

// MARK: - UIButton Extensions
extension UIButton {
    func setGradientBackground(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        
        layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addPressAnimation() {
        addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}

// MARK: - UILabel Extensions
extension UILabel {
    func setLineSpacing(_ spacing: CGFloat) {
        guard let text = text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        attributedText = attributedString
    }
}
