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
    }
    
}
