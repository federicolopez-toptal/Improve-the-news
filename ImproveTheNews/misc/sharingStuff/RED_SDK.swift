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

class RED_SDK: NSObject {
    
    static let instance = RED_SDK()
    private let keySHARE_REDLogged = "SHARE_REDLogged"
    
    private var vc: UIViewController?
    private let webView = WKWebView()
    private var rndState = ""
    
    private let CLIENT_ID = "4ohV1VzBRgfMRbbtlSXlWA"
    private let REDIRECT_URI = "https://www.improvethenews.org"
    
    private var callback: ( (Bool)->() )?
    
    
    /*
    private let CLIENT_ID = "78dxrtqsoxss3p"
    private let CLIENT_SECRET = "FesDHpaPtRaRlkdR"
    private let REDIRECT_URI = "https://www.improvethenews.org/"
    
    private let SCOPE = "r_liteprofile%20r_emailaddress"
    private let AUTHURL = "https://www.linkedin.com/oauth/v2/authorization"
    private let TOKENURL = "https://www.linkedin.com/oauth/v2/accessToken"
    */
    
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
                //LoginManager().logOut()
                
                self.logout_web {
                    ShareAPI.removeKey(self.keySHARE_REDLogged)
                    //ShareAPI.instance.disconnect(type: "Reddit")
                }
                
            }
            callback(wasLoggedOut)
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
        
        for _ in 1...19 {
            let i = Int.random(in: 0...chars.count-1)
            result += String(chars[i])
        }
        return result
    }

    private func loadLoginPage() {
        // https://github.com/reddit-archive/reddit/wiki/OAuth2
        
        self.rndState = RND_state()
        let authUrl = "https://www.reddit.com/api/v1/authorize.compact?client_id=" + CLIENT_ID +
            "&response_type=token&state=" + self.rndState + "&redirect_uri=" + REDIRECT_URI +
            "&scope=read"
    
        let urlRequest = URLRequest.init(url: URL.init(string: authUrl)!)
        self.webView.load(urlRequest)
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
        self.webView.reload() //!!!
    }
}

extension RED_SDK: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        var url = (navigationAction.request.url?.absoluteString)! as String
        url = url.replacingOccurrences(of: "#", with: "?")
        //print("REDDIT", url)
        
        let params = URL(string: url)!.params()
        if let _state = params["state"] as? String,
            _state == self.rndState,
            let _token = params["access_token"] as? String {
            
                //self.ITN_login(token: _token)
                decisionHandler(.cancel)
                self.cancelAction()
                ShareAPI.writeKey(self.keySHARE_REDLogged, value: true)
                self.callback?(true)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func ITN_login(token: String) {
        let api = ShareAPI.instance
        api.login(type: "Reddit", accessToken: token) { (success) in
            ShareAPI.writeKey(self.keySHARE_REDLogged, value: true)
            //ShareAPI.LOG(where: "Reddit login", msg: "Success")
        }
    }
    
    /*
    private func authorization() -> String {
        let username = CLIENT_ID
        let password = ""
        let loginString = username + ":" + password
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        return "Basic " + base64LoginString
    }
    
    private func getAccessTokenWith(code: String, callback: @escaping (String?) -> ()) {
        let url = "https://www.reddit.com/api/v1/access_token"
        
        let bodyJson: [String: String] = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": REDIRECT_URI
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(self.authorization(), forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                print("REDDIT/GET.TOKEN/ERROR", _error.localizedDescription)
            } else {
                let str = String(decoding: data!, as: UTF8.self)
                print(str)
            
                if let json = ShareAPI.json(fromData: data) {
                    if let _token = json["access_token"] as? String {
                        callback(_token)
                    } else {
                        print("REDDIT/GET.TOKEN/ERROR", "No access_token")
                        callback(nil)
                    }
                } else {
                    print("REDDIT/GET.TOKEN/ERROR", "Error parsing json")
                    callback(nil)
                }
            }
        }
        task.resume()
    }
    */
}
