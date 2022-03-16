//
//  AppDelegate.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 5/29/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        FirebaseApp.configure() // for Crashlytics
        Thread.sleep(forTimeInterval: 1.0)  // 1 sec delay to extend the launch screen duration
        
        // FB
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    
        return true
    }
    
    func application(_ app: UIApplication, open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        // FB
        ApplicationDelegate.shared.application(app, open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    
    
    
    var orientationLock = UIInterfaceOrientationMask.all
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    
        return self.orientationLock
    }

}




