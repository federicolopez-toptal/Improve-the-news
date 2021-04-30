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
    let tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
    var refresher: UIRefreshControl!        // pull to refresh
    let biasSliders = SliderPopup()         // Preferences (orange) panel
    let loadingView = UIView()              // loading with activityIndicator inside



    var biasButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "prefsButton.png"), for: .normal)
        //button.addTarget(self, action: #selector(showBiasSliders(_:)), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()







    // MARK: - Initialization
    init(topic: String) {
        super.init(nibName: nil, bundle: nil)
        self.topic = topic
    }
    
    required init?(coder: NSCoder) {    // required
        fatalError()
    }
    
    override func viewDidLoad() {
        Utils.shared.newsViewController_ID += 1
        self.uniqueID = Utils.shared.newsViewController_ID
    
        self.newsParser.newsDelegate = self
    
        self.view.backgroundColor = bgBlue
        self.setUpNavBar()
        self.setUpRefresh()
        self.setupTableView()
        self.setUpLoadingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = accentOrange
        self.tableView.delaysContentTouches = false
        self.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!self.firstTime && !self.topicCodeFromSearch.isEmpty) {
            self.loadTopicFromSearch()
        }
    }
    
    // MARK: - UI
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
        
        let headerNib = UINib(nibName: "HeaderCellTextOnly", bundle: nil)
        self.tableView.register(headerNib,
            forHeaderFooterViewReuseIdentifier: "HeaderCellTextOnly")
            
        let cellNib = UINib(nibName: "CellTextOnly", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "CellTextOnly")
        
        let footerNib = UINib(nibName: "FooterCellTextOnly", bundle: nil)
        self.tableView.register(footerNib,
            forHeaderFooterViewReuseIdentifier: "FooterCellTextOnly")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
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
    
        let vc = NewsTextViewController(topic: topicCode)
        vc.param_A = 4
        vc.param_S = 4 // sumar 4? o 4 fijo?
        if(count == 0) {
            vc.param_A = 40
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
    }
    
}



extension NewsTextViewController: UITableViewDelegate, UITableViewDataSource,
    HeaderCellTextOnlyDelegate, FooterCellTextOnlyDelegate {
    
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
        
        cell.exclamationImageView.isHidden = true
        if newsParser.getMarkups(index: index).count > 0 {
            cell.exclamationImageView.isHidden = false
        }
        
        return cell
    }
    
    // Footers
    func tableView(_ tableView: UITableView,
        heightForFooterInSection section: Int) -> CGFloat {
        
        return 70
    }
    
    func tableView(_ tableView: UITableView,
        viewForFooterInSection section: Int) -> UIView? {
        
        if(self.param_A == 40) {
            return nil
        }
        
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "FooterCellTextOnly" ) as! FooterCellTextOnly
        
        cell.delegate = self
        cell.setTopic(self.newsParser.getTopic(index: section))

        return cell
    }
    
    // Tap on "More <topic>"
    func pushNewTopic(_ topic: String, sender: FooterCellTextOnly) {
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
}
