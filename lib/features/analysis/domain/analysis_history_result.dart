/// Model lịch sử phân tích — dùng cho màn "Xem lại kết quả".
///
/// Tuân thủ: mobile-flutter #1 — domain/ chứa Entity classes.
import 'color_result.dart';
import 'body_result.dart';

class AnalysisHistoryResult {
  final ColorResult? color;
  final BodyResult? body;

  const AnalysisHistoryResult({
    required this.color,
    required this.body,
  });

  factory AnalysisHistoryResult.fromJson(Map<String, dynamic> json) {
    final colorJson = json['color'] as Map<String, dynamic>?;
    final bodyJson = json['body'] as Map<String, dynamic>?;

    return AnalysisHistoryResult(
      color: colorJson != null ? ColorResult.fromJson(colorJson) : null,
      body: bodyJson != null ? BodyResult.fromJson(bodyJson) : null,
    );
  }
}
