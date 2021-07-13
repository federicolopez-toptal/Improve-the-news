//
//  AuthViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 30/06/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

enum AuthViewControllerMode {
    case login, registration
}

let NOTIFICATION_UPDATE_NAVBAR = Notification.Name("updateNavBar")

class AuthViewController: UIViewController {

    var mode: AuthViewControllerMode = .login
    
    let scrollview = UIScrollView(frame: .zero)
    var scrollviewBottomConstraint: NSLayoutConstraint?
    let contentView = UIView(frame: .zero)
    let loadingView = UIView()
    
    let emailText = UITextField()
    let passText = UITextField()
    let nameText = UITextField()
    
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Login"
        if(self.mode == .registration){
            self.title = "Registration"
        }
        
        self.initScrollview()
        self.initContent()
        self.initLoading()
        
        /*
        self.emailText.text = "federico@improvethenews.org"
        self.passText.text = "toptal123"
        */
    }
    
    func initLoading() {
        let dim: CGFloat = 65
        self.loadingView.frame = CGRect(x: (UIScreen.main.bounds.width-dim)/2,
                                        y: ((UIScreen.main.bounds.height-dim)/2) - 88,
                                        width: dim, height: dim)
        self.loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        if(!DARKMODE()){ self.loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.25) }
        self.loadingView.isHidden = true
        self.loadingView.layer.cornerRadius = 15
    
        let loading = UIActivityIndicatorView(style: .medium)
        loading.color = UIColor.white.withAlphaComponent(0.6)
        if(!DARKMODE()){ loading.color = darkForBright }
        self.loadingView.addSubview(loading)
        loading.center = CGPoint(x: dim/2, y: dim/2)
        loading.startAnimating()

        self.view.addSubview(self.loadingView)
    }
    
    func initScrollview() {
        self.scrollview.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
        
        self.view.addSubview(self.scrollview)
        self.scrollviewBottomConstraint = self.scrollview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        self.scrollview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.scrollview.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollviewBottomConstraint!
        ])
    }
    
    func initContent() {
        
        let W = UIScreen.main.bounds.width
        
        var H: CGFloat = 900
        if(self.mode == .login) {
            H = 330
        }
        
        self.contentView.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
        self.scrollview.addSubview(self.contentView)
        self.contentView.frame = CGRect(x: 0, y: 0, width: W, height: H)
        self.scrollview.contentSize = CGSize(width: W, height: H)
        
        // MARK: Tap on view to dismiss keyboard
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewOnTap(sender:)))
        contentView.addGestureRecognizer(gesture)
        
        self.initForm()
    }
    
    func initForm() {
        
        let leftMargin: CGFloat = 15
        let W = UIScreen.main.bounds.width
    
    // EMAIL
        let emailLabel = UILabel()
        emailLabel.textColor = DARKMODE() ? accentOrange : textBlack
        emailLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
        self.contentView.addSubview(emailLabel)
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 25),
            emailLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
            constant: leftMargin),
        ])
        emailLabel.text = "Email address *"
        
        emailText.textColor = DARKMODE() ? .white : textBlack
        emailText.keyboardType = .emailAddress
        emailText.layer.cornerRadius = 5.0
        emailText.layer.borderWidth = 1.0
        emailText.layer.borderColor = DARKMODE() ? UIColor.white.withAlphaComponent(0.7).cgColor : textBlackAlpha.cgColor
        emailText.setLeftPaddingPoints(10)
        emailText.autocapitalizationType = .none
        emailText.autocorrectionType = .no
        emailText.smartDashesType = .no
        emailText.smartInsertDeleteType = .no
        emailText.spellCheckingType = .no
        emailText.returnKeyType = .next
        emailText.textContentType = .oneTimeCode
        emailText.delegate = self
        self.contentView.addSubview(emailText)
        emailText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailText.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 2),
            emailText.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
            constant: leftMargin),
            emailText.widthAnchor.constraint(equalToConstant: W-(leftMargin*2)),
            emailText.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let emailLegendLabel = UILabel()
        emailLegendLabel.textColor = DARKMODE() ? UIColor.white.withAlphaComponent(0.5) : textBlackAlpha
        emailLegendLabel.font = UIFont(name: "OpenSans-Regular", size: 14)
        self.contentView.addSubview(emailLegendLabel)
        emailLegendLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailLegendLabel.topAnchor.constraint(equalTo: emailText.bottomAnchor, constant: 4),
            emailLegendLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
            constant: leftMargin),
        ])
        emailLegendLabel.text = "We'll never share your email with anyone else."
        
    // NAME
        if(self.mode == .registration) {
            let nameLabel = UILabel()
            nameLabel.textColor = DARKMODE() ? accentOrange : textBlack
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
            self.contentView.addSubview(nameLabel)
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nameLabel.topAnchor.constraint(equalTo: emailLegendLabel.bottomAnchor, constant: 30),
                nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                constant: leftMargin),
            ])
            nameLabel.text = "Name *"
            
            nameText.textColor = DARKMODE() ? .white : textBlack
            nameText.keyboardType = .namePhonePad
            nameText.layer.cornerRadius = 5.0
            nameText.layer.borderWidth = 1.0
            nameText.layer.borderColor = DARKMODE() ? UIColor.white.withAlphaComponent(0.7).cgColor : textBlackAlpha.cgColor
            nameText.setLeftPaddingPoints(10)
            nameText.autocapitalizationType = .words
            nameText.autocorrectionType = .no
            nameText.smartDashesType = .no
            nameText.smartInsertDeleteType = .no
            nameText.spellCheckingType = .no
            nameText.returnKeyType = .next
            nameText.textContentType = .oneTimeCode
            nameText.delegate = self
            self.contentView.addSubview(nameText)
            nameText.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nameText.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
                nameText.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                constant: leftMargin),
                nameText.widthAnchor.constraint(equalToConstant: W-(leftMargin*2)),
                nameText.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
    
    // PASSWORD
        let passLabel = UILabel()
        passLabel.textColor = DARKMODE() ? accentOrange : textBlack
        passLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
        self.contentView.addSubview(passLabel)
        passLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var passTopConstraint = passLabel.topAnchor.constraint(equalTo: emailLegendLabel.bottomAnchor, constant: 30)
        if(self.mode == .registration) {
            passTopConstraint = passLabel.topAnchor.constraint(equalTo: nameText.bottomAnchor, constant: 30)
        }
        
        NSLayoutConstraint.activate([
            passTopConstraint,
            passLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
            constant: leftMargin),
        ])
        passLabel.text = "Password *"


        passText.textColor = DARKMODE() ? .white : textBlack
        passText.isSecureTextEntry = true
        passText.layer.cornerRadius = 5.0
        passText.layer.borderWidth = 1.0
        passText.layer.borderColor = DARKMODE() ? UIColor.white.withAlphaComponent(0.7).cgColor : textBlackAlpha.cgColor
        passText.setLeftPaddingPoints(10)
        passText.returnKeyType = .send
        passText.textContentType = .oneTimeCode
        passText.delegate = self
        self.contentView.addSubview(passText)
        passText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passText.topAnchor.constraint(equalTo: passLabel.bottomAnchor, constant: 2),
            passText.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
            constant: leftMargin),
            passText.widthAnchor.constraint(equalToConstant: W-(leftMargin*2)),
            passText.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let passLegendLabel = UILabel()
        passLegendLabel.textColor = DARKMODE() ? UIColor.white.withAlphaComponent(0.5) : textBlackAlpha
        passLegendLabel.font = UIFont(name: "OpenSans-Regular", size: 14)
        self.contentView.addSubview(passLegendLabel)
        passLegendLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passLegendLabel.topAnchor.constraint(equalTo: passText.bottomAnchor, constant: 4),
            passLegendLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
            constant: leftMargin),
        ])
        passLegendLabel.text = "field with * are required"
        
        
        
    // ACTION BUTTON
        let actionButton = UIButton(type: .custom)
        actionButton.setTitle("Login", for: .normal)
        if(self.mode == .registration) {
            actionButton.setTitle("Register", for: .normal)
        }
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 17)
        actionButton.backgroundColor = accentOrange
        actionButton.layer.cornerRadius = 10.0
        actionButton.addTarget(self, action: #selector(formRunAction),
            for: .touchUpInside)
        
        self.contentView.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: passLegendLabel.bottomAnchor, constant: 35),
            actionButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
            constant: leftMargin),
            actionButton.widthAnchor.constraint(equalToConstant: 140),
            actionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObservers()
    }

    // MARK: - Keyboard stuff
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEvent(n:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEvent(n:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardEvent(n: Notification) {
        let H = getKeyboardHeight(fromNotification: n)
        
        if(n.name==UIResponder.keyboardWillShowNotification){
            self.scrollviewBottomConstraint!.constant = -H
        } else if(n.name==UIResponder.keyboardWillHideNotification) {
            self.scrollviewBottomConstraint!.constant = 0
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
    
    func SAFE_AREA() -> UIEdgeInsets? {
        let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
        return window?.safeAreaInsets
    }
    
    // MARK: - Some actions
    @objc func formRunAction() {
        if(!VALIDATE_EMAIL(self.emailText.text!)) {
            self.msg("Please, enter a valid email")
            return
        }
        
        if(self.mode == .registration) {
            if(!VALIDATE_NAME(self.nameText.text!)) {
                self.msg("Please, enter a name (3 characters minimum)")
                return
            }
        }
        
        if(!VALIDATE_PASS(self.passText.text!)) {
            self.msg("Please, enter a valid password (4 characters minimum)")
            return
        }
        
        let em = self.emailText.text!
        let ps = self.passText.text!
        let nm = self.nameText.text!
        self.formEnabled(false)
        
        if(self.mode == .login) {
            MarkupUser.shared.login(email: em, pass: ps) { (success) in
                self.formEnabled(true)
                if(!success) {
                    self.msg("Login fail. Check your info and try again")
                } else {
                    self.backToMainScreen(true)
                }
            }
        } else if(self.mode == .registration) {
            MarkupUser.shared.register(email: em, pass: ps, name: nm) { (success) in
                self.formEnabled(true)
                if(!success) {
                    self.msg("Registration fail. Check your info and try again")
                } else {
                    self.backToMainScreen(true)
                }
            }
        }
        
    }
    
    @objc func viewOnTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Utils
    func msg(_ text: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Warning",
                        message: text,
                        preferredStyle: .alert)
                        
            let okAction = UIAlertAction(title: "Ok", style: .cancel) { (alertAction) in
            }
        
            alert.addAction(okAction)
            self.present(alert, animated: true) {
            }
        }
    }
    
    private func formEnabled(_ status: Bool) {
        DispatchQueue.main.async {
            self.loadingView.isHidden = status
        
            self.emailText.isUserInteractionEnabled = status
            self.passText.isUserInteractionEnabled = status
            self.nameText.isUserInteractionEnabled = status
        }
    }
    
    private func backToMainScreen(_ updateNavBar: Bool = false) {
        if(updateNavBar) {
            NotificationCenter.default.post(name: NOTIFICATION_UPDATE_NAVBAR, object: nil)
        }
        
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
}


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}


extension AuthViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == self.emailText) {
            if(self.mode == .registration) {
                self.nameText.becomeFirstResponder()
            } else {
                self.passText.becomeFirstResponder()
            }
        } else if(textField == self.nameText) {
            self.passText.becomeFirstResponder()
        } else if(textField == self.passText) {
            self.formRunAction()
        }
    
        return true
    }

}




