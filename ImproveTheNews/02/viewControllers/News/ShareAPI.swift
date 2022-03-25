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

    private let bearerAuth = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE2NDc0NDcwMTYsImp0aSI6IkRcL01OQ0RQVG8xcVVZaXJcL2lTRjdMQT09IiwiaXNzIjoiaW1wcm92ZXRoZW5ld3Mub3JnIiwibmJmIjoxNjQ3NDQ3MDE2LCJleHAiOjI5NjI0NTUwMTYsImRhdGEiOnsidXNyaWQiOiIzNjM1MDU0MzI1NTE3NDIwMDA1In19.gH0w7cENtFfMou4IeCiBp2Ov4zy1IhS-5Q7WlBY84qbkwiTFOORbR5SBMf_F-5hwUFB7xjn2a39A8MlCLHpVsQ"

    var uuid: String? {
        return ShareAPI.readStringKey(keySHARE_uuid)
    }


    // ************************************************************ //
    func generate() {
        let url = API_BASE_URL() + "/php/api/user/"
        
        let bodyJson: [String: String] = [
            "type": "Generate",
            "userId": USER_ID_old(),
            "app": "iOS"
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        

        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                print("SHARE/GENERATE/ERROR", _error.localizedDescription)
            } else {
                if let json = self.json(fromData: data) {
                    if let _jwt = json["jwt"] as? String, let _uuid = json["uuid"] as? String {
                        print("JWT", _jwt)
                        print("UserID", _uuid)
                        ShareAPI.writeKey(self.keySHARE_uuid, value: _uuid)
                        ShareAPI.writeKey(self.keySHARE_jwt, value: _jwt)
                    } else {
                        print("SHARE/GENERATE/ERROR", "Error parsing json")
                    }
                } else {
                    print("SHARE/GENERATE/ERROR", "Error parsing json")
                }
            }
        }
        task.resume()
        
    }
    /*
    RESPONSE example
    
    {"jwt":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE2NDgwNDAwMTQsImp0aSI6IlpucUMrM29STGI3RDdxOGh6SkliTmc9PSIsImlzcyI6ImltcHJvdmV0aGVuZXdzLm9yZyIsIm5iZiI6MTY0ODA0MDAxNCwiZXhwIjoyOTYzMDQ4MDE0LCJkYXRhIjp7InVzcmlkIjoiMzYzNTA1NDMyNTUxNzQyMDAwNSJ9fQ.C1JN5BwFDAwQ4Tmwu3qofFkTvmcvgdmgeYzmOos875OTa7c_r2uq6Swj1zOSxpY8h0hKcvBjuxCYXhaevwW-Aw","uuid":"3635054325517420005"}
    */
    
    // ************************************************************ //
    func login(type: String, accessToken: String, callback: @escaping (Bool) -> ()) { // (success)
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
        request.setValue(self.bearerAuth, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                print("SHARE/LOGIN/ERROR", _error.localizedDescription)
            } else {
                if let json = self.json(fromData: data) {
                    if let _jwt = json["jwt"] as? String { // let _uuid = json["uuid"]
                        ShareAPI.writeKey(self.keySHARE_jwt, value: _jwt)
                        callback(true)
                    } else {
                        print("SHARE/LOGIN/ERROR", "Error parsing json")
                        callback(false)
                    }
                } else {
                    print("SHARE/LOGIN/ERROR", "Error parsing json")
                    callback(false)
                }
            }
        }
        task.resume()
    }
    
    /*
    RESPONSE example
    
    {"uuid":"3635054325517420005","socialnetworks":[],"message":"OK","slidercookies":"","jwt":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE2NDgwMzk3NzYsImp0aSI6IlhUUUh0UWt3TTErTXk4XC9FY0Z1K1wvZz09IiwiaXNzIjoiaW1wcm92ZXRoZW5ld3Mub3JnIiwibmJmIjoxNjQ4MDM5Nzc2LCJleHAiOjI5NjMwNDc3NzYsImRhdGEiOnsidXNyaWQiOiIzNjM1MDU0MzI1NTE3NDIwMDA1In19.llMWJtx_MQTdWCcnaMIeXk2neJSH6yruLdr-JAnCQhs6_k2i-uy1kHaZixtY00_1YisgGo78rWKWz1pLnFWU1A"}
    */
    
    // ************************************************************ //
    func login_TW(token T: String, verifier V: String, callback: @escaping (Bool) -> ()) { // (success)
        
        let url = API_BASE_URL() + "/php/twitter/login.php?oauth_verifier=\(V)&oauth_token=\(T)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                print("SHARE/LOGIN.TW/ERROR", _error.localizedDescription)
                callback(false)
            } else {
                if let _response = resp as? HTTPURLResponse {
                    let statusCode = _response.statusCode
                    if(statusCode == 200) {
                        print("SHARE/LOGIN.TW", "Success!")
                        callback(true)
                    } else {
                        callback(false)
                    }
                }
            }
        }
        task.resume()
    }
    
    /*
    RESPONSE example
    
    "" 🤦‍♂️
    */
    
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
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                print("SHARE/DISCONNECT/ERROR", _error.localizedDescription)
            } else {
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
}

// ************************************************************ //
// ************************************************************ //

extension ShareAPI {

    // Some utility methods
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
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        vc.present(alert, animated: true) {
        }
    }
    
}
