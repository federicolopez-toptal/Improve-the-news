//
//  FooterCellTextOnly.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 29/04/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit


protocol FooterCellTextOnlyDelegate {
    func pushNewTopic(_ topic: String, sender: FooterCellTextOnly)
    func shareTapped(sender: FooterCellTextOnly)
}


class FooterCellTextOnly: UITableViewHeaderFooterView {

    var delegate: FooterCellTextOnlyDelegate?
    @IBOutlet weak var centeredContainerView: UIView!
    @IBOutlet weak var shareIcon: UIButton!
    
    private var currentTopic: String = ""
    
    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = bgBlue
        
        let moreLabel = self.centeredContainerView.subviews[0] as! UILabel
        moreLabel.textColor = articleSourceColor
        
        let topicLabel = self.centeredContainerView.subviews[1] as! UILabel
        topicLabel.textColor = accentOrange
        
        self.centeredContainerView.backgroundColor = .clear
        self.shareIcon.layer.cornerRadius = 0.5 * 55
        self.shareIcon.addTarget(self,
            action: #selector(shareIconTap(sender:)),
            for: .touchUpInside)
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
