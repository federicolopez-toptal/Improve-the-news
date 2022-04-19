//
//  UserIdGeneration.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 12/04/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation
import UIKit


func USER_ID() -> String {
    
    if(APP_CFG_NEW_USERID) {
    
        // ***************************
        let api = ShareAPI.instance
        if let _uuid = api.uuid {
            return _uuid
        } else {
            if(!api.isGenerating) {
                api.generate()
            }
            return USER_ID__rnd()
        }
        // ***************************
        
    } else {
        return USER_ID__rnd()
    }
    
}

func USER_ID__rnd() -> String {
    let key = "USER_ID Random"
    
    if let _value = ShareAPI.readStringKey(key) {
        return _value
    } else {
        var randomNums = "3" // 3 for "iOS"
        for _ in 1...18 {
            let n = Int.random(in: 0...9)
            randomNums += String(n)
        }
        ShareAPI.writeKey(key, value: randomNums)
        //ShareAPI.LOG(where: "UserIdRandom", msg: randomNums + " was generated")
        return randomNums
    }
}

private func USER_ID__old() -> String {
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

private func USER_ID__manual() -> String {
    //return "3635054325517420005" //1
    return "3596010244403483218" //2
}
