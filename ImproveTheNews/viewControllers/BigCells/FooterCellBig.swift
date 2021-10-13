//
//  FooterCellBig.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 29/04/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit


protocol FooterCellBigDelegate {
    func pushNewTopic(_ topic: String, sender: FooterCellBig)
    func shareTapped(sender: FooterCellBig)
}


class FooterCellBig: UITableViewHeaderFooterView {

    var delegate: FooterCellBigDelegate?
    @IBOutlet weak var centeredContainerView: UIView!
    @IBOutlet weak var shareIcon: UIButton!
    
    private var currentTopic: String = ""
    
    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = DARKMODE() ? bgBlue : bgWhite_LIGHT
        
        let moreLabel = self.centeredContainerView.subviews[0] as! UILabel
        moreLabel.textColor = DARKMODE() ? articleSourceColor : textBlackAlpha
        
        let topicLabel = self.centeredContainerView.subviews[1] as! UILabel
        topicLabel.textColor = accentOrange
        
        self.centeredContainerView.backgroundColor = .clear
        self.shareIcon.layer.cornerRadius = 0.5 * 55
        self.shareIcon.addTarget(self,
            action: #selector(shareIconTap(sender:)),
            for: .touchUpInside)
            
        if(!DARKMODE()) {
            for v in self.contentView.subviews {
                if(v.alpha < 1.0) {
                    v.backgroundColor = .black
                }
                
                if(v is UIImageView) {
                    (v as! UIImageView).image = UIImage(named: "ITN_logo_blackText.png")
                }
            }
        }
        
        if(IS_ZOOMED()) {
            moreLabel.font = UIFont(name: "PTSerif-Bold", size: 22)
            topicLabel.font = UIFont(name: "PTSerif-Bold", size: 22)
        }
    }
    
    func setTopic(_ topic: String) {
        let topicLabel = self.centeredContainerView.subviews[1] as! UILabel
        topicLabel.text = topic
        self.currentTopic = topic
    }

    @IBAction func tapOnTopic(_ sender: UIButton) {
        var topicCode = ""
        for (key, value) in Globals.topicmapping {
            if(key == self.currentTopic) {
                topicCode = value
                break
            }
        }
        
        if(!topicCode.isEmpty) {
            Utils.shared.didTapOnMoreLink = true
            self.delegate?.pushNewTopic(topicCode, sender: self)
        }
    }
    
    @objc func shareIconTap(sender: UIButton) {
        self.delegate?.shareTapped(sender: self)
    }
    
}
