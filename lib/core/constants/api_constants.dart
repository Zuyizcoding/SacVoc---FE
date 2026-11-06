/// Hằng số API — endpoint base URL và paths.
///
class ApiConstants {
  ApiConstants._(); // Không cho phép tạo instance

  /// Truyền --dart-define=API_BASE_URL=... khi dùng thiết bị thật hoặc server khác.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Endpoints
  static const String analyzeColor = '/api/v1/analyze/color';
  static const String analyzeBody = '/api/v1/analyze/body';
  static const String analyzeHistory = '/api/v1/analyze/history';
  static const String outfitRecommend = '/api/v1/outfits/recommend';
  static String outfitDetail(int id) => '/api/v1/outfits/$id';
  static const String health = '/health';
}
