//
//  ShareAPI.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 10/03/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

/*
    By Armin

    Share documentation (google), by Armin
    https://docs.google.com/document/d/169RXt9wfP2wRuhahih-ENLMYWOyiRFWQL5JxNjEN8Pg/edit?usp=sharing
    
    ITN/Users in Postman
    https://improvethenews.postman.co/workspace/ITN~f8d0bd51-4fd7-4c26-b0b6-b92918b59356/request/10024638-52b1da78-1828-4545-a907-4212d29c498e
    
    ITN/Users documentation in Postman
    https://improvethenews.postman.co/workspace/ITN~f8d0bd51-4fd7-4c26-b0b6-b92918b59356/documentation/10024638-aa08b708-8f07-4072-84dc-21b494f63933?entity=folder-76a099f4-63bd-4305-87aa-19767513333c
*/

class ShareAPI {

    static let instance = ShareAPI()
    
    private let keySHARE_uuid = "SHARE_uuid"
    private let keySHARE_jwt = "SHARE_jwt"
    private let keySHARE_bearerAuth = "SHARE_bearerAuth"

    private var bearerAuth = ""
    public var isGenerating = false

    var uuid: String? {
        return ShareAPI.readStringKey(keySHARE_uuid)
    }


    private func getBearerAuth() -> String {
        return ShareAPI.readStringKey(keySHARE_bearerAuth)!
    }

    // ************************************************************ //
    func generate() {
        self.isGenerating = true
        let here = "Generate"
        let url = API_BASE_URL() + "/php/api/user/"
        
        let bodyJson: [String: String] = [
            "type": "Generate",
            "userId": USER_ID_RND(),
            "app": "iOS"
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
                if let json = ShareAPI.json(fromData: data) {
                    if let _jwt = json["jwt"] as? String, let _uuid = json["uuid"] as? String {
                        
                        ShareAPI.LOG(where: here, msg: "got uuid from server: " + _uuid)
                        
                        ShareAPI.writeKey(self.keySHARE_uuid, value: _uuid)
                        ShareAPI.writeKey(self.keySHARE_jwt, value: _jwt)
                        
                        let _bearer = "Bearer " + _jwt
                        ShareAPI.writeKey(self.keySHARE_bearerAuth, value: _bearer)
                    } else {
                        ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
                    }
                } else {
                    ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
                }
            }
            self.isGenerating = false
        }
        task.resume()
        
    }
    /*
    RESPONSE example
    
    {"jwt":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE2NDg3NTE3MDEsImp0aSI6IjFGajlWXC9LcUtsaHB0XC9PMnpudFBTQT09IiwiaXNzIjoiaW1wcm92ZXRoZW5ld3Mub3JnIiwibmJmIjoxNjQ4NzUxNzAxLCJleHAiOjI5NjM3NTk3MDEsImRhdGEiOnsidXNyaWQiOiIzNTAxODQwMDE2OTg1Mzk0MTE1In19.itVlxjouwB9aPwHsJUQYO_EyEFBZzmPg-RedpfYZfWj3UkaJf6HZlK85o6J60Dff_UekoMuMSJy9TpiAAYbiEw","uuid":"3501840016985394115"}
    */
    
    // ************************************************************ //
    func login(type: String, accessToken: String, callback: @escaping (Bool) -> ()) { // (success)
        let here = "Login"
        let url = API_BASE_URL() + "/php/api/user/"
        
        let bodyJson: [String: String] = [
            "type": type,
            "userId": USER_ID(),
            "access_token": accessToken
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(getBearerAuth(), forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
            
                if let json = ShareAPI.json(fromData: data) {
                    if let _jwt = json["jwt"] as? String { // let _uuid = json["uuid"]
                        ShareAPI.LOG(where: here, msg: type + " success")
                        ShareAPI.writeKey(self.keySHARE_jwt, value: _jwt)
                        callback(true)
                    } else {
                        ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
                        callback(false)
                    }
                } else {
                    ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
                    callback(false)
                }
            }
        }
        task.resume()
    }
    
    /*
    RESPONSE example
    
    {"uuid":"3501840016985394115","socialnetworks":["Facebook"],"message":"OK","slidercookies":null,"jwt":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE2NDg3NTIxMDcsImp0aSI6InQ5a0dYSmpjY3ArbHFwd1ZSNUw3Znc9PSIsImlzcyI6ImltcHJvdmV0aGVuZXdzLm9yZyIsIm5iZiI6MTY0ODc1MjEwNywiZXhwIjoyOTYzNzYwMTA3LCJkYXRhIjp7InVzcmlkIjoiMzUwMTg0MDAxNjk4NTM5NDExNSJ9fQ.4DXgJmXCjzBPKvGCD-w8dN8dg2WlRGL4RjzA7xXkUePgLElPdJ2gqBd2pDzWhu87JaIcHjBVCZLuZyyea6hzrA"}
    */
    
    // ************************************************************ //
    func login_TW(token: String, verifier: String, callback: @escaping (Bool) -> ()) {
        let type = "Twitter"
        let here = "Login"
        let url = API_BASE_URL() + "/php/api/user/"
        
        let bodyJson: [String: String] = [
            "type": type,
            "userId": USER_ID(),
            "access_token": token,
            "secret_token": verifier
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(getBearerAuth(), forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
            
                if let json = ShareAPI.json(fromData: data) {
                    if let _jwt = json["jwt"] as? String { // let _uuid = json["uuid"]
                        ShareAPI.LOG(where: here, msg: type + " success")
                        ShareAPI.writeKey(self.keySHARE_jwt, value: _jwt)
                        callback(true)
                    } else {
                        ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
                        callback(false)
                    }
                } else {
                    ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
                    callback(false)
                }
            }
        }
        task.resume()
    }
    
    // ************************************************************ //
    func disconnect(type: String) { // (success)
        let url = API_BASE_URL() + "/php/api/user/"
        
        let bodyJson: [String: String] = [
            "type": "Disconnect",
            "userId": USER_ID(),
            "socialNetwork": type
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(self.bearerAuth, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, resp, error) in
            if let _error = error {
                print("SHARE/DISCONNECT/ERROR", _error.localizedDescription)
            } else {
                /*
                let str = String(decoding: data!, as: UTF8.self)
                print(str)
                */
            
                if let _response = resp as? HTTPURLResponse {
                    let statusCode = _response.statusCode
                    if(statusCode == 200) {
                        print("SHARE/DISCONNECT", "successful")
                    }
                } else {
                    print("SHARE/DISCONNECT/ERROR", "Unknow error")
                }

            }
        }
        task.resume()
    }
    
    /*
    RESPONSE example
    
    {"message":"OK"}
     */
}

// ************************************************************ //
// ************************************************************ //

extension ShareAPI {

    // Some utility methods
    static func json(fromData data: Data?) -> [String: Any]? {
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
    
    static func readStringKey(_ key: String) -> String? {
        if let _value = UserDefaults.standard.string(forKey: key) {
            return _value
        } else {
            return nil
        }
    }
    
    static func readBoolKey(_ key: String) -> Bool {
        let _value = UserDefaults.standard.bool(forKey: key)
        return _value
    }
    
    static func writeKey(_ key: String, value: Any) {
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func removeKey(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
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
    
    static func LOG(where w: String, msg: String) {
        print("SHARE-\(w): " + msg)
    }
    
    static func LOG_ERROR(where w: String, msg: String) {
        print("SHARE", "ERROR in \"\(w)\": \(msg)")
    }
    
    static func LOG_DATA(_ data: Data?, where w: String) {
        let str = String(decoding: data!, as: UTF8.self)
        print("SHARE-\(w)", "DATA " + str)
    }
    
}
