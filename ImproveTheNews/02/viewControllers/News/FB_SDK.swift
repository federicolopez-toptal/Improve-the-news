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
    private let keySHARE_FBLogged = "SHARE_FBLogged"


    // ************************************************************ //
    func isLogged() -> Bool {
        let logged = ShareAPI.readBoolKey(keySHARE_FBLogged)
        if logged, let token = AccessToken.current, !token.isExpired {
            return true
        } else {
            return false
        }
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
                        
                        // _result.token?.tokenString
                        // _result.authenticationToken?.tokenString
                        self.ITN_login(token: _result.token!.tokenString)
                    }
                }
            }
        }
        
    }
    
    private func ITN_login(token: String) {
        let api = ShareAPI.instance
        api.login(type: "Facebook", accessToken: token) { (success) in
            ShareAPI.writeKey(self.keySHARE_FBLogged, value: true)
            print("FB login to the server -", success)
        }
    }
    
    func logout(vc: UIViewController, callback: @escaping (Bool)->() ) {
        
        let _h = "Facebook"
        let _q = "Close current Facebook session?"
        ShareAPI.logoutDialog(vc: vc, header: _h, question: _q) { (wasLoggedOut) in
            if(wasLoggedOut) {
                LoginManager().logOut()
                ShareAPI.removeKey(self.keySHARE_FBLogged)
                ShareAPI.instance.disconnect(type: "Facebook")
            }
            callback(wasLoggedOut)
        }
    }
    
}


/*
    func getToken() -> String? {
        return AccessToken.current?.tokenString
    }
    */
