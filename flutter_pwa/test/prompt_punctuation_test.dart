import 'package:betterwaifu_prompt_builder/prompt_punctuation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserves decimals and uses ordinary punctuation as separators', () {
    final parts = splitPromptText(
      '(blue eyes:1.25). (light:-0.75)；extra',
    );
    expect(parts, ['(blue eyes:1.25)', ' (light:-0.75)；extra']);
    expect(
      splitPromptText('first. second。third; fourth\nfifth', splitCommas: true),
      ['first', ' second', 'third', ' fourth', 'fifth'],
    );
    expect(
      splitPromptText('(.5), (eyes: .75), 12.50, word.42', splitCommas: true),
      ['(.5)', ' (eyes: .75)', ' 12.50', ' word', '42'],
    );
  });

  test('does not split commas inside natural pose fragments', () {
    expect(
      splitPromptText('pose, tilt:1.25. smile, gaze:0.75'),
      ['pose, tilt:1.25', ' smile, gaze:0.75'],
    );
  });
}
