//
//  SessionManager.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

protocol SessionManagerDelegate: class {
    
    func didUpdateActivity(_ activity: CMMotionActivity)
    
    func didUpdateLocation(_ location: CLLocation, withAccelerometerData data: CMAccelerometerData?)
    
}

class SessionManager: NSObject {
    
    weak var delegate: SessionManagerDelegate?
    var isRecording: Bool = false
    
    private let motionManager = CMMotionManager()
    private let motionActivityManager = CMMotionActivityManager()
    private let locationManager = CLLocationManager()
    private var accelerometerUpdateInterval: Double = 1/60
    
    func stopUpdates() {
        isRecording = false
        motionManager.stopAccelerometerUpdates()
        locationManager.stopUpdatingLocation()
        motionActivityManager.stopActivityUpdates()
    }
    
    func startUpdates() {
        isRecording = true
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval
            motionManager.startAccelerometerUpdates()
        }
        
        motionActivityManager.startActivityUpdates(to: .main) { [weak self] (activity) in
            guard let strongSelf = self else { return }
            if let activity = activity {
                strongSelf.delegate?.didUpdateActivity(activity)
            }
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}

extension SessionManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.didUpdateLocation(locations[0], withAccelerometerData: motionManager.accelerometerData)
    }
    
}
