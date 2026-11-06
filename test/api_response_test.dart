import 'package:flutter_test/flutter_test.dart';
import 'package:sac_voc/core/network/api_response.dart';

void main() {
  for (final code in <Object?>['RECOMMENDATION_NOT_READY', 503, null]) {
    test('API accepts error code $code without a cast failure', () {
      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        {'success': false, 'data': null, 'error_code': code},
        (json) => json,
      );
      expect(response.errorCode, code?.toString());
    });
  }
}
