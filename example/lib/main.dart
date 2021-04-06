import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:bluetooth_peripheral/bluetooth_peripheral.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothPeripheral _bluetoothPeripheral = BluetoothPeripheral.instance;
  String _platformVersion = 'Unknown';
  bool _isBroadcasting = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _bluetoothPeripheral.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void _toggleAdvertise() async {
    if (await _bluetoothPeripheral.isAdvertising) {
      _bluetoothPeripheral.stopService();
      setState(() {
        _isBroadcasting = false;
      });
    } else {
      _bluetoothPeripheral.startService("pqEk1YJskZSS8kXBs0VVNO5keVT2", "Miliman13", "Max Nitsche");
      setState(() {
        _isBroadcasting = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('Is advertising: ' + _isBroadcasting.toString()),
              TextButton(
                  onPressed: () => _toggleAdvertise(),
                  child: Text(
                    'Toggle advertising',
                    style: Theme.of(context).primaryTextTheme.button.copyWith(color: Colors.blue),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
