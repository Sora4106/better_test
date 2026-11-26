@TestOn('browser')
library;

// ignore: deprecated_member_use
import 'dart:html' as html;
import 'dart:convert';

import 'package:betterwaifu_prompt_builder/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('emotion stages stay per person and preserve other selections',
      (tester) async {
    final previousErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      // The existing decorated ListTiles emit this debug-only ink warning.
      if (details.exceptionAsString().startsWith(
          'ListTile background color or ink splashes may be invisible.')) {
        return;
      }
      previousErrorHandler?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousErrorHandler);
    await tester.binding.setSurfaceSize(const Size(1440, 1050));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    html.window.localStorage['betterwaifu_prompt_builder_state_v1'] =
        jsonEncode({
      'personSlots': [
        {'detailed': true},
        {'detailed': true},
      ],
      'personSelectedIds': {
        '0': ['pose_head_chin_raised', 'adult_emotion_stage_shy'],
        '1': ['adult_emotion_stage_afterglow'],
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

    Finder stage(int person, String stage) => find.byKey(
        ValueKey('adult-emotion-stage:$person:adult_emotion_stage_$stage'));
    expect(tester.widget<ChoiceChip>(stage(0, 'shy')).selected, isTrue);
    expect(tester.widget<ChoiceChip>(stage(1, 'afterglow')).selected, isTrue);
    tester.widget<ChoiceChip>(stage(0, 'intense')).onSelected!(true);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    // Surface asynchronous widget errors even when the app installs its own
    // FlutterError handler.
    expect(tester.takeException(), isNull);
    final state = jsonDecode(
            html.window.localStorage['betterwaifu_prompt_builder_state_v1']!)
        as Map<String, dynamic>;
    final people = state['personSelectedIds'] as Map<String, dynamic>;
    expect(people['0'], contains('pose_head_chin_raised'));
    expect(people['0'], contains('adult_emotion_stage_intense'));
    expect(people['0'], isNot(contains('adult_emotion_stage_shy')));
    expect(people['1'], contains('adult_emotion_stage_afterglow'));
    await tester.tap(find.byIcon(Icons.vertical_align_bottom).last);
    await tester.pumpAndSettle();
    final output = tester
        .widget<TextField>(find.byWidgetPredicate((widget) =>
            widget is TextField && widget.readOnly && widget.maxLines == 14))
        .controller!
        .text;
    expect(output, contains('heavy blush, closed eyes, open mouth'));
    expect(output, contains('relaxed expression, soft smile'));
    expect(output, contains('chin raised'));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
