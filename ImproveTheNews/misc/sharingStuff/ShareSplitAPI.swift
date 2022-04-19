//
//  ShareSplitAPI.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 13/12/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

class ShareSplitAPI {

    //let BASE_URL = "http://ec2-3-16-162-167.us-east-2.compute.amazonaws.com/php/api/"
    let BASE_URL = "https://www.improvemynews.com/php/api/"
    

    func share(imgUrl: String, comment: String,
        art1: (String, String, String, String, Bool),
        art2: (String, String, String, String, Bool),
        callback: @escaping () ->() ) {
        // 0: img, 1: title, 2: country, 3: source, 4: state
        
        let url = BASE_URL + "split-share/"
        
        let body = self.bodyForShare(img: imgUrl, text: comment, source1: art1.3, source2: art2.3)
        var request = self.request(reqUrl: url)
    }


    func generateImage(_ art1: (String, String, String, String, Bool),
                        _ art2: (String, String, String, String, Bool),
                        callback: @escaping (String?, String?) -> () ) {
                        // 0: img, 1: title, 2: country, 3: source, 4: state
        
        let url = BASE_URL + "image-generator/"
        
        let body = self.bodyForImg(item1: (art1.0, art1.1, art1.3), item2: (art2.0, art2.1, art2.3))
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

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
extension ShareSplitAPI {

    private func request(reqUrl: String) -> URLRequest {
        
        /*
        let bearer = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE2NDk4NTg5OTYsImp0aSI6IkUxQ0F1WElZSEpjazdGdUgwZ1dGUXc9PSIsImlzcyI6ImltcHJvdmV0aGVuZXdzLm9yZyIsIm5iZiI6MTY0OTg1ODk5NiwiZXhwIjoyOTY0NzgwNTk2LCJkYXRhIjp7InVzcmlkIjoiMzkxMTI3ODE2NzUxMTc0NDQxNSJ9fQ.yDNeEqiWKWcma-A31cCDRyWhxYGVtxjkjJvOthyRWZEhlKYOs65lrqiAQwNV1kSlNyt4sKjJe_E-1fE_gpJEcA"
        */
        
        let bearer = ShareAPI.instance.getBearerAuth()
        //let bearer = "Bearer " + ShareAPI.instance.getJWT()
        
        var request = URLRequest(url: URL(string: reqUrl)!)
        request.httpMethod = "POST"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(bearer, forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func bodyForImg(item1: (String, String, String), item2: (String, String, String)) -> Data {

        let img1 = self.clearImgUrl(item1.0)
        let img2 = self.clearImgUrl(item2.0)
        let source1 = self.clearSource(item1.2)
        let source2 = self.clearSource(item2.2)

        let json: [String: String] = [
            "img1": img1,
            "img2": img2,
            "title1": item1.1,
            "title2": item2.1,
            "source1": self.clearSource(source1),
            "source2": self.clearSource(source2),
            "userId": USER_ID()
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        return jsonData!
    }
    
    private func bodyForShare(img: String, text: String, source1: String, source2: String) -> Data {
        
        let _source1 = self.clearSource(source1)
        let _source2 = self.clearSource(source2)
        
        let sliders = self.extractParam("sliders", from: Utils.shared.lastApiCall)
        let json: [String: Any] = [
            "image": img,
            "comment": text,
            "source1": _source1,
            "source2": _source2,
            "slidercookies": sliders,
            "userId": USER_ID()
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        return jsonData!
    }
    
    private func clearImgUrl(_ url: String) -> String {
        var result = url.replacingOccurrences(of: "http://", with: "")
        result = result.replacingOccurrences(of: "https://", with: "")
        return result
    }
    
    private func clearSource(_ source: String) -> String {
        var result = ""
        if(source.contains("#")) {
            result = source.components(separatedBy: " #")[0]
        } else {
            result = source.components(separatedBy: " - ")[0]
        }
        
        return result
    }
    
    private func extractParam(_ param: String, from: String) -> String? {
        let url = URL(string: from)
        return url?.params()[param] as? String
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
