//
//  PrefCell.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 25/08/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

protocol PrefCellDelegate {
    func onStateChange(state: Bool, index: Int)
}


class PrefCell: UITableViewCell {

    var index: Int = -1
    var delegate: PrefCellDelegate?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var state: UISwitch!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.font = UIFont(name: "Poppins-Regular", size: 16)
        self.nameLabel.adjustsFontSizeToFitWidth = true
        self.nameLabel.backgroundColor = .clear
        
        if(DARKMODE()) {
            self.contentView.backgroundColor = .black
            self.nameLabel.textColor = .white
            self.lineView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        } else {
            self.contentView.backgroundColor = .white
            self.nameLabel.textColor = .black
            self.lineView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
        
        state.onTintColor = accentOrange
        if(DARKMODE()) {
            state.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            state.layer.cornerRadius = 16.0
        }
    }
    
    // MARK: - Event(s)
    @IBAction func onStateChange(_ sender: UISwitch) {
        self.delegate?.onStateChange(state: self.state.isOn, index: self.index)
    }
}
