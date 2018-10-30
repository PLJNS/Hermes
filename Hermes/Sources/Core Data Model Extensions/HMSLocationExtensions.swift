//
//  HMSLocationExtensions.swift
//  Hermes
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import CoreData
import CoreLocation
import CSV

extension Collection where Element == HMSLocation {
    
    func csv(filename: String) throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        if let stream = OutputStream(url: url, append: false) {
            let writer = try CSVWriter(stream: stream)
            try writer.write(row: HMSLocation.csvHeader)
            try forEach({ try writer.write(row: $0.csvRow) })
            writer.stream.close()
        }
        return url
    }
    
}

extension HMSLocation {
    
    static let csvHeader: [String] = ["date", "latitude", "longitude", "course", "altitude", "speed"]
    
    var csvRow: [String] {
        return [createdAt?.iso8601 ?? "NA", "\(latitude)", "\(longitude)", "\(course)", "\(altitude)", "\(speed)"]
    }
    
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
