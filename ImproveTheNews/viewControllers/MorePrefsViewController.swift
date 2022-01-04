//
//  MorePrefsViewController.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 14/07/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import UIKit

// -------------------------
struct Preference {
    var text: String
    var key: String
    var status: Bool
    
    init(text: String, key: String) {
        self.text = text
        self.key = key
        
        if let _value = UserDefaults.standard.value(forKey: key) as? Bool {
            self.status = _value
        } else {
            UserDefaults.standard.setValue(true, forKey: key)
            UserDefaults.standard.synchronize()
            self.status = true
        }
    }
}

// -------------------------

class MorePrefsViewController: UIViewController {

    let dismiss = UIButton(title: "Back", titleColor: .label, font: UIFont(name: "OpenSans-Bold", size: 17)!)

    let pagetitle = UILabel(text: "Preferences", font: UIFont(name: "PTSerif-Bold", size: 40), textColor: accentOrange, textAlignment: .left, numberOfLines: 1)

    let list = UITableView()
    var prefsDataSource = [Preference]()


    // MARK: - Initialization
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.loadPrefs()
        
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
        
        // List
        view.addSubview(list)
        list.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: pagetitle.bottomAnchor, constant: 25),
            list.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        let cellNib = UINib(nibName: "PrefCell", bundle: nil)
        list.register(cellNib, forCellReuseIdentifier: "PrefCell")
        list.delegate = self
        list.dataSource = self
        list.separatorStyle = .none
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return STATUS_BAR_STYLE()
    }
    
    private func loadPrefs() {
        
        self.prefsDataSource.append(
            Preference(text: "Show newspaper flags", key: "appCfg_showFlags")
        )
        
        self.prefsDataSource.append(
            Preference(text: "Show newspaper stance insets", key: "appCfg_showStance")
        )
        
        self.prefsDataSource.append(
            Preference(text: "Enable newspaper info popups", key: "appCfg_stancePopup")
        )
        
        self.prefsDataSource.append(
            Preference(text: "Star ratings for articles", key: "appCfg_starRatings")
        )

    }
    
    // MARK: - Some actions
    @objc func handleDismiss() {
        /*
        if(self.shouldUpdate) {
            NotificationCenter.default.post(name: NOTIFICATION_FORCE_RELOAD_NEWS,
                                            object: nil)
        }
        */
        
        self.dismiss(animated: true, completion: nil)
    }

}



extension MorePrefsViewController: UITableViewDelegate, UITableViewDataSource {

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
        
        return self.prefsDataSource.count
    }
    
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "PrefCell") as! PrefCell
        cell.delegate = self
        cell.index = indexPath.row
            
        let P = self.prefsDataSource[indexPath.row]
        cell.nameLabel.text = P.text
        cell.state.setOn(P.status, animated: false)
        
        return cell
    }
    
}



extension MorePrefsViewController: PrefCellDelegate {
    
    func onStateChange(state: Bool, index: Int) {
        self.prefsDataSource[index].status = state
        UserDefaults.standard.set(state, forKey: self.prefsDataSource[index].key)
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: NOTIFICATION_FORCE_RELOAD_NEWS,
                                            object: nil)
    }
    
}


extension MorePrefsViewController {

    public static func showFlags() -> Bool {
        let key = "appCfg_showFlags"
        
        if let _value = UserDefaults.standard.value(forKey: key) as? Bool {
            return _value
        } else {
            UserDefaults.standard.setValue(true, forKey: key)
            UserDefaults.standard.synchronize()
            return true
        }
    }
    
    public static func showStanceInsets() -> Bool {
        let key = "appCfg_showStance"
        
        if let _value = UserDefaults.standard.value(forKey: key) as? Bool {
            return _value
        } else {
            UserDefaults.standard.setValue(true, forKey: key)
            UserDefaults.standard.synchronize()
            return true
        }
    }
    
    public static func showStancePopUp() -> Bool {
        let key = "appCfg_stancePopup"
        
        if let _value = UserDefaults.standard.value(forKey: key) as? Bool {
            return _value
        } else {
            UserDefaults.standard.setValue(true, forKey: key)
            UserDefaults.standard.synchronize()
            return true
        }
    }
    
    public static func showStarRating() -> Bool {
        let key = "appCfg_starRatings"
        
        if let _value = UserDefaults.standard.value(forKey: key) as? Bool {
            return _value
        } else {
            UserDefaults.standard.setValue(true, forKey: key)
            UserDefaults.standard.synchronize()
            return true
        }
    }

}
