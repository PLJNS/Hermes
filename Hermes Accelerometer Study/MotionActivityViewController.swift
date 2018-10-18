//
//  MotionActivityViewController.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/17/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import UIKit
import CoreMotion
import CoreData
import CSV

class MotionActivityViewController: UIViewController {
    
    let motionActivityManager = CMMotionActivityManager()
    lazy var backgroundContext: NSManagedObjectContext = newBackgroundContext()
    
    @IBOutlet weak var stationarySwitch: UISwitch!
    @IBOutlet weak var walkingSwitch: UISwitch!
    @IBOutlet weak var runningSwitch: UISwitch!
    @IBOutlet weak var automotiveSwitch: UISwitch!
    @IBOutlet weak var cyclingSwitch: UISwitch!
    @IBOutlet weak var unknownSwitch: UISwitch!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func buttonTouchUpInside(_ sender: UIButton) {
        switch sender {
        case startButton:
            motionActivityManager.startActivityUpdates(to: .main) { [weak self] (activity) in
                guard let strongSelf = self else { return }
                if let activity = activity {
                    strongSelf.walkingSwitch.isOn = activity.walking
                    strongSelf.runningSwitch.isOn = activity.running
                    strongSelf.automotiveSwitch.isOn = activity.automotive
                    strongSelf.cyclingSwitch.isOn = activity.cycling
                    strongSelf.unknownSwitch.isOn = activity.unknown
                    strongSelf.startDateLabel.text = activity.startDate.string(format: DateFormat.yyyyMMddHHmmss)
                    strongSelf.confidenceLabel.text = activity.confidence.displayString
                    MotionActivity.insertNewObject(into: strongSelf.viewManagedObjectContext, with: activity)
                }
            }
        case stopButton:
            motionActivityManager.stopActivityUpdates()
        case exportButton:
            let fetchRequest: NSFetchRequest<MotionActivity> = MotionActivity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MotionActivity.logDate, ascending: false)]
            let processId = showLoading()
            backgroundContext.perform { [weak self] in
                guard let strongSelf = self else { return }
                if let results = try? strongSelf.backgroundContext.fetch(fetchRequest) {
                    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("MotionActivityData.csv")
                    if let stream = OutputStream(url: url, append: false) {
                        var csvWriter: CSVWriter?
                        do {
                            let writer = try CSVWriter(stream: stream)
                            try writer.write(row: MotionActivity.csvTitleRow)
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
        case clearButton:
            let processId = showLoading()
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MotionActivity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            backgroundContext.perform { [weak self] in
                guard let strongSelf = self else { return }
                do {
                    try strongSelf.backgroundContext.execute(deleteRequest)
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
        case saveButton:
            save(viewManagedObjectContext)
        default:
            ()
        }
    }
    
}
