/// Outfit Repository — Gọi API F3 và parse response.
///
/// Tuân thủ:
///   - mobile-flutter #2: Abstract class + Implementation
///   - mobile-flutter #3: Repository Pattern — data layer tách biệt
///   - Tính năng #15: F1+F2→F3 flow — xử lý lỗi "chưa phân tích"
import 'package:dio/dio.dart';
import '../../../core/network/api_response.dart';
import '../domain/outfit_result.dart';


/// Interface — mock được khi test
abstract class OutfitRepository {
  /// Gợi ý 6 outfit dựa trên F1+F2 đã phân tích
  Future<OutfitResult> getRecommendations({
    String occasion = 'daily',
    String gender = 'any',
  });

  /// Chi tiết 1 outfit
  Future<OutfitDetail> getOutfitDetail(int outfitId);
}


/// Implementation gọi API thật
class OutfitRepositoryImpl implements OutfitRepository {
  final Dio _dio;

  OutfitRepositoryImpl(this._dio);

  @override
  Future<OutfitResult> getRecommendations({
    String occasion = 'daily',
    String gender = 'any',
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/outfits/recommend',
        queryParameters: {
          'occasion': occasion,
          'gender': gender,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => OutfitResult.fromJson(json),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error ?? 'Lỗi không xác định');
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<OutfitDetail> getOutfitDetail(int outfitId) async {
    try {
      final response = await _dio.get(
        '/api/v1/outfits/$outfitId',
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => OutfitDetail.fromJson(json),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error ?? 'Không tìm thấy outfit');
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Map DioException → Exception có message tiếng Việt rõ ràng
  /// Tính năng #34: Error handling toàn diện
  Exception _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final detail = e.response?.data?['detail'];

    // ─── F1+F2 chưa hoàn thành (Tính năng #15) ───
    if (statusCode == 400 && detail is Map) {
      final message = detail['message'] as String? ?? '';
      final missing = detail['missing'] as List? ?? [];

      if (missing.contains('color') && missing.contains('body')) {
        return MissingAnalysisException(
          'Bạn cần phân tích cả màu sắc và dáng người trước khi xem gợi ý.',
          missingColor: true,
          missingBody: true,
        );
      }
      if (missing.contains('color')) {
        return MissingAnalysisException(
          'Bạn cần phân tích màu sắc cá nhân (F1) trước.',
          missingColor: true,
        );
      }
      if (missing.contains('body')) {
        return MissingAnalysisException(
          'Bạn cần phân tích dáng người (F2) trước.',
          missingBody: true,
        );
      }
      return Exception(message);
    }

    // ─── Lỗi chung ───
    switch (statusCode) {
      case 404:
        return Exception('Không tìm thấy trang phục.');
      case 503:
        return Exception('Hệ thống đang bận. Vui lòng thử lại sau.');
      default:
        return Exception('Lỗi kết nối. Kiểm tra mạng và thử lại.');
    }
  }
}


/// Exception đặc biệt — UI xử lý để hiện prompt chuyển sang F1/F2
class MissingAnalysisException implements Exception {
  final String message;
  final bool missingColor;
  final bool missingBody;

  MissingAnalysisException(
    this.message, {
    this.missingColor = false,
    this.missingBody = false,
  });

  @override
  String toString() => message;
}
