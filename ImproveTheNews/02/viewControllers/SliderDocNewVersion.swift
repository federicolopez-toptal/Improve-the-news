//
//  SliderDocNewVersion.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 08/03/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class SliderDoc: UIViewController {

    private var firstTime = true

    private let sliderViewHeight: CGFloat = 70
    private var screenSize = UIScreen.main.bounds
    private let sliderTAGbase = 99

    let mainTitle = UILabel(text: "How the sliders work",
            font: UIFont(name: "PTSerif-Bold", size: 27),
            textColor: accentOrange, textAlignment: .left,
            numberOfLines: 1)

    let dismiss = UIButton(title: "Back", titleColor: .label,
            font: UIFont(name: "OpenSans-Bold", size: 17)!)

    let scrollView = UIScrollView()
    let contentView = UIView()
    
    // ------------------
    let textView1 = UITextView()
    let textView2 = UITextView()
    let textView3 = UITextView()
    
    let bold = ["1. Topic sliders: What topic mix do you want?",  "2. Bias sliders: What spin do you want?", "3. Style sliders: What writing style do you want?", "4. Shelf-life slider: Do you want evergreen or fresh?", "1. Bias sliders: What spin do you want?",
    "2. Style sliders: What writing style do you want?",
    "3. Shelf-life slider: Do you want evergreen or fresh?"] as [NSString]
    let paths = ["https://www.youtube.com/watch?v=PRLF17Pb6vo","https://www.allsides.com/media-bias/media-bias-ratings", "https://swprs.org/media-navigator/"]
    let linked = ["see this video demo"," here", "this classification"]
    let accented = ["left-right slider", "pro-establishment slider", "nuance slider", "depth slider", "shelf-life slider", "recent slider"]
    // ------------------
    
    let bold2 = ["3. Style sliders: What writing style do you want?", "4. Shelf-life slider: Do you want evergreen or fresh?"] as [NSString]
    let paths2: [String] = []
    let linked2: [String] = []
    let accented2 = ["nuance slider", "depth slider", "shelf-life slider", "recent slider"]
    // ------------------
    let resetButton = UIButton(title: "Reset sliders to default",
            titleColor: accentOrange)

    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = DARKMODE() ? .black : bgWhite_LIGHT
        
        if(DARKMODE() && IS_iPAD()) {
            self.view.layer.borderWidth = 2.0
            self.view.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
            self.view.layer.cornerRadius = 10.0
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return STATUS_BAR_STYLE()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(self.firstTime) {
            self.configureView()
            self.refreshSliders()
        }
        self.firstTime = false
    }

    // ----------------------------------
    private func move(_ view: UIView, x: CGFloat, y: CGFloat, bgColor: UIColor = .clear) {
        var mFrame = view.frame
        
        if(x<0) {
            mFrame.origin.x = screenSize.width - mFrame.size.width + x
        } else {
            mFrame.origin.x = x
        }
        
        mFrame.origin.y = y
        view.frame = mFrame
        view.backgroundColor = bgColor
    }
    private func place(_ view: UIView, below: UIView, yOffset: CGFloat  = 0) {
        var mFrame = view.frame
        mFrame.origin.y = below.frame.origin.y + below.frame.size.height + yOffset
        view.frame = mFrame
    }
    private func centerHorizontally(_ view: UIView) {
        var mFrame = view.frame
        mFrame.origin.x = (view.superview!.frame.size.width - mFrame.size.width)/2
        view.frame = mFrame
    }
    private func resize(_ view: UIView, width: CGFloat, height: CGFloat) {
        var mFrame = view.frame
        mFrame.size.width = width
        mFrame.size.height = height
        view.frame = mFrame
    }
    // ----------------------------------

    private func configureView() {
        
        
        
        
        self.screenSize = self.view.frame
        
        /*
        print("IPAD", UIScreen.main.bounds.width)
        print("IPAD", self.view.frame.size.width)
        */
        
        if(!DARKMODE()){
            dismiss.setTitleColor(textBlack, for: .normal)
        }
    
    
// MAIN title
        self.view.addSubview(mainTitle)
        if(IS_iPAD()) {
            mainTitle.font = UIFont(name: "PTSerif-Bold", size: 35)
        }
        mainTitle.sizeToFit()
        if(IS_ZOOMED()) {
            self.move(mainTitle, x: 15, y: 30)
        } else {
            self.move(mainTitle, x: 15, y: 5)
        }
        
// BACK button
        dismiss.titleLabel?.textColor = accentOrange
        view.addSubview(dismiss)
        dismiss.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        self.resize(dismiss, width: 65, height: 20)
        dismiss.backgroundColor = .green
        self.move(dismiss, x: -10, y: 7)

// SCROLLVIEW
        self.view.addSubview(scrollView)
        self.move(scrollView, x: 0, y: 0, bgColor: self.view.backgroundColor!)
        self.place(scrollView, below: mainTitle, yOffset: 5)
        self.resize(scrollView, width: screenSize.width,
                    height: self.view.frame.size.height - scrollView.frame.origin.y - 75)
        if(IS_iPAD()) {
            self.resize(scrollView, width: screenSize.width,
                    height: self.view.frame.size.height - scrollView.frame.origin.y - 60)
        }


// CONTENT view
        scrollView.addSubview(contentView)
        self.move(contentView, x: 0, y: 0)
        self.resize(contentView, width: screenSize.width, height: 1000)
        contentView.backgroundColor = self.view.backgroundColor!
        
// RESET button
        resetButton.layer.borderColor = accentOrange.cgColor
        resetButton.layer.borderWidth = 3
        resetButton.layer.cornerRadius = 10
        resetButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 20)
        resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        view.addSubview(resetButton)
        
        self.resize(resetButton, width: 300, height: 35)
        self.move(resetButton, x: 0, y: 0)
        if(IS_iPHONE()) {
            self.place(resetButton, below: scrollView, yOffset: 10)
        } else {
            self.place(resetButton, below: scrollView, yOffset: 5)
        }
        
        self.centerHorizontally(resetButton)
        
// TEXTVIEW(s)
        var text = ""
        var posY: CGFloat = 5
        
        var filename: String = ""
        
    // 1
        filename = "text1"
        if(!APP_CFG_SHOW_SUPER_SLIDERS){ filename += "b" }
        text = self.readTextFile(filename)
        textView1.attributedText = prettifyText(fullString: text as NSString, boldPartsOfString: bold, font: UIFont(name: "Poppins-Regular", size: 14), boldFont: UIFont(name: "Poppins-Regular", size: 22), paths: paths, linkedSubstrings: linked, accented: accented)
        textView1.textColor = DARKMODE() ? articleHeadLineColor : textBlack
        textView1.backgroundColor = .black
        textView1.isEditable = false
        contentView.addSubview(textView1)
        
        self.resize(textView1, width: screenSize.width-10, height: 100)
        textView1.sizeToFit()
        self.move(textView1, x: 5, y: posY, bgColor: self.view.backgroundColor!)
        
        posY += textView1.frame.size.height + 5
        self.resize(contentView, width: contentView.frame.size.width, height: posY)
        
    // slider 1
        let slider1a = sliderView(title: "Political Stance",
                        leftText: "LEFT", rightText: "RIGHT", sliderID: 0)
        contentView.addSubview(slider1a)
        self.place(slider1a, below: textView1)
        posY += sliderViewHeight
        
        let slider1b = sliderView(title: "Establishment Stance",
                        leftText: "CRITICAL", rightText: "PRO", sliderID: 1)
        contentView.addSubview(slider1b)
        self.place(slider1b, below: slider1a)
        posY += sliderViewHeight
        
    // 2
        filename = "text2"
        if(!APP_CFG_SHOW_SUPER_SLIDERS){ filename += "b" }
        text = self.readTextFile(filename)
        textView2.attributedText = prettifyText(fullString: text as NSString, boldPartsOfString: bold, font: UIFont(name: "Poppins-Regular", size: 14), boldFont: UIFont(name: "Poppins-Regular", size: 22), paths: paths, linkedSubstrings: linked, accented: accented)
        textView2.textColor = DARKMODE() ? articleHeadLineColor : textBlack
        textView2.backgroundColor = .black
        textView2.isEditable = false
        contentView.addSubview(textView2)
        
        self.resize(textView2, width: screenSize.width-10, height: 100)
        textView2.sizeToFit()
        self.move(textView2, x: 5, y: posY, bgColor: self.view.backgroundColor!)
        
        posY += textView2.frame.size.height + 5
        self.resize(contentView, width: contentView.frame.size.width, height: posY)
        
    // slider 2
        let slider2a = sliderView(title: "Writing Style",
                        leftText: "PROVOCATIVE", rightText: "NUANCED", sliderID: 2)
        contentView.addSubview(slider2a)
        self.place(slider2a, below: textView2)
        posY += sliderViewHeight
        
        let slider2b = sliderView(title: "Depth",
                        leftText: "BREEZY", rightText: "DETAILED", sliderID: 3)
        contentView.addSubview(slider2b)
        self.place(slider2b, below: slider2a)
        posY += sliderViewHeight
        
        
    // 3
        filename = "text3"
        if(!APP_CFG_SHOW_SUPER_SLIDERS){ filename += "b" }
        text = self.readTextFile(filename)
        textView3.attributedText = prettifyText(fullString: text as NSString, boldPartsOfString: bold, font: UIFont(name: "Poppins-Regular", size: 14), boldFont: UIFont(name: "Poppins-Regular", size: 22), paths: paths, linkedSubstrings: linked, accented: accented)
        textView3.textColor = DARKMODE() ? articleHeadLineColor : textBlack
        textView3.backgroundColor = .black
        textView3.isEditable = false
        contentView.addSubview(textView3)
        
        self.resize(textView3, width: screenSize.width-10, height: 100)
        textView3.sizeToFit()
        self.move(textView3, x: 5, y: posY, bgColor: self.view.backgroundColor!)
        
        posY += textView3.frame.size.height + 5
        self.resize(contentView, width: contentView.frame.size.width, height: posY)
        
    // slider 3
        let slider3a = sliderView(title: "Shelf-life",
                        leftText: "SHORT", rightText: "LONG", sliderID: 4)
        contentView.addSubview(slider3a)
        self.place(slider3a, below: textView3)
        posY += sliderViewHeight
        
        let slider3b = sliderView(title: "Recency",
                        leftText: "EVERGREEN", rightText: "LATEST", sliderID: 5)
        contentView.addSubview(slider3b)
        self.place(slider3b, below: slider3a)
        posY += sliderViewHeight
        
        posY += 40
        self.resize(contentView, width: contentView.frame.size.width, height: posY)
        
        scrollView.contentSize = contentView.frame.size
    }
    
    private func sliderView(title: String, leftText: String, rightText: String, sliderID: Int) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = self.view.backgroundColor!
        self.resize(view, width: screenSize.width, height: sliderViewHeight)
        
        let titleLabel = UILabel(frame: CGRect(x: 5, y: 0, width: 400, height: 30))
        titleLabel.font = UIFont(name: "Poppins-Regular", size: 22)
        titleLabel.textColor = DARKMODE() ? .white : textBlack
        titleLabel.backgroundColor = .clear
        titleLabel.text = title
        view.addSubview(titleLabel)

        let leftLabel = UILabel(frame: CGRect(x: 10, y: 35, width: 400, height: 20))
        leftLabel.font = UIFont(name: "Poppins-Regular", size: 13)
        leftLabel.textColor = DARKMODE() ? .white : textBlack
        leftLabel.backgroundColor = .clear
        leftLabel.text = leftText
        view.addSubview(leftLabel)
        
        let rightLabel = UILabel(frame: CGRect(x: screenSize.width-400-10, y: 35, width: 400, height: 20))
        rightLabel.font = UIFont(name: "Poppins-Regular", size: 13)
        rightLabel.textColor = DARKMODE() ? .white : textBlack
        rightLabel.textAlignment = .right
        rightLabel.backgroundColor = .clear
        rightLabel.text = rightText
        view.addSubview(rightLabel)
        
        let slider = UISlider(backgroundColor: .red)
        self.resize(slider, width: screenSize.width - 200, height: 20)
        self.move(slider, x: 0, y: 35)
        view.addSubview(slider)
        self.centerHorizontally(slider)
        slider.minimumValue = 0
        slider.maximumValue = 99
        slider.minimumTrackTintColor = .orange
        slider.maximumTrackTintColor = .lightGray
        slider.backgroundColor = .clear
        slider.tag = sliderTAGbase + sliderID
        slider.isContinuous = false
        slider.addTarget(self, action: #selector(self.biasSliderValueDidChange(_:)), for: .valueChanged)
        
        return view
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func reset() {
        resetToDefaults()   // global
        refreshSliders()    // in this screen
        
        
    }
    
    private func readTextFile(_ filename: String) -> String {
        let path = Bundle.main.path(forResource: filename, ofType: "txt")
        var string = ""
        do {
            string = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        } catch {
            print("Error!", error)
        }
        
        return string
    }
    
    @objc func biasSliderValueDidChange(_ sender: UISlider!){
        let index = sender.tag - sliderTAGbase
        let key = sliderIDs[index]
        UserDefaults.setSliderValue(value: sender.value, slider: key)
    }
    
    private let sliderIDs = ["LeRi", "proest", "nuance", "depth", "shelflife", "recency"]
    private func refreshSliders() {
        for id in sliderIDs {
            self.refreshSlider(id: id)
        }
    }
    
    private func refreshSlider(id sliderId: String) {
        
        var index = -1
        for (i, id) in sliderIDs.enumerated() {
            if(id==sliderId) {
                index = i
                break
            }
        }
        
        if(index != -1) {
            let tag = sliderTAGbase + index
            let value = UserDefaults.getValue(key: sliderId)
            if let slider = contentView.viewWithTag(tag) {
                (slider as! UISlider).value = value
            }
        }
    }
    
    
    
}
