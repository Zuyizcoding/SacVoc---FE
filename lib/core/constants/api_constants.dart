/// Hằng số API — endpoint base URL và paths.
///
/// Tuân thủ: mobile-flutter #3 — tập trung URL, không hard-code trong Repository.
class ApiConstants {
  ApiConstants._(); // Không cho phép tạo instance

  /// Base URL — đổi khi deploy lên Railway
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator → localhost

  /// Endpoints
  static const String analyzeColor = '/api/v1/analyze/color';
  static const String analyzeBody = '/api/v1/analyze/body';
  static const String outfitRecommend = '/api/v1/outfits/recommend';
  static const String health = '/health';
}
