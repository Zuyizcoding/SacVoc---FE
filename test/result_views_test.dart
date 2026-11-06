import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sac_voc/core/theme/app_theme.dart';
import 'package:sac_voc/features/analysis/presentation/widgets/body_result_view.dart';
import 'package:sac_voc/features/analysis/presentation/widgets/color_result_view.dart';

import 'support/results.dart';

void main() {
  for (final source in ['live', 'degraded_demo']) {
    testWidgets('shared color result displays palette and source $source',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
            body: SingleChildScrollView(
                child: ColorResultView(result: colorResult(source: source)))),
      ));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Soft Autumn'), findsOneWidget);
      expect(find.text('Ưu tiên olive.'), findsOneWidget);
      expect(find.textContaining('dự phòng'),
          source == 'live' ? findsNothing : findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shared body result displays quality and source $source',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
            body: SingleChildScrollView(
                child: BodyResultView(result: bodyResult(source: source)))),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Rectangle'), findsOneWidget);
      expect(find.text('Chất lượng ảnh đầu vào'), findsOneWidget);
      expect(find.textContaining('dự phòng'),
          source == 'live' ? findsNothing : findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
