//
//  Functions.swift
//  Dating
//
//  Created by Eilon Krauthammer on 09/12/2019.
//  Copyright © 2019 Eilon Krauthammer. All rights reserved.
//

import UIKit
import Foundation

// MARK: - Helper Functions & Structs

func delay(_ interval: TimeInterval, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
        closure()
    }
}

func deg2rad(_ number: CGFloat) -> CGFloat {
    return number * .pi / 180
}

func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    UIImpactFeedbackGenerator(style: style).impactOccurred()
}

func animated(_ duration: TimeInterval = 0.2, _ block: @escaping () -> Void) {
    UIView.animate(withDuration: duration) {
        block()
    }
}

@discardableResult
func alert(_ title: String, _ info: String? = nil, in vc: UIViewController?, defaultHandler: (() -> Void)? = nil) -> UIAlertController {
    let alert = UIAlertController.alert(title: title, message: info, cancelHandler: defaultHandler)
    if let vc = vc { vc.present(alert, animated: true, completion: nil) }
    return alert
}

func localized(_ key: String, comment: String? = nil) -> String {
    NSLocalizedString(key, comment: comment ?? "")
}

import CoreLocation
struct LocationCoordinates: Codable {
    let latitude: Double, longitude: Double
    init(lat: Double, lng: Double) {
        self.latitude = lat
        self.longitude = lng
    }
    
    init?(clLocation: CLLocation?) {
        guard let loc = clLocation else { return nil }
        self.latitude = loc.coordinate.latitude
        self.longitude = loc.coordinate.longitude
    }
    
    /// Distance to another location in meters.
    func distance(to other: LocationCoordinates) -> Double {
        let clSelf = CLLocation(latitude: latitude, longitude: longitude)
        let clOther = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return clSelf.distance(from: clOther)
    }
}


