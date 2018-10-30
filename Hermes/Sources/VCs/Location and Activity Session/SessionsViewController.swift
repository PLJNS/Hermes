//
//  SessionsViewController.swift
//  Hermes
//
//  Created by Paul Jones on 10/18/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import UIKit
import CoreData

class SessionsViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    lazy var fetchedResultsController: NSFetchedResultsController<HMSSession> = {
        let fetchRequest: NSFetchRequest<HMSSession> = HMSSession.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \HMSSession.createdAt, ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: viewManagedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            present(error: error)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "SessionsViewController_to_SessionViewController":
            guard let navigationController = segue.destination as? UINavigationController,
            let destination = navigationController.viewControllers.first as? SessionViewController else {
                fatalError()
            }
            
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
                fatalError()
            }
            
            destination.session = fetchedResultsController.object(at: selectedIndexPath)
        default:
            ()
        }
    }
    
    @IBAction func unwindToSessionsViewController(segue:UIStoryboardSegue) {
        switch segue.identifier ?? "" {
        case "AddSessionViewController_to_SessionsViewController":
            if let source = segue.source as? AddSessionViewController, let sessionName = source.text?.nilIfEmpty {
                let session = HMSSession.insertNewObject(into: viewManagedObjectContext)
                session.name = sessionName
                session.createdAt = Date()
                save(managedObjectContext: viewManagedObjectContext)
            }
        default:
            ()
        }
    }
}

extension SessionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionTableViewCell")!
        let session = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = session.name
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sessions = fetchedResultsController.fetchedObjects else { return 0 }
        return sessions.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let quote = fetchedResultsController.object(at: indexPath)
            quote.managedObjectContext?.delete(quote)
            save(managedObjectContext: viewManagedObjectContext)
        }
    }
    
}

extension SessionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SessionsViewController_to_SessionViewController", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension SessionsViewController: NSFetchedResultsControllerDelegate {
    
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
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        default:
            ()
        }
    }
    
}
