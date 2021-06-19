//
//  SourcesViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 01/06/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

// -------------------------
struct Source {

    var name: String
    var code: String
    var paywall: Bool
    
    var state: Bool = true

    init(_ fields: [String]) {
        self.name = fields[3]
        self.code = String(fields[15].prefix(2))
        self.paywall = (fields[14] == "1")
    }
}

// -------------------------

let KEY_SOURCES_PREFS = "userSourcesPreferences_v2"
// -------------------------
class SourcesViewController: UIViewController {


    let dismiss = UIButton(title: "Back", titleColor: .label, font: UIFont(name: "OpenSans-Bold", size: 17)!)

    let pagetitle = UILabel(text: "Sources", font: UIFont(name: "PTSerif-Bold", size: 40), textColor: accentOrange, textAlignment: .left, numberOfLines: 1)

    let asterikLabel = UILabel(text: "*", font: UIFont(name: "Poppins-SemiBold", size: 16), textColor: .systemPink, textAlignment: .left, numberOfLines: 1)
    let legendLabel = UILabel(text: "indicates paywall", font: UIFont(name: "Poppins-Regular", size: 14), textColor: accentOrange, textAlignment: .left, numberOfLines: 1)

    let list = UITableView()
    var sources = [Source]()
    var preferences = [String]()
    private var shouldUpdate = false

    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(DARKMODE()){
            self.view.backgroundColor = .black
            self.dismiss.setTitleColor(.white, for: .normal)
        } else {
            self.view.backgroundColor = bgWhite_LIGHT
            self.dismiss.setTitleColor(textBlack, for: .normal)
        }
        list.backgroundColor = self.view.backgroundColor
        
        // Title
        view.addSubview(pagetitle)
        pagetitle.translatesAutoresizingMaskIntoConstraints = false
        //pagetitle.backgroundColor = .cyan
        NSLayoutConstraint.activate([
            pagetitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30),
            pagetitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            pagetitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -70)
        ])
        pagetitle.adjustsFontSizeToFitWidth = true
        
        // Dismiss
        dismiss.titleLabel?.textColor = accentOrange
        view.addSubview(dismiss)
        dismiss.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        dismiss.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismiss.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 35),
            dismiss.leadingAnchor.constraint(equalTo: pagetitle.trailingAnchor),
            dismiss.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5)
        ])
        
        // *
        view.addSubview(asterikLabel)
        asterikLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            asterikLabel.topAnchor.constraint(equalTo: pagetitle.bottomAnchor, constant: 5),
            asterikLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15)
        ])
        
        // Legend
        view.addSubview(legendLabel)
        legendLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            legendLabel.topAnchor.constraint(equalTo: pagetitle.bottomAnchor, constant: 3),
            legendLabel.leadingAnchor.constraint(equalTo: asterikLabel.trailingAnchor, constant: 5)
        ])
        legendLabel.textColor = DARKMODE() ? .white : .black
        
        
        // List
        view.addSubview(list)
        list.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: legendLabel.bottomAnchor, constant: 5),
            list.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        let cellNib = UINib(nibName: "SourceCell", bundle: nil)
        list.register(cellNib, forCellReuseIdentifier: "SourceCell")
        list.delegate = self
        list.dataSource = self
        list.separatorStyle = .none
        
        self.initSources()
        self.loadPreferences()
        self.list.reloadData()
    }
    
    private func loadPreferences() {
    
        let delete = false
        if(delete) {
            UserDefaults.standard.removeObject(forKey: KEY_SOURCES_PREFS)
            UserDefaults.standard.synchronize()
        }
    
        self.preferences = []
        if let value = UserDefaults.standard.string(forKey: KEY_SOURCES_PREFS) {
            self.preferences = value.components(separatedBy: ",")
            print("PREFS: " + value)
        }
        
        /*
        else {
            var value = ""
            for S in self.sources {
                if(!value.isEmpty){ value += "," }
                value += S.code
            }
            UserDefaults.standard.set(value, forKey: KEY_SOURCES_PREFS)
            UserDefaults.standard.synchronize()
            
            self.preferences = value.components(separatedBy: ",")
            self.preferences = []
        }
        */
        
        for P in self.preferences {
            let p = String(P.prefix(2))
            let index = self.getSourceIndexFor(code: p)
            self.sources[index].state = false //!P.contains("00")
        }
    }
    
    private func getSourceIndexFor(code: String) -> Int {
        var index = -1
        for (i, S) in self.sources.enumerated() {
            if(S.code==code) {
                index = i
                break
            }
        }
        return index
    }
    
    private func initSources() {
        if let content = readFile("sources.csv") {
            self.parse(content)
        }
    }
    
    // MARK: - Some actions
    @objc func handleDismiss() {
        if(self.shouldUpdate) {
            NotificationCenter.default.post(name: NOTIFICATION_FORCE_RELOAD_NEWS,
                                            object: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
    

}




extension SourcesViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - All related to UITableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 52
    }
    
    func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        
        return self.sources.count
    }
    
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "SourceCell") as! SourceCell
        cell.delegate = self
        cell.index = indexPath.row
            
        let S = self.sources[indexPath.row]
        cell.nameLabel.text = S.name
        cell.highlight(S.paywall)
        cell.state.setOn(S.state, animated: false)
        
        return cell
    }
    
}

extension SourcesViewController: SourceCellDelegate {
    
    func onStateChange(state: Bool, index: Int) {
        self.shouldUpdate = true
        self.sources[index].state = state
        self.updatePreferences()
    }
    
    private func updatePreferences() {
        var value = ""
        for S in self.sources {
            if(S.state==false) {
                if(!value.isEmpty){ value += "," }
                value += S.code + "00"
                //if(!S.state){ value += "00" }
            }
        }
        UserDefaults.standard.set(value, forKey: KEY_SOURCES_PREFS)
        UserDefaults.standard.synchronize()
        self.preferences = value.components(separatedBy: ",")
        
    }
}

extension SourcesViewController {

    // MARK: - All related to data from csv
    private func readFile(_ localFilename: String) -> String? {
        if let filePath = Bundle.main.path(forResource: localFilename, ofType: nil) {
            do {
                let content = try String(contentsOfFile: filePath, encoding: .utf8)
                return content
            } catch {
                print("Reading file error!")
                return nil
            }
        }
        return nil
    }
    
    private func parse(_ content: String) {
        let allRows = content.components(separatedBy: "\n")
        
        for (i, row) in allRows.enumerated() {
            if(i>1) {
                let fields = row.components(separatedBy: ",")
                let newSource = Source(fields)
                self.sources.append(newSource)
            }
        }
        
        self.sources.sort {
            return $0.name.lowercased() < $1.name.lowercased()
        }
    }
    
}
