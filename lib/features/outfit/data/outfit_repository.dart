/// Outfit Repository â€” Gá»i API F3 vÃ  parse response.
///
/// TuÃ¢n thá»§:
///   - mobile-flutter #2: Abstract class + Implementation
///   - mobile-flutter #3: Repository Pattern â€” data layer tÃ¡ch biá»‡t
///   - TÃ­nh nÄƒng #15: F1+F2â†’F3 flow â€” xá»­ lÃ½ lá»—i "chÆ°a phÃ¢n tÃ­ch"
import 'package:dio/dio.dart';
import '../../../core/network/api_response.dart';
import '../domain/outfit_result.dart';


/// Interface â€” mock Ä‘Æ°á»£c khi test
abstract class OutfitRepository {
  /// Gá»£i Ã½ 6 outfit dá»±a trÃªn F1+F2 Ä‘Ã£ phÃ¢n tÃ­ch
  Future<OutfitResult> getRecommendations({
    String occasion = 'daily',
    String gender = 'male',
  });

  /// Chi tiáº¿t 1 outfit
  Future<OutfitDetail> getOutfitDetail(int outfitId);
}


/// Implementation gá»i API tháº­t
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
        throw Exception(apiResponse.error ?? 'Lá»—i khÃ´ng xÃ¡c Ä‘á»‹nh');
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
        throw Exception(apiResponse.error ?? 'KhÃ´ng tÃ¬m tháº¥y outfit');
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Map DioException â†’ Exception cÃ³ message tiáº¿ng Viá»‡t rÃµ rÃ ng
  /// TÃ­nh nÄƒng #34: Error handling toÃ n diá»‡n
  Exception _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final detail = e.response?.data?['detail'];

    // â”€â”€â”€ F1+F2 chÆ°a hoÃ n thÃ nh (TÃ­nh nÄƒng #15) â”€â”€â”€
    if (statusCode == 400 && detail is Map) {
      final message = detail['message'] as String? ?? '';
      final missing = detail['missing'] as List? ?? [];

      if (missing.contains('color') && missing.contains('body')) {
        return MissingAnalysisException(
          'Báº¡n cáº§n phÃ¢n tÃ­ch cáº£ mÃ u sáº¯c vÃ  dÃ¡ng ngÆ°á»i trÆ°á»›c khi xem gá»£i Ã½.',
          missingColor: true,
          missingBody: true,
        );
      }
      if (missing.contains('color')) {
        return MissingAnalysisException(
          'Báº¡n cáº§n phÃ¢n tÃ­ch mÃ u sáº¯c cÃ¡ nhÃ¢n (F1) trÆ°á»›c.',
          missingColor: true,
        );
      }
      if (missing.contains('body')) {
        return MissingAnalysisException(
          'Báº¡n cáº§n phÃ¢n tÃ­ch dÃ¡ng ngÆ°á»i (F2) trÆ°á»›c.',
          missingBody: true,
        );
      }
      return Exception(message);
    }

    // â”€â”€â”€ Lá»—i chung â”€â”€â”€
    switch (statusCode) {
      case 404:
        return Exception('KhÃ´ng tÃ¬m tháº¥y trang phá»¥c.');
      case 503:
        return Exception('Há»‡ thá»‘ng Ä‘ang báº­n. Vui lÃ²ng thá»­ láº¡i sau.');
      default:
        return Exception('Lá»—i káº¿t ná»‘i. Kiá»ƒm tra máº¡ng vÃ  thá»­ láº¡i.');
    }
  }
}


/// Exception Ä‘áº·c biá»‡t â€” UI xá»­ lÃ½ Ä‘á»ƒ hiá»‡n prompt chuyá»ƒn sang F1/F2
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

