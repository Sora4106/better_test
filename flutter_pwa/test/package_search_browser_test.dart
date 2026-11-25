@TestOn('browser')
library;

import 'package:betterwaifu_prompt_builder/attached_outfit_reference_data.dart';
import 'package:betterwaifu_prompt_builder/clothing_part_glyph.dart';
import 'package:betterwaifu_prompt_builder/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
