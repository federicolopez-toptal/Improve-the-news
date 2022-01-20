//
//  StorySourceManager.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 20/01/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation

class StorySourceManager {
    
    public static var shared = StorySourceManager()
    
    private let api_url = API_BASE_URL() + "/php/api/news/sources.php"
    
    init() {
        self.loadSources()
    }
    
    private func loadSources() {
        var request = URLRequest(url: URL(string: api_url)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                print("ERROR! " + _error.localizedDescription)
            } else {
            
                print("JSON", self.json(fromData: data))
            
                if let json = self.json(fromData: data) {
                    print("JSON", json)
                    /*
                    if let msg = json["message"] as? String, msg == "OK" {
                        if let image = json["image"] as? String {
                            callback(nil, image)
                        }
                    } else {
                        callback("Error parsing json", nil)
                    }
                    */
                } else {
                    //callback("Error parsing json", nil)
                }
                
            }
        }
        
        task.resume()
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
