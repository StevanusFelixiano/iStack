//
//  BluetoothService.swift
//  smashPad
//
//  Created by Ahmad Taufiq Hidayat on 01/07/26.
//


import Foundation
import CoreBluetooth
import Combine // Tambahkan baris ini!

class BluetoothService: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = BluetoothService()
    
    private var centralManager: CBCentralManager!
    private var smartPillowPeripheral: CBPeripheral?
    private var ledCharacteristic: CBCharacteristic?
    
    // Ganti dengan UUID dari kode ESP32 kamu nanti
    private let pillowServiceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789012")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func turnOnPillowLED() {
        guard let peripheral = smartPillowPeripheral, let characteristic = ledCharacteristic else { return }
        let data = Data([0x01]) // 0x01 artinya ON di hardware
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        print("💡 Sinyal Bluetooth: Nyalakan Bantal!")
    }
    
    func turnOffPillowLED() {
        guard let peripheral = smartPillowPeripheral, let characteristic = ledCharacteristic else { return }
        let data = Data([0x00]) // 0x00 artinya OFF
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        print("💡 Sinyal Bluetooth: Matikan Bantal!")
    }
    
    // MARK: - Bluetooth Delegates
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // centralManager.scanForPeripherals(withServices: [pillowServiceUUID])
            print("Bluetooth aktif, siap mencari bantal IoT.")
        }
    }
}
