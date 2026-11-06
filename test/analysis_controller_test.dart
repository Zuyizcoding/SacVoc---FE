import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sac_voc/features/analysis/data/analysis_repository.dart';
import 'package:sac_voc/features/analysis/domain/analysis_history_result.dart';
import 'package:sac_voc/features/analysis/domain/body_result.dart';
import 'package:sac_voc/features/analysis/domain/color_result.dart';
import 'package:sac_voc/features/analysis/presentation/analysis_controller.dart';

import 'support/results.dart';

class FakeAnalysisRepository implements AnalysisRepository {
  final color = Completer<ColorResult>();
  final body = Completer<BodyResult>();
  AnalysisHistoryResult history =
      const AnalysisHistoryResult(color: null, body: null);

  @override
  Future<ColorResult> analyzeColor(File imageFile) async {
    final result = await color.future;
    history = AnalysisHistoryResult(color: result, body: history.body);
    return result;
  }

  @override
  Future<BodyResult> analyzeBody(File imageFile) => body.future;

  @override
  Future<AnalysisHistoryResult> getHistory() async => history;
}

void main() {
  test('color exposes loading/data and refreshes the saved profile', () async {
    final repository = FakeAnalysisRepository();
    final container = ProviderContainer(overrides: [
      analysisRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    final history = container.listen(analysisHistoryProvider, (_, __) {});
    addTearDown(history.close);
    await container.read(analysisHistoryProvider.future);
    await container.read(colorAnalysisProvider.future);

    final operation = container
        .read(colorAnalysisProvider.notifier)
        .analyzeImage(File('unused'));
    expect(container.read(colorAnalysisProvider).isLoading, isTrue);
    repository.color.complete(colorResult());
    await operation;
    expect(container.read(colorAnalysisProvider).requireValue?.subSeason,
        'Soft Autumn');
    expect(
        (await container.read(analysisHistoryProvider.future))
            ?.color
            ?.subSeason,
        'Soft Autumn');
  });

  test('body exposes an error and reset returns to the empty state', () async {
    final repository = FakeAnalysisRepository();
    final container = ProviderContainer(overrides: [
      analysisRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    await container.read(bodyAnalysisProvider.future);
    final controller = container.read(bodyAnalysisProvider.notifier);
    final operation = controller.analyzeImage(File('unused'));
    expect(container.read(bodyAnalysisProvider).isLoading, isTrue);
    repository.body.completeError(Exception('photo rejected'));
    await operation;
    expect(container.read(bodyAnalysisProvider).hasError, isTrue);
    controller.reset();
    expect(container.read(bodyAnalysisProvider).requireValue, isNull);
  });
}
