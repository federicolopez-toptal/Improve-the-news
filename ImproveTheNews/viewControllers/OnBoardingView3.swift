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
    var headlineTopConstraint: NSLayoutConstraint?
    var exitButtonBottomConstraint: NSLayoutConstraint?
    var orangePanelTopConstraint: NSLayoutConstraint?

    let texts = [
        "On a typical news feed, you lack control over what newspapers you're shown.",
        "We put YOU in the drivers seat and you choose what you want to be shown.",
        "Use the sliders to see different perspectives."
    ]

    var step3view = UIView()
    var step4view = UIView()
    var step5view = UIView()

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

        var offset: CGFloat = 22 + 38 + 16 + OnBoardingView.headlinesType1_height + 4
        
        self.headline = OnBoardingView.headlinesType1()
        self.addSubview(self.headline)
        headline.translatesAutoresizingMaskIntoConstraints = false
        
        self.headlineTopConstraint = headline.topAnchor.constraint(equalTo: self.topAnchor,
                constant: offset)
        
        NSLayoutConstraint.activate([
            self.headlineTopConstraint!,
            headline.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            headline.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            headline.heightAnchor.constraint(equalToConstant: OnBoardingView.headlinesType1_height)
        ])
        
        self.addStep3()
        self.addStep4()
        self.addStep5()
        
        // !!!
        self.headlineTopConstraint?.constant -= 120
        self.step4view.isHidden = false
    }
    
    // MARK: - Step 3 /////////////////////////
    func addStep3() {
    
        self.initStep(self.step3view)
        let dots = self.createDots(currentPage: 1, container: self.step3view)
        dots.alpha = 0.5
        self.createLabel(self.texts[0], container: self.step3view, below: dots)
        let exitButton = self.createExitButton(container: self.step3view)
        let nextButton = self.createOrangeButton(text: "NEXT",
                container: self.step3view, above: exitButton)
                
        nextButton.addTarget(self, action: #selector(showStep4(_:)), for: .touchUpInside)
    }
    
    func showStep3() {
    
        self.step3view.alpha = 0
        self.step3view.isHidden = false
        self.headlineTopConstraint?.constant -= 120
        
        UIView.animate(withDuration: 0.4) {
            self.layoutIfNeeded()
            self.step3view.alpha = 1
        } completion: { _ in
        }
    }
    
    // MARK: - Step 4 /////////////////////////
    func addStep4() {
    
        self.initStep(self.step4view)
        let dots = self.createDots(currentPage: 1, container: self.step4view)
        self.createLabel(self.texts[1], container: self.step4view, below: dots)
        let exitButton = self.createExitButton(container: self.step4view)
        let nextButton = self.createOrangeButton(text: "NEXT",
                container: self.step4view, above: exitButton)
                
        nextButton.addTarget(self, action: #selector(showStep5(_:)), for: .touchUpInside)
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
    
    // MARK: - Step 5 /////////////////////////
    func addStep5() {
    
        self.initStep(self.step5view)
        let dots = self.createDots(currentPage: 2, container: self.step5view)
        self.createLabel(self.texts[2], container: self.step5view, below: dots)
        let exitButton = self.createExitButton(container: self.step5view)
        
        var offset = SAFE_AREA()!.bottom
        if(offset == 0){ offset = 10 }
        self.createOrangePanel(container: self.step5view, below: exitButton, offset: offset)
    }
    
    @objc func showStep5(_ sender: UIButton?) {
    
        self.step5view.alpha = 0
        self.step5view.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            self.step5view.alpha = 1
        } completion: { _ in
            self.step4view.isHidden = true
            self.exitButtonBottomConstraint?.constant -= 75
            self.orangePanelTopConstraint?.constant = 15
            UIView.animate(withDuration: 0.4) {
                self.layoutIfNeeded()
            } completion: { _ in
            }
        }
    }
    
    
    
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
    
    private func createDots(currentPage: Int, container: UIView) -> UIPageControl {
        let dots = UIPageControl()
        dots.numberOfPages = 4
        dots.currentPage = currentPage-1
        dots.pageIndicatorTintColor = UIColor(rgb: 0x93A0B4)
        dots.currentPageIndicatorTintColor = accentOrange
        container.addSubview(dots)
        dots.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dots.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            dots.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        return dots
    }
    
    private func createLabel(_ text: String, container: UIView, below: UIView) {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor(rgb: 0x93A0B4)
        label.font = UIFont(name: "Roboto-Regular", size: 20)
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: below.bottomAnchor, constant: 15),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30)
        ])
    }
    
    private func createExitButton(container: UIView) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle("EXIT TOUR", for: .normal)
        button.setTitleColor(accentOrange, for: .normal)
        button.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16)
        
        var offset = -SAFE_AREA()!.bottom
        if(offset == 0){ offset = -10 }

        self.exitButtonBottomConstraint = button.bottomAnchor.constraint(
            equalTo: container.bottomAnchor,
            constant: offset)

        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor,
                    constant: -30),
            button.heightAnchor.constraint(equalToConstant: 40),
            self.exitButtonBottomConstraint!
        ])
        button.addTarget(self, action: #selector(exitButtonOnTap(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func createOrangeButton(text: String, container: UIView, above: UIView) -> UIButton {
        let button = OrangeRoundedButton(title: text)
        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor,
                    constant: -30),
            button.bottomAnchor.constraint(equalTo: above.topAnchor, constant: -10),
            button.heightAnchor.constraint(equalToConstant: 50),
            
        ])
        
        return button
    }
    
    private func createOrangePanel(container: UIView, below: UIView, offset: CGFloat) {
        let view = UIView()
        view.backgroundColor = accentOrange
        view.layer.cornerRadius = 25
        
        self.orangePanelTopConstraint = view.topAnchor.constraint(
            equalTo: below.bottomAnchor,
            constant: offset)
        
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.heightAnchor.constraint(equalToConstant: 200),
            self.orangePanelTopConstraint!
        ])
        
        let whiteLine = UIView()
        whiteLine.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view.addSubview(whiteLine)
        whiteLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            whiteLine.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            whiteLine.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            whiteLine.widthAnchor.constraint(equalToConstant: 50),
            whiteLine.heightAnchor.constraint(equalToConstant: 6)
        ])
        whiteLine.layer.cornerRadius = 3
        
        let slider1 = sliderRow(container: view, below: whiteLine, offset: 0,
                        title: "Political stance", left: "LEFT", right: "RIGHT")
    }
    
    private func sliderRow(container: UIView, below: UIView, offset: CGFloat,
                            title: String, left: String, right: String) {
                            
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
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
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
        slider.minimumTrackTintColor = .orange
        slider.maximumTrackTintColor = .lightGray
        view.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 25),
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 80),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80)
        ])
    }
    
}

extension OnBoardingView3 {
    // Event(s)
    @objc func exitButtonOnTap(_ sender: UIButton?) {
        self.delegate?.onBoardingView3Close()
    }
}
