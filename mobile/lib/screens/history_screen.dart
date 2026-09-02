import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/scan_service.dart';
import '../models/scan_history.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScanService>(context, listen: false).fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan History"),
      ),
      body: Consumer<ScanService>(
        builder: (context, scanService, child) {
          final history = scanService.history;

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history, size: 64, color: Colors.black26),
                  SizedBox(height: 16),
                  Text(
                    "No Scan History Yet",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  SizedBox(height: 8),
                  Text("Products scanned using Part 1 will appear here."),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final String ecoGrade = item is ScanHistoryItem ? item.ecoGrade : (item['eco_grade'] ?? item['grade'] ?? 'C');
              final String productName = item is ScanHistoryItem ? item.productName : (item['product_name'] ?? 'Product');
              final String rfidUid = item is ScanHistoryItem ? item.rfidUid : (item['rfid_uid'] ?? '');
              final double ecoScore = item is ScanHistoryItem ? item.ecoScore : ((item['eco_score'] ?? 0).toDouble());
              final DateTime date = item is ScanHistoryItem ? item.timestamp : (item['timestamp'] != null ? (DateTime.tryParse(item['timestamp'].toString()) ?? DateTime.now()) : DateTime.now());

              final gradeColor = AppTheme.getGradeColor(ecoGrade);
              final dateStr = DateFormat('MMM dd, yyyy • h:mm a').format(date);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: gradeColor.withOpacity(0.15),
                    child: Text(
                      ecoGrade,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                  ),
                  title: Text(
                    productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("$rfidUid • $dateStr"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${ecoScore.toInt()}/100",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: gradeColor,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.black45),
                    ],
                  ),
                  onTap: () {
                    if (rfidUid.isNotEmpty) {
                      scanService.analyzeProductByRfid(rfidUid);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ResultScreen()),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
