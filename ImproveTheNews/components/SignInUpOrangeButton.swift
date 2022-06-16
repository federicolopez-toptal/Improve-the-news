//
//  SignInUpOrangeButton.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 07/06/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit

class SignInUpOrangeButton: UIButton {

    var orangeTitle: String?
    var grayTitle: String?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.applyStyle()
    }
    
    private func applyStyle() {
        self.layer.cornerRadius = 20.0
    }
    
    
    
    
    func setAsGray() {
        DispatchQueue.main.async {
            self.backgroundColor = UIColor.gray
            if let _title = self.grayTitle {
                self.setCustomAttributedText(_title)
            }
        }
    }
    
    func setAsOrange() {
        DispatchQueue.main.async {
            self.backgroundColor = UIColor(hex: 0xF3643C)
            if let _title = self.orangeTitle {
                self.setCustomAttributedText(_title)
            }
        }
    }

}
