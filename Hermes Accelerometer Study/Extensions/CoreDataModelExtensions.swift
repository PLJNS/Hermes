//
//  AccelerometerDataExtensions.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/16/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import Foundation
import CoreData
import CoreMotion
import CoreLocation
import CSV

extension HMSMotionActivity {
    
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
}

extension Double {
    func string(format: String) -> String {
        return String(format: "\(format)", self)
    }
}

extension HMSLocation {
    
    func configure(with data: CLLocation) {
        latitude = data.coordinate.latitude
        longitude = data.coordinate.longitude
        course = data.course
        altitude = data.altitude
        speed = data.speed
        createdAt = Date()
    }
    
    public override var description: String {
        return "Location: (lat: \(latitude.string(format: "%.3f")), lon: \(longitude.string(format: "%.3f")), " +
        "course: \(course.string(format: "%.3f")), speed: \(speed.string(format: "%.3f"))" +
        "altitude: \(altitude.string(format: "%.3f"))"
    }
}

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

