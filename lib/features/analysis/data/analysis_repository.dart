// Repository phân tích ảnh — giao tiếp với Backend API.
//
// Tuân thủ:
//   - mobile-flutter #3: Abstract class → dễ Mock test
//   - mobile-flutter #3: UI KHÔNG gọi HTTP trực tiếp — luôn qua Repository
//   - Tính năng #3: Device ID đã inject qua Dio interceptor (dio_client.dart)
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

  String? _asCleanString(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  String? _bodyErrorMessage(Map<String, dynamic> json) {
    final error = _asCleanString(json['error']);
    if (error != null) {
      return error;
    }

    final detail = json['detail'];
    if (detail is Map<String, dynamic>) {
      return _asCleanString(detail['message']) ?? _asCleanString(detail['error']);
    }
    return _asCleanString(detail);
  }

  String? _bodyErrorCode(Map<String, dynamic> json) {
    final direct = json['error_code'];
    if (direct != null) {
      return direct.toString().trim();
    }

    final detail = json['detail'];
    if (detail is Map<String, dynamic> && detail['error_code'] != null) {
      return detail['error_code'].toString().trim();
    }
    return null;
  }

  String? _responseDetail(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is Map<String, dynamic>) {
        final message = _asCleanString(detail['message']) ?? _asCleanString(detail['error']);
        if (message != null) {
          return message;
        }
      }
      final detailString = _asCleanString(detail);
      if (detailString != null) {
        return detailString;
      }
      final bodyError = _asCleanString(data['error']);
      if (bodyError != null) {
        return bodyError;
      }
    }
    return null;
  }

  String? _responseErrorCode(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final direct = data['error_code'];
      if (direct != null) {
        return direct.toString().trim();
      }

      final detail = data['detail'];
      if (detail is Map<String, dynamic> && detail['error_code'] != null) {
        return detail['error_code'].toString().trim();
      }
    }
    return null;
  }

  Exception _exceptionFromTypedError({
    String? errorCode,
    String? message,
    int? statusCode,
  }) {
    switch (errorCode) {
      case 'PHOTO_UNREADABLE':
      case 'PHOTO_TOO_SMALL':
      case 'PHOTO_TOO_FAR':
      case 'NO_PERSON_DETECTED':
      case 'MULTIPLE_PEOPLE_DETECTED':
      case 'CLOTHING_TOO_WIDE':
      case 'AI_INCOMPLETE':
      case 'AI_INVALID_RESULT':
      case 'AI_OVERLOADED':
      case 'ANALYSIS_FAILED':
      case 'RECOMMENDATION_NOT_READY':
        return Exception(message ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.');
      default:
        break;
    }

    switch (statusCode) {
      case 400:
        return Exception(
          message ??
              'Không phân tích được ảnh hiện tại. '
                  'Bạn thử ảnh sáng hơn, rõ hơn và thấy toàn thân nhé.',
        );
      case 422:
        return Exception(
          message ??
              'Ảnh chưa đủ rõ để phân tích chính xác. '
                  'Bạn có thể thử ảnh khác rõ hơn.',
        );
      case 429:
        return Exception(message ?? 'Hệ thống AI đang quá tải. Vui lòng thử lại sau.');
      case 503:
        return Exception(message ?? 'AI đang phản hồi chậm hoặc quá tải. Vui lòng thử lại sau.');
      default:
        return Exception(message ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  Exception _exceptionFromResponseBody(
    Map<String, dynamic> json, {
    String fallbackMessage = 'Phân tích thất bại',
  }) {
    return _exceptionFromTypedError(
      errorCode: _bodyErrorCode(json),
      message: _bodyErrorMessage(json) ?? fallbackMessage,
      statusCode: null,
    );
  }

  Exception _mapDioError(DioException e) {
    final detail = _responseDetail(e);
    final errorCode = _responseErrorCode(e);

    if (e.type == DioExceptionType.receiveTimeout) {
      return Exception(
        detail ??
            'AI đang phản hồi chậm hoặc quá tải ở máy chủ. '
                'Vui lòng thử lại sau 30-60 giây.',
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return Exception(
        detail ??
            'Không kết nối được tới máy chủ phân tích. '
                'Bạn kiểm tra backend đang chạy rồi thử lại nhé.',
      );
    }

    return _exceptionFromTypedError(
      errorCode: errorCode,
      message: detail,
      statusCode: e.response?.statusCode,
    );
  }

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

      throw _exceptionFromResponseBody(json);
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

      throw _exceptionFromResponseBody(json);
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
}

// ──────────────────────────────────────────────
// Riverpod Provider (mobile-flutter #2)
// ──────────────────────────────────────────────
final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AnalysisRepositoryImpl(dio);
});


