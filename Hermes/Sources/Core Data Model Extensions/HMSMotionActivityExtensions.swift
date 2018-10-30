//
//  HMSMotionActivityExtensions.swift
//  Hermes
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import CoreData
import CoreMotion
import CSV

extension Collection where Element == HMSMotionActivity {
    
    func csv(filename: String) throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        if let outputStream = OutputStream(url: url, append: false) {
            let csvWriter = try CSVWriter(stream: outputStream)
            try csvWriter.write(row: HMSMotionActivity.csvHeader)
            try forEach({try csvWriter.write(row: $0.csvRow)})
            csvWriter.stream.close()
        }
        return url
    }
    
}

extension HMSMotionActivity {
    
    static var csvHeader: [String] = ["date", "activity", "confidence"]
    
    var csvRow: [String] {
        return [createdAt?.iso8601 ?? "NA", stateString, "\(confidence)"]
    }
    
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
