//
//  NewsViewController.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 5/29/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import UIKit
import LBTATools
import SDWebImage
import SafariServices
import SwiftyJSON
import SwiftUI

class NewsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout,
    NewsDelegate {

    var uniqueID = -1
    let NOTIFICATION_RELOAD_NEWS_IN_OTHER_INSTANCES = Notification.Name("reloadNewsInOtherInstances")

    let newsParser = News()                 // parser

    // components
    let searchBar = UISearchBar()           // searchBar
    var refresher: UIRefreshControl!        // pull to refresh
    let biasSliders = SliderPopup()         // Preferences (orange) panel
    let loadingView = UIView()              // loading with activityIndicator inside
    
    var shareSplitView: ShareSplitExplainPopup?
    var shareActionsView: ShareSplitActionsPopup?
    var shareArticles: ShareSplitArticles?
    var biasMiniButton = UIView()
    var miniButtonTimer: Timer?
    var enableSplitSharingAfterLoading = false
    var scrollAfterEnableSplit = false
    
    // to populate CollectionView
    //changed home link from "http://www.improvethenews.org/itnserver.php/?topic=" to this one
    //let homelink = "http://ec2-user@ec2-3-16-51-0.us-east-2.compute.amazonaws.com/appserver.php/?topic="
    let homelink = "https://www.improvethenews.org/appserver.php/?topic="
    
    var mainTopic = "Headlines"
    var topic = ""                          // current topic, set at the beginning
    var hierarchy = ""                      // hierarchy (path)
    var superSliderStr = ""                 // para armar el request
    var topicCodeFromSearch = ""
    var splitChangeFirstTime = false
    
    // --------------------------------------------------------
    // horizontal menu
    private var mustShowHorizontalMenu = false
    private var moreHeadLines = MoreHeadlinesView()
    private var seeMoreFooterSection: seeMoreFooterSection0?
    private var moreHeadLinesInCollectionPosY: CGFloat = 0
    
    // --------------------------------------------------------
    //var superSliderLatestUpdate = Date()
    var param_A = 4
    var param_B = 4
    var param_S = 0
    
        let screenWidth = UIScreen.main.bounds.width
        var navBarFrame = CGRect.zero
    // -----------
    var firstTime = true
    var scrollToTopOnLoad = false
//    let pieChartVC = PieChartViewController()
    
    let shadeView = UIView()
    var biasButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "prefsButton.png"), for: .normal)
        button.addTarget(self, action: #selector(showBiasSliders(_:)), for: .touchUpInside)
        //button.clipsToBounds = true
        return button
    }()
    var biasButtonState = 1         // 1: normal icon, 2: share-split icon
    var onBoard: OnBoardingView?
    
    static var biasStatusForCookie = ""
    
    
    // DELETE LATER (!!!)
    var topicSliders = TopicSliderPopup()   // pie chart screen
    var topicTopAnchorHidden: NSLayoutConstraint?
    var topicTopAnchorVisible: NSLayoutConstraint?
    var topicBottomAnchor: NSLayoutConstraint?
    var sliderValues: SliderValues!
    
    var vDivider = UIView()
    
    var hapticType = 0
    
    func testHaptic() {
        DELAY(2.0) {
            self.hapticType += 1
            if(self.hapticType>9){ self.hapticType = 1 }
            
            HAPTIC(type: self.hapticType)
            self.testHaptic()
        }
    }
    
    var articleSide = 0
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Initialization
    init(topic: String) {
        let layout = UICollectionViewFlowLayout.init()
        super.init(collectionViewLayout: layout)
        self.topic = topic
    }
    
    required init?(coder: NSCoder) {    // by default
        fatalError()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.badgeView.removeFromSuperview()
    }
    override func viewDidDisappear(_ animated: Bool) {
        if(self.miniButtonTimer != nil) {
            self.miniButtonTimer?.invalidate()
        }
        self.biasMiniButton.isHidden = true
    }
    
    override func viewDidLoad() {
        if(IS_iPHONE()) {
            AppUtility.lockOrientation(.portrait)
        } else {
            AppUtility.lockOrientation(.all)
        }
        
        self.enableSplitSharingAfterLoading = ENABLE_SPLIT_SHARING_AFTER_LOADING
        ENABLE_SPLIT_SHARING_AFTER_LOADING = false
        
        Utils.shared.navController = self.navigationController as? CustomNavigationController
        Utils.shared.newsViewController_ID += 1
        self.uniqueID = Utils.shared.newsViewController_ID
    
        //overrideUserInterfaceStyle = .dark
                
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        newsParser.newsDelegate = self
        sliderValues = SliderValues.sharedInstance //!!!
        biasSliders.sliderDelegate = self
        biasSliders.shadeDelegate = self
        
        topicSliders.dismissDelegate = self //!!!
        topicSliders.sliderDelegate = self  //!!!
        
        NotificationCenter.default.addObserver(self, selector: #selector(showPrefsPanelFromTour),
            name: NOTIFICATION_ONBOARDING_PREFS_PANEL_SHOW, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hidePrefsPanel),
            name: NOTIFICATION_ONBOARDING_PREFS_PANEL_HIDE, object: nil)
        
        if(self.uniqueID==1) {
            NotificationCenter.default.addObserver(self, selector: #selector(showOnboardingAgain),
            name: NOTIFICATION_SHOW_ONBOARDING, object: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUpNavBar),
            name: NOTIFICATION_UPDATE_NAVBAR, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSlidersInfo),
            name: NOTIFICATION_SHOW_SLIDERS_INFO, object: nil)
            
        NotificationCenter.default.addObserver(self,
            selector: #selector(reloadOtherInstances(notification:)),
            name: NOTIFICATION_RELOAD_NEWS_IN_OTHER_INSTANCES, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNews),
            name: UIApplication.willEnterForegroundNotification, object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAll),
            name: NOTIFICATION_FORCE_RELOAD_NEWS,
            object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(onJsonParseError),
            name: NOTIFICATION_JSON_PARSE_ERROR,
            object: nil)
       
        // collectionView, register cells
        self.collectionView.register(SubtopicHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SubtopicHeader.headerId)
        self.collectionView.register(SubtopicHeaderForSplit.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SubtopicHeaderForSplit.headerId)
        
        
        self.collectionView.register(FAQFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FAQFooter.footerId)
        self.collectionView.register(seeMoreFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: seeMoreFooter.footerId)
        self.collectionView.register(seeMoreFooterSection0.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: seeMoreFooterSection0.footerId)
        self.collectionView.register(seeMoreFooterLast.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: seeMoreFooterLast.footerId)
        self.collectionView.register(ArticleCell.self, forCellWithReuseIdentifier: ArticleCell.cellId)
        self.collectionView.backgroundColor = .systemBackground
        self.collectionView.register(ArticleCellHalf.self, forCellWithReuseIdentifier: ArticleCellHalf.cellId)
        self.collectionView.register(HeadlineCell.self, forCellWithReuseIdentifier: HeadlineCell.cellId)
        self.collectionView.register(ArticleCellAlt.self, forCellWithReuseIdentifier: ArticleCellAlt.cellId)
        self.collectionView.register(StoryCollectionViewCell.self, forCellWithReuseIdentifier: StoryCollectionViewCell.cellId)
        
        
        // intialize some anchors !!!
        topicTopAnchorHidden = topicSliders.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        topicTopAnchorVisible = topicSliders.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        topicBottomAnchor = topicSliders.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        setUpNavBar()
        configureBiasButton()
        self.initBiasMiniButton()
        configureTopicButton() //!!!
        setUpRefresh()
        setUpActivityIndicator()
        initDivider()
        
        self.moreHeadLines.initialize(width: self.screenWidth)
        self.view.addSubview(self.moreHeadLines)
        self.moreHeadLines.delegate = self
        self.moreHeadLines.hide()
        
        self.view.backgroundColor = bgBlue_LIGHT
        self.collectionView.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
        
//        pieChartVC.delegate = self
        
        
        /*
        //testing height(s)
        var AAA: CGFloat = 96+(240*2)+8+115 // header + 2rows + margins + bigFooter(0)
        var BBB: CGFloat = 96+(240*2)+8+70 // header + 2rows + margins + bigFooter(0)
        
        let redView = UIView(frame: CGRect(x: 20, y: AAA + BBB + BBB, width: 100, height: 20))
        redView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        self.collectionView.addSubview(redView)
        */
        
        self.splitChangeFirstTime = true
        let splitValue = UserDefaults.standard.integer(forKey: "userSplitPrefs")
        if(splitValue != 0) {
            self.splitChangeFirstTime = false
            self.biasSliders.setSplitValue(splitValue-1)
            if(self.uniqueID==1 && APP_CFG_SPLITSHARING){ Globals.isSliderOn = true }
        } else {
        }
        
        /*
        // App become active
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        */
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
            
        if(SHOW_ONBOARD() && self.uniqueID==1) {
            self.onBoard = OnBoardingView(container: self.view,
                parser: self.newsParser,
                topic: self.topic,
                sliderValues: self.getSliderValues())
            self.onBoard?.delegate = self
            
            if let obView = self.onBoard {
                obView.alpha = 0.0
                UIView.animate(withDuration: 0.4, delay: 1.0, options: .curveLinear) {
                    obView.alpha = 1.0
                } completion: { success in
                    AppUtility.lockOrientation(ORIENTATION_MASK())
                }
            }
        }
        
        self.shareSplitView = ShareSplitExplainPopup(into: self.view)
        self.shareSplitView?.delegate = self
        self.shareActionsView = ShareSplitActionsPopup(into: self.view)
        self.shareActionsView?.delegate = self
        self.shareArticles = ShareSplitArticles(into: self.view)
        self.shareArticles?.delegate = self
        
//        // ----------------------------------------------

//        DELAY(1.0) {
//            //let vc = AppUser.shared.accountViewController()
//            let vc = MyAccountV2ViewController.createInstance()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        self.shareArticles?.rotate()
    }
    
    
    
    @objc func onJsonParseError() {
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        let tryAgain = UIAlertAction(title: "Try again", style: .default) { action in
            self.firstTime = true
            self.loadData()
        }
        
        let alert = UIAlertController(title: "Improve the news", message: "There was an error loading your news", preferredStyle: .alert)
        alert.addAction(cancel)
        alert.addAction(tryAgain)
        
        self.present(alert, animated: true) {
        }
    }
    
    @objc func onDeviceOrientationChanged() {
        if(!self.firstTime) {
            self.collectionView.collectionViewLayout.invalidateLayout()
            
            // horizontal menu
            self.scrollViewDidScroll(self.collectionView)
            self.moreHeadLines.changeWidthTo(UIScreen.main.bounds.width)
            
            // loading
            let dim: CGFloat = 65
            self.loadingView.frame = CGRect(x: (UIScreen.main.bounds.width-dim)/2,
                                        y: ((UIScreen.main.bounds.height-dim)/2) - 88,
                                        width: dim, height: dim)
                                        
            self.updateBiasButtonPosition()
            self.biasSliders.adaptToScreen()
        }
    }
    
    
    
    var lastTimeActive: Date?
    @objc func applicationDidBecomeActive() {
        if let _lastTimeActive = self.lastTimeActive {
            let now = Date()
            let diff = now - _lastTimeActive
            let limit: TimeInterval = 60 * APP_CFG_INACTIVE_MINS
            
            if(diff >= limit) {
                self.firstTime = true
                self.loadData()
            }
        }
        
    }
    @objc func applicationDidEnterBackground() {
        self.lastTimeActive = Date()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // icons tint
        navigationController?.navigationBar.tintColor = DARKMODE() ? .white : darkForBright
        
        
        //print(Utils.shared.navController)
        //STATUS_BAR_UPDATE()
        
        //UINavigationBar.appearance().    = DARKMODE() ? .black : .default
        
        //navigationController?.navigationBar
        
        //navigationController?.navigationBar.barStyle = DARKMODE() ? .black : .default
        //UPDATE_STATUSBAR(self.navigationController)
        
        self.setUpNavBar()

        collectionView.delaysContentTouches = false
        for view in collectionView.subviews {
          if view is UIScrollView {
              (view as? UIScrollView)!.delaysContentTouches = false
              break
          }
        }
        
        self.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.biasSliders.reloadSliderValues()
        
        if(!self.firstTime && !self.topicCodeFromSearch.isEmpty) {
            self.loadTopicFromSearch()
        }
        
        
        if(APP_CFG_SHOW_MARKUPS && self.uniqueID==1) {
            DELAY(0.3) {
                CookiesAlert.shared.show(viewController: self)
            }
        }
        
        
        
        
        //!!!
//        if(self.firstTime) {
//            let vc = FAQViewController.createInstance()
//            self.present(vc, animated: true)
//        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return STATUS_BAR_STYLE()
    }
    
    // MARK: - Data loading
    func loadData() {
        if(self.firstTime){
            //activityIndicator.startAnimating()
            if(self.loadingView.isHidden) {
                self.loadingView.isHidden = false
            }
            
            //DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            DispatchQueue.main.async {
                self.loadArticles()
                self.reload()
                self.updateTopicSliders()
                
                
                if Globals.isSliderOn {
                    //self.configureBiasSliders()
                }
                
                DELAY(2.0) {
                    self.loadingView.isHidden = true
                    self.firstTime = false
                    self.collectionView.reloadData()
                    self.stopRefresher()
                }

            }
        }
    }
    
    func loadArticles() {
        sliderValues.setTopic(topic: self.topic)
        
        DispatchQueue.global().async {
            let link = self.buildApiCall()
            
            print("GATO", "should load " + link)
            
            //ALERT(vc: self, title: "URL", message: link)
            self.newsParser.getJSONContents(jsonName: link)
        }
    }
    
    /*
    private func buildApiCall_b() -> String {
        let link = "topic=\(self.topic)" +
            ".A\(self.param_A)" + ".B\(self.param_B)" +
            ".S\(self.param_S)"
            
        return link
    }
    */
    
    func buildApiCall(topicForCall: String? = nil, zeroItems: Bool = false) -> String {

        var T = ""
        var ABS = [Int]()
        
        if(topicForCall != nil) {
            T = topicForCall!
        } else {
            T = self.topic
        }
        
        if(zeroItems) {
            ABS = [0, 0, 0]
        } else {
            ABS = [self.param_A,
                    self.param_B,
                    self.param_S
                    ]
        }
        
        var banner: String?
        for bannerID in BannerView.bannerHeights.keys {
            let key = "banner_apiParam_" + bannerID
            if let value = UserDefaults.standard.string(forKey: key) {
                banner = value
            }
        }
        if(banner == nil){ banner = "" }
        banner! += NewsViewController.get_vParams()
        
        var superSlider: String?
        if(!self.superSliderStr.isEmpty){
            superSlider = self.superSliderStr
        }
        
        var bStatus = self.biasSliders.status
        var stanceValue = "0"
        if(self.biasSliders.stanceValues().0){ stanceValue = "1" }
        else if(self.biasSliders.stanceValues().1){ stanceValue = "2" }
        bStatus = String(bStatus.prefix(2)) + stanceValue + String(bStatus.suffix(1))
        bStatus = bStatus.replacingOccurrences(of: "SL", with: "SS")
        
        NewsViewController.biasStatusForCookie = bStatus
        let link = API_CALL(topicCode: T, abs: ABS,
                            biasStatus: bStatus,
                            banners: banner, superSliders: superSlider)
        return link
    }

    func buildApiCall_222(topicForCall: String? = nil, zeroItems: Bool = false) -> String {
    
        var firsthalf = self.homelink
        if(topicForCall != nil) {
            firsthalf += topicForCall!
        } else {
            firsthalf += self.topic
        }
        if(zeroItems) {
            firsthalf += ".A0.B0.S0"
        } else {
            firsthalf += ".A\(self.param_A)" +
                        ".B\(self.param_B)" +
                        ".S\(self.param_S)"
        }
        var nexthalf = self.sliderValues.getBiasPrefs() + createTopicPrefs() + self.biasSliders.status
        
        for bannerID in BannerView.bannerHeights.keys {
            let key = "banner_apiParam_" + bannerID
            if let value = UserDefaults.standard.string(forKey: key) {
                nexthalf += value
            }
        }
        
        var link: String
        if (self.superSliderStr.isEmpty) {
            link = firsthalf + nexthalf
        } else {
            link = firsthalf + nexthalf + "_" + self.superSliderStr
        }
        
        link += "&uid=3"
        if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
            var fixedID = deviceId.uppercased()
            fixedID = fixedID.replacingOccurrences(of: "-", with: "")
            fixedID = fixedID.replacingOccurrences(of: "A", with: "0")
            fixedID = fixedID.replacingOccurrences(of: "B", with: "1")
            fixedID = fixedID.replacingOccurrences(of: "C", with: "2")
            fixedID = fixedID.replacingOccurrences(of: "D", with: "3")
            fixedID = fixedID.replacingOccurrences(of: "E", with: "4")
            fixedID = fixedID.replacingOccurrences(of: "F", with: "5")
            
            link += fixedID //deviceId
        }
        
        link += "&v=I" + Bundle.main.releaseVersionNumber!
        link += "&dev=" + UIDevice.current.modelName.replacingOccurrences(of: " ",
                                    with: "_")

        return link
    }
    
    func reload() {
        // reload?
        print("GATO7 - reload")
        self.collectionView.reloadData()
        /*
        if(self.collectionView.numberOfSections>0) {
            print("GATO7 - reload section 0")
            self.collectionView.reloadSections([0])
            self.collectionView.setNeedsDisplay()
        }
        */
        
        self.hierarchy = ""
        self.hierarchy = newsParser.getHierarchy()
    }
    
    // For NewsDelegate protocol
    func didFinishLoadData(finished: Bool) {
        if BannerInfo.shared != nil {
            if(self.uniqueID==1 && BannerInfo.shared?.delegate==nil) {
                print("######### DELEGATE SET!")
                BannerInfo.shared?.delegate = self
            }
        }
        
        guard finished else {
            print("Could not load data")
            return
        }
        
        self.resetTopicSliders()
        
        updateTopicSliders()
        reload()

        self.moreHeadLines.setTopics(self.newsParser.getAllTopics())
        
        //self.addParamsLabel()
        self.updateDivider()
        
        NotificationCenter.default.post(name: NOTIFICATION_FOR_ONBOARDING_NEWS_LOADED, object: nil)
        
        if(self.scrollToTopOnLoad) {
            UIView.animate(withDuration: 0.5, animations: {
                self.collectionView.contentOffset.y = 0
                
                if(MorePrefsViewController.showStories() && self.mustSplit() && self.scrollAfterEnableSplit) {
                    UIView.animate(withDuration: 0.5, animations: {
                        var offset_y: CGFloat = 100
                        let count = self.newsParser.getArticleCountInSection(section: 0)
                        for i in 0...count {
                            if let _story = self.newsParser.getStory(index: i) {
                                offset_y += CGFloat(STORIES_HEIGHT())
                            } else {
                                break
                            }
                        }
            
                        offset_y -= 45
                        self.collectionView.contentOffset.y = offset_y
                    })
                }
            })
        }
        self.scrollToTopOnLoad = true
        
        if(enableSplitSharingAfterLoading) {
            self.enableSplitSharingAfterLoading = false
            DELAY(0.5) {
                self.startSplitSharingWorkflow()
            }
            
        }
        
        DELAY(2.0) {
            self.scrollAfterEnableSplit = true
        }
    }
    
    func resendRequest() {
        loadArticles()
    }
    
    
    // MARK: - UI
    func setUpActivityIndicator() {
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
    
        /*
        self.activityIndicator = UIActivityIndicatorView(style: .medium)
        
        self.activityIndicator.frame = CGRect(x: (UIScreen.main.bounds.width-20)/2,
                                            y: (UIScreen.main.bounds.height-20)/2,
                                            width: 20, height: 20)
        
        self.view.addSubview(activityIndicator)
        */
        
        self.view.addSubview(self.loadingView)
    }
    
    @objc private func setUpNavBar() {
        /*
        print("GATO999", self.uniqueID)
        
        DispatchQueue.main.async {
            if(APP_CFG_SHOW_MARKUPS && self.uniqueID==1) {
                self.setUpNavBar_new()
            } else {
                self.setUpNavBar_old()
            }
        }
        */
        
        DispatchQueue.main.async {
            SETUP_NAVBAR(viewController: self,
                homeTap: #selector(self.homeButtonTapped),
                menuTap: #selector(self.hamburgerButtonItemClicked(_:)),
                searchTap: #selector(self.searchItemClicked(_:)),
                userTap: #selector(self.userButtonItemClicked(_:)))
        }
    }
    
    private func bellIcon_A() -> UIBarButtonItem {
        let iconsMargin: CGFloat = 45.0
    
        let image = UIImage(systemName: "bell")
        let button = UIBarButtonItem(image: image, style: .plain,
            target: self, action: #selector(bellButtonTap(_:)) )
        button.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: iconsMargin)
        
        return button
    }
    
    private func bellIcon_B() { //-> UIBarButtonItem {
        /*
        
        */
        
        
        let bellInnerButton = UIButton(type: .custom)
        //bellInnerButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        //bellInnerButton.backgroundColor = .green
        bellInnerButton.setImage(UIImage(systemName: "bell"), for: .normal)
        //bellInnerButton.setBackgroundImage(UIImage(systemName: "bell"), for: .normal)
        
        //print( bellInnerButton.contentEdgeInsets )
        
        bellInnerButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 22,
                                            bottom: 0, right: 0)
        let bellButton = UIBarButtonItem(customView: bellInnerButton)
        bellButton.style = .plain
        //bellButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: iconsMargin)
        
        /*
        let bellImage = UIImageView(image: UIImage(systemName: "bell"))
        bellImage.backgroundColor = accentOrange
        //bellImage.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let bellButton = UIBarButtonItem(customView: bellImage)
        bellButton.style = .plain
        */
        
        //bellButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: iconsMargin)
        
    
        /*
        let badgeView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        badgeView.backgroundColor = accentOrange
        bellButton.customView = badgeView
        */
    }

    let badgeView = UIView(frame: .zero)
    private func addBadge() {
    
        if(self.badgeView.superview == nil) {
            var valX: CGFloat = 65.0
            let elementsSizeSum: CGFloat = (44*4)+195+(5*2)
            if(APP_CFG_SHOW_MARKUPS && self.uniqueID==1) {
                if(elementsSizeSum < UIScreen.main.bounds.width) {
                    valX += 8
                }
            }
        
            self.badgeView.frame = CGRect(x: valX, y: 6, width: 15, height: 15)
            self.badgeView.layer.cornerRadius = 7.5
            self.badgeView.backgroundColor = accentOrange
            
            //self.view.addSubview(self.badgeView)
            self.navigationController?.navigationBar.addSubview(self.badgeView)
            //let aaa = self.navigationItem.leftBarButtonItems![0]
            //aaa.customView?.addSubview(self.badgeView)
        }
    
        self.badgeView.subviews.forEach({ $0.removeFromSuperview() })
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.text = "10"
        self.badgeView.addSubview(label)
        
        self.badgeView.isHidden = true
        if(MarkupUser.shared.userInfo != nil && self.uniqueID==1) {
            var count = MarkupUser.shared.userInfo!.notifications
            if(count>99){ count=99 }
        
            //if(count>0) {
                self.badgeView.isHidden = false
                label.text = String(count)
            //}
        }
    }
    
    func setUpRefresh() {
        // set up pull ro refresh at top
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = .lightGray
        self.refresher.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
    }
    
    override func viewDidLayoutSubviews() {
        if let nav = self.navigationController {
            self.navBarFrame = nav.navigationBar.frame
            var posY = self.navBarFrame.origin.y + self.navBarFrame.size.height
            if(!nav.navigationBar.isTranslucent) {
                posY = 0
            }
            self.moreHeadLines.moveTo(y: posY)
        }
    }
    
    // MARK: - UI events/actions
    @objc func refresh(_ sender: UIRefreshControl!) {
        self.refresher.beginRefreshing()
        self.firstTime = true
        self.loadData()
    }
    
    @objc func homeButtonTapped() {
        if(self.onBoard == nil) {
//        if let firstVC = navigationController?.viewControllers.first as? NewsViewController {
////            self.firstTime = true
////            self.loadData()
//            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//        } else {
//
//        }

        navigationController?.popToRootViewController(animated: true)
        let firstIndexPath = IndexPath(row: 0, section: 0)

        if let _vc = navigationController?.viewControllers.first as? NewsViewController {
            if(self == _vc){
                _vc.collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: true)
            } else {
                DELAY(0.2) {
                    _vc.collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: true)
                }
            }
        }
    }}
    
    @objc func searchItemClicked(_ sender:UIBarButtonItem!) {
        let searchvc = SearchViewController()
        navigationController?.pushViewController(searchvc, animated: true)
    }
    
    @objc func userButtonItemClicked(_ sender: UIBarButtonItem!) {
        let vc = AppUser.shared.accountViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func hamburgerButtonItemClicked(_ sender: UIBarButtonItem!) {
        navigationController?.customPushViewController(SectionsViewController())
    }
    
    // MARK: - misc
    @objc func showSlidersInfo() {
        let sliders = SliderDoc()
        self.present(sliders, animated: true, completion: nil)
    }
    @objc func reloadOtherInstances(notification: NSNotification) {
        if let fromID = notification.userInfo?["id"] as? Int {
            if(fromID != self.uniqueID) {
                self.firstTime = true
                //self.reload()
            }
        }
    }
    
    @objc func refreshNews() {
        self.viewWillAppear(false)
    }
    
    @objc func reloadAll() {
        self.firstTime = true
        self.scrollAfterEnableSplit = false
        self.loadData()
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    private func setFlag(imageView: UIImageView, ID: String) {
        let img = UIImage(named: "\(ID.uppercased())64.png")
        
        imageView.backgroundColor = DARKMODE() ? bgBlue : bgWhite_LIGHT
        if(img != nil) {
            imageView.image = img
        } else {
            imageView.image = UIImage(named: "noFlag.png")
        }
    }
    
    func updateTopicSliders() { //!!!
        /*
        sliderValues.setSubtopics(subtopics: newsParser.getAllTopics())
        sliderValues.setPopularities(popularities: newsParser.getPopularities())
        
        topicSliders.loadVariables()
        topicSliders.buildViews()
        */
    }

    
}

extension NewsViewController: TopicSelectorDelegate {
    
    // MARK: - TopicSelectorDelegate Delegate
    func pushNewTopic(newTopic: String) {
        print("GATO - ", newTopic)
        let vc = NewsViewController(topic: newTopic)
        
        // PARAM (A) // --------------------------------
        vc.param_A = 4
        if(newTopic==self.topic && Utils.shared.didTapOnMoreLink) {
            vc.param_A = 10
        }
        Utils.shared.didTapOnMoreLink = false
        
        var topicName = ""
        for (key, value) in Globals.topicmapping {
            if(value == newTopic) {
                topicName = key
            }
        }
        
        var subTopicCount = -1
        if(!topicName.isEmpty) {
            subTopicCount = newsParser.getSubTopicCountFor(topic: topicName)
        }
        if(subTopicCount == 0) {
            vc.param_A = 40 // no tiene sub-topics
        }
        
        // PARAM (S) // --------------------------------
        vc.param_S = 0
        for _vc in self.navigationController!.viewControllers {
            vc.param_S += GET_COUNT_FOR(topic: newTopic, in: _vc)
        }
        
        /*
        for _vc in self.navigationController!.viewControllers {
            let topicAndCount = GET_TOPICARTICLESCOUNT(from: _vc)
            if(topicAndCount.0 == newTopic) {
                vc.param_S += topicAndCount.1
            }
        }
        */
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func changeTopic(newTopic: String) {
        self.topic = newTopic
        sliderValues.clearSubtopics()
        sliderValues.setTopic(topic: newTopic)
        print("topic should be changed to \(self.topic)")
        self.loadArticles()
        self.reload()
    }
    
    func goToScrollView(atSection: Int) {
        self.scrollTheNewsTo(atSection)
    }
    
    func horizontalScroll(to: CGFloat) {
        var mOffset = self.moreHeadLines.scrollView.contentOffset
        mOffset.x = to
        self.moreHeadLines.scrollView.setContentOffset(mOffset, animated: false)
    }
}


extension NewsViewController: BiasSliderDelegate, ShadeDelegate {
    
    // MARK: Bias sliders
    func configureBiasButton() {
        let factor: CGFloat = 0.9
        let size = CGSize(width: 78 * factor, height: 82 *  factor)
        let screenSize = UIScreen.main.bounds
        
        view.addSubview(biasButton)
        let posX = screenSize.width - size.width - 5
        
        var posY = screenSize.height - size.height
        if let nav = navigationController {
            if(!nav.navigationBar.isTranslucent) {
                posY -= 88
            }
        }
        
        
        
        
        //print( "ZOOM", isZoomed() )
        
        /*
        if(isZoomed()) {
            posY += size.height - self.biasSliders.state01_height - 15
        } else {
            posY += size.height - self.biasSliders.state01_height + 15
        }
        */
        
        
        //posY += size.height - //self.biasSliders.state01_height // + 15
        
        //posY
        
        /*
        posY += size.height
        let margin: CGFloat = 6
        posY -= self.biasSliders.state01_height - margin
        */
        
        
        posY = 50
        
        biasButton.frame = CGRect(x: posX, y: posY,
                                width: size.width, height: size.height)
        //biasButton.layer.cornerRadius = size * 0.5
        let y = view.frame.height - self.biasSliders.state01_height
        biasSliders.frame = CGRect(x: 0, y: y, width: view.frame.width, height: 550) //470
        
        biasSliders.buildViews()
        self.biasSliders.status = "SL00"
        self.updateBiasButtonPosition()
        
        
        /*
        let subDim: CGFloat = 30.0
        let subButton = UIButton(type: .system)
        subButton.backgroundColor = .green
        subButton.frame = CGRect(x: 0, y: 0, width: subDim, height: subDim)
        subButton.addTarget(self, action: #selector(subButtonOnTap(sender:)), for: .touchUpInside)
        
        self.biasButton.clipsToBounds = false
        self.biasButton.addSubview(subButton)
        */
        //showBiasSliders
        
        /*
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showBiasSliders(gesture: )))
        self.biasButton.addGestureRecognizer(tapGesture)
        */
        
        
        
        let longPressGesture = UILongPressGestureRecognizer(target: self,
            action: #selector(biasButtonOnLongPress(gesture:)))
        self.biasButton.addGestureRecognizer(longPressGesture)
    }
    @objc func subButtonOnTap(sender: UIButton) {
        print(">>>>>>>")
    }
    
    func updateBiasButtonPosition() {
        var mFrame = self.biasButton.frame
        let screenSize = UIScreen.main.bounds
        
        
        let posX = screenSize.width - mFrame.size.width - 5
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
        if(status == "SL00") {
            posY -= (mFrame.size.height * 1.75)
        } else if(status == "SL01") {
            posY -= self.biasSliders.state01_height - margin
        } else if(status == "SL02") {
            posY -= self.biasSliders.state02_height - margin
        }
        */
        
        if(status == "SL02") {
            posY -= self.biasSliders.state02_height + 110
        } else if(status == "SL01") {
            posY -= self.biasSliders.state01_height + 85
            if(SAFE_AREA()!.bottom>0) { posY -= 25 }
        } else {
            posY -= self.biasSliders.state01_height - 20
        }
        //posY -= margin
        
        mFrame.origin.y = posY
        mFrame.origin.x = posX
        self.biasButton.frame = mFrame
        
        self.biasMiniButtonUpdatePosition()
        self.biasMiniButton.superview?.bringSubviewToFront(self.biasMiniButton)
    }
    
    func configureBiasSliders() {
        
        let y = view.frame.height - self.biasSliders.state01_height
        biasSliders.addShowMore()
        biasSliders.backgroundColor = accentOrange
        
        shadeView.backgroundColor = UIColor.black.withAlphaComponent(0)
        //UIColor(white: 0, alpha: 0.75) // 0.3
        /*
        shadeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        shadeView.isUserInteractionEnabled = true
        */
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
                self.biasMiniButtonUpdatePosition()
                
                /*
                self.biasSliders.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.biasSliders.frame.height)
                */
                
            }, completion: nil)
        
        self.biasButton.superview?.bringSubviewToFront(self.biasButton)
        self.biasMiniButton.superview?.bringSubviewToFront(self.biasMiniButton)
    }
    
    // For ShadeDelegate protocol
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
    
    /*
    @objc func handleDismiss() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.shadeView.alpha = 0
            
        }, completion: nil)
        biasSliders.handleDismiss()
    }
    */
    
    
    @objc func showBiasSliders(_ sender:UIButton!) {
    //@objc func showBiasSliders(gesture: TapGesture)
        // orange button click
        HAPTIC_CLICK()
        
        if(self.biasButtonState==1){
            if !Globals.isSliderOn {
                Globals.isSliderOn = true
            }
            
            if(self.biasSliders.status == "SL00") {
                configureBiasSliders()
                print("BIAS view")
            } else {
                self.biasSliders.handleDismiss()
            }
        } else {
            if(self.biasSliders.status == "SL00") {
                //configureBiasSliders()
                //print("BIAS view")
                //DELAY(0.25) {
                    self.startSplitSharingWorkflow()
                //}
            } else {
                self.startSplitSharingWorkflow()
            }
            
        }
    }
    
    // For BiasSliderDelegate protocol
    func biasSliderDidChange(sliderId: Int) {
    
        let dict = ["id": self.uniqueID]
        NotificationCenter.default.post(name: NOTIFICATION_RELOAD_NEWS_IN_OTHER_INSTANCES,
                                        object: nil,
                                        userInfo: dict)
        
        //biasSliders.activityView.startAnimating()
        biasSliders.showLoading(true)
        
        DispatchQueue.main.async {
            self.scrollToTopOnLoad = false
            self.loadArticles()
            self.reload()

            DELAY(2.0) {
                if(sliderId == self.biasSliders.latestBiasSliderUsed) {
                    self.biasSliders.showLoading(false)
                }
            }
        }
    }
}

//// MARK: Pie chart
//extension NewsViewController: PieChartViewControllerDelegate {
//
//    func showPieChart() {
//        //self.pieChartVC.modalPresentationStyle = .fullScreen
//        if(!self.pieChartVC.isBeingPresented) {
//            self.pieChartVC.set(topics: newsParser.getAllTopics(),
//                        popularities: newsParser.getGlobalPopularities())
//                        //popularities: newsParser.getPopularities())
//
//            self.present(self.pieChartVC, animated: true) {
//            }
//        }
//    }
//
//    // For protocol PieChartViewControllerDelegate
//    func someValueDidChange() {
//        self.firstTime = true
//        self.loadData()
//    }
//}


// MARK: Topic sliders
extension NewsViewController: TopicSliderDelegate, dismissTopicSlidersDelegate {
    
    func showTopicSliders() {
        // Tap on a pie chart button
//        self.showPieChart()
    }
    
    func showTopicSliders2() {
        
        topicSliders.mustSort = true
        //updateTopicSliders()
        
        // SHOWS TOPIC SLIDERS
        topicSliders.loadVariables()
        topicSliders.buildViews()
        
        topicSliders.backgroundColor = accentOrange
        view.addSubview(topicSliders)
        
        topicTopAnchorHidden?.isActive = false
        topicTopAnchorVisible?.isActive = true
        topicBottomAnchor?.isActive = true
        
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    func handleDismissTopicSliders() {
    
        topicTopAnchorVisible?.isActive = false
        topicBottomAnchor?.isActive = false
        topicTopAnchorHidden?.isActive = true
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        //self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        self.collectionView.scrollRectToVisible(CGRect.zero, animated: false)
    }
    
    func topicSliderDidChange() {
        loadArticles()
        reload()
    }
    
    func resetTopicSliders() {
        /*
        topicSliders = TopicSliderPopup()
        
        topicSliders.dismissDelegate = self
        topicSliders.sliderDelegate = self
        
        topicTopAnchorHidden = topicSliders.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        topicTopAnchorVisible = topicSliders.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        topicBottomAnchor = topicSliders.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        configureTopicButton()
        */
    }
    
    func configureTopicButton() {   //!!!
        view.addSubview(topicSliders)
        topicSliders.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topicTopAnchorHidden!,
            topicSliders.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topicSliders.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        topicSliders.buildViews()
    }
}

// MARK: Super slider
extension NewsViewController: SuperSliderDelegate {
    
    func updateSuperSliderStr(topic: String, popularity: Float) {
    
        let key = Globals.slidercodes[topic]!
        let value = String(format: "%02d", Int(popularity))
        
        if (superSliderStr.contains(key)) {
            var start = 0
            var txt = ""
            
            while(start<superSliderStr.count) {
                let endForKey = start + 1
                let thisKey = superSliderStr[start...endForKey]
                let thisValue = superSliderStr[start+2...endForKey+2]
                
                txt += thisKey
                if(thisKey == key) {
                    txt += value
                } else {
                    txt += thisValue
                }
                start += 4
            }
            superSliderStr = txt
        } else {
            superSliderStr += key + String(format: "%02d", Int(popularity))
        }
        
        //print("GATO", superSliderStr)
    }
    
    func superSliderDidChange() {
        /*
        let diff = Date() - self.superSliderLatestUpdate
        if(diff > 2) {
            self.superSliderLatestUpdate = Date()
            
            activityIndicator.startAnimating()
            //DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            DispatchQueue.main.async {
                self.loadArticles()
                self.reload()
                
                DELAY(2) {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        */
        
        self.loadingView.isHidden = false
        DispatchQueue.main.async {
            self.loadArticles()
            // self.reload()
            
            DELAY(2) {
                self.loadingView.isHidden = true
            }
        }
        
    }
}

extension NewsViewController: shareDelegate {
    
    func openSharing(items: [String]) {
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if(IS_iPAD()) {
            let offsetMax = self.collectionView.contentSize.height - self.collectionView.frame.size.height
            let diff = offsetMax - self.collectionView.contentOffset.y
            
            ac.popoverPresentationController?.sourceView = self.view
            ac.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX,
                y: self.view.bounds.height - 100 + diff, width: 0, height: 0)
        }
        
        present(ac, animated: true)
    }

}

extension NewsViewController: BannerInfoDelegate {

    func BannerInfoOnClose() {
        //self.reload()
        
        //self.firstTime = true
        //self.loadData()
        
        DispatchQueue.main.async {
            self.loadArticles()
            self.reload()
            self.updateTopicSliders()
            if Globals.isSliderOn {
                self.configureBiasSliders()
            }
            
            DELAY(0.5) {
                self.loadingView.isHidden = true
                self.firstTime = false
                self.collectionView.reloadData()
                self.stopRefresher()
                
                self.collectionView.setNeedsDisplay()
                self.collectionView.setNeedsLayout()
            }
        }
    }
}

extension NewsViewController {

    // StoryCollectionViewCell - Story cell
    func storyCell(indexPath: IndexPath, index: Int, showHeaders: Bool) -> StoryCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.cellId, for: indexPath) as! StoryCollectionViewCell
        
        if(showHeaders) {
            cell.showHeaders(biasSliders.stanceValues())
        } else {
            cell.hideHeaders()
        }
        
        if let _story = self.newsParser.getStory(index: index) {
            cell.setupViews(sources: _story.sources)
        }
        
        cell.updated.text = "Last updated " + newsParser.getDate(index: index)
        cell.titleLabel.text = self.newsParser.getTitle(index: index)
        
        let imageURL = newsParser.getIMG(index: index)
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                cell.imageView.contentMode = .scaleAspectFill
                cell.imageView.sd_setImage(with: URL(string: imageURL), placeholderImage: nil)
            }
        }
        
        cell.updateLayoutDetails()
        
        return cell
    }

    // MARK: - HeadlineCell (4 items on top)
    func newsItemFor(indexPath: IndexPath, index: Int) -> HeadlineCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeadlineCell.cellId, for: indexPath) as! HeadlineCell
              
            var side = 0
                
            var startIndex = 0
            for n in 0..<indexPath.section {
                startIndex += newsParser.getArticleCountInSection(section: n)
            }
            for i in startIndex...index {
                if self.newsParser.getStory(index: i)==nil {
                    side += 1
                    if(side>2){ side = 1 }
                }
            }
            
            cell.setupViews(split: self.mustSplit(), side: side, section: indexPath.section)
                
            cell.headline.text = newsParser.getTitle(index: index)
            cell.pubDate.text = newsParser.getDate(index: index)
            let imageURL = newsParser.getIMG(index: index)
            //let imgURL = URL(string: imageURL)!
            DispatchQueue.global().async {
                //guard let data = try? Data(contentsOf: imgURL) else { return }
                DispatchQueue.main.async {
                    //print("loading cell images")
//                        let img = UIImage(data: data)
//                        let width = self.view.frame.width - 40
//                        let rescaled = img?.scalePreservingAspectRatio(targetSize: CGSize(width: width, height: width * 7 / 12))
                    cell.imageView.contentMode = .scaleAspectFill
                    cell.imageView.sd_setImage(with: URL(string: imageURL), placeholderImage: nil)
//                        cell.imageView.image = rescaled
                }
            }
            
            cell.source.lineBreakMode = .byWordWrapping
            cell.source.text = newsParser.getSource(index: index) + " - " + newsParser.getDate(index: index)
            cell.source.numberOfLines = 2
            //cell.source.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
            cell.pubDate.text = " "
            
            var showMarkup = false
            for M in newsParser.getMarkups(index: index) {
                let type = M.type.lowercased()
                if(!type.contains("prediction")){ showMarkup = true }
            }
            cell.markupView.isHidden = !showMarkup
            
            /*
            if newsParser.getMarkups(index: index).count > 0 {
                cell.markupView.isHidden = false
            }
            */
            
            
            //cell.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            cell.miniSlidersView?.setValues(val1: newsParser.getLR(index: index),
                                            val2: newsParser.getPE(index: index),
                                            source: newsParser.getSource(index: index),
                                            countryID: newsParser.getCountryID(index: index))
             
            cell.miniSlidersView?.viewController = self
            self.setFlag(imageView: cell.flag, ID: newsParser.getCountryID(index: index))
        
            /*
            if(cell.frame.height == CGFloat(self.storyHeight)) {
                cell.backgroundColor = .green
            } else {
                cell.backgroundColor = .red
            }
            */
        
            /*
            if(self.newsParser.getStory(index: index) == nil) {
                cell.contentView.backgroundColor = .red
            } else {
                cell.backgroundColor = .black
            }
            */
        
            
            //cell.contentView.backgroundColor = .green
            //print( ">> HEIGHT", cell.frame.size.height )
            
            return cell
    }
    



    // MARK: - Collection view (data source + layout)
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var start = 0
        for n in 0..<indexPath.section {
            start += newsParser.getArticleCountInSection(section: n)
        }
        let index = indexPath.row + start
        
        if(index < newsParser.getLength()) {
            
            if(self.newsParser.getStory(index: index) != nil ) {
                var showHeadersAtBottom = false
                if(mustSplit()) {
                    if(self.newsParser.getStory(index: index+1) == nil) {
                        showHeadersAtBottom = true
                    }
                }
                
                return self.storyCell(indexPath: indexPath, index: index, showHeaders: showHeadersAtBottom)
            } else {
                if(indexPath.section == 0) {
                    return self.newsItemFor(indexPath: indexPath, index: index)
                }
                else if (indexPath.row == 0 || indexPath.row == 1) {
                    return self.newsItemFor(indexPath: indexPath, index: index)
                }
                else { // 2 column cells
                    return self.newsItemFor(indexPath: indexPath, index: index)
                }
            }
            
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCell.cellId, for: indexPath) as! ArticleCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        // only one subtopic on page
        if newsParser.getNumOfSections() == 1 && section == 1 {
            return .zero
        }
        
        // default
        //return .init(width: view.frame.width, height: 120)
        //return .init(width: view.frame.width, height: 75)
        
        // SubtopicHeader
        var h: CGFloat = 120
        if(mustSplit()){
            if(!MorePrefsViewController.showStories()) {
                h += 45
            }
        }
        /*
        let iPath = IndexPath(item: 0, section: section)
        let cell = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: iPath) as! SubtopicHeader
        */
        
        let kind = UICollectionView.elementKindSectionHeader
        let iPath = IndexPath(row: 0, section: section)
        
        if( self.mustSplit() ) {
            if let header = self.collectionView(self.collectionView,
                            viewForSupplementaryElementOfKind: kind,
                            at: iPath) as? SubtopicHeaderForSplit {
                
                if(header.hierarchy.text == "  " && self.uniqueID==1) {
                    h -= 20
                }
                
                //if(header.prioritySlider.isHidden) {
                    h -= 29
                //}
                
                
                // % label tmp removed !!!
                h -= 20
                
                if(section>0) {
                    h -= 20
                }
            }
        }
        else {
            if let header = self.collectionView(self.collectionView,
                            viewForSupplementaryElementOfKind: kind,
                            at: iPath) as? SubtopicHeader {
                
                if(header.hierarchy.text == "  " && self.uniqueID==1) {
                    h -= 20
                }
                
                //if(header.prioritySlider.isHidden) {
                    h -= 29
                //}
                
                
                // % label tmp removed !!!
                h -= 20
                
                if(section>0) {
                    h -= 20
                }
            }
        }
        
        print("HEADER HEIGHT: ", h)
        
        return CGSize(width: view.frame.width, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if section == self.collectionView.numberOfSections - 1 {
            // last one
            /*
            let subTopicsCount = newsParser.getNumOfSections()
            if(subTopicsCount==1) {
                return CGSize(width: view.frame.width, height: 260)
            } else {
                
            }*/
            
            // more link + about ITN
            return CGSize(width: UIScreen.main.bounds.width, height: 260)
        }
        else {
            if section == 0 {
                let subTopicsCount = newsParser.getNumOfSections()
                if(subTopicsCount==1) {
                    if(self.param_A==40) {
                        return CGSize.zero
                    } else {
                        return CGSize(width: 0, height: 60)
                    }
                } else {
                    // SEE MORE + horizontal menu
                    var h: CGFloat = 80 + 55 - 20
                    if let bannerInfo = BannerInfo.shared {
                        //let count = self.navigationController!.viewControllers.count
                        if(bannerInfo.active && self.uniqueID==1) {
                            h += BannerView.getHeightForBannerCode(bannerInfo.adCode)
                        }
                    }
                    return CGSize(width: 0, height: h)
                }
            } else {
                // standard SEE MORE
                return CGSize(width: 0, height: 70) // 80
            }
        
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        print("SIZING", UIScreen.main.bounds.width)
        
        
        // one topic on page
        if newsParser.getNumOfSections() == 1 && indexPath.section == 1 {
            return .zero
        }
        
        let cellsPerRow = 2
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            //+ (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))

        
    
        // added for stories
        var isStory = false
        var start = 0
        for n in 0..<indexPath.section {
            start += newsParser.getArticleCountInSection(section: n)
        }
        let index = indexPath.row + start
        if index < newsParser.getLength() {
            if let _story = self.newsParser.getStory(index: index) {
                isStory = true
            }
        }
        
        if(!isStory) {
            let W = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))
            return CGSize(width: W, height: ARTICLE_CELL_HEIGHT())
        } else {
            let W = Int(collectionView.bounds.width)
            var H = STORIES_HEIGHT()
            if(self.newsParser.getStory(index: index+1)==nil && mustSplit()) {
                H += 45
            }
            
            return CGSize(width: W, height: H)
        }
        
        
        /*
        if (indexPath.section == 0) {
            // 4 items for the main Topic
            let cellsPerRow = 2
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

            let totalSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                //+ (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))

            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))

            //let w: CGFloat = (UIScreen.main.bounds.width)/2
            return CGSize(width: size, height: 240)
        }
        else if indexPath.row == 0 || indexPath.row == 1 {
            // big articles with img at left/right
            return .init(width: view.frame.width, height: 160) //200
        } else {
            // 2 items at the bottom of the OTHER topics
            let cellsPerRow = 2
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

            let totalSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                //+ (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))

            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))

            return CGSize(width: size, height: 220) //250
        }
        */
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        /*
        if(section==0) { return 0 }
        else { return 10 }
        */
        
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        /*
        if(section==0){ return 0 }
        else { return 10 } */
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        /*
        var top: CGFloat = 20
        if(section==0) { top = 0 }
        */
        
        return .init(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    
    
   override func numberOfSections(in collectionView: UICollectionView) -> Int {
        var value = 0
        sliderValues.setSectionCount(num: newsParser.getNumOfSections())
        if newsParser.getNumOfSections() == 1 {
            value = 2
        } else {
            value = newsParser.getNumOfSections()
        }
        
        print("### numSections", value)
        return value
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var value = 0
        if newsParser.getNumOfSections() == 1 && section == 1 {
            print("here")
            value = 0
        } else if section >= newsParser.getArticleCountInSection().count {
            print("Oops! loaded too fast")
            print("We only have ", newsParser.getNumOfSections(), " sections")
            value = 0 //newsParser.getArticleCountInSection()[newsParser.getArticleCountInSection().count-1]
        } else {
            value =  newsParser.getArticleCountInSection()[section]
        }
        
        print("### numItems", value)
        return value
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var start = 0
        for n in 0..<indexPath.section {
            start += newsParser.getArticleCountInSection(section: n)
        }
        let index = start + indexPath.row
        
        var link = newsParser.getURL(index: index)
        /*
        if newsParser.getAMPStatus(index: index) == true {
            //link = newsParser.getAMPURL(index: index)
            link = newsParser.getURL(index: index)
        } else {
            link = newsParser.getURL(index: index)
        }
        */
        
        let title = newsParser.getTitle(index: index)
        let markups = newsParser.getMarkups(index: index)
        //let markups = [ Markups(type: "T", description: "abc", link: "http://www.google.com") ]
       
        
        if(self.newsParser.getStory(index: index) == nil ) {
            // regular item
            let vc = WebViewController(url: link, title: title, annotations: markups)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            // story
//            let vc = PlainWebViewController(url: link, title: title)
//            navigationController?.pushViewController(vc, animated: true)

            print( UIScreen.main.bounds.size )

            if(IS_iPAD()) {
                let vc = StoryContentIPADViewController.createInstance()
                vc.link = link
                vc.api_call = self.buildApiCall()
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = StoryContentViewController.createInstance()
                vc.link = link
                vc.api_call = self.buildApiCall()
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
        
        
        /*
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        config.barCollapsingEnabled = false
        
        let url = URL(string: link)!
        let safariVC = SFSafariViewController(url: url, configuration: config)
        safariVC.modalPresentationStyle = .fullScreen
        self.present(safariVC, animated: true, completion: nil)
        */
        
        //navigationController?.pushViewController(safariVC, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
            case UICollectionView.elementKindSectionHeader:
                let kind = UICollectionView.elementKindSectionHeader
                
                if( mustSplit() ) {
                    let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SubtopicHeaderForSplit.headerId, for: indexPath) as! SubtopicHeaderForSplit
                
                    sectionHeader.delegate = self
                    sectionHeader.ssDelegate = self
                    sectionHeader.topicDelegate = self
                    sectionHeader.tag = indexPath.section
                    sectionHeader.configure(biasSliders.stanceValues())
                    
                    
                    let subTopic = newsParser.getTopic(index: indexPath.section)
                    sectionHeader.setHeaderText(subtopic: subTopic)
                    
                    sectionHeader.topicSlidersButton.isHidden = false
                    sectionHeader.prioritySlider.isHidden = false
                    
                    
                    var globalPopularity: Float = 0
                    if(newsParser.getGlobalPopularities().count==0) {
                        globalPopularity = 0
                    } else if(indexPath.section<0 || indexPath.section>=self.newsParser.getGlobalPopularities().count) {
                        globalPopularity = 0
                    } else {
                        globalPopularity = newsParser.getGlobalPopularities()[indexPath.section]
                    }
                    sectionHeader.updateSuperSlider(num: globalPopularity)
                    
                    if indexPath.section == 0 {
                        sectionHeader.label.titleLabel?.font = UIFont(name: "PTSerif-Bold", size: 40)
                    } else {
                        sectionHeader.label.titleLabel?.font = UIFont(name: "PTSerif-Bold", size: 30)
                    }
                                    
                    // no super sliders on main page
                    if self.topic == "news" {
                        sectionHeader.prioritySlider.isHidden = true
                    }
                    
                    // no topic sliders on childless topics
                    if newsParser.getAllTopics().count == 1 {
                        sectionHeader.topicSlidersButton.isHidden = true
                    }
                    
                    var breadcrumbText = ""
                    if(indexPath.section==0 && (self.hierarchy == "Headlines>" || self.hierarchy == "") && self.uniqueID==1) {
                        breadcrumbText = "  "
                        sectionHeader.hierarchy.text = breadcrumbText
                    } else {
                        breadcrumbText = self.hierarchy + newsParser.getTopic(index: indexPath.section)
                        sectionHeader.hierarchy.adjustsFontSizeToFitWidth = true
                        hArray.append(breadcrumbText)
                        
                        let components = breadcrumbText.components(separatedBy: ">")
                        if(components.count > 1) {
                            let last = components.last!
                            breadcrumbText = breadcrumbText.replacingOccurrences(of: ">" + last, with: "")
                            hArray.append(breadcrumbText)
                        }
                        sectionHeader.hierarchy.text = breadcrumbText
                    }

                    sectionHeader.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
                    //sectionHeader.backgroundColor = UIColor.yellow.withAlphaComponent(0.4)
                    
                    return sectionHeader
                
                } else {
                    let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SubtopicHeader.headerId, for: indexPath) as! SubtopicHeader
                
                    sectionHeader.delegate = self
                    sectionHeader.ssDelegate = self
                    sectionHeader.topicDelegate = self
                    sectionHeader.tag = indexPath.section
                    sectionHeader.configure()
                    
                    let subTopic = newsParser.getTopic(index: indexPath.section)
                    sectionHeader.setHeaderText(subtopic: subTopic)
                    
                    sectionHeader.topicSlidersButton.isHidden = false
                    sectionHeader.prioritySlider.isHidden = false
                    
                    
                    var globalPopularity: Float = 0
                    if(newsParser.getGlobalPopularities().count==0) {
                        globalPopularity = 0
                    } else if(indexPath.section<0 || indexPath.section>=self.newsParser.getGlobalPopularities().count) {
                        globalPopularity = 0
                    } else {
                        globalPopularity = newsParser.getGlobalPopularities()[indexPath.section]
                    }
                    sectionHeader.updateSuperSlider(num: globalPopularity)
                    
                    if indexPath.section == 0 {
                        sectionHeader.label.titleLabel?.font = UIFont(name: "PTSerif-Bold", size: 40)
                    } else {
                        sectionHeader.label.titleLabel?.font = UIFont(name: "PTSerif-Bold", size: 30)
                    }
                                    
                    // no super sliders on main page
                    if self.topic == "news" {
                        sectionHeader.prioritySlider.isHidden = true
                    }
                    
                    // no topic sliders on childless topics
                    if newsParser.getAllTopics().count == 1 {
                        sectionHeader.topicSlidersButton.isHidden = true
                    }
                    
                    var breadcrumbText = ""
                    if(indexPath.section==0 && (self.hierarchy == "Headlines>" || self.hierarchy == "") && self.uniqueID==1) {
                        breadcrumbText = "  "
                        sectionHeader.hierarchy.text = breadcrumbText
                    } else {
                        breadcrumbText = self.hierarchy + newsParser.getTopic(index: indexPath.section)
                        sectionHeader.hierarchy.adjustsFontSizeToFitWidth = true
                        hArray.append(breadcrumbText)
                        
                        let components = breadcrumbText.components(separatedBy: ">")
                        if(components.count > 1) {
                            let last = components.last!
                            breadcrumbText = breadcrumbText.replacingOccurrences(of: ">" + last, with: "")
                            hArray.append(breadcrumbText)
                        }
                        sectionHeader.hierarchy.text = breadcrumbText
                    }

                    sectionHeader.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
                    //sectionHeader.backgroundColor = .green
                    return sectionHeader
                }
            
            case UICollectionView.elementKindSectionFooter:
                let kind = UICollectionView.elementKindSectionFooter
                
                if indexPath.section == self.collectionView.numberOfSections - 1 {
                    // last one
                    /*
                    let pageFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FAQFooter.footerId, for: indexPath) as! FAQFooter
                    pageFooter.shareDelegate = self
                    pageFooter.configure()
                    return pageFooter
                    */
                    let subTopicsCount = newsParser.getNumOfSections()
                    if(subTopicsCount==1) {
                        let pageFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FAQFooter.footerId, for: indexPath) as! FAQFooter
                        pageFooter.shareDelegate = self
                        pageFooter.configure()
                        
                        print("> FOOTER FAQFooter", indexPath.row)
                        
                        return pageFooter
                    } else {
                        let seeMore = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: seeMoreFooterLast.footerId, for: indexPath) as! seeMoreFooterLast
                        seeMore.delegate = self
                        seeMore.setFooterText(subtopic: newsParser.getTopic(index: indexPath.section))
                        seeMore.configure()
                        seeMore.configure2()
                        seeMore.shareDelegate = self
                        
                        print("> FOOTER seeMoreFooterLast", newsParser.getTopic(index: indexPath.section))
                        
                        print("ABOUT HEIGHT", seeMore.frame.size.height)
                        return seeMore
                    }
                } else if indexPath.section == 0 {
                    let subTopicsCount = newsParser.getNumOfSections()
                    if(subTopicsCount==1) {
                        let seeMore = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: seeMoreFooter.footerId, for: indexPath) as! seeMoreFooter
                        seeMore.delegate = self
                        // oMore
                        seeMore.setFooterText(subtopic: newsParser.getTopic(index: indexPath.section))
                        seeMore.configure()

                        print("> FOOTER seeMoreFooter", newsParser.getTopic(index: indexPath.section))
                        
                        return seeMore
                    } else {
                        let seeMore = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: seeMoreFooterSection0.footerId, for: indexPath) as! seeMoreFooterSection0
                    
                        seeMore.delegate = self
                        seeMore.topics = newsParser.getAllTopics()
                        // aMore
                        seeMore.setFooterText(subtopic: newsParser.getTopic(index: indexPath.section))
                        seeMore.configure()
                        
                        print("> FOOTER seeMoreFooterSection 000", newsParser.getTopic(index: indexPath.section))
                        
                        //let count = self.navigationController!.viewControllers.count
                        if(self.uniqueID==1 && BannerInfo.shared != nil){
                            seeMore.buildBanner()
                        }
                        
                        self.seeMoreFooterSection = seeMore
                        self.moreHeadLinesInCollectionPosY = seeMore.frame.origin.y
                        
                        var mOffset = self.moreHeadLines.scrollView.contentOffset
                        /*if(mOffset.x < 0){ mOffset.x = 0 }
                        else if(mOffset.x > self.moreHeadLines.scrollView.contentSize.width){
                            mOffset.x = self.moreHeadLines.scrollView.contentSize.width
                        }*/
                        seeMore.scrollView.contentOffset = mOffset
                        
                        //seeMore.backgroundColor = UIColor.green.withAlphaComponent(0.15)
                        
                        //print(">> FOOTER ABOUT", seeMore.frame.size.height)
                        return seeMore
                    }
                
                    
                } else {
                    // no FAQ footer unless last section
                    let seeMore = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: seeMoreFooter.footerId, for: indexPath) as! seeMoreFooter
                    seeMore.delegate = self
                    // oMore
                    seeMore.setFooterText(subtopic: newsParser.getTopic(index: indexPath.section))
                    seeMore.configure()
                    
                    //seeMore.backgroundColor = UIColor.green.withAlphaComponent(0.15)
                    print("> FOOTER seeMoreFooter BBB", newsParser.getTopic(index: indexPath.section))
                    
                    
                    //print(">> FOOTER HEIGHT", seeMore.frame.size.height)
                    return seeMore
                }
            
            default:
                print("Unidentified reusable view")
                fatalError()
        }
    }

}

extension NewsViewController: MoreHeadlinesViewDelegate {
    
    // MARK: - Horizontal menu
    private func itemsHeight(section: Int) -> CGFloat {
        var sum = 0
        
        var start = 0
        for n in 0..<section {
            start += newsParser.getArticleCountInSection(section: n)
        }
        var cols = 0
        let total = newsParser.getArticleCountInSection(section: section)
        for n in 0...total-1 {
            let index = n + start
            
            var height = 0
            if(self.newsParser.getStory(index: index) != nil) {
                height = STORIES_HEIGHT()
            } else {
                cols += 1
                if(cols == 2) {
                    cols = 0
                    height += ARTICLE_CELL_HEIGHT()
                }
                
                if(cols==1 && n==total-1) { // Last loop and just 1 col
                    height = ARTICLE_CELL_HEIGHT()
                }
            }

            sum += height
        }
        
        return CGFloat(sum)
    }
    
    func scrollTheNewsTo(_ index: Int) {
        //let indexPath = IndexPath(item: 0, section: 0)
        /*if let cell = self.collectionView.cellForItem(at: indexPath) {
            self.collectionView.scrollRectToVisible(cell.frame, animated: true)
        }
        */
        
        var offsetY: CGFloat = 0
        
        //var firstItemHeight: CGFloat = 51+(240*2)+8+115 // header + 2rows + margins + bigFooter(0)
        var firstItemHeight: CGFloat = 51+(self.itemsHeight(section: 0))+8+115 // header + 2rows + margins + bigFooter(0)
        if(mustSplit()) {
            // firstItemHeight = 96+(240*2)+8+115
            firstItemHeight = 96+(self.itemsHeight(section: 0))+8+115
        }

        if let info = BannerInfo.shared {
            //let count = self.navigationController!.viewControllers.count
            if(self.uniqueID==1 && info.active) {
                firstItemHeight += BannerView.getHeightForBannerCode(info.adCode)
            }
        }
        
        /*
        var otherItemsHeight: CGFloat = 51+(240*2)+8+70 // header + 2rows + margins + footer
        //let slidersHeight: CGFloat = 29
        if(mustSplit()) {
            otherItemsHeight = 96+(240*2)+8+70
        }
        */
        
        if(index>0) {
            offsetY += firstItemHeight

            for n in 1...index {
                if(n==index){ break }
            
                if(!mustSplit()) {
                    offsetY += 51+(self.itemsHeight(section: n))+8+70 // header + 2rows + margins + footer
                } else {
                    offsetY += 96+(self.itemsHeight(section: n))+8+70
                }
            }

            /*
            let i = CGFloat(index-1)
            offsetY += otherItemsHeight * i
            */
            
            offsetY += -40 // margin (for the horizontal menu fixed at top)
        }
        
        self.collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
    }

    // For MoreHeadlinesViewDelegate protocol
    func scrollFromHeadLines(toSection: Int) {
        self.scrollTheNewsTo(toSection)
    }
    
    func horizontalScrollFromHeadLines(to: CGFloat) {
        var mOffset = self.seeMoreFooterSection?.scrollView.contentOffset
        mOffset?.x = to
        
        if let
        offset = mOffset {
            self.seeMoreFooterSection?.scrollView.setContentOffset(offset, animated: false)
        }
    }
    
    /*
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < 0) {
            //loadArticles()
        }
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        let safeAreaTop: CGFloat = 88
        let offset = scrollView.contentOffset.y + safeAreaTop
        
        let alpha: CGFloat = 1 - ((scrollView.contentOffset.y + safeAreaTop) / safeAreaTop)
        
        navigationController?.navigationBar.alpha = alpha
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0,-offset))
        
        self.view.bringSubviewToFront(self.moreHeadLines)
        print(self.moreHeadLines)
        
    }
    */
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let tableView = scrollView as? UICollectionView else {return}
        let visibleHeadersInSection = tableView.indexPathsForVisibleItems
        let indexHeaderForSection = NSIndexPath(row: 0, section: 0)
    
        if scrollView.contentOffset.y < 0 { return }
        let offsetBetweenItems = 50

        
        var limit = self.moreHeadLinesInCollectionPosY-self.navBarFrame.size.height
        if let nav = navigationController {
            if(!nav.navigationBar.isTranslucent) {
                limit += (self.navBarFrame.origin.y + self.navBarFrame.size.height)
            }
            limit += 18
        }
        limit -= 58
        
        if(limit<110) {
            self.moreHeadLines.hide()
        } else {
            if(scrollView.contentOffset.y >= limit) {
                if let view = self.seeMoreFooterSection {
                    var mOffset = view.scrollView.contentOffset
                    self.moreHeadLines.scrollView.contentOffset = mOffset
                }
                
                if(self.param_A != 40){
                    self.moreHeadLines.show()
                }
            } else {
                if let view = self.seeMoreFooterSection {
                    var mOffset = self.moreHeadLines.scrollView.contentOffset
                    view.scrollView.contentOffset = mOffset
                }
            
                self.moreHeadLines.hide()
            }
        }
        
        self.view.bringSubviewToFront(self.moreHeadLines)
    }
}

extension NewsViewController {
    // Topic from search
    private func loadTopicFromSearch() {
    
        self.loadingView.isHidden = false // show
        var link = self.buildApiCall(topicForCall: self.topicCodeFromSearch, zeroItems: true)
        let url = URL(string: link)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if(error != nil || data == nil) {
                self.loadingView.isHidden = true // hide
                return
            }
            
            do {
                let responseJSON = try JSON(data: data!)
                let topicNode = responseJSON[1][0]
                let count = topicNode[3].intValue

                DispatchQueue.main.async {
                
                    self.firstTime = true
                    self.param_A = 4
                    if(count==0){ self.param_A = 40 }
                    self.topic = self.topicCodeFromSearch
                    self.topicCodeFromSearch = ""
                    
                    self.loadData()
                }
                
                
            } catch _ {
                self.loadingView.isHidden = true // hide
                return
            }
        }
        task.resume()
    }
}


/*
var headers = [String]()


    var artfreq = ".A4"
    var untouchables = ".B4.S0"
    var sliderPrefs = ""
    
    
    var activityIndicator = UIActivityIndicatorView()

 */


extension NewsViewController {

    private func addParamsLabel() {
        /*
        let paramsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        paramsLabel.backgroundColor = UIColor.blue
        paramsLabel.textAlignment = .center
        paramsLabel.textColor = .green
        paramsLabel.text = "A\(self.param_A).B\(self.param_B).S\(self.param_S)"
        
        self.navigationItem.titleView?.addSubview(paramsLabel)
        */
    }

}


extension NewsViewController {

    func initDivider() {
        return //!!!
    
        let w: CGFloat = 60
        let x: CGFloat = (UIScreen.main.bounds.width-w)/2
        let h: CGFloat = UIScreen.main.bounds.height
        vDivider.frame = CGRect(x: x, y: 0, width: w, height: h)
        vDivider.backgroundColor = .clear //UIColor.red.withAlphaComponent(0.25)
        vDivider.clipsToBounds = false
        vDivider.isUserInteractionEnabled = false
        
        /*
        let dirs: [UISwipeGestureRecognizer.Direction] = [.left, .right]
        for D in dirs {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(vDividerOnGesture(gesture:)))
            gesture.direction = D
            vDivider.addGestureRecognizer(gesture)
        }
        */
        
        self.collectionView.addSubview(vDivider)
        vDivider.isHidden = true
    }
    
    @objc func vDividerOnGesture(gesture: UIGestureRecognizer) {
        self.biasSliders.disableSplit()
    }
    
    func updateDivider() {
        return //!!!
    
        // Delete all subviews
        vDivider.subviews.forEach({ $0.removeFromSuperview() })
        
        // Hide/Show component
        if(!mustSplit()) {
            vDivider.isHidden = true
            return
        }
        vDivider.isHidden = false
        
        // Draw lines
        let sections = self.numberOfSections(in: self.collectionView)
        var topValue = sections-1
        if(topValue<=0) {
            return
        }
        
        //topValue = -1 // this will provoke a crash
        let W: CGFloat = 4
        let X: CGFloat = (vDivider.frame.size.width - W)/2
        
        var index = 0
        var offsetY: CGFloat = 0
        
        for sec in 0...topValue {
            
            let items = self.collectionView(self.collectionView, numberOfItemsInSection: sec)
            if(items<=0) {
                continue
            }
            
            var cols = 0
            offsetY += 51 + 53 // header(s)
            for i in 0...items-1 {
            
                var height: CGFloat = 0.0
                if(self.newsParser.getStory(index: index) != nil) {
                    // this is a story, don't draw the line
                    offsetY += CGFloat(STORIES_HEIGHT())
                    index += 1
                    continue
                } else {
                    // normal article
                    cols += 1
                    if(cols == 1) {
                        height = CGFloat(ARTICLE_CELL_HEIGHT())
                    }
                    
                    if(cols==2){
                        cols = 0
                    }
                }
                 
                // draw line
                if(height>0) {
                    let line = UIView(frame: CGRect(x: X, y: offsetY, width: W, height: height))
                    line.backgroundColor = DARKMODE() ? .white : bgWhite_DARK
                    line.alpha = DARKMODE() ? 1.0 : 0.5
                    line.isUserInteractionEnabled = false
                    vDivider.addSubview(line)
                }
                
                // Footer(s)
                if(i==items-1) {
                    if(sec==0) {
                        offsetY += 115
                        // banner
                        if let info = BannerInfo.shared {
                            if(self.uniqueID==1 && info.active) {
                                offsetY += BannerView.getHeightForBannerCode(info.adCode)
                            }
                        }
                    } else {
                        offsetY += 70
                    }
                }
                
                offsetY += height
                index += 1
                
            }
            
            
            
            
            /*
            let margin: CGFloat = 8
            var Y: CGFloat = 51 + 45 // header
            let rows = items/2
            var H: CGFloat = CGFloat(240 * rows)
            let W: CGFloat = 4
            let X: CGFloat = (vDivider.frame.size.width - W)/2
            
            let line = UIView(frame: CGRect(x: X, y: Y + offsetY + margin, width: W, height: H))
            
            line.backgroundColor = DARKMODE() ? .white : bgWhite_DARK
            line.alpha = DARKMODE() ? 1.0 : 0.2
            line.isUserInteractionEnabled = false
            vDivider.addSubview(line)
            
            offsetY += (51+45) + H + margin
            if(sec==0) {
                offsetY += 115
                
                if let info = BannerInfo.shared {
                    if(self.uniqueID==1 && info.active) {
                        offsetY += BannerView.getHeightForBannerCode(info.adCode)
                    }
                }
            } else {
                offsetY += 70
            }
            */
            
            
            
            
            
            // show alpha line
            /*
            if(sec == sections-1) { // last loop
                var segment: CGFloat = 5.0
                var posY: CGFloat = 0
                let limit = offsetY + 50
                //line.frame.origin.y + line.frame.size.height
                
                while(posY < limit) {
                    let alphaLine = UIView(frame: CGRect(x: X, y: posY,
                        width: W, height: segment))
                    alphaLine.backgroundColor =  DARKMODE() ? .white : bgWhite_DARK
                    
                    //line.backgroundColor
                    alphaLine.alpha = DARKMODE() ? 0.06 : 0.4
                    alphaLine.isUserInteractionEnabled = false
                    vDivider.addSubview(alphaLine)
                    
                    posY += (segment * 2)
                }
            }
            */
            

        }
        
        
    }
    
    /*
        H = line.frame.origin.y + line.frame.size.height
        let alphaLine = UIView(frame: CGRect(x: X, y: 0,
            width: W, height: H))
        alphaLine.backgroundColor = line.backgroundColor
        alphaLine.alpha = 0.05
        alphaLine.isUserInteractionEnabled = false
        vDivider.addSubview(alphaLine)
        
        var mFrame = vDivider.frame
        mFrame.size.height = H
        vDivider.frame = mFrame
    */
    
    
    func mustSplit() -> Bool {
        let stancevalues =  self.biasSliders.stanceValues()
        if(stancevalues.0 || stancevalues.1) {
            return true
        } else {
            return false
        }
    }
    
    func splitValueChange() {
    
        if(Utils.shared.currentLayout == .textOnly && !mustSplit()) {
            Utils.shared.newsViewController_ID = 0
            let vc = NewsTextViewController(topic: self.topic)
            vc.param_A = self.param_A
            self.navigationController?.viewControllers = [vc]
            
            return
        }
        if(Utils.shared.currentLayout == .bigBeautiful && !mustSplit()) {
            Utils.shared.newsViewController_ID = 0
            let vc = NewsBigViewController(topic: self.topic)
            vc.param_A = self.param_A
            self.navigationController?.viewControllers = [vc]
            
            return
        }
    
    
    
        if( mustSplit() ) {
            // SPLIT
            self.biasButtonState = 2
            if(vDivider.isHidden) {
                vDivider.alpha = 0
                vDivider.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.vDivider.alpha = 1
                }
            }
        } else {
            // NORMAL
            self.biasButtonState = 1
            if(!vDivider.isHidden) {
                UIView.animate(withDuration: 0.25) {
                    self.vDivider.alpha = 0
                } completion: { success in
                    self.vDivider.isHidden = true
                }
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
        
        // reload the news
        if(splitChangeFirstTime) {
            self.firstTime = true
        }
        
        self.splitChangeFirstTime = true
        self.loadData()
    }
    
    
}

extension NewsViewController {

    @objc func userButtonTap(_ sender: UIBarButtonItem) {
        MarkupUser.shared.showActionSheet(self)
    }

    @objc func bellButtonTap(_ sender: UIBarButtonItem) {
        if(MarkupUser.shared.userInfo == nil) {
            self.alert("Please log in to access this feature")
        } else {
            MarkupUser.shared.openNotifications()
        }
    }
    
    private func alert(_ text: String) {
        let alert = UIAlertController(title: "", message: text, preferredStyle: .alert)
            
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension NewsViewController: OnBoardingViewDelegate {
    
    func onBoardingClose() {
        UserDefaults.standard.setValue("ABC", forKey: ONBOARDING_ID)
        UserDefaults.standard.synchronize()
    
        UIView.animate(withDuration: 0.4) {
            self.onBoard?.alpha = 0.0
        } completion: { _ in
            self.onBoard?.removeFromSuperview()
            self.onBoard = nil
        }
        
        if(IS_iPHONE()) {
            AppUtility.lockOrientation(.portrait)
        } else {
            AppUtility.lockOrientation(.all)
        }
    }
    
    @objc func showOnboardingAgain() {
        self.onBoard?.removeFromSuperview()
        self.onBoard = nil
        //self.navigationController?.popViewController(animated: false)
        
        self.onBoard = OnBoardingView(container: self.view, parser: self.newsParser,
            skipFirstStep: true, topic: self.topic, sliderValues: self.getSliderValues())
            
        self.onBoard?.delegate = self
        AppUtility.lockOrientation(ORIENTATION_MASK())
    }
    
    
    static func get_vParams() -> String {
        var result = ""
        
        var vKeys = [
            "VA": "appCfg_showFlags",
            "VB": "appCfg_showStance",
            "VC": "appCfg_stancePopup",
            "VM": "appCfg_starRatings"
        ]
        
        for (vKey, vValue) in vKeys {
            var vText = vKey
            
            if let _value = UserDefaults.standard.value(forKey: vValue) as? Bool {
                if(_value) {
                    vText += "00"
                } else {
                    vText += "01"
                }
            } else {
                vText += "00"
            }
            
            result += vText
        }
        
        // version
        result += "VE3"
        var version = Bundle.main.releaseVersionNumber!
        if(version.count>=3) {
            let minorVersion = version[2]
            result += String(minorVersion)
        } else {
            result += "0"
        }

        return result
    }
    
    func getSliderValues() -> String {
        var result = SliderValues.sharedInstance.getBiasPrefs()
        result = result.replacingOccurrences(of: "&sliders=", with: "")
        
        var biasStatus = self.biasSliders.status
        biasStatus = biasStatus.replacingOccurrences(of: "SL", with: "SS")
        result += biasStatus
        
        var displayMode = "0"
        if(!DARKMODE()){ displayMode = "1" }
        if(Utils.shared.currentLayout == .denseIntense) {
            result += "LA0" + displayMode
        } else if(Utils.shared.currentLayout == .textOnly) {
            result += "LA1" + displayMode
        } else {
            result += "LA2" + displayMode
        }
        
        for bannerID in BannerView.bannerHeights.keys {
            let key = "banner_apiParam_" + bannerID
            if let value = UserDefaults.standard.string(forKey: key) {
                result += value
                break
            }
        }
        result += NewsViewController.get_vParams()
        
        return result
    }

    @objc func hidePrefsPanel() {
        let status = self.biasSliders.status
        
        if(status != "SL00") {
            // opened
            self.biasSliders.handleDismiss()
        }
    }
    
    @objc func showPrefsPanelFromTour() {
        //DELAY(0.2) {
            self.configureBiasSliders()
        //}
    }
}

extension NewsViewController {

    // biasMiniButton
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
    
    func biasMiniButtonUpdatePosition(offset: CGFloat = 20) {
        var mFrame = self.biasMiniButton.frame
        mFrame.origin.x = self.biasButton.frame.origin.x - offset
        mFrame.origin.y = self.biasButton.frame.origin.y - offset
        self.biasMiniButton.frame = mFrame
    }
    
    @objc func biasMiniButtonOnTap(sender: UIButton) {
        HAPTIC_CLICK()
        
        if(self.biasButtonState == 1) {
            // Normal "panel", go to share-split mode
            if(!mustSplit()) {
                self.enableSplitSharingAfterLoading = true
                self.biasSliders.enableSplitForSharing()
            } else { self.startSplitSharingWorkflow() }
        } else {
            // Split, go to normal (panel) mode
                //self.biasSliders.disableSplitFromOutside()
            
            self.biasButtonState = 1
            let iconImageView = self.biasMiniButton.viewWithTag(767) as! UIImageView
            iconImageView.image = UIImage(named: "shareSplitButton.png")
            let buttonIcon = UIImage(named: "prefsButton.png")
            self.biasButton.setBackgroundImage(buttonIcon, for: .normal)
        }
        
        self.miniButtonTimer?.invalidate()
        self.biasMiniButton.isHidden = true
    }
    
    @objc func biasButtonOnLongPress(gesture: UILongPressGestureRecognizer) {
        if(gesture.state != .began){ return }
        
        if(APP_CFG_SPLITSHARING) {
            //HAPTIC_LONGPRESS()
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
    
    func startSplitSharingWorkflow() {
        self.miniButtonTimer?.invalidate()
        self.biasMiniButton.isHidden = true
        
        self.biasButtonState = 2
        let iconImageView = self.biasMiniButton.viewWithTag(767) as! UIImageView
        iconImageView.image = UIImage(named: "prefsButton.png")
        let buttonIcon = UIImage(named: "shareSplitButton.png")
        self.biasButton.setBackgroundImage(buttonIcon, for: .normal)
    
    
    
        self.shareArticles?.start(parser: self.newsParser)
        self.shareArticles?.isHidden = false
        self.mustShowHorizontalMenu = !self.moreHeadLines.isHidden
        self.moreHeadLines.hide()
    
        if(self.shareSplitView!.mustBeShown()) {
            self.shareSplitView?.show()
        } else {
            self.biasButton.isHidden = true
            self.biasSliders.isHidden = true
            self.biasMiniButton.isHidden = true
            self.shareActionsView?.show()
        }
    }


}

extension NewsViewController: ShareSplitActionsPopupDelegate {
    func shareSplitAction_exit() {
        self.biasButton.isHidden = false
        self.biasSliders.isHidden = false
        
        self.shareArticles?.isHidden = true
        self.shareArticles?.unloadStuff()
        self.shareActionsView?.hide()
        
        if(self.mustShowHorizontalMenu) {
            self.moreHeadLines.show()
        }
    }
    
    func shareSplitAction_share() {
        let vc = ShareSplitShareViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.articles = self.shareArticles?.getSelectedArticles()
        
        //self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true) {
        }
    }
    
    func shareSplitAction_randomize() {
        self.shareArticles?.randomize()
    }
}

extension NewsViewController: ShareSplitExplainPopupDelegate {
    func onShareSplitExplaintPopupClose() {
        self.biasButton.isHidden = true
        self.biasSliders.isHidden = true
        self.shareActionsView?.show()
    }
}

extension NewsViewController: ShareSplitArticlesDelegate {
    func articleWasSelected(totalCount: Int) {
        if(totalCount==2) {
            self.shareActionsView?.setShareEnable(true)
            //self.shareActionsView?.showText("Now tap the share button!")
            self.shareActionsView?.startAnims()
        } else {
            self.shareActionsView?.setShareEnable(false)
            self.shareActionsView?.showText("Select any 2 articles")
            //self.shareActionsView?.stopAnimations()
        }
    }
}

extension NewsViewController: SFSafariViewControllerDelegate {

    func test() {
        /*
        let vc = MyAccountViewController.createInstance()
        self.present(vc, animated: true)
        */
    }

}




/*
    TRASH
    
    private func setUpNavBar_new() {
        searchBar.sizeToFit()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.textColor = .black
        searchBar.tintColor = .black

        let logo = UIImage(named: "N64")
        let titleView = UIImageView(image: logo)
        titleView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleView

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barTintColor = DARKMODE() ? bgBlue_DARK : bgWhite_DARK
        navigationController?.navigationBar.isTranslucent = false
        
        let _textColor = DARKMODE() ? UIColor.white : textBlack
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PlayfairDisplay-SemiBold", size: 26)!, NSAttributedString.Key.foregroundColor: _textColor]
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = DARKMODE() ? bgBlue_DARK : bgWhite_DARK
            appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PlayfairDisplay-SemiBold", size: 26)!, NSAttributedString.Key.foregroundColor: _textColor]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }
        //navigationController?.navigationBar.barStyle = .black

        let sectionsButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "hamburger"), style: .plain, target: self, action: #selector(self.hamburgerButtonItemClicked(_:)))

        let iconsMargin: CGFloat = 45.0

        let bellButton = self.bellIcon_A()

        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self,
            action: #selector(searchItemClicked(_:)))
        
        var userImage = UIImage(systemName: "person")
        if(MarkupUser.shared.userInfo != nil) {
            userImage = UIImage(systemName: "person.fill")
        }
        
        let userButton = UIBarButtonItem(image: userImage, style: .plain, target: self,
            action: #selector(userButtonTap(_:)) )
        userButton.imageInsets = UIEdgeInsets(top: 0, left: iconsMargin,
            bottom: 0, right: 0)

        var leftButtons: [UIBarButtonItem] = [sectionsButton]
        var rightButtons: [UIBarButtonItem] = [searchButton]

        if(APP_CFG_SHOW_MARKUPS && self.uniqueID==1) {
            leftButtons.append(bellButton)
            rightButtons.append(userButton)
        }
        
        navigationItem.leftBarButtonItems = leftButtons
        navigationItem.rightBarButtonItems = rightButtons
        
        navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        var logoFile = "ITN_logo.png"
        if(!DARKMODE()){ logoFile = "ITN_logo_blackText.png" }

        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 165, height: 30))
        //view.backgroundColor = .green
        let img = UIImage(named: logoFile)?.withRenderingMode(.alwaysOriginal)
        let homeButton = UIButton(image: img!)
        
        
        var valX: CGFloat = ((view.frame.size.width - 195)/2) //- 10.0
        let elementsSizeSum: CGFloat = (44*4)+195+(5*2)
        if(APP_CFG_SHOW_MARKUPS && self.uniqueID==1) {
            if(elementsSizeSum>=UIScreen.main.bounds.width) {
                valX -= 10.0
            }
        }
        
        self.addBadge()
        homeButton.frame = CGRect(x: valX, y: 0, width: 195, height: 30)
        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        
        
        view.addSubview(homeButton)
        //view.addSubview(label)
        view.center = navigationItem.titleView!.center
        self.navigationItem.titleView = view
    }
    
    private func setUpNavBar_old() {
        searchBar.sizeToFit()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.textColor = .black
        searchBar.tintColor = .black

        let logo = UIImage(named: "N64")
        let titleView = UIImageView(image: logo)
        titleView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleView
    
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barTintColor = DARKMODE() ? bgBlue_DARK : bgWhite_DARK
        navigationController?.navigationBar.isTranslucent = false
        
        let _textColor = DARKMODE() ? UIColor.white : textBlack
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PlayfairDisplay-SemiBold", size: 26)!, NSAttributedString.Key.foregroundColor: _textColor]
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = DARKMODE() ? bgBlue_DARK : bgWhite_DARK
            appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PlayfairDisplay-SemiBold", size: 26)!, NSAttributedString.Key.foregroundColor: _textColor]
            
            
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }
        //navigationController?.navigationBar.barStyle = .black

        let sectionsButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "hamburger"), style: .plain, target: self, action: #selector(self.sectionButtonItemClicked(_:)))

        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self,
            action: #selector(searchItemClicked(_:)))

        var rightButtons = [searchButton]

        if(APP_CFG_MY_ACCOUNT) {
            var userImage = UIImage(systemName: "person")
            let userButton = UIBarButtonItem(image: userImage, style: .plain, target: self,
                action: #selector(userButtonItemClicked(_:)) )
            userButton.imageInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
            
            rightButtons.append(userButton)
        }

        

        /*
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchItemClicked(_:)))
        */
        
        navigationItem.rightBarButtonItems = rightButtons
        
        navigationItem.leftBarButtonItem = sectionsButton
        navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        var logoFile = "ITN_logo.png"
        if(!DARKMODE()){ logoFile = "ITN_logo_blackText.png" }

        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 195, height: 30))
        let img = UIImage(named: logoFile)?.withRenderingMode(.alwaysOriginal)
        let homeButton = UIButton(image: img!)
        homeButton.frame = CGRect(x: 0, y: 0, width: 195, height: 30)
        
        if(IS_ZOOMED() && self.uniqueID>1) {
            let f: CGFloat = 0.85
            homeButton.frame = CGRect(x: 0, y: 0,
                    width: 195 * f, height: 30 * f)
        }
        
        if(APP_CFG_MY_ACCOUNT) {
                var mFrame = homeButton.frame
                mFrame.origin.x += 20
                homeButton.frame = mFrame
        }

        
        homeButton.addTarget(self, action: #selector(homeButtonTapped),
                            for: .touchUpInside)

        view.addSubview(homeButton)
        view.center = navigationItem.titleView!.center
        self.navigationItem.titleView = view
    }
    
    /*
    func test() {
        
        DELAY(2.0) {
            let vc = MyAccountViewController.createInstance()
            self.present(vc, animated: true)
        
            /*
            let fb = FB_SDK.instance
            fb.login(vc: self)
            */
            /*
            let li = LI_SDK.instance
            li.login(vc: self)
            */
        
            /*
            let red = RED_SDK.instance
            red.login(vc: self)
            */
        
            /*
            let tw = TW_SDK.instance
            tw.login(vc: self)
            */
        }
    }
    
    func test_REDLogin() {
        let red = RED_SDK.instance
        
        red.login(vc: self)
    }
    

    func test_FBLogin() {
        let fb = FB_SDK.instance
        
        /*
        if(!fb.isLogged()) {
            fb.login(vc: self)
        } else {
            fb.logout(vc: self) { (_a) in
                print("SHARE", _a)
                print("SHARE", fb.isLogged())
            }
        }
        */
    }


    func test_LILogin() {
    
        /*
        let li = LI_SDK.instance
        
        if(!li.isLogged()) {
            li.login(vc: self)
        } else {
            li.logout(vc: self) { (a) in
                print("LINKEDIN", "loggedOut", a)
            }
        }
        */

        
    }

    func test_TWLogin() {
        /*
        let tw = TW_SDK.instance
        
        tw.login(vc: self)
        */
        
        /*
        if(!tw.isLogged()) {
            tw.login(vc: self)
        } else {
            tw.logout(vc: self) { (_a) in
                print("SHARE", _a)
                print("SHARE", tw.isLogged())
            }
        }
        */
    }
    
*/
    
    
*/
