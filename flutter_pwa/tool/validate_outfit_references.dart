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
    'taxonomy_costume_elsword_aisha_aether_sage':
        'aether_sage, aether sage aisha',
    'taxonomy_costume_elsword_aisha_void_princess':
        'void_princess, void princess aisha',
    'taxonomy_costume_elsword_aisha_oz_sorcerer':
        'oz_sorcerer, oz sorcerer aisha',
    'taxonomy_costume_elsword_aisha_dimension_witch':
        'dimension_witch, dimension witch aisha',
    'taxonomy_costume_elsword_aisha_metamorphy': 'metamorphy, metamorphy aisha',
    'taxonomy_costume_elsword_aisha_mystic_alchemist':
        'mystic_alchemist, mystic alchemist aisha',
    'taxonomy_costume_elsword_aisha_lord_azoth': 'lord_azoth, lord azoth aisha',
  };
  final actualAishaClassIds = outfitReferencePresets
      .where(
          (preset) => preset.id.startsWith('taxonomy_costume_elsword_aisha_'))
      .map((preset) => preset.id)
      .toSet();
  final expectedAishaClassIds = expectedAishaClassIdentities.keys.toSet();
  if (actualAishaClassIds.length != 8 ||
      !actualAishaClassIds.containsAll(expectedAishaClassIds) ||
      !expectedAishaClassIds.containsAll(actualAishaClassIds)) {
    problems.add(
      'Aisha must expose exactly the eight verified second/third-job references.',
    );
  }
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
  const aishaFaceProfile =
      '(oval face:1.15), (slightly elongated facial proportions:1.15), '
      '(tapered jawline:1.12), (defined nose bridge:1.12), '
      '(defined lower eyelids:1.1), (refined lips:1.1), '
      '(subtle cheekbone definition:1.08), '
      '(refined facial features:1.1), detailed face, highly detailed face, '
      'detailed eyes, consistent facial proportions, facial detail emphasis';
  final expectedAishaHeadProfiles = <String, String>{
    'taxonomy_costume_elsword_aisha_elemental_master':
        'purple hair, long hair, low twintails, ahoge, purple eyes, x-shaped hairclip, $aishaFaceProfile',
    'taxonomy_costume_elsword_aisha_aether_sage':
        'purple hair, very long purple hair, long hair, hair worn down, sidelocks, ahoge, purple eyes, ornate hair ornament, $aishaFaceProfile',
    'taxonomy_costume_elsword_aisha_void_princess':
        'purple eyes, ((purple hair:1.25)), high twintails, compact twintails, flared twintails, outward-curving twintails, tied twin tails, black hair bows, $aishaFaceProfile',
    'taxonomy_costume_elsword_aisha_oz_sorcerer':
        'purple eyes, very long purple hair, very long straight hair, loose hair, hair worn down, smooth straight hair, naturally flowing hair, $aishaFaceProfile',
    'taxonomy_costume_elsword_aisha_dimension_witch':
        'purple hair, purple eyes, twintails, curled twintails, ringlets, pink hair ribbon, two-tone hair bow, $aishaFaceProfile',
    'taxonomy_costume_elsword_aisha_metamorphy':
        'pink-purple hair, purple hair, gradient hair, very long hair, long twintails, drill hair, curled twintails, drill sidelocks, pink eyes, purple eyes, star-shaped eye highlights, star hair ornament, $aishaFaceProfile',
    'taxonomy_costume_elsword_aisha_mystic_alchemist':
        'purple hair, gradient purple hair, low twintails, long hair, ahoge, purple eyes, hair bow, $aishaFaceProfile',
    'taxonomy_costume_elsword_aisha_lord_azoth':
        'light purple hair, very long light purple hair, high ponytail, sidelocks, ahoge, light purple eyes, pale violet eyes, white pupils, monocle, $aishaFaceProfile',
  };
  const expectedAishaOutfitProfiles = <String, String>{
    'taxonomy_costume_elsword_aisha_elemental_master':
        '(elemental master outfit:1.25), (white hooded coat:1.2), white coat, hood down, long white coat, white capelet, hooded capelet, purple trim, pink trim, large pink bow, pink bowtie, chest ribbon, gemstone brooch, large jewel on chest, dark purple turtleneck sweater, black and purple bodice, fitted bodice, black vest, white wide sleeves, oversized sleeves, brown gloves, leather gloves, purple pleated miniskirt, pink accents, black thighhighs, pink markings on thighhighs, white thigh strap, white ankle boots, white and pink boots, jeweled boots, hanging crystal ornaments, crystal tassels, magical accessories, emblem, fantasy mage outfit, elemental mage, magic user, official Elsword style',
    'taxonomy_costume_elsword_aisha_aether_sage':
        '(aether sage outfit:1.25), white and purple dress, dark purple dress, layered dress, sleeveless dress, collared dress, cross-laced clothing, white collar, pink necktie, collar pendant, red gemstone, off-shoulder white coat, open coat, puffy sleeves, wide sleeves, white gloves, white thigh boots, amulet, earrings, gold trim, purple crystal ornaments, elemental magic, aether magic, fantasy mage outfit, official Elsword style',
    'taxonomy_costume_elsword_aisha_void_princess':
        '(void princess outfit:1.3), black and purple mage outfit, magenta accents, cropped mage top, exposed midriff, fitted top, central gem ornament, chest cross motif, black choker, detached sleeves, very wide sleeves, long flared sleeves, black and purple sleeves, magenta circular sleeve patterns, white inner frill at sleeve cuffs, large circular waist ornament, waist belt, above-knee layered skirt, split skirt panels, long trailing side panels, black and purple lower outfit, magenta trim, waist ribbons, hanging ornaments, black thighhighs, symmetrical legwear, magenta vertical stripe on thighhighs, black and purple fantasy shoes, white beast-face shoe ornaments, white pointed shoe decorations, magenta gem accents, pointed footwear, dark magic, purple magic aura, black magic particles, official Elsword style',
    'taxonomy_costume_elsword_aisha_oz_sorcerer':
        '(oz sorcerer outfit:1.25), large witch hat, oversized witch hat, wide-brim witch hat, crooked pointed witch hat, dark purple witch hat, magenta accents, zipper on witch hat, zipper-mouth hat, zipper-like mouth opening, visible zipper teeth, black and purple mage outfit, dark purple halter top, zipper shirt, bare shoulders, exposed midriff, cross-laced straps, detached purple sleeves, wide sleeves, zipper sleeves, frilled open skirt, long split skirt, asymmetrical legwear, dark purple thighhighs, zipper legwear, angular opening on one thighhigh, dark purple shorts, dark purple high heel footwear, zipper footwear, dark magic, official Elsword style',
    'taxonomy_costume_elsword_aisha_dimension_witch':
        '(dimension witch outfit:1.25), white halter dress, criss-cross halter, open dress, purple collar, large back bow, maroon back bow, bare shoulders, detached sleeves, white sleeves, sleeve garters, pink trim, white gloves, purple miniskirt, layered clothing, magenta belt, loose belt, talisman, white socks, ankle cuffs, white cross-laced boots, black ankle straps, energy magic, space-time magic, dimension magic, magical girl outfit, official Elsword style',
    'taxonomy_costume_elsword_aisha_metamorphy':
        '(metamorphy outfit:1.25), magical girl, white dress, pink and purple dress, two-tone dress, frilled dress, pleated skirt, pink gradient skirt, purple gemstone, purple bowtie, large bow, detached collar, pink frilled collar, bare shoulders, white elbow gloves, coattails, gold trim, thigh boots, bow legwear, white bows, high heels, winged footwear, energy magic, space-time magic, star magic, official Elsword style',
    'taxonomy_costume_elsword_aisha_mystic_alchemist':
        '(mystic alchemist outfit:1.25), white dress shirt, white shirt, dark purple bow, black bowtie, red gemstone, black corset, large black belt, red ribbon, purple stole, purple long sleeves, folded cuffs, black gloves, frills, layered purple skirt, multicolored skirt, alchemy vials, potion bottles, flask accessories, belt pouches, purple fold-over boots, frilled footwear, block heels, gold trim, gold soles, homunculus motif, alchemy, official Elsword style',
    'taxonomy_costume_elsword_aisha_lord_azoth':
        "(lord azoth outfit:1.25), black choker, necklace, jewelry, white sleeveless shirt, partially open shirt, bare shoulders, gold chain, gold stole, large loose belt, alchemy vials, potion bottles, high-waisted black pants, double-breasted waist design, gold trim, black coat on shoulders, floating coat, two-sided coat, detached gradient sleeves, black and white gloves, bracelets, thigh pouch, black fold-over boots, high heels, gold soles, footwear cutouts, alchemy, philosopher's stone, official Elsword style",
  };
  const expectedAishaWeaponProfiles = <String, String>{
    'obj_fantasy_elsword_aisha_aether_sage_weapon':
        'magic staff, floating magic book',
    'obj_fantasy_elsword_aisha_void_princess_weapon':
        'dark magic axe staff, compact axe staff, black weapon, white demon-face ornament, purple magical core, pink crystal ornaments, black and purple axe head',
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
  const aishaOutfitWeaponPairs = <String, String>{
    'taxonomy_costume_elsword_aisha_aether_sage':
        'obj_fantasy_elsword_aisha_aether_sage_weapon',
    'taxonomy_costume_elsword_aisha_void_princess':
        'obj_fantasy_elsword_aisha_void_princess_weapon',
    'taxonomy_costume_elsword_aisha_oz_sorcerer':
        'obj_fantasy_elsword_aisha_oz_sorcerer_weapon',
    'taxonomy_costume_elsword_aisha_dimension_witch':
        'obj_fantasy_elsword_aisha_dimension_witch_weapon',
    'taxonomy_costume_elsword_aisha_metamorphy':
        'obj_fantasy_elsword_aisha_metamorphy_weapon',
    'taxonomy_costume_elsword_aisha_mystic_alchemist':
        'obj_fantasy_elsword_aisha_mystic_alchemist_weapon',
    'taxonomy_costume_elsword_aisha_lord_azoth':
        'obj_fantasy_elsword_aisha_lord_azoth_weapon',
  };
  for (final entry in aishaOutfitWeaponPairs.entries) {
    final outfit = presetsById[entry.key]?.unifiedPhraseEn ?? '';
    final weapon = expectedAishaWeaponProfiles[entry.value] ?? '';
    for (final fragment in weapon.split(', ')) {
      if (fragment.isNotEmpty && outfit.contains(fragment)) {
        problems.add(
            '${entry.key}: weapon phrase "$fragment" must remain optional.');
      }
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

  // Rose, Laby, and Lithia have one selectable character entry plus exactly
  // eight second/third-job cards each. Keep the class identity / official
  // design / head profile blocks together, just like the canonical Aisha
  // records, so class hair and outfit information cannot leak between paths.
  const expectedElswordClassJobs = <String, Set<String>>{
    'Rose': {
      'storm_trooper',
      'tempest_burster',
      'crimson_rose',
      'black_massacre',
      'freyja',
      'minerva',
      'optimus',
      'prime_operator',
    },
    'Laby': {
      'rumble_pumn',
      'eternity_winner',
      'shining_romantica',
      'radiant_soul',
      'daydreamer',
      'nisha_labyrinth',
      'punky_poppet',
      'twins_picaro',
    },
    'Lithia': {
      'mighty_miner',
      'gembliss',
      'greedy_wonder',
      'avarice',
      'rima_clavis',
      'achlys',
      'cynical_sneer',
      'mischief',
    },
  };
  const expectedElswordCharacterTags = <String, String>{
    'Rose': 'rose_(elsword)',
    'Laby': 'laby_(elsword)',
    'Lithia': 'lithia_beryl_(elsword)',
  };
  for (final entry in expectedElswordClassJobs.entries) {
    final character = entry.key;
    final prefix = 'taxonomy_costume_elsword_${character.toLowerCase()}_';
    final expectedIds = entry.value.map((job) => '$prefix$job').toSet();
    final actual = outfitReferencePresets
        .where((preset) => preset.id.startsWith(prefix))
        .toList(growable: false);
    final actualIds = actual.map((preset) => preset.id).toSet();
    if (actual.length != 8 ||
        !actualIds.containsAll(expectedIds) ||
        !expectedIds.containsAll(actualIds)) {
      problems.add('$character must expose exactly its eight second/third-job '
          'outfit references.');
    }
    final ownerTag = expectedElswordCharacterTags[character]!;
    if (!catalogCharacters.any((item) => item.characterTag == ownerTag)) {
      problems.add('$character: missing selectable character tag "$ownerTag".');
    }
    for (final preset in actual) {
      const requiredContextIds = {
        'identity',
        'official_design',
        'head_profile'
      };
      final contextIds =
          preset.contextPhrases.map((phrase) => phrase.id).toSet();
      if (!contextIds.containsAll(requiredContextIds) ||
          contextIds.length != requiredContextIds.length) {
        problems.add('${preset.id}: incomplete canonical class context.');
      }
      if (preset.featureTags.isNotEmpty) {
        problems.add('${preset.id}: class head profile must stay contextual.');
      }
      if (!preset.requiredCharacterTags.contains(ownerTag)) {
        problems.add('${preset.id}: missing owner character tag "$ownerTag".');
      }
      final clothingPhrase = preset.unifiedPhraseEn?.toLowerCase() ?? '';
      if (clothingPhrase.contains('official outfit') ||
          clothingPhrase.contains('elsword ${character.toLowerCase()}')) {
        problems
            .add('${preset.id}: class context leaked into clothing phrase.');
      }
    }
  }

  if (problems.isNotEmpty) {
    throw StateError(problems.join('\n'));
  }
  print('Validated ${outfitReferencePresets.length} outfit references.');
}
