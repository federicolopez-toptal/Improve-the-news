//
//  SourceCell.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 01/06/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit


protocol SourceCellDelegate {
    func onStateChange(state: Bool, index: Int)
}


class SourceCell: UITableViewCell {

    var index: Int = -1
    var delegate: SourceCellDelegate?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var asterik: UILabel!
    @IBOutlet weak var state: UISwitch!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.font = UIFont(name: "Poppins-Regular", size: 16)
        
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
    
    func highlight(_ state: Bool) {
        self.asterik.isHidden = !state
    }
    
    // MARK: - Event(s)
    @IBAction func onStateChange(_ sender: UISwitch) {
        self.delegate?.onStateChange(state: self.state.isOn, index: self.index)
    }
    
}
