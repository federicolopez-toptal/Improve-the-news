//
//  customNavigationController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 01/12/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

class customNavigationController: UINavigationController {
    
    override init(rootViewController rootVC: UIViewController) {
        super.init(rootViewController: rootVC)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return DARKMODE() ? .lightContent : .darkContent
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
}
