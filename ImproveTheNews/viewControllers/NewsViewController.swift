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


class NewsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout,
    NewsDelegate {

    let newsParser = News()                 // parser

    // components
    let searchBar = UISearchBar()           // searchBar
    var refresher: UIRefreshControl!        // pull to refresh
    let biasSliders = SliderPopup()         // Preferences (orange) panel
    let loadingView = UIView()              // loading with activityIndicator inside
    
    // to populate CollectionView
    //changed home link from "http://www.improvethenews.org/itnserver.php/?topic=" to this one
    //let homelink = "http://ec2-user@ec2-3-16-51-0.us-east-2.compute.amazonaws.com/appserver.php/?topic="
    let homelink = "https://www.improvethenews.org/appserver.php/?topic="
    
    var mainTopic = "Headlines"
    var topic = ""                          // current topic, set at the beginning
    var hierarchy = ""                      // hierarchy (path)
    var superSliderStr = ""                 // para armar el request
    
    // --------------------------------------------------------
    // horizontal menu
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
    let pieChartVC = PieChartViewController()
    
    let shadeView = UIView()
    var biasButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "prefsButton.png"), for: .normal)
        button.addTarget(self, action: #selector(showBiasSliders(_:)), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    
    
    
    
    // DELETE LATER (!!!)
    var topicSliders = TopicSliderPopup()   // pie chart screen
    var topicTopAnchorHidden: NSLayoutConstraint?
    var topicTopAnchorVisible: NSLayoutConstraint?
    var topicBottomAnchor: NSLayoutConstraint?
    var sliderValues: SliderValues!
    
    
    
    



    // MARK: - Initialization
    init(topic: String) {
        let layout = UICollectionViewFlowLayout.init()
        super.init(collectionViewLayout: layout)
        self.topic = topic
    }
    
    required init?(coder: NSCoder) {    // by default
        fatalError()
    }
    
    override func viewDidLoad() {
        overrideUserInterfaceStyle = .dark
                
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        newsParser.newsDelegate = self
        sliderValues = SliderValues.sharedInstance //!!!
        biasSliders.sliderDelegate = self
        biasSliders.shadeDelegate = self
        
        topicSliders.dismissDelegate = self //!!!
        topicSliders.sliderDelegate = self  //!!!
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNews),
            name: UIApplication.willEnterForegroundNotification, object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAll),
            name: NOTIFICATION_FORCE_RELOAD_NEWS,
            object: nil)
       
        // collectionView, register cells
        self.collectionView.register(SubtopicHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SubtopicHeader.headerId)
        self.collectionView.register(FAQFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FAQFooter.footerId)
        self.collectionView.register(seeMoreFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: seeMoreFooter.footerId)
        self.collectionView.register(seeMoreFooterSection0.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: seeMoreFooterSection0.footerId)
        self.collectionView.register(seeMoreFooterLast.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: seeMoreFooterLast.footerId)
        self.collectionView.register(ArticleCell.self, forCellWithReuseIdentifier: ArticleCell.cellId)
        self.collectionView.backgroundColor = .systemBackground
        self.collectionView.register(ArticleCellHalf.self, forCellWithReuseIdentifier: ArticleCellHalf.cellId)
        self.collectionView.register(HeadlineCell.self, forCellWithReuseIdentifier: HeadlineCell.cellId)
        self.collectionView.register(ArticleCellAlt.self, forCellWithReuseIdentifier: ArticleCellAlt.cellId)
        
        
        // intialize some anchors !!!
        topicTopAnchorHidden = topicSliders.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        topicTopAnchorVisible = topicSliders.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        topicBottomAnchor = topicSliders.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        setUpNavBar()
        configureBiasButton()
        configureTopicButton() //!!!
        setUpRefresh()
        setUpActivityIndicator()
        
        self.moreHeadLines.initialize(width: self.screenWidth)
        self.view.addSubview(self.moreHeadLines)
        self.moreHeadLines.delegate = self
        self.moreHeadLines.hide()
        
        self.view.backgroundColor = bgBlue
        self.collectionView.backgroundColor = bgBlue
        
        pieChartVC.delegate = self
        
        /*
        //testing height(s)
        let redView = UIView(frame: CGRect(x: 20, y: 666 + 681, width: 100, height: 20))
        redView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        self.collectionView.addSubview(redView)
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = accentOrange
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
    }
    

    // MARK: - Data loading
    func loadData() {
        if(self.firstTime){
            //activityIndicator.startAnimating()
            self.loadingView.isHidden = false
            
            //DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            DispatchQueue.main.async {
                self.loadArticles()
                self.reload()
                self.updateTopicSliders()
                if Globals.isSliderOn {
                    self.configureBiasSliders()
                }
                
                DELAY(2.0) {
                    self.loadingView.isHidden = true
                    self.firstTime = false
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
            self.newsParser.getJSONContents(jsonName: link)
        }
    }
    
    private func buildApiCall_b() -> String {
        let link = "topic=\(self.topic)" +
            ".A\(self.param_A)" + ".B\(self.param_B)" +
            ".S\(self.param_S)"
            
        return link
    }
    
    private func buildApiCall() -> String {

        let firsthalf = self.homelink + self.topic +
            ".A\(self.param_A)" + ".B\(self.param_B)" +
            ".S\(self.param_S)"
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
            link += deviceId
        }
            
        return link
    }
    
    func reload() {
        print("reload?")
        self.collectionView.reloadData()
        
        self.hierarchy = ""
        self.hierarchy = newsParser.getHierarchy()
    }
    
    // For NewsDelegate protocol
    func didFinishLoadData(finished: Bool) {
        
        if BannerInfo.shared != nil {
            BannerInfo.shared?.delegate = self
        }
        
        guard finished else {
            print("Could not load data")
            return
        }
        
        self.resetTopicSliders()
        
        updateTopicSliders()
        reload()

        self.moreHeadLines.setTopics(self.newsParser.getAllTopics())
        
        UIView.animate(withDuration: 0.5, animations: {
            self.collectionView.contentOffset.y = 0
        })
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
        self.loadingView.isHidden = true
        self.loadingView.layer.cornerRadius = 15
    
        let loading = UIActivityIndicatorView(style: .medium)
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
    
    private func setUpNavBar() {

        searchBar.sizeToFit()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.textColor = .black
        searchBar.tintColor = .black

        let logo = UIImage(named: "N64")
        let titleView = UIImageView(image: logo)
        titleView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleView

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barTintColor = bgBlue
        navigationController?.navigationBar.backgroundColor = bgBlue
        navigationController?.navigationBar.barTintColor = bgBlue
        navigationController?.navigationBar.barTintColor = bgBlue
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PlayfairDisplay-SemiBold", size: 26)!, NSAttributedString.Key.foregroundColor: UIColor.white]

        let sectionsButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "hamburger"), style: .plain, target: self, action: #selector(self.sectionButtonItemClicked(_:)))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchItemClicked(_:)))
        navigationItem.leftBarButtonItem = sectionsButton
        navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 195, height: 30))
        let img = UIImage(named: "ITN_logo.png")?.withRenderingMode(.alwaysOriginal)
        let homeButton = UIButton(image: img!)
        homeButton.frame = CGRect(x: 0, y: 0, width: 195, height: 30)
        homeButton.addTarget(self, action: #selector(homeButtonTapped),
                            for: .touchUpInside)
        //homeButton.isUserInteractionEnabled = false
        
        /*
        let label = UILabel.init(frame: CGRect(x: 35, y: 5, width: 180, height: 20))
        label.text = "IMPROVE THE NEWS"
        label.font = UIFont(name: "OpenSans-Bold", size: 17)
        label.textColor = .white
        label.textAlignment = .left
        //label.center.y = view.center.y
        */
        
        view.addSubview(homeButton)
        //view.addSubview(label)
        view.center = navigationItem.titleView!.center
        self.navigationItem.titleView = view
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
        if let firstVC = navigationController?.viewControllers.first as? NewsViewController {
            if(firstVC == self) {
                // I'm in the first screen
                if(self.topic == "news") {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.collectionView.contentOffset.y = 0
                    })
                } else {
                    self.firstTime = true
                    self.topic = "news"
                    self.loadData()
                }
            } else {
                let newsVC = navigationController!.viewControllers[0] as! NewsViewController
                
                if(newsVC.topic == "news") {
                    newsVC.collectionView.contentOffset.y = 0
                } else {
                    newsVC.firstTime = true
                    newsVC.topic = "news"
                }
                navigationController!.popToRootViewController(animated: true)
        }
    }}
    
    @objc func searchItemClicked(_ sender:UIBarButtonItem!) {
        let searchvc = SearchViewController()
        navigationController?.pushViewController(searchvc, animated: true)
    }

    @objc func sectionButtonItemClicked(_ sender:UIBarButtonItem!) {
        navigationController?.customPushViewController(SectionsViewController())
    }
    
    // MARK: - misc
    @objc func refreshNews() {
        self.viewWillAppear(false)
    }
    
    @objc func reloadAll() {
        self.firstTime = true
        self.loadData()
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
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
    
        let mainTopic = newsParser.getTopic(index: 0)
        let mainTopic_B = Globals.topicmapping[mainTopic]!
        let subTopicsCount = newsParser.getNumOfSections()
        
        let vc = NewsViewController(topic: newTopic)
        
        vc.param_S = 4 // sumar 4? o 4 fijo?
        if newTopic == mainTopic_B {
            if(subTopicsCount==1) {
                vc.param_A = 40
            }
        } else {
            
        }
        
        if(Utils.shared.didTapOnMoreLink && newTopic=="news") {
            vc.param_A = 10
        }
        Utils.shared.didTapOnMoreLink = false

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
        posY += size.height - self.biasSliders.state01_height + 15
        
        biasButton.frame = CGRect(x: posX, y: posY,
                                width: size.width, height: size.height)
        //biasButton.layer.cornerRadius = size * 0.5
        let y = view.frame.height - self.biasSliders.state01_height
        biasSliders.frame = CGRect(x: 0, y: y, width: view.frame.width, height: 550) //470
        
        biasSliders.buildViews()
        self.biasSliders.status = "SL00"
        self.updateBiasButtonPosition()
    }
    
    func updateBiasButtonPosition() {
        var mFrame = self.biasButton.frame
        let screenSize = UIScreen.main.bounds
        
        var posY = screenSize.height - mFrame.size.height
        if let nav = navigationController {
            if(!nav.navigationBar.isTranslucent) {
                posY -= 88
            }
        }
        posY += mFrame.size.height
        
        let margin: CGFloat = 6
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
            posY -= self.biasSliders.state02_height - margin
        } else {
            posY -= self.biasSliders.state01_height - margin
        }
        
        mFrame.origin.y = posY
        self.biasButton.frame = mFrame
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
                
                /*
                self.biasSliders.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.biasSliders.frame.height)
                */
                
            }, completion: nil)
        
        self.biasButton.superview?.bringSubviewToFront(self.biasButton)
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
        if !Globals.isSliderOn {
            Globals.isSliderOn = true
        }
        
        if(self.biasSliders.status == "SL00") {
            configureBiasSliders()
        } else {
            self.biasSliders.handleDismiss()
        }
    }
    
    // For BiasSliderDelegate protocol
    func biasSliderDidChange(sliderId: Int) {
        
        //biasSliders.activityView.startAnimating()
        biasSliders.showLoading(true)
        
        DispatchQueue.main.async {
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

// MARK: Pie chart
extension NewsViewController: PieChartViewControllerDelegate {
    
    func showPieChart() {
        //self.pieChartVC.modalPresentationStyle = .fullScreen
        if(!self.pieChartVC.isBeingPresented) {
            self.pieChartVC.set(topics: newsParser.getAllTopics(),
                        popularities: newsParser.getPopularities())
        
            self.present(self.pieChartVC, animated: true) {
            }
        }
    }
    
    // For protocol PieChartViewControllerDelegate
    func someValueDidChange() {
        self.firstTime = true
        self.loadData()
    }
}


// MARK: Topic sliders
extension NewsViewController: TopicSliderDelegate, dismissTopicSlidersDelegate {
    
    func showTopicSliders() {
        // Tap on a pie chart button
        self.showPieChart()
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
        present(ac, animated: true)
    }

}

extension NewsViewController: BannerInfoDelegate {

    func BannerInfoOnClose() {
        self.reload()
    }
    
}

extension NewsViewController {

    // MARK: - Collection view (data source + layout)
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var start = 0
        for n in 0..<indexPath.section {
            start += newsParser.getArticleCountInSection(section: n)
        }
        
        let index = indexPath.row + start
        
        if index < newsParser.getLength() {
            //print("section: \(indexPath.section) row \(indexPath.row): \(newsParser.getTitle(index: indexPath.row+start))")
            
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeadlineCell.cellId, for: indexPath) as! HeadlineCell
                
                cell.setupViews()
                
                cell.headline.text = newsParser.getTitle(index: index)
                cell.pubDate.text = newsParser.getDate(index: index)
                let imageURL = newsParser.getIMG(index: index)
                //let imgURL = URL(string: imageURL)!
                DispatchQueue.global().async {
                    //guard let data = try? Data(contentsOf: imgURL) else { return }
                    DispatchQueue.main.async {
                        print("loading cell images")
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
                
                if newsParser.getMarkups(index: index).count > 0 {
                    cell.markupView.isHidden = false
                }
                
                //cell.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                cell.miniSlidersView?.setValues(val1: newsParser.getLR(index: index),
                                                val2: newsParser.getPE(index: index))
                self.setFlag(imageView: cell.flag, ID: newsParser.getCountryID(index: index))
                
                return cell
            }
                
            else if indexPath.row == 0 || indexPath.row == 1 {
                                
                // text on left
                if indexPath.section % 2 == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCell.cellId, for: indexPath) as! ArticleCell
                    
                    cell.setupViews()
                    
                    cell.headline.text = newsParser.getTitle(index: indexPath.row+start)
                    cell.pubDate.text = newsParser.getDate(index: indexPath.row+start)
                    let imageURL = newsParser.getIMG(index: indexPath.row+start)
//                    let imgURL = URL(string: imageURL)!
                    DispatchQueue.global().async {
                        //guard let data = try? Data(contentsOf: imgURL) else { return }
                        DispatchQueue.main.async {
                            print("loading cell images")
//                            let img = UIImage(data: data)
//                            let rescaled = img?.scalePreservingAspectRatio(targetSize: CGSize(width: 190, height: 120))
                            cell.imageView.contentMode = .scaleAspectFill
                            cell.imageView.sd_setImage(with: URL(string: imageURL), placeholderImage: nil)
//                            cell.imageView.image = rescaled
                        }
                    }
                    
                    let i = indexPath.row+start
                    cell.source.lineBreakMode = .byWordWrapping
                    cell.source.text = newsParser.getSource(index: i) + " - " + newsParser.getDate(index: i)
                    cell.source.numberOfLines = 2
                    //cell.source.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
                    cell.pubDate.text = " "
                    //cell.source.text = newsParser.getSource(index: indexPath.row+start)
                    
                    if newsParser.getMarkups(index: index).count > 0 {
                        cell.markupView.isHidden = false
                    }
                    
                    cell.miniSlidersView?.setValues(val1: newsParser.getLR(index: index),
                                                val2: newsParser.getPE(index: index))
                    self.setFlag(imageView: cell.flag, ID: newsParser.getCountryID(index: index))
                    return cell
                    
                }
                // text on right
                else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCellAlt.cellId, for: indexPath) as! ArticleCellAlt
                    
                    
                    cell.setupViews()
                    
                    cell.headline.text = newsParser.getTitle(index: indexPath.row+start)
                    cell.pubDate.text = newsParser.getDate(index: indexPath.row+start)
                    cell.imageView.image = nil
                    let imageURL = newsParser.getIMG(index: indexPath.row+start)
                    //let imgURL = URL(string: imageURL)!
                    DispatchQueue.global().async {
                        //guard let data = try? Data(contentsOf: imgURL) else { return }
                        DispatchQueue.main.async {
                            print("loading cell images")
//                            let img = UIImage(data: data)
//                            let rescaled = img?.scalePreservingAspectRatio(targetSize: CGSize(width: 190, height: 120))
                            cell.imageView.contentMode = .scaleAspectFill
                            cell.imageView.sd_setImage(with: URL(string: imageURL), placeholderImage: nil)
                            //cell.imageView.image = rescaled
                        }
                    }
                    
                    let i = indexPath.row+start
                    cell.source.lineBreakMode = .byWordWrapping
                    cell.source.text = newsParser.getSource(index: i) + " - " + newsParser.getDate(index: i)
                    cell.source.numberOfLines = 2
                    //cell.source.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
                    cell.pubDate.text = " "
                    //cell.source.text = newsParser.getSource(index: i)
                    
                    if newsParser.getMarkups(index: index).count > 0 {
                        cell.markupView.isHidden = false
                    }
                    
                    cell.miniSlidersView?.setValues(val1: newsParser.getLR(index: index),
                                                val2: newsParser.getPE(index: index))
                    self.setFlag(imageView: cell.flag, ID: newsParser.getCountryID(index: index))
                    return cell
                }
               
            }
            // 2 column cells
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCellHalf.cellId, for: indexPath) as! ArticleCellHalf

                cell.setupViews()
                
                cell.headline.text = newsParser.getTitle(index: indexPath.row+start)
                cell.pubDate.text = newsParser.getDate(index: indexPath.row+start)
                 
                let imageURL = newsParser.getIMG(index: indexPath.row+start)
               // let imgURL = URL(string: imageURL)!
                DispatchQueue.global().async {
                    //guard let data = try? Data(contentsOf: imgURL) else { return }
                    DispatchQueue.main.async {
                        print("loading cell images")
//                        let img = UIImage(data: data)
//                        let rescaled = img?.scalePreservingAspectRatio(targetSize: CGSize(width: 190, height: 120))
                        cell.imageView.contentMode = .scaleAspectFill
                        cell.imageView.sd_setImage(with: URL(string: imageURL), placeholderImage: nil)
//                        cell.imageView.image = rescaled
                    }
                }
                
                let i = indexPath.row+start
                cell.source.lineBreakMode = .byWordWrapping
                cell.source.text = newsParser.getSource(index: i) + " - " + newsParser.getDate(index: i)
                cell.source.numberOfLines = 2
                //cell.source.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
                cell.pubDate.text = " "
                
                
                
                //cell.source.text = newsParser.getSource(index: indexPath.row+start)
                
                
                if newsParser.getMarkups(index: index).count > 0 {
                    cell.markupView.isHidden = false
                }
                
                cell.miniSlidersView?.setValues(val1: newsParser.getLR(index: index),
                                                val2: newsParser.getPE(index: index))
                self.setFlag(imageView: cell.flag, ID: newsParser.getCountryID(index: index))
                cell.adjust()
                
                return cell
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
        
        
        var h: CGFloat = 120
        /*
        let iPath = IndexPath(item: 0, section: section)
        let cell = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: iPath) as! SubtopicHeader
        */
        
        let kind = UICollectionView.elementKindSectionHeader
        let iPath = IndexPath(row: 0, section: section)
        if let header = self.collectionView(self.collectionView,
                        viewForSupplementaryElementOfKind: kind,
                        at: iPath) as? SubtopicHeader {
            
            if(header.hierarchy.text == "  ") {
                h -= 20
            }
            
            if(header.prioritySlider.isHidden) {
                h -= 29
            }
            
            
            if(section>0) {
                h -= 20
            }
        }
        
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
            return CGSize(width: view.frame.width, height: 260)
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
                        let count = self.navigationController!.viewControllers.count
                        if(bannerInfo.active && count==1) {
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
        
        // one topic on page
        if newsParser.getNumOfSections() == 1 && indexPath.section == 1 {
            return .zero
        }
        
        // headlines
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
        
        var link = ""
        if newsParser.getAMPStatus(index: index) == true {
            //link = newsParser.getAMPURL(index: index)
            link = newsParser.getURL(index: index)
        } else {
            link = newsParser.getURL(index: index)
        }
        
        let title = newsParser.getTitle(index: index)
        
        let markups = newsParser.getMarkups(index: index)
        //let markups = [ Markups(type: "T", description: "abc", link: "http://www.google.com") ]
       
        let vc = WebViewController(url: link, title: title, annotations: markups)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
            case UICollectionView.elementKindSectionHeader:
                let kind = UICollectionView.elementKindSectionHeader
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
                
                
                /*
                var popularity: Float = 0
                if(newsParser.getPopularities().count==0) {
                    popularity = 0
                } else if(indexPath.section<0 || indexPath.section>=self.newsParser.getPopularities().count) {
                    popularity = 0
                } else {
                    popularity = newsParser.getPopularities()[indexPath.section]
                }
                sectionHeader.updateSuperSlider(num: popularity)
                */
                
                //print("GATO", section, popularity)
                
                
                if indexPath.section == 0 {
                    sectionHeader.label.titleLabel?.font = UIFont(name: "PTSerif-Bold", size: 40)
                    //sectionHeader.label.heightAnchor.constraint(equalToConstant: 36).isActive = true
                } else {
                    sectionHeader.label.titleLabel?.font = UIFont(name: "PTSerif-Bold", size: 30)
                    //sectionHeader.label.heightAnchor.constraint(equalToConstant: 20).isActive = true
                }
                                
                // no super sliders on main page
                if self.topic == "news" {
                    sectionHeader.prioritySlider.isHidden = true
                }
                
                // no topic sliders on childless topics
                if newsParser.getAllTopics().count == 1 {
                    sectionHeader.topicSlidersButton.isHidden = true
                }
                
                /*
                // breadcrumbs
                if indexPath.section == 0 {
                    sectionHeader.hierarchy.text = ""
                } else {
                    
                    sectionHeader.hierarchy.text = self.hierarchy + newsParser.getTopic(index: indexPath.section)
                    
                    
                    // Example: Headlines>Money>Industries>Marketing>whateEver
                    
                    /*
                    var text = ""
                    let components = self.hierarchy.components(separatedBy: ">")
                    if(components.count > 1) {
                        text = components[components.count-2] + ">"
                    }
                    text += newsParser.getTopic(index: indexPath.section)
                    sectionHeader.hierarchy.text = text
                    
                    */
                    
                    sectionHeader.hierarchy.adjustsFontSizeToFitWidth = true
                }
                */
                
                /*
                if indexPath.section == 0 {
                    if self.hierarchy == "Headlines>" {
                        sectionHeader.hierarchy.text = ""
                    } else {
                        sectionHeader.hierarchy.text = String(self.hierarchy.dropLast())
                        hArray.append(sectionHeader.hierarchy.text!)
                    }
                } else {
                    sectionHeader.hierarchy.text = self.hierarchy + newsParser.getTopic(index: indexPath.section)
                    sectionHeader.hierarchy.adjustsFontSizeToFitWidth = true
                    hArray.append(sectionHeader.hierarchy.text!)
                    
//                    var label = UILabel(text: "hey", font: .systemFont(ofSize: 12), textColor: .white, textAlignment: .left, numberOfLines: 1)
//                    var label2 = UILabel(text: "hey", font: .systemFont(ofSize: 12), textColor: .white, textAlignment: .left, numberOfLines: 1)
//                    sectionHeader.myStack.addArrangedSubview(label)
//                    sectionHeader.myStack.addArrangedSubview(label2)
                    //sectionHeader.setUpStackView(atIndex: sectionHeader.tag)
                }
                */
                
                var breadcrumbText = ""
                if(indexPath.section==0 && self.hierarchy == "Headlines>") {
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

                
                
                
                /*
                    if self.hierarchy == "Headlines>" {
                        
                    } else {
                        breadcrumbText = String(self.hierarchy.dropLast())
                        hArray.append(breadcrumbText)
                    }
                    hArray.append(breadcrumbText)
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
                */
                
                
                /*
                let components = self.hierarchy.components(separatedBy: ">")
                    if(components.count > 1) {
                        text = components[components.count-2] + ">"
                    }
                    text += newsParser.getTopic(index: indexPath.section)
                */
                
                sectionHeader.backgroundColor = bgBlue
                
                
                //sectionHeader.backgroundColor  = UIColor.yellow.withAlphaComponent(0.25) //!!!
                return sectionHeader
                
            
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
                        return pageFooter
                    } else {
                        let seeMore = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: seeMoreFooterLast.footerId, for: indexPath) as! seeMoreFooterLast
                        seeMore.delegate = self
                        seeMore.setFooterText(subtopic: newsParser.getTopic(index: indexPath.section))
                        seeMore.configure()
                        seeMore.configure2()
                        seeMore.shareDelegate = self
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
                        return seeMore
                    } else {
                        let seeMore = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: seeMoreFooterSection0.footerId, for: indexPath) as! seeMoreFooterSection0
                    
                        seeMore.delegate = self
                        seeMore.topics = newsParser.getAllTopics()
                        // aMore
                        seeMore.setFooterText(subtopic: newsParser.getTopic(index: indexPath.section))
                        seeMore.configure()
                        
                        let count = self.navigationController!.viewControllers.count
                        if(count==1 && BannerInfo.shared != nil){
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
                        
                        return seeMore
                    }
                
                    
                } else {
                    // no FAQ footer unless last section
                    let seeMore = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: seeMoreFooter.footerId, for: indexPath) as! seeMoreFooter
                    seeMore.delegate = self
                    // oMore
                    seeMore.setFooterText(subtopic: newsParser.getTopic(index: indexPath.section))
                    seeMore.configure()
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
    func scrollTheNewsTo(_ index: Int) {
        //let indexPath = IndexPath(item: 0, section: 0)
        /*if let cell = self.collectionView.cellForItem(at: indexPath) {
            self.collectionView.scrollRectToVisible(cell.frame, animated: true)
        }
        */
        
        var offsetY: CGFloat = 0
        var firstItemHeight: CGFloat = 666 + 8
        if let info = BannerInfo.shared {
            let count = self.navigationController!.viewControllers.count
            if(count==1 && info.active) {
                firstItemHeight += BannerView.getHeightForBannerCode(info.adCode)
            }
        }
        
        //736-20-20-20
        let otherItemsHeight: CGFloat = 681 + 8 //861-20-20-30-100-20
        let slidersHeight: CGFloat = 29
        
        if(index>0) {
            offsetY += firstItemHeight

            let i = CGFloat(index-1)

            if(self.topic=="news") { // No sliders in header
                offsetY += otherItemsHeight * i
            } else {
                offsetY += 49
                offsetY += (otherItemsHeight+slidersHeight) * i
            }
            offsetY += -52 // margin
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
                
                self.moreHeadLines.show()
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


/*
var headers = [String]()


    var artfreq = ".A4"
    var untouchables = ".B4.S0"
    var sliderPrefs = ""
    
    
    var activityIndicator = UIActivityIndicatorView()

 */
