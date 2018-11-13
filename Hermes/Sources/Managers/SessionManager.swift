//
//  SessionManager.swift
//  Hermes
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
    
    func didEnterOrExit(_ region: CLRegion)
}

class SessionManager: NSObject {
    
    weak var delegate: SessionManagerDelegate?
    
    private let motionManager = CMMotionManager()
    private let motionActivityManager = CMMotionActivityManager()
    private let locationManager = CLLocationManager()
    private var accelerometerUpdateInterval: Double = 1/60
    private var stationaryTimer = Timer()
    private var secondCounter = 0
    
    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
        locationManager.stopUpdatingLocation()
        motionActivityManager.stopActivityUpdates()
    }
    
    func startUpdatingLocation() {
        startMotionActivityManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        startMotionActivityManager()
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
}

private extension SessionManager {
    func startAccelerometerUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval
            motionManager.startAccelerometerUpdates()
        }
    }
    
    func startMotionActivityManager() {
        motionActivityManager.startActivityUpdates(to: .main) { [weak self] (activity) in
            guard let strongSelf = self else { return }
            if let activity = activity {
                strongSelf.delegate?.didUpdateActivity(activity)
                if activity.automotive || activity.running || activity.cycling {
                    //cancel timer
                    //strongSelf.secondCounter = 0
                    //strongSelf.stationaryTimer.invalidate()
                    print("MOVING")
                } else {
                    //start timer
                    //strongSelf.stationaryTimer = Timer.scheduledTimer(timeInterval: 1, target: strongSelf, selector: (#selector(strongSelf.updateTimer)), userInfo: nil, repeats: true)
                    print("NOT MOVING")
                }
            }
        }
    }
    
    @objc func updateTimer() {
        secondCounter += 1
        if secondCounter >= 300 {
            secondCounter = 0
            stationaryTimer.invalidate()
            stopUpdates()
        }
    }
    
}

extension SessionManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.didUpdateLocation(locations[0], withAccelerometerData: motionManager.accelerometerData)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            delegate?.didEnterOrExit(region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            delegate?.didEnterOrExit(region)
        }
    }
    
}
