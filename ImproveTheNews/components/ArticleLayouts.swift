//
//  ArticleLayouts.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 8/21/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

struct Section {
    let sectionImage, sectionDescription: String
}

struct Article {
    let image, headline, source, pubDate, logo: String
}

protocol TopicSelectorDelegate {
    func changeTopic(newTopic: String)
    func pushNewTopic(newTopic: String)
    func goToScrollView(atSection: Int)
    func horizontalScroll(to: CGFloat)
}

class HeadlineCell: UICollectionViewCell {
    
    static let cellId = "HeadlineCell"
      
    var miniSlidersView: MiniSlidersView?
    let imageView = UIImageView(backgroundColor: .clear)
    var headline = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 11), numberOfLines: 3)
    let source = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 12))
    let pubDate = UILabel()
    let logoView = UIImageView()
    let markupView = UIImageView()
    let flag = UIImageView()
      
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
          
    required init?(coder: NSCoder) {
        fatalError()
    }
      
      
    /*
    @objc func buttonTap(sender: UIButton) {
        print("GATO", "12312312312")
    }
    */
      
    func setupViews() {
        
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            imageView.heightAnchor.constraint(equalToConstant: self.frame.width * 7 / 12)
        ])
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        
        if(APP_CFG_SHOW_MINI_SLIDERS) {
            if(miniSlidersView == nil) {
                miniSlidersView = MiniSlidersView(some: "")
                miniSlidersView?.insertInto(view: imageView)
                
                /*
                let button = UIButton(type: .system)
                button.backgroundColor = .green
                button.frame = miniSlidersView!.frame
                button.addTarget(self, action: #selector(buttonTap(sender:)),
                    for: .touchUpInside)
                self.addSubview(button)
                */
            }
            miniSlidersView?.setValues(val1: 3, val2: 1)
        }
        
        addSubview(headline)
        headline.translatesAutoresizingMaskIntoConstraints = false
        headline.numberOfLines = 5
        headline.textAlignment = .left // .center
        //headline.backgroundColor = .red
        headline.adjustsFontSizeToFitWidth = true
        headline.minimumScaleFactor = 0.5
        headline.lineBreakMode = .byClipping
        NSLayoutConstraint.activate([
            headline.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 6),
            headline.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6),
            headline.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 3),
            //headline.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        
        if(APP_CFG_SHOW_FLAGS) {
            addSubview(flag)
            flag.layer.cornerRadius = 10
            flag.backgroundColor = bgBlue
        
            flag.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                flag.widthAnchor.constraint(equalToConstant: 18),
                flag.heightAnchor.constraint(equalToConstant: 18),
                flag.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                flag.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 5)
            ])
        }
        
        addSubview(source)
        source.translatesAutoresizingMaskIntoConstraints = false
        
        if(APP_CFG_SHOW_FLAGS) {
            NSLayoutConstraint.activate([
                source.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 0),
                source.leadingAnchor.constraint(equalTo: flag.trailingAnchor, constant: 6),
                source.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6)
            ])
        } else {
            NSLayoutConstraint.activate([
                source.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 0),
                source.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                source.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6)
            ])
        }
        
        
        addSubview(pubDate)
        
        pubDate.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pubDate.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            pubDate.topAnchor.constraint(equalTo: source.bottomAnchor, constant: 0),
            pubDate.heightAnchor.constraint(equalToConstant: 20),
            pubDate.widthAnchor.constraint(equalToConstant: 110)
        ])
        pubDate.adjustsFontSizeToFitWidth = true
        //pubDate.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        
        markupView.image = UIImage(systemName: "exclamationmark.triangle")
        markupView.translatesAutoresizingMaskIntoConstraints = false
        markupView.tintColor = accentOrange
        markupView.isHidden = true
        addSubview(markupView)
        
        NSLayoutConstraint.activate([
            markupView.leadingAnchor.constraint(equalTo: pubDate.trailingAnchor, constant: 10),
            markupView.widthAnchor.constraint(equalToConstant: 25),
            markupView.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 3),
            markupView.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        headline.textColor = articleHeadLineColor
        source.textColor = articleSourceColor
        pubDate.textColor = .secondaryLabel
        
        pubDate.font = UIFont(name: "OpenSans-Bold", size: 11)
        //markupView.isHidden = true
    
    }
    
}

// text on left
class ArticleCell: UICollectionViewCell {
    
    static let cellId = "ArticleCell"
    
    var miniSlidersView: MiniSlidersView?
    let imageView = UIImageView(backgroundColor: .clear)
    var headline = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 13), numberOfLines: 3)
    let source = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 12))
    let pubDate = UILabel()
    let logoView = UIImageView()
    let markupView = UIImageView()
    let flag = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
        
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupViews() {
        
        addSubview(headline)
        
        headline.numberOfLines = 10
        headline.translatesAutoresizingMaskIntoConstraints = false
        headline.adjustsFontSizeToFitWidth = true
        headline.minimumScaleFactor = 0.8
        NSLayoutConstraint.activate([
            headline.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            headline.widthAnchor.constraint(equalToConstant: 190),
            headline.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            //headline.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        if(APP_CFG_SHOW_FLAGS) {
            addSubview(flag)
            flag.layer.cornerRadius = 10
            flag.backgroundColor = bgBlue
        
            flag.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                flag.widthAnchor.constraint(equalToConstant: 18),
                flag.heightAnchor.constraint(equalToConstant: 18),
                flag.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                flag.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 5)
            ])
        }
        
        addSubview(source)
        source.adjustsFontSizeToFitWidth = true
        source.translatesAutoresizingMaskIntoConstraints = false
        
        if(APP_CFG_SHOW_FLAGS) {
            NSLayoutConstraint.activate([
                source.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10 + 21),
                source.widthAnchor.constraint(equalToConstant: 120),
                source.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 0)
            ])
        } else {
            NSLayoutConstraint.activate([
                source.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
                source.widthAnchor.constraint(equalToConstant: 120),
                source.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 0)
            ])
        }
        
        addSubview(pubDate)
        pubDate.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pubDate.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            pubDate.widthAnchor.constraint(equalToConstant: 160),
            pubDate.topAnchor.constraint(equalTo: source.bottomAnchor, constant: 0),
            pubDate.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: headline.trailingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            imageView.heightAnchor.constraint(equalToConstant: 120)
        ])
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        
        if(APP_CFG_SHOW_MINI_SLIDERS) {
            if(miniSlidersView == nil) {
                miniSlidersView = MiniSlidersView(some: "")
                miniSlidersView?.insertInto(view: imageView)
            }
            miniSlidersView?.setValues(val1: 3, val2: 1)
        }
        
        
        markupView.image = UIImage(systemName: "exclamationmark.triangle")
        markupView.translatesAutoresizingMaskIntoConstraints = false
        markupView.tintColor = accentOrange
        markupView.isHidden = true
        addSubview(markupView)
        
        NSLayoutConstraint.activate([
            markupView.leadingAnchor.constraint(equalTo: source.trailingAnchor, constant: 5),
            markupView.widthAnchor.constraint(equalToConstant: 20),
            markupView.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 11),
            markupView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        headline.textColor = articleHeadLineColor
        source.textColor = articleSourceColor
        pubDate.textColor = .secondaryLabel
        
        pubDate.font = UIFont(name: "OpenSans-Bold", size: 13)
        
        //self.backgroundColor = UIColor.red.withAlphaComponent(0.5)
    }
    
}

// text on right
class ArticleCellAlt: UICollectionViewCell {
    
    static let cellId = "ArticleCellAlt"
    
    var miniSlidersView: MiniSlidersView?
    let imageView = UIImageView(backgroundColor: .clear)
    var headline = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 13), numberOfLines: 3)
    let source = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 12))
    let pubDate = UILabel()
    let logoView = UIImageView()
    let markupView = UIImageView()
    let flag = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
        
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupViews() {
        
        addSubview(headline)
        
        headline.translatesAutoresizingMaskIntoConstraints = false
        headline.numberOfLines = 10
        headline.adjustsFontSizeToFitWidth = true
        headline.minimumScaleFactor = 0.8
        NSLayoutConstraint.activate([
            headline.widthAnchor.constraint(equalToConstant: 190),
            headline.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            headline.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            //headline.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: headline.leadingAnchor, constant: -10),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            imageView.heightAnchor.constraint(equalToConstant: 120)
        ])
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        
        if(APP_CFG_SHOW_FLAGS) {
            addSubview(flag)
            flag.layer.cornerRadius = 10
            flag.backgroundColor = bgBlue
        
            flag.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                flag.widthAnchor.constraint(equalToConstant: 18),
                flag.heightAnchor.constraint(equalToConstant: 18),
                flag.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
                flag.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 0)
            ])
        }
        
        
        
        
        if(APP_CFG_SHOW_MINI_SLIDERS) {
            if(miniSlidersView == nil) {
                miniSlidersView = MiniSlidersView(some: "")
                miniSlidersView?.insertInto(view: imageView)
            }
            miniSlidersView?.setValues(val1: 3, val2: 1)
        }
        
        addSubview(source)
        source.adjustsFontSizeToFitWidth = true
        source.translatesAutoresizingMaskIntoConstraints = false
        
        if(APP_CFG_SHOW_FLAGS) {
            NSLayoutConstraint.activate([
                source.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10+21),
                source.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
                source.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 0)
            ])
        } else {
            NSLayoutConstraint.activate([
                source.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
                source.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
                source.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 0)
            ])
        }
        
        addSubview(pubDate)
        
        pubDate.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pubDate.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            pubDate.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            pubDate.topAnchor.constraint(equalTo: source.bottomAnchor, constant: 0),
            pubDate.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        markupView.image = UIImage(systemName: "exclamationmark.triangle")
        markupView.translatesAutoresizingMaskIntoConstraints = false
        markupView.tintColor = accentOrange
        markupView.isHidden = true
        addSubview(markupView)
        
        NSLayoutConstraint.activate([
            markupView.leadingAnchor.constraint(equalTo: source.trailingAnchor, constant: 5),
            markupView.widthAnchor.constraint(equalToConstant: 20),
            markupView.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 8),
            markupView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        headline.textColor = articleHeadLineColor
        source.textColor = articleSourceColor
        pubDate.textColor = .secondaryLabel
        
        pubDate.font = UIFont(name: "OpenSans-Bold", size: 13)
        
        //self.backgroundColor = UIColor.green.withAlphaComponent(0.5)
    }
    
}

// 2 column
class ArticleCellHalf: UICollectionViewCell {
    static let cellId = "ArticleCell2"
    
    var miniSlidersView: MiniSlidersView?
    let imageView = UIImageView(backgroundColor: .clear)
    var headline = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 11), numberOfLines: 3)
    let source = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 12))
    let pubDate = UILabel()
    let logoView = UIImageView()
    let markupView = UIImageView()
    let flag = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
        
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupViews() {
    
        imageView.frame = CGRect(x: 10, y: 5, width: self.frame.width-20, height: self.frame.height / 3 + 10)
        headline.frame = CGRect(x: 10, y: imageView.frame.maxY+3, width: imageView.frame.width-5, height: 90)
        headline.numberOfLines = 5
        headline.textAlignment = .left
        //headline.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        headline.adjustsFontSizeToFitWidth = true
        headline.minimumScaleFactor = 0.5
        headline.lineBreakMode = .byClipping
        
        source.frame = CGRect(x: 10, y: headline.frame.maxY, width: self.frame.width - 40, height: 19)
        pubDate.frame = CGRect(x: 10, y: source.frame.maxY, width: self.frame.width - 55, height: 19)
        markupView.frame = CGRect(x: pubDate.frame.maxX + 5, y: headline.frame.maxY+20, width: 20, height: 20)
        source.adjustsFontSizeToFitWidth = true
        
        addSubview(imageView)
        addSubview(headline)
        addSubview(source)
        addSubview(pubDate)
        addSubview(markupView)
        
        headline.textColor = articleHeadLineColor
        source.textColor = articleSourceColor
        pubDate.textColor = .secondaryLabel
        
        pubDate.font = UIFont(name: "OpenSans-Bold", size: 11)
        
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        if(APP_CFG_SHOW_MINI_SLIDERS) {
            if(miniSlidersView == nil) {
                miniSlidersView = MiniSlidersView(some: "")
                miniSlidersView?.insertInto(view: imageView)
            }
            miniSlidersView?.setValues(val1: 3, val2: 1)
        }


        markupView.image = UIImage(systemName: "exclamationmark.triangle")
        markupView.translatesAutoresizingMaskIntoConstraints = false
        markupView.tintColor = accentOrange
        markupView.isHidden = true
        
        /*
        headline.numberOfLines = 10
        headline.adjustsFontSizeToFitWidth = true
        headline.minimumScaleFactor = 0.8
        */
        
        //self.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
    }
    
    func adjust() {
        headline.sizeToFit()
        
        var mFrame = headline.frame
        mFrame.origin.x = imageView.frame.origin.x + ((imageView.frame.size.width-mFrame.size.width)/2)
        headline.frame = mFrame
        
        source.sizeToFit()
        self.move(label1: source, below: headline)
        pubDate.sizeToFit()
        self.move(label1: pubDate, below: source)
        
        if(APP_CFG_SHOW_FLAGS) {
            addSubview(flag)
            flag.layer.cornerRadius = 10
            flag.backgroundColor = bgBlue
        
            flag.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                flag.widthAnchor.constraint(equalToConstant: 18),
                flag.heightAnchor.constraint(equalToConstant: 18),
                flag.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                flag.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 5)
            ])
        }
        
        source.translatesAutoresizingMaskIntoConstraints = false
        if(APP_CFG_SHOW_FLAGS) {
            NSLayoutConstraint.activate([
                source.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 0),
                source.leadingAnchor.constraint(equalTo: flag.trailingAnchor, constant: 6),
                source.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6)
            ])
        } else {
            NSLayoutConstraint.activate([
                source.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 0),
                source.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                source.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6)
            ])
        }
    }
    private func move(label1: UILabel, below label2: UILabel, separation: CGFloat = 0.0) {
        var mFrame = label1.frame
        mFrame.origin.y = label2.frame.origin.y + label2.frame.size.height + separation
        label1.frame = mFrame
    }
    
}

