//
//  DateFormatterExtensions.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    private static let sharedInstance = DateFormatter()
    
    static func string(of date: Date, using dateFormat: DateFormatConvertible) -> String? {
        DateFormatter.sharedInstance.dateFormat = dateFormat.dateFormat
        return DateFormatter.sharedInstance.string(from: date)
    }
    
}
