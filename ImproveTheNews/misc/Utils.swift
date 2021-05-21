//
//  Utils.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 23/02/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit
import Foundation

class Utils {
    
    static var shared = Utils()




    // Some util flags across the app
    var didTapOnMoreLink = false
    
    // IDs for NewsViewController instances
    var newsViewController_ID = 0
    
    // Current layout
    var currentLayout = layoutType.denseIntense
    
    // Current display mode
    var displayMode: DisplayMode = .bright
}

func DARKMODE() -> Bool {
    if(Utils.shared.displayMode == .dark){ return true }
    return false
}


func DELAY(_ time: TimeInterval, callback: @escaping () ->() ) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
        callback()
    })
}


let LOCAL_KEY_LAYOUT = "userSelectedLayout"

func INITIAL_VC() -> UIViewController {
    
    let topic = "news"
    let layout: layoutType?
    
    if let userSelection = UserDefaults.standard.string(forKey: LOCAL_KEY_LAYOUT) {
        layout = layoutType(rawValue: userSelection)
    } else {
        layout = .denseIntense
    }
    
    Utils.shared.currentLayout = layout!
    if(layout == .denseIntense) {
        return NewsViewController(topic: topic)
    } else if(layout == .textOnly) {
        return NewsTextViewController(topic: topic)
    } else {
        return NewsBigViewController(topic: topic)
    }
}

func API_CALL(topicCode: String, abs: [Int], biasStatus: String,
                banners: String?, superSliders: String?) -> String {

    var link = "https://www.improvethenews.org/appserver.php/?topic=" + topicCode
    link += ".A\(abs[0]).B\(abs[1]).S\(abs[2])"
    link += SliderValues.sharedInstance.getBiasPrefs()
    
    for (_, code) in Globals.slidercodes {
        if let value = UserDefaults.standard.object(forKey: code) as? Float {
            var v = value.rounded()
            if(v > 99){ v = 99 }
            if(v >= 0){
                link += code + String(format: "%02d", Int(v))
            }
        }
    }
    link += biasStatus
    
    if(Utils.shared.currentLayout == .denseIntense) {
        link += "LA00"
    } else if(Utils.shared.currentLayout == .textOnly) {
        link += "LA10"
    } else {
        link += "LA20"
    }
    
    if let _B = banners {
        link += _B
    }
    
    if let _SL = superSliders {
        link += "_" + _SL
    }
    
    link += "&uid=3"
    if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
        var fixedID = deviceId.uppercased()
        fixedID = fixedID.replacingOccurrences(of: "-", with: "")
        fixedID = fixedID.replacingOccurrences(of: "A", with: "0")
        fixedID = fixedID.replacingOccurrences(of: "B", with: "1")
        fixedID = fixedID.replacingOccurrences(of: "C", with: "2")
        fixedID = fixedID.replacingOccurrences(of: "D", with: "3")
        fixedID = fixedID.replacingOccurrences(of: "E", with: "4")
        fixedID = fixedID.replacingOccurrences(of: "F", with: "5")
        
        // only 19 characters!
        if(fixedID.count > 19) {
            fixedID = String( fixedID[0...18] )
        }
        
        link += fixedID
    }
    
    link += "&v=I" + Bundle.main.releaseVersionNumber!
    link += "&dev=" + UIDevice.current.modelName.replacingOccurrences(of: " ", with: "_")
    
    return link
}
