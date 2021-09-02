//
//  OnBoardingView.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 30/08/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(container: UIView) {
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
        self.addView1()
        self.addView2()
        self.addView3()
        
        self.view3.delegate = self
        
        
        // !!!
        self.view1.isHidden = true
        self.view2.isHidden = true
        self.view3.isHidden = false
    }

}

///////////////////////////////////////////////////////
// view1
extension OnBoardingView {

    private func addView1() {
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
        
        showMeButton.addTarget(self, action: #selector(gotoStep2(_:)),
                for: .touchUpInside)
        
        ///////////////////////////////////////////////////
        let label1 = UILabel()
        label1.text = "Would you like a quick tour?"
        label1.textColor = UIColor(rgb: 0x93A0B4)
        label1.font = UIFont(name: "Roboto-Regular", size: 20)
        
        offset = SAFE_AREA()!.bottom
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
    
    @objc func gotoStep2(_ sender: UIButton?) {
        self.view2.alpha = 0
        self.view2.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.view2.alpha = 1
        } completion: { _ in
            self.view1.isHidden = true
            self.gotoStep3()
        }

    }
}

///////////////////////////////////////////////////////
// view2
extension OnBoardingView {

    private func addView2() {
        
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
        
        let headline1 = OnBoardingView.headlinesType1()
        self.view2.addSubview(headline1)
        headline1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headline1.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 16),
            headline1.leadingAnchor.constraint(equalTo: self.view2.leadingAnchor),
            headline1.trailingAnchor.constraint(equalTo: self.view2.trailingAnchor),
            headline1.heightAnchor.constraint(equalToConstant: OnBoardingView.headlinesType1_height)
        ])
        
        let headline2 = OnBoardingView.headlinesType1()
        self.view2.addSubview(headline2)
        headline2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headline2.topAnchor.constraint(equalTo: headline1.bottomAnchor, constant: 4),
            headline2.leadingAnchor.constraint(equalTo: self.view2.leadingAnchor),
            headline2.trailingAnchor.constraint(equalTo: self.view2.trailingAnchor),
            headline2.heightAnchor.constraint(equalToConstant: OnBoardingView.headlinesType1_height)
        ])
        
        self.view2.isHidden = true
    }
    
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

        return result
    }
    
    @objc func gotoStep3() {
        DELAY(1.0) {
            self.view3.alpha = 0
            self.view3.isHidden = false
            UIView.animate(withDuration: 0.4) {
                self.view3.alpha = 1
            } completion: { _ in
                self.view2.isHidden = true
                self.view3.showStep3()
            }
        }
    }
}

///////////////////////////////////////////////////////
// view3
extension OnBoardingView {

    private func addView3() {
        
        self.view3.insertInto(container: self)
        
        
        /*
        var offset: CGFloat = 22 + 38 + 16 + 204 + 4
        
        let headline1 = headlinesType1()
        headline1.tag = 200
        self.view3.addSubview(headline1)
        headline1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headline1.topAnchor.constraint(equalTo: self.view3.topAnchor, constant: offset),
            headline1.leadingAnchor.constraint(equalTo: self.view3.leadingAnchor),
            headline1.trailingAnchor.constraint(equalTo: self.view3.trailingAnchor),
            headline1.heightAnchor.constraint(equalToConstant: 204)
        ])
        */
        
        /*
        ////////////////////////////////////////////////////////////
        let middleView = UIView()
        middleView.tag = 300
        //middleView.backgroundColor = .blue
        self.view3.addSubview(middleView)
        middleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            middleView.topAnchor.constraint(equalTo: headline1.bottomAnchor),
            middleView.leadingAnchor.constraint(equalTo: self.view3.leadingAnchor),
            middleView.trailingAnchor.constraint(equalTo: self.view3.trailingAnchor),
            middleView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        let dots = UIPageControl()
        dots.numberOfPages = 4
        dots.currentPage = 0
        dots.pageIndicatorTintColor = UIColor(rgb: 0x93A0B4)
        dots.currentPageIndicatorTintColor = accentOrange
        middleView.addSubview(dots)
        dots.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dots.topAnchor.constraint(equalTo: middleView.topAnchor, constant: 0),
            dots.centerXAnchor.constraint(equalTo: middleView.centerXAnchor)
        ])
        
        let label1 = UILabel()
        label1.text = "On a typical news feed, you lack control over what newspapers you're shown."
        label1.numberOfLines = 3
        label1.textAlignment = .center
        label1.textColor = UIColor(rgb: 0x93A0B4)
        label1.font = UIFont(name: "Roboto-Regular", size: 20)
        middleView.addSubview(label1)
        label1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label1.topAnchor.constraint(equalTo: dots.bottomAnchor, constant: 15),
            label1.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 30),
            label1.trailingAnchor.constraint(equalTo: middleView.trailingAnchor, constant: -30)
        ])
        
        ////////////////////////////////////////////////////////////
        offset = SAFE_AREA()!.bottom
        
        let bottomView = UIView()
        bottomView.tag = 400
        self.view3.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: self.view3.bottomAnchor, constant: 0),
            bottomView.leadingAnchor.constraint(equalTo: self.view3.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: self.view3.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 100 + offset)
        ])
        
        let nextButton = OrangeRoundedButton(title: "NEXT")
        bottomView.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 30),
            nextButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -30),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.topAnchor.constraint(equalTo: bottomView.topAnchor)
        ])
        nextButton.addTarget(self, action: #selector(step3_ShowText2(_:)), for: .touchUpInside)
        
        let exitButton = UIButton(type: .custom)
        exitButton.setTitle("EXIT TOUR", for: .normal)
        exitButton.setTitleColor(accentOrange, for: .normal)
        exitButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16)
        exitButton.addTarget(self, action: #selector(closeButtonOnTap(_:)), for: .touchUpInside)
        bottomView.addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            exitButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 30),
            exitButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -30),
            exitButton.heightAnchor.constraint(equalToConstant: 40),
            exitButton.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 10)
        ])
        
        middleView.isHidden = true
        bottomView.isHidden = true
        */
        
        self.view3.isHidden = true
    }
    
    /*
    @objc func step3_ShowText2(_ sender: UIButton?){
        let middleView = self.view3.viewWithTag(300)!
        
        for view in middleView.subviews {
            if(view is UILabel) {
                (view as! UILabel).text = "We put YOU in the drivers seat and you choose what you want to be shown."
            }
        }
    }
    
    func completeStep3() {
        let headline = self.view3.viewWithTag(200)!
        let middleView = self.view3.viewWithTag(300)!
        let bottomView = self.view3.viewWithTag(400)!
        
        //let top = headline.frame.origin.y
        let h = middleView.frame.size.height
        
        bottomView.alpha = 0
        bottomView.isHidden = false
        middleView.alpha = 0
        middleView.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            bottomView.alpha = 1
            middleView.alpha = 1
            
            var mFrame = headline.frame
            mFrame.origin.y -= h
            headline.frame = mFrame
            
            mFrame = middleView.frame
            mFrame.origin.y -= h
            middleView.frame = mFrame
            
            
        } completion: { _ in
        }

    }
    */

}

///////////////////////////////////////////////////////
extension OnBoardingView: OnBoardingView3Delegate {
    func onBoardingView3Close() {
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
    
    @objc func closeButtonOnTap(_ sender: UIButton) {
        self.delegate?.onBoardingClose()
    }

}
