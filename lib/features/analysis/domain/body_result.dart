/// Model kết quả phân tích dáng người — Immutable.
///
/// Tuân thủ: mobile-flutter #1 — domain/ chứa Entity classes.
/// Map 1:1 với BodyApiResponse trên backend.
class BodyMeasurements {
  final String shoulderRelative;
  final String hipRelative;
  final String waistDefinition;

  const BodyMeasurements({
    required this.shoulderRelative,
    required this.hipRelative,
    required this.waistDefinition,
  });

  factory BodyMeasurements.fromJson(Map<String, dynamic> json) {
    return BodyMeasurements(
      shoulderRelative: json['shoulder_relative'] as String,
      hipRelative: json['hip_relative'] as String,
      waistDefinition: json['waist_definition'] as String,
    );
  }
}

class BodyResult {
  final String shape;
  final double confidence;
  final String analysisSource;
  final double? photoQualityScore;
  final String? photoQualityBand;
  final BodyMeasurements measurements;
  final List<String> stylingTips;
  final List<String> avoid;
  final String explanation;

  const BodyResult({
    required this.shape,
    required this.confidence,
    required this.analysisSource,
    required this.photoQualityScore,
    required this.photoQualityBand,
    required this.measurements,
    required this.stylingTips,
    required this.avoid,
    required this.explanation,
  });

  factory BodyResult.fromJson(Map<String, dynamic> json) {
    return BodyResult(
      shape: json['shape'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      analysisSource: (json['analysis_source'] as String?) ?? 'live',
      photoQualityScore: (json['photo_quality_score'] as num?)?.toDouble(),
      photoQualityBand: json['photo_quality_band'] as String?,
      measurements: BodyMeasurements.fromJson(
        json['measurements'] as Map<String, dynamic>,
      ),
      stylingTips: List<String>.from(json['styling_tips'] as List),
      avoid: List<String>.from(json['avoid'] as List),
      explanation: json['explanation'] as String,
    );
  }
}
