//
//  MyAccountV2ViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 09/06/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit
import SafariServices

class MyAccountV2ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainStackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var ITNsepConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteAccountsepConstraint: NSLayoutConstraint!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var screenNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var saveNewsletterOptions = false
    @IBOutlet weak var subscribeButton: SignInUpOrangeButton!
    
    @IBOutlet weak var facebookButton: SignInUpOrangeButton!
    @IBOutlet weak var twitterButton: SignInUpOrangeButton!
    @IBOutlet weak var linkedinButton: SignInUpOrangeButton!
    @IBOutlet weak var redditButton: SignInUpOrangeButton!
    
    private let loadingView = UIView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setContentView()
        SETUP_NAVBAR(viewController: self,
            homeTap: nil,
            menuTap: nil,
            searchTap: nil,
            userTap: nil)
            
        self.adaptStyle()
        self.buildLoading()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewOnTap(sender:)))
        self.contentView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
        
        self.setButtonTexts()
        self.getUserInfo()
        self.updateSocialButtons()
        
        DELAY(1.0) {
            let api = ShareAPI.instance
            
            print("SHARE", api.uuid)
            print("SHARE", api.getBearerAuth())
        }
    }
    
    @objc func viewOnTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func showLoading(_ visible: Bool = true) {
        DispatchQueue.main.async {
            self.loadingView.isHidden = !visible
            self.view.isUserInteractionEnabled = !visible
        }
    }
    
    @objc func onDeviceOrientationChanged() {
        var mFrame = self.contentView.frame
        mFrame.size.width = UIScreen.main.bounds.width
        self.contentView.frame = mFrame
         
        let dim: CGFloat = 65
        self.loadingView.frame = CGRect(x: (UIScreen.main.bounds.width-dim)/2,
                                        y: ((UIScreen.main.bounds.height-dim)/2) - 88,
                                        width: dim, height: dim)
    }
    
    private func buildLoading() {
        let dim: CGFloat = 65
        self.loadingView.frame = CGRect(x: (UIScreen.main.bounds.width-dim)/2,
                                        y: ((UIScreen.main.bounds.height-dim)/2) - 88,
                                        width: dim, height: dim)
        self.loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        if(!DARKMODE()){ self.loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.25) }
        self.loadingView.isHidden = true
        self.loadingView.layer.cornerRadius = 15
    
        let loading = UIActivityIndicatorView(style: .medium)
        loading.color = .white
        self.loadingView.addSubview(loading)
        loading.center = CGPoint(x: dim/2, y: dim/2)
        loading.startAnimating()
        self.view.addSubview(self.loadingView)
    }
    
    func adaptStyle() {
        
        if(IS_iPAD()) {
            self.mainStackViewWidthConstraint.constant = 600
            self.ITNsepConstraint.constant = 230
            self.deleteAccountsepConstraint.constant = 200
        }
        
        if(IS_iPHONE()) {
            self.deleteAccountsepConstraint.constant = 0
        }
        
        let mainStackView = self.contentView.subviews.first as! UIStackView
        mainStackView.backgroundColor = .clear
        
        if let textfield = self.contentView.viewWithTag(777) as? UITextField {
            textfield.layer.borderWidth = 1.0
            textfield.layer.borderColor = UIColor(hex: 0xBBBBBB).withAlphaComponent(0.8).cgColor
            textfield.backgroundColor = DARKMODE() ? UIColor(hex: 0x1E1E1E) : .white
            textfield.attributedPlaceholder = NSAttributedString(
                string: textfield.placeholder!,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBBBBBB).withAlphaComponent(0.5)]
            )
                        
            if(!DARKMODE()) {
                textfield.textColor = .black
            }
        }
        
        for subView in mainStackView.arrangedSubviews {
            if(subView.tag == 666) {
                let hStackView = (subView as! UIStackView)
                for subView in hStackView.arrangedSubviews {
                    if(subView.tag == 444 && subView is UITextField) {
                        let textField = (subView as! UITextField)
                
                        textField.layer.borderWidth = 1.0
                        textField.layer.borderColor = UIColor(hex: 0xBBBBBB).withAlphaComponent(0.8).cgColor
                        textField.backgroundColor = DARKMODE() ? UIColor(hex: 0x1E1E1E) : .white
                        textField.attributedPlaceholder = NSAttributedString(
                            string: textField.placeholder!,
                            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBBBBBB).withAlphaComponent(0.5)]
                        )
                        
                        if(!IS_iPAD()) {
                            textField.widthAnchor.constraint(equalToConstant: 320).isActive = true
                        }
                        
                        if(!DARKMODE()) {
                            textField.textColor = .black
                        }
                    }
                }
            }
        }
        
        
        
        if(DARKMODE()){ return }
        for subView in mainStackView.arrangedSubviews {
            if(subView.tag == 222) {
                let label = (subView as! UILabel)
                label.textColor = .black
            }
            
            if(subView.tag == 333) {
                subView.backgroundColor = .black
            }
            
            if(subView.tag == 666) {
                let hStackView = (subView as! UIStackView)
                for subView in hStackView.arrangedSubviews {
                    if(subView is UILabel) {
                        (subView as! UILabel).textColor = .black
                    }
                }
            }
        }
        
        if let imageView = self.contentView.viewWithTag(555) as? UIImageView {
            imageView.image = UIImage(named: "ITN_logo_blackText.png")
        }
        if let imageView = self.contentView.viewWithTag(556) as? UIImageView {
            imageView.image = UIImage(named: "ITN_logo_blackText.png")
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return STATUS_BAR_STYLE()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.removeSignInUpForms()
    }
    
    private func removeSignInUpForms() {
        var mVCs = self.navigationController?.viewControllers
        for (i, vc) in mVCs!.enumerated() {
            if(vc is SignInSignUpViewControllerViewController) {
                mVCs?.remove(at: i)
                break
            }
        }
        
        self.navigationController?.viewControllers = mVCs!
    }
    
}

// MARK: - UI
extension MyAccountV2ViewController {

    public static func createInstance() -> MyAccountV2ViewController {
        let vc = MyAccountV2ViewController(nibName: "MyAccountV2ViewController", bundle: nil)
        return vc
    }
    
    private func setContentView() {
        let screen_W = UIScreen.main.bounds.size.width
        //self.buildLoading()
        self.view.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
        self.scrollView.backgroundColor = self.view.backgroundColor
        
        self.scrollView.addSubview(self.contentView)
        
        self.contentView.frame = CGRect(x: 0, y: 0, width: screen_W, height: self.contentView.frame.size.height)
        //self.loginView.addGestureRecognizer(gesture1)
        self.contentView.backgroundColor = .clear
        
        self.scrollView.contentSize = CGSize(width: screen_W, height: self.contentView.frame.size.height)
    }
    
    private func setButtonTexts() {
        self.subscribeButton.orangeTitle = "SUBSCRIBE"
        self.subscribeButton.grayTitle = "UNSUBSCRIBE"
        
        self.facebookButton.orangeTitle = "CONNECT"
        self.facebookButton.grayTitle = "DISCONNECT"
        self.twitterButton.orangeTitle = "CONNECT"
        self.twitterButton.grayTitle = "DISCONNECT"
        self.linkedinButton.orangeTitle = "CONNECT"
        self.linkedinButton.grayTitle = "DISCONNECT"
        self.redditButton.orangeTitle = "CONNECT"
        self.redditButton.grayTitle = "DISCONNECT"
    }
    
    private func updateSocialButtons() {
        if(FB_SDK.instance.isLogged()) {
            facebookButton.setAsGray()
        } else {
            facebookButton.setAsOrange()
        }
        
        if(TW_SDK.instance.isLogged()) {
            twitterButton.setAsGray()
        } else {
            twitterButton.setAsOrange()
        }
        
        if(LI_SDK.instance.isLogged()) {
            linkedinButton.setAsGray()
        } else {
            linkedinButton.setAsOrange()
        }
        
        if(RED_SDK.instance.isLogged()) {
            redditButton.setAsGray()
        } else {
            redditButton.setAsOrange()
        }
    }
    
}

// MARK: - Component action(s)
extension MyAccountV2ViewController {

    @IBAction func signOutButtonTap(_ sender: UIButton) {
        ALERT_YESNO(vc: self, title: "Warning", question: "Sign Out from your account?") { answer in
            if(answer) {
                AppUser.shared.setLogin(false)
        
                FB_SDK.instance.logoutDirect()
                TW_SDK.instance.logoutDirect()
                LI_SDK.instance.logoutDirect()
                RED_SDK.instance.logoutDirect()
        
                let vc = AppUser.shared.accountViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func saveUserInfoButtonTap(_ sender: UIButton) {
        self.saveUserInfo()
    }
    
    @IBAction func subscribeButtonTap(_ sender: UIButton) {
        self.setSubscriptionOnOff()
    }
    
    @IBAction func newsletterOptionvalueChange(_ sender: UISwitch) {
        if(!self.saveNewsletterOptions){ return }
        
        let tag = sender.tag
        var oppositeTag = 0
        
        switch(tag) {
            case 101:
                oppositeTag = 102
            case 102:
                oppositeTag = 101
            case 103:
                oppositeTag = 104
            case 104:
                oppositeTag = 103
            case 105:
                oppositeTag = 106
            case 106:
                oppositeTag = 105
            // ...
            default:
                oppositeTag = 0
        }
        
        let oppositeSwitch = self.getSwitchWithTag(oppositeTag)
        oppositeSwitch.isOn = !sender.isOn
        
        // -------------------------------------
        
        var options = [String: String]()
        
        if(self.getSwitchWithTag(101).isOn) {
            options["frequency"] = "Daily"
        } else {
            options["frequency"] = "Weekly"
        }
        
        if(self.getSwitchWithTag(103).isOn) {
            options["content"] = "All top stories"
        } else {
            options["content"] = "Top 5 stories"
        }
        
        if(self.getSwitchWithTag(105).isOn) {
            options["ordering"] = "World news first"
        } else {
            options["ordering"] = "US news first"
        }
        
        self.setNewsletterOption(fields: options)
    }
    
    private func getSwitchWithTag(_ tag: Int) -> UISwitch {
        return self.contentView.viewWithTag(tag) as! UISwitch
    }
    
    @IBAction func socialButtonTap(_ sender: UIButton) {
        self.tapOnSocial(sender.tag-200)
    }
    
    @IBAction func deleteAccountButtonTap(_ sender: UIButton) {
        ALERT_YESNO(vc: self, title: "Warning", question: "Delete your account?") { answer in
            if(answer) { self.disconnectAll() }
        }
    }
}

// MARK: - Social
extension MyAccountV2ViewController: SFSafariViewControllerDelegate {
    
    private func tapOnSocial(_ tag: Int) {
        if(tag==1) {
            // FACEBOOK
            let fb = FB_SDK.instance
        
            if(fb.isLogged()) {
                fb.logout(vc: self) { (isLoggedOut) in
                    if(isLoggedOut) {
                        self.facebookButton.setAsOrange()
                    }
                }
            } else {
                fb.login(vc: self) { (isLogged) in
                    if(isLogged) {
                        self.facebookButton.setAsGray()
                    }
                }
            }
        } else if(tag==2) {
            // TWITTER
            let tw = TW_SDK.instance
        
            if(tw.isLogged()) {
                tw.logout(vc: self) { (isLoggedOut) in
                    if(isLoggedOut) {
                        self.twitterButton.setAsOrange()
                    }
                }
            } else {
                tw.login(vc: self) { (isLogged) in
                    if(isLogged) {
                        self.twitterButton.setAsGray()
                    }
                }
            }
        } else if(tag==3) {
            // LINKEDIN
            let li = LI_SDK.instance
        
            if(li.isLogged()) {
                li.logout(vc: self) { (isLoggedOut) in
                    if(isLoggedOut) {
                        self.linkedinButton.setAsOrange()
                    }
                }
            } else {
                li.login(vc: self) { (isLogged) in
                    if(isLogged) {
                        self.linkedinButton.setAsGray()
                    }
                }
            }
        } else if(tag==4) {
            // REDDIT
            let re = RED_SDK.instance
        
            if(re.isLogged()) {
                re.logout(vc: self) { (isLoggedOut) in
                    if(isLoggedOut) {
                        self.redditButton.setAsOrange()
                    }
                }
            } else {
                re.login(vc: self) { (isLogged) in
                    if(isLogged) {
                        self.redditButton.setAsGray()
                    }
                }
            }
        }
        
    }
}


// MARK: - Data (read)
extension MyAccountV2ViewController {

    private func getUserInfo() {
        self.showLoading()
        AppUser.shared.getInfo { success in
            DispatchQueue.main.async {
                self.nameTextField.text = AppUser.shared.name
                self.lastNameTextField.text = AppUser.shared.lastName
                self.screenNameTextField.text = AppUser.shared.screenName
                self.emailTextField.text = AppUser.shared.email
                
                if(AppUser.shared.subscribed) {
                    self.subscribeButton.setAsGray()
                } else {
                    self.subscribeButton.setAsOrange()
                }
                
                for (key, value) in AppUser.shared.newsletterOptions! {
                    self.getSwitchWithTag(key).isOn = value
                }
                
                self.saveNewsletterOptions = true
                self.showLoading(false)
            }
        }
    }
    
    private func saveUserInfo() {
        self.showLoading()
        ShareAPI.instance.saveUserInfo(name: self.nameTextField.text,
                         lastName: self.lastNameTextField.text,
                         screenName: self.screenNameTextField.text,
                         email: self.emailTextField.text) { success in
            
            self.showLoading(false)
        }
    }
    
    private func setSubscriptionOnOff() {
        self.showLoading()
        
        if(AppUser.shared.subscribed) {
            // cancel subscription
            ShareAPI.instance.unsubscribeToNewsLetter { success in
                DispatchQueue.main.async {
                    if(success) { self.subscribeButton.setAsOrange() }
                    self.showLoading(false)
                }
            }
        } else {
            // subscribe!
            let email = self.emailTextField.text
            //let email = AppUser.shared.email
            
            if(email == nil || email!.isEmpty) {
                ALERT(vc: self, title: "Warning", message: "Email is mandatory!")
                self.showLoading(false)
            } else {
                ShareAPI.instance.subscribeToNewsLetter(email: email!) { success in
                    DispatchQueue.main.async {
                        if(success) { self.subscribeButton.setAsGray() }
                        self.showLoading(false)
                    }
                }
            }
        }
    }
    
    private func setNewsletterOption(fields: [String: String]) {
        self.showLoading()
        
        let email = self.emailTextField.text
        if(email == nil || email!.isEmpty) {
            ALERT(vc: self, title: "Warning", message: "Email is mandatory!")
            self.showLoading(false)
        } else {
            ShareAPI.instance.setNewsletterOption(email: email!, fields: fields) { success in
                self.showLoading(false)
            }
        }
        
    }
    
    private func disconnectAll() {
        self.showLoading()
        ShareAPI.instance.disconnectAll { success in
            FB_SDK.instance.logoutDirect()
            TW_SDK.instance.logoutDirect()
            LI_SDK.instance.logoutDirect()
            RED_SDK.instance.logoutDirect()
            
            DispatchQueue.main.async {
                self.showLoading(false)
    //            self.getUserInfo()
    //
    //            DELAY(1.0) {
    //                self.updateSocialButtons()
    //            }

                AppUser.shared.setLogin(false)
                let vc = AppUser.shared.accountViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}
