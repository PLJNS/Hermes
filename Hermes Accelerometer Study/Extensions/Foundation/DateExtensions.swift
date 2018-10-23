//
//  DateExtensions.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/18/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import Foundation

extension Date {
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    
}


