//
//  UIViewControllerExtensions.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/16/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var persistentContainer: NSPersistentContainer {
        return appDelegate.persistentContainer
    }
    
    var viewManagedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func present(error: Error) {
        present(UIAlertController(title: "Error", error: error), animated: true)
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
    
    public func showLoading(style: UIActivityIndicatorView.Style = .gray) -> Int {
        let processId = Int.random
        let activityIndicatorView = UIActivityIndicatorView(style: style)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.tag = processId
        activityIndicatorView.center = view.center
        activityIndicatorView.alpha = 0
        activityIndicatorView.startAnimating()
        
        view.isUserInteractionEnabled = false
        view.addSubview(activityIndicatorView)
        
        UIView.animate(withDuration: 0.25) {
            activityIndicatorView.alpha = 1
        }
        
        return processId
    }
    
    public func hideLoading(procesId: Int) {
        view.isUserInteractionEnabled = true
        if let activityIndicatorView = view.viewWithTag(procesId) {
            UIView.animate(withDuration: 0.25, animations: {
                activityIndicatorView.alpha = 0
            }) { (_) in
                activityIndicatorView.removeFromSuperview()
            }
        }
        
    }
}
