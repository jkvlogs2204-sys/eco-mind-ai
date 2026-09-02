import 'package:flutter/material.dart';
import '../models/eco_score.dart';
import '../theme/app_theme.dart';

class EcoScoreCardWidget extends StatefulWidget {
  final EcoScoreAnalysisModel analysis;

  const EcoScoreCardWidget({super.key, required this.analysis});

  @override
  State<EcoScoreCardWidget> createState() => _EcoScoreCardWidgetState();
}

class _EcoScoreCardWidgetState extends State<EcoScoreCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.analysis.ecoScore,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.outCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(EcoScoreCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.analysis.ecoScore != widget.analysis.ecoScore) {
      _scoreAnimation = Tween<double>(
        begin: 0.0,
        end: widget.analysis.ecoScore,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.outCubic));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMethodologyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Score Calculation Methodology",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Eco score is calculated using a transparent 5-factor weighted algorithm:",
                style: TextStyle(fontSize: 13, color: Colors.black64),
              ),
              const SizedBox(height: 16),
              _buildFactorRow("Carbon Impact", "30%", widget.analysis.components.carbon, Colors.blue),
              _buildFactorRow("Water Impact", "20%", widget.analysis.components.water, Colors.cyan),
              _buildFactorRow("Packaging Material", "15%", widget.analysis.components.packaging, Colors.amber),
              _buildFactorRow("Recyclability", "20%", widget.analysis.components.recyclability, Colors.green),
              _buildFactorRow("Reuse & Lifespan", "15%", widget.analysis.components.reuse, Colors.purple),
              const SizedBox(height: 16),
              const Text(
                "Final Eco Score = (Carbon × 0.30) + (Water × 0.20) + (Packaging × 0.15) + (Recyclability × 0.20) + (Reuse × 0.15)",
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFactorRow(String name, String weight, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "Weight: $weight",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "${score.toInt()}/100",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = AppTheme.getGradeColor(widget.analysis.grade);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, gradeColor.withOpacity(0.05)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedBuilder(
          animation: _scoreAnimation,
          builder: (context, child) {
            final animatedScore = _scoreAnimation.value;

            return Column(
              children: [
                const Text(
                  "ECO SCORE",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: animatedScore / 100.0,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.shade200,
                        color: gradeColor,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          animatedScore.toInt().toString(),
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: gradeColor,
                          ),
                        ),
                        const Text(
                          "/ 100",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: gradeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "GRADE ${widget.analysis.grade}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.analysis.decision,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: gradeColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.analysis.explanation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _showMethodologyBottomSheet(context),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text("How is this score calculated?"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
