//
//  Colors.swift
//  Dating
//
//  Created by Eilon Krauthammer on 29/11/2019.
//  Copyright © 2019 Eilon Krauthammer. All rights reserved.
//

import UIKit

struct Colors {
    static var background: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        }
        return .white
    }
    
    static var secondaryBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.secondarySystemBackground
        }
        return .rgb(r: 242.0, g: 242.0, b:247.0, a: 1.0)
    }
    
    static var tertiaryBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.tertiarySystemBackground
        }
        return .white
    }
    
    static var label: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }
    
    static var secondaryLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return .darkGray
        }
    }
    
    static var tertiaryLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .tertiaryLabel
        } else {
            return .darkGray
        }
    }
    
    static var quaternaryLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .quaternaryLabel
        } else {
            return .rgb(r:60.0, g: 60.0, b:67.0, a: 0.18)
        }
    }
    
    static var component: UIColor {
        let base = UIColor.black.withAlphaComponent(0.035)
        if #available(iOS 13, *) {
            return UIColor { (traitCollection) -> UIColor in
                return traitCollection.userInterfaceStyle == .light ? base : UIColor.white.withAlphaComponent(0.1)
            }
        }
        return base
    }
    
    
    
    static var separator: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return border
                }
                return .separator
            }
        } else {
            return border
        }
    }
    
    static var opaqueSeparator: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return .rgb(r: 60.0, g: 60.0, b: 67.0, a: 1.0)
                }
                return .rgb(r: 198.0, g: 198.0, b: 200.0, a: 1.0)
            }
        }
        
        return .rgb(r: 60.0, g: 60.0, b: 67.0, a: 1.0)
    }
    
    static var chatSection: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return section
                } else {
                    return .rgb(r: 20, g: 20, b: 24, a: 1.0)
                }
            }
        }
        
        return section
    }
    
    static var categoryLabel: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traits) -> UIColor in
                let baseColor: UIColor = traits.userInterfaceStyle == .dark ? .white : .black
                return baseColor.withAlphaComponent(0.25)
            }
        }
        
        return UIColor.black.withAlphaComponent(0.25)
    }
    
    static var placeholder: UIColor {
        if #available(iOS 13, *) {
            return .placeholderText
        }
        
        return .rgb(r: 60.0, g: 60.0, b: 67.0, a: 0.3)
    }
    
    static let shadow:       UIColor = UIColor.black.withAlphaComponent(0.3)
    static let actionButton: UIColor = UIColor(red: 0.675, green: 0.188, blue: 0.184, alpha: 1.00)
    static let selection:    UIColor = UIColor(red: 0.902, green: 0.541, blue: 0.486, alpha: 1.00)
    static let border:       UIColor = .gray(240.0)
    static let section:      UIColor = .gray(248.0)
    
    static let mainCircle: UIColor = UIColor(red: 0.945, green: 0.953, blue: 0.973, alpha: 1.00)
    
    static let red:   UIColor = UIColor(red: 0.863, green: 0.369, blue: 0.333, alpha: 1.00)
    static let green: UIColor = UIColor(red: 0.282, green: 0.557, blue: 0.216, alpha: 1.00)
    
    static let mainBlue =      UIColor(red: 0.196, green: 0.580, blue: 0.875, alpha: 1.00)
    static let boldBlue =      UIColor(red: 0.325, green: 0.408, blue: 0.733, alpha: 1.00)
    static let secondaryBlue = UIColor(red: 0.439, green: 0.651, blue: 0.902, alpha: 1.00)
    static let textSubBlue =   UIColor(red: 0.290, green: 0.565, blue: 0.886, alpha: 1.00).withAlphaComponent(0.6)
    
    static var adaptiveElement: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return secondaryBackground.lighter(by: 40.0)
                } else {
                    /// Return the color for Light Mode
                    return background
                }
            }
        } else {
            return background
        }
    }
    
    static var adaptiveCircle: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return mainCircle.darker(by: 90.0)
                } else {
                    /// Return the color for Light Mode
                    return mainCircle
                }
            }
        } else {
            /// Return a fallback color for iOS 12 and lower.
            return mainCircle
        }
    }
}

