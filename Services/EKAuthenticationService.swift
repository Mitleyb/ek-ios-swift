//
//  AuthenticationManager.swift
//  Dating
//
//  Created by Eilon Krauthammer on 30/03/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import Foundation
import LocalAuthentication

struct EKLocalAuth {
    static func authenticate(successHandler: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        let authReason = localized("auth_reason")
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: authReason) { success, error in
                DispatchQueue.main.async {
                    successHandler(success)
                }
            }
        } else {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: authReason) { success, error in
                DispatchQueue.main.async {
                    successHandler(success)
                }
            }
        }
    }
}


