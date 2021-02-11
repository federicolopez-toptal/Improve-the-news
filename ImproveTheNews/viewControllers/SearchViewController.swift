//
//  SearchViewController.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 8/24/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController {
    
    let searchBar = UISearchBar()
    
    var sliderValues: SliderValues!
    
    let topicsTable = UITableView()
    var filteredData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        
        sliderValues = SliderValues.sharedInstance
        
        filteredData = Globals.searchTopics
        topicsTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        setupTableView()
        
        setupNavBar()
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = topicsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
            cell.textLabel?.textColor = articleHeadLineColor
            cell.textLabel?.text = filteredData[indexPath.row]
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let topicname = filteredData[indexPath.row]
            let topiccode = Globals.topicmapping[topicname]
            sliderValues.setTopic(topic: topiccode!)
            
            let newsVC = navigationController!.viewControllers[0] as! NewsViewController
            newsVC.firstTime = true
            newsVC.topic = topiccode!
            //newsVC.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            navigationController!.popToRootViewController(animated: true)
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
        
        searchBar.showsCancelButton = true
        navigationItem.titleView = true ? searchBar : nil
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
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
