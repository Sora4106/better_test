import 'package:betterwaifu_prompt_builder/clothing_part_glyph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('round clothing glyph toggles and marks the hidden state',
      (tester) async {
    var visible = true;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => ClothingVisibilityButton(
            part: 'top',
            label: '上衣 · Top',
            visible: visible,
            onPressed: () => setState(() => visible = !visible),
          ),
        ),
      ),
    ));

    final button = find.byType(IconButton);
    final glyph = find.byType(ClothingPartGlyph);
    expect(find.text('上衣 · Top'), findsNothing);
    expect(tester.widget<IconButton>(button).style?.shape?.resolve({}),
        isA<CircleBorder>());
    expect(tester.widget<ClothingPartGlyph>(glyph).strikeColor, isNull);

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(button).isSelected, isFalse);
    expect(tester.widget<ClothingPartGlyph>(glyph).strikeColor, isNotNull);

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(button).isSelected, isTrue);
    expect(tester.widget<ClothingPartGlyph>(glyph).strikeColor, isNull);
  });
}
