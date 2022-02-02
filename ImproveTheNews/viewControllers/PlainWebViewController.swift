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

    var pageURL = ""
    var safeArea: UILayoutGuide!
    let shade = UIView()
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webview = WKWebView(frame: .zero, configuration: webConfiguration)
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

        self.pageURL = url
        
        let url = URL(string: url)!
        let request = URLRequest(url: url)
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
        
        if let rUrl = navigationAction.request.url?.absoluteString {
            if(rUrl == "https://www.improvethenews.org/") {
                decisionHandler(.cancel)
                self.navigationController?.popViewController(animated: true)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
        
        //print( "NAVIGATION", navigationAction.request.url )
        //decisionHandler(.allow)
    }
    
}


