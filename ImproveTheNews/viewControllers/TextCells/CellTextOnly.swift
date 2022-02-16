//
//  CellTextOnly.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 29/04/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

class CellTextOnly: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var exclamationImageView: UIImageView!
    @IBOutlet weak var miniSliderContainer: UIImageView!
    var miniSlidersView: MiniSlidersView?
    
    @IBOutlet weak var flagLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var sourceLeadingConstraint: NSLayoutConstraint!

    
    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = DARKMODE() ? bgBlue: bgWhite_LIGHT
        self.contentLabel.textColor = DARKMODE() ? articleHeadLineColor : darkForBright
        self.flagImageView.backgroundColor = bgBlue
        self.flagImageView.layer.cornerRadius = 10
        self.sourceLabel.textColor = DARKMODE() ? articleSourceColor : textBlackAlpha
        
        self.exclamationImageView.image = UIImage(systemName: "exclamationmark.triangle")
        self.exclamationImageView.tintColor = accentOrange
        
        if(!DARKMODE()) {
            self.contentView.subviews.last?.backgroundColor = .black
        }
        
        //self.contentLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
        //self.contentLabel.minimumScaleFactor = 0.5
        
        if(IS_ZOOMED()) {
            self.sourceLabel.font = UIFont(name: "Poppins-SemiBold", size: 11.5)
        }
        
        if(miniSlidersView == nil) {
            miniSlidersView = MiniSlidersView(some: "", factor: 1.0)
            miniSlidersView?.insertInto(view: self.miniSliderContainer)
        }
        miniSlidersView?.setValues(val1: 3, val2: 1)
    }
    
    func updateIconsVisible() {
        self.miniSliderContainer.isHidden = !MorePrefsViewController.showStanceInsets()
        self.flagImageView.isHidden = !MorePrefsViewController.showFlags()
        
        if(!self.miniSliderContainer.isHidden) {
            self.flagLeadingConstraint.constant = 16 + 30 + 5
        } else {
            self.flagLeadingConstraint.constant = 16
        }
        
        var sourceLeading: CGFloat = 16
        if(!self.flagImageView.isHidden){ sourceLeading += 18 }
        if(!self.miniSliderContainer.isHidden){ sourceLeading += 30 + 5 }
        sourceLeading += 8
        
        if(self.miniSliderContainer.isHidden && self.flagImageView.isHidden){ sourceLeading = 16 }
        self.sourceLeadingConstraint.constant = sourceLeading
        
        /*
        if(self.flagImageView.isHidden) {
            self.sourceLeadingConstraint.constant = 16.0
        } else {
            self.sourceLeadingConstraint.constant = 42.0
        }
        */
    }
    
}
