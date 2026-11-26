@TestOn('browser')
library;

// ignore: deprecated_member_use
import 'dart:html' as html;
import 'dart:convert';

import 'package:betterwaifu_prompt_builder/clothing_part_glyph.dart';
import 'package:betterwaifu_prompt_builder/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shared options and outfit sections retain independent state',
      (tester) async {
    final oldErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().startsWith(
          'ListTile background color or ink splashes may be invisible.')) {
        return;
      }
      oldErrorHandler?.call(details);
    };
    addTearDown(() => FlutterError.onError = oldErrorHandler);
    await tester.binding.setSurfaceSize(const Size(1440, 1050));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    html.window.localStorage['betterwaifu_prompt_builder_state_v1'] =
        jsonEncode({
      'personSlots': [
        {'detailed': true, 'gender': '女性'},
      ],
      'personSelectedIds': {
        '0': [
          'outfit_phrase_eastern_fantasy_festival_red_white',
          'clothing_scope_socks_wear_removed',
        ],
      },
      'showAdult': true,
      'stepLayoutVersion': 7,
    });
    app.main();
    await tester.pumpAndSettle();
    final poseStep = find.text('5 姿勢與互動');
    await tester.ensureVisible(poseStep);
    await tester.tap(poseStep);
    await tester.pumpAndSettle();
    expect(find.text('共用鏡頭與額外動態'), findsOneWidget);

    Future<void> selectShared(String english) async {
      final label = find.byWidgetPredicate((widget) =>
          widget is Text && (widget.data?.endsWith(' · $english') ?? false));
      final chip = find.ancestor(of: label, matching: find.byType(FilterChip));
      expect(chip, findsWidgets);
      tester.widget<FilterChip>(chip.first).onSelected!(true);
      await tester.pumpAndSettle();
    }

    await selectShared('speed lines');
    await selectShared('from above');
    await selectShared('full body');
    await tester.tap(find.byIcon(Icons.vertical_align_bottom).last);
    await tester.pumpAndSettle();
    String output() => tester
        .widget<TextField>(find.byWidgetPredicate((widget) =>
            widget is TextField && widget.readOnly && widget.maxLines == 14))
        .controller!
        .text;
    expect(output(), contains('speed lines'));
    expect(output(), contains('from above'));
    expect(output(), contains('full body'));
    expect(output(), contains('white stockings'));
    expect(output(), contains('socks removed'));
    final socks = find.byWidgetPredicate((widget) =>
        widget is ClothingVisibilityButton &&
        widget.part == 'legwear' &&
        widget.label.contains('紅白東方幻想祭典服'));
    expect(socks, findsOneWidget);
    tester.widget<ClothingVisibilityButton>(socks).onPressed();
    await tester.pumpAndSettle();
    expect(output(), isNot(contains('white stockings')));
    expect(output(), isNot(contains('socks removed')));
    expect(output(), contains('red ribbon sandals'));
    tester.widget<ClothingVisibilityButton>(socks).onPressed();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(output(), contains('white stockings'));
    expect(output(), contains('socks removed'));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
