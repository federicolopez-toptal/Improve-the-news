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
    
    private let api_url = API_BASE_URL() + "/news.json" //"/php/api/news/sources.php"
    private var sources = [String: String]()
    private var sources_LR = [String: Int]()
    private var sources_PE = [String: Int]()
    private var loaded = false
    
    public func getIconForSource(_ sourceName: String) -> String {
        if(self.sources.keys.count>0 && self.sources.keys.contains(sourceName)) {
            if(self.sources[sourceName] != nil) {
                if let _value = self.sources[sourceName] {
                    return _value
                } else {
                    return ""
                }
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    public func filterSources(toFilter: [String]) -> [String] {
        var result = [String]()
        
        for _key in toFilter {
            if(self.sources.keys.contains(_key)) {
                result.append(_key)
            }
        }
        
        return result
    }
    
    public func loadSources( callback: @escaping (Error?) -> () ) {
        if(self.loaded) {
            callback(nil)
            return
        }
    
        var request = URLRequest(url: URL(string: api_url)!)
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            if let _error = error {
                callback(_error)
            } else {

                if let json = self.json(fromData: data) {
                    
                    for item in json {
                    
                        // icon
                        if let _key = item["shortname"] as? String, let _icon = item["icon"] as? String {
                            var value = _icon
                            if(!value.contains("http") && !value.contains("www")) {
                                value = API_BASE_URL() + "/" + value
                            }
                            self.sources[_key] = value
                        }
                        
                        // LR, PE
                        if let _key = item["name"] as? String, let _LR = item["lr"] as? String, let _PE = item["pe"] as? String {
                            let _keyLower = _key.lowercased()

                            self.sources_LR[_keyLower] = Int(_LR)
                            self.sources_PE[_keyLower] = Int(_PE)
                        }
                    }
                    
                    self.loaded = true
                    callback(nil)
                } else {
                    callback(nil)
                }
                
            }
        }
        
        task.resume()
    }
    
    func getLR(name: String) -> Int {
        if let _value = self.sources_LR[name] {
            return _value
        } else {
            return 0
        }
    }
    func getPE(name: String) -> Int {
        if let _value = self.sources_PE[name] {
            return _value
        } else {
            return 0
        }
    }
    
    
    
    private func json(fromData data: Data?) -> [[String: Any]]? {
        if let _data = data {
            do{
                let json = try JSONSerialization.jsonObject(with: _data, options: []) as? [[String: Any]]
                return json
                
            } catch {
                print( "ERROR", error.localizedDescription )
                return nil
            }
        } else {
            return nil
        }
    }
    
}
