import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';

///Singletone instance
class BluetoothPeripheral {
  final MethodChannel _methodChannel =
      const MethodChannel('dev.nitsche.bluetooth_peripheral/methods');
  final EventChannel _eventChannel = const EventChannel('dev.nitsche.bluetooth_peripheral/events');

  /// Singleton boilerplate
  BluetoothPeripheral._() {
    log("Bluetooth peripheral singleton created!", name: this.runtimeType.toString());
  }

  static BluetoothPeripheral _instance = BluetoothPeripheral._();
  static BluetoothPeripheral get instance => _instance;

  Future<String?> get platformVersion async {
    final String? version = await _methodChannel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<void> startService(String userId, String username, String displayName) async {
    assert(userId.isNotEmpty);
    if (!await (isAdvertising as FutureOr<bool>)) {
      Map params = <String, String>{
        "userId": userId,
        "username": username,
        "displayName": displayName
      };
      await _methodChannel.invokeMethod('startService', params);
    }
  }

  Future<void> stopService() async {
    if (await (isAdvertising) ?? false) {
      await _methodChannel.invokeMethod('stopService');
    }
  }

  Future<bool?> get isAdvertising async {
    return await _methodChannel.invokeMethod('isAdvertising');
  }

  Stream<bool> getAdvertisingStateChange() {
    return _eventChannel.receiveBroadcastStream().cast<bool>();
  }
}
