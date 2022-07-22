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
    
    private var firstTime: Bool = true
    private var showMoreFacts: Bool = true
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
    private let loadingView = UIView()
    
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainImageCreditButton: UIButton!
    @IBOutlet weak var factsSourceSeparation: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setContentView()
        self.buildLoading()
        self.showLoading()
        
        self.navigationItem.hidesBackButton = true
        SETUP_NAVBAR(viewController: self,
            homeTap: nil,
            menuTap: #selector(self.hamburgerButtonItemClicked(_:)),
            searchTap: #selector(self.searchItemClicked(_:)),
            userTap: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if(self.firstTime) {
            self.firstTime = false
        
            self.removeAllFacts()
            self.removeAllSpins()
            self.removeAllArticles()
            
            if let _link = self.link {
                StoryContent.instance.loadData(link: _link) { (storyData, facts, spins, articles, version) in
                    self.storyData = storyData
                    self.facts = facts
                    self.spins = spins
                    self.articles = articles
                    self.version = version

                    self.updateUI()
                    self.showLoading(false)
                }
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
    
    // MARK: - Modified TitleBar
    @objc func hamburgerButtonItemClicked(_ sender: UIBarButtonItem!) {
        navigationController?.customPushViewController(SectionsViewController())
    }
    
    @objc func searchItemClicked(_ sender:UIBarButtonItem!) {
        let searchvc = SearchViewController()
        navigationController?.pushViewController(searchvc, animated: true)
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
    
    private func buildLoading() {
        let dim: CGFloat = 65
        self.loadingView.frame = CGRect(x: (UIScreen.main.bounds.width-dim)/2,
                                        y: ((UIScreen.main.bounds.height-dim)/2) - 88,
                                        width: dim, height: dim)
        self.loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        if(!DARKMODE()){ self.loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.25) }
        self.loadingView.isHidden = true
        self.loadingView.layer.cornerRadius = 15
    
        let loading = UIActivityIndicatorView(style: .medium)
        loading.color = .white
        self.loadingView.addSubview(loading)
        loading.center = CGPoint(x: dim/2, y: dim/2)
        loading.startAnimating()
        self.view.addSubview(self.loadingView)
    }
    
    func showLoading(_ visible: Bool = true) {
        DispatchQueue.main.async {
            self.loadingView.isHidden = !visible
            self.view.isUserInteractionEnabled = !visible
        }
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
            let articlesTitleLabel = self.contentView.viewWithTag(104) as! UILabel
            articlesTitleLabel.textColor = self.C(0xFFFFFF, 0xFF643C)
            
            if let _data = self.storyData {
                //self.title = _data.title
                self.mainTitle.text = _data.title
                self.mainImageView.sd_setImage(with: URL(string: _data.image_src), placeholderImage: nil)
                
                let credit = "Image credit: " + _data.image_credit_title
                self.mainImageCreditButton.setCustomAttributedText(credit, color: UIColor(hex: 0x93A0B4))

                self.addFacts()
                self.addSpins()
                self.addArticles()
                
                DELAY(0.25) {
                    self.updateContentSize()
                }
                
            } else {
                //self.title = ""
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
        }
    }
    
    private func updateContentSize() {
        let bottomGreenView = self.contentView.viewWithTag(999)!
        bottomGreenView.alpha = 0.0
        
        let screen_W = UIScreen.main.bounds.size.width
        let height: CGFloat = bottomGreenView.frame.origin.y + bottomGreenView.frame.size.height
        
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
//        factLabel.font = UIFont(name: "Merriweather-Bold", size: 15)
//        factLabel.text = fact.title
        factLabel.attributedText = self.attrText(fact.title, index: index)
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
        let _sourceText = " [" + String(index+1) + "] " + fact.source_title + " "
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
        self.addUnderline(to: sourceLabel)
        self.sourceWidths.append(_sourceWidth)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(sourceLabelTap(_:)))
        sourceLabel.addGestureRecognizer(tap)
        sourceLabel.isUserInteractionEnabled = true
        
        if(isLast) {
            let spacer = UIView()
            spacer.backgroundColor = .green
            spacer.alpha = 0
            sourcesHStack.addArrangedSubview(spacer)
        }
    }
    
    func addUnderline(to label: UILabel) {
        let attrText = NSMutableAttributedString(string: label.text!)
        var range = NSRange(location: 3, length: attrText.string.count-3)
        
        attrText.addAttribute(NSAttributedString.Key.underlineStyle,
            value: 1, range: range)
        
        label.attributedText = attrText
    }
    
    func attrText(_ text: String, index: Int) -> NSAttributedString {
        let fontBold = UIFont(name: "Merriweather-Bold", size: 15)
        let fontItalic = UIFont(name: "Merriweather-LightItalic", size: 15)
        let extraText = " [" + String(index+1) + "]"
        let mText = text + extraText
        
        let attr = prettifyText(fullString: mText as NSString, boldPartsOfString: [],
            font: fontBold, boldFont: fontBold,
            paths: [], linkedSubstrings: [],
            accented: [])
    
        //factLabel.textColor =
        
            
        let mAttr = NSMutableAttributedString(attributedString: attr)
        
        var range = NSRange(location: 0, length: attr.string.count)
        mAttr.addAttribute(NSAttributedString.Key.foregroundColor,
            value: self.C(0xFFFFFF, 0x1D242F),
            range: range)
        
        range = NSRange(location: attr.string.count - extraText.count, length: extraText.count)
        
        mAttr.addAttribute(NSAttributedString.Key.foregroundColor,
            value: UIColor(hex: 0xFF643C),
            range: range)
        mAttr.addAttribute(NSAttributedString.Key.font,
            value: fontItalic!,
            range: range)
            
            
        return mAttr
    }
    
    private func resetFacts() {
        self.removeAllFacts()
        self.addFacts()
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
        titleLabel.font = UIFont(name: "Merriweather-Bold", size: 17)
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
            flag.image = self.GET_FLAG(id: _countryCode)
            
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
            
            //view.backgroundColor = self.C(0x93A0B4, 0x1D242F)
            var H: CGFloat = 6.0
            if(i==2) {
                H = 2
            }
            
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: H)
            ])
            
            if(i==2) {
                let lineImageView = UIImageView()
                lineImageView.image = UIImage(named: "StoryArticleLineSep.png")
                lineImageView.backgroundColor = .clear
                lineImageView.alpha = 0.7
                view.addSubview(lineImageView)
                view.clipsToBounds = true
                lineImageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    lineImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    lineImageView.topAnchor.constraint(equalTo: view.topAnchor),
                    lineImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    lineImageView.widthAnchor.constraint(equalToConstant: 1080/2)
                ])
            }
        }

        spinsVContainer.backgroundColor = .clear
    }
    
    private func ADD_SPIN_TAP(to view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(spinOnTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    @IBAction func spinOnTap(_ sender: UITapGestureRecognizer) {
        let tag = sender.view!.tag - 200
        
        let spin = self.spins![tag]
        self.OPEN_URL(spin.url, title: spin.subTitle)
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
    
    // MARK: - Articles
    private func removeAllArticles() {
        let articlesVContainer = self.contentView.viewWithTag(105) as! UIStackView
        articlesVContainer.removeAllArrangedSubviews()
    }
    
    private func addArticles() {
        if let _articles = self.articles {
            for (i, AR) in _articles.enumerated() {
                self.addSingleArticle(AR, index: i)
            }
        }
    }
    
    private func addSingleArticle(_ article: StoryArticle, index: Int) {
        let articlesVContainer = self.contentView.viewWithTag(105) as! UIStackView
        
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
        imageView.sd_setImage(with: URL(string: article.image), placeholderImage: nil)
        imageView.tag = 300 + index
        self.ADD_ARTICLE_TAP(to: imageView)
        
        let subVerticalStack = UIStackView()
        subVerticalStack.axis = .vertical
        subVerticalStack.spacing = 2.0
        subVerticalStack.backgroundColor = .clear
        
        let articleTitleLabel = UILabel()
        articleTitleLabel.text = article.title
        articleTitleLabel.numberOfLines = 4
        articleTitleLabel.font = UIFont(name: "Merriweather-Bold", size: 17)
        articleTitleLabel.textColor = self.C(0xFFFFFF, 0x1D242F)
        articleTitleLabel.adjustsFontSizeToFitWidth = true
        articleTitleLabel.minimumScaleFactor = 0.5
        subVerticalStack.addArrangedSubview(articleTitleLabel)
        articleTitleLabel.tag = 300 + index
        self.ADD_ARTICLE_TAP(to: articleTitleLabel)
        
        let subHorizontalStack = UIStackView()
        subHorizontalStack.axis = .horizontal
        subHorizontalStack.backgroundColor = .clear
        subHorizontalStack.spacing = 7.0
        
        if let _countryCode = article.media_country_code {
            let flag = UIImageView()
            flag.contentMode = .scaleAspectFit
            flag.image = self.GET_FLAG(id: _countryCode)
            
            subHorizontalStack.addArrangedSubview(flag)
            flag.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                flag.widthAnchor.constraint(equalToConstant: 20),
                flag.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        
        let sourceTime = UILabel()
        let source = article.media_title.replacingOccurrences(of: " #", with: "")
//        sourceTime.text = source + " - " + FORMAT_TIME(spin.time)
        sourceTime.text = article.media_title // + " - " + FORMAT_TIME(spin.time)
        print("TIME", article.time)
        
        sourceTime.textColor = self.C(0x93A0B4, 0x1D242F)
        sourceTime.font = UIFont(name: "Roboto-Regular", size: 14)!
        subHorizontalStack.addArrangedSubview(sourceTime)
        subVerticalStack.addArrangedSubview(subHorizontalStack)
        
        let spacer = UIView()
        spacer.backgroundColor = .clear
        subVerticalStack.addArrangedSubview(spacer)
        
        horizontalStack.addArrangedSubview(subVerticalStack)
        articlesVContainer.addArrangedSubview(horizontalStack)
        
        // ---------
        
        let stackSpacer = UIStackView()
        stackSpacer.axis = .vertical
        stackSpacer.backgroundColor = .clear
        articlesVContainer.addArrangedSubview(stackSpacer)
        stackSpacer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackSpacer.heightAnchor.constraint(equalToConstant: 13)
        ])
        
        for i in 1...3 {
            let view = UIView()
            view.backgroundColor = .clear
            stackSpacer.addArrangedSubview(view)
            
            //view.backgroundColor = self.C(0x93A0B4, 0x1D242F)
            var H: CGFloat = 6.0
            if(i==2) {
                H = 2
            }
            
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: H)
            ])
            
            if(i==2) {
                let lineImageView = UIImageView()
                lineImageView.image = UIImage(named: "StoryArticleLineSep.png")
                lineImageView.backgroundColor = .clear
                lineImageView.alpha = 0.35
                view.addSubview(lineImageView)
                view.clipsToBounds = true
                lineImageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    lineImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    lineImageView.topAnchor.constraint(equalTo: view.topAnchor),
                    lineImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    lineImageView.widthAnchor.constraint(equalToConstant: 1080/2)
                ])
            }
        }
        
//        let stackSpacer = UIStackView()
//        stackSpacer.axis = .vertical
//        stackSpacer.backgroundColor = .clear
//        articlesVContainer.addArrangedSubview(stackSpacer)
//        stackSpacer.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            stackSpacer.heightAnchor.constraint(equalToConstant: 13)
//        ])
//
//        for i in 1...3 {
//            let view = UIView()
//            view.backgroundColor = .clear
//            stackSpacer.addArrangedSubview(view)
//
//            var H: CGFloat = 6.0
//            if(i==2) {
//                H = 1
//                view.backgroundColor = self.C(0x93A0B4, 0x1D242F)
//            }
//
//            view.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                view.heightAnchor.constraint(equalToConstant: H)
//            ])
//        }

        articlesVContainer.backgroundColor = .clear
    }
    
    private func ADD_ARTICLE_TAP(to view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(articleOnTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    @IBAction func articleOnTap(_ sender: UITapGestureRecognizer) {
        let tag = sender.view!.tag - 300
        
        let article = self.articles![tag]
        self.OPEN_URL(article.url, title: article.title)
    }
    
}

// MARK: - Button taps
extension StoryContentViewController {
    
    @IBAction func showMoreSourcesButtonTap(_ sender: UIButton) {
        if(self.showMoreFacts) {
            sender.setCustomAttributedText("Show fewer facts")
            //sender.isHidden = true
            //self.factsSourceSeparation.constant = 20
            
            self.addFacts()
        } else {
            sender.setCustomAttributedText("Show more")
            self.resetFacts()
        }
        self.showMoreFacts = !self.showMoreFacts
    
        // update/refresh
        DELAY(0.25) {
            self.updateContentSize()
        }
    }
    
    private func OPEN_URL(_ url: String, title: String = "") {
//        if let url = URL(string: url) {
//            UIApplication.shared.open(url)
//        }

        let vc = PlainWebViewController(url: url, title: title)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func mainImageCreditButtonTap(_ sender: UIButton) {
        if let _data = self.storyData {
            self.OPEN_URL(_data.image_credit_url, title: _data.image_credit_title)
        }
    }
    
    @IBAction func sourceLabelTap(_ sender: UITapGestureRecognizer) {
        let label = sender.view as! UILabel
        let tag = label.tag - 150
        
        let fact = self.facts![tag]
        self.OPEN_URL(fact.source_url, title: fact.source_title)
    }
    
    @IBAction func homeButtonTap(_ sender: UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
