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
}


class FooterCellTextOnly: UITableViewHeaderFooterView {

    var delegate: FooterCellTextOnlyDelegate?
    @IBOutlet weak var centeredContainerView: UIView!
    
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
            self.delegate?.pushNewTopic(topicCode, sender: self)
        }
    }
    
}
