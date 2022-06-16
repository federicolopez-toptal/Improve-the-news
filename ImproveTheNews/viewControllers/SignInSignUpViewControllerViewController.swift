//
//  SignInSignUpViewControllerViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 25/05/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit
import SafariServices

class SignInSignUpViewControllerViewController: UIViewController {

    var firstTime = true

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    private let loadingView = UIView()
    
    @IBOutlet weak var loginView: UIView!
        @IBOutlet weak var loginEmailTextField: UITextField!
        @IBOutlet weak var loginPassTextField: UITextField!
        @IBOutlet weak var loginNewsletterTextField: UITextField!
    
    @IBOutlet weak var registrationView: UIView!
        @IBOutlet weak var regEmailTextField: UITextField!
        @IBOutlet weak var regPassTextField: UITextField!
        @IBOutlet weak var regPassConfirmTextField: UITextField!
        @IBOutlet weak var regNewsletterCheckbox: UISwitch!
        @IBOutlet weak var regNewsletterTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateAllSocialButtons()
        self.buildContentViews()
        
        SETUP_NAVBAR(viewController: self,
            homeTap: nil,
            menuTap: nil,
            searchTap: nil,
            userTap: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
            
        DELAY(1.0) {
            let api = ShareAPI.instance
            
            print("SHARE", api.uuid)
            print("SHARE", api.getBearerAuth())
        }
    }
    
    @objc func onDeviceOrientationChanged() {
        var mFrame = self.loginView.frame
        mFrame.size.width = UIScreen.main.bounds.width
        self.loginView.frame = mFrame
        
        mFrame = self.registrationView.frame
        mFrame.size.width = UIScreen.main.bounds.width
        self.registrationView.frame = mFrame
        
        let dim: CGFloat = 65
        self.loadingView.frame = CGRect(x: (UIScreen.main.bounds.width-dim)/2,
                                        y: ((UIScreen.main.bounds.height-dim)/2) - 88,
                                        width: dim, height: dim)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return STATUS_BAR_STYLE()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.removeMyAccountScreen()
    }
    
    private func removeMyAccountScreen() {
        var mVCs = self.navigationController?.viewControllers
        for (i, vc) in mVCs!.enumerated() {
            if(vc is MyAccountV2ViewController) {
                mVCs?.remove(at: i)
                break
            }
        }
        
        self.navigationController?.viewControllers = mVCs!
    }

}

// MARK: - UI
extension SignInSignUpViewControllerViewController {
    
    public static func createInstance() -> SignInSignUpViewControllerViewController {
        let vc = SignInSignUpViewControllerViewController(nibName: "SignInSignUpViewControllerViewController", bundle: nil)
//        vc.modalPresentationStyle = .fullScreen
        return vc
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
    
    func showLoading(_ visible: Bool = true) {
        DispatchQueue.main.async {
            self.loadingView.isHidden = !visible
            self.view.isUserInteractionEnabled = !visible
        }
    }
    
    private func buildContentViews() {
        
        let screen_W = UIScreen.main.bounds.size.width
        self.buildLoading()

        self.view.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT

    // LOGIN
        let gesture1 = UITapGestureRecognizer(target: self, action: #selector(viewOnTap(sender:)))
        
        self.scrollView.addSubview(self.loginView)
        
        self.loginView.frame = CGRect(x: 0, y: 0, width: screen_W, height: self.loginView.frame.size.height)
        self.loginView.addGestureRecognizer(gesture1)
        self.loginView.backgroundColor = .clear
        
        self.loginEmailTextField.keyboardType = .emailAddress
        self.loginEmailTextField.autocapitalizationType = .none
        self.loginEmailTextField.autocorrectionType = .no
        self.loginEmailTextField.smartDashesType = .no
        self.loginEmailTextField.smartInsertDeleteType = .no
        self.loginEmailTextField.spellCheckingType = .no
        self.loginEmailTextField.returnKeyType = .next
        self.loginEmailTextField.delegate = self

        self.loginEmailTextField.layer.borderWidth = 1.0
        self.loginEmailTextField.layer.borderColor = UIColor(hex: 0xBBBBBB).withAlphaComponent(0.8).cgColor
        self.loginEmailTextField.backgroundColor = DARKMODE() ? UIColor(hex: 0x1E1E1E) : .white
        self.loginEmailTextField.attributedPlaceholder = NSAttributedString(
            string: "Your Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBBBBBB).withAlphaComponent(0.5)]
        )

        self.loginPassTextField.keyboardType = .asciiCapable
        self.loginPassTextField.returnKeyType = .send
        self.loginPassTextField.delegate = self

        self.loginPassTextField.layer.borderWidth = 1.0
        self.loginPassTextField.layer.borderColor = UIColor(hex: 0xBBBBBB).withAlphaComponent(0.8).cgColor
        self.loginPassTextField.backgroundColor = DARKMODE() ? UIColor(hex: 0x1E1E1E) : .white
        self.loginPassTextField.attributedPlaceholder = NSAttributedString(
            string: "Your Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBBBBBB).withAlphaComponent(0.5)]
        )


        let loginFormView = self.loginView.subviews.first as! SignInUpFormFormView
        loginFormView.backgroundColor = self.view.backgroundColor
        loginFormView.layer.borderWidth = 10.0
        loginFormView.layer.borderColor = DARKMODE() ? UIColor.white.withAlphaComponent(0.35).cgColor : UIColor.black.withAlphaComponent(0.15).cgColor
        
        let midScreenX = UIScreen.main.bounds.size.width/2
        let posY: CGFloat = 60.0

        loginFormView.lines.append(Line(startPont: CGPoint(x: midScreenX, y: 15),
            endPoint: CGPoint(x: midScreenX, y: posY)))
        loginFormView.lines.append(Line(startPont: CGPoint(x: midScreenX+10, y: posY),
            endPoint: CGPoint(x: UIScreen.main.bounds.size.width-15, y: posY)))

        self.loginNewsletterTextField.layer.borderWidth = 1.0
        self.loginNewsletterTextField.layer.borderColor = UIColor(hex: 0xBBBBBB).withAlphaComponent(0.8).cgColor
        self.loginNewsletterTextField.backgroundColor = DARKMODE() ? UIColor(hex: 0x1E1E1E) : .white
        self.loginNewsletterTextField.attributedPlaceholder = NSAttributedString(
            string: "Your Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBBBBBB).withAlphaComponent(0.5)]
        )

        if(!DARKMODE()) {
            let regButton = loginFormView.subviews[1] as! UIButton
            let attributes = [NSAttributedString.Key.font: UIFont(name: "Merriweather-Bold", size: 16)!,
                            NSAttributedString.Key.foregroundColor: UIColor.black]
            let attrTitle = NSAttributedString(string: "Sign Up", attributes: attributes)
            regButton.setAttributedTitle(attrTitle, for: .normal)
            
            let title = loginFormView.subviews[2] as! UILabel
            title.textColor = .black
            
            let vStackView = loginFormView.subviews[3] as! UIStackView
            for V in vStackView.arrangedSubviews {
                if(V is UILabel) {
                    (V as! UILabel).textColor = .black
                }
            }
            
            self.loginEmailTextField.textColor = .black
            self.loginPassTextField.textColor = .black
            self.loginNewsletterTextField.textColor = .black
            
            let darkView = self.loginView.subviews[3]
            darkView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
    
    // REGISTRATION
    let gesture2 = UITapGestureRecognizer(target: self, action: #selector(viewOnTap(sender:)))
    
        self.scrollView.addSubview(self.registrationView)
        self.registrationView.frame = CGRect(x: 0, y: 0, width: screen_W, height: self.registrationView.frame.size.height)
        self.registrationView.addGestureRecognizer(gesture2)
        self.registrationView.backgroundColor = .clear
    
        self.regEmailTextField.keyboardType = .emailAddress
        self.regEmailTextField.autocapitalizationType = .none
        self.regEmailTextField.autocorrectionType = .no
        self.regEmailTextField.smartDashesType = .no
        self.regEmailTextField.smartInsertDeleteType = .no
        self.regEmailTextField.spellCheckingType = .no
        self.regEmailTextField.returnKeyType = .next
        self.regEmailTextField.delegate = self
        
        self.regEmailTextField.layer.borderWidth = 1.0
        self.regEmailTextField.layer.borderColor = UIColor(hex: 0xBBBBBB).withAlphaComponent(0.8).cgColor
        self.regEmailTextField.backgroundColor = DARKMODE() ? UIColor(hex: 0x1E1E1E) : .white
        self.regEmailTextField.attributedPlaceholder = NSAttributedString(
            string: "Your Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBBBBBB).withAlphaComponent(0.5)]
        )
        
        self.regPassTextField.keyboardType = .asciiCapable
        self.regPassTextField.returnKeyType = .next
        self.regPassTextField.delegate = self
        
        self.regPassTextField.layer.borderWidth = 1.0
        self.regPassTextField.layer.borderColor = UIColor(hex: 0xBBBBBB).withAlphaComponent(0.8).cgColor
        self.regPassTextField.backgroundColor = DARKMODE() ? UIColor(hex: 0x1E1E1E) : .white
        self.regPassTextField.attributedPlaceholder = NSAttributedString(
            string: "Your Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBBBBBB).withAlphaComponent(0.5)]
        )
        
        self.regPassConfirmTextField.keyboardType = .asciiCapable
        self.regPassConfirmTextField.returnKeyType = .send
        self.regPassConfirmTextField.delegate = self
    
        self.regPassConfirmTextField.layer.borderWidth = 1.0
        self.regPassConfirmTextField.layer.borderColor = UIColor(hex: 0xBBBBBB).withAlphaComponent(0.8).cgColor
        self.regPassConfirmTextField.backgroundColor = DARKMODE() ? UIColor(hex: 0x1E1E1E) : .white
        self.regPassConfirmTextField.attributedPlaceholder = NSAttributedString(
            string: "Confirm Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBBBBBB).withAlphaComponent(0.5)]
        )
        
        let regFormView = self.registrationView.subviews.first as! SignInUpFormFormView
        regFormView.backgroundColor = self.view.backgroundColor
        regFormView.layer.borderWidth = 10.0
        regFormView.layer.borderColor = DARKMODE() ? UIColor.white.withAlphaComponent(0.35).cgColor : UIColor.black.withAlphaComponent(0.15).cgColor

        regFormView.lines.append(Line(startPont: CGPoint(x: midScreenX, y: 15),
            endPoint: CGPoint(x: midScreenX, y: posY)))
        regFormView.lines.append(Line(startPont: CGPoint(x: 15, y: posY),
            endPoint: CGPoint(x: midScreenX-10, y: posY)))
    
        self.regNewsletterTextField.layer.borderWidth = 1.0
        self.regNewsletterTextField.layer.borderColor = UIColor(hex: 0xBBBBBB).withAlphaComponent(0.8).cgColor
        self.regNewsletterTextField.backgroundColor = DARKMODE() ? UIColor(hex: 0x1E1E1E) : .white
        self.regNewsletterTextField.attributedPlaceholder = NSAttributedString(
            string: "Your Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBBBBBB).withAlphaComponent(0.5)]
        )
    
        if(!DARKMODE()) {
            let loginButton = regFormView.subviews[0] as! UIButton
            let attributes = [NSAttributedString.Key.font: UIFont(name: "Merriweather-Bold", size: 16)!,
                            NSAttributedString.Key.foregroundColor: UIColor.black]
            let attrTitle = NSAttributedString(string: "Sign In", attributes: attributes)
            loginButton.setAttributedTitle(attrTitle, for: .normal)
            
            let title = regFormView.subviews[2] as! UILabel
            title.textColor = .black
            
            let vStackView = regFormView.subviews[3] as! UIStackView
            for V in vStackView.arrangedSubviews {
                if(V is UILabel) {
                    (V as! UILabel).textColor = .black
                }
            }
            
            self.regEmailTextField.textColor = .black
            self.regPassTextField.textColor = .black
            self.regPassConfirmTextField.textColor = .black
            self.regNewsletterTextField.textColor = .black
            
            let darkView = self.registrationView.subviews[3]
            darkView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            
            let labelsVStackView = regFormView.subviews[7] as! UIStackView
            for V in labelsVStackView.arrangedSubviews {
                let innerHStack = V as! UIStackView
                let label = innerHStack.arrangedSubviews[1] as! UILabel
                label.textColor = .black
            }
            let extraLabel = regFormView.subviews[8] as! UILabel
            extraLabel.textColor = .black
        }
    
    
    // misc
        self.showLogin()
        //self.showRegistration()
        
        self.scrollView.backgroundColor = self.view.backgroundColor
    }
    
    private func scrollFormsToTop() {
        self.scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    private func showLogin() {
        let screen_W = UIScreen.main.bounds.size.width
    
        self.loginView.isHidden = false
        self.registrationView.isHidden = true
        self.scrollFormsToTop()
        self.scrollView.contentSize = CGSize(width: screen_W, height: self.loginView.frame.size.height)
    }
    
    private func showRegistration() {
        let screen_W = UIScreen.main.bounds.size.width
    
        self.registrationView.isHidden = false
        self.loginView.isHidden = true
        self.scrollFormsToTop()
        self.scrollView.contentSize = CGSize(width: screen_W, height: self.registrationView.frame.size.height)
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEvent(n:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEvent(n:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self,
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardEvent(n: Notification) {
        let H = getKeyboardHeight(fromNotification: n)
        
        if(n.name==UIResponder.keyboardWillShowNotification){
            self.scrollViewBottomConstraint.constant = 34 - H
        } else if(n.name==UIResponder.keyboardWillHideNotification) {
            self.scrollViewBottomConstraint.constant = 34
        }
        
        view.layoutIfNeeded()
    }
    
    func getKeyboardHeight(fromNotification notification: Notification) -> CGFloat {
        if let H = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            return H
        } else {
            return 300
        }
    }
    
    @objc func viewOnTap(sender: UITapGestureRecognizer) {
        self.dismissKeyboard()
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
        self.scrollFormsToTop()
    }
    
}

// MARK: - UITextField
extension SignInSignUpViewControllerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Login
        if(textField == self.loginEmailTextField) {
            self.loginPassTextField.becomeFirstResponder()
        } else if(textField == self.loginPassTextField) {
            self.performLogin()
        }
        
        // Registration
        if(textField == self.regEmailTextField) {
            self.regPassTextField.becomeFirstResponder()
        } else if(textField == self.regPassTextField) {
            self.regPassConfirmTextField.becomeFirstResponder()
        } else if(textField == self.regPassConfirmTextField) {
            self.performRegistration()
        }
        
        return true
    }
    
}

// MARK: - Button action(s)
extension SignInSignUpViewControllerViewController {
    
    @IBAction func gotoRegistrationButtonTap(_ sender: UIButton) {
        self.showRegistration()
    }
    
    @IBAction func gotoLoginButtonTap(_ sender: UIButton) {
        self.showLogin()
    }
    
    @IBAction func loginActionButtonTap(_ sender: UIButton) {
        self.performLogin()
    }
    
    @IBAction func regActionButtonTap(_ sender: UIButton) {
        self.performRegistration()
    }
    
    @IBAction func newsletterButtonTap(_ sender: UIButton) {
        self.subscribeToNewsletter(tag: sender.tag)
    }
    
    @IBAction func forgotPassButtonTap(_ sender: UIButton) {
        let vc = ForgotPassViewController.createInstance()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - Form action(s)
extension SignInSignUpViewControllerViewController {
    
    private func performLogin() {
    
        self.dismissKeyboard()
        let email = self.loginEmailTextField.text!
        let pass = self.loginPassTextField.text!
        
        if(!VALIDATE_EMAIL(email)) {
            ALERT(vc: self, title: "Warning", message: "Please, enter a valid email")
        } else if(!VALIDATE_PASS(pass)) {
            ALERT(vc: self, title: "Warning", message: "Your password must be 4 characters long minimum")
        } else {
            self.showLoading()
            let api = ShareAPI.instance
            api.signIn(email: email, password: pass) { (success, errorMsg) in
                self.showLoading(false)
                if(!success) {
                    var msg = "An error ocurred. Please, try again later"
                    if let _msg = errorMsg {
                        msg = _msg
                    }
                    
                    ALERT(vc: self, title: "Warning", message: msg)
                } else {
                    ALERT(vc: self, title: "Success", message: "Successful login") {
                        self.userWasLogged()
//                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        }
    }
    
    private func performRegistration() {
        self.dismissKeyboard()
        let email = self.regEmailTextField.text!
        let pass = self.regPassTextField.text!
        let passConfirm = self.regPassConfirmTextField.text!
        
        if(!VALIDATE_EMAIL(email)) {
            ALERT(vc: self, title: "Warning", message: "Please, enter a valid email")
        } else if(!VALIDATE_PASS(pass)) {
            ALERT(vc: self, title: "Warning", message: "Your password must be 4 characters long minimum")
        } else if(pass != passConfirm) {
            ALERT(vc: self, title: "Warning", message: "The password and its confirmation mismatch")
        } else {
            
            self.showLoading()
            let api = ShareAPI.instance
            api.signUp(email: email, password: pass, newsletter: self.regNewsletterCheckbox.isOn) { (success, errorMsg) in
                self.showLoading(false)
                if(!success) {
                    var msg = "An error ocurred. Please, try again later"
                    if let _msg = errorMsg {
                        msg = _msg
                    }
                    
                    ALERT(vc: self, title: "Warning", message: msg)
                } else {
                    ALERT(vc: self, title: "Success", message: "Registration successful. You' receive an email to verify your account")
                }
            }
        }
        
    }
    
    private func subscribeToNewsletter(tag: Int) {
        self.dismissKeyboard()
        var email = self.loginNewsletterTextField.text!
        if(tag==2){ email = self.regNewsletterTextField.text! }
        
        if(!VALIDATE_EMAIL(email)) {
            ALERT(vc: self, title: "Warning", message: "Please, enter a valid email")
        } else {
            
            self.showLoading()
            let api = ShareAPI.instance
            api.subscribeToNewsLetter(email: email) { success in
                self.showLoading(false)
                ALERT(vc: self, title: "Success", message: "Subscription successfull")
            }
        }
    }
    
}

extension SignInSignUpViewControllerViewController: SFSafariViewControllerDelegate {
// MARK: - Social
    private func updateAllSocialButtons() {
        let loginButtons = loginView.viewWithTag(888) as! UIStackView
        for B in loginButtons.arrangedSubviews {
            self.updateButton((B as! UIButton))
        }
        
        let regButtons = registrationView.viewWithTag(999) as! UIStackView
        for B in regButtons.arrangedSubviews {
            self.updateButton((B as! UIButton))
        }
    }
    
    private func updateButton(_ button: UIButton) {
        DispatchQueue.main.async {
            let tag = button.tag - 100
            var state = false
            
            switch(tag) {
                case 1:
                    let fb = FB_SDK.instance
                    state = fb.isLogged()
                case 2:
                    let li = LI_SDK.instance
                    state = li.isLogged()
                case 3:
                    let tw = TW_SDK.instance
                    state = tw.isLogged()
                case 4:
                    let red = RED_SDK.instance
                    state = red.isLogged()
            
                default:
                    state = false
            }
        
            if(state) {
                button.alpha = 1.0
                //button.isEnabled = false
            } else {
                button.alpha = 0.25
                //button.isEnabled = true
            }
        }
    }
    
    @IBAction func socialButtonTap(_ sender: UIButton) {
        let tag = sender.tag-100
        print(tag)
        
        switch(tag) {
            case 1:
            FB_buttonTap()
            case 2:
            LI_buttonTap()
            case 3:
            TW_buttonTap()
            case 4:
            RED_buttonTap()

            default:
            FB_buttonTap()
        }
    }
    
    private func getButton(groupTag: Int, tag: Int) -> UIButton {
        var group = loginView.viewWithTag(888) as! UIStackView
        if(groupTag==999) {
            group = registrationView.viewWithTag(999) as! UIStackView
        }
        
        return (group.viewWithTag(tag) as! UIButton)
    }
    
    private func FB_buttonTap() {
        let fb = FB_SDK.instance
        let button1 = self.getButton(groupTag: 888, tag: 101)
        let button2 = self.getButton(groupTag: 999, tag: 101)
        
        if(fb.isLogged()) {
            fb.logout(vc: self) { (isLoggedOut) in
                if(isLoggedOut) {
                    self.updateButton(button1)
                    self.updateButton(button2)
                }
            }
        } else {
            fb.login(vc: self) { (isLogged) in
                if(isLogged) {
                    self.updateButton(button1)
                    self.updateButton(button2)
                    self.userWasLogged()
                }
            }
        }
    }
    
    private func TW_buttonTap() {
        let tw = TW_SDK.instance
        let button1 = self.getButton(groupTag: 888, tag: 103)
        let button2 = self.getButton(groupTag: 999, tag: 103)

        if(tw.isLogged()) {
            tw.logout(vc: self) { (isLoggedOut) in
                if(isLoggedOut) {
                    self.updateButton(button1)
                    self.updateButton(button2)
                }
            }
        } else {
            tw.login(vc: self) { (isLogged) in
                if(isLogged) {
                    self.updateButton(button1)
                    self.updateButton(button2)
                    self.userWasLogged()
                }
            }
        }
    }

    private func LI_buttonTap() {
        let li = LI_SDK.instance
        let button1 = self.getButton(groupTag: 888, tag: 102)
        let button2 = self.getButton(groupTag: 999, tag: 102)

        if(li.isLogged()) {
            li.logout(vc: self) { (isLoggedOut) in
                if(isLoggedOut) {
                    self.updateButton(button1)
                    self.updateButton(button2)
                }
            }
        } else {
            li.login(vc: self) { (isLogged) in
                if(isLogged) {
                    self.updateButton(button1)
                    self.updateButton(button2)
                    self.userWasLogged()
                }
            }
        }
    }

    private func RED_buttonTap() {
        let red = RED_SDK.instance
        let button1 = self.getButton(groupTag: 888, tag: 104)
        let button2 = self.getButton(groupTag: 999, tag: 104)

        if(red.isLogged()) {
            red.logout(vc: self) { (isLoggedOut) in
                if(isLoggedOut) {
                    self.updateButton(button1)
                    self.updateButton(button2)
                }
            }
        } else {
            red.login(vc: self) { (isLogged) in
                if(isLogged) {
                    self.updateButton(button1)
                    self.updateButton(button2)
                    self.userWasLogged()
                }
            }
        }
    }
    
}


extension SignInSignUpViewControllerViewController {
    
    func userWasLogged() {
        AppUser.shared.setLogin(true)
        
        DispatchQueue.main.async {
            let vc = AppUser.shared.accountViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
