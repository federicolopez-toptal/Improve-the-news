//
//  SliderValues.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 7/3/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation

class SliderValues: NSObject {
    
    static let sharedInstance = SliderValues()
    
    private var LR: Int
    private var PE: Int
    private var NU: Int
    private var DE: Int
    private var SL: Int
    private var RE: Int
    private var topic: String
    private var currentArticle: String
    private var numOfSections: Int
    private var currentSubtopics: [String]
    private var popularities: [Float]
    private var topics: [String: Int]
    private var topicString: String
    
    private override init() {
        if UserDefaults.exists(key: "LeRi") {
            LR = Int(UserDefaults.getValue(key: "LeRi"))
        } else {
            LR = 50
        }
        
        if UserDefaults.exists(key: "proest") {
            PE = Int(UserDefaults.getValue(key: "proest"))
        } else {
            PE = 50
        }
        
        if UserDefaults.exists(key: "nuance") {
            NU = Int(UserDefaults.getValue(key: "nuance"))
        } else {
            NU = 70
        }
        
        if UserDefaults.exists(key: "depth") {
            DE = Int(UserDefaults.getValue(key: "depth"))
        } else {
            DE = 70
        }
        
        if UserDefaults.exists(key: "shelflife") {
            SL = Int(UserDefaults.getValue(key: "shelflife"))
        } else {
            SL = 70
        }
        
        if UserDefaults.exists(key: "recency") {
            RE = Int(UserDefaults.getValue(key: "recency"))
        } else {
            RE = 70
        }
        
        topic = "news"
        currentArticle = ""
        numOfSections = 1
        currentSubtopics = []
        popularities = []
        topics = [:]
        topicString = ""
    }
    
    func refresh() {
        if UserDefaults.exists(key: "LeRi") {
            LR = Int(UserDefaults.getValue(key: "LeRi"))
        } else {
            LR = 50
        }
        
        if UserDefaults.exists(key: "proest") {
            PE = Int(UserDefaults.getValue(key: "proest"))
        } else {
            PE = 50
        }
        
        if UserDefaults.exists(key: "nuance") {
            NU = Int(UserDefaults.getValue(key: "nuance"))
        } else {
            NU = 70
        }
        
        if UserDefaults.exists(key: "depth") {
            DE = Int(UserDefaults.getValue(key: "depth"))
        } else {
            DE = 70
        }
        
        if UserDefaults.exists(key: "shelflife") {
            SL = Int(UserDefaults.getValue(key: "shelflife"))
        } else {
            SL = 70
        }
        
        if UserDefaults.exists(key: "recency") {
            RE = Int(UserDefaults.getValue(key: "recency"))
        } else {
            RE = 70
        }

        /*
        topic = "news"
        currentArticle = ""
        numOfSections = 1
        currentSubtopics = []
        popularities = []
        topics = [:]
        topicString = ""
        */
        
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "reloadArticles"),
            object: nil
        )
    }
    
    func setLR(LR: Int) {
        self.LR = LR
    }
    
    func setPE(PE: Int) {
        self.PE = PE
    }
    
    func setNU(NU: Int) {
        self.NU = NU
    }
    
    func setDE(DE: Int) {
        self.DE = DE
    }
    
    func setSL(SL: Int) {
        self.SL = SL
    }
    
    func setRE(RE: Int) {
        self.RE = RE
    }
    
    func setTopic(topic: String) {
        self.topic = topic
    }
    
    func setCurrentArticle(article: String) {
        self.currentArticle = article
    }
    
    func setSectionCount(num: Int) {
        self.numOfSections = num
    }
    
    func setSubtopics(subtopics: [String]) {
        self.currentSubtopics = subtopics
    }
    
    func setPopularities(popularities: [Float]) {
        self.popularities = popularities
    }
    
    func addSubtopic(topic: String, value: Int) {
        self.topics[topic] = value
    }
    
    func clearSubtopics() {
        self.topics.removeAll()
    }
    
    func getLR() -> Int {
        return self.LR
    }
    
    func getPE() -> Int {
        return self.PE
    }
    
    func getNU() -> Int {
        return self.NU
    }
    
    func getDE() -> Int {
        return self.DE
    }
    
    func getSL() -> Int {
        return self.SL
    }
    
    func getRE() -> Int {
        return self.RE
    }
    
    func getTopic() -> String {
        return self.topic
    }
    
    func getCurrentArticle() -> String {
        return self.currentArticle
    }
    
    func getSectionCount() -> Int {
        return self.numOfSections
    }
    
    func getSubtopics() -> [String] {
        return self.currentSubtopics
    }
    
    func getPopularities() -> [Float] {
        return self.popularities
    }
    
    func getTopicPrefs() -> [String:Int] {
        return self.topics
    }

    func getBiasPrefs() -> String {
        let LRstr = "&sliders=LR" + String(format: "%02d", self.LR)
        let PEstr = "PE" + String(format: "%02d", self.PE)
        let NUstr = "NU" + String(format: "%02d", self.NU)
        let DEstr = "DE" + String(format: "%02d", self.DE)
        let SLstr = "SL" + String(format: "%02d", self.SL)
        let REstr = "RE" + String(format: "%02d", self.RE)
        
        //print("bias prefs: \(LRstr + PEstr + NUstr + DEstr + SLstr + REstr)")
        return LRstr + PEstr + NUstr + DEstr + SLstr + REstr
    }

}
