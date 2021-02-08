//
//  CustomSlider.swift
//  ImproveTheNews
//
//  Created by Actmobile on 16/11/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

class CustomSlider : UISlider {
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var new = CGRect(x: rect.origin.x, y: (rect.origin.y - 15), width: rect.size.width, height: (rect.size.height + 30))
        return super.thumbRect(forBounds: bounds, trackRect: new, value: value).insetBy(dx: 10, dy: 10)
    }
}
