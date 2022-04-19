//
//  PulseButton.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 08/12/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit
import SwiftUI

protocol PulseButtonDelegate {
    func pulseButtonOnTap(index: Int)
}


class PulseButton: UIView {

    private var index = -1
    var delegate: PulseButtonDelegate?

    private let buttonsDim: CGFloat = 60.0
    private let circleBehind = UIImageView()
    private let buttonImage = UIButton(type: .custom)
    private let orangeCover = UIView()
    private var animating = false
    private var buttonForAnimation = UIButton(type: .custom)


    init(superview: UIView, index: Int) {
        super.init(frame: .zero)
        
        self.index = index
        superview.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        if(index==1) {
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 30)
            ])
        } else if(index==2) {
            NSLayoutConstraint.activate([
                self.centerXAnchor.constraint(equalTo: superview.centerXAnchor)
            ])
        } else if(index==3) {
            NSLayoutConstraint.activate([
                self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -30),
            ])
        }
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 22),
            self.widthAnchor.constraint(equalToConstant: buttonsDim),
            self.heightAnchor.constraint(equalToConstant: buttonsDim)
        ])
        
        self.circleBehind.image = UIImage(named: "shareSplit_button.png")
        superview.addSubview(self.circleBehind)
        self.circleBehind.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.circleBehind.topAnchor.constraint(equalTo: self.topAnchor),
            self.circleBehind.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.circleBehind.widthAnchor.constraint(equalToConstant: buttonsDim),
            self.circleBehind.heightAnchor.constraint(equalToConstant: buttonsDim)
        ])
        
        self.buttonImage.setImage(UIImage(named: "shareSplit_button.png"), for: .normal)
        superview.addSubview(self.buttonImage)
        self.buttonImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.buttonImage.topAnchor.constraint(equalTo: self.topAnchor),
            self.buttonImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.buttonImage.widthAnchor.constraint(equalToConstant: buttonsDim),
            self.buttonImage.heightAnchor.constraint(equalToConstant: buttonsDim)
        ])
        self.buttonImage.addTarget(self, action: #selector(buttonOnTap(_:)), for: .touchUpInside)
        
        let iconImgView = UIImageView()
        if(index==1) {
            iconImgView.image = UIImage(named: "shareSplit_exitIcon.png")
        } else if(index==2) {
            iconImgView.image = UIImage(named: "shareSplit_shareIcon.png")
        } else if(index==3) {
            iconImgView.image = UIImage(named: "shareSplit_randomIcon.png")
        }
        
        superview.addSubview(iconImgView)
        iconImgView.translatesAutoresizingMaskIntoConstraints = false
        if(index==1) {
            NSLayoutConstraint.activate([
                iconImgView.widthAnchor.constraint(equalToConstant: 22.5),
                iconImgView.heightAnchor.constraint(equalToConstant: 24.9)
            ])
        } else if(index==2) {
            NSLayoutConstraint.activate([
                iconImgView.widthAnchor.constraint(equalToConstant: 20.0),
                iconImgView.heightAnchor.constraint(equalToConstant: 20.0)
            ])
        } else if(index==3) {
            NSLayoutConstraint.activate([
                iconImgView.widthAnchor.constraint(equalToConstant: 10.5),
                iconImgView.heightAnchor.constraint(equalToConstant: 24.25)
            ])
        }
        
        NSLayoutConstraint.activate([
            iconImgView.centerXAnchor.constraint(equalTo: self.buttonImage.centerXAnchor),
            iconImgView.centerYAnchor.constraint(equalTo: self.buttonImage.centerYAnchor)
        ])
        
        self.buttonForAnimation.backgroundColor = .clear
        superview.addSubview(self.buttonForAnimation)
        self.buttonForAnimation.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.buttonForAnimation.topAnchor.constraint(equalTo: self.topAnchor),
            self.buttonForAnimation.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.buttonForAnimation.widthAnchor.constraint(equalToConstant: buttonsDim),
            self.buttonForAnimation.heightAnchor.constraint(equalToConstant: buttonsDim)
        ])
        self.buttonForAnimation.addTarget(self, action: #selector(buttonOnTap(_:)), for: .touchUpInside)
        self.buttonForAnimation.isHidden = true
        
        self.orangeCover.backgroundColor = accentOrange.withAlphaComponent(0.25)
        superview.addSubview(self.orangeCover)
        self.orangeCover.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.orangeCover.topAnchor.constraint(equalTo: self.topAnchor),
            self.orangeCover.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.orangeCover.widthAnchor.constraint(equalToConstant: buttonsDim),
            self.orangeCover.heightAnchor.constraint(equalToConstant: buttonsDim)
        ])
        self.setEnabled(true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    func setEnabled(_ state: Bool) {
        self.orangeCover.isHidden = state
    }
    
    func startAnimation() {
        self.buttonForAnimation.isHidden = false
        self.animating = true
        self.circleBehind.transform = CGAffineTransform.identity
        self.circleBehind.alpha = 0.7
    
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseOut]) {
            self.buttonImage.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.circleBehind.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
            self.circleBehind.alpha = 0.0
            
        } completion: { _ in
            if(self.animating) {
                UIView.animate(withDuration: 0.6, delay: 0.0, options: [.curveEaseOut]) {
                    self.buttonImage.transform = CGAffineTransform.identity
                } completion: { _ in
                    if(self.animating){ self.startAnimation() }
                }
            }
        }
    }
    
    func stopAnimation() {
        self.buttonForAnimation.isHidden = true
        self.animating = false
        self.buttonImage.layer.removeAllAnimations()
        self.buttonImage.transform = CGAffineTransform.identity
        self.circleBehind.layer.removeAllAnimations()
        self.circleBehind.transform = CGAffineTransform.identity
        self.circleBehind.alpha = 0.0
    }
    
    @objc func buttonOnTap(_ sender: UIButton?) {
        self.delegate?.pulseButtonOnTap(index: self.index)
    }
    
    
}
