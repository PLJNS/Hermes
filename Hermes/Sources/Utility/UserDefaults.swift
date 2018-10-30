//
//  UserDefaults.swift
//  Hermes
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import Foundation

enum UserDefaultsKeys: String, UserDefaultsKeyConvertible {
    case updateInterval = "updateInterval"
    
    var userDefaultsKey: String {
        return rawValue
    }
    
}

extension UserDefaults {
    
    var updateInterval: Float {
        get {
            return float(forKey: UserDefaultsKeys.updateInterval)
        } set {
            set(newValue, forKey: UserDefaultsKeys.updateInterval)
        }
    }
    
}
