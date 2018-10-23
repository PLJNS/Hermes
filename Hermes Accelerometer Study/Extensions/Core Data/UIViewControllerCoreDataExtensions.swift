//
//  UIViewControllerCoreDataExtensions.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    
    var persistentContainer: NSPersistentContainer {
        return UIApplication.shared.applicationDelegate.persistentContainer
    }
    
    var viewManagedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func save(managedObjectContext: NSManagedObjectContext) {
        do {
            let processId = showLoading()
            try managedObjectContext.save()
            hideLoading(procesId: processId)
        } catch {
            present(UIAlertController(error: error), animated: true)
        }
    }
    
}
