//
//  DateFormat.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import Foundation

enum DateFormat: String, DateFormatConvertible {
    
    case yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
    
    var dateFormat: String {
        return rawValue
    }
    
}
