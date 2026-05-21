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

class MenswearGuide {
  final List<String> tops;
  final List<String> bottoms;
  final List<String> accessories;

  const MenswearGuide({
    required this.tops,
    required this.bottoms,
    required this.accessories,
  });

  factory MenswearGuide.fromJson(Map<String, dynamic> json) {
    return MenswearGuide(
      tops: List<String>.from(json['tops'] as List? ?? const []),
      bottoms: List<String>.from(json['bottoms'] as List? ?? const []),
      accessories: List<String>.from(json['accessories'] as List? ?? const []),
    );
  }
}

class ColorResult {
  final String subSeason;
  final String primarySeason;
  final double confidence;
  final String analysisSource;
  final String secondarySeason;
  final String explanation;
  final List<String> palette;     // 6 hex codes
  final MakeupGuide makeup;
  final String advice;
  final MenswearGuide? menswear;
  final String gradientFrom;
  final String gradientTo;

  // Hardcode map theo ENHANCED `season_data.py` (Playbook 6.5 - Cách 1)
  static const Map<String, Map<String, String>> _seasonGradientMap = {
    'Light Spring': {'gradient_from': '#FFD6A5', 'gradient_to': '#FFAFCC'},
    'True Spring': {'gradient_from': '#FFD6A5', 'gradient_to': '#FFAFCC'},
    'Bright Spring': {'gradient_from': '#FFD6A5', 'gradient_to': '#FFAFCC'},
    'Light Summer': {'gradient_from': '#BDE0FE', 'gradient_to': '#CDB4DB'},
    'True Summer': {'gradient_from': '#BDE0FE', 'gradient_to': '#CDB4DB'},
    'Soft Summer': {'gradient_from': '#BDE0FE', 'gradient_to': '#CDB4DB'},
    'Soft Autumn': {'gradient_from': '#E9C46A', 'gradient_to': '#8B4513'},
    'True Autumn': {'gradient_from': '#E9C46A', 'gradient_to': '#8B4513'},
    'Deep Autumn': {'gradient_from': '#E9C46A', 'gradient_to': '#8B4513'},
    'Deep Winter': {'gradient_from': '#1B4F72', 'gradient_to': '#4A235A'},
    'True Winter': {'gradient_from': '#1B4F72', 'gradient_to': '#4A235A'},
    'Bright Winter': {'gradient_from': '#1B4F72', 'gradient_to': '#4A235A'},
  };

  const ColorResult({
    required this.subSeason,
    required this.primarySeason,
    required this.confidence,
    required this.analysisSource,
    required this.secondarySeason,
    required this.explanation,
    required this.palette,
    required this.makeup,
    required this.advice,
    required this.menswear,
    required this.gradientFrom,
    required this.gradientTo,
  });

  factory ColorResult.fromJson(Map<String, dynamic> json) {
    final subSeason = json['sub_season'] as String;
    final gradientFrom = (json['gradient_from'] as String?) ??
        _seasonGradientMap[subSeason]?['gradient_from'] ??
        '#FAFAFA';
    final gradientTo = (json['gradient_to'] as String?) ??
        _seasonGradientMap[subSeason]?['gradient_to'] ??
        '#E0E0E0';

    return ColorResult(
      subSeason: subSeason,
      primarySeason: json['primary_season'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      analysisSource: (json['analysis_source'] as String?) ?? 'live',
      secondarySeason: json['secondary_season'] as String,
      explanation: json['explanation'] as String,
      palette: List<String>.from(json['palette'] as List),
      makeup: MakeupGuide.fromJson(json['makeup'] as Map<String, dynamic>),
      advice: json['advice'] as String,
      menswear: (json['menswear'] as Map<String, dynamic>?) != null
          ? MenswearGuide.fromJson(json['menswear'] as Map<String, dynamic>)
          : null,
      gradientFrom: gradientFrom,
      gradientTo: gradientTo,
    );
  }
}
