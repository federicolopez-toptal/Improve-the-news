//
//  MiniSlidersView.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 23/03/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

// -----------------------------------
class MiniSlidersView: UIView {
    
    let dim: CGFloat = 35.0
    let thumbDim: CGFloat = 8.0
    
    let line1 = UIView(frame: CGRect.zero)
    let line2 = UIView(frame: CGRect.zero)
    
    let thumb1 = UIView(frame: CGRect.zero)
    let thumb2 = UIView(frame: CGRect.zero)

    // MARK: - Initialization
    init(some: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: dim, height: dim))
        self.backgroundColor = bgBlue
        
        line1.frame = CGRect(x: 3, y: 12, width: dim-12, height: 2)
        line1.backgroundColor = UIColor.init(hex: 0x4F5F8B)
        line1.layer.cornerRadius = 2
        self.addSubview(line1)
        
        line2.frame = CGRect(x: 3, y: 26, width: dim-12, height: 2)
        line2.backgroundColor = line1.backgroundColor
        line2.layer.cornerRadius = 2
        self.addSubview(line2)
        
        thumb1.frame = CGRect(x: 0, y: 0, width: thumbDim, height: thumbDim)
        thumb1.layer.cornerRadius = 4
        thumb1.backgroundColor = UIColor.init(hex: 0xDFE1D8)
        line1.addSubview(thumb1)
        thumb2.frame = CGRect(x: 0, y: 0, width: thumbDim, height: thumbDim)
        thumb2.layer.cornerRadius = 4
        thumb2.backgroundColor = UIColor.init(hex: 0xDFE1D8)
        line2.addSubview(thumb2)
        
        self.setValues(val1: 1, val2: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - misc
    func insertInto(view: UIView) {
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            self.heightAnchor.constraint(equalToConstant: dim),
            self.widthAnchor.constraint(equalToConstant: dim)
        ])
        self.layer.cornerRadius = 15
        self.layer.maskedCorners = [.layerMaxXMinYCorner]
    }
    
    func setValues(val1: Int, val2: Int) {
        var val: Int
        var posX: CGFloat
        var mFrame: CGRect
        
        val = Int.random(in: 1...5)
        mFrame = thumb1.frame
        mFrame.origin.y = -3
        mFrame.origin.x = ((line1.frame.size.width-(thumbDim/2))/5) * CGFloat((val-1))
        thumb1.frame = mFrame
        
        val = Int.random(in: 1...5)
        mFrame = thumb2.frame
        mFrame.origin.y = -3
        mFrame.origin.x = ((line2.frame.size.width-(thumbDim/2))/5) * CGFloat((val-1))
        thumb2.frame = mFrame
    }
    
}
