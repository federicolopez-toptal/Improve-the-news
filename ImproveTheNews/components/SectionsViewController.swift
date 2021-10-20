//
//  SectionsViewController.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 5/30/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import UIKit
import SafariServices

class SectionViewCell: UITableViewCell {
    
    static let cellId = "SectionViewCell"
    var sectionTitle = UILabel()
    
    var title: String! {
        didSet {
            sectionTitle.text = title
            sectionTitle.textColor = .label
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(sectionTitle)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

let NOTIFICATION_SHOW_ONBOARDING = Notification.Name("showOnboarding")
class SectionsViewController: UIViewController {
    
    var support = [String]()
    let feedbackForm = "https://docs.google.com/forms/d/e/1FAIpQLSfoGi4VkL99kV4nESvK71k4NgzcVuIo4o-JDrlmBqArLR_IYA/viewform"
        
    let tableView = UITableView()
    var safeArea: UILayoutGuide!
    
    private let appLayouts = [layoutType.denseIntense,
                                layoutType.textOnly,
                                layoutType.bigBeautiful]
    // layoutType.bigBeautiful,
    
    override func loadView() {
        super.loadView()
        
        self.support = ["FAQ", "How the sliders work", "Feedback", "Privacy Policy", "Contact"]
        if(APP_CFG_SHOW_LAYOUTS) {
            self.support.append("Change Layout")
        }
        if(Utils.shared.displayMode == .dark) {
            self.support.append("Enable Bright mode")
        } else {
            self.support.append("Enable Dark mode")
        }
        
        if(APP_CFG_SHOW_SOURCES) {
            self.support.append("Source filters")
        }
        
        if(APP_CFG_MORE_PREFS) {
            self.support.append("More Preferences")
        }
        self.support.append("Tour")
        
        navigationItem.largeTitleDisplayMode = .never
        safeArea = view.layoutMarginsGuide
        
        navigationItem.title = "Support"
        setupTableView()
        
        self.view.backgroundColor = DARKMODE() ? .black : bgWhite_LIGHT
        self.tableView.backgroundColor = self.view.backgroundColor
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
            constant: -25).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(DARKMODE()){ overrideUserInterfaceStyle = .dark }
        tableView.register(SectionViewCell.self, forCellReuseIdentifier: SectionViewCell.cellId)
        
        let img = UIImage(systemName: "chevron.right")
        let customBackButton = UIBarButtonItem(image: img, style: .plain,
            target: self, action: #selector(customBackButtonTap(sender:)))
        self.navigationItem.rightBarButtonItem  = customBackButton
        
        self.addVersionNumber()
    }
    
    private func addVersionNumber() {
        
        var val_y = UIScreen.main.bounds.height - 25 - 88 - 20
        if(SAFE_AREA()!.bottom==0) {
            val_y = UIScreen.main.bounds.height - 25 - 20 - 48
        }
        
        let val_w = UIScreen.main.bounds.width - 30
        let vLabel = UILabel(text: "version 1.0",
                        font: UIFont(name: "Poppins-SemiBold", size: 13),
                        textColor: accentOrange,
                        textAlignment: .center,
                        numberOfLines: 1)
        vLabel.backgroundColor = .clear
        vLabel.frame = CGRect(x: 15, y: val_y, width: val_w, height: 25)
        vLabel.alpha = 0.75
        
        vLabel.text = "version " + Bundle.main.releaseVersionNumber! + " (build " +
                    Bundle.main.buildVersionNumber! + ")"
        
        self.view.addSubview(vLabel)
    }
    
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        let iPath = IndexPath(row: 1, section: 0)
        self.tableView(tableView, didSelectRowAt: iPath)
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
        //navigationController?.navigationBar.barStyle = DARKMODE() ? .black : .default
        navigationController?.navigationBar.barStyle = .default
    }
    
    @objc func customBackButtonTap(sender: UIBarButtonItem) {
        self.navigationController?.customPopViewController()
    }

}

extension SectionsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return support.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SectionViewCell.cellId, for: indexPath) as! SectionViewCell
        cell.textLabel?.font = UIFont(name: "Poppins-SemiBold", size: 17)
        cell.textLabel?.textColor = DARKMODE() ? articleHeadLineColor : textBlack
        cell.contentView.backgroundColor = DARKMODE() ? .black : .white
        cell.textLabel?.text = support[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        deselect()
        switch indexPath.row {
            case 0:
                let FAQ = FAQPage()
                present(FAQ, animated: true, completion: nil)
            case 1:
                let sliders = SliderDoc()
                present(sliders, animated: true, completion: nil)
            case 2:
                let url = URL(string: feedbackForm)!
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true

                let vc = SFSafariViewController(url: url, configuration: config)
                vc.preferredBarTintColor = DARKMODE() ? .black : .white
                vc.preferredControlTintColor = accentOrange
                present(vc, animated: true, completion: nil)
            case 3:
                let privacy = PrivacyPolicy()
                present(privacy, animated: true, completion: nil)
            case 4:
                let contact = ContactPage()
                present(contact, animated: true, completion: nil)
            case 5:
                self.selectLayout()
            case 6:
                self.changeDisplayMode()
            case 7:
                let sources = SourcesViewController()
                sources.modalPresentationStyle = .fullScreen
                present(sources, animated: true, completion: nil)
            case 8:
                let prefs = MorePrefsViewController()
                prefs.modalPresentationStyle = .fullScreen
                present(prefs, animated: true, completion: nil)
            case 9:
                self.showOnboarding()
            default:
                fatalError()
        }
            
    }
    
    private func showOnboarding() {
        if(Utils.shared.currentLayout == .denseIntense) {
            self.navigationController?.customPopViewController()
            DELAY(0.1) {
                NotificationCenter.default.post(name: NOTIFICATION_SHOW_ONBOARDING, object: nil)
            }
            
            //print("??? ONBOARDING load!")
        } else {
            self.selectLayout(.denseIntense)
            DELAY(0.8) {
                NotificationCenter.default.post(name: NOTIFICATION_SHOW_ONBOARDING, object: nil)
            }
            
            //print("??? ONBOARDING load!")
        }
    }
    
    private func changeDisplayMode() {
        if(Utils.shared.displayMode == .dark) {
            Utils.shared.displayMode = .bright
        } else {
            Utils.shared.displayMode = .dark
        }
        
        let newValue = Utils.shared.displayMode.rawValue
        UserDefaults.standard.set(newValue, forKey: LOCAL_KEY_DISPLAYMODE)
        UserDefaults.standard.synchronize()
        
        
        let topic = self.getMainTopic()
        var news: UIViewController?
        
        Utils.shared.newsViewController_ID = 0
        let vc = self.navigationController?.viewControllers.first!
        if(vc is NewsViewController){ news = NewsViewController(topic: topic) }
        else if(vc is NewsTextViewController){ news = NewsTextViewController(topic: topic) }
        else if(vc is NewsBigViewController){ news = NewsBigViewController(topic: topic) }
        
        self.navigationController?.viewControllers = [news!, self]
        self.navigationController?.customPopViewController()
    }
    private func getMainTopic() -> String {
        var topic = "news"
        
        let vc = self.navigationController?.viewControllers.first!
        if(vc is NewsViewController){ topic = (vc as! NewsViewController).topic }
        else if(vc is NewsTextViewController){ topic = (vc as! NewsTextViewController).topic }
        else if(vc is NewsBigViewController){ topic = (vc as! NewsBigViewController).topic }

        return topic
    }
    
    private func selectLayout() {
        let actionSheet = UIAlertController(title: "",
                                            message: "Select a layout to visualize the news",
                                            preferredStyle: .actionSheet)
        
        for layout in appLayouts {
            let action = UIAlertAction(title: layout.rawValue,
                                            style: .default) { (action) in
                self.selectLayout(layout)
            }
            
            actionSheet.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
        }
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true) {
        }
    }
    
    private func selectLayout(_ layout: layoutType) {
            Utils.shared.currentLayout = layout
            
            UserDefaults.standard.set(layout.rawValue, forKey: LOCAL_KEY_LAYOUT)
            UserDefaults.standard.synchronize()
            
            var changeCurrentVC = false
            var topicToLoad = "news"
            var param_A = 4
            
            if let nav = self.navigationController {
                let currentVC = nav.viewControllers[0]
                
                // get topic value
                if(currentVC is NewsViewController) {
                    let vc = currentVC as! NewsViewController
                    topicToLoad = vc.topic
                    param_A = vc.param_A
                } else if(currentVC is NewsTextViewController) {
                    let vc = currentVC as! NewsTextViewController
                    topicToLoad = vc.topic
                    param_A = vc.param_A
                } else if(currentVC is NewsBigViewController) {
                    let vc = currentVC as! NewsBigViewController
                    topicToLoad = vc.topic
                    param_A = vc.param_A
                }
                
                if(layout == .denseIntense) {
                    if(!(currentVC is NewsViewController)) {
                        changeCurrentVC = true
                    }
                } else if(layout == .textOnly) {
                    if(!(currentVC is NewsTextViewController)) {
                        changeCurrentVC = true
                    }
                } else if(layout == .bigBeautiful) {
                    if(!(currentVC is NewsBigViewController)) {
                        changeCurrentVC = true
                    }
                }
            }
            
            if(changeCurrentVC) {
                Utils.shared.newsViewController_ID = 0
                var vc: UIViewController?
                
                if(layout == .denseIntense) {
                    vc = NewsViewController(topic: topicToLoad)
                    (vc as! NewsViewController).param_A = param_A
                } else if(layout == .textOnly) {
                    vc = NewsTextViewController(topic: topicToLoad)
                    (vc as! NewsTextViewController).param_A = param_A
                } else if(layout == .bigBeautiful) {
                    vc = NewsBigViewController(topic: topicToLoad)
                    (vc as! NewsBigViewController).param_A = param_A
                }
                
                if(vc != nil) {
                    self.navigationController?.viewControllers = [vc!, self]
                }
            }
            self.navigationController?.customPopViewController()
    }
    
    private func showAlert(_ text: String) {
        let alert = UIAlertController(title: "Warning", message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)

        alert.addAction(okAction)
        self.present(alert, animated: true) {
        }
    }
    
    func deselect() {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: false)
        }
    }
}

import SwiftUI
struct SectionsPreview: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<SectionsPreview.ContainerView>) -> UIViewController {
            return UINavigationController(rootViewController: SectionsViewController())
        }
        
        func updateUIViewController(_ uiViewController: SectionsPreview.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<SectionsPreview.ContainerView>) {
            
        }
        
    }
}




extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
