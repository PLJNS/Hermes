//
//  BluetoothDetailViewController.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/25/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothDetailViewController: UIViewController {
    
    var peripheral: CBPeripheral!
    var bluetoothManager: BluetoothManager!
    
    @IBOutlet private weak var notifyOnConnectionSwitch: UISwitch!
    @IBOutlet private weak var notifyOnDisconnectionSwitch: UISwitch!
    @IBOutlet private weak var connectButton: UIButton!
    @IBOutlet private weak var disconnectButton: UIButton!
    @IBOutlet private weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = peripheral?.debugDescription
    }
    
    @IBAction func buttonDidTouchUpInside(_ sender: UIButton) {
        switch sender {
        case connectButton:
            bluetoothManager.connect(peripheral: peripheral,
                                     notifyOnConnection: notifyOnConnection,
                                     notifyOnDisconnection: notifyOnDisconnection)
        case disconnectButton:
            bluetoothManager.disconnect(peripheral: peripheral)
        default:
            fatalError()
        }
    }
    
}

private extension BluetoothDetailViewController {
    
    private var notifyOnConnection: Bool {
        return notifyOnConnectionSwitch.isOn
    }
    
    private var notifyOnDisconnection: Bool {
        return notifyOnDisconnectionSwitch.isOn
    }
    
}
