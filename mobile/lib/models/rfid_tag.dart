class RFIDTagModel {
  final int id;
  final String rfidUid;
  final int? productId;
  final String status;
  final String? productName;
  final String? category;
  final DateTime createdAt;

  RFIDTagModel({
    required this.id,
    required this.rfidUid,
    this.productId,
    required this.status,
    this.productName,
    this.category,
    required this.createdAt,
  });

  factory RFIDTagModel.fromJson(Map<String, dynamic> json) {
    return RFIDTagModel(
      id: json['id'] ?? 0,
      rfidUid: json['rfid_uid'] ?? '',
      productId: json['product_id'],
      status: json['status'] ?? 'UNASSIGNED',
      productName: json['product_name'],
      category: json['category'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
