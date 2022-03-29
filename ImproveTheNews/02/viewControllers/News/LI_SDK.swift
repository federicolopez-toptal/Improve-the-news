//
//  LI_SDK.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 28/03/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class LI_SDK: NSObject {
    
    static let instance = LI_SDK()
    private let keySHARE_LILogged = "SHARE_LILogged"
    
    private var vc: UIViewController?
    private let webView = WKWebView()
    
    private let CLIENT_ID = "78dxrtqsoxss3p"
    private let CLIENT_SECRET = "FesDHpaPtRaRlkdR"
    private let REDIRECT_URI = "https://www.improvethenews.org/"
    
    private let SCOPE = "r_liteprofile%20r_emailaddress"
    private let AUTHURL = "https://www.linkedin.com/oauth/v2/authorization"
    private let TOKENURL = "https://www.linkedin.com/oauth/v2/accessToken"
    
    // ************************************************************ //
    func isLogged() -> Bool {
        let logged = ShareAPI.readBoolKey(keySHARE_LILogged)
        if logged {
            return true
        } else {
            return false
        }
    }
    
    func login(vc: UIViewController) {
        self.vc = vc
        
        let nav = self.createNavController()
        self.loadLoginPage()
        self.vc?.present(nav, animated: true)
    }
    
    private func ITN_login(token: String) {
        let api = ShareAPI.instance
        api.login(type: "Linkedin", accessToken: token) { (success) in
            ShareAPI.writeKey(self.keySHARE_LILogged, value: true)
            print("LINKEDIN login to the server -", success)
        }
    }
    
    func logout(vc: UIViewController, callback: @escaping (Bool)->() ) {
        let _h = "LinkedIn"
        let _q = "Close current LinkedIn session?"
        
        ShareAPI.logoutDialog(vc: vc, header: _h, question: _q) { (wasLoggedOut) in
            if(wasLoggedOut) {
                //LoginManager().logOut()
                ShareAPI.removeKey(self.keySHARE_LILogged)
                ShareAPI.instance.disconnect(type: "Linkedin")
            }
            callback(wasLoggedOut)
        }
    }
    
    // ************************************************************ //
}

extension LI_SDK {
    private func loadLoginPage() {
        let state = "linkedin\(Int(NSDate().timeIntervalSince1970))"
        let authURLFull = AUTHURL + "?response_type=code&client_id=" + CLIENT_ID +
            "&scope=" + SCOPE + "&state=" + state + "&redirect_uri=" + REDIRECT_URI

        let urlRequest = URLRequest.init(url: URL.init(string: authURLFull)!)
        self.webView.load(urlRequest)
    }
}

extension LI_SDK { // UI
    
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
        appearance.backgroundColor = UIColor(red: 1, green: 98, blue: 182)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.compactAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance

        vc.navigationItem.title = "linkedin.com"
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

extension LI_SDK: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let url = (navigationAction.request.url?.absoluteString)! as String
        //print("LINKEDIN", url)
        
        /*if(url.contains("/login-cancel")) {
            print("LINKEDIN - Cancelled")
            self.cancelAction()
            decisionHandler(.cancel)
        } else
        */
        
         if(url.contains("?code=")) {
            print("LINKEDIN - Logueado")
            decisionHandler(.cancel)
            self.getAccessTokenWith(authCode: self.getAuthCodeFrom(url: url)) { (token) in
                if let _token = token {
                    self.ITN_login(token: _token)
                    self.cancelAction()
                }
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func getAuthCodeFrom(url: String) -> String {
        let _url = URL(string: url)
        let params = _url?.params()
        let code = params?["code"] as! String
        
        return code
    }
    
    private func getAccessTokenWith(authCode: String, callback: @escaping (String?) -> ()) {
        // POST params
        let grantType = "authorization_code"
        let postParams = "grant_type=" + grantType +
            "&code=" + authCode + "&redirect_uri=" + REDIRECT_URI + "&client_id=" +
            CLIENT_ID + "&client_secret=" + CLIENT_SECRET
        
        let postData = postParams.data(using: String.Encoding.utf8)
        let request = NSMutableURLRequest(url: URL(string: TOKENURL)!)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        //let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (D, R, E) -> Void in
            if let _error = E {
                print("LINKEDIN", _error.localizedDescription)
                callback(nil)
                return
            }
            
            let statusCode = (R as! HTTPURLResponse).statusCode
            if statusCode == 200 {
                let results = try! JSONSerialization.jsonObject(with: D!,
                    options: .allowFragments) as? [AnyHashable: Any]

                let accessToken = results?["access_token"] as! String
                callback(accessToken)
            } else {
                callback(nil)
            }
        }
        task.resume()
    }
    
}
