//
//  AppData.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 24/02/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation


class AppData {

    static var shared = AppData()
    
    var layout: LayoutType = .denseIntense
    //var displayMode: DisplayMode = .bright
    
}

// ------------------------------------------
enum LayoutType: String {
    case denseIntense = "Dense & intense"
    case bigBeautiful = "Big & beautiful"
    case textOnly = "Text only"
}

// ------------------------------------------
enum DisplayMode: String {
    case dark = "darkMode"
    case bright = "brightMode"
}

