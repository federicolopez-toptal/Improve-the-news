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
    
    https://developers.facebook.com/docs/ios
    
    https://cocoapods.org/pods/FBSDKCoreKit
*/


import Foundation
import FBSDKLoginKit
import FBSDKShareKit
import UIKit

class FB_SDK {

    static let instance = FB_SDK()
    private let keySHARE_FBLogged = "SHARE_FBLogged"

    private var callback: ( (Bool)->() )?

    // FB ids & URLs in the info.plist file

    // ************************************************************ //
    func isLogged() -> Bool {
        let logged = ShareAPI.readBoolKey(keySHARE_FBLogged)
        if logged, let token = AccessToken.current, !token.isExpired {
            return true
        } else {
            return false
        }
    }
    
    func login(vc: UIViewController, callback: @escaping (Bool)->()) {
        self.callback = callback
        
        let loginManager = LoginManager()
        let permissions = ["public_profile"]
        loginManager.logIn(permissions: permissions, from: vc) { result, error in
            if let _error = error {
                print("Error", _error.localizedDescription)
                self.callback?(false)
            } else {
                if let _result = result {
                    if(_result.isCancelled) {
                        print("FB - Cancelled")
                        self.callback?(false)
                    } else {
                        print("FB - Logueado!")
                        
                        /*
                            callback(true)
                            ShareAPI.writeKey(self.keySHARE_FBLogged, value: true)
                        */
                        self.ITN_login(token: _result.token!.tokenString)
                    }
                } else {
                    self.callback?(false)
                }
            }
        }
        
    }
    
    private func ITN_login(token: String) {
        let api = ShareAPI.instance
        api.login(type: "Facebook", accessToken: token, secret: nil) { (success) in
            self.callback?(true)
            ShareAPI.writeKey(self.keySHARE_FBLogged, value: true)
            ShareAPI.LOG(where: "Facebook login", msg: "Success")
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
    
    func share(link: String, comment: String?, vc: UIViewController) {
        let content = ShareLinkContent()
        content.contentURL = URL(string: link)
        content.quote = comment
        
        let dialog = ShareDialog(viewController: vc, content: content, delegate: vc as? SharingDelegate)
        dialog.show()
    }
    
    
//        let photo = SharePhoto(image: UIImage(named: "sonic2.jpg")!, isUserGenerated: false)
//        let photoContent = SharePhotoContent()
//        photoContent.photos = [photo]
//        //photoContent.contentURL = URL(string: link)
//        //photoContent.
}


