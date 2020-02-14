//
//  ChatTextView.swift
//  Dating
//
//  Created by Eilon Krauthammer on 05/12/2019.
//  Copyright © 2019 Eilon Krauthammer. All rights reserved.
//

import UIKit

class EKDynamicTextView: UITextView {
    
    public var layoutHandler: (() -> Void)?
    
    static let defaultPlaceholder = "chat_tf_placeholder"

    @IBInspectable public var localizedPlaceholder: String = DynamicTextView.defaultPlaceholder
    public var placeholder: String { localized(self.localizedPlaceholder) }
    
    public var onChange: (() -> Void)?
    
    private var didLayout = false
    
    override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !didLayout {
            didLayout = true
        }
    }
    
     override func awakeFromNib() {
        super.awakeFromNib()
        text = localized(self.placeholder)
     }

    private func commonInit() {
        // self
        delegate = self
        backgroundColor = nil
        contentInset = .init(top: 0, left: 4.0, bottom: 0, right: 4.0)
        
        // layer
        layer.roundCorners(of: .wide)
        layer.borderWidth = 1.5
        layer.borderColor = Colors.separator.cgColor
        
        // Set for placeholder
        textColor = Colors.placeholder
        text = self.placeholder
    }
}

extension DynamicTextView : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if text == placeholder {
            text = .init()
        }
        
        textColor = Colors.label
        invalidateIntrinsicContentSize()
        layoutHandler?()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = Colors.placeholder
            textView.text = self.placeholder
            invalidateIntrinsicContentSize()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.invalidateIntrinsicContentSize()
        layoutHandler?()
        self.onChange?()
    }
    
}
