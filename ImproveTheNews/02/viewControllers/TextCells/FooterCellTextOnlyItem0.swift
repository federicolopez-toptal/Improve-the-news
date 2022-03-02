//
//  FooterCellTextOnlyItem0.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 11/05/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit


protocol FooterCellTextOnlyItem0Delegate {
    func pushNewTopic(_ topic: String, sender: FooterCellTextOnlyItem0)
}


class FooterCellTextOnlyItem0: UITableViewHeaderFooterView {

    var delegate: FooterCellTextOnlyItem0Delegate?
    @IBOutlet weak var centeredContainerView: UIView!
    
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
    
}
