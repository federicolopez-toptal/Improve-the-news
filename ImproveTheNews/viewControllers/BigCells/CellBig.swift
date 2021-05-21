//
//  CellBig.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 12/05/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

class CellBig: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var exclamationImageView: UIImageView!
    @IBOutlet weak var mainPic: UIImageView!
    
    var miniSlidersView: MiniSlidersView?
    
    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = bgBlue
        self.contentLabel.textColor = articleHeadLineColor
        self.flagImageView.backgroundColor = bgBlue
        self.flagImageView.layer.cornerRadius = 10
        self.sourceLabel.textColor = articleSourceColor
        
        self.exclamationImageView.image = UIImage(systemName: "exclamationmark.triangle")
        self.exclamationImageView.tintColor = accentOrange
        
        self.mainPic.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        self.mainPic.layer.cornerRadius = 15
        self.mainPic.clipsToBounds = true
        
        if(APP_CFG_SHOW_MINI_SLIDERS) {
            if(miniSlidersView == nil) {
                miniSlidersView = MiniSlidersView(some: "", factor: 1.5)
                miniSlidersView?.insertInto(view: mainPic)
            }
            miniSlidersView?.setValues(val1: 3, val2: 1)
        }
    }
    
}
