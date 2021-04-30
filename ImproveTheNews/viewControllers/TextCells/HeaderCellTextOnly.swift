//
//  HeaderCellTextOnly.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 29/04/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit


protocol HeaderCellTextOnlyDelegate {
    func pushNewTopic(_ topic: String, sender: HeaderCellTextOnly)
}

class HeaderCellTextOnly: UITableViewHeaderFooterView {

    var delegate: HeaderCellTextOnlyDelegate?

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var hierarchyLabel: UILabel!
    
    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = bgBlue
        self.contentLabel.textColor = accentOrange
        
        self.hierarchyLabel.textColor = articleSourceColor
        self.hierarchyLabel.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self,
            action: #selector(tapOnHierarchy(_ :)))
        self.hierarchyLabel.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Action(s)
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
