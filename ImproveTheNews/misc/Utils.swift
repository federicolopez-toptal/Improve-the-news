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

    // main navigatorController
    //var navController: UINavigationController?
    var navController: customNavigationController?
    
    var didLoadBanner: Bool = false
    var lastApiCall: String = ""
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


func GET_TOPICARTICLESCOUNT(from vc: UIViewController) -> (String, Int) {
    var topic = ""
    var count = 0
    
    if(vc is NewsViewController) {
        topic = (vc as! NewsViewController).topic
        count = (vc as! NewsViewController).param_A
    } else if(vc is NewsTextViewController) {
        topic = (vc as! NewsTextViewController).topic
        count = (vc as! NewsTextViewController).param_A
    } else if(vc is NewsBigViewController) {
        topic = (vc as! NewsBigViewController).topic
        count = (vc as! NewsBigViewController).param_A
    }
    
    return (topic, count)
}




let LOCAL_KEY_LAYOUT = "userSelectedLayout"
let LOCAL_KEY_DISPLAYMODE = "userSelectedDisplayMode"


func INITIAL_VC() -> UIViewController {
    
    let topic = "news"
    
    let displayMode: DisplayMode?
    if let userDisplayMode = UserDefaults.standard.string(forKey: LOCAL_KEY_DISPLAYMODE) {
        displayMode = DisplayMode(rawValue: userDisplayMode)
    } else {
        displayMode = .dark
    }
    Utils.shared.displayMode = displayMode!
    
    var layout: layoutType?
    if let userLayout = UserDefaults.standard.string(forKey: LOCAL_KEY_LAYOUT) {
        layout = layoutType(rawValue: userLayout)
    } else {
        layout = .denseIntense
    }
    
    if(SHOW_ONBOARD()) {
        layout = .denseIntense
        UserDefaults.standard.set(layout!.rawValue, forKey: LOCAL_KEY_LAYOUT)
        UserDefaults.standard.synchronize()
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

func SHOW_ONBOARD() -> Bool {
    if let onBoardingValue = UserDefaults.standard.string(forKey: ONBOARDING_ID) {
        return false
    } else {
        return true
    }
    
    //return true
}

func OB_PARAM() -> String {
    if let OB = UserDefaults.standard.string(forKey: "OBparam") {
        return OB
    } else {
        return "oB10"
    }
}
func SET_OB_PARAM(_ value: String) {
    UserDefaults.standard.set(value, forKey: "OBparam")
    UserDefaults.standard.synchronize()
}

func API_BASE_URL() -> String {
    let dict = Bundle.main.infoDictionary!
    return dict["API_BASE_URL"] as! String
}

func API_CALL(topicCode: String, abs: [Int], biasStatus: String,
                banners: String?, superSliders: String?) -> String {

    //var link = "https://www.improvethenews.org/appserver.php/?topic=" + topicCode
    //var link = "https://www.improvemynews.com/appserver.php/?topic=" + topicCode
    
    var link = API_BASE_URL() + "/appserver.php/?topic=" + topicCode
    
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
    
    var displayMode = "0"
    if(!DARKMODE()){ displayMode = "1" }
    
    if(Utils.shared.currentLayout == .denseIntense) {
        link += "LA0" + displayMode
    } else if(Utils.shared.currentLayout == .textOnly) {
        link += "LA1" + displayMode
    } else {
        link += "LA2" + displayMode
    }
    
    if(MorePrefsViewController.showStories()) { // Stories
        link += "ST01"
    } else {
        link += "ST00"
    }
    
    if let _B = banners {
        link += _B
    }
    
    
    if(APP_CFG_SHOW_SOURCES) {
        if let sourcePrefs = UserDefaults.standard.string(forKey: KEY_SOURCES_PREFS) {
            link += sourcePrefs.replacingOccurrences(of: ",", with: "")
        }
    }
    
    
    if let _SL = superSliders {
        link += "_" + _SL
    }
    link += OB_PARAM()
    
    link += "&uid=" + USER_ID()
    /*
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
    */
    
    link += "&v=I" + Bundle.main.releaseVersionNumber!
    link += "&dev=" + UIDevice.current.modelName.replacingOccurrences(of: " ", with: "_")
    
    Utils.shared.lastApiCall = link
    return link
}

func USER_ID() -> String {
    var result = "3"
    let limit = 19
    
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
        if(fixedID.count > (limit-1)) {
            fixedID = String( fixedID[0...(limit-2)] )
        }
        result += fixedID
    }
    return result
}

// MARK: - Validations
func VALIDATE_EMAIL(_ email:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

func VALIDATE_NAME(_ name: String) -> Bool {
    if(name.isEmpty) {
        return false
    } else {
        if(name.count<3) {
            return false
        } else {
            return true
        }
    }
}

func VALIDATE_PASS(_ pass: String) -> Bool {
    if(pass.isEmpty) {
        return false
    } else {
        if(pass.count<4) {
            return false
        } else {
            return true
        }
    }
}

func IS_ZOOMED() -> Bool {

    let screen = UIScreen.main
    return screen.scale < screen.nativeScale
    
    /*
    if(screen.scale > screen.nativeScale) {
        return true
    } else {
        return false
    }
    */
   
}

func RND(range: ClosedRange<Int>) -> Int {
    return Int.random(in: range)
}


func HAPTIC_CLICK() {
    HAPTIC(type: 4)
}
func HAPTIC_LONGPRESS() {
    HAPTIC(type: 2)
}

func HAPTIC(type: Int) {
    //print("Haptic", type)

    if(type<4) {
        var _type: UINotificationFeedbackGenerator.FeedbackType = .success
        if(type==2){ _type = .error }
        else if(type==3){ _type = .warning }
        
        UINotificationFeedbackGenerator().notificationOccurred(_type)
    } else if(type<8) {
        var _type: UIImpactFeedbackGenerator.FeedbackStyle = .light
        if(type==4){ _type = .medium }
        else if(type==5){ _type = .heavy }
        else if(type==6){ _type = .rigid }
        else if(type==7){ _type = .soft }
        
        UIImpactFeedbackGenerator(style: _type).impactOccurred()
    } else {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    
}

func STATUS_BAR_STYLE() -> UIStatusBarStyle {
    return DARKMODE() ? .lightContent : .darkContent
}

func STATUS_BAR_STYLE_opposite() -> UIStatusBarStyle {
    return DARKMODE() ? .darkContent : .lightContent
}

/*
func STATUS_BAR_UPDATE() {
    if let nav = Utils.shared.navController {
        nav.navigationBar.barStyle = DARKMODE() ? .black : .default
    }
}
*/
