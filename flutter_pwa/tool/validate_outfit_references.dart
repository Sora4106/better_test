import '../lib/clothing_taxonomy.dart';
import '../lib/blue_outfit_reference_data.dart';
import '../lib/catalog_data.dart';
import '../lib/elsword_job_outfit_data.dart';
import '../lib/object_catalog_data.dart';
import '../lib/outfit_reference_catalog.dart';

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
  'pastel blue',
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
  String characterKey(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  final ageSensitive = RegExp(
    r'\b(cute|short|slim|baby|child|children|kid|kids|teen|teenage|minor|underage|loli|shota)\b|\b(school|student) uniform\b|\bserafuku\b',
    caseSensitive: false,
  );
  void validatePromptTerm(String context, String? value) {
    const moderationSafeCompounds = {
      // This is an exact Danbooru clothing tag, safe despite containing
      // the word "short".
      'short sleeves',
    };
    if (value != null &&
        !moderationSafeCompounds.contains(value.toLowerCase()) &&
        ageSensitive.hasMatch(value)) {
      problems.add('$context: age-sensitive prompt term "$value".');
    }
  }

  final ids = outfitReferencePresets.map((preset) => preset.id).toList();
  if (outfitReferencePresets.isEmpty || blueOutfitReferencePresets.isEmpty) {
    problems.add('Outfit reference catalogs must not be empty.');
  }
  if (ids.toSet().length != ids.length) {
    problems.add('Preset IDs are not unique.');
  }
  for (final tag in elswordJobVisualDetailTags) {
    if (!elswordJobDetailGroups.contains(tag.group)) {
      problems.add('${tag.id}: unknown Elsword detail group "${tag.group}".');
    }
    if (tag.zh.trim().isEmpty || tag.en.trim().isEmpty) {
      problems.add('${tag.id}: Elsword detail is missing bilingual text.');
    }
  }
  final knownEquipmentTagIds = <String>{
    ...objectCatalogTags.map((tag) => tag.id),
    ...elswordJobWeaponTags.map((tag) => tag.id),
  };
  for (final tag in elswordJobWeaponTags) {
    if (tag.group != '物件' ||
        !tag.id.startsWith('obj_fantasy_elsword_') ||
        tag.zh.trim().isEmpty ||
        tag.en.trim().isEmpty) {
      problems.add('${tag.id}: invalid Elsword class weapon data.');
    }
    validatePromptTerm('${tag.id} weapon', tag.en);
  }

  bool hasDimension(String scope, String kind, String value) {
    final kinds = kind == 'cut'
        ? const {'cut', 'upper_cut', 'lower_cut'}
        : <String>{kind};
    return clothingDimensionTags.any((tag) =>
        kinds.any(
            (candidate) => tag.group == 'clothing_scope_${scope}_$candidate') &&
        tag.en == value);
  }

  for (final preset in outfitReferencePresets) {
    if (preset.pieces.isEmpty && !preset.usesUnifiedPhrase) {
      problems.add('${preset.id}: no garment pieces.');
    }
    if (preset.usesUnifiedPhrase &&
        (preset.unifiedPhraseZh?.trim().isEmpty ?? true)) {
      problems
          .add('${preset.id}: unified outfit phrase is missing Chinese text.');
    }
    for (final phrase in preset.contextPhrases) {
      if (phrase.id.trim().isEmpty ||
          phrase.group.trim().isEmpty ||
          phrase.zh.trim().isEmpty ||
          phrase.en.trim().isEmpty) {
        problems.add('${preset.id}: incomplete outfit context phrase.');
      }
      validatePromptTerm('${preset.id} context phrase', phrase.en);
    }
    for (final ownerTag in preset.requiredCharacterTags) {
      final ownerExists = catalogCharacters.any(
        (character) =>
            characterKey(character.characterTag) == characterKey(ownerTag),
      );
      if (!ownerExists) {
        problems.add('${preset.id}: unknown owner character "$ownerTag".');
      }
    }
    if (preset.isCharacterSpecific &&
        preset.requiredCharacterLabel.trim().isEmpty) {
      problems.add('${preset.id}: missing owner character label.');
    }
    for (final detailId in preset.detailTagIds) {
      if (!clothingTaxonomyTags.any((tag) => tag.id == detailId)) {
        problems.add('${preset.id}: missing outfit detail tag "$detailId".');
      }
    }
    for (final equipmentId in preset.equipmentTagIds) {
      if (!knownEquipmentTagIds.contains(equipmentId)) {
        problems.add('${preset.id}: missing equipment tag "$equipmentId".');
      }
    }
    for (final piece in preset.pieces) {
      validatePromptTerm('${preset.id} garment', piece.garment);
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
        validatePromptTerm('${preset.id} ${entry.key}', value);
        if (value != null && !hasDimension(piece.scope, entry.key, value)) {
          problems.add('${preset.id}: missing ${piece.scope} ${entry.key} '
              '"$value".');
        }
      }
      for (final value in piece.materials) {
        validatePromptTerm('${preset.id} material', value);
        if (!hasDimension(piece.scope, 'material', value)) {
          problems.add('${preset.id}: missing ${piece.scope} material '
              '"$value".');
        }
      }
      for (final value in piece.details) {
        validatePromptTerm('${preset.id} detail', value);
        if (!hasDimension(piece.scope, 'detail', value)) {
          problems.add('${preset.id}: missing ${piece.scope} detail '
              '"$value".');
        }
      }
      for (final value in piece.patterns) {
        validatePromptTerm('${preset.id} pattern', value);
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
      validatePromptTerm('${preset.id} ${entry.key}', value);
      if (value != null &&
          !clothingOverallTags
              .any((tag) => tag.group == entry.key && tag.en == value)) {
        problems.add('${preset.id}: missing ${entry.key} "$value".');
      }
    }
  }

  final elementalMaster = outfitReferencePresets
      .where((preset) =>
          preset.id == 'taxonomy_costume_elsword_aisha_elemental_master')
      .toList();
  if (elementalMaster.length != 1) {
    problems.add('Missing Aisha Elemental Master outfit reference.');
  } else {
    final preset = elementalMaster.single;
    const expectedContextIds = {'identity', 'official_design', 'head_profile'};
    final contextIds = preset.contextPhrases.map((phrase) => phrase.id).toSet();
    if (!contextIds.containsAll(expectedContextIds) ||
        contextIds.length != expectedContextIds.length) {
      problems.add(
          '${preset.id}: expected identity, official-design, and head-profile phrases.');
    }
    if (preset.featureTags.isNotEmpty) {
      problems.add(
          '${preset.id}: class profile must not use generic feature tags.');
    }
    final clothingPhrase = preset.unifiedPhraseEn?.toLowerCase() ?? '';
    if (clothingPhrase.contains('official outfit') ||
        clothingPhrase.contains('elsword aisha elemental master')) {
      problems.add('${preset.id}: class context leaked into clothing phrase.');
    }
  }

  // Every canonical Aisha second / third-job reference follows the same
  // class-scoped output contract as Elemental Master: job name and official
  // design stay ahead of the head profile, while the outfit phrase contains
  // only clothing. This keeps a previous job's hairstyle from leaking into a
  // newly selected Aisha class.
  const expectedAishaClassIdentities = <String, String>{
    'taxonomy_costume_elsword_aisha_elemental_master':
        'elemental_master, elemental master aisha',
    'taxonomy_costume_elsword_aisha_aether_sage': 'elsword, aether_sage',
    'taxonomy_costume_elsword_aisha_void_princess': 'elsword, void_princess',
    'taxonomy_costume_elsword_aisha_oz_sorcerer': 'elsword, oz_sorcerer',
    'taxonomy_costume_elsword_aisha_dimension_witch':
        'elsword, dimension_witch',
    'taxonomy_costume_elsword_aisha_metamorphy': 'elsword, metamorphy',
    'taxonomy_costume_elsword_aisha_mystic_alchemist':
        'elsword, mystic_alchemist',
    'taxonomy_costume_elsword_aisha_lord_azoth': 'elsword, lord_azoth',
  };
  for (final entry in expectedAishaClassIdentities.entries) {
    final matching = outfitReferencePresets
        .where((preset) => preset.id == entry.key)
        .toList(growable: false);
    if (matching.length != 1) {
      problems.add('Missing canonical Aisha class reference "${entry.key}".');
      continue;
    }
    final preset = matching.single;
    final phrasesById = {
      for (final phrase in preset.contextPhrases) phrase.id: phrase,
    };
    const expectedContextIds = {'identity', 'official_design', 'head_profile'};
    if (!phrasesById.keys.toSet().containsAll(expectedContextIds) ||
        phrasesById.length != expectedContextIds.length) {
      problems.add('${preset.id}: incomplete canonical Aisha class context.');
    }
    if (phrasesById['identity']?.en != entry.value) {
      problems.add('${preset.id}: unexpected canonical job identity phrase.');
    }
    if ((phrasesById['head_profile']?.en.trim().isEmpty ?? true)) {
      problems.add('${preset.id}: missing canonical Aisha head profile.');
    }
    if (preset.featureTags.isNotEmpty) {
      problems.add(
          '${preset.id}: class profile must not use generic feature tags.');
    }
    final clothingPhrase = preset.unifiedPhraseEn?.toLowerCase() ?? '';
    if (clothingPhrase.contains('official outfit') ||
        clothingPhrase.contains('elsword aisha')) {
      problems.add('${preset.id}: class context leaked into clothing phrase.');
    }
  }

  // The verified Aisha 2nd/3rd-job document is intentionally checked as
  // complete ordered phrases. This prevents old hand-written alternatives
  // from silently returning to a class after future catalog edits.
  const expectedAishaNames = <String, String>{
    'taxonomy_costume_elsword_aisha_elemental_master': '愛莎・元素魔導轉職服裝',
    'taxonomy_costume_elsword_aisha_aether_sage': '愛莎・乙太魔導轉職服裝',
    'taxonomy_costume_elsword_aisha_void_princess': '愛莎・虛無公主轉職服裝',
    'taxonomy_costume_elsword_aisha_oz_sorcerer': '愛莎・奧茲魔導轉職服裝',
    'taxonomy_costume_elsword_aisha_dimension_witch': '愛莎・次元魔女轉職服裝',
    'taxonomy_costume_elsword_aisha_metamorphy': '愛莎・星光魔女轉職服裝',
    'taxonomy_costume_elsword_aisha_mystic_alchemist': '愛莎・真理術士轉職服裝',
    'taxonomy_costume_elsword_aisha_lord_azoth': '愛莎・萬靈賢者轉職服裝',
  };
  const expectedAishaHeadProfiles = <String, String>{
    'taxonomy_costume_elsword_aisha_aether_sage':
        'purple hair, very long purple hair, long hair, sidelocks, ahoge, purple eyes',
    'taxonomy_costume_elsword_aisha_void_princess':
        'purple hair, purple eyes, high twintails, compact twintails, outward-curving twintails, black hair ribbons',
    'taxonomy_costume_elsword_aisha_oz_sorcerer':
        'purple eyes, very long purple hair, very long straight hair, loose hair, hair worn down, smooth straight hair, naturally flowing hair',
    'taxonomy_costume_elsword_aisha_dimension_witch':
        'purple hair, purple eyes, twintails, curled twintails, ringlets, pink hair ribbon, two-tone hair bow',
    'taxonomy_costume_elsword_aisha_metamorphy':
        'pink-purple hair, purple hair, gradient hair, very long hair, long twintails, drill hair, curled twintails, drill sidelocks, pink eyes, purple eyes, star-shaped eye highlights, star hair ornament',
    'taxonomy_costume_elsword_aisha_mystic_alchemist':
        'purple hair, gradient purple hair, purple eyes, low twintails, long hair, ahoge, hair bow',
    'taxonomy_costume_elsword_aisha_lord_azoth':
        'light purple hair, very long light purple hair, high ponytail, sidelocks, ahoge, light purple eyes, pale violet eyes, white pupils, monocle',
  };
  const expectedAishaOutfitProfiles = <String, String>{
    'taxonomy_costume_elsword_aisha_aether_sage':
        'white and purple dress, dark purple dress, layered dress, sleeveless dress, collared dress, cross-laced clothing, white collar, pink necktie, collar pendant, red gemstone, off-shoulder white coat, open coat, puffy sleeves, white gloves, white thigh boots, amulet, earrings, elemental magic, aether magic',
    'taxonomy_costume_elsword_aisha_void_princess':
        'magenta cropped top, cross motif, white shrug, purple juliet sleeves, detached sleeves, very wide sleeves, frilled sleeves, purple armband, magenta armband, exposed midriff, purple miniskirt, zipper skirt, magenta belt, black ribbon, waist cape, long split waist panels, purple garter straps, purple thigh boots, zipper boots, dark magic',
    'taxonomy_costume_elsword_aisha_oz_sorcerer':
        'large witch hat, oversized witch hat, wide-brim witch hat, crooked pointed witch hat, dark purple witch hat, magenta accents, zipper on witch hat, zipper-mouth hat, zipper-like mouth opening, visible zipper teeth, black and purple mage outfit, dark purple halter top, zipper shirt, bare shoulders, exposed midriff, cross-laced straps, detached purple sleeves, wide sleeves, zipper sleeves, frilled open skirt, long split skirt, asymmetrical legwear, dark purple thighhighs, zipper legwear, angular opening on one thighhigh, dark purple shorts, dark purple high heel footwear, zipper footwear, dark magic',
    'taxonomy_costume_elsword_aisha_dimension_witch':
        'white halter dress, criss-cross halter, open dress, purple collar, large back bow, maroon back bow, bare shoulders, detached sleeves, white sleeves, sleeve garters, pink trim, white gloves, purple miniskirt, layered clothing, magenta belt, loose belt, talisman, white socks, ankle cuffs, white cross-laced boots, black ankle straps, energy magic, space-time magic, dimension magic',
    'taxonomy_costume_elsword_aisha_metamorphy':
        'magical girl, white dress, pink and purple dress, two-tone dress, frilled dress, pleated skirt, pink gradient skirt, purple gemstone, purple bowtie, large bow, detached collar, pink frilled collar, bare shoulders, white elbow gloves, coattails, gold trim, thigh boots, bow legwear, white bows, high heels, winged footwear, energy magic, space-time magic, star magic',
    'taxonomy_costume_elsword_aisha_mystic_alchemist':
        'white dress shirt, white shirt, dark purple bow, black bowtie, red gemstone, black corset, large black belt, red ribbon, purple stole, purple long sleeves, folded cuffs, black gloves, frills, layered purple skirt, multicolored skirt, alchemy vials, potion bottles, flask accessories, belt pouches, purple fold-over boots, frilled footwear, block heels, gold trim, gold soles, homunculus motif, alchemy',
    'taxonomy_costume_elsword_aisha_lord_azoth':
        "black choker, necklace, jewelry, white sleeveless shirt, partially open shirt, bare shoulders, gold chain, gold stole, large loose belt, alchemy vials, potion bottles, high-waisted black pants, double-breasted waist design, gold trim, black coat on shoulders, floating coat, two-sided coat, detached gradient sleeves, black and white gloves, bracelets, thigh pouch, black fold-over boots, high heels, gold soles, footwear cutouts, alchemy, philosopher's stone",
  };
  const expectedAishaWeaponProfiles = <String, String>{
    'obj_fantasy_elsword_aisha_aether_sage_weapon':
        'magic staff, floating magic book',
    'obj_fantasy_elsword_aisha_void_princess_weapon':
        'dark magic staff, axe-shaped magic staff, black and white demon-shaped staff head, purple magical core',
    'obj_fantasy_elsword_aisha_oz_sorcerer_weapon':
        'large dark magic staff, axe-headed staff, battle-axe-shaped staff head, purple magical core',
    'obj_fantasy_elsword_aisha_dimension_witch_weapon': 'staff',
    'obj_fantasy_elsword_aisha_metamorphy_weapon': 'magical staff',
    'obj_fantasy_elsword_aisha_mystic_alchemist_weapon':
        'alchemy staff, alchemy book',
    'obj_fantasy_elsword_aisha_lord_azoth_weapon':
        "alchemy staff, philosopher's stone motif, floating alchemy book",
  };
  final presetsById = {
    for (final preset in outfitReferencePresets) preset.id: preset,
  };
  for (final entry in expectedAishaNames.entries) {
    final preset = presetsById[entry.key];
    if (preset == null || preset.name != entry.value) {
      problems.add('${entry.key}: unexpected Traditional Chinese class name.');
    }
  }
  for (final entry in expectedAishaHeadProfiles.entries) {
    final preset = presetsById[entry.key];
    final matches = preset == null
        ? const <String>[]
        : preset.contextPhrases
            .where((phrase) => phrase.id == 'head_profile')
            .map((phrase) => phrase.en)
            .toList(growable: false);
    final actual = matches.isEmpty ? '' : matches.first;
    if (actual != entry.value) {
      problems
          .add('${entry.key}: head profile differs from verified Aisha data.');
    }
  }
  for (final entry in expectedAishaOutfitProfiles.entries) {
    final actual = presetsById[entry.key]?.unifiedPhraseEn;
    if (actual != entry.value) {
      problems.add(
          '${entry.key}: outfit profile differs from verified Aisha data.');
    }
  }
  final weaponsById = <String, String>{
    for (final tag in elswordJobWeaponTags) tag.id: tag.en,
  };
  for (final entry in expectedAishaWeaponProfiles.entries) {
    if (weaponsById[entry.key] != entry.value) {
      problems.add(
          '${entry.key}: weapon profile differs from verified Aisha data.');
    }
  }
  final directCanonicalAishaIds = elswordJobOutfitTags
      .map((tag) => tag.id)
      .where(expectedAishaNames.containsKey)
      .toList(growable: false);
  if (directCanonicalAishaIds.isNotEmpty) {
    problems.add(
        'Canonical Aisha classes still expose retired direct outfit tags.');
  }

  if (problems.isNotEmpty) {
    throw StateError(problems.join('\n'));
  }
  print('Validated ${outfitReferencePresets.length} outfit references.');
}
