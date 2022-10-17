//
//  StoryContentIPADViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 01/08/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit
import SDWebImage


class StoryContentIPADViewController: UIViewController {

    // ---------------
    private var firstTime: Bool = true
    public var link: String?
    public var api_call: String?

    private var storyData: StoryData?
    private var facts: [StoryFact]?
    private var sources: [String]?
    private var spins: [StorySpin]?
    private var articles: [StoryArticle]?
    private var version: String?

    // ---------------
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    private let loadingView = UIView()
    
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainImageCreditButton: UIButton!
    
    let mainImageViewWidthFactor: CGFloat = 0.4
    @IBOutlet weak var mainImageViewWidthConstraint: NSLayoutConstraint!
    
    private var spinCol = 1
    private var artCol = 1
    
    private var factsAdded: Int = 0
    private var showMoreFacts: Bool = true
    private var sourceRow: Int = 0
    private var sourceWidths = [CGFloat]()
    
    // ---------------
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
            
        SETUP_NAVBAR(viewController: self,
            homeTap: #selector(self.homeButtonTapped),
            menuTap: #selector(self.hamburgerButtonItemClicked(_:)),
            searchTap: #selector(self.searchItemClicked(_:)),
            userTap: nil)
            
        self.loadSplitForPrefsPanel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAll),
            name: NOTIFICATION_FORCE_RELOAD_NEWS,
            object: nil)
    }
    
    @objc func reloadAll() {
        DispatchQueue.main.async {
            self.loadData()
        }
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
        self.spinCol = 1
        self.removeAllSpins()
        self.artCol = 1
        self.removeAllArticles()
        
        if let _link = self.link {
            StoryContent.instance.loadData(link: _link, filter: _filter, mustSplit: self.mustSplit()) { (storyData, facts, spins, articles, version) in
            
                if(storyData == nil || facts == nil || spins == nil || articles == nil || version == nil) {
                    ALERT(vc: self, title: "Error",
                        message: "There was an error loading your content. Try again later") {
                            self.navigationController?.popViewController(animated: true)
                        }
                } else {
                    self.storyData = storyData
                    
                    self.facts = [StoryFact]()
                    // Remove empty sources
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
            
//                self.storyData = storyData
//                self.facts = facts
//                self.spins = spins
//                self.articles = articles
//                self.version = version
//
//                self.updateUI()
//                self.showLoading(false)
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
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    // MARK: - Modified TitleBar
    @objc func homeButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
        let firstIndexPath = IndexPath(row: 0, section: 0)

        if let _vc = navigationController?.viewControllers.first as? NewsViewController {
            DELAY(0.2) {
                _vc.collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: true)
            }
        } else if let _vc = navigationController?.viewControllers.first as? NewsTextViewController {
            DELAY(0.2) {
                _vc.tableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
            }
        } else if let _vc = navigationController?.viewControllers.first as? NewsBigViewController {
            DELAY(0.2) {
                _vc.tableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
            }
        }
    }
    
    @objc func hamburgerButtonItemClicked(_ sender: UIBarButtonItem!) {
        navigationController?.customPushViewController(SectionsViewController())
    }
    
    @objc func searchItemClicked(_ sender:UIBarButtonItem!) {
        let searchvc = SearchViewController()
        navigationController?.pushViewController(searchvc, animated: true)
    }

}

// PRAGMA MARK: - UI
extension StoryContentIPADViewController {

    public static func createInstance() -> StoryContentIPADViewController {
        let vc = StoryContentIPADViewController(nibName: "StoryContentIPADViewController",
            bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    private func setContentView() {
        let screen_W = UIScreen.main.bounds.size.width
        
        self.view.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
        self.scrollView.backgroundColor = self.view.backgroundColor
        
        self.scrollView.addSubview(self.contentView)
        self.contentView.frame = CGRect(x: 0, y: 0,
            width: screen_W, height: self.contentView.frame.size.height)
        self.contentView.backgroundColor = self.scrollView.backgroundColor
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
    
    private func updateUI() {
        let screen_W = UIScreen.main.bounds.size.width
        
        DispatchQueue.main.async {
        
            self.mainTitle.textColor = self.C(0xFFFFFF, 0x1D242F)
            self.mainTitle.backgroundColor = .clear
            self.mainTitle.superview?.backgroundColor = .clear
            self.mainTitle.superview?.superview?.backgroundColor = .clear
            self.mainImageViewWidthConstraint.constant = screen_W * self.mainImageViewWidthFactor
            self.mainImageCreditButton.backgroundColor = .clear
            let spinTitleLabel = self.contentView.viewWithTag(102) as! UILabel
            spinTitleLabel.textColor = self.C(0xFF643C, 0x1D242F)
            let articlesTitleLabel = self.contentView.viewWithTag(104) as! UILabel
            articlesTitleLabel.textColor = self.C(0xFFFFFF, 0xFF643C)
        
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
        
            if let _data = self.storyData {
                self.mainTitle.text = _data.title
                self.mainImageView.sd_setImage(with: URL(string: _data.image_src),
                    placeholderImage: nil)
                    
                let credit = "Image credit: " + _data.image_credit_title
                self.mainImageCreditButton.setCustomAttributedText(credit, color: UIColor(hex: 0x93A0B4))
                
                // DATA
                self.addFacts()
                self.addSpins()
                self.addArticles()
                
                DELAY(0.25) {
                    self.updateContentSize()
                }
            } else {
                self.mainTitle.text = ""
                self.mainImageView.image = nil
                self.mainImageCreditButton.setCustomAttributedText("", color: UIColor(hex: 0x93A0B4))
            }
            
            self.scrollView.isHidden = false
            self.scrollView.isUserInteractionEnabled = true
            self.scrollView.isExclusiveTouch = true
            self.scrollView.canCancelContentTouches = true
            self.scrollView.delaysContentTouches = false
        }
    }
    
    @objc func onDeviceOrientationChanged() {
        let screen_W = UIScreen.main.bounds.size.width
    
        var mFrame = self.contentView.frame
        mFrame.size.width = screen_W
        self.contentView.frame = mFrame
        
        self.mainImageViewWidthConstraint.constant = screen_W * self.mainImageViewWidthFactor
        
        self.updateBiasButtonPosition()
        self.biasSliders.adaptToScreen()
        
        self.removeAllFacts()
        if(self.factsAdded == 1) {
            self.addFacts()
        } else {
            self.addAllFacts()
        }
        
        DELAY(0.5) {
            self.updateContentSize()
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
    
}

// PRAGMA MARK: - misc
extension StoryContentIPADViewController {
    private func C(_ darkColorHex: Int, _ brightColorHex: Int) -> UIColor {
        return DARKMODE() ? UIColor(hex: darkColorHex) : UIColor(hex: brightColorHex)
    }

    private func OPEN_URL(_ url: String, title: String = "") {
//        let vc = PlainWebViewController(url: url, title: title)
//        navigationController?.pushViewController(vc, animated: true)

        let vc = WebViewController(url: url, title: title, annotations: [])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func GET_FLAG(id: String) -> UIImage {
        var result = UIImage(named: "\(id.uppercased())64.png")
        if(result==nil) {
            result = UIImage(named: "noFlag.png")
        }
        return result!
    }
    
    private func LR_PE(name: String) -> (Int, Int) {
        let parts = name.components(separatedBy: " #")
        let extName = parts.first!.lowercased()
        
        let LR = StorySourceManager.shared.getLR(name: extName)
        let PE = StorySourceManager.shared.getPE(name: extName)
        
        return (LR, PE)
    }
    
}

// PRAGMA MARK: - UIGestureRecognizerDelegate
extension StoryContentIPADViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
}

// PRAGMA MARK: - Button(s)
extension StoryContentIPADViewController {

    @IBAction func homeButtonTap(_ sender: UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
     @IBAction func mainImageCreditButtonTap(_ sender: UIButton) {
        if let _data = self.storyData {
            self.OPEN_URL(_data.image_credit_url, title: _data.image_credit_title)
        }
    }
    
}

// PRAGMA MARK: Fact(s)
extension StoryContentIPADViewController {
    
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
                
        if let _facts = self.facts {
        
            if(factsVContainer.arrangedSubviews.count==0) {
                // Initial 3
                self.factsAdded = 1
                for (i, F) in _facts.enumerated() {
                    if(i<=2) {
                        self.addSingleFact(F, isLast: i == 2, index: i)
                    }
                }
            } else {
                // The rest
                self.factsAdded = 2
                for (i, F) in _facts.enumerated() {
                    if(i>2) {
                        self.addSingleFact(F, isLast: i == self.facts!.count-1, index: i)
                    }
                }
            }
        }
        
        /*
        let X: CGFloat = 20 + self.mainImageViewWidthConstraint.constant + 10 + 20
        self.sourcesTotalWidth = UIScreen.main.bounds.width - X - 20 - 20
        */
        
//        let testView = UIView()
//        testView.backgroundColor = .cyan
//        testView.alpha = 0.5
//        self.view.addSubview(testView)
//        testView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            testView.widthAnchor.constraint(equalToConstant: self.sourcesTotalWidth),
//            testView.heightAnchor.constraint(equalToConstant: 200),
//            testView.topAnchor.constraint(equalTo: self.view.topAnchor,
//                constant: 300),
//            testView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,
//                constant: X)
//        ])
    }
    
    private func addAllFacts() {
        let factsVContainer = self.contentView.viewWithTag(100) as! UIStackView
                
        self.factsAdded = 2
        if let _facts = self.facts {
            for (i, F) in _facts.enumerated() {
                self.addSingleFact(F, isLast: i == self.facts!.count-1, index: i)
            }
        }
        
    }
    
    private func addSingleFact(_ fact: StoryFact, isLast: Bool = false, index: Int) {
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
        sourcesHStack.backgroundColor = .clear
        
        
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
        let _sourceText = " [" + String(self.sources!.count) + "] " + fact.source_title + " " + self.sufix(index: _index-1)
        let _sourceWidth = _sourceText.width(withConstraintedHeight: _sourceHeight,
            font: _sourceFont)
            
        var _widthSum: CGFloat = 0
        //let _widthTotal = UIScreen.main.bounds.width - 20 - 40
        
//        let _widthTotal = UIScreen.main.bounds.width - 20 - 20 - 10 - self.mainImageViewWidthConstraint.constant
  
        let X: CGFloat = 20 + self.mainImageViewWidthConstraint.constant + 10 + 20
//        self.sourcesTotalWidth = UIScreen.main.bounds.width - X - 20 - 20
        let _widthTotal = UIScreen.main.bounds.width - X - 20 - 20
  
        for W in self.sourceWidths {
            _widthSum += W + sourcesHStack.spacing
        }
        if(_widthSum + _sourceWidth > _widthTotal) {
            let spacer = UIView()
            spacer.backgroundColor = .clear
            spacer.alpha = 0
            sourcesHStack.addArrangedSubview(spacer)
            
            let newSourcesHStack = UIStackView()
            newSourcesHStack.backgroundColor  = self.scrollView.backgroundColor
            newSourcesHStack.axis = .horizontal
            newSourcesHStack.spacing = 10
            sourcesVContainer.addArrangedSubview(newSourcesHStack)
            
            self.sourceRow += 1
            self.sourceWidths = [CGFloat]()
            
            //sourcesHStack = sourcesVContainer.arrangedSubviews[self.sourceRow] as! UIStackView
            sourcesHStack = sourcesVContainer.arrangedSubviews.last as! UIStackView
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
    
    func sufix(index: Int) -> String {
        
        var _sources: [(name: String, url: String)] = []
        
        // remove repeated url(s)
        for F in self.facts! {
            var found = false
            for _S in _sources {
                if(_S.url == F.source_url) {
                    found = true
                    break
                }
            }
            
            if(!found) {
                _sources.append((name: F.source_title, url: F.source_url))
            }
        }

        let name = _sources[index].name
        var count = 0
        for _S in _sources {
            if(_S.name == name) {
                count += 1
            }
        }
        
        if(count == 1) {
            return ""
        } else {
            var num = 0
            for (i, _S) in _sources.enumerated() {
                if(_S.name == name) {
                    num += 1
                    if(i==index) {
                        break
                    }
                }
            }
            
            let letters = "abcdefghijklmnopqrstuvwxyz"
            return "(" + String(letters[num-1]) + ") "
        }
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
    
    func addUnderline(to label: UILabel) {
        let attrText = NSMutableAttributedString(string: label.text!)
        var range = NSRange(location: 3, length: attrText.string.count-3)
        
        attrText.addAttribute(NSAttributedString.Key.underlineStyle,
            value: 1, range: range)
        
        label.attributedText = attrText
    }
    
    @IBAction func sourceLabelTap(_ sender: UITapGestureRecognizer) {
        let label = sender.view as! UILabel
        let tag = label.tag - 150
        
        var title = ""
        let link = self.sources![tag-1]
        
        for F in self.facts! {
            if(F.source_url == link) {
                title = F.source_title
                break
            }
        }
        
        self.OPEN_URL(link, title: title)
    }
    
    @IBAction func showMoreSourcesButtonTap(_ sender: UIButton) {
        if(self.showMoreFacts) {
            sender.setCustomAttributedText("Show fewer facts")
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
    
    private func resetFacts() {
        self.removeAllFacts()
        self.addFacts()
    }
    
}

// PRAGMA MARK: Spin(s)
extension StoryContentIPADViewController {
    
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
        let v_main_container = self.contentView.viewWithTag(103) as! UIStackView
        var h_colS_container: UIStackView!
        
        if(self.spinCol == 1) {
            // New col
            h_colS_container = UIStackView()
            h_colS_container.axis = .horizontal
            h_colS_container.spacing = 40
            h_colS_container.backgroundColor = .clear //.green
            v_main_container.addArrangedSubview(h_colS_container)
        } else {
            h_colS_container = (v_main_container.subviews.last as! UIStackView)
        }
        self.spinCol += 1
        if(self.spinCol>2){ self.spinCol = 1 }
        
        let v_col_container = UIStackView()
        v_col_container.axis = .vertical
        v_col_container.spacing = 10
        v_col_container.backgroundColor = .clear //.yellow
        h_colS_container.addArrangedSubview(v_col_container)
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Merriweather-Bold", size: 17)
        titleLabel.text = spin.title
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = self.C(0xFFFFFF, 0xFF643C)
        v_col_container.addArrangedSubview(titleLabel)
        titleLabel.tag = 200 + index
        

        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont(name: "Roboto-Regular", size: 16)!
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.textColor = self.C(0x93A0B4, 0x1D242F)
        descriptionLabel.text = spin.description
        v_col_container.addArrangedSubview(descriptionLabel)
        descriptionLabel.tag = 200 + index

        // Incomplete spin
//        if let _image = spin.image, let _subTitle = spin.subTitle,
//            let _mediaCountryCode = spin.media_country_code,
//            let _mediaTitle = spin.media_title {
//        if(spin.image.isEmpty && spin.subTitle.isEmpty
//            && spin.media_country_code == nil && spin.media_title.isEmpty) {
        
//            spinsVContainer.addArrangedSubview(titleLabel)
//            spinsVContainer.addArrangedSubview(descriptionLabel)
//            self.addSpinSeparator(verticalStackView: spinsVContainer)
        
        let A = (spin.image == nil)
        var A2 = false
        if let _field = spin.image, _field.isEmpty {
            A2 = true
        }
        
        let B = (spin.subTitle == nil)
        var B2 = false
        if let _field = spin.subTitle, _field.isEmpty {
            B2 = true
        }
        
        let C = (spin.media_country_code == nil)
        var C2 = false
        if let _field = spin.media_country_code, _field.isEmpty {
            C2 = true
        }
        
        let D = (spin.media_title == nil)
        var D2 = false
        if let _field = spin.media_title, _field.isEmpty {
            D2 = true
        }
        
        if( (A || A2) && (B || B2) && (C || C2) && (D || D2)) {
            let spacer = UIView()
            spacer.backgroundColor = .clear
            v_main_container.backgroundColor = .clear
            v_col_container.addArrangedSubview(spacer)
        
            return
        }

        self.ADD_SPIN_TAP(to: titleLabel)
        self.ADD_SPIN_TAP(to: descriptionLabel)

        let h_img_container = UIStackView()
        h_img_container.axis = .horizontal
        h_img_container.backgroundColor = .clear
        h_img_container.spacing = 10.0

        let factor: CGFloat = 1.3
        let imageView = UIImageView()
        imageView.contentMode = self.mainImageView.contentMode
        imageView.clipsToBounds = true
        imageView.backgroundColor = .darkGray
        h_img_container.addArrangedSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 112 * factor),
            imageView.heightAnchor.constraint(equalToConstant: 75 * factor)
        ])
//        imageView.sd_setImage(with: URL(string: spin.image), placeholderImage: nil)
        if let _image = spin.image {
            imageView.sd_setImage(with: URL(string: _image), placeholderImage: nil)
        } else {
            imageView.image = nil
        }
        imageView.tag = 200 + index
        self.ADD_SPIN_TAP(to: imageView)

        let v_data_container = UIStackView()
        v_data_container.axis = .vertical
        v_data_container.spacing = 2.0
        v_data_container.backgroundColor = .clear

        let spinTitleLabel = UILabel()
        spinTitleLabel.text = spin.subTitle
        spinTitleLabel.numberOfLines = 3
        spinTitleLabel.font = UIFont(name: "Merriweather-Bold", size: 17)
        spinTitleLabel.textColor = self.C(0xFFFFFF, 0x1D242F)
        spinTitleLabel.adjustsFontSizeToFitWidth = true
        spinTitleLabel.minimumScaleFactor = 0.5
        v_data_container.addArrangedSubview(spinTitleLabel)
        spinTitleLabel.tag = 200 + index
        self.ADD_SPIN_TAP(to: spinTitleLabel)

        let h_flag_container = UIStackView()
        h_flag_container.axis = .horizontal
        h_flag_container.backgroundColor = .clear
        h_flag_container.spacing = 7.0
        NSLayoutConstraint.activate([
            h_flag_container.heightAnchor.constraint(equalToConstant: 28.0)
        ])

        if let _countryCode = spin.media_country_code, MorePrefsViewController.showFlags() {
            let flag = UIImageView()
            flag.contentMode = .scaleAspectFit
            flag.image = self.GET_FLAG(id: _countryCode)

            h_flag_container.addArrangedSubview(flag)
            flag.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                flag.widthAnchor.constraint(equalToConstant: 20),
                flag.heightAnchor.constraint(equalToConstant: 20)
            ])
        }

        let sourceTime = UILabel()
        //let source = spin.media_title.replacingOccurrences(of: " #", with: "")
//        sourceTime.text = source + " - " + FORMAT_TIME(spin.time)
//        sourceTime.text = spin.media_title.components(separatedBy: " #").first! // + " - " + FORMAT_TIME(spin.time)
        var sourceName = ""
        if let _media_title = spin.media_title {
            sourceName = _media_title.components(separatedBy: " #").first!
        }
        //self.LR_PE(name: spin.media_title)

        sourceTime.textColor = self.C(0x93A0B4, 0x1D242F)
        sourceTime.font = UIFont(name: "Roboto-Regular", size: 14)!
        h_flag_container.addArrangedSubview(sourceTime)

        if(MorePrefsViewController.showStanceInsets()) {
            let miniSlider = MiniSlidersCircView(some: "")
            miniSlider.insertInto(stackView: h_flag_container)
            
//            let LR_PE = self.LR_PE(name: spin.media_title)
            var LR_PE = (1, 1)
            if let _mediaTitle = spin.media_title {
                LR_PE = self.LR_PE(name: _mediaTitle)
            }

            if(LR_PE.0==0 && LR_PE.1==0) {
                miniSlider.isHidden = true
            } else {
                miniSlider.setValues(val1: LR_PE.0, val2: LR_PE.1, source: spin.media_title ?? "")
            }
            miniSlider.viewController = self
        }

        let spacer2 = UIView()
        spacer2.backgroundColor = .clear
        h_flag_container.addArrangedSubview(spacer2)


        v_data_container.addArrangedSubview(h_flag_container)

        let spacer = UIView()
        spacer.backgroundColor = .clear
        v_data_container.addArrangedSubview(spacer)

        h_img_container.addArrangedSubview(v_data_container)
        v_col_container.addArrangedSubview(h_img_container)
        
        let extraHeight = UIView()
        extraHeight.backgroundColor = .clear
        v_col_container.addArrangedSubview(extraHeight)
        extraHeight.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            extraHeight.heightAnchor.constraint(equalToConstant: 25)
        ])

        // ---------

        if(self.spinCol==2 && index<self.spins!.count-1) {
            // VERTICAL LINE
            let vLine = UIView()
            vLine.backgroundColor = .clear //.red.withAlphaComponent(0.2)
            vLine.clipsToBounds = true
            h_colS_container.addSubview(vLine)
            
            vLine.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vLine.topAnchor.constraint(equalTo: h_colS_container.topAnchor),
                vLine.bottomAnchor.constraint(equalTo: h_colS_container.bottomAnchor),
                vLine.widthAnchor.constraint(equalToConstant: 4),
                vLine.centerXAnchor.constraint(equalTo: h_colS_container.centerXAnchor)
            ])
            
            let lineImageView = UIImageView()
            lineImageView.image = UIImage(named: "StoryArticleLineSep_vert_iPad.png")
            lineImageView.backgroundColor = .clear
            lineImageView.alpha = 0.7
            vLine.addSubview(lineImageView)
            vLine.clipsToBounds = true
            lineImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
//                lineImageView.topAnchor.constraint(equalTo: vLine.topAnchor),
//                lineImageView.bottomAnchor.constraint(equalTo: vLine.bottomAnchor),
                
                lineImageView.heightAnchor.constraint(equalToConstant: 300),
                lineImageView.widthAnchor.constraint(equalToConstant: 2),
                lineImageView.centerXAnchor.constraint(equalTo: vLine.centerXAnchor),
                lineImageView.centerYAnchor.constraint(equalTo: vLine.centerYAnchor)
            ])
        }
        
        var add_H_line = false
        if(self.spinCol==1 && index>0) {
            add_H_line = true
        }

        if(self.spinCol==2 && index==self.spins!.count-1) {
            // Spacer
            let spacer = UIStackView()
            spacer.axis = .vertical
            spacer.spacing = 10
            spacer.backgroundColor = .clear
            h_colS_container.addArrangedSubview(spacer)
            
            let titleLabel = UILabel()
            titleLabel.text = "Lorem ipsum"
            titleLabel.numberOfLines = 0
            titleLabel.textColor = .clear
            spacer.addArrangedSubview(titleLabel)
            
            add_H_line = true
        }
        
        if(add_H_line) {
        // HORIZONTAL LINE
            let hLine = UIView()
            hLine.backgroundColor = .clear
            v_main_container.addArrangedSubview(hLine)
            
            hLine.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hLine.leadingAnchor.constraint(equalTo: v_main_container.leadingAnchor),
                hLine.trailingAnchor.constraint(equalTo: v_main_container.trailingAnchor),
                hLine.heightAnchor.constraint(equalToConstant: 4)
            ])
            
            let lineImageView = UIImageView()
            lineImageView.image = UIImage(named: "StoryArticleLineSep_iPad.png")
            lineImageView.backgroundColor = .clear
            lineImageView.alpha = 0.7
            hLine.addSubview(lineImageView)
            hLine.clipsToBounds = true
            lineImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                lineImageView.leadingAnchor.constraint(equalTo: hLine.leadingAnchor),
                lineImageView.trailingAnchor.constraint(equalTo: hLine.trailingAnchor),
                lineImageView.heightAnchor.constraint(equalToConstant: 2),
                lineImageView.centerYAnchor.constraint(equalTo: hLine.centerYAnchor)
            ])
        }
        
        v_main_container.backgroundColor = .clear
    }
    
    @IBAction func spinOnTap(_ sender: UITapGestureRecognizer) {
        let tag = sender.view!.tag - 200
        
        let spin = self.spins![tag]
//        self.OPEN_URL(spin.url, title: spin.subTitle)
        if let _url = spin.url, let _subTitle = spin.subTitle {
                    self.OPEN_URL(_url, title: _subTitle)
        }
    }
    
    private func ADD_SPIN_TAP(to view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(spinOnTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
}

// PRAGMA MARK: - Article(s)
extension StoryContentIPADViewController {
    
    private func removeAllArticles() {
        let articlesVContainer = self.contentView.viewWithTag(105) as! UIStackView
        articlesVContainer.removeAllArrangedSubviews()
    }
    
    private func addArticles() {
    
        print("ARTICLES", self.articles?.count)
        if let _articles = self.articles {
            for (i, AR) in _articles.enumerated() {
                self.addSingleArticle(AR, index: i)
            }
        }
    }
    
    private func addSingleArticle(_ article: StoryArticle, index: Int) {
        let v_main_container = self.contentView.viewWithTag(105) as! UIStackView
        var h_colS_container: UIStackView!
        
        if(self.artCol == 1) {
            // New col
            h_colS_container = UIStackView()
            h_colS_container.axis = .horizontal
            h_colS_container.spacing = 25
            h_colS_container.backgroundColor = .clear
            v_main_container.addArrangedSubview(h_colS_container)
        } else {
            h_colS_container = (v_main_container.subviews.last as! UIStackView)
        }
        self.artCol += 1
        if(self.artCol>3){ self.artCol = 1 }
        
        
        let v_img_container = UIStackView()
        v_img_container.axis = .vertical
        v_img_container.backgroundColor = .clear
        v_img_container.spacing = 8
        h_colS_container.addArrangedSubview(v_img_container)

        let factor: CGFloat = 1.3
        let imageView = UIImageView()
        imageView.contentMode = self.mainImageView.contentMode
        imageView.clipsToBounds = true
        imageView.backgroundColor = .darkGray
        v_img_container.addArrangedSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            imageView.widthAnchor.constraint(equalToConstant: 112 * factor),
            imageView.heightAnchor.constraint(equalToConstant: 185)
        ])
        imageView.sd_setImage(with: URL(string: article.image), placeholderImage: nil)
        imageView.tag = 300 + index
        self.ADD_ARTICLE_TAP(to: imageView)
        
        let articleTitleLabel = UILabel()
        articleTitleLabel.text = article.title
        articleTitleLabel.numberOfLines = 4
        articleTitleLabel.font = UIFont(name: "Merriweather-Bold", size: 17)
        articleTitleLabel.textColor = self.C(0xFFFFFF, 0x1D242F)
        articleTitleLabel.adjustsFontSizeToFitWidth = true
        articleTitleLabel.minimumScaleFactor = 0.5
        articleTitleLabel.tag = 300 + index
        self.ADD_ARTICLE_TAP(to: articleTitleLabel)
        v_img_container.addArrangedSubview(articleTitleLabel)

        let h_flag_container = UIStackView()
        h_flag_container.axis = .horizontal
        h_flag_container.backgroundColor = .clear
        h_flag_container.spacing = 7.0
        v_img_container.addArrangedSubview(h_flag_container)
        NSLayoutConstraint.activate([
            h_flag_container.heightAnchor.constraint(equalToConstant: 28.0)
        ])

        if let _countryCode = article.media_country_code, MorePrefsViewController.showFlags() {
            let flag = UIImageView()
            flag.contentMode = .scaleAspectFit
            flag.image = self.GET_FLAG(id: _countryCode)

            h_flag_container.addArrangedSubview(flag)
            flag.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                flag.widthAnchor.constraint(equalToConstant: 20),
                flag.heightAnchor.constraint(equalToConstant: 20)
            ])
        }

        let sourceTime = UILabel()
//        let source = article.media_title.replacingOccurrences(of: " #", with: "")
//        sourceTime.text = source + " - " + FORMAT_TIME(spin.time)
        sourceTime.text = article.media_title.components(separatedBy: " #").first! // + " - " + FORMAT_TIME(spin.time)
        sourceTime.textColor = self.C(0x93A0B4, 0x1D242F)
        sourceTime.font = UIFont(name: "Roboto-Regular", size: 14)!
        h_flag_container.addArrangedSubview(sourceTime)

        if(MorePrefsViewController.showStanceInsets()) {
            let miniSlider = MiniSlidersCircView(some: "")
            miniSlider.insertInto(stackView: h_flag_container)
            let LR_PE = self.LR_PE(name: article.media_title)
            if(LR_PE.0==0 && LR_PE.1==0) {
                miniSlider.isHidden = true
            } else {
                miniSlider.setValues(val1: LR_PE.0, val2: LR_PE.1, source: article.media_title)
            }
            miniSlider.viewController = self
        }

        let spacer2 = UIView()
        spacer2.backgroundColor = .clear
        h_flag_container.addArrangedSubview(spacer2)
        v_img_container.addArrangedSubview(h_flag_container)

        let spacer = UIView()
        spacer.backgroundColor = .clear
        v_img_container.addArrangedSubview(spacer)
        
        // ---------
        
        if(index==self.articles!.count-1) {
            let col = self.artCol-1
            
            if(col==1 || col==2) {
                for i in col+1...3 {
                    // Spacer
                    let spacer = UIStackView()
                    spacer.axis = .horizontal
                    spacer.spacing = 15
                    spacer.backgroundColor = .clear
                    h_colS_container.addArrangedSubview(spacer)
                    
                    let titleLabel = UILabel()
                    titleLabel.text = "Lorem ipsum"
                    titleLabel.numberOfLines = 0
                    titleLabel.textColor = .clear
                    spacer.addArrangedSubview(titleLabel)
                }
            }
        }
        
        v_main_container.backgroundColor = .clear
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



extension StoryContentIPADViewController: BiasSliderDelegate, ShadeDelegate {
    
    func biasSliderDidChange(sliderId: Int) {
    
        let dict = ["id": self.uniqueID]
        NotificationCenter.default.post(name: NOTIFICATION_RELOAD_NEWS_IN_OTHER_INSTANCES,
                                        object: nil,
                                        userInfo: dict)
        
        self.scrollView.isHidden = true
        biasSliders.showLoading(true)
        self.showLoading()
        
        if let _navController = self.navigationController {
            for (i, vc) in _navController.viewControllers.enumerated() {
                if(vc == self) {
                    let prev = self.navigationController!.viewControllers[i-1]
                    
                    if let _vc = prev as? NewsViewController {
                        self.api_call = _vc.buildApiCall()
                    }
                    
                    break
                }
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
        
        if let _navController = self.navigationController {
            for vc in _navController.viewControllers {
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
    
    
    let factor: CGFloat = 0.9
        
//        let screenSize = UIScreen.main.bounds
//
//        self.view.addSubview(self.biasButton)
//        let posX = screenSize.width - size.width - 5
//
//        var posY = screenSize.height - size.height
//        if let nav = self.navigationController {
//            if(!nav.navigationBar.isTranslucent) {
//                posY -= 88
//            }
//        }
//        posY += size.height - self.biasSliders.state01_height + 15
//
//        biasButton.frame = CGRect(x: posX, y: posY,
//                                width: size.width, height: size.height)
//        //biasButton.layer.cornerRadius = size * 0.5
//        let y = view.frame.height - self.biasSliders.state01_height
//        biasSliders.frame = CGRect(x: 0, y: y, width: view.frame.width, height: 550)
//
//        biasSliders.buildViews()
//        self.biasSliders.status = "SL00"
//        self.updateBiasButtonPosition()
        ///////////////////////////////////////////////////////
        let size = CGSize(width: 78 * factor, height: 82 *  factor)
    
        var mFrame = self.biasButton.frame
        let screenSize = UIScreen.main.bounds
        
        let posX = screenSize.width - size.width - 5
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
        mFrame.origin.x = posX
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
