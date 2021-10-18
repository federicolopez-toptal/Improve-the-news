//
//  OnBoardingView.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 30/08/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit
import SwiftUI

///////////////////////////////////////////////////////
let NOTIFICATION_FOR_ONBOARDING_NEWS_LOADED = Notification.Name("forOnboardingNewsLoaded")
let NOTIFICATION_CLOSE_ONBOARDING_FROM_OUTSIDE = Notification.Name("closeOnboardingFromOutside")

struct SimplestNews {
    var title: String
    var sourceTime: String
    var imageUrl: String
    var articleUrl: String
}

///////////////////////////////////////////////////////
protocol OnBoardingViewDelegate {
    func onBoardingClose()
}

///////////////////////////////////////////////////////
class OnBoardingView: UIView {

    var delegate: OnBoardingViewDelegate? 
    static let headlinesType1_height: CGFloat = 204
    
    var view1 = UIView()
    var view2 = UIView()
    var view3 = OnBoardingView3()
    var parser: News?
    
    var topic: String?
    var sliderValues: String?
    var currentStep: logEventStep = .step1_invitation
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(container: UIView, parser: News, skipFirstStep: Bool = false,
        topic: String = "news", sliderValues: String = "") {
        
        print("???", "ONBOARDING INIT")
        self.topic = topic
        self.sliderValues = sliderValues
        
        self.parser = parser
        super.init(frame: .zero)
        self.backgroundColor = bgBlue
        
        container.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: container.topAnchor),
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        //self.addTestButton()
        self.createView1()
        self.createView2()
        self.createView3()
        
        //self.testSteps() // !!!
        NotificationCenter.default.addObserver(self, selector: #selector(onNewsLoaded),
            name: NOTIFICATION_FOR_ONBOARDING_NEWS_LOADED, object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(closeFromOutside),
            name: NOTIFICATION_CLOSE_ONBOARDING_FROM_OUTSIDE, object: nil)
            
        if(skipFirstStep) {
            self.view1.isHidden = true
            self.view2.isHidden = false
            self.logEvent(type: .started, step: .step2_lackControl)
            
            DELAY(1.0) { // 2
                self.showView3()
            }
            
            self.alpha = 0.0
            UIView.animate(withDuration: 0.2) {
                self.alpha = 1.0
            }
        } else {
            self.alpha = 0.0
            UIView.animate(withDuration: 0.7) {
                self.alpha = 1.0
                self.currentStep = .step1_invitation
                self.logEvent(type: .started, step: .step1_invitation)
            }
        }
    }
    
    private func testSteps() {
        self.view1.isHidden = true
        self.view2.isHidden = true
        self.view3.isHidden = false
    }


    // MARK: - View1 /////////////////////////
    private func createView1() {
        var offset: CGFloat = 0
    
        self.view1.backgroundColor = self.backgroundColor
        self.addSubview(view1)
        
        view1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view1.topAnchor.constraint(equalTo: self.topAnchor),
            view1.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view1.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view1.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        offset = -32
        offset -= SAFE_AREA()!.bottom
        let showMeButton = OrangeRoundedButton(title: "SHOW ME!")
        self.view1.addSubview(showMeButton)
        showMeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showMeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            showMeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            showMeButton.heightAnchor.constraint(equalToConstant: 50),
            showMeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: offset)
        ])
        
        showMeButton.addTarget(self, action: #selector(showView2(_:)),
                for: .touchUpInside)
        
        ///////////////////////////////////////////////////
        let label1 = UILabel()
        label1.numberOfLines = 2
        label1.text = "It looks like you’re new here.\nWould you like a tour?"
        label1.textAlignment = .center
        label1.textColor = UIColor(rgb: 0x93A0B4)
        label1.font = UIFont(name: "Roboto-Regular", size: 20)
        if(IS_ZOOMED()){ label1.font = UIFont(name: "Roboto-Regular", size: 16) }
        
        offset = SAFE_AREA()!.bottom
        if(offset==0){ offset = 34 }
        self.view1.addSubview(label1)
        label1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label1.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label1.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -offset)
        ])
        
        ///////////////////////////////////////////////////
        let button1 = UIButton(type: .custom)
        button1.setTitle("NO THANKS.", for: .normal)
        button1.setTitleColor(accentOrange, for: .normal)
        button1.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16)
        if(IS_ZOOMED()){ button1.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 14) }
        button1.addTarget(self, action: #selector(closeButtonOnTap(_:)),
                for: .touchUpInside)
        
        self.view1.addSubview(button1)
        button1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button1.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            button1.widthAnchor.constraint(equalTo: label1.widthAnchor),
            button1.heightAnchor.constraint(equalToConstant: 40),
            button1.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 20)
        ])
    }
    
    
    // MARK: - View2 /////////////////////////
    private func createView2() {
        
        self.view2.backgroundColor = self.backgroundColor
        self.addSubview(view2)
        view2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view2.topAnchor.constraint(equalTo: self.topAnchor),
            view2.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view2.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view2.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        let label1 = UILabel()
        label1.textColor = .white
        label1.font = UIFont(name: "Merriweather-Bold", size: 30)
        label1.text = "Headlines"
        self.view2.addSubview(label1)
        label1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label1.topAnchor.constraint(equalTo: self.topAnchor,
                    constant: 22),
            label1.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                    constant: 15),
        ])
        
        let headline1 = OnBoardingView.headlinesType1_dynamic()
        self.view2.addSubview(headline1)
        headline1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headline1.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 16),
            headline1.leadingAnchor.constraint(equalTo: self.view2.leadingAnchor),
            headline1.trailingAnchor.constraint(equalTo: self.view2.trailingAnchor),
            headline1.heightAnchor.constraint(equalToConstant: OnBoardingView.headlinesType1_height)
        ])
        headline1.tag = 100
        if(self.parser != nil) {
            self.showNews(headline: headline1, indexes: [0, 1])
        }
        
        let headline2 = OnBoardingView.headlinesType1_dynamic()
        self.view2.addSubview(headline2)
        headline2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headline2.topAnchor.constraint(equalTo: headline1.bottomAnchor, constant: 4),
            headline2.leadingAnchor.constraint(equalTo: self.view2.leadingAnchor),
            headline2.trailingAnchor.constraint(equalTo: self.view2.trailingAnchor),
            headline2.heightAnchor.constraint(equalToConstant: OnBoardingView.headlinesType1_height)
        ])
        headline2.tag = 200
        if(self.parser != nil) {
            self.showNews(headline: headline2, indexes: [2, 3])
        }
        
        self.view2.isHidden = true
    }
    
    @objc func showView2(_ sender: UIButton?) {
        self.logEvent(type: .completed, step: self.currentStep)
        self.view2.alpha = 0
        self.view2.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.view2.alpha = 1
        } completion: { _ in
            self.view1.isHidden = true
            DELAY(0.5) { // 1
                self.showView3()
            }
        }
    }
    
    @objc func showView3() {
        self.view3.alpha = 0
        self.view3.isHidden = false
        if(SAFE_AREA()!.bottom>0){
            self.view3.showStep3()
        }

        UIView.animate(withDuration: 0.7) {
            self.view3.alpha = 1
        } completion: { _ in
            self.view2.isHidden = true
            if(SAFE_AREA()!.bottom==0) {
                self.view3.showStep3_animated()
            }
        }
    }


    // MARK: - View3 /////////////////////////
    private func createView3() {
        self.view3.insertInto(container: self, parser: self.parser,
            topic: self.topic!, sliderValues: self.sliderValues!)
        
        self.view3.isHidden = true
        self.view3.delegate = self
    }
    
    
    // MARK: - Components
    static func headlinesType1() -> UIView {
        let result = UIView()
        
        let screenSize = UIScreen.main.bounds.size
        var w: CGFloat = screenSize.width - 30
        let h: CGFloat = (401 * w)/1335
        
        let pics = UIImageView(image: UIImage(named: "headlines01"))
        result.addSubview(pics)
        pics.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pics.topAnchor.constraint(equalTo: result.topAnchor),
            pics.leadingAnchor.constraint(equalTo: result.leadingAnchor, constant: 15),
            pics.widthAnchor.constraint(equalToConstant: w),
            pics.heightAnchor.constraint(equalToConstant: h)
        ])

        w = (screenSize.width/2)-30
        let title1 = UILabel()
        title1.text = "The pros and cons of wind power"
        title1.textColor = .white
        title1.numberOfLines = 2
        title1.font = UIFont(name: "Poppins-SemiBold", size: 14)
        if(IS_ZOOMED()){ title1.font = UIFont(name: "Poppins-SemiBold", size: 12) }
        result.addSubview(title1)
        title1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title1.topAnchor.constraint(equalTo: pics.bottomAnchor, constant: 6),
            title1.leadingAnchor.constraint(equalTo: result.leadingAnchor, constant: 15),
            title1.widthAnchor.constraint(equalToConstant: w),
        ])
        
        let subText = UILabel()
        subText.text = "TechCrunch • 25 minutes ago"
        subText.textColor = UIColor.white.withAlphaComponent(0.2)
        subText.numberOfLines = 2
        subText.font = UIFont(name: "Poppins-SemiBold", size: 12)
        if(IS_ZOOMED()){ subText.font = UIFont(name: "Poppins-SemiBold", size: 10) }
        result.addSubview(subText)
        subText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subText.topAnchor.constraint(equalTo: title1.bottomAnchor, constant: 6),
            subText.leadingAnchor.constraint(equalTo: result.leadingAnchor, constant: 15),
            subText.widthAnchor.constraint(equalToConstant: w),
        ])
        
        let title2 = UILabel()
        title2.text = "Recent trends in world energy use"
        title2.textColor = .white
        title2.numberOfLines = 2
        title2.font = UIFont(name: "Poppins-SemiBold", size: 14)
        result.addSubview(title2)
        title2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title2.topAnchor.constraint(equalTo: pics.bottomAnchor, constant: 6),
            title2.trailingAnchor.constraint(equalTo: result.trailingAnchor, constant: -15),
            title2.widthAnchor.constraint(equalToConstant: w),
        ])
        
        let subText2 = UILabel()
        subText2.text = "NY Times • 4 hours ago"
        subText2.textColor = UIColor.white.withAlphaComponent(0.2)
        subText2.numberOfLines = 2
        subText2.font = UIFont(name: "Poppins-SemiBold", size: 12)
        result.addSubview(subText2)
        subText2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subText2.topAnchor.constraint(equalTo: title2.bottomAnchor, constant: 6),
            subText2.trailingAnchor.constraint(equalTo: result.trailingAnchor, constant: -15),
            subText2.widthAnchor.constraint(equalToConstant: w),
        ])

        return result
    }
    
    static func headlinesType1_dynamic() -> UIView {
        let result = UIView()
        
        let screenSize = UIScreen.main.bounds.size
        var w: CGFloat = screenSize.width - 30
        let h: CGFloat = (401 * w)/1335
        
        w = (screenSize.width/2)-30
        let pic1 = UIImageView()
        pic1.backgroundColor = .gray
        pic1.layer.cornerRadius = 15.0
        pic1.clipsToBounds = true
        result.addSubview(pic1)
        pic1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pic1.topAnchor.constraint(equalTo: result.topAnchor),
            pic1.leadingAnchor.constraint(equalTo: result.leadingAnchor, constant: 15),
            pic1.widthAnchor.constraint(equalToConstant: w),
            pic1.heightAnchor.constraint(equalToConstant: h)
        ])
        pic1.tag = 101
        
        let title1 = UILabel()
        title1.text = "The pros and cons of wind power"
        title1.textColor = .white
        title1.numberOfLines = 2
        title1.font = UIFont(name: "Poppins-SemiBold", size: 14)
        if(IS_ZOOMED()){ title1.font = UIFont(name: "Poppins-SemiBold", size: 12) }
        result.addSubview(title1)
        title1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title1.topAnchor.constraint(equalTo: pic1.bottomAnchor, constant: 6),
            title1.leadingAnchor.constraint(equalTo: result.leadingAnchor, constant: 15),
            title1.widthAnchor.constraint(equalToConstant: w),
        ])
        title1.tag = 102
        
        let subText = UILabel()
        subText.text = "TechCrunch • 25 minutes ago"
        subText.textColor = UIColor.white.withAlphaComponent(0.2)
        subText.numberOfLines = 2
        subText.font = UIFont(name: "Poppins-SemiBold", size: 12)
        if(IS_ZOOMED()){ subText.font = UIFont(name: "Poppins-SemiBold", size: 10) }
        result.addSubview(subText)
        subText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subText.topAnchor.constraint(equalTo: title1.bottomAnchor, constant: 6),
            subText.leadingAnchor.constraint(equalTo: result.leadingAnchor, constant: 15),
            subText.widthAnchor.constraint(equalToConstant: w),
        ])
        subText.tag = 103
        
        let pic2 = UIImageView()
        pic2.backgroundColor = .gray
        pic2.layer.cornerRadius = pic1.layer.cornerRadius
        pic2.clipsToBounds = true
        result.addSubview(pic2)
        pic2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pic2.topAnchor.constraint(equalTo: result.topAnchor),
            pic2.trailingAnchor.constraint(equalTo: result.trailingAnchor, constant: -15),
            pic2.widthAnchor.constraint(equalToConstant: w),
            pic2.heightAnchor.constraint(equalToConstant: h)
        ])
        pic2.tag = 201
        
        let title2 = UILabel()
        title2.text = "Recent trends in world energy use"
        title2.textColor = .white
        title2.numberOfLines = 2
        title2.font = UIFont(name: "Poppins-SemiBold", size: 14)
        result.addSubview(title2)
        title2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title2.topAnchor.constraint(equalTo: pic1.bottomAnchor, constant: 6),
            title2.trailingAnchor.constraint(equalTo: result.trailingAnchor, constant: -15),
            title2.widthAnchor.constraint(equalToConstant: w),
        ])
        title2.tag = 202
        
        let subText2 = UILabel()
        subText2.text = "NY Times • 4 hours ago"
        subText2.textColor = UIColor.white.withAlphaComponent(0.2)
        subText2.numberOfLines = 2
        subText2.font = UIFont(name: "Poppins-SemiBold", size: 12)
        result.addSubview(subText2)
        subText2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subText2.topAnchor.constraint(equalTo: title2.bottomAnchor, constant: 6),
            subText2.trailingAnchor.constraint(equalTo: result.trailingAnchor, constant: -15),
            subText2.widthAnchor.constraint(equalToConstant: w),
        ])
        subText2.tag = 203

        // Loading...
        let loadingView = UIView()
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        loadingView.layer.cornerRadius = 15
        result.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: result.topAnchor, constant: 30),
            loadingView.centerXAnchor.constraint(equalTo: result.centerXAnchor),
            loadingView.widthAnchor.constraint(equalToConstant: 65),
            loadingView.heightAnchor.constraint(equalToConstant: 65)
        ])
        loadingView.layer.borderWidth = 3.0
        loadingView.layer.borderColor = UIColor.black.withAlphaComponent(0.25).cgColor
        
        let loading = UIActivityIndicatorView(style: .medium)
        loading.color = .white
        loadingView.addSubview(loading)
        loading.center = CGPoint(x: 65/2, y: 65/2)
        loading.startAnimating()
        
        loadingView.tag = 444
        loadingView.isHidden = true
        
        // Splitted view ##########################################
        let splittedView = UIView()
        splittedView.backgroundColor = .clear
        result.addSubview(splittedView)
        splittedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            splittedView.topAnchor.constraint(equalTo: result.topAnchor),
            splittedView.leadingAnchor.constraint(equalTo: result.leadingAnchor),
            splittedView.trailingAnchor.constraint(equalTo: result.trailingAnchor),
            splittedView.bottomAnchor.constraint(equalTo: result.bottomAnchor)
        ])
        result.sendSubviewToBack(splittedView)
        
        let divLine = UIView()
        divLine.backgroundColor = .white
        splittedView.addSubview(divLine)
        divLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divLine.centerXAnchor.constraint(equalTo: splittedView.centerXAnchor),
            divLine.topAnchor.constraint(equalTo: splittedView.topAnchor, constant: -60),
            divLine.widthAnchor.constraint(equalToConstant: 1.0),
            divLine.heightAnchor.constraint(equalToConstant: OnBoardingView.headlinesType1_height + 60)
        ])
        
        let halfScreen = UIScreen.main.bounds.size.width / 2
        var headersTopOffset: CGFloat = -50
        if(SAFE_AREA()!.bottom == 0){ headersTopOffset = -32 }
        
        let label1 = UILabel()
        label1.textColor = .white
        label1.font = UIFont(name: "Merriweather-Bold", size: 22)
        label1.text = "LEFT"
        label1.textAlignment = .center
        splittedView.addSubview(label1)
        label1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label1.topAnchor.constraint(equalTo: splittedView.topAnchor,
                    constant: headersTopOffset),
            label1.widthAnchor.constraint(equalToConstant: halfScreen),
            label1.leadingAnchor.constraint(equalTo: splittedView.leadingAnchor)
        ])
        
        let label2 = UILabel()
        label2.textColor = .white
        label2.font = UIFont(name: "Merriweather-Bold", size: 22)
        label2.text = "RIGHT"
        label2.textAlignment = .center
        splittedView.addSubview(label2)
        label2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label2.topAnchor.constraint(equalTo: splittedView.topAnchor,
                    constant: headersTopOffset),
            label2.widthAnchor.constraint(equalToConstant: halfScreen),
            label2.leadingAnchor.constraint(equalTo: splittedView.leadingAnchor, constant: halfScreen)
        ])
        
        splittedView.tag = 777
        splittedView.isHidden = true
        
        // Buttons (to open news)
        let link1 = UIButton()
        link1.backgroundColor = .clear
        result.addSubview(link1)
        link1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            link1.leadingAnchor.constraint(equalTo: pic1.leadingAnchor),
            link1.topAnchor.constraint(equalTo: pic1.topAnchor),
            link1.widthAnchor.constraint(equalTo: pic1.widthAnchor),
            link1.heightAnchor.constraint(equalTo: pic1.heightAnchor)
        ])
        link1.tag = 901
        
        let link2 = UIButton()
        link2.backgroundColor = .clear
        result.addSubview(link2)
        link2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            link2.leadingAnchor.constraint(equalTo: pic2.leadingAnchor),
            link2.topAnchor.constraint(equalTo: pic2.topAnchor),
            link2.widthAnchor.constraint(equalTo: pic2.widthAnchor),
            link2.heightAnchor.constraint(equalTo: pic2.heightAnchor)
        ])
        link2.tag = 902
        
        return result
    }
    
    /*
    
    @objc func linkButtonOnTap(_ sender: UIButton) {
        print("LINK TAP!")
    }
    */
    
    static func headlinesType2() -> UIView {
        let result = UIView()
        
        let screenSize = UIScreen.main.bounds.size
        var w: CGFloat = screenSize.width - 30
        let h: CGFloat = (401 * w)/1335
        
        let pics = UIImageView(image: UIImage(named: "headlines02"))
        result.addSubview(pics)
        pics.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pics.topAnchor.constraint(equalTo: result.topAnchor),
            pics.leadingAnchor.constraint(equalTo: result.leadingAnchor, constant: 15),
            pics.widthAnchor.constraint(equalToConstant: w),
            pics.heightAnchor.constraint(equalToConstant: h)
        ])

        w = (screenSize.width/2)-30
        let title1 = UILabel()
        title1.text = "The pros and cons of wind power"
        title1.textColor = .white
        title1.numberOfLines = 2
        title1.font = UIFont(name: "Poppins-SemiBold", size: 14)
        result.addSubview(title1)
        title1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title1.topAnchor.constraint(equalTo: pics.bottomAnchor, constant: 6),
            title1.leadingAnchor.constraint(equalTo: result.leadingAnchor, constant: 15),
            title1.widthAnchor.constraint(equalToConstant: w),
        ])
        
        let subText = UILabel()
        subText.text = "TechCrunch • 25 minutes ago"
        subText.textColor = UIColor.white.withAlphaComponent(0.2)
        subText.numberOfLines = 2
        subText.font = UIFont(name: "Poppins-SemiBold", size: 12)
        result.addSubview(subText)
        subText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subText.topAnchor.constraint(equalTo: title1.bottomAnchor, constant: 6),
            subText.leadingAnchor.constraint(equalTo: result.leadingAnchor, constant: 15),
            subText.widthAnchor.constraint(equalToConstant: w),
        ])
        
        let title2 = UILabel()
        title2.text = "Recent trends in world energy use"
        title2.textColor = .white
        title2.numberOfLines = 2
        title2.font = UIFont(name: "Poppins-SemiBold", size: 14)
        result.addSubview(title2)
        title2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title2.topAnchor.constraint(equalTo: pics.bottomAnchor, constant: 6),
            title2.trailingAnchor.constraint(equalTo: result.trailingAnchor, constant: -15),
            title2.widthAnchor.constraint(equalToConstant: w),
        ])
        
        let subText2 = UILabel()
        subText2.text = "NY Times • 4 hours ago"
        subText2.textColor = UIColor.white.withAlphaComponent(0.2)
        subText2.numberOfLines = 2
        subText2.font = UIFont(name: "Poppins-SemiBold", size: 12)
        result.addSubview(subText2)
        subText2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subText2.topAnchor.constraint(equalTo: title2.bottomAnchor, constant: 6),
            subText2.trailingAnchor.constraint(equalTo: result.trailingAnchor, constant: -15),
            subText2.widthAnchor.constraint(equalToConstant: w),
        ])
        
        let divLine = UIView()
        divLine.backgroundColor = .white
        result.addSubview(divLine)
        divLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divLine.centerXAnchor.constraint(equalTo: result.centerXAnchor),
            divLine.topAnchor.constraint(equalTo: result.topAnchor, constant: -60),
            divLine.widthAnchor.constraint(equalToConstant: 1.0),
            divLine.heightAnchor.constraint(equalToConstant: OnBoardingView.headlinesType1_height + 60)
        ])
        
        let halfScreen = UIScreen.main.bounds.size.width / 2
        
        var headersTopOffset: CGFloat = -50
        if(SAFE_AREA()!.bottom == 0){ headersTopOffset = -32 }
        
        let label1 = UILabel()
        label1.textColor = .white
        label1.font = UIFont(name: "Merriweather-Bold", size: 22)
        label1.text = "LEFT"
        label1.textAlignment = .center
        result.addSubview(label1)
        label1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label1.topAnchor.constraint(equalTo: result.topAnchor,
                    constant: headersTopOffset),
            label1.widthAnchor.constraint(equalToConstant: halfScreen),
            label1.leadingAnchor.constraint(equalTo: result.leadingAnchor)
        ])
        
        let label2 = UILabel()
        label2.textColor = .white
        label2.font = UIFont(name: "Merriweather-Bold", size: 22)
        label2.text = "RIGHT"
        label2.textAlignment = .center
        result.addSubview(label2)
        label2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label2.topAnchor.constraint(equalTo: result.topAnchor,
                    constant: headersTopOffset),
            label2.widthAnchor.constraint(equalToConstant: halfScreen),
            label2.leadingAnchor.constraint(equalTo: result.leadingAnchor, constant: halfScreen)
        ])

        return result
    }
    
}

///////////////////////////////////////////////////////
extension OnBoardingView: OnBoardingView3Delegate {
    func onBoardingView3Close() {
        NotificationCenter.default.removeObserver(self)
        self.delegate?.onBoardingClose()
    }
}

///////////////////////////////////////////////////////
// Test button
extension OnBoardingView {
    private func addTestButton() {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Close", for: .normal)
        
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 100),
            button.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0)
        ])
        
        button.addTarget(self, action: #selector(closeButtonOnTap(_:)), for: .touchUpInside)
    }
    
    @objc func closeButtonOnTap(_ sender: UIButton?) {
        NotificationCenter.default.removeObserver(self)
        self.logEvent(type: .exited, step: self.currentStep)
        self.delegate?.onBoardingClose()
    }

    @objc func onNewsLoaded() { // on notification
        let headline1 = self.view2.viewWithTag(100)!
        self.showNews(headline: headline1, indexes: [0, 1])
        
        let headline2 = self.view2.viewWithTag(200)!
        self.showNews(headline: headline2, indexes: [2, 3])
    }
    
    @objc func closeFromOutside() {
        if(!view1.isHidden) {
            // step 1
            self.closeButtonOnTap(nil)
        } else {
            // step 3 on
            view3.exitButtonOnTap(nil)
        }
    }
    
    private func getNews(index i: Int) -> SimplestNews? {
        if let news = self.parser {
            let title = news.getTitle(index: i)
            let sourceTime = news.getSource(index: i) + " - " + news.getDate(index: i)
            let imageUrl = news.getIMG(index: i)
            let articleUrl = news.getURL(index: i)
            
            return SimplestNews(title: title, sourceTime: sourceTime,
                imageUrl: imageUrl, articleUrl: articleUrl)
        }
        return nil
    }
    
    private func showNews(headline: UIView, indexes: [Int]) {
        let news1 = getNews(index: indexes[0])!
        let pic1 = headline.viewWithTag(101) as! UIImageView
        let title1 = headline.viewWithTag(102) as! UILabel
        let subText = headline.viewWithTag(103) as! UILabel
        
        title1.text = news1.title
        subText.text = news1.sourceTime
        
        DispatchQueue.main.async {
            pic1.contentMode = .scaleAspectFill
            pic1.sd_setImage(with: URL(string: news1.imageUrl), placeholderImage: nil)
        }
        
        //////////////
        let news2 = getNews(index: indexes[1])!
        let pic2 = headline.viewWithTag(201) as! UIImageView
        let title2 = headline.viewWithTag(202) as! UILabel
        let subText2 = headline.viewWithTag(203) as! UILabel
        
        title2.text = news2.title
        subText2.text = news2.sourceTime
        
        DispatchQueue.main.async {
            pic2.contentMode = .scaleAspectFill
            pic2.sd_setImage(with: URL(string: news2.imageUrl), placeholderImage: nil)
        }

    }
    
    
    func logEvent(type: logEventType, step: logEventStep) {
        OnBoardingView.logEvent(type: type, step: step,
            topic: self.topic!, sliderValues: self.sliderValues!)
    }
    
    
    static func stepToNumber(_ step: logEventStep, offset: Int = 0) -> String {
        var value = 0
        switch step {
            case .step1_invitation:
                value = 1
            case .step2_lackControl:
                value = 2
            case .step3_takeControl:
                value = 3
            case .step4_sliderIntro:
                value = 4
                    case .step4_sliderMoved:
                    value = 4
            case .step5_splitIntro:
                value = 5
                    case .step5_splitChecked:
                    value = 5
            case .step6_otherSliders:
                value = 6
        }
        
        if(offset>0) {
            value += offset
            if(value>6){ value=6 }
        }
        
        return String(value)
    }
    static func OBparam(_ event: logEventType, _ step: logEventStep) -> String {
        
        if(step == .step4_sliderMoved || step == .step5_splitChecked) {
            return OB_PARAM()
        } else {
            var ob = "oB"
            if(event == .exited) { ob += "1" + OnBoardingView.stepToNumber(step) }
            else if(event == .started) { ob += "0" + OnBoardingView.stepToNumber(step) }
            else if(event == .completed) {
                if(step == .step6_otherSliders) {
                    ob += "1"
                } else {
                    ob += "0"
                }
                ob += OnBoardingView.stepToNumber(step, offset: 1)
            }
            
            SET_OB_PARAM(ob)
            return ob
        }
    }
    
    static func logEvent(type: logEventType, step: logEventStep,
        topic: String, sliderValues: String) {

        let sliderValues2 = sliderValues + OnBoardingView.OBparam(type, step)
        let v = "I" + Bundle.main.releaseVersionNumber!
        let dev = UIDevice.current.modelName.replacingOccurrences(of: " ", with: "_")

        let logUrl = "https://www.improvemynews.com/php/util/log.php"
        //let logUrl = "https://www.improvethenews.org/php/util/log.php"
        
        let json: [String: Any] = [
            "event": type.rawValue,
            "userId": USER_ID(),
            "sliderValues": sliderValues2,
            "topic": topic,
            "additionalEvent": step.rawValue,
            "onboardingVersion": ONBOARDING_VERSION,
            "v": v,
            "dev": dev
        ]
        
        print("???", "ONBOARDING EVENT", type.rawValue, step.rawValue)
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let jsonSize = String(jsonData!.count)
        print("???", "ONBOARDING EVENT size", jsonSize)
        print("???", "ONBOARDING sliderValues", sliderValues2)
        
        var request = URLRequest(url: URL(string: logUrl)!)
        request.httpMethod = "POST"
        //request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(jsonSize, forHTTPHeaderField: "Content-Length")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if(error != nil) {
                print("Error \(error)")
                return
            }
            
            if let _response = response as? HTTPURLResponse, let _data = data {
                let statusCode = _response.statusCode
                let text = String(data: _data, encoding: .utf8)
                
                if(statusCode==200 && text=="OK") {
                    print("???", "ONBOARDING EVENT completed")
                } else {
                    print("??? ONBOARDING EVENT", "log event FAIL")
                }
            } else {
                print("??? ONBOARDING EVENT", "log event FAIL")
            }
            
        }
        
        task.resume()
    }
    

}

enum logEventType: String {
    case started = "onboarding_started"
    case exited = "onboarding_exited"
    case completed = "onboarding_step_completed"
}

enum logEventStep: String {
    case step1_invitation = "invitation"
    case step2_lackControl = "lack-control"
    case step3_takeControl = "take-control"
    case step4_sliderIntro = "slider-intro"
    case step4_sliderMoved = "slider-moved"
    case step5_splitIntro = "split-intro"
    case step5_splitChecked = "split-activated"
    case step6_otherSliders = "other-sliders"
}
