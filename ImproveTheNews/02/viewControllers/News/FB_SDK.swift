//
//  FB_SDK.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 15/03/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

/*
    https://developers.facebook.com/docs/facebook-login/ios/
    https://developers.facebook.com/docs/facebook-login/ios/advanced
    https://cocoapods.org/pods/FBSDKCoreKit
*/


import Foundation
import FBSDKLoginKit
import UIKit

class FB_SDK {

    static let instance = FB_SDK()


    func isLogged() -> Bool {
        if let token = AccessToken.current, !token.isExpired {
            return true
        } else {
            return false
        }
    }
    
    func getToken() -> String? {
        return AccessToken.current?.tokenString
    }
    
    func login(vc: UIViewController) {
        let loginManager = LoginManager()
        let permissions = ["public_profile"]
        loginManager.logIn(permissions: permissions, from: vc) { result, error in
            if let _error = error {
                print("Error", _error.localizedDescription)
            } else {
                if let _result = result {
                    if(_result.isCancelled) {
                        print("FB - Cancelled")
                    } else {
                        print("FB - Logueado!")
                    }
                    
                    /*
                    print(_result.token?.tokenString)
                    print(_result.authenticationToken?.tokenString)
                    */
                }
            }
        }
    }
    
    func logout(vc: UIViewController, callback: @escaping (Bool)->() ) {
        
        let alert = UIAlertController(title: "Facebook", message: "Close current session?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
            let loginManager = LoginManager()
            loginManager.logOut()
        
            callback(true)
        }
        let noAction = UIAlertAction(title: "No", style: .default) { action in
            callback(false)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        vc.present(alert, animated: true) {
        }
        
        
    }
}
