import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/scan_service.dart';
import '../widgets/eco_score_card.dart';
import '../widgets/impact_card.dart';
import '../widgets/alternative_card.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Analysis"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ScanService>(context, listen: false).resetScan();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Consumer<ScanService>(
        builder: (context, scanService, child) {
          if (scanService.state == ScanState.analyzing) {
            return _buildLoadingView();
          }

          if (scanService.state == ScanState.error) {
            return _buildErrorView(context, scanService.errorMessage ?? "An error occurred");
          }

          final product = scanService.currentProduct;
          final analysis = scanService.currentAnalysis;
          final geminiInsight = scanService.currentGeminiInsight;

          if (product == null || analysis == null) {
            return const Center(child: Text("No product analysis available."));
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAlignment: CrossAlignment.start,
              children: [
                // Header Product Banner
                Container(
                  width: double.infinity,
                  color: AppTheme.primaryGreen,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  child: Column(
                    crossAlignment: CrossAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Data Status: ${product.dataStatus}",
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${product.brand} • Material: ${product.material}",
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Eco Score Gauge Card (Animated)
                EcoScoreCardWidget(analysis: analysis),

                // Environmental Impact Breakdown
                EnvironmentalImpactWidget(
                  product: product,
                  components: analysis.components,
                ),

                // ✨ EcoMind AI Insight Section (Structured Gemini AI Output)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAlignment: CrossAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.auto_awesome, color: Colors.amber, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  "EcoMind AI Insight",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            if (geminiInsight != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  geminiInsight.source,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Why This Score?
                        const Text(
                          "Why This Score?",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          geminiInsight?.whyThisScore ?? analysis.explanation,
                          style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                        ),
                        const SizedBox(height: 14),

                        // Impact Drivers
                        if (geminiInsight != null && geminiInsight.impactDrivers.isNotEmpty) ...[
                          const Text(
                            "Key Impact Drivers",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                          const SizedBox(height: 4),
                          ...geminiInsight.impactDrivers.map((d) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  crossAlignment: CrossAlignment.start,
                                  children: [
                                    const Text("• ", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                    Expanded(child: Text(d, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 12),
                        ],

                        // Positive Factors
                        if (geminiInsight != null && geminiInsight.positiveFactors.isNotEmpty) ...[
                          const Text(
                            "Positive Factors",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          const SizedBox(height: 4),
                          ...geminiInsight.positiveFactors.map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  crossAlignment: CrossAlignment.start,
                                  children: [
                                    const Text("✓ ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                    Expanded(child: Text(p, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 12),
                        ],

                        // What Can I Do? (Action Categories)
                        if (geminiInsight != null && geminiInsight.actions.isNotEmpty) ...[
                          const Text(
                            "What Can I Do?",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                          ),
                          const SizedBox(height: 6),
                          _buildActionTile("USE BETTER", geminiInsight.actions['use_better'], Icons.lightbulb_outline, Colors.blue),
                          _buildActionTile("REUSE", geminiInsight.actions['reuse'], Icons.autorenew, Colors.green),
                          _buildActionTile("REPAIR", geminiInsight.actions['repair'], Icons.build_outlined, Colors.amber),
                          _buildActionTile("REDUCE", geminiInsight.actions['reduce'], Icons.trending_down, Colors.purple),
                          _buildActionTile("RECYCLE", geminiInsight.actions['recycle'], Icons.recycling, Colors.teal),
                          _buildActionTile("REPLACE", geminiInsight.actions['replace'], Icons.swap_horiz, Colors.deepOrange),
                          const SizedBox(height: 10),
                        ],

                        // Disposal Guidance & Confidence Note
                        if (geminiInsight != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAlignment: CrossAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.delete_outline, size: 16, color: Colors.black54),
                                    SizedBox(width: 6),
                                    Text("Disposal Guidance:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(geminiInsight.disposalGuidance, style: const TextStyle(fontSize: 11, color: Colors.black70)),
                                const SizedBox(height: 6),
                                Text(
                                  geminiInsight.confidenceNote,
                                  style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black45),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Transparency Section: How EcoMind AI Works
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: const Color(0xFFF1F5F9),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAlignment: CrossAlignment.start,
                      children: const [
                        Text(
                          "How EcoMind AI Works",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "RFID identifies product → EcoMind's deterministic scoring engine calculates official score → Gemini explains environmental implications & action ideas.",
                          style: TextStyle(fontSize: 11, color: Colors.black64, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ),

                // Better Alternative Component
                AlternativeCardWidget(
                  scannedProduct: product,
                  analysis: analysis,
                ),

                // Scientific Honesty Disclaimer Note
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Data & Methodology: Environmental values shown are estimated/demo values for prototype demonstration and are not laboratory measurements.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                // Bottom Action Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        scanService.resetScan();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("SCAN ANOTHER PRODUCT"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionTile(String label, String? detail, IconData icon, Color color) {
    if (detail == null || detail.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAlignment: CrossAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              detail,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: AppTheme.primaryGreen),
            SizedBox(height: 24),
            Text(
              "Analyzing Product & AI Insights...",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
            SizedBox(height: 16),
            Text("• Identifying product UID ✓"),
            SizedBox(height: 6),
            Text("• Querying Eco Decision Engine ✓"),
            SizedBox(height: 6),
            Text("• Generating Gemini AI Insights..."),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 70, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "Product Not Found",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black64),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Provider.of<ScanService>(context, listen: false).resetScan();
                Navigator.pop(context);
              },
              child: const Text("TRY AGAIN"),
            ),
          ],
        ),
      ),
    );
  }
}
