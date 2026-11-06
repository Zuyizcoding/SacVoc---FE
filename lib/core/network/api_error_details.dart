import 'package:dio/dio.dart';

/// Đọc hai định dạng lỗi của API hiện tại, giữ nguyên ưu tiên của từng nguồn.
class ApiErrorDetails {
  final String? message;
  final String? code;

  const ApiErrorDetails({this.message, this.code});

  static String? _text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;

  static String? _detailMessage(Object? detail) {
    if (detail is Map) {
      return _text(detail['message']) ?? _text(detail['error']);
    }
    return _text(detail);
  }

  factory ApiErrorDetails.fromBody(Map<String, dynamic> body) {
    final detail = body['detail'];
    return ApiErrorDetails(
      message: _text(body['error']) ?? _detailMessage(detail),
      code:
          (body['error_code'] ?? (detail is Map ? detail['error_code'] : null))
              ?.toString()
              .trim(),
    );
  }

  factory ApiErrorDetails.fromException(DioException error) {
    final body = error.response?.data;
    if (body is! Map<String, dynamic>) return const ApiErrorDetails();
    final parsed = ApiErrorDetails.fromBody(body);
    return ApiErrorDetails(
      message: _detailMessage(body['detail']) ?? _text(body['error']),
      code: parsed.code,
    );
  }
}
