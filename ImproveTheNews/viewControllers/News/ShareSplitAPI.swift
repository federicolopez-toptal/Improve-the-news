//
//  ShareSplitAPI.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 13/12/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

class ShareSplitAPI {

    private func request(reqUrl: String) -> URLRequest {
        let bearer = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE2MzgyNzg4ODUsImp0aSI6InZWbXN4WHhwRTRWaTVxN25UN3VtTVE9PSIsImlzcyI6ImltcHJvdmV0aGVuZXdzLm9yZyIsIm5iZiI6MTYzODI3ODg4NSwiZXhwIjoyOTUzMDI3Njg1LCJkYXRhIjp7InVzcmlkIjoiMjUwOTAwMjUzNzUzNjA1MiJ9fQ.dX7XCCAypg0J8JJGj5FE8gzkGtX-Kbij4G__olkB8lG5gFaCPwIAv44VBbnGfzZ2MmLKLkDPWas5Gr_22XOGvA"
        
        var request = URLRequest(url: URL(string: reqUrl)!)
        request.httpMethod = "POST"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(bearer, forHTTPHeaderField: "Authorization")
        return request
    }
    private func body(item1: (String, String, String), item2: (String, String, String)) -> Data {

        var img1 = item1.0
        img1 = img1.replacingOccurrences(of: "http://", with: "")
        img1 = img1.replacingOccurrences(of: "https://", with: "")
        
        var img2 = item2.0
        img2 = img2.replacingOccurrences(of: "http://", with: "")
        img2 = img2.replacingOccurrences(of: "https://", with: "")

        var source1 = item1.2
        if(source1.contains("#")) {
            source1 = source1.components(separatedBy: " #")[0]
        } else {
            source1 = source1.components(separatedBy: " - ")[0]
        }
        
        var source2 = item2.2
        if(source2.contains("#")) {
            source2 = source2.components(separatedBy: " #")[0]
        } else {
            source2 = source2.components(separatedBy: " - ")[0]
        }

        print("SOURCE1", source1)
        print("SOURCE2", source2)

        let json: [String: String] = [
            "img1": img1,
            "img2": img2,
            "title1": item1.1,
            "title2": item2.1,
            "source1": source1,
            "source2": source2
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        return jsonData!
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
    
    

    func generateImage(_ art1: (String, String, String, String, Bool),
                        _ art2: (String, String, String, String, Bool),
                        callback: @escaping (String?, String?) -> () ) {
                        // 0: img, 1: title, 2: country, 3: source, 4: state
        
        let url = "http://ec2-3-16-162-167.us-east-2.compute.amazonaws.com/php/api/image-generator/"
        
        let body = self.body(item1: (art1.0, art1.1, art1.3), item2: (art2.0, art2.1, art2.3))
        let bodySize = String(body.count)
        var request = self.request(reqUrl: url)
        request.setValue(bodySize, forHTTPHeaderField: "Content-Length")
        request.httpBody = body
        
        
        
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                print("ERROR! " + _error.localizedDescription)
                callback(_error.localizedDescription, nil)
            } else {
                if let json = self.json(fromData: data) {
                    if let msg = json["message"] as? String, msg == "OK" {
                        if let image = json["image"] as? String {
                            callback(nil, image)
                        }
                    } else {
                        callback("Error parsing json", nil)
                    }
                } else {
                    callback("Error parsing json", nil)
                }
                
            }
        }
        
        task.resume()
    }

}
