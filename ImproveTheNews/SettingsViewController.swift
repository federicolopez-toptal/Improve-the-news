//
//  SettingsViewController.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 5/30/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import UIKit
import LBTATools
import Charts
    
class SettingsViewController: UIViewController {
    
    var safeArea: UILayoutGuide!
    var sliderStack = UIStackView()
    
    var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var sliderValues: SliderValues!
    
    var defaults = [Float]()
    var subtopics: [String] = []
    var popularities: [Float] = []
    var topicString = ""
    
    // pie chart stuff
    var colors = [UIColor]()
    var pieChart = PieChartView()
    
    // to calculate popularities
    var zero: Float = 1.0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        self.colors.removeAll()
        
        // fetches new subtopics
        reload()
        
        // appends new subtopics to stackview
        sliderStack.removeAllArrangedSubviews()
        addSubtopics()
        createSliderPrefs()
        
        defaults = popularities
        
        // make the pie chart
        if subtopics.count > 0 {
            let title = createTitle(name: "Your \(sliderValues.getSubtopics()[0]) feed:")
            sliderStack.insertArrangedSubview(title, at: 0)
            title.adjustsFontSizeToFitWidth = true
            
            createChart()
            
            colorSideBars()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = accentOrange
        
        setupUI()
        
        sliderValues = SliderValues.sharedInstance
    }
}

// UI extension
extension SettingsViewController {
    
    func createSliderPrefs() {
        self.topicString = ""
        for topic in self.subtopics {
            let key = Globals.slidercodes[topic]!
            let val = UserDefaults.getValue(key: key)
            self.topicString += key + String(Int(val))
        }
        
        sliderValues.setTopicPrefs(newString: self.topicString)
    }
    
    func setupUI() {
        self.view.backgroundColor = .systemBackground
        
        navigationItem.title = "Settings"
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.backgroundColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PlayfairDisplay-SemiBold", size: 26)!]

        self.view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
          
        sliderStack.axis = .vertical
        sliderStack.alignment = .fill
        sliderStack.spacing = 0
        sliderStack.distribution = .fill
        scrollView.addSubview(sliderStack)

        sliderStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            sliderStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            sliderStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            sliderStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            sliderStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            sliderStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        self.edgesForExtendedLayout = []
    }
    
    func addSubtopics() {
        
        if subtopics.count > 0 {
            let title = createTitle(name: "Topic Sliders")
            sliderStack.addArrangedSubview(title)
        }
        
        for i in 0..<subtopics.count {
            
            let miniview = UIView()
            miniview.backgroundColor = accentOrange
            sliderStack.addArrangedSubview(miniview)
            miniview.translatesAutoresizingMaskIntoConstraints = false
         
            miniview.heightAnchor.constraint(equalToConstant: 70).isActive = true
            
            let colorBar = UIView(backgroundColor: .gray)
            miniview.addSubview(colorBar)
            colorBar.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                colorBar.leadingAnchor.constraint(equalTo: miniview.leadingAnchor),
                colorBar.topAnchor.constraint(equalTo: miniview.topAnchor),
                colorBar.bottomAnchor.constraint(equalTo: miniview.bottomAnchor),
                colorBar.widthAnchor.constraint(equalToConstant: 24)
            ])
            
            let name = UILabel(text: self.subtopics[i], font: UIFont(name: "OpenSans-Bold", size: 17), textColor: .label, textAlignment: .left, numberOfLines: 2)
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
            slider.isContinuous = true
            slider.tintColor = .black
            slider.addTarget(self, action: #selector(self.topicSliderValueDidChange(_:)), for: .valueChanged)
            slider.tag = i
            slider.isContinuous = false
            
            let topickey = Globals.slidercodes[self.subtopics[i]]
            var v = Float(0)
            if UserDefaults.exists(key: topickey!) {
                v = UserDefaults.getValue(key: topickey!)
            } else {
                v = self.popularities[i]
                UserDefaults.setSliderValue(value: self.popularities[i], slider: topickey!)
            }
            slider.setValue(v, animated: false)
            
            miniview.addSubview(slider)
            slider.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                slider.leadingAnchor.constraint(equalTo: name.trailingAnchor, constant: 5),
                slider.centerYAnchor.constraint(equalTo: miniview.centerYAnchor),
                slider.trailingAnchor.constraint(equalTo: miniview.trailingAnchor, constant: -10)
            ])
        }
        
    }
    
    func reload() {
        self.subtopics.removeAll()
        self.subtopics = sliderValues.getSubtopics()
        
        if self.subtopics.count > 0 {
            self.subtopics.removeFirst()
            
            var pop = sliderValues.getPopularities()
            zero = pop[0]
            pop.removeFirst()
            for i in 0..<pop.count {
                self.popularities.append((pop[i]/zero) * 100)
            }
        }
    }
    
    func createTitle(name: String) -> UILabel {
        let title = UILabel(text: name, font: UIFont(name: "OpenSans-Bold", size: 30), textColor: .label, textAlignment: .left, numberOfLines: 1)
        title.frame = CGRect(x: 15, y: 0, width: 385, height: 60)
        title.backgroundColor = accentOrange
        
        return title
    }
    
    func colorSideBars() {
        for i in 0..<colors.count {
            if let view = view.viewWithTag(i) {
                if let slider = view as? UISlider {
                    
                    let parent = slider.superview
                    let bar = parent?.subviews[0]
                    
                    bar?.backgroundColor = colors[i]
                    
                }
            }
        }
    }
}

// pie chart
extension SettingsViewController {
    // the pie chart
    func createChart() {
        setChart()
        pieChart.backgroundColor = accentOrange
        pieChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 400)
        pieChart.heightAnchor.constraint(equalToConstant: 400).isActive = true
        pieChart.holeColor = accentOrange
        pieChart.legend.enabled = false
        pieChart.drawEntryLabelsEnabled = false
        
        self.sliderStack.insertArrangedSubview(pieChart, at: 1)
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
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<subtopics.count {
            let dataEntry = PieChartDataEntry(value: Double(popularities[i]), label: subtopics[i])
            dataEntries.append(dataEntry)
        }
       
        // Set ChartDataSet
        self.colors.removeAll()
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        //let orangeAccents = colorChart(base: accentOrange)
        self.colors = colorChart(base: .gray)
//        var limit = subtopics.count / 2
//        for i in 0..<subtopics.count {
//           let num = Int.random(in: 0 ..< 1)
//            if num == 0 && limit > 0 {
//                self.colors.append(orangeAccents[i])
//                limit -= 1
//            } else {
//                self.colors.append(blackAccents[i])
//            }
//        }
        
        pieChartDataSet.colors = self.colors
        pieChartDataSet.drawValuesEnabled = false
       
        // Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
       
        pieChart.data = pieChartData
    }
    
    func recalculate(index: Int, newValue: Float) {
        popularities[index] = newValue
        
        let total = popularities.reduce(0, +)
        var new = [Float]()
        for p in popularities {
            new.append((p / total) * 100)
        }
        popularities = new
    }
    
    // automatically readjusts sliders to compensate
    func setSliders() {
        for i in 0..<popularities.count {
            if let view = view.viewWithTag(i) {
                if let slider = view as? UISlider {
                    slider.setValue(popularities[i], animated: false)
                    
                    let parent = slider.superview
                    let label = parent?.subviews[1]
                    
                    if let name = label as? UILabel {
                        let key = Globals.slidercodes[name.text!]
                        UserDefaults.setSliderValue(value: popularities[i], slider: key!)
                       
                    }
                }
            }
        }
    }
    
}

// dealing with slider changes
extension SettingsViewController {
    
    @objc func topicSliderValueDidChange(_ sender: UISlider!){
        let index = sender.tag
        
        recalculate(index: index, newValue: sender.value)
        setSliders()
        setChart()
        
        createSliderPrefs()
                
        print("should've set topic prefs: \(self.sliderValues.getTopicPrefs())")
        
    }
    
}

import SwiftUI
struct SettingsPreview: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<SettingsPreview.ContainerView>) -> UIViewController {
            return UINavigationController(rootViewController: SettingsViewController())
        }
        
        func updateUIViewController(_ uiViewController: SettingsPreview.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<SettingsPreview.ContainerView>) {
            
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
