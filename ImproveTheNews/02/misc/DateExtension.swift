//
//  DateExtension.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 02/03/2021.
//  Copyright © 2021 Mindy Long. All rights reserved.
//

import Foundation

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}
