//
//  FAQViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 11/05/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit
import SafariServices


class FAQViewController: UIViewController {

    var scrollview = UIScrollView()
    var contentView = UIView()


    public static func createInstance() -> FAQViewController {
        let vc = FAQViewController()
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = DARKMODE() ? .black : bgWhite_LIGHT
        self.buildContent()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return STATUS_BAR_STYLE()
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

// MARK: UI
extension FAQViewController {

    func buildContent() {

        // ScrollView
        self.view.addSubview(self.scrollview)
        self.scrollview.backgroundColor = .clear
        self.scrollview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.scrollview.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        // ContenView
        let contentViewHeightConstraint = self.contentView.heightAnchor.constraint(equalTo: self.scrollview.heightAnchor)
        contentViewHeightConstraint.priority = .defaultLow
        
        self.scrollview.addSubview(self.contentView)
        self.contentView.backgroundColor = .clear
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.scrollview.topAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.scrollview.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.scrollview.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.scrollview.bottomAnchor),
            self.contentView.widthAnchor.constraint(equalTo: self.scrollview.widthAnchor)
            //contentViewHeightConstraint
        ])
        
        // VStack
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.backgroundColor = .clear
        vStack.spacing = 5
        self.contentView.addSubview(vStack)
        
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            vStack.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            vStack.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            vStack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10)
        ])
        
        // title HStack
        let titleHStack = UIStackView()
        titleHStack.axis = .horizontal
        titleHStack.backgroundColor = .clear
        vStack.addArrangedSubview(titleHStack)
        titleHStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleHStack.topAnchor.constraint(equalTo: vStack.topAnchor, constant: 5),
            titleHStack.heightAnchor.constraint(equalToConstant: 38)
        ])
        
        // Main title
        let mainTitleLabel = UILabel(text: "FAQ", font: UIFont(name: "PTSerif-Bold", size: 34),
                textColor: accentOrange, textAlignment: .left, numberOfLines: 1)
        titleHStack.addArrangedSubview(mainTitleLabel)
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainTitleLabel.topAnchor.constraint(equalTo: titleHStack.topAnchor, constant: 0),
            mainTitleLabel.leadingAnchor.constraint(equalTo: titleHStack.leadingAnchor, constant: 5)
        ])
        
        // Close button
        let closeButton = UIButton(type: .custom)
        let attributes = [NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 17)!,
                            NSAttributedString.Key.foregroundColor: DARKMODE() ? UIColor.white : UIColor.black.withAlphaComponent(0.6)]
        let attrTitle = NSAttributedString(string: "Close", attributes: attributes)
        closeButton.setAttributedTitle(attrTitle, for: .normal)
        closeButton.backgroundColor = .clear //UIColor.black.withAlphaComponent(0.25)
        titleHStack.addArrangedSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: titleHStack.bottomAnchor, constant: 0),
            closeButton.widthAnchor.constraint(equalToConstant: 70),
            closeButton.heightAnchor.constraint(equalToConstant: 38)
        ])
        closeButton.addTarget(self, action: #selector(closeButtonTap(sender:)), for: .touchUpInside)
        
        // Spacer
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        vStack.addArrangedSubview(spacerView)
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spacerView.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        // Sections
        for i in 0...FAQ_titles.count-1 {
            
            // section HEADER
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.spacing = 5
            hStack.alignment = .leading
            hStack.backgroundColor = .clear
            vStack.addArrangedSubview(hStack)
        
            let plusButton = UIButton(type: .custom)
            plusButton.tag = 100 + i
            plusButton.tintColor = accentOrange
            let imgConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .medium)
            plusButton.setImage(UIImage(systemName: "plus.circle", withConfiguration: imgConfig), for: .normal)
            plusButton.addTarget(self, action: #selector(plusButtonOnTap(sender:)), for: .touchUpInside)
            hStack.addArrangedSubview(plusButton)
            
            let titleLabel = UILabel(text: FAQ_titles[i],
                font: UIFont(name: "PTSerif-Bold", size: 25),
                textColor: DARKMODE() ? .white : .black.withAlphaComponent(0.6), textAlignment: .left,
                numberOfLines: 1)
            titleLabel.numberOfLines = 0
            hStack.addArrangedSubview(titleLabel)
            
            let spacer = UIView()
            spacer.backgroundColor = .clear
            hStack.addArrangedSubview(spacer)
            
            // section CONTENT
            let innerVStack = UIStackView()
            innerVStack.axis = .vertical
            innerVStack.spacing = 5
            innerVStack.backgroundColor = .clear
            innerVStack.tag = 200 + i
            vStack.addArrangedSubview(innerVStack)
            
            let contentTextView = UITextView()
            contentTextView.isEditable = false
            contentTextView.textColor = .white
            contentTextView.isScrollEnabled = false
            contentTextView.backgroundColor = contentTextView.superview?.backgroundColor
            
            var contentText = ""
            if(i <= FAQ_contents.count-1) {
                contentText = FAQ_contents[i]
            }
            
            contentTextView.attributedText = self.attrText(contentText, i)
            contentTextView.delegate = self
            innerVStack.addArrangedSubview(contentTextView)
            var H = contentTextView.attributedText.height(containerWidth: UIScreen.main.bounds.width-20) + 15
            if(i==FAQ_titles.count-1){ H += 30 }
            contentTextView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentTextView.topAnchor.constraint(equalTo: innerVStack.topAnchor),
                contentTextView.leadingAnchor.constraint(equalTo: innerVStack.leadingAnchor),
                contentTextView.trailingAnchor.constraint(equalTo: innerVStack.trailingAnchor),
                contentTextView.heightAnchor.constraint(equalToConstant: H)
            ])
            
            let pic = FAQ_PICS[i]
            if( pic != nil) {
                let filename = pic![0] as! String
                let size = pic![1] as! CGSize
                
                let W = UIScreen.main.bounds.width-20
                let H = (W * size.height)/size.width
                
                let imageView = UIImageView()
                imageView.image = UIImage(named: filename)
                innerVStack.addArrangedSubview(imageView)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imageView.heightAnchor.constraint(equalToConstant: H)
                ])
            }
            
            let bottomSpacer = UIView()
            bottomSpacer.backgroundColor = .clear
            innerVStack.addArrangedSubview(bottomSpacer)
            bottomSpacer.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bottomSpacer.heightAnchor.constraint(equalToConstant: 13)
            ])
            
            
            innerVStack.isHidden = true
        }

    }
    
    @objc func closeButtonTap(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc func plusButtonOnTap(sender: UIButton) {
        let tag = 100 + sender.tag
        if let contentVStack = self.contentView.viewWithTag(tag) as? UIStackView {
            contentVStack.isHidden = !contentVStack.isHidden
            
            var imageName = "plus.circle"
            if(!contentVStack.isHidden) {
                imageName = "minus.circle"
            }
            
            let imgConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .medium)
            sender.setImage(UIImage(systemName: imageName, withConfiguration: imgConfig), for: .normal)
        }
    }
    
    func attrText(_ text: String, _ index: Int) -> NSAttributedString {
        let font = UIFont(name: "Poppins-Regular", size: 14)
    
        let parts = FAQ_PARTS[index]
        let links = FAQ_LINKS[index]
    
        let attr = prettifyText(fullString: text as NSString, boldPartsOfString: [], font: font, boldFont: font,
            paths: links, linkedSubstrings: parts, accented: [])
            
        let mAttr = NSMutableAttributedString(attributedString: attr)
        let range = NSRange(location: 0, length: attr.string.count)
        mAttr.addAttribute(NSAttributedString.Key.foregroundColor, value: DARKMODE() ? UIColor.white : UIColor.black,
            range: range)
            
        return mAttr
    }
    
    private func callFeedbackForm() {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true

        let vc = SFSafariViewController(url: URL(string: FAQ_feedbackForm)!, configuration: config)
        vc.preferredBarTintColor = .black
        vc.preferredControlTintColor = accentOrange
        present(vc, animated: true, completion: nil)
    }

}

extension FAQViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange,
        interaction: UITextItemInteraction) -> Bool {
        
        if(URL.absoluteString == FAQ_feedbackForm) {
            self.callFeedbackForm()
            return false
        } else {
            return true
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
    
}
