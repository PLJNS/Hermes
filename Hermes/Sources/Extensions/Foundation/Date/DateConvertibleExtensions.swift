//
//  DateConvertibleExtensions.swift
//  Hermes
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import Foundation

extension Date {
    
    func string(format: DateFormatConvertible) -> String? {
        return DateFormatter.string(of: self, using: format)
    }
    
}
