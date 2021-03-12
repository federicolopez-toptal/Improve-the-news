//
//  BannerView.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 11/03/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

// ------------------------------------------------------------
protocol BannerInfoDelegate {
    func BannerInfoOnClose()
}

class BannerInfo {
    
    static var shared: BannerInfo?
    
    var delegate: BannerInfoDelegate?
    
    var header: String
    var text: String
    var colorScheme: Int
    var adType: String
    var adCode: String
    var imgSize: Int
    var imgUrl: String
    var url: String
    
    var active: Bool
    var apiParam: String
    
    init(json: JSON) {
        header = json[1].stringValue
        text = json[2].stringValue
        colorScheme = json[3].intValue
        adType = json[4].stringValue
        adCode = json[5].stringValue
        imgSize = json[6].intValue
        imgUrl = json[7].stringValue
        url = json[8].stringValue
        
        apiParam = self.adCode + "01" // banner was shown
        
        let key = "banner_" + adCode
        if(UserDefaults.standard.object(forKey: key) == nil) {
            UserDefaults.setBoolValue(true, forKey: key)
            active = true
        } else {
            active = UserDefaults.getBoolValue(key: key)
        }
    }
    
    func log() {
        print(header)
        print(text)
        print(colorScheme)
        print(adType)
        print(adCode)
        print(imgSize)
        print(imgUrl)
        print(url)
    }
    
}
// ------------------------------------------------------------

protocol BannerViewDelegate {
    func tapOnLink(adCode: String)
    func tapOnClose(adCode: String, dontShow: Bool)
}

class BannerView: UIView {

    // --------------------------
    static let bannerHeights = [
        "yT": 440
    ] as [String: CGFloat]

    static func getHeightForBannerCode(_ code: String) -> CGFloat {
        var result: CGFloat = 0
        if let height = BannerView.bannerHeights[code] {
            result = height
        }
        
        return result
    }
    // --------------------------
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var onOff = UISwitch(frame: CGRect.zero)
    var delegate: BannerViewDelegate?
    
    init(posY: CGFloat) {
        let info = BannerInfo.shared!
        let H = BannerView.getHeightForBannerCode(info.adCode)
        
        super.init(frame: CGRect(x: 0, y: posY,
            width: UIScreen.main.bounds.width, height: H))
            
        if(info.adCode == "yT") {
            self.populateYouTubeBanner()
        }
        
        let key = "banner_" + info.adCode
        if(UserDefaults.standard.object(forKey: key) == nil) {
            UserDefaults.setBoolValue(true, forKey: key)
            BannerInfo.shared!.active = true
        } else {
            BannerInfo.shared!.active = UserDefaults.getBoolValue(key: key)
        }
        
        print(BannerInfo.shared!.active)
        print("")
    }
    
    // --------------------------
    func populateYouTubeBanner() {
        let info = BannerInfo.shared!
        self.backgroundColor  = bgBlue
        
        let logo = UIImageView(image: UIImage(named: "N64"))
        self.addSubview(logo)
        self.resize(logo, width: 40, height: 40)
        self.move(logo, x: 0, y: 10)
        self.centerHorizontally(logo)
        
        let header = UILabel(text: info.header,
                        font: UIFont(name: "Poppins-SemiBold", size: 18),
                        textColor: .white, textAlignment: .center, numberOfLines: 2)
        header.backgroundColor = .clear
        header.sizeToFit()
        self.addSubview(header)
        self.resize(header, width: 150, height: header.frame.size.height * 2)
        self.place(header, below: logo, yOffset: 10)
        self.centerHorizontally(header)
        
        let image = UIImageView(frame: CGRect.zero)
        image.contentMode = .scaleAspectFill
        image.sd_setImage(with: URL(string: info.imgUrl), placeholderImage: nil)
        self.addSubview(image)
        self.resize(image, width: 200, height: 200)
        self.place(image, below: header, yOffset: 10)
        self.centerHorizontally(image)
        
        let imageArea = UIButton(type: .custom)
        self.addSubview(imageArea)
        imageArea.frame = image.frame
        imageArea.addTarget(self, action: #selector(tapOnImage(sender:)), for: .touchUpInside)
        imageArea.backgroundColor = .clear
        
        let text = UILabel(text: info.text,
                        font: UIFont(name: "Poppins-SemiBold", size: 14),
                        textColor: .white, textAlignment: .center, numberOfLines: 1)
        text.backgroundColor = .clear
        text.sizeToFit()
        self.addSubview(text)
        self.place(text, below: header, yOffset: 210)
        self.centerHorizontally(text)
        
        let containerView = UIView()
        self.addSubview(containerView)
        self.resize(containerView, width: 290, height: 31)
        containerView.backgroundColor = .clear
        self.place(containerView, below: text, yOffset: 30)
        self.centerHorizontally(containerView)
        
        
        let button = UIButton(type: .custom)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 14)
        button.setTitle("Close", for: .normal)
        containerView.addSubview(button)
        self.resize(button, width: 75, height: 30)
        button.layer.cornerRadius = 15
        self.move(button, x: containerView.frame.size.width - 75, y: 0, bgColor: accentOrange)
        button.addTarget(self, action: #selector(closeView(sender:)), for: .touchUpInside)
        
        containerView.addSubview(onOff)
        self.resize(onOff, width: 42, height: 31)
        self.move(onOff, x: 0, y: 0)
        
        let dontShow = UILabel(text: "Don't show again",
                        font: UIFont(name: "Poppins-SemiBold", size: 14),
                        textColor: .white, textAlignment: .left, numberOfLines: 1)
        dontShow.backgroundColor = .red
        dontShow.sizeToFit()
        containerView.addSubview(dontShow)
        self.move(dontShow, x: 58, y: 6)
    }
    
    @objc func tapOnImage(sender: UIButton) {
        if let url = URL(string: BannerInfo.shared!.url) {
            UIApplication.shared.open(url)
            BannerInfo.shared!.apiParam = BannerInfo.shared!.adCode + "04"
        }    
    }
    @objc func closeView(sender: UIButton) {
        if(self.onOff.isOn) {
            BannerInfo.shared!.apiParam = BannerInfo.shared!.adCode + "03"
            UserDefaults.setBoolValue(false, forKey: "banner_" + BannerInfo.shared!.adCode)
        } else {
            BannerInfo.shared!.apiParam = BannerInfo.shared!.adCode + "02"
        }
        BannerInfo.shared!.active = false
        BannerInfo.shared?.delegate?.BannerInfoOnClose()
    }
    
    // --------------------------
    private func move(_ view: UIView, x: CGFloat, y: CGFloat, bgColor: UIColor = .clear) {
        let screenSize = UIScreen.main.bounds
        var mFrame = view.frame
        
        if(x<0) {
            mFrame.origin.x = screenSize.width - mFrame.size.width + x
        } else {
            mFrame.origin.x = x
        }
        
        mFrame.origin.y = y
        view.frame = mFrame
        view.backgroundColor = bgColor
    }
    private func place(_ view: UIView, below: UIView, yOffset: CGFloat  = 0) {
        var mFrame = view.frame
        mFrame.origin.y = below.frame.origin.y + below.frame.size.height + yOffset
        view.frame = mFrame
    }
    private func centerHorizontally(_ view: UIView) {
        var mFrame = view.frame
        mFrame.origin.x = (view.superview!.frame.size.width - mFrame.size.width)/2
        view.frame = mFrame
    }
    private func resize(_ view: UIView, width: CGFloat, height: CGFloat) {
        var mFrame = view.frame
        mFrame.size.width = width
        mFrame.size.height = height
        view.frame = mFrame
    }
    // --------------------------
}
// ------------------------------------------------------------
