//
//  IntExtensions.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/18/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import Foundation

public extension UInt32 {
    public static var random: UInt32 {
        return arc4random_uniform(UInt32.max)
    }
}

public extension Int {
    public static var random: Int {
        return Int(UInt32.random)
    }
}
