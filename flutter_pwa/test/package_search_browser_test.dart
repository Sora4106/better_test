@TestOn('browser')
library;

// ignore: deprecated_member_use
import 'dart:html' as html;
import 'dart:convert';

import 'package:betterwaifu_prompt_builder/attached_outfit_reference_data.dart';
import 'package:betterwaifu_prompt_builder/clothing_part_glyph.dart';
import 'package:betterwaifu_prompt_builder/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('manual weighted prompts keep decimal points in output',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1050));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    html.window.localStorage['betterwaifu_prompt_builder_state_v1'] =
        jsonEncode({
      'personSlots': [
        {
          'detailed': true,
          'featureExtraPositive': '(sparkling eyes:1.25). soft lighting',
          'clothingExtraPositive': '(lace dress:1.15). ribbon',
          'poseExtraPositive': '(sitting:0.75). waving',
        },
      ],
      'extraPositive': '(blue eyes:1.35). colorful. (sharp focus:.85)',
      'sharedPoseExtra': '(holding hands:1.20). standing together',
      'stepLayoutVersion': 7,
    });
    app.main();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.vertical_align_bottom).last);
    await tester.pumpAndSettle();
    final output = tester
        .widget<TextField>(find.byWidgetPredicate((widget) =>
            widget is TextField && widget.readOnly && widget.maxLines == 14))
        .controller!
        .text;
    for (final phrase in [
      '(sparkling eyes:1.25)',
      '(lace dress:1.15)',
      '(sitting:0.75)',
      '(blue eyes:1.35)',
      '(sharp focus:.85)',
      '(holding hands:1.20)',
      'colorful',
      'standing together',
    ]) {
      expect(output, contains(phrase));
    }
    expect(output, isNot(contains('eyes:1, 25')));
    expect(output.trimRight().endsWith('.'), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('indoor and outdoor scenes compose and survive reload',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1050));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    app.main();
    await tester.pumpAndSettle();

    Future<void> toggleScene(String query, String english) async {
      final search = find.byWidgetPredicate((widget) =>
          widget is TextField &&
          widget.decoration?.hintText == '搜尋中英文標籤、姿勢套件、服裝套裝…');
      await tester.ensureVisible(search);
      await tester.pump();
      await tester.enterText(search, query);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      final chip = find.ancestor(
        of: find.byWidgetPredicate((widget) =>
            widget is Text && (widget.data?.endsWith('·  $english') ?? false)),
        matching: find.byType(FilterChip),
      );
      expect(chip, findsOneWidget);
      await tester.ensureVisible(chip);
      await tester.pump();
      await tester.tap(chip);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.text('標籤可能互相衝突'), findsNothing);
      expect(tester.takeException(), isNull);
    }

    await toggleScene('bedroom', 'bedroom');
    await toggleScene('forest clearing', 'forest clearing');
    await toggleScene('bathroom', 'bathroom');
    await toggleScene('beach', 'beach');

    final raw = html.window.localStorage['betterwaifu_prompt_builder_state_v1'];
    expect(raw, isNotNull);
    final state = jsonDecode(raw!) as Map<String, dynamic>;
    final selected = (state['selectedIds'] as List).cast<String>();
    expect(
      selected,
      containsAll([
        'scene_bedroom',
        'scene_forest_clearing',
        'scene_bathroom',
        'scene_beach',
      ]),
    );

    String englishOutput() => tester
        .widget<TextField>(find.byWidgetPredicate((widget) =>
            widget is TextField && widget.readOnly && widget.maxLines == 14))
        .controller!
        .text;
    for (final phrase in ['bedroom', 'forest clearing', 'bathroom', 'beach']) {
      expect(englishOutput(), contains(phrase));
    }
    await tester.pumpWidget(const SizedBox.shrink());
    app.main();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    final outputButton = find.byIcon(Icons.vertical_align_bottom);
    expect(outputButton, findsWidgets);
    await tester.tap(outputButton.last);
    await tester.pumpAndSettle();
    for (final phrase in ['bedroom', 'forest clearing', 'bathroom', 'beach']) {
      expect(englishOutput(), contains(phrase));
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('pose package panels expand and can be searched', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1050));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    app.main();
    await tester.pumpAndSettle();

    final poseStep = find.text('5 姿勢與互動');
    await tester.ensureVisible(poseStep);
    await tester.pump();
    await tester.tap(poseStep);
    await tester.pumpAndSettle();

    final posePanel = find.text('姿勢套件（主題）');
    expect(posePanel, findsOneWidget);
    await tester.ensureVisible(posePanel);
    await tester.pump();
    await tester.tap(posePanel);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('完整姿勢套件資料庫'), findsOneWidget);

    final search = find.byWidgetPredicate((widget) =>
        widget is TextField && widget.decoration?.hintText == '用中文或英文搜尋姿勢套件…');
    expect(search, findsOneWidget);
    await tester.ensureVisible(search);
    await tester.pump();
    final sample = attachedPosePackages.firstWhere(
        (package) => package.naturalPrompt.toLowerCase().contains('kneeling'));
    await tester.enterText(search, sample.name);
    await tester.pumpAndSettle();
    expect(find.textContaining('姿勢套件 ·'), findsWidgets);
    expect(tester.takeException(), isNull);
    final pose = find.widgetWithText(ListTile, sample.name);
    expect(pose, findsOneWidget);
    await tester.ensureVisible(pose);
    await tester.pump();
    await tester.tap(pose);
    await tester.pumpAndSettle();
    expect(tester.widget<ListTile>(pose).selected, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('search applies presets and clothing glyph updates output',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1050));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    app.main();
    await tester.pumpAndSettle();

    final search = find.byWidgetPredicate((widget) =>
        widget is TextField &&
        widget.decoration?.hintText == '搜尋中英文標籤、姿勢套件、服裝套裝…');

    Future<void> searchFor(String query) async {
      await tester.ensureVisible(search);
      await tester.pump();
      await tester.enterText(search, query);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    }

    Future<void> tapVisible(Finder target) async {
      await tester.ensureVisible(target);
      await tester.pump();
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    final pose = attachedPosePackages.first;
    await searchFor(pose.name);
    final poseTile = find.widgetWithText(ListTile, pose.name);
    expect(poseTile, findsOneWidget);
    await tapVisible(poseTile);
    expect(tester.widget<ListTile>(poseTile).selected, isTrue);

    await searchFor('皇家藍 armored_boots');
    final outfit = find.widgetWithText(ListTile, '皇家騎士裝 · Royal Knight');
    expect(outfit, findsOneWidget);
    await tapVisible(outfit);
    expect(tester.widget<ListTile>(outfit).selected, isTrue);

    String englishOutput() => tester
        .widget<TextField>(find.byWidgetPredicate((widget) =>
            widget is TextField && widget.readOnly && widget.maxLines == 14))
        .controller!
        .text;

    final shoes = find.byWidgetPredicate((widget) =>
        widget is ClothingVisibilityButton && widget.part == 'footwear');
    expect(shoes, findsOneWidget);
    expect(englishOutput(), contains('armored boots'));
    await tapVisible(shoes);
    expect(tester.widget<ClothingVisibilityButton>(shoes).visible, isFalse);
    expect(englishOutput(), isNot(contains('armored boots')));
    expect(englishOutput(), contains('combat skirt'));

    await tapVisible(shoes);
    expect(tester.widget<ClothingVisibilityButton>(shoes).visible, isTrue);
    expect(englishOutput(), contains('armored boots'));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
