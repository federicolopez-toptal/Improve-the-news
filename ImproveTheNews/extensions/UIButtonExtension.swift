//
//  UIButtonExtension.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 06/04/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension UIButton {

    

    func setCustomAttributedTextColor(_ color: UIColor) {
        let text = self.titleLabel!.text!
        let font = self.titleLabel!.font!
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
    func setCustomAttributedText(_ text: String) {
        let font = self.titleLabel!.font!
        let color = self.titleLabel!.textColor!
    
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
    
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
    func setCustomAttributedText(_ text: String, color: UIColor) {
        let font = self.titleLabel!.font!        

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
    
        self.setAttributedTitle(attributedString, for: .normal)
    }

}
