//
//  BluetoothViewController.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/24/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import UIKit
import Dwifft
import CoreBluetooth

class BluetoothViewController: UIViewController {
    
    private var bluetoothManager: BluetoothManager!
    private var dataSource: SingleSectionTableViewDiffCalculator<CBPeripheral>!
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private var pauseBarButtonItem: UIBarButtonItem!
    @IBOutlet private var playBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothManager = BluetoothManager(delegate: self)
        dataSource = SingleSectionTableViewDiffCalculator(tableView: tableView)
        navigationItem.rightBarButtonItems = [pauseBarButtonItem]
    }
    
    @IBAction func didSelectBarButtonItem(_ sender: UIBarButtonItem) {
        switch sender {
        case pauseBarButtonItem:
            navigationItem.rightBarButtonItems = [playBarButtonItem]
            bluetoothManager.stopScan()
        case playBarButtonItem:
            navigationItem.rightBarButtonItems = [pauseBarButtonItem]
            bluetoothManager.startScan()
        default:
            ()
        }
    }
}

extension BluetoothViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothTableViewCell", for: indexPath)
        let peripheral = dataSource.rows[indexPath.row]
        cell.textLabel?.text = peripheral.name ?? peripheral.identifier.uuidString
        cell.detailTextLabel?.text = "\(bluetoothManager.rssi(for: peripheral)?.doubleValue ?? 0)"
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.accessoryType = bluetoothManager.isConnected(toPeripheral: peripheral) ? .checkmark : .none
        return cell
    }

}

extension BluetoothViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = dataSource.rows[indexPath.row]
        if bluetoothManager.isConnected(toPeripheral: peripheral) {
            bluetoothManager.disconnect(peripheral: peripheral)
        } else {
            bluetoothManager.connect(peripheral: peripheral, notify: false)
        }
    }
    
}

extension BluetoothViewController: BluetoothManagerDelegate {
    
    func bluetoothManagerDidUpdateConnectedPeripherals(_ bluetoothManager: BluetoothManager) {
        tableView.reloadData()
    }
    
    func bluetoothManager(_ bluetoothManager: BluetoothManager, didUpdateRankedPeripherals rankedPeripherals: [CBPeripheral]) {
        dataSource.rows = rankedPeripherals
    }
    
    func bluetoothManager(_ bluetoothManager: BluetoothManager, didAttemptConnectionTo peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            present(error: error)
            return
        }
    }
    
}
