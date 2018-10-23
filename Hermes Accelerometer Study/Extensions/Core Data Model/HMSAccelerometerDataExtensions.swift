//
//  HMSAccelerometerDataExtensions.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import CoreData
import CoreMotion

extension HMSAccelerometerData {
    
    func configure(with data: CMAccelerometerData) {
        x = data.acceleration.x
        y = data.acceleration.y
        z = data.acceleration.z
        createdAt = Date()
    }
    
    public override var description: String {
        return "Accelerometer: \(x.string(format: "%.3f")), \(y.string(format: "%.3f")), \(z.string(format: "%.3f"))"
    }
    
}
