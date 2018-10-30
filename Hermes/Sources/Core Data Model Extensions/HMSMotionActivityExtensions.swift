//
//  HMSMotionActivityExtensions.swift
//  Hermes
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import CoreData
import CoreMotion

extension HMSMotionActivity {
    
    func configure(with data: CMMotionActivity) {
        confidence = Int16(data.confidence.rawValue)
        startDate = data.startDate
        unknown = data.unknown
        stationary = data.stationary
        walking = data.walking
        running = data.running
        automotive = data.automotive
        cycling = data.cycling
        createdAt = Date()
    }
    
    public override var description: String {
        return "\(stateString.capitalizingFirstLetter()) with \(CMMotionActivityConfidence(rawValue: Int(confidence))?.displayString ?? "unknown") confidence"
    }
    
    var stateString: String {
        switch (unknown, stationary, walking, running, automotive, cycling) {
        case (_, true, _, _, _, _):
            return "stationary"
        case (_, _, true, _, _, _):
            return "walking"
        case (_, _, _, true, _, _):
            return "running"
        case (_, _, _, _, true, _):
            return "automotive"
        case (_, _, _, _, _, true):
            return "cycling"
        case (_, _, _, _, _, _):
            return "unknown"
        }
    }
    
}
