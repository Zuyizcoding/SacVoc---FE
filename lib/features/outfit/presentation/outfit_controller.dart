/// Outfit Controller â€” Riverpod AsyncNotifier cho F3.
///
/// TuÃ¢n thá»§:
///   - mobile-flutter #4: AsyncNotifier â€” 3 state: data / loading / error
///   - mobile-flutter #3: Gá»i Repository, KHÃ”NG gá»i Dio trá»±c tiáº¿p
///   - TÃ­nh nÄƒng #15: Xá»­ lÃ½ MissingAnalysisException Ä‘áº·c biá»‡t
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/outfit_repository.dart';
import '../domain/outfit_result.dart';
import '../../../core/network/dio_client.dart';


// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// PROVIDERS â€” Dependency Injection chuá»—i
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

/// Repository provider â€” inject DioClient
final outfitRepositoryProvider = Provider<OutfitRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return OutfitRepositoryImpl(dio);
});

/// Controller provider â€” quáº£n lÃ½ state F3 recommendations
final outfitControllerProvider =
    AsyncNotifierProvider<OutfitController, OutfitResult?>(
  OutfitController.new,
);

/// Controller cho outfit detail (theo ID)
final outfitDetailProvider =
    FutureProvider.family<OutfitDetail, int>((ref, outfitId) async {
  final repo = ref.watch(outfitRepositoryProvider);
  return repo.getOutfitDetail(outfitId);
});


// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// CONTROLLER â€” AsyncNotifier
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class OutfitController extends AsyncNotifier<OutfitResult?> {
  @override
  Future<OutfitResult?> build() async {
    // Khá»Ÿi táº¡o null â€” chá» user nháº¥n "Xem gá»£i Ã½"
    return null;
  }

  /// Gá»i API láº¥y 6 outfit gá»£i Ã½
  ///
  /// UI gá»i hÃ m nÃ y khi user vÃ o tab F3.
  /// TÃ­nh nÄƒng #15: Náº¿u chÆ°a phÃ¢n tÃ­ch F1/F2 â†’ MissingAnalysisException
  ///   â†’ UI báº¯t exception nÃ y Ä‘á»ƒ hiá»‡n dialog hÆ°á»›ng dáº«n.
  Future<void> loadRecommendations({
    String occasion = 'daily',
    String gender = 'male',
  }) async {
    // Chuyá»ƒn sang loading state
    state = const AsyncLoading();

    // Gá»i API
    state = await AsyncValue.guard(() async {
      final repo = ref.read(outfitRepositoryProvider);
      return repo.getRecommendations(occasion: occasion, gender: gender);
    });
  }

  /// Refresh â€” gá»i láº¡i API (VD: sau khi phÃ¢n tÃ­ch láº¡i F1/F2)
  Future<void> refresh({
    String occasion = 'daily',
    String gender = 'male',
  }) async {
    await loadRecommendations(occasion: occasion, gender: gender);
  }
}

