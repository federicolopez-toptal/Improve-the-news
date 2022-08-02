//
//  StoryContentIPADViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 01/08/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit
import SDWebImage


class StoryContentIPADViewController: UIViewController {

    // ---------------
    private var firstTime: Bool = true
    public var link: String?
    public var api_call: String?

    private var storyData: StoryData?
    private var facts: [StoryFact]?
    private var sources: [String]?
    private var spins: [StorySpin]?
    private var articles: [StoryArticle]?
    private var version: String?

    // ---------------
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainImageCreditButton: UIButton!
    
    let mainImageViewWidthFactor: CGFloat = 0.4
    @IBOutlet weak var mainImageViewWidthConstraint: NSLayoutConstraint!
    
    private var spinCol = 1
    private var artCol = 1
    
    // ---------------
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setContentView()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
            
        SETUP_NAVBAR(viewController: self,
            homeTap: nil,
            menuTap: #selector(self.hamburgerButtonItemClicked(_:)),
            searchTap: #selector(self.searchItemClicked(_:)),
            userTap: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if(self.firstTime) {
            self.firstTime = false
            self.loadData()
        }
    }
    
    private func loadData() {
    
        var _api_call = ""
        var _filter = ""
        if(self.api_call != nil){ _api_call = self.api_call! }

        if let _url = URL(string: _api_call) {
            _filter = _url.params()["sliders"] as! String
        }


//        self.removeAllFacts()
        self.spinCol = 1
        self.removeAllSpins()
        self.artCol = 1
        self.removeAllArticles()
        
        if let _link = self.link {
            StoryContent.instance.loadData(link: _link, filter: _filter) { (storyData, facts, spins, articles, version) in
                self.storyData = storyData
                self.facts = facts
                self.spins = spins
                self.articles = articles
                self.version = version

                self.updateUI()
                //self.showLoading(false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = DARKMODE() ? .white : darkForBright
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return STATUS_BAR_STYLE()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    // MARK: - Modified TitleBar
    @objc func hamburgerButtonItemClicked(_ sender: UIBarButtonItem!) {
        navigationController?.customPushViewController(SectionsViewController())
    }
    
    @objc func searchItemClicked(_ sender:UIBarButtonItem!) {
        let searchvc = SearchViewController()
        navigationController?.pushViewController(searchvc, animated: true)
    }

}

// PRAGMA MARK: - UI
extension StoryContentIPADViewController {

    public static func createInstance() -> StoryContentIPADViewController {
        let vc = StoryContentIPADViewController(nibName: "StoryContentIPADViewController",
            bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    private func setContentView() {
        let screen_W = UIScreen.main.bounds.size.width
        
        self.view.backgroundColor = DARKMODE() ? bgBlue_LIGHT : bgWhite_LIGHT
        self.scrollView.backgroundColor = self.view.backgroundColor
        
        self.scrollView.addSubview(self.contentView)
        self.contentView.frame = CGRect(x: 0, y: 0,
            width: screen_W, height: self.contentView.frame.size.height)
        self.contentView.backgroundColor = self.scrollView.backgroundColor
        self.scrollView.contentSize = CGSize(width: screen_W, height: self.contentView.frame.size.height)

//        self.scrollView.isHidden = true
    }
    
    private func updateUI() {
        let screen_W = UIScreen.main.bounds.size.width
        
        DispatchQueue.main.async {
        
            self.mainTitle.textColor = self.C(0xFFFFFF, 0x1D242F)
            self.mainImageViewWidthConstraint.constant = screen_W * self.mainImageViewWidthFactor
        
            let spinTitleLabel = self.contentView.viewWithTag(102) as! UILabel
            spinTitleLabel.textColor = self.C(0xFF643C, 0x1D242F)
            let articlesTitleLabel = self.contentView.viewWithTag(104) as! UILabel
            articlesTitleLabel.textColor = self.C(0xFFFFFF, 0xFF643C)
        
            if let _data = self.storyData {
                self.mainTitle.text = _data.title
                self.mainImageView.sd_setImage(with: URL(string: _data.image_src),
                    placeholderImage: nil)
                    
                let credit = "Image credit: " + _data.image_credit_title
                self.mainImageCreditButton.setCustomAttributedText(credit, color: UIColor(hex: 0x93A0B4))
                
                // DATA
                self.addSpins()
                self.addArticles()
                
                DELAY(0.25) {
                    self.updateContentSize()
                }
            } else {
                self.mainTitle.text = ""
                self.mainImageView.image = nil
                self.mainImageCreditButton.setCustomAttributedText("", color: UIColor(hex: 0x93A0B4))
            }
        }
    }
    
    @objc func onDeviceOrientationChanged() {
        let screen_W = UIScreen.main.bounds.size.width
    
        var mFrame = self.contentView.frame
        mFrame.size.width = screen_W
        self.contentView.frame = mFrame
        
        self.mainImageViewWidthConstraint.constant = screen_W * self.mainImageViewWidthFactor
    }
    
    private func updateContentSize() {
        let bottomGreenView = self.contentView.viewWithTag(999)!
        bottomGreenView.alpha = 0.0
        
        let screen_W = UIScreen.main.bounds.size.width
        let height: CGFloat = bottomGreenView.frame.origin.y + bottomGreenView.frame.size.height
        
        self.contentView.frame = CGRect(x: 0, y: 0, width: screen_W, height: height)
        self.scrollView.contentSize = CGSize(width: screen_W, height: height)
    }
    
}

// PRAGMA MARK: - misc
extension StoryContentIPADViewController {
    private func C(_ darkColorHex: Int, _ brightColorHex: Int) -> UIColor {
        return DARKMODE() ? UIColor(hex: darkColorHex) : UIColor(hex: brightColorHex)
    }

    private func OPEN_URL(_ url: String, title: String = "") {
        let vc = PlainWebViewController(url: url, title: title)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func GET_FLAG(id: String) -> UIImage {
        var result = UIImage(named: "\(id.uppercased())64.png")
        if(result==nil) {
            result = UIImage(named: "noFlag.png")
        }
        return result!
    }
    
    private func LR_PE(name: String) -> (Int, Int) {
        let parts = name.components(separatedBy: " #")
        let extName = parts.first!.lowercased()
        
        let LR = StorySourceManager.shared.getLR(name: extName)
        let PE = StorySourceManager.shared.getPE(name: extName)
        
        return (LR, PE)
    }
    
}

// PRAGMA MARK: - UIGestureRecognizerDelegate
extension StoryContentIPADViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
}

// PRAGMA MARK: - Button(s)
extension StoryContentIPADViewController {

    @IBAction func homeButtonTap(_ sender: UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
     @IBAction func mainImageCreditButtonTap(_ sender: UIButton) {
        if let _data = self.storyData {
            self.OPEN_URL(_data.image_credit_url, title: _data.image_credit_title)
        }
    }
    
}

// PRAGMA MARK: Spin(s)
extension StoryContentIPADViewController {
    
    private func removeAllSpins() {
        let spinsVContainer = self.contentView.viewWithTag(103) as! UIStackView
        spinsVContainer.removeAllArrangedSubviews()
    }
    
    private func addSpins() {
        if let _spins = self.spins {
            for (i, SP) in _spins.enumerated() {
                self.addSingleSpin(SP, index: i)
            }
        }
    }
    
    private func addSingleSpin(_ spin: StorySpin, index: Int) {
        let v_main_container = self.contentView.viewWithTag(103) as! UIStackView
        var h_colS_container: UIStackView!
        
        if(self.spinCol == 1) {
            // New col
            h_colS_container = UIStackView()
            h_colS_container.axis = .horizontal
            h_colS_container.spacing = 20
            h_colS_container.backgroundColor = .clear //.green
            v_main_container.addArrangedSubview(h_colS_container)
        } else {
            h_colS_container = (v_main_container.subviews.last as! UIStackView)
        }
        self.spinCol += 1
        if(self.spinCol>2){ self.spinCol = 1 }
        
        let v_col_container = UIStackView()
        v_col_container.axis = .vertical
        v_col_container.spacing = 10
        v_col_container.backgroundColor = .clear //.yellow
        h_colS_container.addArrangedSubview(v_col_container)
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Merriweather-Bold", size: 17)
        titleLabel.text = spin.title
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = self.C(0xFFFFFF, 0xFF643C)
        v_col_container.addArrangedSubview(titleLabel)
        titleLabel.tag = 200 + index
        self.ADD_SPIN_TAP(to: titleLabel)

        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont(name: "Roboto-Regular", size: 16)!
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.textColor = self.C(0x93A0B4, 0x1D242F)
        descriptionLabel.text = spin.description
        v_col_container.addArrangedSubview(descriptionLabel)
        descriptionLabel.tag = 200 + index
        self.ADD_SPIN_TAP(to: descriptionLabel)

        let h_img_container = UIStackView()
        h_img_container.axis = .horizontal
        h_img_container.backgroundColor = .clear
        h_img_container.spacing = 10.0

        let factor: CGFloat = 1.3
        let imageView = UIImageView()
        imageView.contentMode = self.mainImageView.contentMode
        imageView.clipsToBounds = true
        imageView.backgroundColor = .darkGray
        h_img_container.addArrangedSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 112 * factor),
            imageView.heightAnchor.constraint(equalToConstant: 75 * factor)
        ])
        imageView.sd_setImage(with: URL(string: spin.image), placeholderImage: nil)
        imageView.tag = 200 + index
        self.ADD_SPIN_TAP(to: imageView)

        let v_data_container = UIStackView()
        v_data_container.axis = .vertical
        v_data_container.spacing = 2.0
        v_data_container.backgroundColor = .clear

        let spinTitleLabel = UILabel()
        spinTitleLabel.text = spin.subTitle
        spinTitleLabel.numberOfLines = 3
        spinTitleLabel.font = UIFont(name: "Merriweather-Bold", size: 17)
        spinTitleLabel.textColor = self.C(0xFFFFFF, 0x1D242F)
        spinTitleLabel.adjustsFontSizeToFitWidth = true
        spinTitleLabel.minimumScaleFactor = 0.5
        v_data_container.addArrangedSubview(spinTitleLabel)
        spinTitleLabel.tag = 200 + index
        self.ADD_SPIN_TAP(to: spinTitleLabel)

        let h_flag_container = UIStackView()
        h_flag_container.axis = .horizontal
        h_flag_container.backgroundColor = .clear
        h_flag_container.spacing = 7.0
        NSLayoutConstraint.activate([
            h_flag_container.heightAnchor.constraint(equalToConstant: 28.0)
        ])

        if let _countryCode = spin.media_country_code {
            let flag = UIImageView()
            flag.contentMode = .scaleAspectFit
            flag.image = self.GET_FLAG(id: _countryCode)

            h_flag_container.addArrangedSubview(flag)
            flag.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                flag.widthAnchor.constraint(equalToConstant: 20),
                flag.heightAnchor.constraint(equalToConstant: 20)
            ])
        }

        let sourceTime = UILabel()
        //let source = spin.media_title.replacingOccurrences(of: " #", with: "")
//        sourceTime.text = source + " - " + FORMAT_TIME(spin.time)
        sourceTime.text = spin.media_title.components(separatedBy: " #").first! // + " - " + FORMAT_TIME(spin.time)
        //self.LR_PE(name: spin.media_title)

        sourceTime.textColor = self.C(0x93A0B4, 0x1D242F)
        sourceTime.font = UIFont(name: "Roboto-Regular", size: 14)!
        h_flag_container.addArrangedSubview(sourceTime)

        let miniSlider = MiniSlidersCircView(some: "")
        miniSlider.insertInto(stackView: h_flag_container)
        let LR_PE = self.LR_PE(name: spin.media_title)
        if(LR_PE.0==0 && LR_PE.1==0) {
            miniSlider.isHidden = true
        } else {
            miniSlider.setValues(val1: LR_PE.0, val2: LR_PE.1)
        }

        let spacer2 = UIView()
        spacer2.backgroundColor = .clear
        h_flag_container.addArrangedSubview(spacer2)


        v_data_container.addArrangedSubview(h_flag_container)

        let spacer = UIView()
        spacer.backgroundColor = .clear
        v_data_container.addArrangedSubview(spacer)

        h_img_container.addArrangedSubview(v_data_container)
        v_col_container.addArrangedSubview(h_img_container)
        
        let extraHeight = UIView()
        extraHeight.backgroundColor = .clear
        v_col_container.addArrangedSubview(extraHeight)
        extraHeight.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            extraHeight.heightAnchor.constraint(equalToConstant: 25)
        ])

        // ---------

//        let stackSpacer = UIStackView()
//        stackSpacer.axis = .vertical
//        stackSpacer.backgroundColor = .clear
//        main_V_container.addArrangedSubview(stackSpacer)
//        stackSpacer.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            stackSpacer.heightAnchor.constraint(equalToConstant: 13)
//        ])
//
//        for i in 1...3 {
//            let view = UIView()
//            view.backgroundColor = .clear
//            stackSpacer.addArrangedSubview(view)
//
//            //view.backgroundColor = self.C(0x93A0B4, 0x1D242F)
//            var H: CGFloat = 6.0
//            if(i==2) {
//                H = 2
//            }
//
//            view.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                view.heightAnchor.constraint(equalToConstant: H)
//            ])
//
//            if(i==2) {
//                let lineImageView = UIImageView()
//                lineImageView.image = UIImage(named: "StoryArticleLineSep.png")
//                lineImageView.backgroundColor = .clear
//                lineImageView.alpha = 0.7
//                view.addSubview(lineImageView)
//                view.clipsToBounds = true
//                lineImageView.translatesAutoresizingMaskIntoConstraints = false
//                NSLayoutConstraint.activate([
//                    lineImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                    lineImageView.topAnchor.constraint(equalTo: view.topAnchor),
//                    lineImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//                    lineImageView.widthAnchor.constraint(equalToConstant: 1080/2)
//                ])
//            }
//        }
//
//

        if(self.spinCol==2 && index<self.spins!.count-1) {
            // VERTICAL LINE
            let vLine = UIView()
            vLine.backgroundColor = .cyan
            h_colS_container.addSubview(vLine)
            
            vLine.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vLine.topAnchor.constraint(equalTo: h_colS_container.topAnchor),
                vLine.bottomAnchor.constraint(equalTo: h_colS_container.bottomAnchor),
                vLine.widthAnchor.constraint(equalToConstant: 4),
                vLine.centerXAnchor.constraint(equalTo: h_colS_container.centerXAnchor)
            ])
        }
        
        var add_H_line = false
        if(self.spinCol==1 && index>0) {
            add_H_line = true
        }

        if(self.spinCol==2 && index==self.spins!.count-1) {
            // Spacer
            let spacer = UIStackView()
            spacer.axis = .vertical
            spacer.spacing = 10
            spacer.backgroundColor = .clear
            h_colS_container.addArrangedSubview(spacer)
            
            let titleLabel = UILabel()
            titleLabel.text = "Lorem ipsum"
            titleLabel.numberOfLines = 0
            titleLabel.textColor = .clear
            spacer.addArrangedSubview(titleLabel)
            
            add_H_line = true
        }
        
        if(add_H_line) {
        // HORIZONTAL LINE
            let hLine = UIView()
            hLine.backgroundColor = .systemPink
            v_main_container.addArrangedSubview(hLine)
            
            hLine.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hLine.leadingAnchor.constraint(equalTo: v_main_container.leadingAnchor),
                hLine.trailingAnchor.constraint(equalTo: v_main_container.trailingAnchor),
                hLine.heightAnchor.constraint(equalToConstant: 4)
            ])
        }
        
        v_main_container.backgroundColor = .clear
    }
    
    @IBAction func spinOnTap(_ sender: UITapGestureRecognizer) {
        let tag = sender.view!.tag - 200
        
        let spin = self.spins![tag]
        self.OPEN_URL(spin.url, title: spin.subTitle)
    }
    
    private func ADD_SPIN_TAP(to view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(spinOnTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
}

// PRAGMA MARK: - Article(s)
extension StoryContentIPADViewController {
    
    private func removeAllArticles() {
        let articlesVContainer = self.contentView.viewWithTag(105) as! UIStackView
        articlesVContainer.removeAllArrangedSubviews()
    }
    
    private func addArticles() {
        if let _articles = self.articles {
            for (i, AR) in _articles.enumerated() {
                self.addSingleArticle(AR, index: i)
            }
        }
    }
    
    private func addSingleArticle(_ article: StoryArticle, index: Int) {
        let v_main_container = self.contentView.viewWithTag(105) as! UIStackView
        var h_colS_container: UIStackView!
        
        if(self.artCol == 1) {
            // New col
            h_colS_container = UIStackView()
            h_colS_container.axis = .horizontal
            h_colS_container.spacing = 15
            h_colS_container.backgroundColor = .green
            v_main_container.addArrangedSubview(h_colS_container)
        } else {
            h_colS_container = (v_main_container.subviews.last as! UIStackView)
        }
        self.artCol += 1
        if(self.artCol>3){ self.artCol = 1 }
        
        
        let h_img_container = UIStackView()
        h_img_container.axis = .horizontal
        h_img_container.backgroundColor = .blue
        h_img_container.spacing = 10.0
        
        let factor: CGFloat = 1.3
        let imageView = UIImageView()
        imageView.contentMode = self.mainImageView.contentMode
        imageView.clipsToBounds = true
        imageView.backgroundColor = .darkGray
        h_img_container.addArrangedSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 112 * factor),
            imageView.heightAnchor.constraint(equalToConstant: 75 * factor)
        ])
        imageView.sd_setImage(with: URL(string: article.image), placeholderImage: nil)
        imageView.tag = 300 + index
        self.ADD_ARTICLE_TAP(to: imageView)
        
        let v_data_container = UIStackView()
        v_data_container.axis = .vertical
        v_data_container.spacing = 2.0
        v_data_container.backgroundColor = .clear
        
        let articleTitleLabel = UILabel()
        articleTitleLabel.text = article.title
        articleTitleLabel.numberOfLines = 4
        articleTitleLabel.font = UIFont(name: "Merriweather-Bold", size: 17)
        articleTitleLabel.textColor = self.C(0xFFFFFF, 0x1D242F)
        articleTitleLabel.adjustsFontSizeToFitWidth = true
        articleTitleLabel.minimumScaleFactor = 0.5
        v_data_container.addArrangedSubview(articleTitleLabel)
        articleTitleLabel.tag = 300 + index
        self.ADD_ARTICLE_TAP(to: articleTitleLabel)
        
        let h_flag_container = UIStackView()
        h_flag_container.axis = .horizontal
        h_flag_container.backgroundColor = .clear
        h_flag_container.spacing = 7.0
        NSLayoutConstraint.activate([
            h_flag_container.heightAnchor.constraint(equalToConstant: 28.0)
        ])
        
        if let _countryCode = article.media_country_code {
            let flag = UIImageView()
            flag.contentMode = .scaleAspectFit
            flag.image = self.GET_FLAG(id: _countryCode)
            
            h_flag_container.addArrangedSubview(flag)
            flag.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                flag.widthAnchor.constraint(equalToConstant: 20),
                flag.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        
        let sourceTime = UILabel()
//        let source = article.media_title.replacingOccurrences(of: " #", with: "")
//        sourceTime.text = source + " - " + FORMAT_TIME(spin.time)
        sourceTime.text = article.media_title.components(separatedBy: " #").first! // + " - " + FORMAT_TIME(spin.time)
        sourceTime.textColor = self.C(0x93A0B4, 0x1D242F)
        sourceTime.font = UIFont(name: "Roboto-Regular", size: 14)!
        h_flag_container.addArrangedSubview(sourceTime)
        
        let miniSlider = MiniSlidersCircView(some: "")
        miniSlider.insertInto(stackView: h_flag_container)
        let LR_PE = self.LR_PE(name: article.media_title)
        if(LR_PE.0==0 && LR_PE.1==0) {
            miniSlider.isHidden = true
        } else {
            miniSlider.setValues(val1: LR_PE.0, val2: LR_PE.1)
        }
        
        let spacer2 = UIView()
        spacer2.backgroundColor = .clear
        h_flag_container.addArrangedSubview(spacer2)
        v_data_container.addArrangedSubview(h_flag_container)
        
        let spacer = UIView()
        spacer.backgroundColor = .clear
        v_data_container.addArrangedSubview(spacer)
        
        h_img_container.addArrangedSubview(v_data_container)
        h_colS_container.addArrangedSubview(h_img_container)
        
        // ---------
        
        if(index==self.articles!.count-1) {
            let col = self.artCol-1
            
            if(col==1 || col==2) {
                for i in col+1...3 {
                    // Spacer
                    let spacer = UIStackView()
                    spacer.axis = .horizontal
                    spacer.spacing = 15
                    spacer.backgroundColor = .clear
                    h_colS_container.addArrangedSubview(spacer)
                    
                    let titleLabel = UILabel()
                    titleLabel.text = "Lorem ipsum"
                    titleLabel.numberOfLines = 0
                    titleLabel.textColor = .clear
                    spacer.addArrangedSubview(titleLabel)
                }
            }
        }


        //v_main_container.backgroundColor = .clear
    }
    
    private func ADD_ARTICLE_TAP(to view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(articleOnTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    @IBAction func articleOnTap(_ sender: UITapGestureRecognizer) {
        let tag = sender.view!.tag - 300
        
        let article = self.articles![tag]
        self.OPEN_URL(article.url, title: article.title)
    }
    
}


