class ScanHistoryItem {
  final int id;
  final String rfidUid;
  final String productName;
  final double ecoScore;
  final String ecoGrade;
  final DateTime timestamp;

  ScanHistoryItem({
    required this.id,
    required this.rfidUid,
    required this.productName,
    required this.ecoScore,
    required this.ecoGrade,
    required this.timestamp,
  });

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id'] ?? 0,
      rfidUid: json['rfid_uid'] ?? '',
      productName: json['product_name'] ?? 'Scanned Product',
      ecoScore: (json['eco_score'] ?? json['score'] ?? 50.0).toDouble(),
      ecoGrade: json['eco_grade'] ?? json['grade'] ?? 'C',
      timestamp: json['timestamp'] != null
          ? (DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rfid_uid': rfidUid,
      'product_name': productName,
      'eco_score': ecoScore,
      'eco_grade': ecoGrade,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
