//
//  CustomNavigationController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 01/12/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers([INITIAL_VC()], animated: false)
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    
    override var shouldAutorotate: Bool {
        if(IS_iPHONE()){ return false }
        else { return true }
    }
    
}
