//
//  HorizontalMenuView.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 11/05/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

protocol HorizontalMenuViewDelegate {
    func goToScrollView(atSection: Int)
}


class HorizontalMenuView: UIScrollView {

    var customDelegate: HorizontalMenuViewDelegate?
    var offset_y: CGFloat = 0.0

    // MARK: Initialization
    init() {
        let w = UIScreen.main.bounds.width
        super.init(frame: CGRect(x: 0, y: 0, width: w, height: 36))
        self.backgroundColor = DARKMODE() ? articleSourceColor : bgWhite_DARK
        self.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Data
    func setTopics(_ topics: [String]) {
        var x = 0
        self.subviews.forEach({ $0.removeFromSuperview() })
        for (i, topic) in topics.enumerated() {
            if(i==0) {
                continue
            }
        
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            label.textColor = DARKMODE() ? articleHeadLineColor : darkForBright
            label.backgroundColor = DARKMODE() ? articleSourceColor : bgWhite_DARK
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
            
            self.addSubview(label)
            
            let button = UIButton(frame: label.frame)
            button.backgroundColor = .clear
            button.tag = i
            
            button.addTarget(self, action: #selector(scrollViewButtonTapped(_:)), for: .touchUpInside)
            self.addSubview(button)
            x += Int(label.frame.size.width)
            
            self.contentSize = CGSize(width: CGFloat(x), height: self.frame.size.height)
        }
    }
    
    // MARK: - Action(s)
    @objc func scrollViewButtonTapped(_ sender: UIButton!) {
        self.customDelegate?.goToScrollView(atSection: sender.tag)
    }
    
    // MARK: - misc
    func moveTo(y: CGFloat) {
        var newValue = -y + offset_y
        if(newValue<0){ newValue=0 }
    
        var mFrame = self.frame
        mFrame.origin.y = newValue
        self.frame = mFrame
    }
    
    func backToZero() {
        self.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func changeWidthTo(_ newWidth: CGFloat) {
        var mFrame = self.frame
        mFrame.size.width = newWidth
        self.frame = mFrame
        
        mFrame = self.frame
        mFrame.size.width = newWidth
        self.frame = mFrame
    }
    
}
