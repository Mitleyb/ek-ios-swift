//
//  PopButton.swift
//  Dating
//
//  Created by Eilon Krauthammer on 30/11/2019.
//  Copyright © 2019 Eilon Krauthammer. All rights reserved.
//

import UIKit

class PopButton: UIButton {
    
    @IBInspectable public var accentColor: UIColor = Colors.red
    @IBInspectable public var isInverted: Bool = false
    
    override var intrinsicContentSize: CGSize {
        return .square(60.0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(accentColor: UIColor, icon: UIImage, isInverted: Bool = false) {
        self.init(type: .custom)
        self.accentColor = accentColor
        self.isInverted = isInverted
        self.setImage(icon, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        commonDesign()
    }
    
    private func commonDesign() {
        backgroundColor = isInverted ? accentColor : Colors.adaptiveElement
        tintColor = isInverted ? .white : accentColor
        adjustsImageWhenHighlighted = false
        
        layer.roundCorners(of: .oval)
        layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        layer.shadowRadius = 3.0
        layer.shadowOffset = .init(width: 0, height: 2.0)
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.shadowOpacity = 0.5
    }
    
    private var highlightFlag = false
    override var isHighlighted: Bool {
        didSet {
            highlightFlag = isHighlighted == oldValue
            if !highlightFlag {
                UIView.animate(withDuration: 0.15) {
                    self.transform = self.isHighlighted ? .evenScale(0.9) : .evenScale(1)
                }
            }
        }
    }
    
}
