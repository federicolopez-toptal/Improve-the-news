//
//  ShareAPI.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 10/03/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation

/*
    Share documentation, by Armin
    https://docs.google.com/document/d/169RXt9wfP2wRuhahih-ENLMYWOyiRFWQL5JxNjEN8Pg/edit?usp=sharing
*/

class ShareAPI {

    static let instance = ShareAPI()
    private let key_JWT = "JWT_locally_stored"

    // ************************************************************ //
                                    // success, errorDescription or JWT string
    func getJWT(callback: @escaping (Bool, String) -> ()) {
                                
        if let _jwt = self.getLocal_JWT() {
            callback(true, _jwt)
            return
        }


        let url = API_BASE_URL() + "/php/api/user/"
        
        let bodyJson: [String: String] = [
            "type": "Generate",
            "userId": USER_ID(),
            "app": "iOS"
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = body
        

        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                callback(false, _error.localizedDescription)
            } else {
                if let json = self.json(fromData: data) {
                    if let _jwt = json["jwt"] as? String { //}, let _uuid = json["uuid"] {
                        self.writeLocal_JWT(_jwt)
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
                        self.writeLocal_JWT(_jwt)
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

    // Private methods
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
    
    private func getLocal_JWT() -> String? {
        if let _value = UserDefaults.standard.string(forKey: key_JWT) {
            return _value
        } else {
            return nil
        }
    }
    
    private func writeLocal_JWT(_ value: String) {
        UserDefaults.standard.setValue(value, forKey: key_JWT)
        UserDefaults.standard.synchronize()
    }
    
}
