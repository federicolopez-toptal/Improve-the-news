//
//  ShareSplitArticles.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 24/11/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit
import SwiftUI

protocol ShareSplitArticlesDelegate {
    func articleWasSelected(totalCount: Int)
}


class ShareSplitArticles: UIView {

    var delegate: ShareSplitArticlesDelegate?

    let column1 = UITableView()
    let column2 = UITableView()
    private var started = false
    private var offsetFixed = false

    private var parser: News?
    var dp1top = 0
    var dp1Bottom = 0
    var dp2top = 0
    var dp2Bottom = 0
    var dp1 = [(String, String, String, String, Bool, String)]()
    var dp2 = [(String, String, String, String, Bool, String)]()
    var dataProvider1 = [(String, String, String, String, Bool, String)]()
    var dataProvider2 = [(String, String, String, String, Bool, String)]()
    let ARTICLES_TO_ADD = 15

    var headerHeightConstraint: NSLayoutConstraint?
    var headerTimer: Timer?
    
    let headerLabel1 = UILabel()
    let headerLabel2 = UILabel()
    var showBorders = false
    let hOrangeLine = UIView()
    
    var randomizeAnim_targetY: CGFloat = 0.0
    var centered1: Int = 0
    var centered2: Int = 0
    var randomizeCount = 0

    ///
    var column1WidthConstraint: NSLayoutConstraint?
    var column2WidthConstraint: NSLayoutConstraint?



    init(into container: UIView) {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = .green
        container.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            self.topAnchor.constraint(equalTo: container.topAnchor),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -110)
        ])
        
        let halfScreenWidth = UIScreen.main.bounds.size.width/2
        
        let header = UIView()
        header.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
        self.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        self.headerHeightConstraint = header.heightAnchor.constraint(equalToConstant: 60)
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            header.topAnchor.constraint(equalTo: self.topAnchor),
            self.headerHeightConstraint!
        ])
        
        let splitOption = UserDefaults.standard.integer(forKey: "userSplitPrefs")
        
        headerLabel1.textAlignment = .center
        headerLabel1.font = UIFont(name: "PTSerif-Bold", size: 20)
        headerLabel1.textColor = .white
        if(!DARKMODE()){ headerLabel1.textColor = textBlackAlpha }
        headerLabel1.text = "LEFT"
        if(splitOption==2){ headerLabel1.text = "CRITICAL" }
        header.addSubview(headerLabel1)
        headerLabel1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel1.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            headerLabel1.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -10),
            headerLabel1.widthAnchor.constraint(equalToConstant: halfScreenWidth)
        ])
        
        let upArrow1 = UIImageView()
        upArrow1.image = UIImage(systemName: "chevron.up")
        upArrow1.tintColor = accentOrange
        header.addSubview(upArrow1)
        upArrow1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            upArrow1.widthAnchor.constraint(equalToConstant: 16),
            upArrow1.heightAnchor.constraint(equalToConstant: 20),
            upArrow1.centerXAnchor.constraint(equalTo: headerLabel1.centerXAnchor),
            upArrow1.bottomAnchor.constraint(equalTo: headerLabel1.topAnchor, constant: 0)
        ])
        
        headerLabel2.textAlignment = .center
        headerLabel2.font = UIFont(name: "PTSerif-Bold", size: 20)
        headerLabel2.textColor = .white
        if(!DARKMODE()){ headerLabel2.textColor = textBlackAlpha }
        headerLabel2.text = "RIGHT"
        if(splitOption==2){ headerLabel2.text = "PRO" }
        header.addSubview(headerLabel2)
        headerLabel2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel2.leadingAnchor.constraint(equalTo: headerLabel1.trailingAnchor),
            //headerLabel2.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            headerLabel2.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -10),
            headerLabel2.widthAnchor.constraint(equalToConstant: halfScreenWidth)
        ])
        
        let upArrow2 = UIImageView()
        upArrow2.image = UIImage(systemName: "chevron.up")
        upArrow2.tintColor = accentOrange
        header.addSubview(upArrow2)
        upArrow2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            upArrow2.widthAnchor.constraint(equalToConstant: 16),
            upArrow2.heightAnchor.constraint(equalToConstant: 20),
            upArrow2.centerXAnchor.constraint(equalTo: headerLabel2.centerXAnchor),
            upArrow2.bottomAnchor.constraint(equalTo: headerLabel2.topAnchor, constant: 0)
        ])
        
        column1.backgroundColor = header.backgroundColor
        self.addSubview(column1)
        column1.translatesAutoresizingMaskIntoConstraints = false
        self.column1WidthConstraint = column1.widthAnchor.constraint(equalToConstant: halfScreenWidth)
        NSLayoutConstraint.activate([
            column1.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.column1WidthConstraint!,
            column1.topAnchor.constraint(equalTo: header.bottomAnchor),
            column1.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            /*
            column1.topAnchor.constraint(equalTo: self.topAnchor, constant: 240),
            column1.heightAnchor.constraint(equalToConstant: 240)
            */
        ])
        
        column2.backgroundColor = header.backgroundColor
        self.addSubview(column2)
        column2.translatesAutoresizingMaskIntoConstraints = false
        self.column2WidthConstraint = column2.widthAnchor.constraint(equalToConstant: halfScreenWidth)
        NSLayoutConstraint.activate([
            column2.leadingAnchor.constraint(equalTo: column1.trailingAnchor),
            column2.topAnchor.constraint(equalTo: header.bottomAnchor),
            column2.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.column2WidthConstraint!
            //column2.widthAnchor.constraint(equalTo: column1.widthAnchor)
        ])
        
        let line = UIView()
        line.backgroundColor = .white
        if(!DARKMODE()){ line.backgroundColor = bgWhite_DARK }        
        self.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.topAnchor.constraint(equalTo: header.bottomAnchor),
            line.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            line.widthAnchor.constraint(equalToConstant: 4),
            line.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        hOrangeLine.backgroundColor = UIColor(hex: 0xF0914F)
        self.addSubview(hOrangeLine)
        hOrangeLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hOrangeLine.centerYAnchor.constraint(equalTo: self.column1.centerYAnchor, constant: -60),
            hOrangeLine.heightAnchor.constraint(equalToConstant: 4),
            hOrangeLine.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            hOrangeLine.widthAnchor.constraint(equalToConstant: 24)
        ])
        hOrangeLine.isHidden = true
        
        self.isHidden = true
        //self.addGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addGestures() {
        let panGesture1 = UIPanGestureRecognizer(target: self, action: #selector(columnOnPan(_:)))
        //panGesture1.minimumNumberOfTouches = 1
        //let panGesture2 = UIPanGestureRecognizer(target: self, action: #selector(columnOnPan(_:)))
        //panGesture2.minimumNumberOfTouches = 1
        
        self.column1.addGestureRecognizer(panGesture1)
        //self.column2.addGestureRecognizer(panGesture2)
    }
    
    func rotate() {
        let halfScreenWidth = UIScreen.main.bounds.size.height/2
        
        self.column1WidthConstraint?.constant = halfScreenWidth
        self.column2WidthConstraint?.constant = halfScreenWidth
        
        if(self.headerHeightConstraint!.constant > 0.0) {
            self.headerHeightConstraint?.constant = 0.0
            UIView.animate(withDuration: 0.4) {
                self.superview?.layoutIfNeeded()
            } completion: { (succeed) in
            }
        }
        
        self.fixListsScrollPosition(self.column1)
        self.fixListsScrollPosition(self.column2)
    }
    
    func start(parser: News) {
        self.randomizeCount = 0
        self.offsetFixed = false
        self.parser = parser
        self.populateDataProviders()
        self.headerHeightConstraint?.constant = 60.0
        self.hOrangeLine.isHidden = true
        
        if(self.started) {
            self.updateHeaderTexts()
            self.column1.reloadData()
            self.column2.reloadData()
            self.column1.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            self.column2.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            
            self.headerHeightConstraint?.constant = 0.0
            /*
            DELAY(1.0) {
                
                self.addItemsAtTop(1)
                self.addItemsAtTop(1)
                self.addItemsAtTop(1)
                
                
                /*
                self.addItemsAtBottom(2)
                self.addItemsAtBottom(2)
                */
                
            }
            */
            
            /*
            DELAY(2.0) {
                self.startScrollingTimer()
            }
            */
            
            return
        }
        self.started = true
        
        let lists = [column1, column2]
        let nibName = "ShareSplitArticleCell"
        let nib = UINib(nibName: nibName, bundle: nil)
        for L in lists {
            L.separatorStyle = .none
            L.tableFooterView = UIView()
            L.register(nib, forCellReuseIdentifier: nibName)
            L.delegate = self
            L.dataSource = self
            L.decelerationRate = .fast
        }
        
        column1.tag = 101
        column2.tag = 102
        
        DELAY(0.5) {
            self.centered1 = self.getCenteredRow(index: 1)
            self.centered2 = self.getCenteredRow(index: 2)
        }
    }
    
    private func updateHeaderTexts() {
        let splitOption = UserDefaults.standard.integer(forKey: "userSplitPrefs")
        
        headerLabel1.text = "LEFT"
        if(splitOption==2){ headerLabel1.text = "CRITICAL" }
        headerLabel2.text = "RIGHT"
        if(splitOption==2){ headerLabel2.text = "PRO" }
    }
    
    func populateDataProviders() {
        var index = 0
        var side = 1
        
        self.dp1 = [(String, String, String, String, Bool, String)]()
        self.dp2 = [(String, String, String, String, Bool, String)]()
        self.dataProvider1 = [(String, String, String, String, Bool, String)]()
        self.dataProvider2 = [(String, String, String, String, Bool, String)]()
        
        if let sections = self.parser?.getNumOfSections(), sections>0 {
            for i in 0...sections-1 {
                if let arts = self.parser?.getArticleCountInSection(section: i), arts>0 {
                    for _ in 0...arts-1 {
                    
                        if(self.parser!.getStory(index: index) == nil) {
                            let title = self.parser!.getTitle(index: index)
                            let img = self.parser!.getIMG(index: index)
                            let flag = self.parser!.getCountryID(index: index)
                            let source = self.parser!.getSource(index: index) + " - " + self.parser!.getDate(index: index)
                            let url = self.parser!.getURL(index: index)
                            
                            let newItem = (img, title, flag, source, false, url)
                            if(side==1){
                                self.dp1.append(newItem)
                                self.dataProvider1.append(newItem)
                                side = 2
                            } else {
                                self.dp2.append(newItem)
                                self.dataProvider2.append(newItem)
                                side = 1
                            }
                        }
                        
                        index += 1
                        //if(self.dp1.count>=5 && self.dp2.count>=5){ break } //!!!
                    }
                }
                //if(self.dp1.count>=5 && self.dp2.count>=5){ break } //!!!
            }
        }
        
        dp1Bottom = 0
        dp2Bottom = 0
        dp1top = self.dp1.count-1
        dp2top = self.dp2.count-1
    }
    
    func getSelectedArticles() -> [(String, String, String, String, Bool, String)] {
        var result = [(String, String, String, String, Bool, String)]()
    
        for _d in self.dataProvider1 {
            if(_d.4) {
                result.append(_d)
                break
            }
        }
        
        for _d in self.dataProvider2 {
            if(_d.4) {
                result.append(_d)
                break
            }
        }
        
        return result
    }
    
}

extension ShareSplitArticles: UITableViewDelegate, UITableViewDataSource,
    UIScrollViewDelegate, ShareSplitArticleCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        
        if(tableView.tag == 101) {
            return self.dataProvider1.count
        } else {
            return self.dataProvider2.count
        }
    }
    
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let  cell = tableView.dequeueReusableCell(withIdentifier:
            "ShareSplitArticleCell") as! ShareSplitArticleCell
           
        var info = ("", "", "", "", false, "")
        let index = indexPath.row
        if(tableView.tag == 101) {
            info = self.dataProvider1[index]
        } else {
            info = self.dataProvider2[index]
        }
        
        cell.showBorders = self.showBorders
        cell.update(img: info.0, text: info.1, countryID: info.2, source: info.3, state: info.4)
        cell.delegate = self
        cell.setList(tableView.tag-100)
        cell.setIndex(indexPath.row)
        cell.updateCheck()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 240.0
    }
    
    func cellWasChecked(list: Int, index: Int, state: Bool) {
        var listComponent = self.column1
        if(list==2) {
            listComponent = self.column2
        }
        
        // edit dataProviders (for cell updating)
        if(!state) {
            self.editDataProvider(list, index, value: state)
        } else {
            let total = self.tableView(listComponent, numberOfRowsInSection: 0)
            for i in 0...total-1 {
                if(i==index) {
                    self.editDataProvider(list, i, value: true)
                } else {
                    self.editDataProvider(list, i, value: false)
                }
            }
        }
        
        // manual tap, disable the randomize borders
        self.showBorders = false
        for (i, _d) in self.dataProvider1.enumerated() {
            if(_d.4) {
                self.column1.reloadRows(at: [IndexPath(item: i, section: 0)], with: .none)
                break
                
            }
        }
        for (i, _d) in self.dataProvider2.enumerated() {
            if(_d.4) {
                self.column2.reloadRows(at: [IndexPath(item: i, section: 0)], with: .none)
                break
            }
        }
        self.hOrangeLine.isHidden = true
        
        // Total selection count
        var count = 0
        for _d in self.dataProvider1 {
            if(_d.4){
                count += 1
                break
            }
        }
        for _d in self.dataProvider2 {
            if(_d.4){
                count += 1
                break
            }
        }

        self.delegate?.articleWasSelected(totalCount: count)
        listComponent.reloadData()
    }
    
    private func editDataProvider(_ list: Int, _ item: Int, value: Bool) {
        if(list==1) {
            var mItem = self.dataProvider1[item]
            mItem.4 = value
            self.dataProvider1[item] = mItem
        } else {
            var mItem = self.dataProvider2[item]
            mItem.4 = value
            self.dataProvider2[item] = mItem
        }
    }
  
    // scrollview
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // headers dissapearing
        if(self.headerHeightConstraint!.constant > 0.0) {
            self.headerHeightConstraint?.constant = 0.0
            UIView.animate(withDuration: 0.4) {
                self.superview!.layoutIfNeeded()
            } completion: { (succeed) in
            }
        }

        // unused
        if let _t = self.headerTimer {
            _t.invalidate()
        }
        
        // scrolling offset fix
        if(!self.offsetFixed) {
            var list = self.column1
            if(scrollView.tag==101){ list = self.column2 } // the OTHER list
            
            let iPath = list.indexPathForRow(at: CGPoint(x: list.bounds.midX, y: list.bounds.midY))!
            list.scrollToRow(at: iPath, at: .middle, animated: true)
            
            self.offsetFixed = true
        }
        
        // removing borders (from randomize)
        self.showBorders = false
        for (i, _d) in self.dataProvider1.enumerated() {
            if(_d.4) {
                self.column1.reloadRows(at: [IndexPath(item: i, section: 0)], with: .none)
                break
                
            }
        }
        for (i, _d) in self.dataProvider2.enumerated() {
            if(_d.4) {
                self.column2.reloadRows(at: [IndexPath(item: i, section: 0)], with: .none)
                break
                
            }
        }
        self.hOrangeLine.isHidden = true
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
        willDecelerate decelerate: Bool) {
        
        //print("LIST SCROLL OFFSET", self.column1.contentOffset.y)
        if(!decelerate) {
            self.fixListsScrollPosition(scrollView)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //print(scrollView.frame.size.height - (240 * 5))
        print("Y", scrollView.contentOffset.y )
        
        var list = 1
        if(scrollView == self.column2){ list = 2 }
        
        // TOP
        if(scrollView.contentOffset.y == 0.0) {
            self.addItemsAtTop(list)
        }
        
        var limit: CGFloat = 0
        if(list==1){ limit = 240.0 * CGFloat(self.dataProvider1.count) }
        else if(list==2){ limit = 240.0 * CGFloat(self.dataProvider2.count) }
        limit -= self.column1.frame.size.height
        
        // BOTTOM
        if(scrollView.contentOffset.y == limit) {
            self.addItemsAtBottom(list)
        }
        
        DELAY(0.1) {
            self.fixListsScrollPosition(scrollView)
        }
    }
    
    
    
    private func fixListsScrollPosition(_ scrollView: UIScrollView) {
        var list = self.column1
        if(scrollView.tag == 102) { list = self.column2 }

        if let iPath = list.indexPathForRow(at: CGPoint(x: list.bounds.midX, y: list.bounds.midY)) {
            list.scrollToRow(at: iPath, at: .middle, animated: true)
        
            self.centered1 = self.getCenteredRow(index: 1)
            self.centered2 = self.getCenteredRow(index: 2)
        }
        
        //let iPath = list.indexPathForRow(at: CGPoint(x: list.bounds.midX, y: list.bounds.midY))!
        
    }
    
    @objc func columnOnPan(_ gesture: UIPanGestureRecognizer?) {
        /*
        if(gesture?.numberOfTouches==1 && gesture?.state == .changed) {
            print("asdadas")

            
            /*
            var list = self.column1
            if(gesture?.view == self.column2){ list = column2 }
            
            if(list==self.column1){ print("1") }
            else{ print("2") }
            */
            
        }
        */
    }

    
}


extension ShareSplitArticles {
    
    func randomize() {
    
        if(headerHeightConstraint!.constant > 0) {
            self.headerHeightConstraint?.constant = 0.0
            UIView.animate(withDuration: 0.4) {
                self.superview!.layoutIfNeeded()
            } completion: { (succeed) in
                self.randomize_step2()
            }
        } else {
            self.randomize_step2()
        }
    }
    
    func random(current: Int, min: Int, max: Int) -> Int {
        var variation = 5
        variation += self.randomizeCount-1
        if(variation>15){ variation = 15 }
        
        var limMin = current - variation
        if(limMin<min){ limMin = min }
        
        var limMax = current + variation
        if(limMax>max){ limMax = max }
        
        var value = RND(range: limMin...limMax)
        //while(value == current) {
        
        while(abs(value-current)<2) {
            value = RND(range: limMin...limMax)
        }
        
        return value
    }
    
    func randomize_step2() {
        self.randomizeCount += 1
    
        self.showBorders = true
        self.hOrangeLine.isHidden = true
    
        let count1 = self.dataProvider1.count
        let count2 = self.dataProvider2.count
        
        let row1 = self.random(current: self.centered1, min: 1, max: count1-2)
        self.centered1 = row1
        
        let row2 = self.random(current: self.centered2, min: 1, max: count2-2)
        self.centered2 = row2
    

        /*
        var row1 = RND(range: 0...count1-1)
        var row2 = RND(range: 0...count2-1)
        if(row1==0){ row1 = 1 }
        if(row1==count1-1){ row1 = count1-2 }
        if(row2==count2-1){ row2 = count2-2 }
        if(row2==0){ row2 = 1 }
        */
        
            for (i, _d) in self.dataProvider1.enumerated() {
                if(_d.4 && i==row1) {
                    self.column1.reloadRows(at: [IndexPath(item: i, section: 0)], with: .none)
                    break
                }
            }
            for (i, _d) in self.dataProvider2.enumerated() {
                if(_d.4 && i==row2) {
                    self.column2.reloadRows(at: [IndexPath(item: i, section: 0)], with: .none)
                    break
                }
            }
        
        let iPath1 = IndexPath(row: row1, section: 0)
        let iPath2 = IndexPath(row: row2, section: 0)
        
        //print("RANDOM: \(row1)/\(count1), \(row2)/\(count2)")
        //self.column1.scrollToRow(at: iPath1, at: .middle, animated: true)
        self.manualScrollTo(column: 1, row: row1)
        self.manualScrollTo(column: 2, row: row2)
        //self.column2.scrollToRow(at: iPath2, at: .middle, animated: true)
        
        //////
        if let cell1 = self.tableView(self.column1, cellForRowAt: iPath1) as? ShareSplitArticleCell {
            if(!cell1.checked) {
                let total = self.tableView(self.column1, numberOfRowsInSection: 0)
                for i in 0...total-1 {
                    if(i==row1) {
                        self.editDataProvider(1, i, value: true)
                    } else {
                        self.editDataProvider(1, i, value: false)
                    }
                }
                self.column1.reloadData()
            }
        }
        if let cell2 = self.tableView(self.column2, cellForRowAt: iPath2) as? ShareSplitArticleCell {
            if(!cell2.checked) {
                let total = self.tableView(self.column2, numberOfRowsInSection: 0)
                for i in 0...total-1 {
                    if(i==row2) {
                        self.editDataProvider(2, i, value: true)
                    } else {
                        self.editDataProvider(2, i, value: false)
                    }
                }
                self.column2.reloadData()
            }
        }
        
        /*
        DELAY(0.4) {
            self.hOrangeLine.alpha = 0.0
            self.hOrangeLine.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.hOrangeLine.alpha = 1.0
            }
        }
        */
    }
    
    func getCenteredRow(index: Int) -> Int {
        var list = self.column1
        if(index==2){ list = self.column2 }
        
        let valY = list.contentOffset.y + (list.frame.size.height/2)
        let iPath = list.indexPathForRow(at: CGPoint(x: 20, y: valY))
        if(iPath == nil) {
            return -1
        } else {
            return iPath!.row
        }
    }
    
    
    func manualScrollTo(column: Int, row: Int) {
        
        let itemHeight: CGFloat = 240.0
        
        var list = self.column1
        if(column==2){ list = self.column2 }
        
        let start_Y = list.contentOffset.y
        let target_Y = (itemHeight * CGFloat(row)) - (list.frame.size.height-itemHeight)/2
        var values = [CGFloat]()
        
        let total = 55
        let totalTime: Double = 1.0
        for i in 0...total-1 {
            let t = (totalTime/Double(total-1)) * Double(i)
            let value = self.easeOutElastic(time: t,
                start: start_Y,
                change: target_Y-start_Y,
                duration: totalTime)
                
            values.append(value)
        }
        
        var i = 0
        let tmr = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { (tmr) in
            list.setContentOffset(CGPoint(x: 0, y: values[i]), animated: false)
        
            i += 1
            if(i == total) {
                tmr.invalidate()
                list.setContentOffset(CGPoint(x: 0, y: target_Y), animated: false)
                self.hOrangeLine.isHidden = false
            }
        }

    }
    
    // https://spicyyoghurt.com/tools/easing-functions
    // t, b, c, d (time, beginning, change, duration)
    func linear(time: CGFloat, start: CGFloat, change: CGFloat, duration: CGFloat) -> CGFloat {
        return change * time / duration + start
    }
    
    func easeInQuad(time: CGFloat, start: CGFloat, change: CGFloat, duration: CGFloat) -> CGFloat {
        return change * (time / duration) * time + start
    }
    
    func easeOutQuad(time: CGFloat, start: CGFloat, change: CGFloat, duration: CGFloat) -> CGFloat {
        return -change * (time / duration) * (time-2) + start
    }
    func easeOutSin(time: CGFloat, start: CGFloat, change: CGFloat, duration: CGFloat) -> CGFloat {
        return change * sin(time / duration * (Double.pi / 2)) + start
    }
    func easeOutCirc(time: CGFloat, start: CGFloat, change: CGFloat, duration: CGFloat) -> CGFloat {
        let t2 = time / duration - 1
        return change * sqrt(1 - t2 * t2) + start
    }
    
    func easeInElastic(time: CGFloat, start: CGFloat, change: CGFloat, duration: CGFloat) -> CGFloat {
        var s: Double = 1.70158
        //s = s/5.0
        
        
        var p: Double = duration * 0.3
        var a: Double = change
        
        if(time==0){ return start }
        if(time/duration == 1){ return start + change }
        
        if(a < abs(change)) {
            a = change
            s = p / 4
        } else {
            s = p / (2 * Double.pi) * asin(change / a)
        }
        
        return -(a * pow(2, 10 * (time-1)) * sin((time * duration - s) * (2 * Double.pi) / p)) + start
    }
    
    func easeOutElastic(time: CGFloat, start: CGFloat, change: CGFloat, duration: CGFloat) -> CGFloat {
        var s: Double = 1.70158// / 20.0
        var p: Double = duration * 0.3
        var a: Double = change
        
        if(time==0){ return start }
        if(time/duration == 1){ return start + change }
        
        if(a < abs(change)) {
            a = change
            s = p / 4
        } else {
            s = p / (2 * Double.pi) * asin(change / a)
        }
        
        return a * pow(2, -10 * time) * sin((time * duration - s) * (2 * Double.pi) / p) + change + start
    }
}

extension ShareSplitArticles {
    
    private func addItemsAtTop(_ index: Int) {
    
        var offset = self.column1.contentOffset
        if(index==2){ offset = self.column2.contentOffset }
        offset.y += (240 * CGFloat(self.ARTICLES_TO_ADD))
        
        var toAdd = [(String, String, String, String, Bool, String)]()
        var j = dp1top
        if(index==2){ j = dp2top }
        for _ in 1...self.ARTICLES_TO_ADD {
            if(index==1) {
                toAdd.append(self.dp1[j])
            } else if(index==2) {
                toAdd.append(self.dp2[j])
            }
            
            j -= 1
            if(index==1 && j == -1) { j=self.dp1.count-1 }
            else if(index==2 && j == -1) { j=self.dp2.count-2 }
            
            if(index==1){ dp1top = j }
            else if(index==2){ dp2top = j }
        }
        toAdd = toAdd.reversed()
        
        if(index==1) {
            self.dataProvider1 = toAdd + self.dataProvider1
            self.column1.reloadData()
            self.column1.setContentOffset(offset, animated: false)
        } else if(index==2) {
            self.dataProvider2 = toAdd + self.dataProvider2
            self.column2.reloadData()
            self.column2.setContentOffset(offset, animated: false)
        }
        
        print("ADDED at TOP!")
    }
    
    private func addItemsAtBottom(_ index: Int) {
        
        var offset = self.column1.contentOffset
        if(index==2){ offset = self.column2.contentOffset }
        offset.y -= (240 * CGFloat(self.ARTICLES_TO_ADD))
        
        var toAdd = [(String, String, String, String, Bool, String)]()
        var j = dp1Bottom
        if(index==2){ j = dp2Bottom }
        for _ in 1...self.ARTICLES_TO_ADD {
            if(index==1) {
                toAdd.append(self.dp1[j])
            } else if(index==2) {
                toAdd.append(self.dp2[j])
            }
            
            j += 1
            if(index==1 && j==dp1.count) { j=0 }
            else if(index==2 && j==dp2.count) { j=0 }
            
            if(index==1){ dp1Bottom = j }
            else if(index==2){ dp2Bottom = j }
        }
        
        if(index==1) {
            self.dataProvider1 = self.dataProvider1 + toAdd
            self.column1.reloadData()
            self.column1.setContentOffset(offset, animated: false)
        } else if(index==2) {
            self.dataProvider2 = self.dataProvider2 + toAdd
            self.column2.reloadData()
            self.column2.setContentOffset(offset, animated: false)
        }
        
        print("ADDED at BOTTOM!")
    }
     
    func unloadStuff() {
        /*
        self.dp1 = [(String, String, String, String, Bool)]()
        self.dp2 = [(String, String, String, String, Bool)]()
        self.dataProvider1 = [(String, String, String, String, Bool)]()
        self.dataProvider2 = [(String, String, String, String, Bool)]()
        self.column1.reloadData()
        self.column2.reloadData()
        */
    }
    
}
