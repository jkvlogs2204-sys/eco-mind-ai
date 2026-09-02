import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/scan_service.dart';
import '../services/bluetooth_service.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';
import 'rfid_management_screen.dart';
import 'bluetooth_connection_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  void initState() {
    super.initState();
    final btService = Provider.of<BluetoothService>(context, listen: false);
    final scanService = Provider.of<ScanService>(context, listen: false);
    scanService.attachBluetoothService(btService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Physical RFID Scanner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BluetoothConnectionScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ScanService>(
        builder: (context, scanService, child) {
          final btService = Provider.of<BluetoothService>(context);

          // Auto-navigate to ResultScreen when physical RFID tag is scanned
          if (scanService.state == ScanState.success) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResultScreen()),
              );
            });
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Real-time Top Status Banner (HC-05 CONNECTED / DISCONNECTED)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BluetoothConnectionScreen()),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    color: btService.isConnected ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            btService.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                            color: btService.isConnected ? Colors.green : Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAlignment: CrossAlignment.start,
                              children: [
                                Text(
                                  btService.isConnected
                                      ? "● HC-05 CONNECTED"
                                      : "● HC-05 DISCONNECTED",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: btService.isConnected ? Colors.green.shade800 : Colors.red.shade800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  btService.isConnected
                                      ? "Connected to ${btService.connectedDeviceName}. RFID Scanner Ready!"
                                      : "Tap here to connect your EcoMind RFID scanner.",
                                  style: const TextStyle(fontSize: 12, color: Colors.black64),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: btService.isConnected ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Animated Physical RFID Pulse Scanner
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: btService.isConnected ? AppTheme.lightSage.withOpacity(0.4) : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: btService.isConnected ? AppTheme.primaryGreen : Colors.grey,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        color: btService.isConnected ? AppTheme.primaryGreen : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            scanService.state == ScanState.analyzing
                                ? Icons.hourglass_top
                                : Icons.nfc,
                            size: 76,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "MFRC522",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                if (!btService.isConnected) ...[
                  const Text(
                    "SCANNER DISCONNECTED",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BluetoothConnectionScreen()),
                      );
                    },
                    icon: const Icon(Icons.bluetooth_searching),
                    label: const Text("CONNECT RFID SCANNER"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                ] else if (scanService.state == ScanState.analyzing) ...[
                  const CircularProgressIndicator(color: AppTheme.primaryGreen),
                  const SizedBox(height: 14),
                  const Text(
                    "Physical Tag Detected! Analyzing LCA metrics...",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen),
                  ),
                ] else if (scanService.state == ScanState.unregistered) ...[
                  Card(
                    color: Colors.amber.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
                          const SizedBox(height: 8),
                          const Text(
                            "Unregistered RFID Tag Detected",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Physical Tag UID ${scanService.scannedUid} is not assigned to a product.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RFIDManagementScreen()),
                              );
                            },
                            icon: const Icon(Icons.link),
                            label: const Text("REGISTER / ASSIGN TAG"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    "TAP PHYSICAL RFID TAG ON READER",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Place your product RFID card/tag against the MFRC522 sensor. The app will automatically identify the product, calculate the Eco Score, generate AI Insights, and display the result.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
