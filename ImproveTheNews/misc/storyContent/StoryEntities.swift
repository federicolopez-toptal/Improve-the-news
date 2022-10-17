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
    
    let id: String
    let title: String
    let image_src: String
    let image_credit_title: String
    let image_credit_url: String
    
    init(_ json: [String: Any]) {
        self.id = String(json["id"] as! Int)
        self.title = json["title"] as! String
        
        let imageObj = json["image"] as! [String: Any]
        self.image_src = imageObj["src"] as! String
        
        let imageCreditObj = imageObj["credit"] as! [String: String]
        self.image_credit_title = imageCreditObj["title"]!
        self.image_credit_url = imageCreditObj["url"]!
    }
    
}


class StoryFact {
    
    let title: String           // text
    let source_title: String    // source name
    let source_url: String      // source url

    init(_ json: [String: Any]) {
        self.title = json["title"] as! String
        
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
        
        let sourceArray = json["source"] as! [[String: Any]]
        if(sourceArray.count>0) {
            let first = sourceArray[0]
            self.source_title = first["title"] as! String
            self.source_url = first["url"] as! String
        } else {
            self.source_title = ""
            self.source_url = ""
        }
    }
    
}


class StorySpin {

    var title: String
    var description: String
    let timeStamp: String?
    
    let subTitle: String?
    let url: String?
    let image: String?
    let time: Int?
    let media_title: String?
    let media_country_code: String?

    init(_ json: [String: Any]) {
        self.title = "Title not available"
        if let _title = json["title"] as? String {
            self.title = _title
        }
        
        self.description = "Description not available"
        if let _description = json["description"] as? String {
            self.description = _description
        }
        
        self.timeStamp = json["timestamp"] as? String
        
        let spinsArray = json["spins"] as! [[String: Any]]
        if(spinsArray.count>0) {
            let first = spinsArray[0]
            self.subTitle = first["title"] as? String
            self.url = first["url"] as? String
            self.image = first["image"] as? String
            self.time = first["time"] as? Int
            
            if let mediaObj = first["media"] as? [String: Any] {
                self.media_title = mediaObj["title"] as? String
                self.media_country_code = mediaObj["country_code"] as? String
            } else {
                self.media_title = ""
                self.media_country_code = ""
            }
            
        } else {
            self.subTitle = ""
            self.image = ""
            self.url = ""
            self.time = 0
            self.media_title = ""
            self.media_country_code = nil
        }
    }
    
}


class StoryArticle {

    let id: String
    let title: String
    let url: String
    let image: String
    let time: Int
    let media_title: String
    let media_country_code: String?

    init(_ json: [String: Any]) {
        self.id = json["id"] as! String
        self.title = json["title"] as! String
        self.url = json["url"] as! String
        self.image = json["image"] as! String
        self.time = json["time"] as! Int
        
        let mediaObj = json["media"] as! [String: Any]
        self.media_title = mediaObj["title"] as! String
        self.media_country_code = mediaObj["country_code"] as? String
    }
    
}
