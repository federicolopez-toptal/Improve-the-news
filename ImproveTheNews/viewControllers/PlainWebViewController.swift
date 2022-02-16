//
//  PlainWebViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 25/01/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation
import UIKit
import WebKit


class PlainWebViewController: UIViewController, WKUIDelegate {

    var safeArea: UILayoutGuide!
    let shade = UIView()
    
    var loadCount = 0
    
    lazy var webView: WKWebView = {
        let cfg = WKWebViewConfiguration()
        
        /*
        if #available(iOS 14.0, *) {
            let prefs = WKWebpagePreferences()
            prefs.allowsContentJavaScript = true
            prefs.defaultWebpagePreferences = prefs
        } else {
            let prefs = WKPreferences()
            prefs.javaScriptEnabled = true
            cfg.preferences = prefs
        }
        */
        
        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true
        cfg.preferences = prefs
        
        let webview = WKWebView(frame: .zero, configuration: cfg)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        webview.translatesAutoresizingMaskIntoConstraints = false

        return webview
    }()
    
    var webViewTopConstraint: NSLayoutConstraint?
    var webViewBottomConstraint: NSLayoutConstraint?
    
    
    // MARK: - Init
    init(url: String, title: String) {
        super.init(nibName: nil, bundle: nil)

        let url = URL(string: url)!   //!!!
        //let url = Bundle.main.url(forResource: "test.html", withExtension: nil)!
        //let url = URL(string: "https://www.javatpoint.com/oprweb/test.jsp?filename=javascript-alert1")!
        
        let cookieDisplayMode = HTTPCookie(properties: [
            .domain: url.host!,
            .path: "/",
            .name: "brightdark",
            .value: DARKMODE() ? "00" : "01",
            .secure: "true",
            .expires: NSDate(timeIntervalSinceNow: 60 * 60)
        ])
        
        // Sliders
        var slidersValue = SliderValues.sharedInstance.getBiasPrefs()
        
            // Banner
            var banner: String?
            for bannerID in BannerView.bannerHeights.keys {
                let key = "banner_apiParam_" + bannerID
                if let value = UserDefaults.standard.string(forKey: key) {
                    banner = value
                }
            }
            if(banner == nil){ banner = "" }
            banner! += NewsViewController.get_vParams() // Some preferences
            slidersValue += banner!
        
            // split on/off + Prefs panel status
            slidersValue += NewsViewController.biasStatusForCookie
            
            // Display mode + Current layout
            var displayMode = "0"
            if(!DARKMODE()){ displayMode = "1" }
            if(Utils.shared.currentLayout == .denseIntense) {
                slidersValue += "LA0" + displayMode
            } else if(Utils.shared.currentLayout == .textOnly) {
                slidersValue += "LA1" + displayMode
            } else {
                slidersValue += "LA2" + displayMode
            }
            
        slidersValue = slidersValue.replacingOccurrences(of: "&sliders=", with: "")
        let cookieSliders = HTTPCookie(properties: [
            .domain: url.host!,
            .path: "/",
            .name: "slidercookies",
            .value: slidersValue,
            .secure: "true",
            .expires: NSDate(timeIntervalSinceNow: 60 * 60)
        ])
        print("SLIDERS", slidersValue)
        
        var request = URLRequest(url: url)
        
        if let _cookieDisplayMode = cookieDisplayMode, let _cookieSliders = cookieSliders {
            let values = HTTPCookie.requestHeaderFields(with: [_cookieDisplayMode, _cookieSliders])
            request.allHTTPHeaderFields = values
            //self.webview.configuration.websiteDataStore.httpCookieStore.setCookie(_cookie)
        }

        self.webView.load(request)
        
        navigationItem.largeTitleDisplayMode = .never
        safeArea = view.layoutMarginsGuide
        navigationItem.title = title
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return STATUS_BAR_STYLE()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBarButton = UIBarButtonItem(image: UIImage(named: "chevron-backward")!, style: .plain, target: self, action: #selector(goBack(_:)))
        
        navigationItem.setLeftBarButton(backBarButton, animated: true)
        
        setupUI()
    }
    
    func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(webView)
        
        let bottom = SAFE_AREA()!.bottom
        
        self.webViewTopConstraint = webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        self.webViewBottomConstraint = webView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: bottom)
             
        NSLayoutConstraint.activate([
            self.webViewTopConstraint!,
            webView.leftAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.webViewBottomConstraint!,
            webView.rightAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStatusBar()
        setupWebNavBar()
        initControls()
    }
    
    

}

// MARK: UI setup
extension PlainWebViewController {

    func setupWebNavBar() {
        navigationController?.navigationBar.tintColor = DARKMODE() ? .white : textBlack
    }
    
    func initControls() {
          let configuration = WKWebViewConfiguration()
          let contentController = WKUserContentController()
          configuration.userContentController = contentController
    }

}

// MARK: User interaction(s)
extension PlainWebViewController {
    
    @objc func goBack(_ sender:UIBarButtonItem!) {
          self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK:
extension PlainWebViewController: WKNavigationDelegate {
    // Ref: https://www.hackingwithswift.com/articles/112/the-ultimate-guide-to-wkwebview
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        self.loadCount += 1
        
        if let domain = navigationAction.request.url?.host {
            var goToUrl = navigationAction.request.url!.absoluteString
            goToUrl = goToUrl.replacingOccurrences(of: "http://", with: "")
            goToUrl = goToUrl.replacingOccurrences(of: "https://", with: "")
            goToUrl = goToUrl.replacingOccurrences(of: "/", with: "")
            
            if(goToUrl == domain) {
                // Back to headlines
                decisionHandler(.cancel)
                self.navigationController?.popViewController(animated: true)
            } else {
                if(IS_iPAD()) {
                    if(self.loadCount>1) {
                        UIApplication.shared.openURL(navigationAction.request.url!)
                        decisionHandler(.cancel)
                    } else {
                        decisionHandler(.allow)
                    }
                } else {
                    decisionHandler(.allow)
                }
            }
        } else {
            decisionHandler(.cancel)
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if let frame = navigationAction.targetFrame,
            frame.isMainFrame {
            return nil
        }
        
        //webView.load(navigationAction.request)
        UIApplication.shared.openURL(navigationAction.request.url!)
        
        return nil
    }
    
}


