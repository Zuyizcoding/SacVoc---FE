/// Outfit Repository - call F3 API and parse response.
///
/// Conventions:
///   - mobile-flutter #2: Abstract class + Implementation
///   - mobile-flutter #3: Repository Pattern - separate data layer
///   - Feature #15: F1+F2 -> F3 flow - handle "not analyzed yet" cases
import 'package:dio/dio.dart';
import '../../../core/network/api_response.dart';
import '../domain/outfit_result.dart';


/// Interface - easy to mock in tests
abstract class OutfitRepository {
  /// Recommend 6 outfits based on completed F1 + F2 analyses.
  Future<OutfitResult> getRecommendations({
    String occasion = 'daily',
    String gender = 'male',
  });

  /// Load details for a single outfit.
  Future<OutfitDetail> getOutfitDetail(int outfitId);
}


/// Production implementation backed by the API.
class OutfitRepositoryImpl implements OutfitRepository {
  final Dio _dio;

  OutfitRepositoryImpl(this._dio);

  @override
  Future<OutfitResult> getRecommendations({
    String occasion = 'daily',
    String gender = 'male',
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

  /// Map DioException to user-friendly Vietnamese messages.
  /// Feature #34: centralized error handling.
  Exception _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final detail = e.response?.data?['detail'];

    // F1 + F2 not completed yet.
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

    // Generic API failures.
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


/// Special exception so the UI can guide users back to F1/F2 first.
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

