//
//  StoryContentViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 07/07/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftUI
import Charts


class StoryContentViewController: UIViewController {
    
    public var link: String?
    
    private var storyData: StoryData?
    private var facts: [StoryFact]?
    private var spins: [StorySpin]?
    private var articles: [StoryArticle]?
    private var version: String?
    
    private var sourceRow: Int = 0
    private var sourceWidths = [CGFloat]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainImageCreditButton: UIButton!
    @IBOutlet weak var factsSourceSeparation: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setContentView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.removeAllFacts()
        self.removeAllSpins()
        if let _link = self.link {
            StoryContent.instance.loadData(link: _link) { (storyData, facts, spins, articles, version) in
                self.storyData = storyData
                self.facts = facts
                self.spins = spins
                self.articles = articles
                self.version = version

                self.updateUI()
                self.addTestView()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = DARKMODE() ? .white : darkForBright
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return STATUS_BAR_STYLE()
    }
    
}

// MARK: - UI
extension StoryContentViewController {//}: UIGestureRecognizerDelegate {

//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        print("TRUE!")
//        return true
//    }

    public static func createInstance() -> StoryContentViewController {
        let vc = StoryContentViewController(nibName: "StoryContentViewController", bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    private func setContentView() {
        let screen_W = UIScreen.main.bounds.size.width
        
        self.view.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
        self.scrollView.backgroundColor = self.view.backgroundColor
        
        self.scrollView.addSubview(self.contentView)
        self.contentView.frame = CGRect(x: 0, y: 0, width: screen_W, height: self.contentView.frame.size.height)
        self.scrollView.contentSize = CGSize(width: screen_W, height: self.contentView.frame.size.height)
        
        self.scrollView.isHidden = true
    }
    
    private func C(_ darkColorHex: Int, _ brightColorHex: Int) -> UIColor {
        return DARKMODE() ? UIColor(hex: darkColorHex) : UIColor(hex: brightColorHex)
    }
    
    private func updateUI() {
        DispatchQueue.main.async {

            self.mainTitle.textColor = self.C(0xFFFFFF, 0x1D242F)
            self.mainImageViewHeightConstraint.constant = CGFloat(STORIES_HEIGHT() - 15)
            self.mainImageCreditButton.backgroundColor = .clear
            
            let factsVContainer = self.contentView.viewWithTag(100) as! UIStackView
            factsVContainer.backgroundColor = self.scrollView.backgroundColor
                let factsView = factsVContainer.superview
                factsView?.backgroundColor = self.scrollView.backgroundColor
                factsView?.layer.borderWidth = 8.0
                factsView?.layer.borderColor = self.C(0x1D2530, 0xE1E3E3).cgColor
                    let factsTitle = factsView?.subviews.first as! UILabel
                    factsTitle.textColor = self.C(0xFFFFFF, 0x1D242F)
                    let line = factsView?.subviews[3] as! UIView
                    line.backgroundColor = self.C(0x1E2634, 0xE2E3E3)
                    let sourcesTitle = factsView?.subviews[4] as! UILabel
                    sourcesTitle.textColor = factsTitle.textColor
            let sourcesVContainer = self.contentView.viewWithTag(101) as! UIStackView
                sourcesVContainer.backgroundColor = self.scrollView.backgroundColor
            let spinTitleLabel = self.contentView.viewWithTag(102) as! UILabel
            spinTitleLabel.textColor = self.C(0xFF643C, 0x1D242F)
            
            if let _data = self.storyData {
                self.title = _data.title
                self.mainTitle.text = _data.title
                self.mainImageView.sd_setImage(with: URL(string: _data.image_src), placeholderImage: nil)
                
                let credit = "Image credit: " + _data.image_credit_title
                self.mainImageCreditButton.setCustomAttributedText(credit, color: UIColor(hex: 0x93A0B4))

                self.addFacts()
                self.addSpins()
                
                DELAY(0.25) {
                    self.updateContentSize()
                }
                
            } else {
                self.title = ""
                self.mainTitle.text = ""
                self.mainImageView.image = nil
                self.mainImageCreditButton.setCustomAttributedText("", color: UIColor(hex: 0x93A0B4))
            }
            
            self.contentView.backgroundColor = self.scrollView.backgroundColor
            self.scrollView.isHidden = false
            
            self.scrollView.isUserInteractionEnabled = true
            self.scrollView.isExclusiveTouch = true
            self.scrollView.canCancelContentTouches = true
            self.scrollView.delaysContentTouches = false
            
            
//            delaysContentTouches = false
        }
    }
    
    private func addTestView() {
//        DispatchQueue.main.async {
//            let testView = UIView()
//            testView.backgroundColor = .green
//
//            self.contentView.addSubview(testView)
//            testView.frame = CGRect(x: 0, y: 325, width: 100, height: 50)
//        }
    }
    
    private func updateContentSize() {
        let bottomGreenView = self.contentView.viewWithTag(999)!
        bottomGreenView.alpha = 0.0
        
        let screen_W = UIScreen.main.bounds.size.width
        let height: CGFloat = bottomGreenView.frame.origin.y + bottomGreenView.frame.size.height + 200
        
        self.contentView.frame = CGRect(x: 0, y: 0, width: screen_W, height: height)
        self.scrollView.contentSize = CGSize(width: screen_W, height: height)
    }
    
    // MARK: - Facts
    private func removeAllFacts() {
        let factsVContainer = self.contentView.viewWithTag(100) as! UIStackView
        factsVContainer.removeAllArrangedSubviews()
        
        let sourcesVContainer = self.contentView.viewWithTag(101) as! UIStackView
        sourcesVContainer.removeAllArrangedSubviews()
        
        self.sourceRow = -1
        self.sourceWidths = [CGFloat]()
    }
    
    private func addFacts() {
        let factsVContainer = self.contentView.viewWithTag(100) as! UIStackView
        
//        let limit = 3
        
        if let _facts = self.facts {
//            for (i, F) in _facts.enumerated() {
//                if(i<=limit) {
//                    //self.addSingleFact(F, isLast: i == self.facts!.count-1, index: i)
//                    self.addSingleFact(F, isLast: i == limit, index: i)
//                }
//            }
        
            if(factsVContainer.arrangedSubviews.count==0) {
                // Initial 3
                for (i, F) in _facts.enumerated() {
                    if(i<=2) {
                        self.addSingleFact(F, isLast: i == 2, index: i)
                    }
                }
            } else {
                // The rest
                for (i, F) in _facts.enumerated() {
                    if(i>2) {
                        self.addSingleFact(F, isLast: i == self.facts!.count-1, index: i)
                    }
                }

//                let sourcesVContainer = self.contentView.viewWithTag(101) as! UIStackView
//                sourcesVContainer.removeAllArrangedSubviews()
//                self.sourceRow = -1
//                self.sourceWidths = [CGFloat]()
//
//                for (i, F) in _facts.enumerated() {
////                    self.addSingleFact(F, isLast: i == self.facts!.count-1, index: i)
//                    self.addSingleSource(F, isLast: i == self.facts!.count-1, index: i)
//                }
            }
        }
    }
    
    private func addSingleFact(_ fact: StoryFact, isLast: Bool = false, index: Int) {
        let factsVContainer = self.contentView.viewWithTag(100) as! UIStackView
        let sourcesVContainer = self.contentView.viewWithTag(101) as! UIStackView
        
        // FACT
        let factHStack = UIStackView()
        factHStack.backgroundColor  = .clear
        factHStack.axis = .horizontal
        
        let dotContainer = UIView()
        dotContainer.backgroundColor = .clear
        factHStack.addArrangedSubview(dotContainer)
        dotContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dotContainer.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        let dot = UIView()
        dot.backgroundColor = UIColor(hex: 0xFF643C)
        dotContainer.addSubview(dot)
        dot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dot.centerXAnchor.constraint(equalTo: dotContainer.centerXAnchor),
            dot.topAnchor.constraint(equalTo: dotContainer.topAnchor, constant: 6),
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8)
        ])
        
        let factLabel = UILabel()
        factLabel.numberOfLines = 0
        factLabel.backgroundColor = .clear
        factLabel.font = UIFont(name: "Merriweather-Bold", size: 15)
        factLabel.text = fact.title
        factLabel.textColor = self.C(0xFFFFFF, 0x1D242F)
        factHStack.addArrangedSubview(factLabel)
        factsVContainer.addArrangedSubview(factHStack)

        // SOURCE
        if(self.sourceRow == -1) {
            let sourcesHStack = UIStackView()
            sourcesHStack.backgroundColor  = self.scrollView.backgroundColor
            sourcesHStack.axis = .horizontal
            sourcesHStack.spacing = 10
            sourcesVContainer.addArrangedSubview(sourcesHStack)
            
            self.sourceRow = 0
        }
        var sourcesHStack = sourcesVContainer.arrangedSubviews[self.sourceRow] as! UIStackView
        
        if(!isLast) {
            if let _last = sourcesHStack.arrangedSubviews.last, _last.alpha == 0 {
                _last.removeFromSuperview()
            }
        }
        
        let _sourceHeight: CGFloat = 21.0
        let _sourceFont = UIFont(name: "Roboto-Regular", size: 15)!
        let _sourceText = " " + fact.source_title + " "
        let _sourceWidth = _sourceText.width(withConstraintedHeight: _sourceHeight,
            font: _sourceFont)
            
        var _widthSum: CGFloat = 0
        let _widthTotal = UIScreen.main.bounds.width - 20 - 40
        for W in self.sourceWidths {
            _widthSum += W + sourcesHStack.spacing
        }
        if(_widthSum + _sourceWidth > _widthTotal) {
            let spacer = UIView()
            spacer.backgroundColor = .green
            spacer.alpha = 0
            sourcesHStack.addArrangedSubview(spacer)
            
            let newSourcesHStack = UIStackView()
            newSourcesHStack.backgroundColor  = self.scrollView.backgroundColor
            newSourcesHStack.axis = .horizontal
            newSourcesHStack.spacing = 10
            sourcesVContainer.addArrangedSubview(newSourcesHStack)
            
            self.sourceRow += 1
            self.sourceWidths = [CGFloat]()
            sourcesHStack = sourcesVContainer.arrangedSubviews[self.sourceRow] as! UIStackView
        }
        
        let sourceContainer = UIView()
        sourceContainer.backgroundColor = .clear
        sourcesHStack.addArrangedSubview(sourceContainer)
        sourceContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sourceContainer.heightAnchor.constraint(equalToConstant: 21),
            sourceContainer.widthAnchor.constraint(equalToConstant: _sourceWidth)
        ])
        
        
        let sourceLabel = UILabel()
        sourceLabel.numberOfLines = 1
        sourceLabel.backgroundColor = .clear //self.scrollView.backgroundColor
        sourceLabel.font = _sourceFont
        sourceLabel.text = _sourceText
        sourceLabel.tag = 150 + index
        sourceLabel.textColor = UIColor(hex: 0xFF643C)
        sourceContainer.addSubview(sourceLabel)
        sourceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sourceLabel.heightAnchor.constraint(equalToConstant: 21),
            sourceLabel.widthAnchor.constraint(equalToConstant: _sourceWidth)
        ])
        self.sourceWidths.append(_sourceWidth)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(sourceLabelTap(_:)))
//        tap.delegate = self
        sourceLabel.addGestureRecognizer(tap)
        sourceLabel.isUserInteractionEnabled = true
        
//        let buttonArea = UIButton(type: .custom)
//        buttonArea.backgroundColor = .clear
//        //buttonArea.alpha = 0.1
//        buttonArea.isUserInteractionEnabled = true
//        sourceContainer.addSubview(buttonArea)
//        //sourcesHStack.addArrangedSubview(buttonArea)
//        buttonArea.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            buttonArea.widthAnchor.constraint(equalTo: sourceLabel.widthAnchor),
//            buttonArea.heightAnchor.constraint(equalTo: sourceLabel.heightAnchor)
//        ])
//        buttonArea.addTarget(self, action: #selector(buttonAreaOnTap(_:)), for: .touchUpInside)
        
        if(isLast) {
            let spacer = UIView()
            spacer.backgroundColor = .green
            spacer.alpha = 0
            sourcesHStack.addArrangedSubview(spacer)
        }
    }
    @IBAction func buttonAreaOnTap(_ sender: UIButton) {
        print("BUTTON TAP!")
    }
    
    
    
    
    // MARK: - Spins
    private func removeAllSpins() {
        let spinsVContainer = self.contentView.viewWithTag(103) as! UIStackView
        spinsVContainer.removeAllArrangedSubviews()
    }
    
    private func addSpins() {
        if let _spins = self.spins {
            for (i, SP) in _spins.enumerated() {
                self.addSingleSpin(SP, index: i)
            }
        }
    }
    
    private func addSingleSpin(_ spin: StorySpin, index: Int) {
        let spinsVContainer = self.contentView.viewWithTag(103) as! UIStackView
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Merriweather-Bold", size: 16)
        titleLabel.text = spin.title
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = self.C(0xFFFFFF, 0xFF643C)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(spinOnTap(_:)))
        tap.cancelsTouchesInView = false
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tap)
        
        
        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont(name: "Roboto-Regular", size: 16)!
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.textColor = self.C(0x93A0B4, 0x1D242F)
        descriptionLabel.text = spin.description
        
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.backgroundColor = .clear
        horizontalStack.spacing = 10.0
        
        let factor: CGFloat = 1.3
        let imageView = UIImageView()
        imageView.contentMode = self.mainImageView.contentMode
        imageView.clipsToBounds = true
        imageView.backgroundColor = .darkGray
        horizontalStack.addArrangedSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 112 * factor),
            imageView.heightAnchor.constraint(equalToConstant: 75 * factor)
        ])
        imageView.sd_setImage(with: URL(string: spin.image), placeholderImage: nil)
        imageView.tag = 200 + index
        self.ADD_SPIN_TAP(to: imageView)

        let subVerticalStack = UIStackView()
        subVerticalStack.axis = .vertical
        subVerticalStack.spacing = 2.0
        subVerticalStack.backgroundColor = .clear
        
        let spinTitleLabel = UILabel()
        spinTitleLabel.text = spin.subTitle
        spinTitleLabel.numberOfLines = 3
        spinTitleLabel.font = UIFont(name: "Merriweather-Bold", size: 17)
        spinTitleLabel.textColor = self.C(0xFFFFFF, 0x1D242F)
        spinTitleLabel.adjustsFontSizeToFitWidth = true
        spinTitleLabel.minimumScaleFactor = 0.5
        subVerticalStack.addArrangedSubview(spinTitleLabel)
        spinTitleLabel.tag = 200 + index
        self.ADD_SPIN_TAP(to: spinTitleLabel)
        
        let subHorizontalStack = UIStackView()
        subHorizontalStack.axis = .horizontal
        subHorizontalStack.backgroundColor = .clear
        subHorizontalStack.spacing = 7.0
        
        if let _countryCode = spin.media_country_code {
            let flag = UIImageView()
            flag.contentMode = .scaleAspectFit
            flag.image = GET_FLAG(id: _countryCode)
            
            subHorizontalStack.addArrangedSubview(flag)
            flag.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                flag.widthAnchor.constraint(equalToConstant: 20),
                flag.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        
        let sourceTime = UILabel()
        let source = spin.media_title.replacingOccurrences(of: " #", with: "")
//        sourceTime.text = source + " - " + FORMAT_TIME(spin.time)
        sourceTime.text = spin.media_title // + " - " + FORMAT_TIME(spin.time)
        print("TIME", spin.time)
        
        sourceTime.textColor = self.C(0x93A0B4, 0x1D242F)
        sourceTime.font = UIFont(name: "Roboto-Regular", size: 14)!
        subHorizontalStack.addArrangedSubview(sourceTime)
        subVerticalStack.addArrangedSubview(subHorizontalStack)
        
        let spacer = UIView()
        spacer.backgroundColor = .clear
        subVerticalStack.addArrangedSubview(spacer)
        
        horizontalStack.addArrangedSubview(subVerticalStack)
        spinsVContainer.addArrangedSubview(titleLabel)
        spinsVContainer.addArrangedSubview(descriptionLabel)
        spinsVContainer.addArrangedSubview(horizontalStack)
        
        // ---------
        
        let stackSpacer = UIStackView()
        stackSpacer.axis = .vertical
        stackSpacer.backgroundColor = .clear
        spinsVContainer.addArrangedSubview(stackSpacer)
        stackSpacer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackSpacer.heightAnchor.constraint(equalToConstant: 13)
        ])
        
        for i in 1...3 {
            let view = UIView()
            view.backgroundColor = .clear
            stackSpacer.addArrangedSubview(view)
            
            var H: CGFloat = 6.0
            if(i==2) {
                H = 1
                view.backgroundColor = self.C(0x93A0B4, 0x1D242F)
            }
            
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: H)
            ])
        }

        spinsVContainer.backgroundColor = .clear
    }
    
    private func ADD_SPIN_TAP(to view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(spinOnTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    
    
    private func GET_FLAG(id: String) -> UIImage {
        var result = UIImage(named: "\(id.uppercased())64.png")
        if(result==nil) {
            result = UIImage(named: "noFlag.png")
        }
        return result!
    }
    
    private func FORMAT_TIME(_ time: Int) -> String {
        let SEC: CGFloat = 1.0
        let MIN = SEC * 60
        let HOUR = MIN * 60
        let DAY = HOUR * 24
        let MONTH = DAY * 30
        let YEAR = MONTH * 12
        let unityValues = [YEAR, MONTH, DAY, HOUR, MIN, SEC]
        let unityNames = ["year", "month", "day", "hour", "minute", "second"]
        
        var result = ""
        for (i, UNITY) in unityValues.enumerated() {
            let div = Int( CGFloat(time) / UNITY )
            if(div>0) {
                result = String(div) + " " + unityNames[i]
                if(div>1){ result += "s"
                }
                
                result += " ago"
                break
            }
        }
        
        return result
    }
    
}

// MARK: - Button taps
extension StoryContentViewController {
    
    @IBAction func showMoreSourcesButtonTap(_ sender: UIButton) {
        sender.isHidden = true
        self.factsSourceSeparation.constant = 20
        self.addFacts()

        DELAY(0.25) {
            self.updateContentSize()
        }
    }
    
    private func OPEN_URL(_ url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func mainImageCreditButtonTap(_ sender: UIButton) {
        if let _data = self.storyData {
            self.OPEN_URL(_data.image_credit_url)
        }
    }
    
    @IBAction func sourceLabelTap(_ sender: UITapGestureRecognizer) {
        let label = sender.view as! UILabel
        let tag = label.tag - 150
        
        let fact = self.facts![tag]
        self.OPEN_URL(fact.source_url)
    }
    
    @IBAction func spinOnTap(_ sender: UITapGestureRecognizer) {
        let tag = sender.view!.tag - 200
        
        let spin = self.spins![tag]
        self.OPEN_URL(spin.url)
    }
    
}
