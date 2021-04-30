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
        
        self.contentView.backgroundColor = bgBlue
        self.contentLabel.textColor = articleHeadLineColor
        self.flagImageView.backgroundColor = bgBlue
        self.flagImageView.layer.cornerRadius = 10
        self.sourceLabel.textColor = articleSourceColor
        
        self.exclamationImageView.image = UIImage(systemName: "exclamationmark.triangle")
        self.exclamationImageView.tintColor = accentOrange
    }
    
}
