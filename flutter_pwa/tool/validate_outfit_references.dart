import '../lib/clothing_taxonomy.dart';
import '../lib/outfit_reference_data.dart';

const _colors = <String>{
  'black',
  'white',
  'red',
  'blue',
  'pink',
  'purple',
  'green',
  'yellow',
  'brown',
  'gray',
  'gold',
  'silver',
  'orange',
  'multicolored',
  'aqua',
  'light blue',
  'dark blue',
  'navy',
  'sky blue',
  'baby blue',
  'royal blue',
  'azure',
  'cobalt blue',
  'sapphire blue',
  'steel blue',
  'midnight blue',
  'powder blue',
  'turquoise',
  'teal',
  'light red',
  'dark red',
  'crimson',
  'scarlet',
  'maroon',
  'burgundy',
  'wine red',
  'coral',
  'light green',
  'dark green',
  'lime',
  'mint green',
  'emerald green',
  'jade green',
  'forest green',
  'olive',
  'sage green',
  'light yellow',
  'dark yellow',
  'lemon yellow',
  'mustard yellow',
  'golden',
  'amber',
  'peach',
  'salmon',
  'lavender',
  'lilac',
  'magenta',
  'hot pink',
  'light pink',
  'dark pink',
  'rose',
  'light gray',
  'dark gray',
  'slate gray',
  'pewter',
  'charcoal',
  'jet black',
  'ebony',
  'off-black',
  'ivory',
  'cream',
  'beige',
  'light brown',
  'dark brown',
  'coffee',
  'tan',
  'camel',
  'chocolate',
  'chestnut',
  'khaki',
  'taupe',
  'copper',
  'rose gold',
};

void main() {
  final problems = <String>[];
  final ids = outfitReferencePresets.map((preset) => preset.id).toList();
  if (outfitReferencePresets.length != 30) {
    problems
        .add('Expected 30 presets, found ${outfitReferencePresets.length}.');
  }
  if (ids.toSet().length != ids.length) {
    problems.add('Preset IDs are not unique.');
  }

  bool hasDimension(String scope, String kind, String value) =>
      clothingDimensionTags.any((tag) =>
          tag.group == 'clothing_scope_${scope}_$kind' && tag.en == value);

  for (final preset in outfitReferencePresets) {
    if (preset.pieces.isEmpty) {
      problems.add('${preset.id}: no garment pieces.');
    }
    for (final piece in preset.pieces) {
      final hasGarment = clothingTaxonomyTags.any((tag) =>
              tag.en == piece.garment &&
              tag.id.startsWith('taxonomy_${piece.scope}_')) ||
          (piece.scope == 'socks' && piece.garment == 'socks');
      if (!hasGarment) {
        problems.add('${preset.id}: missing ${piece.scope} garment '
            '"${piece.garment}".');
      }
      for (final entry in <String, String?>{
        'cut': piece.cut,
        'fit': piece.fit,
        'length': piece.length,
      }.entries) {
        final value = entry.value;
        if (value != null && !hasDimension(piece.scope, entry.key, value)) {
          problems.add('${preset.id}: missing ${piece.scope} ${entry.key} '
              '"$value".');
        }
      }
      for (final value in piece.materials) {
        if (!hasDimension(piece.scope, 'material', value)) {
          problems.add('${preset.id}: missing ${piece.scope} material '
              '"$value".');
        }
      }
      for (final value in piece.details) {
        if (!hasDimension(piece.scope, 'detail', value)) {
          problems.add('${preset.id}: missing ${piece.scope} detail '
              '"$value".');
        }
      }
      for (final value in piece.patterns) {
        if (!hasDimension(piece.scope, 'pattern', value)) {
          problems.add('${preset.id}: missing ${piece.scope} pattern '
              '"$value".');
        }
      }
      for (final color in [piece.mainColor, piece.secondaryColor]) {
        if (color != null && !_colors.contains(color)) {
          problems.add('${preset.id}: unknown color "$color".');
        }
      }
      for (final style in piece.styles) {
        if (!(piece.scope == 'socks' && style == 'tabi socks')) {
          problems.add('${preset.id}: unvalidated legacy style "$style".');
        }
      }
    }

    for (final entry in <String, String?>{
      '服裝・主要風格': preset.mainStyle,
      '服裝・子風格': preset.subStyle,
      '服裝・氣質': preset.mood,
      '服裝・場合': preset.occasion,
    }.entries) {
      final value = entry.value;
      if (value != null &&
          !clothingOverallTags
              .any((tag) => tag.group == entry.key && tag.en == value)) {
        problems.add('${preset.id}: missing ${entry.key} "$value".');
      }
    }
  }

  if (problems.isNotEmpty) {
    throw StateError(problems.join('\n'));
  }
  print('Validated ${outfitReferencePresets.length} outfit references.');
}
