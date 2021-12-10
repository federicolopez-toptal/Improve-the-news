//
//  ShareSplitActionsPopup.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 18/11/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit
import SwiftUI


protocol ShareSplitActionsPopupDelegate {
    func shareSplitAction_exit()
    func shareSplitAction_share()
    func shareSplitAction_randomize()
}


class ShareSplitActionsPopup: UIView {

    var button1: PulseButton?
    var button2: PulseButton?
    var button3: PulseButton?

    let textLabel: UILabel = UILabel()
    private var bottomConstraint: NSLayoutConstraint?
    var delegate: ShareSplitActionsPopupDelegate?

    private var currentAnim = 2
   
    
    init(into container: UIView) {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = accentOrange
        self.bottomConstraint = self.bottomAnchor.constraint(equalTo: container.bottomAnchor,
            constant: 0)
            
        container.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.widthAnchor.constraint(equalTo: container.widthAnchor),
            self.heightAnchor.constraint(equalToConstant: 150),
            self.bottomConstraint!
        ])
        
        self.layer.cornerRadius = 45.0
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        self.button1 = PulseButton(superview: self, index: 1)
        self.button1?.delegate = self
        self.button2 = PulseButton(superview: self, index: 2)
        self.button2?.delegate = self
        self.button3 = PulseButton(superview: self, index: 3)
        self.button3?.delegate = self
        
        self.textLabel.font = UIFont(name: "Roboto-Regular", size: 17.0)
        self.textLabel.textColor = .white
        self.textLabel.textAlignment = .center
        self.textLabel.numberOfLines = 2
        self.addSubview(self.textLabel)
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.textLabel.leadingAnchor.constraint(equalTo: button1!.leadingAnchor),
            self.textLabel.trailingAnchor.constraint(equalTo: button3!.trailingAnchor),
            self.textLabel.topAnchor.constraint(equalTo: button1!.bottomAnchor, constant: 13),
        ])
        
        self.showText("Select any 2 articles")
        self.setShareEnable(false)
        
        self.bottomConstraint?.constant = 100
        self.layoutIfNeeded()
        self.isHidden = true
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(onSplitShareViewControllerClosed),
            name: NOTIFICATION_CLOSE_SPLITSHARE,
            object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onSplitShareViewControllerClosed() {
        /*
        self.stopAnimations()
        
        self.startAnimation(button: self.button3)
        */
        //self.currentAnim = 3
    }
    


    // MARK: - Action(s)
    func show() {
        self.superview?.bringSubviewToFront(self)
        self.currentAnim = 2
    
        self.alpha = 0.0
        self.isHidden = false
        self.bottomConstraint!.constant = 0.0
        self.setShareEnable(false)
        self.showText("Select any 2 articles")
        
        UIView.animate(withDuration: 0.4) {
            self.alpha = 1.0
            self.superview!.layoutIfNeeded()
        } completion: { (succeed) in
        }
    }
    
    func hide() {
        self.bottomConstraint!.constant = 100
    
        UIView.animate(withDuration: 0.4) {
            self.superview!.layoutIfNeeded()
            self.alpha = 0.0
        } completion: { (succeed) in
            self.isHidden = true
        }
    }
    
    func showText(_ text: String) {
        self.textLabel.text = text
    }
    
    func setShareEnable(_ state: Bool) {
        self.button2?.setEnabled(state)
        
        if(!state) {
            self.currentAnim = 2
            self.button2?.stopAnimation()
            self.button3?.stopAnimation()
        }
    }
    
    func startAnims() {
        if(self.currentAnim == 2) {
            self.button2?.startAnimation()
            self.showText("Now tap the share button!")
        }
        
        /*
         else if(self.currentAnim == 3) {
            self.button3?.startAnimation()
            self.showText("Tap to randomise, or manually scroll each column.")
        }
        */
    }
    
    func randomize() {
        
    }
    
}

extension ShareSplitActionsPopup: PulseButtonDelegate {

    func pulseButtonOnTap(index: Int) {
        if(index==1) { // EXIT
            self.delegate?.shareSplitAction_exit()
        } else if(index==2) { // SHARE
            self.button2?.stopAnimation()
            self.delegate?.shareSplitAction_share()
            
            DELAY(1.0) {
                self.currentAnim = -1
                self.button3?.startAnimation()
                self.showText("Tap to randomise, or manually scroll each column.")
            }
            
            
        } else if(index==3) { // RANDOMIZE
            self.showText("Like what we found? Tap ‘Share’, or\ntap the randomise button again!")
            self.button2?.stopAnimation()
            self.button3?.stopAnimation()
            
            DELAY(1.0) {
                self.button2?.startAnimation()
            }
        
            self.setShareEnable(true)
            self.delegate?.shareSplitAction_randomize()
        }
    }

}
