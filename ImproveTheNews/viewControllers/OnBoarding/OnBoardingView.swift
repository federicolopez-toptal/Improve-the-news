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
        self.createView1()
        self.createView2()
        self.createView3()
        
        //self.testSteps() // !!!
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
    
    @objc func showView2(_ sender: UIButton?) {
        self.view2.alpha = 0
        self.view2.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.view2.alpha = 1
        } completion: { _ in
            self.view1.isHidden = true
            DELAY(1.0) {
                self.showView3()
            }
        }

    }
    
    @objc func showView3() {
        self.view3.alpha = 0
        self.view3.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.view3.alpha = 1
        } completion: { _ in
            self.view2.isHidden = true
            self.view3.showStep3()
        }
    }


    // MARK: - View3 /////////////////////////
    private func createView3() {
        self.view3.insertInto(container: self)
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
        
        let label1 = UILabel()
        label1.textColor = .white
        label1.font = UIFont(name: "Merriweather-Bold", size: 22)
        label1.text = "LEFT"
        label1.textAlignment = .center
        result.addSubview(label1)
        label1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label1.topAnchor.constraint(equalTo: result.topAnchor,
                    constant: -50),
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
                    constant: -50),
            label2.widthAnchor.constraint(equalToConstant: halfScreen),
            label2.leadingAnchor.constraint(equalTo: result.leadingAnchor, constant: halfScreen)
        ])

        return result
    }
    
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
