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
      
    let imageView = UIImageView(backgroundColor: .clear)
    var headline = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 12), numberOfLines: 3)
    let source = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 12))
    let pubDate = UILabel()
    let logoView = UIImageView()
    let markupView = UIImageView()
      
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
          
    required init?(coder: NSCoder) {
        fatalError()
    }
      
    func setupViews() {
        
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalToConstant: self.frame.width * 7 / 12)
        ])
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        
        addSubview(headline)
        headline.translatesAutoresizingMaskIntoConstraints = false
        headline.numberOfLines = 10
        //headline.backgroundColor = .red
        headline.adjustsFontSizeToFitWidth = true
        headline.minimumScaleFactor = 0.8
        NSLayoutConstraint.activate([
            headline.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            headline.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            headline.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            //headline.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        
        addSubview(source)
        source.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            source.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            source.widthAnchor.constraint(equalToConstant: 130),
            source.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 0),
            source.heightAnchor.constraint(equalToConstant: 20)
        ])
        source.adjustsFontSizeToFitWidth = true
        
        addSubview(pubDate)
        
        pubDate.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pubDate.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            pubDate.topAnchor.constraint(equalTo: source.bottomAnchor, constant: 0),
            pubDate.heightAnchor.constraint(equalToConstant: 20),
            pubDate.widthAnchor.constraint(equalToConstant: 110)
        ])
        
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
        
        pubDate.font = UIFont(name: "OpenSans-Bold", size: 12)
        //markupView.isHidden = true
    
    }
    
}

// text on left
class ArticleCell: UICollectionViewCell {
    
    static let cellId = "ArticleCell"
    
    let imageView = UIImageView(backgroundColor: .clear)
    var headline = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 14), numberOfLines: 3)
    let source = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 12))
    let pubDate = UILabel()
    let logoView = UIImageView()
    let markupView = UIImageView()
    
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
        
        addSubview(source)
        source.adjustsFontSizeToFitWidth = true
        
        source.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            source.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            source.widthAnchor.constraint(equalToConstant: 120),
            source.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 0),
            source.heightAnchor.constraint(equalToConstant: 20)
        ])
        
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
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 120)
        ])
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        
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
        
        pubDate.font = UIFont(name: "OpenSans-Bold", size: 14)
    }
    
}

// text on right
class ArticleCellAlt: UICollectionViewCell {
    
    static let cellId = "ArticleCellAlt"
    
    let imageView = UIImageView(backgroundColor: .clear)
    var headline = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 14), numberOfLines: 3)
    let source = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 12))
    let pubDate = UILabel()
    let logoView = UIImageView()
    let markupView = UIImageView()
    
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
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 120)
        ])
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        
        addSubview(source)
        source.adjustsFontSizeToFitWidth = true
        
        source.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            source.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            source.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            source.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 0),
            source.heightAnchor.constraint(equalToConstant: 20)
        ])
        
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
        
        pubDate.font = UIFont(name: "OpenSans-Bold", size: 14)
    }
    
}

// 2 column
class ArticleCellHalf: UICollectionViewCell {
    static let cellId = "ArticleCell2"
    
    let imageView = UIImageView(backgroundColor: .clear)
    var headline = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 12), numberOfLines: 3)
    let source = UILabel(font: UIFont(name: "Poppins-SemiBold", size: 12))
    let pubDate = UILabel()
    let logoView = UIImageView()
    let markupView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
        
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupViews() {
    
        imageView.frame = CGRect(x: 10, y: 10, width: self.frame.width-20, height: self.frame.height / 3 + 10)
        headline.frame = CGRect(x: 10, y: imageView.frame.maxY+3, width: imageView.frame.width-5, height: 90)
        source.frame = CGRect(x: 10, y: headline.frame.maxY, width: self.frame.width - 40, height: 19)
        pubDate.frame = CGRect(x: 10, y: headline.frame.maxY+20, width: self.frame.width - 55, height: 19)
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
        
        pubDate.font = UIFont(name: "OpenSans-Bold", size: 14)
        
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true

        markupView.image = UIImage(systemName: "exclamationmark.triangle")
        markupView.translatesAutoresizingMaskIntoConstraints = false
        markupView.tintColor = accentOrange
        markupView.isHidden = true
        
        headline.numberOfLines = 10
        headline.adjustsFontSizeToFitWidth = true
        headline.minimumScaleFactor = 0.8
    }
    
}

