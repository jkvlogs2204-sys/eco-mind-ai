import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/eco_score.dart';
import '../theme/app_theme.dart';

class ComparisonScreen extends StatelessWidget {
  final ProductModel scannedProduct;
  final EcoScoreAnalysisModel analysis;
  final BetterAlternativeModel alternative;

  const ComparisonScreen({
    super.key,
    required this.scannedProduct,
    required this.analysis,
    required this.alternative,
  });

  @override
  Widget build(BuildContext context) {
    final scannedGradeColor = AppTheme.getGradeColor(analysis.grade);
    final altGradeColor = AppTheme.getGradeColor(alternative.ecoGrade);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Comparison"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "SUSTAINABILITY COMPARISON",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Scanned Product Card
                Expanded(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: scannedGradeColor, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          const Text(
                            "SCANNED PRODUCT",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            scannedProduct.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: scannedGradeColor.withOpacity(0.15),
                            child: Text(
                              analysis.ecoScore.toInt().toString(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: scannedGradeColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Grade ${analysis.grade}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: scannedGradeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "VS",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black45,
                    ),
                  ),
                ),

                // Alternative Product Card
                Expanded(
                  child: Card(
                    color: const Color(0xFFF4FBF7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: altGradeColor, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          const Text(
                            "BETTER ALTERNATIVE",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            alternative.productName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: altGradeColor.withOpacity(0.15),
                            child: Text(
                              alternative.ecoScore.toInt().toString(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: altGradeColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Grade ${alternative.ecoGrade}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: altGradeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAlignment.start,
                  children: [
                    const Text(
                      "Why Choose the Alternative?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alternative.reason,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
