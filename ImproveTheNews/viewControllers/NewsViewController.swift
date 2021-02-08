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

class NewsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let group = DispatchGroup()
    
    // key UI elements
    let searchBar = UISearchBar()
    let newsParser = News()
    var sliderValues: SliderValues!
    var headers = [String]()
    
    // to populate CollectionView
    //changed home link from "http://www.improvethenews.org/itnserver.php/?topic=" to this one
    let homelink = "http://ec2-user@ec2-3-16-51-0.us-east-2.compute.amazonaws.com/appserver.php/?topic="
    var topic = ""
    var artfreq = ".A4"
    var untouchables = ".B4.S0"
    var sliderPrefs = ""
    var hierarchy = ""
    var mainTopic = "Headlines"
    var refresher: UIRefreshControl!
    
    var activityIndicator = UIActivityIndicatorView()
    
    // bias sliders button + view
    var biasButton: UIButton = {
        let button = UIButton(image: UIImage(named: "sliders")!)
        button.backgroundColor = accentOrange
        button.tintColor = .white
        button.addTarget(self, action: #selector(showBiasSliders(_:)), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    let biasSliders = SliderPopup()
    let slidersHeight: CGFloat = 220
    let shadeView = UIView()
    
    // topic sliders
    let topicSliders = TopicSliderPopup()
    var topicTopAnchorHidden: NSLayoutConstraint?
    var topicTopAnchorVisible: NSLayoutConstraint?
    var topicBottomAnchor: NSLayoutConstraint?
    
    // super sliders
    var superSliderStr = "_"
    
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
                cell.source.text = newsParser.getSource(index: index)
                
                if newsParser.getMarkups(index: index).count > 0 {
                    cell.markupView.isHidden = false
                }
                
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
                    cell.source.text = newsParser.getSource(index: indexPath.row+start)
                    
                    if newsParser.getMarkups(index: index).count > 0 {
                        cell.markupView.isHidden = false
                    }
                    
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
                    cell.source.text = newsParser.getSource(index: indexPath.row+start)
                    
                    if newsParser.getMarkups(index: index).count > 0 {
                        cell.markupView.isHidden = false
                    }
                    
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
                cell.source.text = newsParser.getSource(index: indexPath.row+start)
                
                if newsParser.getMarkups(index: index).count > 0 {
                    cell.markupView.isHidden = false
                }
                
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
        return .init(width: view.frame.width, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if section == self.collectionView.numberOfSections - 1 {
            return .init(width: view.frame.width, height: 500)
        }
        else {
            if self.artfreq == ".A50" && section == 0 {
                return .zero
            }
            else if section == 0{
                // see more footer
                //increasing height of footer for horizontal scroll view
                return .init(width: 0, height: 100)
            } else {
                return .init(width: 0, height: 30)
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
            let cellsPerRow = 2
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

            let totalSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))

            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))

            return CGSize(width: size, height: 250)
        }
        // section highlights
        else if indexPath.row == 0 || indexPath.row == 1 {
            return .init(width: view.frame.width, height: 200)
        }
        // the rest
        else {
            let cellsPerRow = 2
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

            let totalSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))

            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))

            return CGSize(width: size, height: 250)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 20, left: 0, bottom: 0, right: 0)
    }
    
   override func numberOfSections(in collectionView: UICollectionView) -> Int {
        sliderValues.setSectionCount(num: newsParser.getNumOfSections())
        if newsParser.getNumOfSections() == 1 {
            return 2
        }
        return newsParser.getNumOfSections()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if newsParser.getNumOfSections() == 1 && section == 1 {
            print("here")
            return 0
        } else if section >= newsParser.getArticleCountInSection().count {
            print("Oops! loaded too fast")
            print("We only have ", newsParser.getNumOfSections(), " sections")
            return newsParser.getArticleCountInSection()[newsParser.getArticleCountInSection().count-1]
        } else {
            return newsParser.getArticleCountInSection()[section]
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var start = 0
        for n in 0..<indexPath.section {
            start += newsParser.getArticleCountInSection(section: n)
        }
        
        let index = start + indexPath.row
        
        var link = ""
        if newsParser.getAMPStatus(index: index) == true {
            link = newsParser.getAMPURL(index: index)
        } else {
            link = newsParser.getURL(index: index)
        }
        
        let title = newsParser.getTitle(index: index)
        let markups = newsParser.getMarkups(index: index)
       
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
                sectionHeader.setHeaderText(subtopic: newsParser.getTopic(index: indexPath.section))
                sectionHeader.topicSlidersButton.isHidden = false
                sectionHeader.prioritySlider.isHidden = false
                //sectionHeader.isUserInteractionEnabled = false
                
                let globalPopularity = newsParser.getGlobalPopularities()[indexPath.section]
                sectionHeader.updateSuperSlider(num: globalPopularity)
                
                if indexPath.section == 0 {
                    sectionHeader.label.titleLabel?.font = UIFont(name: "PTSerif-Bold", size: 40)
                } else {
                    sectionHeader.label.titleLabel?.font = UIFont(name: "PTSerif-Bold", size: 30)
                }
                                
                // no super sliders on main page
                if self.topic == "news"{
                    sectionHeader.prioritySlider.isHidden = true
                }
                
                // no topic sliders on childless topics
                if newsParser.getAllTopics().count == 1 {
                    sectionHeader.topicSlidersButton.isHidden = true
                }
                
                // some bugs w/ the breadcrumbs
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
                return sectionHeader
                
            
            case UICollectionView.elementKindSectionFooter:
                let kind = UICollectionView.elementKindSectionFooter
                if indexPath.section == self.collectionView.numberOfSections - 1 {
                    let pageFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FAQFooter.footerId, for: indexPath) as! FAQFooter
                    pageFooter.shareDelegate = self
                    pageFooter.configure()
                    
                    return pageFooter
                } else if indexPath.section == 0 {
                    let seeMore = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: seeMoreFooterSection0.footerId, for: indexPath) as! seeMoreFooterSection0
                    seeMore.delegate = self
                    seeMore.setFooterText(subtopic: "MORE " + newsParser.getTopic(index: indexPath.section))
                    seeMore.configure()
                    return seeMore
                } else {
                    // no FAQ footer unless last section
                    let seeMore = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: seeMoreFooter.footerId, for: indexPath) as! seeMoreFooter
                    seeMore.delegate = self
                    seeMore.setFooterText(subtopic: "MORE " + newsParser.getTopic(index: indexPath.section))
                    seeMore.configure()
                    return seeMore
                }
            
            default:
                print("Unidentified reusable view")
                fatalError()
        }
    }
    
    //for loading articles when collection view scrolled to the top
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
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let tableView = scrollView as? UICollectionView else {return}
        let visibleHeadersInSection = tableView.indexPathsForVisibleItems
        
        let indexHeaderForSection = NSIndexPath(row: 0, section: 0) // Get the indexPath of your header for your selected cell
//        let header = collectionView.viewForSupplementaryElementOfKind(indexHeaderForSection)
//
        //let view = self.collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: <#T##IndexPath#>)

        //let visibleHeadersInSection = tableView.indexPathsForVisibleItems.map{ tableView.headerView(forSection: $0.section) }

    
        if scrollView.contentOffset.y < 0 {
            return
        }

        let offsetBetweenItems = 50

//        let indexForTopCard = Int(scrollView.contentOffset.y / offsetBetweenItems)
//        let card = cards[indexForTopCard] as? Card

//        card?.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: card?.frame.size.width ?? 0.0, height: card?.frame.size.height ?? 0.0)
    }
    
    init(topic: String) {
        let layout = UICollectionViewFlowLayout.init()
        super.init(collectionViewLayout: layout)
        
        self.topic = topic
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.tintColor = accentOrange // item colors
        collectionView.delaysContentTouches = false
        
        for view in collectionView.subviews {
              if view is UIScrollView {
                  (view as? UIScrollView)!.delaysContentTouches = false
                  break
              }
          }
        
        activityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            
            self.loadArticles()
            self.reload()
            self.updateTopicSliders()
            if Globals.isSliderOn {
                self.configureBiasSliders()
            }
            
            sleep(2)
            self.activityIndicator.stopAnimating()
        }
    }
    
    func setUpActivityIndicator() {
        self.activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }

    override func viewDidLoad() {
        overrideUserInterfaceStyle = .dark
                
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        newsParser.newsDelegate = self
        sliderValues = SliderValues.sharedInstance
        biasSliders.sliderDelegate = self
        biasSliders.shadeDelegate = self
        topicSliders.dismissDelegate = self
        topicSliders.sliderDelegate = self
        
        //observer to detect app entering foreground
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNews), name: UIApplication.willEnterForegroundNotification, object: nil)
       
        self.collectionView.register(SubtopicHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SubtopicHeader.headerId)
        self.collectionView.register(FAQFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FAQFooter.footerId)
        self.collectionView.register(seeMoreFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: seeMoreFooter.footerId)
        self.collectionView.register(seeMoreFooterSection0.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: seeMoreFooterSection0.footerId)
        self.collectionView.register(ArticleCell.self, forCellWithReuseIdentifier: ArticleCell.cellId)
        self.collectionView.backgroundColor = .systemBackground
        self.collectionView.register(ArticleCellHalf.self, forCellWithReuseIdentifier: ArticleCellHalf.cellId)
        self.collectionView.register(HeadlineCell.self, forCellWithReuseIdentifier: HeadlineCell.cellId)
        self.collectionView.register(ArticleCellAlt.self, forCellWithReuseIdentifier: ArticleCellAlt.cellId)
        
        
        // intialize some anchors
        topicTopAnchorHidden = topicSliders.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        topicTopAnchorVisible = topicSliders.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        topicBottomAnchor = topicSliders.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        setUpNavBar()
        setUp()
        configureBiasButton()
        configureTopicButton()
        setUpRefresh()
        setUpActivityIndicator()
    }
    
    @objc func refreshNews(){
        self.viewWillAppear(false)
    }
}

// page refreshing
extension NewsViewController {
     
    // sends server request
    func loadArticles() {
        sliderValues.setTopic(topic: self.topic)
        
        DispatchQueue.global().async {
            
            let firsthalf = self.homelink + self.topic + self.artfreq + self.untouchables
            let nexthalf = self.sliderValues.getBiasPrefs() + createTopicPrefs()
            let link: String
            if self.superSliderStr == "_" {
                link = firsthalf + nexthalf
            } else {
                link = firsthalf + nexthalf + self.superSliderStr
            }
            
            print("should be loading " + link)
            self.newsParser.getJSONContents(jsonName: link)
            
        }
                
    }
    
    // updates UI w/ server response
    func reload() {
        print("reload?")
        self.collectionView.reloadData()
        
        self.hierarchy = ""
        self.hierarchy = newsParser.getHierarchy()
    }
    
    @objc func refresh(_ sender: UIRefreshControl!) {
        
        self.refresher.beginRefreshing()
        
        print("refresh?")
        self.collectionView.reloadData()
        
        self.hierarchy = ""
        self.hierarchy = newsParser.getHierarchy()
        
        stopRefresher()
        
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    // MARK: Update topic sliders only when topic changes
    func updateTopicSliders() {
        print("how many times am i called")
        // for topic sliders
        sliderValues.setSubtopics(subtopics: newsParser.getAllTopics())
        sliderValues.setPopularities(popularities: newsParser.getPopularities())
        
        topicSliders.loadVariables()
        topicSliders.buildViews()
    }
}

extension NewsViewController: NewsDelegate {
    
    func didFinishLoadData(finished: Bool) {
        
        guard finished else {
            // Handle the unfinished state
            print("Could not load data")
            return
        }
        
        updateTopicSliders()
        reload()

    }
    
    func resendRequest() {
        loadArticles()
    }

}

extension NewsViewController {

    fileprivate func setUpNavBar() {

        searchBar.sizeToFit()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.textColor = .black
        searchBar.tintColor = .black
        
        let logo = UIImage(named: "N64")
        let titleView = UIImageView(image: logo)
        titleView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleView

//        navigationItem.title = "Improve the News"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barTintColor = .black// bar color when scrolling down
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PlayfairDisplay-SemiBold", size: 26)!, NSAttributedString.Key.foregroundColor: UIColor.white]

        let sectionsButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "hamburger"), style: .plain, target: self, action: #selector(self.sectionButtonItemClicked(_:)))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchItemClicked(_:)))
        navigationItem.leftBarButtonItem = sectionsButton
        navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    }
    
    func setUp() {
        
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        let img = UIImage(named: "N64")?.withRenderingMode(.alwaysOriginal)
        let homeButton = UIButton(image: img!)
        homeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        let label = UILabel.init(frame: CGRect(x: 35, y: 5, width: 180, height: 20))
        label.text = "IMPROVE THE NEWS"
        label.font = UIFont(name: "OpenSans-Bold", size: 17)
        label.textColor = .white
        label.textAlignment = .left
        //label.center.y = view.center.y
        view.addSubview(homeButton)
        view.addSubview(label)
        view.center = navigationItem.titleView!.center
        self.navigationItem.titleView = view
    }
    
    @objc func homeButtonTapped() {
        if self.topic != "news" {
            let newsVC = navigationController!.viewControllers[0] as! NewsViewController
            newsVC.topic = "news"
            newsVC.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            navigationController!.popToRootViewController(animated: true)
            self.loadArticles()
        }
    }
    
    @objc func searchItemClicked(_ sender:UIBarButtonItem!) {
        let searchvc = SearchViewController()
        navigationController?.pushViewController(searchvc, animated: true)
    }

    @objc func sectionButtonItemClicked(_ sender:UIBarButtonItem!) {
        navigationController?.pushViewController(SectionsViewController(), animated: true)
    }
    
    func setUpRefresh() {
        
        // set up refresher at top
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = .lightGray
        self.refresher.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
    }

}

extension NewsViewController: TopicSelectorDelegate {
    
    func pushNewTopic(newTopic: String) {
        let vc = NewsViewController(topic: newTopic)
        let mainTopic = newsParser.getTopic(index: 0)
        
        // Getting more article on same topic
        if newTopic == Globals.topicmapping[mainTopic]! {
            if self.artfreq == ".A4" {
                vc.artfreq = ".A20"
                vc.untouchables = ".B4.S4"
            } else if self.artfreq == ".A20" {
                vc.artfreq = ".A50"
                vc.untouchables = ".B4.S24"
            }
        } else {
            // Getting more articles on sub topic
            vc.artfreq = ".A20"
            vc.untouchables = ".B4.S4"
        }
        
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
        let indexPath = IndexPath(item: 0, section: atSection)
        //let section = self.collectionView.
        self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
}

// MARK: Bias sliders
extension NewsViewController: BiasSliderDelegate, ShadeDelegate {
    
    func configureBiasButton() {
        view.addSubview(biasButton)
        biasButton.frame = CGRect(x: view.frame.maxX-60, y: view.frame.height - 150, width: 50, height: 50)
        biasButton.layer.cornerRadius = 0.5 * biasButton.bounds.size.width
        let y = view.frame.height - slidersHeight
        biasSliders.frame = CGRect(x: 0, y: y, width: view.frame.width, height: 470)
        biasSliders.buildViews()
    }
    
    func configureBiasSliders() {
        
        let y = view.frame.height - slidersHeight
        
        biasSliders.addShowMore()
        biasSliders.backgroundColor = accentOrange
        
        shadeView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        shadeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        shadeView.isUserInteractionEnabled = false
        
        view.addSubview(shadeView)
        view.addSubview(biasSliders)
        
        shadeView.frame = view.frame
        shadeView.alpha = 0
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.shadeView.alpha = 1
                self.biasSliders.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.biasSliders.frame.height)
                
            }, completion: nil)
        
    }
    
    func dismissShade() {
        if Globals.isSliderOn {
            Globals.isSliderOn = false
        }
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.shadeView.alpha = 0
            
        }, completion: nil)
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.shadeView.alpha = 0
            
        }, completion: nil)
        biasSliders.handleDismiss()
    }
    
    
    @objc func showBiasSliders(_ sender:UIButton!) {
        if !Globals.isSliderOn {
            Globals.isSliderOn = true
        }
        configureBiasSliders()
    }
    
    func biasSliderDidChange() {
        
        biasSliders.activityView.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.loadArticles()
            self.reload()
            sleep(2)
            self.biasSliders.activityView.stopAnimating()
        }
    }
}

// MARK: Topic sliders
extension NewsViewController: TopicSliderDelegate, dismissTopicSlidersDelegate {
    
    func configureTopicButton() {
        view.addSubview(topicSliders)
        topicSliders.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topicTopAnchorHidden!,
            topicSliders.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topicSliders.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        topicSliders.buildViews()
    }
    
    func showTopicSliders() {
        
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
        
        collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        
    }
    
    func topicSliderDidChange() {
        loadArticles()
        reload()
    }
    
}

// MARK: Super slider
extension NewsViewController: SuperSliderDelegate {
    
    func updateSuperSliderStr(topic: String, popularity: Float) {
    
            let key = Globals.slidercodes[topic]!
        superSliderStr += key + String(format: "%02d", Int(popularity))
        
        print("super slider str: \(superSliderStr)")
    }
    
    func superSliderDidChange() {
        
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.loadArticles()
            self.reload()
            sleep(2)
            self.activityIndicator.stopAnimating()
        }
    }
}

extension NewsViewController: shareDelegate {
    
    func openSharing(items: [String]) {
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
}



import SwiftUI
struct MainPreview: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }

    struct ContainerView: UIViewControllerRepresentable {

        func makeUIViewController(context: UIViewControllerRepresentableContext<MainPreview.ContainerView>) -> UIViewController {
            return UINavigationController(rootViewController: NewsViewController(topic: "news"))
        }

        func updateUIViewController(_ uiViewController: MainPreview.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<MainPreview.ContainerView>) {

        }

    }
}
