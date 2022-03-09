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

struct Story {
    let sources: [String]
}

struct NewsData {
    let source, subtopic, date, title, URL, imgURL, ampStatus, ampURL: String
    let LR, PE: Int
    let countryID: String
    let markups: [Markups]
    let story: Story?
}

let NOTIFICATION_JSON_PARSE_ERROR = Notification.Name("jsonParseError")

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
    private var topicCodes: [String]
    private var sectionTitles: [String]
    private var subTopicsCount: [Int]
    private var popularities: [Float]
    private var chosenPopularities: [Float]
    private var globalPopularities: [Float]
    private var hierarchy: String
    
    private func reArrangeAllData() {
        // desired order
        let orderedTopics = ["headlines", "world", "crime & justice", "science & technology", "education",
            "health", "environment/energy", "military", "politics", "money", "culture", "media",
            "entertainment", "sports"]

        var count = 0
        while(count < orderedTopics.count) {
            let topic = orderedTopics[count]
            let index = self.search(topic, in: self.sectionTitles)
            if(index != -1) {
                self.data.swapAt(count, index)
                self.sectionCounts.swapAt(count, index)
                self.sectionTitles.swapAt(count, index)
                self.popularities.swapAt(count, index)
                self.chosenPopularities.swapAt(count, index)
                self.globalPopularities.swapAt(count, index)
            }
            count += 1
        }
        count = 0
        while(count < self.sectionTitles.count) {
            let topic = self.sectionTitles[count]
            let index = self.search(topic, in: orderedTopics)
            if(index == -1) {
                self.data.rearrange(from: count, to: self.sectionTitles.count-1)
                self.sectionCounts.rearrange(from: count, to: self.sectionTitles.count-1)
                self.sectionTitles.rearrange(from: count, to: self.sectionTitles.count-1)
                self.popularities.rearrange(from: count, to: self.sectionTitles.count-1)
                self.chosenPopularities.rearrange(from: count, to: self.sectionTitles.count-1)
                self.globalPopularities.rearrange(from: count, to: self.sectionTitles.count-1)
            }
            count += 1
        }
    }
    
    // ------------------------------------------------------------------------------------
    private func search(_ number: Int, in array: [Int]) -> Int {
        var result = -1
        for (index, n) in array.enumerated() {
            if(number == n) {
                result = index
                break
            }
        }
        return result
    }
    
    // ------------------------------------------------------------------------------------
    private func search(_ topic: String, in array: [String]) -> Int {
        var result = -1
        
        for (index, currentTopic) in array.enumerated() {
            if(topic.lowercased() == currentTopic.lowercased()) {
                result = index
                break
            }
        }
        return result
    }
    
    
    
    
    
    
    
    
    init() {
        
        topicCount = 0
        data = []
        sectionCounts = []
        topicCodes = []
        sectionTitles = []
        popularities = []
        hierarchy = ""
        chosenPopularities = []
        globalPopularities = []
        subTopicsCount = []
        
    }
    
    private func readJSONFile(forName name: String) {
            
        let url = Foundation.URL(string: name)
        // URL(string: name)
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
        self.topicCodes.removeAll()
        self.topicCount = 0
        self.popularities.removeAll()
        self.chosenPopularities.removeAll()
        self.globalPopularities.removeAll()
        self.hierarchy = ""

        //print(">>>", BannerInfo.shared)

        /*
        let testText = ""
        let jsonData2 = testText.data(using: .utf8)!
        */

        do {
            let decodedData = try JSON(data: jsonData)
            
            for (index1, subtopic):(String, JSON) in decodedData {
                
                //if decodedData[1][0][0].stringValue == "INFO" {
                    if subtopic[0][0].stringValue == "INFO" {
                        if(!Utils.shared.didLoadBanner) {
                            let jsonForBanner = subtopic[0]
                            if(BannerView.bannerIsValid(id: jsonForBanner[5].stringValue)) {
                                BannerInfo.shared = BannerInfo(json: jsonForBanner)
                                Utils.shared.didLoadBanner = true
                            }
                        }
                        
                        continue
                    }

                /*
                print("GATO", index1, subtopic[0][0].stringValue)
                */
                
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
                                
                                let num = articles[3].intValue
                                self.subTopicsCount.append(num)
                                
                                self.topicCodes.append(articles[0].stringValue)
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
                                    
                                    let num = articles[3].intValue
                                    self.subTopicsCount.append(num)
                                    
                                    self.topicCodes.append(articles[0].stringValue)
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
                                
                                let news = NewsData(
                                    source: article[0].stringValue,
                                    subtopic: articles[1].stringValue,
                                    date: article[1].stringValue,
                                    title: article[2].stringValue,
                                    URL: article[3].stringValue,
                                    imgURL: article[4].stringValue,
                                    ampStatus: article[5].stringValue,
                                    ampURL: article[6].stringValue,
                                    LR: article[8].intValue,
                                    PE: article[9].intValue,
                                    countryID: article[10].stringValue,
                                    markups: m,
                                    story: self.buildStory(from: article)
                                )
                                
                                self.data.append(news)
                                count += 1
                            }
                            
                            self.sectionCounts.append(articles.count)
                        }
                    }
                }
            }
            
            //self.reArrangeAllData()
            // test
            /*
            if(BannerInfo.shared == nil) {
                BannerInfo.shared = BannerInfo(test: true)
                Utils.shared.didLoadBanner = true
            }
            */
        
            DispatchQueue.main.async{
                self.newsDelegate!.didFinishLoadData(finished: true)
            }
        } catch let jsonErr {
            print("decoding error")
            print(String(decoding: jsonData, as: UTF8.self))
            print(jsonErr)
            
            DispatchQueue.main.async{
                NotificationCenter.default.post(name: NOTIFICATION_JSON_PARSE_ERROR, object: nil)
            }
        }
        
        
        
    }
    
    func buildStory(from json: JSON) -> Story? {
    
        let storyValue = json[11].stringValue
        if(storyValue.isEmpty){ return nil }
        
        var _sources = [String]()
        for value in json[12].arrayValue {
            _sources.append(value.stringValue)
        }
    
        return Story(sources: _sources)
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
        if(validateSectionIndex(section)) {
            return self.sectionCounts[section]
        } else {
            return 0
        }
    }
    
    // ----------
    private let defaultStrValue = ""
    
    private func validateSectionIndex(_ index: Int) -> Bool {
        var value = true
        if(self.sectionCounts.count==0){
            value = false
        } else if(index<0 || index>=self.sectionCounts.count) {
            value = false
        }
        
        if(!value){ print("GATO section validation FALSE") }
        return value
    }
    
    private func validateDataIndex(_ index: Int) -> Bool {
        var value = true
        if(self.data.count==0){
            value = false
        } else if(index<0 || index>=self.data.count) {
            value = false
        }
        
        if(!value){ print("GATO data validation FALSE") }
        return value
    }
    
    private func validateTopicIndex(_ index: Int) -> Bool {
        var value = true
        if(self.sectionTitles.count==0){
            value = false
        } else if(index<0 || index>=self.sectionTitles.count) {
            value = false
        }
        
        if(!value){ print("GATO topic validation FALSE") }
        return value
    }
    
    // ----------
    func getSource(index: Int) -> String {
        if(validateDataIndex(index)){
            return self.data[index].source
        } else {
            return defaultStrValue
        }
    }
    
    func getAllTopics() -> [String] {
        return self.sectionTitles
    }
    
    func getAllTopicCodes() -> [String] {
        return self.topicCodes
    }
    
    func getTopic(index: Int) -> String {
        if(validateTopicIndex(index)){
            return self.sectionTitles[index]
        } else {
            return defaultStrValue
        }
    }
    
    func getTitle(index: Int) -> String {
        if(validateDataIndex(index)){
            return self.data[index].title
        } else {
            return defaultStrValue
        }
    }
    
    func getStory(index: Int) -> Story? {
        if(validateDataIndex(index)){
            return self.data[index].story
        } else {
            return nil
        }
    }
    
    func getDate(index: Int) -> String {
        if(validateDataIndex(index)){
            return self.data[index].date
        } else {
            return defaultStrValue
        }
    }
    
    func getURL(index: Int) -> String {
        if(validateDataIndex(index)){
            return self.data[index].URL
        } else {
            return defaultStrValue
        }
    }
     
    func getIMG(index: Int) -> String {
        if(validateDataIndex(index)){
            return self.data[index].imgURL
        } else {
            return defaultStrValue
        }
    }
    
    func getLogo(index: Int) -> String {
        if(validateDataIndex(index)){
            return source_logos[self.data[index].source] ?? "Logo not found"
        } else {
            return defaultStrValue
        }
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
        if(validateDataIndex(index)){
            if self.data[index].ampStatus != "N" {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func getAMPURL(index: Int) -> String {
        if(validateDataIndex(index)){
            return self.data[index].ampURL
        } else {
            return defaultStrValue
        }
    }
    
    func getMarkups(index: Int) -> [Markups] {
        if(validateDataIndex(index)){
            return self.data[index].markups
        } else {
            return []
        }
    }
    
    func getLR(index: Int) -> Int {
        if(validateDataIndex(index)){
            return self.data[index].LR
        } else {
            return 1
        }
    }
    
    func getPE(index: Int) -> Int {
        if(validateDataIndex(index)){
            return self.data[index].PE
        } else {
            return 1
        }
    }
    
    func getCountryID(index: Int) -> String {
        if(validateDataIndex(index)){
            return self.data[index].countryID
        } else {
            return ""
        }
    }
    
    private func getSubTopicsCount(index: Int) -> Int {
        if(validateDataIndex(index)){
            return self.subTopicsCount[index]
        } else {
            return -1
        }
    }
    func getSubTopicCountFor(topic: String) -> Int {
        var index = -1
        for (i, txt) in self.sectionTitles.enumerated() {
            if(txt == topic) {
                index = i
                break
            }
        }
        if(index == -1) {
            return -1
        } else {
            return self.getSubTopicsCount(index: index)
        }
    }
    
}


extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}
