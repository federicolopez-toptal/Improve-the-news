//
//  MarkupUser.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 30/06/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit
import Foundation



struct UserInfo {
    
    var id: Int
    var name: String
    var email: String
    var role: Int
    var notifications: Int

    init(json: [String: Any]) {
        self.id = Int(json["id"] as! String)!
        self.name = json["name"] as! String
        self.email = json["email"] as! String
        
        self.role = 0
        if let _strRole = json["role"] as? String {
            self.role = Int(_strRole)!
        }
        
        self.notifications = json["notifications"] as! Int
    }
}
// ---------------------------------



class MarkupUser {

    static var shared = MarkupUser()
    
    let url = "http://ec2-3-19-242-162.us-east-2.compute.amazonaws.com/Clean/api.php"
    var userInfo: UserInfo?

    func showActionSheet(_ vc: UIViewController) {
        if(self.userInfo==nil) {
            self.showActionSheetUnlogged(vc)
        } else {
            self.showActionSheetlogged(vc)
        }
    }
    
    private func showActionSheetlogged(_ vc: UIViewController) {
        let actionSheet = UIAlertController(title: "",
                                            message: "User actions",
                                            preferredStyle: .actionSheet)
                                            
        // LOG OUT
        let actionLogout = UIAlertAction(title: "Log out", style: .default) { (action) in
            self.logout(vc)
        }
        actionSheet.addAction(actionLogout)
        
        // CANCEL
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
        }
        actionSheet.addAction(cancel)
        
        vc.present(actionSheet, animated: true) {
        }
    }
     
    private func showActionSheetUnlogged(_ vc: UIViewController) {
        let actionSheet = UIAlertController(title: "",
                                            message: "User actions",
                                            preferredStyle: .actionSheet)
        
    // LOGIN
        let actionLogin = UIAlertAction(title: "Login", style: .default) { (action) in
            let newVC = AuthViewController()
            newVC.mode = .login
            vc.navigationController?.pushViewController(newVC, animated: true)
        }
        actionSheet.addAction(actionLogin)
    
    // REGISTRATION
        let actionReg = UIAlertAction(title: "Sign Up", style: .default) { (action) in
            let newVC = AuthViewController()
            newVC.mode = .registration
            vc.navigationController?.pushViewController(newVC, animated: true)
        }
        actionSheet.addAction(actionReg)
        
    // CANCEL
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
        }
        actionSheet.addAction(cancel)
        
        vc.present(actionSheet, animated: true) {
        }
    }

    func register(email: String, pass: String, name: String, callback: @escaping (Bool) -> () ) {
        let body = self.body(email: email, name: name, pass: pass)
        var request = self.request(reqUrl: self.url + "?type=register")
        request.httpBody = body.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                print("ERROR! " + _error.localizedDescription)
                callback(false)
            } else {
                let json = self.json(fromData: data)
                
                var errorAction = false
                if let _json = json {
                    if let _ = _json["notifications"] {
                        errorAction = false
                        self.userInfo = UserInfo(json: _json)
                    } else {
                        errorAction = true
                    }
                } else {
                    errorAction = true
                }

                callback(!errorAction)
            }
        }
        
        task.resume()
    }

    func login(email: String, pass: String, callback: @escaping (Bool) -> () ) {
        let body = self.body(email: email, name: "", pass: pass)
        var request = self.request(reqUrl: self.url + "?type=login")
        request.httpBody = body.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                print("ERROR! " + _error.localizedDescription)
                callback(false)
            } else {
                let json = self.json(fromData: data)
                
                var errorAction = false
                if let _json = json {
                    if let _ = _json["notifications"] {
                        errorAction = false
                        self.userInfo = UserInfo(json: _json)
                    } else {
                        errorAction = true
                    }
                } else {
                    errorAction = true
                }

                callback(!errorAction)
            }
        }
        
        task.resume()
    }
    
    func logout(_ vc: UIViewController) {
        let alert = UIAlertController(title: "Warning",
                        message: "Log out the current user?",
                        preferredStyle: .alert)
                        
            let noAction = UIAlertAction(title: "No", style: .default) { (alertAction) in
            }
            alert.addAction(noAction)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (alertAction) in
                self.userInfo = nil
                NotificationCenter.default.post(name: NOTIFICATION_UPDATE_NAVBAR,
                                                object: nil)
            }
            alert.addAction(yesAction)
            
            vc.present(alert, animated: true) {
            }
    }
    
    // --------------------------------------------------------------
    private func request(reqUrl: String) -> URLRequest {
        var request = URLRequest(url: URL(string: reqUrl)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        return request
    }
    
    private func body(email: String, name: String, pass: String) -> String {
        let _id = USER_ID()
        return "email=\(email)&name=\(name)&pass=\(pass)&usrid=\(_id)"
    }
    
    private func json(fromData data: Data?) -> [String: Any]? {
        if let _data = data {
            do{
                let json = try JSONSerialization.jsonObject(with: _data,
                                options: []) as? [String : Any]
                return json
            }catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    
}

