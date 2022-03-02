//
//  SearchViewController.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 8/24/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class SearchViewController: UIViewController {
    
    let searchBar = UISearchBar()
    
    var sliderValues: SliderValues!
    
    let topicsTable = UITableView()
    var filteredData = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        self.view.backgroundColor = DARKMODE() ? .black : bgWhite_LIGHT
        topicsTable.backgroundColor = self.view.backgroundColor
        
        sliderValues = SliderValues.sharedInstance
        
        filteredData = Globals.searchTopics
        topicsTable.register(UITableViewCell.self,
            forCellReuseIdentifier: "cell")
        setupTableView()
        
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.setNeedsLayout()
        navigationController?.view.layoutIfNeeded()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = topicsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
            cell.textLabel?.textColor = DARKMODE() ? articleHeadLineColor : textBlack
            cell.contentView.backgroundColor = DARKMODE() ? UIColor.black : bgWhite_LIGHT
            cell.textLabel?.text = filteredData[indexPath.row]
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt
            indexPath: IndexPath) {
    
            let topicName = filteredData[indexPath.row]
            guard let topicCode = Globals.topicmapping[topicName] else {
                return
            }
            
            if(Utils.shared.currentLayout == .denseIntense) {
                //"Dense & Intense"
                let vc = NewsViewController(topic: topicCode)
                vc.firstTime = false
                vc.topicCodeFromSearch = topicCode
                self.insertNewVCInNavigationStack(vc)
            } else if(Utils.shared.currentLayout == .textOnly) {
                //"Text only"
                let vc = NewsTextViewController(topic: topicCode)
                vc.firstTime = false
                vc.topicCodeFromSearch = topicCode
                self.insertNewVCInNavigationStack(vc)
            } else if(Utils.shared.currentLayout == .bigBeautiful) {
                //"Big & Beautiful"
                let vc = NewsBigViewController(topic: topicCode)
                vc.firstTime = false
                vc.topicCodeFromSearch = topicCode
                self.insertNewVCInNavigationStack(vc)
            }
            
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: NOTIFICATION_CLOSE_ONBOARDING_FROM_OUTSIDE,
                object: nil)
        }
        
        func insertNewVCInNavigationStack(_ vc: UIViewController) {
            if let nav = self.navigationController {
                var VCs = [UIViewController]()
                for vc in nav.viewControllers {
                    if(vc != self) {
                        VCs.append(vc)
                    }
                }
                VCs.append(vc)
                VCs.append(self)
                
                nav.viewControllers = VCs
            }
        }
        
        
        func setupTableView() {
            view.addSubview(topicsTable)
            topicsTable.delegate = self
            topicsTable.dataSource = self
            topicsTable.translatesAutoresizingMaskIntoConstraints = false
            topicsTable.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
            topicsTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            topicsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            topicsTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            topicsTable.tableFooterView = UIView()
        }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    fileprivate func setupNavBar() {
        searchBar.sizeToFit()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.textColor = .black
        searchBar.tintColor = .white
        searchBar.searchTextField.font = UIFont(name: "OpenSans-Bold", size: 17)
        searchBar.delegate = self
        
        UITextField.appearance(whenContainedInInstancesOf: [type(of: searchBar)]).tintColor = .black

        navigationItem.title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let _textColor = DARKMODE() ? UIColor.white : UIColor.black
        let buttonAttributes = [NSAttributedString.Key.foregroundColor: _textColor]
        UIBarButtonItem.appearance().setTitleTextAttributes(buttonAttributes , for: .normal)
        
        
        
        //navigationController?.navigationBar.tintColor = DARKMODE() ? .white : .black
        
        searchBar.showsCancelButton = false
        navigationItem.titleView = true ? searchBar : nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return STATUS_BAR_STYLE()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //self.view.endEditing(true)
        searchBar.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = []

        if searchText == "" {
            filteredData = Globals.topics
        } else {
            for topic in Globals.topics {
                if topic.lowercased().contains(searchText.lowercased()) {
                    filteredData.append(topic)
                }
            }
        }
        self.topicsTable.reloadData()
    }
}


import SwiftUI
struct SearchPreview: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<SearchPreview.ContainerView>) -> UIViewController {
            return UINavigationController(rootViewController: SearchViewController())
        }
        
        func updateUIViewController(_ uiViewController: SearchPreview.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<SearchPreview.ContainerView>) {
            
        }
        
    }
}

extension SearchViewController {
    
    
    
    
    private func userTapsOnTopic(_ topicName: String) {
    
        guard let topicCode = Globals.topicmapping[topicName],
            let nav = self.navigationController else {
            
            return
        }
        
        var link = ""
        sliderValues.setTopic(topic: topicCode)
        for vc in nav.viewControllers {
            if(vc is NewsViewController) {
                link = (vc as! NewsViewController).buildApiCall(topicForCall: topicCode,
                                                                zeroItems: true)
                break
            }
        }
        
        let url = URL(string: link)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if(error != nil || data == nil) {
                return
            }
            
            do {
                let responseJSON = try JSON(data: data!)
                let topicNode = responseJSON[1][0]
                
                let count = topicNode[3].intValue
                print("GATO6", count)
                
                DispatchQueue.main.async {
                
                    for vc in nav.viewControllers {
                        if(vc is NewsViewController) {
                            let targetVC = vc as! NewsViewController
                        
                            targetVC.firstTime = true
                            targetVC.param_A = 4
                            if(count==0){ targetVC.param_A = 40 }
                            targetVC.topic = topicCode
                            
                            nav.popToRootViewController(animated: true)
                        }
                    }
                }
                
                
            } catch _ {
            return
        }
        }
        task.resume()
    }
    
    
    
    
}
