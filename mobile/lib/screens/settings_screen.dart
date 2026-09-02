import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/scan_service.dart';
import '../services/bluetooth_service.dart';
import '../theme/app_theme.dart';
import 'bluetooth_connection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    final scanService = Provider.of<ScanService>(context, listen: false);
    _urlController = TextEditingController(text: scanService.apiService.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanService = Provider.of<ScanService>(context);
    final btService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings & Config"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "API CONFIGURATION",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Eco Decision Engine Base URL", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text(
                    "For Android physical devices, use your PC local IP (e.g. http://192.168.1.5:8000). For Android Emulator, use http://10.0.2.2:8000.",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          scanService.apiService.updateBaseUrl(_urlController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("API Base URL Updated")),
                          );
                        },
                        child: const Text("SAVE"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "HARDWARE & SCANNER",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bluetooth, color: AppTheme.primaryGreen),
              title: const Text("Bluetooth Connection"),
              subtitle: Text(btService.isConnected ? "Connected to ${btService.connectedDeviceName}" : "Not Connected"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BluetoothConnectionScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "ABOUT ECOMIND AI",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("EcoMind AI System — Part 3", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 6),
                  Text("Aligned with UN Sustainable Development Goal 12 (Responsible Consumption and Production)."),
                  SizedBox(height: 8),
                  Text("Version 1.0.0 (Build 2026.1)", style: TextStyle(fontSize: 12, color: Colors.black45)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
