//
//  ImageSwipingCollectionView.swift
//  Dating
//
//  Created by Eilon Krauthammer on 02/12/2019.
//  Copyright © 2019 Eilon Krauthammer. All rights reserved.
//

import UIKit

final class ImageSwipingCollectionView: UICollectionView {

    public var images: [UIImage] = .init() {
        didSet {
            super.reloadData()
            pageControl.numberOfPages = images.count
            pageControl.semanticContentAttribute = .forceLeftToRight
            guard !(pageControl.isDescendant(of: self)) else { return }
            addSubview(pageControl)
        }
    }
    
    /// Determines if the collection view is swipeable or tappable
    /// true == Only tappable.
    public var isStatic: Bool = false {
        willSet {
            isScrollEnabled = !newValue
            // Add tap gesture if needed.
            if newValue {
                self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
            }
        }
    }
    
    public var didTapImage: ((UIImage) -> Void)?
        
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = images.count
        pc.currentPage = 0
        pc.center.x = relativeCenter.x
        pc.frame.origin.y = bounds.maxY - 24.0
        pc.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
        return pc
    }()
    
    private let cellIdentifier = "Cell"
    
    private var didLayout = false
    
    public init() {
        super.init(frame: .zero, collectionViewLayout: LocalizedLayout())
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = Colors.background
        
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0.0
            layout.minimumInteritemSpacing = 0.0
        }
        
        delegate = self
        dataSource = self
        
        contentInset = .zero
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        
        register(ImageCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !didLayout {
            didLayout = true
            pageControl.center.x = relativeCenter.x
        }
        if isStatic {
            pageControl.frame.origin.y = bounds.minY + 24.0
        } else {
            pageControl.frame.origin.y = bounds.maxY - 24.0
        }
    }
    
    @objc private func tapped(_ gr: UITapGestureRecognizer) {
        guard let currentCell = visibleCells.first else { return }
        
        let tapX = gr.location(in: self).x
        let isForward = tapX >= (currentCell.frame.maxX + currentCell.frame.minX) / 2
        pageControl.currentPage += isForward ? 1 : -1
        let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
        scrollToItem(at: indexPath, at: .init(), animated: true)
        
        hapticFeedback()
    }
}

// MARK: - CollectionView Delegate
extension ImageSwipingCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ImageCell
        cell.image = images.at(indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let image = images[safe: indexPath.item] else { return }
        didTapImage?(image)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return frame.size
    }
}

// MARK: - ScrollView Handling
extension ImageSwipingCollectionView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.center.x = relativeCenter.x + scrollView.contentOffset.x
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        let index = Int(x / frame.width)
        pageControl.currentPage = index
    }
}

// MARK: - Image Cell class
final class ImageCell: UICollectionViewCell {
    public var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }
    
    private var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = contentView.bounds
        imageView.autoresizingMask = .flexibleHeight
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

