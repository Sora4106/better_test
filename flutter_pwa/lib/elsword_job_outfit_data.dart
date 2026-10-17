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
          r'\b(?:boots?|shoes?|thighhighs?|socks?|leg guards?|leg wraps?|thigh strap)\b')
      .hasMatch(value)) {
    return elswordJobDetailFootwearGroup;
  }
  if (RegExp(r'\b(?:skirt|waist|sash|belt)\b').hasMatch(value)) {
    return elswordJobDetailLowerGroup;
  }
  if (RegExp(
          r'\b(?:coat|cape|capelet|mantle|hood|sleeves?|bodice|vest|turtleneck|top|robe|dress|armor|jacket)\b')
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
        _ => '',
      };

  _ElswordJobLook get look {
    final looks = switch (characterEn) {
      'Aisha' => _aishaLooks,
      'Rena' => _renaLooks,
      'Eve' => _eveLooks,
      'Ara' => _araLooks,
      'Elesis' => _elesisLooks,
      _ => const <String, _ElswordJobLook>{},
    };
    return looks[jobEn] ?? _fallbackLook;
  }

  List<String> get featureTags {
    // Aisha's job-specific hair/head profile belongs to the canonical class
    // phrase below. Do not select it as generic Aisha traits, otherwise a
    // prior class can leave hair or accessories behind after a class switch.
    if (usesCanonicalAishaJobProfile) return const <String>[];
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

  List<_ElswordStyleDetail> get visualDetails => [
        _ElswordStyleDetail(
          '$jobZh職業套裝',
          usesElementalMasterProfile
              ? '(elemental master outfit:1.25)'
              : '${jobEn.toLowerCase()} outfit',
        ),
        ...look.details,
      ];

  /// The reference-card action uses one concise, canonical description. Extra
  /// source phrases stay selectable, but do not all pile into the default
  /// prompt as duplicate synonyms.
  List<_ElswordStyleDetail> get presetVisualDetails => [
        _ElswordStyleDetail('$jobZh職業套裝', '${jobEn.toLowerCase()} outfit'),
        ...look.details,
      ];

  /// The exact ordered components used by [unifiedOutfitPhrase].  Keeping
  /// these as individual fragments makes it possible to remove a coat, skirt,
  /// shoes, or accessory from a selected class set without reordering the
  /// remaining canonical description.
  List<_ElswordStyleDetail> get unifiedOutfitDetails {
    // The canonical Aisha jobs provide their identity, official-design, and
    // hair/head blocks through [contextPhrases].  Do not duplicate that
    // material inside the clothing group.
    if (usesCanonicalAishaJobProfile) return visualDetails;
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

  /// Complete non-clothing blocks that are emitted in front of the canonical
  /// outfit. Keeping each one as one tag makes the order predictable and lets
  /// the user turn the job's head profile off without changing global Aisha
  /// traits.
  List<OutfitReferenceContextPhraseData> get contextPhrases {
    if (!usesCanonicalAishaJobProfile) {
      return const <OutfitReferenceContextPhraseData>[];
    }
    final identity = _aishaJobIdentity;
    if (identity == null) return const <OutfitReferenceContextPhraseData>[];
    final headProfile = usesElementalMasterProfile
        ? 'purple hair, long hair, low twintails, ahoge, purple eyes, x-shaped hairclip, (oval face:1.15), (slightly elongated facial proportions:1.15), (tapered jawline:1.12), (defined nose bridge:1.12), (defined lower eyelids:1.1), (refined lips:1.1), (subtle cheekbone definition:1.08), (refined facial features:1.1), detailed face, highly detailed face, detailed eyes, consistent facial proportions, facial detail emphasis'
        : look.hairTags.join(', ');
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
            'Aether Sage' => '以太賢者・法杖與浮游魔導書',
            'Void Princess' => '虛無公主・惡魔頭法杖',
            'Oz Sorcerer' => '奧茲魔導・斧頭法杖',
            'Dimension Witch' => '次元魔女・時空法杖',
            'Metamorphy' => '鍊金變形者・魔法法杖',
            'Mystic Alchemist' => '神秘鍊金術師・鍊金法杖與魔導書',
            'Lord Azoth' => '亞佐特領主・賢者之石法杖與浮游魔導書',
            _ => '$jobZh專屬法杖',
          },
        'Rena' => '$jobZh專屬精靈弓',
        'Eve' => '$jobZh專屬納斯德武裝',
        'Ara' => '$jobZh專屬靈槍',
        'Elesis' => '$jobZh專屬騎士劍',
        _ => '$jobZh專屬武器',
      };

  String get weaponEn {
    final descriptor = _elswordWeaponDescriptor(jobEn);
    return switch (characterEn) {
      'Aisha' => switch (jobEn) {
          'Aether Sage' =>
            'ornate aether magic staff with a floating magic book, glowing red gemstone, elemental magic, official Elsword class weapon',
          'Void Princess' =>
            'dark magic staff with a black and white demon-shaped staff head, official Elsword class weapon',
          'Oz Sorcerer' =>
            'large dark magic staff with an axe-headed staff head, official Elsword class weapon',
          'Dimension Witch' =>
            'space-time magic staff with a talisman and energy magic, official Elsword class weapon',
          'Metamorphy' =>
            'magical staff with a purple gemstone and space-time magic, official Elsword class weapon',
          'Mystic Alchemist' =>
            'alchemy staff with an alchemy book, potion bottles, and alchemy vials, official Elsword class weapon',
          'Lord Azoth' =>
            'alchemy staff with a philosopher\'s stone motif and a floating alchemy book, official Elsword class weapon',
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
  'High Magician': _ElswordJobLook(
    palette: '白色 × 紫色 × 粉紅色',
    hairTags: ['low twintails', 'ahoge', 'x-shaped hairclip'],
    details: [
      _ElswordStyleDetail('白紫法師長外套', 'white and purple mage coat'),
      _ElswordStyleDetail('粉紅胸前蝴蝶結', 'large pink chest bow'),
      _ElswordStyleDetail('寶石胸針', 'gemstone brooch'),
      _ElswordStyleDetail('寬大袖口', 'wide sleeves'),
    ],
  ),
  'Elemental Master': _ElswordJobLook(
    palette: '白色 × 紫色 × 粉紅色',
    hairTags: ['low twintails', 'ahoge', 'x-shaped hairclip'],
    details: [
      _ElswordStyleDetail('元素大師服裝強調', '(white hooded coat:1.2)'),
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
      'sidelocks',
      'ahoge',
      'purple eyes',
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
      _ElswordStyleDetail('白色手套', 'white gloves'),
      _ElswordStyleDetail('白色大腿靴', 'white thigh boots'),
      _ElswordStyleDetail('護身符', 'amulet'),
      _ElswordStyleDetail('耳環', 'earrings'),
      _ElswordStyleDetail('元素魔法', 'elemental magic'),
    ],
  ),
  'Dark Magician': _ElswordJobLook(
    palette: '黑色 × 深紫色 × 酒紅色',
    hairTags: ['long straight hair', 'hair over one eye'],
    details: [
      _ElswordStyleDetail('黑紫暗黑法師洋裝', 'black and dark purple mage dress'),
      _ElswordStyleDetail('酒紅色蝴蝶結', 'burgundy bow'),
      _ElswordStyleDetail('黑色短斗篷', 'black capelet'),
      _ElswordStyleDetail('暗色寶石飾品', 'dark gemstone ornaments'),
    ],
  ),
  'Void Princess': _ElswordJobLook(
    palette: '紫色 × 洋紅色 × 白色 × 黑色',
    hairTags: [
      'purple hair',
      'purple eyes',
      'twintails',
      'black hair ribbons',
    ],
    details: [
      _ElswordStyleDetail('洋紅短版上衣', 'magenta cropped top'),
      _ElswordStyleDetail('十字圖樣', 'cross motif'),
      _ElswordStyleDetail('白色披肩', 'white shrug'),
      _ElswordStyleDetail('紫色朱麗葉袖', 'purple juliet sleeves'),
      _ElswordStyleDetail('荷葉袖', 'frilled sleeves'),
      _ElswordStyleDetail('紫色臂環', 'purple armband'),
      _ElswordStyleDetail('洋紅臂環', 'magenta armband'),
      _ElswordStyleDetail('露出腰腹', 'exposed midriff'),
      _ElswordStyleDetail('紫色迷你裙', 'purple miniskirt'),
      _ElswordStyleDetail('拉鍊裙', 'zipper skirt'),
      _ElswordStyleDetail('洋紅腰帶', 'magenta belt'),
      _ElswordStyleDetail('黑色緞帶', 'black ribbon'),
      _ElswordStyleDetail('腰部斗篷', 'waist cape'),
      _ElswordStyleDetail('腰側長開衩布片', 'long split waist panels'),
      _ElswordStyleDetail('紫色吊襪帶', 'purple garter straps'),
      _ElswordStyleDetail('紫色大腿靴', 'purple thigh boots'),
      _ElswordStyleDetail('拉鍊靴', 'zipper boots'),
      _ElswordStyleDetail('暗黑魔法', 'dark magic'),
    ],
  ),
  'Oz Sorcerer': _ElswordJobLook(
    palette: '黑色 × 紫色 × 粉紅色',
    hairTags: [
      'purple hair',
      'very long purple hair',
      'straight hair',
      'loose hair',
      'hair worn down',
      'purple eyes',
    ],
    details: [
      _ElswordStyleDetail('大型魔女帽', 'large witch hat'),
      _ElswordStyleDetail('深紫色魔女帽', 'dark purple witch hat'),
      _ElswordStyleDetail('洋紅寶石', 'magenta gemstone'),
      _ElswordStyleDetail('拉鍊帽', 'zipper hat'),
      _ElswordStyleDetail('拉鍊嘴魔女帽', 'zipper-mouth hat'),
      _ElswordStyleDetail('深紫色繞頸上衣', 'dark purple halter top'),
      _ElswordStyleDetail('拉鍊上衣', 'zipper shirt'),
      _ElswordStyleDetail('洋紅滾邊', 'magenta trim'),
      _ElswordStyleDetail('衣領寶石', 'collar jewel'),
      _ElswordStyleDetail('裸露肩膀', 'bare shoulders'),
      _ElswordStyleDetail('露出腰腹', 'exposed midriff'),
      _ElswordStyleDetail('交叉繫帶', 'cross-laced straps'),
      _ElswordStyleDetail('分離式紫色袖套', 'detached purple sleeves'),
      _ElswordStyleDetail('拉鍊袖套', 'zipper sleeves'),
      _ElswordStyleDetail('不對稱腿部服飾', 'asymmetrical legwear'),
      _ElswordStyleDetail('深紫色大腿襪', 'dark purple thighhighs'),
      _ElswordStyleDetail('拉鍊腿部服飾', 'zipper legwear'),
      _ElswordStyleDetail('單側大腿襪角形開口', 'angular opening on one thighhigh'),
      _ElswordStyleDetail('深紫貼身短褲', 'dark purple micro shorts'),
      _ElswordStyleDetail('荷葉短褲', 'frilled shorts'),
      _ElswordStyleDetail('荷葉開襟裙', 'frilled open skirt'),
      _ElswordStyleDetail('長開衩裙', 'long split skirt'),
      _ElswordStyleDetail('雙面布料', 'two-sided fabric'),
      _ElswordStyleDetail('深紫高跟靴', 'dark purple high heel boots'),
      _ElswordStyleDetail('拉鍊鞋履', 'zipper footwear'),
      _ElswordStyleDetail('暗黑魔法', 'dark magic'),
    ],
  ),
  'Battle Magician': _ElswordJobLook(
    palette: '黑色 × 紫色 × 金色',
    hairTags: ['high ponytail', 'ahoge'],
    details: [
      _ElswordStyleDetail('黑紫戰鬥法師上衣', 'black and purple battle mage top'),
      _ElswordStyleDetail('金色護腕與護甲飾邊', 'gold bracers and armor trim'),
      _ElswordStyleDetail('貼身馬甲', 'fitted bodice'),
      _ElswordStyleDetail('披肩斗篷', 'shoulder capelet'),
    ],
  ),
  'Dimension Witch': _ElswordJobLook(
    palette: '白色 × 紫色 × 粉紅色 × 洋紅色',
    hairTags: [
      'purple hair',
      'purple eyes',
      'twintails',
      'twin drills',
      'ringlets',
      'curly twintails',
      'pink hair ribbon',
      'two-tone hair bow',
    ],
    details: [
      _ElswordStyleDetail('白色繞頸洋裝', 'white halter dress'),
      _ElswordStyleDetail('交叉繫帶繞頸', 'criss-cross halter'),
      _ElswordStyleDetail('開襟洋裝', 'open dress'),
      _ElswordStyleDetail('紫色衣領', 'purple collar'),
      _ElswordStyleDetail('酒紅背後蝴蝶結', 'maroon back bow'),
      _ElswordStyleDetail('大型背後蝴蝶結', 'large back bow'),
      _ElswordStyleDetail('裸露肩膀', 'bare shoulders'),
      _ElswordStyleDetail('分離式袖套', 'detached sleeves'),
      _ElswordStyleDetail('白色袖套', 'white sleeves'),
      _ElswordStyleDetail('袖套環帶', 'sleeve garters'),
      _ElswordStyleDetail('粉紅滾邊', 'pink trim'),
      _ElswordStyleDetail('白色手套', 'white gloves'),
      _ElswordStyleDetail('粉紅手腕帶', 'pink wrist straps'),
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
    ],
  ),
  'Metamorphy': _ElswordJobLook(
    palette: '白色 × 粉紅色 × 紫色 × 金色',
    hairTags: [
      'pink-purple hair',
      'gradient hair',
      'very long hair',
      'long twintails',
      'twin drills',
      'drill hair',
      'drill sidelocks',
      'pink eyes',
      'starry hair',
      'star-shaped eye highlights',
      'star hair ornament',
      'rabbit-ear-shaped hair ornament',
    ],
    details: [
      _ElswordStyleDetail('魔法少女風格', 'magical girl'),
      _ElswordStyleDetail('白色平口洋裝', 'white strapless dress'),
      _ElswordStyleDetail('雙色洋裝', 'two-tone dress'),
      _ElswordStyleDetail('荷葉洋裝', 'frilled dress'),
      _ElswordStyleDetail('百褶裙', 'pleated skirt'),
      _ElswordStyleDetail('粉紅漸層裙', 'pink gradient skirt'),
      _ElswordStyleDetail('紫色寶石', 'purple gemstone'),
      _ElswordStyleDetail('紫色領結', 'purple bowtie'),
      _ElswordStyleDetail('大型領結', 'large bowtie'),
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
    ],
  ),
  'Wiz Magician': _ElswordJobLook(
    palette: '紫色 × 金色 × 白色',
    hairTags: ['long hair', 'side braid'],
    details: [
      _ElswordStyleDetail('紫金鍊金術師外套', 'purple and gold alchemist coat'),
      _ElswordStyleDetail('魔法瓶腰飾', 'alchemy flask belt ornaments'),
      _ElswordStyleDetail('白色袖口', 'white sleeve cuffs'),
      _ElswordStyleDetail('鍊金術徽章', 'alchemist emblem'),
    ],
  ),
  'Mystic Alchemist': _ElswordJobLook(
    palette: '白色 × 黑色 × 紫色 × 紅色 × 金色',
    hairTags: [
      'purple hair',
      'gradient purple hair',
      'purple eyes',
      'low twintails',
      'long hair',
      'ahoge',
      'hair bow',
    ],
    details: [
      _ElswordStyleDetail('白色襯衫洋裝', 'white dress shirt'),
      _ElswordStyleDetail('白色襯衫', 'white shirt'),
      _ElswordStyleDetail('黑色領結', 'black bowtie'),
      _ElswordStyleDetail('深紫蝴蝶結', 'dark purple bow'),
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

const _elswordJobs = <_ElswordJobOutfit>[
  _ElswordJobOutfit('愛莎', 'Aisha', '高階魔術師', 'High Magician'),
  _ElswordJobOutfit('愛莎', 'Aisha', '元素大師', 'Elemental Master'),
  _ElswordJobOutfit('愛莎', 'Aisha', '以太賢者', 'Aether Sage'),
  _ElswordJobOutfit('愛莎', 'Aisha', '闇黑魔術師', 'Dark Magician'),
  _ElswordJobOutfit('愛莎', 'Aisha', '虛無公主', 'Void Princess'),
  _ElswordJobOutfit('愛莎', 'Aisha', '奧茲魔術師', 'Oz Sorcerer'),
  _ElswordJobOutfit('愛莎', 'Aisha', '戰鬥魔術師', 'Battle Magician'),
  _ElswordJobOutfit('愛莎', 'Aisha', '次元魔女', 'Dimension Witch'),
  _ElswordJobOutfit('愛莎', 'Aisha', '鍊金變形者', 'Metamorphy'),
  _ElswordJobOutfit('愛莎', 'Aisha', '巫師魔術師', 'Wiz Magician'),
  _ElswordJobOutfit('愛莎', 'Aisha', '神秘鍊金術師', 'Mystic Alchemist'),
  _ElswordJobOutfit('愛莎', 'Aisha', '亞佐特領主', 'Lord Azoth'),
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

/// Main selectable garment for each job. These IDs use the regular costume
/// taxonomy so colour, wear state, and other clothing controls stay editable.
final List<CatalogTagData> elswordJobOutfitTags =
    List<CatalogTagData>.unmodifiable(
  _elswordJobs.map((job) => CatalogTagData(
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
