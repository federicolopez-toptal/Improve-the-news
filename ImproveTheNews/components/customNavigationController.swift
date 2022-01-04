//
//  customNavigationController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 01/12/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

// https://sanzeevgautam.medium.com/preferredstatusbarstyle-not-called-in-swift-eefae1f10262

class customNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers([INITIAL_VC()], animated: false)
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    
    /*
    override init(rootViewController rootVC: UIViewController) {
        super.init(rootViewController: rootVC)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
        
    }
    
    // StatusBar Style
    override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    */
    
    
    
    
    
    
    
    
    /*
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
     
    override var viewControllers: [UIViewController] {
        didSet { setNeedsStatusBarAppearanceUpdate() }
    }
    */
}
