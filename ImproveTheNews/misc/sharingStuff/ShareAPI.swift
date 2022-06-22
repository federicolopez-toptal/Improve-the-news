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

    func getBearerAuth() -> String {
        return "Bearer " + self.getJWT()
//        return ShareAPI.readStringKey(keySHARE_bearerAuth)!
    }
    
    func getJWT() -> String {
        if let _jwt = ShareAPI.readStringKey(self.keySHARE_jwt) {
            return _jwt
        } else {
            return ""
        }
    }

    // ************************************************************ //
    private func host(includePhp: Bool = true) -> String {
        /*
        var result = API_BASE_URL()
        if(includePhp){ result += "/php" }
        
        return result
        */
        
        return "https://biaspost.org"
    }
    
// MARK: - API methods
    // ************************************************************ //
    func generate() {
        self.isGenerating = true
        let here = "Generate"
        let url = self.host() + "/api/user/"
        
        let bodyJson: [String: String] = [
            "type": "Generate",
            "userId": USER_ID__rnd(),
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
                                                
                        let _bearer = "Bearer " + _jwt
                        ShareAPI.writeKey(self.keySHARE_bearerAuth, value: _bearer)
                        ShareAPI.LOG(where: here, msg: "Auth: " + _bearer)
                        
                        ShareAPI.writeKey(self.keySHARE_uuid, value: _uuid)
                        ShareAPI.writeKey(self.keySHARE_jwt, value: _jwt)
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
    func login(type: String, accessToken: String, secret: String?, callback: @escaping (Bool) -> ()) { // (success)
        let here = "Login"
        let url = self.host() + "/api/user/"
        
        var bodyJson: [String: String] = [
            "type": type,
            "userId": USER_ID(),
            "access_token": accessToken,
            "option": "Sign In",
            "newsletter": "Y",
            "app": "iOS"
        ]
        
        if let _secret = secret {
            if(type.lowercased() == "reddit") {
                bodyJson["refresh_token"] = _secret
            } else {
                bodyJson["secret_token"] = _secret
            }
        }
        
        /*
        print(bodyJson)
        print(self.getBearerAuth())
        */
        
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
                    if let _jwt = json["jwt"] as? String, let _uuid = json["uuid"] as? String {
                        ShareAPI.LOG(where: here, msg: type + " success")
                        ShareAPI.writeKey(self.keySHARE_jwt, value: _jwt)
                        ShareAPI.writeKey(self.keySHARE_uuid, value: _uuid)
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
//    func login_TW(token: String, verifier: String, callback: @escaping (Bool) -> ()) {
//        let type = "Twitter"
//        let here = "Login"
//        let url = self.host() + "/api/user/"
//
//        let bodyJson: [String: String] = [
//            "type": type,
//            "userId": USER_ID(),
//            "access_token": token,
//            "secret_token": verifier
//        ]
//
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "POST"
//        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
//        request.httpBody = body
//        request.setValue(getBearerAuth(), forHTTPHeaderField: "Authorization")
//
//        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
//            if let _error = error {
//                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
//            } else {
//                ShareAPI.LOG_DATA(data, where: here)
//
//                if let json = ShareAPI.json(fromData: data) {
//                    if let _jwt = json["jwt"] as? String { // let _uuid = json["uuid"]
//                        ShareAPI.LOG(where: here, msg: type + " success")
//                        ShareAPI.writeKey(self.keySHARE_jwt, value: _jwt)
//                        callback(true)
//                    } else {
//                        ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
//                        callback(false)
//                    }
//                } else {
//                    ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
//                    callback(false)
//                }
//            }
//        }
//        task.resume()
//    }
    
    // ************************************************************ //
    func disconnect(type: String) { // (success)
        let here = "Disconnect"
        let url = self.host() + "/api/user/"
        
        let bodyJson: [String: String] = [
            "type": "Disconnect",
            "userId": USER_ID(),
            "socialNetwork": type
        ]
        // print(self.getBearerAuth())
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(self.getBearerAuth(), forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, resp, error) in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
            
                if let _response = resp as? HTTPURLResponse {
                    let statusCode = _response.statusCode
                    if(statusCode == 200) {
                        ShareAPI.LOG(where: here, msg: type + " success")
                    }
                } else {
                    ShareAPI.LOG_ERROR(where: here, msg: "Unknown error")
                }

            }
        }
        task.resume()
    }
    
    /*
    RESPONSE example
    
    {"message":"OK"}
    */
     
     // ************************************************************ //
     func generateImage(_ article1: (String, String, String, String, Bool, String),
        _ article2: (String, String, String, String, Bool, String),
        callback: @escaping (String?) -> ()) {
        // 0: img, 1: title, 2: country, 3: source, 4: state, 5: URL
     
        let here = "GenerateImage"
        let url = self.host() + "/api/image-generator/"
        
        let bodyJson: [String: String] = [
            "img1": ShareAPI.clearUrl(article1.0),
            "img2": ShareAPI.clearUrl(article2.0),
            "title1": article1.1,
            "title2": article2.1,
            "source1": ShareAPI.clearSource(article1.3),
            "source2": ShareAPI.clearSource(article2.3),
            "userId": USER_ID()
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
                    if let _image = json["image"] as? String {
                        ShareAPI.LOG(where: here, msg: "Image generated! " + _image)
                        callback(_image)
                    } else {
                        ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
                        callback(nil)
                    }
                } else {
                    ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
                    callback(nil)
                }
            }
        }
        task.resume()
        
     }
     
     /*
     RESPONSE example
     
     {
        "message": "OK",
        "image": "https://www.improvemynews.com/php/api/image-generator/images/wb6gRfWd63Z04eKnj9aV.jpg"
     }
     */
      
    // ************************************************************ //
    func shareSplit(_ article1: (String, String, String, String, Bool, String),
        _ article2: (String, String, String, String, Bool, String),
        types: [String], imageURL: String, text: String,
        callback: @escaping (Bool, String, String) -> ()) {
        // 0: img, 1: title, 2: country, 3: source, 4: state, 5: URL
        
        let here = "ShareSplit"
        let url = self.host() + "/api/split-share/"
        
//        let imageURL2 = "https://www.lacasadeel.net/wp-content/uploads/2022/02/SONIC-the-hedgehog-2-poster-final-sin-arreglar-554x790.png"
        
        let bodyJson: [String: Any] = [
            "types": types,
            "image": ShareAPI.clearUrl(imageURL),
            "aid1": ShareAPI.clearUrl(article1.5),
            "aid2": ShareAPI.clearUrl(article2.5),
            "comment": text,
            "source1": ShareAPI.clearSource(article1.3),
            "source2": ShareAPI.clearSource(article2.3),
            "slidercookies": "LR50PE50NU70DE70SL70RE70SS00LA00ST01yT01VM00VA00VB00VC00VE33oB11", //!!!
            "userId": USER_ID()
        ]
        
        print("SHARE", bodyJson)
        let errorMsg = "There was an error sharing your articles. Please try again"
        
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
                    var responses = self.responsePerSocialNetwork(json: json, types: types)
                    if(responses==nil){ responses = errorMsg }
                    
                    var url = ""
                    if let _url = json["url"] as? String {
                        url = _url
                    }
                    
                    print(responses!, url)
                    callback(true, responses!, url)
                } else {
                    ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
                    callback(false, errorMsg, "")
                }
            }
        }
        task.resume()
        
    }
    
    func responsePerSocialNetwork(json: [String: Any], types: [String]) -> String? {
        var result: String? = nil
        let okMsg = "Articles shared successfully"
        
        if(types.count==1) {
            let T = types.first!
            if(T=="Facebook"){
                result = nil
            } else {
                if let _typeContent = json[T] as? [String: String] {
                    if let _message = _typeContent["message"] {
                        if(_message.lowercased() == "ok") {
                            result = okMsg
                        }
                    }
                }
            }
        } else {
            var results = [String: Bool]()
            var typesCount = types.count
        
            for T in types {
                var T_result = false
                if(T=="Facebook"){
                    T_result = false
                    typesCount -= 1
                    continue
                } else {
                    if let _typeContent = json[T] as? [String: String] {
                        if let _message = _typeContent["message"] {
                            if(_message.lowercased() == "ok") {
                                T_result = true
                            }
                        }
                    }
                }
                
                results[T] = T_result
            }
            
            var ok = 0
            var nok = 0
            for(_, value) in results {
                if(value){ ok += 1 }
                else{ nok += 1 }
            }
            
            if(ok==typesCount) { // All ok
                result = okMsg
            } else if(nok==typesCount) { // All failed
                result = nil
            } else {
                result = okMsg + " via:\n"
                for(key, value) in results {
                    if(value){ result! += "* " + key + "\n" }
                }
                
                result! += "\n"
                result! += "Articles failed not be shared via:\n"
                for(key, value) in results {
                    if(!value){ result! += "* " + key + "\n" }
                }
            }
        }
    
        return result
    }
    
    
    /*
    RESPONSE example
    
    OK      {"Linkedin":{"message":"OK"}}
    ERROR   {"Reddit":{"message":"NOK"}}
    
    */
      
    // ************************************************************ //
    func signIn(email: String, password: String,
        callback: @escaping (Bool, String?) -> ()) {
        
        let here = "SignIn (Login)"
        let url = self.host() + "/api/user/"
        
        let bodyJson: [String: String] = [
            "type": "Sign In",
            "userId": USER_ID(),
            "email": email,
            "password": password,
            "app": "iOS"
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(getBearerAuth(), forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
                callback(false, nil)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
                if let json = ShareAPI.json(fromData: data) {
                    if let _status = json["status"] as? String {
                        if(_status == "OK") {
                            if let _jwt = json["jwt"], let _uuid = json["uuid"] as? String {
                                ShareAPI.writeKey(self.keySHARE_jwt, value: _jwt)
                                ShareAPI.writeKey(self.keySHARE_uuid, value: _uuid)
                            }
                            callback(true, nil)
                        } else {
                            if let _msg = json["message"] as? String {
                                callback(false, _msg)
                            } else {
                                callback(false, nil)
                            }
                        }
                    } else {
                        callback(false, nil)
                    }
                } else {
                    ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
                    callback(false, nil)
                }
            
            
            
//                ShareAPI.LOG_DATA(data, where: here)
//
//                if let json = ShareAPI.json(fromData: data) {
//                    if let _image = json["image"] as? String {
//                        ShareAPI.LOG(where: here, msg: "Image generated! " + _image)
//                        callback(true)
//                    } else {
//                        ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
//                        callback(false)
//                    }
//                } else {
//                    ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
//                    callback(false)
//                }
            }
        }
        task.resume()
    }
    
    /*
    RESPONSE example
    
    {
    "status": "NOK",
    "message": "Email not verified. Please verify your email by clicking the 'Verify Email' link in the email that was sent on the account registration."
    }
    
    {
    "status": "NOK",
    "message": "Invalid credentials"
    }
    
     */
    
    // ************************************************************ //
    // Registration
    func signUp(email: String, password: String, newsletter: Bool,
        callback: @escaping (Bool, String?) -> ()) {
        
        let here = "SignUp (Registration)"
        let url = self.host() + "/api/user/"
        
        let bodyJson: [String: String] = [
            "type": "Sign Up",
            "userId": USER_ID(),
            "email": email,
            "password": password,
            "newsletter": newsletter ? "Y" : "N",
            "app": "iOS"
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(getBearerAuth(), forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
                callback(false, nil)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
                if let json = ShareAPI.json(fromData: data) {
                    if let _status = json["status"] as? String {
                        if(_status == "OK") {
                            if let _jwt = json["jwt"], let _uuid = json["uuid"] as? String {
                                ShareAPI.writeKey(self.keySHARE_jwt, value: _jwt)
                                ShareAPI.writeKey(self.keySHARE_uuid, value: _uuid)
                            }
                            callback(true, nil)
                        } else {
                            if let _msg = json["message"] as? String {
                                callback(false, _msg)
                            } else {
                                callback(false, nil)
                            }
                        }
                    } else {
                        callback(false, nil)
                    }
                } else {
                    ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
                    callback(false, nil)
                }
            }
        }
        task.resume()
    }
 
    /*
    RESPONSE example
    
    {
    "jwt": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE2NTQwMjQ2ODQsImp0aSI6IklERmg0XC9DUWgrVUtKVjZVS2dnSk1nPT0iLCJpc3MiOiJpbXByb3ZldGhlbmV3cy5vcmciLCJuYmYiOjE2NTQwMjQ2ODQsImV4cCI6Mjk2OTAzMjY4NCwiZGF0YSI6eyJ1c3JpZCI6IjMyNTU0NzYxNTE2NzI0ODA0MzcifX0.8dddcj1csRmZJ3a1VNwoAAjRJ3IkirpV0giq41lon41vnd9QJrSrtSXR4PPyqrpOhemjYkoULLEEJA44krwy8A",
    "uuid": "3255476151672480437",
    "status": "OK"
    }
    
    {
    "status": "NOK",
    "message": "User already exists, please login instead."
    }
    
    */
 
    // ************************************************************ //
    func subscribeToNewsLetter(email: String,
        callback: @escaping (Bool) -> ()) {
        
        let here = "Subcribe to newsletter"
        let url = self.host() + "/api/newsletter/"
        
        let bodyJson: [String: String] = [
            "type": "Subscribe",
            "userId": USER_ID(),
            "email": email
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(getBearerAuth(), forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
                callback(false)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
                if let json = ShareAPI.json(fromData: data) {
                    if let _status = json["message"] as? String {
                        if(_status == "OK") {
                            AppUser.shared.subscribed = true
                            callback(true)
                        } else {
                            callback(false)
                        }
                    } else {
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
        { "message": "OK" }
     */
    
    // ************************************************************ //
    func unsubscribeToNewsLetter(callback: @escaping (Bool) -> ()) {
        
        let here = "Subcribe to newsletter"
        let url = self.host() + "/api/newsletter/"
        
        let bodyJson: [String: String] = [
            "type": "Unsubscribe",
            "userId": USER_ID()
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(getBearerAuth(), forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
                callback(false)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
                if let json = ShareAPI.json(fromData: data) {
                    if let _status = json["message"] as? String {
                        if(_status == "OK") {
                            AppUser.shared.subscribed = false
                            callback(true)
                        } else {
                            callback(false)
                        }
                    } else {
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
        { "message": "OK" }
     */
    
    // ************************************************************ //
    func forgotPassword(email: String,
        callback: @escaping (Bool, String?) -> ()) {
        
        let here = "Forgot password"
        let url = self.host() + "/api/user/"
        
        let bodyJson: [String: String] = [
            "type": "Generate Password Reset Link",
            "email": email,
            "app": "iOS"
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(getBearerAuth(), forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
                callback(false, _error.localizedDescription)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
                if let json = ShareAPI.json(fromData: data) {
                    if let _status = json["status"] as? String {
                        if(_status == "OK") {
                            callback(true, nil)
                        } else {
                            if let msg = json["message"] as? String {
                                callback(false, msg)
                            } else {
                                callback(false, nil)
                            }
                        }
                    } else {
                        callback(false, nil)
                    }
                } else {
                    ShareAPI.LOG_ERROR(where: here, msg: "Error parsing JSON")
                    callback(false, nil)
                }
            }
        }
        task.resume()
    }
    
    /*
        RESPONSE example
        
        {"status":"OK","message":"Please check your spam folder."}
        {"status":"NOK","message":"User does not exist"}
        
     */
     
    // ************************************************************ //
    private func setAppLocalUser(_ json: [String: Any]) {
        let user = AppUser.shared
        user.name = json["firstname"] as? String
        user.lastName = json["lastname"] as? String
        user.screenName = json["username"] as? String
        user.email = json["email"] as? String
        
        if let _subscribed = json["subscribed"] as? String {
            user.newsletterOptions = [Int: Bool]()
            
            if(_subscribed == "Y") {
                user.subscribed = true
                if let options = json["subscription"] as? [String: String] {
                    if let frequency = options["frequency"] as? String {
                        if(frequency=="Daily"){
                            user.newsletterOptions![101] = true
                            user.newsletterOptions![102] = false
                        } else {
                            user.newsletterOptions![101] = false
                            user.newsletterOptions![102] = true
                        }
                    }
                    
                    if let frequency = options["content"] as? String {
                        if(frequency=="All top stories"){
                            user.newsletterOptions![103] = true
                            user.newsletterOptions![104] = false
                        } else {
                            user.newsletterOptions![103] = false
                            user.newsletterOptions![104] = true
                        }
                    }
                    
                    if let frequency = options["ordering"] as? String {
                        if(frequency=="World news first"){
                            user.newsletterOptions![105] = true
                            user.newsletterOptions![106] = false
                        } else {
                            user.newsletterOptions![105] = false
                            user.newsletterOptions![106] = true
                        }
                    }
                }
            } else {
                user.subscribed = false
            }
        }
    }
    
    func getUserInfo(callback: @escaping (Bool) -> ()) {
        
        let here = "get user info"
        let url = self.host() + "/api/user/"
        
        let bodyJson: [String: String] = [
            "type": "User Info Get",
            "userId": USER_ID()
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(getBearerAuth(), forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
                callback(false)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
                if let json = ShareAPI.json(fromData: data) {
                    if let _msg = json["message"] as? String, _msg == "OK" {
                        self.setAppLocalUser(json)
                        callback(true)
                    } else {
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
    
        {
            "uuid": "3485127359718489297",
            "message": "OK",
            "socialnetworks": [
                "Twitter"
            ],
            "slidercookies": "",
            "firstname": "",
            "username": " ",
            "lastname": "",
            "email": "",
            "subscribed": "N"
        }
     */
    // ************************************************************ //
    func saveUserInfo(name: String?, lastName: String?, screenName: String?, email: String?,
        callback: @escaping (Bool) -> ()) {
        
        let here = "save user info"
        let url = self.host() + "/api/user/"
        
        var bodyJson: [String: String] = [
            "type": "User Info Update",
            "userId": USER_ID()
        ]
        if let _name = name {
            bodyJson["firstName"] = _name
        }
        if let _lastName = lastName {
            bodyJson["lastName"] = _lastName
        }
        if let _screenName = screenName {
            bodyJson["username"] = _screenName
        }
        if let _email = email {
            bodyJson["email"] = _email
        }
        
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(getBearerAuth(), forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
                callback(false)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
                if let json = ShareAPI.json(fromData: data) {
                    if let _msg = json["message"] as? String, _msg == "OK" {
                        self.setAppLocalUser(json)
                        callback(true)
                    } else {
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
    RESPONSE EXAMPLE
    
    {
        "uuid": "3485127359718489297",
        "message": "OK",
        "socialnetworks": [
            "Twitter"
        ],
        "slidercookies": "",
        "firstname": "Federico",
        "username": "federico.test_ITN Lopez",
        "lastname": "Lopez",
        "email": "federico.002@gmail.com",
        "subscribed": "N"
    }
     */
     
    // ************************************************************ //
    func setNewsletterOption(email: String, fields: [String: String],
        callback: @escaping (Bool) -> ()) {
        
        let here = "Set newsletter option"
        let url = self.host() + "/api/newsletter/"
        
        var bodyJson: [String: String] = [
            "type": "Options",
            "userId": USER_ID(),
            "email": email,
        ]
        for (key, value) in fields {
            bodyJson[key] = value
        }
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(getBearerAuth(), forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
                callback(false)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
                if let json = ShareAPI.json(fromData: data) {
                    if let _status = json["message"] as? String {
                        if(_status == "OK") {
                            //AppUser.shared.subscribed = true
                            callback(true)
                        } else {
                            callback(false)
                        }
                    } else {
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
        { "message": "OK" }
     */
     
    // ************************************************************ //
    func disconnectAll(callback: @escaping (Bool) -> ()) {
        
        let here = "Disconnect All"
        let url = self.host() + "/api/user/"
        
        let bodyJson: [String: String] = [
            "type": "Disconnect All",
            "userId": USER_ID()
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        request.setValue(getBearerAuth(), forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                ShareAPI.LOG_ERROR(where: here, msg: _error.localizedDescription)
                callback(false)
            } else {
                ShareAPI.LOG_DATA(data, where: here)
                if let json = ShareAPI.json(fromData: data) {
                    if let _msg = json["message"] as? String, _msg == "OK" {
                        self.setAppLocalUser(json)
                        callback(true)
                    } else {
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
    RESPONSE EXAMPLE
    
    {"message":"OK"}
     */
}

// ************************************************************ //
// ************************************************************ //

// MARK: - Utility methods
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
    
    func writeJWT(_ jwt: String) {
        ShareAPI.writeKey(self.keySHARE_jwt, value: jwt)
    }
    
    func writeUUID(_ uuid: String) {
        ShareAPI.writeKey(self.keySHARE_uuid, value: uuid)
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
        var str = String(decoding: data!, as: UTF8.self)
        str = str.replacingOccurrences(of: "\n", with: "")
        
        print("SHARE-\(w)", "DATA " + str)
    }
    
    static func clearUrl(_ url: String) -> String {
        var result = url.replacingOccurrences(of: "http://", with: "")
        result = result.replacingOccurrences(of: "https://", with: "")
        return result
    }
    
    static func clearSource(_ source: String) -> String {
        var result = ""
        if(source.contains("#")) {
            result = source.components(separatedBy: " #")[0]
        } else {
            result = source.components(separatedBy: " - ")[0]
        }
        
        return result
    }
    
}
