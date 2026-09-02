import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BluetoothConnState {
  disconnected,
  enablingBluetooth,
  searching,
  found,
  connecting,
  connected,
  failed,
  error,
}

class BluetoothService extends ChangeNotifier {
  BluetoothConnection? _connection;
  BluetoothConnState _connState = BluetoothConnState.disconnected;

  String? _connectedDeviceName;
  String? _connectedDeviceAddress;
  String? _errorMessage;

  List<BluetoothDevice> _discoveredDevices = [];
  List<BluetoothDevice> _priorityDevices = [];
  StreamSubscription<BluetoothDiscoveryResult>? _discoverySubscription;
  bool _isSearching = false;

  final StreamController<String> _rfidStreamController =
      StreamController<String>.broadcast();
  Stream<String> get rfidStream => _rfidStreamController.stream;

  String _buffer = '';

  BluetoothConnState get connState => _connState;
  bool get isConnected => _connState == BluetoothConnState.connected;
  bool get isSearching => _isSearching;
  String? get connectedDeviceName => _connectedDeviceName;
  String? get connectedDeviceAddress => _connectedDeviceAddress;
  String? get errorMessage => _errorMessage;
  List<BluetoothDevice> get discoveredDevices => _discoveredDevices;
  List<BluetoothDevice> get priorityDevices => _priorityDevices;

  static const String _prefAddress = 'last_hc05_address';
  static const String _prefName = 'last_hc05_name';

  BluetoothService() {
    _initAutoReconnect();
  }

  // ── Load saved device info without auto-firing un-permitted connection ──
  Future<void> _initAutoReconnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAddress = prefs.getString(_prefAddress);
      final savedName = prefs.getString(_prefName);
      if (savedAddress != null && savedAddress.isNotEmpty) {
        _connectedDeviceName = savedName ?? 'HC-05 Scanner';
        _connectedDeviceAddress = savedAddress;
      }
    } catch (e) {
      debugPrint('SharedPreferences init error: $e');
    }
  }

  // ── Request Bluetooth ON from user, then scan ───────────────────────────────
  Future<void> enableAndScan() async {
    _errorMessage = null;
    notifyListeners();

    try {
      final bool? isOn = await FlutterBluetoothSerial.instance.isEnabled;
      if (isOn != true) {
        _connState = BluetoothConnState.enablingBluetooth;
        notifyListeners();

        final bool? enabled =
            await FlutterBluetoothSerial.instance.requestEnable();
        if (enabled != true) {
          _connState = BluetoothConnState.error;
          _errorMessage =
              'Bluetooth is OFF. Please enable Bluetooth to connect the HC-05 scanner.';
          notifyListeners();
          return;
        }
      }

      startDiscovery();
    } catch (e) {
      _connState = BluetoothConnState.error;
      _errorMessage = 'Bluetooth permission error: $e';
      notifyListeners();
    }
  }

  // ── Discover nearby Classic Bluetooth devices ───────────────────────────────
  Future<void> startDiscovery() async {
    _isSearching = true;
    _connState = BluetoothConnState.searching;
    _discoveredDevices.clear();
    _priorityDevices.clear();
    _errorMessage = null;
    notifyListeners();

    try {
      final bonded = await FlutterBluetoothSerial.instance.getBondedDevices();
      for (final device in bonded) {
        _addDiscoveredDevice(device);
      }
      notifyListeners();

      _discoverySubscription?.cancel();
      _discoverySubscription =
          FlutterBluetoothSerial.instance.startDiscovery().listen(
        (result) {
          _addDiscoveredDevice(result.device);
          notifyListeners();
        },
        onDone: () {
          _isSearching = false;
          if (_connState == BluetoothConnState.searching) {
            _connState = _discoveredDevices.isNotEmpty
                ? BluetoothConnState.found
                : BluetoothConnState.disconnected;
          }
          notifyListeners();
        },
        onError: (e) {
          _isSearching = false;
          _connState = BluetoothConnState.error;
          _errorMessage = 'Bluetooth scan error: $e';
          notifyListeners();
        },
      );
    } catch (e) {
      _isSearching = false;
      _connState = BluetoothConnState.error;
      _errorMessage = 'Failed to start scan: $e';
      notifyListeners();
    }
  }

  void _addDiscoveredDevice(BluetoothDevice device) {
    if (_discoveredDevices.any((d) => d.address == device.address)) return;
    _discoveredDevices.add(device);
    final name = (device.name ?? '').toUpperCase();
    if (name.contains('HC-05') ||
        name.contains('ECOMIND') ||
        name.contains('SCANNER')) {
      _priorityDevices.add(device);
    }
  }

  void stopDiscovery() {
    try {
      _discoverySubscription?.cancel();
    } catch (_) {}
    _isSearching = false;
    notifyListeners();
  }

  // ── Connect to selected HC-05 device ───────────────────────────────────────
  Future<bool> connectToDevice(BluetoothDevice device) async {
    stopDiscovery();
    _connState = BluetoothConnState.connecting;
    _connectedDeviceAddress = device.address;
    _errorMessage = null;
    notifyListeners();

    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _connectedDeviceName = device.name ?? 'HC-05 Scanner';
      _connectedDeviceAddress = device.address;
      _connState = BluetoothConnState.connected;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefAddress, device.address);
        await prefs.setString(_prefName, _connectedDeviceName!);
      } catch (_) {}

      notifyListeners();
      _listenToStream();
      return true;
    } catch (e) {
      _connState = BluetoothConnState.failed;
      _errorMessage = 'Cannot connect to ${device.name ?? 'HC-05'}: $e\n\n'
          'Tip: Make sure HC-05 is powered ON and paired in Phone Settings.';
      notifyListeners();
      return false;
    }
  }

  // ── Auto-reconnect to last saved device ────────────────────────────────────
  Future<bool> autoReconnect() async {
    if (_connectedDeviceAddress == null || _connectedDeviceAddress!.isEmpty) {
      return false;
    }
    if (isConnected) return true;

    try {
      final bool? isOn = await FlutterBluetoothSerial.instance.isEnabled;
      if (isOn != true) return false;

      _connState = BluetoothConnState.connecting;
      notifyListeners();

      _connection =
          await BluetoothConnection.toAddress(_connectedDeviceAddress!);
      _connState = BluetoothConnState.connected;
      notifyListeners();
      _listenToStream();
      return true;
    } catch (e) {
      _connState = BluetoothConnState.disconnected;
      notifyListeners();
      return false;
    }
  }

  // ── Read PRODUCT:<UID>\n lines from HC-05 serial stream ────────────────────
  void _listenToStream() {
    try {
      _connection?.input?.listen(
        (Uint8List data) {
          _buffer += ascii.decode(data);
          while (_buffer.contains('\n')) {
            final idx = _buffer.indexOf('\n');
            final line = _buffer.substring(0, idx).trim();
            _buffer = _buffer.substring(idx + 1);
            if (line.isNotEmpty) _handleIncomingLine(line);
          }
        },
        onDone: () => _handleDisconnectEvent(),
        onError: (e) {
          _errorMessage = 'Bluetooth stream error: $e';
          _handleDisconnectEvent();
        },
      );
    } catch (e) {
      _handleDisconnectEvent();
    }
  }

  void _handleIncomingLine(String line) {
    line = line.trim().toUpperCase();
    if (line.startsWith('PRODUCT:')) {
      final uid = line.substring(8).trim();
      if (uid.isNotEmpty) {
        _rfidStreamController.add(uid);
      }
    }
  }

  void _handleDisconnectEvent() {
    try {
      _connection?.dispose();
      _connection = null;
    } catch (_) {}
    _connState = BluetoothConnState.disconnected;
    notifyListeners();
  }

  Future<void> disconnect() async {
    stopDiscovery();
    _handleDisconnectEvent();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefAddress);
      await prefs.remove(_prefName);
    } catch (_) {}
    _connectedDeviceName = null;
    _connectedDeviceAddress = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopDiscovery();
    try {
      _connection?.dispose();
      _rfidStreamController.close();
    } catch (_) {}
    super.dispose();
  }

  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (_) {
      return [];
    }
  }
}
