import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/eco_score.dart';
import '../theme/app_theme.dart';
import '../screens/comparison_screen.dart';

class AlternativeCardWidget extends StatelessWidget {
  final ProductModel scannedProduct;
  final EcoScoreAnalysisModel analysis;

  const AlternativeCardWidget({
    super.key,
    required this.scannedProduct,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final alt = analysis.betterAlternative;
    if (alt == null) return const SizedBox.shrink();

    final altGradeColor = AppTheme.getGradeColor(alt.ecoGrade);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD1E7DD), width: 1.5),
      ),
      color: const Color(0xFFF4FBF7),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: Color(0xFF0F5132), size: 22),
                const SizedBox(width: 8),
                const Text(
                  "BETTER ALTERNATIVE",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Color(0xFF0F5132),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alt.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${alt.brand} • ${alt.category}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: altGradeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: altGradeColor, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        alt.ecoScore.toInt().toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: altGradeColor,
                        ),
                      ),
                      Text(
                        "Grade ${alt.ecoGrade}",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: altGradeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alt.reason,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ComparisonScreen(
                        scannedProduct: scannedProduct,
                        analysis: analysis,
                        alternative: alt,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.compare_arrows, size: 20),
                label: const Text("COMPARE PRODUCTS"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F5132),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
