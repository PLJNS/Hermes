//
//  NSManagedObjectExtensions.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/18/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import CoreData

extension NSManagedObject {
    @discardableResult class func insertNewObject(into context: NSManagedObjectContext) -> Self {
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: context)
        return unsafeDowncast(object, to: self)
    }
}
