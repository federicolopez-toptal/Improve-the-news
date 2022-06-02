//
//  SignInUpFormView.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 02/06/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

struct Line {
    var startPont : CGPoint
    var endPoint : CGPoint
}

class SignInUpFormFormView: UIView {

    var lines = [Line]()

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let strokeColor = DARKMODE() ? UIColor.white.withAlphaComponent(0.35) : UIColor.black.withAlphaComponent(0.15)
        
        for L in self.lines {
            context?.beginPath()
            context?.move(to: L.startPont)
            context?.addLine(to: L.endPoint)
            context?.setLineCap(CGLineCap.square)
            context?.setFillColor(UIColor.black.cgColor)
            context?.setStrokeColor(strokeColor.cgColor)
            context?.setLineWidth(10.0)
            context?.strokePath()
        }
    }

}
