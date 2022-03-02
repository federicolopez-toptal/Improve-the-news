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
    var button = UIButton(title: "topic", titleColor: accentOrange, font: UIFont(name: "PTSerif-Bold", size: 18)!, backgroundColor: .darkGray, target: self, action: #selector(goToTopic(_:)))
    
    // ------------------------------------------
    // ITN Footer
    let view = UIView()
    var middle = UIView()
    
    var shareDelegate: shareDelegate?
    let titleImage = UIImageView(image: UIImage(named: "ITN_logo.png"))
    
    let title = UILabel(text: "Improve the News", font: .boldSystemFont(ofSize: 20), textColor: .label, textAlignment: .center, numberOfLines: 1)
    let about = UILabel()
    let copyright = UILabel()
    
    let str = "A non-profit news aggregator helping you break out of your filter bubble"
    
    let shareBubble = UILabel(text: "Share with a friend", font: UIFont(name: "OpenSans-Regular", size: 12), textColor: .secondaryLabel, textAlignment: .center, numberOfLines: 1)
    
    let shareIcon = UIButton(image: UIImage(systemName: "square.and.arrow.up")!)
    // ------------------------------------------
    
    public func configure2() {

        self.titleImage.image = UIImage(named: "ITN_logo_blackText.png")
        if(DARKMODE()) {
            self.titleImage.image = UIImage(named: "ITN_logo.png")
        }

        addSubview(view)
        view.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        view.addSubview(title)
        view.addSubview(titleImage)
        titleImage.backgroundColor = .clear
        titleImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            titleImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            titleImage.widthAnchor.constraint(equalToConstant: 195),
            titleImage.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        line.backgroundColor = DARKMODE() ? articleSourceColor : textBlackAlpha
        view.addSubview(line)
        
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            line.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            line.topAnchor.constraint(equalTo: view.topAnchor),
            line.heightAnchor.constraint(equalToConstant: 1.0)
        ])
        
        
        
        
        about.textAlignment = .left
        about.text = str
        about.font = UIFont(name: "OpenSans-Regular", size: 11)
        about.textColor = DARKMODE() ? UIColor(rgb: 0x737D96) : textBlack
        about.numberOfLines = 18
        about.adjustsFontSizeToFitWidth = true
        about.sizeToFit()
        
        view.addSubview(about)
        about.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            about.topAnchor.constraint(equalTo: titleImage.bottomAnchor, constant: 15),
            about.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            //about.heightAnchor.constraint(equalToConstant: 44),
            about.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width-30)
        ])
        about.backgroundColor = .clear
        
        copyright.textAlignment = .left
        //copyright.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        copyright.text = "© 2021 Improve The News Foundation - All Rights Reserved"
        copyright.font = UIFont.systemFont(ofSize: 11)
        copyright.textColor = DARKMODE() ? UIColor(rgb: 0x737D96) : textBlack
        copyright.numberOfLines = 2
        copyright.adjustsFontSizeToFitWidth = true
        copyright.sizeToFit()
        
        view.addSubview(copyright)
        copyright.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            copyright.topAnchor.constraint(equalTo: about.bottomAnchor, constant: 8),
            copyright.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            //copyright.heightAnchor.constraint(equalToConstant: 30),
            copyright.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width-30)
        ])
        copyright.backgroundColor = .clear

        
        view.addSubview(shareIcon)
        shareIcon.tintColor = UIColor.white
        shareIcon.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        shareIcon.backgroundColor = accentOrange
        shareIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareIcon.topAnchor.constraint(equalTo: copyright.bottomAnchor, constant: 15),
            shareIcon.heightAnchor.constraint(equalToConstant: 55),
            shareIcon.widthAnchor.constraint(equalToConstant: 55),
            shareIcon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
        shareIcon.layer.cornerRadius = 0.5 * 55
    }
    
    @objc func sharePressed(_ sender: UIButton!) {
        let links = ["http://www.improvethenews.org/"]
        shareDelegate?.openSharing(items: links)
    }
    
    
    public func configure() {
        middle.backgroundColor = .clear
        addSubview(middle)
        middle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            middle.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            middle.topAnchor.constraint(equalTo: self.topAnchor, constant: 20 + 4),
            middle.widthAnchor.constraint(equalToConstant: 10),
            middle.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        label.text = "More"
        label.font = UIFont(name: "PTSerif-Bold", size: 18)
        label.textColor = DARKMODE() ? articleSourceColor : textBlackAlpha
        label.sizeToFit()
        label.backgroundColor = .clear
        /*
            var mFrame = label.frame
            mFrame.origin.x = (UIScreen.main.bounds.width/2) - mFrame.size.width
            mFrame.origin.y = 20 + 4
            label.frame = mFrame
        addSubview(label)
        */
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: middle.leadingAnchor),
            label.topAnchor.constraint(equalTo: middle.topAnchor)
        ])
        
        button.sizeToFit()
        button.backgroundColor = .clear
        
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: middle.trailingAnchor),
            button.topAnchor.constraint(equalTo: middle.topAnchor, constant: -6)
        ])
        
        /*
            mFrame = button.frame
            mFrame.origin.x = (UIScreen.main.bounds.width/2)
            mFrame.origin.y = 13 + 5
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
        */

        addTopBorder()
        self.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
    }
    
    func addTopBorder() {
        let border = UIView(frame: CGRect(x: 10, y: 5,
                            width: self.frame.width - 20, height: 1))
        
                            
        border.backgroundColor = DARKMODE() ? articleSourceColor : textBlackAlpha
        addSubview(border)
        
        border.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            border.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            border.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            border.heightAnchor.constraint(equalToConstant: 1.0)
        ])
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
