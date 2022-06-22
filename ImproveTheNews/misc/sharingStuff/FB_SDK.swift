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
import UIKit

let NOTIFICATION_FB_LOGGED = Notification.Name("FacebookLogged")
let NOTIFICATION_FB_DONE = Notification.Name("FacebookDone")

class FB_SDK {

    static let instance = FB_SDK()
    private let keySHARE_FBLogged = "SHARE_FBLogged"

    private var callback: ( (Bool)->() )?

    // FB ids & URLs in the info.plist file

    // ************************************************************ //
    func isLogged() -> Bool {
        let logged = ShareAPI.readBoolKey(keySHARE_FBLogged)
        if(logged) {
            return true
        } else {
            return false
        }
    }
    
    
//    let api = ShareAPI.instance
//        let jwt = api.getBearerAuth().replacingOccurrences(of: "Bearer ", with: "")
//        let fbLogin = "https://www.improvemynews.com/mobile-auth?jwt=" + jwt + "&usrid=" + api.uuid! + "&type=iOS&social_network=Facebook"
//
//
//
//        DELAY(2.0) {
//            print("SHARE", fbShare)
//            UIApplication.shared.open(URL(string: fbShare)!)
//        }
    
    
    func login(vc: UIViewController, callback: @escaping (Bool)->()) {
        self.callback = callback
        
        let api = ShareAPI.instance
        let jwt = api.getBearerAuth().replacingOccurrences(of: "Bearer ", with: "")
    
        let loginUrl = "https://www.improvemynews.com/mobile-auth?jwt=" + jwt + "&usrid=" + api.uuid! + "&type=iOS&social_network=Facebook"

        NotificationCenter.default.addObserver(self,
            selector: #selector(onFacebookLogged),
            name: NOTIFICATION_FB_LOGGED,
            object: nil)
            
        UIApplication.shared.open(URL(string: loginUrl)!)
    }
    
    @objc func onFacebookLogged() {
        self.callback?(true)
        ShareAPI.writeKey(self.keySHARE_FBLogged, value: true)
        ShareAPI.LOG(where: "Facebook login", msg: "Success")
    }
    
    func logout(vc: UIViewController, callback: @escaping (Bool)->() ) {
        let _h = "Facebook"
        let _q = "Close current Facebook session?"
        
        ShareAPI.logoutDialog(vc: vc, header: _h, question: _q) { (wasLoggedOut) in
            if(wasLoggedOut) {
                ShareAPI.removeKey(self.keySHARE_FBLogged)
                ShareAPI.instance.disconnect(type: "Facebook")
            }
            callback(wasLoggedOut)
        }
    }
    
    func logoutDirect() {
        ShareAPI.removeKey(self.keySHARE_FBLogged)
        ShareAPI.instance.disconnect(type: "Facebook")
    }
    
    func share(link: String, comment: String?, vc: UIViewController) {
//        let content = ShareLinkContent()
//        content.contentURL = URL(string: link)
//        content.quote = comment
//
//        let dialog = ShareDialog(viewController: vc, content: content, delegate: vc as? SharingDelegate)
//        if(IS_iPAD()){ dialog.mode = .web }
//        dialog.show()

        var C = ""
        if let _comment = comment {
            C = _comment
        }
        C = C.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

        let shareUrl = "https://www.facebook.com/dialog/share?app_id=499204491779033&display=popup&quote=" + C + "&href=" + link + "&redirect_uri=https://www.improvemynews.com/fb-share?app=iOS"
        
        UIApplication.shared.open(URL(string: shareUrl)!)
    }
    
}


