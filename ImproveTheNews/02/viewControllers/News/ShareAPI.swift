//
//  ShareAPI.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 10/03/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation

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

    var uuid: String? {
        return self.readKey(keySHARE_uuid)
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
                        self.writeKey(self.keySHARE_uuid, value: _uuid)
                        self.writeKey(self.keySHARE_jwt, value: _jwt)
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
    
    // ************************************************************ //
                                                        // success, errorDescription or JWT string
    func login(accessToken: String, callback: @escaping (Bool, String) -> ()) {
        let url = API_BASE_URL() + "/php/api/user/"
        
        let bodyJson: [String: String] = [
            "type": "Facebook",
            "userId": USER_ID(),
            "access_token": accessToken
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        
        let bearer = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE2MzgyNzg4ODUsImp0aSI6InZWbXN4WHhwRTRWaTVxN25UN3VtTVE9PSIsImlzcyI6ImltcHJvdmV0aGVuZXdzLm9yZyIsIm5iZiI6MTYzODI3ODg4NSwiZXhwIjoyOTUzMDI3Njg1LCJkYXRhIjp7InVzcmlkIjoiMjUwOTAwMjUzNzUzNjA1MiJ9fQ.dX7XCCAypg0J8JJGj5FE8gzkGtX-Kbij4G__olkB8lG5gFaCPwIAv44VBbnGfzZ2MmLKLkDPWas5Gr_22XOGvA"
        request.setValue(bearer, forHTTPHeaderField: "Authorization")
        

        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                callback(false, _error.localizedDescription)
            } else {
                if let json = self.json(fromData: data) {
                    if let _jwt = json["jwt"] as? String { //}, let _uuid = json["uuid"] {
                        //self.writeLocal_JWT(_jwt)
                        callback(true, _jwt)
                    } else {
                        callback(false, "Error parsing json")
                    }
                } else {
                    callback(false, "Error parsing json")
                }
            }
        }
        task.resume()
    }
    
}

extension ShareAPI {

    // Some private methods
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
    
    private func readKey(_ key: String) -> String? {
        if let _value = UserDefaults.standard.string(forKey: key) {
            return _value
        } else {
            return nil
        }
    }
    
    private func writeKey(_ key: String, value: String) {
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
}
