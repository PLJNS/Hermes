//
//  AppDelegate.swift
//  Hermes
//
//  Created by Paul Jones on 10/15/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import CoreMotion
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var sessionManager = SessionManager()
    var bluetoothManager: BluetoothManager?
    var session: HMSSession?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let _ = launchOptions?[.location] {
            sessionManager.startMonitoringSignificantLocationChanges()
            session = HMSSession.insertNewObject(into: viewManagedObjectContext)
            session?.name = "\(Date().iso8601) Background Mode"
            session?.createdAt = Date()
        }
        
        sessionManager.delegate = self
        sessionManager.startMonitoringSignificantLocationChanges()
        
        if let centralManagerIdentifiers = launchOptions?[.bluetoothCentrals] as? [String] {
            if centralManagerIdentifiers.first == BluetoothManager.defaultRestoreIdentifier {
                sessionManager.startMonitoringSignificantLocationChanges()
                session = HMSSession.insertNewObject(into: viewManagedObjectContext)
                session?.name = "\(Date().iso8601) BT Background Mode"
                session?.createdAt = Date()
                
                bluetoothManager = BluetoothManager(delegate: self, restoreIdentifier: BluetoothManager.defaultRestoreIdentifier)
            }
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

extension AppDelegate: BluetoothManagerDelegate {

    func bluetoothManagerDidUpdateConnectedPeripherals(_ bluetoothManager: BluetoothManager) {
        ()
    }
    
    func bluetoothManager(_ bluetoothManager: BluetoothManager, didUpdateRankedPeripherals rankedPeripherals: [CBPeripheral]) {
        ()
    }
    
    func bluetoothManager(_ bluetoothManager: BluetoothManager, didAttemptConnectionTo peripheral: CBPeripheral, error: Error?) {
        ()
    }
    
    
}

extension AppDelegate: SessionManagerDelegate {
    
    func didUpdateActivity(_ activity: CMMotionActivity) {
        if let session = session {
            let hmsMotionActivity = HMSMotionActivity.insertNewObject(into: viewManagedObjectContext)
            hmsMotionActivity.configure(with: activity)
            session.addToEntries(hmsMotionActivity)
            saveContext()
        }
    }
    
    func didUpdateLocation(_ location: CLLocation, withAccelerometerData data: CMAccelerometerData?) {
        if let session = session {
            let hmsLocation = HMSLocation.insertNewObject(into: viewManagedObjectContext)
            hmsLocation.configure(with: location)
            session.addToEntries(hmsLocation)            
            saveContext()
        }
    }
    
}
