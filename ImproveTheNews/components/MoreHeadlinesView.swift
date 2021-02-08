//
//  MoreHeadlinesView.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 08/02/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

class MoreHeadlinesView: UIView {

    private var scrollView = UIScrollView()

    // MARK: - Init
    func initialize(frame: CGRect) {
        /*
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 40, width: bounds.width, height: 50))
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.flashScrollIndicators()
        */
        
        self.frame = frame
        self.backgroundColor = .red
    }
    
    
}
