//
//  NewsParser.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 6/14/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol NewsDelegate {
    func didFinishLoadData(finished: Bool)
    func resendRequest()
}

struct Subtopic {
    let title: String
    let articles: [NewsData]
}

struct Markups {
    let type, description, link: String
}

struct NewsData {
    let source, subtopic, date, title, URL, imgURL, ampStatus, ampURL: String
    let markups: [Markups]
}

class News {
    
    private var source_logos = [
        
        "The Atlantic": "atlantic-logo",
        "Fox News": "foxnews-logo",
        "New York Times": "nyt-logo",
        "WSJ": "wsj-logo"
        
    ]
    
    private var articlesBySection: [String:[NewsData]] = [:]
    
    var newsDelegate: NewsDelegate?
    
    private var topicCount: Int
    private var data: [NewsData]
    private var sectionCounts: [Int]
    private var sectionTitles: [String]
    private var popularities: [Float]
    private var chosenPopularities: [Float]
    private var globalPopularities: [Float]
    private var hierarchy: String
    
    init() {
        
        topicCount = 0
        data = []
        sectionCounts = []
        sectionTitles = []
        popularities = []
        hierarchy = ""
        chosenPopularities = []
        globalPopularities = []
        
    }
    
    private func readJSONFile(forName name: String) {
            
        let url = Foundation.URL(string: name)
        var jsonData: Data?
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }
                        
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                    print("Server error!")
                    self.newsDelegate!.resendRequest()
                return
            }
            
            do {
                jsonData = data!
                self.parse(jsonData: jsonData!)
            }
        }
        task.resume()
    }
    
    private func parse(jsonData: Data) {
        /*
            ** SLIDER CODES [index1 = 0] **
            jsonData[0] = string representing new intune global popularities
            
            ** SUBTOPIC [index1 = 1] **
            jsonData[1] = main page
         
                ** ARTICLE 0 [index2 = 0] **
                jsonData[0][0] = title and stuff
                
                ** ARTICLE 1 [index2 = 0] **
                jsonData[0][1...n] = main page
                    jsonData[0][1...j][0] = source
                    jsonData[0][1...j][1] = date
                    jsonData[0][1...j][2] = URL
                    jsonData[0][1...j][3] = image URL
                    jsonData[0][1...j][4] = AMP status
                    jsonData[0][1...j][5] = AMP URL or empty str
                    jsonData[0][1...j][6] = markups
            
            ** SUBTOPIC 1 **
            jsonData[1...n] = subtopics
                jsonData[1...n][0] = title and stuff
                jsonData[1...n][1...j] = articles in subtopics
                    jsonData[1...n][1...j][0] = source
                    jsonData[1...n][1...j][1] = date
                    jsonData[1...n][1...j][2] = URL
                    jsonData[1...n][1...j][3] = image URL
        */
        print("inside parse")
        
        self.data.removeAll()
        self.sectionCounts.removeAll()
        self.sectionTitles.removeAll()
        self.topicCount = 0
        self.popularities.removeAll()
        self.chosenPopularities.removeAll()
        self.globalPopularities.removeAll()
        self.hierarchy = ""

        do {
            let decodedData = try JSON(data: jsonData)
            //print("data: \(String(decoding: jsonData, as: UTF8.self))")
            for (index1,subtopic):(String, JSON) in decodedData {
                
                if decodedData[1][0][0].stringValue == "INFO" {
                    return
                }
                
                // topic string
                if Int(index1) == 0 {
                    let topicstr = subtopic[0].stringValue
                    
                    // update all topic sliders
                    topicStrToDict(str: topicstr)
                }
                
                // subtopic = each topic segment
                if Int(index1)! > 0 {
                    self.topicCount += 1
                    for (index2, articles):(String, JSON) in subtopic {
                        
                        // [index1][0 (index2)]: topic, display-name, popularities, hierarchy, etc.
                        if Int(index2) == 0 {
                            
                            // first section always has 8 fields
                            /*
                             jsonData[1][0] -- MAIN TOPIC --
                                jsonData[1][0][0] = topic key e.g. "news"
                                jsonData[1][0][1] = lowercase description? e.g. "headline"
                                jsonData[1][0][2] = name to display e.g. "Headline"
                                jsonData[1][0][3] = total articles stored in section? e.g. "headline"
                                jsonData[1][0][4] = 2-letter topic code e.g. "aa"
                                jsonData[1][0][5] = baseline popularity
                                jsonData[1][0][6] = chosen popularity
                                jsonData[1][0][7] = global popularity
                                jsonData[1][0][8] = hierarchy
                             */
                            
                            if Int(index1) == 1 {
                                let subtopic = articles[2].stringValue
                                self.sectionTitles.append(subtopic)
                                self.popularities.append(articles[5].float!) // baseline popularities
                                self.chosenPopularities.append(articles[6].float!) // chosen popularities
                                self.globalPopularities.append(articles[7].float!) // global popularities
                                
                                // go to hierarchy array
                                self.hierarchy = ""
                                for (_, level):(String, JSON) in articles[8] {
                                    self.hierarchy += level[1].stringValue + ">"
                                }
                            }
                            
                            else {
                                let topic = articles[0].stringValue
                                
                                //condition for the Ad section
                                //if topic != "INFO" {
                                    let subtopic = articles[2].stringValue
                                    self.sectionTitles.append(subtopic)
                                    if articles[5].float != nil {
                                        self.popularities.append(articles[5].float!)
                                    }
                                     // baseline popularities
                                    self.chosenPopularities.append(articles[6].float!)// chosen popularities
                                    if articles[7].float != nil {
                                        self.globalPopularities.append(articles[7].float!)
                                    }
                                     // global popularities
                                    
                                    // go to hierarchy array
                                    self.hierarchy = ""
                                    for (_, level):(String, JSON) in articles[8] {
                                        self.hierarchy += level[1].stringValue + ">"
                                    }
                                //}
                                // rest of the sections always have 8 fields
                                /* j > 1
                                 jsonData[j][0] -- MAIN TOPIC --
                                    jsonData[j][0][0] = topic key e.g. "news"
                                    jsonData[j][0][1] = lowercase description? e.g. "headline"
                                    jsonData[j][0][2] = name to display e.g. "Headline"
                                    jsonData[j][0][3] = random num? e.g. "headline"
                                    jsonData[j][0][4] = 2-letter topic code e.g. "aa"
                                    jsonData[j][0][5] = baseline popularity
                                    jsonData[j][0][6] = chosen popularity
                                    jsonData[j][0][7] = global popularity
                                    jsonData[1][0][8] = hierarchy
                                */
                                         
                            }
                
                        }
                        
                        // the articles underneath each subtopic
                        else if Int(index2) != 0 {
                            
                            var count = 0
                            for (_, article):(String, JSON) in articles {
                                /*
                                    articles[0] = source
                                    articles[1] = date
                                    articles[2] = title
                                    articles[3] = source URL
                                    articles[4] = image URL
                                    articles[5] = AMP status: "E" (yes), "N" (none), "P" (phone only)
                                    articles[6] = AMP URL
                                    articles[7] = markups if any
                                 */
                                
                                // get markups first
                                var m: [Markups] = []
                                for (_, markup):(String, JSON) in article[7] {
                                    let one = Markups(type: markup[1].stringValue, description: markup[0].stringValue, link: markup[2].stringValue)
                                    
                                    m.append(one)
                                }
                                
                                let news = NewsData(source: article[0].stringValue, subtopic: articles[1].stringValue, date: article[1].stringValue, title: article[2].stringValue, URL: article[3].stringValue, imgURL: article[4].stringValue, ampStatus: article[5].stringValue, ampURL:article[6].stringValue, markups: m)
                                self.data.append(news)
                                count += 1
                            }
                            
                            self.sectionCounts.append(articles.count)
                        }
                    }
                }
            }
            DispatchQueue.main.async{
                self.newsDelegate!.didFinishLoadData(finished: true)
            }
        } catch let jsonErr {
            print("decoding error")
            print(String(decoding: jsonData, as: UTF8.self))
            print(jsonErr)
        }
    }
    
    func getJSONContents(jsonName: String) {
        readJSONFile(forName: jsonName)
    }
    
    func getNumOfSections() -> Int {
        return self.topicCount
    }
    
    func getArticleCountInSection() -> [Int] {
        return self.sectionCounts
    }
    
    func getArticleCountInSection(section: Int) -> Int {
        return self.sectionCounts[section]
    }
    
    func getSource(index: Int) -> String {
        return self.data[index].source
    }
    
    func getAllTopics() -> [String] {
        return self.sectionTitles
    }
    
    func getTopic(index: Int) -> String {
        return self.sectionTitles[index]
    }
    
    func getTitle(index: Int) -> String {
        return self.data[index].title
    }
    
    func getDate(index: Int) -> String {
        return self.data[index].date
    }
    
    func getURL(index: Int) -> String {
        return self.data[index].URL
    }
     
    func getIMG(index: Int) -> String {
        return self.data[index].imgURL
    }
    
    func getLogo(index: Int) -> String {
        return source_logos[self.data[index].source] ?? "Logo not found"
    }
    
    func getLength() -> Int {
        return self.data.count
    }
    
    func getPopularities() -> [Float] {
        return self.popularities
    }
    
    func getChosenPopularities() -> [Float] {
        return self.chosenPopularities
    }
    
    func getGlobalPopularities() -> [Float] {
        return self.globalPopularities
    }
    
    func getHierarchy() -> String {
        return self.hierarchy
    }
    
    func getAMPStatus(index: Int) -> Bool {
        if self.data[index].ampStatus != "N" {
            return true
        } else {
            return false
        }
    }
    
    func getAMPURL(index: Int) -> String {
        return self.data[index].ampURL
    }
    
    func getMarkups(index: Int) -> [Markups] {
        return self.data[index].markups
    }
}
