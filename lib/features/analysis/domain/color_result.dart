/// Model kết quả phân tích màu sắc — Immutable.
///
/// Tuân thủ: mobile-flutter #1 — domain/ chứa Entity classes.
/// Map 1:1 với ColorApiResponse trên backend.
class MakeupGuide {
  final List<String> lip;
  final List<String> eye;
  final List<String> hair;

  const MakeupGuide({
    required this.lip,
    required this.eye,
    required this.hair,
  });

  factory MakeupGuide.fromJson(Map<String, dynamic> json) {
    return MakeupGuide(
      lip: List<String>.from(json['lip'] as List),
      eye: List<String>.from(json['eye'] as List),
      hair: List<String>.from(json['hair'] as List),
    );
  }
}

class ColorResult {
  final String subSeason;
  final String primarySeason;
  final double confidence;
  final String secondarySeason;
  final String explanation;
  final List<String> palette;     // 6 hex codes
  final MakeupGuide makeup;
  final String advice;

  const ColorResult({
    required this.subSeason,
    required this.primarySeason,
    required this.confidence,
    required this.secondarySeason,
    required this.explanation,
    required this.palette,
    required this.makeup,
    required this.advice,
  });

  factory ColorResult.fromJson(Map<String, dynamic> json) {
    return ColorResult(
      subSeason: json['sub_season'] as String,
      primarySeason: json['primary_season'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      secondarySeason: json['secondary_season'] as String,
      explanation: json['explanation'] as String,
      palette: List<String>.from(json['palette'] as List),
      makeup: MakeupGuide.fromJson(json['makeup'] as Map<String, dynamic>),
      advice: json['advice'] as String,
    );
  }
}
