//
//  SessionViewController.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/18/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import CoreData
import CSV

class SessionViewController: UIViewController {
    
    var session: HMSSession?
    
    @IBOutlet private var pauseBarButtonItem: UIBarButtonItem!
    @IBOutlet private var trashBarButtonItem: UIBarButtonItem!
    @IBOutlet private var playBarButtonItem: UIBarButtonItem!
    @IBOutlet private var shareBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var tableView: UITableView!
    
    private var sessionManager = SessionManager()
    private lazy var backgroundContext: NSManagedObjectContext = newBackgroundContext()
    private lazy var fetchedResultsController: NSFetchedResultsController<HMSEntry> = {
        let fetchRequest: NSFetchRequest<HMSEntry> = HMSEntry.fetchRequest()
        if let sessionName = session?.name {
            fetchRequest.predicate = NSPredicate(format: "session.name == %@", sessionName)
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \HMSEntry.createdAt, ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: viewManagedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionManager.delegate = self
        title = session?.name
        navigationItem.setRightBarButtonItems([playBarButtonItem, trashBarButtonItem, shareBarButtonItem], animated: false)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            present(error: error)
        }
    }
    
    @IBAction func didSelectBarButtonItem(_ sender: UIBarButtonItem) {
        switch sender {
        case pauseBarButtonItem:
            navigationItem.setRightBarButtonItems([playBarButtonItem, trashBarButtonItem, shareBarButtonItem], animated: true)
            navigationItem.hidesBackButton = false
            trashBarButtonItem.isEnabled = true
            sessionManager.stopUpdates()
            save(managedObjectContext: viewManagedObjectContext)
        case trashBarButtonItem:
            if let session = session {
                viewManagedObjectContext.delete(session)
                do {
                    try viewManagedObjectContext.save()
                    navigationController?.navigationController?.popToRootViewController(animated: true)
                } catch {
                    present(error: error)
                }
            }
        case shareBarButtonItem:
            guard let sessionName = session?.name else { return }
            let locationFetchRequest: NSFetchRequest<HMSLocation> = HMSLocation.fetchRequest()
            locationFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \HMSLocation.createdAt, ascending: false)]
            locationFetchRequest.predicate = NSPredicate(format: "session.name == %@", sessionName)
            
            let motionActivityFetchRequest: NSFetchRequest<HMSMotionActivity> = HMSMotionActivity.fetchRequest()
            motionActivityFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \HMSMotionActivity.createdAt, ascending: false)]
            motionActivityFetchRequest.predicate = NSPredicate(format: "session.name == %@", sessionName)
            
            var locationResultsUrl, motionActivityResultsUrl: URL?
            
            let processId = showLoading()
            backgroundContext.perform { [weak self] in
                guard let strongSelf = self else { return }
                
                let dispatchGroup = DispatchGroup()
                if let locationResults = try? strongSelf.backgroundContext.fetch(locationFetchRequest) {
                    dispatchGroup.enter()
                    DispatchQueue.global().async {
                        defer { dispatchGroup.leave() }
                        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(sessionName)_Location+Accelerometer.csv")
                        locationResultsUrl = url
                        if let stream = OutputStream(url: url, append: false) {
                            var locationCSVWriter: CSVWriter?
                            do {
                                let locationWriter = try CSVWriter(stream: stream)
                                try locationWriter.write(row: ["date", "latitude", "longitude", "course", "altitude", "speed", "x", "y", "z"])
                                for location in locationResults {
                                    try locationWriter.write(row: [
                                        location.createdAt?.iso8601 ?? "NA",
                                        "\(location.latitude)",
                                        "\(location.longitude)",
                                        "\(location.course)",
                                        "\(location.altitude)",
                                        "\(location.speed)",
                                        "\(location.accelerometerData?.x ?? 0)",
                                        "\(location.accelerometerData?.y ?? 0)",
                                        "\(location.accelerometerData?.z ?? 0)"
                                        ])
                                }
                                locationCSVWriter = locationWriter
                            } catch {
                                DispatchQueue.main.async { [weak self] in
                                    guard let strongSelf = self else { return }
                                    strongSelf.present(UIAlertController(error: error), animated: true)
                                }
                            }
                            
                            locationCSVWriter?.stream.close()
                        }
                    }
                }
                
                if let motionActivityResults = try? strongSelf.backgroundContext.fetch(motionActivityFetchRequest) {
                    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(sessionName)_Motion_Activity.csv")
                    dispatchGroup.enter()
                    DispatchQueue.global().async {
                        defer { dispatchGroup.leave() }
                        motionActivityResultsUrl = url
                        if let motionActivityStream = OutputStream(url: url, append: false) {
                            var motionActivityCSVWriter: CSVWriter?
                            do {
                                let motionActivityWriter = try CSVWriter(stream: motionActivityStream)
                                try motionActivityWriter.write(row: ["date", "activity", "confidence"])
                                for motionActivity in motionActivityResults {
                                    try motionActivityWriter.write(row: [
                                        motionActivity.createdAt?.iso8601 ?? "NA",
                                        motionActivity.stateString,
                                        "\(motionActivity.confidence)"])
                                }
                                motionActivityCSVWriter = motionActivityWriter
                            } catch {
                                DispatchQueue.main.async { [weak self] in
                                    guard let strongSelf = self else { return }
                                    strongSelf.present(UIAlertController(error: error), animated: true)
                                }
                            }
                            
                            motionActivityCSVWriter?.stream.close()
                        }
                    }
                }
                
                dispatchGroup.wait()
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.hideLoading(procesId: processId)
                    if let motionActivityResultsUrl = motionActivityResultsUrl, let locationResultsUrl = locationResultsUrl {
                        let activityVC = UIActivityViewController(activityItems: [motionActivityResultsUrl, locationResultsUrl], applicationActivities: nil)
                        strongSelf.present(activityVC, animated: true)
                    }
                }
            }
        case playBarButtonItem:
            navigationItem.setRightBarButtonItems([pauseBarButtonItem, trashBarButtonItem, shareBarButtonItem], animated: true)
            navigationItem.hidesBackButton = true
            trashBarButtonItem.isEnabled = false
            sessionManager.startUpdatingLocation()
        default:
            ()
        }
    }
    
}

extension SessionViewController: SessionManagerDelegate {
    
    func didUpdateActivity(_ activity: CMMotionActivity) {
        let hmsMotionActivity = HMSMotionActivity.insertNewObject(into: viewManagedObjectContext)
        hmsMotionActivity.configure(with: activity)
        session?.addToEntries(hmsMotionActivity)
    }
    
    func didUpdateLocation(_ location: CLLocation, withAccelerometerData data: CMAccelerometerData?) {
        let hmsLocation = HMSLocation.insertNewObject(into: viewManagedObjectContext)
        hmsLocation.configure(with: location)
        session?.addToEntries(hmsLocation)

        if let accelerometerData = data {
            let hmsAcceleromter = HMSAccelerometerData.insertNewObject(into: viewManagedObjectContext)
            hmsAcceleromter.configure(with: accelerometerData)
            hmsLocation.accelerometerData = hmsAcceleromter
            session?.addToEntries(hmsAcceleromter)
        }
    }
    
}

extension SessionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryTableViewCell")!
        let entry = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = entry.description
        cell.detailTextLabel?.text = entry.createdAt?.iso8601
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return 0 }
        return fetchedObjects.count
    }
    
}


extension SessionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            break;
        default:
            ()
        }
    }
    
}
