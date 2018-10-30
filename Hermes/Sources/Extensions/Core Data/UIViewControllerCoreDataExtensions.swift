//
//  UIViewControllerCoreDataExtensions.swift
//  Hermes
//
//  Created by Paul Jones on 10/23/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    
    var applicationDelegate: AppDelegate {
        return UIApplication.shared.applicationDelegate
    }
    
    var persistentContainer: NSPersistentContainer {
        return applicationDelegate.persistentContainer
    }
    
    var viewManagedObjectContext: NSManagedObjectContext {
        return applicationDelegate.viewManagedObjectContext
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
            present(error: error)
        }
    }
    
}
