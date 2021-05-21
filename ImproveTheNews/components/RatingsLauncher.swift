//
//  RatingsLauncher.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 7/4/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import SwiftyJSON

protocol RatingsLauncherDelegate {
    func RatingOnError()
    func RatingCompleted()
}



class RatingsLauncher: UIView {
    
    var sliderValues: SliderValues!
    var delegate: RatingsLauncherDelegate?
    
    static var ratings = 1
        
    lazy var cosmos: CosmosView = {
        let stars = CosmosView()
        stars.settings.starMargin = 5
        stars.settings.starSize = 22
        stars.settings.fillMode = .half
        stars.settings.starMargin = 5
        stars.settings.minTouchRating = 0
        stars.rating = 0
        stars.settings.emptyBorderWidth = 1.2
        return stars
    }()
    
     lazy var submit: UIButton = {
        let button = UIButton()
        button.setTitle("Submit", for: .normal)
        button.setTitle("Rated", for: .highlighted)
        button.setTitle("Rated", for: .selected)
        button.setTitleColor(.white, for: .normal)
        //button.setTitleColor(.black, for: .highlighted)
        button.backgroundColor = accentOrange
        button.layer.cornerRadius = 10
    //    button.layer.border
        button.addTarget(self, action: #selector(submitPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    var close: UIButton = {
        let btn = UIButton(type: .custom)
        let img = UIImage(systemName: "xmark.circle")
        btn.setBackgroundImage(img, for: .normal)
        btn.tintColor = accentOrange
        btn.addTarget(self, action: #selector(closePressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    
    
    
    func buildView() {
        
        backgroundColor = .black
        
        // configuring ratings view
        let name = UILabel(text: "Rate\narticle", font: .boldSystemFont(ofSize: 16), textColor: accentOrange, textAlignment: .left, numberOfLines: 2)
        addSubview(name)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            name.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            name.widthAnchor.constraint(equalToConstant: 50),
            name.topAnchor.constraint(equalTo: self.topAnchor, constant: 5)
        ])
        
        addSubview(cosmos)
        cosmos.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cosmos.leadingAnchor.constraint(equalTo: name.trailingAnchor, constant: 15),
            cosmos.widthAnchor.constraint(equalToConstant: 140),
            cosmos.topAnchor.constraint(equalTo: self.topAnchor, constant: 14)
        ])
        //cosmos.backgroundColor = UIColor.red.withAlphaComponent(0.25)
        
        submit.isUserInteractionEnabled = false
        addSubview(submit)
        submit.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submit.leadingAnchor.constraint(equalTo: cosmos.trailingAnchor, constant: 7),
            submit.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -43),
            submit.topAnchor.constraint(equalTo: self.topAnchor, constant: 8)
        ])
        
        addSubview(close)
        close.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            close.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            close.widthAnchor.constraint(equalToConstant: 32),
            close.heightAnchor.constraint(equalToConstant: 32),
            close.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6)
        ])
        
                
        // handle touch events
        cosmos.didTouchCosmos = {
            rating in print("rated \(rating) stars")
        }
        cosmos.didFinishTouchingCosmos = { rating in
            RatingsLauncher.ratings = Int(rating)
            self.submitPressed(self.submit)
        }
    
        sliderValues = SliderValues.sharedInstance

    }
    
}

// touch events
extension RatingsLauncher {
    
    @objc func closePressed(_ sender: UIButton) {
        self.delegate?.RatingCompleted()
    }
    
    @objc func submitPressed(_ sender:UIButton!) {
        
        sender.backgroundColor = .black
        sender.setTitle("Rated", for: .normal)
        
        let elapsedTime = CFAbsoluteTimeGetCurrent() - WebViewController.startTime
        submitRatings(rating: RatingsLauncher.ratings, seconds: elapsedTime)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 0.3) {
                sender.backgroundColor = accentOrange
                sender.setTitle("Submit", for: .normal)
                self.delegate?.RatingCompleted()
            }
        }
        
        print("article rated in \(elapsedTime) seconds")
    }
    
    func submitRatings(rating: Int, seconds: Double) {
        
        let domain = "https://www.improvethenews.org"
        //let domain = "http://ec2-3-134-77-115.us-east-2.compute.amazonaws.com"
        var link = domain + "/srating.php"
        
        // uid
        if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
            link += "?uid=3"
            
            var fixedID = deviceId.uppercased()
            fixedID = fixedID.replacingOccurrences(of: "-", with: "")
            fixedID = fixedID.replacingOccurrences(of: "A", with: "0")
            fixedID = fixedID.replacingOccurrences(of: "B", with: "1")
            fixedID = fixedID.replacingOccurrences(of: "C", with: "2")
            fixedID = fixedID.replacingOccurrences(of: "D", with: "3")
            fixedID = fixedID.replacingOccurrences(of: "E", with: "4")
            fixedID = fixedID.replacingOccurrences(of: "F", with: "5")
            link += fixedID
        }
        
        // url
        var articleURL = self.sliderValues.getCurrentArticle()
        articleURL = articleURL.replacingOccurrences(of: "//", with: "")
        
        link += "&url=" + articleURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        // rating
        link += "&rating=" + String(rating)
        
        // pwd
        link += "&pwd=31415926535"
        
        // call api for ratings
        let url = URL(string: link)!
        //var jsonData: Data?
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if(error != nil || data == nil) {
                self.delegate?.RatingOnError()
                return
            }
            
            do {
                let responseJSON = try JSON(data: data!)
                for (key, value) in responseJSON {
                    if(key == "status" && value.intValue == 200) {
                        print("Rating sent successfully")
                    }
                }
                
            } catch let jsonError {
                self.delegate?.RatingOnError()
            }
        }
        task.resume()
        
        /*
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            do {
                let decodedData = try JSON(data: data)
            }
            
            
                
            /*
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                    print("Server error!")
                    self.newsDelegate!.resendRequest()
                return
            }
            
            do {
                jsonData = data!
                self.parse(jsonData: jsonData!)
            }
            */
        }
        task.resume()
        */
        
        
        
        
        /*
        // prepare post parameters
        let requesturl = "http://ec2-3-21-45-12.us-east-2.compute.amazonaws.com/recordfb_app.php"
        if !UserDefaults.exists(key: "uuid") {
            UserDefaults.createUUID()
        }
        let uuid = UserDefaults.getUUID()
        let page = sliderValues.getTopic() + "A6.B4.S4" + sliderValues.getBiasPrefs().replacingOccurrences(of: "&sliders=", with: "")
        let jsonData = "id=\(uuid)&url=\(self.sliderValues.getCurrentArticle())&rating=\(rating)&seconds=\(seconds)&page=\(page)"

        // create POST request
        let url = URL(string: requesturl)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = jsonData.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if response != nil {
                print("Success!")
            }
        }.resume()
        */
    }
}
