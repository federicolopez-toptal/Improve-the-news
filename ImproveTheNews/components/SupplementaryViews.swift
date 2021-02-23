//
//  SupplementaryViews.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 8/21/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

protocol shareDelegate {
    func openSharing(items: [String])
}

protocol TopicSliderDelegate {
    func showTopicSliders()
    func topicSliderDidChange()
}

protocol SuperSliderDelegate {
    func updateSuperSliderStr(topic: String, popularity: Float)
    func superSliderDidChange()
}

class SubtopicHeader: UICollectionReusableView {
    
    static let headerId = "subtopicHeader"
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
        button.addTarget(self, action: #selector(goToTopic(_:)), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        
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
    
    
    public func configure() {
        
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
        
    // main orange Title
        //addSubview(label)
        stackView.addArrangedSubview(label)
        //label.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 40),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -80)
        ])
        
        addSubview(topicSlidersButton)
        topicSlidersButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //topicSlidersButton.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            topicSlidersButton.topAnchor.constraint(equalTo: hierarchy.bottomAnchor, constant: 0),
            topicSlidersButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            topicSlidersButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
        ])
        //topicSlidersButton.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        topicSlidersButton.addTarget(self, action: #selector(showTopicSliders(_:)), for: .touchUpInside)
        
        
        //addSubview(topicPriority)
        stackView.addArrangedSubview(topicPriority)
        topicPriority.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topicPriority.heightAnchor.constraint(equalToConstant: 25),
            topicPriority.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            topicPriority.widthAnchor.constraint(equalToConstant: 250)
        ])
        //topicPriority.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        
        
        //addSubview(prioritySlider)
        stackView.addArrangedSubview(prioritySlider)
        prioritySlider.isContinuous = false
        prioritySlider.tintColor = .orange
        prioritySlider.minimumValue = 0
        //prioritySlider.maximumValue = 1
        prioritySlider.setValue(0.5, animated: false)
        prioritySlider.isUserInteractionEnabled = true
        prioritySlider.addTarget(self, action: #selector(self.valueDidChange(_:)), for: .valueChanged)
        
        prioritySlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //prioritySlider.topAnchor.constraint(equalTo: topicPriority.bottomAnchor, constant: 0),
            //prioritySlider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            prioritySlider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            prioritySlider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
        //prioritySlider.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        
        //prioritySlider.isUserInteractionEnabled = false
    }
    
    @objc func goToTopic(_ sender: UIButton!) {
            print("GATO", "click en titulo naranja")
            if label.titleLabel!.text! == "Headlines" {
                self.delegate!.pushNewTopic(newTopic: "news")
            } else {
                let newTopic = Globals.topicmapping[label.titleLabel!.text!]!
                self.delegate!.pushNewTopic(newTopic: newTopic)
            }
        }
    
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        
        guard let text = self.hierarchy.text else { return }
        
        let privacyPolicyRange = (text as NSString).range(of: "Headlines")
        
        print("GATO", "Tap on breadcrumb")
        if gesture.didTapAttributedTextInLabel(label: self.hierarchy, inRange: privacyPolicyRange) {
            print("User tapped on Headlines")
            goToTopic(topic: "news")
        } else {
            print("User tapped on text")
            
            let index = text.index(text.startIndex, offsetBy: 10)
            let remainingText = text[index...]
            let topicsArray = remainingText.components(separatedBy: ">")
            
            var found = false
            for t in topicsArray {
                let topicRange = (text as NSString).range(of: t)
                if gesture.didTapAttributedTextInLabel(label: self.hierarchy, inRange: topicRange) {
                    found = true
                    self.delegate!.pushNewTopic(newTopic: Globals.topicmapping[t]!)
                    break
                }
            }
            
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
        print("popularity: \(num)")
        // calculate slider value
        let x = log10(Double(num) / pmin) / log10(pmax / pmin)
        print("calculated: \(x)")
        
        // update slider
        prioritySlider.setValue(Float(x), animated: false)
        
        // update label
        formatter.numberStyle = .decimal
        formatter.maximumSignificantDigits = 2
        formatter.minimumSignificantDigits = 2
        let rounded = formatter.string(from: num * 100 as NSNumber)!
        topicPriority.text = "represents \(rounded)% of your total news"
    }
    
    @objc func goToTopic(topic: String) {
        // llamado desde el breadcrumb!
        if topic == "news" {
            //add mapping code
            //let newTopic = Globals.topicmapping[withTop]
            self.delegate!.pushNewTopic(newTopic: "news")
        }
    }
    
    @objc func valueDidChange(_ sender: UISlider!) {
        
        let x = Double(sender.value)
        let val = 100 * pmin * exp(x * log(pmax / pmin))
        let rounded = Double(round(10000 * val) / 10000)
        formatter.maximumSignificantDigits = 2
        formatter.minimumSignificantDigits = 2
        let round = formatter.string(from: NSNumber(value: rounded))
        topicPriority.text = "represents \(round!)% of your total news"
        
        let subtopic = label.currentTitle!
        if subtopic == "Headlines" {
            self.ssDelegate?.updateSuperSliderStr(topic: "News", popularity: Float(rounded))
        } else {
            self.ssDelegate?.updateSuperSliderStr(topic: subtopic, popularity: Float(rounded))
        }
        self.ssDelegate?.superSliderDidChange()
    }
    
    @objc func showTopicSliders(_ sender: UIButton!) {
        topicDelegate?.showTopicSliders()
    }
}

class seeMoreFooter: UICollectionReusableView {
    
    static let footerId = "FooterId"
    
    var delegate: TopicSelectorDelegate?
    
    var label = UILabel()
    var button = UIButton(title: "topic", titleColor: accentOrange, font: UIFont(name: "PTSerif-Bold", size: 23)!, backgroundColor: .darkGray, target: self, action: #selector(goToTopic(_:)))
    
    public func configure() {
        
        label.text = "More "
        label.font = UIFont(name: "PTSerif-Bold", size: 23)
        label.textColor = articleSourceColor
        label.sizeToFit()
        label.backgroundColor = .clear
            var mFrame = label.frame
            mFrame.origin.x = (UIScreen.main.bounds.width/2) - mFrame.size.width
            mFrame.origin.y = 20 + 4
            label.frame = mFrame
        addSubview(label)
        
        button.sizeToFit()
        button.backgroundColor = .clear
            mFrame = button.frame
            mFrame.origin.x = (UIScreen.main.bounds.width/2)
            mFrame.origin.y = 13 + 4
            button.frame = mFrame
        addSubview(button)
        
            let w = label.frame.size.width + button.frame.size.width
            let newX = (UIScreen.main.bounds.width - w)/2
            let diffX = newX - label.frame.origin.x
            
            mFrame = label.frame
            mFrame.origin.x += diffX
            label.frame = mFrame
            
            mFrame = button.frame
            mFrame.origin.x += diffX
            button.frame = mFrame
        
        
        /*
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.sizeToFit()
        button.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 12)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            button.heightAnchor.constraint(equalToConstant: 10),
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10)
        ])
        */
        
        /*
        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 10),
            image.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 3),
            image.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
        ])
        */

        addTopBorder()
        self.backgroundColor = bgBlue
    }
    
    func addTopBorder() {
        let border = UIView(frame: CGRect(x: 10, y: 5,
                            width: self.frame.width - 20, height: 1))
        border.backgroundColor = articleSourceColor
        addSubview(border)
    }
    
    func addBottomBorder() {
        let border = UIView(frame: CGRect(x: 10, y: self.frame.height - 5,
                            width: self.frame.width - 20, height: 2))
        border.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        addSubview(border)
    }
    
    public func setFooterText(subtopic: String) {
        button.setTitle(subtopic, for: .normal)
    }
    
    @objc func goToTopic(_ sender: UIButton!) {
        print("GATO", "click en MORE al fondo")
        let buttontext = button.titleLabel!.text!
        let topic = buttontext.replacingOccurrences(of: "MORE ", with: "")
        
        if(Globals.topicmapping[topic] != nil) {
            let newTopic = Globals.topicmapping[topic]!
            self.delegate!.pushNewTopic(newTopic: newTopic)
        }
    }
}

class seeMoreFooterSection0: UICollectionReusableView, UIScrollViewDelegate {
    
    static let footerId = "FooterIdSection0"
    
    var delegate: TopicSelectorDelegate?
    var topics: [String] = []
    
    var label = UILabel()
    var scrollView = UIScrollView()
    var button = UIButton(title: "topic", titleColor: accentOrange, font: UIFont(name: "PTSerif-Bold", size: 23)!, backgroundColor: .darkGray, target: self, action: #selector(goToTopic(_:)))
    
    public func configure() {
        label.text = "More "
        label.font = UIFont(name: "PTSerif-Bold", size: 23)
        label.textColor = articleSourceColor
        label.sizeToFit()
        label.backgroundColor = .clear
            var mFrame = label.frame
            mFrame.origin.x = (UIScreen.main.bounds.width/2) - mFrame.size.width
            mFrame.origin.y = 20
            label.frame = mFrame
        addSubview(label)
        
        button.sizeToFit()
        button.backgroundColor = .clear
            mFrame = button.frame
            mFrame.origin.x = (UIScreen.main.bounds.width/2)
            mFrame.origin.y = 13
            button.frame = mFrame
        addSubview(button)
        
            let w = label.frame.size.width + button.frame.size.width
            let newX = (UIScreen.main.bounds.width - w)/2
            let diffX = newX - label.frame.origin.x
            
            mFrame = label.frame
            mFrame.origin.x += diffX
            label.frame = mFrame
            
            mFrame = button.frame
            mFrame.origin.x += diffX
            button.frame = mFrame
            
          
        //scrollView
        
        scrollView.frame = CGRect(x: 0, y: 62, width: bounds.width, height: 36)
        scrollView.flashScrollIndicators()
        scrollView.delegate = self
        scrollView.backgroundColor = articleSourceColor //.clear
        
        var x = 0
        //for i in 0..<Globals.searchTopics.count {
        //for i in 0..<self.topics.count {
        
        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        for (i, topic) in self.topics.enumerated() {
            if(i==0) {
                continue
            }
        
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            label.textColor = articleHeadLineColor
            label.backgroundColor = articleSourceColor
            label.font = UIFont(name: "Poppins-SemiBold", size: 12)
            label.textAlignment = .center
            label.text = topic.uppercased()
            label.sizeToFit()
            label.isUserInteractionEnabled = false
            
                var mFrame = label.frame
                mFrame.origin.y = 0
                mFrame.origin.x = CGFloat(x)
                mFrame.size.width += 40.0
                mFrame.size.height = 36
                label.frame = mFrame
            
            scrollView.addSubview(label)
            
            let button = UIButton(frame: label.frame)
            button.backgroundColor = .clear
            button.tag = i
            
            button.addTarget(self, action: #selector(scrollViewButtonTapped(_:)), for: .touchUpInside)
            scrollView.addSubview(button)
            x += Int(label.frame.size.width)
            
            scrollView.contentSize = CGSize(width: CGFloat(x), height: scrollView.frame.size.height)
        }
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)

        addTopBorder()
        self.backgroundColor = bgBlue
    }
    
    @objc func scrollViewButtonTapped(_ sender: UIButton!) {
        print("scrollViewButtonTapped")
        self.delegate?.goToScrollView(atSection: sender.tag)
    }
    
    func addTopBorder() {
        let border = UIView(frame: CGRect(x: 10, y: 5,
                            width: self.frame.width - 20, height: 1))
        border.backgroundColor = articleSourceColor
        addSubview(border)
    }
    
    func addBottomBorder() {
        
        let border = UIView(frame: CGRect(x: 10, y: self.frame.height - 5, width: self.frame.width - 20, height: 2))
        border.backgroundColor = .secondaryLabel
        addSubview(border)
    }
    
    public func setFooterText(subtopic: String) {
        button.setTitle(subtopic, for: .normal)
    }
    
    @objc func goToTopic(_ sender: UIButton!) {
        Utils.shared.didTapOnMoreLink = true
        print("GATO", "Click titulo naranja (0)")
        let buttontext = button.titleLabel!.text!
        let topic = buttontext.replacingOccurrences(of: "MORE ", with: "")
        let newTopic = Globals.topicmapping[String(topic)]!
        self.delegate!.pushNewTopic(newTopic: newTopic)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.isDragging) {
            self.delegate?.horizontalScroll(to: scrollView.contentOffset.x)
        }
    }
}

class FAQFooter: UICollectionReusableView {
    
    static let footerId = "FAQId"
    
    var shareDelegate: shareDelegate?
    
    let view = UIView()
    let titleImage = UIImageView(image: UIImage(named: "ITN_logo.png"))
    
    let title = UILabel(text: "Improve the News", font: .boldSystemFont(ofSize: 20), textColor: .label, textAlignment: .center, numberOfLines: 1)
    let about = UILabel()
    /*
    let str = """
    Just as it’s healthier to choose what you eat deliberately than impulsively, it’s more empowering to chose your news diet deliberately on this site than to randomly read what marketers and machine-learning algorithms elsewhere predict that you’ll impulsively click on. You can make these deliberate choices about topic, stance, style, etc. by adjusting the sliders.

    This app was created by MIT student Mindy Long. Its news feed is based on a research research project lead by Prof. Max Tegmark on automated news classification.
    """
    */
    
    let str = "A non-profit news aggregator helping you break out of your filter bubble"
    
    let shareBubble = UILabel(text: "Share with a friend", font: UIFont(name: "OpenSans-Regular", size: 12), textColor: .secondaryLabel, textAlignment: .center, numberOfLines: 1)
    
    let shareIcon = UIButton(image: UIImage(systemName: "square.and.arrow.up")!)
    
    public func configure() {
        
        backgroundColor = bgBlue
        
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        view.addSubview(title)
        view.backgroundColor = bgBlue
        
        view.addSubview(titleImage)
        titleImage.backgroundColor = .clear
        titleImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            titleImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            titleImage.widthAnchor.constraint(equalToConstant: 195),
            titleImage.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        line.backgroundColor = articleSourceColor
        view.addSubview(line)
        
        /*
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont(name: "PlayfairDisplay-SemiBold", size: 38)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 43),
            title.heightAnchor.constraint(equalToConstant: 47),
            title.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        */
        
        about.textAlignment = .left
        about.text = str
        about.font = UIFont(name: "OpenSans-Regular", size: 12)
        about.textColor = UIColor(rgb: 0x737D96)
        about.numberOfLines = 18
        about.adjustsFontSizeToFitWidth = true
        about.sizeToFit()
        
        view.addSubview(about)
        about.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            about.topAnchor.constraint(equalTo: titleImage.bottomAnchor, constant: 20),
            about.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            about.heightAnchor.constraint(equalToConstant: 44),
            about.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width-30)
        ])
        about.backgroundColor = .clear
        
        view.addSubview(shareIcon)
        shareIcon.tintColor = UIColor.white
        shareIcon.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        shareIcon.backgroundColor = accentOrange
        shareIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareIcon.topAnchor.constraint(equalTo: about.bottomAnchor, constant: 20),
            shareIcon.heightAnchor.constraint(equalToConstant: 55),
            shareIcon.widthAnchor.constraint(equalToConstant: 55),
            shareIcon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
        shareIcon.layer.cornerRadius = 0.5 * 55
        
        /*
        view.addSubview(shareBubble)
        shareBubble.translatesAutoresizingMaskIntoConstraints = false
        shareBubble.font = UIFont(name: "OpenSans-Regular", size: 12)
        NSLayoutConstraint.activate([
            shareBubble.topAnchor.constraint(equalTo: shareIcon.bottomAnchor, constant: 15),
            shareBubble.heightAnchor.constraint(equalToConstant: 20),
            shareBubble.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            shareBubble.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15)
        ])
        */
        
    }
    
    @objc func sharePressed(_ sender: UIButton!) {
        let links = ["http://www.improvethenews.org/"]
        shareDelegate?.openSharing(items: links)
    }

}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        textContainer.size.width = label.intrinsicContentSize.width
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (label.intrinsicContentSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        var indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        indexOfCharacter = indexOfCharacter + 0
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
