import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BleManager {
  static final BleManager instance = BleManager._internal();

  BleManager._internal();

  BluetoothDevice? device;
  BluetoothCharacteristic? sensorCharacteristic;

  StreamSubscription<List<ScanResult>>? scanSubscription;
  StreamSubscription<List<int>>? notifySubscription;
  StreamSubscription<BluetoothConnectionState>? connectionSubscription;

  final StreamController<void> _disconnectEvents =
      StreamController<void>.broadcast();

  Stream<void> get disconnectEvents => _disconnectEvents.stream;

  int bpm = 0;
  int spo2 = 0;
  double temperature = 0;
  bool fingerDetected = false;
  int respiratoryRate = 0;

  String connectionStatus = "Disconnected";

  bool _isConnecting = false;
  bool _isScanning = false;

  // Used to cancel an old automatic reconnect.
  int _connectionAttempt = 0;



/* static blue connection 
  static const String savedDeviceKey = 'saved_device_mac';

  //static const String targetDeviceId = "3C:0F:02:D7:A1:91"; lumang esp nasira
  static const String targetDeviceId = "3C:0F:02:D7:A5:3D"; //new esp 

  static const String characteristicUuid =
      "abcdefab-1234-5678-1234-abcdefabcdef"; */


  static const String savedDeviceKey = 'saved_device_mac';

  static const String serviceUuid =
      "12345678-1234-1234-1234-1234567890ab";

  static const String characteristicUuid =
      "abcdefab-1234-5678-1234-abcdefabcdef";
  

  // ============================================================
  // MANUAL SCAN
  // Used by Settings -> Scan for Devices
  // ============================================================


/* static blue connection 

  Future<void> scan([String? targetMac]) async {
    print("=================================");
    print("MANUAL SCAN REQUESTED");
    print("=================================");

    // A manual scan should take priority over
    // any previous automatic attempt.
    _connectionAttempt++;

    // Clean up previous BLE operations.
    await _cleanupBleOperations();

    final String macToFind = targetMac ?? targetDeviceId;

    connectionStatus = "Scanning...";

    print("Looking for: $macToFind");

    _isScanning = true;

    try {
      scanSubscription =
          FlutterBluePlus.scanResults.listen((results) async {
        if (!_isScanning) return;

        for (final ScanResult result in results) {
          final String deviceId =
              result.device.remoteId.toString();

          print(
            "Found Device -> "
            "Name: '${result.device.platformName}', "
            "ID: $deviceId",
          );

          if (deviceId == macToFind) {
            print("=================================");
            print("PetMonitor Found!");
            print("Device ID: $deviceId");
            print("=================================");

            _isScanning = false;

            await FlutterBluePlus.stopScan();
            await scanSubscription?.cancel();
            scanSubscription = null;

            device = result.device;

            await _connectToDevice(
              result.device,
              _connectionAttempt,
            );

            break;
          }
        }
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
      );

      // If the scan timed out without finding the device.
      if (_isScanning) {
        _isScanning = false;

        connectionStatus = "Disconnected";

        print("PetMonitor was not found.");
      }
    } catch (e) {
      _isScanning = false;

      connectionStatus = "Disconnected";

      print("BLE scan error: $e");
    }
  }    */


  Future<void> scan() async {
    print("=================================");
    print("MANUAL SCAN REQUESTED");
    print("=================================");

    _connectionAttempt++;
    await _cleanupBleOperations();

    connectionStatus = "Scanning...";
    _isScanning = true;

    try {
      scanSubscription =
          FlutterBluePlus.scanResults.listen((results) async {
        if (!_isScanning) return;

        for (final ScanResult result in results) {
          final String deviceName =
              result.advertisementData.advName.isNotEmpty
                  ? result.advertisementData.advName
                  : result.device.platformName;

          final String deviceId =
              result.device.remoteId.toString();

          final bool hasAniSafeService =
              result.advertisementData.serviceUuids.any(
            (uuid) =>
                uuid.toString().toLowerCase() ==
                serviceUuid.toLowerCase(),
          );

          print(
            "Found Device -> "
            "Name: '$deviceName', "
            "ID: $deviceId, "
            "Services: ${result.advertisementData.serviceUuids}",
          );

          // ==========================================
          // CHECK FOR ANISAFE ESP32
          // ==========================================

          /*if (deviceName == "PetMonitor" &&
              hasAniSafeService) {  */

          if (hasAniSafeService) {

            print("=================================");
            print("AniSafe PetMonitor Found!");
            print("Device Name: $deviceName");
            print("Device ID: $deviceId");
            print("AniSafe Service Found!");
            print("=================================");

            _isScanning = false;

            await FlutterBluePlus.stopScan();
            await scanSubscription?.cancel();
            scanSubscription = null;

            device = result.device;

            await _connectToDevice(
              result.device,
              _connectionAttempt,
            );

            break;
          }
        }
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
      );

      if (_isScanning) {
        _isScanning = false;

        connectionStatus = "Disconnected";

        print("=================================");
        print("AniSafe PetMonitor was not found.");
        print("=================================");
      }
    } catch (e) {
      _isScanning = false;

      connectionStatus = "Disconnected";

      print("=================================");
      print("BLE scan error: $e");
      print("=================================");
    }
  }




  // ============================================================
  // CONNECT TO DEVICE
  // ============================================================

  Future<bool> _connectToDevice(
    BluetoothDevice targetDevice,
    int attempt,
  ) async {
    if (_isConnecting) {
      print("BleManager: Already connecting.");
      return false;
    }

    // If another operation has replaced this attempt,
    // stop this one.
    if (attempt != _connectionAttempt) {
      print("Old connection attempt cancelled.");
      return false;
    }

    _isConnecting = true;

    device = targetDevice;

    connectionStatus = "Connecting...";

    print("=================================");
    print("Connecting to ESP32...");
    print("Device ID: ${targetDevice.remoteId}");
    print("=================================");

    try {
      // Clean old listeners only.
      await notifySubscription?.cancel();
      notifySubscription = null;

      await connectionSubscription?.cancel();
      connectionSubscription = null;

      // --------------------------------------------------------
      // CONNECT
      // --------------------------------------------------------

      await targetDevice.connect(
        timeout: const Duration(seconds: 10),
      );

      // Check if this attempt is still valid.
      if (attempt != _connectionAttempt) {
        print("Connection attempt became obsolete.");

        _isConnecting = false;

        return false;
      }

      print("Connected to ESP32!");

      connectionStatus = "Connected";

      // --------------------------------------------------------
      // CONNECTION STATE LISTENER
      // --------------------------------------------------------

      connectionSubscription =
          targetDevice.connectionState.listen((state) async {
        print("Connection State: $state");

        if (state == BluetoothConnectionState.connected) {
          connectionStatus = "Connected";
        }

        
        if (state == BluetoothConnectionState.disconnected) {
          print("ESP32 disconnected.");

          connectionStatus = "Disconnected";

          sensorCharacteristic = null;

          // Notify MonitoringController immediately.
          _disconnectEvents.add(null);

          // Keep the existing automatic reconnect behavior.
          final int reconnectAttempt = ++_connectionAttempt;

          await _automaticReconnect(reconnectAttempt);
        }

      });

      // --------------------------------------------------------
      // SAVE DEVICE ID
      // --------------------------------------------------------

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        savedDeviceKey,
        targetDevice.remoteId.toString(),
      );

      print(
        "Saved ESP32 ID: ${targetDevice.remoteId}",
      );

      // --------------------------------------------------------
      // DISCOVER SERVICES
      // --------------------------------------------------------

      final services =
          await targetDevice.discoverServices();

      print("========== SERVICES ==========");

      for (final service in services) {
        print("Service: ${service.uuid}");

        for (final characteristic
            in service.characteristics) {
          print(
            "  Characteristic: ${characteristic.uuid}",
          );

          if (characteristic.uuid
                  .toString()
                  .toLowerCase() ==
              characteristicUuid.toLowerCase()) {
            sensorCharacteristic = characteristic;

            print("=================================");
            print("Sensor Characteristic Found!");
            print("=================================");

            await sensorCharacteristic!
                .setNotifyValue(true);

            print("=================================");
            print("Notifications Enabled!");
            print("=================================");

            // --------------------------------------------------
            // NOTIFICATION LISTENER
            // --------------------------------------------------

            await notifySubscription?.cancel();

            notifySubscription =
                sensorCharacteristic!
                    .lastValueStream
                    .listen((value) {
              if (value.isEmpty) return;

              try {
                final String jsonString =
                    utf8.decode(value);

                print("JSON: $jsonString");

                final data =
                    jsonDecode(jsonString);

                bpm = data["heartRate"] ?? 0;

                spo2 = data["spo2"] ?? 0;

                temperature =
                    (data["temperature"] ?? 0)
                        .toDouble();

                fingerDetected =
                    data["fingerDetected"] ?? false;

                respiratoryRate =
                    (data["respiratoryRate"] ?? 0).round();

                print("=================================");
                print("BPM: $bpm");
                print("SpO2: $spo2");
                print("Temperature: $temperature");
                print("Finger: $fingerDetected");
                print("Respiratory Rate: $respiratoryRate");
                print("=================================");
              } catch (e) {
                print(
                  "BLE JSON error: $e",
                );
              }
            });

            print(
              "BLE data listener ready.",
            );
          }
        }
      }

      _isConnecting = false;

      return true;
    } catch (e) {
      print("=================================");
      print("ESP32 connection failed.");
      print("Error: $e");
      print("=================================");

      connectionStatus = "Disconnected";

      _isConnecting = false;

      return false;
    }
  }

  // ============================================================
  // AUTOMATIC CONNECTION WHEN MONITOR SCREEN OPENS
  // ============================================================

  Future<bool> connectToSavedDevice() async {
    print("=================================");
    print("AUTOMATIC CONNECTION REQUESTED");
    print("=================================");

    if (_isConnecting) {
      print(
        "BleManager: Another connection is already running.",
      );

      return false;
    }

    // Cancel any previous scan/reconnect.
    _connectionAttempt++;

    await _cleanupBleOperations();

    final prefs =
        await SharedPreferences.getInstance();

    final String? savedMac =
        prefs.getString(savedDeviceKey);

    if (savedMac == null || savedMac.isEmpty) {
      print(
        "BleManager: No saved ESP32 device.",
      );

      connectionStatus = "Disconnected";

      return false;
    }

    print("=================================");
    print("Saved ESP32 found.");
    print("Saved ID: $savedMac");
    print("Trying automatic connection...");
    print("=================================");

    connectionStatus = "Connecting...";

    final int attempt = _connectionAttempt;

    try {
      final BluetoothDevice savedDevice =
          BluetoothDevice.fromId(savedMac);

      device = savedDevice;

      return await _connectToDevice(
        savedDevice,
        attempt,
      );
    } catch (e) {
      print(
        "Automatic connection failed: $e",
      );

      connectionStatus = "Disconnected";

      _isConnecting = false;

      return false;
    }
  }

  // ============================================================
  // AUTOMATIC RECONNECT AFTER DISCONNECTION
  // ============================================================

  Future<void> _automaticReconnect(
    int attempt,
  ) async {
    if (_isConnecting) {
      return;
    }

    final prefs =
        await SharedPreferences.getInstance();

    final String? savedMac =
        prefs.getString(savedDeviceKey);

    if (savedMac == null || savedMac.isEmpty) {
      print(
        "No saved device for automatic reconnect.",
      );

      return;
    }

    print("=================================");
    print("Automatic reconnect scheduled...");
    print("Saved ID: $savedMac");
    print("=================================");

    await Future.delayed(
      const Duration(seconds: 2),
    );

    // A manual scan or another connection attempt
    // may have happened during the delay.
    if (attempt != _connectionAttempt) {
      print(
        "Automatic reconnect cancelled because "
        "another BLE operation started.",
      );

      return;
    }

    if (_isConnecting || _isScanning) {
      return;
    }

    try {
      final BluetoothDevice savedDevice =
          BluetoothDevice.fromId(savedMac);

      await _connectToDevice(
        savedDevice,
        attempt,
      );
    } catch (e) {
      print(
        "Automatic reconnect failed: $e",
      );

      connectionStatus = "Disconnected";

      _isConnecting = false;
    }
  }

  // ============================================================
  // CLEANUP BLE OPERATIONS
  // ============================================================

  Future<void> _cleanupBleOperations() async {
    print(
      "BleManager: Cleaning previous BLE operations...",
    );

    _isScanning = false;

    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}

    await scanSubscription?.cancel();
    scanSubscription = null;

    await notifySubscription?.cancel();
    notifySubscription = null;

    await connectionSubscription?.cancel();
    connectionSubscription = null;

    sensorCharacteristic = null;

    _isConnecting = false;
  }
}