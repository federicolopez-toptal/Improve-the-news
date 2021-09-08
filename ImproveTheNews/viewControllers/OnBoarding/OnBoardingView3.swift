//
//  OnBoardingView3.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 01/09/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

///////////////////////////////////////////////////////
protocol OnBoardingView3Delegate {
    func onBoardingView3Close()
}

///////////////////////////////////////////////////////
class OnBoardingView3: UIView {

    var delegate: OnBoardingView3Delegate?
    
    var headline = UIView()
    var headline2 = UIView()
    var headline3 = UIView()
    
    var animHeadlineLC: NSLayoutConstraint?
    var animExitButtonLC: NSLayoutConstraint?
    var animExitButton2LC: NSLayoutConstraint?
    var exitButtonBottomOffset: CGFloat = 0.0
    var sliderValue: CGFloat = 0.0
    
    let texts = [
        "On a typical news feed, you lack control over what newspapers you're shown.",
        "We put YOU in the drivers seat and you choose what you want to be shown.",
        "Use the sliders to see different perspectives.",
        "Sometimes you want to compare both sides – we call it the ‘split’.",
        "Now you can see what is really going on in the world!",
        "And we have more sliders to play with!"
    ]

    var step3view = UIView()
    var step4view = UIView()
    var step5_6view = UIView()
    var step7view = UIView()
    var step8view = UIView()
    var step9view = UIView()
    var step10view = UIView()

    ///////////////////////////////////////////////////////
    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    ///////////////////////////////////////////////////////
    func insertInto(container: UIView) {
        
        self.backgroundColor = container.backgroundColor
        
        container.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: container.topAnchor),
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        self.initHeadlines()
        self.createStep3()
        self.createStep4()
        self.createStep5_6()
        self.createStep7()
        self.createStep8()
        self.createStep9()
        self.createStep10()
        
        //self.testSteps() // !!!
    }
    
    private func initHeadlines() {
        let offset: CGFloat = 22 + 38 + 16 + OnBoardingView.headlinesType1_height + 4
        
        // headline 1
        self.headline = OnBoardingView.headlinesType1()
        self.addSubview(self.headline)
        headline.translatesAutoresizingMaskIntoConstraints = false
        
        self.animHeadlineLC = headline.topAnchor.constraint(equalTo: self.topAnchor, constant: offset)
        
        NSLayoutConstraint.activate([
            self.animHeadlineLC!,
            headline.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            headline.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            headline.heightAnchor.constraint(equalToConstant: OnBoardingView.headlinesType1_height)
        ])
        
        var offset2 = offset
        offset2 -= 140
        if(SAFE_AREA()!.bottom == 0) { offset2 -= 70 }
        
        
        // headline 2
        self.headline2 = OnBoardingView.headlinesType1()
        self.addSubview(self.headline2)
        headline2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headline2.topAnchor.constraint(equalTo: self.topAnchor, constant: offset2),
            headline2.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            headline2.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            headline2.heightAnchor.constraint(equalToConstant: OnBoardingView.headlinesType1_height)
        ])
        for sv in self.headline2.subviews {
            if(sv is UIImageView) {
                (sv as! UIImageView).image = UIImage(named: "headlines02")
            }
        }
        self.headline2.isHidden = true
        
        // headline 3
        self.headline3 = OnBoardingView.headlinesType2()
        self.addSubview(self.headline3)
        self.headline3.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headline3.topAnchor.constraint(equalTo: self.topAnchor, constant: offset2),
            headline3.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            headline3.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            headline.heightAnchor.constraint(equalToConstant: OnBoardingView.headlinesType1_height)
        ])
        self.headline3.isHidden = true
    }
    
    private func testSteps() {
        // 3 & 4
        self.animHeadlineLC?.constant -= 140
        if(SAFE_AREA()!.bottom == 0) {
            self.animHeadlineLC?.constant -= 70
        }
        // 5 & 6
        self.animExitButtonLC?.constant -= 90
        let panel = self.step5_6view.viewWithTag(11)!
        panel.alpha = 1.0
        let nextButton = self.step5_6view.viewWithTag(22) as! UIButton
        nextButton.isHidden = false
        // 7, 8, 9
        self.headline3.isHidden = false
        self.step9view.isHidden = false
    }
    
    // MARK: - Step 3 /////////////////////////
    func createStep3() {
    
        self.exitButtonBottomOffset = -SAFE_AREA()!.bottom
        if(self.exitButtonBottomOffset == 0){ self.exitButtonBottomOffset = -10 }
    
        self.initStep(self.step3view)
        let dots = self.createDots(currentPage: -1, container: self.step3view)
        dots.alpha = 0.25
        self.createLabel(self.texts[0], container: self.step3view, below: dots, topOffset: 15)
        let exitButton = self.createExitButton(container: self.step3view,
            bottomOffset: self.exitButtonBottomOffset)
        let nextButton = self.createOrangeButton(text: "NEXT",
                container: self.step3view, above: exitButton, bottomOffset: -10)
                
        nextButton.addTarget(self, action: #selector(showStep4(_:)), for: .touchUpInside)
    }
    
    func showStep3() {
    
        self.step3view.alpha = 0
        self.step3view.isHidden = false
        
        self.animHeadlineLC?.constant -= 140
        if(SAFE_AREA()!.bottom == 0) {
            self.animHeadlineLC?.constant -= 70
        }
        
        UIView.animate(withDuration: 0.4) {
            self.layoutIfNeeded()
            self.step3view.alpha = 1
        } completion: { _ in
        }
    }
    
    // MARK: - Step 4 /////////////////////////
    func createStep4() {
    
        self.initStep(self.step4view)
        let dots = self.createDots(currentPage: 1, container: self.step4view)
        self.createLabel(self.texts[1], container: self.step4view, below: dots, topOffset: 15)
        let exitButton = self.createExitButton(container: self.step4view,
            bottomOffset: self.exitButtonBottomOffset)
        let nextButton = self.createOrangeButton(text: "NEXT",
                container: self.step4view, above: exitButton, bottomOffset: -10)
                
        nextButton.addTarget(self, action: #selector(showStep5_6(_:)), for: .touchUpInside)
    }
    
    @objc func showStep4(_ sender: UIButton?) {
    
        self.step4view.alpha = 0
        self.step4view.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            self.step4view.alpha = 1
        } completion: { _ in
            self.step3view.isHidden = true
        }
    }
    
    // MARK: - Step 5_6 /////////////////////////
    func createStep5_6() {
    
        self.initStep(self.step5_6view)
        let dots = self.createDots(currentPage: 2, container: self.step5_6view)
        self.createLabel(self.texts[2], container: self.step5_6view, below: dots, topOffset: 15)
        let exitButton = self.createExitButton(container: self.step5_6view,
            bottomOffset: self.exitButtonBottomOffset, forAnim: true)
        
        let panel = self.createOrangePanel(container: self.step5_6view,
            below: exitButton, topOffset: 15)
        panel.alpha = 0.0
        panel.tag = 11
        
        let nextButton = self.createOrangeButton(text: "I'M GOOD!",
            container: self.step5_6view, above: exitButton, bottomOffset: -10)
        nextButton.isHidden = true
        nextButton.tag = 22
        nextButton.addTarget(self, action: #selector(showStep7(_:)), for: .touchUpInside)
        
        self.exitButtonBottomOffset -= 90
    }
    
    @objc func showStep5_6(_ sender: UIButton?) {
    
        self.step5_6view.alpha = 0
        self.step5_6view.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            self.step5_6view.alpha = 1
        } completion: { _ in
            self.step4view.isHidden = true
            
            self.animExitButtonLC?.constant -= 90
            UIView.animate(withDuration: 0.4) {
                let panel = self.step5_6view.viewWithTag(11)!
                panel.alpha = 1.0
                self.layoutIfNeeded()
            } completion: { _ in
                /*
                DELAY(1.0) {
                    let nextButton = self.step5_6view.viewWithTag(22) as! UIButton
                    nextButton.alpha = 0.0
                    nextButton.isHidden = false
                    UIView.animate(withDuration: 0.4) {
                        nextButton.alpha = 1.0
                    }
                }
                */
            }
            
        }
    }
    
    // MARK: - Step 7 /////////////////////////
    func createStep7() {
        self.initStep(self.step7view)
        let dots = self.createDots(currentPage: 3, container: self.step7view)
        let label = self.createLabel(self.texts[3], container: self.step7view, below: dots,
            topOffset: 15)
        let exitButton = self.createExitButton(container: self.step7view,
            bottomOffset: self.exitButtonBottomOffset)
        
        let panel = self.createOrangePanel(container: self.step7view,
            below: exitButton, topOffset: 15, showSplit: true, splitState: false)
        panel.tag = 11
            
        let checkbox = self.createCheckboxLarge(container: self.step7view,
            below: label, topOffset: 20)
        checkbox.tag = 22
    }
    
    @objc func showStep7(_ sender: UIButton?) {
        self.step7view.alpha = 0
        self.step7view.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            self.step7view.alpha = 1
        } completion: { _ in
            self.step5_6view.isHidden = true
        }
    }
    
    @objc func checkboxOnCheck(_ sender: UIButton) {
        // checkbox large
        let checkBox = self.step7view.viewWithTag(22)!
        for sv in checkBox.subviews {
            if(sv is UIImageView) {
                let img = (sv as! UIImageView)
                img.image = UIImage(named: "onboardingCheckON.png")
            }
            
            if(sv is UIButton) {
                let button = (sv as! UIButton)
                button.isEnabled = false
            }
        }
        
        // checkbox small
        let panel = self.step7view.viewWithTag(11)!
        let checkBox2 = panel.viewWithTag(212)!
        for sv in checkBox2.subviews {
            if(sv is UIImageView) {
                let img = (sv as! UIImageView)
                img.image = UIImage(systemName: "checkmark.square")
            }
            
            if(sv is UIButton) {
                let button = (sv as! UIButton)
                button.isEnabled = false
            }
        }
        
        self.showStep8(nil)
    }
    
    // MARK: - Step 8 /////////////////////////
    func createStep8() {
        self.initStep(self.step8view)
        let dots = self.createDots(currentPage: 3, container: self.step8view)
        let label = self.createLabel(self.texts[4], container: self.step8view, below: dots, topOffset: 15)
        let exitButton = self.createExitButton(container: self.step8view,
            bottomOffset: self.exitButtonBottomOffset)
        
        let panel = self.createOrangePanel(container: self.step8view,
            below: exitButton, topOffset: 15, showSplit: true, splitState: true)
        panel.tag = 11
            
        let checkbox = self.createCheckboxLarge(container: self.step8view,
            below: label, topOffset: 20, state: true)
    }
    
    @objc func showStep8(_ sender: UIButton?) {
        self.step8view.alpha = 0.0
        self.step8view.isHidden = false
        
        self.headline3.alpha = 0.0
        self.headline3.isHidden = false
        self.headline2.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) {
            self.step8view.alpha = 1.0
            self.headline3.alpha = 1.0
            self.headline2.alpha = 0.0
        } completion: { _ in
            self.step7view.isHidden = true
            
            self.headline2.alpha = 1.0
            self.headline2.isHidden = true
            
            DELAY(5.0) {
                self.showStep9(nil)
            }
        }
    }
    
    // MARK: - Step 9 /////////////////////////
    func createStep9() {
        self.initStep(self.step9view)
        let dots = self.createDots(currentPage: 4, container: self.step9view)
        let label = self.createLabel(self.texts[5], container: self.step9view,
            below: dots, topOffset: 15)
        let exitButton = self.createExitButton(container: self.step9view,
            bottomOffset: self.exitButtonBottomOffset)
        
        let panel = self.createOrangePanel(container: self.step9view,
            below: exitButton, topOffset: 15, showSplit: false, splitState: false)
        panel.tag = 11
            
        let nextButton = self.createPrefsButton(container: self.step9view, below: label, topOffset: 20)
        nextButton.addTarget(self, action: #selector(showStep10(_:)), for: .touchUpInside)
    }
    
    @objc func showStep9(_ sender: UIButton?) {
        self.step9view.alpha = 0.0
        self.step9view.isHidden = false
        
        self.headline2.alpha = 0.0
        self.headline2.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            self.step9view.alpha = 1.0
            self.headline2.alpha = 1.0
            self.headline3.alpha = 0.0
        } completion: { _ in
            self.step8view.isHidden = true
            
            self.headline3.alpha = 1.0
            self.headline3.isHidden = true
        }
    }
    
    // MARK: - Step 10 /////////////////////////
    func createStep10() {
        self.initStep(self.step10view)
        let dots = self.createDots(currentPage: 4, container: self.step10view)
        let label = self.createLabel(self.texts[5], container: self.step10view,
            below: dots, topOffset: 15)
        let exitButton = self.createExitButton(container: self.step10view,
            bottomOffset: self.exitButtonBottomOffset, forAnim: true)
        
        let panel = self.createOrangePanel(container: self.step10view,
            below: exitButton, topOffset: 15, showSplit: false, splitState: false,
            secondRow: true)
        panel.tag = 11
    }
    
    @objc func showStep10(_ sender: UIButton?) {
        self.step10view.alpha = 0.0
        self.step10view.isHidden = false
        self.headline.isHidden = false
        self.headline.alpha = 0.0
        
        UIView.animate(withDuration: 0.4) {
            self.step10view.alpha = 1.0
            self.headline.alpha = 1.0
            self.headline2.alpha = 0.0
        } completion: { _ in
            self.step9view.isHidden = true
            self.animExitButton2LC?.constant -= 80
            self.headline2.alpha = 1.0
            self.headline2.isHidden = true
            
            UIView.animate(withDuration: 0.4) {
                self.layoutIfNeeded()
            } completion: { _ in
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////
    
    // MARK: - Components
    private func initStep(_ view: UIView) {
        view.backgroundColor = bgBlue
        //view.backgroundColor = .blue
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.headline.bottomAnchor)
        ])
        
        view.isHidden = true
    }
    
    private func createDots(currentPage: Int, container: UIView,
        topOffset: CGFloat = 0.0) -> UIPageControl {
        
        let dots = UIPageControl()
        dots.numberOfPages = 4
        if(currentPage != -1) { dots.currentPage = currentPage-1 }
        dots.pageIndicatorTintColor = UIColor(rgb: 0x93A0B4)
        dots.currentPageIndicatorTintColor = accentOrange
        container.addSubview(dots)
        dots.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dots.topAnchor.constraint(equalTo: container.topAnchor, constant: topOffset),
            dots.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        return dots
    }
    
    private func createLabel(_ text: String, container: UIView, below: UIView,
        topOffset: CGFloat = 0.0) -> UILabel {
        
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor(rgb: 0x93A0B4)
        label.font = UIFont(name: "Roboto-Regular", size: 20)
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: below.bottomAnchor, constant: topOffset),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30)
        ])
        
        return label
    }
    
    private func createExitButton(container: UIView,
        bottomOffset: CGFloat = 0.0,
        forAnim: Bool = false) -> UIButton {
        
        let button = UIButton(type: .custom)
        button.setTitle("EXIT TOUR", for: .normal)
        button.setTitleColor(accentOrange, for: .normal)
        button.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16)
        
        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor,
                constant: 30),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor,
                constant: -30),
            button.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        if(forAnim) {
            if(container == self.step5_6view) {
                self.animExitButtonLC = button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: bottomOffset)
            
                NSLayoutConstraint.activate([
                    self.animExitButtonLC!
                ])
            }
            
            if(container == self.step10view) {
                self.animExitButton2LC = button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: bottomOffset)
            
                NSLayoutConstraint.activate([
                    self.animExitButton2LC!
                ])
            }
        } else {
            NSLayoutConstraint.activate([
                button.bottomAnchor.constraint(equalTo: container.bottomAnchor,
                constant: bottomOffset)
            ])
        }
        
        button.addTarget(self, action: #selector(exitButtonOnTap(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func createExitButton2(container: UIView, offset: CGFloat) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle("EXIT TOUR", for: .normal)
        button.setTitleColor(accentOrange, for: .normal)
        button.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16)
        
        var bottom = -SAFE_AREA()!.bottom
        if(bottom == 0){ bottom = -10 }

        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor,
                constant: 30),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor,
                constant: -30),
            button.heightAnchor.constraint(equalToConstant: 40),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor,
                    constant: bottom - offset)
        ])
        
        button.addTarget(self, action: #selector(exitButtonOnTap(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func createOrangeButton(text: String, container: UIView,
        above: UIView, bottomOffset: CGFloat = 0.0) -> UIButton {
        
        let button = OrangeRoundedButton(title: text)
        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor,
                    constant: -30),
            button.bottomAnchor.constraint(equalTo: above.topAnchor, constant: bottomOffset),
            button.heightAnchor.constraint(equalToConstant: 50),
            
        ])
        
        return button
    }
    
    private func createOrangePanel(container: UIView, below: UIView,
        topOffset: CGFloat, showSplit: Bool = false, splitState: Bool = false,
        secondRow: Bool = false) -> UIView {
        
        let view = UIView()
        view.backgroundColor = accentOrange
        view.layer.cornerRadius = 25
        
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.heightAnchor.constraint(equalToConstant: 200),
            view.topAnchor.constraint( equalTo: below.bottomAnchor, constant: topOffset)
        ])
        
        let whiteLine = UIView()
        whiteLine.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view.addSubview(whiteLine)
        whiteLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            whiteLine.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            whiteLine.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            whiteLine.widthAnchor.constraint(equalToConstant: 50),
            whiteLine.heightAnchor.constraint(equalToConstant: 6)
        ])
        whiteLine.layer.cornerRadius = 3
        
        if(showSplit) {
            let checkbox = self.createCheckboxSmall(container: view,
                    topOffset: 0, trailingOffset: -10, state: splitState)
            checkbox.tag = 212
        }
        
        var slider1: UIView
        if(splitState) {
            slider1 = sliderRow(container: view, below: whiteLine, offset: 4,
                        title: "Political stance", left: "LEFT", right: "RIGHT", sliderEnabled: false)
        } else {
            slider1 = sliderRow(container: view, below: whiteLine, offset: 4,
                        title: "Political stance", left: "LEFT", right: "RIGHT")
        }
        slider1.tag = 101
                        
        if(secondRow) {
            sliderRow(container: view, below: slider1, offset: 20,
                        title: "Establishment stance", left: "CRITICAL", right: "PRO",
                        separatorOnTop: true)
        }
                        
        return view
    }
    
    private func sliderRow(container: UIView, below: UIView, offset: CGFloat,
                            title: String, left: String, right: String,
                            separatorOnTop: Bool = false,
                            sliderEnabled: Bool = true) -> UIView {
                            
        let view = UIView()
        //view.backgroundColor = .green
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.heightAnchor.constraint(equalToConstant: 70),
            view.topAnchor.constraint(equalTo: below.bottomAnchor, constant: 0)
        ])
        
        let separator = UIView()
        if(separatorOnTop) {
            separator.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            view.addSubview(separator)
            separator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                separator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                separator.heightAnchor.constraint(equalToConstant: 2),
                separator.topAnchor.constraint(equalTo: view.topAnchor)
            ])
        }
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15)
        ])
        if(separatorOnTop) {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 12)
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: view.topAnchor)
            ])
        }
        
        let leftLabel = UILabel()
        leftLabel.text = left
        leftLabel.textColor = .white
        leftLabel.font = UIFont(name: "Poppins-SemiBold", size: 12)
        view.addSubview(leftLabel)
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            leftLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 25)
        ])
        
        let rightLabel = UILabel()
        rightLabel.text = right
        rightLabel.textColor = .white
        rightLabel.textAlignment = .right
        rightLabel.font = UIFont(name: "Poppins-SemiBold", size: 12)
        view.addSubview(rightLabel)
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            rightLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 25)
        ])
        
        let slider = UISlider()
        slider.minimumTrackTintColor = UIColor(rgb: 0x913A1F)
        slider.maximumTrackTintColor = UIColor(rgb: 0x913A1F)
        slider.minimumValue = 0
        slider.maximumValue = 99
        view.addSubview(slider)
             
        slider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 25),
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 80),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80)
        ])
        
        if(!sliderEnabled) {
            slider.thumbTintColor = .clear
            slider.isEnabled = false
            
            let vLine = UIView()
            vLine.backgroundColor = .white
            slider.addSubview(vLine)
            vLine.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vLine.centerYAnchor.constraint(equalTo: slider.centerYAnchor),
                vLine.centerXAnchor.constraint(equalTo: slider.centerXAnchor),
                vLine.widthAnchor.constraint(equalToConstant: 6),
                vLine.heightAnchor.constraint(equalToConstant: 22)
            ])
            vLine.layer.cornerRadius = 3.0
        }
        
        
        
        if(!separatorOnTop) {
            slider.addTarget(self, action: #selector(sliderOnValueChange(_:)),
                    for: .valueChanged)
        }

        return view
    }
    
    @objc func sliderOnValueChange(_ sender: UISlider) {
        let views = [self.step3view, self.step4view, self.step5_6view, self.step7view,
                self.step8view, self.step9view, self.step10view]
        
        self.sliderValue = CGFloat(sender.value)
        
        for v in views {
            if let panel = v.viewWithTag(11), let sliderRow = panel.viewWithTag(101) {
                for sb in sliderRow.subviews {
                    if(sb is UISlider) {
                        let slider = (sb as! UISlider)
                        if(slider != sender) {
                            slider.setValue(Float(self.sliderValue), animated: false)
                        } else {
                            if(v == self.step5_6view) {
                                if(headline2.isHidden) {
                                    self.headline2.alpha = 0.0
                                    self.headline2.isHidden = false
                                    
                                    UIView.animate(withDuration: 0.4) {
                                            self.headline2.alpha = 1.0
                                            self.headline.alpha = 0.0
                                        } completion: { _ in
                                            self.headline.alpha = 1.0
                                            self.headline.isHidden = true
                                            
                                            DELAY(3.0) {
                                                let nextButton = self.step5_6view.viewWithTag(22) as! UIButton
                                                
                                                nextButton.alpha = 0.0
                                                nextButton.isHidden = false
                                                UIView.animate(withDuration: 0.4) {
                                                    nextButton.alpha = 1.0
                                                }
                                            }
                                        }
                                }
                            
                            
                                
                                
                                
                                    
                                    
                                
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    private func createCheckboxLarge(container: UIView, below: UIView,
        topOffset: CGFloat, state: Bool = false) -> UIView {
        
        let view = UIView()
        //view.backgroundColor = UIColor.yellow.withAlphaComponent(0.1)
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            view.topAnchor.constraint(equalTo: below.bottomAnchor, constant: topOffset),
            view.widthAnchor.constraint(equalToConstant: 100),
            view.heightAnchor.constraint(equalToConstant: 40)
        ])
    
        let img = UIImageView(image: UIImage(named: "onboardingCheckOFF.png"))
        if(state) { img.image = UIImage(named: "onboardingCheckON.png") }
        view.addSubview(img)
        img.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            img.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            img.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            img.widthAnchor.constraint(equalToConstant: 335 / 7),
            img.heightAnchor.constraint(equalToConstant: 275 / 7)
        ])
        //img.alpha = 0.5
        
        let label = UILabel()
        label.text = "Split"
        label.textColor = accentOrange
        label.font = UIFont(name: "Roboto-Regular", size: 20)
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: img.trailingAnchor, constant: -4),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 4),
        ])
        
        let button = UIButton(type: .system)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            button.topAnchor.constraint(equalTo: view.topAnchor),
        ])
        if(!state) {
            button.addTarget(self, action: #selector(checkboxOnCheck(_:)), for: .touchUpInside)
        }
        
        return view
    }
    
    private func createCheckboxSmall(container: UIView, topOffset: CGFloat,
        trailingOffset: CGFloat, state: Bool = false) -> UIView {
        let view = UIView()
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: topOffset),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor,
                constant: trailingOffset),
            view.widthAnchor.constraint(equalToConstant: 120),
            view.heightAnchor.constraint(equalToConstant: 35)
        ])
        //view.backgroundColor = .red
        
        let img = UIImageView(image: UIImage(systemName: "square"))
        if(state){ img.image = UIImage(systemName: "checkmark.square") }
        img.tintColor = .black
        view.addSubview(img)
        img.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            img.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4 + 30),
            img.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 5),
            img.widthAnchor.constraint(equalToConstant: 18),
            img.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        let label = UILabel()
        label.text = "Split"
        label.textColor = .black
        label.font = UIFont(name: "Poppins-SemiBold", size: 15)
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: img.trailingAnchor, constant: 4),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 5),
        ])
        
        if(!state) {
            let button = UIButton(type: .system)
            view.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                button.topAnchor.constraint(equalTo: view.topAnchor),
            ])
            button.addTarget(self, action: #selector(checkboxOnCheck(_:)), for: .touchUpInside)
            //button.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        }
        
        return view
    }
    
    private func createPrefsButton(container: UIView, below: UIView,
        topOffset: CGFloat) -> UIButton {
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "onBoardingPrefsButton"), for: .normal)
        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: below.bottomAnchor, constant: topOffset),
            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 78),
            button.heightAnchor.constraint(equalToConstant: 82)
        ])
        
        return button
    }
    
}

extension OnBoardingView3 {
    // Event(s)
    @objc func exitButtonOnTap(_ sender: UIButton?) {
        self.delegate?.onBoardingView3Close()
    }
}
