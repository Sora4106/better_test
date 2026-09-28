import 'dart:io';

void main() {
  final source = File('lib/main.dart').readAsStringSync();
  const requiredSnippets = <String>[
    "'pants_color', '褲子顏色'",
    "'shorts_color', '短褲顏色'",
    "'skirt_color', '裙子顏色'",
    "'pants_trim_color', '褲子邊線色'",
    "'shorts_trim_color', '短褲邊線色'",
    "'skirt_trim_color', '裙子邊線色'",
    "'pants' => '褲子顏色'",
    "'shorts' => '短褲顏色'",
    "'skirt' => '裙子顏色'",
    "'pants' => '褲子邊線色'",
    "'shorts' => '短褲邊線色'",
    "'skirt' => '裙子邊線色'",
  ];
  final missing = requiredSnippets.where((value) => !source.contains(value));
  if (missing.isNotEmpty) {
    throw StateError(
      'Lower-body colour channels are incomplete: ${missing.join(', ')}',
    );
  }

  const obsoleteGenerators = <String>[
    "'bottom_color', '下身顏色'",
    "'bottom_shade_color', '下身顏色'",
    "'bottom_trim_color', '下身邊線色'",
  ];
  final activeLegacy =
      obsoleteGenerators.where((value) => source.contains(value));
  if (activeLegacy.isNotEmpty) {
    throw StateError(
      'Shared lower-body colour generators returned: ${activeLegacy.join(', ')}',
    );
  }

  print(
      'Lower-body colour channels OK: pants, shorts, and skirt are separate.');
}
