//
//  seeMoreFooterLast.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 16/02/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

class seeMoreFooterLast: UICollectionReusableView {
    
    static let footerId = "FooterIdLast"
    
    var delegate: TopicSelectorDelegate?
    
    var label = UILabel()
    var button = UIButton(title: "topic", titleColor: accentOrange, font: UIFont(name: "PTSerif-Bold", size: 23)!, backgroundColor: .darkGray, target: self, action: #selector(goToTopic(_:)))
    
    public func configure() {
        
        label.text = "More "
        label.font = UIFont(name: "PTSerif-Bold", size: 23)
        label.textColor = articleSourceColor
        label.sizeToFit()
        label.backgroundColor = .clear
            var mFrame = label.frame
            mFrame.origin.x = (UIScreen.main.bounds.width/2) - mFrame.size.width
            mFrame.origin.y = 20 + 4
            label.frame = mFrame
        addSubview(label)
        
        button.sizeToFit()
        button.backgroundColor = .clear
            mFrame = button.frame
            mFrame.origin.x = (UIScreen.main.bounds.width/2)
            mFrame.origin.y = 13 + 4
            button.frame = mFrame
        addSubview(button)
        
            let w = label.frame.size.width + button.frame.size.width
            let newX = (UIScreen.main.bounds.width - w)/2
            let diffX = newX - label.frame.origin.x
            
            mFrame = label.frame
            mFrame.origin.x += diffX
            label.frame = mFrame
            
            mFrame = button.frame
            mFrame.origin.x += diffX
            button.frame = mFrame

        addTopBorder()
        self.backgroundColor = bgBlue
    }
    
    func addTopBorder() {
        let border = UIView(frame: CGRect(x: 10, y: 5,
                            width: self.frame.width - 20, height: 1))
        border.backgroundColor = articleSourceColor
        addSubview(border)
    }
    
    func addBottomBorder() {
        let border = UIView(frame: CGRect(x: 10, y: self.frame.height - 5,
                            width: self.frame.width - 20, height: 2))
        border.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        addSubview(border)
    }
    
    public func setFooterText(subtopic: String) {
        button.setTitle(subtopic, for: .normal)
    }
    
    @objc func goToTopic(_ sender: UIButton!) {
        print("GATO", "click en MORE al fondo")
        let buttontext = button.titleLabel!.text!
        let topic = buttontext.replacingOccurrences(of: "MORE ", with: "")
        
        if(Globals.topicmapping[topic] != nil) {
            let newTopic = Globals.topicmapping[topic]!
            self.delegate!.pushNewTopic(newTopic: newTopic)
        }
    }
}
