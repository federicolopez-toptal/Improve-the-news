//
//  MoreHeadlinesView.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 08/02/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

// ------------
protocol MoreHeadlinesViewDelegate {
    func scrollFromHeadLines(toSection: Int)
    func horizontalScrollFromHeadLines(to: CGFloat)
}

// ------------
class customUIScrollView: UIScrollView {
      
      
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Begin!")
    }
    
    
    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        
        print("assadasdsa")
        
        return true
    }
    
}

// ------------
class MoreHeadlinesView: UIView, UIScrollViewDelegate {

    var delegate: MoreHeadlinesViewDelegate?
    var scrollView = customUIScrollView()

    // MARK: - Init
    func initialize(width: CGFloat) {
        self.frame = CGRect(x: 0, y: 0, width: width, height: 36)
        self.backgroundColor = DARKMODE() ? bgBlue_DARK : bgWhite_DARK
        
        self.scrollView = customUIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: 36))
        self.scrollView.showsHorizontalScrollIndicator = true
        self.scrollView.flashScrollIndicators()
        self.scrollView.delegate = self
        self.scrollView.canCancelContentTouches = false
        self.scrollView.backgroundColor = DARKMODE() ? articleSourceColor : bgWhite_DARK
        self.addSubview(self.scrollView)

        var x = 0
        for i in 0..<Globals.searchTopics.count {
            if(i==0) {
                continue
            }
        
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            label.textColor = DARKMODE() ? articleHeadLineColor : textBlack
            label.backgroundColor = DARKMODE() ? bgBlue_DARK : bgWhite_DARK
            
            //articleSourceColor
            label.font = UIFont(name: "Poppins-SemiBold", size: 12)
            label.textAlignment = .center
            label.text = Globals.searchTopics[i].uppercased()
            label.sizeToFit()
            label.isUserInteractionEnabled = false
            
                var mFrame = label.frame
                mFrame.origin.y = 0
                mFrame.origin.x = CGFloat(x)
                mFrame.size.width += 40.0
                mFrame.size.height = 36
                label.frame = mFrame
            
            scrollView.addSubview(label)
        
        
            let button = UIButton(frame: label.frame)
            button.backgroundColor = .clear
            button.tag = i
            
            button.addTarget(self, action: #selector(headLineTap(_:)), for: .touchUpInside)
            scrollView.addSubview(button)
            x += Int(label.frame.size.width)
            
            scrollView.contentSize = CGSize(width: CGFloat(x), height: scrollView.frame.size.height)
        
        
        
            /*
            let button = UIButton(frame: CGRect(x: CGFloat(x), y: 3, width: 100, height: 30))
            button.setTitle(Globals.searchTopics[i].uppercased(), for: .normal)
            button.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 12)
            button.titleLabel?.textColor = articleHeadLineColor
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.textAlignment = .center
            button.tag = i
            button.addTarget(self, action: #selector(headLineTap(_:)), for: .touchUpInside)
            scrollView.addSubview(button)
            x += Int(button.frame.size.width)
            
            scrollView.contentSize = CGSize(width: CGFloat(x), height: scrollView.frame.size.height)
            scrollView.backgroundColor = articleSourceColor
            */
        }
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    func moveTo(y: CGFloat) {
        var mFrame = self.frame
        mFrame.origin.y = y
        self.frame = mFrame
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
    
    @objc private func headLineTap(_ sender: UIButton!) {
        print("scrollViewButtonTapped")
        self.delegate?.scrollFromHeadLines(toSection: sender.tag)
    }
    
    // MARK: - Scrollview
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.isDragging) {
            self.delegate?.horizontalScrollFromHeadLines(to: scrollView.contentOffset.x)
        }
    }
    
    func setTopics(_ topics: [String]) {
        
        var x = 0
        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        //for i in 0..<Globals.searchTopics.count {
        for (i, topic) in topics.enumerated() {
            if(i==0) {
                continue
            }
        
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            label.textColor = DARKMODE() ? articleHeadLineColor : textBlack
            label.backgroundColor = DARKMODE() ? bgBlue_DARK : bgWhite_DARK
            //articleSourceColor
            label.font = UIFont(name: "Poppins-SemiBold", size: 12)
            label.textAlignment = .center
            label.text = topic.uppercased()
            label.sizeToFit()
            label.isUserInteractionEnabled = false
            
                var mFrame = label.frame
                mFrame.origin.y = 0
                mFrame.origin.x = CGFloat(x)
                mFrame.size.width += 40.0
                mFrame.size.height = 36
                label.frame = mFrame
            
            scrollView.addSubview(label)
        
        
            let button = UIButton(frame: label.frame)
            button.backgroundColor = .clear
            button.tag = i
            
            button.addTarget(self, action: #selector(headLineTap(_:)), for: .touchUpInside)
            scrollView.addSubview(button)
            x += Int(label.frame.size.width)
            
            scrollView.contentSize = CGSize(width: CGFloat(x), height: scrollView.frame.size.height)
        
        
            /*
            let button = UIButton(frame: CGRect(x: CGFloat(x), y: 3, width: 100, height: 30))
            button.setTitle(topic.uppercased(), for: .normal)
            //button.setTitle(Globals.searchTopics[i].uppercased(), for: .normal)
            button.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 12)
            button.titleLabel?.textColor = articleHeadLineColor
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.textAlignment = .center
            button.tag = i
            button.addTarget(self, action: #selector(headLineTap(_:)), for: .touchUpInside)
            scrollView.addSubview(button)
            x += Int(button.frame.size.width)
            
            scrollView.contentSize = CGSize(width: CGFloat(x), height: scrollView.frame.size.height)
            scrollView.backgroundColor = articleSourceColor
            */
        }
    }
    
}
