////
////  PieChartViewController.swift
////  ImproveTheNews
////
////  Created by Federico Lopez on 05/04/2021.
////  Copyright © 2021 Mindy Long. All rights reserved.
////
//
//import Foundation
//import UIKit
//import Charts
//
//
//protocol PieChartViewControllerDelegate {
//    func someValueDidChange()
//}
//
//
//class PieChartViewController: UIViewController {
//
//    let SHOW_VALUE_LABEL = false
//
//    var delegate: PieChartViewControllerDelegate?
//
//    private var topicForTitle = ""
//    private var topics = [String]()
//    private var popularities = [Float]()
//    
//    var pieChart = PieChartView()
//    
//    var scrollView: UIScrollView = {
//        let v = UIScrollView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
//
//    var mainVStack: UIStackView = {
//        let v = UIStackView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
//
//    let titleLabel = UILabel(text: "", font: UIFont(name: "PTSerif-Bold", size: 24), textColor: .white, textAlignment: .left, numberOfLines: 1)
//
//    let dismiss = UIButton(image: UIImage(systemName: "xmark.circle.fill")!,
//        tintColor: .white, target: self,
//        action: #selector(handleDismiss))
//
//    let allcolors: [UIColor] = [UIColor(rgb: 0xc60b42), UIColor(rgb: 0xc980f1), UIColor(rgb: 0xe45552), UIColor(rgb: 0xc133203), UIColor(rgb: 0xc727ba9), UIColor(rgb: 0xcd987c), UIColor(rgb: 0xb908dd), UIColor(rgb: 0x441ff2), UIColor(rgb: 0xac3ce5), UIColor(rgb: 0x8f0a4e), UIColor(rgb: 0x975c4b), UIColor(rgb: 0x6ffd2e), UIColor(rgb: 0x5e7b6b), UIColor(rgb: 0x172eb6), UIColor(rgb: 0xc45c5e), UIColor(rgb: 0x2e68c6), UIColor(rgb: 0xff0000), UIColor(rgb: 0x0000ff)]
//
//
//
//
//
//
//    
//
//
//
//    // MARK: Initialization
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = accentOrange
//    }
//    
//    private func build_UI() {
//    
//    // scrolLView
//        scrollView.subviews.forEach({ $0.removeFromSuperview() })
//        self.view.addSubview(scrollView)
//    
//        //scrollView.backgroundColor = .green
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//        ])
//    
//    // vStack
//        mainVStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        mainVStack.backgroundColor = accentOrange
//        mainVStack.axis = .vertical
//        mainVStack.alignment = .fill
//        mainVStack.spacing = 0
//        mainVStack.distribution = .fillProportionally
//    
//        scrollView.addSubview(mainVStack)
//        mainVStack.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            mainVStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            mainVStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            mainVStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
//            mainVStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
//        ])
//        
//    // header
//        let header = UIView()
//        mainVStack.addArrangedSubview(header)
//        header.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            header.leadingAnchor.constraint(equalTo: mainVStack.leadingAnchor, constant: 10),
//            header.trailingAnchor.constraint(equalTo: mainVStack.trailingAnchor, constant: -10),
//            header.heightAnchor.constraint(equalToConstant: 40)
//        ])
//    
//    // header / title
//        titleLabel.text = "Your \(self.topicForTitle) feed:"
//        titleLabel.adjustsFontSizeToFitWidth = true
//        header.addSubview(titleLabel)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -50),
//            titleLabel.topAnchor.constraint(equalTo: header.topAnchor),
//            titleLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor)
//        ])
//        
//    // header / dismiss
//        header.addSubview(dismiss)
//        dismiss.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            dismiss.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
//            dismiss.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -10),
//            dismiss.topAnchor.constraint(equalTo: mainVStack.topAnchor, constant: 10)
//        ])
//    
//    // chart
//        self.setChartData()
//    
//        pieChart.backgroundColor = accentOrange
//        pieChart.holeColor = accentOrange
//        pieChart.legend.enabled = true
//        pieChart.legend.orientation = .horizontal
//        pieChart.legend.horizontalAlignment = .center
//        pieChart.legend.font = UIFont(name: "Poppins-SemiBold", size: 12)!
//        pieChart.legend.textColor = .white
//        pieChart.drawEntryLabelsEnabled = false
//        mainVStack.addArrangedSubview(pieChart)
//        
//        //add(pieChart, at: 1)
//        pieChart.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            pieChart.leadingAnchor.constraint(equalTo: mainVStack.leadingAnchor),
//            pieChart.trailingAnchor.constraint(equalTo: mainVStack.trailingAnchor),
//            pieChart.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width - 40)
//        ])
//        
//    // Title (2)
//    let title2Label = UILabel(text: "Topic Sliders", font: UIFont(name: "PTSerif-Bold", size: 24), textColor: .white, textAlignment: .left, numberOfLines: 1)
//    mainVStack.addArrangedSubview(title2Label)
//        
//    // Each item (topic) listed
//        var total: Float = 0
//        let colors = Array(self.allcolors[..<self.topics.count])
//        for (i, topic) in self.topics.enumerated() {
//            
//            let topicView = UIView()
//            mainVStack.addArrangedSubview(topicView)
//            topicView.translatesAutoresizingMaskIntoConstraints = false
//            topicView.backgroundColor = accentOrange
//            topicView.isUserInteractionEnabled = true
//            NSLayoutConstraint.activate([
//                topicView.leadingAnchor.constraint(equalTo: mainVStack.leadingAnchor),
//                topicView.trailingAnchor.constraint(equalTo: mainVStack.trailingAnchor),
//                topicView.heightAnchor.constraint(equalToConstant: 70)
//            ])
//            
//            let colorBar = UIView(backgroundColor: colors[i])
//            topicView.addSubview(colorBar)
//            colorBar.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                colorBar.leadingAnchor.constraint(equalTo: topicView.leadingAnchor),
//                colorBar.topAnchor.constraint(equalTo: topicView.topAnchor),
//                colorBar.bottomAnchor.constraint(equalTo: topicView.bottomAnchor),
//                colorBar.widthAnchor.constraint(equalToConstant: 24)
//            ])
//            
//            let name = UILabel(text: topic, font: UIFont(name: "Poppins-SemiBold", size: 12), textColor: .white, textAlignment: .left, numberOfLines: 2)
//            name.adjustsFontSizeToFitWidth = true
//            topicView.addSubview(name)
//            name.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                name.leadingAnchor.constraint(equalTo: colorBar.trailingAnchor, constant: 5),
//                name.topAnchor.constraint(equalTo: topicView.topAnchor),
//                name.bottomAnchor.constraint(equalTo: topicView.bottomAnchor),
//                name.widthAnchor.constraint(equalToConstant: 150)
//            ])
//            
//            let valueLabel = UILabel(text: "00", font: UIFont(name: "Poppins-SemiBold", size: 12), textColor: UIColor.white.withAlphaComponent(0.5), textAlignment: .right, numberOfLines: 2)
//            valueLabel.adjustsFontSizeToFitWidth = true
//            topicView.addSubview(valueLabel)
//            valueLabel.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                valueLabel.leadingAnchor.constraint(equalTo: colorBar.trailingAnchor, constant: 5),
//                valueLabel.topAnchor.constraint(equalTo: topicView.topAnchor),
//                valueLabel.bottomAnchor.constraint(equalTo: topicView.bottomAnchor),
//                valueLabel.widthAnchor.constraint(equalToConstant: 150)
//            ])
//            valueLabel.tag = i + 200
//            valueLabel.text = self.formatValue(self.popularities[i])
//            valueLabel.alpha = 0
//            
//            total += self.popularities[i]
//            
//            let slider = UISlider(backgroundColor: accentOrange)
//            slider.minimumValue = 0
//            slider.maximumValue = 99
//            slider.tintColor = .black
//            slider.addTarget(self, action: #selector(sliderValueDidChange(_:)),
//                            for: .valueChanged)
//            slider.tag = i + 100
//            
//            slider.isContinuous = false
//            //slider.setValue(self.popularities[i], animated: false)
//            slider.setValue(self.popularities[i], animated: false)
//            
//            topicView.addSubview(slider)
//            slider.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                slider.leadingAnchor.constraint(equalTo: name.trailingAnchor, constant: 10),
//                slider.centerYAnchor.constraint(equalTo: topicView.centerYAnchor),
//                slider.trailingAnchor.constraint(equalTo: topicView.trailingAnchor, constant: -10)
//            ])
//        }
//        print("GATO6 total:", total)
//        print("GATO6 -----------------")
//    }
//
//    // MARK: - Some event/action(s)
//    @objc func sliderValueDidChange(_ sender: UISlider!){
//    
//        let i = sender.tag - 100
//    
//        // update label value
//        let valueLabel = sender.superview?.viewWithTag(i + 200) as! UILabel
//        valueLabel.text = self.formatValue(sender.value)
//        
//        let prevValue = self.popularities[i]
//        let newValue = sender.value
//        let diff = newValue - prevValue
//        let change = (diff / Float(self.popularities.count-1)) * -1
//        
//        self.popularities[i] = sender.value
//        for (j, p) in self.popularities.enumerated() {
//            if(j != i) {
//                var newValue = self.popularities[j] + change
//                if(newValue < 0.0) {
//                    newValue = 0
//                }
//                self.popularities[j] = newValue
//            }
//            
//            let value = self.popularities[j]
//            
//            if let slider = self.view.viewWithTag(j + 100) as? UISlider {
//                slider.value = value
//            }
//            if let label = self.view.viewWithTag(j + 200) as? UILabel {
//                label.text = self.formatValue(value)
//            }
//        }
//        self.setChartData()
//        
//        
//        for (i, t) in self.topics.enumerated() {
//            if let key = Globals.slidercodes[t] {
//                self.setValueForKey(key, value: self.popularities[i])
//            }
//        }
//        
//        self.delegate?.someValueDidChange()
//    }
//    
//    @objc func handleDismiss() {
//        self.dismiss(animated: true) {
//        }
//    }
//    
//    // MARK: - misc
//    private func formatValue(_ value: Float) -> String {
//        return String(format: "%.2f", value)
//    }
//    private func printPopularities() {
//        let index = 6
//        for (i, p) in self.popularities.enumerated() {
//            print("GATO\(index) \(i): \(p)")
//        }
//        print("GATO\(index) -------------------")
//    }
//    
//    // MARK: - Data
//    func set(topics: [String], popularities: [Float]) {
//        self.topicForTitle = topics.first!
//        
//        self.topics = topics
//        self.topics.removeFirst()
//        
//        self.popularities = popularities
//        self.popularities.removeFirst()
//        
//        var total: Float = 0
//        for p in self.popularities {
//            total += p
//        }
//
//        var tmp: Float = 0
//        for (i, p) in self.popularities.enumerated() {
//            let val = (p * 100)/total
//            self.popularities[i] = val
//            
//            tmp += val
//        }
//        
//        sortData()
//        build_UI()
//    }
//    
//    private func setChartData() {
//        var dataEntries: [ChartDataEntry] = []
//        
//        for (i, topic) in self.topics.enumerated() {
//            let value = self.popularities[i]
//            let entry = PieChartDataEntry(value: Double(value), label: topic)
//            dataEntries.append(entry)
//        }
//        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
//        
//        pieChartDataSet.colors = Array(self.allcolors[..<self.topics.count])
//        pieChartDataSet.drawValuesEnabled = false
//        
//        let pieChartData = PieChartData(dataSet: pieChartDataSet)
//        let format = NumberFormatter()
//        format.numberStyle = .none
//        let formatter = DefaultValueFormatter(formatter: format)
//        pieChartData.setValueFormatter(formatter)
//        pieChart.data = pieChartData
//    }
//    
//    private func sortData() {
//        // Sort by popularities
//        var dict = [String: Float]()
//        for (i, topic) in self.topics.enumerated() {
//            dict[topic] = self.popularities[i]
//        }
//        let sortedElements = dict.sorted {
//            return $0.value > $1.value
//        }
//        
//        self.topics.removeAll()
//        self.popularities.removeAll()
//        for e in sortedElements {
//            let top = e.key
//            let pop = e.value
//            
//            self.topics.append(top)
//            self.popularities.append(pop)
//        }
//    }
//    
//    // MARK: - UserDefaults
//    private func existValueForKey(_ key: String) -> Bool {
//        if(UserDefaults.standard.object(forKey: key) == nil) {
//            return false
//        } else {
//            let val = UserDefaults.standard.float(forKey: key)
//            if(val<0.0) {
//                return false
//            } else {
//                return true
//            }
//        }
//    }
//    
//    private func valueForKey(_ key: String) -> Float {
//        return UserDefaults.standard.float(forKey: key)
//    }
//    
//    private func setValueForKey(_ key: String, value: Float) {
//        UserDefaults.standard.set(value, forKey: key)
//        UserDefaults.standard.synchronize()
//    }
//}
