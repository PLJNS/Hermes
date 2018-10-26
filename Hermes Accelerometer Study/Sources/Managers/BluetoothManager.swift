//
//  BluetoothManager.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/25/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BluetoothManagerDelegate: class {
    func bluetoothManagerDidUpdateConnectedPeripherals(_ bluetoothManager: BluetoothManager)
    func bluetoothManager(_ bluetoothManager: BluetoothManager, didUpdateRankedPeripherals rankedPeripherals: [CBPeripheral])
    func bluetoothManager(_ bluetoothManager: BluetoothManager, didAttemptConnectionTo peripheral: CBPeripheral, error: Error?)
}

extension Notification.Name {
    
    static let BluetoothManagerDidConnectToPeripheral = Notification.Name(rawValue: "BluetoothManagerDidConnectToPeripheral")
    
    static let BluetoothManagerDidDisconnectFromPeripheral = Notification.Name(rawValue: "BluetoothManagerDidDisconnectFromPeripheral")
    
}

class BluetoothManager: NSObject {
    
    weak var delegate: BluetoothManagerDelegate?
    
    private var manager: CBCentralManager!
    private var peripherals: Set<CBPeripheral> = Set()
    private var identifiersToRSSIs: [UUID : NSNumber] = [:]
    private var rankedPeripherals: [CBPeripheral] = []
    private var connectedPeripherals: [CBPeripheral] = []
    private var timer: Timer?
    
    init(delegate: BluetoothManagerDelegate) {
        self.delegate = delegate
        super.init()
        manager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    func stopScan() {
        manager.stopScan()
    }
    
    func startScan() {
        manager.scanForPeripherals(withServices: nil, options: nil)
        connectedPeripherals = manager.retrieveConnectedPeripherals(withServices: [])
    }
    
    func connect(peripheral: CBPeripheral, notifyOnConnection: Bool, notifyOnDisconnection: Bool) {
        manager.connect(peripheral, options: [
            CBConnectPeripheralOptionNotifyOnConnectionKey : NSNumber(booleanLiteral: notifyOnConnection),
            CBConnectPeripheralOptionNotifyOnDisconnectionKey : NSNumber(booleanLiteral: notifyOnDisconnection)
        ])
    }
    
    func disconnect(peripheral: CBPeripheral) {
        manager.cancelPeripheralConnection(peripheral)
    }
    
    func isConnected(toPeripheral peripheral: CBPeripheral) -> Bool {
        return connectedPeripherals.contains(peripheral)
    }
    
    func rssi(for peripheral: CBPeripheral) -> NSNumber? {
        return identifiersToRSSIs[peripheral.identifier]
    }
    
}

private extension BluetoothManager {
    
    func rankPeripherals() {
        var peripheralsAndRSSIs: [(peripheral: CBPeripheral, rssi: NSNumber)] = []
        
        for peripheral in peripherals {
            if let rssi = identifiersToRSSIs[peripheral.identifier] {
                peripheralsAndRSSIs.append((peripheral, rssi))
            }
        }
        
        peripheralsAndRSSIs.sort(by: ({  $0.rssi.doubleValue > $1.rssi.doubleValue }))
        rankedPeripherals = peripheralsAndRSSIs.map({ $0.peripheral })
    }

}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            ()
        case .resetting:
            ()
        case .unsupported:
            ()
        case .unauthorized:
            ()
        case .poweredOff:
            ()
        case .poweredOn:
            manager.scanForPeripherals(withServices: nil, options: nil)
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
                guard let strongSelf = self else { return }
                strongSelf.rankPeripherals()
                strongSelf.delegate?.bluetoothManager(strongSelf, didUpdateRankedPeripherals: strongSelf.rankedPeripherals)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripherals.removeAll(where: { $0.identifier == peripheral.identifier })
        delegate?.bluetoothManagerDidUpdateConnectedPeripherals(self)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripherals.append(peripheral)
        delegate?.bluetoothManagerDidUpdateConnectedPeripherals(self)
        delegate?.bluetoothManager(self, didAttemptConnectionTo: peripheral, error: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.bluetoothManager(self, didAttemptConnectionTo: peripheral, error: error)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripherals.insert(peripheral)
        identifiersToRSSIs[peripheral.identifier] = RSSI
    }
    
}
