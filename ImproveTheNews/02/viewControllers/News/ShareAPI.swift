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

    private let key_JWT = "JWT_locally_stored"

    func getJWT(callback: @escaping (Bool, String) -> ()) {
                                // success, errorDescription or JWT string

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
