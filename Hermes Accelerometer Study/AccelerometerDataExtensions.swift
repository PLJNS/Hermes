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

extension DateFormatter {
    
    private static let sharedInstance = DateFormatter()
    
    static func string(of date: Date, using dateFormat: DateFormat) -> String? {
        DateFormatter.sharedInstance.dateFormat = dateFormat.rawValue
        return DateFormatter.sharedInstance.string(from: date)
    }
}

extension Formatter {
    
    static let iso8601 = ISO8601DateFormatter()
    
}

enum DateFormat: String {
    case yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
}

extension Date {
    
    func string(format: DateFormat) -> String? {
        return DateFormatter.string(of: self, using: format)
    }
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension CMMotionActivityConfidence {
    
    var displayString: String {
        switch self {
        case .high:
            return "High"
        case .medium:
            return "Medium"
        case .low:
            return "Low"
        }
    }
    
}

extension MotionActivity {
    static var csvTitleRow: [String] = ["logDate", "startDate", "confidence", "stationary", "walking", "running", "automotive", "cycling", "unknown"]
    
    var csvRow: [String] {
        return [logDate?.iso8601 ?? "", startDate?.iso8601 ?? "", "\(confidence)", "\(stationary)", "\(walking)", "\(running)", "\(automotive)", "\(cycling)", "\(unknown)"]
    }
    
    class func insertNewObject(into context: NSManagedObjectContext, with data: CMMotionActivity) {
        let motionActivity = MotionActivity.insertNewObject(into: context)
        motionActivity.confidence = Int16(data.confidence.rawValue)
        motionActivity.startDate = data.startDate
        motionActivity.unknown = data.unknown
        motionActivity.stationary = data.stationary
        motionActivity.walking = data.walking
        motionActivity.running = data.running
        motionActivity.automotive = data.automotive
        motionActivity.cycling = data.cycling
        motionActivity.logDate = Date()
    }
}

extension AccelerometerData {
    
    class func insertNewObject(into context: NSManagedObjectContext,
                               usingLocation location: CLLocation?,
                               andAccelerometerData data: CMAccelerometerData) -> AccelerometerData {
        let newData = AccelerometerData.insertNewObject(into: context)
        newData.x = data.acceleration.x
        newData.y = data.acceleration.y
        newData.z = data.acceleration.z
        newData.course = location?.course ?? 0
        newData.latitude = location?.coordinate.latitude ?? 0
        newData.speed = location?.speed ?? 0
        newData.altitude = location?.altitude ?? 0
        newData.longitude = location?.coordinate.longitude ?? 0
        newData.date = Date()
        return newData
    }
    
    static var csvTitleRow: [String] = ["date", "x", "y", "z", "latitude", "longitude"]
    
    var csvRow: [String] {
        return ["\(Formatter.iso8601.string(from: date ?? Date.distantPast))", "\(x)", "\(y)", "\(z)", "\(latitude)", "\(longitude)"]
    }
    
    override public var debugDescription: String {
        return """
               x=\(String(format: "%+.02f", x))\ty=\(String(format: "%+.02f", y))\tz=\(String(format: "%+.02f", z))
               lat:\(String(format: "%+.04f", latitude))\tlon:\(String(format: "%+.04f", longitude))\n
               """
    }
}

// askdhsnkajsdn

extension NSManagedObject {
    @discardableResult class func insertNewObject(into context: NSManagedObjectContext) -> Self {
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: context)
        return unsafeDowncast(object, to: self)
    }
}

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

extension CMAcceleration: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "x=\(String(format: "%+.02f", x))\ty=\(String(format: "%+.02f", y))\tz=\(String(format: "%+.02f", z))\n"
    }
}

extension CLLocation {
    open var paulsDebugDescription: String {
        return """
               lat:\(String(format: "%+.02f", coordinate.latitude))\tlon:\(String(format: "%+.02f", coordinate.longitude))
               speed:\(String(format: "%+.02f", speed)) mps\tcourse:\(String(format: "%+.02f", course))
               """
    }
}
