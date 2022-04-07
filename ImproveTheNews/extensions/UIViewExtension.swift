//
//  UIViewExtension.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 07/04/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func getCustomViewWithTag(_ tag: Int) -> UIView? {
        var result: UIView?
        
        for V in self.subviews {
            if(V.tag==tag) {
                result = V
                break
            }
        }
        
        return result
    }
    
}
