//
//  ForgotPassViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 09/06/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit

class ForgotPassViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    private let loadingView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
        self.buildContent()
        self.buildLoading()
        SETUP_NAVBAR(viewController: self,
            homeTap: nil,
            menuTap: nil,
            searchTap: nil,
            userTap: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return STATUS_BAR_STYLE()
    }

}

// MARK: - UI
extension ForgotPassViewController {

    public static func createInstance() -> ForgotPassViewController {
        let vc = ForgotPassViewController(nibName: "ForgotPassViewController", bundle: nil)
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
    
    private func buildContent() {
        let formView = self.view.subviews.first as! SignInUpFormFormView
        formView.backgroundColor = self.view.backgroundColor
        formView.layer.borderWidth = 10.0
        formView.layer.borderColor = DARKMODE() ? UIColor.white.withAlphaComponent(0.35).cgColor : UIColor.black.withAlphaComponent(0.15).cgColor
        
        self.emailTextField.keyboardType = .emailAddress
        self.emailTextField.autocapitalizationType = .none
        self.emailTextField.autocorrectionType = .no
        self.emailTextField.smartDashesType = .no
        self.emailTextField.smartInsertDeleteType = .no
        self.emailTextField.spellCheckingType = .no
        self.emailTextField.returnKeyType = .send
        self.emailTextField.delegate = self

        self.emailTextField.layer.borderWidth = 1.0
        self.emailTextField.layer.borderColor = UIColor(hex: 0xBBBBBB).withAlphaComponent(0.8).cgColor
        self.emailTextField.backgroundColor = DARKMODE() ? UIColor(hex: 0x1E1E1E) : .white
        self.emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Your Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBBBBBB).withAlphaComponent(0.5)]
        )
        
        if(!DARKMODE()) {
            let formView = self.view.subviews.first!
            let titleLabel = formView.subviews.first as! UILabel
            
            titleLabel.textColor = .black
            self.emailTextField.textColor = .black
        }
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func showLoading(_ visible: Bool = true) {
        DispatchQueue.main.async {
            self.loadingView.isHidden = !visible
            self.view.isUserInteractionEnabled = !visible
        }
    }
    
}

// MARK: - Button action(s)
extension ForgotPassViewController {
    @IBAction func signUpButtonTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func formActionButtonTap(_ sender: UIButton) {
        self.sendForm()
    }
}

// MARK: - UITextFieldDelegate
extension ForgotPassViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendForm()
        return true
    }
    
}

// MARK: - Form stuff
extension ForgotPassViewController {
    private func sendForm() {
        self.dismissKeyboard()
        let email = self.emailTextField.text!
        
        if(!VALIDATE_EMAIL(email)) {
            ALERT(vc: self, title: "Warning", message: "Please, enter a valid email")
        } else {
            self.showLoading()
            let api = ShareAPI.instance
            
            api.forgotPassword(email: email) { success in
                self.showLoading(false)
                if(!success) {
                    let msg = "An error ocurred. Please, try again later"
                    ALERT(vc: self, title: "Warning", message: msg)
                } else {
                    ALERT(vc: self, title: "Success", message: "Password reset link sent to your email") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        }
    }
}
