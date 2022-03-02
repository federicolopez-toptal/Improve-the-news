//
//  TabBarController.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 5/30/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        UITabBar.appearance().tintColor = accentOrange
        viewControllers = [createTabBarItem(title: "News", imageName: "news-32", viewController: NewsViewController(topic: "news"))]
        
    }
    
    private func createTabBarItem(title: String, imageName: String, viewController: UIViewController) -> UINavigationController {
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        
        return navController
    }
    
}
