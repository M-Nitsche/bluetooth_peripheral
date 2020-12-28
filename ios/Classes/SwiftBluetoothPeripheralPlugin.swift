import Flutter
import UIKit

public class SwiftBluetoothPeripheralPlugin: NSObject, FlutterPlugin, FlutterStreamHandler{
    
    private var peripheral = BLEPeripheralManager()
    private var eventSink: FlutterEventSink?
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: "dev.nitsche.bluetooth_peripheral/methods", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "dev.nitsche.bluetooth_peripheral/events", binaryMessenger: registrar.messenger())
    let instance = SwiftBluetoothPeripheralPlugin()
    eventChannel.setStreamHandler(instance)
    instance.registerListener();
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
  }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func registerListener() {
        peripheral.onAdvertisingStateChanged = {isAdvertising in
            if (self.eventSink != nil) {
                self.eventSink!(isAdvertising)
            }
        }
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
    case "startService":
        print("Start Service");
        startService(call, result)
    case "stopService":
        print("Stop Service");
        stopService(call, result)
    case "isAdvertising":
        isAdvertising(call, result)
    case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion);
    default:
        result(FlutterMethodNotImplemented);
    }
  }
    
        private func startService(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
            let map = call.arguments as? Dictionary<String, Any>
            let userData = UserData(
                userId: map?["userId"] as! String, username: map?["username"] as! String, displayName: map?["displayName"] as! String)
            peripheral.startService(data: userData);
            result(nil)
        }

        private func stopService(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
            peripheral.stopService();
            result(nil)
        }

        private func isAdvertising(_ call: FlutterMethodCall,
                                   _ result: @escaping FlutterResult) {
            result(peripheral.isAdvertising())
        }
}
