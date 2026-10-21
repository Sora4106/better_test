/// Detailed, model-facing profiles for Elsword's female second / third jobs.
///
/// A profile is deliberately kept separate from the generic character catalog:
/// selecting one class must bring its own hair, head modules, silhouette,
/// weapon, effects, and any canonical companion without leaking another class
/// into the generated prompt.  Aisha continues to use the hand-authored data
/// in `elsword_job_outfit_data.dart` and is intentionally not represented here.
class ElswordFemaleCharacterPromptBase {
  const ElswordFemaleCharacterPromptBase({
    required this.characterEn,
    required this.characterZh,
    required this.characterTag,
    required this.baseCharacterTags,
    required this.defaultEyeTags,
    required this.faceTags,
    required this.optionalNegativeTags,
  });

  final String characterEn;
  final String characterZh;
  final String characterTag;
  final List<String> baseCharacterTags;
  final List<String> defaultEyeTags;
  final List<String> faceTags;
  final List<String> optionalNegativeTags;
}

/// A bilingual segment of a class outfit.  The rendered English phrase stays
/// in one clothing block, while the Chinese label makes the section removable
/// and inspectable in the outfit card.
class ElswordJobPromptSegment {
  const ElswordJobPromptSegment(this.id, this.zh, this.tags);

  final String id;
  final String zh;
  final List<String> tags;

  String get en => _dedupe(tags).join(', ');
}

/// Complete prompt data for one official Taiwanese Elsword class reference.
/// Every profile exposes the requested database dimensions, even when a
/// companion is intentionally optional and therefore an empty list.
class ElswordFemaleJobPromptProfile {
  const ElswordFemaleJobPromptProfile({
    required this.base,
    required this.classEn,
    required this.classZh,
    required this.classTag,
    required this.palette,
    required this.hairTags,
    required this.headAccessoryTags,
    required this.outfitTags,
    required this.upperBodyTags,
    required this.lowerBodyTags,
    required this.legwearTags,
    required this.footwearTags,
    required this.accessoryTags,
    required this.weaponTags,
    required this.magicEffectTags,
    required this.classThemeTags,
    this.canonicalAppearanceTags = const <String>[],
    this.eyeTags = const <String>[],
    this.companionTags = const <String>[],
    this.optionalNegativeTags = const <String>[],
  });

  final ElswordFemaleCharacterPromptBase base;
  final String classEn;
  final String classZh;
  final String classTag;
  final String palette;
  final List<String> hairTags;
  final List<String> eyeTags;
  final List<String> headAccessoryTags;
  final List<String> outfitTags;
  final List<String> upperBodyTags;
  final List<String> lowerBodyTags;
  final List<String> legwearTags;
  final List<String> footwearTags;
  final List<String> accessoryTags;
  final List<String> weaponTags;
  final List<String> magicEffectTags;
  final List<String> companionTags;
  final List<String> classThemeTags;

  /// Some official class designs have an inseparable hairstyle, face, and body
  /// silhouette. Keep those descriptions in one ordered block so a job preset
  /// does not fall back to its character's generic appearance.
  final List<String> canonicalAppearanceTags;
  final List<String> optionalNegativeTags;

  String get key => elswordFemaleJobProfileKey(base.characterEn, classEn);
  String get classNameTag =>
      '${classEn.toLowerCase()} ${base.characterEn.toLowerCase()}';
  String get outfitAnchor => '(${classEn.toLowerCase()} outfit:1.3)';

  List<String> get resolvedEyeTags =>
      _dedupe(eyeTags.isEmpty ? base.defaultEyeTags : eyeTags);

  List<String> get characterAndHeadTags {
    if (canonicalAppearanceTags.isNotEmpty) {
      return _dedupe(canonicalAppearanceTags);
    }
    return _dedupe(<String>[
      ...base.baseCharacterTags,
      ...hairTags,
      ...resolvedEyeTags,
      ...headAccessoryTags,
      ...base.faceTags,
    ]);
  }

  List<ElswordJobPromptSegment> get outfitSegments => <ElswordJobPromptSegment>[
        ElswordJobPromptSegment('silhouette', '$classZh・職業服裝輪廓', outfitTags),
        ElswordJobPromptSegment('upper', '$classZh・上身與袖型', upperBodyTags),
        ElswordJobPromptSegment('lower', '$classZh・下身結構', lowerBodyTags),
        ElswordJobPromptSegment('legwear', '$classZh・腿部裝備', legwearTags),
        ElswordJobPromptSegment('footwear', '$classZh・鞋履', footwearTags),
        ElswordJobPromptSegment('accessory', '$classZh・飾品與裝置', <String>[
          ...accessoryTags,
          ...companionTags,
          ...magicEffectTags,
          ...classThemeTags,
          'official Elsword style',
        ]),
      ].where((segment) => segment.en.isNotEmpty).toList(growable: false);

  List<String> get optionalNegativePromptTags => _dedupe(<String>[
        ...base.optionalNegativeTags,
        ...optionalNegativeTags,
      ]);

  /// Copy-ready WAI prompt reference.  The app normally adds the weapon only
  /// when the user selects it, but this full reference intentionally includes
  /// the class weapon so the entire official look can be tested in one paste.
  String get recommendedPrompt => '(${_dedupe(<String>[
            '1girl',
            base.characterTag,
            'elsword',
            classTag,
            classNameTag,
            'official outfit',
            'canon outfit',
            'official character design',
            'character accurate',
            'official game style',
            'original class outfit',
            ...characterAndHeadTags,
            outfitAnchor,
            for (final segment in outfitSegments) segment.en,
            ...weaponTags,
          ]).join(', ')})';
}

String elswordFemaleJobProfileKey(String characterEn, String classEn) =>
    '$characterEn::$classEn';

ElswordFemaleJobPromptProfile? elswordFemaleJobPromptProfileFor(
  String characterEn,
  String classEn,
) =>
    elswordFemaleJobPromptProfiles[
        elswordFemaleJobProfileKey(characterEn, classEn)];

List<String> _dedupe(Iterable<String> tags) {
  final seen = <String>{};
  return tags
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .where((tag) => seen.add(tag.toLowerCase()))
      .toList(growable: false);
}

const _refinedFaceTags = <String>[
  '(oval face:1.15)',
  '(slightly elongated facial proportions:1.12)',
  '(tapered jawline:1.1)',
  '(defined nose bridge:1.08)',
  '(defined lower eyelids:1.08)',
  '(refined lips:1.05)',
  '(refined facial features:1.08)',
  'detailed face',
  'highly detailed face',
  'detailed eyes',
  'consistent facial proportions',
  'facial detail emphasis',
];

const _rena = ElswordFemaleCharacterPromptBase(
  characterEn: 'Rena',
  characterZh: '蕾娜',
  characterTag: 'rena erindel',
  baseCharacterTags: <String>[
    'female elf',
    'pointed elf ears',
    'yellow-green hair',
  ],
  defaultEyeTags: <String>['green eyes'],
  faceTags: _refinedFaceTags,
  optionalNegativeTags: <String>[
    'human ears',
    'rounded ears',
    'duplicate bow',
    'malformed bow',
    'extra bowstring',
  ],
);

const _eve = ElswordFemaleCharacterPromptBase(
  characterEn: 'Eve',
  characterZh: '伊芙',
  characterTag: 'eve (elsword)',
  baseCharacterTags: <String>[
    'silver-white hair',
    'nasod mechanical design',
    'mechanical ear modules',
  ],
  defaultEyeTags: <String>['orange eyes', 'amber eyes'],
  faceTags: _refinedFaceTags,
  optionalNegativeTags: <String>[
    'elf ears',
    'pointed biological ears',
    'feather wings',
    'organic wings',
    'duplicate mechanical cores',
  ],
);

const _ara = ElswordFemaleCharacterPromptBase(
  characterEn: 'Ara',
  characterZh: '艾拉',
  characterTag: 'ara haan',
  baseCharacterTags: <String>[
    'long dark hair',
    'eastern martial artist',
  ],
  defaultEyeTags: <String>['red eyes'],
  faceTags: _refinedFaceTags,
  optionalNegativeTags: <String>[
    'duplicate spear',
    'extra arms',
    'malformed hands',
    'western plate armor',
  ],
);

const _elesis = ElswordFemaleCharacterPromptBase(
  characterEn: 'Elesis',
  characterZh: '愛利西斯',
  characterTag: 'elesis (elsword)',
  baseCharacterTags: <String>[
    'red hair',
    'female knight',
  ],
  defaultEyeTags: <String>['red eyes', 'amber-red eyes'],
  faceTags: _refinedFaceTags,
  optionalNegativeTags: <String>[
    'duplicate sword',
    'malformed sword',
    'extra arms',
    'extra fingers',
  ],
);

const _lu = ElswordFemaleCharacterPromptBase(
  characterEn: 'Luciela',
  characterZh: '露',
  characterTag: 'luciela r. sourcream',
  baseCharacterTags: <String>[
    'demon girl',
    'pale hair',
    'demon horns',
    'demon royalty',
  ],
  defaultEyeTags: <String>['crimson eyes'],
  faceTags: _refinedFaceTags,
  optionalNegativeTags: <String>[
    'ciel',
    'male butler',
    'duplicate horns',
    'extra wings',
  ],
);

const _rose = ElswordFemaleCharacterPromptBase(
  characterEn: 'Rose',
  characterZh: '羅潔',
  characterTag: 'rose_(elsword)',
  baseCharacterTags: <String>[
    'blonde hair',
    'female gunner',
    'military gunner design',
  ],
  defaultEyeTags: <String>['blue eyes'],
  faceTags: _refinedFaceTags,
  optionalNegativeTags: <String>[
    'duplicate gun',
    'malformed firearm',
    'extra trigger',
    'extra arms',
  ],
);

const _laby = ElswordFemaleCharacterPromptBase(
  characterEn: 'Laby',
  characterZh: '菈比',
  characterTag: 'laby_(elsword)',
  baseCharacterTags: <String>[
    'light pink hair',
    'mirror magic user',
  ],
  defaultEyeTags: <String>['pink eyes'],
  faceTags: _refinedFaceTags,
  optionalNegativeTags: <String>[
    'duplicate mirror',
    'malformed hands',
    'extra arms',
    'extra goggles',
  ],
);

const _lithia = ElswordFemaleCharacterPromptBase(
  characterEn: 'Lithia',
  characterZh: '莉緹亞',
  characterTag: 'lithia_beryl_(elsword)',
  baseCharacterTags: <String>[
    'ash-blonde hair',
    'gemstone magic user',
  ],
  defaultEyeTags: <String>['teal eyes'],
  faceTags: _refinedFaceTags,
  optionalNegativeTags: <String>[
    'duplicate pickaxe',
    'malformed tool',
    'extra arms',
    'extra goggles',
  ],
);

ElswordFemaleJobPromptProfile _profile(
  ElswordFemaleCharacterPromptBase base, {
  required String classEn,
  required String classZh,
  required String classTag,
  required String palette,
  required List<String> hair,
  required List<String> head,
  required List<String> outfit,
  required List<String> upper,
  required List<String> lower,
  required List<String> legwear,
  required List<String> footwear,
  required List<String> accessories,
  required List<String> weapon,
  required List<String> magic,
  required List<String> theme,
  List<String> appearance = const <String>[],
  List<String> eyes = const <String>[],
  List<String> companions = const <String>[],
  List<String> negative = const <String>[],
}) =>
    ElswordFemaleJobPromptProfile(
      base: base,
      classEn: classEn,
      classZh: classZh,
      classTag: classTag,
      palette: palette,
      hairTags: hair,
      eyeTags: eyes,
      headAccessoryTags: head,
      outfitTags: outfit,
      upperBodyTags: upper,
      lowerBodyTags: lower,
      legwearTags: legwear,
      footwearTags: footwear,
      accessoryTags: accessories,
      weaponTags: weapon,
      magicEffectTags: magic,
      companionTags: companions,
      classThemeTags: theme,
      canonicalAppearanceTags: appearance,
      optionalNegativeTags: negative,
    );

final Map<String, ElswordFemaleJobPromptProfile>
    elswordFemaleJobPromptProfiles =
    Map<String, ElswordFemaleJobPromptProfile>.unmodifiable(
  <String, ElswordFemaleJobPromptProfile>{
    for (final profile in <ElswordFemaleJobPromptProfile>[
      // Rena ---------------------------------------------------------------
      _profile(
        _rena,
        classEn: 'Wind Sneaker',
        classZh: '風行者',
        classTag: 'wind_sneaker',
        palette: '黃綠色（同髮色） × 黑色 × 白色 × 金色',
        hair: const <String>[],
        head: const <String>[],
        appearance: <String>[
          'elf ears',
          'long pointed ears',
          'green eyes',
          'light yellow-green hair',
          'yellow-green hair',
          'lime-blonde hair',
          'long hair',
          'high ponytail',
          'long high ponytail',
          'side bangs',
          'layered bangs',
          '((white flower hair ornament:1.18))',
          '((black satin ribbon wrapped around the ponytail base:1.25))',
          '((black satin ribbon wrapped around the rear one-third of the ponytail:1.22))',
          'flowing hair',
          'athletic body',
          'toned legs',
          'large breasts',
          '(oval face:1.12)',
          '(delicate nose:1.05)',
          '(defined eyes:1.08)',
          'detailed face',
          'detailed eyes',
          'consistent facial proportions',
        ],
        outfit: <String>[
          'green black fantasy fighter outfit',
          'outfit green parts match her hair color',
          'all green clothing uses the same yellow-green tone as her hair',
          'hair-matching yellow-green outfit accents',
          'lime-blonde green clothing',
          'hair-colored green fabric',
          'white collar',
          'off-shoulder outfit',
          'exposed shoulders',
        ],
        upper: <String>[
          'black corset covering the bust and waist',
          'black fitted waist corset',
          'black upper torso',
          'black underbust',
          'black waist',
          'black fabric continuously covering the bust and waist',
          '((gold four-pointed star ornament at the neckline:1.2))',
          '((gold circular ornament at the underbust center:1.2))',
          'light yellow-green sleeves',
          '((yellow-green bell sleeves:1.28))',
          '((long flared yellow-green sleeves:1.25))',
          'sleeve color matches her hair',
          'black frilled sleeve cuffs',
          'black fingerless gloves',
        ],
        lower: <String>[
          '((two separate black fabric ribbons attached at the waist:1.35))',
          '((one black fabric ribbon on the left waist:1.32))',
          '((one black fabric ribbon on the right waist:1.32))',
          'soft flowing black ribbon tails',
          'gold ring ornaments near the ribbon bases',
          'gold ornaments at the ribbon ends',
          'fabric accessories only',
          '((slightly longer layered skirt:1.24))',
          'yellow-green skirt',
          '((yellow-green pleated outer skirt:1.32))',
          'outer skirt matches her hair color',
          '((black frilled inner underskirt:1.25))',
          'yellow-green outer skirt',
          'black inner frilled layer',
        ],
        legwear: const <String>[],
        footwear: <String>[
          '((black long boots:1.3))',
          '((tall black combat boots:1.28))',
          '((below-knee boots:1.35))',
          '((boots reaching just below the knees:1.35))',
          '((consistent boot height:1.22))',
          'front-laced black boots',
          'mostly black boots',
          'structured long boots',
          'firm boot shaft',
          'not ankle boots',
          'not compact boots',
          'not ankle-length boots',
          'not over-knee boots',
          'not thighhigh boots',
        ],
        accessories: const <String>[],
        weapon: <String>[
          'small single-handed bow',
          'compact hand bow',
          'small bow weapon mounted on one hand',
          'not a full-size bow',
          'not a longbow',
          'yellow-green bow body',
          'bow color matches her hair',
          'white bow tips',
          'black grip',
          'gold accents',
          'official Elsword style weapon',
        ],
        magic: const <String>[],
        theme: const <String>[],
      ),
      _profile(
        _rena,
        classEn: 'Anemos',
        classZh: '疾風之翼',
        classTag: 'anemos',
        palette: '白色 × 青綠色 × 金色',
        hair: <String>['yellow-green side ponytail', 'flowing wavy hair'],
        head: <String>['teal feather hair ornament', 'gold leaf hair clasp'],
        outfit: <String>[
          'white and teal wind spirit combat outfit',
          'gold trim'
        ],
        upper: <String>[
          'white fitted sleeveless top',
          'teal detached sleeves',
          'gold shoulder guards',
          'cross-laced waist sash',
        ],
        lower: <String>[
          'layered teal skirt panels',
          'asymmetrical waist drape'
        ],
        legwear: <String>['black fitted legwear', 'teal knee wraps'],
        footwear: <String>['white armored ankle boots', 'gold heel guards'],
        accessories: <String>['wind emblem', 'gold waist chains'],
        weapon: <String>[
          'ornate elven bow',
          'white and teal bow body',
          'gold wind motifs',
          'curved bow limbs',
          'visible bowstring',
        ],
        magic: <String>[
          'teal wind vortex',
          'feather-like wind trails',
          'air magic'
        ],
        theme: <String>['wind spirit martial artist', 'aerial kicking style'],
      ),
      _profile(
        _rena,
        classEn: 'Grand Archer',
        classZh: '守護者',
        classTag: 'grand_archer',
        palette: '白色 × 綠色 × 金色',
        hair: <String>[
          'long yellow-green hair',
          'side braid',
          'loose sidelocks'
        ],
        head: <String>['gold leaf circlet', 'green feather hair ornament'],
        outfit: <String>['white and green elven archer outfit', 'gold trim'],
        upper: <String>[
          'white collared archer top',
          'green fitted bodice',
          'gold shoulder mantle',
          'leather bracers',
        ],
        lower: <String>['layered white skirt panels', 'green split overskirt'],
        legwear: <String>['dark green leg wraps', 'leather thigh straps'],
        footwear: <String>['white knee-high archer boots', 'gold ankle guards'],
        accessories: <String>['ornate quiver', 'leaf-shaped waist emblem'],
        weapon: <String>[
          'large ornate elven bow',
          'white and green bow frame',
          'gold leaf-shaped limbs',
          'curved bow limbs',
          'visible bowstring',
        ],
        magic: <String>['green spirit arrows', 'leaf particles', 'elven light'],
        theme: <String>['long-range elven archer', 'guardian archer'],
      ),
      _profile(
        _rena,
        classEn: 'Daybreaker',
        classZh: '破曉行者',
        classTag: 'daybreaker',
        palette: '白色 × 金色 × 淺藍色',
        hair: <String>['long yellow-green wavy hair', 'flowing side braid'],
        eyes: <String>['golden-green eyes'],
        head: <String>['light blue crystal hair ornament', 'gold leaf circlet'],
        outfit: <String>[
          'white and gold dawn archer outfit',
          'light blue accents'
        ],
        upper: <String>[
          'white fitted archer blouse',
          'gold-trimmed shoulder mantle',
          'light blue chest gem',
          'white forearm guards',
        ],
        lower: <String>['white layered skirt panels', 'light blue split drape'],
        legwear: <String>['white fitted legwear', 'gold thigh straps'],
        footwear: <String>['white high boots', 'gold toe guards'],
        accessories: <String>['spirit stone pendant', 'gold quiver fittings'],
        weapon: <String>[
          'large dawn elven bow',
          'white bow frame',
          'gold trim',
          'light blue crystal core',
          'curved bow limbs',
          'visible bowstring',
        ],
        magic: <String>[
          'dawn light arrows',
          'light blue spirit particles',
          'sunrise glow'
        ],
        theme: <String>['radiant elven archer', 'long-range spirit archer'],
      ),
      _profile(
        _rena,
        classEn: 'Night Watcher',
        classZh: '夜襲者',
        classTag: 'night_watcher',
        palette: '黑色 × 深綠色 × 銀色',
        hair: <String>[
          'long dark green hair',
          'side braid',
          'wind-swept bangs'
        ],
        eyes: <String>['yellow-green eyes'],
        head: <String>['black leaf hair clasp', 'silver moon hair ornament'],
        outfit: <String>['black and dark green ranger outfit', 'silver trim'],
        upper: <String>[
          'black fitted ranger top',
          'dark green hooded shoulder mantle',
          'leather arm guards',
          'cross-laced chest straps',
        ],
        lower: <String>['dark green split skirt panels', 'black utility belt'],
        legwear: <String>['black fitted legwear', 'dark green thigh straps'],
        footwear: <String>['black ranger boots', 'silver ankle buckles'],
        accessories: <String>['trap pouches', 'moon emblem', 'ornate quiver'],
        weapon: <String>[
          'dark elven bow',
          'black and deep green bow body',
          'silver moon ornaments',
          'curved bow limbs',
          'visible bowstring',
        ],
        magic: <String>[
          'forest shadow magic',
          'green trap glyphs',
          'moonlight particles'
        ],
        theme: <String>['forest ranger', 'trap specialist'],
      ),
      _profile(
        _rena,
        classEn: 'Twilight',
        classZh: '暮光行者',
        classTag: 'twilight',
        palette: '黑色 × 紫色 × 深綠色',
        hair: <String>[
          'very long dark green hair',
          'straight hair',
          'long sidelocks'
        ],
        eyes: <String>['purple-green eyes'],
        head: <String>[
          'black feather hair ornament',
          'purple crystal hair clasp'
        ],
        outfit: <String>[
          'black and purple twilight ranger outfit',
          'deep green accents'
        ],
        upper: <String>[
          'black fitted ranger bodice',
          'purple armored shoulder wrap',
          'dark green detached sleeves',
          'cross-laced waist belt',
        ],
        lower: <String>[
          'asymmetrical purple skirt panels',
          'black split overskirt'
        ],
        legwear: <String>['black thigh straps', 'purple fitted legwear'],
        footwear: <String>[
          'black high-heel ranger boots',
          'purple ankle armor'
        ],
        accessories: <String>['forest emblem', 'dark crystal quiver'],
        weapon: <String>[
          'twilight elven bow',
          'black and purple bow frame',
          'deep green crystal ornaments',
          'curved bow limbs',
          'visible bowstring',
        ],
        magic: <String>[
          'twilight shadow arrows',
          'purple forest mist',
          'dark green particles'
        ],
        theme: <String>['twilight ranger', 'ambush archer'],
      ),
      _profile(
        _rena,
        classEn: 'Tale Spinner',
        classZh: '織語者',
        classTag: 'tale_spinner',
        palette: '象牙白 × 藍色 × 金色',
        hair: <String>['long yellow-green hair', 'side braid', 'soft waves'],
        eyes: <String>['golden-green eyes'],
        head: <String>['blue ribbon hair ornament', 'gold leaf hair clasp'],
        outfit: <String>[
          'ivory and blue storyteller archer outfit',
          'gold trim'
        ],
        upper: <String>[
          'ivory collared blouse',
          'blue fitted vest',
          'gold-trimmed sleeves',
          'ornate shoulder drape',
        ],
        lower: <String>['blue layered skirt panels', 'ivory split overskirt'],
        legwear: <String>['blue fitted legwear', 'gold thigh straps'],
        footwear: <String>['ivory ankle boots', 'gold lace fittings'],
        accessories: <String>[
          'story scroll ornament',
          'gold music-note brooch'
        ],
        weapon: <String>[
          'ornate tale bow',
          'ivory and blue bow frame',
          'gold filigree',
          'curved bow limbs',
          'visible bowstring',
        ],
        magic: <String>[
          'blue storybook light',
          'floating script particles',
          'gold sound-wave glyphs'
        ],
        theme: <String>['storyteller archer', 'elven bard motif'],
      ),
      _profile(
        _rena,
        classEn: 'Prophetess',
        classZh: '先知行者',
        classTag: 'prophetess',
        palette: '白色 × 青綠色 × 金色',
        hair: <String>[
          'yellow-green flowing hair',
          'wavy hair',
          'long sidelocks'
        ],
        eyes: <String>['golden eyes'],
        head: <String>['teal crystal head ornament', 'gold leaf circlet'],
        outfit: <String>[
          'white and teal prophetess ranger outfit',
          'gold trim'
        ],
        upper: <String>[
          'white fitted oracle top',
          'teal layered shoulder fabric',
          'gold-trimmed detached sleeves',
          'crystal chest ornament',
        ],
        lower: <String>['white layered skirt panels', 'teal ceremonial drape'],
        legwear: <String>['white fitted legwear', 'gold knee ornaments'],
        footwear: <String>['white high boots', 'teal crystal ankle guards'],
        accessories: <String>['gold prophecy chains', 'ornate quiver'],
        weapon: <String>[
          'prophetess elven bow',
          'white and teal bow body',
          'gold crystal fittings',
          'curved bow limbs',
          'visible bowstring',
        ],
        magic: <String>[
          'teal prophecy glyphs',
          'gold divination light',
          'floating leaf particles'
        ],
        theme: <String>['oracle ranger', 'prophecy archer'],
      ),

      // Eve ----------------------------------------------------------------
      _profile(
        _eve,
        classEn: 'Code: Nemesis',
        classZh: '復仇女神',
        classTag: 'code_nemesis',
        palette: '黑色 × 白色 × 洋紅色 × 橘色',
        hair: <String>['long silver-white hair', 'smooth straight hair'],
        head: <String>[
          'large blue oval forehead core',
          'compact black triangular mechanical ear ornaments',
          'nasod side head fins',
          'orange circular mechanical details',
        ],
        outfit: <String>[
          'black white and dark-gray nasod combat outfit',
          'magenta accents'
        ],
        upper: <String>[
          'fitted black mechanical bodice',
          'white armored chest frame',
          'rigid black mechanical cape panels',
          'orange circular cores',
        ],
        lower: <String>[
          'segmented black mechanical skirt panels',
          'white hip armor'
        ],
        legwear: <String>[
          'black mechanical thigh guards',
          'orange knee joints'
        ],
        footwear: <String>['black thigh boots', 'white armored boots'],
        accessories: <String>[
          'nasod core ornaments',
          'magenta mechanical cables'
        ],
        weapon: <String>[
          'floating ancient nasod weapons',
          'black mechanical weapon frames',
          'white armor plates',
          'orange glowing cores',
          'magenta energy edges',
        ],
        magic: <String>[
          'orange nasod energy',
          'magenta force field',
          'mechanical particles'
        ],
        theme: <String>['nasod combat queen', 'ancient nasod weapon control'],
      ),
      _profile(
        _eve,
        classEn: 'Code: Ultimate',
        classZh: 'Code:Ultimate',
        classTag: 'code_ultimate',
        palette: '黑色 × 白色 × 洋紅色 × 青色',
        hair: <String>[
          'very long silver-white hair',
          'straight hair',
          'long sidelocks'
        ],
        head: <String>[
          'black angular mechanical crown',
          'white mechanical side ornaments',
          'cyan glowing head circuits',
        ],
        outfit: <String>[
          'predominantly black nasod armor',
          'white accents',
          'magenta accents'
        ],
        upper: <String>[
          'black angular mechanical breastplate',
          'white armored shoulder frame',
          'cyan glowing circuit lines',
          'magenta core at chest',
        ],
        lower: <String>[
          'black segmented armor skirt panels',
          'white hip armor'
        ],
        legwear: <String>['black mechanical leg armor', 'cyan circuit rings'],
        footwear: <String>[
          'black armored thigh boots',
          'cyan mechanical soles'
        ],
        accessories: <String>['mechanical crown frame', 'magenta core cables'],
        weapon: <String>[
          'enormous nasod greatblade',
          'black angular blade body',
          'white mechanical frame',
          'cyan glowing circuits',
          'energy blade edge',
        ],
        magic: <String>[
          'cyan energy rings',
          'magenta energy core',
          'mechanical beam particles'
        ],
        theme: <String>['ultimate nasod armor', 'heavy mechanical combat'],
      ),
      _profile(
        _eve,
        classEn: 'Code: Empress',
        classZh: '創造女帝',
        classTag: 'code_empress',
        palette: '白色 × 金色 × 黑色 × 粉紅色',
        hair: <String>['silver-white hair', 'long flowing hair'],
        head: <String>[
          'blue forehead core',
          'gold mechanical crown',
          'white nasod side fins'
        ],
        outfit: <String>[
          'white gold and black royal nasod outfit',
          'pink accents'
        ],
        upper: <String>[
          'white fitted queen bodice',
          'gold mechanical collar',
          'large blue chest core',
          'black segmented shoulder frame',
        ],
        lower: <String>[
          'layered segmented mechanical skirt',
          'white and gold petal panels'
        ],
        legwear: <String>['white mechanical thigh guards', 'gold knee joints'],
        footwear: <String>['white armored boots', 'gold mechanical heels'],
        accessories: <String>['royal nasod crown', 'pink core ornaments'],
        weapon: <String>[
          'floating royal nasod control drones',
          'white and gold mechanical frames',
          'blue energy cores',
          'pink command lights',
        ],
        companions: <String>['Oberon', 'Ophelia', 'nasod servants'],
        magic: <String>[
          'blue nasod energy',
          'gold command glyphs',
          'pink mechanical particles'
        ],
        theme: <String>['nasod empress', 'royal mechanical command'],
      ),
      _profile(
        _eve,
        classEn: 'Code: Esencia',
        classZh: 'Code:Esencia',
        classTag: 'code_esencia',
        palette: '白色 × 粉紅色 × 金色 × 藍色',
        hair: <String>['silver-white hair', 'long flowing hair', 'soft waves'],
        head: <String>[
          'white mechanical crown',
          'large pink halo',
          'blue forehead core'
        ],
        outfit: <String>[
          'white pink and gold queen outfit',
          'blue core accents'
        ],
        upper: <String>[
          'white fitted queen bodice',
          'gold mechanical collar',
          'large blue chest core',
          'pink shoulder panels',
        ],
        lower: <String>[
          'layered petal-like mechanical panels',
          'white and pink skirt frame'
        ],
        legwear: <String>[
          'white mechanical thigh guards',
          'gold knee ornaments'
        ],
        footwear: <String>['white high boots', 'pink mechanical soles'],
        accessories: <String>['pink halo frame', 'gold petal ornaments'],
        weapon: <String>[
          'floating nasod servant control devices',
          'white and gold mechanical frames',
          'pink halo rings',
          'blue energy cores',
        ],
        companions: <String>['Oberon', 'Ophelia', 'nasod servants'],
        magic: <String>[
          'pink nasod light',
          'blue energy field',
          'gold mechanical particles'
        ],
        theme: <String>['nasod queen', 'elegant mechanical command'],
      ),
      _profile(
        _eve,
        classEn: 'Code: Battle Seraph',
        classZh: '熾天女皇',
        classTag: 'code_battle_seraph',
        palette: '白色 × 黑色 × 藍色 × 金色',
        hair: <String>['very long straight silver-white hair'],
        head: <String>[
          'compact flat mechanical ear modules',
          'white and black nasod side fins',
          'large blue oval forehead core',
        ],
        outfit: <String>[
          'white black blue and gold futuristic nasod combat outfit'
        ],
        upper: <String>[
          'white mechanical breastplate',
          'black armored waist frame',
          'large blue diamond-shaped chest core',
          'gold shoulder guards',
        ],
        lower: <String>[
          'white segmented lower armor',
          'black mechanical skirt panels'
        ],
        legwear: <String>[
          'white mechanical thigh guards',
          'blue crystal knee ornaments'
        ],
        footwear: <String>[
          'white mechanical thigh boots',
          'blue crystal soles'
        ],
        accessories: <String>['blue crystal ornaments', 'gold nasod frame'],
        weapon: <String>[
          'floating blue crystal prisms',
          'white mechanical drone frames',
          'blue energy emitters',
          'gold circuit fittings',
        ],
        companions: <String>['nasod support drones'],
        magic: <String>['electron beam', 'photon energy', 'blue force field'],
        theme: <String>['futuristic nasod combat', 'mechanical beam weaponry'],
      ),
      _profile(
        _eve,
        classEn: 'Code: Sariel',
        classZh: 'Code:Sariel',
        classTag: 'code_sariel',
        palette: '白色 × 黑色 × 青色',
        hair: <String>['very long silver-white hair', 'flowing straight hair'],
        head: <String>[
          'angular mechanical ear wings',
          'cyan glowing ear modules'
        ],
        outfit: <String>['white black and cyan streamlined nasod armor'],
        upper: <String>[
          'white fitted mechanical breastplate',
          'black angular shoulder frame',
          'cyan glowing circuit lines',
          'crystal chest emitter',
        ],
        lower: <String>['white segmented skirt armor', 'black hip panels'],
        legwear: <String>['white mechanical leg armor', 'cyan circuit rings'],
        footwear: <String>['white armored boots', 'cyan energy soles'],
        accessories: <String>[
          'cyan crystal ornaments',
          'mechanical wing mounts'
        ],
        weapon: <String>[
          'laser blade wing assemblies',
          'translucent cyan energy wings',
          'white mechanical frames',
          'cyan crystal blade edges',
        ],
        magic: <String>[
          'cyan laser beams',
          'photon particles',
          'blue energy field'
        ],
        theme: <String>['nasod beam specialist', 'mechanical energy wings'],
        negative: <String>['feather wings'],
      ),
      _profile(
        _eve,
        classEn: 'Code: Failess',
        classZh: '失序女王',
        classTag: 'code_failess',
        palette: '黑色 × 白色 × 橘色 × 粉紅色',
        hair: <String>[
          'silver-white fluffy bob cut',
          'layered bob',
          'long sidelocks'
        ],
        head: <String>[
          'black asymmetric hair ornament',
          'compact black-and-white mechanical ear fins',
          'long white cable ribbon extension',
        ],
        outfit: <String>[
          'black-and-white layered nasod outfit',
          'orange and pink error accents'
        ],
        upper: <String>[
          'black fitted mechanical top',
          'white frilled collar',
          'asymmetrical black-and-white sleeves',
          'orange error lights',
        ],
        lower: <String>[
          'black layered skirt panels',
          'white inner frills',
          'pink error stripes'
        ],
        legwear: <String>[
          'spiral legwear',
          'asymmetrical mechanical thigh panels'
        ],
        footwear: <String>['black ankle boots', 'orange mechanical soles'],
        accessories: <String>[
          'black mechanical ribbons',
          'pink glitch ornaments'
        ],
        weapon: <String>[
          'floating corrupted nasod devices',
          'black-and-white mechanical frames',
          'orange error lights',
          'pink glitch particles',
        ],
        companions: <String>['damaged nasod companion'],
        magic: <String>[
          'pink glitch effects',
          'orange error windows',
          'digital fragments'
        ],
        theme: <String>['unstable nasod queen', 'error-code motif'],
      ),
      _profile(
        _eve,
        classEn: 'Code: Antithese',
        classZh: 'Code:Antithese',
        classTag: 'code_antithese',
        palette: '黑色 × 金色 × 橘紅色 × 洋紅色',
        hair: <String>[
          'very long silver-gray hair',
          'swept bangs',
          'flowing sidelocks'
        ],
        eyes: <String>['orange-red eyes'],
        head: <String>[
          'orange-red crystal crown',
          'black and gold mechanical side modules'
        ],
        outfit: <String>[
          'predominantly black corrupted queen outfit',
          'gold mechanical trim'
        ],
        upper: <String>[
          'black fitted mechanical bodice',
          'orange-red chest crystal',
          'gold angular shoulder modules',
          'magenta inner glow',
        ],
        lower: <String>[
          'large jagged layered skirt panels',
          'black cape-like mechanical panels'
        ],
        legwear: <String>[
          'corrupted asymmetrical leg armor',
          'orange mechanical joints'
        ],
        footwear: <String>[
          'black pointed armored boots',
          'gold mechanical soles'
        ],
        accessories: <String>[
          'corrupted crown frame',
          'black mechanical cables'
        ],
        weapon: <String>[
          'corrupted nasod blade assemblies',
          'black angular frames',
          'orange-red crystal cores',
          'magenta energy edges',
        ],
        companions: <String>['damaged nasod companion'],
        magic: <String>[
          'digital disintegration',
          'red error windows',
          'red pixels'
        ],
        theme: <String>['corrupted nasod queen', 'antithese error motif'],
      ),
      // Ara ---------------------------------------------------------------
      _profile(
        _ara,
        classEn: 'Sakra Devanam',
        classZh: '帝天',
        classTag: 'sakra_devanam',
        palette: '靛藍色 × 白色 × 金色',
        hair: <String>[
          'very long black hair',
          'high ponytail',
          'gold hair ornaments'
        ],
        head: <String>[
          'blue-and-gold forehead jewel',
          'ornate eastern hairpin'
        ],
        outfit: <String>[
          'imperial eastern martial outfit',
          'blue-and-white guardian silhouette'
        ],
        upper: <String>[
          'white fitted martial jacket',
          'blue shoulder guards',
          'gold collar trim'
        ],
        lower: <String>[
          'blue layered hakama panels',
          'white split overskirt',
          'gold waist sash'
        ],
        legwear: <String>['blue leg wraps', 'gold knee guards'],
        footwear: <String>['blue armored boots', 'gold toe guards'],
        accessories: <String>['jade waist ornament', 'gold talisman ribbons'],
        weapon: <String>[
          'ornate dragon spear',
          'blue-and-gold spear shaft',
          'imperial spear blade'
        ],
        magic: <String>['blue qi trails', 'gold guardian sigils'],
        theme: <String>['imperial martial artist', 'dragon guardian motif'],
      ),
      _profile(
        _ara,
        classEn: 'Apsara',
        classZh: '妃天武皇',
        classTag: 'apsara',
        palette: '白色 × 青綠色 × 金色',
        hair: <String>[
          'very long black hair',
          'flowing ponytail',
          'teal hair ribbons'
        ],
        head: <String>[
          'gold lotus forehead ornament',
          'teal feather hair ornaments'
        ],
        outfit: <String>[
          'celestial eastern martial outfit',
          'white-and-teal flowing silhouette'
        ],
        upper: <String>[
          'white sleeveless martial top',
          'teal detached sleeves',
          'gold chest ornament'
        ],
        lower: <String>[
          'flowing white skirt panels',
          'teal layered drapery',
          'gold waist sash'
        ],
        legwear: <String>['white leg wraps', 'teal ankle guards'],
        footwear: <String>['white martial boots', 'gold sole guards'],
        accessories: <String>['lotus waist charm', 'flowing ribbon streamers'],
        weapon: <String>[
          'celestial jade spear',
          'gold spear head',
          'teal spear ribbons'
        ],
        magic: <String>['teal wind ribbons', 'gold lotus sigils'],
        theme: <String>['celestial martial artist', 'lotus guardian motif'],
      ),
      _profile(
        _ara,
        classEn: 'Yama Raja',
        classZh: '冥王',
        classTag: 'yama_raja',
        palette: '黑色 × 深紫色 × 金色',
        hair: <String>[
          'long black hair',
          'high ponytail',
          'purple hair ribbons'
        ],
        head: <String>[
          'dark gold forehead ornament',
          'purple demon hair ornaments'
        ],
        outfit: <String>[
          'dark eastern battle outfit',
          'black-and-purple royal silhouette'
        ],
        upper: <String>[
          'black fitted martial bodice',
          'purple armored sleeves',
          'gold chest guards'
        ],
        lower: <String>[
          'black split skirt panels',
          'deep purple waist drapery',
          'gold belt plates'
        ],
        legwear: <String>['black leg wraps', 'purple knee armor'],
        footwear: <String>['black armored boots', 'gold pointed guards'],
        accessories: <String>['demon talisman belt', 'purple prayer beads'],
        weapon: <String>[
          'dark ceremonial spear',
          'purple spear blade',
          'gold polearm ornaments'
        ],
        magic: <String>['violet qi flames', 'dark talisman particles'],
        theme: <String>['underworld martial artist', 'demon king motif'],
      ),
      _profile(
        _ara,
        classEn: 'Devi',
        classZh: '梵天武皇',
        classTag: 'devi',
        palette: '黑色 × 深紅色 × 金色',
        hair: <String>[
          'long black hair',
          'flowing high ponytail',
          'crimson hair ribbons'
        ],
        head: <String>[
          'crimson forehead jewel',
          'gold horn-shaped hair ornaments'
        ],
        outfit: <String>[
          'demonic eastern martial outfit',
          'black-and-crimson battle silhouette'
        ],
        upper: <String>[
          'black fitted combat top',
          'crimson detached sleeves',
          'gold armored collar'
        ],
        lower: <String>[
          'crimson split skirt panels',
          'black layered waist drapery',
          'gold belt ornaments'
        ],
        legwear: <String>['black thigh guards', 'crimson leg wraps'],
        footwear: <String>['black combat boots', 'gold heel guards'],
        accessories: <String>['demon seal talismans', 'crimson waist chains'],
        weapon: <String>[
          'crimson demon spear',
          'black polearm shaft',
          'gold spear ornaments'
        ],
        magic: <String>['crimson demon flames', 'dark qi particles'],
        theme: <String>['demon martial sovereign', 'crimson curse motif'],
      ),
      _profile(
        _ara,
        classEn: 'Asura',
        classZh: '修羅',
        classTag: 'asura',
        palette: '黑色 × 靛藍色 × 銀色',
        hair: <String>[
          'very long black hair',
          'side ponytail',
          'blue hair ribbons'
        ],
        head: <String>['silver fox hair ornament', 'blue talisman hairpin'],
        outfit: <String>[
          'spectral eastern warrior outfit',
          'black-and-blue layered silhouette'
        ],
        upper: <String>[
          'black sleeveless martial top',
          'blue detached sleeves',
          'silver chest talismans'
        ],
        lower: <String>[
          'black layered skirt panels',
          'blue split drapery',
          'silver waist sash'
        ],
        legwear: <String>['black leg wraps', 'blue calf guards'],
        footwear: <String>['black martial boots', 'silver sole guards'],
        accessories: <String>['fox spirit talismans', 'silver waist charms'],
        weapon: <String>[
          'spectral blue spear',
          'silver spear blade',
          'talisman-wrapped shaft'
        ],
        magic: <String>['blue foxfire', 'spectral talisman trails'],
        theme: <String>['fox spirit warrior', 'spectral martial motif'],
      ),
      _profile(
        _ara,
        classEn: 'Shakti',
        classZh: '羅天武皇',
        classTag: 'shakti',
        palette: '白色 × 粉紅色 × 金色',
        hair: <String>[
          'very long black hair',
          'flowing ponytail',
          'pink ribbon ties'
        ],
        head: <String>['gold fox hair ornament', 'pink gemstone hairpin'],
        outfit: <String>[
          'sacred fox spirit outfit',
          'white-and-pink ceremonial silhouette'
        ],
        upper: <String>[
          'white fitted martial top',
          'pink detached sleeves',
          'gold chest jewel'
        ],
        lower: <String>[
          'white layered skirt panels',
          'pink flowing drapery',
          'gold waist sash'
        ],
        legwear: <String>['white leg wraps', 'pink ankle guards'],
        footwear: <String>['white martial boots', 'gold toe guards'],
        accessories: <String>['fox spirit charms', 'pink prayer ribbons'],
        weapon: <String>[
          'sacred fox spear',
          'gold spear head',
          'pink ribbon streamers'
        ],
        magic: <String>['pink foxfire', 'gold spirit sigils'],
        theme: <String>['sacred fox guardian', 'celestial spirit motif'],
      ),
      _profile(
        _ara,
        classEn: 'Marici',
        classZh: '陽琰',
        classTag: 'marici',
        palette: '珊瑚色 × 白色 × 金色',
        hair: <String>[
          'long black hair',
          'high ponytail',
          'coral hair ribbons'
        ],
        eyes: <String>['amber eyes'],
        head: <String>['sun-disc hair ornament', 'gold forehead jewel'],
        outfit: <String>[
          'sunlit eastern martial outfit',
          'coral-and-white layered silhouette'
        ],
        upper: <String>[
          'white fitted martial jacket',
          'coral detached sleeves',
          'gold chest guards'
        ],
        lower: <String>[
          'coral split skirt panels',
          'white flowing waist drapery',
          'gold belt plates'
        ],
        legwear: <String>['white leg wraps', 'coral knee guards'],
        footwear: <String>['white armored boots', 'gold sole plates'],
        accessories: <String>['sun talisman belt', 'coral waist ribbons'],
        weapon: <String>[
          'sunlit ceremonial spear',
          'gold spear head',
          'coral spear ribbons'
        ],
        magic: <String>['solar qi trails', 'gold light particles'],
        theme: <String>['sun martial artist', 'radiant guardian motif'],
      ),
      _profile(
        _ara,
        classEn: 'Surya',
        classZh: '日天',
        classTag: 'surya',
        palette: '白色 × 金色 × 橘色 × 青綠色',
        hair: <String>[
          'very long teal-black hair',
          'high ponytail',
          'orange ribbon ties'
        ],
        eyes: <String>['orange eyes', 'gold eyes'],
        head: <String>['gold sun-disc hair ornament', 'teal gemstone hairpin'],
        outfit: <String>[
          'solar celestial martial outfit',
          'white-and-gold regal silhouette'
        ],
        upper: <String>[
          'white fitted celestial jacket',
          'gold shoulder guards',
          'orange chest jewel'
        ],
        lower: <String>[
          'white layered skirt panels',
          'orange split drapery',
          'gold waist sash'
        ],
        legwear: <String>['white leg wraps', 'gold calf guards'],
        footwear: <String>['white armored boots', 'gold pointed toe guards'],
        accessories: <String>['solar halo ornament', 'gold talisman ribbons'],
        weapon: <String>[
          'solar spear',
          'gold circular spear guard',
          'orange light spear blade'
        ],
        magic: <String>[
          'solar rays',
          'gold light sigils',
          'orange flame particles'
        ],
        theme: <String>['sun deity martial artist', 'radiant spear motif'],
      ),
      // Elesis ------------------------------------------------------------
      _profile(
        _elesis,
        classEn: 'Grand Master',
        classZh: '舞劍聖姬',
        classTag: 'grand_master',
        palette: '白色 × 紅色 × 金色',
        hair: <String>['long red hair', 'high ponytail', 'gold hair clasp'],
        head: <String>['gold knight head ornament', 'red ribbon tie'],
        outfit: <String>[
          'royal knight outfit',
          'white-and-red armored silhouette'
        ],
        upper: <String>[
          'white knight cuirass',
          'red shoulder armor',
          'gold chest crest'
        ],
        lower: <String>[
          'red layered skirt armor',
          'white hip plates',
          'gold waist belt'
        ],
        legwear: <String>['white armored leggings', 'red knee guards'],
        footwear: <String>['white armored boots', 'gold toe guards'],
        accessories: <String>['royal knight capelet', 'gold sword belt'],
        weapon: <String>[
          'ornate greatsword',
          'white-and-gold blade',
          'red sword tassel'
        ],
        magic: <String>['gold sword trails', 'royal crest particles'],
        theme: <String>['royal sword master', 'imperial knight motif'],
      ),
      _profile(
        _elesis,
        classEn: 'Empire Sword',
        classZh: '帝國之劍',
        classTag: 'empire_sword',
        palette: '黑色 × 深紅色 × 金色',
        hair: <String>[
          'long red hair',
          'high ponytail',
          'black-and-gold hair clasp'
        ],
        head: <String>['gold imperial head ornament', 'dark red ribbon tie'],
        outfit: <String>[
          'imperial knight outfit',
          'black-and-crimson armored silhouette'
        ],
        upper: <String>[
          'black knight cuirass',
          'crimson shoulder armor',
          'gold imperial chest crest'
        ],
        lower: <String>[
          'deep red layered skirt armor',
          'black hip plates',
          'gold waist belt'
        ],
        legwear: <String>['black armored leggings', 'crimson knee guards'],
        footwear: <String>['black armored boots', 'gold toe guards'],
        accessories: <String>['imperial sword belt', 'gold command insignia'],
        weapon: <String>[
          'imperial greatsword',
          'black-and-gold blade',
          'crimson sword guard'
        ],
        magic: <String>['gold sword trails', 'imperial command sigils'],
        theme: <String>['empire sword commander', 'imperial knight motif'],
      ),
      _profile(
        _elesis,
        classEn: 'Blazing Heart',
        classZh: '斷罪緋皇',
        classTag: 'blazing_heart',
        palette: '紅色 × 黑色 × 橘色',
        hair: <String>[
          'long red hair',
          'flowing ponytail',
          'flame-shaped hair ornament'
        ],
        eyes: <String>['fiery red eyes'],
        head: <String>['black flame hair clasp', 'orange gemstone hairpin'],
        outfit: <String>[
          'flame knight outfit',
          'red-and-black battle silhouette'
        ],
        upper: <String>[
          'red armored bodice',
          'black shoulder guards',
          'orange chest crystal'
        ],
        lower: <String>[
          'red layered skirt armor',
          'black split waist panels',
          'flame-pattern belt'
        ],
        legwear: <String>['black armored leggings', 'red knee guards'],
        footwear: <String>['black armored boots', 'orange sole guards'],
        accessories: <String>['flame emblem belt', 'red armor ribbons'],
        weapon: <String>[
          'flaming greatsword',
          'black blade core',
          'orange flame edge'
        ],
        magic: <String>['orange flames', 'red ember particles'],
        theme: <String>['flame sword knight', 'blazing battle motif'],
      ),
      _profile(
        _elesis,
        classEn: 'Flame Lord',
        classZh: '毀焰尊爵',
        classTag: 'flame_lord',
        palette: '深紅色 × 黑色 × 橘色 × 金色',
        hair: <String>[
          'very long crimson hair',
          'high ponytail',
          'gold flame hair clasp'
        ],
        eyes: <String>['orange-red eyes'],
        head: <String>['gold flame crown ornament', 'black hair ribbons'],
        outfit: <String>[
          'flame sovereign knight outfit',
          'crimson-and-black regal silhouette'
        ],
        upper: <String>[
          'black armored bodice',
          'crimson shoulder armor',
          'gold chest emblem'
        ],
        lower: <String>[
          'crimson layered skirt armor',
          'black split panels',
          'gold waist plates'
        ],
        legwear: <String>['black armored leggings', 'crimson calf guards'],
        footwear: <String>['black armored boots', 'gold flame heel guards'],
        accessories: <String>['flame command belt', 'gold armor chains'],
        weapon: <String>[
          'flame lord greatsword',
          'black-and-crimson blade',
          'gold sword guard'
        ],
        magic: <String>['roaring flame aura', 'ember storm particles'],
        theme: <String>['flame sovereign', 'regal inferno motif'],
      ),
      _profile(
        _elesis,
        classEn: 'Crimson Avenger',
        classZh: '紅蓮復仇者',
        classTag: 'crimson_avenger',
        palette: '黑色 × 深紅色 × 銀色',
        hair: <String>[
          'long crimson hair',
          'windblown hair',
          'black ribbon ties'
        ],
        eyes: <String>['crimson eyes'],
        head: <String>['black blade-shaped hair ornament', 'silver hair clasp'],
        outfit: <String>[
          'dark avenger knight outfit',
          'black-and-crimson battle silhouette'
        ],
        upper: <String>[
          'black fitted armored bodice',
          'crimson detached sleeves',
          'silver chest plates'
        ],
        lower: <String>[
          'black split skirt panels',
          'crimson layered drapery',
          'silver waist belt'
        ],
        legwear: <String>['black armored leg guards', 'crimson knee plates'],
        footwear: <String>['black combat boots', 'silver toe guards'],
        accessories: <String>['dark revenge emblem', 'crimson waist chains'],
        weapon: <String>[
          'dark crimson greatsword',
          'black blade edge',
          'silver sword guard'
        ],
        magic: <String>['crimson blood aura', 'black slash particles'],
        theme: <String>['dark avenger', 'crimson revenge motif'],
      ),
      _profile(
        _elesis,
        classEn: 'Bloody Queen',
        classZh: '紅蓮女王',
        classTag: 'bloody_queen',
        palette: '黑色 × 深紅色 × 金色',
        hair: <String>[
          'very long crimson hair',
          'high ponytail',
          'gold hair ornaments'
        ],
        eyes: <String>['crimson eyes'],
        head: <String>['gold queen crown ornament', 'black ribbon ties'],
        outfit: <String>[
          'crimson queen knight outfit',
          'black-and-red regal silhouette'
        ],
        upper: <String>[
          'black armored bodice',
          'crimson shoulder guards',
          'gold chest jewel'
        ],
        lower: <String>[
          'large crimson layered skirt armor',
          'black split panels',
          'gold waist corset'
        ],
        legwear: <String>['black armored leggings', 'crimson thigh guards'],
        footwear: <String>['black armored boots', 'gold heel guards'],
        accessories: <String>['queen sword belt', 'crimson armor chains'],
        weapon: <String>[
          'bloody queen greatsword',
          'crimson blade',
          'gold sword guard'
        ],
        magic: <String>['crimson blood energy', 'dark rose particles'],
        theme: <String>['crimson battle queen', 'blood sword motif'],
      ),
      _profile(
        _elesis,
        classEn: 'Patrona',
        classZh: '守護聖女',
        classTag: 'patrona',
        palette: '白色 × 藍色 × 金色',
        hair: <String>['long red hair', 'high ponytail', 'blue ribbon ties'],
        eyes: <String>['blue eyes'],
        head: <String>['gold guardian head ornament', 'blue gemstone hairpin'],
        outfit: <String>[
          'holy guardian knight outfit',
          'white-and-blue ceremonial silhouette'
        ],
        upper: <String>[
          'white knight cuirass',
          'blue shoulder guards',
          'gold chest crest'
        ],
        lower: <String>[
          'white layered skirt armor',
          'blue split drapery',
          'gold waist belt'
        ],
        legwear: <String>['white armored leggings', 'blue knee guards'],
        footwear: <String>['white armored boots', 'gold toe guards'],
        accessories: <String>['guardian crest belt', 'blue prayer ribbons'],
        weapon: <String>[
          'holy guardian sword',
          'white-and-gold blade',
          'blue sword gem'
        ],
        magic: <String>['blue holy light', 'gold shield sigils'],
        theme: <String>['holy guardian knight', 'sanctuary sword motif'],
      ),
      _profile(
        _elesis,
        classEn: 'Adrestia',
        classZh: '世界聖劍',
        classTag: 'adrestia',
        palette: '白色 × 銀色 × 藍色 × 金色',
        hair: <String>[
          'long red hair',
          'flowing high ponytail',
          'blue ribbon ties'
        ],
        eyes: <String>['blue eyes', 'amber-red eyes'],
        head: <String>['silver holy head ornament', 'gold crest hairpin'],
        outfit: <String>[
          'sacred sword knight outfit',
          'white-and-silver regal silhouette'
        ],
        upper: <String>[
          'white fitted knight armor',
          'silver shoulder guards',
          'blue chest crystal'
        ],
        lower: <String>[
          'white layered skirt armor',
          'blue split panels',
          'gold waist plates'
        ],
        legwear: <String>['silver armored leggings', 'blue knee guards'],
        footwear: <String>['white armored boots', 'silver sole guards'],
        accessories: <String>['holy crest belt', 'gold prayer chains'],
        weapon: <String>[
          'sacred world sword',
          'white-and-gold blade',
          'blue holy core'
        ],
        magic: <String>[
          'blue holy light',
          'gold sword sigils',
          'silver light particles'
        ],
        theme: <String>['sacred sword guardian', 'world sword motif'],
      ),
      // Lu / Luciela ------------------------------------------------------
      _profile(
        _lu,
        classEn: 'Dreadlord',
        classZh: '邪恐夜皇',
        classTag: 'dreadlord',
        palette: '黑色 × 深紅色 × 紫色',
        hair: <String>[
          'very long pale silver hair',
          'flowing hair',
          'black ribbon ties'
        ],
        head: <String>['curved black demon horns', 'crimson horn ornaments'],
        outfit: <String>[
          'demon lord outfit',
          'black-and-crimson regal silhouette'
        ],
        upper: <String>[
          'black fitted demon bodice',
          'crimson chest armor',
          'purple collar ornament'
        ],
        lower: <String>[
          'black layered skirt panels',
          'crimson split drapery',
          'demon waist belt'
        ],
        legwear: <String>['black thigh guards', 'crimson leg straps'],
        footwear: <String>['black demon boots', 'crimson heel guards'],
        accessories: <String>['demon royal crest', 'black waist chains'],
        weapon: <String>[
          'demon command gauntlet',
          'black demonic blade',
          'crimson crystal core'
        ],
        magic: <String>['crimson demon aura', 'purple curse particles'],
        theme: <String>['demon lord', 'royal underworld motif'],
      ),
      _profile(
        _lu,
        classEn: 'Catastrophe',
        classZh: '災禍魔王',
        classTag: 'catastrophe',
        palette: '黑色 × 深紅色 × 金色',
        hair: <String>[
          'very long pale silver hair',
          'windblown hair',
          'crimson ribbon ties'
        ],
        eyes: <String>['crimson eyes', 'gold eyes'],
        head: <String>['black demon horns', 'gold horn ornaments'],
        outfit: <String>[
          'catastrophe demon ruler outfit',
          'black-and-crimson ceremonial silhouette'
        ],
        upper: <String>[
          'black fitted demon jacket',
          'crimson armored sleeves',
          'gold chest jewel'
        ],
        lower: <String>[
          'crimson layered skirt panels',
          'black split drapery',
          'gold waist ornament'
        ],
        legwear: <String>['black leg guards', 'crimson thigh straps'],
        footwear: <String>['black demon boots', 'gold pointed guards'],
        accessories: <String>[
          'catastrophe crest',
          'black-and-gold waist chains'
        ],
        weapon: <String>[
          'catastrophe demon weapon',
          'black clawed gauntlet',
          'crimson magic core'
        ],
        magic: <String>['crimson catastrophe flames', 'black curse particles'],
        theme: <String>['catastrophe demon ruler', 'ruin magic motif'],
      ),
      _profile(
        _lu,
        classEn: 'Noblesse',
        classZh: '闇夜女爵',
        classTag: 'noblesse',
        palette: '白色 × 深藍色 × 金色',
        hair: <String>[
          'very long pale silver hair',
          'smooth flowing hair',
          'blue ribbon ties'
        ],
        eyes: <String>['blue eyes', 'crimson eyes'],
        head: <String>['elegant demon horns', 'gold royal hair ornament'],
        outfit: <String>[
          'demon noble outfit',
          'white-and-navy regal silhouette'
        ],
        upper: <String>[
          'white fitted noble bodice',
          'navy sleeves',
          'gold collar ornament'
        ],
        lower: <String>[
          'navy layered skirt panels',
          'white split drapery',
          'gold waist belt'
        ],
        legwear: <String>['navy leg guards', 'white thigh straps'],
        footwear: <String>['white demon boots', 'gold heel guards'],
        accessories: <String>['noble crest brooch', 'gold jewel chains'],
        weapon: <String>[
          'demon noble scepter',
          'white-and-gold staff',
          'blue jewel core'
        ],
        magic: <String>['blue demon aura', 'gold royal sigils'],
        theme: <String>['demon noblewoman', 'royal command motif'],
      ),
      _profile(
        _lu,
        classEn: 'Innocent',
        classZh: '釋罪女皇',
        classTag: 'innocent',
        palette: '白色 × 金色 × 深藍色',
        hair: <String>[
          'very long pale silver hair',
          'flowing hair',
          'gold ribbon ties'
        ],
        eyes: <String>['blue eyes', 'gold eyes'],
        head: <String>['white demon horns', 'gold crown ornament'],
        outfit: <String>[
          'innocent demon queen outfit',
          'white-and-gold regal silhouette'
        ],
        upper: <String>[
          'white fitted royal bodice',
          'blue detached sleeves',
          'gold chest jewel'
        ],
        lower: <String>[
          'white layered skirt panels',
          'navy split drapery',
          'gold waist corset'
        ],
        legwear: <String>['white leg guards', 'gold thigh straps'],
        footwear: <String>['white royal boots', 'gold sole guards'],
        accessories: <String>['forgiveness crest', 'gold prayer chains'],
        weapon: <String>[
          'innocent royal scepter',
          'white-and-gold demon staff',
          'blue jewel core'
        ],
        magic: <String>['white demon light', 'gold absolution sigils'],
        theme: <String>['demon queen of absolution', 'noble command motif'],
      ),
      _profile(
        _lu,
        classEn: 'Demonio',
        classZh: '冷焰邪魔',
        classTag: 'demonio',
        palette: '黑色 × 藍色 × 紫色',
        hair: <String>[
          'very long pale silver hair',
          'wild flowing hair',
          'blue ribbon ties'
        ],
        eyes: <String>['blue eyes', 'crimson eyes'],
        head: <String>['black demon horns', 'blue crystal horn ornaments'],
        outfit: <String>[
          'cold flame demon outfit',
          'black-and-blue battle silhouette'
        ],
        upper: <String>[
          'black fitted demon bodice',
          'blue armored sleeves',
          'purple chest crystal'
        ],
        lower: <String>[
          'black split skirt panels',
          'blue layered drapery',
          'demon waist belt'
        ],
        legwear: <String>['black leg guards', 'blue thigh straps'],
        footwear: <String>['black demon boots', 'blue sole guards'],
        accessories: <String>['cold flame crest', 'black demon chains'],
        weapon: <String>[
          'cold flame demon gauntlet',
          'black claw weapon',
          'blue crystal core'
        ],
        magic: <String>['blue demon flames', 'violet curse particles'],
        theme: <String>['cold flame demon', 'abyssal battle motif'],
      ),
      _profile(
        _lu,
        classEn: 'Diangelion',
        classZh: '滅盡魔皇',
        classTag: 'diangelion',
        palette: '黑色 × 深紅色 × 紫色',
        hair: <String>[
          'very long pale silver hair',
          'windblown hair',
          'purple ribbon ties'
        ],
        eyes: <String>['crimson eyes', 'violet eyes'],
        head: <String>['large black demon horns', 'crimson horn jewels'],
        outfit: <String>[
          'annihilation demon ruler outfit',
          'black-and-crimson armored silhouette'
        ],
        upper: <String>[
          'black armored demon bodice',
          'crimson shoulder guards',
          'purple chest core'
        ],
        lower: <String>[
          'black layered skirt panels',
          'crimson split waist drapery',
          'demon belt plates'
        ],
        legwear: <String>['black armored leggings', 'crimson thigh guards'],
        footwear: <String>['black demon boots', 'purple heel guards'],
        accessories: <String>['annihilation crest', 'black crystal chains'],
        weapon: <String>[
          'annihilation demon weapon',
          'black blade gauntlet',
          'crimson energy core'
        ],
        magic: <String>['crimson destruction aura', 'purple abyss particles'],
        theme: <String>[
          'annihilation demon ruler',
          'abyssal destruction motif'
        ],
      ),
      _profile(
        _lu,
        classEn: 'Turbids',
        classZh: '混沌執政',
        classTag: 'turbids',
        palette: '深藍色 × 黑色 × 白色',
        hair: <String>[
          'very long pale silver hair',
          'swept hair',
          'blue ribbon ties'
        ],
        eyes: <String>['blue eyes', 'crimson eyes'],
        head: <String>['black demon horns', 'blue crystal hair ornament'],
        outfit: <String>[
          'chaos governor outfit',
          'navy-and-black ceremonial silhouette'
        ],
        upper: <String>[
          'navy fitted demon jacket',
          'black armored sleeves',
          'white chest emblem'
        ],
        lower: <String>[
          'black layered skirt panels',
          'navy split drapery',
          'white waist ornament'
        ],
        legwear: <String>['black leg guards', 'navy thigh straps'],
        footwear: <String>['black demon boots', 'blue sole guards'],
        accessories: <String>['chaos crest', 'white crystal chains'],
        weapon: <String>[
          'chaos command staff',
          'black-and-blue demon staff',
          'white crystal core'
        ],
        magic: <String>['navy chaos mist', 'white distortion particles'],
        theme: <String>['chaos governor', 'abyss command motif'],
      ),
      _profile(
        _lu,
        classEn: 'Demersio',
        classZh: '深淵魔君',
        classTag: 'demersio',
        palette: '黑色 × 白色 × 靛藍色 × 金色',
        hair: <String>[
          'very long pale silver hair',
          'flowing hair',
          'indigo ribbon ties'
        ],
        eyes: <String>['blue eyes', 'gold eyes'],
        head: <String>['black demon horns', 'gold abyss crown ornament'],
        outfit: <String>[
          'abyssal demon ruler outfit',
          'black-and-white regal silhouette'
        ],
        upper: <String>[
          'white fitted demon bodice',
          'black armored sleeves',
          'indigo chest core'
        ],
        lower: <String>[
          'black layered skirt panels',
          'white split drapery',
          'gold abyss belt'
        ],
        legwear: <String>['black armored leggings', 'white thigh guards'],
        footwear: <String>['black demon boots', 'gold heel guards'],
        accessories: <String>['abyssal crown crest', 'gold crystal chains'],
        weapon: <String>[
          'abyssal command weapon',
          'black-and-gold demon staff',
          'indigo crystal core'
        ],
        magic: <String>[
          'abyssal blue aura',
          'black void particles',
          'gold command sigils'
        ],
        theme: <String>['abyssal demon ruler', 'void command motif'],
      ),
      // Rose --------------------------------------------------------------
      _profile(
        _rose,
        classEn: 'Storm Trooper',
        classZh: '暴風騎兵',
        classTag: 'storm_trooper',
        palette: '白色 × 藍色 × 銀色',
        hair: <String>['long blonde hair', 'high ponytail', 'blue ribbon tie'],
        head: <String>['blue military beret', 'silver headset module'],
        outfit: <String>[
          'military artillery outfit',
          'white-and-blue tactical silhouette'
        ],
        upper: <String>[
          'white fitted military jacket',
          'blue armored shoulder pads',
          'silver chest buckles'
        ],
        lower: <String>[
          'blue tactical skirt panels',
          'white utility belt',
          'silver ammunition pouches'
        ],
        legwear: <String>['blue tactical legwear', 'white knee guards'],
        footwear: <String>['white combat boots', 'blue armored soles'],
        accessories: <String>['artillery harness', 'military utility belt'],
        weapon: <String>[
          'heavy artillery cannon',
          'white-and-blue launcher',
          'silver ammunition drum'
        ],
        magic: <String>['artillery smoke', 'blue muzzle flash'],
        theme: <String>['storm artillery gunner', 'military bombardment motif'],
      ),
      _profile(
        _rose,
        classEn: 'Tempest Burster',
        classZh: '暴風破壞者',
        classTag: 'tempest_burster',
        palette: '白色 × 靛藍色 × 金色',
        hair: <String>[
          'long blonde hair',
          'high ponytail',
          'indigo ribbon tie'
        ],
        eyes: <String>['cyan-blue eyes'],
        head: <String>['indigo military headpiece', 'gold headset modules'],
        outfit: <String>[
          'tempest artillery commander outfit',
          'white-and-indigo tactical silhouette'
        ],
        upper: <String>[
          'white fitted command jacket',
          'indigo armored sleeves',
          'gold chest clasps'
        ],
        lower: <String>[
          'indigo tactical skirt panels',
          'white utility belt',
          'gold ammunition modules'
        ],
        legwear: <String>['indigo tactical legwear', 'white knee armor'],
        footwear: <String>['white combat boots', 'gold armored soles'],
        accessories: <String>[
          'command artillery harness',
          'gold targeting device'
        ],
        weapon: <String>[
          'tempest rail cannon',
          'white-and-indigo heavy launcher',
          'gold energy chamber'
        ],
        magic: <String>['blue shockwave trails', 'gold artillery sparks'],
        theme: <String>['tempest artillery commander', 'heavy cannon motif'],
      ),
      _profile(
        _rose,
        classEn: 'Crimson Rose',
        classZh: '緋紅玫瑰',
        classTag: 'crimson_rose',
        palette: '黑色 × 深紅色 × 銀色',
        hair: <String>[
          'long blonde hair',
          'side ponytail',
          'crimson ribbon tie'
        ],
        head: <String>['black military cap', 'silver earpiece'],
        outfit: <String>[
          'crimson gunner outfit',
          'black-and-red tactical silhouette'
        ],
        upper: <String>[
          'black fitted gunner jacket',
          'crimson sleeves',
          'silver chest harness'
        ],
        lower: <String>[
          'black tactical skirt panels',
          'crimson utility belt',
          'silver holsters'
        ],
        legwear: <String>['black tactical legwear', 'crimson thigh straps'],
        footwear: <String>['black combat boots', 'silver sole guards'],
        accessories: <String>[
          'dual pistol holsters',
          'crimson ammunition belt'
        ],
        weapon: <String>[
          'dual crimson revolvers',
          'black pistol frames',
          'silver trigger guards'
        ],
        magic: <String>['crimson muzzle flash', 'black gun smoke'],
        theme: <String>['crimson gunner', 'dual revolver motif'],
      ),
      _profile(
        _rose,
        classEn: 'Black Massacre',
        classZh: '黑色徒殺者',
        classTag: 'black_massacre',
        palette: '黑色 × 深紅色 × 紫色',
        hair: <String>[
          'long blonde hair',
          'flowing side ponytail',
          'black ribbon tie'
        ],
        eyes: <String>['crimson eyes'],
        head: <String>['black military cap', 'violet earpiece module'],
        outfit: <String>[
          'black massacre gunner outfit',
          'black-and-crimson assassin silhouette'
        ],
        upper: <String>[
          'black fitted tactical jacket',
          'crimson armored sleeves',
          'violet chest harness'
        ],
        lower: <String>[
          'black layered tactical panels',
          'crimson holster belt',
          'violet ammunition modules'
        ],
        legwear: <String>['black tactical legwear', 'crimson thigh straps'],
        footwear: <String>['black combat boots', 'violet heel guards'],
        accessories: <String>['dual pistol holsters', 'black ammunition belt'],
        weapon: <String>[
          'dual black pistols',
          'crimson pistol accents',
          'violet energy chambers'
        ],
        magic: <String>[
          'dark gun smoke',
          'crimson muzzle flash',
          'violet bullet trails'
        ],
        theme: <String>['black massacre gunner', 'dark dual pistol motif'],
      ),
      _profile(
        _rose,
        classEn: 'Freyja',
        classZh: '芙蕾雅',
        classTag: 'freyja',
        palette: '海軍藍 × 白色 × 金色',
        hair: <String>['long blonde hair', 'high ponytail', 'navy ribbon tie'],
        head: <String>['navy military beret', 'gold headset module'],
        outfit: <String>[
          'tactical aerial gunner outfit',
          'navy-and-white military silhouette'
        ],
        upper: <String>[
          'white fitted tactical jacket',
          'navy armored sleeves',
          'gold chest clasps'
        ],
        lower: <String>[
          'navy tactical skirt panels',
          'white utility belt',
          'gold grenade pouches'
        ],
        legwear: <String>['navy tactical legwear', 'white knee guards'],
        footwear: <String>['navy combat boots', 'gold sole guards'],
        accessories: <String>[
          'tactical grenade harness',
          'gold targeting module'
        ],
        weapon: <String>[
          'precision rifle',
          'navy-and-white firearm',
          'gold scope module'
        ],
        magic: <String>['gold muzzle sparks', 'blue aerial trails'],
        theme: <String>['tactical aerial gunner', 'precision firearm motif'],
      ),
      _profile(
        _rose,
        classEn: 'Minerva',
        classZh: '密涅瓦',
        classTag: 'minerva',
        palette: '深藍色 × 黑色 × 銀色',
        hair: <String>['long blonde hair', 'high ponytail', 'blue ribbon tie'],
        eyes: <String>['cyan-blue eyes'],
        head: <String>[
          'blue tactical headpiece',
          'silver communication headset'
        ],
        outfit: <String>[
          'minerva aerial gunner outfit',
          'blue-and-black tactical silhouette'
        ],
        upper: <String>[
          'black fitted tactical jacket',
          'blue armored sleeves',
          'silver chest harness'
        ],
        lower: <String>[
          'blue tactical skirt panels',
          'black utility belt',
          'silver device pouches'
        ],
        legwear: <String>['black tactical legwear', 'blue knee guards'],
        footwear: <String>['black combat boots', 'silver sole guards'],
        accessories: <String>[
          'aerial targeting harness',
          'silver tactical modules'
        ],
        weapon: <String>[
          'minerva tactical rifle',
          'black-and-blue firearm',
          'silver targeting scope'
        ],
        magic: <String>['blue aerial trails', 'silver muzzle sparks'],
        theme: <String>['aerial tactical gunner', 'mobile firearm motif'],
      ),
      _profile(
        _rose,
        classEn: 'Optimus',
        classZh: '機械之靈',
        classTag: 'optimus',
        palette: '白色 × 青綠色 × 灰色',
        hair: <String>['long blonde hair', 'side ponytail', 'teal ribbon tie'],
        eyes: <String>['cyan-blue eyes'],
        head: <String>['teal mechanical headset', 'gray control visor'],
        outfit: <String>[
          'mechanical operator outfit',
          'white-and-teal technical silhouette'
        ],
        upper: <String>[
          'white fitted operator jacket',
          'teal mechanical sleeves',
          'gray chest control panel'
        ],
        lower: <String>[
          'teal tactical skirt panels',
          'gray utility belt',
          'white drone modules'
        ],
        legwear: <String>['gray tactical legwear', 'teal knee guards'],
        footwear: <String>['white technical boots', 'teal sole guards'],
        accessories: <String>[
          'mechanical control harness',
          'drone command belt'
        ],
        weapon: <String>[
          'mechanical command rifle',
          'white-and-teal firearm',
          'gray drone controller'
        ],
        companions: <String>['floating mechanical drones'],
        magic: <String>['teal digital particles', 'mechanical command signals'],
        theme: <String>['mechanical operator', 'drone command motif'],
      ),
      _profile(
        _rose,
        classEn: 'Prime Operator',
        classZh: '軍械首席',
        classTag: 'prime_operator',
        palette: '白色 × 金色 × 青綠色 × 灰色',
        hair: <String>['long blonde hair', 'high ponytail', 'teal ribbon tie'],
        eyes: <String>['cyan-blue eyes'],
        head: <String>['white command headset', 'gold mechanical visor'],
        outfit: <String>[
          'prime operator outfit',
          'white-and-gold command silhouette'
        ],
        upper: <String>[
          'white fitted command jacket',
          'teal mechanical sleeves',
          'gold chest control core'
        ],
        lower: <String>[
          'white tactical skirt panels',
          'gray utility belt',
          'gold drone modules'
        ],
        legwear: <String>['gray tactical legwear', 'white knee guards'],
        footwear: <String>['white command boots', 'gold sole guards'],
        accessories: <String>['prime control harness', 'gold command belt'],
        weapon: <String>[
          'prime operator firearm',
          'white-and-gold command rifle',
          'teal energy chamber'
        ],
        companions: <String>['floating command drones'],
        magic: <String>['teal command signals', 'gold digital particles'],
        theme: <String>['prime mechanical commander', 'drone operator motif'],
      ),
      // Laby --------------------------------------------------------------
      _profile(
        _laby,
        classEn: 'Rumble Pumn',
        classZh: '堅毅格鬥者',
        classTag: 'rumble_pumn',
        palette: '粉紅色 × 白色 × 深藍色',
        hair: <String>['light pink hair', 'layered bob cut', 'ahoge'],
        head: <String>['pink hair clip', 'navy headband'],
        outfit: <String>[
          'mirror boxer outfit',
          'pink-and-white combat silhouette'
        ],
        upper: <String>[
          'white fitted combat top',
          'pink boxing jacket',
          'navy chest straps'
        ],
        lower: <String>[
          'pink layered skirt panels',
          'white fitted lower garment',
          'navy waist belt'
        ],
        legwear: <String>['white leg wraps', 'pink knee guards'],
        footwear: <String>['pink combat boots', 'navy sole guards'],
        accessories: <String>['mirror emblem belt', 'pink boxing wraps'],
        weapon: <String>[
          'mirror boxing gauntlets',
          'pink impact gloves',
          'navy knuckle guards'
        ],
        magic: <String>['pink impact trails', 'mirror spark particles'],
        theme: <String>['mirror boxer', 'energetic combat motif'],
      ),
      _profile(
        _laby,
        classEn: 'Eternity Winner',
        classZh: '永恆勝者',
        classTag: 'eternity_winner',
        palette: '粉紅色 × 白色 × 金色',
        hair: <String>['light pink hair', 'flowing layered hair', 'ahoge'],
        eyes: <String>['pink eyes', 'gold eyes'],
        head: <String>['gold mirror hair ornament', 'pink ribbon ties'],
        outfit: <String>[
          'eternal champion outfit',
          'pink-and-white heroic silhouette'
        ],
        upper: <String>[
          'white fitted combat jacket',
          'pink armored sleeves',
          'gold chest emblem'
        ],
        lower: <String>[
          'pink layered skirt panels',
          'white fitted lower garment',
          'gold waist belt'
        ],
        legwear: <String>['white leg wraps', 'pink knee guards'],
        footwear: <String>['white combat boots', 'gold sole guards'],
        accessories: <String>['champion mirror crest', 'gold victory ribbons'],
        weapon: <String>[
          'eternal mirror gauntlets',
          'pink energy gloves',
          'gold knuckle guards'
        ],
        magic: <String>['gold impact rings', 'pink victory particles'],
        theme: <String>['eternal mirror champion', 'victory combat motif'],
      ),
      _profile(
        _laby,
        classEn: 'Shining Romantica',
        classZh: '奪目浪漫者',
        classTag: 'shining_romantica',
        palette: '白色 × 粉紅色 × 金色',
        hair: <String>[
          'light pink hair',
          'flowing layered hair',
          'side ribbon ties'
        ],
        eyes: <String>['pink eyes', 'gold eyes'],
        head: <String>['gold mirror hair ornament', 'pink bow hair clip'],
        outfit: <String>[
          'radiant romantic outfit',
          'white-and-pink layered silhouette'
        ],
        upper: <String>[
          'white fitted blouse',
          'pink detached sleeves',
          'gold chest ribbon'
        ],
        lower: <String>[
          'pink layered skirt panels',
          'white inner frills',
          'gold waist ornament'
        ],
        legwear: <String>['white lace legwear', 'pink garter straps'],
        footwear: <String>['white ankle boots', 'gold heel guards'],
        accessories: <String>['romantic mirror brooch', 'pink jewel chains'],
        weapon: <String>[
          'radiant mirror focus',
          'white-and-gold mirror frame',
          'pink jewel core'
        ],
        magic: <String>['pink sparkling light', 'gold heart-shaped particles'],
        theme: <String>['radiant romantic magician', 'mirror light motif'],
      ),
      _profile(
        _laby,
        classEn: 'Radiant Soul',
        classZh: '燦光靈者',
        classTag: 'radiant_soul',
        palette: '白色 × 粉紅色 × 金色 × 淡紫色',
        hair: <String>[
          'light pink hair',
          'very long flowing hair',
          'soft ribbon ties'
        ],
        eyes: <String>['pink eyes', 'gold eyes'],
        head: <String>['gold mirror crown ornament', 'pink gemstone hairpin'],
        outfit: <String>[
          'radiant soul outfit',
          'white-and-pink ceremonial silhouette'
        ],
        upper: <String>[
          'white fitted ceremonial top',
          'pink translucent sleeves',
          'gold chest jewel'
        ],
        lower: <String>[
          'white layered skirt panels',
          'pink flowing drapery',
          'gold waist belt'
        ],
        legwear: <String>['white lace legwear', 'pink ankle ribbons'],
        footwear: <String>['white ankle boots', 'gold sole guards'],
        accessories: <String>['radiant mirror crest', 'pink crystal chains'],
        weapon: <String>[
          'radiant mirror focus',
          'gold mirror frame',
          'pink crystal core'
        ],
        companions: <String>['Nisha mirror companion'],
        magic: <String>['radiant pink aura', 'gold light particles'],
        theme: <String>['radiant soul magician', 'mirror companion motif'],
      ),
      _profile(
        _laby,
        classEn: 'Daydreamer',
        classZh: '幻夢者',
        classTag: 'daydreamer',
        palette: '黑色 × 紫色 × 粉紅色',
        hair: <String>[
          'light pink hair',
          'messy layered hair',
          'side ribbon ties'
        ],
        eyes: <String>['violet eyes', 'pink eyes'],
        head: <String>['purple mirror hair ornament', 'black ribbon tie'],
        outfit: <String>[
          'dream illusionist outfit',
          'black-and-purple layered silhouette'
        ],
        upper: <String>[
          'black fitted top',
          'purple detached sleeves',
          'pink chest jewel'
        ],
        lower: <String>[
          'purple layered skirt panels',
          'black inner frills',
          'pink waist belt'
        ],
        legwear: <String>['black patterned legwear', 'purple garter straps'],
        footwear: <String>['black ankle boots', 'pink sole accents'],
        accessories: <String>['dream mirror brooch', 'purple crystal chains'],
        weapon: <String>[
          'dream mirror focus',
          'black mirror frame',
          'pink crystal core'
        ],
        companions: <String>['Nisha mirror companion'],
        magic: <String>['purple dream mist', 'pink illusion particles'],
        theme: <String>['dream illusionist', 'mirror dream motif'],
      ),
      _profile(
        _laby,
        classEn: 'Nisha Labyrinth',
        classZh: '迷喚者',
        classTag: 'nisha_labyrinth',
        palette: '黑色 × 深紫色 × 粉紅色',
        hair: <String>[
          'light pink hair',
          'very long messy hair',
          'dark ribbon ties'
        ],
        eyes: <String>['violet eyes', 'pink eyes'],
        head: <String>['black mirror hair ornament', 'purple crystal hairpin'],
        outfit: <String>[
          'labyrinth mirror outfit',
          'black-and-violet layered silhouette'
        ],
        upper: <String>[
          'black fitted bodice',
          'deep purple detached sleeves',
          'pink mirror chest ornament'
        ],
        lower: <String>[
          'black layered skirt panels',
          'purple split drapery',
          'pink waist belt'
        ],
        legwear: <String>['black patterned legwear', 'purple thigh straps'],
        footwear: <String>['black ankle boots', 'violet heel guards'],
        accessories: <String>['labyrinth mirror brooch', 'dark crystal chains'],
        weapon: <String>[
          'dark mirror focus',
          'black mirror frame',
          'violet crystal core'
        ],
        companions: <String>['Nisha mirror companion'],
        magic: <String>['violet shadow mist', 'pink mirror shards'],
        theme: <String>['labyrinth mirror magician', 'dark dream motif'],
      ),
      _profile(
        _laby,
        classEn: 'Punky Poppet',
        classZh: '龐克寶貝',
        classTag: 'punky_poppet',
        palette: '黑色 × 粉紅色 × 紫色',
        hair: <String>[
          'light pink hair',
          'layered bob cut',
          'outward hair ends',
          'ahoge'
        ],
        eyes: <String>['pink eyes', 'violet eyes'],
        head: <String>[
          'purple goggles',
          'black headband',
          'pink bow hair clip'
        ],
        outfit: <String>[
          'punk mirror outfit',
          'black-and-pink layered silhouette'
        ],
        upper: <String>[
          'black cropped jacket',
          'pink oversized sleeves',
          'purple chest straps'
        ],
        lower: <String>[
          'black layered skirt panels',
          'pink inner frills',
          'purple waist belt'
        ],
        legwear: <String>['mismatched black legwear', 'pink thigh straps'],
        footwear: <String>['black chunky ankle boots', 'pink sole accents'],
        accessories: <String>['punk mirror brooch', 'black buckle chains'],
        weapon: <String>[
          'punk mirror focus',
          'black mirror frame',
          'purple crystal core'
        ],
        magic: <String>['pink graffiti particles', 'purple mirror shards'],
        theme: <String>['punk mirror trickster', 'mischievous stage motif'],
      ),
      _profile(
        _laby,
        classEn: 'Twins Picaro',
        classZh: '搗蛋雙星',
        classTag: 'twins_picaro',
        palette: '黑色 × 紫色 × 洋紅色 × 粉紅色',
        hair: <String>[
          'pale pink hair',
          'light blonde to pale pink gradient hair',
          'fluffy layered bob cut',
          'chin-length hair',
          'thick sidelocks',
          'messy hair',
          'outward hair ends',
          'ahoge',
        ],
        eyes: <String>['pink eyes'],
        head: <String>[
          'purple goggles',
          'black headband',
          'purple bow hair clip'
        ],
        outfit: <String>[
          'twins picaro trickster outfit',
          'black-and-purple asymmetrical silhouette'
        ],
        upper: <String>[
          'purple cropped jacket',
          'black oversized sleeves',
          'white cuff lining',
          'black straps and buckles'
        ],
        lower: <String>[
          'asymmetrical layered skirt',
          'black-and-magenta jagged panels',
          'fitted lower garment beneath skirt'
        ],
        legwear: <String>[
          'mismatched black legwear',
          'purple thigh straps',
          'pink garter accents'
        ],
        footwear: <String>['chunky purple ankle boots', 'pink boot soles'],
        accessories: <String>[
          'black waist belts',
          'metal rings',
          'hanging buckle ornaments'
        ],
        weapon: <String>[
          'trickster mirror focus',
          'black-and-purple mirror frame',
          'magenta crystal core'
        ],
        magic: <String>['purple mirror shards', 'pink prank particles'],
        theme: <String>[
          'mischievous mirror trickster',
          'wonderland stage motif'
        ],
      ),
      // Lithia ------------------------------------------------------------
      _profile(
        _lithia,
        classEn: 'Mighty Miner',
        classZh: '祕寶礦工',
        classTag: 'mighty_miner',
        palette: '棕色 × 綠色 × 金色',
        hair: <String>[
          'ash-blonde hair',
          'long braided hair',
          'green ribbon tie'
        ],
        head: <String>['mining hat', 'round protective goggles'],
        outfit: <String>[
          'gemstone miner outfit',
          'brown-and-green utility silhouette'
        ],
        upper: <String>[
          'brown fitted mining jacket',
          'green work sleeves',
          'gold chest buckles'
        ],
        lower: <String>[
          'brown utility skirt panels',
          'green tool belt',
          'gold pouch clasps'
        ],
        legwear: <String>['dark green legwear', 'brown knee guards'],
        footwear: <String>['brown work boots', 'gold sole guards'],
        accessories: <String>['gemstone tool belt', 'crystal pouches'],
        weapon: <String>[
          'crystal mining pickaxe',
          'gold pickaxe head',
          'green gemstone core'
        ],
        magic: <String>['gemstone spark particles', 'green crystal glow'],
        theme: <String>['gemstone miner', 'treasure excavation motif'],
      ),
      _profile(
        _lithia,
        classEn: 'Gembliss',
        classZh: '璀璨之智',
        classTag: 'gembliss',
        palette: '白色 × 青綠色 × 金色 × 水晶色',
        hair: <String>[
          'ash-blonde hair',
          'very long flowing hair',
          'teal ribbon ties'
        ],
        eyes: <String>['teal eyes', 'gold eyes'],
        head: <String>['crystal crown ornament', 'gold gemstone hairpin'],
        outfit: <String>[
          'gemstone scholar outfit',
          'white-and-teal crystalline silhouette'
        ],
        upper: <String>[
          'white fitted scholar jacket',
          'teal crystal sleeves',
          'gold chest jewel'
        ],
        lower: <String>[
          'white layered skirt panels',
          'teal crystal drapery',
          'gold waist belt'
        ],
        legwear: <String>['white patterned legwear', 'teal ankle crystals'],
        footwear: <String>['white ankle boots', 'gold crystal soles'],
        accessories: <String>[
          'floating gemstone ornaments',
          'gold crystal chains'
        ],
        weapon: <String>[
          'crystal pickaxe staff',
          'white-and-gold tool shaft',
          'teal crystal head'
        ],
        magic: <String>['floating gemstones', 'teal crystal light'],
        theme: <String>['gemstone scholar', 'crystal treasure motif'],
      ),
      _profile(
        _lithia,
        classEn: 'Greedy Wonder',
        classZh: '名癒奇姬',
        classTag: 'greedy_wonder',
        palette: '綠色 × 金色 × 白色',
        hair: <String>['ash-blonde hair', 'side ponytail', 'green ribbon tie'],
        eyes: <String>['teal eyes', 'gold eyes'],
        head: <String>['gold gemstone hair ornament', 'green crystal hairpin'],
        outfit: <String>[
          'treasure healer outfit',
          'green-and-gold ornate silhouette'
        ],
        upper: <String>[
          'white fitted healer jacket',
          'green sleeves',
          'gold gemstone chest ornament'
        ],
        lower: <String>[
          'green layered skirt panels',
          'white inner drapery',
          'gold coin belt'
        ],
        legwear: <String>['white legwear', 'green garter straps'],
        footwear: <String>['green ankle boots', 'gold heel guards'],
        accessories: <String>[
          'gemstone medicine bottles',
          'gold treasure chains'
        ],
        weapon: <String>[
          'gemstone healing tool',
          'gold crystal staff',
          'green jewel core'
        ],
        magic: <String>['green healing light', 'gold coin particles'],
        theme: <String>['treasure healer', 'gemstone remedy motif'],
      ),
      _profile(
        _lithia,
        classEn: 'Avarice',
        classZh: '愛芙瑞絲',
        classTag: 'avarice',
        palette: '深綠色 × 金色 × 黑色',
        hair: <String>[
          'ash-blonde hair',
          'very long flowing hair',
          'black ribbon ties'
        ],
        eyes: <String>['teal eyes', 'gold eyes'],
        head: <String>[
          'gold gemstone crown ornament',
          'dark green crystal hairpin'
        ],
        outfit: <String>[
          'avarice treasure outfit',
          'deep green-and-gold regal silhouette'
        ],
        upper: <String>[
          'black fitted bodice',
          'deep green sleeves',
          'gold chest jewels'
        ],
        lower: <String>[
          'deep green layered skirt panels',
          'black split drapery',
          'gold coin waist belt'
        ],
        legwear: <String>['black patterned legwear', 'gold thigh chains'],
        footwear: <String>['black ankle boots', 'gold jewel heel guards'],
        accessories: <String>['gold treasure chains', 'green gemstone brooch'],
        weapon: <String>[
          'avarice crystal tool',
          'black-and-gold staff',
          'green jewel core'
        ],
        magic: <String>['gold treasure particles', 'green crystal glow'],
        theme: <String>['avarice treasure sovereign', 'gemstone wealth motif'],
      ),
      _profile(
        _lithia,
        classEn: 'Rima Clavis',
        classZh: '裂隙行者',
        classTag: 'rima_clavis',
        palette: '黑色 × 深藍色 × 青綠色',
        hair: <String>['ash-blonde hair', 'side braid', 'dark teal ribbon tie'],
        eyes: <String>['teal eyes', 'violet eyes'],
        head: <String>['rift key hair ornament', 'black crystal hairpin'],
        outfit: <String>[
          'rift traveler outfit',
          'black-and-blue occult silhouette'
        ],
        upper: <String>[
          'black fitted traveler jacket',
          'deep blue sleeves',
          'teal chest crystal'
        ],
        lower: <String>[
          'black layered skirt panels',
          'blue split drapery',
          'rift key belt'
        ],
        legwear: <String>['black patterned legwear', 'teal calf guards'],
        footwear: <String>['black ankle boots', 'blue sole guards'],
        accessories: <String>['rift keys', 'teal crystal chains'],
        weapon: <String>[
          'rift key staff',
          'black-and-blue tool shaft',
          'teal crystal key head'
        ],
        magic: <String>['blue rift particles', 'teal dimensional glow'],
        theme: <String>['rift traveler', 'dimensional key motif'],
      ),
      _profile(
        _lithia,
        classEn: 'Achlys',
        classZh: '異界女神',
        classTag: 'achlys',
        palette: '黑色 × 紫色 × 青綠色 × 金色',
        hair: <String>[
          'ash-blonde hair',
          'very long flowing hair',
          'violet ribbon ties'
        ],
        eyes: <String>['teal eyes', 'violet eyes'],
        head: <String>['gold rift crown ornament', 'purple crystal hairpin'],
        outfit: <String>[
          'otherworld goddess outfit',
          'black-and-violet regal silhouette'
        ],
        upper: <String>[
          'black fitted occult bodice',
          'violet flowing sleeves',
          'gold chest crystal'
        ],
        lower: <String>[
          'black layered skirt panels',
          'purple split drapery',
          'gold rift waist belt'
        ],
        legwear: <String>['black patterned legwear', 'violet thigh chains'],
        footwear: <String>['black ankle boots', 'gold crystal soles'],
        accessories: <String>[
          'otherworld key ornaments',
          'violet gemstone chains'
        ],
        weapon: <String>[
          'otherworld key staff',
          'black-and-gold staff frame',
          'violet crystal core'
        ],
        magic: <String>['violet rift aura', 'teal dimensional particles'],
        theme: <String>['otherworld goddess', 'rift sovereign motif'],
      ),
      _profile(
        _lithia,
        classEn: 'Cynical Sneer',
        classZh: '諷世愚者',
        classTag: 'cynical_sneer',
        palette: '黑色 × 灰色 × 金色 × 青綠色',
        hair: <String>[
          'ash-blonde hair',
          'messy layered hair',
          'dark ribbon ties'
        ],
        eyes: <String>['teal eyes', 'gold eyes'],
        head: <String>['gold monocle ornament', 'black crystal hairpin'],
        outfit: <String>[
          'cynical trickster outfit',
          'black-and-gray layered silhouette'
        ],
        upper: <String>[
          'black fitted jacket',
          'gray patterned sleeves',
          'gold chest clasps'
        ],
        lower: <String>[
          'black layered skirt panels',
          'gray split drapery',
          'gold trickster belt'
        ],
        legwear: <String>['black patterned legwear', 'gray thigh straps'],
        footwear: <String>['black ankle boots', 'gold sole guards'],
        accessories: <String>['trickster key chains', 'gold gemstone brooch'],
        weapon: <String>[
          'cynical crystal tool',
          'black-and-gold staff',
          'teal jewel core'
        ],
        magic: <String>['gray illusion mist', 'teal crystal sparks'],
        theme: <String>['cynical trickster', 'gemstone deception motif'],
      ),
      _profile(
        _lithia,
        classEn: 'Mischief',
        classZh: '惡戲奇術師',
        classTag: 'mischief',
        palette: '黑色 × 金色 × 深綠色 × 青綠色',
        hair: <String>[
          'ash-blonde hair',
          'messy layered hair',
          'side braid',
          'dark green ribbon ties'
        ],
        eyes: <String>['teal eyes', 'gold eyes'],
        head: <String>[
          'gold trickster goggles',
          'black-and-green hair ornament'
        ],
        outfit: <String>[
          'mischief illusionist outfit',
          'black-and-gold layered silhouette'
        ],
        upper: <String>[
          'black fitted trickster jacket',
          'dark green sleeves',
          'gold chest buckles'
        ],
        lower: <String>[
          'black layered skirt panels',
          'deep green split drapery',
          'gold waist belt'
        ],
        legwear: <String>['black patterned legwear', 'gold thigh chains'],
        footwear: <String>['black ankle boots', 'gold crystal soles'],
        accessories: <String>['trickster key ornaments', 'gold crystal chains'],
        weapon: <String>[
          'mischief crystal tool',
          'black-and-gold staff frame',
          'teal crystal core'
        ],
        magic: <String>['teal illusion sparks', 'gold trickster particles'],
        theme: <String>['mischief illusionist', 'gemstone trickster motif'],
      ),
    ])
      profile.key: profile,
  },
);
