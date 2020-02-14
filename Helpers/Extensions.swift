//
//  Extensions.swift
//  Dating
//
//  Created by Eilon Krauthammer on 29/11/2019.
//  Copyright © 2019 Eilon Krauthammer. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

// MARK: - Extensions

extension CGPoint {
    static var screenCenter: CGPoint {
        return .init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    }
}

extension CGSize {
    static func square(_ side: CGFloat) -> CGSize {
        return .init(width: side, height: side)
    }
}

extension UIEdgeInsets {
    static func even(_ value: CGFloat) -> UIEdgeInsets {
        return .init(top: value, left: value, bottom: value, right: value)
    }
    
    static func vertical(_ v: CGFloat, horizontal h: CGFloat) -> UIEdgeInsets {
        return .init(top: v, left: h, bottom: v, right: h)
    }
}

extension CGAffineTransform {
    static func evenScale(_ value: CGFloat) -> CGAffineTransform {
        return .init(scaleX: value, y: value)
    }
    
    func evenScaled(_ value: CGFloat) -> CGAffineTransform {
        return scaledBy(x: value, y: value)
    }
}

extension Array {
    func at(_ index: Int) -> Element {
        return self[index]
    }
    
    mutating func empty() {
        self = []
    }
    
    var lastIndex: Int { count - 1 }
}

extension Array where Element: Equatable {
    func unique() -> [Element] {
        var filtered = self
        var removed = 0
        for (idx, elem) in self.enumerated() {
            if filtered.filter({ $0 == elem }).count > 1 {
                filtered.remove(at: idx-removed)
                removed += 1
            }
        }
        return filtered
    }
}

extension Collection {
    subscript(safe index: Index) -> Iterator.Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

extension FloatingPoint {
    func isInDimension<T: FloatingPoint>(of other: T) -> Bool {
        return (self > .zero) == (other > .zero)
    }
}

extension Double {
    var timeString: String {
        let minutes = Int(floor(self / 60))
        let seconds = Int(self) - (minutes * 60)
        return "\(minutes):\(seconds)"
    }
}

extension IntegerLiteralType {
    var bool: Bool {
        return self > 0 ? true : false
    }
}

extension Bool {
    var int: Int {
        return self ? 1 : 0
    }
    
    var string: String {
        return self ? "1" : "0"
    }
}

extension Date {
    enum FormatStyle { case regular, short }
    
    var timeFormat: String {
        DateFormatter(format: "H:mm").string(from: self)
    }
    
    func dateFormat() -> String {
        if Calendar.current.isDateInToday(self) {
            return localized("today") + ", " + timeFormat
        } else if Calendar.current.isDateInYesterday(self) {
            return localized("yesterday") + ", " + timeFormat
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: self)
        }
    }
    
    func chatFormat() -> String {
        if Calendar.current.isDateInToday(self) {
            return localized("today")
        } else if Calendar.current.isDateInYesterday(self) {
            return localized("yesterday")
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: self)
        }
    }
}

extension CALayer {
    enum CornerRadiusPreset {
        case oval, regular, wide, custom(CGFloat)
    }
    
    func roundCorners(of radius: CornerRadiusPreset) {
        switch radius {
            case .oval:
                cornerRadius = min(bounds.height/2, bounds.width/2)
            case .regular:
                cornerRadius = 8.0
            case .wide:
                cornerRadius = 15.0
            case .custom(let rad):
                cornerRadius = rad
        }
    }
    
    func applyShadow(radius: CGFloat = 2.0, opacity: Float = 0.5) {
        shadowColor = Colors.shadow.cgColor
        shadowOpacity = opacity
        shadowRadius = radius
        shadowOffset = CGSize(width: 0, height: 1.0)
    }
}

extension UIColor {
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
    static func gray(_ val: CGFloat) -> UIColor {
        return UIColor.rgb(r: val, g: val, b: val, a: 1.0)
    }
    
    func lighter(by percentage: CGFloat = 10.0) -> UIColor {
        return self.adjust(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 10.0) -> UIColor {
        return self.adjust(by: -abs(percentage))
    }
    
    func adjust(by percentage: CGFloat) -> UIColor {
        var alpha, hue, saturation, brightness, red, green, blue, white : CGFloat
        (alpha, hue, saturation, brightness, red, green, blue, white) = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        
        let multiplier = percentage / 100.0
        
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let newBrightness: CGFloat = max(min(brightness + multiplier*brightness, 1.0), 0.0)
            return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
        }
        else if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let newRed: CGFloat = min(max(red + multiplier*red, 0.0), 1.0)
            let newGreen: CGFloat = min(max(green + multiplier*green, 0.0), 1.0)
            let newBlue: CGFloat = min(max(blue + multiplier*blue, 0.0), 1.0)
            return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: alpha)
        }
        else if self.getWhite(&white, alpha: &alpha) {
            let newWhite: CGFloat = (white + multiplier*white)
            return UIColor(white: newWhite, alpha: alpha)
        }
        
        return self
    }
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    
    func heightOfString(forWidth width: CGFloat, withFont font: UIFont, fromSecondLineOnly: Bool = false) -> CGFloat {
        let charSize = font.lineHeight
        let textSize = self.boundingRect(with: CGSize(width: width, height: CGFloat.zero), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let linesRoundedUp = CGFloat(Int(ceil(textSize.height/charSize)))
        
        let toggle: CGFloat = fromSecondLineOnly ? 1 : 0
        return (linesRoundedUp - toggle) * charSize
    }
    
    func lineCount(forWidth width: CGFloat, withFont font: UIFont) -> CGFloat {
        let charSize = font.lineHeight
        let textSize = self.boundingRect(with: CGSize(width: width, height: CGFloat.zero), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let linesRoundedUp = CGFloat(Int(ceil(textSize.height/charSize)))
        return linesRoundedUp
    }
}

extension String {
    /// Drops 'n' characters from the end of the string.
    func drop(_ n: Int) -> Self {
        return Self(dropLast(n))
    }
    
    /// Drops 'n' characters from the start of the string.
    func chop(_ n: Int) -> Self {
        return Self(dropFirst(n))
    }
    
    func trimmed() -> Self {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }

    var bool: Bool {
        return self == "1"
    }
    
    static var space: Self {
        return " "
    }
}

extension UIAlertController {
    typealias Handler = (() -> Void)?
    static func alert(title: String, message: String?, cancelTitle: String = localized("ok"), actionTitle: String? = nil, cancelHandler: Handler = nil, actionHandler: Handler = nil) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in
            cancelHandler?()
        }))
        
        if let title = actionTitle, let action = actionHandler {
            controller.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                action()
            }))
        }
        
        return controller
    }
}

extension UIView {
    var relativeCenter: CGPoint {
        return .init(x: bounds.width/2, y: bounds.height/2)
    }
}

extension UILabel {
    static func defaultLabel(text: String = "", size: CGFloat = UIFont.systemFontSize, weight: UIFont.Weight = .regular, color: UIColor = Colors.label, maxLines: Int = 0) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.textAlignment = .natural
        label.numberOfLines = maxLines
        return label
    }
}

extension UITextField {
    func stringEntry() -> String {
        guard let text = text else { return "" }
        return text.trimmed()
    }
}

extension UITextView {
    func stringEntry() -> String {
        guard let text = text else { return "" }
        return text.trimmed()
    }
}

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeFor(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

extension UIImage {
    func base64(compressionQuality q: CGFloat = 0.5, resizeFor dimension: CGFloat? = nil) -> String? {
        var resizedImage: UIImage?
        if let dimension = dimension {
            resizedImage = resizeFor(width: dimension)
        }
        
        return (resizedImage ?? self).jpegData(compressionQuality: q)?.base64EncodedString()
    }
}

extension UIImage {
    static func downloaded(from url: URL, completion: @escaping (UIImage) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { print("Failed to fetch image."); return }
            DispatchQueue.main.async() {
                completion(image)
            }
        }.resume()
    }
}

extension NVActivityIndicatorViewable where Self: UIViewController {
    func loadUIStart(message: String? = nil) {
        startAnimating(message: message, type: .ballPulseSync)
    }

    func loadUIStop() {
        stopAnimating()
    }
}

// MARK: - Cover Layer
fileprivate var coverLayerDismisser: (() -> Void)?
extension UIViewController {
    static var COVERLAYER_TAG: Int { return 80 }
    
    var currentCoverLayer: UIView? {
        return view.viewWithTag(UIViewController.COVERLAYER_TAG)
    }
    
    func insertCoverLayer(behind _view: UIView, dismissHandler: (() -> Void)? = nil) {
        let layer = UIView(frame: view.bounds)
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        layer.alpha = 0.0
        layer.tag = UIViewController.COVERLAYER_TAG
        layer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeCoverLayer)))
        coverLayerDismisser = dismissHandler
        view.insertSubview(layer, belowSubview: _view)
        
        UIView.animate(withDuration: 0.25) {
            layer.alpha = 1.0
        }
    }
    
    @objc func removeCoverLayer(withDismisser: Bool = true) {
        if !withDismisser {
            coverLayerDismisser?()
        }
        if let coverLayer = view.subviews.first(where: { $0.tag == UIViewController.COVERLAYER_TAG }) {
            UIView.animate(withDuration: 0.25, animations: {
                coverLayer.alpha = 0.0
            }) { _ in
                coverLayer.removeFromSuperview()
            }
        } else {
            print("No cover layer was found within the views subviews.")
        }
    }
}

extension UIViewController {
    func hidesKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension UIView {
    func findView<T: UIView>(byType _: T.Type) -> T? {
        return subviews.first { $0 is T } as? T
    }
}

// MARK: - Auto Layout
extension UIView {
    func fix(in container: UIView, padding: UIEdgeInsets = .zero) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: container.topAnchor, constant: padding.top),
            bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -padding.bottom),
            leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding.left),
            trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding.right)
        ])
    }
    
    func hfix(in container: UIView, padding: CGFloat = .zero) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        leftAnchor.constraint(equalTo: container.leftAnchor, constant: padding).isActive = true
        rightAnchor.constraint(equalTo: container.rightAnchor, constant: -padding).isActive = true
    }
    
    func vfix(in container: UIView, padding: CGFloat = .zero) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        topAnchor.constraint(equalTo: container.topAnchor, constant: padding).isActive = true
        bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -padding).isActive = true
    }
    
    func constraintAspectRatio(_ ar: CGFloat, width: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let w = width {
            self.widthAnchor.constraint(equalToConstant: w).isActive = true
        }
        
        self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: ar).isActive = true
    }
    
    func equalLeadingTrailing(to view: UIView, margin: CGFloat = 0.0) {
        leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor, constant: -margin).isActive = true
    }
    
    func center(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension UIView {
    @discardableResult
    func findConstraint(layoutAttribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        if let constraints = superview?.constraints {
            for constraint in constraints where itemMatch(constraint: constraint, layoutAttribute: layoutAttribute) {
                return constraint
            }
        }
        return nil
    }
    
    func itemMatch(constraint: NSLayoutConstraint, layoutAttribute: NSLayoutConstraint.Attribute) -> Bool {
        let firstItemMatch = constraint.firstItem as? UIView == self && constraint.firstAttribute == layoutAttribute
        let secondItemMatch = constraint.secondItem as? UIView == self && constraint.secondAttribute == layoutAttribute
        return firstItemMatch || secondItemMatch
    }
    
    static func separator() -> UIView {
        let sep = UIView()
        sep.backgroundColor = Colors.separator
        sep.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        return sep
    }
}

extension UIScrollView {

  var minContentOffset: CGPoint {
    return CGPoint(
      x: -contentInset.left,
      y: -contentInset.top)
  }

  var maxContentOffset: CGPoint {
    return CGPoint(
      x: contentSize.width - bounds.width + contentInset.right,
      y: contentSize.height - bounds.height + contentInset.bottom)
  }

  func scrollToMinContentOffset(animated: Bool) {
    setContentOffset(minContentOffset, animated: animated)
  }

  func scrollToMaxContentOffset(animated: Bool) {
    setContentOffset(maxContentOffset, animated: animated)
  }
}

// MARK: - Graveyard

/*
extension UITableView {
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    override open var intrinsicContentSize: CGSize {
        var height: CGFloat = .zero
        for r in 0 ..< numberOfRows(inSection: 0) {
            height += rectForRow(at: IndexPath(row: r, section: 0)).height
        }
        return .init(width: frame.width, height: height)
    }
}
*/


