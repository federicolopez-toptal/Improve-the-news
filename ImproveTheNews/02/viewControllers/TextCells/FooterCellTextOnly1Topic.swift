//
//  FooterCellTextOnly.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 29/04/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit


protocol FooterCellTextOnly1TopicDelegate {
    func share1TopicTapped(sender: FooterCellTextOnly1Topic)
}


class FooterCellTextOnly1Topic: UITableViewHeaderFooterView {

    var delegate: FooterCellTextOnly1TopicDelegate?
    @IBOutlet weak var shareIcon: UIButton!
    
    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = DARKMODE() ? bgBlue : bgWhite_LIGHT
        
        self.shareIcon.layer.cornerRadius = 0.5 * 55
        self.shareIcon.addTarget(self,
            action: #selector(shareIconTap(sender:)),
            for: .touchUpInside)
            
        if(!DARKMODE()) {
            for v in self.contentView.subviews {
                if(v.alpha < 1.0) {
                    v.backgroundColor = .black
                }
                
                if(v is UIImageView) {
                    (v as! UIImageView).image = UIImage(named: "ITN_logo_blackText.png")
                }
            }
        }
    }
    
    @objc func shareIconTap(sender: UIButton) {
        self.delegate?.share1TopicTapped(sender: self)
    }
    
}
