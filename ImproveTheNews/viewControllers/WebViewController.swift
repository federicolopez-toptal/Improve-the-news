//
//  WebViewController.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 7/3/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate {
    
    var pageURL = ""
    var markupsLinks = [String]()
    
    var isMarkUpShowing = true
    
    var safeArea: UILayoutGuide!
    let shade = UIView()
    let ratingsMenu = RatingsLauncher()
    var sliderValues: SliderValues!
    
    // markup variables
    var contestedclaims = [Markups]()
    var markupButton: UIButton = {
        let button = UIButton(image: UIImage(systemName: "exclamationmark.triangle")!)
        button.backgroundColor = .orange
        button.tintColor = .white
        button.addTarget(self, action: #selector(showMarkups(_:)), for: .touchUpInside   )
        button.clipsToBounds = true
        return button
    }()
    let markupView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    var stackView: UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let sourceLinkAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "OpenSans-Bold", size: 14)!,
    .foregroundColor: UIColor.white]
    
    // markup constraints
    var markupTopAnchorHidden: NSLayoutConstraint?
    var markupTopAnchorVisible: NSLayoutConstraint?
    
    // timer
    static var startTime: CFAbsoluteTime!
    
    init(url: String, title: String, annotations: [Markups]) {
        super.init(nibName: nil, bundle: nil)

        contestedclaims = annotations
        print("GATO2", contestedclaims.count)
        
        pageURL = url
        
        sliderValues = SliderValues.sharedInstance
        sliderValues.setCurrentArticle(article: url)
        
        WebViewController.startTime = CFAbsoluteTimeGetCurrent()
        
        let url = URL(string: url)!
        let request = URLRequest(url: url)
        webView.load(request)
        
        navigationItem.largeTitleDisplayMode = .never
        safeArea = view.layoutMarginsGuide
        navigationItem.title = title
        hidesBottomBarWhenPushed = true
        
        loadMarkups()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webview = WKWebView(frame: .zero, configuration: webConfiguration)
        webview.uiDelegate = self
        webview.translatesAutoresizingMaskIntoConstraints = false

//        view.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress),options: .new, context: nil)

        return webview
    }()
    
    lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        return progress
    }()
    
    var webViewTopConstraint: NSLayoutConstraint?
    var webViewBottomConstraint: NSLayoutConstraint?
    
    func setupUI() {
        self.view.backgroundColor = .white
        
        //self.view.addSubview(progressView)
        self.view.addSubview(webView)
        
        self.webViewTopConstraint = webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        self.webViewBottomConstraint = webView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
             
        NSLayoutConstraint.activate([
            self.webViewTopConstraint!,
            webView.leftAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.webViewBottomConstraint!,
            webView.rightAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ])
        self.view.addSubview(markupView)
        
        NSLayoutConstraint.activate([
            markupView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            markupView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            markupTopAnchorVisible!
        ])
        
        // markup button IFF there are markups
        if self.contestedclaims.count > 0 {
            configureMarkupButton()
        }
        
        // show ratings at bottom
        showRatingsMenu()
    }
    
    func showRatingsMenu() {
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        let height: CGFloat = 75
        let y: CGFloat = screenSize.size.height - height - 88
        ratingsMenu.frame = CGRect(x: 0, y: y, width: view.frame.width, height: height)
        ratingsMenu.buildView()
                
        view.addSubview(ratingsMenu)
        //ratingsMenu.isHidden = true
    }
    
    func hideRatingView() {
        var mFrame = ratingsMenu.frame
        mFrame.origin.y += mFrame.size.height + 10
        
        UIView.animate(withDuration: 0.5) {
            self.ratingsMenu.frame = mFrame
        } completion: { (success) in
            print("Done!")
        }
    }
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupWebNavBar()
        initControls()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        markupTopAnchorHidden = markupView.bottomAnchor.constraint(equalTo: self.view.topAnchor)
        markupTopAnchorVisible = markupView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        
        let backBarButton = UIBarButtonItem(image: UIImage(named: "chevron-backward")!, style: .plain, target: self, action: #selector(goBack(_:)))
        let shareBarButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up")!, style: .plain, target: self, action: #selector(sharePressed(_:)))
        shareBarButton.tintColor = DARKMODE() ? accentOrange : textBlack
        
        navigationItem.setRightBarButton(shareBarButton, animated: true)
        navigationItem.setLeftBarButton(backBarButton, animated: true)
        
        ratingsMenu.delegate = self
        setupUI()
    }
    
}

// MARK: UI setup
extension WebViewController {
    func setupWebNavBar() {
        navigationController?.navigationBar.tintColor = DARKMODE() ? .white : textBlack
    }
    
    func initControls() {
          
          //WKUserContentController allows us to add Javascript scripts to our webView that will run either at the beginning of a page load OR at the end of a page load.

          let configuration = WKWebViewConfiguration()
          let contentController = WKUserContentController()
          configuration.userContentController = contentController
          
    }
    
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

}

// MARK: User responses
extension WebViewController {
    
    func configureMarkupButton() {
        
        view.addSubview(markupButton)
        markupButton.frame = CGRect(x: view.frame.maxX-60, y: view.frame.height - 150, width: 50, height: 50)
        //markupButton.frame = CGRect(x: 60, y: 60, width: 50, height: 50)
        markupButton.layer.cornerRadius = 0.5 * markupButton.bounds.size.width
    }
    
    @objc func goBack(_ sender:UIBarButtonItem!) {
          self.navigationController?.popViewController(animated: true)
    }
      
    @objc func handleDismiss() {
        
        markupTopAnchorVisible?.isActive = false
        markupTopAnchorHidden?.isActive = true
        
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
      
    @objc func showMarkups(_ sender:UIButton!) {
        
        if isMarkUpShowing {
            self.handleDismiss()
            isMarkUpShowing = false
        } else {
            markupTopAnchorHidden?.isActive = false
            markupTopAnchorVisible?.isActive = true
            isMarkUpShowing = true
        }
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            self.view.layoutIfNeeded()

        }, completion: nil)
    }
    
}

// MARK: Markup Control
extension WebViewController {
    
    func loadMarkups() {
        
        markupView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: markupView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: markupView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: markupView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: markupView.trailingAnchor)
        ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.distribution = .fillProportionally
        
        //print("# of markups: \(self.contestedclaims.count)")
        var first = true
        var heightSum: CGFloat = 0.0
        self.markupsLinks = [String]()
        for (i, cc) in self.contestedclaims.enumerated() {

            let markup = UIView(backgroundColor: accentOrange)
            stackView.addArrangedSubview(markup)
            
            markup.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                markup.heightAnchor.constraint(equalToConstant: 100),
                markup.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                markup.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            ])
            heightSum += 100
            
            // add top border
            if !first {
                
                let border = UIView()
                
                border.backgroundColor = UIColor(rgb: 0xcc5500)
                markup.addSubview(border)
                
                border.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    border.heightAnchor.constraint(equalToConstant: 2),
                    border.trailingAnchor.constraint(equalTo: markup.trailingAnchor),
                    border.leadingAnchor.constraint(equalTo: markup.leadingAnchor),
                    border.topAnchor.constraint(equalTo: markup.topAnchor)
                ])
            }
            
            let markupTitle = UILabel(text: cc.type, font: UIFont(name: "OpenSans-Bold", size: 15), textColor: .black, textAlignment: .left, numberOfLines: 2)
            let str = NSMutableAttributedString(string: cc.description + " | Source", attributes: sourceLinkAttributes)
            let foundRange = str.mutableString.range(of: "Source")
            str.addAttribute(NSAttributedString.Key.link, value: cc.link, range: foundRange)
            let markupText = ResponsiveTextView(backgroundColor: accentOrange)
            markupText.attributedText = str
            markupText.textContainerInset.left = -4
            markupText.isEditable = false
            markupText.dataDetectorTypes = .all
            
            markup.addSubview(markupTitle)
            markupTitle.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                markupTitle.leadingAnchor.constraint(equalTo: markup.leadingAnchor, constant: 15),
                markupTitle.trailingAnchor.constraint(equalTo: markup.trailingAnchor, constant: -40),
                markupTitle.topAnchor.constraint(equalTo: markup.topAnchor, constant: 10),
                markupTitle.heightAnchor.constraint(equalToConstant: 20)
            ])
            
            markup.addSubview(markupText)
            markupText.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                markupText.leadingAnchor.constraint(equalTo: markup.leadingAnchor, constant: 15),
                markupText.trailingAnchor.constraint(equalTo: markup.trailingAnchor, constant: -15),
                markupText.topAnchor.constraint(equalTo: markupTitle.bottomAnchor, constant: 5),
                markupText.bottomAnchor.constraint(equalTo: markup.bottomAnchor, constant: -10),
            ])
            
            
            let buttonArea = UIButton(type: .system)
            buttonArea.backgroundColor = .green
            markup.addSubview(buttonArea)
            buttonArea.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                buttonArea.leadingAnchor.constraint(equalTo: markup.leadingAnchor),
                buttonArea.trailingAnchor.constraint(equalTo: markup.trailingAnchor),
                buttonArea.topAnchor.constraint(equalTo: markup.topAnchor),
                buttonArea.bottomAnchor.constraint(equalTo: markup.bottomAnchor)
            ])
            buttonArea.tag = 100 + i
            self.markupsLinks.append(cc.link)
            buttonArea.addTarget(self, action: #selector(buttonAreaTap(sender:)), for: .touchUpInside)
            buttonArea.backgroundColor = .clear
            buttonArea.superview?.sendSubviewToBack(buttonArea)
            
            // add cancel button
            if first {
                let dismissButton = UIButton(backgroundColor: accentOrange)
                dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
                dismissButton.tintColor = .black
                dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
                
                markup.addSubview(dismissButton)
                dismissButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    dismissButton.topAnchor.constraint(equalTo: markup.topAnchor, constant: 7),
                    dismissButton.trailingAnchor.constraint(equalTo: markup.trailingAnchor, constant: -15),
                    dismissButton.widthAnchor.constraint(equalToConstant: 30),
                    dismissButton.heightAnchor.constraint(equalToConstant: 30)
                ])
            }
            
            
            
            first = false
        }
    
        // ---------------------------
        /*
        webView
        
        
                .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,
                constant: heightSum)
            */
            
        self.webViewTopConstraint!.constant = heightSum
        self.webView.layoutIfNeeded()
    }
    
    @objc func buttonAreaTap(sender: UIButton) {
        let index = sender.tag - 100
        let link = self.markupsLinks[index]
        let url = URL(string: link)
        
        UIApplication.shared.open(url!)
    }
    
}



extension NSAttributedString {
    
    static func makeHyperlink(for path: String, in string: String, as substring: String) -> NSAttributedString {
        
        let nstring = NSString(string: string)
        let sbstrRange = nstring.range(of: substring)
        let attributedString = NSMutableAttributedString(string: string)
        
        attributedString.addAttribute(.link, value: path, range: sbstrRange)
        
        return attributedString
    }
}

class ResponsiveTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.delaysContentTouches = false
        
        self.isScrollEnabled = false
        self.isEditable = false
        self.isUserInteractionEnabled = true
        self.isSelectable = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // location of the tap
        var location = point
        location.x -= self.textContainerInset.left
        location.y -= self.textContainerInset.top
        
        // find the character that's been tapped
        let characterIndex = self.layoutManager.characterIndex(for: location, in: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if characterIndex < self.textStorage.length {
            // if the character is a link, handle the tap as UITextView normally would
            if (self.textStorage.attribute(NSAttributedString.Key.link, at: characterIndex, effectiveRange: nil) != nil) {
                return self
            }
        }
        
        // otherwise return nil so the tap goes on to the next receiver
        return nil
    }
}

extension WebViewController: RatingsLauncherDelegate {
    
    func RatingCompleted() {
        self.webViewBottomConstraint?.constant = 0
        self.webView.layoutIfNeeded()
        
        self.hideRatingView()
    }
    
    func RatingOnError() {
    
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Warning",
                                message: "An error ocurred while sending your rating. Please, try again later",
                                preferredStyle: .alert)
                      
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
     
/*
        let detailsAction = UIAlertAction(title: "Details", style: .default) { (action) in
            NotificationCenter.default.post(name: NOTIFICATION_SHOW_SLIDERS_INFO, object: nil)
        }
        
        
        alert.addAction(detailsAction)
        alert.addAction(okAction)
        alert.preferredAction = okAction
*/

        
        
    }
    
}
