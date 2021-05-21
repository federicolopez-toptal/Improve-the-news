//
//  NewsBigViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 12/05/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class NewsBigViewController: UIViewController {

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





    // MARK: - Initialization
    init(topic: String) {
        super.init(nibName: nil, bundle: nil)
        self.topic = topic
    }
    
    required init?(coder: NSCoder) {    // required
        fatalError()
    }
    
    override func viewDidLoad() {
        print("BIG!!!")
        
        Utils.shared.newsViewController_ID += 1
        self.uniqueID = Utils.shared.newsViewController_ID
    
        self.newsParser.newsDelegate = self
        self.biasSliders.sliderDelegate = self
        self.biasSliders.shadeDelegate = self
    
        self.view.backgroundColor = bgBlue
        self.setUpNavBar()
        self.setUpRefresh()
        self.setupTableView()
        self.setUpLoadingView()
        self.setUpHorizontalMenu()
        self.setUpBiasButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .white
        self.tableView.delaysContentTouches = false
        self.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!self.firstTime && !self.topicCodeFromSearch.isEmpty) {
            self.loadTopicFromSearch()
        }
    }
    
    // MARK: - UI
    private func setUpHorizontalMenu() {
        self.view.addSubview(self.horizontalMenu)
        
        let margin: CGFloat = 0
        self.horizontalMenu.offset_y = CGFloat(80 + (360 * self.param_A)) + margin
        self.horizontalMenu.moveTo(y: 0)
        self.horizontalMenu.isHidden = true
        self.horizontalMenu.customDelegate = self
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
        self.tableView.backgroundColor = bgBlue
        
        let headerNib = UINib(nibName: "HeaderCellBig", bundle: nil)
        self.tableView.register(headerNib,
            forHeaderFooterViewReuseIdentifier: "HeaderCellBig")
            
        let cellNib = UINib(nibName: "CellBig", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "CellBig")
        
        let footerNib = UINib(nibName: "FooterCellBig", bundle: nil)
        self.tableView.register(footerNib,
            forHeaderFooterViewReuseIdentifier: "FooterCellBig")
            
        let footerItem0Nib = UINib(nibName: "FooterCellBigItem0", bundle: nil)
        self.tableView.register(footerItem0Nib,
            forHeaderFooterViewReuseIdentifier: "FooterCellBigItem0")
        
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
        self.loadingView.isHidden = true
        self.loadingView.layer.cornerRadius = 15
    
        let loading = UIActivityIndicatorView(style: .medium)
        self.loadingView.addSubview(loading)
        loading.color = .white
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
        if let nav = navigationController {
            if(!nav.navigationBar.isTranslucent) {
                posY -= 88
            }
        }
        posY += mFrame.size.height
        
        let margin: CGFloat = 6
        let status = self.biasSliders.status
        
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
        navigationController?.customPushViewController(SectionsViewController())
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
        let offset = CGPoint(x: 0, y: 0)
        self.tableView.setContentOffset(offset, animated: true)
        self.horizontalMenu.backToZero()
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
        
        let link = API_CALL(topicCode: T, abs: ABS,
                            biasStatus: self.biasSliders.status,
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
        
        var topicName = ""
        for (key, value) in Globals.topicmapping {
            if(value == topicCode) {
                topicName = key
                break
            }
        }
        var count = -1
        if(!topicName.isEmpty) {
            count = newsParser.getSubTopicCountFor(topic: topicName)
        }
    
        let vc = NewsBigViewController(topic: topicCode)
        vc.param_A = 4
        vc.param_S = 4 // sumar 4? o 4 fijo?
        if(count == 0) {
            vc.param_A = 40
        }
        
        if(Utils.shared.didTapOnMoreLink) { //} && topicCode=="news") {
            vc.param_A = 10
        }
        Utils.shared.didTapOnMoreLink = false
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}



extension NewsBigViewController: NewsDelegate {
    
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
    }
    
}


// MARK: - All tableView related
extension NewsBigViewController: UITableViewDelegate, UITableViewDataSource,
    HeaderCellBigDelegate, FooterCellBigDelegate,
    FooterCellBigItem0Delegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.newsParser.getNumOfSections()
    }
    
    // Headers
    func tableView(_ tableView: UITableView,
        heightForHeaderInSection section: Int) -> CGFloat {
        
        return 80
    }
    
    func tableView(_ tableView: UITableView,
        viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderCellBig" ) as! HeaderCellBig

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
    func pushNewTopic(_ topic: String, sender: HeaderCellBig) {
        self.pushNewTopic(topic)
    }
    
    // Tap on share
    func shareTapped(sender: FooterCellBig) {
        let ac = UIActivityViewController(activityItems: ["http://www.improvethenews.org/"], applicationActivities: nil)
        self.present(ac, animated: true)
    }

    // Cells
    func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 360
    }
    
    func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        
        return self.newsParser.getArticleCountInSection()[section]
    }
    
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "CellBig") as! CellBig
            
        var start = 0
        for n in 0..<indexPath.section {
            start += newsParser.getArticleCountInSection(section: n)
        }
        let index = indexPath.row + start
            
        cell.contentLabel.text = self.newsParser.getTitle(index: index)
        self.setFlag(imageView: cell.flagImageView, ID: newsParser.getCountryID(index: index))
        cell.sourceLabel.text = newsParser.getSource(index: index) + " - " + newsParser.getDate(index: index)
        
        cell.exclamationImageView.isHidden = true
        if newsParser.getMarkups(index: index).count > 0 {
            cell.exclamationImageView.isHidden = false
        }
        
        let imageURL = newsParser.getIMG(index: index)
        DispatchQueue.main.async {
            cell.mainPic.contentMode = .scaleAspectFill
            cell.mainPic.sd_setImage(with: URL(string: imageURL), placeholderImage: nil)
        }
        
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
            
            let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "FooterCellBigItem0" ) as! FooterCellBigItem0
            
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
            let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "FooterCellBig" ) as! FooterCellBig
    
            cell.delegate = self
            cell.setTopic(self.newsParser.getTopic(index: section))

            return cell
        }
    }
    
    // Tap on "More <topic>"
    func pushNewTopic(_ topic: String, sender: FooterCellBig) {
        self.pushNewTopic(topic)
    }
    
    func pushNewTopic(_ topic: String, sender: FooterCellBigItem0) {
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

extension NewsBigViewController: BiasSliderDelegate, ShadeDelegate {

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

extension NewsBigViewController: HorizontalMenuViewDelegate {
    func goToScrollView(atSection: Int) {
    
        var offset_y: CGFloat = 0
        for i in 1...atSection {
            if(i==1){
                let h = self.horizontalMenu.frame.size.height
                offset_y += 80 + (360*4) + 115 - h
                
                if(self.mustShowBanner() && self.bannerView?.superview != nil) {
                    let code = BannerInfo.shared!.adCode
                    offset_y += BannerView.getHeightForBannerCode(code)
                }
                
                
            } else {
                offset_y += 80 + (360*4) + 70
            }
        }
        
        self.tableView.setContentOffset(CGPoint(x: 0, y: offset_y), animated: true)
    }
}

extension NewsBigViewController: BannerInfoDelegate {
    
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
