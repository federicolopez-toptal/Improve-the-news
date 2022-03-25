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
    static let callbackUrl = "ITNTestApp://"
    
    private let tw_consumerKey = "csb01s65kGzYIr3OGyYQGIf52"
    private let tw_consumerSecret = "qtdyt54STbMgN2ieoZKj4NRhMOtDvQRJJOgwa74Sw002W6WgB5"
    
    
    // ************************************************************ //
    func login(vc: UIViewController) {
        self.start()
        let callback = URL(string: TW_SDK.callbackUrl)!
        
        self.swifter!.authorize(withCallback: callback,
                                presentingFrom: vc,
                                authSuccess: { (T, V) in
            
            print("TW - Logueado")
            self.ITN_login(token: T, verifier: V)

        }, failure: { _ in
            print("TW - Cancelled")
            if(vc.presentingViewController != nil) {
                vc.dismiss(animated: true)
            }
        })
        
    }
    
    private func ITN_login(token T: String, verifier V: String) {
        let api = ShareAPI.instance
        api.login_TW(token: T, verifier: V) { (success) in
            ShareAPI.writeKey(self.keySHARE_TWLogged, value: true)
            print("TW login to the server -", success)
        }
    }
    
    // ************************************************************ //
    
}

extension TW_SDK {
    
    private func start() {
        if(self.swifter == nil) {
            self.swifter = Swifter(consumerKey: tw_consumerKey,
                consumerSecret: tw_consumerSecret, appOnly: false)
        }
    }
    
}
