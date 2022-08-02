//
//  StoryContent.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 30/06/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation

class StoryContent {

    private let storyID_url = API_BASE_URL() + "/api/route?slug="
    private let storyData_url = API_BASE_URL() + "/php/stories/index.php?path=story&id=<ID>&filters=<FILTERS>"
    private let storyArticles_url = API_BASE_URL() + "/php/stories/index.php?path=articles&story_id=<ID>&filters=<FILTERS>"

    static let instance = StoryContent()
    
    func loadData(link: String, filter: String,
        callback: @escaping (StoryData?, [StoryFact]?, [StorySpin]?, [StoryArticle]?, String?) ->() ) {
    //) {
        let slug = self.extractSlugFrom(url: link)
        self.getStoryID(slug: slug) { storyID in
            if let _id = storyID {
                self.getStoryData(storyID: _id, filter: filter) { (storyData, facts, spins, articles, version) in
                    callback(storyData, facts, spins, articles, version)
//                    print("#########################")
//                    print(storyData?.title)
//                    print("FACTS", facts?.count)
////                    print(facts?.first?.title, facts?.first?.source_title)
//                    print("SPINS", spins?.count)
//                    //print(spins?.first?.title, spins?.first?.time)
//                    print("ARTICLES", articles?.count)
//                    //print(articles?.first?.title, articles?.first?.media_title)
//                    print(version)
//
//                    print("")
                }
            }
        }
    }
    
    func loadAlgo() {
    
    }

}

// MARK: - misc
extension StoryContent {

    private func getStoryData(storyID: String, filter: String,
        callback: @escaping (StoryData?, [StoryFact]?, [StorySpin]?, [StoryArticle]?, String?) ->() ) {
        
        var url = storyData_url.replacingOccurrences(of: "<ID>", with: storyID)
        url = url.replacingOccurrences(of: "<FILTERS>", with: filter)
        
        print("URL", url)
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, resp, error) in
            if let _error = error {
                print(_error.localizedDescription)
                callback(nil, nil, nil, nil, nil)
            } else {
                ShareAPI.LOG_DATA(data, where: "getStoryData")
                if let json = ShareAPI.json(fromData: data) {
                    //Story content
                    let storyDataJson = json["storyData"] as! [String: Any]
                    
                    let storyFactsArray = self.removeNullFrom(json["facts"])
                    let storySpinsArray = self.removeNullFrom(json["spinSection"])
                    let storyArticles = self.removeNullFrom(json["articles"])
                    let version = json["version"] as! String
                    
                    let storyData = StoryData(storyDataJson)
                    
                    var facts = [StoryFact]()
                    for F in storyFactsArray {
                        let newFact = StoryFact(F)
                        facts.append(newFact)
                    }
                    
                    var spins = [StorySpin]()
                    for SP in storySpinsArray {
                        let newSpin = StorySpin(SP)
                        spins.append(newSpin)
                    }
                    
                    var articles = [StoryArticle]()
                    for A in storyArticles {
                        let newArt = StoryArticle(A)
                        articles.append(newArt)
                    }
                    
                    callback(storyData, facts, spins, articles, version)
                } else {
                    callback(nil, nil, nil, nil, nil)
                }
            }
        }
        task.resume()
    }
    
    private func removeNullFrom(_ node: Any?) -> [[String: Any]] {
        let array = node as! [Any?]
        var filteredArray = [Any?]()
        
        for obj in array {
            if let _ = obj as? [String: Any] {
                filteredArray.append(obj)
            }
        }
        
        //let filteredArray = array.filter { $0 != nil }
        return filteredArray as! [[String: Any]]
    }

    private func getStoryID(slug: String,
        callback: @escaping (String?) -> ()) {
        
        let url = storyID_url + slug
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, resp, error) in
            if let _error = error {
                print(_error.localizedDescription)
                callback(nil)
            } else {
                var strData = String(decoding: data!, as: UTF8.self)
                strData = String(strData.dropFirst())
                strData = String(strData.dropLast())
                let mData = strData.data(using: .utf8)
                
                ShareAPI.LOG_DATA(mData, where: "getStoryID")
                if let json = ShareAPI.json(fromData: mData) {
                    let path = json["path"] as! String
                    let storyID = path.replacingOccurrences(of: "/stories/", with: "")
                    callback(storyID)
                } else {
                    callback(nil)
                }
            }
        }
        task.resume()
    }

    private func extractSlugFrom(url: String) -> String {
        if let _url = URL(string: url), let _domain = _url.host {
            let parts = url.components(separatedBy: _domain)
            if(parts.count>1) {
                return String(parts[1].dropFirst())
            }
        }
        return url
    }
    
}
