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

class NewsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, MoreHeadlinesViewDelegate {
    
    
    
    
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
    
    let loadingView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    // ---
    let screenWidth = UIScreen.main.bounds.width
    var navBarFrame = CGRect.zero
    // ---
    private var moreHeadLines = MoreHeadlinesView()
    private var seeMoreFooterSection: seeMoreFooterSection0?
    
    private var moreHeadLinesInCollectionPosY: CGFloat = 0
    var firstTime = true
    
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
    let slidersHeight: CGFloat = 270 // 220
    let shadeView = UIView()
    
    // topic sliders
    let topicSliders = TopicSliderPopup()
    var topicTopAnchorHidden: NSLayoutConstraint?
    var topicTopAnchorVisible: NSLayoutConstraint?
    var topicBottomAnchor: NSLayoutConstraint?
    
    // super sliders
    var superSliderStr = "_"
    
    // -----------
    var param_A = 4
    var param_B = 4
    var param_S = 0
    
    // -----------
    
    
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
            // last one
            /*
            let subTopicsCount = newsParser.getNumOfSections()
            if(subTopicsCount==1) {
                return CGSize(width: view.frame.width, height: 260)
            } else {
                
            }*/
            
            return CGSize(width: view.frame.width, height: 260)
        }
        else {
            /*
            if self.artfreq == ".A50" && section == 0 {
                return .zero
            }
            else
            */
            
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
                    return CGSize(width: 0, height: 80 + 50 + 20)
                }
            } else {
                // standard SEE MORE
                return CGSize(width: 0, height: 80)
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
                
                let subTopic = newsParser.getTopic(index: indexPath.section)
                sectionHeader.setHeaderText(subtopic: subTopic)
                
                sectionHeader.topicSlidersButton.isHidden = false
                sectionHeader.prioritySlider.isHidden = false
                //sectionHeader.isUserInteractionEnabled = false
                
                var globalPopularity: Float = 0
                if(newsParser.getGlobalPopularities().count==0){
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
                if self.topic == "news"{
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
                if indexPath.section == 0 {
                    if self.hierarchy == "Headlines>" {
                        breadcrumbText = ""
                    } else {
                        breadcrumbText = String(self.hierarchy.dropLast())
                        hArray.append(breadcrumbText)
                    }
                } else {
                    breadcrumbText = self.hierarchy + newsParser.getTopic(index: indexPath.section)
                    sectionHeader.hierarchy.adjustsFontSizeToFitWidth = true
                    hArray.append(breadcrumbText)
                }
                
                let components = breadcrumbText.components(separatedBy: ">")
                if(components.count > 1) {
                    let last = components.last!
                    breadcrumbText = breadcrumbText.replacingOccurrences(of: ">" + last, with: "")
                    hArray.append(breadcrumbText)
                }
                sectionHeader.hierarchy.text = breadcrumbText
                
                /*
                let components = self.hierarchy.components(separatedBy: ">")
                    if(components.count > 1) {
                        text = components[components.count-2] + ">"
                    }
                    text += newsParser.getTopic(index: indexPath.section)
                */
                
                sectionHeader.backgroundColor  = bgBlue
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
    
    //for loading articles when collection view scrolled to the top
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < 0) {
            //loadArticles()
        }
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        /*
        let safeAreaTop: CGFloat = 88
        let offset = scrollView.contentOffset.y + safeAreaTop
        
        let alpha: CGFloat = 1 - ((scrollView.contentOffset.y + safeAreaTop) / safeAreaTop)
        
        navigationController?.navigationBar.alpha = alpha
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0,-offset))
        
        self.view.bringSubviewToFront(self.moreHeadLines)
        print(self.moreHeadLines)
        */
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

        
        var limit = self.moreHeadLinesInCollectionPosY-self.navBarFrame.size.height
        if let nav = navigationController {
            if(!nav.navigationBar.isTranslucent) {
                limit += (self.navBarFrame.origin.y + self.navBarFrame.size.height)
            }
            limit += 40
        }
        
        if(limit<110) {
            self.moreHeadLines.hide()
        } else {
            if(scrollView.contentOffset.y >= limit) {
                if let view = self.seeMoreFooterSection {
                    var mOffset = view.scrollView.contentOffset
                    /*if(mOffset.x < 0){ mOffset.x = 0 }
                    else if(mOffset.x > scrollView.contentSize.width){
                        mOffset.x = scrollView.contentSize.width
                    }*/
                    self.moreHeadLines.scrollView.contentOffset = mOffset
                }
                
                self.moreHeadLines.show()
            } else {
                if let view = self.seeMoreFooterSection {
                    var mOffset = self.moreHeadLines.scrollView.contentOffset
                    /*if(mOffset.x < 0){ mOffset.x = 0 }
                    else if(mOffset.x > scrollView.contentSize.width){
                        mOffset.x = scrollView.contentSize.width
                    }*/
                    view.scrollView.contentOffset = mOffset
                }
            
                self.moreHeadLines.hide()
            }
        }
        
        
        self.view.bringSubviewToFront(self.moreHeadLines)

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
        
        self.loadData()
    }
    
    func loadData() {
        if(self.firstTime){
            //activityIndicator.startAnimating()
            self.loadingView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                
                self.loadArticles()
                self.reload()
                self.updateTopicSliders()
                if Globals.isSliderOn {
                    self.configureBiasSliders()
                }
                
                sleep(2)
                self.loadingView.isHidden = true
                self.firstTime = false
                //self.activityIndicator.stopAnimating()

                self.stopRefresher()
            }
        }
    }
    
    
    
    
    
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
        self.collectionView.register(seeMoreFooterLast.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: seeMoreFooterLast.footerId)
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
        
        
        
        
        self.moreHeadLines.initialize(width: self.screenWidth)
        self.view.addSubview(self.moreHeadLines)
        self.moreHeadLines.delegate = self
        self.moreHeadLines.hide()
        
        self.view.backgroundColor = bgBlue
        self.collectionView.backgroundColor = bgBlue
    }
    
    func scrollFromHeadLines(toSection: Int) {
        self.scrollTheNewsTo(toSection)
    }
    
    @objc func refreshNews(){
        self.viewWillAppear(false)
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
    
    func scrollTheNewsTo(_ index: Int) {
        //let indexPath = IndexPath(item: 0, section: 0)
        /*if let cell = self.collectionView.cellForItem(at: indexPath) {
            self.collectionView.scrollRectToVisible(cell.frame, animated: true)
        }
        */
        
        //self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        
        
        
        /*
        let val_y: CGFloat = CGFloat((800) * index)
        self.collectionView.setContentOffset(CGPoint(x: 0, y: val_y), animated: true)
        */
        
        /*
        let cell = self.collectionView.cellForItem(at: indexPath)
        self.collectionView.
        
        cell?.alpha = 0.25
        */
        
        var offsetY: CGFloat = 0
        
        if(index>0) {
            offsetY = 800
            offsetY += CGFloat(890 * (index-1))
            offsetY += -45 // margin
        }
        
        
        /*
        for i in 0...index {
            if(i==0){ offsetY += 800 }
            else { offsetY += 890 }
        }
        */
        
        self.collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
    }
}

// page refreshing
extension NewsViewController {
     
    // sends server request
    func loadArticles() {
        sliderValues.setTopic(topic: self.topic)
        
        DispatchQueue.global().async {
            
            /*
            let firsthalf = self.homelink + self.topic + self.artfreq + self.untouchables
            let nexthalf = self.sliderValues.getBiasPrefs() + createTopicPrefs()
            let link: String
            if self.superSliderStr == "_" {
                link = firsthalf + nexthalf
            } else {
                link = firsthalf + nexthalf + self.superSliderStr
            }
            */
            
            let link = self.buildApiCall()
            
            print("GATO", "should load " + self.buildApiCall_b())
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
        /*
            self.artfreq
            self.untouchables
        */
    
        let firsthalf = self.homelink + self.topic +
            ".A\(self.param_A)" + ".B\(self.param_B)" +
            ".S\(self.param_S)"
            
        let nexthalf = self.sliderValues.getBiasPrefs() + createTopicPrefs()
        let link: String
        if self.superSliderStr == "_" {
            link = firsthalf + nexthalf
        } else {
            link = firsthalf + nexthalf + self.superSliderStr
        }
            
        return link
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
        self.firstTime = true
        self.loadData()
        
        /*
        print("refresh?")
        self.collectionView.reloadData()
        
        self.hierarchy = ""
        self.hierarchy = newsParser.getHierarchy()
        */
        
        //stopRefresher()
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

        self.moreHeadLines.setTopics(self.newsParser.getAllTopics())
        
        UIView.animate(withDuration: 0.5, animations: {
            self.collectionView.contentOffset.y = 0
        })
        
        
        //self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
        navigationController?.navigationBar.barTintColor = bgBlue
        //.black// bar color when scrolling down
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

    }
    
    func setUp() {
        
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
        
        
        /*
        // Getting more article on same topic
        if newTopic == mainTopic_B {
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
}

// MARK: Bias sliders
extension NewsViewController: BiasSliderDelegate, ShadeDelegate {
    
    func configureBiasButton() {
        view.addSubview(biasButton)
        
        var posY = view.frame.height - 150
        
        if let nav = navigationController {
            if(!nav.navigationBar.isTranslucent) {
                posY -= 88
            }
        }
        
        biasButton.frame = CGRect(x: view.frame.maxX-60, y: posY, width: 50, height: 50)
        biasButton.layer.cornerRadius = 0.5 * biasButton.bounds.size.width
        let y = view.frame.height - slidersHeight
        biasSliders.frame = CGRect(x: 0, y: y, width: view.frame.width, height: 550) //470
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
        
        self.biasSliders.separatorView.isHidden = false
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
        
        //biasSliders.activityView.startAnimating()
        biasSliders.showLoading(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.loadArticles()
            self.reload()
            sleep(2)
            //self.biasSliders.activityView.stopAnimating()
            self.biasSliders.showLoading(false)
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
    
    func horizontalScroll(to: CGFloat) {
        var mOffset = self.moreHeadLines.scrollView.contentOffset
        mOffset.x = to
        self.moreHeadLines.scrollView.setContentOffset(mOffset, animated: false)
    }
    
    func horizontalScrollFromHeadLines(to: CGFloat) {
        var mOffset = self.seeMoreFooterSection?.scrollView.contentOffset
        mOffset?.x = to
        
        if let
        offset = mOffset {
            self.seeMoreFooterSection?.scrollView.setContentOffset(offset, animated: false)
        }
    }
    
}




/*
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
*/
