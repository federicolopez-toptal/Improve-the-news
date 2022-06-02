//
//  SignInUpTextField.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 02/06/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit

class SignInUpTextField: UITextField {

    var textPadding = UIEdgeInsets(
        top: 0,
        left: 8,
        bottom: 0,
        right: 0
    )
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

}
