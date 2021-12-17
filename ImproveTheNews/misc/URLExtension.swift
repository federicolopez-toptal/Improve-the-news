//
//  URLExtension.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 14/12/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import Foundation


extension URL {

  func params() -> [String:Any] {
    var dict = [String:Any]()

    if let components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
      if let queryItems = components.queryItems {
        for item in queryItems {
          dict[item.name] = item.value!
        }
      }
      return dict
    } else {
      return [:]
    }
  }
  
}
