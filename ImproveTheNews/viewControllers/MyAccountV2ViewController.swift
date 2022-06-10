//
//  MyAccountV2ViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 09/06/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit

class MyAccountV2ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setContentView()
        SETUP_NAVBAR(viewController: self,
            homeTap: nil,
            menuTap: nil,
            searchTap: nil,
            userTap: nil)
            
        if(!DARKMODE()){ self.applyStyle() }
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
    }
    
    @objc func onDeviceOrientationChanged() {
        var mFrame = self.contentView.frame
        mFrame.size.width = UIScreen.main.bounds.width
        self.contentView.frame = mFrame
         
//        let dim: CGFloat = 65
//        self.loadingView.frame = CGRect(x: (UIScreen.main.bounds.width-dim)/2,
//                                        y: ((UIScreen.main.bounds.height-dim)/2) - 88,
//                                        width: dim, height: dim)
    }
    
    func applyStyle() {
        let vStackView = self.contentView.subviews.first as! UIStackView
        let signOutLabel = vStackView.arrangedSubviews.first as! UILabel
        
        signOutLabel.textColor = .black
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
    
}

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
    
}
