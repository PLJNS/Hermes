//
//  AddLocationViewController.swift
//  Hermes
//
//  Created by Olivia Taylor on 11/8/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import MapKit
import UIKit

protocol AddLocationViewControllerDelegate {
    func addLocationViewController(controller: AddLocationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D,
                                        radius: Double, identifier: String, note: String, eventType: EventType)
}

class AddLocationViewController: UITableViewController {

    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var zoomButton: UIBarButtonItem!
    @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var delegate: AddLocationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [addButton, zoomButton]
        addButton.isEnabled = false
    }
    
    @IBAction func textFieldEditingChanged(sender: UITextField) {
        addButton.isEnabled = !radiusTextField.text!.isEmpty && !noteTextField.text!.isEmpty
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onAdd(sender: AnyObject) {
        let coordinate = mapView.centerCoordinate
        let radius = Double(radiusTextField.text!) ?? 0
        let identifier = NSUUID().uuidString
        let note = noteTextField.text
        let eventType: EventType = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? .onEntry : .onExit
        delegate?.addLocationViewController(controller: self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note!, eventType: eventType)
    }
    
    @IBAction private func onZoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToUserLocation()
    }

}
