//
//  AppDelegate.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/15/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import CoreMotion

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var sessionManager = SessionManager()
    var session: HMSSession?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let _ = launchOptions?[.location] {
            session = HMSSession.insertNewObject(into: viewManagedObjectContext)
            session?.name = "\(Date().iso8601) Background Mode"
            sessionManager.delegate = self
            sessionManager.startUpdates()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        ()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        ()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        ()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        ()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Hermes_Accelerometer_Study")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var viewManagedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext () {
        if viewManagedObjectContext.hasChanges {
            do {
                try viewManagedObjectContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: SessionManagerDelegate {
    
    func didUpdateActivity(_ activity: CMMotionActivity) {
        let hmsMotionActivity = HMSMotionActivity.insertNewObject(into: viewManagedObjectContext)
        hmsMotionActivity.configure(with: activity)
        session?.addToEntries(hmsMotionActivity)
        saveContext()
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
        
        saveContext()
    }
    
}
