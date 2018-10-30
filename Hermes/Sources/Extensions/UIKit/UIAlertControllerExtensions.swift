//
//  UIAlertControllerExtensions.swift
//  Hermes
//
//  Created by Paul Jones on 10/16/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import UIKit

extension UIAlertController {
    public convenience init(title: String = "Error",
                            error: Error,
                            defaultActionButtonTitle: String = "OK",
                            preferredStyle: UIAlertController.Style = .alert,
                            tintColor: UIColor? = nil) {
        self.init(title: title, message: error.localizedDescription, preferredStyle: preferredStyle)
        let defaultAction = UIAlertAction(title: defaultActionButtonTitle, style: .default, handler: nil)
        addAction(defaultAction)
        if let color = tintColor {
            view.tintColor = color
        }
    }
}
