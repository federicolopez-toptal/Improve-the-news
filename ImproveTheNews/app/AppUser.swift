//
//  AppUser.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 09/06/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

class AppUser {
    
    static let shared = AppUser()
    private let keyUSER_logged = "USER_logged"
    
    func isLogged() -> Bool {
        let logged = ShareAPI.readBoolKey(keyUSER_logged)
        if logged {
            return true
        } else {
            return false
        }
    }
    
    func setLogin(_ state: Bool) {
        if(state) {
            ShareAPI.writeKey(self.keyUSER_logged, value: true)
        }
        else {
            ShareAPI.removeKey(self.keyUSER_logged)
        }
    }
    
    func accountViewController() -> UIViewController {
        var vc: UIViewController?
    
        if(isLogged()) {
            vc = MyAccountV2ViewController.createInstance()
        } else {
            vc = SignInSignUpViewControllerViewController.createInstance()
        }
        
        return vc!
    }
    
}
