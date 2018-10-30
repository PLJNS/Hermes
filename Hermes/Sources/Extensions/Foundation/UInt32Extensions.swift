//
//  UInt32Extensions.swift
//  Hermes
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import Foundation

public extension UInt32 {
    
    public static var random: UInt32 {
        return arc4random_uniform(UInt32.max)
    }
    
}
