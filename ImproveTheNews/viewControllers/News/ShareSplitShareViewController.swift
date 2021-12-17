//
//  ShareSplitShareViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 01/12/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit
import SDWebImage

let NOTIFICATION_CLOSE_SPLITSHARE = Notification.Name("closeSplitShare")

class ShareSplitShareViewController: UIViewController {

    var articles: [(String, String, String, String, Bool)]?
    private var article1: (String, String, String, String, Bool)?
    private var article2: (String, String, String, String, Bool)?
    let blueContainer = UIView()

    let scrollview = UIScrollView()
    let contentView = UIView()
    var scrollviewBottomConstraint: NSLayoutConstraint?
    let textInput = UITextView()

    let loadingView = UIView()


    override func viewDidLoad() {
        self.view.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT

        if let _arts = self.articles {
            self.article1 = _arts[0]
            self.article2 = _arts[1]
        }
        
        let valY: CGFloat = SAFE_AREA()!.top
        
        self.scrollview.backgroundColor = self.view.backgroundColor
        self.view.addSubview(self.scrollview)
        self.scrollview.translatesAutoresizingMaskIntoConstraints = false
        self.scrollviewBottomConstraint = self.scrollview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            self.scrollview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollview.topAnchor.constraint(equalTo: self.view.topAnchor, constant: valY),
            self.scrollviewBottomConstraint!
        ])
            
        let closeButton = UIButton(type: .custom)
        closeButton.backgroundColor = .clear
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        if(!DARKMODE()){ closeButton.tintColor = UIColor.black.withAlphaComponent(0.5) }
        self.view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalToConstant: 50),
            closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: valY)
        ])
        closeButton.addTarget(self, action: #selector(closeButtonOnTap(sender:)),
            for: .touchUpInside)
        
        let contentHeight: CGFloat = 800
        self.contentView.backgroundColor = self.view.backgroundColor
        self.scrollview.addSubview(self.contentView)
        self.contentView.frame = CGRect(x: 0, y: 0,
            width: UIScreen.main.bounds.size.width, height: contentHeight)
        self.scrollview.contentSize = self.contentView.frame.size
        
        
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.text = "Share the split &\nimprove the news!"
        titleLabel.textColor = .white
        if(!DARKMODE()){ titleLabel.textColor = UIColor.black.withAlphaComponent(0.25) }
        titleLabel.font = UIFont(name: "Merriweather-Bold", size: 22)
        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
        ])
        
        blueContainer.backgroundColor = UIColor(hex: 0x283E60)
        self.contentView.addSubview(blueContainer)
        blueContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blueContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            blueContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                constant: -20),
            blueContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            blueContainer.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        let half = (UIScreen.main.bounds.size.width - 40)/2
        let splitOption = UserDefaults.standard.integer(forKey: "userSplitPrefs")
        
        let header1 = UILabel()
        header1.textColor = .white
        header1.text = "LEFT"
        if(splitOption==2){ header1.text = "CRITICAL" }
        header1.textAlignment = .center
        header1.font = UIFont(name: "PTSerif-Bold", size: 20)
        blueContainer.addSubview(header1)
        header1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header1.leadingAnchor.constraint(equalTo: blueContainer.leadingAnchor),
            header1.topAnchor.constraint(equalTo: blueContainer.topAnchor, constant: 13),
            header1.widthAnchor.constraint(equalToConstant: half)
        ])
        
        let header2 = UILabel()
        header2.textColor = .white
        header2.text = "RIGHT"
        if(splitOption==2){ header2.text = "PRO" }
        header2.textAlignment = .center
        header2.font = UIFont(name: "PTSerif-Bold", size: 20)
        blueContainer.addSubview(header2)
        header2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header2.leadingAnchor.constraint(equalTo: blueContainer.leadingAnchor, constant: half),
            header2.topAnchor.constraint(equalTo: blueContainer.topAnchor, constant: 13),
            header2.widthAnchor.constraint(equalToConstant: half)
        ])
        
        let image1 = UIImageView()
        image1.backgroundColor = .gray
        image1.clipsToBounds = true
        image1.contentMode = .scaleAspectFill
        blueContainer.addSubview(image1)
        image1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image1.widthAnchor.constraint(equalToConstant: 150),
            image1.heightAnchor.constraint(equalToConstant: 95),
            image1.topAnchor.constraint(equalTo: header1.bottomAnchor, constant: 10),
            image1.centerXAnchor.constraint(equalTo: header1.centerXAnchor)
        ])
        
        let image2 = UIImageView()
        image2.backgroundColor = .gray
        image2.clipsToBounds = true
        image2.contentMode = .scaleAspectFill
        blueContainer.addSubview(image2)
        image2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image2.widthAnchor.constraint(equalTo: image1.widthAnchor),
            image2.heightAnchor.constraint(equalTo: image1.heightAnchor),
            image2.topAnchor.constraint(equalTo: header2.bottomAnchor, constant: 10),
            image2.centerXAnchor.constraint(equalTo: header2.centerXAnchor)
        ])
        
        let title1 = UILabel()
        title1.textColor = .white
        title1.textAlignment = .left
        title1.font = UIFont(name: "Roboto-Bold", size: 16)
        title1.numberOfLines = 0
        title1.lineBreakMode = .byClipping
        title1.adjustsFontSizeToFitWidth = true
        title1.minimumScaleFactor = 0.5
        //title1.backgroundColor = .red
        title1.text = "UK government reveals net zero plan it says will create up to 440,000 jobs"
        blueContainer.addSubview(title1)
        title1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title1.leadingAnchor.constraint(equalTo: image1.leadingAnchor),
            title1.topAnchor.constraint(equalTo: image1.bottomAnchor, constant: 11),
            title1.widthAnchor.constraint(equalTo: image1.widthAnchor)
        ])
        
        let title2 = UILabel()
        title2.textColor = .white
        title2.textAlignment = .left
        title2.font = UIFont(name: "Roboto-Bold", size: 16)
        title2.numberOfLines = 0
        title2.adjustsFontSizeToFitWidth = true
        title2.minimumScaleFactor = 0.5
        //title2.backgroundColor = .red
        title2.text = "UK government reveals net zero plan it says will create up to 440,000 jobs"
        blueContainer.addSubview(title2)
        title2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title2.leadingAnchor.constraint(equalTo: image2.leadingAnchor),
            title2.topAnchor.constraint(equalTo: image2.bottomAnchor, constant: 11),
            title2.widthAnchor.constraint(equalTo: image2.widthAnchor)
        ])
        
        let source1 = UILabel()
        source1.textColor = UIColor.white.withAlphaComponent(0.5)
        source1.text = "asdasda"
        source1.font = title1.font
        source1.adjustsFontSizeToFitWidth = true
        source1.minimumScaleFactor = 0.5
        blueContainer.addSubview(source1)
        source1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            source1.leadingAnchor.constraint(equalTo: title1.leadingAnchor),
            source1.widthAnchor.constraint(equalTo: title1.widthAnchor),
            source1.topAnchor.constraint(equalTo: blueContainer.topAnchor, constant: 300)
        ])
        
        let source2 = UILabel()
        source2.textColor = UIColor.white.withAlphaComponent(0.5)
        source2.text = "asdasda"
        source2.font = title1.font
        source2.adjustsFontSizeToFitWidth = true
        source2.minimumScaleFactor = 0.5
        blueContainer.addSubview(source2)
        source2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            source2.leadingAnchor.constraint(equalTo: title2.leadingAnchor),
            source2.widthAnchor.constraint(equalTo: title2.widthAnchor),
            source2.topAnchor.constraint(equalTo: blueContainer.topAnchor, constant: 300)
        ])
        
        if let _a1 = self.article1 {
            image1.sd_setImage(with: URL(string: _a1.0), placeholderImage: nil)
            title1.text = _a1.1
            title1.sizeToFit()
            source1.text = _a1.3.components(separatedBy: " - ")[0]
        }
        if let _a2 = self.article2 {
            image2.sd_setImage(with: URL(string: _a2.0), placeholderImage: nil)
            title2.text = _a2.1
            source2.text = _a2.3.components(separatedBy: " - ")[0]
        }
        
        let logo = UIImageView()
        logo.image = UIImage(named: "N64")
        blueContainer.addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logo.leadingAnchor.constraint(equalTo: blueContainer.leadingAnchor, constant: 19),
            logo.bottomAnchor.constraint(equalTo: blueContainer.bottomAnchor, constant: -20),
            logo.widthAnchor.constraint(equalToConstant: 30),
            logo.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let footer = UILabel()
        footer.textColor = .white
        footer.font = UIFont(name: "Roboto-Bold", size: 12)
        footer.textAlignment = .right
        footer.numberOfLines = 3
        var spectrum = "POLITICAL"
        if(splitOption==2){ spectrum = "ESTABLISHMENT" }
        footer.text = "ARTICLES FROM OPPOSITE ENDS OF\nTHE \(spectrum) SPECTRUM.\nSEE THE PROBLEM?"
        blueContainer.addSubview(footer)
        footer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footer.trailingAnchor.constraint(equalTo: blueContainer.trailingAnchor, constant: -10),
            footer.bottomAnchor.constraint(equalTo: logo.bottomAnchor, constant: 5),
        ])
        
        drawVerticalLine()
        drawHorizontalLine()
        
        let title2Label = UILabel()
        title2Label.numberOfLines = 2
        title2Label.textAlignment = .left
        title2Label.text = "Your thoughts on these news outlets\nreporting of this topic?"
        title2Label.textColor = titleLabel.textColor
        title2Label.font = UIFont(name: "Merriweather-Bold", size: 16)
        self.contentView.addSubview(title2Label)
        title2Label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title2Label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            title2Label.topAnchor.constraint(equalTo: blueContainer.bottomAnchor, constant: 20),
        ])
        
        textInput.textColor = titleLabel.textColor
        textInput.backgroundColor = self.view.backgroundColor
        self.contentView.addSubview(textInput)
        textInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textInput.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            textInput.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            textInput.topAnchor.constraint(equalTo: title2Label.bottomAnchor, constant: 20),
            textInput.heightAnchor.constraint(equalToConstant: 75.0),
        ])
        textInput.font = UIFont.systemFont(ofSize: 15.0)
        textInput.layer.borderWidth = 1.0
        textInput.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        if(!DARKMODE()){ textInput.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor }
        textInput.text = ""
        textInput.delegate = self
        
        let iconsGroup = UIStackView()
        iconsGroup.axis = .horizontal
        iconsGroup.alignment = .center
        iconsGroup.spacing = 20
        iconsGroup.backgroundColor = self.view.backgroundColor
        self.contentView.addSubview(iconsGroup)
        iconsGroup.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconsGroup.topAnchor.constraint(equalTo: textInput.bottomAnchor, constant: 20),
            iconsGroup.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        ])
        
        let fb_icon = UIButton(type: .custom)
        fb_icon.setImage(UIImage(named: "fb_logo.png"), for: .normal)
        iconsGroup.addArrangedSubview(fb_icon)
        fb_icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fb_icon.widthAnchor.constraint(equalToConstant: 32),
            fb_icon.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        let in_icon = UIButton(type: .custom)
        in_icon.setImage(UIImage(named: "in_logo.png"), for: .normal)
        iconsGroup.addArrangedSubview(in_icon)
        in_icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            in_icon.widthAnchor.constraint(equalToConstant: 32),
            in_icon.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        let tw_icon = UIButton(type: .custom)
        tw_icon.setImage(UIImage(named: "tw_logo.png"), for: .normal)
        iconsGroup.addArrangedSubview(tw_icon)
        tw_icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tw_icon.widthAnchor.constraint(equalToConstant: 32),
            tw_icon.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        let re_icon = UIButton(type: .custom)
        re_icon.setImage(UIImage(named: "re_logo.png"), for: .normal)
        iconsGroup.addArrangedSubview(re_icon)
        re_icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            re_icon.widthAnchor.constraint(equalToConstant: 32),
            re_icon.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        let shareButton = UIButton(type: .custom)
        shareButton.backgroundColor = accentOrange
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.setTitle("SHARE NOW!", for: .normal)
        shareButton.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 14)
        self.contentView.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            shareButton.topAnchor.constraint(equalTo: iconsGroup.bottomAnchor, constant: 25),
        ])
        shareButton.layer.cornerRadius = 25.0
        shareButton.addTarget(self, action: #selector(shareOnTap(_:)), for: .touchUpInside)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewOnTap(sender:)))
        contentView.addGestureRecognizer(gesture)
        
        // loading
        let dim: CGFloat = 65
        self.loadingView.frame = CGRect(x: (UIScreen.main.bounds.width-dim)/2,
                                        y: ((UIScreen.main.bounds.height-dim)/2) - 88,
                                        width: dim, height: dim)
        self.loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        if(!DARKMODE()){ self.loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.25) }
        self.loadingView.isHidden = true
        self.loadingView.layer.cornerRadius = 15
    
        let loading = UIActivityIndicatorView(style: .medium)
        if(DARKMODE()){ loading.color = .white }
        else { loading.color = darkForBright }
        self.loadingView.addSubview(loading)
        loading.center = CGPoint(x: dim/2, y: dim/2)
        loading.startAnimating()
        self.view.addSubview(self.loadingView)
    }
    
    private func drawVerticalLine() {
        let length: CGFloat = 5
        let totalHeight: CGFloat = 325
        let half = (UIScreen.main.bounds.size.width - 40)/2
        
        var currentY: CGFloat = 0.0
        while(currentY < totalHeight) {
            let line = UIView()
            line.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            line.frame = CGRect(x: half-1, y: currentY, width: 2.0, height: length)
            self.blueContainer.addSubview(line)
        
            currentY += (length * 2)
        }
    }
    
    private func drawHorizontalLine() {
        let length: CGFloat = 5
        let totalWidth: CGFloat = UIScreen.main.bounds.size.width - 40
        
        var currentX: CGFloat = 0.0
        while(currentX < totalWidth) {
            let line = UIView()
            line.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            line.frame = CGRect(x: currentX, y: 325, width: length, height: 2.0)
            self.blueContainer.addSubview(line)
        
            currentX += (length * 2)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObservers()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return DARKMODE() ? .lightContent : .darkContent
    }
    
    // MARK: - Keyboard stuff
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEvent(n:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEvent(n:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardEvent(n: Notification) {
        let H = getKeyboardHeight(fromNotification: n)
        
        if(n.name==UIResponder.keyboardWillShowNotification){
            self.scrollviewBottomConstraint!.constant = -H
        } else if(n.name==UIResponder.keyboardWillHideNotification) {
            self.scrollviewBottomConstraint!.constant = 0
        }
        
        view.layoutIfNeeded()
    }
    func getKeyboardHeight(fromNotification notification: Notification) -> CGFloat {
        if let H = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            return H
        } else {
            return 300
        }
    }
    
    // MARK: - Some taps
    @objc func closeButtonOnTap(sender: UIButton?) {
        NotificationCenter.default.post(name: NOTIFICATION_CLOSE_SPLITSHARE, object: nil)
        
        self.dismiss(animated: true) {
        }
    }
    
    @objc func viewOnTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func shareOnTap(_ sender: UIButton?) {
        
        self.loadingView.isHidden = false
        
        let api = ShareSplitAPI()
        api.generateImage(self.article1!, self.article2!) { (error, imageUrl) in
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
            }
            
            if let _error = error {
                print("ERROR", _error)
            } else if let _img = imageUrl {
                //print("IMG", _img)
                DispatchQueue.main.async {
                    UIApplication.shared.open(URL(string: _img)!)
                }
            }
        }
        
        /*
        let img = "http://ec2-3-16-162-167.us-east-2.compute.amazonaws.com/php/api/image-generator/images/u2jKupucLCkMcmcizdoB.jpg"
        
        let api = ShareSplitAPI()
        api.share(imgUrl: img, comment: self.textInput.text,
            art1: self.article1!, art2: self.article2!) {
        }
        */
        
    }

}

extension ShareSplitShareViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
        replacementText text: String) -> Bool {
    
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}
