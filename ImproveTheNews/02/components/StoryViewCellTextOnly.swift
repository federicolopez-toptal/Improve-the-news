//
//  StoryViewCellTextOnly.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 25/01/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit

class StoryViewCellTextOnly: UITableViewCell {

    static let cellId = "StoryViewCellTextOnly"

    private let ICON_SIZE: CGFloat = 17.0
    private let ICON_SEP: CGFloat = 5.0
    
    var icons = [UIImageView]()
    let updated = UILabel()
    var updatedLeadingConstraint: NSLayoutConstraint?
    let orangeArrow = UIImageView(image: UIImage(named: "updatedIcon.png"))
    let titleLabel = UILabel()
    let storySign = UILabel()
    let bgView = UIView()
    
    private var validSources = [String]()
    
    
    func setupViews(sources: [String]) {
        self.contentView.backgroundColor = DARKMODE() ? bgBlue : bgWhite_LIGHT
        self.selectionStyle = .none
    
        StorySourceManager.shared.loadSources { (error) in
            self.validSources = StorySourceManager.shared.filterSources(toFilter: sources)
            
            DispatchQueue.main.async {
                self.setupViews_step2()
            }
        }
    }
        
    private func setupViews_step2() {
        
        addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bgView.topAnchor.constraint(equalTo: topAnchor),
            bgView.heightAnchor.constraint(equalToConstant: 140)
        ])
        bgView.backgroundColor = DARKMODE() ? UIColor(hex: 0x1D2530) : UIColor(hex: 0xE9EAEB)
        
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
                    _icon.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4-20),
                    _icon.heightAnchor.constraint(equalToConstant: ICON_SIZE),
                    _icon.widthAnchor.constraint(equalToConstant: ICON_SIZE)
                ])
                
                let iconURL = StorySourceManager.shared.getIconForSource(self.validSources[i-1])
                
                if(iconURL.isEmpty) {
                    _icon.image = nil
                } else if(!iconURL.contains(".svg")) {
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
                _icon.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4-20),
                _icon.heightAnchor.constraint(equalToConstant: ICON_SIZE),
                _icon.widthAnchor.constraint(equalToConstant: 1.0)
            ])
                
            icons.append(_icon)
        }
        
        addSubview(updated)
        updated.textColor = UIColor(hex: 0x93A0B4)
        if(!DARKMODE()){ updated.textColor = UIColor(hex: 0x1D242F) }
        //updated.text = "Last updated 30 min ago"
        updated.font = UIFont(name: "Roboto-Regular", size: 12)
        updated.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            updated.leadingAnchor.constraint(equalTo: self.icons.last!.trailingAnchor, constant: 10),
            updated.topAnchor.constraint(equalTo: icons.last!.topAnchor, constant: 2)
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
        titleLabel.font = UIFont(name: "Merriweather-Bold", size: 20)
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75
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
        
        //self.sendSubviewToBack(bgView)
    }

}
