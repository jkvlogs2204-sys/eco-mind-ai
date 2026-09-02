class EcoComponentScoresModel {
  final double carbon;
  final double water;
  final double packaging;
  final double recyclability;
  final double reuse;

  EcoComponentScoresModel({
    required this.carbon,
    required this.water,
    required this.packaging,
    required this.recyclability,
    required this.reuse,
  });

  factory EcoComponentScoresModel.fromJson(Map<String, dynamic> json) {
    return EcoComponentScoresModel(
      carbon: (json['carbon'] ?? 50.0).toDouble(),
      water: (json['water'] ?? 50.0).toDouble(),
      packaging: (json['packaging'] ?? 50.0).toDouble(),
      recyclability: (json['recyclability'] ?? 50.0).toDouble(),
      reuse: (json['reuse'] ?? 50.0).toDouble(),
    );
  }
}

class GeminiInsightModel {
  final String summary;
  final String whyThisScore;
  final List<String> impactDrivers;
  final List<String> positiveFactors;
  final Map<String, String?> actions;
  final String? betterAlternative;
  final String disposalGuidance;
  final String confidenceNote;
  final String source;

  GeminiInsightModel({
    required this.summary,
    required this.whyThisScore,
    required this.impactDrivers,
    required this.positiveFactors,
    required this.actions,
    this.betterAlternative,
    required this.disposalGuidance,
    required this.confidenceNote,
    required this.source,
  });

  factory GeminiInsightModel.fromJson(Map<String, dynamic> json) {
    final rawActions = json['actions'] as Map<String, dynamic>? ?? {};
    final Map<String, String?> parsedActions = {};
    rawActions.forEach((key, value) {
      parsedActions[key] = value?.toString();
    });

    return GeminiInsightModel(
      summary: json['summary'] ?? '',
      whyThisScore: json['why_this_score'] ?? json['summary'] ?? '',
      impactDrivers: List<String>.from(json['impact_drivers'] ?? []),
      positiveFactors: List<String>.from(json['positive_factors'] ?? []),
      actions: parsedActions,
      betterAlternative: json['better_alternative'],
      disposalGuidance: json['disposal_guidance'] ?? '',
      confidenceNote: json['confidence_note'] ?? '',
      source: json['source'] ?? 'EcoMind AI',
    );
  }
}

class EcoScoreAnalysisModel {
  final double ecoScore;
  final String grade;
  final String decision;
  final String explanation;
  final EcoComponentScoresModel components;

  EcoScoreAnalysisModel({
    required this.ecoScore,
    required this.grade,
    required this.decision,
    required this.explanation,
    required this.components,
  });

  factory EcoScoreAnalysisModel.fromJson(Map<String, dynamic> json) {
    return EcoScoreAnalysisModel(
      ecoScore: (json['value'] ?? json['eco_score'] ?? 0.0).toDouble(),
      grade: json['grade'] ?? 'C',
      decision: json['decision'] ?? 'MODERATE IMPACT',
      explanation: json['explanation'] ?? '',
      components: EcoComponentScoresModel.fromJson(json['components'] ?? {}),
    );
  }
}
