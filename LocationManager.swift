//
//  LocationManager.swift
//  Dating
//
//  Created by Eilon Krauthammer on 17/12/2019.
//  Copyright © 2019 Eilon Krauthammer. All rights reserved.
//

import UIKit
import CoreLocation

final class LocationManager: NSObject {
    
    // Class singleton
    static let shared: LocationManager = LocationManager()
    
    private let manager: CLLocationManager = CLLocationManager()
    
    public var lastLocation: CLLocation?
    public var authorizationStatus: CLAuthorizationStatus = .notDetermined {
        didSet {
            if oldValue == .denied && authorizationStatus == .authorizedWhenInUse {
                manager.startUpdatingLocation()
            }
        }
    }
        
    private var locationCallback: LocationCallback?
    
    public var deniedAuthorizationCallback: (() -> Void)?
    
    typealias LocationCallback = (CLLocation?) -> Void
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
    }
    
    public func getLocation(_ callback: @escaping LocationCallback) {
        manager.startUpdatingLocation()
        self.locationCallback = callback
    }
    
    deinit {
        manager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.manager.stopUpdatingLocation()
        let location = locations.last
        self.lastLocation = location
        self.locationCallback?(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.manager.stopUpdatingLocation()
        self.locationCallback?(nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .denied {
            deniedAuthorizationCallback?()
        }
    }
}

extension LocationManager {
    static func deniedLocationAccess(handleIn vc: UIViewController) {
        let alert = UIAlertController.alert(title: "Please approve location usage", message: "We need your location to find people around you. Please enable location for this app in settings under 'Location'.", cancelTitle: "OK", cancelHandler: {
            redirectToSettings()
        })
        vc.present(alert, animated: true)
    }

    fileprivate static func redirectToSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
       
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

extension CLLocation {
    var locationCoordinates: LocationCoordinates {
        return .init(lat: coordinate.latitude, lng: coordinate.longitude)
    }
}

