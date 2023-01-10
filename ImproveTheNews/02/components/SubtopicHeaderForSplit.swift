//
//  SubtopicHeaderForSplit.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 25/06/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

class SubtopicHeaderForSplit: UICollectionReusableView {
    
    static let headerId = "subtopicHeaderForSplit"
    var delegate: TopicSelectorDelegate?
    var topicDelegate: TopicSliderDelegate?
    var ssDelegate: SuperSliderDelegate?
    
    var label: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Title >", for: .normal)
        button.setTitleColor(accentOrange, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont(name: "PTSerif-Bold", size: 40)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(goToTopic(_:)), for: .touchUpInside)
        //button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        return button
    }()
    
    var topicSlidersButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "piechart"), for: .normal)
        button.setTitleColor(accentOrange, for: .normal)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(showTopicSliders(_:)), for: .touchUpInside)
        return button
    }()
    
    var hierarchy: UILabel = {
        let h = UILabel(text: "", font: UIFont(name: "Poppins-SemiBold", size: 13), textColor: articleSourceColor, textAlignment: .left, numberOfLines: 1)
        return h
    }()
    
    var topicPriority: UILabel = {
        let h = UILabel(text: "Represents 15.29% of your total news", font: UIFont(name: "OpenSans-Bold", size: 11), textColor: .secondaryLabel, textAlignment: .left, numberOfLines: 1)
        return h
    }()
    
    var prioritySlider: UISlider = {
        let slider = CustomSlider(backgroundColor: .clear)
        return slider
    }()
    let pmin = 0.00001
    let pmax = 0.9
    let formatter = NumberFormatter()
    
    var stackView = UIStackView()
    var stackViewSplit = UIStackView()
    
    public func configure(_ stancevalues: (Bool, Bool), section: Int) {
        
        backgroundColor = .systemBackground
        addSubview(stackView)
        
        stackView.frame = self.frame
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.distribution = .fillProportionally
        //stackView.backgroundColor = UIColor.green.withAlphaComponent(0.2)


    // Breadcrumbs
        hierarchy.isUserInteractionEnabled = true
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        self.hierarchy.addGestureRecognizer(tapgesture)
        
        //addSubview(hierarchy)
        stackView.addArrangedSubview(hierarchy)
        //hierarchy.backgroundColor = UIColor.green.withAlphaComponent(0.4)
        hierarchy.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hierarchy.heightAnchor.constraint(equalToConstant: 20),
            hierarchy.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            hierarchy.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
        //self.hierarchy.backgroundColor = .red
        
        self.hierarchy.textColor = DARKMODE() ? articleSourceColor : textBlackAlpha
        
    // main orange Title
        //addSubview(label)
        stackView.addArrangedSubview(label)
        //label.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 36),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
        
        
        
        //var stackViewSplit = UIStackView()
        stackViewSplit.subviews.forEach({ $0.removeFromSuperview() })
        
        stackView.addArrangedSubview(stackViewSplit)
        stackViewSplit.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackViewSplit.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            stackViewSplit.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            stackViewSplit.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
            stackViewSplit.heightAnchor.constraint(equalToConstant: 50)
        ])
        stackViewSplit.axis = .horizontal
        //stackViewSplit.backgroundColor = UIColor.green.withAlphaComponent(0.25)
        stackViewSplit.alignment = .fill
        stackViewSplit.spacing = 0
        stackViewSplit.distribution = .fillProportionally
        
        for i in 1...2 {
            var labelSplit = UILabel()
            
            if(stancevalues.0) {
                // POLITICAL
                if(i==1){ labelSplit.text = "LEFT" }
                else { labelSplit.text = "RIGHT" }
            } else {
                // ESTABLISHMENT
                if(i==1){ labelSplit.text = "CRITICAL" }
                else { labelSplit.text = "PRO" }
            }
            
            //labelSplit.tag = 44 + i
            labelSplit.textAlignment = .center
            labelSplit.font = UIFont(name: "PTSerif-Bold", size: 20)
            
            /*
            if(i==1){
                labelSplit.backgroundColor = UIColor.yellow.withAlphaComponent(0.2)
            } else {
                labelSplit.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
            }*/
            
            labelSplit.textColor = .white
            if(!DARKMODE()){ labelSplit.textColor = textBlackAlpha }
            
            //label.backgroundColor = DARKMODE() ? articleSourceColor :
            stackViewSplit.addArrangedSubview(labelSplit)
            
            
            let labelWidth: CGFloat = (UIScreen.main.bounds.width - 20)/2
            labelSplit.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                labelSplit.widthAnchor.constraint(equalToConstant: labelWidth),
            ])
            
            if(MorePrefsViewController.showStories()) {
                if(section != 0){ labelSplit.textColor = .clear }
            }
        }
        
        
    if(APP_CFG_SHOW_PIE_CHART) {
        // -------
        addSubview(topicSlidersButton)
        topicSlidersButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //topicSlidersButton.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            topicSlidersButton.topAnchor.constraint(equalTo: label.topAnchor, constant: 10),
            topicSlidersButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            topicSlidersButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
        ])
        //topicSlidersButton.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        topicSlidersButton.addTarget(self, action: #selector(showTopicSliders(_:)), for: .touchUpInside)
        // -------
    }
        
        //addSubview(topicPriority)
        stackView.addArrangedSubview(topicPriority)
        topicPriority.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topicPriority.heightAnchor.constraint(equalToConstant: 25),
            topicPriority.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            topicPriority.widthAnchor.constraint(equalToConstant: 250)
        ])
        //topicPriority.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        
        if(APP_CFG_SHOW_SUPER_SLIDERS) {
        //addSubview(prioritySlider)
        stackView.addArrangedSubview(prioritySlider)
        prioritySlider.isContinuous = true
        prioritySlider.tintColor = .orange
        prioritySlider.minimumValue = 0
        //prioritySlider.maximumValue = 1
        prioritySlider.setValue(0.5, animated: false)
        prioritySlider.isUserInteractionEnabled = true
        
        prioritySlider.addTarget(self, action: #selector(self.valueDidChange(_:)), for: .valueChanged)
        prioritySlider.addTarget(self, action: #selector(self.sliderOnRelease(_:)), for: .touchUpInside)
        prioritySlider.addTarget(self, action: #selector(self.sliderOnRelease(_:)), for: .touchUpOutside)
        
        prioritySlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //prioritySlider.topAnchor.constraint(equalTo: topicPriority.bottomAnchor, constant: 0),
            //prioritySlider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            prioritySlider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            prioritySlider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
        //prioritySlider.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        
        prioritySlider.isUserInteractionEnabled = true
        //label.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        }
    }
    
    @objc func goToTopic(_ sender: UIButton!) {
            if label.titleLabel!.text! == "Headlines" {
                self.delegate!.pushNewTopic(newTopic: "news")
            } else {
                let newTopic = Globals.topicmapping[label.titleLabel!.text!]!
                self.delegate!.pushNewTopic(newTopic: newTopic)
            }
        }
    
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        
        guard let text = self.hierarchy.text else { return }
        if(text=="  ") {
            return
        }
        
        let firstTopic = text.components(separatedBy: ">").first!
        let _range = (text as NSString).range(of: firstTopic)
        //let _range = (text as NSString).range(of: "Headlines")
        
        if gesture.didTapAttributedTextInLabel(label: self.hierarchy, inRange: _range) {
            print("User tapped on first topic")
            goToTopic(topic: firstTopic) ///BUG
        } else {
            print("User tapped on text")
            
            let index = text.index(text.startIndex, offsetBy: firstTopic.count+1)
            let remainingText = text[index...]
            let topicsArray = remainingText.components(separatedBy: ">")
            
            var found = false
            for t in topicsArray {
                let topicRange = (text as NSString).range(of: t)
                
                ///BUG
                if gesture.didTapAttributedTextInLabel(label: self.hierarchy, inRange: topicRange) {
                    found = true
                    self.delegate!.pushNewTopic(newTopic: Globals.topicmapping[t]!)
                    break
                }
            }
            
            /// BUG
            if(!found) {
                let t = topicsArray[0]
                self.delegate!.pushNewTopic(newTopic: Globals.topicmapping[t]!)
            }

            /*
            let newTopic = Globals.topicmapping[topicsArray[0]]
            print("GATO3", newTopic)
            self.delegate!.pushNewTopic(newTopic: newTopic!)
            */
        }
    }
    
    public func setHeaderText(subtopic: String) {
        label.setTitle(subtopic, for: .normal)
    }
    
    public func setFont(size: CGFloat) {
        label.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: size)
    }
    
    func updateSuperSlider(num: Float) {
        //print("GATO", num)
        var percentage = Int(num * 100)
        //print("GATO", percentage)
        //print("GATO -----------------")
    
        /*
        print("popularity: \(num)")
        // calculate slider value
        let x = log10(Double(num) / pmin) / log10(pmax / pmin)
        print("calculated: \(x)")
        
        // update slider
        //prioritySlider.setValue(Float(x), animated: false)
        prioritySlider.setValue(num, animated: false)
        
        // update label
        formatter.numberStyle = .decimal
        formatter.maximumSignificantDigits = 2
        formatter.minimumSignificantDigits = 2
        let rounded = formatter.string(from: num * 100 as NSNumber)!
        topicPriority.text = "represents \(rounded)% of your total news"
        */
        
        //print("GATO", prioritySlider.value, num, rounded)
        
        //if(percentage>99){ percentage = 99 }
        
        prioritySlider.setValue(num, animated: false)
        topicPriority.text = "represents \(percentage)% of your total news"
        
        // !!!
        //topicPriority.alpha = 0.0
        topicPriority.isHidden = true
    }
    
    @objc func goToTopic(topic: String) {
        /*
        if topic == "news" {
            //add mapping code
            //let newTopic = Globals.topicmapping[withTop]
            self.delegate!.pushNewTopic(newTopic: "news")
        }
        */
        
        let topicCode = Globals.topicmapping[topic]!
        self.delegate?.pushNewTopic(newTopic: topicCode)
    }
    
    @objc func sliderOnRelease(_ sender: UISlider) {
        self.ssDelegate?.superSliderDidChange()
    }
    
    
    @objc func valueDidChange(_ sender: UISlider!) {
        let newValue = sender.value
        var percentage = newValue * 100
        //if(percentage>99){ percentage = 99 }
        
        formatter.maximumSignificantDigits = 3
        formatter.minimumSignificantDigits = 2
        let round = formatter.string(from: NSNumber(value: Int(percentage)))
        topicPriority.text = "represents \(round!)% of your total news"
        
        // !!!!
        //topicPriority.alpha = 0.0
        topicPriority.isHidden = true
        
        let subtopic = label.currentTitle!
        var valueForApi = percentage
        if(valueForApi < 0){ valueForApi = 0 }
        if(valueForApi > 99){ valueForApi = 99 }
        
        if subtopic == "Headlines" {
            self.ssDelegate?.updateSuperSliderStr(topic: "News", popularity: Float(valueForApi))
        } else {
            self.ssDelegate?.updateSuperSliderStr(topic: subtopic, popularity: Float(valueForApi))
        }
        
        
        
    /*
        let x = Double(sender.value)
        let val = 100 * pmin * exp(x * log(pmax / pmin))
        let rounded = Double(round(10000 * val) / 10000)
        formatter.maximumSignificantDigits = 2
        formatter.minimumSignificantDigits = 2
        let round = formatter.string(from: NSNumber(value: rounded))
        topicPriority.text = "represents \(round!)% of your total news"
        
        var valueForApi = x * 100
        if(valueForApi < 0){ valueForApi = 0 }
        if(valueForApi > 99){ valueForApi = 99 }
        
        let subtopic = label.currentTitle!
        if subtopic == "Headlines" {
            self.ssDelegate?.updateSuperSliderStr(topic: "News", popularity: Float(valueForApi))
        } else {
            self.ssDelegate?.updateSuperSliderStr(topic: subtopic, popularity: Float(valueForApi))
        }
        
        print("GATO", sender.value)
        print("GATO", val, round!)
        print("GATO", valueForApi)
        print("GATO ----------------")
        
        // hago esto en otro evento
        //self.ssDelegate?.superSliderDidChange()
        
        */
    }
    
    @objc func showTopicSliders(_ sender: UIButton!) {
        topicDelegate?.showTopicSliders()
    }
    
}
