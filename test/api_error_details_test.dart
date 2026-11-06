import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sac_voc/core/network/api_error_details.dart';

void main() {
  test('reads API failure envelope and numeric legacy code', () {
    final error = ApiErrorDetails.fromBody({
      'error': 'server message',
      'error_code': 503,
    });
    expect(error.message, 'server message');
    expect(error.code, '503');
  });

  test('reads FastAPI detail without losing its message', () {
    final error = ApiErrorDetails.fromException(DioException(
      requestOptions: RequestOptions(path: '/'),
      response: Response(
        requestOptions: RequestOptions(path: '/'),
        data: {
          'detail': {
            'message': 'photo too small',
            'error_code': 'PHOTO_TOO_SMALL'
          }
        },
      ),
    ));
    expect(error.message, 'photo too small');
    expect(error.code, 'PHOTO_TOO_SMALL');
  });

  test('handles string detail and absent error payload', () {
    expect(ApiErrorDetails.fromBody({'detail': 'busy'}).message, 'busy');
    final error = ApiErrorDetails.fromException(
      DioException(requestOptions: RequestOptions(path: '/')),
    );
    expect(error.message, isNull);
    expect(error.code, isNull);
  });
}
