// Outfit controller for the F3 recommendation flow.
//
// Conventions:
//   - Feature #15: handle MissingAnalysisException explicitly
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../data/outfit_repository.dart';
import '../domain/outfit_result.dart';

// Providers.

/// Repository provider.
final outfitRepositoryProvider = Provider<OutfitRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return OutfitRepositoryImpl(dio);
});

/// Main controller provider for F3 recommendations.
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

// Controller.

class OutfitController extends AsyncNotifier<OutfitResult?> {
  @override
  Future<OutfitResult?> build() async {
    // Start empty until the user explicitly requests recommendations.
    return null;
  }

  /// Load 6 recommended outfits from the API.
  ///
  /// The UI calls this when entering the F3 tab.
  /// If F1/F2 are missing, the repository throws MissingAnalysisException.
  Future<void> loadRecommendations({
    String occasion = 'daily',
    String gender = 'male',
  }) async {
    // Move into loading state while fetching recommendations.
    state = const AsyncLoading();

    // Call the repository.
    state = await AsyncValue.guard(() async {
      final repo = ref.read(outfitRepositoryProvider);
      return repo.getRecommendations(occasion: occasion, gender: gender);
    });
  }

  /// Reload recommendations after the user updates prior analyses.
  Future<void> refresh({
    String occasion = 'daily',
    String gender = 'male',
  }) async {
    await loadRecommendations(occasion: occasion, gender: gender);
  }
}
