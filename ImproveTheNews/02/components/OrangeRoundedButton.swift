//
//  OrangeRoundedButton.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 30/08/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

class OrangeRoundedButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)
        self.backgroundColor = accentOrange
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 14)
        if(IS_ZOOMED()){ self.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 12) }
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 25
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
