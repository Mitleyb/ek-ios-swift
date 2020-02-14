//
//  SizingCollectionView.swift
//  Dating
//
//  Created by Eilon Krauthammer on 23/01/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import UIKit

class SizingCollectionView: UICollectionView {

    fileprivate var noContentLabel: UILabel = {
        let lb = UILabel.defaultLabel(text: localized("no_posts"), size: 15.0, weight: .regular, color: Colors.secondaryLabel, maxLines: 1)
        lb.textAlignment = .center
        return lb
    }()
    
    override var intrinsicContentSize: CGSize {
        max(contentSize, noContentLabel.intrinsicContentSize)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addSubview(noContentLabel)
        noContentLabel.center(in: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
    
    override func reloadData() {
        super.reloadData()
        noContentLabel.isHidden = !(numberOfItems(inSection: 0) == 0)
    }
}

extension CGSize: Comparable {
    public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        return (lhs.width < rhs.width) && (lhs.height < rhs.height)
    }
}
