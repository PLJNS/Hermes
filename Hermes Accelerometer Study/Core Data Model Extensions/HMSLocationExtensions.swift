//
//  HMSLocationExtensions.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import CoreData
import CoreLocation

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
