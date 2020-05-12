//
//  ImageDetailController.swift
//  Dating
//
//  Created by Eilon Krauthammer on 01/01/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import UIKit

class ImageDetailController: EKPresentationController {

    let image: UIImage
    
    private var aboutToClose = false {
        didSet {
            guard aboutToClose && !oldValue else { return }
            hapticFeedback()
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: self.image)
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.roundCorners(of: .regular)
        imageView.constraintAspectRatio(1.0)
        return imageView
    }()
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.swipeDismissable = true
        super.viewDidLoad()
        super.customSize = .square(UIScreen.main.bounds.width * 0.9)
                
        view.addSubview(imageView)
        imageView.fix(in: view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        self.image = .init()
        super.init(coder: coder)
    }
}

// MARK: - Gesture recognizers handling

extension ImageDetailController {
    private func addGestureRecognizers() {
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
        pinchRecognizer.delegate = self
        imageView.addGestureRecognizer(pinchRecognizer)
        
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        rotationRecognizer.delegate = self
        imageView.addGestureRecognizer(rotationRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        panRecognizer.delegate = self
        imageView.addGestureRecognizer(panRecognizer)
    }
    
    @objc private func didPinch(_ gr: UIPinchGestureRecognizer) {
        if gr.state == .ended {
            aboutToClose = false
            animated {
                self.imageView.transform = .identity
            }
        } else {
            imageView.transform = imageView.transform.evenScaled(gr.scale)
            gr.scale = 1.0
        }
        
        dismissRecognizer?.isEnabled = gr.state == .ended
    }
    
    @objc private func didRotate(_ gr: UIRotationGestureRecognizer) {
        imageView.transform = imageView.transform.rotated(by: gr.rotation)
        gr.rotation = 0.0
    }
    
    @objc private func didPan(_ gr: UIPanGestureRecognizer) {
        if gr.state == .ended {
            aboutToClose = false
            animated {
                self.imageView.transform = .identity
            }
            
            return ()
        }

        let translation = gr.translation(in: imageView)
        imageView.transform = imageView.transform.translatedBy(x: translation.x, y: translation.y)
        gr.setTranslation(.zero, in: imageView)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
