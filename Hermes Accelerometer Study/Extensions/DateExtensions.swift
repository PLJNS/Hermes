//
//  DateExtensions.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/18/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    private static let sharedInstance = DateFormatter()
    
    static func string(of date: Date, using dateFormat: DateFormat) -> String? {
        DateFormatter.sharedInstance.dateFormat = dateFormat.rawValue
        return DateFormatter.sharedInstance.string(from: date)
    }
}

extension Formatter {
    
    static let iso8601 = ISO8601DateFormatter()
    
}

enum DateFormat: String {
    case yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
}

extension Date {
    
    func string(format: DateFormat) -> String? {
        return DateFormatter.string(of: self, using: format)
    }
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}
