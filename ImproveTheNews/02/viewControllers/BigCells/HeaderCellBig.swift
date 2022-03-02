//
//  HeaderCellBig.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 12/05/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit


protocol HeaderCellBigDelegate {
    func pushNewTopic(_ topic: String, sender: HeaderCellBig)
}

class HeaderCellBig: UITableViewHeaderFooterView {

    var delegate: HeaderCellBigDelegate?

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var hierarchyLabel: UILabel!
    
    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = DARKMODE() ? bgBlue : bgWhite_LIGHT
        self.contentLabel.textColor = accentOrange
        self.contentLabel.isUserInteractionEnabled = true
        
        let titleTapGesture = UITapGestureRecognizer(target: self,
            action: #selector(tapOnTitle(_:)))
        self.contentLabel.addGestureRecognizer(titleTapGesture)
        
        
        self.hierarchyLabel.textColor = DARKMODE() ? articleSourceColor : textBlackAlpha
        self.hierarchyLabel.isUserInteractionEnabled = true
        
        let hierarchyTapGesture = UITapGestureRecognizer(target: self,
            action: #selector(tapOnHierarchy(_ :)))
        self.hierarchyLabel.addGestureRecognizer(hierarchyTapGesture)
    }
    
    // MARK: - Action(s)
    @objc func tapOnTitle(_ gesture: UITapGestureRecognizer) {
        let topicName = self.contentLabel.text!
        self.goToTopic(topic: Globals.topicmapping[topicName]!)
    }
    
    @objc func tapOnHierarchy(_ gesture: UITapGestureRecognizer) {
        
        guard let text = self.hierarchyLabel.text else { return }
        if(text=="  ") {
            return
        }
        
        let privacyPolicyRange = (text as NSString).range(of: "Headlines")
        
        if gesture.didTapAttributedTextInLabel(label: self.hierarchyLabel, inRange: privacyPolicyRange) {
            self.goToTopic(topic: "news")
        } else {
            let index = text.index(text.startIndex, offsetBy: 10)
            let remainingText = text[index...]
            let topicsArray = remainingText.components(separatedBy: ">")
            
            var found = false
            for t in topicsArray {
                let topicRange = (text as NSString).range(of: t)
                if gesture.didTapAttributedTextInLabel(label: self.hierarchyLabel,
                    inRange: topicRange) {
                    found = true
                    self.goToTopic(topic: Globals.topicmapping[t]!)
                    break
                }
            }
            
            if(!found) {
                let t = topicsArray[0]
                self.goToTopic(topic: Globals.topicmapping[t]!)
            }
        }
    }
    
    // MARK: - misc
    @objc func goToTopic(topic: String) {
        self.delegate?.pushNewTopic(topic, sender: self)
    }
    
}
