import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../screens/bluetooth_screen.dart';

class ScannerStatusWidget extends StatelessWidget {
  const ScannerStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothService>(
      builder: (context, btService, child) {
        final isConnected = btService.isConnected;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isConnected ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isConnected ? Colors.green.shade400 : Colors.orange.shade300,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green.shade100 : Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                    color: isConnected ? Colors.green.shade800 : Colors.orange.shade900,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAlignment.start,
                    children: [
                      const Text(
                        "Scanner Status",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isConnected ? Colors.green : Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConnected
                                ? (btService.connectedDeviceName ?? "Connected")
                                : "Not Connected",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isConnected ? Colors.green.shade900 : Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BluetoothScreen()),
                    );
                  },
                  child: Text(
                    isConnected ? "MANAGE" : "CONNECT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isConnected ? Colors.green.shade800 : Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
