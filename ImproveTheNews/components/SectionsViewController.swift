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

class SectionsViewController: UIViewController {
    
    let support = ["FAQ", "How the sliders work", "Feedback", "Privacy Policy", "Contact"]
    let feedbackForm = "https://docs.google.com/forms/d/e/1FAIpQLSfoGi4VkL99kV4nESvK71k4NgzcVuIo4o-JDrlmBqArLR_IYA/viewform"
        
    let tableView = UITableView()
    var safeArea: UILayoutGuide!
    
    override func loadView() {
        super.loadView()
        
        navigationItem.largeTitleDisplayMode = .never
        safeArea = view.layoutMarginsGuide
        
        navigationItem.title = "Support"
        
        setupTableView()
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        tableView.register(SectionViewCell.self, forCellReuseIdentifier: SectionViewCell.cellId)
    }
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        let iPath = IndexPath(row: 1, section: 0)
        self.tableView(tableView, didSelectRowAt: iPath)
    }
    */

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
        cell.textLabel?.textColor = articleHeadLineColor
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
                vc.preferredBarTintColor = .black
                vc.preferredControlTintColor = accentOrange
                present(vc, animated: true, completion: nil)
            case 3:
                let privacy = PrivacyPolicy()
                present(privacy, animated: true, completion: nil)
            case 4:
                let contact = ContactPage()
                present(contact, animated: true, completion: nil)
            default:
                fatalError()
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
