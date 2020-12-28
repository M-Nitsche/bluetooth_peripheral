import 'dart:async';

import 'package:flutter/services.dart';

class BluetoothPeripheral {
  static BluetoothPeripheral _instance;
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  factory BluetoothPeripheral() {
    if (_instance == null) {
      final MethodChannel methodChannel =
          const MethodChannel('dev.nitsche.bluetooth_peripheral/methods');

      final EventChannel eventChannel =
          const EventChannel('dev.nitsche.bluetooth_peripheral/events');
      _instance = BluetoothPeripheral.private(methodChannel, eventChannel);
    }
    return _instance;
  }

  BluetoothPeripheral.private(this._methodChannel, this._eventChannel);

  Future<String> get platformVersion async {
    final String version = await _methodChannel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<void> startService(String userId, String username, String displayName) async {
    assert(userId != null && userId.isNotEmpty);
    if (!await isAdvertising) {
      Map params = <String, String>{
        "userId": userId,
        "username": username,
        "displayName": displayName
      };
      await _methodChannel.invokeMethod('startService', params);
    }
  }

  Future<void> stopService() async {
    if (await isAdvertising) {
      await _methodChannel.invokeMethod('stopService');
    }
  }

  Future<bool> get isAdvertising async {
    return await _methodChannel.invokeMethod('isAdvertising');
  }

  Stream<bool> getAdvertisingStateChange() {
    return _eventChannel.receiveBroadcastStream().cast<bool>();
  }
}
