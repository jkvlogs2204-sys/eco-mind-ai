import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/eco_score.dart';

class EnvironmentalImpactWidget extends StatelessWidget {
  final ProductModel product;
  final ComponentScoresModel components;

  const EnvironmentalImpactWidget({
    super.key,
    required this.product,
    required this.components,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ENVIRONMENTAL IMPACT",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricTile(
              icon: Icons.co2,
              title: "Carbon Footprint",
              value: "${product.carbonFootprint} ${product.carbonUnit}",
              subScore: components.carbon,
              color: Colors.blue.shade700,
            ),
            const Divider(height: 24),
            _buildMetricTile(
              icon: Icons.water_drop,
              title: "Water Footprint",
              value: "${product.waterFootprint} ${product.waterUnit}",
              subScore: components.water,
              color: Colors.cyan.shade700,
            ),
            const Divider(height: 24),
            _buildMetricTile(
              icon: Icons.inventory_2,
              title: "Packaging",
              value: product.packaging,
              subScore: components.packaging,
              color: Colors.amber.shade800,
            ),
            const Divider(height: 24),
            _buildMetricTile(
              icon: Icons.autorenew,
              title: "Recyclability",
              value: "${product.recyclability.toInt()}%",
              subScore: components.recyclability,
              color: Colors.green.shade700,
            ),
            const Divider(height: 24),
            _buildMetricTile(
              icon: Icons.update,
              title: "Reuse & Lifespan",
              value: "${product.reusePotential.toInt()}% (${product.lifespanDays} days)",
              subScore: components.reuse,
              color: Colors.purple.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String value,
    required double subScore,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: subScore / 100.0,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.15),
            color: color,
          ),
        ),
      ],
    );
  }
}
