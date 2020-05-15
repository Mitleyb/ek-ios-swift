//
//  EKTabController.swift
//  Elapsed
//
//  Created by Eilon Krauthammer on 16/09/2019.
//  Copyright © 2019 Eilon Krauthammer. All rights reserved.
//

import UIKit

class EKTabController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}


extension EKTabController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: [fromVC, toVC])
    }
}

class MyTransition: NSObject, UIViewControllerAnimatedTransitioning {

    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.25

    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let fromView = fromVC.view,
            let toVC = transitionContext.viewController(forKey: .to),
            let toView = toVC.view
        else {
            transitionContext.completeTransition(false)
            return
        }

        
        DispatchQueue.main.async {
            toView.alpha = 0.0
            transitionContext.containerView.addSubview(toView)
            toView.subviews.forEach { sub in
                sub.transform.tx += 100
            }
            UIView.animate(withDuration: self.transitionDuration, delay: 0, options: .curveEaseOut, animations: {
                fromView.subviews.forEach { sub in
                    sub.alpha = 0.0
                    sub.transform.tx -= 50
                }
                toView.alpha = 1.0
                toView.subviews.forEach { sub in
                    sub.alpha = 1.0
                    sub.transform = .identity
                }
            }) { _ in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }

    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        for (index, thisVC) in vcs.enumerated() {
            if thisVC == vc { return index }
        }
        return nil
    }
}
