import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sac_voc/features/outfit/data/outfit_repository.dart';
import 'package:sac_voc/features/outfit/domain/outfit_result.dart';
import 'package:sac_voc/features/outfit/presentation/outfit_controller.dart';

class FakeOutfitRepository implements OutfitRepository {
  Completer<OutfitResult> pending = Completer<OutfitResult>();
  String? requestedOccasion;
  @override
  Future<OutfitResult> getRecommendations(
      {String occasion = 'daily', String gender = 'male'}) {
    requestedOccasion = occasion;
    return pending.future;
  }

  @override
  Future<OutfitDetail> getOutfitDetail(int outfitId) =>
      throw UnimplementedError();
}

void main() {
  test('outfit preserves typed missing-analysis errors and can reload',
      () async {
    final repository = FakeOutfitRepository();
    final container = ProviderContainer(overrides: [
      outfitRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    expect(await container.read(outfitControllerProvider.future), isNull);
    final controller = container.read(outfitControllerProvider.notifier);
    final failed = controller.loadRecommendations();
    expect(container.read(outfitControllerProvider).isLoading, isTrue);
    repository.pending.completeError(
        MissingAnalysisException('missing color', missingColor: true));
    await failed;
    expect(container.read(outfitControllerProvider).error,
        isA<MissingAnalysisException>());
    repository.pending = Completer<OutfitResult>();
    final reload = controller.refresh(occasion: 'work');
    repository.pending.complete(const OutfitResult(
        queryUsed: 'query', querySource: 'test', outfits: []));
    await reload;
    expect(repository.requestedOccasion, 'work');
    expect(container.read(outfitControllerProvider).requireValue?.queryUsed,
        'query');
  });
}
