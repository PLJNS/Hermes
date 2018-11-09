//
//  MapViewController.swift
//  Hermes
//
//  Created by Olivia Taylor on 11/8/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

struct PreferencesKeys {
    static let savedItems = "savedItems"
}

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var geotifications: [Geotification] = []
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        loadAllGeotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGeotification" {
            let navigationController = segue.destination as! UINavigationController
            let vc = navigationController.viewControllers.first as! AddLocationViewController
            vc.delegate = self
        }
    }
    
    func region(with geotification: Geotification) -> CLCircularRegion {
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        region.notifyOnEntry = true // (geotification.eventType == .onEntry)
        region.notifyOnExit = false //!region.notifyOnEntry
        return region
    }
    
    func startMonitoring(geotification: Geotification) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle: "Error", message: "Geofencing is not supported on this device!")
            return
        }
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            showAlert(withTitle: "Warning", message: "You must grant the app permission to access device location")
        }
        let region = self.region(with: geotification)
        locationManager?.startMonitoring(for: region)
    }
    
    func stopMonitoring(geotification: Geotification) {
        for region in locationManager?.monitoredRegions ?? [] {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else {
                continue
            }
            locationManager?.stopMonitoring(for: circularRegion)
        }
    }
    
    // MARK: Loading and saving functions
    func loadAllGeotifications() {
        geotifications = []
        guard let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) else { return }
        for savedItem in savedItems {
            guard let geotification = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? Geotification else { continue }
            add(geotification: geotification)
        }
    }
    
    func saveAllGeotifications() {
        var items: [Data] = []
        for geotification in geotifications {
            let item = NSKeyedArchiver.archivedData(withRootObject: geotification)
            items.append(item)
        }
        UserDefaults.standard.set(items, forKey: PreferencesKeys.savedItems)
    }
    
    // MARK: Functions that update the model/associated views with geotification changes
    func add(geotification: Geotification) {
        geotifications.append(geotification)
        mapView.addAnnotation(geotification)
        addRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    func remove(geotification: Geotification) {
        if let indexInArray = geotifications.index(of: geotification) {
            geotifications.remove(at: indexInArray)
        }
        mapView.removeAnnotation(geotification)
        removeRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    func updateGeotificationsCount() {
//        title = "Geotifications (\(geotifications.count))"
        navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20)
    }
    
    // MARK: Map overlay functions
    func addRadiusOverlay(forGeotification geotification: Geotification) {
        mapView?.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    func removeRadiusOverlay(forGeotification geotification: Geotification) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
                mapView?.removeOverlay(circleOverlay)
                break
            }
        }
    }
    
    // MARK: Other mapview functions
    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToUserLocation()
    }
    
}

// MARK: AddGeotificationViewControllerDelegate
extension MapViewController: AddLocationViewControllerDelegate {
    
    func addLocationViewController(controller: AddLocationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: EventType) {
        controller.dismiss(animated: true, completion: nil)
        let clampedRadius = min(radius, locationManager?.maximumRegionMonitoringDistance ?? -1)
        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
        add(geotification: geotification)
        startMonitoring(geotification: geotification)
        saveAllGeotifications()
    }
    
}

// MARK: - Location Manager Delegate
extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
}

// MARK: - MapView Delegate
extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myGeotification"
        if annotation is Geotification {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(named: "DeleteGeotification")!, for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }


    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete geotification
        let geotification = view.annotation as! Geotification
        stopMonitoring(geotification: geotification)
        remove(geotification: geotification)
        saveAllGeotifications()
    }

}
