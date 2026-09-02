import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../theme/app_theme.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> _devices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPairedDevices();
  }

  Future<void> _loadPairedDevices() async {
    setState(() {
      _isLoading = true;
    });
    final btService = Provider.of<BluetoothService>(context, listen: false);
    final list = await btService.getPairedDevices();
    setState(() {
      _devices = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final btService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("HC-05 Bluetooth Setup"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPairedDevices,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Status Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: btService.isConnected ? Colors.green : Colors.orange,
                      child: Icon(
                        btService.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAlignment.start,
                        children: [
                          Text(
                            btService.isConnected
                                ? "Connected: ${btService.connectedDeviceName}"
                                : "Disconnected",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            btService.isConnected
                                ? "Address: ${btService.connectedDeviceAddress}"
                                : "Select your paired HC-05 module below to connect.",
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    if (btService.isConnected)
                      TextButton(
                        onPressed: () => btService.disconnect(),
                        child: const Text("DISCONNECT", style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (btService.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        btService.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            const Text(
              "Paired Bluetooth Devices",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                  : _devices.isEmpty
                      ? const Center(
                          child: Text(
                            "No paired Bluetooth devices found.\nPlease pair your HC-05 module in Android Bluetooth settings first.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _devices.length,
                          itemBuilder: (context, index) {
                            final device = _devices[index];
                            final isConnectedDevice = btService.connectedDeviceAddress == device.address;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const Icon(Icons.bluetooth, color: AppTheme.primaryGreen),
                                title: Text(
                                  device.name ?? "HC-05 Scanner",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(device.address),
                                trailing: isConnectedDevice
                                    ? const Chip(
                                        label: Text("CONNECTED", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        backgroundColor: Colors.green,
                                      )
                                    : ElevatedButton(
                                        onPressed: () async {
                                          final ok = await btService.connectToDevice(device);
                                          if (ok && mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Connected to ${device.name ?? 'HC-05'}")),
                                            );
                                          }
                                        },
                                        child: const Text("CONNECT"),
                                      ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
