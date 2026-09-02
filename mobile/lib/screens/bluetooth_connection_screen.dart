import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../theme/app_theme.dart';
import 'scan_screen.dart';

class BluetoothConnectionScreen extends StatefulWidget {
  const BluetoothConnectionScreen({super.key});

  @override
  State<BluetoothConnectionScreen> createState() =>
      _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState
    extends State<BluetoothConnectionScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start scan when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bt = Provider.of<BluetoothService>(context, listen: false);
      if (!bt.isConnected && !bt.isSearching) {
        bt.enableAndScan(); // asks user to turn on Bluetooth if OFF
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect HC-05 Scanner'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<BluetoothService>(
        builder: (context, bt, _) {
          return Column(
            children: [
              // ── Header + Status ─────────────────────────────────────────
              Container(
                width: double.infinity,
                color: AppTheme.primaryGreen,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    _StatusCard(bt: bt),
                    const SizedBox(height: 12),
                    _MainActionButton(bt: bt),
                  ],
                ),
              ),

              // ── Device List ─────────────────────────────────────────────
              Expanded(
                child: bt.isConnected
                    ? _ConnectedView(bt: bt)
                    : _DeviceListView(bt: bt),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Card
// ─────────────────────────────────────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final BluetoothService bt;
  const _StatusCard({required this.bt});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String title;
    String sub;

    switch (bt.connState) {
      case BluetoothConnState.connected:
        icon = Icons.check_circle;
        color = Colors.greenAccent;
        title = '🟢  CONNECTED — ${bt.connectedDeviceName}';
        sub = 'RFID Scanner is live. Tap a tag to scan!';
        break;
      case BluetoothConnState.connecting:
        icon = Icons.hourglass_top;
        color = Colors.amber;
        title = '🟡  Connecting...';
        sub = 'Establishing serial connection to HC-05...';
        break;
      case BluetoothConnState.enablingBluetooth:
        icon = Icons.bluetooth_disabled;
        color = Colors.amber;
        title = '🟡  Turning Bluetooth ON...';
        sub = 'Please accept the Bluetooth permission popup.';
        break;
      case BluetoothConnState.searching:
        icon = Icons.bluetooth_searching;
        color = Colors.lightBlueAccent;
        title = '🔵  Scanning for HC-05...';
        sub = 'Searching nearby Bluetooth devices. Keep HC-05 powered ON.';
        break;
      case BluetoothConnState.found:
        icon = Icons.bluetooth;
        color = Colors.lightBlueAccent;
        title = '🔵  Devices Found';
        sub = 'Select your HC-05 scanner below.';
        break;
      case BluetoothConnState.failed:
        icon = Icons.link_off;
        color = Colors.redAccent;
        title = '🔴  Connection Failed';
        sub = bt.errorMessage ?? 'Tap RETRY to try again.';
        break;
      case BluetoothConnState.error:
        icon = Icons.error_outline;
        color = Colors.redAccent;
        title = '🔴  Error';
        sub = bt.errorMessage ?? 'Tap SCAN to retry.';
        break;
      default:
        icon = Icons.bluetooth_disabled;
        color = Colors.white54;
        title = '⚪  Not Connected';
        sub = 'Tap the button below to find your HC-05 scanner.';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Action Button
// ─────────────────────────────────────────────────────────────────────────────
class _MainActionButton extends StatelessWidget {
  final BluetoothService bt;
  const _MainActionButton({required this.bt});

  @override
  Widget build(BuildContext context) {
    if (bt.isConnected) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ScanScreen()),
            );
          },
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('START SCANNING'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    final isLoading = bt.isSearching ||
        bt.connState == BluetoothConnState.connecting ||
        bt.connState == BluetoothConnState.enablingBluetooth;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : () => bt.enableAndScan(),
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.bluetooth_searching),
        label: Text(isLoading ? 'SCANNING...' : '🔍  SCAN FOR HC-05'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Connected View (with Disconnect option)
// ─────────────────────────────────────────────────────────────────────────────
class _ConnectedView extends StatelessWidget {
  final BluetoothService bt;
  const _ConnectedView({required this.bt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_connected,
              size: 80, color: AppTheme.primaryGreen),
          const SizedBox(height: 16),
          Text(
            bt.connectedDeviceName ?? 'HC-05',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            bt.connectedDeviceAddress ?? '',
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 6),
          const Chip(
            label: Text(
              'CONNECTED — RFID Scanner Ready',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            backgroundColor: Colors.green,
          ),
          const SizedBox(height: 30),
          const Text(
            'Tap any registered RFID product tag on your MFRC522 reader. '
            'The result will appear instantly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 30),
          OutlinedButton.icon(
            onPressed: () => bt.disconnect(),
            icon: const Icon(Icons.bluetooth_disabled, color: Colors.red),
            label: const Text(
              'DISCONNECT',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Device List View
// ─────────────────────────────────────────────────────────────────────────────
class _DeviceListView extends StatelessWidget {
  final BluetoothService bt;
  const _DeviceListView({required this.bt});

  @override
  Widget build(BuildContext context) {
    final allDevices = bt.discoveredDevices;

    if (allDevices.isEmpty && !bt.isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bluetooth_disabled,
                  size: 64, color: Colors.black26),
              const SizedBox(height: 16),
              const Text(
                'No Bluetooth devices found.',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const Text(
                'Make sure your HC-05 module is powered ON and your phone Bluetooth is enabled.\n\n'
                'If HC-05 is not listed, pair it first:\n'
                'Phone Settings → Bluetooth → Pair new device → Select HC-05.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black45, height: 1.5),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => bt.enableAndScan(),
                icon: const Icon(Icons.refresh),
                label: const Text('SCAN AGAIN'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── HC-05 Priority Devices ──────────────────────────────────────
        if (bt.priorityDevices.isNotEmpty) ...[
          const _SectionHeader(
            icon: Icons.star,
            label: 'EcoMind HC-05 Scanners',
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 8),
          ...bt.priorityDevices.map(
            (d) => _DeviceCard(device: d, bt: bt, isPriority: true),
          ),
          const SizedBox(height: 16),
        ],

        // ── All Other Paired / Discovered Devices ───────────────────────
        const _SectionHeader(
          icon: Icons.devices,
          label: 'All Nearby Bluetooth Devices',
          color: Colors.black87,
        ),
        const SizedBox(height: 8),

        if (bt.isSearching)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Scanning...',
                  style: TextStyle(color: AppTheme.primaryGreen),
                ),
              ],
            ),
          ),

        ...allDevices
            .where(
              (d) => !bt.priorityDevices.any((p) => p.address == d.address),
            )
            .map((d) => _DeviceCard(device: d, bt: bt, isPriority: false)),

        if (allDevices.isEmpty && bt.isSearching)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Scanning for HC-05...\nKeep the module powered ON.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionHeader(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Device Card
// ─────────────────────────────────────────────────────────────────────────────
class _DeviceCard extends StatelessWidget {
  final BluetoothDevice device;
  final BluetoothService bt;
  final bool isPriority;
  const _DeviceCard(
      {required this.device, required this.bt, required this.isPriority});

  @override
  Widget build(BuildContext context) {
    final isThisConnected =
        bt.isConnected && bt.connectedDeviceAddress == device.address;
    final isThisConnecting = bt.connState == BluetoothConnState.connecting &&
        bt.connectedDeviceAddress == device.address;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isPriority ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isPriority
            ? const BorderSide(color: AppTheme.primaryGreen, width: 1.5)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              isPriority ? AppTheme.primaryGreen : Colors.grey.shade200,
          child: Icon(
            Icons.bluetooth,
            color: isPriority ? Colors.white : Colors.black54,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                device.name ?? 'Unknown Device',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            if (isPriority)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.lightSage,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'HC-05',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          device.address,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: isThisConnected
            ? const Chip(
                label: Text(
                  'CONNECTED ✓',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.green,
              )
            : isThisConnecting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppTheme.primaryGreen,
                    ),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      final ok = await bt.connectToDevice(device);
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Connected to ${device.name ?? 'HC-05'}!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(bt.errorMessage ?? 'Connection failed'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('CONNECT'),
                  ),
      ),
    );
  }
}
