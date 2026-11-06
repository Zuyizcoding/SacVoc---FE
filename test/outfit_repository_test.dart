import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sac_voc/features/outfit/data/outfit_repository.dart';

void main() {
  for (final missing in [
    <String>['color'],
    <String>['body'],
    <String>['color', 'body']
  ]) {
    test('preserves missing analysis guidance: $missing', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
        handler.reject(DioException(
          requestOptions: request,
          response: Response(requestOptions: request, statusCode: 400, data: {
            'detail': {'message': 'missing profile', 'missing': missing},
          }),
          type: DioExceptionType.badResponse,
        ));
      }));
      addTearDown(() => dio.close());
      await expectLater(
        OutfitRepositoryImpl(dio).getRecommendations(),
        throwsA(isA<MissingAnalysisException>()
            .having((e) => e.missingColor, 'missingColor',
                missing.contains('color'))
            .having(
                (e) => e.missingBody, 'missingBody', missing.contains('body'))),
      );
    });
  }
}
