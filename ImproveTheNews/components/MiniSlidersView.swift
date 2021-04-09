//
//  MiniSlidersView.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 23/03/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import Foundation
import UIKit


let NOTIFICATION_SHOW_SLIDERS_INFO = Notification.Name("showSlidersInfo")
// -----------------------------------
class MiniSlidersView: UIView {
    
    let dim: CGFloat = 35.0
    let thumbDim: CGFloat = 8.0
    
    let line1 = UIView(frame: CGRect.zero)
    let line2 = UIView(frame: CGRect.zero)
    
    let thumb1 = UIView(frame: CGRect.zero)
    let thumb2 = UIView(frame: CGRect.zero)

    var textOnTap = ""
    var viewController: UIViewController?

    // MARK: - Initialization
    init(some: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: dim, height: dim))
        self.backgroundColor = bgBlue
        
        line1.frame = CGRect(x: 3, y: 12, width: dim-12, height: 2)
        line1.backgroundColor = UIColor.init(hex: 0x4F5F8B)
        line1.layer.cornerRadius = 2
        self.addSubview(line1)
        
        line2.frame = CGRect(x: 3, y: 26, width: dim-12, height: 2)
        line2.backgroundColor = line1.backgroundColor
        line2.layer.cornerRadius = 2
        self.addSubview(line2)
        
        thumb1.frame = CGRect(x: 0, y: 0, width: thumbDim, height: thumbDim)
        thumb1.layer.cornerRadius = 4
        thumb1.backgroundColor = UIColor.init(hex: 0xDFE1D8)
        line1.addSubview(thumb1)
        thumb2.frame = CGRect(x: 0, y: 0, width: thumbDim, height: thumbDim)
        thumb2.layer.cornerRadius = 4
        thumb2.backgroundColor = UIColor.init(hex: 0xDFE1D8)
        line2.addSubview(thumb2)
        
        self.setValues(val1: 1, val2: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action(s)
    @objc func buttonOnTap(sender: UIButton) {
        print("GATO", "asdadasdsadasdasdsdas")
    }
    
    // MARK: - misc
    func insertInto(view: UIView) {
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            self.heightAnchor.constraint(equalToConstant: dim),
            self.widthAnchor.constraint(equalToConstant: dim)
        ])
        self.layer.cornerRadius = 15
        self.layer.maskedCorners = [.layerMaxXMinYCorner]
        
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        view.superview?.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            button.heightAnchor.constraint(equalToConstant: dim * 1.5),
            button.widthAnchor.constraint(equalToConstant: dim * 1.5)
        ])
        button.addTarget(self, action: #selector(buttonAreaTap(sender:)), for: .touchUpInside)
    }
    
    func setValues(val1: Int, val2: Int, source: String = "", countryID: String = "") {
        var val: Int
        var posX: CGFloat
        var mFrame: CGRect
        
        val = val1 //Int.random(in: 1...5)
        if(val<1){ val = 1 }
        else if(val>5){ val = 5 }
        
        //self.textOnTap = "<SOURCE> has a " + LR_text(val) + " and "
        self.textOnTap = "<SOURCE>"
        if(!source.isEmpty) {
            var lastIndex = source.count-1
            
            let parts = source.components(separatedBy: "#")
            if let part_1 = parts.first {
                lastIndex = part_1.count-2
            }
            
            let cleanSource = source[0...lastIndex]
            self.textOnTap = self.textOnTap.replacingOccurrences(of: "<SOURCE>", with: cleanSource)
        }
        self.textOnTap += self.NATIONALITY_forID(countryID)
        self.textOnTap += " has a " + LR_text(val) + " and "
        
        mFrame = thumb1.frame
        mFrame.origin.y = -3
        mFrame.origin.x = ((line1.frame.size.width-(thumbDim/2))/5) * CGFloat((val-1))
        thumb1.frame = mFrame
        
        val = val2 //Int.random(in: 1...5)
        if(val<1){ val = 1 }
        else if(val>5){ val = 5 }
        
        self.textOnTap += PE_text(val) + " stance"
        
        mFrame = thumb2.frame
        mFrame.origin.y = -3
        mFrame.origin.x = ((line2.frame.size.width-(thumbDim/2))/5) * CGFloat((val-1))
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
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
}


