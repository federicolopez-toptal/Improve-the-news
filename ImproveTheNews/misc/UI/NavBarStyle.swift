//
//  NavBarStyle.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 11/04/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

func SETUP_NAVBAR(viewController: UIViewController, homeTap: Selector, menuTap: Selector,
    searchTap: Selector, userTap: Selector) {
        
        let searchBar = SEARCH_BAR(fromViewController: viewController)
        let uniqueID = UNIQUE_ID(fromViewController: viewController)
        
        searchBar.sizeToFit()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.textColor = .black
        searchBar.tintColor = .black

        if(viewController.navigationController == nil){ return }

        let navController = viewController.navigationController!
        navController.navigationBar.prefersLargeTitles = false
        navController.navigationBar.barTintColor = DARKMODE() ? bgBlue_DARK : bgWhite_DARK
        navController.navigationBar.isTranslucent = false

        let _textColor = DARKMODE() ? UIColor.white : textBlack
        let _attributes = [NSAttributedString.Key.font: UIFont(name: "PlayfairDisplay-SemiBold", size: 26)!, NSAttributedString.Key.foregroundColor: _textColor]
        navController.navigationBar.titleTextAttributes = _attributes

        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = DARKMODE() ? bgBlue_DARK : bgWhite_DARK
            appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PlayfairDisplay-SemiBold", size: 26)!, NSAttributedString.Key.foregroundColor: _textColor]
            
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = navController.navigationBar.standardAppearance
        }
        
        var leftButtons = [UIBarButtonItem]()
        var rightButtons = [UIBarButtonItem]()
        
        
        



        if(uniqueID == 1) {
            // LEFT
            let hamburgerButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "hamburger"),
            style: .plain, target: viewController, action: menuTap)
            
            leftButtons.append(hamburgerButton)
        }
        
        // RIGHT
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search,
            target: viewController, action: searchTap)
            
        rightButtons.append(searchButton)
        
        if(APP_CFG_MY_ACCOUNT) {
            let userImage = UIImage(systemName: "person")
            let userButton = UIBarButtonItem(image: userImage, style: .plain,
                target: viewController, action: userTap)
            userButton.imageInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
            
            rightButtons.append(userButton)
        }
        
        
        viewController.navigationItem.leftBarButtonItems = leftButtons
        viewController.navigationItem.rightBarButtonItems = rightButtons
        //viewController.navigationItem.leftBarButtonItem = sectionsButton
        viewController.navigationItem.leftItemsSupplementBackButton = true
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain,
            target: nil, action: nil)
        
        var logoFile = "ITN_logo.png"
        if(!DARKMODE()){ logoFile = "ITN_logo_blackText.png" }

        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 195, height: 30))
        let img = UIImage(named: logoFile)?.withRenderingMode(.alwaysOriginal)
        let homeButton = UIButton(image: img!)
        homeButton.frame = CGRect(x: 0, y: 0, width: 195, height: 30)
        homeButton.addTarget(viewController, action: homeTap, for: .touchUpInside)
                           
        
        if(IS_ZOOMED() && uniqueID>1) {
            let f: CGFloat = 0.85
            homeButton.frame = CGRect(x: 0, y: 0,
                    width: 195 * f, height: 30 * f)
        }
        
        if(APP_CFG_MY_ACCOUNT && uniqueID==1) {
            var mFrame = homeButton.frame
            mFrame.origin.x += 20
            homeButton.frame = mFrame
        }

        view.addSubview(homeButton)
        //view.center = navigationItem.titleView!.center
        viewController.navigationItem.titleView = view

}


private func SEARCH_BAR(fromViewController vc: UIViewController) -> UISearchBar {
    if(vc is NewsViewController) {
        return (vc as! NewsViewController).searchBar
    } else if(vc is NewsTextViewController) {
        return (vc as! NewsTextViewController).searchBar
    } else {
        return (vc as! NewsBigViewController).searchBar
    }
}

private func UNIQUE_ID(fromViewController vc: UIViewController) -> Int {
    if(vc is NewsViewController) {
        return (vc as! NewsViewController).uniqueID
    } else if(vc is NewsTextViewController) {
        return (vc as! NewsTextViewController).uniqueID
    } else {
        return (vc as! NewsBigViewController).uniqueID
    }
}
