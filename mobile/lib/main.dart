import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/bluetooth_service.dart';
import 'services/scan_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcoMindApp());
}

class EcoMindApp extends StatelessWidget {
  const EcoMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothService()),
        ChangeNotifierProxyProvider<BluetoothService, ScanService>(
          create: (context) => ScanService(
            Provider.of<BluetoothService>(context, listen: false),
          ),
          update: (context, bluetoothService, previous) =>
              previous ?? ScanService(bluetoothService),
        ),
      ],
      child: MaterialApp(
        title: 'EcoMind AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
