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

class RatingsLauncher: UIView {
    
    var sliderValues: SliderValues!
    static var ratings = 1
        
    // VERY IMPORTANT
    let requesturl = "http://ec2-3-21-45-12.us-east-2.compute.amazonaws.com/recordfb_app.php"
    
    lazy var cosmos: CosmosView = {
        let stars = CosmosView()
        stars.settings.starMargin = 5
        stars.settings.starSize = 20
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
    
    func buildView() {
        
        backgroundColor = .black
        
        // configuring ratings view
        let name = UILabel(text: "Rate article", font: .boldSystemFont(ofSize: 16), textColor: accentOrange, textAlignment: .left, numberOfLines: 1)
        addSubview(name)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            name.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            name.widthAnchor.constraint(equalToConstant: 90),
            name.topAnchor.constraint(equalTo: self.topAnchor, constant: 14)
        ])
        
        addSubview(cosmos)
        
        cosmos.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cosmos.leadingAnchor.constraint(equalTo: name.trailingAnchor, constant: 5),
            cosmos.widthAnchor.constraint(equalToConstant: 130),
            cosmos.topAnchor.constraint(equalTo: self.topAnchor, constant: 14)
        ])
        
        submit.isUserInteractionEnabled = true
        addSubview(submit)
        submit.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submit.leadingAnchor.constraint(equalTo: cosmos.trailingAnchor, constant: 10),
            submit.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            submit.topAnchor.constraint(equalTo: self.topAnchor, constant: 8)
        ])
                
        // handle touch events
        cosmos.didTouchCosmos = {
            rating in print("rated \(rating) stars")
        }
        cosmos.didFinishTouchingCosmos = { rating in
            RatingsLauncher.ratings = Int(rating)
        }
    
        sliderValues = SliderValues.sharedInstance

    }
    
}

// touch events
extension RatingsLauncher {
    
    @objc func submitPressed(_ sender:UIButton!) {
        
        sender.backgroundColor = .black
        sender.setTitle("Rated", for: .normal)
        
        let elapsedTime = CFAbsoluteTimeGetCurrent() - WebViewController.startTime
        submitRatings(rating: RatingsLauncher.ratings, seconds: elapsedTime)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 0.3) {
                sender.backgroundColor = accentOrange
                sender.setTitle("Submit", for: .normal)
            }
        }
        
        print("article rated in \(elapsedTime) seconds")
    }
    
    func submitRatings(rating: Int, seconds: Double) {
        
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
    }
}
