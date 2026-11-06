// Controller phân tích ảnh — quản lý state Loading/Success/Error.
//
//   - Widget chỉ hiển thị (Dumb Widget), logic đẩy về Controller
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/analysis_repository.dart';
import '../domain/analysis_history_result.dart';
import '../domain/body_result.dart';
import '../domain/color_result.dart';

// ──────────────────────────────────────────────
// Color Analysis Controller (F1)
// ──────────────────────────────────────────────

/// State cho Color Analysis — AsyncValue tự xử lý Loading/Data/Error
final colorAnalysisProvider =
    AsyncNotifierProvider<ColorAnalysisController, ColorResult?>(
  ColorAnalysisController.new,
);

class ColorAnalysisController extends AsyncNotifier<ColorResult?> {
  @override
  Future<ColorResult?> build() async {
    // Khởi tạo null — chưa phân tích
    return null;
  }

  /// Gửi ảnh selfie đi phân tích.
  ///
  /// UI gọi: ref.read(colorAnalysisProvider.notifier).analyzeImage(file)
  // UI listen: ref.watch(colorAnalysisProvider) → AsyncValue<ColorResult?>
  ///   - AsyncLoading → hiển thị shimmer/spinner
  ///   - AsyncData    → hiển thị ColorResultScreen
  ///   - AsyncError   → hiển thị ErrorView với message tiếng Việt
  Future<void> analyzeImage(File imageFile) async {
    // Đặt state = loading → UI tự hiển thị loading
    state = const AsyncValue.loading();

    final nextState = await AsyncValue.guard(() async {
      final repository = ref.read(analysisRepositoryProvider);
      return repository.analyzeColor(imageFile);
    });

    state = nextState;

    // Invalidate history so "Xem lại kết quả" always shows the latest result.
    if (nextState.hasValue && nextState.value != null) {
      ref.invalidate(analysisHistoryProvider);
    }
  }

  /// Reset kết quả — cho phép phân tích lại
  void reset() {
    state = const AsyncValue.data(null);
  }
}

// ──────────────────────────────────────────────
// Body Analysis Controller (F2)
// ──────────────────────────────────────────────

/// State cho Body Analysis
final bodyAnalysisProvider =
    AsyncNotifierProvider<BodyAnalysisController, BodyResult?>(
  BodyAnalysisController.new,
);

class BodyAnalysisController extends AsyncNotifier<BodyResult?> {
  @override
  Future<BodyResult?> build() async {
    return null;
  }

  /// Gửi ảnh toàn thân đi phân tích.
  Future<void> analyzeImage(File imageFile) async {
    state = const AsyncValue.loading();

    final nextState = await AsyncValue.guard(() async {
      final repository = ref.read(analysisRepositoryProvider);
      return repository.analyzeBody(imageFile);
    });

    state = nextState;

    if (nextState.hasValue && nextState.value != null) {
      ref.invalidate(analysisHistoryProvider);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// ──────────────────────────────────────────────
// History Viewer Controller (F1 + F2)
// ──────────────────────────────────────────────

/// State cho History Viewer — AsyncValue tự xử lý Loading/Data/Error
final analysisHistoryProvider =
    AsyncNotifierProvider<AnalysisHistoryController, AnalysisHistoryResult?>(
  AnalysisHistoryController.new,
);

class AnalysisHistoryController extends AsyncNotifier<AnalysisHistoryResult?> {
  @override
  Future<AnalysisHistoryResult?> build() async {
    final repository = ref.read(analysisRepositoryProvider);
    return repository.getHistory();
  }

  /// Refresh lịch sử — gọi lại API
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(analysisRepositoryProvider);
      return repository.getHistory();
    });
  }
}
