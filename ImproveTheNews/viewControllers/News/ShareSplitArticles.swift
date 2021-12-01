//
//  ShareSplitArticles.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 24/11/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

protocol ShareSplitArticlesDelegate {
    func articleWasSelected(totalCount: Int)
}


class ShareSplitArticles: UIView {

    var delegate: ShareSplitArticlesDelegate?

    let column1 = UITableView()
    let column2 = UITableView()
    private var started = false

    private var parser: News?
    var dataProvider1 = [(String, String, String, String, Bool)]()
    var dataProvider2 = [(String, String, String, String, Bool)]()

    var scrollPositions = [CGFloat]()
    var headerHeightConstraint: NSLayoutConstraint?
    var headerTimer: Timer?
    
    let headerLabel1 = UILabel()
    let headerLabel2 = UILabel()
    

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
        NSLayoutConstraint.activate([
            column1.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            column1.widthAnchor.constraint(equalToConstant: halfScreenWidth),
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
        NSLayoutConstraint.activate([
            column2.leadingAnchor.constraint(equalTo: column1.trailingAnchor),
            column2.topAnchor.constraint(equalTo: header.bottomAnchor),
            column2.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            column2.widthAnchor.constraint(equalTo: column1.widthAnchor)
        ])
        
        let line = UIView()
        line.backgroundColor = .white
        self.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.topAnchor.constraint(equalTo: header.bottomAnchor),
            line.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            line.widthAnchor.constraint(equalToConstant: 4),
            line.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start(parser: News) {
        self.parser = parser
        self.populateDataProviders()
        self.headerHeightConstraint?.constant = 60.0
        
        if(self.started) {
            self.updateHeaderTexts()
            self.column1.reloadData()
            self.column2.reloadData()
            self.column1.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            self.column2.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
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
        self.dataProvider1 = [(String, String, String, String, Bool)]()
        self.dataProvider2 = [(String, String, String, String, Bool)]()
        
        if let sections = self.parser?.getNumOfSections(), sections>0 {
            for i in 0...sections-1 {
                if let arts = self.parser?.getArticleCountInSection(section: i), arts>0 {
                    for _ in 0...arts-1 {
                        let title = self.parser!.getTitle(index: index)
                        let img = self.parser!.getIMG(index: index)
                        let flag = self.parser!.getCountryID(index: index)
                        let source = self.parser!.getSource(index: index) + " - " + self.parser!.getDate(index: index)
                        
                        let newItem = (img, title, flag, source, false)
                        if(side==1){
                            self.dataProvider1.append(newItem)
                            side = 2
                        } else {
                            self.dataProvider2.append(newItem)
                            side = 1
                        }

                        index += 1
                    }
                }
            }
        }
        
        var posY: CGFloat = 0.0
        self.scrollPositions = [CGFloat]()
        for _ in self.dataProvider1 {
            self.scrollPositions.append(posY)
            posY += 240.0
        }
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "ShareSplitArticleCell") as! ShareSplitArticleCell
                
        var info = ("", "", "", "", false)
        let index = indexPath.row
        if(tableView.tag == 101) {
            info = self.dataProvider1[index]
        } else {
            info = self.dataProvider2[index]
        }
                
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
        if(self.headerHeightConstraint!.constant > 0.0) {
            self.headerHeightConstraint?.constant = 0.0
            UIView.animate(withDuration: 0.4) {
                self.superview!.layoutIfNeeded()
            } completion: { (succeed) in
            }
        }

        if let _t = self.headerTimer {
            _t.invalidate()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
        willDecelerate decelerate: Bool) {
        
        if(!decelerate) {
            self.fixListsScrollPosition(scrollView)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.fixListsScrollPosition(scrollView)
    }
    
    private func fixListsScrollPosition(_ scrollView: UIScrollView) {
        print("FIXING SCROLL!")
        
        var minorVal: (Int, CGFloat) = (0, 0.0)
        let currentY = scrollView.contentOffset.y
        for i in 0...self.scrollPositions.count-1 {
            var difference = currentY - self.scrollPositions[i]
            if(difference<0){ difference *= -1 }
            
            if(i==0){
                minorVal = (0, difference)
            } else {
                if(difference<minorVal.1) {
                    minorVal = (i, difference)
                }
            }
            
        }
        
        let destinationY = self.scrollPositions[minorVal.0]
        scrollView.setContentOffset(CGPoint(x: 0, y: destinationY), animated: true)
        
        self.headerTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { timer in
            self.headerHeightConstraint?.constant = 60.0
            UIView.animate(withDuration: 0.4) {
                self.superview!.layoutIfNeeded()
            } completion: { (succeed) in
            }
        }
    }

    
}





/*
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let list = self.column1
        let verticalOffset = CGFloat( Int(targetContentOffset.pointee.y) % Int(list.rowHeight) )
        
        if(velocity.y < 0) {
            targetContentOffset.pointee.y -= verticalOffset
        } else if(velocity.y > 0) {
            targetContentOffset.pointee.y += list.rowHeight - verticalOffset
        } else {
            if(verticalOffset < list.rowHeight/2) {
                targetContentOffset.pointee.y -= verticalOffset
            } else {
                targetContentOffset.pointee.y += list.rowHeight - verticalOffset
            }
        }
        
        print("###")
    }
    */
    
/*
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let list = self.column1
        
        let posY = Int(targetContentOffset.pointee.y)
        let toMove = posY % Int(list.rowHeight)
        let limit = Int(list.rowHeight/2)
        
        if(toMove < limit) {
            targetContentOffset.pointee.y -= CGFloat(toMove)
        } else {
            targetContentOffset.pointee.y += list.rowHeight - CGFloat(toMove)
        }
    }
*/
    
    
/*
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
        willDecelerate decelerate: Bool) {
        
        if(!decelerate) {
            self.scrollViewDidEndDecelerating(scrollView)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let list = self.column1
        let point = CGPoint(x: list.contentOffset.x,
            y: list.contentOffset.y + list.rowHeight/2)
        
        if let iPath = self.column1.indexPathForRow(at: point) {
            list.scrollToRow(at: iPath, at: .top, animated: true)
        }
    }
*/

   /*
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
        willDecelerate decelerate: Bool) {
        
        //if(!decelerate) {
            //print(scrollView.tag)
            //print("---")
            //self.scrollViewDidEndDecelerating(scrollView)
        //}
        
        //var list = self.column1
        //if(scrollView.tag==102){ list = self.column2 }
        
        /*
        let currentY = scrollView.contentOffset.y
        for i in 0...self.scrollPositions.count-1 {
            var difference = currentY - self.scrollPositions[i]
            if(difference<0){ difference *= -1 }
            
            
        }
        */
        
        /*
        let destinationY: CGFloat = 240.0
        scrollView.setContentOffset(CGPoint(x: 0, y: destinationY), animated: true)
        */
        
        //print( list.contentOffset.y )
        
        //if(!decelerate) {
            self.fixListsScrollPosition(scrollView)
        //}
    }
    */
    
    /*
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        /*
        var list = self.column1
        if(scrollView.tag==102){ list = self.column2 }
        
        
        let point = CGPoint(x: list.contentOffset.x,
            y: list.contentOffset.y + list.rowHeight/2)
        
        if let iPath = self.column1.indexPathForRow(at: point) {
            list.scrollToRow(at: iPath, at: .top, animated: true)
        }
        */
        
        self.fixListsScrollPosition(scrollView)
    }
*/
