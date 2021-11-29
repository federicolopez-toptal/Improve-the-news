//
//  ShareSplitArticleCell.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 25/11/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit
import SDWebImage

protocol ShareSplitArticleCellDelegate {
    func cellWasChecked(list: Int, index: Int, state: Bool)
}


class ShareSplitArticleCell: UITableViewCell {

    var delegate: ShareSplitArticleCellDelegate?

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    
    private var index: Int = -1
    private var list: Int = -1
    
    private var checked = false
    @IBOutlet weak var checkButton: UIButton!
    
    
    
    
    func setIndex(_ index: Int) {
        self.index = index
    }
    
    func setList(_ list: Int) {
        self.list = list
    }
    
    func update(img: String, text: String, countryID: String, source: String, state: Bool) {
        self.selectionStyle = .none
        self.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
    
        self.thumbImageView.backgroundColor = .darkGray
        self.thumbImageView.layer.cornerRadius = 15
        self.thumbImageView.clipsToBounds = true
        self.thumbImageView.contentMode = .scaleAspectFill
        self.thumbImageView.sd_setImage(with: URL(string: img), placeholderImage: nil)
        
        self.titleLabel.text = text
        self.titleLabel.backgroundColor = self.backgroundColor
        self.titleLabel.textColor = DARKMODE() ? articleHeadLineColor : darkForBright
        
        self.sourceLabel.text = source
        self.sourceLabel.backgroundColor = self.backgroundColor
        self.sourceLabel.textColor = DARKMODE() ? articleSourceColor : textBlackAlpha
        
        self.flag.backgroundColor = self.thumbImageView.backgroundColor
        self.flag.layer.cornerRadius = 10.0
        self.flag.image = GET_FLAG(id: countryID)
        
        self.checked = state
        self.updateCheck()
    }
    
    func updateCheck() {
        self.checkButton.setTitle("", for: .normal)
        self.checkButton.layer.cornerRadius = 10.0
        
        var img = UIImage(systemName: "checkmark.square")
        self.checkButton.tintColor = .orange
        if(!self.checked) {
            img = UIImage(systemName: "square")
            self.checkButton.tintColor = .white
        }
        self.checkButton.setImage(img, for: .normal)
    }
    
    private func GET_FLAG(id: String) -> UIImage {
        var result = UIImage(named: "\(id.uppercased())64.png")
        if(result==nil) {
            result = UIImage(named: "noFlag.png")
        }
        return result!
    }
    
    @IBAction func checkButtonOnTap(_ sender: UIButton) {
        self.delegate?.cellWasChecked(list: self.list, index: self.index, state: !self.checked)
    }
    
    
    
    
    
    
    
    func setChecked(_ value: Bool) {
        self.checked = value
        self.updateCheck()
    }
    
    func setChecked2(_ value: String) {
        self.titleLabel.text = value
    }
}
