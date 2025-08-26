// bluetooth_functions.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';

Future<void> sendSignalToSTM32(int tableNumber, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) async {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

  try {
    // Start scanning for devices
    flutterBlue.startScan(timeout: Duration(seconds: 15));
    var scanSubscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          devices.add(result.device);
        }
      }
    });

    // Wait for a while to gather scan results
    await Future.delayed(Duration(seconds: 10));
    flutterBlue.stopScan();
    await scanSubscription.cancel();

    // Find the desired device
    BluetoothDevice? desiredDevice;
    for (BluetoothDevice device in devices) {
      if (device.name == 'wadie') {
        desiredDevice = device;
        break;
      }
    }

    if (desiredDevice != null) {
      // Connect to the device
      await desiredDevice.connect();

      // Discover services
      List<BluetoothService> services = await desiredDevice.discoverServices();
      BluetoothService? service;
      try {
        service = services.firstWhere((s) => s.uuid == Guid('0000ffe0-0000-1000-8000-00805f9b34fb'));
      } catch (e) {
        service = null;
      }

      if (service != null) {
        BluetoothCharacteristic? characteristic;
        try {
          characteristic = service.characteristics.firstWhere((c) => c.uuid == Guid('0000ffe1-0000-1000-8000-00805f9b34fb'));
        } catch (e) {
          characteristic = null;
        }

        if (characteristic != null) {
          // Send data
          List<int> data = utf8.encode('Table number: $tableNumber Ready to deliver');
          await characteristic.write(data);

          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('Signal sent successfully to STM32'),
            ),
          );
        } else {
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('Characteristic not found for the desired device.'),
            ),
          );
        }
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Service not found for the desired device.'),
          ),
        );
      }

      // Disconnect from the device
      await desiredDevice.disconnect();
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Desired Bluetooth device not found'),
        ),
      );
    }
  } catch (e) {
    print('Error sending signal to STM32 via Bluetooth: $e');
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Error sending signal to STM32 via Bluetooth'),
      ),
    );
  }
}

Future<void> sendBluetoothData(
    String deviceName, String message, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) async {
  try {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    // Check if Bluetooth is available and turned on
    bool isAvailable = await flutterBlue.isAvailable;
    bool isOn = await flutterBlue.isOn;

    if (!isAvailable || !isOn) {
      print('Bluetooth is not available or turned off.');
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Bluetooth is not available or turned off'),
        ),
      );
      return;
    }

    // Start scanning for Bluetooth devices
    List<BluetoothDevice> scannedDevices = [];
    var scanSubscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name.trim().toUpperCase() ==
            deviceName.trim().toUpperCase()) {
          scannedDevices.add(result.device);
        }
      }
    });

    flutterBlue.startScan(timeout: Duration(seconds: 10));

    // Delay to allow scanning
    await Future.delayed(Duration(seconds: 10));

    // Stop scanning and cancel the subscription
    flutterBlue.stopScan();
    scanSubscription.cancel();

    // Find the desired Bluetooth device in the scanned devices
    BluetoothDevice? desiredDevice;
    if (scannedDevices.isNotEmpty) {
      desiredDevice = scannedDevices.first;
    } else {
      print('Desired Bluetooth device "$deviceName" not found.');
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Desired Bluetooth device not found'),
        ),
      );
      return;
    }

    // Connect to the desired Bluetooth device
    await desiredDevice.connect();

    // Define data to send
    List<int> data = utf8.encode(message);

    // Define service and characteristic UUIDs (modify as needed)
    Guid serviceUuid = Guid('0000ffe0-0000-1000-8000-00805f9b34fb');
    Guid characteristicUuid = Guid('0000ffe1-0000-1000-8000-00805f9b34fb');

    // Discover services and find the target service
    List<BluetoothService> services =
    await desiredDevice.discoverServices();
    BluetoothService service =
    services.firstWhere((s) => s.uuid == serviceUuid);

    // Find the characteristic within the service
    BluetoothCharacteristic? characteristic = service.characteristics
        .firstWhere((c) => c.uuid == characteristicUuid);

    if (characteristic != null) {
      // Write data to the characteristic
      await characteristic.write(data);
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Data sent successfully: $message'),
        ),
      );
    } else {
      print('Characteristic not found for the desired device.');
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Failed to send data via Bluetooth'),
        ),
      );
    }

    // Disconnect from the device after communication
    await desiredDevice.disconnect();
  } catch (e) {
    print('Error during Bluetooth communication: $e');
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Error during Bluetooth communication'),
      ),
    );
  }
}
