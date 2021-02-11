//
//  SliderPopup.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 8/17/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

protocol BiasSliderDelegate {
    func biasSliderDidChange()
}

protocol ShadeDelegate {
    func dismissShade()
}

class SliderPopup: UIView {
    
    var sliderValues: SliderValues!
    
    var activityView = UIActivityIndicatorView()
    
    var stackView = UIStackView()
    
    let labels = [
            "Political stance","Establishment stance","Writing style","Depth","Shelf-life","Recency"
    ]
    let descriptions = [["LEFT", "RIGHT"], ["CRITICAL", "PRO"], ["PROVOCATIVE", "NUANCED"], ["BREEZY", "DETAILED"],
                        ["BRIEF", "LONG"], ["EVERGREEN", "LATEST"]]
    let keys = ["LeRi", "proest", "nuance", "depth", "shelflife", "recency"]
    
    lazy var showMore: UIButton = {
        let button = UIButton(image: UIImage(systemName: "chevron.up.circle.fill")!, tintColor: biasSliderColor, target: self, action: #selector(handleShowMore))
        return button
    }()
    
    var sliderDelegate: BiasSliderDelegate?
    var shadeDelegate: ShadeDelegate?
    
    var isShowingMore = false
    var loadingView = UIView()
}

extension SliderPopup {
    
    func buildViews() {
        
        sliderValues = SliderValues.sharedInstance
        
        self.layer.cornerRadius = 20
        self.layer.shadowRadius = 12
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 10)
        
        addSubview(stackView)
        
        setUpActivityIndicator()
        setupLoading()
        
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
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        
        // title + "x" out button
        let controls = UIView()
        let title = createTitle(name: "Preferences")
        title.textColor = biasSliderColor
        let dismiss = UIButton(image: UIImage(systemName: "xmark.circle.fill")!, tintColor: biasSliderColor, target: self, action: #selector(handleDismiss))
        title.frame = CGRect(x: 10, y: 3, width: stackView.frame.width - 65, height: 40)
        dismiss.frame = CGRect(x: title.frame.maxX, y: 3, width: 50, height: 40)
        controls.addSubview(title)
        controls.addSubview(dismiss)
        stackView.addArrangedSubview(controls)
        controls.translatesAutoresizingMaskIntoConstraints = false
        controls.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // the actual sliders
        for i in 0..<labels.count {
            let miniview = UIView()
            
            stackView.addArrangedSubview(miniview)
            miniview.translatesAutoresizingMaskIntoConstraints = false
            miniview.heightAnchor.constraint(equalToConstant: 60).isActive = true
            miniview.isUserInteractionEnabled = true

            
            let name = UILabel(text: labels[i], font: UIFont(name: "Poppins-SemiBold", size: 17), textColor: biasSliderTitles, textAlignment: .left, numberOfLines: 1)
            name.frame = CGRect(x: 10, y: 0, width: stackView.frame.width, height: 30)
            
            let minLabel = createLabel(name: descriptions[i][0])
            let maxLabel = createLabel(name: descriptions[i][1])
            
            let slider = UISlider(backgroundColor: .clear)
            slider.frame = CGRect(x: 90, y: name.frame.maxY+3, width: stackView.frame.width - 180, height: 20)
            slider.minimumValue = 0
            slider.maximumValue = 99
            //slider.tintColor = .white
            slider.minimumTrackTintColor = .orange
            slider.maximumTrackTintColor = .lightGray
            slider.addTarget(self, action: #selector(self.biasSliderValueDidChange(_:)), for: .valueChanged)
            slider.tag = i + 50
            slider.isContinuous = false
            minLabel.frame = CGRect(x: 10, y: name.frame.maxY+3, width: 75, height: 20)
            maxLabel.frame = CGRect(x: slider.frame.maxX + 5, y: name.frame.maxY+3, width: 75, height: 20)
            
            minLabel.textAlignment = .center
            maxLabel.textAlignment = .center
            
            var v = Float(0)
            let k = keys[i]
            if UserDefaults.exists(key: k) {
                v = UserDefaults.getValue(key: k)
            } else {
                if i == 0 || i == 1 {
                    UserDefaults.setSliderValue(value: 50, slider: k)
                    v = 50
                } else {
                    UserDefaults.setSliderValue(value: 70, slider: k)
                    v = 70
                }
            
            }
    
            slider.setValue(v, animated: false)
            
            miniview.addSubview(name)
            miniview.addSubview(slider)
            miniview.addSubview(minLabel)
            miniview.addSubview(maxLabel)
            
            if(i==1) {
                let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                separatorView.translatesAutoresizingMaskIntoConstraints = false
                separatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
                stackView.addArrangedSubview(separatorView)
            }

        }
        
        // add showLess button
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.addArrangedSubview(bottomView)
        
        let showLess = UIButton(image: UIImage(systemName: "chevron.down.circle.fill")!, tintColor: biasSliderColor, target: self, action: #selector(handleShowLess))
        showLess.translatesAutoresizingMaskIntoConstraints = false
        showLess.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        let xConstraint = NSLayoutConstraint(item: showLess, attribute: .centerX, relatedBy: .equal, toItem: bottomView, attribute: .centerX, multiplier: 1, constant: 0)
        bottomView.addConstraint(xConstraint)
        
        bottomView.addSubview(showLess)
        
        
        //swipe gestures
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleShowMore))
        swipeUp.direction = .up
        stackView.addGestureRecognizer(swipeUp)
        
        if (!isShowingMore) {
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleDismiss))
            swipeDown.direction = .down
            stackView.addGestureRecognizer(swipeDown)
        } else {
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleShowLess))
            swipeDown.direction = .down
            stackView.addGestureRecognizer(swipeDown)
        }
    }
    
    func setUpActivityIndicator() {
        self.activityView = UIActivityIndicatorView(style: .medium)
        activityView.frame = CGRect(x: (UIScreen.main.bounds.width/2), y: 30, width: 20, height: 20)
        activityView.hidesWhenStopped = true
        stackView.addSubview(activityView)
    }
    
    func createTitle(name: String) -> UILabel {
        let title = UILabel(text: name, font: UIFont(name: "PTSerif-Bold", size: 30), textColor: .label, textAlignment: .left, numberOfLines: 1)
        
        return title
    }
    
    func createLabel(name: String) -> UILabel {
        let title = UILabel(text: name, font: UIFont(name: "Poppins-SemiBold", size: 12), textColor: articleHeadLineColor, textAlignment: .left, numberOfLines: 1)
        
        return title
    }
    
    func addShowMore() {
        if (showMore.isHidden) {
            showMore.isHidden = false
        }
        stackView.insertArrangedSubview(showMore, at: 1)
        showMore.translatesAutoresizingMaskIntoConstraints = false
        showMore.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    func resetSliders() {
        
        for i in 0..<labels.count {
            let tag = i + 50
            if let view = self.viewWithTag(tag) {
                if let slider = view as? UISlider {
                    let value = UserDefaults.getValue(key: keys[i])
                    slider.setValue(value, animated: false)
                }
            }
        }
        
    }
    
    
    func setupLoading() {
        var w: CGFloat = 250
        var x = UIScreen.main.bounds.width - w - 17
        self.loadingView.frame = CGRect(x: x, y: 40, width: w, height: 25)
        self.loadingView.backgroundColor = .clear
        self.addSubview(loadingView)
        
        x = self.loadingView.frame.size.width - 20
        let loading = UIActivityIndicatorView(style: .medium)
        loading.frame = CGRect(x: x, y: 0, width: 20, height: 20)
        loading.startAnimating()
        loading.color = .black
        self.loadingView.addSubview(loading)
        
        w = 200
        x = loading.frame.origin.x - 7 - w
        let label = UILabel(frame: CGRect(x: x, y: 0, width: w, height: 25))
        label.backgroundColor = .clear
        label.text = "Updating your feed"
        label.textColor = .black
        label.textAlignment = .right
        label.font = UIFont(name: "Poppins-SemiBold", size: 12)
        
        self.loadingView.addSubview(label)
        self.showLoading(false)
    }
    
    func moveLoadingOnTopOfView(_ view: UIView) {
        var mFrame = self.loadingView.frame
        mFrame.origin.y = view.frame.origin.y - mFrame.size.height + 27
        self.loadingView.frame = mFrame
    }
    
    func showLoading(_ visibility: Bool) {
        self.loadingView.isHidden = !visibility
    }
    
}

// gesture recognizers
extension SliderPopup: UIGestureRecognizerDelegate {
    
    @objc func biasSliderValueDidChange(_ sender:UISlider!){
        let view = sender.superview!
        self.moveLoadingOnTopOfView(view)
    
        print("bias slider value did change")
        switch sender.tag {
            case 50:
                self.sliderValues.setLR(LR: Int(sender.value))
                UserDefaults.setSliderValue(value: Float(self.sliderValues.getLR()), slider: "LeRi")
                print("lr changed to \(self.sliderValues.getLR())")
                break
            case 51:
                self.sliderValues.setPE(PE: Int(sender.value))
                UserDefaults.setSliderValue(value: Float(self.sliderValues.getPE()), slider: "proest")
                print("pe changed to \(self.sliderValues.getPE())")
                break
            case 52:
                self.sliderValues.setNU(NU: Int(sender.value))
                UserDefaults.setSliderValue(value: Float(self.sliderValues.getNU()), slider: "nuance")
                print("NU changed to \(self.sliderValues.getNU())")
                break
            case 53:
                self.sliderValues.setDE(DE: Int(sender.value))
                UserDefaults.setSliderValue(value: Float(self.sliderValues.getDE()), slider: "depth")
                print("DE changed to \(self.sliderValues.getDE())")
                break
            case 54:
                self.sliderValues.setSL(SL: Int(sender.value))
                UserDefaults.setSliderValue(value: Float(self.sliderValues.getSL()), slider: "shelflife")
                print("SL changed to \(self.sliderValues.getSL())")
                break
            case 55:
                self.sliderValues.setRE(RE: Int(sender.value))
                UserDefaults.setSliderValue(value: Float(self.sliderValues.getRE()), slider: "recency")
                print("RE changed to \(self.sliderValues.getRE())")
                break
            default:
                print("unidentified slider value changed")
        }
        sliderDelegate?.biasSliderDidChange()
    }
    
    
    // cancel button
    @objc func handleDismiss() {
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.5, animations: {
            self.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.frame.height)
        })
        
        shadeDelegate?.dismissShade()
    }
    
    // show all sliders
    @objc func handleShowMore() {
        
        if !isShowingMore {
            isShowingMore = true
        }
        
        let height = CGFloat(550) //480
        let screenSize = UIScreen.main.bounds.size
        
        UIView.animate(withDuration: 0.5, animations: {
            self.showMore.isHidden = true
            self.frame = CGRect(x: 0, y: screenSize.height - height - 88, width: screenSize.width, height: self.frame.height)
        })
        
        showMore.isHidden = true
        //stackView.arrangedSubviews[0].removeFromSuperview()
    }
    
    // hide nonessential sliders
    @objc func handleShowLess() {
        
        if isShowingMore {
            isShowingMore = false
        }
        
        let height = CGFloat(270) // 220
        let screenSize = UIScreen.main.bounds.size
        
        UIView.animate(withDuration: 0.5, animations: {
            self.showMore.isHidden = false
            self.frame = CGRect(x: 0, y: screenSize.height - height - 88, width: screenSize.width, height: self.frame.height)
        })
        
        addShowMore()
    }
    
}
