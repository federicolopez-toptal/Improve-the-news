//
//  StoryContentViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 07/07/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftUI


class StoryContentViewController: UIViewController {
    
    public var link: String?
    
    private var storyData: StoryData?
    private var facts: [StoryFact]?
    private var spins: [StorySpin]?
    private var articles: [StoryArticle]?
    private var version: String?
    
    private var sourceRow: Int = 0
    private var sourceWidths = [CGFloat]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainImageCreditButton: UIButton!
    @IBOutlet weak var factsSourceSeparation: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setContentView()
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.removeAllFacts()
        if let _link = self.link {
            StoryContent.instance.loadData(link: _link) { (storyData, facts, spins, articles, version) in
                self.storyData = storyData
                self.facts = facts
                self.spins = spins
                self.articles = articles
                self.version = version

                self.updateUI()
            }
        }
    }
    
}

// MARK: - UI
extension StoryContentViewController {

    public static func createInstance() -> StoryContentViewController {
        let vc = StoryContentViewController(nibName: "StoryContentViewController", bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    private func setContentView() {
        let screen_W = UIScreen.main.bounds.size.width
        
        self.view.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
        self.scrollView.backgroundColor = self.view.backgroundColor
        
        self.scrollView.addSubview(self.contentView)
        self.contentView.frame = CGRect(x: 0, y: 0, width: screen_W, height: self.contentView.frame.size.height)
        self.scrollView.contentSize = CGSize(width: screen_W, height: self.contentView.frame.size.height)
        
        self.scrollView.isHidden = true
    }
    
    private func C(_ darkColorHex: Int, _ brightColorHex: Int) -> UIColor {
        return DARKMODE() ? UIColor(hex: darkColorHex) : UIColor(hex: brightColorHex)
    }
    
    private func updateUI() {
        DispatchQueue.main.async {

            self.mainTitle.textColor = self.C(0xFFFFFF, 0x1D242F)
            self.mainImageCreditButton.backgroundColor = .clear
            
            let factsVContainer = self.contentView.viewWithTag(100) as! UIStackView
            factsVContainer.backgroundColor = self.scrollView.backgroundColor
                let factsView = factsVContainer.superview
                factsView?.backgroundColor = self.scrollView.backgroundColor
                factsView?.layer.borderWidth = 8.0
                factsView?.layer.borderColor = self.C(0x1D2530, 0xE1E3E3).cgColor
                    let factsTitle = factsView?.subviews.first as! UILabel
                    factsTitle.textColor = self.C(0xFFFFFF, 0x1D242F)
                    let line = factsView?.subviews[3] as! UIView
                    line.backgroundColor = self.C(0x1E2634, 0xE2E3E3)
                    let sourcesTitle = factsView?.subviews[4] as! UILabel
                    sourcesTitle.textColor = factsTitle.textColor
            let sourcesVContainer = self.contentView.viewWithTag(101) as! UIStackView
                sourcesVContainer.backgroundColor = self.scrollView.backgroundColor
            
            if let _data = self.storyData {
                self.title = _data.title
                self.mainTitle.text = _data.title
                self.mainImageView.sd_setImage(with: URL(string: _data.image_src), placeholderImage: nil)
                
                let credit = "Image credit: " + _data.image_credit_title
                self.mainImageCreditButton.setCustomAttributedText(credit, color: UIColor(hex: 0x93A0B4))

                self.addFacts()
            } else {
                self.title = ""
                self.mainTitle.text = ""
                self.mainImageView.image = nil
                self.mainImageCreditButton.setCustomAttributedText("", color: UIColor(hex: 0x93A0B4))
            }
            
            self.contentView.backgroundColor = self.scrollView.backgroundColor
            self.scrollView.isHidden = false
        }
    }
    
    private func removeAllFacts() {
        let factsVContainer = self.contentView.viewWithTag(100) as! UIStackView
        factsVContainer.removeAllArrangedSubviews()
        
        let sourcesVContainer = self.contentView.viewWithTag(101) as! UIStackView
        sourcesVContainer.removeAllArrangedSubviews()
        
        self.sourceRow = -1
        self.sourceWidths = [CGFloat]()
    }
    
    private func addFacts() {
        let factsVContainer = self.contentView.viewWithTag(100) as! UIStackView
        
        if let _facts = self.facts {
            if(factsVContainer.arrangedSubviews.count==0) {
                // Initial 3
                for (i, F) in _facts.enumerated() {
                    if(i<=2) {
                        self.addSingleFact(F, isLast: i == 2, index: i)
                    }
                }
            } else {
                // The rest
                for (i, F) in _facts.enumerated() {
                    if(i>2) {
                        self.addSingleFact(F, isLast: i == self.facts!.count-1, index: i)
                    }
                }
            }
        }
    }
    
    private func addSingleFact(_ fact: StoryFact, isLast: Bool = false, index: Int) {
        let factsVContainer = self.contentView.viewWithTag(100) as! UIStackView
        let sourcesVContainer = self.contentView.viewWithTag(101) as! UIStackView
        
        // FACT
        let factHStack = UIStackView()
        factHStack.backgroundColor  = .clear
        factHStack.axis = .horizontal
        
        let dotContainer = UIView()
        dotContainer.backgroundColor = .clear
        factHStack.addArrangedSubview(dotContainer)
        dotContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dotContainer.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        let dot = UIView()
        dot.backgroundColor = UIColor(hex: 0xFF643C)
        dotContainer.addSubview(dot)
        dot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dot.centerXAnchor.constraint(equalTo: dotContainer.centerXAnchor),
            dot.topAnchor.constraint(equalTo: dotContainer.topAnchor, constant: 6),
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8)
        ])
        
        let factLabel = UILabel()
        factLabel.numberOfLines = 0
        factLabel.backgroundColor = .clear
        factLabel.font = UIFont(name: "Merriweather-Bold", size: 15)
        factLabel.text = fact.title
        factLabel.textColor = self.C(0xFFFFFF, 0x1D242F)
        factHStack.addArrangedSubview(factLabel)
        factsVContainer.addArrangedSubview(factHStack)
        
        // SOURCE
        if(self.sourceRow == -1) {
            let sourcesHStack = UIStackView()
            sourcesHStack.backgroundColor  = self.scrollView.backgroundColor
            sourcesHStack.axis = .horizontal
            sourcesHStack.spacing = 10
            sourcesVContainer.addArrangedSubview(sourcesHStack)
            
            self.sourceRow = 0
        }
        var sourcesHStack = sourcesVContainer.arrangedSubviews[self.sourceRow] as! UIStackView
        
        if(!isLast) {
            if let _last = sourcesHStack.arrangedSubviews.last, _last.alpha == 0 {
                _last.removeFromSuperview()
            }
        }
        
        let _sourceHeight: CGFloat = 21.0
        let _sourceFont = UIFont(name: "Roboto-Regular", size: 15)!
        let _sourceText = " " + fact.source_title + " "
        let _sourceWidth = _sourceText.width(withConstraintedHeight: _sourceHeight,
            font: _sourceFont)
            
        var _widthSum: CGFloat = 0
        let _widthTotal = UIScreen.main.bounds.width - 20 - 40
        for W in self.sourceWidths {
            _widthSum += W + sourcesHStack.spacing
        }
        if(_widthSum + _sourceWidth > _widthTotal) {
            let spacer = UIView()
            spacer.backgroundColor = .blue
            spacer.alpha = 0
            sourcesHStack.addArrangedSubview(spacer)
            
            let newSourcesHStack = UIStackView()
            newSourcesHStack.backgroundColor  = self.scrollView.backgroundColor
            newSourcesHStack.axis = .horizontal
            newSourcesHStack.spacing = 10
            sourcesVContainer.addArrangedSubview(newSourcesHStack)
            
            self.sourceRow += 1
            self.sourceWidths = [CGFloat]()
            sourcesHStack = sourcesVContainer.arrangedSubviews[self.sourceRow] as! UIStackView
        }
        
        let sourceLabel = UILabel()
        sourceLabel.numberOfLines = 1
        sourceLabel.backgroundColor = self.scrollView.backgroundColor
        sourceLabel.font = _sourceFont
        sourceLabel.text = _sourceText
        sourceLabel.tag = 150 + index
        sourceLabel.textColor = UIColor(hex: 0xFF643C)
        sourcesHStack.addArrangedSubview(sourceLabel)
        sourceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sourceLabel.heightAnchor.constraint(equalToConstant: 21),
            sourceLabel.widthAnchor.constraint(equalToConstant: _sourceWidth)
        ])
        self.sourceWidths.append(_sourceWidth)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(sourceLabelTap(_:)))
        sourceLabel.addGestureRecognizer(tap)
        sourceLabel.isUserInteractionEnabled = true
        
        if(isLast) {
            let spacer = UIView()
            spacer.backgroundColor = .blue
            spacer.alpha = 0
            sourcesHStack.addArrangedSubview(spacer)
        }
    }
    
}

// MARK: - Button taps
extension StoryContentViewController {
    
    @IBAction func showMoreSourcesButtonTap(_ sender: UIButton) {
        sender.isHidden = true
        self.factsSourceSeparation.constant = 20
        self.addFacts()
    }
    
    private func OPEN_URL(_ url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func mainImageCreditButtonTap(_ sender: UIButton) {
        if let _data = self.storyData {
            self.OPEN_URL(_data.image_credit_url)
        }
    }
    
    @IBAction func sourceLabelTap(_ sender: UITapGestureRecognizer) {
        let label = sender.view as! UILabel
        let tag = label.tag - 150
        
        let fact = self.facts![tag]
        self.OPEN_URL(fact.source_url)
    }
    
}
