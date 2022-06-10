//
//  RED_SDK.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 31/03/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation
import UIKit
import WebKit

// REF: https://github.com/reddit-archive/reddit/wiki/OAuth2


class RED_SDK: NSObject {
    
    static let instance = RED_SDK()
    private let keySHARE_REDLogged = "SHARE_REDLogged"
    
    private var vc: UIViewController?
    private let webView = WKWebView()
    private var rndState = ""
    
    
//    private let CLIENT_ID = "4ohV1VzBRgfMRbbtlSXlWA"
//    private let REDIRECT_URI = "https://www.improvemynews.com/reddit"
    
//    private let CLIENT_ID = "GU2ZOAR1Tpku_xdtt8fwpw"
//    private let CLIENT_SECRET = "cM01yBeT415RA8VqFHfHuVE5NRbPHA"
//    private let REDIRECT_URI = "https://www.improvemynews.com/reddit"
    
    private let CLIENT_ID = "00-5QMHihPOO4LHhFxHuFg"
    private let CLIENT_SECRET = ""
    private let REDIRECT_URI = "https://www.improvemynews.com/reddit-app"
    
    private var callback: ( (Bool)->() )?
    
    // ************************************************************ //
    func isLogged() -> Bool {
        let logged = ShareAPI.readBoolKey(keySHARE_REDLogged)
        if logged {
            return true
        } else {
            return false
        }
    }
    
    func login(vc: UIViewController, callback: @escaping (Bool)->()) {
        self.vc = vc
        self.callback = callback
        
        let nav = self.createNavController()
        self.loadLoginPage()
        self.vc?.present(nav, animated: true)
    }
    
    func logout(vc: UIViewController, callback: @escaping (Bool)->() ) {
        let _h = "REDDIT"
        let _q = "Close current REDDIT session?"
        
        ShareAPI.logoutDialog(vc: vc, header: _h, question: _q) { (wasLoggedOut) in
            if(wasLoggedOut) {
                self.logout_web {
                    ShareAPI.removeKey(self.keySHARE_REDLogged)
                    ShareAPI.instance.disconnect(type: "Reddit")
                }
                
            }
            callback(wasLoggedOut)
        }
    }
    
    func logoutDirect() {
        self.logout_web {
            ShareAPI.removeKey(self.keySHARE_REDLogged)
            ShareAPI.instance.disconnect(type: "Reddit")
        }
    }
    
    private func logout_web(callback: @escaping ()->()) {
        
        let url = "https://www.reddit.com/logout"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        self.webView.load(request)
        callback()
    }
    
    // ************************************************************ //
}

extension RED_SDK {

    private func RND_state() -> String {
        var result = ""
        let chars = "ab0cd1ef2gh3ij4kl5mn6op7qr8st9uvwxyz"
        
        for _ in 1...29 {
            let i = Int.random(in: 0...chars.count-1)
            result += String(chars[i])
        }
        return result
    }
    
    private func custom_state() -> String {
        let jwt = ShareAPI.instance.getBearerAuth().replacingOccurrences(of: "Bearer ", with: "")
        return ShareAPI.instance.uuid! + "{{}}" + jwt
    }

    private func loadLoginPage() {

        self.rndState = RND_state()
        let authUrl = "https://www.reddit.com/api/v1/authorize.compact?client_id=" + CLIENT_ID +
            "&response_type=code&state=" + self.rndState + "&redirect_uri=" + REDIRECT_URI +
            "&scope=identity,submit&duration=permanent"
            //scope=read
    
        let urlRequest = URLRequest.init(url: URL.init(string: authUrl)!)
        self.webView.load(urlRequest)
    }
    
    private func getTokenWith(code: String, callback: @escaping (String?, String?) -> ()) {
        
        let here = "Reddit, getToken"
        let tokenUrl = "https://www.reddit.com/api/v1/access_token"
        let params = "grant_type=authorization_code&code=" + code + "&redirect_uri=" + REDIRECT_URI
        
        var request = URLRequest(url: URL(string: tokenUrl)!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        request.setValue(self.authorization(), forHTTPHeaderField: "Authorization")
        request.httpBody = params.data(using: .utf8)
        
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
            
                if let json = ShareAPI.json(fromData: data) {
                    if let _token = json["access_token"] as? String,
                        let _refresh = json["refresh_token"] as? String {
                        
                        ShareAPI.LOG(where: here, msg: "got access token:" + _token)
                        callback(_token, _refresh)
                    } else {
                        ShareAPI.LOG_ERROR(where: here, msg: "No access token")
                        callback(nil, nil)
                    }
                } else {
                    ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
                    callback(nil, nil)
                }
            }
        }
        task.resume()
    }
    
    private func authorization() -> String {
        let username = CLIENT_ID
        let password = CLIENT_SECRET
        let loginString = username + ":" + password
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        return "Basic " + base64LoginString
    }
}

extension RED_SDK { // UI
    
    private func createLinkedInViewController() -> UIViewController {
        let vc = UIViewController()
        
        self.webView.navigationDelegate = self
        vc.view.addSubview(self.webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.webView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            self.webView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            self.webView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            self.webView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        return vc
    }
    
    private func createNavController() -> UINavigationController {
        let vc = self.createLinkedInViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = false
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel,
            target: self,
            action: #selector(self.cancelAction))
        vc.navigationItem.leftBarButtonItem = cancelButton
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
            target: self,
            action: #selector(self.refreshAction))
        vc.navigationItem.rightBarButtonItem = refreshButton
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(red: 255, green: 51, blue: 18)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.compactAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance

        vc.navigationItem.title = "reddit.com"
        nav.navigationBar.tintColor = UIColor.white
        nav.modalPresentationStyle = .overFullScreen
        nav.modalTransitionStyle = .coverVertical
        
        return nav
    }

    @objc func cancelAction() {
        DispatchQueue.main.async {
            self.vc?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func refreshAction() {
        self.webView.reload()
    }
}

extension RED_SDK: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        var url = (navigationAction.request.url?.absoluteString)! as String
        
        let params = URL(string: url)!.params()
        if let _state = params["state"] as? String,
            _state == self.rndState,
            let _code = params["code"] as? String {
            //let _token = params["access_token"] as? String {
            
                print("SHARE", _code)
                
                self.getTokenWith(code: _code) { (token, refresh) in
                    if let _token = token, let _refresh = refresh {
                        self.ITN_login(token: _token, refresh: _refresh)
                    }
                }
                decisionHandler(.cancel)
                
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func ITN_login(token: String, refresh: String) {
        let api = ShareAPI.instance
        api.login(type: "Reddit", accessToken: token, secret: refresh) { (success) in
            ShareAPI.writeKey(self.keySHARE_REDLogged, value: true)
            ShareAPI.LOG(where: "Reddit login", msg: "Success")
            self.callback?(true)
            self.cancelAction()
        }
    }
    
}
