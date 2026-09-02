class ProductModel {
  final int id;
  final String name;
  final String brand;
  final String category;
  final String material;
  final String packaging;
  final double carbonFootprint;
  final String carbonUnit;
  final double waterFootprint;
  final String waterUnit;
  final double recyclability;
  final double reusePotential;
  final int lifespanDays;
  final String? description;
  final String? disposalGuidance;
  final String dataStatus;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.material,
    required this.packaging,
    required this.carbonFootprint,
    required this.carbonUnit,
    required this.waterFootprint,
    required this.waterUnit,
    required this.recyclability,
    required this.reusePotential,
    required this.lifespanDays,
    this.description,
    this.disposalGuidance,
    required this.dataStatus,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final prod = json['product'] ?? json;
    final env = json['environment'] ?? json;

    return ProductModel(
      id: prod['id'] ?? 0,
      name: prod['name'] ?? prod['product_name'] ?? 'Unknown Product',
      brand: prod['brand'] ?? 'Unknown Brand',
      category: prod['category'] ?? 'General',
      material: prod['material'] ?? 'Mixed Materials',
      packaging: env['packaging'] ?? json['packaging'] ?? 'Standard',
      carbonFootprint: (env['carbon']?['value'] ?? json['carbon_footprint'] ?? 0.0).toDouble(),
      carbonUnit: env['carbon']?['unit'] ?? json['carbon_unit'] ?? 'kg CO2e',
      waterFootprint: (env['water']?['value'] ?? json['water_footprint'] ?? 0.0).toDouble(),
      waterUnit: env['water']?['unit'] ?? json['water_unit'] ?? 'litres',
      recyclability: (env['recyclability'] ?? json['recyclability'] ?? 0.0).toDouble(),
      reusePotential: (env['reuse_potential'] ?? json['reuse_potential'] ?? 0.0).toDouble(),
      lifespanDays: env['lifespan_days'] ?? json['lifespan'] ?? 30,
      description: prod['description'],
      disposalGuidance: env['disposal_guidance'] ?? json['disposal_guidance'],
      dataStatus: json['data_status'] ?? 'DEMO DATA',
    );
  }
}
