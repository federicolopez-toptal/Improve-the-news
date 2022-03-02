//
//  CookiesAlert.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 13/07/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

class CookiesAlert: UIView {

    static var shared = CookiesAlert()
    private var vc: UIViewController?

    // MARK: - Initialization
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 130))
        self.backgroundColor = accentOrange.withAlphaComponent(0.95)
        self.addContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addContent() {
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        let txt = "By using our site, you agree to our use of cookies"
        let font = UIFont(name: "Poppins-SemiBold", size: 14.0)
        let label = UILabel(text: txt, font: font, textColor: .white,
                            textAlignment: .left, numberOfLines: 0)
        
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 15.0),
            label.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width-20.0)
        ])
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attrStr = NSMutableAttributedString(
            string: "More info",
            attributes: attrs
        )
        
        let infoButton = UIButton(type: .custom)
        infoButton.setAttributedTitle(attrStr, for: .normal)
        infoButton.contentHorizontalAlignment = .left
        self.addSubview(infoButton)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0),
            infoButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 0),
            infoButton.widthAnchor.constraint(equalToConstant: 100),
            infoButton.heightAnchor.constraint(equalToConstant: 20)
        ])
        infoButton.backgroundColor = .clear
        infoButton.addTarget(self, action: #selector(moreInfoButtonTap), for: .touchUpInside)
        
        let okButton = UIButton(type: .custom)
        okButton.titleLabel?.font = font
        okButton.setTitleColor(.white, for: .normal)
        okButton.setTitle("Accept", for: .normal)
        self.addSubview(okButton)
        okButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            okButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0),
            okButton.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 20.0),
            okButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width-20.0),
            okButton.heightAnchor.constraint(equalToConstant: 35)
        ])
        okButton.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        okButton.addTarget(self, action: #selector(okButtonTap), for: .touchUpInside)
    }
    
    // MARK: - Actions
    func show(viewController: UIViewController) {
        if(MarkupUser.shared.userInfo == nil) { return }
        if(self.superview != nil){ return }
        if let _val = UserDefaults.standard.string(forKey: self.keyName()) {
            return
        }
        
        
        self.vc = viewController
        
        var mFrame = self.frame
        mFrame.origin.y = -self.frame.size.height
        self.frame = mFrame
        viewController.view.addSubview(self)
        UIView.animate(withDuration: 0.75) {
            var mFrame = self.frame
            mFrame.origin.y = 0
            self.frame = mFrame
        } completion: { (success) in
        }
    }
    
    private func hide() {
        var mFrame = self.frame
        mFrame.origin.y = 0
        self.frame = mFrame

        UIView.animate(withDuration: 0.75) {
            var mFrame = self.frame
            mFrame.origin.y = -self.frame.size.height
            self.frame = mFrame
        } completion: { (success) in
            self.removeFromSuperview()
        }
    }
    
    @objc private func moreInfoButtonTap() {
        if let _vc = self.vc {
            let privacy = PrivacyPolicy()
            _vc.present(privacy, animated: true, completion: nil)
        }
    }
    
    @objc private func okButtonTap() {
        UserDefaults.standard.setValue("abc", forKey: self.keyName())
        UserDefaults.standard.synchronize()
        
        self.hide()
    }
    
    // MARK: - misc
    private func keyName() -> String {
        return "markupUser_" + String(MarkupUser.shared.userInfo!.id)
    }
    
}
