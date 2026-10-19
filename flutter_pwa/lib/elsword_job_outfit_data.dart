import 'catalog_data.dart';
import 'outfit_reference_data.dart';

/// Picker categories for phrases that describe a particular Elsword class
/// design. They remain part of the costume prompt block, but are displayed by
/// their visual role so users can find and remove them.
const elswordJobDetailOutfitGroup = '艾爾之光・職業套裝';
const elswordJobDetailUpperGroup = '艾爾之光・上身細節';
const elswordJobDetailLowerGroup = '艾爾之光・下身與腿部';
const elswordJobDetailFootwearGroup = '艾爾之光・鞋襪細節';
const elswordJobDetailHeadGroup = '艾爾之光・頭部飾品';
const elswordJobDetailTrimGroup = '艾爾之光・配色與飾邊';
const elswordJobDetailAccessoryGroup = '艾爾之光・飾品與裝置';

/// These are complete, class-scoped phrase blocks.  They are intentionally
/// outside [elswordJobDetailGroups] so they do not behave like individually
/// editable clothing dimensions after a canonical outfit is selected.
const elswordJobIdentityGroup = '艾爾之光・職業識別';
const elswordJobOfficialDesignGroup = '艾爾之光・原作服裝設定';
const elswordJobHeadFeatureGroup = '艾爾之光・職業頭部特徵';

const elswordJobContextPhraseGroups = <String>[
  elswordJobIdentityGroup,
  elswordJobOfficialDesignGroup,
  elswordJobHeadFeatureGroup,
];

const elswordJobDetailGroups = <String>[
  elswordJobDetailOutfitGroup,
  elswordJobDetailUpperGroup,
  elswordJobDetailLowerGroup,
  elswordJobDetailFootwearGroup,
  elswordJobDetailHeadGroup,
  elswordJobDetailTrimGroup,
  elswordJobDetailAccessoryGroup,
];

/// Normalises a weighted prompt fragment only for classification.  The source
/// text is never changed, so a class outfit can still preserve its original
/// weights in the final prompt.
String _elswordComparableDetail(String english) => english
    .trim()
    .toLowerCase()
    .replaceFirst(RegExp(r'^\s*\('), '')
    .replaceFirst(RegExp(r':\s*\d+(?:\.\d+)?\s*\)\s*$'), '')
    .trim();

/// Keep class-specific visual descriptions as complete phrases whenever a
/// regular one-word tag would lose the intended design detail.
String elswordJobDetailGroupFor(String english) {
  final value = _elswordComparableDetail(english);
  if (value.endsWith(' outfit') ||
      const {
        'elemental mage',
        'magic user',
        'official elsword style',
      }.contains(value)) {
    return elswordJobDetailOutfitGroup;
  }
  if (RegExp(r'\b(?:trim|pattern|markings|accents|lining)\b').hasMatch(value)) {
    return elswordJobDetailTrimGroup;
  }
  if (RegExp(r'\b(?:hat|crown|head ornament|hairclip)\b').hasMatch(value)) {
    return elswordJobDetailHeadGroup;
  }
  if (RegExp(
          r'\b(?:boots?|shoes?|thighhighs?|socks?|leg guards?|leg wraps?|thigh strap|garter straps?|legwear|footwear|ankle cuffs?)\b')
      .hasMatch(value)) {
    return elswordJobDetailFootwearGroup;
  }
  if (RegExp(r'\b(?:skirt|waist|sash|belt|pants?|shorts?)\b').hasMatch(value)) {
    return elswordJobDetailLowerGroup;
  }
  if (RegExp(
          r'\b(?:coat|cape|capelet|mantle|hood|sleeves?|bodice|vest|turtleneck|top|robe|dress|armor|jacket|gloves?|shrug)\b')
      .hasMatch(value)) {
    return elswordJobDetailUpperGroup;
  }
  return elswordJobDetailAccessoryGroup;
}

/// Each class outfit remains a single canonical prompt phrase by default, but
/// these logical keys allow its visual parts to be hidden independently after
/// applying it.  The ordered fragments themselves are kept intact below.
String _elswordOutfitSectionIdFor(String english) {
  return switch (elswordJobDetailGroupFor(english)) {
    elswordJobDetailOutfitGroup => 'silhouette',
    elswordJobDetailUpperGroup => 'upper',
    elswordJobDetailLowerGroup => 'lower',
    elswordJobDetailFootwearGroup => 'footwear',
    elswordJobDetailHeadGroup => 'head',
    elswordJobDetailTrimGroup => 'trim',
    _ => 'accessory',
  };
}

String _elswordOutfitSectionLabel(String id) => switch (id) {
      'silhouette' => '職業套裝輪廓',
      'upper' => '上身／外套',
      'lower' => '下身／裙褲',
      'footwear' => '鞋襪／腿部',
      'head' => '頭部飾品',
      'trim' => '配色／飾邊',
      _ => '飾品／裝置',
    };

/// A bilingual visual phrase that belongs inside a single class-outfit block.
/// They are deliberately editable description helpers, not claims that every
/// phrase is an exact model trigger tag.
class _ElswordStyleDetail {
  const _ElswordStyleDetail(this.zh, this.en);

  final String zh;
  final String en;
}

/// A visual starting point for one Elsword job path. Hair traits use existing
/// selectable feature tags, while [details] stay grouped with the outfit.
class _ElswordJobLook {
  const _ElswordJobLook({
    required this.palette,
    this.hairTags = const <String>[],
    this.details = const <_ElswordStyleDetail>[],
  });

  final String palette;
  final List<String> hairTags;
  final List<_ElswordStyleDetail> details;
}

class _ElswordJobOutfit {
  const _ElswordJobOutfit(
      this.characterZh, this.characterEn, this.jobZh, this.jobEn);

  /// The eight second / third-job Aisha looks have their own canonical head
  /// profile.  Keep that profile with the job reference rather than applying
  /// it as generic Aisha traits: the latter is what previously allowed one
  /// class hairstyle to remain when switching to another job.
  static const Set<String> _canonicalAishaJobs = <String>{
    'Elemental Master',
    'Aether Sage',
    'Void Princess',
    'Oz Sorcerer',
    'Dimension Witch',
    'Metamorphy',
    'Mystic Alchemist',
    'Lord Azoth',
  };

  /// The supplied Aisha class profiles deliberately share the same facial
  /// refinement anchor.  Keeping the block here prevents one class from
  /// silently drifting to an abbreviated face description while another keeps
  /// the complete Elemental Master form.
  static const String _aishaFaceProfile =
      '(oval face:1.15), (slightly elongated facial proportions:1.15), '
      '(tapered jawline:1.12), (defined nose bridge:1.12), '
      '(defined lower eyelids:1.1), (refined lips:1.1), '
      '(subtle cheekbone definition:1.08), '
      '(refined facial features:1.1), detailed face, highly detailed face, '
      'detailed eyes, consistent facial proportions, facial detail emphasis';

  final String characterZh;
  final String characterEn;
  final String jobZh;
  final String jobEn;

  String get id =>
      'taxonomy_costume_elsword_${characterEn.toLowerCase()}_${jobEn.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+$'), '')}';
  String get zh => '$characterZh・$jobZh轉職服裝';
  String get en => 'Elsword $characterEn $jobEn official class outfit';

  String get ownerCharacterTag => switch (characterEn) {
        'Aisha' => 'aisha_(elsword)',
        'Rena' => 'rena erindel',
        'Eve' => 'eve (elsword)',
        'Ara' => 'ara haan',
        'Elesis' => 'elesis (elsword)',
        'Rose' => 'rose_(elsword)',
        'Laby' => 'laby_(elsword)',
        'Lithia' => 'lithia_beryl_(elsword)',
        'Luciela' => 'luciela r. sourcream',
        _ => '',
      };

  _ElswordJobLook get look {
    final looks = switch (characterEn) {
      'Aisha' => _aishaLooks,
      'Rena' => _renaLooks,
      'Eve' => _eveLooks,
      'Ara' => _araLooks,
      'Elesis' => _elesisLooks,
      'Rose' => _roseLooks,
      'Laby' => _labyLooks,
      'Lithia' => _lithiaLooks,
      'Luciela' => _lucielaLooks,
      _ => const <String, _ElswordJobLook>{},
    };
    return looks[jobEn] ?? _fallbackLook;
  }

  List<String> get featureTags {
    // Aisha's job-specific hair/head profile belongs to the canonical class
    // phrase below. Do not select it as generic Aisha traits, otherwise a
    // prior class can leave hair or accessories behind after a class switch.
    if (usesCanonicalJobProfile) return const <String>[];
    final base = switch (characterEn) {
      'Aisha' => const ['purple hair', 'long hair', 'purple eyes'],
      'Rena' => const ['green hair', 'long hair'],
      'Eve' => const ['blonde hair', 'long hair'],
      'Ara' => const ['black hair', 'long hair'],
      'Elesis' => const ['red hair', 'long hair'],
      _ => const <String>[],
    };
    return {...base, ...look.hairTags}.toList(growable: false);
  }

  List<_ElswordStyleDetail> get visualDetails {
    // Every canonical Aisha class is emitted only from its documented phrase
    // list. Each class keeps its documented outfit-anchor weight while using
    // the same Elemental Master-style output structure.
    if (usesCanonicalAishaJobProfile) {
      return <_ElswordStyleDetail>[
        _ElswordStyleDetail(
          '$jobZh職業套裝',
          '(${_aishaJobOutfitAnchor!}:$_aishaJobOutfitWeight)',
        ),
        ...look.details,
      ];
    }
    if (usesCanonicalJobProfile) {
      return <_ElswordStyleDetail>[
        _ElswordStyleDetail(
          '$jobZh・原作職業套裝',
          '(${jobEn.toLowerCase()} outfit:1.25)',
        ),
        ...look.details,
      ];
    }
    return <_ElswordStyleDetail>[
      _ElswordStyleDetail('$jobZh職業套裝', '${jobEn.toLowerCase()} outfit'),
      ...look.details,
    ];
  }

  /// The reference-card action uses one concise, canonical description. Extra
  /// source phrases stay selectable, but do not all pile into the default
  /// prompt as duplicate synonyms.
  List<_ElswordStyleDetail> get presetVisualDetails => visualDetails;

  /// The exact ordered components used by [unifiedOutfitPhrase].  Keeping
  /// these as individual fragments makes it possible to remove a coat, skirt,
  /// shoes, or accessory from a selected class set without reordering the
  /// remaining canonical description.
  List<_ElswordStyleDetail> get unifiedOutfitDetails {
    // The canonical Aisha jobs provide their identity, official-design, and
    // hair/head blocks through [contextPhrases].  Do not duplicate that
    // material inside the clothing group.
    if (usesCanonicalJobProfile) return visualDetails;
    return <_ElswordStyleDetail>[
      _ElswordStyleDetail('$jobZh職業套裝輪廓', en),
      _ElswordStyleDetail(
        '$jobZh原作服裝設定',
        'official outfit, canon outfit, official character design, character accurate, official game style, original class outfit',
      ),
      ...visualDetails,
    ];
  }

  /// Fragments share an ID when they belong to the same removable outfit
  /// region.  The UI shows one switch per ID, while prompt output preserves
  /// the source order of every still-enabled fragment.
  List<OutfitUnifiedPhraseSectionData> get unifiedPhraseSections => [
        for (final detail in unifiedOutfitDetails)
          OutfitUnifiedPhraseSectionData(
            id: _elswordOutfitSectionIdFor(detail.en),
            zh: _elswordOutfitSectionLabel(
              _elswordOutfitSectionIdFor(detail.en),
            ),
            en: detail.en,
          ),
      ];

  bool get usesElementalMasterProfile =>
      characterEn == 'Aisha' && jobEn == 'Elemental Master';

  bool get usesCanonicalAishaJobProfile =>
      characterEn == 'Aisha' && _canonicalAishaJobs.contains(jobEn);

  /// Rose, Laby, Lithia, and Luciela follow the same bundled class-reference
  /// contract as Aisha: their job name, official-design phrase, and
  /// class-specific head profile are emitted ahead of one complete outfit block.
  /// This prevents a different class's hair or outfit pieces from leaking into
  /// a selected job.
  bool get usesCanonicalJobProfile =>
      usesCanonicalAishaJobProfile ||
      const <String>{'Rose', 'Laby', 'Lithia', 'Luciela'}.contains(characterEn);

  String? get _aishaJobIdentity => switch (jobEn) {
        'Elemental Master' => 'elemental_master, elemental master aisha',
        'Aether Sage' => 'aether_sage, aether sage aisha',
        'Void Princess' => 'void_princess, void princess aisha',
        'Oz Sorcerer' => 'oz_sorcerer, oz sorcerer aisha',
        'Dimension Witch' => 'dimension_witch, dimension witch aisha',
        'Metamorphy' => 'metamorphy, metamorphy aisha',
        'Mystic Alchemist' => 'mystic_alchemist, mystic alchemist aisha',
        'Lord Azoth' => 'lord_azoth, lord azoth aisha',
        _ => null,
      };

  String? get _canonicalJobIdentity {
    if (usesCanonicalAishaJobProfile) return _aishaJobIdentity;
    if (!usesCanonicalJobProfile) return null;
    final jobToken = jobEn
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return '$jobToken, ${jobEn.toLowerCase()} ${characterEn.toLowerCase()}';
  }

  String? get _aishaJobOutfitAnchor => switch (jobEn) {
        'Elemental Master' => 'elemental master outfit',
        'Aether Sage' => 'aether sage outfit',
        'Void Princess' => 'void princess outfit',
        'Oz Sorcerer' => 'oz sorcerer outfit',
        'Dimension Witch' => 'dimension witch outfit',
        'Metamorphy' => 'metamorphy outfit',
        'Mystic Alchemist' => 'mystic alchemist outfit',
        'Lord Azoth' => 'lord azoth outfit',
        _ => null,
      };

  String get _aishaJobOutfitWeight => switch (jobEn) {
        'Void Princess' => '1.3',
        _ => '1.25',
      };

  /// Complete non-clothing blocks that are emitted in front of the canonical
  /// outfit. Keeping each one as one tag makes the order predictable and lets
  /// the user turn the job's head profile off without changing global Aisha
  /// traits.
  List<OutfitReferenceContextPhraseData> get contextPhrases {
    if (!usesCanonicalJobProfile) {
      return const <OutfitReferenceContextPhraseData>[];
    }
    final identity = _canonicalJobIdentity;
    if (identity == null) return const <OutfitReferenceContextPhraseData>[];
    final headProfile = <String>[
      ...look.hairTags,
      if (usesCanonicalAishaJobProfile) _aishaFaceProfile,
    ].join(', ');
    return <OutfitReferenceContextPhraseData>[
      OutfitReferenceContextPhraseData(
        id: 'identity',
        group: elswordJobIdentityGroup,
        zh: '$jobZh・職業標籤',
        en: identity,
      ),
      OutfitReferenceContextPhraseData(
        id: 'official_design',
        group: elswordJobOfficialDesignGroup,
        zh: '$jobZh・原作設定服裝',
        en: 'official outfit, canon outfit, official character design, character accurate, official game style, original class outfit',
      ),
      OutfitReferenceContextPhraseData(
        id: 'head_profile',
        group: elswordJobHeadFeatureGroup,
        zh: '$jobZh・頭部特徵',
        en: headProfile,
      ),
    ];
  }

  /// Older releases added these traits as normal feature chips.  Retain the
  /// values only for one-way local-storage migration to the class head phrase.
  List<String> get legacyFeatureTagsForMigration {
    if (!usesCanonicalAishaJobProfile) return const <String>[];
    return switch (jobEn) {
      'Elemental Master' => const <String>[
          'purple hair',
          'long hair',
          'purple eyes',
          'low twintails',
          'ahoge',
          'x-shaped hairclip',
        ],
      'Aether Sage' => const <String>[
          'purple hair',
          'long hair',
          'purple eyes',
          'twintails',
          'ahoge',
        ],
      'Void Princess' => const <String>[
          'purple hair',
          'long hair',
          'purple eyes',
          'side ponytail',
        ],
      'Oz Sorcerer' => const <String>[
          'purple hair',
          'long hair',
          'purple eyes',
          'very long hair',
          'twintails',
        ],
      'Dimension Witch' => const <String>[
          'purple hair',
          'long hair',
          'purple eyes',
          'double bun',
        ],
      'Metamorphy' => const <String>[
          'purple hair',
          'long hair',
          'purple eyes',
          'high ponytail',
        ],
      'Mystic Alchemist' => const <String>[
          'purple hair',
          'long hair',
          'purple eyes',
          'low ponytail',
          'ahoge',
        ],
      'Lord Azoth' => const <String>[
          'purple hair',
          'long hair',
          'purple eyes',
          'very long hair',
          'long straight hair',
        ],
      _ => const <String>[],
    };
  }

  /// A canonical job outfit needs to survive as one visual unit.  Retain the
  /// detailed phrases inside one tag instead of exposing every component as a
  /// separately editable garment after it is applied.
  String get unifiedOutfitPhrase {
    final seen = <String>{};
    return unifiedOutfitDetails
        .map((detail) => detail.en)
        .where((value) => value.trim().isNotEmpty)
        .where((value) => seen.add(value.trim().toLowerCase()))
        .join(', ');
  }

  /// Every class card can optionally attach one complete weapon description.
  /// These are separate from the outfit phrase so users may retain a faithful
  /// outfit silhouette without forcing its weapon into every prompt.
  bool get usesElementalMasterStaff => usesElementalMasterProfile;

  String get weaponTagId {
    if (usesElementalMasterStaff) {
      return 'obj_fantasy_elemental_master_staff';
    }
    final character = characterEn
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final job = jobEn
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return 'obj_fantasy_elsword_${character}_${job}_weapon';
  }

  String get weaponZh => switch (characterEn) {
        'Aisha' => switch (jobEn) {
            'Aether Sage' => '乙太魔導・法杖與浮游魔導書',
            'Void Princess' => '虛無公主・暗黑斧形法杖',
            'Oz Sorcerer' => '奧茲魔導・斧頭法杖',
            'Dimension Witch' => '次元魔女・時空法杖',
            'Metamorphy' => '星光魔女・魔法法杖',
            'Mystic Alchemist' => '真理術士・鍊金法杖與鍊金書',
            'Lord Azoth' => '萬靈賢者・賢者之石法杖與浮游鍊金書',
            _ => '$jobZh專屬法杖',
          },
        'Rena' => '$jobZh專屬精靈弓',
        'Eve' => '$jobZh專屬納斯德武裝',
        'Ara' => '$jobZh專屬靈槍',
        'Elesis' => '$jobZh專屬騎士劍',
        'Rose' => switch (jobEn) {
            'Storm Trooper' => '風暴神兵・重砲武裝',
            'Tempest Burster' => '暴風破壞者・超音速磁軌砲',
            'Crimson Rose' => '血色玫瑰・雙槍',
            'Black Massacre' => '黑色屠殺者・暗黑雙槍',
            'Freyja' => '芙蕾雅・榴彈與爆破武裝',
            'Minerva' => '密涅瓦・空戰槍械',
            'Optimus' => '終極武器・召喚機器人',
            'Prime Operator' => '第一原質・機械軍團控制器',
            _ => '$jobZh專屬槍械',
          },
        'Laby' => switch (jobEn) {
            'Rumble Pumn' => '喧嘩拳擊者・拳套與鏡子',
            'Eternity Winner' => '永恆勝利者・能量拳套與鏡子',
            'Shining Romantica' => '光耀浪漫者・華麗魔鏡',
            'Radiant Soul' => '星耀魂靈者・光輝魔鏡',
            'Daydreamer' => '空想幻夢者・夢境魔鏡',
            'Nisha Labyrinth' => '夜暝魂夢者・暗影魔鏡',
            'Punky Poppet' => '甜心劫掠者・龐克魔鏡',
            'Twins Picaro' => '雙珠邪魅者・雙子魔鏡',
            _ => '$jobZh專屬魔鏡',
          },
        'Lithia' => switch (jobEn) {
            'Mighty Miner' => '強力礦工・魔法礦鎬',
            'Gembliss' => '寶石極樂・寶石礦鎬',
            'Greedy Wonder' => '貪心神醫・寶石法器',
            'Avarice' => '極欲饕餮・華麗寶石法器',
            'Rima Clavis' => '律法之鑰・裂隙法器',
            'Achlys' => '阿克莉絲・混沌裂隙法器',
            'Cynical Sneer' => '諷世愚者・惡魔法器',
            'Mischief' => '惡戲奇術師・惡作劇法器',
            _ => '$jobZh專屬魔法礦鎬',
          },
        'Luciela' => switch (jobEn) {
            'Dreadlord' => '邪恐夜皇・魔爪與槍刃',
            'Catastrophe' => '災禍魔王・災厄魔刃',
            'Noblesse' => '闇夜女爵・深淵靈槍',
            'Innocent' => '釋罪女皇・賽菲洛特幻影兵器',
            'Demonio' => '冷焰邪魔・惡魔爪刃',
            'Diangelion' => '滅盡魔皇・深淵巨鐮',
            'Turbids' => '混濁影靈・深淵魔槍',
            'Demersio' => '深淵魔君・深淵雙生兵器',
            _ => '$jobZh專屬惡魔武器',
          },
        _ => '$jobZh專屬武器',
      };

  String get weaponEn {
    final descriptor = _elswordWeaponDescriptor(jobEn);
    return switch (characterEn) {
      'Aisha' => switch (jobEn) {
          'Aether Sage' => 'magic staff, floating magic book',
          'Void Princess' =>
            'dark magic axe staff, compact axe staff, black weapon, white demon-face ornament, purple magical core, pink crystal ornaments, black and purple axe head',
          'Oz Sorcerer' =>
            'large dark magic staff, axe-headed staff, battle-axe-shaped staff head, purple magical core',
          'Dimension Witch' => 'staff',
          'Metamorphy' => 'magical staff',
          'Mystic Alchemist' => 'alchemy staff, alchemy book',
          'Lord Azoth' =>
            'alchemy staff, philosopher\'s stone motif, floating alchemy book',
          _ =>
            'ornate $descriptor magic staff with a glowing gemstone, official Elsword class weapon',
        },
      'Rena' =>
        'ornate $descriptor elven bow with engraved limbs and a glowing bowstring, official Elsword ranger weapon',
      'Eve' =>
        'floating $descriptor nasod weapon drones with glowing energy cores, official Elsword nasod weapon',
      'Ara' =>
        'ornate $descriptor spirit spear with glowing talismans, official Elsword martial weapon',
      'Elesis' =>
        'ornate $descriptor knight sword with an engraved guard and a glowing crest, official Elsword knight weapon',
      'Rose' => switch (jobEn) {
          'Storm Trooper' =>
            'heavy artillery cannon, grenade launcher, gravity cannon, official Elsword gunner weapon',
          'Tempest Burster' =>
            'supersonic buster railgun, hybrid railgun, heavy artillery cannon, official Elsword gunner weapon',
          'Crimson Rose' =>
            'dual revolvers, crimson energy bullets, official Elsword assassin gunner weapon',
          'Black Massacre' =>
            'dual black pistols, dark energy firearm, official Elsword assassin gunner weapon',
          'Freyja' =>
            'explosive grenade launcher, attribute bullets, official Elsword gunner weapon',
          'Minerva' =>
            'aerial firearm, electric launcher, official Elsword gunner weapon',
          'Optimus' =>
            'summoned combat robot, mechanical drone, remote controller, official Elsword mech weapon',
          'Prime Operator' =>
            'mechanical drone army, command controller, giant mech cannon, official Elsword mech weapon',
          _ =>
            'ornate $descriptor gunner weapon, official Elsword class weapon',
        },
      'Laby' => switch (jobEn) {
          'Rumble Pumn' =>
            'oversized boxing gloves, magical mirror, official Elsword fighter weapon',
          'Eternity Winner' =>
            'energy gauntlets, magical mirror, official Elsword fighter weapon',
          'Shining Romantica' =>
            'ornate mirror, magical reflector, official Elsword mirror weapon',
          'Radiant Soul' =>
            'glowing mirror, radiant light orb, official Elsword mirror weapon',
          'Daydreamer' =>
            'dream mirror, shadow familiar, official Elsword mirror weapon',
          'Nisha Labyrinth' =>
            'black mirror, shadow familiar, official Elsword mirror weapon',
          'Punky Poppet' =>
            'punk mirror, shadow puppet, official Elsword mirror weapon',
          'Twins Picaro' =>
            'twin magical mirrors, playing-card magic, official Elsword mirror weapon',
          _ => 'ornate $descriptor magic mirror, official Elsword class weapon',
        },
      'Lithia' => switch (jobEn) {
          'Mighty Miner' =>
            'enchanted mining pickaxe, gemstone drill, official Elsword relic weapon',
          'Gembliss' =>
            'gemstone pickaxe, floating crystal ore, official Elsword relic weapon',
          'Greedy Wonder' =>
            'gemstone magic pickaxe, healing crystal, official Elsword relic weapon',
          'Avarice' =>
            'ornate gemstone pickaxe, gold crystal charm, official Elsword relic weapon',
          'Rima Clavis' =>
            'rift magic pickaxe, dimensional key device, official Elsword relic weapon',
          'Achlys' =>
            'chaos rift pickaxe, fractured crystal device, official Elsword relic weapon',
          'Cynical Sneer' =>
            'demonic magic pickaxe, cursed crystal device, official Elsword relic weapon',
          'Mischief' =>
            'trickster magic pickaxe, demonic crystal device, official Elsword relic weapon',
          _ =>
            'ornate $descriptor magic pickaxe, official Elsword relic weapon',
        },
      'Luciela' => switch (jobEn) {
          'Dreadlord' =>
            'demonic gauntlets, dark gunblades, cyan energy blade, official Elsword demon weapon',
          'Catastrophe' =>
            'catastrophe scythe, black and cyan gunblade, chained demon weapon, official Elsword demon weapon',
          'Noblesse' =>
            'royal spirit spear, cyan spear, dark gunblades, official Elsword abyss weapon',
          'Innocent' =>
            'sephirot phantasma, twin spectral weapons, cyan energy lances, official Elsword abyss weapon',
          'Demonio' =>
            'demonic gauntlets, black gunblade, blue demon claws, official Elsword demon weapon',
          'Diangelion' =>
            'abyssal scythe, demon claws, cyan demon weapon, official Elsword demon weapon',
          'Turbids' =>
            'abyssal spear, blue crystal staff, dark gunblade, official Elsword abyss weapon',
          'Demersio' =>
            'abyssal spear, black and white gunblade, dark energy weapon, official Elsword abyss weapon',
          _ => 'ornate $descriptor demon weapon, official Elsword class weapon',
        },
      _ => 'ornate $descriptor fantasy weapon, official Elsword class weapon',
    };
  }
}

/// Avoid using the word "little" in prompt-facing class weapon descriptions.
/// It is a part of several official job names, but unnecessary here and can be
/// mistaken for an age reference by image-generation moderation.
String _elswordWeaponDescriptor(String jobEn) {
  const replacements = <String, String>{
    'Little Hsien': 'celestial spirit',
    'Little Devil': 'demonic spirit',
    'Little Specter': 'spectral spirit',
    'Little Helper': 'guardian spirit',
  };
  return replacements[jobEn] ??
      jobEn.toLowerCase().replaceFirst('code:', 'nasod').trim();
}

String _elswordVisualDetailId(String english) =>
    'elsword_detail_${english.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '')}';

const _fallbackLook = _ElswordJobLook(
  palette: '依原作職業設計',
  details: [
    _ElswordStyleDetail('原作職業剪裁', 'original class outfit design'),
  ],
);

const _aishaLooks = <String, _ElswordJobLook>{
  'Elemental Master': _ElswordJobLook(
    palette: '白色 × 紫色 × 粉紅色',
    hairTags: [
      'purple hair',
      'long hair',
      'low twintails',
      'ahoge',
      'purple eyes',
      'x-shaped hairclip',
    ],
    details: [
      _ElswordStyleDetail('元素魔導服裝強調', '(white hooded coat:1.2)'),
      _ElswordStyleDetail('白色外套', 'white coat'),
      _ElswordStyleDetail('放下的帽兜', 'hood down'),
      _ElswordStyleDetail('白色長外套', 'long white coat'),
      _ElswordStyleDetail('白色短斗篷', 'white capelet'),
      _ElswordStyleDetail('連帽短斗篷', 'hooded capelet'),
      _ElswordStyleDetail('紫色滾邊', 'purple trim'),
      _ElswordStyleDetail('粉紅色滾邊', 'pink trim'),
      _ElswordStyleDetail('大型粉紅蝴蝶結', 'large pink bow'),
      _ElswordStyleDetail('粉紅領結', 'pink bowtie'),
      _ElswordStyleDetail('胸前緞帶', 'chest ribbon'),
      _ElswordStyleDetail('寶石胸針', 'gemstone brooch'),
      _ElswordStyleDetail('胸前大型寶石', 'large jewel on chest'),
      _ElswordStyleDetail('深紫高領毛衣', 'dark purple turtleneck sweater'),
      _ElswordStyleDetail('黑紫色馬甲', 'black and purple bodice'),
      _ElswordStyleDetail('貼身馬甲', 'fitted bodice'),
      _ElswordStyleDetail('黑色背心層', 'black vest'),
      _ElswordStyleDetail('白色寬袖', 'white wide sleeves'),
      _ElswordStyleDetail('寬大袖子', 'oversized sleeves'),
      _ElswordStyleDetail('棕色手套', 'brown gloves'),
      _ElswordStyleDetail('皮革手套', 'leather gloves'),
      _ElswordStyleDetail('紫色百褶迷你裙', 'purple pleated miniskirt'),
      _ElswordStyleDetail('粉紅點綴', 'pink accents'),
      _ElswordStyleDetail('黑色大腿襪', 'black thighhighs'),
      _ElswordStyleDetail('粉紅大腿襪圖樣', 'pink markings on thighhighs'),
      _ElswordStyleDetail('白色大腿環帶', 'white thigh strap'),
      _ElswordStyleDetail('白色踝靴', 'white ankle boots'),
      _ElswordStyleDetail('白粉長靴', 'white and pink boots'),
      _ElswordStyleDetail('寶石靴', 'jeweled boots'),
      _ElswordStyleDetail('垂墜水晶飾品', 'hanging crystal ornaments'),
      _ElswordStyleDetail('水晶流蘇', 'crystal tassels'),
      _ElswordStyleDetail('魔法飾品', 'magical accessories'),
      _ElswordStyleDetail('魔法徽章', 'emblem'),
      _ElswordStyleDetail('奇幻法師服裝', 'fantasy mage outfit'),
      _ElswordStyleDetail('元素法師', 'elemental mage'),
      _ElswordStyleDetail('魔法使用者', 'magic user'),
      _ElswordStyleDetail('艾爾之光原作風格', 'official Elsword style'),
    ],
  ),
  'Aether Sage': _ElswordJobLook(
    palette: '白色 × 紫色 × 深紫色 × 粉紅色',
    hairTags: [
      'purple hair',
      'very long purple hair',
      'long hair',
      'hair worn down',
      'sidelocks',
      'ahoge',
      'purple eyes',
      'ornate hair ornament',
    ],
    details: [
      _ElswordStyleDetail('白紫色洋裝', 'white and purple dress'),
      _ElswordStyleDetail('深紫色洋裝', 'dark purple dress'),
      _ElswordStyleDetail('分層洋裝', 'layered dress'),
      _ElswordStyleDetail('無袖洋裝', 'sleeveless dress'),
      _ElswordStyleDetail('有領洋裝', 'collared dress'),
      _ElswordStyleDetail('交叉繫帶服裝', 'cross-laced clothing'),
      _ElswordStyleDetail('白色衣領', 'white collar'),
      _ElswordStyleDetail('粉紅領帶', 'pink necktie'),
      _ElswordStyleDetail('領口墜飾', 'collar pendant'),
      _ElswordStyleDetail('紅色寶石', 'red gemstone'),
      _ElswordStyleDetail('露肩白色外套', 'off-shoulder white coat'),
      _ElswordStyleDetail('敞開外套', 'open coat'),
      _ElswordStyleDetail('泡泡袖', 'puffy sleeves'),
      _ElswordStyleDetail('寬大袖子', 'wide sleeves'),
      _ElswordStyleDetail('白色手套', 'white gloves'),
      _ElswordStyleDetail('白色大腿靴', 'white thigh boots'),
      _ElswordStyleDetail('護身符', 'amulet'),
      _ElswordStyleDetail('耳環', 'earrings'),
      _ElswordStyleDetail('金色滾邊', 'gold trim'),
      _ElswordStyleDetail('紫色水晶飾品', 'purple crystal ornaments'),
      _ElswordStyleDetail('元素魔法', 'elemental magic'),
      _ElswordStyleDetail('乙太魔法', 'aether magic'),
      _ElswordStyleDetail('奇幻法師服裝', 'fantasy mage outfit'),
      _ElswordStyleDetail('艾爾之光原作風格', 'official Elsword style'),
    ],
  ),
  'Void Princess': _ElswordJobLook(
    palette: '紫色 × 洋紅色 × 白色 × 黑色',
    hairTags: [
      'purple eyes',
      '((purple hair:1.25))',
      'high twintails',
      'compact twintails',
      'flared twintails',
      'outward-curving twintails',
      'tied twin tails',
      'black hair bows',
    ],
    details: [
      _ElswordStyleDetail('黑紫法師服裝', 'black and purple mage outfit'),
      _ElswordStyleDetail('洋紅色點綴', 'magenta accents'),
      _ElswordStyleDetail('短版法師上衣', 'cropped mage top'),
      _ElswordStyleDetail('露出腰腹', 'exposed midriff'),
      _ElswordStyleDetail('合身上衣', 'fitted top'),
      _ElswordStyleDetail('中央寶石裝飾', 'central gem ornament'),
      _ElswordStyleDetail('胸前十字圖樣', 'chest cross motif'),
      _ElswordStyleDetail('黑色頸圈', 'black choker'),
      _ElswordStyleDetail('分離式袖套', 'detached sleeves'),
      _ElswordStyleDetail('超寬袖', 'very wide sleeves'),
      _ElswordStyleDetail('長喇叭袖', 'long flared sleeves'),
      _ElswordStyleDetail('黑紫袖套', 'black and purple sleeves'),
      _ElswordStyleDetail('袖上洋紅圓形圖樣', 'magenta circular sleeve patterns'),
      _ElswordStyleDetail('袖口白色內層荷葉邊', 'white inner frill at sleeve cuffs'),
      _ElswordStyleDetail('大型圓形腰部裝飾', 'large circular waist ornament'),
      _ElswordStyleDetail('腰帶', 'waist belt'),
      _ElswordStyleDetail('及膝上層次裙', 'above-knee layered skirt'),
      _ElswordStyleDetail('開衩裙片', 'split skirt panels'),
      _ElswordStyleDetail('側邊長垂布', 'long trailing side panels'),
      _ElswordStyleDetail('黑紫下身服裝', 'black and purple lower outfit'),
      _ElswordStyleDetail('洋紅色滾邊', 'magenta trim'),
      _ElswordStyleDetail('腰部緞帶', 'waist ribbons'),
      _ElswordStyleDetail('垂掛飾件', 'hanging ornaments'),
      _ElswordStyleDetail('黑色大腿襪', 'black thighhighs'),
      _ElswordStyleDetail('對稱腿部服飾', 'symmetrical legwear'),
      _ElswordStyleDetail('大腿襪洋紅直條紋', 'magenta vertical stripe on thighhighs'),
      _ElswordStyleDetail('黑紫奇幻鞋履', 'black and purple fantasy shoes'),
      _ElswordStyleDetail('白色獸臉鞋飾', 'white beast-face shoe ornaments'),
      _ElswordStyleDetail('白色尖頭鞋飾', 'white pointed shoe decorations'),
      _ElswordStyleDetail('洋紅寶石點綴', 'magenta gem accents'),
      _ElswordStyleDetail('尖頭鞋履', 'pointed footwear'),
      _ElswordStyleDetail('暗黑魔法', 'dark magic'),
      _ElswordStyleDetail('紫色魔法光環', 'purple magic aura'),
      _ElswordStyleDetail('黑色魔法粒子', 'black magic particles'),
      _ElswordStyleDetail('艾爾之光原作風格', 'official Elsword style'),
    ],
  ),
  'Oz Sorcerer': _ElswordJobLook(
    palette: '黑色 × 紫色 × 粉紅色',
    hairTags: [
      'purple eyes',
      'very long purple hair',
      'very long straight hair',
      'loose hair',
      'hair worn down',
      'smooth straight hair',
      'naturally flowing hair',
    ],
    details: [
      _ElswordStyleDetail('大型魔女帽', 'large witch hat'),
      _ElswordStyleDetail('超大魔女帽', 'oversized witch hat'),
      _ElswordStyleDetail('寬簷魔女帽', 'wide-brim witch hat'),
      _ElswordStyleDetail('歪尖魔女帽', 'crooked pointed witch hat'),
      _ElswordStyleDetail('深紫色魔女帽', 'dark purple witch hat'),
      _ElswordStyleDetail('洋紅色點綴', 'magenta accents'),
      _ElswordStyleDetail('魔女帽拉鍊', 'zipper on witch hat'),
      _ElswordStyleDetail('拉鍊嘴魔女帽', 'zipper-mouth hat'),
      _ElswordStyleDetail('拉鍊狀嘴部開口', 'zipper-like mouth opening'),
      _ElswordStyleDetail('可見拉鍊齒', 'visible zipper teeth'),
      _ElswordStyleDetail('黑紫法師服', 'black and purple mage outfit'),
      _ElswordStyleDetail('深紫色繞頸上衣', 'dark purple halter top'),
      _ElswordStyleDetail('拉鍊上衣', 'zipper shirt'),
      _ElswordStyleDetail('裸露肩膀', 'bare shoulders'),
      _ElswordStyleDetail('露出腰腹', 'exposed midriff'),
      _ElswordStyleDetail('交叉繫帶', 'cross-laced straps'),
      _ElswordStyleDetail('分離式紫色袖套', 'detached purple sleeves'),
      _ElswordStyleDetail('寬大袖子', 'wide sleeves'),
      _ElswordStyleDetail('拉鍊袖套', 'zipper sleeves'),
      _ElswordStyleDetail('荷葉開襟裙', 'frilled open skirt'),
      _ElswordStyleDetail('長開衩裙', 'long split skirt'),
      _ElswordStyleDetail('不對稱腿部服飾', 'asymmetrical legwear'),
      _ElswordStyleDetail('深紫色大腿襪', 'dark purple thighhighs'),
      _ElswordStyleDetail('拉鍊腿部服飾', 'zipper legwear'),
      _ElswordStyleDetail('單側大腿襪角形開口', 'angular opening on one thighhigh'),
      _ElswordStyleDetail('深紫色短褲', 'dark purple shorts'),
      _ElswordStyleDetail('深紫色高跟鞋履', 'dark purple high heel footwear'),
      _ElswordStyleDetail('拉鍊鞋履', 'zipper footwear'),
      _ElswordStyleDetail('暗黑魔法', 'dark magic'),
      _ElswordStyleDetail('艾爾之光原作風格', 'official Elsword style'),
    ],
  ),
  'Dimension Witch': _ElswordJobLook(
    palette: '白色 × 紫色 × 粉紅色 × 洋紅色',
    hairTags: [
      'purple hair',
      'purple eyes',
      'twintails',
      'curled twintails',
      'ringlets',
      'pink hair ribbon',
      'two-tone hair bow',
    ],
    details: [
      _ElswordStyleDetail('白色繞頸洋裝', 'white halter dress'),
      _ElswordStyleDetail('交叉繫帶繞頸', 'criss-cross halter'),
      _ElswordStyleDetail('開襟洋裝', 'open dress'),
      _ElswordStyleDetail('紫色衣領', 'purple collar'),
      _ElswordStyleDetail('大型背後蝴蝶結', 'large back bow'),
      _ElswordStyleDetail('酒紅背後蝴蝶結', 'maroon back bow'),
      _ElswordStyleDetail('裸露肩膀', 'bare shoulders'),
      _ElswordStyleDetail('分離式袖套', 'detached sleeves'),
      _ElswordStyleDetail('白色袖套', 'white sleeves'),
      _ElswordStyleDetail('袖套環帶', 'sleeve garters'),
      _ElswordStyleDetail('粉紅滾邊', 'pink trim'),
      _ElswordStyleDetail('白色手套', 'white gloves'),
      _ElswordStyleDetail('紫色迷你裙', 'purple miniskirt'),
      _ElswordStyleDetail('分層服裝', 'layered clothing'),
      _ElswordStyleDetail('洋紅腰帶', 'magenta belt'),
      _ElswordStyleDetail('鬆垂腰帶', 'loose belt'),
      _ElswordStyleDetail('符咒', 'talisman'),
      _ElswordStyleDetail('白色襪子', 'white socks'),
      _ElswordStyleDetail('踝部袖口', 'ankle cuffs'),
      _ElswordStyleDetail('白色交叉繫帶靴', 'white cross-laced boots'),
      _ElswordStyleDetail('黑色踝帶', 'black ankle straps'),
      _ElswordStyleDetail('能量魔法', 'energy magic'),
      _ElswordStyleDetail('時空魔法', 'space-time magic'),
      _ElswordStyleDetail('次元魔法', 'dimension magic'),
      _ElswordStyleDetail('魔法少女服裝', 'magical girl outfit'),
      _ElswordStyleDetail('艾爾之光原作風格', 'official Elsword style'),
    ],
  ),
  'Metamorphy': _ElswordJobLook(
    palette: '白色 × 粉紅色 × 紫色 × 金色',
    hairTags: [
      'pink-purple hair',
      'purple hair',
      'gradient hair',
      'very long hair',
      'long twintails',
      'drill hair',
      'curled twintails',
      'drill sidelocks',
      'pink eyes',
      'purple eyes',
      'star-shaped eye highlights',
      'star hair ornament',
    ],
    details: [
      _ElswordStyleDetail('魔法少女風格', 'magical girl'),
      _ElswordStyleDetail('白色洋裝', 'white dress'),
      _ElswordStyleDetail('粉紫洋裝', 'pink and purple dress'),
      _ElswordStyleDetail('雙色洋裝', 'two-tone dress'),
      _ElswordStyleDetail('荷葉洋裝', 'frilled dress'),
      _ElswordStyleDetail('百褶裙', 'pleated skirt'),
      _ElswordStyleDetail('粉紅漸層裙', 'pink gradient skirt'),
      _ElswordStyleDetail('紫色寶石', 'purple gemstone'),
      _ElswordStyleDetail('紫色領結', 'purple bowtie'),
      _ElswordStyleDetail('大型蝴蝶結', 'large bow'),
      _ElswordStyleDetail('分離式衣領', 'detached collar'),
      _ElswordStyleDetail('粉紅荷葉衣領', 'pink frilled collar'),
      _ElswordStyleDetail('裸露肩膀', 'bare shoulders'),
      _ElswordStyleDetail('白色肘上手套', 'white elbow gloves'),
      _ElswordStyleDetail('燕尾下襬', 'coattails'),
      _ElswordStyleDetail('金色滾邊', 'gold trim'),
      _ElswordStyleDetail('大腿靴', 'thigh boots'),
      _ElswordStyleDetail('蝴蝶結腿部飾品', 'bow legwear'),
      _ElswordStyleDetail('白色蝴蝶結', 'white bows'),
      _ElswordStyleDetail('高跟鞋', 'high heels'),
      _ElswordStyleDetail('翼狀鞋履', 'winged footwear'),
      _ElswordStyleDetail('能量魔法', 'energy magic'),
      _ElswordStyleDetail('時空魔法', 'space-time magic'),
      _ElswordStyleDetail('星光魔法', 'star magic'),
      _ElswordStyleDetail('艾爾之光原作風格', 'official Elsword style'),
    ],
  ),
  'Mystic Alchemist': _ElswordJobLook(
    palette: '白色 × 黑色 × 紫色 × 紅色 × 金色',
    hairTags: [
      'purple hair',
      'gradient purple hair',
      'low twintails',
      'long hair',
      'ahoge',
      'purple eyes',
      'hair bow',
    ],
    details: [
      _ElswordStyleDetail('白色襯衫洋裝', 'white dress shirt'),
      _ElswordStyleDetail('白色襯衫', 'white shirt'),
      _ElswordStyleDetail('深紫蝴蝶結', 'dark purple bow'),
      _ElswordStyleDetail('黑色領結', 'black bowtie'),
      _ElswordStyleDetail('紅色寶石', 'red gemstone'),
      _ElswordStyleDetail('黑色束腰', 'black corset'),
      _ElswordStyleDetail('大型黑色腰帶', 'large black belt'),
      _ElswordStyleDetail('紅色緞帶', 'red ribbon'),
      _ElswordStyleDetail('紫色披肩', 'purple stole'),
      _ElswordStyleDetail('紫色長袖', 'purple long sleeves'),
      _ElswordStyleDetail('反摺袖口', 'folded cuffs'),
      _ElswordStyleDetail('黑色手套', 'black gloves'),
      _ElswordStyleDetail('荷葉邊', 'frills'),
      _ElswordStyleDetail('分層紫色裙', 'layered purple skirt'),
      _ElswordStyleDetail('多色裙', 'multicolored skirt'),
      _ElswordStyleDetail('鍊金試管', 'alchemy vials'),
      _ElswordStyleDetail('藥水瓶', 'potion bottles'),
      _ElswordStyleDetail('燒瓶飾品', 'flask accessories'),
      _ElswordStyleDetail('腰間小袋', 'belt pouches'),
      _ElswordStyleDetail('紫色反摺靴', 'purple fold-over boots'),
      _ElswordStyleDetail('荷葉鞋履', 'frilled footwear'),
      _ElswordStyleDetail('粗跟鞋', 'block heels'),
      _ElswordStyleDetail('金色滾邊', 'gold trim'),
      _ElswordStyleDetail('金色鞋底', 'gold soles'),
      _ElswordStyleDetail('人造人圖樣', 'homunculus motif'),
      _ElswordStyleDetail('鍊金術', 'alchemy'),
      _ElswordStyleDetail('艾爾之光原作風格', 'official Elsword style'),
    ],
  ),
  'Lord Azoth': _ElswordJobLook(
    palette: '白色 × 黑色 × 金色 × 淡紫色',
    hairTags: [
      'light purple hair',
      'very long light purple hair',
      'high ponytail',
      'sidelocks',
      'ahoge',
      'light purple eyes',
      'pale violet eyes',
      'white pupils',
      'monocle',
    ],
    details: [
      _ElswordStyleDetail('黑色頸圈', 'black choker'),
      _ElswordStyleDetail('項鍊', 'necklace'),
      _ElswordStyleDetail('珠寶飾品', 'jewelry'),
      _ElswordStyleDetail('白色無袖上衣', 'white sleeveless shirt'),
      _ElswordStyleDetail('半敞開上衣', 'partially open shirt'),
      _ElswordStyleDetail('裸露肩膀', 'bare shoulders'),
      _ElswordStyleDetail('金色鍊條', 'gold chain'),
      _ElswordStyleDetail('金色披肩', 'gold stole'),
      _ElswordStyleDetail('大型鬆垂腰帶', 'large loose belt'),
      _ElswordStyleDetail('鍊金試管', 'alchemy vials'),
      _ElswordStyleDetail('藥水瓶', 'potion bottles'),
      _ElswordStyleDetail('高腰黑色長褲', 'high-waisted black pants'),
      _ElswordStyleDetail('雙排扣腰部設計', 'double-breasted waist design'),
      _ElswordStyleDetail('金色滾邊', 'gold trim'),
      _ElswordStyleDetail('披肩黑色外套', 'black coat on shoulders'),
      _ElswordStyleDetail('浮空外套', 'floating coat'),
      _ElswordStyleDetail('雙面外套', 'two-sided coat'),
      _ElswordStyleDetail('漸層分離式袖套', 'detached gradient sleeves'),
      _ElswordStyleDetail('黑白手套', 'black and white gloves'),
      _ElswordStyleDetail('手環', 'bracelets'),
      _ElswordStyleDetail('大腿小袋', 'thigh pouch'),
      _ElswordStyleDetail('黑色反摺靴', 'black fold-over boots'),
      _ElswordStyleDetail('高跟鞋', 'high heels'),
      _ElswordStyleDetail('金色鞋底', 'gold soles'),
      _ElswordStyleDetail('鞋履鏤空', 'footwear cutouts'),
      _ElswordStyleDetail('鍊金術', 'alchemy'),
      _ElswordStyleDetail('賢者之石', 'philosopher\'s stone'),
      _ElswordStyleDetail('艾爾之光原作風格', 'official Elsword style'),
    ],
  ),
};

const _renaLooks = <String, _ElswordJobLook>{
  'Combat Ranger': _ElswordJobLook(
    palette: '綠色 × 棕色 × 白色',
    hairTags: ['high ponytail'],
    details: [
      _ElswordStyleDetail('綠棕戰鬥遊俠服', 'green and brown combat ranger outfit'),
      _ElswordStyleDetail('皮革護腕', 'leather arm guards'),
      _ElswordStyleDetail('遊俠斗篷', 'ranger capelet'),
    ],
  ),
  'Wind Sneaker': _ElswordJobLook(
    palette: '白色 × 綠色 × 天藍色',
    hairTags: ['high ponytail'],
    details: [
      _ElswordStyleDetail('白綠疾風武鬥服', 'white and green wind fighter outfit'),
      _ElswordStyleDetail('飄帶腰封', 'flowing sash belt'),
      _ElswordStyleDetail('腿部綁帶', 'leg wraps'),
    ],
  ),
  'Anemos': _ElswordJobLook(
    palette: '白色 × 青綠色 × 金色',
    hairTags: ['wavy hair', 'side ponytail'],
    details: [
      _ElswordStyleDetail(
          '白青風靈舞者套裝', 'white and teal wind spirit dancer outfit'),
      _ElswordStyleDetail('羽毛披肩', 'feathered shoulder cape'),
      _ElswordStyleDetail('金色風紋飾邊', 'gold wind-pattern trim'),
    ],
  ),
  'Sniping Ranger': _ElswordJobLook(
    palette: '森林綠 × 棕色 × 黑色',
    hairTags: ['long straight hair'],
    details: [
      _ElswordStyleDetail('森林綠狙擊遊俠外套', 'forest green sniping ranger coat'),
      _ElswordStyleDetail('箭袋腰帶', 'quiver belt'),
      _ElswordStyleDetail('皮革護手', 'leather gloves'),
    ],
  ),
  'Grand Archer': _ElswordJobLook(
    palette: '白色 × 金色 × 綠色',
    hairTags: ['long hair', 'side braid'],
    details: [
      _ElswordStyleDetail('白金大弓手斗篷', 'white and gold grand archer cape'),
      _ElswordStyleDetail('綠色精靈飾邊', 'green elven trim'),
      _ElswordStyleDetail('裝飾箭袋', 'ornate quiver'),
    ],
  ),
  'Daybreaker': _ElswordJobLook(
    palette: '白色 × 金色 × 淺藍色',
    hairTags: ['long hair', 'wavy hair'],
    details: [
      _ElswordStyleDetail('白金破曉弓手禮服', 'white and gold daybreaker archer dress'),
      _ElswordStyleDetail('淺藍靈石飾品', 'light blue spirit stone ornaments'),
      _ElswordStyleDetail('飄逸肩披', 'flowing shoulder mantle'),
    ],
  ),
  'Trapping Ranger': _ElswordJobLook(
    palette: '黑色 × 深綠色 × 棕色',
    hairTags: ['low ponytail'],
    details: [
      _ElswordStyleDetail(
          '黑綠陷阱遊俠服', 'black and dark green trapping ranger outfit'),
      _ElswordStyleDetail('工具腰帶', 'utility belt'),
      _ElswordStyleDetail('皮革短斗篷', 'leather capelet'),
    ],
  ),
  'Night Watcher': _ElswordJobLook(
    palette: '黑色 × 深藍色 × 銀色',
    hairTags: ['long hair', 'side braid'],
    details: [
      _ElswordStyleDetail('黑藍夜巡者鎧裝', 'black and navy night watcher armor'),
      _ElswordStyleDetail('銀色月紋飾邊', 'silver moon-pattern trim'),
      _ElswordStyleDetail('偵察披風', 'scout cloak'),
    ],
  ),
  'Twilight': _ElswordJobLook(
    palette: '黑色 × 紫色 × 深綠色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('暮光精靈披風', 'twilight elven cloak'),
      _ElswordStyleDetail('紫黑輕甲', 'purple and black light armor'),
      _ElswordStyleDetail('森林徽章', 'forest emblem'),
    ],
  ),
  'Poetic Ranger': _ElswordJobLook(
    palette: '象牙白 × 天藍色 × 金色',
    hairTags: ['long hair', 'twin braids'],
    details: [
      _ElswordStyleDetail('象牙白詩歌遊俠服', 'ivory poetic ranger outfit'),
      _ElswordStyleDetail('藍色吟遊飄帶', 'blue bard ribbons'),
      _ElswordStyleDetail('金色羽飾', 'gold feather ornaments'),
    ],
  ),
  'Tale Spinner': _ElswordJobLook(
    palette: '藍色 × 金色 × 白色',
    hairTags: ['long hair', 'side braid'],
    details: [
      _ElswordStyleDetail('藍金說書人套裝', 'blue and gold tale spinner outfit'),
      _ElswordStyleDetail('長版吟遊披肩', 'long bard mantle'),
      _ElswordStyleDetail('樂譜飾品', 'musical score ornaments'),
    ],
  ),
  'Prophetess': _ElswordJobLook(
    palette: '白色 × 青綠色 × 金色',
    hairTags: ['very long hair', 'wavy hair'],
    details: [
      _ElswordStyleDetail('白青預言者長袍', 'white and teal prophetess robe'),
      _ElswordStyleDetail('金色預言飾鏈', 'gold prophecy chains'),
      _ElswordStyleDetail('水晶頭飾', 'crystal head ornament'),
    ],
  ),
};

const _eveLooks = <String, _ElswordJobLook>{
  'Code: Exotic': _ElswordJobLook(
    palette: '黑色 × 紅色 × 銀色',
    hairTags: ['long straight hair'],
    details: [
      _ElswordStyleDetail('黑紅納斯德戰鬥裝甲', 'black and red nasod battle armor'),
      _ElswordStyleDetail('機械手臂飾件', 'mechanical arm ornaments'),
      _ElswordStyleDetail('銀色金屬護甲', 'silver metallic armor'),
    ],
  ),
  'Code: Nemesis': _ElswordJobLook(
    palette: '白色 × 藍色 × 金色',
    hairTags: ['long hair', 'side ponytail'],
    details: [
      _ElswordStyleDetail('白藍納斯德女王裝甲', 'white and blue nasod queen armor'),
      _ElswordStyleDetail('金色機械冠飾', 'gold mechanical crown ornament'),
      _ElswordStyleDetail('裝甲裙襬', 'armored skirt panels'),
    ],
  ),
  'Code: Ultimate': _ElswordJobLook(
    palette: '黑色 × 紅色 × 紫色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('黑紅終極戰鬥裝甲', 'black and red ultimate battle armor'),
      _ElswordStyleDetail('紫色能量核心', 'purple energy core'),
      _ElswordStyleDetail('機械護腿', 'mechanical leg guards'),
    ],
  ),
  'Code: Architecture': _ElswordJobLook(
    palette: '白色 × 天藍色 × 金色',
    hairTags: ['long straight hair'],
    details: [
      _ElswordStyleDetail('白藍建築師洋裝', 'white and light blue architecture dress'),
      _ElswordStyleDetail('金色機械緞帶', 'gold mechanical ribbons'),
      _ElswordStyleDetail('人偶風裙襬', 'doll-like skirt panels'),
    ],
  ),
  'Code: Empress': _ElswordJobLook(
    palette: '黑色 × 白色 × 金色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('黑白皇后禮服', 'black and white empress dress'),
      _ElswordStyleDetail('金色機械冠飾', 'gold mechanical crown'),
      _ElswordStyleDetail('分層機械裙片', 'layered mechanical skirt panels'),
    ],
  ),
  'Code: Esencia': _ElswordJobLook(
    palette: '白色 × 藍色 × 淡金色',
    hairTags: ['long hair', 'wavy hair'],
    details: [
      _ElswordStyleDetail('白藍艾森希雅禮服', 'white and blue esencia dress'),
      _ElswordStyleDetail('淡金機械飾件', 'pale gold mechanical ornaments'),
      _ElswordStyleDetail('優雅分層裙襬', 'elegant layered skirt panels'),
    ],
  ),
  'Code: Electra': _ElswordJobLook(
    palette: '黑色 × 電光藍 × 白色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('黑藍電能戰衣', 'black and electric blue combat suit'),
      _ElswordStyleDetail('發光電路飾邊', 'glowing circuit trim'),
      _ElswordStyleDetail('機械護臂', 'mechanical arm guards'),
    ],
  ),
  'Code: Battle Seraph': _ElswordJobLook(
    palette: '白色 × 金色 × 淺藍色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('白金戰鬥熾天使裝甲', 'white and gold battle seraph armor'),
      _ElswordStyleDetail('淺藍發光核心', 'light blue glowing core'),
      _ElswordStyleDetail('翼狀機械飾件', 'wing-shaped mechanical ornaments'),
    ],
  ),
  'Code: Sariel': _ElswordJobLook(
    palette: '白色 × 金色 × 天藍色',
    hairTags: ['very long hair', 'wavy hair'],
    details: [
      _ElswordStyleDetail('白金沙利葉禮服', 'white and gold sariel dress'),
      _ElswordStyleDetail('天藍能量線條', 'sky blue energy lines'),
      _ElswordStyleDetail('浮游機械光環', 'floating mechanical halo'),
    ],
  ),
  'Code: Unknown': _ElswordJobLook(
    palette: '黑色 × 紫色 × 青色',
    hairTags: ['long hair', 'hair over one eye'],
    details: [
      _ElswordStyleDetail('黑紫未知代碼戰衣', 'black and purple unknown code outfit'),
      _ElswordStyleDetail('青色故障光效飾件', 'cyan glitch-light ornaments'),
      _ElswordStyleDetail('不對稱護甲', 'asymmetrical armor'),
    ],
  ),
  'Code: Failess': _ElswordJobLook(
    palette: '白色 × 黑色 × 洋紅色',
    hairTags: ['long hair', 'messy hair'],
    details: [
      _ElswordStyleDetail('黑白無瑕代碼禮服', 'black and white failess dress'),
      _ElswordStyleDetail('洋紅錯誤光紋', 'magenta error-light patterns'),
      _ElswordStyleDetail('破碎機械飾片', 'fractured mechanical ornaments'),
    ],
  ),
  'Code: Antithese': _ElswordJobLook(
    palette: '黑色 × 深紅色 × 銀色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail(
          '黑紅反命題裝甲禮服', 'black and dark red antithese armor dress'),
      _ElswordStyleDetail('銀色尖銳飾邊', 'silver sharp trim'),
      _ElswordStyleDetail('機械王冠飾件', 'mechanical crown ornaments'),
    ],
  ),
};

const _araLooks = <String, _ElswordJobLook>{
  'Little Hsien': _ElswordJobLook(
    palette: '白色 × 藍色 × 金色',
    hairTags: ['high ponytail'],
    details: [
      _ElswordStyleDetail('白藍仙術韓服', 'white and blue martial hanfu'),
      _ElswordStyleDetail('金色雲紋飾邊', 'gold cloud-pattern trim'),
      _ElswordStyleDetail('飄帶腰封', 'flowing sash belt'),
    ],
  ),
  'Sakra Devanam': _ElswordJobLook(
    palette: '藍色 × 金色 × 白色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('藍金護法武術服', 'blue and gold guardian martial outfit'),
      _ElswordStyleDetail('裝甲護肩', 'armored shoulder guards'),
      _ElswordStyleDetail('神聖符文飾品', 'sacred rune ornaments'),
    ],
  ),
  'Apsara': _ElswordJobLook(
    palette: '白色 × 青色 × 金色',
    hairTags: ['long hair', 'side ponytail'],
    details: [
      _ElswordStyleDetail('白青天女戰袍', 'white and cyan apsara battle robe'),
      _ElswordStyleDetail('金色飄帶', 'gold flowing ribbons'),
      _ElswordStyleDetail('長袖武術上衣', 'long-sleeved martial top'),
    ],
  ),
  'Little Devil': _ElswordJobLook(
    palette: '黑色 × 紅色 × 紫色',
    hairTags: ['long hair', 'double bun'],
    details: [
      _ElswordStyleDetail(
          '黑紅小魔武術服', 'black and red little devil martial outfit'),
      _ElswordStyleDetail('紫色惡魔飾品', 'purple demon ornaments'),
      _ElswordStyleDetail('短版外套', 'cropped jacket'),
    ],
  ),
  'Yama Raja': _ElswordJobLook(
    palette: '黑色 × 深紫色 × 金色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail(
          '黑紫冥王戰袍', 'black and dark purple yama raja battle robe'),
      _ElswordStyleDetail('金色鬼面飾件', 'gold oni-mask ornaments'),
      _ElswordStyleDetail('重疊腰封', 'layered waist sash'),
    ],
  ),
  'Devi': _ElswordJobLook(
    palette: '深紅色 × 黑色 × 金色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('深紅帝魔長袍', 'dark red devi robe'),
      _ElswordStyleDetail('黑金戰甲飾邊', 'black and gold armor trim'),
      _ElswordStyleDetail('惡魔花紋', 'demon-pattern ornaments'),
    ],
  ),
  'Little Specter': _ElswordJobLook(
    palette: '白色 × 藍色 × 粉紅色',
    hairTags: ['high ponytail', 'hair ribbon'],
    details: [
      _ElswordStyleDetail('白藍靈狐術士服', 'white and blue fox spirit outfit'),
      _ElswordStyleDetail('粉紅符紙飾品', 'pink talisman ornaments'),
      _ElswordStyleDetail('短斗篷', 'capelet'),
    ],
  ),
  'Asura': _ElswordJobLook(
    palette: '黑色 × 藍色 × 銀色',
    hairTags: ['long hair', 'side braid'],
    details: [
      _ElswordStyleDetail('黑藍修羅戰鬥服', 'black and blue asura battle outfit'),
      _ElswordStyleDetail('銀色狐火飾邊', 'silver foxfire trim'),
      _ElswordStyleDetail('不對稱護甲', 'asymmetrical armor'),
    ],
  ),
  'Shakti': _ElswordJobLook(
    palette: '白色 × 金色 × 粉紅色',
    hairTags: ['very long hair', 'wavy hair'],
    details: [
      _ElswordStyleDetail('白金夏克提長袍', 'white and gold shakti robe'),
      _ElswordStyleDetail('粉紅靈狐飄帶', 'pink fox spirit ribbons'),
      _ElswordStyleDetail('寶石腰飾', 'gemstone waist ornaments'),
    ],
  ),
  'Little Helper': _ElswordJobLook(
    palette: '白色 × 綠色 × 金色',
    hairTags: ['long hair', 'twin braids'],
    details: [
      _ElswordStyleDetail('白綠靈獸使服', 'white and green spirit keeper outfit'),
      _ElswordStyleDetail('金色護符飾件', 'gold talisman ornaments'),
      _ElswordStyleDetail('分層短袍', 'layered cropped robe'),
    ],
  ),
  'Marici': _ElswordJobLook(
    palette: '珊瑚色 × 白色 × 金色',
    hairTags: ['long hair', 'side ponytail'],
    details: [
      _ElswordStyleDetail('珊瑚白摩利西亞套裝', 'coral and white marici outfit'),
      _ElswordStyleDetail('金色靈獸紋飾', 'gold sacred beast ornaments'),
      _ElswordStyleDetail('長版袖飾', 'long sleeve ornaments'),
    ],
  ),
  'Surya': _ElswordJobLook(
    palette: '白色 × 金色 × 橘色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('白金蘇利耶禮服', 'white and gold surya robe'),
      _ElswordStyleDetail('橘金日輪飾品', 'orange and gold sun-disc ornaments'),
      _ElswordStyleDetail('長披肩', 'long shoulder mantle'),
    ],
  ),
};

const _elesisLooks = <String, _ElswordJobLook>{
  'Saber Knight': _ElswordJobLook(
    palette: '紅色 × 銀色 × 黑色',
    hairTags: ['high ponytail'],
    details: [
      _ElswordStyleDetail('紅銀軍刀騎士裝甲', 'red and silver saber knight armor'),
      _ElswordStyleDetail('黑色短披風', 'black capelet'),
      _ElswordStyleDetail('金屬護腕', 'metal bracers'),
    ],
  ),
  'Grand Master': _ElswordJobLook(
    palette: '白色 × 金色 × 紅色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('白金大師騎士裝甲', 'white and gold grand master armor'),
      _ElswordStyleDetail('紅色披風', 'red knight cape'),
      _ElswordStyleDetail('皇家徽章', 'royal emblem'),
    ],
  ),
  'Empire Sword': _ElswordJobLook(
    palette: '黑色 × 深紅色 × 金色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('黑紅帝國之劍裝甲', 'black and dark red empire sword armor'),
      _ElswordStyleDetail('金色軍裝飾邊', 'gold military trim'),
      _ElswordStyleDetail('長披風', 'long cape'),
    ],
  ),
  'Pyro Knight': _ElswordJobLook(
    palette: '黑色 × 橘色 × 紅色',
    hairTags: ['high ponytail'],
    details: [
      _ElswordStyleDetail('黑橘烈焰騎士裝甲', 'black and orange pyro knight armor'),
      _ElswordStyleDetail('火焰紋飾邊', 'flame-pattern trim'),
      _ElswordStyleDetail('護肩鎧甲', 'armored pauldrons'),
    ],
  ),
  'Blazing Heart': _ElswordJobLook(
    palette: '紅色 × 黑色 × 金色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail(
          '紅黑熾炎之心戰衣', 'red and black blazing heart battle outfit'),
      _ElswordStyleDetail('金色火焰飾件', 'gold flame ornaments'),
      _ElswordStyleDetail('貼身護甲馬甲', 'fitted armor bodice'),
    ],
  ),
  'Flame Lord': _ElswordJobLook(
    palette: '深紅色 × 黑色 × 橘色',
    hairTags: ['very long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('深紅炎之領主裝甲', 'dark red flame lord armor'),
      _ElswordStyleDetail('黑色熔岩披風', 'black lava-pattern cape'),
      _ElswordStyleDetail('橘色火焰飾邊', 'orange flame trim'),
    ],
  ),
  'Dark Knight': _ElswordJobLook(
    palette: '黑色 × 紫色 × 銀色',
    hairTags: ['long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('黑紫暗黑騎士裝甲', 'black and purple dark knight armor'),
      _ElswordStyleDetail('銀色尖刺飾件', 'silver spiked ornaments'),
      _ElswordStyleDetail('暗色長披風', 'dark long cape'),
    ],
  ),
  'Crimson Avenger': _ElswordJobLook(
    palette: '黑色 × 深紅色 × 銀色',
    hairTags: ['long hair', 'messy hair'],
    details: [
      _ElswordStyleDetail(
          '黑紅緋紅復仇者戰衣', 'black and dark red crimson avenger outfit'),
      _ElswordStyleDetail('銀色束帶護甲', 'silver strapped armor'),
      _ElswordStyleDetail('破損披風', 'tattered cape'),
    ],
  ),
  'Bloody Queen': _ElswordJobLook(
    palette: '黑色 × 血紅色 × 金色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('黑紅血腥女王禮服', 'black and blood-red bloody queen dress'),
      _ElswordStyleDetail('金色王冠飾件', 'gold crown ornaments'),
      _ElswordStyleDetail('裝甲裙襬', 'armored skirt panels'),
    ],
  ),
  'Soar Knight': _ElswordJobLook(
    palette: '海軍藍 × 銀色 × 白色',
    hairTags: ['high ponytail'],
    details: [
      _ElswordStyleDetail('藍銀飛空騎士裝甲', 'navy and silver soar knight armor'),
      _ElswordStyleDetail('白色長披風', 'white long cape'),
      _ElswordStyleDetail('藍色寶石護甲', 'blue gemstone armor'),
    ],
  ),
  'Patrona': _ElswordJobLook(
    palette: '白色 × 藍色 × 金色',
    hairTags: ['long hair', 'side ponytail'],
    details: [
      _ElswordStyleDetail('白藍帕特羅娜騎士裝', 'white and blue patrona knight outfit'),
      _ElswordStyleDetail('金色記憶徽章', 'gold memory emblem'),
      _ElswordStyleDetail('精緻肩甲', 'ornate shoulder armor'),
    ],
  ),
  'Adrestia': _ElswordJobLook(
    palette: '白色 × 藍色 × 銀色',
    hairTags: ['very long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('白藍阿德雷斯緹亞裝甲', 'white and blue adrestia armor'),
      _ElswordStyleDetail('發光藍色左臂護甲', 'glowing blue left-arm armor'),
      _ElswordStyleDetail('銀色聖劍飾件', 'silver holy-sword ornaments'),
      _ElswordStyleDetail('長版王族披風', 'long royal cape'),
    ],
  ),
};

/// Rose's eight second / third-job references.  Weapons intentionally stay in
/// the optional equipment catalog, not in these clothing phrases.
const _roseLooks = <String, _ElswordJobLook>{
  'Storm Trooper': _ElswordJobLook(
    palette: '海軍藍 × 黑色 × 銀色',
    hairTags: ['blonde hair', 'blue eyes', 'blue hair ribbon'],
    details: [
      _ElswordStyleDetail('風暴神兵・重砲軍裝',
          'navy and black heavy artillery uniform, fitted military bodysuit, armored chest plate'),
      _ElswordStyleDetail('風暴神兵・外套與護臂',
          'navy military coat, black armored gloves, mechanical arm guards'),
      _ElswordStyleDetail('風暴神兵・下身與靴子',
          'black tactical legwear, navy thigh boots, silver buckles'),
      _ElswordStyleDetail(
          '風暴神兵・機械裝置', 'utility belt, artillery harness, metallic insignia'),
    ],
  ),
  'Tempest Burster': _ElswordJobLook(
    palette: '深藍色 × 黑色 × 銀色',
    hairTags: ['blonde hair', 'blue eyes', 'blue hair ribbon'],
    details: [
      _ElswordStyleDetail('暴風破壞者・重砲戰衣',
          'dark navy and black railgunner outfit, fitted armored bodysuit, silver chest armor'),
      _ElswordStyleDetail('暴風破壞者・軍裝外套',
          'long navy military coat, reinforced shoulder armor, black gloves'),
      _ElswordStyleDetail('暴風破壞者・腿部與靴子',
          'black armored legwear, navy high boots, silver boot guards'),
      _ElswordStyleDetail('暴風破壞者・火力裝置',
          'artillery harness, ammo belt, glowing blue mechanical accents'),
    ],
  ),
  'Crimson Rose': _ElswordJobLook(
    palette: '黑色 × 深紅色 × 金色',
    hairTags: ['blonde hair', 'blue eyes', 'red hair ribbon'],
    details: [
      _ElswordStyleDetail('血色玫瑰・暗殺戰衣',
          'black and crimson assassin bodysuit, fitted corset, dark red chest armor'),
      _ElswordStyleDetail(
          '血色玫瑰・外套與手套', 'crimson long coat, black gloves, chain accessories'),
      _ElswordStyleDetail('血色玫瑰・腿部與鞋履',
          'black thighhighs, crimson garter straps, black high heel boots'),
      _ElswordStyleDetail('血色玫瑰・血色飾件',
          'rose emblem, crimson gemstone ornaments, dark red ribbons'),
    ],
  ),
  'Black Massacre': _ElswordJobLook(
    palette: '黑色 × 深紅色 × 銀色',
    hairTags: ['blonde hair', 'blue eyes', 'black hat', 'hair over one eye'],
    details: [
      _ElswordStyleDetail('黑色屠殺者・暗黑戰衣',
          'black assassin bodysuit, dark crimson corset, fitted black vest'),
      _ElswordStyleDetail(
          '黑色屠殺者・大衣與手套', 'black long coat, black gloves, chain decorations'),
      _ElswordStyleDetail('黑色屠殺者・腿部與鞋履',
          'black thighhighs, black thigh boots, silver ankle straps'),
      _ElswordStyleDetail('黑色屠殺者・暗紅飾件',
          'dark red ribbons, silver tassels, black rose ornaments'),
    ],
  ),
  'Freyja': _ElswordJobLook(
    palette: '白色 × 藍色 × 金色',
    hairTags: ['blonde hair', 'blue eyes', 'blue hair ribbon'],
    details: [
      _ElswordStyleDetail('芙蕾雅・爆破軍裝',
          'white and blue valkyrie gunner outfit, fitted armored bodice, gold chest emblem'),
      _ElswordStyleDetail('芙蕾雅・外套與護臂',
          'white military coat, blue armored sleeves, black gloves'),
      _ElswordStyleDetail(
          '芙蕾雅・腿部與靴子', 'blue leg guards, white thigh boots, gold boot armor'),
      _ElswordStyleDetail(
          '芙蕾雅・戰場飾件', 'wing motif, gold belt, blue energy accents'),
    ],
  ),
  'Minerva': _ElswordJobLook(
    palette: '白色 × 天藍色 × 金色',
    hairTags: ['blonde hair', 'blue eyes', 'blue hair ribbon'],
    details: [
      _ElswordStyleDetail('密涅瓦・空戰軍裝',
          'white and sky blue aerial gunner suit, fitted armored bodice, gold chest emblem'),
      _ElswordStyleDetail(
          '密涅瓦・披風與護臂', 'blue capelet, white armored sleeves, black gloves'),
      _ElswordStyleDetail(
          '密涅瓦・腿部與靴子', 'sky blue leg guards, white high boots, gold buckles'),
      _ElswordStyleDetail('密涅瓦・機械翼飾件',
          'mechanical wing pack, blue energy accents, metallic insignia'),
    ],
  ),
  'Optimus': _ElswordJobLook(
    palette: '白色 × 青綠色 × 黑色',
    hairTags: ['blonde hair', 'blue eyes', 'goggles'],
    details: [
      _ElswordStyleDetail('終極武器・機械工戰衣',
          'white and teal mechanic outfit, fitted black bodysuit, teal chest armor'),
      _ElswordStyleDetail('終極武器・外套與手套',
          'white cropped jacket, mechanical gauntlets, black gloves'),
      _ElswordStyleDetail('終極武器・腿部與靴子',
          'black mechanical legwear, white armored boots, teal boot lights'),
      _ElswordStyleDetail(
          '終極武器・機械飾件', 'tool belt, mechanical backpack, teal circuit accents'),
    ],
  ),
  'Prime Operator': _ElswordJobLook(
    palette: '白色 × 黑色 × 青綠色',
    hairTags: ['blonde hair', 'blue eyes', 'goggles'],
    details: [
      _ElswordStyleDetail('第一原質・指揮官戰衣',
          'white and black mech commander outfit, fitted armored bodice, teal chest lights'),
      _ElswordStyleDetail('第一原質・外套與護臂',
          'black command coat, white mechanical sleeves, control gloves'),
      _ElswordStyleDetail('第一原質・腿部與靴子',
          'black armored legwear, white mechanical boots, teal boot lights'),
      _ElswordStyleDetail('第一原質・機械軍團飾件',
          'command headset, mechanical backpack, teal circuit ornaments'),
    ],
  ),
};

/// Laby's job outfits keep all class appearance phrases bundled with the
/// selected class.  No age-related wording is emitted into prompts.
const _labyLooks = <String, _ElswordJobLook>{
  'Rumble Pumn': _ElswordJobLook(
    palette: '粉紅色 × 海軍藍 × 白色',
    hairTags: ['pink hair', 'pink eyes', 'ahoge', 'hair ornament'],
    details: [
      _ElswordStyleDetail('喧嘩拳擊者・拳擊戰衣',
          'pink and navy fighter outfit, fitted top, white chest bow'),
      _ElswordStyleDetail('喧嘩拳擊者・護臂與袖套',
          'navy detached sleeves, pink wrist wraps, padded arm guards'),
      _ElswordStyleDetail('喧嘩拳擊者・下身與靴子',
          'pink pleated skirt, navy legwear, white lace-up boots'),
      _ElswordStyleDetail('喧嘩拳擊者・活力飾件',
          'heart motif, striped ribbons, blue gemstone ornaments'),
    ],
  ),
  'Eternity Winner': _ElswordJobLook(
    palette: '深藍色 × 粉紅色 × 白色',
    hairTags: ['pink hair', 'pink eyes', 'ahoge', 'hair ornament'],
    details: [
      _ElswordStyleDetail('永恆勝利者・冠軍戰衣',
          'dark blue and pink champion outfit, fitted bodice, white chest bow'),
      _ElswordStyleDetail('永恆勝利者・護臂與袖套',
          'white detached sleeves, dark blue arm guards, pink wrist ribbons'),
      _ElswordStyleDetail('永恆勝利者・下身與靴子',
          'layered pink skirt, dark blue legwear, white high boots'),
      _ElswordStyleDetail(
          '永恆勝利者・冠軍飾件', 'star motif, blue energy accents, ornate ribbons'),
    ],
  ),
  'Shining Romantica': _ElswordJobLook(
    palette: '白色 × 粉紅色 × 金色',
    hairTags: ['pink hair', 'pink eyes', 'ahoge', 'hair ornament'],
    details: [
      _ElswordStyleDetail('光耀浪漫者・華麗洋裝',
          'white and pink magical dress, fitted bodice, gold chest ornament'),
      _ElswordStyleDetail('光耀浪漫者・袖套與披肩',
          'pink detached sleeves, white shoulder shawl, long ribbon sleeves'),
      _ElswordStyleDetail(
          '光耀浪漫者・裙襬與鞋履', 'layered white skirt, pink frills, white ankle boots'),
      _ElswordStyleDetail('光耀浪漫者・浪漫飾件',
          'heart motif, gold gemstone ornaments, large pink bows'),
    ],
  ),
  'Radiant Soul': _ElswordJobLook(
    palette: '白色 × 淺藍色 × 金色',
    hairTags: ['pink hair', 'pink eyes', 'ahoge', 'hair ornament'],
    details: [
      _ElswordStyleDetail('星耀魂靈者・光輝洋裝',
          'white and light blue radiant dress, fitted bodice, gold chest ornament'),
      _ElswordStyleDetail('星耀魂靈者・袖套與披肩',
          'light blue detached sleeves, white shoulder shawl, flowing ribbon sleeves'),
      _ElswordStyleDetail('星耀魂靈者・裙襬與鞋履',
          'layered white skirt, light blue frills, white high boots'),
      _ElswordStyleDetail(
          '星耀魂靈者・星光飾件', 'star motif, radiant crystal ornaments, gold ribbons'),
    ],
  ),
  'Daydreamer': _ElswordJobLook(
    palette: '黑色 × 紫色 × 粉紅色',
    hairTags: ['pink hair', 'pink eyes', 'ahoge', 'hair ornament'],
    details: [
      _ElswordStyleDetail('空想幻夢者・夢境洋裝',
          'black and purple dream dress, fitted bodice, pink chest ribbons'),
      _ElswordStyleDetail('空想幻夢者・袖套與披肩',
          'purple detached sleeves, black shoulder shawl, flowing ribbons'),
      _ElswordStyleDetail('空想幻夢者・裙襬與鞋履',
          'layered black skirt, purple frills, black lace-up boots'),
      _ElswordStyleDetail('空想幻夢者・夢境飾件',
          'dream cloud motif, purple crystal ornaments, dark ribbons'),
    ],
  ),
  'Nisha Labyrinth': _ElswordJobLook(
    palette: '黑色 × 深紫色 × 灰色',
    hairTags: ['pink hair', 'pink eyes', 'ahoge', 'hair ornament'],
    details: [
      _ElswordStyleDetail('夜暝魂夢者・迷宮洋裝',
          'black and dark purple gothic dress, fitted bodice, gray chest ribbons'),
      _ElswordStyleDetail('夜暝魂夢者・袖套與披風',
          'dark detached sleeves, black hooded cape, layered ribbon sleeves'),
      _ElswordStyleDetail('夜暝魂夢者・裙襬與鞋履',
          'layered black skirt, dark purple frills, black high boots'),
      _ElswordStyleDetail(
          '夜暝魂夢者・暗影飾件', 'shadow motif, dark crystal ornaments, black ribbons'),
    ],
  ),
  'Punky Poppet': _ElswordJobLook(
    palette: '黑色 × 熱粉紅色 × 白色',
    hairTags: ['pink hair', 'pink eyes', 'ahoge', 'hair ornament'],
    details: [
      _ElswordStyleDetail('甜心劫掠者・龐克洋裝',
          'black and hot pink punk dress, fitted bodice, white chest bow'),
      _ElswordStyleDetail('甜心劫掠者・袖套與手套',
          'striped detached sleeves, black fingerless gloves, pink wrist ribbons'),
      _ElswordStyleDetail('甜心劫掠者・裙襬與鞋履',
          'layered punk skirt, striped legwear, black lace-up boots'),
      _ElswordStyleDetail(
          '甜心劫掠者・龐克飾件', 'chain accessories, heart motif, hot pink ribbons'),
    ],
  ),
  'Twins Picaro': _ElswordJobLook(
    palette: '黑色 × 紅色 × 白色',
    hairTags: ['pink hair', 'pink eyes', 'ahoge', 'hair ornament'],
    details: [
      _ElswordStyleDetail('雙珠邪魅者・小丑洋裝',
          'black red and white harlequin dress, asymmetrical bodice, striped chest bow'),
      _ElswordStyleDetail('雙珠邪魅者・袖套與手套',
          'mismatched detached sleeves, black gloves, red wrist ribbons'),
      _ElswordStyleDetail('雙珠邪魅者・裙襬與鞋履',
          'asymmetrical layered skirt, striped legwear, black buckle boots'),
      _ElswordStyleDetail('雙珠邪魅者・戲法飾件',
          'playing-card motif, jester ornaments, red and white ribbons'),
    ],
  ),
};

/// Lithia's official paths use gemstone, relic, and rift motifs.  Each block
/// provides the class silhouette, while her pickaxe-like weapons stay optional.
const _lithiaLooks = <String, _ElswordJobLook>{
  'Mighty Miner': _ElswordJobLook(
    palette: '綠色 × 黑色 × 金色',
    hairTags: ['grey hair', 'green eyes', 'long hair', 'ponytail', 'ahoge'],
    details: [
      _ElswordStyleDetail('強力礦工・礦工戰衣',
          'green and black relic miner outfit, fitted top, gold chest ornament'),
      _ElswordStyleDetail('強力礦工・護臂與外套',
          'black mechanical sleeves, green arm guards, utility belt'),
      _ElswordStyleDetail('強力礦工・下身與靴子',
          'black fitted pants, green knee guards, black armored boots'),
      _ElswordStyleDetail('強力礦工・礦石飾件',
          'goggles, gemstone ornaments, metallic mining accessories'),
    ],
  ),
  'Gembliss': _ElswordJobLook(
    palette: '綠色 × 黑色 × 青綠色',
    hairTags: ['grey hair', 'green eyes', 'long hair', 'ponytail', 'ahoge'],
    details: [
      _ElswordStyleDetail('寶石極樂・高科技戰衣',
          'green and black high-tech miner outfit, fitted cropped top, teal chest lights'),
      _ElswordStyleDetail('寶石極樂・機械護臂',
          'oversized mechanical sleeves, black arm guards, green circuit accents'),
      _ElswordStyleDetail('寶石極樂・下身與靴子',
          'black fitted pants, green thigh guards, high-tech armored boots'),
      _ElswordStyleDetail('寶石極樂・寶石飾件',
          'goggles, floating gemstone ornaments, metallic ribbons'),
    ],
  ),
  'Greedy Wonder': _ElswordJobLook(
    palette: '白色 × 綠色 × 金色',
    hairTags: ['grey hair', 'green eyes', 'long hair', 'ponytail', 'ahoge'],
    details: [
      _ElswordStyleDetail('貪心神醫・療癒術士裝',
          'white and green healer outfit, fitted bodice, gold chest ornament'),
      _ElswordStyleDetail('貪心神醫・披肩與袖套',
          'white capelet, green detached sleeves, gold arm bands'),
      _ElswordStyleDetail(
          '貪心神醫・裙襬與鞋履', 'white layered skirt, green legwear, white high boots'),
      _ElswordStyleDetail(
          '貪心神醫・寶石飾件', 'gemstone brooch, gold belt, healing crystal ornaments'),
    ],
  ),
  'Avarice': _ElswordJobLook(
    palette: '白色 × 祖母綠色 × 金色',
    hairTags: ['grey hair', 'green eyes', 'long hair', 'ponytail', 'ahoge'],
    details: [
      _ElswordStyleDetail('極欲饕餮・華麗術士裝',
          'white and emerald green ornate healer dress, fitted bodice, gold chest ornament'),
      _ElswordStyleDetail('極欲饕餮・披肩與袖套',
          'white shoulder cape, emerald detached sleeves, gold arm bands'),
      _ElswordStyleDetail('極欲饕餮・裙襬與鞋履',
          'layered white skirt, emerald legwear, white high boots'),
      _ElswordStyleDetail('極欲饕餮・財寶飾件',
          'gold gemstone ornaments, ornate belt, floating crystal charms'),
    ],
  ),
  'Rima Clavis': _ElswordJobLook(
    palette: '黑色 × 青綠色 × 銀色',
    hairTags: ['grey hair', 'green eyes', 'long hair', 'ponytail', 'ahoge'],
    details: [
      _ElswordStyleDetail('律法之鑰・裂隙探索裝',
          'black and teal rift explorer outfit, fitted armored top, silver chest ornament'),
      _ElswordStyleDetail('律法之鑰・外套與護臂',
          'black asymmetrical coat, teal arm guards, silver gloves'),
      _ElswordStyleDetail('律法之鑰・下身與靴子',
          'black fitted pants, teal thigh straps, black armored boots'),
      _ElswordStyleDetail('律法之鑰・裂隙飾件',
          'dimensional key motif, teal crystal ornaments, rift energy accents'),
    ],
  ),
  'Achlys': _ElswordJobLook(
    palette: '黑色 × 酸橙綠色 × 紫色',
    hairTags: ['grey hair', 'green eyes', 'long hair', 'ponytail', 'ahoge'],
    details: [
      _ElswordStyleDetail('阿克莉絲・混沌裂隙裝',
          'black and lime green chaos rift outfit, fitted armored top, purple chest gem'),
      _ElswordStyleDetail(
          '阿克莉絲・外套與護臂', 'black split coat, lime green arm guards, dark gloves'),
      _ElswordStyleDetail('阿克莉絲・下身與靴子',
          'black fitted pants, lime green leg guards, black high boots'),
      _ElswordStyleDetail('阿克莉絲・混沌飾件',
          'fractured crystal ornaments, rift ribbons, purple energy accents'),
    ],
  ),
  'Cynical Sneer': _ElswordJobLook(
    palette: '黑色 × 紫色 × 酒紅色',
    hairTags: ['grey hair', 'green eyes', 'long hair', 'ponytail', 'ahoge'],
    details: [
      _ElswordStyleDetail('諷世愚者・惡魔術士裝',
          'black and purple trickster outfit, fitted bodice, burgundy chest ribbon'),
      _ElswordStyleDetail('諷世愚者・披肩與袖套',
          'black asymmetrical cape, purple detached sleeves, dark gloves'),
      _ElswordStyleDetail('諷世愚者・下身與靴子',
          'black layered skirt, purple legwear, black buckle boots'),
      _ElswordStyleDetail('諷世愚者・惡魔飾件',
          'demonic crystal ornaments, crescent motif, burgundy ribbons'),
    ],
  ),
  'Mischief': _ElswordJobLook(
    palette: '黑色 × 紫色 × 紅色',
    hairTags: ['grey hair', 'green eyes', 'long hair', 'ponytail', 'ahoge'],
    details: [
      _ElswordStyleDetail('惡戲奇術師・詭術洋裝',
          'black purple and red trickster dress, asymmetrical bodice, dark chest ribbons'),
      _ElswordStyleDetail('惡戲奇術師・披肩與袖套',
          'black hooded cape, purple detached sleeves, red gloves'),
      _ElswordStyleDetail('惡戲奇術師・裙襬與鞋履',
          'asymmetrical layered skirt, black legwear, black buckle boots'),
      _ElswordStyleDetail('惡戲奇術師・惡作劇飾件',
          'demonic gemstone ornaments, playing-card motif, red ribbons'),
    ],
  ),
};

/// Lu/Ciel's second and third jobs are designed as complete paired silhouettes.
/// The class card keeps Lu's visible head profile with the one-piece costume
/// description, while the paired class weapon remains an optional object tag.
const _lucielaLooks = <String, _ElswordJobLook>{
  'Dreadlord': _ElswordJobLook(
    palette: '深藍色 × 黑色 × 青藍色 × 白色',
    hairTags: ['white hair', 'long hair', 'blue eyes', 'demon horns'],
    details: [
      _ElswordStyleDetail('邪恐夜皇・惡魔戰衣',
          'black and navy demon regalia, fitted military coat, cyan trim'),
      _ElswordStyleDetail('邪恐夜皇・肩甲與袖套',
          'black armored pauldrons, detached sleeves, dark leather gloves'),
      _ElswordStyleDetail('邪恐夜皇・下身與靴履',
          'layered navy skirt, black thighhighs, black armored boots'),
      _ElswordStyleDetail('邪恐夜皇・王權飾件',
          'cyan gemstone ornaments, silver buckles, chain accessories, demon crest'),
    ],
  ),
  'Catastrophe': _ElswordJobLook(
    palette: '黑色 × 深藍色 × 洋紅色 × 青藍色',
    hairTags: ['white hair', 'long hair', 'blue eyes', 'demon horns'],
    details: [
      _ElswordStyleDetail('災禍魔王・惡魔王裝',
          'black and dark navy demon royal outfit, magenta accents, fitted bodice'),
      _ElswordStyleDetail('災禍魔王・披風與袖套',
          'long asymmetric coat panels, black detached sleeves, dark gloves'),
      _ElswordStyleDetail('災禍魔王・裙襬與靴履',
          'layered black skirt, magenta cape panels, black high boots'),
      _ElswordStyleDetail('災禍魔王・魔王飾件',
          'demon crown, bat wing motif, cyan crystal ornaments, dark chains'),
    ],
  ),
  'Noblesse': _ElswordJobLook(
    palette: '白色 × 深藍色 × 青藍色 × 黑色',
    hairTags: ['white hair', 'very long hair', 'blue eyes', 'pointed ears'],
    details: [
      _ElswordStyleDetail('闇夜女爵・王族禮裝',
          'white and navy royal dress, dark fitted bodice, cyan trim'),
      _ElswordStyleDetail('闇夜女爵・披肩與袖套',
          'navy shoulder cape, black detached sleeves, white gloves'),
      _ElswordStyleDetail('闇夜女爵・裙襬與靴履',
          'layered navy skirt, black thighhighs, dark blue armored boots'),
      _ElswordStyleDetail('闇夜女爵・王室飾件',
          'royal crest, floating white ribbons, cyan crystal ornaments, silver chains'),
    ],
  ),
  'Innocent': _ElswordJobLook(
    palette: '白色 × 深藍色 × 青藍色 × 黑色',
    hairTags: ['white hair', 'very long hair', 'blue eyes', 'demon horns'],
    details: [
      _ElswordStyleDetail('釋罪女皇・雙生王裝',
          'white black and navy royal outfit, star motif, cyan trim'),
      _ElswordStyleDetail('釋罪女皇・披風與手套',
          'white cape panels, navy detached sleeves, black gloves'),
      _ElswordStyleDetail('釋罪女皇・下身與靴履',
          'layered navy skirt, white legwear, dark blue high boots'),
      _ElswordStyleDetail('釋罪女皇・幻影飾件',
          'floating ribbon ornaments, cyan star crystals, silver chains, abyss crest'),
    ],
  ),
  'Demonio': _ElswordJobLook(
    palette: '黑色 × 深藍色 × 青藍色 × 白色',
    hairTags: ['white hair', 'long hair', 'blue eyes', 'large demon horns'],
    details: [
      _ElswordStyleDetail('冷焰邪魔・惡魔裝甲',
          'black and dark navy demon armor, cyan glowing accents, fitted bodice'),
      _ElswordStyleDetail('冷焰邪魔・外套與袖套',
          'long split black coat, armored detached sleeves, dark gloves'),
      _ElswordStyleDetail('冷焰邪魔・下身與靴履',
          'black layered skirt, blue thighhighs, black armored high boots'),
      _ElswordStyleDetail('冷焰邪魔・冷焰飾件',
          'blue flame ornaments, demon crest, black chains, cyan crystal details'),
    ],
  ),
  'Diangelion': _ElswordJobLook(
    palette: '黑色 × 深藍色 × 青藍色 × 白色',
    hairTags: ['white hair', 'long hair', 'blue eyes', 'large demon horns'],
    details: [
      _ElswordStyleDetail('滅盡魔皇・毀滅戰衣',
          'black torn demon armor, cyan glowing edges, fitted bodice'),
      _ElswordStyleDetail('滅盡魔皇・披風與護臂',
          'ragged black cape, armored detached sleeves, clawed gloves'),
      _ElswordStyleDetail('滅盡魔皇・下身與靴履',
          'black layered skirt, dark legwear, black armored boots'),
      _ElswordStyleDetail('滅盡魔皇・深淵飾件',
          'abyssal chains, dark feather ornaments, cyan crystal details, demon crest'),
    ],
  ),
  'Turbids': _ElswordJobLook(
    palette: '白色 × 深藍色 × 青藍色 × 銀色',
    hairTags: ['white hair', 'long hair', 'blue eyes', 'pointed ears'],
    details: [
      _ElswordStyleDetail('混濁影靈・深淵禮裝',
          'white and navy abyss regalia, dark blue fitted bodice, silver trim'),
      _ElswordStyleDetail('混濁影靈・披肩與袖套',
          'white shoulder cape, navy detached sleeves, dark gloves'),
      _ElswordStyleDetail('混濁影靈・裙襬與靴履',
          'layered navy skirt, white legwear, dark blue high boots'),
      _ElswordStyleDetail('混濁影靈・靈魂飾件',
          'blue crystal ornaments, silver chains, abyss crest, floating ribbons'),
    ],
  ),
  'Demersio': _ElswordJobLook(
    palette: '白色 × 黑色 × 深藍色 × 銀色',
    hairTags: ['white hair', 'long hair', 'blue eyes', 'demon horns'],
    details: [
      _ElswordStyleDetail('深淵魔君・深淵王裝',
          'white black and navy abyss outfit, fitted armored bodice, silver trim'),
      _ElswordStyleDetail('深淵魔君・披風與袖套',
          'black asymmetric cape, white ruffled sleeves, dark gloves'),
      _ElswordStyleDetail('深淵魔君・下身與靴履',
          'layered navy skirt, white legwear, dark armored boots'),
      _ElswordStyleDetail('深淵魔君・魔君飾件',
          'abyssal wing motif, dark chains, silver crystal ornaments, demon crest'),
    ],
  ),
};

const _elswordJobs = <_ElswordJobOutfit>[
  _ElswordJobOutfit('愛莎', 'Aisha', '元素魔導', 'Elemental Master'),
  _ElswordJobOutfit('愛莎', 'Aisha', '乙太魔導', 'Aether Sage'),
  _ElswordJobOutfit('愛莎', 'Aisha', '虛無公主', 'Void Princess'),
  _ElswordJobOutfit('愛莎', 'Aisha', '奧茲魔導', 'Oz Sorcerer'),
  _ElswordJobOutfit('愛莎', 'Aisha', '次元魔女', 'Dimension Witch'),
  _ElswordJobOutfit('愛莎', 'Aisha', '星光魔女', 'Metamorphy'),
  _ElswordJobOutfit('愛莎', 'Aisha', '真理術士', 'Mystic Alchemist'),
  _ElswordJobOutfit('愛莎', 'Aisha', '萬靈賢者', 'Lord Azoth'),
  _ElswordJobOutfit('蘿潔', 'Rose', '風暴神兵', 'Storm Trooper'),
  _ElswordJobOutfit('蘿潔', 'Rose', '暴風破壞者', 'Tempest Burster'),
  _ElswordJobOutfit('蘿潔', 'Rose', '血色玫瑰', 'Crimson Rose'),
  _ElswordJobOutfit('蘿潔', 'Rose', '黑色屠殺者', 'Black Massacre'),
  _ElswordJobOutfit('蘿潔', 'Rose', '芙蕾雅', 'Freyja'),
  _ElswordJobOutfit('蘿潔', 'Rose', '密涅瓦', 'Minerva'),
  _ElswordJobOutfit('蘿潔', 'Rose', '終極武器', 'Optimus'),
  _ElswordJobOutfit('蘿潔', 'Rose', '第一原質', 'Prime Operator'),
  _ElswordJobOutfit('菈比', 'Laby', '喧嘩拳擊者', 'Rumble Pumn'),
  _ElswordJobOutfit('菈比', 'Laby', '永恆勝利者', 'Eternity Winner'),
  _ElswordJobOutfit('菈比', 'Laby', '光耀浪漫者', 'Shining Romantica'),
  _ElswordJobOutfit('菈比', 'Laby', '星耀魂靈者', 'Radiant Soul'),
  _ElswordJobOutfit('菈比', 'Laby', '空想幻夢者', 'Daydreamer'),
  _ElswordJobOutfit('菈比', 'Laby', '夜暝魂夢者', 'Nisha Labyrinth'),
  _ElswordJobOutfit('菈比', 'Laby', '甜心劫掠者', 'Punky Poppet'),
  _ElswordJobOutfit('菈比', 'Laby', '雙珠邪魅者', 'Twins Picaro'),
  _ElswordJobOutfit('莉緹亞', 'Lithia', '強力礦工', 'Mighty Miner'),
  _ElswordJobOutfit('莉緹亞', 'Lithia', '寶石極樂', 'Gembliss'),
  _ElswordJobOutfit('莉緹亞', 'Lithia', '貪心神醫', 'Greedy Wonder'),
  _ElswordJobOutfit('莉緹亞', 'Lithia', '極欲饕餮', 'Avarice'),
  _ElswordJobOutfit('莉緹亞', 'Lithia', '律法之鑰', 'Rima Clavis'),
  _ElswordJobOutfit('莉緹亞', 'Lithia', '阿克莉絲', 'Achlys'),
  _ElswordJobOutfit('莉緹亞', 'Lithia', '諷世愚者', 'Cynical Sneer'),
  _ElswordJobOutfit('莉緹亞', 'Lithia', '惡戲奇術師', 'Mischief'),
  _ElswordJobOutfit('露・希爾', 'Luciela', '邪恐夜皇', 'Dreadlord'),
  _ElswordJobOutfit('露・希爾', 'Luciela', '災禍魔王', 'Catastrophe'),
  _ElswordJobOutfit('露・希爾', 'Luciela', '闇夜女爵', 'Noblesse'),
  _ElswordJobOutfit('露・希爾', 'Luciela', '釋罪女皇', 'Innocent'),
  _ElswordJobOutfit('露・希爾', 'Luciela', '冷焰邪魔', 'Demonio'),
  _ElswordJobOutfit('露・希爾', 'Luciela', '滅盡魔皇', 'Diangelion'),
  _ElswordJobOutfit('露・希爾', 'Luciela', '混濁影靈', 'Turbids'),
  _ElswordJobOutfit('露・希爾', 'Luciela', '深淵魔君', 'Demersio'),
  _ElswordJobOutfit('蕾娜', 'Rena', '戰鬥遊俠', 'Combat Ranger'),
  _ElswordJobOutfit('蕾娜', 'Rena', '疾風之靴', 'Wind Sneaker'),
  _ElswordJobOutfit('蕾娜', 'Rena', '安涅莫斯', 'Anemos'),
  _ElswordJobOutfit('蕾娜', 'Rena', '狙擊遊俠', 'Sniping Ranger'),
  _ElswordJobOutfit('蕾娜', 'Rena', '大弓手', 'Grand Archer'),
  _ElswordJobOutfit('蕾娜', 'Rena', '破曉者', 'Daybreaker'),
  _ElswordJobOutfit('蕾娜', 'Rena', '陷阱遊俠', 'Trapping Ranger'),
  _ElswordJobOutfit('蕾娜', 'Rena', '夜行者', 'Night Watcher'),
  _ElswordJobOutfit('蕾娜', 'Rena', '暮光', 'Twilight'),
  _ElswordJobOutfit('蕾娜', 'Rena', '詩意遊俠', 'Poetic Ranger'),
  _ElswordJobOutfit('蕾娜', 'Rena', '說書人', 'Tale Spinner'),
  _ElswordJobOutfit('蕾娜', 'Rena', '預言者', 'Prophetess'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Exotic', 'Code: Exotic'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Nemesis', 'Code: Nemesis'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Ultimate', 'Code: Ultimate'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Architecture', 'Code: Architecture'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Empress', 'Code: Empress'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Esencia', 'Code: Esencia'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Electra', 'Code: Electra'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Battle Seraph', 'Code: Battle Seraph'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Sariel', 'Code: Sariel'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Unknown', 'Code: Unknown'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Failess', 'Code: Failess'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Antithese', 'Code: Antithese'),
  _ElswordJobOutfit('亞拉', 'Ara', '小仙', 'Little Hsien'),
  _ElswordJobOutfit('亞拉', 'Ara', '帝天', 'Sakra Devanam'),
  _ElswordJobOutfit('亞拉', 'Ara', '阿修羅', 'Apsara'),
  _ElswordJobOutfit('亞拉', 'Ara', '小魔', 'Little Devil'),
  _ElswordJobOutfit('亞拉', 'Ara', '冥王', 'Yama Raja'),
  _ElswordJobOutfit('亞拉', 'Ara', '帝魔', 'Devi'),
  _ElswordJobOutfit('亞拉', 'Ara', '小靈', 'Little Specter'),
  _ElswordJobOutfit('亞拉', 'Ara', '修羅', 'Asura'),
  _ElswordJobOutfit('亞拉', 'Ara', '修緹', 'Shakti'),
  _ElswordJobOutfit('亞拉', 'Ara', '小輔', 'Little Helper'),
  _ElswordJobOutfit('亞拉', 'Ara', '摩利西亞', 'Marici'),
  _ElswordJobOutfit('亞拉', 'Ara', '蘇利耶', 'Surya'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '劍騎士', 'Saber Knight'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '大師劍士', 'Grand Master'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '帝國之劍', 'Empire Sword'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '烈焰騎士', 'Pyro Knight'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '熾炎之心', 'Blazing Heart'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '火焰領主', 'Flame Lord'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '闇黑騎士', 'Dark Knight'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '緋紅復仇者', 'Crimson Avenger'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '血腥女王', 'Bloody Queen'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '飛空騎士', 'Soar Knight'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '帕特羅娜', 'Patrona'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '阿德雷斯緹亞', 'Adrestia'),
];

/// Main selectable garment for non-canonical jobs. Canonical second/third-job
/// sets are intentionally available only through their reference cards, so an
/// obsolete generic "Elsword ... official class outfit" phrase can never be
/// selected beside their documented class block.
final List<CatalogTagData> elswordJobOutfitTags =
    List<CatalogTagData>.unmodifiable(
  _elswordJobs
      .where((job) => !job.usesCanonicalJobProfile)
      .map((job) => CatalogTagData(
            id: job.id,
            group: '特殊服裝',
            zh: job.zh,
            en: job.en,
            order: 4,
            support: 'description',
          )),
);

/// Job-specific visible details. They are placed in the same costume prompt
/// parentheses as their selected job outfit, while remaining removable tags.
final List<CatalogTagData> elswordJobVisualDetailTags =
    List<CatalogTagData>.unmodifiable(
  <String, _ElswordStyleDetail>{
    for (final job in _elswordJobs)
      for (final detail in job.visualDetails) detail.en: detail,
  }.values.toList().asMap().entries.map((entry) => CatalogTagData(
        id: _elswordVisualDetailId(entry.value.en),
        group: elswordJobDetailGroupFor(entry.value.en),
        zh: entry.value.zh,
        en: entry.value.en,
        order: entry.key + 1,
        support: 'description',
      )),
);

/// Optional one-phrase weapons for the class-outfit cards. The Elemental
/// Master keeps its existing hand-authored staff phrase; every other job gets
/// its own model-facing weapon description and can be selected independently.
final List<CatalogTagData> elswordJobWeaponTags =
    List<CatalogTagData>.unmodifiable(
  _elswordJobs
      .where((job) => !job.usesElementalMasterStaff)
      .map((job) => CatalogTagData(
            id: job.weaponTagId,
            group: '物件',
            zh: job.weaponZh,
            en: job.weaponEn,
            order: 5,
            support: 'description',
          ))
      .toList(),
);

/// Complete built-in references. Each job is applied as one canonical outfit
/// phrase so the original silhouette is kept intact. Full-body wear/exposure
/// controls remain available after applying, while an optional class weapon is
/// shown next to the outfit card when the catalog contains one.
final List<OutfitReferencePresetData> elswordJobOutfitReferencePresets =
    List<OutfitReferencePresetData>.unmodifiable(
  _elswordJobs
      .map((job) => OutfitReferencePresetData(
            id: job.id,
            category: '艾爾之光・轉職服裝',
            name: job.zh,
            palette: job.look.palette,
            description:
                '套用 ${job.characterZh}・${job.jobZh} 的完整原作轉職服裝片語；可在套用後單獨保留或移除套裝輪廓、上身、下身、鞋襪、飾邊與配件。全身穿脫／暴露狀態與專屬武器仍可另外調整。',
            pieces: const <OutfitPiecePresetData>[],
            featureTags: job.featureTags,
            contextPhrases: job.contextPhrases,
            legacyFeatureTagsForMigration: job.legacyFeatureTagsForMigration,
            unifiedPhraseZh: job.zh,
            unifiedPhraseEn: job.unifiedOutfitPhrase,
            unifiedPhraseSections: job.unifiedPhraseSections,
            equipmentTagIds: <String>[job.weaponTagId],
            ownerCharacterTags: job.ownerCharacterTag.isEmpty
                ? const <String>[]
                : <String>[job.ownerCharacterTag],
            ownerCharacterLabel: job.characterZh,
          ))
      .toList(),
);
