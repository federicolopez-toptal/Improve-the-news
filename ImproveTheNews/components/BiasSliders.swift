//
//  SliderPopup.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 8/17/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

@objc protocol BiasSliderDelegate {
    func biasSliderDidChange(sliderId: Int)
    @objc optional func splitValueChange()
}

protocol ShadeDelegate {
    func dismissShade()
    func panelFullyOpened()
}

class SliderPopup: UIView {
    
    private var politicalStance = false
    private var establishmentStance = false
    
    let state01_height: CGFloat = 230
    let state02_height: CGFloat = 480 //480
    var latestBiasSliderUsed: Int = -1
    
    
    var sliderValues: SliderValues!
    
    var activityView = UIActivityIndicatorView()
    
    var stackView = UIStackView()
    
    let labels = [
            "Political stance","Establishment stance","Writing style","Depth","Shelf-life","Recency"
    ]
    let descriptions = [["LEFT", "RIGHT"], ["CRITICAL", "PRO"], ["PROVOCATIVE", "NUANCED"], ["BREEZY", "DETAILED"],
                        ["SHORT", "LONG"], ["EVERGREEN", "LATEST"]]
    let keys = ["LeRi", "proest", "nuance", "depth", "shelflife", "recency"]
    
    lazy var showMore: UIButton = {
        let button = UIButton(image: UIImage(systemName: "chevron.up.circle.fill")!, tintColor: biasSliderColor, target: self, action: #selector(handleShowMore))
        return button
    }()
    
    var sliderDelegate: BiasSliderDelegate?
    var shadeDelegate: ShadeDelegate?
    
    var isShowingMore = false
    var loadingView = UIView()
    
    var separatorView = UIView()
    
    var status: String = "SL00"
    
    public func stanceValues() -> (Bool, Bool) {
        return (politicalStance, establishmentStance)
    }
}

extension SliderPopup {
    
    func buildViews() {
        
        sliderValues = SliderValues.sharedInstance
        
        self.layer.cornerRadius = 30
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
        //let controls = UIView()
        
        let lineContainer = UIView()
        let w: CGFloat = 60
        let h: CGFloat = 35
        let valx = (UIScreen.main.bounds.width-w)/2
        let lineView = UIView(frame: CGRect(x: valx, y: h-8-10, width: w, height: 8))
        lineView.layer.cornerRadius = 4
        lineView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        lineContainer.addSubview(lineView)
        stackView.addArrangedSubview(lineContainer)
        lineContainer.translatesAutoresizingMaskIntoConstraints = false
        lineContainer.heightAnchor.constraint(equalToConstant: h).isActive = true
        lineContainer.backgroundColor = .clear
        
        /*
        draggableLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            draggableLine.heightAnchor.constraint(equalToConstant: 4),
            draggableLine.widthAnchor.constraint(equalToConstant: 50),
            draggableLine.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5)
        ])
        */
        
        /*
        let title = createTitle(name: "Preferences")
        title.textColor = biasSliderColor
        let dismiss = UIButton(image: UIImage(systemName: "xmark.circle.fill")!, tintColor: biasSliderColor, target: self, action: #selector(handleDismiss))
        title.frame = CGRect(x: 10, y: 3, width: stackView.frame.width - 65, height: 40)
        dismiss.frame = CGRect(x: title.frame.maxX, y: 3, width: 50, height: 40)
        controls.addSubview(title)
        controls.addSubview(dismiss)
        controls.backgroundColor = .green
        stackView.addArrangedSubview(controls)
        controls.translatesAutoresizingMaskIntoConstraints = false
        controls.heightAnchor.constraint(equalToConstant: 40).isActive = true
        */
        
        let margin: CGFloat = 20
        
        // the actual sliders
        for i in 0..<labels.count {
            let miniview = UIView()
            
            stackView.addArrangedSubview(miniview)
            miniview.translatesAutoresizingMaskIntoConstraints = false
            miniview.heightAnchor.constraint(equalToConstant: 60).isActive = true
            miniview.isUserInteractionEnabled = true

            
            let name = UILabel(text: labels[i], font: UIFont(name: "Poppins-SemiBold", size: 17), textColor: biasSliderTitles, textAlignment: .left, numberOfLines: 1)
            name.frame = CGRect(x: margin, y: 0, width: stackView.frame.width-(margin*2), height: 30)
            //name.backgroundColor = .blue
            
            let minLabel = createLabel(name: descriptions[i][0])
            let maxLabel = createLabel(name: descriptions[i][1])
            
            let slider = UISlider(backgroundColor: .clear)
            slider.frame = CGRect(x:(UIScreen.main.bounds.width-(stackView.frame.width - 210))/2,
                y: name.frame.maxY+3,
                width: stackView.frame.width - 210,
                height: 20)
            slider.minimumValue = 0
            slider.maximumValue = 99
            //slider.tintColor = .white
            slider.minimumTrackTintColor = .orange
            slider.maximumTrackTintColor = .lightGray
            slider.addTarget(self, action: #selector(self.biasSliderValueDidChange(_:)), for: .valueChanged)
            slider.tag = i + 50
            slider.isContinuous = false
            minLabel.frame = CGRect(x: margin, y: name.frame.maxY+3, width: 95, height: 20)
            maxLabel.frame = CGRect(x: UIScreen.main.bounds.width - 95 - margin,
                y: name.frame.maxY+3, width: 95, height: 20)
            
            minLabel.textAlignment = .left
            //minLabel.backgroundColor = UIColor.black.withAlphaComponent(0.25)
            maxLabel.textAlignment = .right
            //maxLabel.backgroundColor = UIColor.black.withAlphaComponent(0.25)
            
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
                separatorView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                separatorView.translatesAutoresizingMaskIntoConstraints = false
                separatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
                stackView.addArrangedSubview(separatorView)
            }
            
            if(i<2 && Utils.shared.currentLayout == .denseIntense) {
                let w: CGFloat = 80
                let x: CGFloat = slider.frame.origin.x + slider.frame.size.width - 55
                let splitLabel = UILabel(frame: CGRect(x: x, y: 3, width: w, height: 25))
                splitLabel.backgroundColor = .clear
                splitLabel.text = "Split"
                splitLabel.textColor = .black
                splitLabel.textAlignment = .right
                splitLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)

                let splitButton = UIButton(type: .custom)
                splitButton.frame = CGRect(x: x+20, y: 4, width: 60, height: 22)
                splitButton.tag = i
                splitButton.tintColor = .black
                splitButton.contentHorizontalAlignment = .left
                splitButton.setImage(UIImage(systemName: "square"), for: .normal)
                splitButton.addTarget(self, action: #selector(splitButtonTap(sender:)),
                    for: .touchUpInside)
                splitButton.backgroundColor = .clear
                
                var mFrame = slider.frame
                mFrame.origin.y -= 5
                mFrame.size.height += 10
                let splitSliderView = UIView(frame: mFrame)
                splitSliderView.backgroundColor = accentOrange
                
                    let H: CGFloat = 4.5
                    let W: CGFloat = mFrame.size.width - 6
                    let X: CGFloat = (mFrame.size.width-W)/2
                    let Y: CGFloat = (mFrame.size.height - H)/2
                    
                    let sliderLine = UIView(frame: CGRect(x: X, y: Y,
                                            width: W, height: H))
                    sliderLine.layer.cornerRadius = H/2
                    sliderLine.backgroundColor = .orange
                    splitSliderView.addSubview(sliderLine)
                    
                    let grayHalf = UIView(frame: CGRect(x: X + (W/2), y: Y,
                                            width: W/2, height: H))
                    grayHalf.layer.cornerRadius = H/2
                    grayHalf.backgroundColor = .lightGray
                    splitSliderView.addSubview(grayHalf)
                    
                    let vline = UIView(frame: CGRect(x: X + (W/2),
                    y: (mFrame.size.height-20)/2, width: 4.5, height: 20))
                    vline.layer.cornerRadius = 2.25
                    vline.backgroundColor = .white
                    splitSliderView.addSubview(vline)
                    
                
                miniview.addSubview(splitLabel)
                miniview.addSubview(splitButton)
                
                miniview.addSubview(splitSliderView)
                splitSliderView.tag = 99 + i
                splitSliderView.isHidden = true
                
                
                let dirs: [UISwipeGestureRecognizer.Direction] = [.left, .right, .up, .down]
                for D in dirs {
                    let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.splitViewOnGesture(gesture:)))
                    gesture.direction = D
                    splitSliderView.addGestureRecognizer(gesture)
                }
                
                
                let gesture = UITapGestureRecognizer(target: self, action: #selector(self.splitViewOnGesture(gesture:)))
                splitSliderView.addGestureRecognizer(gesture)
                
            }
            
            

        }
        
        
        // add showLess button
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        //bottomView.backgroundColor = .green
        stackView.addArrangedSubview(bottomView)
        
        let showLess = UIButton(image: UIImage(systemName: "chevron.down.circle.fill")!, tintColor: biasSliderColor, target: self, action: #selector(handleShowLess))
        //bottomView.addSubview(showLess)
        showLess.translatesAutoresizingMaskIntoConstraints = false
        showLess.heightAnchor.constraint(equalToConstant: 35).isActive = true
        /*
        let xConstraint = NSLayoutConstraint(item: showLess, attribute: .centerX, relatedBy: .equal, toItem: bottomView, attribute: .centerX, multiplier: 1, constant: 0)
        bottomView.addConstraint(xConstraint)
        showLess.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 3).isActive = true
        */
        
        //swipe gestures
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleShowMore))
        swipeUp.direction = .up
        stackView.addGestureRecognizer(swipeUp)
        
        //if (!isShowingMore) {
        
        if(self.status=="SL00") {
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleDismiss))
            swipeDown.direction = .down
            stackView.addGestureRecognizer(swipeDown)
        } else {
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleShowLess))
            swipeDown.direction = .down
            stackView.addGestureRecognizer(swipeDown)
        }
    }
    
    func disableSplit() {

        if(politicalStance) {
            let row = self.stackView.subviews[2]
            for v in row.subviews {
                if(v is UIButton) {
                    self.splitButtonTap(sender: (v as! UIButton))
                    break
                }
            }
        } else if(establishmentStance) {
            let row = self.stackView.subviews[3]
            for v in row.subviews {
                if(v is UIButton) {
                    self.splitButtonTap(sender: (v as! UIButton))
                    break
                }
            }
        }
    }
    
    @objc func splitViewOnGesture(gesture: UIGestureRecognizer) {
        let tag = gesture.view!.tag - 99
        for V in gesture.view!.superview!.subviews {
            if(V is UIButton) {
                self.splitButtonTap(sender: (V as! UIButton))
                break
            }
        }
    }
    
    
    private func updateCheckBox(_ button: UIButton, value: Bool) {
        let img = value ? UIImage(systemName: "checkmark.square") :
            UIImage(systemName: "square")
        button.setImage(img, for: .normal)
    }
    
    @objc func splitButtonTap(sender: UIButton) {
        
        // update values
        if(sender.tag==0) {
            // Political stance
            politicalStance = !politicalStance
            if(politicalStance) {
                establishmentStance = false
            }
        } else {
            // Establishment stance
            establishmentStance = !establishmentStance
            if(establishmentStance) {
                politicalStance = false
            }
        }
        
        // update checkboxes
        let row1 = self.stackView.subviews[2]
        for v in row1.subviews {
            if(v is UIButton) {
                self.updateCheckBox((v as! UIButton), value: politicalStance)
                break
            }
        }
        let row2 = self.stackView.subviews[3]
        for v in row2.subviews {
            if(v is UIButton) {
                self.updateCheckBox((v as! UIButton), value: establishmentStance)
                break
            }
        }
        
        // show/hide the slider replica
        let slider1Replica = row1.viewWithTag(99+0)
        slider1Replica?.isHidden = !politicalStance
        
        let slider2Replica = row2.viewWithTag(99+1)
        slider2Replica?.isHidden = !establishmentStance
        
        
        
        /*
        var value = false
        if(sender.tag==0) {
            // Political stance
            politicalStance = !politicalStance
            value = politicalStance
        } else {
            // Establishment stance
            establishmentStance = !establishmentStance
            value = establishmentStance
        }
        */

        /*
        let overlapView = sender.superview?.viewWithTag(99+sender.tag)
        overlapView?.isHidden = !value

        let img = value ? UIImage(systemName: "checkmark.square") :
            UIImage(systemName: "square")
        sender.setImage(img, for: .normal)
        */
        
        if let valueChanged = self.sliderDelegate?.splitValueChange {
            valueChanged()
        }
    }
    
    func reloadSliderValues() {
        for (i, key) in keys.enumerated() {
            let value = UserDefaults.getValue(key: key)
            let tag = i + 50
            
            if let slider = stackView.viewWithTag(tag) as? UISlider {
                slider.value = value
            }
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
        /*
        if (showMore.isHidden) {
            showMore.isHidden = false
        }
        stackView.insertArrangedSubview(showMore, at: 1)
        showMore.translatesAutoresizingMaskIntoConstraints = false
        showMore.heightAnchor.constraint(equalToConstant: 35).isActive = true
        */
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
        var w: CGFloat = 140
        var x = UIScreen.main.bounds.width - w - 17
        self.loadingView.frame = CGRect(x: x, y: 40, width: w, height: 25)
        self.loadingView.backgroundColor = .clear
        self.addSubview(loadingView)
        
        x = self.loadingView.frame.size.width - 20
        let loading = UIActivityIndicatorView(style: .medium)
        loading.frame = CGRect(x: x, y: 0, width: 20, height: 20)
        loading.startAnimating()
        loading.color = .white
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
        
        self.loadingView.backgroundColor = accentOrange
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
        self.latestBiasSliderUsed = sender.tag
        
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
        sliderDelegate?.biasSliderDidChange(sliderId: sender.tag)
    }
    
    
    // cancel button
    @objc func handleDismiss() {
        self.status = "SL00"
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
        
        self.status = "SL02"
        //let height = CGFloat(490) //490
        let screenSize = UIScreen.main.bounds.size
        
        UIView.animate(withDuration: 0.5, animations: {
            self.showMore.isHidden = true
            self.frame = CGRect(x: 0, y: screenSize.height-88-self.state02_height, width: screenSize.width, height: self.frame.height)
        })
        
        self.separatorView.isHidden = true
        //showMore.isHidden = true
        //stackView.arrangedSubviews[0].removeFromSuperview()
        
        self.shadeDelegate?.panelFullyOpened()
    }
    
    // hide nonessential sliders
    @objc func handleShowLess() {
        
        if isShowingMore {
            isShowingMore = false
        }
        
        self.status = "SL01"
        let height = CGFloat(270) // 220
        let screenSize = UIScreen.main.bounds.size
        
        UIView.animate(withDuration: 0.5, animations: {
            self.showMore.isHidden = false
            self.frame = CGRect(x: 0, y: screenSize.height - height - 88, width: screenSize.width, height: self.frame.height)
        })
        
        self.separatorView.isHidden = false
        addShowMore()
    }
    
}
