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
    public var api_call: String?
    
    private var storyData: StoryData?
    private var facts: [StoryFact]?
    private var sources: [String]?
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


    var uniqueID = -1
    var biasButtonState = 1         // 1: normal icon, 2: share-split icon
    let biasSliders = SliderPopup() // Preferences (orange) panel
    var biasMiniButton = UIView()
    var miniButtonTimer: Timer?
    let shadeView = UIView()
    var biasButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "prefsButton.png"), for: .normal)
        button.addTarget(self, action: #selector(showBiasSliders(_:)), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    let NOTIFICATION_RELOAD_NEWS_IN_OTHER_INSTANCES = Notification.Name("reloadNewsInOtherInstances")


    override func viewDidLoad() {
        super.viewDidLoad()
        self.setContentView()
        self.buildLoading()
        self.showLoading()
        
        self.uniqueID = Utils.shared.newsViewController_ID
        self.biasSliders.sliderDelegate = self
        self.biasSliders.shadeDelegate = self
        self.setUpBiasButton()
        self.initBiasMiniButton()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        SETUP_NAVBAR(viewController: self,
            homeTap: nil,
            menuTap: #selector(self.hamburgerButtonItemClicked(_:)),
            searchTap: #selector(self.searchItemClicked(_:)),
            userTap: nil)
            
        self.loadSplitForPrefsPanel()
    }

    private func loadSplitForPrefsPanel() {
        let index = UserDefaults.standard.integer(forKey: "userSplitPrefs")-1
        if(index > -1) {
            self.biasSliders.setSplitValue(index)
        }
        
        if( mustSplit() ) { // SPLIT
            self.biasButtonState = 2
        } else { // NORMAL
            self.biasButtonState = 1
        }
        
        let iconImageView = self.biasMiniButton.viewWithTag(767) as! UIImageView
        iconImageView.image = UIImage(named: "shareSplitButton.png")
        
        if(!APP_CFG_SPLITSHARING) {
            self.biasButtonState = 1
        }

        self.biasSliders.canDismiss = true
        var buttonIcon = UIImage(named: "prefsButton.png")
        if(self.biasButtonState == 2) {
            //self.biasSliders.canDismiss = false
            buttonIcon = UIImage(named: "shareSplitButton.png")
            iconImageView.image = UIImage(named: "prefsButton.png")
        }
        self.biasButton.setBackgroundImage(buttonIcon, for: .normal)
        self.biasMiniButton.superview?.bringSubviewToFront(self.biasMiniButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if(self.firstTime) {
            self.firstTime = false
            self.loadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.biasSliders.adaptToScreen()
    }
    
    private func loadData() {
    
        var _api_call = ""
        var _filter = ""
        if(self.api_call != nil){ _api_call = self.api_call! }

        if let _url = URL(string: _api_call) {
            _filter = _url.params()["sliders"] as! String
        }
        
        self.removeAllFacts()
        self.removeAllSpins()
        self.removeAllArticles()
        
        if let _link = self.link {
            print("LOAD DATA", _link, _filter)
        
            StoryContent.instance.loadData(link: _link, filter: _filter, mustSplit: self.mustSplit()) { (storyData, facts, spins, articles, version) in
                self.storyData = storyData
                
                self.facts = [StoryFact]()
                for F in facts! {
                    if(!F.source_url.isEmpty && !F.source_title.isEmpty) {
                        self.facts?.append(F)
                    }
                }
                
                
                self.spins = spins
                self.articles = articles
                self.version = version

                self.updateUI()
                self.showLoading(false)
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
        self.sources = [String]()
    
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
//        print("IS LAST:", isLast)
        
        let factsVContainer = self.contentView.viewWithTag(100) as! UIStackView
        let sourcesVContainer = self.contentView.viewWithTag(101) as! UIStackView
        
        var _index = self.sources!.count + 1
        var mustAddSource = true
        for (i, S) in self.sources!.enumerated() {
            if(S==fact.source_url) {
                mustAddSource = false
                _index = i + 1
                break
            }
        }
        
        
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
        factLabel.attributedText = self.attrText(fact.title, index: _index)
        factHStack.addArrangedSubview(factLabel)
        factsVContainer.addArrangedSubview(factHStack)

        print("> FACT", fact.title, _index)


        // SOURCE
        var mustAdd = false
        if(!(self.sources?.contains(fact.source_url))!) {
            self.sources?.append(fact.source_url)
            mustAdd = true
        }
        
        print("SOURCES", self.sources)
        print("SOURCES", "-------")
        
        if(self.sourceRow == -1) {
            let sourcesHStack = UIStackView()
            sourcesHStack.backgroundColor  = self.scrollView.backgroundColor
            sourcesHStack.axis = .horizontal
            sourcesHStack.spacing = 10
            sourcesVContainer.addArrangedSubview(sourcesHStack)
            
            self.sourceRow = 0
        }
        var sourcesHStack = sourcesVContainer.arrangedSubviews[self.sourceRow] as! UIStackView
        
        if(!mustAdd){
            if(isLast) {
                let spacer = UIView()
                spacer.backgroundColor = .green
                spacer.alpha = 0
                sourcesHStack.addArrangedSubview(spacer)
            }
            
            return
        }
        
        
        
        if(!isLast) {
            if let _last = sourcesHStack.arrangedSubviews.last, _last.alpha == 0 {
                _last.removeFromSuperview()
            }
        }
        
        let _sourceHeight: CGFloat = 21.0
        let _sourceFont = UIFont(name: "Roboto-Regular", size: 15)!
        let _sourceText = " [" + String(self.sources!.count) + "] " + fact.source_title + " "
        let _sourceWidth = _sourceText.width(withConstraintedHeight: _sourceHeight,
            font: _sourceFont)
            
        var _widthSum: CGFloat = 0
        let _widthTotal = UIScreen.main.bounds.width - 20 - 40
        for W in self.sourceWidths {
            _widthSum += W + sourcesHStack.spacing
        }
        if(_widthSum + _sourceWidth > _widthTotal) {
            let spacer = UIView()
            spacer.backgroundColor = .systemPink //.clear
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
        sourceLabel.tag = 150 + _index
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
        let extraText = " [" + String(index) + "]"
        let mText = text + extraText
        
        let attr = prettifyText(fullString: mText as NSString, boldPartsOfString: [],
            font: fontBold, boldFont: fontBold,
            paths: [], linkedSubstrings: [],
            accented: [])
        
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
        NSLayoutConstraint.activate([
            subHorizontalStack.heightAnchor.constraint(equalToConstant: 28.0)
        ])
        
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
        //let source = spin.media_title.replacingOccurrences(of: " #", with: "")
//        sourceTime.text = source + " - " + FORMAT_TIME(spin.time)
        let sourceName = spin.media_title.components(separatedBy: " #").first!
        sourceTime.text = sourceName // + " - " + FORMAT_TIME(spin.time)
        //self.LR_PE(name: spin.media_title)
        
        sourceTime.textColor = self.C(0x93A0B4, 0x1D242F)
        sourceTime.font = UIFont(name: "Roboto-Regular", size: 14)!
        subHorizontalStack.addArrangedSubview(sourceTime)
        
        let miniSlider = MiniSlidersCircView(some: "")
        miniSlider.insertInto(stackView: subHorizontalStack)
        let LR_PE = self.LR_PE(name: spin.media_title)
        if(LR_PE.0==0 && LR_PE.1==0) {
            miniSlider.isHidden = true
        } else {
            var cCode = ""
            if let _countryCode = spin.media_country_code {
                cCode = _countryCode
            }
        
            miniSlider.setValues(val1: LR_PE.0, val2: LR_PE.1,
                                 source: sourceName, countryID: cCode)
        }
        miniSlider.viewController = self
        
        let spacer2 = UIView()
        spacer2.backgroundColor = .clear
        subHorizontalStack.addArrangedSubview(spacer2)
        
        
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
    
    private func LR_PE(name: String) -> (Int, Int) {
        let parts = name.components(separatedBy: " #")
        let extName = parts.first!.lowercased()
        
        let LR = StorySourceManager.shared.getLR(name: extName)
        let PE = StorySourceManager.shared.getPE(name: extName)
        
        return (LR, PE)
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
        NSLayoutConstraint.activate([
            subHorizontalStack.heightAnchor.constraint(equalToConstant: 28.0)
        ])
        
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
//        let source = article.media_title.replacingOccurrences(of: " #", with: "")
//        sourceTime.text = source + " - " + FORMAT_TIME(spin.time)
        let sourceName = article.media_title.components(separatedBy: " #").first!
        sourceTime.text = sourceName // + " - " + FORMAT_TIME(spin.time)
        sourceTime.textColor = self.C(0x93A0B4, 0x1D242F)
        sourceTime.font = UIFont(name: "Roboto-Regular", size: 14)!
        subHorizontalStack.addArrangedSubview(sourceTime)
        
        let miniSlider = MiniSlidersCircView(some: "")
        miniSlider.insertInto(stackView: subHorizontalStack)
        let LR_PE = self.LR_PE(name: article.media_title)
        if(LR_PE.0==0 && LR_PE.1==0) {
            miniSlider.isHidden = true
        } else {
            var cCode = ""
            if let _countryCode = article.media_country_code {
                cCode = _countryCode
            }
        
            miniSlider.setValues(val1: LR_PE.0, val2: LR_PE.1,
                                 source: sourceName, countryID: cCode)
        }
        miniSlider.viewController = self

        
        let spacer2 = UIView()
        spacer2.backgroundColor = .clear
        subHorizontalStack.addArrangedSubview(spacer2)
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

//        let vc = PlainWebViewController(url: url, title: title)
//        navigationController?.pushViewController(vc, animated: true)
        
        let vc = WebViewController(url: url, title: title, annotations: [])
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
        
        //print("SOURCE TAG", tag)
        var title = ""
        let link = self.sources![tag-1]
        
        for F in self.facts! {
            if(F.source_url == link) {
                title = F.source_title
                break
            }
        }
        
//        let fact = self.facts![tag]
        self.OPEN_URL(link, title: title)
    }
    
    @IBAction func homeButtonTap(_ sender: UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension StoryContentViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}


extension StoryContentViewController: BiasSliderDelegate, ShadeDelegate {
    
    func biasSliderDidChange(sliderId: Int) {
    
        let dict = ["id": self.uniqueID]
        NotificationCenter.default.post(name: NOTIFICATION_RELOAD_NEWS_IN_OTHER_INSTANCES,
                                        object: nil,
                                        userInfo: dict)
        
        self.scrollView.isHidden = true
        biasSliders.showLoading(true)
        self.showLoading()
        
        for (i, vc) in self.navigationController!.viewControllers.enumerated() {
            if(vc == self) {
                let prev = self.navigationController!.viewControllers[i-1]
                
                if let _vc = prev as? NewsViewController {
                    self.api_call = _vc.buildApiCall()
                }
                
                break
            }
        }
        
        DispatchQueue.main.async {
            self.loadData()
            DELAY(2.0) {
                if(sliderId == self.biasSliders.latestBiasSliderUsed) {
                    self.biasSliders.showLoading(false)
                    self.scrollView.isHidden = false
                    self.showLoading(false)
                }
            }
        }
    }
    private func mustSplit() -> Bool {
        let stancevalues =  self.biasSliders.stanceValues()
        if(stancevalues.0 || stancevalues.1) {
            return true
        } else {
            return false
        }
    }
    
    func splitValueChange() {
        if(self.firstTime){ return }
        
        if( mustSplit() ) { // SPLIT
            self.biasButtonState = 2
        } else { // NORMAL
            self.biasButtonState = 1
        }
        
        for vc in self.navigationController!.viewControllers {
            if(vc != self) {
                if let _vc = vc as? NewsViewController { // NewsViewController
                    if(self.mustSplit()) {
                        _vc.biasSliders.enableSplitForSharing()
                    } else {
                        _vc.biasSliders.disableSplitFromOutside()
                    }
                } else if let _vc = vc as? NewsTextViewController { // NewsTextViewController
                    if(self.mustSplit()) {
                        _vc.biasSliders.enableSplitForSharing()
                    } else {
                        _vc.biasSliders.disableSplitFromOutside()
                    }
                } else if let _vc = vc as? NewsBigViewController { // NewsBigViewController
                    if(self.mustSplit()) {
                        _vc.biasSliders.enableSplitForSharing()
                    } else {
                        _vc.biasSliders.disableSplitFromOutside()
                    }
                }
            }
        }
    
    
    
//        let dict = ["id": self.uniqueID]
//        NotificationCenter.default.post(name: NOTIFICATION_RELOAD_NEWS_IN_OTHER_INSTANCES,
//                                        object: nil,
//                                        userInfo: dict)
//
        self.scrollView.isHidden = true
        biasSliders.showLoading(true)
        self.showLoading()

        DispatchQueue.main.async {
            self.loadData()
            DELAY(2.0) {
//                if(sliderId == self.biasSliders.latestBiasSliderUsed) {
                    self.biasSliders.showLoading(false)
                    self.scrollView.isHidden = false
                    self.showLoading(false)
//                }
            }
        }
    
        let iconImageView = self.biasMiniButton.viewWithTag(767) as! UIImageView
        iconImageView.image = UIImage(named: "shareSplitButton.png")
        
        if(!APP_CFG_SPLITSHARING) {
            self.biasButtonState = 1
        }

        self.biasSliders.canDismiss = true
        var buttonIcon = UIImage(named: "prefsButton.png")
        if(self.biasButtonState == 2) {
            //self.biasSliders.canDismiss = false
            buttonIcon = UIImage(named: "shareSplitButton.png")
            iconImageView.image = UIImage(named: "prefsButton.png")
        }
        self.biasButton.setBackgroundImage(buttonIcon, for: .normal)
        self.biasMiniButton.superview?.bringSubviewToFront(self.biasMiniButton)
    
    
//        if(!self.mustSplit()) {
//            //self.firstTime = true
//            self.loadData()
//
////            let offset = CGPoint(x: 0, y: 0)
////            self.tableView.setContentOffset(offset, animated: true)
////            self.horizontalMenu.backToZero()
//        } else {
//            DELAY(0.3) {
//                Utils.shared.newsViewController_ID = 0
//                let vc = NewsViewController(topic: self.topic)
//                vc.param_A = self.param_A
//                self.navigationController?.viewControllers = [vc]
//            }
//        }
    }
    
    
    // ShadeDelegate
    func dismissShade() {
        if Globals.isSliderOn {
            Globals.isSliderOn = false
        }
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.shadeView.alpha = 0
            self.updateBiasButtonPosition()
        }, completion: nil)
    }
    func panelFullyOpened() {
        UIView.animate(withDuration: 0.5, animations: {
            self.updateBiasButtonPosition()
        })
    }
    
    func updateBiasButtonPosition() {
        var mFrame = self.biasButton.frame
        let screenSize = UIScreen.main.bounds
        
        var posY = screenSize.height - mFrame.size.height
        /*if let nav = navigationController {
            if(!nav.navigationBar.isTranslucent) {
                posY -= 88
            }
        }*/
        posY += mFrame.size.height
        
        //let margin: CGFloat = 6
        let status = self.biasSliders.status
        
        /*
        if(status == "SL02") {
            posY -= self.biasSliders.state02_height - margin
        } else {
            posY -= self.biasSliders.state01_height - margin
        }*/
        if(status == "SL02") {
            posY -= self.biasSliders.state02_height + 110
        } else if(status == "SL01") {
            posY -= self.biasSliders.state01_height + 85
            if(SAFE_AREA()!.bottom>0) { posY -= 25 }
        } else {
            posY -= self.biasSliders.state01_height - 20
        }
        
        mFrame.origin.y = posY
        self.biasButton.frame = mFrame
        
        self.biasMiniButtonUpdatePosition()
        self.biasMiniButton.superview?.bringSubviewToFront(self.biasMiniButton)
    }
    func biasMiniButtonUpdatePosition(offset: CGFloat = 20) {
        var mFrame = self.biasMiniButton.frame
        mFrame.origin.x = self.biasButton.frame.origin.x - offset
        mFrame.origin.y = self.biasButton.frame.origin.y - offset
        self.biasMiniButton.frame = mFrame
    }
    
    @objc func showBiasSliders(_ sender:UIButton!) {
        HAPTIC_CLICK()
    
        if !Globals.isSliderOn {
            Globals.isSliderOn = true
        }
        
        if(self.biasSliders.status == "SL00") {
            configureBiasSliders()
        } else {
            self.biasSliders.handleDismiss()
        }
    }
    func configureBiasSliders() {
        
        let y = view.frame.height - self.biasSliders.state01_height
        biasSliders.addShowMore()
        biasSliders.backgroundColor = accentOrange
        
        shadeView.backgroundColor = UIColor.black.withAlphaComponent(0)
        shadeView.isUserInteractionEnabled = false
        
        view.addSubview(shadeView)
        view.addSubview(biasSliders)
        
        var mFrame = view.frame
        mFrame.origin.y = 0
        shadeView.frame = mFrame
        shadeView.alpha = 0
        
        self.biasSliders.reloadSliderValues()
        self.biasSliders.status = "SL01"
        self.biasSliders.separatorView.isHidden = false
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.shadeView.alpha = 1
                
                var mFrame = self.biasSliders.frame
                mFrame.origin.y = y
                self.biasSliders.frame = mFrame
                
                self.updateBiasButtonPosition()
                
            }, completion: nil)
        
        self.biasButton.superview?.bringSubviewToFront(self.biasButton)
    }
    
    private func setUpBiasButton() {
        let factor: CGFloat = 0.9
        let size = CGSize(width: 78 * factor, height: 82 *  factor)
        let screenSize = UIScreen.main.bounds
        
        self.view.addSubview(self.biasButton)
        let posX = screenSize.width - size.width - 5
        
        var posY = screenSize.height - size.height
        if let nav = self.navigationController {
            if(!nav.navigationBar.isTranslucent) {
                posY -= 88
            }
        }
        posY += size.height - self.biasSliders.state01_height + 15
        
        biasButton.frame = CGRect(x: posX, y: posY,
                                width: size.width, height: size.height)
        //biasButton.layer.cornerRadius = size * 0.5
        let y = view.frame.height - self.biasSliders.state01_height
        biasSliders.frame = CGRect(x: 0, y: y, width: view.frame.width, height: 550)
        
        biasSliders.buildViews()
        self.biasSliders.status = "SL00"
        self.updateBiasButtonPosition()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self,
            action: #selector(biasButtonOnLongPress(gesture:)))
        self.biasButton.addGestureRecognizer(longPressGesture)
    }
    
    func initBiasMiniButton() {
        let dim: CGFloat = 45.0
        
        self.biasMiniButton.frame = CGRect(x: 0, y: 0, width: dim, height: dim)
        self.biasMiniButton.backgroundColor = .clear
        view.addSubview(self.biasMiniButton)
        
        let icon = UIImageView()
        icon.image = UIImage(named: "shareSplitButton.png")
        icon.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        self.biasMiniButton.addSubview(icon)
        icon.center = CGPoint(x: dim/2, y: dim/2)
        icon.tag = 767
        
        let buttonArea = UIButton(type: .custom)
        buttonArea.frame = CGRect(x: 0, y: 0, width: dim, height: dim)
        buttonArea.backgroundColor = .clear
        self.biasMiniButton.addSubview(buttonArea)
        buttonArea.addTarget(self, action: #selector(biasMiniButtonOnTap(sender:)),
            for: .touchUpInside)
        
        self.biasMiniButtonUpdatePosition()
        self.biasMiniButton.isHidden = true
    }
    
    @objc func biasButtonOnLongPress(gesture: UILongPressGestureRecognizer) {
        if(gesture.state != .began){ return }
        
        if(APP_CFG_SPLITSHARING) {
            HAPTIC_CLICK()
        
            if(self.biasMiniButton.isHidden) {
                self.biasMiniButtonUpdatePosition(offset: 0)
                self.biasMiniButton.alpha = 1.0
                self.biasMiniButton.isHidden = false
                self.biasButton.superview?.bringSubviewToFront(self.biasButton)

                UIView.animate(withDuration: 0.4) {
                    self.biasMiniButton.alpha = 1.0
                    self.biasMiniButtonUpdatePosition()
                } completion: { succeed in
                    if(self.miniButtonTimer != nil) {
                        self.miniButtonTimer?.invalidate()
                    }
                    self.miniButtonTimer = Timer.scheduledTimer(withTimeInterval: 4.0,
                        repeats: false) { timer in

                        self.biasButton.superview?.bringSubviewToFront(self.biasButton)
                        UIView.animate(withDuration: 0.4) {
                            self.biasMiniButton.alpha = 1.0
                            self.biasMiniButtonUpdatePosition(offset: 0)
                        } completion: { (succeed) in
                            self.biasMiniButton.isHidden = true
                        }
                    }
                }

            }
        }
    }
    
    @objc func biasMiniButtonOnTap(sender: UIButton) {
        HAPTIC_CLICK()
        
        ENABLE_SPLIT_SHARING_AFTER_LOADING = true
        self.biasSliders.enableSplitForSharing()
    }
    
    
}
