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
        let shareBarButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up")!, style: .plain, target: self, action: #selector(sharePressed(_:)))
        shareBarButton.tintColor = DARKMODE() ? accentOrange : textBlack
        
        //navigationItem.setRightBarButton(shareBarButton, animated: true)
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
    
    /*
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    @objc func redirect(_ sender: UIButton!) {
        let link = self.contestedclaims[sender.tag].link
        let vc = WebViewController(url: link, title: "Context", annotations: [])
        self.navigationController?.pushViewController(vc, animated: false)
    }
    */

}

// MARK: User responses
extension PlainWebViewController {
    
    @objc func goBack(_ sender:UIBarButtonItem!) {
          self.navigationController?.popViewController(animated: true)
    }
      
    @objc func handleDismiss() {
        
        self.webViewTopConstraint!.constant = 0
        self.webView.layoutIfNeeded()
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            self.view.layoutIfNeeded()

        }, completion: nil)
        
    }
      
    @objc func sharePressed(_ sender: UIBarButtonItem!) {
          let link = [pageURL]
          let ac = UIActivityViewController(activityItems: link, applicationActivities: nil)
          present(ac, animated: true)
    }
    
}


