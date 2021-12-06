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
}


class ShareSplitActionsPopup: UIView {

    let blackCircle = UIView()
    
    let textLabel: UILabel = UILabel()
    private var bottomConstraint: NSLayoutConstraint?
    var delegate: ShareSplitActionsPopupDelegate?

    let button1 = UIButton(type: .custom)
    let button2 = UIButton(type: .custom)
    let button3 = UIButton(type: .custom)
    var currentAnimButton: UIButton?
    let buttonBehind = UIImageView()
    
    init(into container: UIView) {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = accentOrange //UIColor(hex: 0xD3592D)
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
        
        
        let buttonsDim: CGFloat = 60.0
        
        button1.setImage(UIImage(named: "shareSplit_button.png"), for: .normal)
        self.addSubview(button1)
        //button1.frame = CGRect(x: 30, y: 22, width: buttonsDim, height: buttonsDim)
        button1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button1.topAnchor.constraint(equalTo: self.topAnchor, constant: 22),
            button1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            button1.widthAnchor.constraint(equalToConstant: buttonsDim),
            button1.heightAnchor.constraint(equalToConstant: buttonsDim)
        ])
        button1.addTarget(self, action: #selector(exitButtonOnTap(_:)), for: .touchUpInside)
        
        button2.setImage(UIImage(named: "shareSplit_button.png"), for: .normal)
        self.addSubview(button2)
        button2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button2.topAnchor.constraint(equalTo: button1.topAnchor),
            button2.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            button2.widthAnchor.constraint(equalToConstant: buttonsDim),
            button2.heightAnchor.constraint(equalToConstant: buttonsDim)
        ])
        button2.addTarget(self, action: #selector(shareButtonOnTap(_:)), for: .touchUpInside)
        
        button3.setImage(UIImage(named: "shareSplit_button.png"), for: .normal)
        self.addSubview(button3)
        button3.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button3.topAnchor.constraint(equalTo: button1.topAnchor),
            button3.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            button3.widthAnchor.constraint(equalToConstant: buttonsDim),
            button3.heightAnchor.constraint(equalToConstant: buttonsDim)
        ])
        button3.addTarget(self, action: #selector(randomizeButtonOnTap(_:)), for: .touchUpInside)
        
        
        buttonBehind.image = UIImage(named: "shareSplit_button.png")
        self.addSubview(buttonBehind)
        
        let icon1 = UIImageView()
        icon1.image = UIImage(named: "shareSplit_exitIcon.png")
        self.addSubview(icon1)
        icon1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon1.widthAnchor.constraint(equalToConstant: 22.5),
            icon1.heightAnchor.constraint(equalToConstant: 24.9),
            icon1.centerXAnchor.constraint(equalTo: button1.centerXAnchor),
            icon1.centerYAnchor.constraint(equalTo: button1.centerYAnchor)
        ])
        
        let icon2 = UIImageView()
        icon2.image = UIImage(named: "shareSplit_shareIcon.png")
        self.addSubview(icon2)
        icon2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon2.widthAnchor.constraint(equalToConstant: 20.0),
            icon2.heightAnchor.constraint(equalToConstant: 20.0),
            icon2.centerXAnchor.constraint(equalTo: button2.centerXAnchor),
            icon2.centerYAnchor.constraint(equalTo: button2.centerYAnchor)
        ])
        
        let icon3 = UIImageView()
        icon3.image = UIImage(named: "shareSplit_randomIcon.png")
        self.addSubview(icon3)
        icon3.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon3.widthAnchor.constraint(equalToConstant: 10.5),
            icon3.heightAnchor.constraint(equalToConstant: 24.25),
            icon3.centerXAnchor.constraint(equalTo: button3.centerXAnchor),
            icon3.centerYAnchor.constraint(equalTo: button3.centerYAnchor)
        ])
        
        self.textLabel.font = UIFont(name: "Roboto-Regular", size: 17.0)
        self.textLabel.textColor = .white
        self.textLabel.textAlignment = .center
        self.addSubview(self.textLabel)
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.textLabel.leadingAnchor.constraint(equalTo: button1.leadingAnchor),
            self.textLabel.trailingAnchor.constraint(equalTo: button3.trailingAnchor),
            self.textLabel.topAnchor.constraint(equalTo: button1.bottomAnchor, constant: 19),
        ])
        
        self.addSubview(blackCircle)
        blackCircle.backgroundColor = accentOrange.withAlphaComponent(0.25)
        //UIColor.black.withAlphaComponent(0.25)
        
        blackCircle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blackCircle.topAnchor.constraint(equalTo: button2.topAnchor),
            blackCircle.leadingAnchor.constraint(equalTo: button2.leadingAnchor),
            blackCircle.widthAnchor.constraint(equalToConstant: buttonsDim),
            blackCircle.heightAnchor.constraint(equalToConstant: buttonsDim)
        ])
        blackCircle.layer.cornerRadius = buttonsDim/2
        
        self.showText("Select any 2 articles")
        self.setShareEnable(false)
        
        self.bottomConstraint?.constant = 100
        self.layoutIfNeeded()
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action(s)
    func show() {
        self.superview?.bringSubviewToFront(self)
    
        self.alpha = 0.0
        self.isHidden = false
        self.bottomConstraint!.constant = 0.0
        self.setShareEnable(false)
        self.showText("Select any 2 articles")
        
        UIView.animate(withDuration: 0.4) {
            self.alpha = 1.0
            self.superview!.layoutIfNeeded()
        } completion: { (succeed) in
            
            DELAY(1.0) {
                self.startAnimation(button: self.button1)
            }
            
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
        self.blackCircle.isHidden = state
    }
    
    // MARK: - Event(s)
    @objc func exitButtonOnTap(_ sender: UIButton?) {
        self.delegate?.shareSplitAction_exit()
    }
    
    @objc func shareButtonOnTap(_ sender: UIButton?) {
        //self.delegate?.shareSplitAction_share()
        self.startAnimation(button: self.button1)
    }
    
    @objc func randomizeButtonOnTap(_ sender: UIButton?) {
        self.stopAnimations()
    }
    
    // MARK: - Animation
    func stopAnimations() {
        if(self.currentAnimButton != nil) {
            self.currentAnimButton?.layer.removeAllAnimations()
        }
        self.buttonBehind.layer.removeAllAnimations()
        self.buttonBehind.isHidden = true
        
        self.currentAnimButton = nil
    }
    
    func startAnimation(button: UIButton) {
        self.currentAnimButton = button
        
        let _scaleTo: CGFloat = 1.1
        let _scaleToBig: CGFloat = 1.7
        
        self.buttonBehind.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.buttonBehind.topAnchor.constraint(equalTo: button.topAnchor),
            self.buttonBehind.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            self.buttonBehind.widthAnchor.constraint(equalTo: button.widthAnchor),
            self.buttonBehind.heightAnchor.constraint(equalTo: button.heightAnchor)
        ])
        self.buttonBehind.transform = CGAffineTransform.identity
        self.buttonBehind.isHidden = false
        self.buttonBehind.alpha = 0.7
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut) {
            button.transform = CGAffineTransform(scaleX: _scaleTo, y: _scaleTo)
            self.buttonBehind.transform = CGAffineTransform(scaleX: _scaleToBig, y: _scaleToBig)
            self.buttonBehind.alpha = 0.0
        } completion: { _ in
            if let _button = self.currentAnimButton {
                UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut) {
                    _button.transform = CGAffineTransform.identity
                } completion: { _ in
                    if(self.currentAnimButton != nil) {
                        self.startAnimation(button: self.currentAnimButton!)
                    }
                }
            }
        }

    }

}
