//
//  UserDefaultsKeyConvertible.swift
//  Hermes
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import Foundation

/// Your object can be converted into a user defaults key. See UserDefaultsExtensions.
protocol UserDefaultsKeyConvertible {
    
    /// The key.
    var userDefaultsKey: String { get }
    
}
