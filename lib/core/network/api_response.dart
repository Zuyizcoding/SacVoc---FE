/// Envelope API; đọc được cả mã lỗi chuỗi hiện tại và mã số của payload cũ.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? errorCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.errorCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool,
      data: json['data'] != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
      errorCode: json['error_code']?.toString(),
    );
  }
}
