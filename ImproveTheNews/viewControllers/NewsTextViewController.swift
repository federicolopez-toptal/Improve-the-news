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
        Utils.shared.navController = self.navigationController
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
            
        if(SHOW_ONBOARD() && self.uniqueID==1) {
            self.onBoard = OnBoardingView(container: self.view, parser: self.newsParser)
            self.onBoard?.delegate = self
            
            if let obView = self.onBoard {
                obView.alpha = 0.0
                UIView.animate(withDuration: 0.4, delay: 1.0, options: .curveLinear) {
                    obView.alpha = 1.0
                } completion: { success in
                }
            }
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
    
    @objc private func reloadAll() {
        self.firstTime = true
        self.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = DARKMODE() ? .white : darkForBright
        navigationController?.navigationBar.barStyle = DARKMODE() ? .black : .default
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
    private func setUpHorizontalMenu() {
        self.view.addSubview(self.horizontalMenu)
        
        let margin: CGFloat = 0
        self.horizontalMenu.offset_y = CGFloat(70 + (100 * self.param_A)) + margin
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
        print("GATO999", self.uniqueID)
        DispatchQueue.main.async {
            self.setUpNavBar_2()
        }
    }
    
    @objc private func setUpNavBar_2() {
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
        
        //navigationController?.navigationBar.barStyle = .black
        let _textColor = DARKMODE() ? UIColor.white : textBlack
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PlayfairDisplay-SemiBold", size: 26)!, NSAttributedString.Key.foregroundColor: _textColor]

        let sectionsButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "hamburger"), style: .plain, target: self, action: #selector(self.sectionButtonItemClicked(_:)))

        let iconsMargin: CGFloat = 45.0

        let bellButton = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain,
            target: self, action: #selector(bellButtonTap(_:)) )
        bellButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: iconsMargin)

        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self,
            action: #selector(searchItemClicked(_:)))
            
        var userImage = UIImage(systemName: "person")
        if(MarkupUser.shared.userInfo != nil) {
            userImage = UIImage(systemName: "person.fill")
        }
            
        let userButton = UIBarButtonItem(image: userImage, style: .plain,
            target: self, action: #selector(userButtonTap(_:)) )
        userButton.imageInsets = UIEdgeInsets(top: 0, left: iconsMargin, bottom: 0, right: 0)

        var leftButtons: [UIBarButtonItem] = [sectionsButton]
        var rightButtons: [UIBarButtonItem] = [searchButton]

        if(APP_CFG_SHOW_MARKUPS && self.uniqueID==1) {
            leftButtons.append(bellButton)
            rightButtons.append(userButton)
        }
        
        
        navigationItem.leftBarButtonItems = leftButtons
        navigationItem.rightBarButtonItems = rightButtons

        /*
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchItemClicked(_:)))
        navigationItem.leftBarButtonItem = sectionsButton
        */
        navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        var logoFile = "ITN_logo.png"
        if(!DARKMODE()){ logoFile = "ITN_logo_blackText.png" }
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 165, height: 30))
        
        let img = UIImage(named: logoFile)?.withRenderingMode(.alwaysOriginal)
        let homeButton = UIButton(image: img!)
        
        var valX: CGFloat = 0
        let elementsSizeSum: CGFloat = (44*4)+195+(5*2)
        if(APP_CFG_SHOW_MARKUPS && self.uniqueID==1) {
            valX = ((view.frame.size.width - 195)/2) //- 10.0
            if(elementsSizeSum>=UIScreen.main.bounds.width) {
                valX -= 10.0
            }
        }
        
        self.addBadge()
        //homeButton.frame = CGRect(x: 0, y: 0, width: 195, height: 30)
        homeButton.frame = CGRect(x: valX, y: 0, width: 195, height: 30)
        homeButton.addTarget(self, action: #selector(homeButtonTapped),
                            for: .touchUpInside)
        
        view.addSubview(homeButton)
        view.center = navigationItem.titleView!.center
        self.navigationItem.titleView = view
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
    @objc func sectionButtonItemClicked(_ sender:UIBarButtonItem!) {
        if(self.onBoard == nil) {
            navigationController?.customPushViewController(SectionsViewController())
        }
    }
    
    @objc func searchItemClicked(_ sender:UIBarButtonItem!) {
        if(self.onBoard == nil) {
            let searchvc = SearchViewController()
            navigationController?.pushViewController(searchvc, animated: true)
        }
    }
    
    @objc func refresh(_ sender: UIRefreshControl!) {
        self.refresher.beginRefreshing()
        self.firstTime = true
        self.loadData()
    }
    
    @objc func homeButtonTapped() {
        if(self.onBoard == nil) {
            self.firstTime = true
            self.loadData()
            
            let offset = CGPoint(x: 0, y: 0)
            self.tableView.setContentOffset(offset, animated: true)
            self.horizontalMenu.backToZero()
        }
    }
    
    @objc func showBiasSliders(_ sender:UIButton!) {
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
            let topicAndCount = GET_TOPICARTICLESCOUNT(from: _vc)
            if(topicAndCount.0 == topicCode) {
                vc.param_S += topicAndCount.1
            }
        }

        navigationController?.pushViewController(vc, animated: true)
    }
    
}



extension NewsTextViewController: NewsDelegate {
    
    func resendRequest() {
        self.loadArticles()
    }
    
    func didFinishLoadData(finished: Bool) {
        self.hierarchy = newsParser.getHierarchy()
        self.loadingView.isHidden = true
        self.firstTime = false
        self.tableView.reloadData()
        self.stopRefresher()
        
        if BannerInfo.shared != nil {
            BannerInfo.shared?.delegate = self
        }
        self.horizontalMenu.setTopics(self.newsParser.getAllTopics())
        if(self.param_A != 40){
            self.horizontalMenu.isHidden = false
        }
        
        self.addParamsLabel()
        NotificationCenter.default.post(name: NOTIFICATION_FOR_ONBOARDING_NEWS_LOADED, object: nil)
    }
    
}


// MARK: - All tableView related
extension NewsTextViewController: UITableViewDelegate, UITableViewDataSource,
    HeaderCellTextOnlyDelegate, FooterCellTextOnlyDelegate,
    FooterCellTextOnlyItem0Delegate {
    
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
        let ac = UIActivityViewController(activityItems: ["http://www.improvethenews.org/"], applicationActivities: nil)
        self.present(ac, animated: true)
    }

    // Cells
    func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        
        return self.newsParser.getArticleCountInSection()[section]
    }
    
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "CellTextOnly") as! CellTextOnly
            
        var start = 0
        for n in 0..<indexPath.section {
            start += newsParser.getArticleCountInSection(section: n)
        }
        let index = indexPath.row + start
            
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
        
        return cell
    }
    
    // Footers
    func tableView(_ tableView: UITableView,
        heightForFooterInSection section: Int) -> CGFloat {
        
        let count = self.numberOfSections(in: self.tableView)
        if(section==0){
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
            return nil
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
        
        let vc = WebViewController(url: link, title: title, annotations: markups)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.horizontalMenu.moveTo(y: scrollView.contentOffset.y)
    }
}

extension NewsTextViewController: BiasSliderDelegate, ShadeDelegate {

    // BiasSliderDelegate
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
                offset_y += 70 + (100*4) + 115 - h
                
                if(self.mustShowBanner() && self.bannerView?.superview != nil) {
                    let code = BannerInfo.shared!.adCode
                    offset_y += BannerView.getHeightForBannerCode(code)
                }
                
                
            } else {
                offset_y += 70 + (100*4) + 70
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
    }
    
    @objc func showOnboardingAgain() {
        self.navigationController?.popViewController(animated: false)
        self.onBoard = OnBoardingView(container: self.view, parser: self.newsParser, skipFirstStep: true)
        self.onBoard?.delegate = self
    }
    
}
