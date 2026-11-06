// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sac_voc/main.dart';
import 'package:sac_voc/features/analysis/domain/analysis_history_result.dart';
import 'package:sac_voc/features/analysis/presentation/analysis_controller.dart';

class EmptyHistoryController extends AnalysisHistoryController {
  @override
  Future<AnalysisHistoryResult?> build() async =>
      const AnalysisHistoryResult(color: null, body: null);
}

void main() {
  testWidgets('App boots smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analysisHistoryProvider.overrideWith(EmptyHistoryController.new)
        ],
        child: const SacVocApp(),
      ),
    );

    // SplashScreen schedules a delayed navigation after 2 seconds.
    // Advance time so no timers remain pending.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // App should render at least one route widget tree.
    expect(find.text('Sắc Vóc'), findsWidgets);
  });
}
