//
//  ShareSplitActionsPopup.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 18/11/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

class ShareSplitActionsPopup: UIView {

    let textLabel: UILabel = UILabel()
    private var bottomConstraint: NSLayoutConstraint?

    init(into container: UIView) {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor(hex: 0xD3592D)
        self.bottomConstraint = self.bottomAnchor.constraint(equalTo: container.bottomAnchor,
            constant: 0)
            
        container.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.widthAnchor.constraint(equalTo: container.widthAnchor),
            self.heightAnchor.constraint(equalToConstant: 180),
            self.bottomConstraint!
        ])
        
        self.layer.cornerRadius = 45.0
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        
        let buttonsDim: CGFloat = 60.0
        
        let button1 = UIImageView()
        button1.image = UIImage(named: "shareSplit_button.png")
        self.addSubview(button1)
        button1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button1.topAnchor.constraint(equalTo: self.topAnchor, constant: 35),
            button1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            button1.widthAnchor.constraint(equalToConstant: buttonsDim),
            button1.heightAnchor.constraint(equalToConstant: buttonsDim)
        ])
        
        let button2 = UIImageView()
        button2.image = UIImage(named: "shareSplit_button.png")
        self.addSubview(button2)
        button2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button2.topAnchor.constraint(equalTo: button1.topAnchor),
            button2.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            button2.widthAnchor.constraint(equalToConstant: buttonsDim),
            button2.heightAnchor.constraint(equalToConstant: buttonsDim)
        ])
        
        let button3 = UIImageView()
        button3.image = UIImage(named: "shareSplit_button.png")
        self.addSubview(button3)
        button3.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button3.topAnchor.constraint(equalTo: button1.topAnchor),
            button3.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            button3.widthAnchor.constraint(equalToConstant: buttonsDim),
            button3.heightAnchor.constraint(equalToConstant: buttonsDim)
        ])
        
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
            self.textLabel.topAnchor.constraint(equalTo: button1.bottomAnchor, constant: 25),
        ])
        
        self.showText("Select any 2 articles")
        
        
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
        
        UIView.animate(withDuration: 0.4) {
            self.alpha = 1.0
            self.superview!.layoutIfNeeded()
        } completion: { (succeed) in
            print("DONE!")
        }

    }
    
    func showText(_ text: String) {
        self.textLabel.text = text
    }

}
