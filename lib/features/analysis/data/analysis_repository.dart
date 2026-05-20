/// Repository phân tích ảnh — giao tiếp với Backend API.
///
/// Tuân thủ:
///   - mobile-flutter #3: Abstract class → dễ Mock test
///   - mobile-flutter #3: UI KHÔNG gọi HTTP trực tiếp — luôn qua Repository
///   - Tính năng #3: Device ID đã inject qua Dio interceptor (dio_client.dart)
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../domain/analysis_history_result.dart';
import '../domain/color_result.dart';
import '../domain/body_result.dart';

// ──────────────────────────────────────────────
// Abstract Repository (mobile-flutter #3)
// ──────────────────────────────────────────────
abstract class AnalysisRepository {
  /// F1 — Phân tích màu sắc từ ảnh selfie
  Future<ColorResult> analyzeColor(File imageFile);

  /// F2 — Phân tích dáng người từ ảnh toàn thân
  Future<BodyResult> analyzeBody(File imageFile);

  /// Lịch sử F1 + F2 — màn "Xem lại kết quả"
  Future<AnalysisHistoryResult> getHistory();
}

// ──────────────────────────────────────────────
// Implementation (gọi API thật)
// ──────────────────────────────────────────────
class AnalysisRepositoryImpl implements AnalysisRepository {
  final Dio _dio;

  AnalysisRepositoryImpl(this._dio);

  @override
  Future<ColorResult> analyzeColor(File imageFile) async {
    try {
      // Gửi ảnh dạng multipart — Device ID đã tự inject qua interceptor
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'selfie.jpg',
        ),
      });

      final response = await _dio.post(
        ApiConstants.analyzeColor,
        data: formData,
      );

      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true && json['data'] != null) {
        return ColorResult.fromJson(json['data'] as Map<String, dynamic>);
      }

      throw Exception(json['error'] ?? 'Phân tích thất bại');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<BodyResult> analyzeBody(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'fullbody.jpg',
        ),
      });

      final response = await _dio.post(
        ApiConstants.analyzeBody,
        data: formData,
      );

      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true && json['data'] != null) {
        return BodyResult.fromJson(json['data'] as Map<String, dynamic>);
      }

      throw Exception(json['error'] ?? 'Phân tích thất bại');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<AnalysisHistoryResult> getHistory() async {
    try {
      final response = await _dio.get(ApiConstants.analyzeHistory);
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true && json['data'] != null) {
        return AnalysisHistoryResult.fromJson(
          json['data'] as Map<String, dynamic>,
        );
      }

      return const AnalysisHistoryResult(color: null, body: null);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Map DioException → thông báo tiếng Việt (Tính năng #34)
  Exception _mapDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return Exception(
          'Không phân tích được ảnh hiện tại. '
          'Bạn thử ảnh sáng hơn, rõ hơn và thấy toàn thân nhé.',
        );

      case 422:
        return Exception(
          'Ảnh chưa đủ rõ để phân tích chính xác. '
          'Bạn có thể thử ảnh khác rõ hơn.',
        );
      case 429:
        final detail = e.response?.data?['detail'];
        if (detail is String && detail.isNotEmpty) {
          return Exception(detail);
        }
        return Exception('Hệ thống AI đang quá tải. Vui lòng thử lại sau.');
      case 503:
        return Exception('AI đang bận. Thử lại sau 5 giây.');
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return Exception('Kết nối chậm. Kiểm tra internet và thử lại.');
        }
        return Exception('Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
  }
}

// ──────────────────────────────────────────────
// Riverpod Provider (mobile-flutter #2)
// ──────────────────────────────────────────────
final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AnalysisRepositoryImpl(dio);
});


