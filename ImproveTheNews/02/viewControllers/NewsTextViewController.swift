//
//  NewsTextViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 27/04/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class NewsTextViewController: UIViewController {

    var firstTime = true
    var uniqueID = -1
    var topic = ""                          // current topic, set at the beginning
    var hierarchy = ""                      // hierarchy (path)
    var topicCodeFromSearch = ""
    var superSliderStr = ""                 // para armar el request

    let newsParser = News()                 // parser
    var param_A = 4
    var param_B = 4
    var param_S = 0

    let searchBar = UISearchBar()           // searchBar
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    var refresher: UIRefreshControl!        // pull to refresh
    let biasSliders = SliderPopup()         // Preferences (orange) panel
    let loadingView = UIView()              // loading with activityIndicator inside
    let horizontalMenu = HorizontalMenuView()
    var bannerView: BannerView?
    
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

    let NOTIFICATION_RELOAD_NEWS_IN_OTHER_INSTANCES =             Notification.Name("reloadNewsInOtherInstances")

    var onBoard: OnBoardingView?

    let STORIES_HEIGHT_2 = 150



    // MARK: - Initialization
    init(topic: String) {
        super.init(nibName: nil, bundle: nil)
        self.topic = topic
    }
    
    required init?(coder: NSCoder) {    // required
        fatalError()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.badgeView.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        AppUtility.lockOrientation(.all)
    
        Utils.shared.navController = self.navigationController as? CustomNavigationController
        Utils.shared.newsViewController_ID += 1
        self.uniqueID = Utils.shared.newsViewController_ID
    
        self.newsParser.newsDelegate = self
        self.biasSliders.sliderDelegate = self
        self.biasSliders.shadeDelegate = self
    
        self.view.backgroundColor = DARKMODE() ? bgBlue : bgWhite_LIGHT
        self.tableView.backgroundColor = self.view.backgroundColor
        self.setUpNavBar()
        self.setUpRefresh()
        self.setupTableView()
        self.setUpLoadingView()
        self.setUpHorizontalMenu()
        self.setUpBiasButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showPrefsPanelFromTour),
            name: NOTIFICATION_ONBOARDING_PREFS_PANEL_SHOW, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hidePrefsPanel),
            name: NOTIFICATION_ONBOARDING_PREFS_PANEL_HIDE, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showOnboardingAgain),
            name: NOTIFICATION_SHOW_ONBOARDING, object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(setUpNavBar),
            name: NOTIFICATION_UPDATE_NAVBAR, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAll),
            name: NOTIFICATION_FORCE_RELOAD_NEWS,
            object: nil)
            
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(onJsonParseError),
            name: NOTIFICATION_JSON_PARSE_ERROR,
            object: nil)
            
        if(SHOW_ONBOARD() && self.uniqueID==1) {
            self.onBoard = OnBoardingView(container: self.view,
                parser: self.newsParser, topic: self.topic,
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSlidersInfo),
            name: NOTIFICATION_SHOW_SLIDERS_INFO, object: nil)
            
        self.initBiasMiniButton()
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
            self.scrollViewDidScroll(self.tableView)
            self.horizontalMenu.changeWidthTo(UIScreen.main.bounds.width)
            
            // loading
            let dim: CGFloat = 65
            self.loadingView.frame = CGRect(x: (UIScreen.main.bounds.width-dim)/2,
                                            y: ((UIScreen.main.bounds.height-dim)/2) - 88,
                                            width: dim, height: dim)
        }
    }
    
    @objc func showSlidersInfo() {
        let sliders = SliderDoc()
        self.present(sliders, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return STATUS_BAR_STYLE()
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
    
    @objc private func reloadAll() {
        self.firstTime = true
        self.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = DARKMODE() ? .white : darkForBright
        //navigationController?.navigationBar.barStyle = DARKMODE() ? .black : .default
        self.setUpNavBar()
    
        self.tableView.delaysContentTouches = false
        self.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!self.firstTime && !self.topicCodeFromSearch.isEmpty) {
            self.loadTopicFromSearch()
        }
        
        if(APP_CFG_SHOW_MARKUPS && self.uniqueID==1) {
            DELAY(0.3) {
                CookiesAlert.shared.show(viewController: self)
            }
        }
    }
    
    // MARK: - UI
    private func itemsHeight(section: Int) -> CGFloat {
        var sum = 0
        
        var start = 0
        for n in 0..<section {
            start += newsParser.getArticleCountInSection(section: n)
        }
        let total = newsParser.getArticleCountInSection(section: section)
        if(total==0){ return 0.0 }
        
        for n in 0...total-1 {
            let index = n + start
            
            var height = 0
            if(self.newsParser.getStory(index: index) != nil) {
                height = STORIES_HEIGHT_2
            } else {
                height += 100
            }

            sum += height
        }
        
        return CGFloat(sum)
    }
    
    private func setUpHorizontalMenu() {
        self.view.addSubview(self.horizontalMenu)
        
        let margin: CGFloat = 0
        //self.horizontalMenu.offset_y = CGFloat(70 + (100 * self.param_A)) + margin
        self.horizontalMenu.offset_y = CGFloat(70 + self.itemsHeight(section: 0) + margin)
        self.horizontalMenu.moveTo(y: 0)
        self.horizontalMenu.isHidden = true
        self.horizontalMenu.customDelegate = self
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
            self.navigationController?.navigationBar.addSubview(self.badgeView)
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
    
    @objc private func setUpNavBar() {
        /*
        print("GATO999", self.uniqueID)
        DispatchQueue.main.async {
            self.setUpNavBar_2()
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
    
    func setupTableView() {
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.tableView.backgroundColor = self.view.backgroundColor
        
        let headerNib = UINib(nibName: "HeaderCellTextOnly", bundle: nil)
        self.tableView.register(headerNib,
            forHeaderFooterViewReuseIdentifier: "HeaderCellTextOnly")
            
        let cellNib = UINib(nibName: "CellTextOnly", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "CellTextOnly")
        
        let footerNib = UINib(nibName: "FooterCellTextOnly", bundle: nil)
        self.tableView.register(footerNib,
            forHeaderFooterViewReuseIdentifier: "FooterCellTextOnly")
            
        let footerItem0Nib = UINib(nibName: "FooterCellTextOnlyItem0", bundle: nil)
        self.tableView.register(footerItem0Nib,
            forHeaderFooterViewReuseIdentifier: "FooterCellTextOnlyItem0")
            
        let footer1topicNib = UINib(nibName: "FooterCellTextOnly1Topic", bundle: nil)
        self.tableView.register(footer1topicNib,
            forHeaderFooterViewReuseIdentifier: "FooterCellTextOnly1Topic")
            
        
        self.tableView.register(StoryViewCellTextOnly.self, forCellReuseIdentifier: StoryViewCellTextOnly.cellId)
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.indicatorStyle = .white
    }
    
    func setUpRefresh() {
        self.refresher = UIRefreshControl()
        self.tableView.alwaysBounceVertical = true
        self.refresher.tintColor = .lightGray
        self.refresher.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refresher)
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    func setUpLoadingView() {
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
        if(!DARKMODE()){ loading.color = darkForBright }
        self.loadingView.addSubview(loading)
        loading.center = CGPoint(x: dim/2, y: dim/2)
        loading.startAnimating()
    
        self.view.addSubview(self.loadingView)
    }
    
    private func setFlag(imageView: UIImageView, ID: String) {
        let img = UIImage(named: "\(ID.uppercased())64.png")
        
        imageView.backgroundColor = bgBlue
        if(img != nil) {
            imageView.image = img
        } else {
            imageView.image = UIImage(named: "noFlag.png")
        }
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
    
    // MARK: - Some action(s)
    @objc func hamburgerButtonItemClicked(_ sender:UIBarButtonItem!) {
        navigationController?.customPushViewController(SectionsViewController())
    }
    
    @objc func userButtonItemClicked(_ sender:UIBarButtonItem!) {
        let vc = AppUser.shared.accountViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func searchItemClicked(_ sender:UIBarButtonItem!) {
        let searchvc = SearchViewController()
        navigationController?.pushViewController(searchvc, animated: true)
    }
    
    @objc func refresh(_ sender: UIRefreshControl!) {
        self.refresher.beginRefreshing()
        self.firstTime = true
        self.loadData()
    }
    
    @objc func homeButtonTapped() {
        if(self.onBoard == nil) {
//            self.firstTime = true
//            self.loadData()
//
//            let offset = CGPoint(x: 0, y: 0)
//            self.tableView.setContentOffset(offset, animated: true)
//            self.horizontalMenu.backToZero()

            navigationController?.popToRootViewController(animated: true)
            let firstIndexPath = IndexPath(row: 0, section: 0)

            if let _vc = navigationController?.viewControllers.first as? NewsTextViewController {
                if(self == _vc){
                    _vc.tableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
                } else {
                    DELAY(0.2) {
                        _vc.tableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
                    }
                }
            }
        }
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
    
    
    // MARK: - Data
    func loadData() {
        if(self.firstTime) {
            if(self.loadingView.isHidden) {
                self.loadingView.isHidden = false
            }
            
            DispatchQueue.main.async {
                self.loadArticles()
                DELAY(2.5) {
                    if(!self.loadingView.isHidden) {
                        self.loadingView.isHidden = true
                        self.firstTime = false
                        self.tableView.reloadData()
                        self.stopRefresher()
                    }
                }
            }
        }
    }
    
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
        bStatus = bStatus.replacingOccurrences(of: "SL", with: "SS")
        
        let link = API_CALL(topicCode: T, abs: ABS,
                            biasStatus: bStatus,
                            banners: banner, superSliders: superSlider)
        return link
    }
    
    func loadArticles() {
        DispatchQueue.global().async {
            let link = self.buildApiCall()
            print("GATO", "should load " + link)
            self.newsParser.getJSONContents(jsonName: link)
        }
    }
    
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
    
    // MARK: - misc
    func pushNewTopic(_ topicCode: String) {
        let vc = NewsTextViewController(topic: topicCode)
        
        // PARAM (A) // --------------------------------
        vc.param_A = 4
        if(topicCode==self.topic && Utils.shared.didTapOnMoreLink) {
            vc.param_A = 10
        }
        Utils.shared.didTapOnMoreLink = false
        
        var topicName = ""
        for (key, value) in Globals.topicmapping {
            if(value == topicCode) {
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
            vc.param_S += GET_COUNT_FOR(topic: topicCode, in: _vc)
        }
        
        /*
        vc.param_S = 0
        for _vc in self.navigationController!.viewControllers {
            let topicAndCount = GET_TOPICARTICLESCOUNT(from: _vc)
            if(topicAndCount.0 == topicCode) {
                vc.param_S += topicAndCount.1
            }
        }
        */

        navigationController?.pushViewController(vc, animated: true)
    }
    
}



extension NewsTextViewController: NewsDelegate {
    
    func resendRequest() {
        self.loadArticles()
    }
    
    func didFinishLoadData(finished: Bool) {
        if(BannerInfo.shared != nil) {
            if(self.uniqueID==1 && BannerInfo.shared?.delegate==nil) {
                print("######### DELEGATE SET!")
                BannerInfo.shared?.delegate = self
            }
        }
        
        self.hierarchy = newsParser.getHierarchy()
        self.loadingView.isHidden = true
        self.firstTime = false
        self.tableView.reloadData()
        self.stopRefresher()
        
        self.horizontalMenu.setTopics(self.newsParser.getAllTopics())
        if(self.param_A != 40){
            self.horizontalMenu.isHidden = false
        }
        
        let margin: CGFloat = 0.0
        self.horizontalMenu.offset_y = CGFloat(70 + self.itemsHeight(section: 0) + margin)
        self.horizontalMenu.moveTo(y: 0)
        
        self.addParamsLabel()
        NotificationCenter.default.post(name: NOTIFICATION_FOR_ONBOARDING_NEWS_LOADED, object: nil)
        
        //self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
}


// MARK: - All tableView related
extension NewsTextViewController: UITableViewDelegate, UITableViewDataSource,
    HeaderCellTextOnlyDelegate, FooterCellTextOnlyDelegate,
    FooterCellTextOnlyItem0Delegate, FooterCellTextOnly1TopicDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.newsParser.getNumOfSections()
    }
    
    // Headers
    func tableView(_ tableView: UITableView,
        heightForHeaderInSection section: Int) -> CGFloat {
        
        return 70
    }
    
    func tableView(_ tableView: UITableView,
        viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderCellTextOnly" ) as! HeaderCellTextOnly

        cell.delegate = self
        cell.contentLabel.text = self.newsParser.getTopic(index: section)

        var breadcrumbText = ""
        breadcrumbText = self.hierarchy + newsParser.getTopic(index: section)
        cell.hierarchyLabel.adjustsFontSizeToFitWidth = true
        hArray.append(breadcrumbText)
        
        let components = breadcrumbText.components(separatedBy: ">")
        if(components.count > 1) {
            let last = components.last!
            breadcrumbText = breadcrumbText.replacingOccurrences(of: ">" + last, with: "")
            hArray.append(breadcrumbText)
        }
        cell.hierarchyLabel.text = breadcrumbText

        return cell
    }
    
    // Tap on breadcrumbs
    func pushNewTopic(_ topic: String, sender: HeaderCellTextOnly) {
        self.pushNewTopic(topic)
    }
    
    // Tap on share
    func shareTapped(sender: FooterCellTextOnly) {
        self.share()
    }
    
    func share1TopicTapped(sender: FooterCellTextOnly1Topic) {
        self.share()
    }
    
    func share() {
        let ac = UIActivityViewController(activityItems: ["http://www.improvethenews.org/"], applicationActivities: nil)
        
        if(IS_iPAD()) {
            let offsetMax = self.tableView.contentSize.height - self.tableView.frame.size.height
            let diff = offsetMax - self.tableView.contentOffset.y
            
            ac.popoverPresentationController?.sourceView = self.view
            ac.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX,
                y: self.view.bounds.height - 100 + diff, width: 0, height: 0)
        }
        
        self.present(ac, animated: true)
    }

    // Cells
    func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
        
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
            //print("STORIES test", indexPath.section, index, 100)
            return 100.0
        } else {
            //print("STORIES test", indexPath.section, index, STORIES_HEIGHT)
            return CGFloat(STORIES_HEIGHT_2)
        }
        
        //return 100
    }
    
    func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        
        return self.newsParser.getArticleCountInSection()[section]
    }
    
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var start = 0
        for n in 0..<indexPath.section {
            start += newsParser.getArticleCountInSection(section: n)
        }
        let index = indexPath.row + start
        
        //if(index < newsParser.getLength()) {
        if(self.newsParser.getStory(index: index) != nil ) {    // Story
            let cell = self.storyCell(index: index)
            return cell
        } else {
            let cell = self.regularCell(index: index)
            return cell
        }
        //}
    }
    
    // story cell
    private func storyCell(index: Int) -> StoryViewCellTextOnly {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            StoryViewCellTextOnly.cellId) as! StoryViewCellTextOnly
            
        cell.setupViews(sources: self.newsParser.getStory(index: index)!.sources)
        
        cell.updated.text = "Last updated " + newsParser.getDate(index: index)
        cell.titleLabel.text = self.newsParser.getTitle(index: index)
            
        return cell
    }
    
    // regular cell
    private func regularCell(index: Int) -> CellTextOnly {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "CellTextOnly") as! CellTextOnly
            
        cell.contentLabel.text = self.newsParser.getTitle(index: index)
        
        self.setFlag(imageView: cell.flagImageView, ID: newsParser.getCountryID(index: index))
        cell.sourceLabel.text = newsParser.getSource(index: index) + " - " + newsParser.getDate(index: index)
        
        var showMarkup = false
        cell.exclamationImageView.isHidden = true
        for M in newsParser.getMarkups(index: index) {
            let type = M.type.lowercased()
            if(!type.contains("prediction")){ showMarkup = true }
        }
        cell.exclamationImageView.isHidden = !showMarkup
        cell.updateIconsVisible()
        
        cell.miniSlidersView?.setValues(val1: newsParser.getLR(index: index),
                                            val2: newsParser.getPE(index: index),
                                            source: newsParser.getSource(index: index),
                                            countryID: newsParser.getCountryID(index: index))
        cell.miniSlidersView?.viewController = self
        
        return cell
    }
    
    // Footers
    func tableView(_ tableView: UITableView,
        heightForFooterInSection section: Int) -> CGFloat {
        
        let count = self.numberOfSections(in: self.tableView)
        if(section==0){
            if(self.param_A == 40) {
                return 310
            }
        
            var h: CGFloat = 115
            if(self.mustShowBanner() && BannerInfo.shared != nil) {
                let code = BannerInfo.shared!.adCode
                h += BannerView.getHeightForBannerCode(code)
            }
            return h
        } else if(section==count-1){
            return 290  // last footer, with ITN + share
        }
        
        return 70 // default plain footer
    }
    
    func tableView(_ tableView: UITableView,
        viewForFooterInSection section: Int) -> UIView? {
        
        if(self.param_A == 40) {
            // only 1 topic
            let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "FooterCellTextOnly1Topic" ) as! FooterCellTextOnly1Topic
            cell.delegate = self

            return cell
        }
        
        if(section==0) {
            // first footer, with horizontal menu
            
            let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "FooterCellTextOnlyItem0" ) as! FooterCellTextOnlyItem0
            
            cell.delegate = self
            cell.setTopic(self.newsParser.getTopic(index: section))

            if(self.mustShowBanner() && BannerInfo.shared != nil) {
                if(self.bannerView == nil) {
                    let h = self.tableView(self.tableView,
                        heightForFooterInSection: 0)
                
                    let code = BannerInfo.shared!.adCode
                    let bannerHeight = BannerView.getHeightForBannerCode(code)
    
                    self.bannerView = BannerView(posY: h - bannerHeight)
                }
                cell.contentView.addSubview(self.bannerView!)
            } else {
                if(self.bannerView != nil) {
                    self.bannerView!.removeFromSuperview()
                }
            }
            
            return cell
        } else {
            let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "FooterCellTextOnly" ) as! FooterCellTextOnly
    
            cell.delegate = self
            cell.setTopic(self.newsParser.getTopic(index: section))

            return cell
        }
    }
    
    // Tap on "More <topic>"
    func pushNewTopic(_ topic: String, sender: FooterCellTextOnly) {
        self.pushNewTopic(topic)
    }
    
    func pushNewTopic(_ topic: String, sender: FooterCellTextOnlyItem0) {
        self.pushNewTopic(topic)
    }
    
    // Tap on a cell
    func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        
        var start = 0
        for n in 0..<indexPath.section {
            start += newsParser.getArticleCountInSection(section: n)
        }
        let index = start + indexPath.row
        
        var link = newsParser.getURL(index: index)
        let title = newsParser.getTitle(index: index)
        let markups = newsParser.getMarkups(index: index)
        
        if(self.newsParser.getStory(index: index) == nil ) {
            // regular item
            let vc = WebViewController(url: link, title: title, annotations: markups)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            // story
//            let vc = PlainWebViewController(url: link, title: title)
//            navigationController?.pushViewController(vc, animated: true)

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
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.horizontalMenu.moveTo(y: scrollView.contentOffset.y)
    }
}

extension NewsTextViewController: BiasSliderDelegate, ShadeDelegate {

    // BiasSliderDelegate
    func splitValueChange() {
        if(!self.mustSplit()) {
            self.firstTime = true
            self.loadData()
            
            let offset = CGPoint(x: 0, y: 0)
            self.tableView.setContentOffset(offset, animated: true)
            self.horizontalMenu.backToZero()
        } else {
            DELAY(0.3) {
                Utils.shared.newsViewController_ID = 0
                let vc = NewsViewController(topic: self.topic)
                vc.param_A = self.param_A
                self.navigationController?.viewControllers = [vc]
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
    
    func biasSliderDidChange(sliderId: Int) {
    
        let dict = ["id": self.uniqueID]
        NotificationCenter.default.post(name: NOTIFICATION_RELOAD_NEWS_IN_OTHER_INSTANCES,
                                        object: nil,
                                        userInfo: dict)
        
        biasSliders.showLoading(true)
        
        DispatchQueue.main.async {
            /*
            self.loadArticles()
            self.reload()
            */
            self.firstTime = true
            self.loadData()

            DELAY(2.0) {
                if(sliderId == self.biasSliders.latestBiasSliderUsed) {
                    self.biasSliders.showLoading(false)
                }
            }
        }
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

}

extension NewsTextViewController: HorizontalMenuViewDelegate {
    func goToScrollView(atSection: Int) {
    
        var offset_y: CGFloat = 0
        for i in 1...atSection {
            if(i==1){
                let h = self.horizontalMenu.frame.size.height
                //offset_y += 70 + (100*4) + 115 - h
                offset_y += 70 + self.itemsHeight(section: i-1) + 115 - h
                
                if(self.mustShowBanner() && self.bannerView?.superview != nil) {
                    let code = BannerInfo.shared!.adCode
                    offset_y += BannerView.getHeightForBannerCode(code)
                }
                
                
            } else {
                //offset_y += 70 + (100*4) + 70
                offset_y += 70 + self.itemsHeight(section: i-1) + 70
            }
        }
        
        self.tableView.setContentOffset(CGPoint(x: 0, y: offset_y), animated: true)
    }
}

extension NewsTextViewController: BannerInfoDelegate {
    
    // Delegate
    func BannerInfoOnClose() {
        BannerInfo.shared?.active = false
        self.bannerView?.removeFromSuperview()
        self.tableView.reloadData()
        
    /*
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    */
    }
    
    // All banner related
    private func mustShowBanner() -> Bool {
        var result = false
        if let bannerInfo = BannerInfo.shared {
            if(bannerInfo.active && self.uniqueID==1) {
                result = true
            }
        }
        
        return result
    }
    
}

extension NewsTextViewController {

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


extension NewsTextViewController {

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

extension NewsTextViewController: OnBoardingViewDelegate {
    
    func onBoardingClose() {
        UserDefaults.standard.setValue("ABC", forKey: ONBOARDING_ID)
        UserDefaults.standard.synchronize()
    
        UIView.animate(withDuration: 0.4) {
            self.onBoard?.alpha = 0.0
        } completion: { _ in
            self.onBoard?.removeFromSuperview()
            self.onBoard = nil
        }
        
        AppUtility.lockOrientation(.all)
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
        DELAY(0.2) {
            self.configureBiasSliders()
        }
    }
}


// MARK: - Mini-button
extension NewsTextViewController {

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
        
        ENABLE_SPLIT_SHARING_AFTER_LOADING = true
        self.biasSliders.enableSplitForSharing()
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
    
}



