//
//  StoryEntities.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 30/06/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation

/*
    Ejemplo:
        https://www.improvemynews.com/php/stories/index.php?path=story&id=%202719&filters=123
*/


class StoryData {
    
    var id: String = "1"
    var title: String = "Title not available"
    var image_src: String = ""
    var image_credit_title: String = "Not available"
    var image_credit_url: String = ""
    
    init(_ json: [String: Any]) {
        if let _id = json["id"] as? Int {
            self.id = String(_id)
        }
        
        if let _title = json["title"] as? String {
            self.title = _title
        }
        
        if let _imageObj = json["image"] as? [String: Any] {
            self.image_src = _imageObj["src"] as! String
            if let _imageCreditObj = _imageObj["credit"] as? [String: String] {
                self.image_credit_title = _imageCreditObj["title"]!
                self.image_credit_url = _imageCreditObj["url"]!
            }
        }
        
    }
    
}


class StoryFact {
    
    var title: String = ""           // text
    var source_title: String = ""    // source name
    var source_url: String = ""      // source url

    init(_ json: [String: Any]) {
    
        if let _title = json["title"] as? String {
            self.title = _title
        }
        
        /*
        let sourceArray = json["source"] as! [[String: String]]
        if(sourceArray.count>0) {
            let first = sourceArray[0]
            self.source_title = first["title"]!
            self.source_url = first["url"]!
        } else {
            self.source_title = ""
            self.source_url = ""
        }
        */
        
        if let _sourceArray = json["source"] as? [[String: Any]] {
            if(_sourceArray.count>0) {
                let first = _sourceArray[0]
                
                if let sTitle = first["title"] as? String {
                    self.source_title = sTitle
                }
                if let sUrl = first["url"] as? String {
                    self.source_url = sUrl
                }                
            }
        }
        
    }
    
}


class StorySpin {

    var title: String = "Title not available"
    var description: String = "Description not available"
    
    var timeStamp: String?
    var subTitle: String? = ""
    var url: String? = ""
    var image: String? = ""
    var time: Int? = 0
    var media_title: String? = ""
    var media_country_code: String? = ""

    init(_ json: [String: Any]) {
        
        if let _title = json["title"] as? String {
            self.title = _title
        }
                
        if let _description = json["description"] as? String {
            self.description = _description
        }
        
        self.timeStamp = json["timestamp"] as? String
        
        if let _spinsArray = json["spins"] as? [[String: Any]] {
            if(_spinsArray.count>0) {
                let first = _spinsArray[0]
                self.subTitle = first["title"] as? String
                self.url = first["url"] as? String
                self.image = first["image"] as? String
                self.time = first["time"] as? Int
                
                if let mediaObj = first["media"] as? [String: Any] {
                    self.media_title = mediaObj["title"] as? String
                    self.media_country_code = mediaObj["country_code"] as? String
                }
            }
        }
        
        
    }
    
}


class StoryArticle {

    var id: String = "1"
    var title: String = "Title not available"
    var url: String = ""
    var image: String = ""
    var time: Int = 0
    var media_title: String = ""
    var media_country_code: String? = nil

    init(_ json: [String: Any]) {
        self.id = self.obtain(json["id"], default: "1")
        self.title = self.obtain(json["title"])
        self.url = self.obtain(json["url"])
        self.image = self.obtain(json["image"])
        
        if let _time = json["time"] as? Int {
            self.time = _time
        }
        
        if let _mediaObj = json["media"] as? [String: Any] {
            if let _title = _mediaObj["title"] as? String {
                self.media_title = _title
            }
        
            self.media_country_code = _mediaObj["country_code"] as? String
        }
        
    }
    
    private func obtain(_ value: Any?, default defaultValue: String = "") -> String {
        if let _value = value as? String {
            return _value
        }
        return defaultValue
    }
    
}
