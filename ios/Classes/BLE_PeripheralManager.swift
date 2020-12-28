//
//  BLECentralManager.swift
//  BlueToothCentral
//
//  Created by Olivier Robin on 30/10/2016.
//  Copyright © 2016 fr.ormaa. All rights reserved.
//

import Foundation
import CoreBluetooth


// Apple documentation :
// https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/CoreBluetoothBackgroundProcessingForIOSApps/PerformingTasksWhileYourAppIsInTheBackground.html

// UUID of peripheral service, and characteristics
// can be generated using "uuidgen" under osx console

let peripheralName = "GymWithMehhhhhhhh";
let userServiceUUID = "50189210-7EB7-4502-BAFE-8E95DCC9C536";

//Characteristics
let userIdCharacteristicUUID = "11967A3A-B135-449B-8117-739A62332697";
let usernameCharacteristicUUID = "2E46E42B-364A-4A82-B843-6FBAAB1315D8";
let displayNameCharacterisitcUUID = "9C245CA3-2250-43F4-8232-FDDB31025BA3";

class BLEPeripheralManager : NSObject, CBPeripheralManagerDelegate {

    var localPeripheralManager: CBPeripheralManager!
    var createdService = [CBService]()
    var userData: UserData!
    
    var onAdvertisingStateChanged: ((Bool) -> Void)?
    var shouldStartAdvertise: Bool = false
    
    override init() {
        super.init()
        localPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // start the PeripheralManager
    //
    func startService(data: UserData) {
        userData = data
            shouldStartAdvertise = true
            peripheralManagerDidUpdateState(localPeripheralManager)
    }
    
    // Stop advertising.
    //
    func stopService() {
        if(localPeripheralManager != nil) {
            print("stop BLEPeripheral")
            self.localPeripheralManager.removeAllServices()
            self.localPeripheralManager.stopAdvertising()
            onAdvertisingStateChanged!(false)
        } else {
            print("Cannot stop because periperalManager is nil")
        }
    }
    
    // delegate
    //
    // Receive bluetooth state
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        if peripheral.state == .poweredOn && shouldStartAdvertise {
            self.createServices()
            shouldStartAdvertise = false

        }
        else {
            print("cannot create services. state = " + getState(peripheral: peripheral))
        }
        onAdvertisingStateChanged!(peripheral.isAdvertising)
    }
    
    func createServices() {
        print("createServices")

        // service
        let serviceUUID = CBUUID(string: userServiceUUID)
        let service = CBMutableService(type: serviceUUID, primary: true)
        
        // characteristic
        var chs = [CBMutableCharacteristic]()

        // Read characteristic
        let characteristic1UUID = CBUUID(string: userIdCharacteristicUUID)
        let properties: CBCharacteristicProperties = [.read]
        let permissions: CBAttributePermissions = [.readable]
        var ch = CBMutableCharacteristic(type: characteristic1UUID, properties: properties, value: userData.userId, permissions: permissions)
        chs.append(ch)
        
        let characteristic2UUID = CBUUID(string: usernameCharacteristicUUID)
        ch = CBMutableCharacteristic(type: characteristic2UUID, properties: properties, value: userData.username, permissions: permissions)
        chs.append(ch)
        
        let characteristic3UUID = CBUUID(string: displayNameCharacterisitcUUID)
        ch = CBMutableCharacteristic(type: characteristic3UUID, properties: properties, value: userData.displayName, permissions: permissions)
        chs.append(ch)
        
        // Create the service, add the characteristic to it
        service.characteristics = chs
        
        createdService.append(service)
        localPeripheralManager.add(service)
    }

    // delegate
    // service + Charactersitic added to peripheral
    //
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?){
        print("peripheralManager didAdd service")
        
        if error != nil {
            print("Error adding services: \(error?.localizedDescription ?? "Error")")
        }
        else {
            let advertisement: [String : Any] = [CBAdvertisementDataServiceUUIDsKey : [service.uuid]] //CBAdvertisementDataLocalNameKey: peripheralName]
            // start the advertisement
            self.localPeripheralManager.startAdvertising(advertisement)
            
            print("Starting to advertise.")
        }
    }
    
    // Advertising done
    //
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?){
        if error != nil {
            print("peripheralManagerDidStartAdvertising Error :\n \(error?.localizedDescription ?? "Error")")
        }
        else {
            print( "peripheralManagerDidStartAdvertising OK")
        }
    }
    
    // called when Central manager send read request
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        // prepare advertisement data
        let data: Data = "Hello You".data(using: String.Encoding.utf16)!
        request.value = data //characteristic.value

        // Respond to the request
        localPeripheralManager.respond( to: request, withResult: .success)
        
        // acknowledge : ok
        peripheral.respond(to: request, withResult: CBATTError.success)
    }
    
    // called when central manager send write request
    //
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print( "peripheralManager didReceiveWrite")
        for r in requests {
            print("request uuid: " + r.characteristic.uuid.uuidString)
        }
        
        if requests.count > 0 {
            let str = NSString(data: requests[0].value!, encoding:String.Encoding.utf16.rawValue)!
            print("value sent by central Manager :\n" + String(describing: str))
        }
        peripheral.respond(to: requests[0], withResult: CBATTError.success)
    }

    func isAdvertising() -> Bool {
        if (localPeripheralManager == nil) {
            return false
        }
        return localPeripheralManager.isAdvertising
    }
    
    func respond(to request: CBATTRequest, withResult result: CBATTError.Code) {
        print("response requested")
    }
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        print("peripheral name changed")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("peripheral service modified")
    }
    
    func getState(peripheral: CBPeripheralManager) -> String {
        
        switch peripheral.state {
        case .poweredOn :
            return "poweredON"
        case .poweredOff :
            return "poweredOFF"
        case .resetting:
            return "resetting"
        case .unauthorized:
            return "unauthorized"
        case .unknown:
            return "unknown"
        case .unsupported:
            return "unsupported"
        @unknown default:
            fatalError()
        }
    }
}
