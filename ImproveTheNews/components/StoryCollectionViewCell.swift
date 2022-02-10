//
//  StoryCollectionViewCell.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 19/01/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {
    
    static let cellId = "StoryCollectionViewCell"
    
    private let ICON_SIZE: CGFloat = 17.0
    private let ICON_SEP: CGFloat = 5.0
    
    let imageView = UIImageView(backgroundColor: .clear)
    let gradient = UIImageView(image: UIImage(named: "gradient_dark.png"))
    var icons = [UIImageView]()
    let updated = UILabel()
    var updatedLeadingConstraint: NSLayoutConstraint?
    let orangeArrow = UIImageView(image: UIImage(named: "updatedIcon.png"))
    let titleLabel = UILabel()
    let storySign = UILabel()
    
    let labelSplit1 = UILabel()
    let labelSplit2 = UILabel()
    
    private var validSources = [String]()
    private var showHeaders = false
    private var stanceValues = (false, false)
    
    func setupViews(sources: [String]) {
        StorySourceManager.shared.loadSources { (error) in
            self.validSources = StorySourceManager.shared.filterSources(toFilter: sources)
            
            DispatchQueue.main.async {
                self.setupViews_step2()
            }
        }
    }
        
    private func setupViews_step2() {
        // Image
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: 250)
        ])
        imageView.clipsToBounds = true
        
        // Gradient
        addSubview(gradient)
        if(!DARKMODE()){ gradient.image = UIImage(named: "gradient_light.png") }
        gradient.alpha = 0.98
        gradient.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradient.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            gradient.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            gradient.heightAnchor.constraint(equalToConstant: 175)
        ])

        // Icons
        if(icons.count > 0) {
            for i in icons {
                i.removeFromSuperview()
            }
            icons = [UIImageView]()
        }
        
        var iconsCountToShow = self.validSources.count
        var posX: CGFloat = 16.0
        
        if(iconsCountToShow>6){ iconsCountToShow = 6 }
        if(iconsCountToShow > 0) {
            for i in 1...iconsCountToShow {
                let _icon = UIImageView()
                _icon.backgroundColor = .white
                
                addSubview(_icon)
                _icon.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    _icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: posX),
                    _icon.topAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(STORIES_HEIGHT)-ICON_SIZE-15-17),
                    _icon.heightAnchor.constraint(equalToConstant: ICON_SIZE),
                    _icon.widthAnchor.constraint(equalToConstant: ICON_SIZE)
                ])
                
                let iconURL = StorySourceManager.shared.getIconForSource(self.validSources[i-1])
                
                if(!iconURL.contains(".svg")) {
                    _icon.sd_setImage(with: URL(string: iconURL), placeholderImage: nil)
                } else {
                    let filename = self.validSources[i-1] + ".png"
                    _icon.image = UIImage(named: filename)
                }
                
                
                posX += ICON_SIZE + ICON_SEP
                icons.append(_icon)
            }
        } else {
            let _icon = UIImageView()
            _icon.backgroundColor = .clear
                
            addSubview(_icon)
            _icon.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                _icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: posX),
                _icon.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -17),
                _icon.heightAnchor.constraint(equalToConstant: ICON_SIZE),
                _icon.widthAnchor.constraint(equalToConstant: 1.0)
            ])
                
            icons.append(_icon)
        }
        
        addSubview(updated)
        updated.textColor = UIColor(hex: 0x93A0B4)
        if(!DARKMODE()){ updated.textColor = UIColor(hex: 0x1D242F) }
        updated.text = "Last updated 30 min ago"
        updated.font = UIFont(name: "Roboto-Regular", size: 12)
        updated.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            updated.leadingAnchor.constraint(equalTo: icons.last!.trailingAnchor, constant: 10),
            updated.topAnchor.constraint(equalTo: icons.last!.topAnchor, constant: 2),
        ])
        
        // orange arrow
        addSubview(orangeArrow)
        orangeArrow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            orangeArrow.leadingAnchor.constraint(equalTo: updated.trailingAnchor, constant: 8),
            orangeArrow.topAnchor.constraint(equalTo: updated.topAnchor, constant: 3),
            orangeArrow.widthAnchor.constraint(equalToConstant: 14),
            orangeArrow.heightAnchor.constraint(equalToConstant: 8)
        ])
        
        // title
        addSubview(titleLabel)
        titleLabel.textColor = .white
        if(!DARKMODE()){ titleLabel.textColor = UIColor(hex: 0x1D242F) }
        titleLabel.font = UIFont(name: "Merriweather-Bold", size: 22)
        titleLabel.numberOfLines = 3
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.lineBreakMode = .byClipping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: icons.last!.topAnchor, constant: -10)
        ])
        
        // Story sign
        addSubview(storySign)
        storySign.text = "STORY"
        storySign.textAlignment = .center
        storySign.font = UIFont(name: "Roboto-Bold", size: 12)
        storySign.backgroundColor = UIColor(hex: 0xFF643C)
        if(!DARKMODE()){ storySign.backgroundColor = .white }
        storySign.textColor = .white
        if(!DARKMODE()){ storySign.textColor = UIColor(hex: 0x1D242F) }
        storySign.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            storySign.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            storySign.widthAnchor.constraint(equalToConstant: 57),
            storySign.heightAnchor.constraint(equalToConstant: 22),
            storySign.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -6)
        ])
        storySign.layer.cornerRadius = 11.0
        storySign.layer.masksToBounds = true
        
        // split 1
        addSubview(labelSplit1)
        labelSplit1.textColor = .white
        if(!DARKMODE()){ labelSplit1.textColor = textBlackAlpha }
        labelSplit1.font = UIFont(name: "PTSerif-Bold", size: 20)
        labelSplit1.numberOfLines = 1
        labelSplit1.textAlignment = .center
        labelSplit1.text = "ABC"
        labelSplit1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelSplit1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            labelSplit1.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2),
            labelSplit1.topAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(STORIES_HEIGHT))
        ])
        
        // split 2
        addSubview(labelSplit2)
        labelSplit2.textColor = .white
        if(!DARKMODE()){ labelSplit2.textColor = textBlackAlpha }
        labelSplit2.font = UIFont(name: "PTSerif-Bold", size: 20)
        labelSplit2.numberOfLines = 1
        labelSplit2.textAlignment = .center
        labelSplit2.text = "ABC"
        labelSplit2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelSplit2.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: UIScreen.main.bounds.width/2),
            labelSplit2.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2),
            labelSplit2.topAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(STORIES_HEIGHT))
        ])
        
        if(!self.showHeaders) {
            labelSplit1.textColor = .clear
            labelSplit2.textColor = .clear
        } else {
            labelSplit1.textColor = .white
            if(!DARKMODE()){ labelSplit1.textColor = textBlackAlpha }
            labelSplit2.textColor = labelSplit1.textColor
        
            if(stanceValues.0) {
                // POLITICAL
                labelSplit1.text = "LEFT"
                labelSplit2.text = "RIGHT"
            } else {
                // ESTABLISHMENT
                labelSplit1.text = "CRITICAL"
                labelSplit2.text = "PRO"
            }
        }
    }
    
    func hideHeaders() {
        self.showHeaders = false
    }
    
    func showHeaders(_ stanceValues: (Bool, Bool)) {
        self.showHeaders = true
        self.stanceValues = stanceValues
    }
    
}
