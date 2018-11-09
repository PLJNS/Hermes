//
//  MapKitExtensions.swift
//  Hermes
//
//  Created by Olivia Taylor on 11/8/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import MapKit
import UIKit

extension MKMapView {
    func zoomToUserLocation() {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        setRegion(region, animated: true)
    }
}
