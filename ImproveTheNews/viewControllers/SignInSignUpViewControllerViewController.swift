//
//  SignInSignUpViewControllerViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 25/05/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit

class SignInSignUpViewControllerViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    private let loadingView = UIView()
    
    @IBOutlet weak var loginView: UIView!
        @IBOutlet weak var loginEmailTextField: UITextField!
        @IBOutlet weak var loginPassTextField: UITextField!
    
    @IBOutlet weak var registrationView: UIView!
        @IBOutlet weak var regEmailTextField: UITextField!
        @IBOutlet weak var regPassTextField: UITextField!
        @IBOutlet weak var regPassConfirmTextField: UITextField!
        @IBOutlet weak var regNewsletterCheckbox: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildContentViews()
        
        SETUP_NAVBAR(viewController: self,
            homeTap: nil,
            menuTap: nil,
            searchTap: nil,
            userTap: nil)
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
                }
            }
        }
        
    }
    
}
