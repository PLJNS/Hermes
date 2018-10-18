//
//  ViewController.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/15/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import UIKit
import CoreMotion
import CoreData
import CoreLocation
import CSV

class ViewController: UIViewController {

    let motion = CMMotionManager()
    let activity = CMMotionActivityManager()
    var timer: Timer?
    lazy var backgroundContext: NSManagedObjectContext = newBackgroundContext()
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var updateIntervalLabel: UILabel!
    @IBOutlet weak var updateIntervalSlider: UISlider!
    
    var updateInterval: Double {
        return 1.0 / Double(updateIntervalSlider.value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateIntervalSlider.value = UserDefaults.standard.updateInterval
        updateIntervalLabel.text = "Update interval \(Int(UserDefaults.standard.updateInterval))"
        motion.accelerometerUpdateInterval = updateInterval
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        
        let processId = showLoading()
        let fetchRequest: NSFetchRequest<AccelerometerData> = AccelerometerData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \AccelerometerData.date, ascending: false)]
        fetchRequest.fetchLimit = 1000
        backgroundContext.perform { [weak self] in
            guard let strongSelf = self else { return }
            if let results = try? strongSelf.backgroundContext.fetch(fetchRequest) {
                for result in results.reversed() {
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.textView.text = result.debugDescription.appending(strongSelf.textView.text.prefix(10000))
                    }
                }
            }
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.hideLoading(procesId: processId)
            }
        }
    }
    
    func startAccelerometers() {
        if motion.isAccelerometerAvailable {
            motion.accelerometerUpdateInterval = updateInterval
            motion.startAccelerometerUpdates()
            configureTimer()
        }
        
    }
    
    func configureTimer() {
        timer?.invalidate()
        timer = nil
        
        timer = Timer(fire: Date(), interval: updateInterval,
                      repeats: true, block: { [weak self] (timer) in
                        guard let strongSelf = self else { return }
                        if let data = strongSelf.motion.accelerometerData {
                            let text = strongSelf.textView.text.prefix(10000)
                            let insert = AccelerometerData.insertNewObject(into: strongSelf.viewManagedObjectContext, usingLocation: nil, andAccelerometerData: data)
                            strongSelf.textView.text = insert.debugDescription.appending(text)
                        }
        })
        
        RunLoop.current.add(timer!, forMode: .default)
    }
    
    func stopAccelerometers() {
        motion.stopAccelerometerUpdates()
        timer?.invalidate()
        timer = nil
    }
    
    func export() {
        let fetchRequest: NSFetchRequest<AccelerometerData> = AccelerometerData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \AccelerometerData.date, ascending: false)]
        let processId = showLoading()
        backgroundContext.perform { [weak self] in
            guard let strongSelf = self else { return }
            if let results = try? strongSelf.backgroundContext.fetch(fetchRequest) {
                let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("AccelerometerData.csv")
                if let stream = OutputStream(url: url, append: false) {
                    var csvWriter: CSVWriter?
                    do {
                        let writer = try CSVWriter(stream: stream)
                        try writer.write(row: AccelerometerData.csvTitleRow)
                        for result in results {
                            try writer.write(row: result.csvRow)
                        }
                        csvWriter = writer
                    } catch {
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.present(UIAlertController(error: error), animated: true)
                        }
                    }
                    
                    csvWriter?.stream.close()
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.hideLoading(procesId: processId)
                        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                        strongSelf.present(activityVC, animated: true)
                    }
                }
            }
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.hideLoading(procesId: processId)
            }
        }
    }
    
    func clearData() {
        let processId = showLoading()
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AccelerometerData.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        backgroundContext.perform { [weak self] in
            guard let strongSelf = self else { return }
            do {
                try strongSelf.backgroundContext.execute(deleteRequest)
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.textView.text = ""
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.present(UIAlertController(error: error), animated: true)
                }
            }
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.hideLoading(procesId: processId)
            }
        }
    }
    
    @IBAction func buttonTouchUpInside(_ sender: UIButton) {
        switch sender {
        case startButton:
            startAccelerometers()
        case stopButton:
            stopAccelerometers()
        case saveButton:
            save(viewManagedObjectContext)
        case clearButton:
            clearData()
        case exportButton:
            export()
        default:
            ()
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        switch sender {
        case updateIntervalSlider:
            UserDefaults.standard.updateInterval = sender.value
            updateIntervalLabel.text = "Update interval \(Int(sender.value))"
            motion.accelerometerUpdateInterval = updateInterval
            configureTimer()
        default:
            ()
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
}
