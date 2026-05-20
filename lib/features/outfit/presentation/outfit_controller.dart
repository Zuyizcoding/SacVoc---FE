/// Outfit Controller — Riverpod AsyncNotifier cho F3.
///
/// Tuân thủ:
///   - mobile-flutter #4: AsyncNotifier — 3 state: data / loading / error
///   - mobile-flutter #3: Gọi Repository, KHÔNG gọi Dio trực tiếp
///   - Tính năng #15: Xử lý MissingAnalysisException đặc biệt
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/outfit_repository.dart';
import '../domain/outfit_result.dart';
import '../../../core/network/dio_client.dart';


// ═══════════════════════════════════════════════
// PROVIDERS — Dependency Injection chuỗi
// ═══════════════════════════════════════════════

/// Repository provider — inject DioClient
final outfitRepositoryProvider = Provider<OutfitRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return OutfitRepositoryImpl(dio);
});

/// Controller provider — quản lý state F3 recommendations
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


// ═══════════════════════════════════════════════
// CONTROLLER — AsyncNotifier
// ═══════════════════════════════════════════════

class OutfitController extends AsyncNotifier<OutfitResult?> {
  @override
  Future<OutfitResult?> build() async {
    // Khởi tạo null — chờ user nhấn "Xem gợi ý"
    return null;
  }

  /// Gọi API lấy 6 outfit gợi ý
  ///
  /// UI gọi hàm này khi user vào tab F3.
  /// Tính năng #15: Nếu chưa phân tích F1/F2 → MissingAnalysisException
  ///   → UI bắt exception này để hiện dialog hướng dẫn.
  Future<void> loadRecommendations({
    String occasion = 'daily',
    String gender = 'any',
  }) async {
    // Chuyển sang loading state
    state = const AsyncLoading();

    // Gọi API
    state = await AsyncValue.guard(() async {
      final repo = ref.read(outfitRepositoryProvider);
      return repo.getRecommendations(occasion: occasion, gender: gender);
    });
  }

  /// Refresh — gọi lại API (VD: sau khi phân tích lại F1/F2)
  Future<void> refresh({
    String occasion = 'daily',
    String gender = 'any',
  }) async {
    await loadRecommendations(occasion: occasion, gender: gender);
  }
}
