//
//  MyAccountViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 05/04/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit
import SafariServices
import FBSDKShareKit

class MyAccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyStyle()
        self.updateButtons()
        
        
        DELAY(1.0) {
            let api = ShareAPI.instance
            
            print("SHARE", api.uuid)
            print("SHARE", api.getBearerAuth())
            
//            let fb = FB_SDK.instance
////            let _link = "https://www.independent.co.uk/space/kamala-harris-missiles-satellite-destroy-b2060554.html"
//            let _link = "https://www.improvethenews.org/split-shares?id=340"
//            fb.share(link: _link, vc: self)
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return STATUS_BAR_STYLE()
    }

}

// MARK: UI
extension MyAccountViewController {

    public static func createInstance() -> MyAccountViewController {
        let vc = MyAccountViewController(nibName: "MyAccountViewController", bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    private func applyStyle() {
        let dismissButton = self.view.viewWithTag(101) as! UIButton
        
        if(DARKMODE()){ // DARK mode
            self.view.backgroundColor = .black
            dismissButton.setCustomAttributedTextColor(.white)
        } else { // BRIGHT mode
            self.view.backgroundColor = bgWhite_LIGHT
            dismissButton.setCustomAttributedTextColor(textBlack)
            
            // labels
            let labels = [102, 103]
            for T in labels {
                let label = self.view.viewWithTag(T) as! UILabel
                label.textColor = .black
            }
        }
        
        // containers
        let containers = [104, 105, 106, 107]
        for C in containers {
            let view = self.view.viewWithTag(C)!
            view.backgroundColor = self.view.backgroundColor
            
            if(!DARKMODE()) {
                let label = view.getCustomViewWithTag(1) as! UILabel
                label.textColor = .black
                
                let line = view.getCustomViewWithTag(2)!
                line.backgroundColor = .black
            }
        }
        
    }
    
    func updateButtons() {
        let fb = FB_SDK.instance
        let fb_button = self.view.viewWithTag(31) as! SocialConnectButton
        fb_button.connected = fb.isLogged()
        
        let tw = TW_SDK.instance
        let tw_button = self.view.viewWithTag(32) as! SocialConnectButton
        tw_button.connected = tw.isLogged()
        
        let li = LI_SDK.instance
        let li_button = self.view.viewWithTag(33) as! SocialConnectButton
        li_button.connected = li.isLogged()
        
        let red = RED_SDK.instance
        let red_button = self.view.viewWithTag(34) as! SocialConnectButton
        red_button.connected = red.isLogged()
    }
    
    // MARK: UI Events
    @IBAction func backButtonTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func socialsButtonTap(_ sender: UIButton) {
        let tag = sender.tag - 30
        switch(tag) {
            case 1:
            FB_buttonTap()
            case 2:
            TW_buttonTap()
            case 3:
            LI_buttonTap()
            case 4:
            RED_buttonTap()
        
            default:
            FB_buttonTap()
        }
    }
}

// MARK: Social stuff
extension MyAccountViewController: SFSafariViewControllerDelegate {

    private func FB_buttonTap() {
        let fb = FB_SDK.instance
        let fb_button = self.view.viewWithTag(31) as! SocialConnectButton
    
        if(fb.isLogged()) {
            fb.logout(vc: self) { (isLoggedOut) in
                if(isLoggedOut) { self.updateButton(fb_button, connected: false) }
            }
        } else {
            fb.login(vc: self) { (isLogged) in
                if(isLogged) { self.updateButton(fb_button, connected: true) }
            }
        }
    }
    
    private func TW_buttonTap() {
        let tw = TW_SDK.instance
        let tw_button = self.view.viewWithTag(32) as! SocialConnectButton
    
        if(tw.isLogged()) {
            tw.logout(vc: self) { (isLoggedOut) in
                if(isLoggedOut) { self.updateButton(tw_button, connected: false) }
            }
        } else {
            tw.login(vc: self) { (isLogged) in
                if(isLogged) { self.updateButton(tw_button, connected: true) }
            }
        }
    }
    
    private func LI_buttonTap() {
        let li = LI_SDK.instance
        let li_button = self.view.viewWithTag(33) as! SocialConnectButton
    
        if(li.isLogged()) {
            li.logout(vc: self) { (isLoggedOut) in
                if(isLoggedOut) { li_button.connected = false }
            }
        } else {
            li.login(vc: self) { (isLogged) in
                if(isLogged) {
                    DispatchQueue.main.async { li_button.connected = true }
                }
            }
        }
    }
    
    private func RED_buttonTap() {
        let red = RED_SDK.instance
        let red_button = self.view.viewWithTag(34) as! SocialConnectButton
    
        if(red.isLogged()) {
            red.logout(vc: self) { (isLoggedOut) in
                if(isLoggedOut) { red_button.connected = false }
            }
        } else {
            red.login(vc: self) { (isLogged) in
                if(isLogged) {
                    DispatchQueue.main.async { red_button.connected = true }
                }
            }
        }
    }
    
    private func updateButton(_ button: SocialConnectButton, connected: Bool) {
        DispatchQueue.main.async {
            button.connected = connected
        }
    }
}


extension MyAccountViewController: SharingDelegate {
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("SHARE", "yessss")
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("SHARE", "fail")
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        print("SHARE", "cancel!")
    }
    

}
