//
//  Alerts.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 07/04/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation
import UIKit


func ALERT(vc: UIViewController, title T: String, message M: String) {
    DispatchQueue.main.async {
        let alert = UIAlertController(title: T, message: M, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { action in
        }
        
        alert.addAction(okAction)
        vc.present(alert, animated: true) {
        }
    }
}

func ALERT(vc: UIViewController, title T: String, message M: String, callback: @escaping () -> ()) {
    let alert = UIAlertController(title: T, message: M, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ok", style: .default) { action in
        callback()
    }
    
    alert.addAction(okAction)
    vc.present(alert, animated: true) {
    }
}

func ALERT_YESNO(vc: UIViewController, title T: String, question Q: String, callback: @escaping (Bool) -> ()) {
    let alert = UIAlertController(title: T, message: Q, preferredStyle: .alert)
    
    let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
        callback(true)
    }
    let noAction = UIAlertAction(title: "No", style: .default) { action in
        callback(false)
    }
    
    alert.addAction(noAction)
    alert.addAction(yesAction)
    
    vc.present(alert, animated: true) {
    }
}


/*
static func logoutDialog(vc: UIViewController, header: String, question: String, callback: @escaping (Bool) -> ()) {
        let alert = UIAlertController(title: header, message: question, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
            callback(true)
        }
        let noAction = UIAlertAction(title: "No", style: .default) { action in
            callback(false)
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        vc.present(alert, animated: true) {
        }
    }
*/
