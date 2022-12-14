//
//  MiniSlidersCircView.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 23/03/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import Foundation
import UIKit


//let NOTIFICATION_SHOW_SLIDERS_INFO = Notification.Name("showSlidersInfo")
// -----------------------------------
class MiniSlidersCircView: UIView {
    
    let dim: CGFloat = 28.0
    let thumbDim: CGFloat = 7
    
    let line1 = UIView(frame: CGRect.zero)
    let line2 = UIView(frame: CGRect.zero)
    
    let thumb1 = UIView(frame: CGRect.zero)
    let thumb2 = UIView(frame: CGRect.zero)

    var textOnTap = ""
    var viewController: UIViewController?

    var factor: CGFloat = 1.0

    // MARK: - Initialization
    init(some: String, factor: CGFloat = 1.0) {
        self.factor = factor
        
        super.init(frame: CGRect(x: 0, y: 0, width: dim * factor, height: dim * factor))
        self.backgroundColor = DARKMODE() ? .white.withAlphaComponent(0.15) : UIColor(hex: 0xEAEBEC)
        
        line1.frame = CGRect(x: 5 * factor, y: 9 * factor,
            width: (dim-10)*factor, height: 2*factor)
        line1.backgroundColor = DARKMODE() ? UIColor(hex: 0x93A0B4) : UIColor(hex: 0x93A0B4)
//        line1.layer.cornerRadius = 2 * factor
        self.addSubview(line1)

        line2.frame = CGRect(x: 5 * factor, y: 19 * factor,
            width: (dim-10)*factor, height: 2 * factor)
        line2.backgroundColor = line1.backgroundColor
//        line2.layer.cornerRadius = 2 * factor
        self.addSubview(line2)
//
        thumb1.frame = CGRect(x: 0, y: -2, width: thumbDim * factor, height: thumbDim * factor)
        thumb1.layer.cornerRadius = 4 * factor
        thumb1.backgroundColor = DARKMODE() ? .white : UIColor(hex: 0xFF643C)
        line1.addSubview(thumb1)
        thumb2.frame = CGRect(x: 0, y: -2, width: thumbDim * factor, height: thumbDim * factor)
        thumb2.layer.cornerRadius = 4 * factor
        thumb2.backgroundColor = thumb1.backgroundColor
        line2.addSubview(thumb2)
//
        self.setValues(val1: 1, val2: 1)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewOnTap(sender:)))
        self.addGestureRecognizer(gesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action(s)
    @objc func viewOnTap(sender: UITapGestureRecognizer) {
        if(MorePrefsViewController.showStancePopUp()) {
            let alert = UIAlertController(title: "", message: self.textOnTap,
                preferredStyle: .alert)
            
            let detailsAction = UIAlertAction(title: "Details", style: .default) { (action) in
                NotificationCenter.default.post(name: NOTIFICATION_SHOW_SLIDERS_INFO, object: nil)
            }
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(detailsAction)
            alert.addAction(okAction)
            alert.preferredAction = okAction

            if let vc = self.viewController {
                vc.present(alert, animated: true) {
                }
            }
        }
    }
    
    // MARK: - misc
    func insertInto(stackView: UIStackView) {
        //self.backgroundColor = .green
    
        stackView.addArrangedSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            self.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0),
//            self.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0),
            self.heightAnchor.constraint(equalToConstant: dim * factor),
            self.widthAnchor.constraint(equalToConstant: dim * factor)
        ])
        self.layer.cornerRadius = (dim/2) * factor
//        self.layer.maskedCorners = [.layerMaxXMinYCorner]
    }
    
    func setValues(val1: Int, val2: Int, source: String = "", countryID: String = "") {
        var val: Int
        var posX: CGFloat
        var mFrame: CGRect
        
        val = val1
        if(val<1){ val = 1 }
        else if(val>5){ val = 5 }
        
        self.textOnTap = "<SOURCE>"
        if(!source.isEmpty) {
            var lastIndex = source.count-1
            
            let parts = source.components(separatedBy: "#")
            if let part_1 = parts.first {
                lastIndex = part_1.count-1
            }
            
            let cleanSource = source[0...lastIndex]
            self.textOnTap = self.textOnTap.replacingOccurrences(of: "<SOURCE>", with: cleanSource)
        }
        self.textOnTap += self.NATIONALITY_forID(countryID)
        self.textOnTap += "has a " + LR_text(val) + " and "
        
        let tDim = thumbDim * factor
        mFrame = thumb1.frame
        mFrame.origin.y = -3 * self.factor
        mFrame.origin.x = ((line1.frame.size.width-(tDim/2))/5) * CGFloat((val-1))
        thumb1.frame = mFrame
        
        //val = Int.random(in: 1...5)  // <-- For testing purposes
        val = val2
        if(val<1){ val = 1 }
        else if(val>5){ val = 5 }
        
        self.textOnTap += PE_text(val) + " stance"
        
        mFrame = thumb2.frame
        mFrame.origin.y = -3 * factor
        mFrame.origin.x = ((line2.frame.size.width-(tDim/2))/5) * CGFloat((val-1))
        thumb2.frame = mFrame
    }
    
    private func LR_text(_ value: Int) -> String {
        switch value {
            case 1:
                return "left"
            case 2:
                return "center-left"
            case 3:
                return "center"
            case 4:
                return "center-right"
            default:
                return "right"
        }
    }
    
    private func PE_text(_ value: Int) -> String {
        switch value {
            case 1:
                return "establishment-critical"
            case 2:
                return "slightly establishment-critical"
            case 3:
                return "establishment-neutral"
            case 4:
                return "slightly pro-establishment"
            default:
                return "pro-establishment"
        }
    }
    
    private func NATIONALITY_forID(_ countryID: String) -> String {
        var nationality = ""
        
        switch countryID {
            case "GBR":
                nationality = "British"
            case "CAN":
                nationality = "Canadian"
            case "LBN":
                nationality = "Lebanese"
            case "USA":
                nationality = "American"
            case "ISR":
                nationality = "Israeli"
            case "KOR":
                nationality = "South Korean"
            case "RUS":
                nationality = "Russian"
            case "CHN":
                nationality = "Chinese"
            case "QAT":
                nationality = "Qatari"
                
            default:
                nationality = ""
        }
        
        if(!nationality.isEmpty) {
            nationality = " is " + nationality + " and "
        }
        
        return nationality
    }
    
    @objc func buttonAreaTap(sender: UIButton) {
        if(MorePrefsViewController.showStancePopUp()) {
            let alert = UIAlertController(title: "", message: self.textOnTap,
                preferredStyle: .alert)
            
            let detailsAction = UIAlertAction(title: "Details", style: .default) { (action) in
                NotificationCenter.default.post(name: NOTIFICATION_SHOW_SLIDERS_INFO, object: nil)
            }
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(detailsAction)
            alert.addAction(okAction)
            alert.preferredAction = okAction

            if let vc = self.viewController {
                vc.present(alert, animated: true) {
                    //vc.setNeedsStatusBarAppearanceUpdate()
                    //UIApplication.shared.statusBarStyle = .darkContent
                }
            }
        }
    }
    
}


