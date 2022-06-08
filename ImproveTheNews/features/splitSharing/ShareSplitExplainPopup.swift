//
//  ShareSplitExplainPopup.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 15/11/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

protocol ShareSplitExplainPopupDelegate {
    func onShareSplitExplaintPopupClose()
}


class ShareSplitExplainPopup: UIView {

    var delegate: ShareSplitExplainPopupDelegate?
    private var dontShowStatus = false
    private var bottomConstraint: NSLayoutConstraint?
    let dontShowButton = UIButton(type: .system)

    private var dontShowKey = "shareSplitExplainPopupDontShow"

    init(into container: UIView) {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.bottomConstraint = self.bottomAnchor.constraint(equalTo: container.bottomAnchor,
            constant: 0)
        
        container.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.widthAnchor.constraint(equalTo: container.widthAnchor),
            self.topAnchor.constraint(equalTo: container.topAnchor),
            //self.heightAnchor.constraint(equalToConstant: 450),
            self.bottomConstraint!
        ])
        
        let blueRect = UIView(frame: CGRect.zero)
        blueRect.backgroundColor = UIColor(hex: 0x1B2239)
        self.addSubview(blueRect)
        blueRect.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blueRect.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blueRect.widthAnchor.constraint(equalTo: self.widthAnchor),
            blueRect.heightAnchor.constraint(equalToConstant: 450),
            blueRect.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Merriweather-Bold", size: 22)
        titleLabel.textColor = .white
        titleLabel.text = "Share the split mode"
        blueRect.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: blueRect.topAnchor, constant: 27),
            titleLabel.leadingAnchor.constraint(equalTo: blueRect.leadingAnchor, constant: 20),
        ])
        
        let button1 = UIImageView()
        button1.image = UIImage(named: "shareSplit_button.png")
        blueRect.addSubview(button1)
        button1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 25),
            button1.leadingAnchor.constraint(equalTo: blueRect.leadingAnchor, constant: 20),
            button1.widthAnchor.constraint(equalToConstant: 50),
            button1.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let button2 = UIImageView()
        button2.image = UIImage(named: "shareSplit_button.png")
        blueRect.addSubview(button2)
        button2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button2.topAnchor.constraint(equalTo: button1.bottomAnchor, constant: 40),
            button2.leadingAnchor.constraint(equalTo: blueRect.leadingAnchor, constant: 20),
            button2.widthAnchor.constraint(equalToConstant: 50),
            button2.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let button3 = UIImageView()
        button3.image = UIImage(named: "shareSplit_button.png")
        blueRect.addSubview(button3)
        button3.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button3.topAnchor.constraint(equalTo: button2.bottomAnchor, constant: 40),
            button3.leadingAnchor.constraint(equalTo: blueRect.leadingAnchor, constant: 20),
            button3.widthAnchor.constraint(equalToConstant: 50),
            button3.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let label1 = UILabel()
        label1.textColor = UIColor(hex: 0x93A0B4)
        label1.numberOfLines = 0
        label1.font = UIFont(name: "Roboto-Regular", size: 15)
        label1.text = "Select any 2 articles from either side of the split, then tap the share button and share the split on your social channels!"
        blueRect.addSubview(label1)
        label1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label1.leadingAnchor.constraint(equalTo: button1.trailingAnchor, constant: 17),
            label1.trailingAnchor.constraint(equalTo: blueRect.trailingAnchor, constant: -31),
            label1.topAnchor.constraint(equalTo: button1.topAnchor)
        ])
        
        let label2 = UILabel()
        label2.textColor = UIColor(hex: 0x93A0B4)
        label2.numberOfLines = 0
        label2.font = UIFont(name: "Roboto-Regular", size: 15)
        label2.text = "To exit split mode and access the sliders, tap the back arrow button."
        blueRect.addSubview(label2)
        label2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label2.leadingAnchor.constraint(equalTo: button2.trailingAnchor, constant: 17),
            label2.trailingAnchor.constraint(equalTo: blueRect.trailingAnchor, constant: -31),
            label2.topAnchor.constraint(equalTo: button2.topAnchor)
        ])
        
        let label3 = UILabel()
        label3.textColor = UIColor(hex: 0x93A0B4)
        label3.numberOfLines = 0
        label3.font = UIFont(name: "Roboto-Regular", size: 15)
        label3.text = "Tapping the Randomise button allows you to see random pairings of articles while in ‘Split’ mode. You can also scroll each column manually."
        blueRect.addSubview(label3)
        label3.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label3.leadingAnchor.constraint(equalTo: button3.trailingAnchor, constant: 17),
            label3.trailingAnchor.constraint(equalTo: blueRect.trailingAnchor, constant: -31),
            label3.topAnchor.constraint(equalTo: button3.topAnchor)
        ])

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        blueRect.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 35),
            closeButton.heightAnchor.constraint(equalToConstant: 35),
            closeButton.topAnchor.constraint(equalTo: blueRect.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: blueRect.trailingAnchor, constant: -10)
        ])
        closeButton.addTarget(self,
            action: #selector(closeButtonTap(sender: )), for: .touchUpInside)
        
        let line = UIView()
        line.backgroundColor = .white
        line.alpha = 0.1
        blueRect.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: blueRect.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: blueRect.trailingAnchor),
            line.topAnchor.constraint(equalTo: blueRect.topAnchor),
            line.heightAnchor.constraint(equalToConstant: 1.0)
        ])
        
        let icon1 = UIImageView()
        icon1.image = UIImage(named: "shareSplit_shareIcon.png")
        blueRect.addSubview(icon1)
        icon1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon1.widthAnchor.constraint(equalToConstant: 22.5),
            icon1.heightAnchor.constraint(equalToConstant: 24.9),
            icon1.centerXAnchor.constraint(equalTo: button1.centerXAnchor),
            icon1.centerYAnchor.constraint(equalTo: button1.centerYAnchor)
        ])
        
        let icon2 = UIImageView()
        icon2.image = UIImage(named: "shareSplit_exitIcon.png")
        blueRect.addSubview(icon2)
        icon2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon2.widthAnchor.constraint(equalToConstant: 20.0),
            icon2.heightAnchor.constraint(equalToConstant: 20.0),
            icon2.centerXAnchor.constraint(equalTo: button2.centerXAnchor),
            icon2.centerYAnchor.constraint(equalTo: button2.centerYAnchor)
        ])
        
        let icon3 = UIImageView()
        icon3.image = UIImage(named: "shareSplit_randomIcon.png")
        blueRect.addSubview(icon3)
        icon3.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon3.widthAnchor.constraint(equalToConstant: 10.5),
            icon3.heightAnchor.constraint(equalToConstant: 24.25),
            icon3.centerXAnchor.constraint(equalTo: button3.centerXAnchor),
            icon3.centerYAnchor.constraint(equalTo: button3.centerYAnchor)
        ])
        
        dontShowButton.setImage(UIImage(systemName: "square"), for: .normal)
        dontShowButton.setTitle("  Don’t show this dialog again", for: .normal)
        dontShowButton.contentHorizontalAlignment = .left
        dontShowButton.tintColor = UIColor(hex: 0x93A0B4)
        dontShowButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 15)
        blueRect.addSubview(dontShowButton)
        dontShowButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dontShowButton.leadingAnchor.constraint(equalTo: blueRect.leadingAnchor, constant: 20),
            dontShowButton.trailingAnchor.constraint(equalTo: blueRect.trailingAnchor, constant: -20),
            dontShowButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        if(IS_iPHONE()) {
            dontShowButton.topAnchor.constraint(equalTo: label3.bottomAnchor, constant: 25).isActive = true
        } else if(IS_iPAD()) {
            dontShowButton.topAnchor.constraint(equalTo: icon3.bottomAnchor, constant: 35).isActive = true
        }
        
        dontShowButton.addTarget(self,
            action: #selector(dontShowButtonTap(sender: )), for: .touchUpInside)
            
        self.bottomConstraint?.constant = 450/2
        self.layoutIfNeeded()
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func mustBeShown() -> Bool {
        let value = UserDefaults.getBoolValue(key: self.dontShowKey)
        return !value
        
        //return true
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
    
    func hide() {
        self.alpha = 1.0
        self.bottomConstraint!.constant = 450/2
        
        UIView.animate(withDuration: 0.4) {
            self.alpha = 0.0
            self.superview!.layoutIfNeeded()
        } completion: { (succeed) in
            self.isHidden = true
        }
    }
    
    // MARK: - Event(s)
    @objc func closeButtonTap(sender: UIButton) {
        self.hide()
        self.delegate?.onShareSplitExplaintPopupClose()
    }
    
    @objc func dontShowButtonTap(sender: UIButton) {
        self.dontShowStatus = !self.dontShowStatus
        if(self.dontShowStatus){
            self.dontShowButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        } else {
            self.dontShowButton.setImage(UIImage(systemName: "square"), for: .normal)
        }
        
        UserDefaults.setBoolValue(self.dontShowStatus, forKey: self.dontShowKey)
    }
    
}
