import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> topics = [
      {
        'title': 'Carbon Footprint',
        'icon': Icons.co2,
        'color': Colors.blue,
        'summary': 'The total greenhouse gas emissions produced directly and indirectly by a product throughout its lifecycle.',
        'details': 'Carbon footprint measures emissions in kg CO2 equivalent. Lower carbon footprints reduce global thermal forcing and atmospheric warming.'
      },
      {
        'title': 'Water Footprint',
        'icon': Icons.water_drop,
        'color': Colors.cyan,
        'summary': 'The volume of freshwater used to produce, manufacture, and transport the product.',
        'details': 'Water footprints include green water (rainwater), blue water (surface/groundwater), and grey water (dilution of pollutants).'
      },
      {
        'title': 'Recyclability & Circularity',
        'icon': Icons.autorenew,
        'color': Colors.green,
        'summary': 'The proportion of materials in a product that can be reclaimed and reprocessed into new raw materials.',
        'details': 'High recyclability prevents landfill overflow and reduces the necessity of extracting virgin raw resources.'
      },
      {
        'title': 'Packaging Sustainability',
        'icon': Icons.inventory_2,
        'color': Colors.amber,
        'summary': 'Evaluating whether product packaging uses single-use plastics or eco-friendly alternatives.',
        'details': 'Opting for compostable, paper, or glass packaging minimizes microplastic accumulation in terrestrial and aquatic ecosystems.'
      },
      {
        'title': 'Reuse & Product Lifespan',
        'icon': Icons.update,
        'color': Colors.purple,
        'summary': 'The capability of a product to be reused multiple times or sustained over a long duration.',
        'details': 'Reusable stainless steel or glass containers eliminate thousands of single-use disposable items across their operational lifetime.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Learn Sustainability"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final item = topics[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: (item['color'] as Color).withOpacity(0.15),
                child: Icon(item['icon'] as IconData, color: item['color'] as Color),
              ),
              title: Text(
                item['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                item['summary'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    item['details'] as String,
                    style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
