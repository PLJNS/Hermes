//
//  AddSessionViewController.swift
//  Hermes
//
//  Created by Paul Jones on 10/18/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import UIKit

class AddSessionViewController: UIViewController {
    
    var text: String? {
        return textField.text
    }
    
    @IBOutlet private weak var textField: UITextField!
    
}
