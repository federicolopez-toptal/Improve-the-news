//
//  TopicSliders.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 8/26/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation
import UIKit
import Charts

protocol dismissTopicSlidersDelegate {
    func handleDismissTopicSliders()
}

class TopicSliderPopup: UIView {
    
    var sliderValues: SliderValues!
    var mustSort = true
    
    var sliderStack: UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var sliderDelegate: TopicSliderDelegate? //change
    var shadeDelegate: ShadeDelegate?
    var dismissDelegate: dismissTopicSlidersDelegate?
    
    var defaults = [Float]()
    
    var subtopics: [String] = []
    var popularities: [Float] = []
    
    var topicString = ""
    
    // pie chart stuff
    let allcolors: [UIColor] = [UIColor(rgb: 0xc60b42), UIColor(rgb: 0xc980f1), UIColor(rgb: 0xe45552), UIColor(rgb: 0xc133203), UIColor(rgb: 0xc727ba9), UIColor(rgb: 0xcd987c), UIColor(rgb: 0xb908dd), UIColor(rgb: 0x441ff2), UIColor(rgb: 0xac3ce5), UIColor(rgb: 0x8f0a4e), UIColor(rgb: 0x975c4b), UIColor(rgb: 0x6ffd2e), UIColor(rgb: 0x5e7b6b), UIColor(rgb: 0x172eb6), UIColor(rgb: 0xc45c5e), UIColor(rgb: 0x2e68c6), UIColor(rgb: 0xff0000), UIColor(rgb: 0x0000ff)]
    var usedColors = [UIColor]()
//    var pieChart = PieChartView()
    var colorMapping: [String : UIColor] = [:]
    
    // to calculate popularities
    var zero: Float = 1.0
    
    // universal button
    let dismiss = UIButton(image: UIImage(systemName: "xmark.circle.fill")!, tintColor: .white, target: self, action: #selector(handleDismiss))
    
    func msg(_ text: String) {
        print("GATO3", text)
    }
    func msg(_ text: String, _ array: [Any]) {
        print("GATO3", text, array)
    }
    
    
    func loadVariables() {
        msg("LOAD VARS")
        
        sliderValues = SliderValues.sharedInstance
        //self.usedColors.removeAll()
        
        // fetches new subtopics
        reload()
            
        // cleaning current view
        //sliderStack.removeAllArrangedSubviews()
        sliderStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // repopulating view
        if subtopics.count > 0 {
            
            let header = UIView()
            sliderStack.insertArrangedSubview(header, at: 0)
            header.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                header.leadingAnchor.constraint(equalTo: sliderStack.leadingAnchor, constant: 10),
                header.trailingAnchor.constraint(equalTo: sliderStack.trailingAnchor, constant: -10),
                header.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            if(sliderValues.getSubtopics()[0] != nil) {
                let title = createTitle(name: "Your \(sliderValues.getSubtopics()[0]) feed:")
                title.adjustsFontSizeToFitWidth = true
                
                header.addSubview(title)
                title.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    title.leadingAnchor.constraint(equalTo: header.leadingAnchor),
                    title.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -50),
                    title.topAnchor.constraint(equalTo: header.topAnchor),
                    title.bottomAnchor.constraint(equalTo: header.bottomAnchor)
                ])
                
                
                header.addSubview(dismiss)
                dismiss.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    dismiss.leadingAnchor.constraint(equalTo: title.trailingAnchor),
                    dismiss.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -10),
                    dismiss.topAnchor.constraint(equalTo: sliderStack.topAnchor, constant: 10)
                ])
                
                let total = popularities.reduce(0, +)
                let factor: Float
                if total < 99 {
                    factor = 100 / total
                    
                    popularities = popularities.map { $0 * factor }
                }
                
                // make the pie chart
                createChart()
                colorSideBars()
            }
        }

    }
}

// MARK: UI Setup
extension TopicSliderPopup {
    
    func buildViews() {
        
        msg("BUILD VIEWS")
        sliderValues = SliderValues.sharedInstance
        
        self.layer.cornerRadius = 20
        self.layer.shadowRadius = 12
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 10)
        
        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        sliderStack.axis = .vertical
        sliderStack.alignment = .fill
        sliderStack.spacing = 0
        sliderStack.distribution = .fillProportionally
        
        scrollView.addSubview(sliderStack)
        sliderStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sliderStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            sliderStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            sliderStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            sliderStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
        //sliderStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // title + "x" out button
        let controls = UIView()
        sliderStack.addArrangedSubview(controls)
        controls.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controls.leadingAnchor.constraint(equalTo: sliderStack.leadingAnchor, constant: 10),
            controls.trailingAnchor.constraint(equalTo: sliderStack.trailingAnchor, constant: -10),
            controls.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        if subtopics.count > 0 {
            let title = createTitle(name: "Topic Sliders")
            title.textColor = .label
            
            controls.addSubview(title)
            title.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                title.leadingAnchor.constraint(equalTo: controls.leadingAnchor, constant: 10),
                title.trailingAnchor.constraint(equalTo: controls.trailingAnchor, constant: -50)
            ])
        }
        
        let total = popularities.reduce(0, +)
        let factor: Float
        if total < 99 {
            factor = 100 / total
            
            popularities = popularities.map { $0 * factor }
        }
        
        for i in 0..<subtopics.count {
            
            let miniview = UIView()
            sliderStack.addArrangedSubview(miniview)
            miniview.translatesAutoresizingMaskIntoConstraints = false
            miniview.backgroundColor = accentOrange
            miniview.isUserInteractionEnabled = true
            
            NSLayoutConstraint.activate([
                miniview.leadingAnchor.constraint(equalTo: sliderStack.leadingAnchor),
                miniview.trailingAnchor.constraint(equalTo: sliderStack.trailingAnchor),
                miniview.heightAnchor.constraint(equalToConstant: 70)
            ])
            
            let colorBar = UIView(backgroundColor: .gray)
            miniview.addSubview(colorBar)
            colorBar.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                colorBar.leadingAnchor.constraint(equalTo: miniview.leadingAnchor),
                colorBar.topAnchor.constraint(equalTo: miniview.topAnchor),
                colorBar.bottomAnchor.constraint(equalTo: miniview.bottomAnchor),
                colorBar.widthAnchor.constraint(equalToConstant: 24)
            ])
            
            let name = UILabel(text: self.subtopics[i], font: UIFont(name: "Poppins-SemiBold", size: 12), textColor: .label, textAlignment: .left, numberOfLines: 2)
            name.adjustsFontSizeToFitWidth = true
            miniview.addSubview(name)
            name.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                name.leadingAnchor.constraint(equalTo: colorBar.trailingAnchor, constant: 5),
                name.topAnchor.constraint(equalTo: miniview.topAnchor),
                name.bottomAnchor.constraint(equalTo: miniview.bottomAnchor),
                name.widthAnchor.constraint(equalToConstant: 150)
            ])
            
            
            let slider = UISlider(backgroundColor: accentOrange)
            slider.minimumValue = 0
            slider.maximumValue = 99
            slider.tintColor = .black
            slider.addTarget(self, action: #selector(self.topicSliderValueDidChange(_:)), for: .valueChanged)
            slider.tag = i + 100
            slider.isContinuous = false
            
            let topickey = Globals.slidercodes[self.subtopics[i]]
            var v = Float(0)
            
            if topickey != nil {
                if UserDefaults.exists(key: topickey!) {
                    v = UserDefaults.getValue(key: topickey!)
                } else {
                    if(i<self.popularities.count) {
                        v = self.popularities[i]
                        UserDefaults.setSliderValue(value: self.popularities[i], slider: topickey!)
                    } else {
                        v = 0
                    }
                }
                slider.setValue(v, animated: false)
            }

            
            miniview.addSubview(slider)
            slider.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                slider.leadingAnchor.constraint(equalTo: name.trailingAnchor, constant: 10),
                slider.centerYAnchor.constraint(equalTo: miniview.centerYAnchor),
                slider.trailingAnchor.constraint(equalTo: miniview.trailingAnchor, constant: -10)
            ])
            
        }
        
        colorSideBars()
        //colorSideBars()
        
        let swipeView = UIView()
        swipeView.backgroundColor = .clear
        self.addSubview(swipeView)
        swipeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            swipeView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            swipeView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -60),
            swipeView.topAnchor.constraint(equalTo: self.topAnchor),
            swipeView.heightAnchor.constraint(equalToConstant: 65)
        ])
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleDismiss))
        swipe.direction = .down
        swipeView.addGestureRecognizer(swipe)
        
        self.layoutIfNeeded()
    }
    
    func createTitle(name: String) -> UILabel {
        let title = UILabel(text: name, font: UIFont(name: "PTSerif-Bold", size: 24), textColor: .label, textAlignment: .left, numberOfLines: 1)
        
        return title
    }
    
    func colorSideBars() {
        
        for i in 0..<usedColors.count {
            let tag = i + 100
            if let view = self.viewWithTag(tag) {
                if let slider = view as? UISlider {
                    let parent = slider.superview
                    let bar = parent?.subviews[0]
                    
                    bar?.backgroundColor = self.usedColors[i]
                    
                }
            }
        }
    }
}

// MARK: Functionality
extension TopicSliderPopup {
    
    func reload() {
        
        let sliderPopularities = sliderValues.getPopularities()
        if abs(sliderPopularities.count - self.popularities.count) > 1 || (self.subtopics.count == self.popularities.count && self.subtopics.count == 0) {
        
            self.subtopics.removeAll()
            self.subtopics = sliderValues.getSubtopics()
            self.popularities = sliderPopularities.map { $0 * 100 }
            
            if self.subtopics.count > 1 && self.subtopics.count == self.popularities.count {
                self.subtopics.removeFirst()
                self.popularities.removeFirst()
            }
        }
        
        
        
        
        //print("GATO6", mustSort)
        if(mustSort) {
        /*
            // sort by popularities
            var dict = [String: Float]()
            for (i, topic) in self.subtopics.enumerated() {
                dict[topic] = self.popularities[i]
            }
            print("GATO6", dict)
            let sortedElements = dict.sorted {
                return $0.value > $1.value
            }
            print("GATO6", dict)
            
            self.subtopics.removeAll()
            self.popularities.removeAll()
            for e in sortedElements {
                let sTopic = e.key
                let pop = e.value
                
                self.subtopics.append(sTopic)
                self.popularities.append(pop)
            }
            */
        }
        //print("GATO6", self.subtopics)
        //print("GATO6", self.popularities)
        //print("GATO6", "--------------")
        
        
        

    }
    
}

// MARK: User interaction
extension TopicSliderPopup {
    @objc func handleDismiss() {
        dismissDelegate?.handleDismissTopicSliders()
    }
    
    @objc func topicSliderValueDidChange(_ sender:UISlider!){
        mustSort = false
        
        let index = sender.tag - 100
        let newValue: Float
        
        if sender.value > 1 {
            newValue = sender.value
        } else {
            newValue = 1
        }
        
        recalculate(index: index, newValue: newValue)
        setSliders()
        print("should've set sliders")
        setChart()
        print("should've set chart")
        
        sliderDelegate?.topicSliderDidChange()
    }
}

// MARK: PIE CHART
extension TopicSliderPopup {
    
    // the pie chart
    func createChart() {
//        setChart() // set data
//        pieChart.backgroundColor = accentOrange
//        pieChart.holeColor = accentOrange
//        pieChart.legend.enabled = true
//        pieChart.legend.orientation = .horizontal
//        pieChart.legend.horizontalAlignment = .center
//        pieChart.legend.font = UIFont(name: "Poppins-SemiBold", size: 12)!
//        pieChart.drawEntryLabelsEnabled = false
//
//        self.sliderStack.insertArrangedSubview(pieChart, at: 1)
//        pieChart.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            pieChart.leadingAnchor.constraint(equalTo: sliderStack.leadingAnchor),
//            pieChart.trailingAnchor.constraint(equalTo: sliderStack.trailingAnchor),
//            pieChart.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width - 40)
//        ])
    }
   
    func colorChart(base: UIColor) -> [UIColor] {
       
        var c: [UIColor] = []
        for _ in 0..<subtopics.count {
            let num = Int.random(in: -60 ..< 60)
            let color = base.adjust(by: CGFloat(num))
            c.append(color!)
        }
       
        return c
    }
   
    func setChart() {
        
        // Set ChartDataEntry
//        var dataEntries: [ChartDataEntry] = []
//
//        // get subtopic data if exists else default to popularities
//        var v: Float
//        for i in 0..<subtopics.count {
//            let topickey = Globals.slidercodes[self.subtopics[i]]
//
//            if topickey != nil {
//                if UserDefaults.exists(key: topickey!) {
//                    v = UserDefaults.getValue(key: topickey!)
//                } else {
//                    if(i<self.popularities.count) {
//                        v = self.popularities[i]
//                        UserDefaults.setSliderValue(value: self.popularities[i], slider: topickey!)
//                    } else {
//                        v = 0
//                    }
//                }
//                let dataEntry = PieChartDataEntry(value: Double(v), label: subtopics[i])
//                dataEntries.append(dataEntry)
//            }
//        }
//
        /*
        for de in dataEntries {
            print( "GATO5", (de as! PieChartDataEntry).label )
        }
        */
        
        
        
        
        /*
        dataEntries.sort {
            $0.y < $1.y
 //           ($0 as! PieChartDataEntry).value < ($1 as! PieChartDataEntry).value
        }
        */
        
        
        
        /*
        for de in dataEntries {
            print( "GATO5", (de as! PieChartDataEntry).label )
        }
        */
        
        // Set ChartDataSet
//        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
//        //let orangeAccents = colorChart(base: accentOrange)
//        //self.colors = colorChart(base: .gray)
//        
//        // first time loading this pie chart
//        let n = self.subtopics.count
//        self.usedColors = Array(self.allcolors[..<n])
//
//        pieChartDataSet.colors = usedColors
//        pieChartDataSet.drawValuesEnabled = false
//        
//        // Set ChartData
//        let pieChartData = PieChartData(dataSet: pieChartDataSet)
//        let format = NumberFormatter()
//        format.numberStyle = .none
//        let formatter = DefaultValueFormatter(formatter: format)
//        pieChartData.setValueFormatter(formatter)
//        
//        pieChart.data = pieChartData
       
    }
    
    func recalculate(index: Int, newValue: Float) {
        print("old popularities: \(popularities)")
        popularities[index] = newValue
        
        let total = popularities.reduce(0, +)
        var new = [Float]()
        for p in popularities {
            if (p / total) * 100 >= 1 {
                new.append((p / total) * 100)
            } else { new.append(1) }
        }
        popularities = new
        print("new popularities: \(popularities)")
        sliderValues.setPopularities(popularities: popularities)
    }
    
    // automatically readjusts sliders to compensate
    func setSliders() {
        if(popularities.count==0) { return }
    
        for i in 0..<popularities.count {
            let tag = i + 100
            if let view = self.viewWithTag(tag) {
                if let slider = view as? UISlider {
                    slider.setValue(popularities[i], animated: false)
                    
                    let parent = slider.superview
                    let label = parent?.subviews[1]
                    
                    if let name = label as? UILabel {
                        if let key = Globals.slidercodes[name.text!] {
                            UserDefaults.setSliderValue(value: popularities[i], slider: key)
                            print("Successfully set \(self.subtopics[i]) \(key) to \(UserDefaults.getValue(key: key)) ")
                        }
                    }
                }
            }
        }
    }
    
    func mapSubtopicsToColors() {
        for i in 0..<subtopics.count {
            colorMapping[subtopics[i]] = usedColors[i]
        }
    }
    
}

extension UIColor {
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}

extension UIStackView {
    @discardableResult
    func removeAllArrangedSubviews() -> [UIView] {
        return arrangedSubviews.reduce([UIView]()) { $0 + [removeArrangedSubViewProperly($1)] }
    }

    func removeArrangedSubViewProperly(_ view: UIView) -> UIView {
        removeArrangedSubview(view)
        NSLayoutConstraint.deactivate(view.constraints)
        view.removeFromSuperview()
        return view
    }
}
