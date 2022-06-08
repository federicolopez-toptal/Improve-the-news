//
//  SignInUpOrangeButton.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 07/06/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit

class SignInUpOrangeButton: UIButton {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.applyStyle()
    }
    
    private func applyStyle() {
        self.layer.cornerRadius = 20.0
    }

}
