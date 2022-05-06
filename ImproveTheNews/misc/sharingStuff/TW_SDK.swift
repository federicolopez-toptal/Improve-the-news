//
//  TW_SDK.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 23/03/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

/*
    https://github.com/mattdonnelly/Swifter
*/

import Foundation
import Swifter

class TW_SDK {

    static let instance = TW_SDK()
    private let keySHARE_TWLogged = "SHARE_TWLogged"

    private var swifter: Swifter?
    
    /*
    private let tw_consumerKey = "csb01s65kGzYIr3OGyYQGIf52"
    private let tw_consumerSecret = "qtdyt54STbMgN2ieoZKj4NRhMOtDvQRJJOgwa74Sw002W6WgB5"
    static let callbackUrl = "ITNTestApp://"
    */
    
    private let tw_consumerKey = "n7YSfPhxCWRl2UMzMjGvifB8J"
    private let tw_consumerSecret = "AsPxQmra31to7nvKBFMwYXW4nBu6nLoAOwrWZAqmYdsPqu0gXW"
    static let callbackUrl = "ITNTestApp://"

    private var callback: ( (Bool)->() )?
    
    // ************************************************************ //
    private func start() {
        if(self.swifter == nil) {
            self.swifter = Swifter(consumerKey: tw_consumerKey,
                consumerSecret: tw_consumerSecret, appOnly: false)
        }
    }
    
    func isLogged() -> Bool {
        let logged = ShareAPI.readBoolKey(keySHARE_TWLogged)
        if logged {
            return true
        } else {
            return false
        }
    }
    
    func login(vc: UIViewController, callback: @escaping (Bool)->()) {
        self.callback = callback
        
        self.start()
        let callbackUrl = URL(string: TW_SDK.callbackUrl)!
        
        self.swifter!.authorize(withCallback: callbackUrl,
                                presentingFrom: vc,
                                authSuccess: { (T, V) in
            
            print("TW - Logueado")
                
            /*
                callback(true)
                ShareAPI.writeKey(self.keySHARE_TWLogged, value: true)
            */
            
            self.ITN_login(token: T, verifier: V)

        }, failure: { _ in
            print("TW - Cancelled")
            if(vc.presentingViewController != nil) {
                vc.dismiss(animated: true)
            }
            self.callback?(false)
        })
        
    }
    
    private func ITN_login(token T: String, verifier V: String) {
        let api = ShareAPI.instance
        
//        api.login_TW(token: T, verifier: V) { (success) in
//            self.callback?(true)
//            ShareAPI.writeKey(self.keySHARE_TWLogged, value: true)
//            ShareAPI.LOG(where: "Twitter login", msg: "Success")
//        }
        
        api.login(type: "Twitter", accessToken: T, secret: V) { (success) in
            self.callback?(true)
            ShareAPI.writeKey(self.keySHARE_TWLogged, value: true)
            ShareAPI.LOG(where: "Twitter login", msg: "Success")
        }
    }
    
    func logout(vc: UIViewController, callback: @escaping (Bool)->() ) {
        let _h = "Twitter"
        let _q = "Close current Twitter session?"
        
        ShareAPI.logoutDialog(vc: vc, header: _h, question: _q) { (wasLoggedOut) in
            if(wasLoggedOut) {
                ShareAPI.removeKey(self.keySHARE_TWLogged)
                ShareAPI.instance.disconnect(type: "Twitter")
            }
            callback(wasLoggedOut)
        }
    }
    
}

extension TW_SDK {
    
    
    
}
