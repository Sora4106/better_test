import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_version.dart';
import 'catalog_data.dart';
import 'clothing_taxonomy.dart';
import 'expanded_tag_data.dart';
import 'outfit_reference_catalog.dart';
import 'object_catalog_data.dart';
import 'prompt_package_data.dart';

const _storageKey = 'betterwaifu_prompt_builder_state_v1';
const _lastSeenVersionKey = 'betterwaifu_prompt_builder_last_seen_version';
const _stepLayoutVersion = 3;
const _wingTypeGroup = '翅膀類型';
const _wingColorGroup = '翅膀顏色';
const _animalEarColorGroup = '獸耳顏色';
const _animalTailColorGroup = '獸尾顏色';
const _animalHandColorGroup = '獸手顏色';
const _animalFootColorGroup = '獸足顏色';
const _physicalTraitColorGroups = <String>{
  _animalEarColorGroup,
  _animalTailColorGroup,
  _animalHandColorGroup,
  _animalFootColorGroup,
  _wingColorGroup,
};
// Dynamic head details are selected with poses, not with permanent character
// appearance.  Keep the actual stored tag groups unchanged for compatibility.
const _staticFaceAppearanceGroup = '固定外觀・臉部結構';
const _animalTraitGroup = '獸化特徵';
const _expressionEyesGroup = '頭部動態・眼睛／視線';
const _expressionMouthGroup = '頭部動態・嘴巴／口型';
const _expressionTeasingGroup = '頭部動態・挑逗';
const _expressionSymbolGroup = '頭部動態・符號表情';
const _expressionOtherGroup = '頭部動態・情緒／其他';
const _objectInteractionGroup = '互動・物件動作';
const _indoorSceneGroup = '室內場景';
const _outdoorSceneGroup = '戶外場景';
const _outdoorTimeGroup = '戶外時段';
const _cameraFramingGroup = '鏡頭・取景範圍';
const _cameraFaceFocusGroup = '鏡頭・臉部（眼睛／嘴巴／表情）';
const _cameraFocusGroup = '鏡頭・身體聚焦（頭到腳）';
const _cameraCropGroup = '鏡頭・裁切構圖';
const _objectFurnitureGroup = '物件・家具／室內';
const _objectDiningGroup = '物件・飲食／餐具';
const _objectStudyGroup = '物件・學習／藝術／音樂';
const _objectTechGroup = '物件・科技／媒體';
const _objectSportGroup = '物件・運動／戶外';
const _objectToolGroup = '物件・工具／科學／遊戲';
const _objectFantasyGroup = '物件・武器／奇幻';
const _objectTravelGroup = '物件・交通／旅行';
const _objectDailyGroup = '物件・日常／裝飾';
const _objectPickerGroups = <String>{
  _objectFurnitureGroup,
  _objectDiningGroup,
  _objectStudyGroup,
  _objectTechGroup,
  _objectSportGroup,
  _objectToolGroup,
  _objectFantasyGroup,
  _objectTravelGroup,
  _objectDailyGroup,
};
const _buttonSurface = Color(0xff34344d);
const _buttonBorder = Color(0xff77779b);
const _buttonSelectedSurface = Color(0xffc4b5fd);
const _buttonSelectedText = Color(0xff171326);
const _defaultNegativeText =
    'lowres, worst quality, bad quality, bad anatomy, bad hands, extra digits, '
    'multiple views, fewer digits, extra limbs, missing fingers, deformed, text, '
    'error, jpeg artifacts, watermark, unfinished, displeasing, signature, username, scan artifacts';

const _indoorSceneIds = <String>{
  'scene_indoor_pool',
  'scene_sports_hall',
  'scene_gym',
  'scene_training_room',
  'scene_martial_arts_dojo',
  'scene_dance_studio',
  'scene_ice_rink',
  'scene_bowling_alley',
  'scene_archery_range',
  'scene_boxing_ring',
  'scene_wrestling_arena',
  'scene_locker_room',
  'scene_shopping_mall',
  'scene_cafe',
  'scene_restaurant',
  'scene_library',
  'scene_train_interior',
  'scene_office',
  'scene_hospital',
  'scene_aquarium',
  'scene_museum',
  'scene_theater',
  'scene_concert_stage',
  'scene_school_hallway',
  'scene_convenience_store',
  'scene_living_room',
  'scene_kitchen',
  'scene_dining_room',
  'scene_hallway',
  'scene_apartment',
  'scene_studio_apartment',
  'scene_hotel_room',
  'scene_hotel_lobby',
  'scene_dormitory_room',
  'scene_laundry_room',
  'scene_walk_in_closet',
  'scene_art_studio',
  'scene_photography_studio',
  'scene_recording_studio',
  'scene_backstage',
  'scene_dressing_room',
  'scene_ballroom',
  'scene_banquet_hall',
  'scene_workshop',
  'scene_laboratory',
  'scene_computer_room',
  'scene_auditorium',
  'scene_subway_station',
  'scene_subway_interior',
  'scene_airport',
  'scene_airplane_cabin',
  'scene_bookstore',
  'scene_flower_shop',
  'scene_shopping_arcade',
  'scene_greenhouse',
  'scene_tatami_room',
  'scene_traditional_japanese_house',
  'scene_ryokan',
  'scene_arcade',
  'scene_karaoke_room',
  'scene_billiards_hall',
  'scene_movie_theater',
  'scene_planetarium',
  'scene_tea_house',
  'scene_bakery',
  'scene_wedding_venue',
  'scene_fencing_hall',
  'scene_climbing_gym',
  'scene_shooting_range',
  'scene_table_tennis_room',
  'scene_kendo_dojo',
  'scene_weight_room',
  'scene_yoga_studio',
  'scene_ballet_studio',
  'scene_kyudo_dojo',
  'scene_traditional_kyudo_dojo',
  'scene_wooden_floor',
};

bool _isScenePickerGroup(String group) =>
    group == _indoorSceneGroup || group == _outdoorSceneGroup;

bool _isCameraGroup(String group) => const {
      _cameraFramingGroup,
      _cameraFaceFocusGroup,
      _cameraFocusGroup,
      _cameraCropGroup,
      '畫面',
    }.contains(group);

/// Only these tags belong to the first wizard step. Shared interactions,
/// quality, and miscellaneous prompt terms can still be stored globally, but
/// must not be displayed as if they were a scene or camera selection.
bool _isSceneVisualPromptGroup(String group) =>
    _isScenePickerGroup(group) ||
    group == _outdoorTimeGroup ||
    _isCameraGroup(group);

/// Shared actions describe what multiple characters do together. They are
/// selected globally and are intentionally rendered after every character's
/// own pose/action block, without parentheses or a character weight.
bool _isSharedActionGroup(String group) =>
    const {
      '\u89aa\u543b\u52d5\u4f5c',
      '\u591a\u4eba\u4e92\u52d5',
      '\u8c93\u7cfb\u30fb\u4eba\u7269\u4e92\u52d5',
      '\u89d2\u8272\u59ff\u52e2',
      '\u6027\u884c\u70ba',
      '\u6027\u59ff\u52e2',
    }.contains(group) ||
    expandedSexualPoseGroups.contains(group) ||
    expandedSexualActGroups.contains(group);

bool _isGlobalPromptGroup(String group) =>
    _isSceneVisualPromptGroup(group) ||
    _isSharedActionGroup(group) ||
    const {'品質', '其他'}.contains(group);

String _catalogPickerGroup(CatalogTagData data) {
  if (data.group == _animalTraitGroup &&
      RegExp(r'\bwings?\b', caseSensitive: false).hasMatch(data.en)) {
    return _wingTypeGroup;
  }
  if (data.group != '場景') return data.group;
  return _indoorSceneIds.contains(data.id)
      ? _indoorSceneGroup
      : _outdoorSceneGroup;
}

const _negativeCatalog = <Map<String, String>>[
  {'en': 'lowres', 'zh': '低解析度'},
  {'en': 'blurry', 'zh': '模糊'},
  {'en': 'worst quality', 'zh': '最差品質'},
  {'en': 'bad quality', 'zh': '低品質'},
  {'en': 'bad anatomy', 'zh': '錯誤的人體結構'},
  {'en': 'bad hands', 'zh': '錯誤的手部'},
  {'en': 'bad feet', 'zh': '錯誤的腳部'},
  {'en': 'extra digits', 'zh': '多餘手指'},
  {'en': 'fewer digits', 'zh': '手指數量不足'},
  {'en': 'extra limbs', 'zh': '多餘肢體'},
  {'en': 'missing fingers', 'zh': '缺少手指'},
  {'en': 'multiple views', 'zh': '多重視角'},
  {'en': 'deformed', 'zh': '變形'},
  {'en': 'poorly drawn face', 'zh': '臉部繪製不佳'},
  {'en': 'duplicate', 'zh': '重複內容'},
  {'en': 'text', 'zh': '文字'},
  {'en': 'error', 'zh': '錯誤'},
  {'en': 'jpeg artifacts', 'zh': 'JPEG 壓縮瑕疵'},
  {'en': 'watermark', 'zh': '浮水印'},
  {'en': 'logo', 'zh': '標誌'},
  {'en': 'signature', 'zh': '簽名'},
  {'en': 'username', 'zh': '使用者名稱'},
  {'en': 'unfinished', 'zh': '未完成'},
  {'en': 'displeasing', 'zh': '令人不悅'},
  {'en': 'scan artifacts', 'zh': '掃描瑕疵'},
  {'en': 'sketch', 'zh': '草稿'},
  {'en': 'monochrome', 'zh': '單色'},
  {'en': 'greyscale', 'zh': '灰階'},
  {'en': 'artist name', 'zh': '藝術家名稱'},
];

extension _StringFallback on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

class TagItem {
  const TagItem({
    required this.id,
    required this.group,
    required this.zh,
    required this.en,
    required this.order,
    this.adult = false,
    this.builtIn = true,
    this.conflictGroup,
    this.support = 'standard',
  });

  final String id;
  final String group;
  final String zh;
  final String en;
  final int order;
  final bool adult;
  final bool builtIn;
  final String? conflictGroup;
  final String support;

  Map<String, dynamic> toJson() => {
        'id': id,
        'group': group,
        'zh': zh,
        'en': en,
        'order': order,
        'adult': adult,
        'builtIn': builtIn,
        'conflictGroup': conflictGroup,
        'support': support,
      };

  factory TagItem.fromJson(Map<String, dynamic> json) => TagItem(
        id: '${json['id']}',
        group: '${json['group'] ?? '自訂'}',
        zh: '${json['zh'] ?? ''}',
        en: '${json['en'] ?? ''}',
        order: (json['order'] as num?)?.toInt() ?? 1,
        adult: json['adult'] == true,
        builtIn: false,
        conflictGroup: json['conflictGroup'] as String?,
        support: '${json['support'] ?? 'standard'}',
      );
}

class _HairGradientStyle {
  const _HairGradientStyle({
    required this.id,
    required this.zh,
    required this.hint,
  });

  final String id;
  final String zh;
  final String hint;
}

const _defaultHairGradientStyle = 'linear';

/// Two selected hair colours are emitted as one composed phrase.  These
/// choices describe where colour 2 appears relative to colour 1, rather than
/// adding unconnected colour tags that the model might apply elsewhere.
const _hairGradientStyles = <_HairGradientStyle>[
  _HairGradientStyle(
    id: 'linear',
    zh: '全髮線性漸層',
    hint: '色 1 從髮根平滑過渡至色 2',
  ),
  _HairGradientStyle(
    id: 'tips',
    zh: '髮尾漸層',
    hint: '色 1 為主髮色，色 2 出現在髮尾',
  ),
  _HairGradientStyle(
    id: 'roots',
    zh: '髮根漸層',
    hint: '色 1 為主髮色，色 2 出現在髮根',
  ),
  _HairGradientStyle(
    id: 'inner',
    zh: '內層挑染',
    hint: '色 1 為外層，色 2 出現在內層髮束',
  ),
  _HairGradientStyle(
    id: 'split',
    zh: '左右分色',
    hint: '左右兩側分別使用色 1 與色 2',
  ),
  _HairGradientStyle(
    id: 'underlayer',
    zh: '底層雙色',
    hint: '色 1 為表層，色 2 為下層髮色',
  ),
];

/// Exact, active names listed by Danbooru's official Hair Styles tag group or
/// confirmed through its tag API. Other hairstyle entries remain available as
/// natural-language hints because Amanatsu may still understand some of them,
/// but the UI labels them separately instead of implying official support.
const _officialHairStyleEnglish = <String>{
  'hair between eyes',
  'bob cut',
  'pixie cut',
  'straight hair',
  'wavy hair',
  'curly hair',
  'messy hair',
  'spiked hair',
  'ponytail',
  'high ponytail',
  'low ponytail',
  'side ponytail',
  'low side ponytail',
  'high side ponytail',
  'folded ponytail',
  'twintails',
  'low twintails',
  'uneven twintails',
  'single braid',
  'twin braids',
  'low twin braids',
  'side braid',
  'front braid',
  'half crown braid',
  'braided ponytail',
  'braided twintails',
  'crown braid',
  'rope braid',
  'braided bun',
  'braided bangs',
  'multiple braids',
  'cornrows',
  'dreadlocks',
  'box braids',
  'half up braid',
  'half up half down braid',
  'hair bun',
  'single hair bun',
  'double bun',
  'very low bun',
  'heart hair bun',
  'hair rings',
  'half updo',
  'one side up',
  'two side up',
  'hime cut',
  'wolf cut',
  'jellyfish cut',
  'bowl cut',
  'inverted bob',
  'mullet',
  'butterfly cut',
  'feathered hair',
  'fluffy hair',
  'flipped hair',
  'drill hair',
  'twin drills',
  'ringlets',
  'afro',
  'beehive hairdo',
  'pompadour',
  'quiff',
  'victory rolls',
  'wet hair',
  'arched bangs',
  'asymmetrical bangs',
  'blunt bangs',
  'choppy bangs',
  'diagonal bangs',
  'fanged bangs',
  'long bangs',
  'wispy bangs',
  'parted bangs',
  'middle part',
  'curtained hair',
  'swept bangs',
  'hair over one eye',
  'hair over eyes',
  'sidelocks',
  'long sidelocks',
  'asymmetrical sidelocks',
  'drill sidelocks',
  'antenna hair',
  'heart ahoge',
  'huge ahoge',
  'hair pulled back',
  'hair slicked back',
  'alternate hairstyle',
  'hair down',
  'hair up',
  'asymmetrical hair',
  'sidecut',
  'blunt ends',
  'bow-shaped hair',
  'chignon',
};

bool _isOfficialHairStyleTag(TagItem tag) =>
    tag.group == '髮型' &&
    _officialHairStyleEnglish.contains(tag.en.trim().toLowerCase());

class _GeneratedOutputTag {
  const _GeneratedOutputTag({
    required this.zh,
    required this.en,
    this.tagId,
    this.tagIds = const <String>[],
    this.personIndex,
    this.characterTag = false,
    this.combinationId,
    this.personPoseExtraValue,
    this.sharedPoseExtraValue,
    this.clothingBlockKey,
  });

  final String zh;
  final String en;
  final String? tagId;
  final List<String> tagIds;
  final int? personIndex;
  final bool characterTag;
  final String? combinationId;
  final String? personPoseExtraValue;
  final String? sharedPoseExtraValue;

  /// Identifies the garment block that owns this generated clothing phrase.
  /// This is used only when rendering the English prompt, so its individual
  /// type/material/detail/colour/wear-state phrases can remain together.
  final String? clothingBlockKey;
}

class Preset {
  Preset({required this.name, required this.payload});

  final String name;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {'name': name, 'payload': payload};

  factory Preset.fromJson(Map<String, dynamic> json) => Preset(
        name: '${json['name'] ?? '未命名組合'}',
        payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
      );
}

class PromptCombination {
  PromptCombination({
    required this.id,
    required this.name,
    required this.tagIds,
    required this.extraPositive,
  });

  final String id;
  final String name;
  final List<String> tagIds;
  final String extraPositive;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tagIds': tagIds,
        'extraPositive': extraPositive,
      };

  factory PromptCombination.fromJson(Map<String, dynamic> json) =>
      PromptCombination(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        tagIds: (json['tagIds'] as List? ?? []).map((id) => '$id').toList(),
        extraPositive: '${json['extraPositive'] ?? ''}',
      );
}

class _OutfitReferenceResolution {
  const _OutfitReferenceResolution({
    required this.tags,
    required this.missing,
  });

  final List<TagItem> tags;
  final List<String> missing;
}

class _AdultPosePackage {
  const _AdultPosePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.femaleCount,
    required this.maleCount,
    required this.personTags,
    required this.frameTags,
    this.category = '基礎套件',
  });

  final String id;
  final String name;
  final String description;
  final int femaleCount;
  final int maleCount;
  final List<String> personTags;
  final List<String> frameTags;
  final String category;

  /// A withdrawal/end state is only meaningful for penetrative adult poses.
  /// It retains the pose and framing, removes the in-progress act labels, and
  /// derives a direction from the original position instead of turning every
  /// package into the same generic ending action.
  bool get supportsEndPose =>
      maleCount > 0 &&
      personTags.any(
        (tag) => const {'vaginal', 'triple vaginal', 'anal'}.contains(tag),
      );

  String get endMovementTag {
    final tags = personTags.toSet();
    // The person on top separates vertically, so preserve that vertical read.
    if (tags.contains('girl on top') ||
        tags.contains('cowgirl position') ||
        tags.contains('reverse cowgirl') ||
        tags.contains('reverse cowgirl position') ||
        tags.contains('squatting cowgirl position') ||
        tags.contains('reverse squatting cowgirl position') ||
        tags.contains('upright straddle') ||
        tags.contains('reverse upright straddle') ||
        tags.contains('amazon position') ||
        tags.contains('mounting')) {
      return 'pulling out upwards';
    }
    // Side-by-side positions read most clearly as a lateral separation.
    if (tags.contains('on side') ||
        tags.contains('lying on side') ||
        tags.contains('spooning')) {
      return 'pulling out sideways';
    }
    // Rear-entry positions keep the rear orientation while separating.
    if (tags.contains('doggystyle') ||
        tags.contains('sex from behind') ||
        tags.contains('bent over') ||
        tags.contains('top-down bottom-up') ||
        tags.contains('prone bone')) {
      return 'pulling out backwards';
    }
    // Face-to-face, standing, and the remaining positions retain their
    // original pose and separate backwards from that configuration.
    return 'pulling out backwards';
  }

  String get endMovementZh => switch (endMovementTag) {
        'pulling out upwards' => '向上抽離',
        'pulling out sideways' => '向側邊抽離',
        'pulling out backwards' => '向後抽離',
        _ => '抽離動作',
      };

  List<String> personTagsFor({required bool endPose}) {
    if (!endPose || !supportsEndPose) return personTags;
    const inProgressActs = <String>{
      'sex',
      'vaginal',
      'triple vaginal',
      'anal',
    };
    return [
      ...personTags.where((tag) => !inProgressActs.contains(tag)),
      'pulling out',
      if (endMovementTag != 'pulling out') endMovementTag,
    ];
  }

  Iterable<String> get allPersonTags => [
        ...personTags,
        if (supportsEndPose) ...personTagsFor(endPose: true),
      ];
}

_AdultPosePackage _adultPosePack(
  String id,
  String name,
  String description,
  String category,
  List<String> personTags,
  List<String> frameTags, {
  int femaleCount = 1,
  int maleCount = 1,
}) =>
    _AdultPosePackage(
      id: id,
      name: name,
      description: description,
      category: category,
      femaleCount: femaleCount,
      maleCount: maleCount,
      personTags: personTags,
      frameTags: frameTags,
    );

final _adultPosePackages = <_AdultPosePackage>[
  _AdultPosePackage(
    id: 'solo_fingering_seated_front',
    name: '坐姿手指自慰・正面',
    description: '坐姿、分腿，正面膝上構圖',
    femaleCount: 1,
    maleCount: 0,
    personTags: [
      'female masturbation',
      'vaginal fingering',
      'sitting',
      'legs apart'
    ],
    frameTags: ['front view', 'cowboy shot'],
  ),
  _AdultPosePackage(
    id: 'solo_fingering_lying_above',
    name: '仰躺手指自慰・俯視',
    description: '仰躺、抬腿，由上方拍攝全身',
    femaleCount: 1,
    maleCount: 0,
    personTags: [
      'female masturbation',
      'vaginal fingering',
      'lying on back',
      'legs up',
    ],
    frameTags: ['from above', 'full body'],
  ),
  _AdultPosePackage(
    id: 'solo_clothed_rubbing_side',
    name: '隔衣摩擦自慰・側面',
    description: '隔著衣物摩擦，坐姿側面全身',
    femaleCount: 1,
    maleCount: 0,
    personTags: [
      'female masturbation',
      'masturbation through clothes',
      'crotch rub',
      'sitting',
    ],
    frameTags: ['side view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'solo_pillow_humping_above',
    name: '枕頭磨蹭・俯視',
    description: '跪姿前傾，從上方呈現動作',
    femaleCount: 1,
    maleCount: 0,
    personTags: [
      'female masturbation',
      'pillow humping',
      'kneeling',
      'leaning forward',
    ],
    frameTags: ['from above', 'full body'],
  ),
  _AdultPosePackage(
    id: 'solo_table_humping_side',
    name: '桌緣磨蹭・側面',
    description: '身體前傾靠近桌緣，側面構圖',
    femaleCount: 1,
    maleCount: 0,
    personTags: [
      'female masturbation',
      'table humping',
      'standing',
      'leaning forward',
    ],
    frameTags: ['side view', 'cowboy shot'],
  ),
  _AdultPosePackage(
    id: 'solo_vibrator_lying_low',
    name: '按摩器仰躺・低角度',
    description: '仰躺使用手持按摩器，低角度全身',
    femaleCount: 1,
    maleCount: 0,
    personTags: [
      'female masturbation',
      'sex toy use',
      'handheld vibrator',
      'lying on back',
    ],
    frameTags: ['low-angle view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'solo_dildo_riding_front',
    name: '假陽具騎乘・正面',
    description: '直立跨坐騎乘，正面全身構圖',
    femaleCount: 1,
    maleCount: 0,
    personTags: [
      'female masturbation',
      'dildo riding',
      'upright straddle',
    ],
    frameTags: ['front view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'couple_missionary_side',
    name: '傳教士體位・側面',
    description: '男方在上、女方仰躺，側面全身',
    femaleCount: 1,
    maleCount: 1,
    personTags: ['sex', 'vaginal', 'missionary', 'boy on top', 'lying on back'],
    frameTags: ['side view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'couple_mating_press_above',
    name: '交合壓腿式・俯視',
    description: '膝蓋貼胸、雙腿抬起，由上方拍攝',
    femaleCount: 1,
    maleCount: 1,
    personTags: [
      'sex',
      'vaginal',
      'mating press',
      'knees to chest',
      'legs up',
    ],
    frameTags: ['from above', 'full body'],
  ),
  _AdultPosePackage(
    id: 'couple_cowgirl_low',
    name: '女上位・低角度',
    description: '女方跨坐在上，低角度全身',
    femaleCount: 1,
    maleCount: 1,
    personTags: [
      'sex',
      'vaginal',
      'cowgirl position',
      'girl on top',
      'straddling'
    ],
    frameTags: ['low-angle view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'couple_reverse_cowgirl_rear',
    name: '背向女上位・背面',
    description: '女方背向跨坐，背面全身構圖',
    femaleCount: 1,
    maleCount: 1,
    personTags: [
      'sex',
      'vaginal',
      'reverse cowgirl',
      'reverse upright straddle',
    ],
    frameTags: ['rear view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'couple_doggy_rear',
    name: '後入式・背面',
    description: '四足姿勢後入，背面全身構圖',
    femaleCount: 1,
    maleCount: 1,
    personTags: [
      'sex',
      'vaginal',
      'doggystyle',
      'sex from behind',
      'all fours'
    ],
    frameTags: ['rear view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'couple_anal_doggy_rear',
    name: '肛交後入式・背面',
    description: '四足姿勢肛交，背面全身構圖',
    femaleCount: 1,
    maleCount: 1,
    personTags: ['sex', 'anal', 'doggystyle', 'sex from behind', 'all fours'],
    frameTags: ['rear view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'couple_prone_bone_side',
    name: '俯臥後入・側面',
    description: '女方俯臥的後入姿勢，側面全身',
    femaleCount: 1,
    maleCount: 1,
    personTags: ['sex', 'vaginal', 'prone bone', 'lying on stomach'],
    frameTags: ['side view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'couple_prone_bone_back_hug',
    name: '同向俯臥後抱位・側面',
    description: '兩人身體同向平貼，男方從後方環抱並進行後入，側面全身構圖',
    femaleCount: 1,
    maleCount: 1,
    personTags: [
      'sex',
      'vaginal',
      'prone bone',
      'lying on stomach',
      'hug from behind',
    ],
    frameTags: ['side view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'couple_supine_rear_hug',
    name: '同向仰躺後抱位・側面',
    description: '兩人身體同向仰躺，男方在後方環抱並由後方進行，側面全身構圖',
    femaleCount: 1,
    maleCount: 1,
    personTags: [
      'sex',
      'vaginal',
      'sex from behind',
      'lying on back',
      'hug from behind',
    ],
    frameTags: ['side view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'couple_spooning_side',
    name: '側臥相擁式・側面',
    description: '兩人側臥相擁，側面全身構圖',
    femaleCount: 1,
    maleCount: 1,
    personTags: ['sex', 'vaginal', 'spooning', 'on side', 'lying on side'],
    frameTags: ['side view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'couple_standing_side',
    name: '站立性交・側面',
    description: '雙方站立，側面全身構圖',
    femaleCount: 1,
    maleCount: 1,
    personTags: ['sex', 'vaginal', 'standing sex', 'standing'],
    frameTags: ['side view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'couple_upright_straddle_front',
    name: '正面直立跨坐',
    description: '面對面直立跨坐，正面全身',
    femaleCount: 1,
    maleCount: 1,
    personTags: [
      'sex',
      'vaginal',
      'upright straddle',
      'face-to-face',
      'straddling',
    ],
    frameTags: ['front view', 'full body'],
  ),
  _AdultPosePackage(
    id: 'couple_sixty_nine_side',
    name: '六九式・側面',
    description: '雙人口部互動，側面全身構圖',
    femaleCount: 1,
    maleCount: 1,
    personTags: ['oral', '69', 'lying'],
    frameTags: ['side view', 'full body'],
  ),
  ..._femaleFemaleAdultPosePackages,
  ..._additionalAdultPosePackages,
  ..._groupAdultPosePackages,
  ..._shijuhatteAdultPosePackages,
];

/// Adult female/female presets shown only when the current cast is exactly two
/// women.  All prompt terms are already present in the local bilingual tag
/// catalog, so applying a preset can select real tags instead of adding free
/// text that cannot be reverse-matched later.
final _femaleFemaleAdultPosePackages = <_AdultPosePackage>[
  _adultPosePack(
    'ff_tribadism_face_to_face_front',
    '女女剪式摩擦・正面',
    '兩位成年女性面對面、雙腿交纏進行剪式摩擦',
    '女女・摩擦',
    ['tribadism', 'scissoring', 'face-to-face', 'lying', 'leg lock'],
    ['front view', 'full body'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_tribadism_side',
    '女女側臥摩擦・側面',
    '兩位成年女性側臥、腿部交纏摩擦，以側面呈現',
    '女女・摩擦',
    ['tribadism', 'scissoring', 'on side', 'lying on side', 'leg lock'],
    ['side view', 'full body'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_tribadism_seated_front',
    '女女坐姿摩擦・正面',
    '兩位成年女性面對面坐著，張腿並以剪式姿勢摩擦',
    '女女・摩擦',
    ['tribadism', 'scissoring', 'sitting', 'face-to-face', 'legs apart'],
    ['front view', 'full body'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_cunnilingus_lying_front',
    '女女仰躺舔陰・正面',
    '一位成年女性仰躺張腿，另一位從正面進行口部互動',
    '女女・口部',
    ['oral', 'cunnilingus', 'lying on back', 'legs apart'],
    ['front view', 'full body'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_facesitting_low',
    '女女顏面騎乘・低角度',
    '一位成年女性跨坐在上，另一位進行口部互動',
    '女女・口部',
    ['oral', 'cunnilingus', 'facesitting', 'girl on top', 'straddling'],
    ['low-angle view', 'full body'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_sixty_nine_side',
    '女女六九式・側面',
    '兩位成年女性反向躺臥，同時進行口部互動',
    '女女・口部',
    ['oral', '69', 'cunnilingus', 'lying', 'on side'],
    ['side view', 'full body'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_mutual_fingering_seated',
    '女女相互指交・坐姿',
    '兩位成年女性面對面坐著，同時進行手指刺激',
    '女女・相互刺激',
    [
      'mutual masturbation',
      'fingering',
      'vaginal fingering',
      'sitting',
      'face-to-face',
    ],
    ['front view', 'cowboy shot'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_mutual_masturbation_above',
    '女女相互自慰・俯視',
    '兩位成年女性並排仰躺，同時進行相互自慰',
    '女女・相互刺激',
    [
      'mutual masturbation',
      'female masturbation',
      'lying on back',
      'legs apart'
    ],
    ['from above', 'full body'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_strapon_missionary_side',
    '女女穿戴式傳教士體位・側面',
    '一位成年女性使用穿戴式道具，另一位仰躺的面對面體位',
    '女女・穿戴式道具',
    [
      'sex',
      'vaginal',
      'strap-on',
      'missionary',
      'lying on back',
      'face-to-face'
    ],
    ['side view', 'full body'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_strapon_doggy_rear',
    '女女穿戴式後入・背面',
    '一位成年女性使用穿戴式道具，對四肢著地的另一位後入',
    '女女・穿戴式道具',
    [
      'sex',
      'vaginal',
      'strap-on',
      'doggystyle',
      'sex from behind',
      'all fours'
    ],
    ['rear view', 'full body'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_strapon_cowgirl_low',
    '女女穿戴式女上位・低角度',
    '一位成年女性使用穿戴式道具，另一位面對面跨坐在上',
    '女女・穿戴式道具',
    [
      'sex',
      'vaginal',
      'strap-on',
      'cowgirl position',
      'girl on top',
      'straddling'
    ],
    ['low-angle view', 'full body'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_double_dildo_front',
    '女女雙頭道具・正面',
    '兩位成年女性面對面跨坐，使用雙頭假陰莖',
    '女女・玩具',
    [
      'sex toy use',
      'double dildo',
      'vaginal object insertion',
      'face-to-face',
      'straddling',
    ],
    ['front view', 'full body'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_breast_grinding_front',
    '女女胸部貼合摩擦・正面',
    '兩位成年女性面對面擁抱，胸部貼合摩擦',
    '女女・貼身互動',
    [
      'breast grinding',
      'grinding',
      'nipple-to-nipple',
      'face-to-face',
      'hugging'
    ],
    ['front view', 'cowboy shot'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_kissing_lap_straddle',
    '女女膝上跨坐接吻',
    '一位成年女性跨坐在另一位腿上，面對面擁抱接吻',
    '女女・貼身互動',
    ['french kiss', 'straddling', 'sitting on lap', 'face-to-face', 'hugging'],
    ['side view', 'cowboy shot'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_strapon_prone_bone_back_hug',
    '女女穿戴式・同向俯臥後抱位',
    '兩位成年女性同向平貼俯臥，後方以穿戴式道具環抱後入',
    '女女・穿戴式道具',
    [
      'sex',
      'vaginal',
      'strap-on',
      'prone bone',
      'lying on stomach',
      'hug from behind',
    ],
    ['side view', 'full body'],
    femaleCount: 2,
    maleCount: 0,
  ),
  _adultPosePack(
    'ff_strapon_supine_rear_hug',
    '女女穿戴式・同向仰躺後抱位',
    '兩位成年女性同向仰躺，後方以穿戴式道具環抱並由後方進行',
    '女女・穿戴式道具',
    [
      'sex',
      'vaginal',
      'strap-on',
      'sex from behind',
      'lying on back',
      'hug from behind',
    ],
    ['side view', 'full body'],
    femaleCount: 2,
    maleCount: 0,
  ),
];

final _additionalAdultPosePackages = <_AdultPosePackage>[
  _adultPosePack(
    'extra_missionary_pov',
    '傳教士體位・主觀正面',
    '男方在上、女方仰躺，以第一人稱膝上構圖呈現',
    '男上位',
    ['sex', 'vaginal', 'missionary', 'boy on top', 'lying on back'],
    ['pov', 'cowboy shot'],
  ),
  _adultPosePack(
    'extra_mating_press_side',
    '交合壓腿式・側面',
    '女方膝蓋貼胸、雙腿抬起，側面全身構圖',
    '男上位',
    ['sex', 'vaginal', 'mating press', 'knees to chest', 'legs up'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'extra_anvil_side',
    '鐵砧體位・側面',
    '女方仰躺並將雙腿抬高，側面呈現雙人姿勢',
    '男上位',
    ['sex', 'vaginal', 'anvil position', 'lying on back', 'legs up'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'extra_folded_missionary_above',
    '折疊傳教士體位・俯視',
    '仰躺折疊身體並收腿，由上方呈現',
    '男上位',
    ['sex', 'vaginal', 'missionary', 'folded', 'knees to chest'],
    ['from above', 'full body'],
  ),
  _adultPosePack(
    'extra_legs_over_head_missionary',
    '雙腿過頭傳教士體位・正面',
    '女方仰躺並將雙腿越過頭部，正面全身構圖',
    '男上位',
    ['sex', 'vaginal', 'missionary', 'legs over head', 'lying on back'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'extra_standing_missionary_front',
    '站立傳教士體位・正面',
    '面對面的站立傳教士姿勢，正面全身構圖',
    '男上位',
    ['sex', 'vaginal', 'standing missionary', 'face-to-face', 'standing'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'extra_piledriver_front',
    '打樁機體位・正面',
    '女方倒置並將腿部抬高，正面全身構圖',
    '男上位',
    ['sex', 'vaginal', 'piledriver', 'legs over head', 'upside-down'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'extra_full_nelson_rear',
    '全尼爾森式・背面',
    '由後方固定上身並抬腿，背面全身構圖',
    '男上位',
    ['sex', 'vaginal', 'full nelson', 'legs up'],
    ['rear view', 'full body'],
  ),
  _adultPosePack(
    'extra_cowgirl_front',
    '女上位・正面',
    '女方正面跨坐在上，正面全身構圖',
    '女上位',
    ['sex', 'vaginal', 'cowgirl position', 'girl on top', 'straddling'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'extra_squatting_cowgirl_front',
    '蹲式女上位・正面',
    '女方蹲姿跨坐在上，正面全身構圖',
    '女上位',
    [
      'sex',
      'vaginal',
      'squatting cowgirl position',
      'girl on top',
      'squatting'
    ],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'extra_amazon_front',
    '亞馬遜體位・正面',
    '女方控制在上方的亞馬遜體位，正面構圖',
    '女上位',
    ['sex', 'vaginal', 'amazon position', 'girl on top'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'extra_reverse_cowgirl_side',
    '反向女上位・側面',
    '女方背向跨坐，從側面呈現雙人輪廓',
    '女上位',
    ['sex', 'vaginal', 'reverse cowgirl position', 'girl on top', 'straddling'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'extra_reverse_squatting_cowgirl_rear',
    '反向蹲式女上位・背面',
    '女方背向蹲姿跨坐，背面全身構圖',
    '女上位',
    ['sex', 'vaginal', 'reverse squatting cowgirl position', 'squatting'],
    ['rear view', 'full body'],
  ),
  _adultPosePack(
    'extra_reverse_upright_straddle_side',
    '反向直立跨坐・側面',
    '背向直立跨坐，以側面全身呈現',
    '女上位',
    ['sex', 'vaginal', 'reverse upright straddle', 'straddling'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'extra_doggy_side',
    '後入式・側面',
    '四足姿勢後入，改用側面全身構圖',
    '後入／側臥',
    ['sex', 'vaginal', 'doggystyle', 'sex from behind', 'all fours'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'extra_bent_over_rear',
    '俯身後入・背面',
    '女方站立俯身、由後方進行，背面構圖',
    '後入／側臥',
    ['sex', 'vaginal', 'sex from behind', 'bent over', 'standing'],
    ['rear view', 'full body'],
  ),
  _adultPosePack(
    'extra_top_down_bottom_up_rear',
    '俯身抬臀後入・背面',
    '上身壓低並抬高臀部，背面全身構圖',
    '後入／側臥',
    ['sex', 'vaginal', 'sex from behind', 'top-down bottom-up'],
    ['rear view', 'full body'],
  ),
  _adultPosePack(
    'extra_prone_bone_above',
    '俯臥後入・俯視',
    '女方俯臥的後入姿勢，由上方呈現',
    '後入／側臥',
    ['sex', 'vaginal', 'prone bone', 'lying on stomach'],
    ['from above', 'full body'],
  ),
  _adultPosePack(
    'extra_spooning_above',
    '側臥相擁式・俯視',
    '兩人側臥相擁，由上方呈現身體位置',
    '後入／側臥',
    ['sex', 'vaginal', 'spooning', 'on side', 'lying on side'],
    ['from above', 'full body'],
  ),
  _adultPosePack(
    'extra_on_side_face_to_face',
    '面對面側臥式・正面',
    '兩人面對面側臥，正面全身構圖',
    '後入／側臥',
    ['sex', 'vaginal', 'on side', 'lying on side', 'face-to-face'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'extra_standing_sex_front',
    '站立性交・正面',
    '兩人面對面站立，正面全身構圖',
    '站立／懸空',
    ['sex', 'vaginal', 'standing sex', 'standing', 'face-to-face'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'extra_suspended_congress_side',
    '懸空交合・側面',
    '一方抱起另一方進行懸空交合，側面全身構圖',
    '站立／懸空',
    ['sex', 'vaginal', 'suspended congress', 'standing'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'extra_reverse_suspended_congress_rear',
    '反向懸空交合・背面',
    '背向抱持的懸空交合姿勢，背面全身構圖',
    '站立／懸空',
    ['sex', 'vaginal', 'reverse suspended congress', 'standing'],
    ['rear view', 'full body'],
  ),
  _adultPosePack(
    'extra_mounting_side',
    '交合騎乘・側面',
    '以騎乘方式交合，側面全身構圖',
    '女上位',
    ['sex', 'vaginal', 'mounting', 'straddling'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'extra_sixty_nine_above',
    '六九式・俯視',
    '雙人口部互動，由上方呈現完整身體位置',
    '口部／胸部／足部',
    ['oral', '69', 'lying'],
    ['from above', 'full body'],
  ),
  _adultPosePack(
    'extra_upright_sixty_nine_front',
    '直立六九式・正面',
    '直立抱持的六九式，正面全身構圖',
    '口部／胸部／足部',
    ['oral', 'upright 69', 'standing'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'extra_facesitting_front',
    '顏面騎乘・正面',
    '一方跨坐於另一方臉部，正面膝上構圖',
    '口部／胸部／足部',
    ['oral', 'facesitting', 'girl on top', 'straddling'],
    ['front view', 'cowboy shot'],
  ),
  _adultPosePack(
    'extra_cunnilingus_lying_front',
    '仰躺舔陰・正面',
    '女方仰躺分腿接受舔陰，正面全身構圖',
    '口部／胸部／足部',
    ['oral', 'cunnilingus', 'lying on back', 'legs apart'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'extra_fellatio_kneeling_side',
    '跪姿口交・側面',
    '女方跪姿進行口交，側面全身構圖',
    '口部／胸部／足部',
    ['oral', 'fellatio', 'kneeling'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'extra_irrumatio_kneeling_side',
    '主動深入式口交・側面',
    '跪姿的主動深入式口交，側面全身構圖',
    '口部／胸部／足部',
    ['oral', 'irrumatio', 'kneeling'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'extra_paizuri_front',
    '乳交・正面',
    '正面呈現胸部夾弄動作與雙方位置',
    '口部／胸部／足部',
    ['paizuri', 'kneeling'],
    ['front view', 'cowboy shot'],
  ),
  _adultPosePack(
    'extra_perpendicular_paizuri_side',
    '垂直乳交・側面',
    '垂直方向的乳交姿勢，側面膝上構圖',
    '口部／胸部／足部',
    ['paizuri', 'perpendicular paizuri', 'kneeling'],
    ['side view', 'cowboy shot'],
  ),
  _adultPosePack(
    'extra_straddling_paizuri_front',
    '跨坐乳交・正面',
    '女方跨坐進行乳交，正面全身構圖',
    '口部／胸部／足部',
    ['paizuri', 'straddling paizuri', 'straddling'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'extra_paizuri_on_lap_side',
    '膝上乳交・側面',
    '在對方腿上進行乳交，側面全身構圖',
    '口部／胸部／足部',
    ['paizuri', 'paizuri on lap', 'sitting on lap'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'extra_footjob_front',
    '足交・正面',
    '坐姿以足部互動，正面全身構圖',
    '口部／胸部／足部',
    ['footjob', 'sitting', 'legs up'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'extra_reverse_footjob_side',
    '反向足交・側面',
    '反向身體配置的足交，側面全身構圖',
    '口部／胸部／足部',
    ['footjob', 'reverse footjob', 'lying'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'extra_footjob_from_behind_rear',
    '背後足交・背面',
    '從對方背後進行足部互動，背面全身構圖',
    '口部／胸部／足部',
    ['footjob', 'footjob from behind', 'sitting'],
    ['rear view', 'full body'],
  ),
  _adultPosePack(
    'extra_handjob_seated_front',
    '坐姿手交・正面',
    '兩人坐姿進行手部互動，正面膝上構圖',
    '口部／胸部／足部',
    ['handjob', 'sitting', 'face-to-face'],
    ['front view', 'cowboy shot'],
  ),
  _adultPosePack(
    'extra_reach_around_rear',
    '背後手交・背面',
    '由背後伸手進行手交，背面膝上構圖',
    '口部／胸部／足部',
    ['handjob', 'reach-around', 'standing'],
    ['rear view', 'cowboy shot'],
  ),
  _adultPosePack(
    'extra_cooperative_fellatio_side',
    '協力口交・側面',
    '雙方配合的口交姿勢，側面全身構圖',
    '口部／胸部／足部',
    ['oral', 'fellatio', 'cooperative fellatio', 'kneeling'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'extra_spitroast_side',
    '前後同時口交・側面',
    '三人前後配置，同時包含口部與後方互動',
    '多人・2男1女',
    ['group sex', 'threesome', 'spitroast', 'oral', 'vaginal', 'kneeling'],
    ['side view', 'full body'],
    femaleCount: 1,
    maleCount: 2,
  ),
  _adultPosePack(
    'extra_reverse_spitroast_side',
    '反向前後同時口交・側面',
    '反向三人前後配置，側面完整呈現',
    '多人・2男1女',
    ['group sex', 'threesome', 'reverse spitroast', 'oral', 'vaginal'],
    ['side view', 'full body'],
    femaleCount: 1,
    maleCount: 2,
  ),
  _adultPosePack(
    'extra_double_penetration_rear',
    '雙重插入・背面',
    '三人雙重插入配置，以背面全身構圖呈現',
    '多人・2男1女',
    ['group sex', 'threesome', 'double penetration', 'vaginal', 'anal'],
    ['rear view', 'full body'],
    femaleCount: 1,
    maleCount: 2,
  ),
  _adultPosePack(
    'extra_double_vaginal_front',
    '雙重陰道插入・正面',
    '三人雙重陰道插入配置，正面全身構圖',
    '多人・2男1女',
    ['group sex', 'threesome', 'double vaginal', 'lying on back', 'legs apart'],
    ['front view', 'full body'],
    femaleCount: 1,
    maleCount: 2,
  ),
  _adultPosePack(
    'extra_double_anal_rear',
    '雙重肛門插入・背面',
    '三人雙重肛門插入配置，背面全身構圖',
    '多人・2男1女',
    ['group sex', 'threesome', 'double anal', 'all fours'],
    ['rear view', 'full body'],
    femaleCount: 1,
    maleCount: 2,
  ),
  _adultPosePack(
    'extra_oral_sandwich_side',
    '口交夾擊・側面',
    '兩位女性與一位男性的口部夾擊配置',
    '多人・1男2女',
    ['group sex', 'threesome', 'oral sandwich', 'oral', 'lying'],
    ['side view', 'full body'],
    femaleCount: 2,
    maleCount: 1,
  ),
  _adultPosePack(
    'extra_cooperative_fellatio_group_front',
    '雙人協力口交・正面',
    '兩位女性跪姿協力進行口交，正面構圖',
    '多人・1男2女',
    ['group sex', 'threesome', 'cooperative fellatio', 'fellatio', 'kneeling'],
    ['front view', 'full body'],
    femaleCount: 2,
    maleCount: 1,
  ),
  _adultPosePack(
    'extra_double_handjob_group_front',
    '雙人手交・正面',
    '兩位女性共同進行手部互動，正面膝上構圖',
    '多人・1男2女',
    ['group sex', 'threesome', 'double handjob', 'sitting'],
    ['front view', 'cowboy shot'],
    femaleCount: 2,
    maleCount: 1,
  ),
  _adultPosePack(
    'extra_daisy_chain_above',
    '連環口交・俯視',
    '三人依序排列的連環口部互動，由上方呈現',
    '多人・1男2女',
    ['group sex', 'threesome', 'daisy chain', 'oral', 'lying'],
    ['from above', 'full body'],
    femaleCount: 2,
    maleCount: 1,
  ),
  _adultPosePack(
    'extra_threesome_teamwork_above',
    '三人協作姿勢・俯視',
    '三人協作的綜合互動姿勢，由上方呈現',
    '多人・1男2女',
    ['group sex', 'threesome', 'teamwork', 'lying'],
    ['from above', 'full body'],
    femaleCount: 2,
    maleCount: 1,
  ),
];

/// 依目前人物卡片的男女數量顯示；套件本身只描述畫面中的主要互動，
/// 各角色的外觀、服裝與其他個別動作仍由人物卡片維持。
final _groupAdultPosePackages = <_AdultPosePackage>[
  _adultPosePack(
    'multi_2m1f_gangbang_spitroast',
    '前後夾擊・口交與陰道',
    '一位女性位於兩位男性之間，前方口交、後方陰道交合',
    '多人・2男1女',
    ['group sex', 'threesome', 'gangbang', 'spitroast', 'fellatio', 'vaginal'],
    ['side view', 'full body'],
    femaleCount: 1,
    maleCount: 2,
  ),
  _adultPosePack(
    'multi_2m1f_oral_anal_spitroast',
    '前後夾擊・口交與肛交',
    '一位女性前方口交並同時接受後方肛交，以背面呈現',
    '多人・2男1女',
    ['group sex', 'threesome', 'spitroast', 'fellatio', 'anal', 'doggystyle'],
    ['rear view', 'full body'],
    femaleCount: 1,
    maleCount: 2,
  ),
  _adultPosePack(
    'multi_2m1f_multiple_fellatio',
    '雙男性口交・正面',
    '一位女性跪姿同時為兩位男性進行口交',
    '多人・2男1女',
    ['group sex', 'threesome', 'multiple penis fellatio', 'kneeling'],
    ['front view', 'full body'],
    femaleCount: 1,
    maleCount: 2,
  ),
  _adultPosePack(
    'multi_2m1f_double_handjob',
    '雙男性手交・正面',
    '一位女性同時以雙手為兩位男性進行手交',
    '多人・2男1女',
    ['group sex', 'threesome', 'double handjob', 'kneeling'],
    ['front view', 'cowboy shot'],
    femaleCount: 1,
    maleCount: 2,
  ),
  _adultPosePack(
    'multi_2m1f_paizuri_fellatio',
    '乳交與口交協作',
    '一位女性以乳交與口交同時和兩位男性互動',
    '多人・2男1女',
    ['group sex', 'threesome', 'paizuri', 'fellatio', 'teamwork', 'kneeling'],
    ['front view', 'cowboy shot'],
    femaleCount: 1,
    maleCount: 2,
  ),
  _adultPosePack(
    'multi_1m2f_cowgirl_kiss',
    '女上位與親吻協作',
    '一位女性騎乘男性，另一位女性在旁親吻互動',
    '多人・1男2女',
    [
      'group sex',
      'threesome',
      'cowgirl position',
      'girl on top',
      'kiss',
      'teamwork'
    ],
    ['front view', 'full body'],
    femaleCount: 2,
    maleCount: 1,
  ),
  _adultPosePack(
    'multi_1m2f_oral_chain',
    '雙女性口部連環互動',
    '兩位女性與一位男性形成口交與舔陰的連環配置',
    '多人・1男2女',
    ['group sex', 'threesome', 'oral', '69', 'cunnilingus', 'fellatio'],
    ['side view', 'full body'],
    femaleCount: 2,
    maleCount: 1,
  ),
  _adultPosePack(
    'multi_1m2f_facesitting_handjob',
    '顏面騎乘與手交',
    '一位女性顏面騎乘，另一位女性同時進行手交',
    '多人・1男2女',
    ['group sex', 'threesome', 'facesitting', 'handjob', 'girl on top'],
    ['front view', 'full body'],
    femaleCount: 2,
    maleCount: 1,
  ),
  _adultPosePack(
    'multi_1m2f_paizuri_handjob',
    '乳交與手交協作',
    '兩位女性分別進行乳交與手交，以正面膝上構圖呈現',
    '多人・1男2女',
    ['group sex', 'threesome', 'paizuri', 'handjob', 'teamwork'],
    ['front view', 'cowboy shot'],
    femaleCount: 2,
    maleCount: 1,
  ),
  _adultPosePack(
    'multi_1m2f_double_footjob',
    '雙女性足交・俯視',
    '兩位女性共同以足部和一位男性互動',
    '多人・1男2女',
    ['group sex', 'threesome', 'double footjob', 'teamwork', 'sitting'],
    ['from above', 'full body'],
    femaleCount: 2,
    maleCount: 1,
  ),
  _adultPosePack(
    'multi_3m1f_triple_penetration',
    '三重插入・背面',
    '一位女性與三位男性的三重插入配置，以背面全身呈現',
    '多人・3男1女',
    [
      'group sex',
      'foursome',
      'gangbang',
      'triple penetration',
      'vaginal',
      'anal'
    ],
    ['rear view', 'full body'],
    femaleCount: 1,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m1f_triple_vaginal',
    '三重陰道插入・正面',
    '一位女性仰躺展腿，與三位男性形成三重陰道插入配置',
    '多人・3男1女',
    [
      'group sex',
      'foursome',
      'gangbang',
      'triple vaginal',
      'lying on back',
      'legs apart'
    ],
    ['front view', 'full body'],
    femaleCount: 1,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m1f_double_penetration_fellatio',
    '雙重插入加口交・側面',
    '一位女性同時接受雙重插入並為第三位男性口交',
    '多人・3男1女',
    [
      'group sex',
      'foursome',
      'gangbang',
      'double penetration',
      'fellatio',
      'spitroast'
    ],
    ['side view', 'full body'],
    femaleCount: 1,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m1f_double_vaginal_fellatio',
    '雙重陰道插入加口交',
    '一位女性接受雙重陰道插入並同時為第三位男性口交',
    '多人・3男1女',
    ['group sex', 'foursome', 'gangbang', 'double vaginal', 'fellatio'],
    ['front view', 'full body'],
    femaleCount: 1,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m1f_double_anal_fellatio',
    '雙重肛交加口交',
    '一位女性接受雙重肛交並同時為第三位男性口交',
    '多人・3男1女',
    ['group sex', 'foursome', 'gangbang', 'double anal', 'fellatio'],
    ['rear view', 'full body'],
    femaleCount: 1,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m1f_multiple_fellatio',
    '三男性多人式口交',
    '一位女性跪姿與三位男性進行多人式口交',
    '多人・3男1女',
    ['group sex', 'foursome', 'multiple penis fellatio', 'kneeling'],
    ['front view', 'full body'],
    femaleCount: 1,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m1f_handjob_fellatio',
    '雙手交加口交',
    '一位女性以雙手交與口交同時和三位男性互動',
    '多人・3男1女',
    ['group sex', 'foursome', 'double handjob', 'fellatio', 'kneeling'],
    ['front view', 'cowboy shot'],
    femaleCount: 1,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m1f_all_fours_gangbang',
    '四足姿勢多人性交',
    '一位女性維持四足姿勢，由三位男性共同互動',
    '多人・3男1女',
    ['group sex', 'foursome', 'gangbang', 'teamwork', 'all fours'],
    ['rear view', 'full body'],
    femaleCount: 1,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_2m2f_paired_missionary',
    '雙組傳教士體位・俯視',
    '兩男兩女形成兩組傳教士體位，由上方呈現',
    '多人・2男2女',
    [
      'group sex',
      'foursome',
      'vaginal',
      'missionary',
      'teamwork',
      'lying on back'
    ],
    ['from above', 'full body'],
    femaleCount: 2,
    maleCount: 2,
  ),
  _adultPosePack(
    'multi_2m2f_paired_doggy',
    '雙組後入式・背面',
    '兩男兩女形成兩組四足後入姿勢，以背面呈現',
    '多人・2男2女',
    [
      'group sex',
      'foursome',
      'vaginal',
      'doggystyle',
      'sex from behind',
      'all fours'
    ],
    ['rear view', 'full body'],
    femaleCount: 2,
    maleCount: 2,
  ),
  _adultPosePack(
    'multi_2m2f_paired_cowgirl',
    '雙組女上位・正面',
    '兩位女性分別騎乘一位男性，以正面全身呈現',
    '多人・2男2女',
    [
      'group sex',
      'foursome',
      'vaginal',
      'cowgirl position',
      'girl on top',
      'straddling'
    ],
    ['front view', 'full body'],
    femaleCount: 2,
    maleCount: 2,
  ),
  _adultPosePack(
    'multi_2m2f_mixed_cowgirl',
    '正反女上位組合',
    '一組正向女上位、一組反向女上位，以側面呈現',
    '多人・2男2女',
    [
      'group sex',
      'foursome',
      'vaginal',
      'cowgirl position',
      'reverse cowgirl position',
      'teamwork'
    ],
    ['side view', 'full body'],
    femaleCount: 2,
    maleCount: 2,
  ),
  _adultPosePack(
    'multi_2m2f_love_train',
    '四人性愛列車・側面',
    '兩男兩女形成站立連續隊列，以側面全身呈現',
    '多人・2男2女',
    ['group sex', 'foursome', 'love train', 'standing sex', 'sex from behind'],
    ['side view', 'full body'],
    femaleCount: 2,
    maleCount: 2,
  ),
  _adultPosePack(
    'multi_2m2f_oral_teamwork',
    '四人口部協作',
    '兩男兩女形成口交與舔陰的協作配置',
    '多人・2男2女',
    [
      'group sex',
      'foursome',
      'oral sandwich',
      'cunnilingus',
      'fellatio',
      'kneeling'
    ],
    ['side view', 'full body'],
    femaleCount: 2,
    maleCount: 2,
  ),
  _adultPosePack(
    'multi_2m2f_penetration_oral',
    '雙重插入與口交協作',
    '一組雙重插入並由另一位女性加入口部互動',
    '多人・2男2女',
    ['group sex', 'foursome', 'double penetration', 'fellatio', 'teamwork'],
    ['from above', 'full body'],
    femaleCount: 2,
    maleCount: 2,
  ),
  _adultPosePack(
    'multi_2m2f_side_teamwork',
    '四人側臥協作・俯視',
    '兩男兩女以側臥相連方式進行多人互動',
    '多人・2男2女',
    ['group sex', 'foursome', 'spooning', 'on side', 'teamwork'],
    ['from above', 'full body'],
    femaleCount: 2,
    maleCount: 2,
  ),
  _adultPosePack(
    'multi_3m2f_double_penetration_gangbang',
    '五人雙重插入夾擊',
    '三男兩女的五人配置，以雙重插入為主要動作',
    '多人・3男2女',
    ['group sex', 'fivesome', 'gangbang', 'double penetration', 'teamwork'],
    ['rear view', 'full body'],
    femaleCount: 2,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m2f_triple_penetration',
    '五人三重插入協作',
    '三男兩女的五人配置，以三重插入與協作互動為主',
    '多人・3男2女',
    ['group sex', 'fivesome', 'gangbang', 'triple penetration', 'teamwork'],
    ['from above', 'full body'],
    femaleCount: 2,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m2f_double_vaginal_oral',
    '雙重陰道插入與口交',
    '一位女性接受雙重陰道插入，另一位女性加入口交',
    '多人・3男2女',
    [
      'group sex',
      'fivesome',
      'gangbang',
      'double vaginal',
      'fellatio',
      'teamwork'
    ],
    ['front view', 'full body'],
    femaleCount: 2,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m2f_double_anal_oral',
    '雙重肛交與口交',
    '一位女性接受雙重肛交，另一位女性加入口交',
    '多人・3男2女',
    [
      'group sex',
      'fivesome',
      'gangbang',
      'double anal',
      'fellatio',
      'teamwork'
    ],
    ['rear view', 'full body'],
    femaleCount: 2,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m2f_oral_circle',
    '五人口部協作',
    '三男兩女形成多人式口交與舔陰配置',
    '多人・3男2女',
    [
      'group sex',
      'fivesome',
      'multiple penis fellatio',
      'cunnilingus',
      'oral sandwich',
      'kneeling'
    ],
    ['front view', 'full body'],
    femaleCount: 2,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m2f_love_train',
    '五人性愛列車・側面',
    '三男兩女形成站立連續隊列，以側面呈現',
    '多人・3男2女',
    ['group sex', 'fivesome', 'love train', 'standing sex', 'sex from behind'],
    ['side view', 'full body'],
    femaleCount: 2,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m2f_cowgirl_rear_mix',
    '女上位與後入混合',
    '一位女性女上位、另一位女性後入，第三位男性加入協作',
    '多人・3男2女',
    [
      'group sex',
      'fivesome',
      'cowgirl position',
      'doggystyle',
      'sex from behind',
      'teamwork'
    ],
    ['side view', 'full body'],
    femaleCount: 2,
    maleCount: 3,
  ),
  _adultPosePack(
    'multi_3m2f_orgy_teamwork',
    '五人綜合群交・俯視',
    '三男兩女的綜合群交配置，由上方呈現所有人物',
    '多人・3男2女',
    ['group sex', 'fivesome', 'orgy', 'teamwork', 'lying'],
    ['from above', 'full body'],
    femaleCount: 2,
    maleCount: 3,
  ),
];

/// 江戶四十八手沒有一套能直接交給模型的標準英文標籤。
/// 這裡保留傳統名稱，並用現有 Danbooru／Illustrious 標籤描述最接近的
/// 身體配置。部分同屬正常位或交差位的招式，會以腿部、身體方向與鏡頭
/// 標籤補足差異。
final _shijuhatteAdultPosePackages = <_AdultPosePackage>[
  _adultPosePack(
    'shijuhatte_01_ajiro_honte',
    '01 網代本手｜正常位',
    '傳統正常位；男方在上、女方仰躺，以正面全身呈現',
    '四十八手・正常位',
    ['sex', 'vaginal', 'missionary', 'boy on top', 'lying on back'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_02_ageha_honte',
    '02 揚羽本手｜交纏正常位',
    '正常位中雙腿交纏並相擁，以側面呈現',
    '四十八手・正常位',
    ['sex', 'vaginal', 'missionary', 'leg lock', 'hugging'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_03_ikada_honte',
    '03 筏本手｜展腿正常位',
    '女方仰躺展腿的正常位，由上方呈現身體配置',
    '四十八手・正常位',
    ['sex', 'vaginal', 'missionary', 'lying on back', 'legs apart'],
    ['from above', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_04_sekirei_honte',
    '04 鶺鴒本手｜動態正常位',
    '以腰部動作強調傳統正常位，採正面膝上構圖',
    '四十八手・正常位',
    ['sex', 'vaginal', 'missionary', 'pelvic thrust', 'lying on back'],
    ['front view', 'cowboy shot'],
  ),
  _adultPosePack(
    'shijuhatte_05_kotobuki_honte',
    '05 壽本手｜相擁正常位',
    '面對面相擁的正常位，以側面全身呈現',
    '四十八手・正常位',
    ['sex', 'vaginal', 'missionary', 'face-to-face', 'hugging'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_06_horairi_honte',
    '06 洞入本手｜抬腿正常位',
    '變形正常位；女方仰躺抬腿，以側面呈現',
    '四十八手・正常位',
    ['sex', 'vaginal', 'missionary', 'lying on back', 'legs up'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_07_kasafune_honte',
    '07 笠舟本手｜屈膝貼胸',
    '雙膝收向胸前的折疊正常位，以側面呈現',
    '四十八手・正常位',
    ['sex', 'vaginal', 'missionary', 'folded', 'knees to chest'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_08_miyama_honte',
    '08 深山本手｜壓腿正常位',
    '以膝蓋貼胸的壓腿正常位近似，由上方呈現',
    '四十八手・正常位',
    ['sex', 'vaginal', 'mating press', 'knees to chest', 'legs up'],
    ['from above', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_09_irifune_honte',
    '09 入船本手｜正面座位',
    '男方坐姿、雙方面對面直立跨坐，以側面呈現',
    '四十八手・正常位',
    ['sex', 'vaginal', 'upright straddle', 'face-to-face', 'sitting'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_10_karakusa_ichausu',
    '10 唐草居茶臼｜面對面座位',
    '雙方面對面坐姿跨坐，以正面全身呈現',
    '四十八手・座位與側位',
    ['sex', 'vaginal', 'upright straddle', 'face-to-face', 'straddling'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_11_shinobi_ichausu',
    '11 忍居茶臼｜相擁座位',
    '在對方腿上相擁跨坐，以側面全身呈現',
    '四十八手・座位與側位',
    ['sex', 'vaginal', 'upright straddle', 'sitting on lap', 'hugging'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_12_hamachidori',
    '12 濱千鳥｜半側正常位',
    '女方仰躺、男方半側身的正常位，以側面呈現',
    '四十八手・座位與側位',
    ['sex', 'vaginal', 'missionary', 'on side', 'lying on side'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_13_yokobue',
    '13 横笛｜面對面側位',
    '雙方面對面側臥，以側面全身呈現',
    '四十八手・座位與側位',
    ['sex', 'vaginal', 'on side', 'lying on side', 'face-to-face'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_14_kobore_matsuba',
    '14 零松葉｜交纏側位',
    '側臥並交纏腿部的交差式側位，由上方呈現',
    '四十八手・座位與側位',
    ['sex', 'vaginal', 'on side', 'lying on side', 'leg lock'],
    ['from above', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_15_kiku_ichimonji',
    '15 菊一文字｜展腿側位',
    '側臥展腿的交差式側位，以正面全身呈現',
    '四十八手・座位與側位',
    ['sex', 'vaginal', 'on side', 'lying on side', 'legs apart'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_16_ukihashi',
    '16 浮橋｜側臥相擁',
    '兩人同向側臥相擁，以側面全身呈現',
    '四十八手・座位與側位',
    ['sex', 'vaginal', 'spooning', 'on side', 'lying on side'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_17_yaetsubaki',
    '17 八重椿｜面對面交差位',
    '面對面側臥並交纏腿部，由上方呈現',
    '四十八手・座位與側位',
    ['sex', 'vaginal', 'on side', 'face-to-face', 'leg lock'],
    ['from above', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_18_tsubame_gaeshi',
    '18 燕返｜背向交差位',
    '側臥背向交差配置，以背面全身呈現',
    '四十八手・座位與側位',
    ['sex', 'vaginal', 'sex from behind', 'on side', 'leg lock'],
    ['rear view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_19_manji_kuzushi',
    '19 卍崩｜扭身交差位',
    '側臥交差並扭轉上身，以俯視呈現',
    '四十八手・座位與側位',
    ['sex', 'vaginal', 'on side', 'twisted torso', 'crossed legs'],
    ['from above', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_20_defune_ushirodori',
    '20 出船後取｜四足後入',
    '四足姿勢的後背位，以背面全身呈現',
    '四十八手・後背位',
    ['sex', 'vaginal', 'doggystyle', 'sex from behind', 'all fours'],
    ['rear view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_21_tsubushi_komagake',
    '21 潰駒掛｜低身後入',
    '身體壓低並跪姿後入，以背面全身呈現',
    '四十八手・後背位',
    ['sex', 'vaginal', 'sex from behind', 'kneeling', 'leaning forward'],
    ['rear view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_22_hon_komagake',
    '22 本駒掛｜背向座位',
    '男方坐姿、女方背向直立跨坐，以背面呈現',
    '四十八手・後背位',
    [
      'sex',
      'vaginal',
      'sex from behind',
      'reverse upright straddle',
      'sitting'
    ],
    ['rear view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_23_shimekomi_nishiki',
    '23 〆込錦｜膝上後背座位',
    '女方背向坐在對方腿上，以側面全身呈現',
    '四十八手・後背位',
    [
      'sex',
      'vaginal',
      'sex from behind',
      'reverse upright straddle',
      'sitting on lap'
    ],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_24_shimekomi_chidori',
    '24 〆込千鳥｜仰躺背向騎乘',
    '男方仰躺、女方背向騎乘，以側面呈現',
    '四十八手・後背位',
    [
      'sex',
      'vaginal',
      'reverse cowgirl position',
      'girl on top',
      'lying on back'
    ],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_25_ushiro_yagura',
    '25 後櫓｜站立後入',
    '站立俯身的後背位，以背面全身呈現',
    '四十八手・後背位',
    ['sex', 'vaginal', 'standing sex', 'sex from behind', 'bent over'],
    ['rear view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_26_midare_botan',
    '26 亂牡丹｜背面座位',
    '背向坐姿騎乘，以背面全身呈現',
    '四十八手・後背位',
    [
      'sex',
      'vaginal',
      'reverse cowgirl position',
      'sitting on lap',
      'straddling'
    ],
    ['rear view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_27_hon_chausu',
    '27 本茶臼｜密著座位',
    '面對面緊密相擁的直立跨坐，以正面呈現',
    '四十八手・騎乘與交差位',
    ['sex', 'vaginal', 'upright straddle', 'face-to-face', 'hugging'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_28_ikada_chausu',
    '28 筏茶臼｜前傾騎乘',
    '女方在上並向前伸展貼近，以側面呈現',
    '四十八手・騎乘與交差位',
    ['sex', 'vaginal', 'cowgirl position', 'girl on top', 'leaning forward'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_29_shigure_chausu',
    '29 時雨茶臼｜女上位',
    '標準女上位跨坐，以正面全身呈現',
    '四十八手・騎乘與交差位',
    ['sex', 'vaginal', 'cowgirl position', 'girl on top', 'straddling'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_30_hataori_chausu',
    '30 機織茶臼｜蹲式女上位',
    '女方蹲姿騎乘，以正面全身呈現',
    '四十八手・騎乘與交差位',
    [
      'sex',
      'vaginal',
      'squatting cowgirl position',
      'girl on top',
      'squatting'
    ],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_31_gosho_guruma',
    '31 御所車｜交腿交差位',
    '側臥並交叉腿部的變形交差位，由上方呈現',
    '四十八手・騎乘與交差位',
    ['sex', 'vaginal', 'on side', 'leg lock', 'crossed legs'],
    ['from above', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_32_tsukimi_chausu',
    '32 月見茶臼｜變形背向騎乘',
    '背向坐姿的變形女上位，以背面呈現',
    '四十八手・騎乘與交差位',
    ['sex', 'vaginal', 'reverse cowgirl position', 'girl on top', 'sitting'],
    ['rear view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_33_takarabune',
    '33 寶船｜相向交差位',
    '面對面側臥並交叉腿部，以側面呈現',
    '四十八手・騎乘與交差位',
    ['sex', 'vaginal', 'on side', 'face-to-face', 'crossed legs'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_34_karatake_wari',
    '34 唐竹割｜展腿伸長位',
    '仰躺展腿的伸長位，以正面全身呈現',
    '四十八手・騎乘與交差位',
    ['sex', 'vaginal', 'missionary', 'lying on back', 'spread legs'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_35_shigarami',
    '35 笧｜過頭伸長位',
    '仰躺並將雙腿越過頭部，以側面呈現',
    '四十八手・騎乘與交差位',
    ['sex', 'vaginal', 'missionary', 'legs over head', 'folded'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_36_ikada_kuzushi',
    '36 筏崩｜單腿伸長位',
    '仰躺並伸出單腿的變形伸長位，以側面呈現',
    '四十八手・騎乘與交差位',
    ['sex', 'vaginal', 'missionary', 'lying on back', 'outstretched leg'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_37_kuruwa_tsunagi',
    '37 廓繋｜相擁交差位',
    '側臥、相擁並交纏腿部，以側面呈現',
    '四十八手・騎乘與交差位',
    ['sex', 'vaginal', 'on side', 'leg lock', 'hugging'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_38_kagerou',
    '38 蜉蝣｜變形女上位',
    '由女方主導的非常規騎乘姿勢，以正面呈現',
    '四十八手・騎乘與交差位',
    ['sex', 'vaginal', 'amazon position', 'girl on top'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_39_kinuta',
    '39 砧｜臀部相貼',
    '兩人臀部方向相貼的特殊坐姿，以側面呈現',
    '四十八手・騎乘與交差位',
    ['sex', 'vaginal', 'ass-to-ass', 'sitting'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_40_kurui_jishi',
    '40 狂獅子｜相向展腿',
    '雙方面對面展腿，使身體結合位置清楚可見',
    '四十八手・騎乘與交差位',
    ['sex', 'vaginal', 'face-to-face', 'sitting', 'legs apart'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_41_hanabishi_zeme',
    '41 花菱責｜舔陰',
    '女方仰躺展腿接受舔陰，以正面呈現',
    '四十八手・口部與手部',
    ['oral', 'cunnilingus', 'lying on back', 'legs apart'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_42_shakuhachi',
    '42 尺八｜跪姿口交',
    '跪姿進行陰莖口交，以側面全身呈現',
    '四十八手・口部與手部',
    ['oral', 'fellatio', 'kneeling'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_43_mukudori',
    '43 椋鳥｜男上六九式',
    '男方在上的六九式，以側面全身呈現',
    '四十八手・口部與手部',
    ['oral', '69', 'boy on top', 'lying'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_44_byakko_nishiki',
    '44 白光錦｜陰道指交',
    '女方仰躺展腿接受陰道指交，以正面呈現',
    '四十八手・口部與手部',
    ['fingering', 'vaginal fingering', 'lying on back', 'legs apart'],
    ['front view', 'cowboy shot'],
  ),
  _adultPosePack(
    'shijuhatte_45_sakasa_mukudori',
    '45 逆椋鳥｜女上六九式',
    '女方在上的六九式，以側面全身呈現',
    '四十八手・口部與手部',
    ['oral', '69', 'girl on top', 'lying'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_46_futatsu_domoe',
    '46 二巴｜側臥六九式',
    '雙方側臥進行六九式，以側面全身呈現',
    '四十八手・口部與手部',
    ['oral', '69', 'on side', 'lying on side'],
    ['side view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_47_tachi_kanae',
    '47 立鼎｜面對面站立',
    '雙方面對面站立交合，以正面全身呈現',
    '四十八手・立位與懸空',
    ['sex', 'vaginal', 'standing sex', 'standing', 'face-to-face'],
    ['front view', 'full body'],
  ),
  _adultPosePack(
    'shijuhatte_48_yagura_dachi',
    '48 櫓立｜懸空抱持',
    '站立抱起對方進行懸空交合，以側面全身呈現',
    '四十八手・立位與懸空',
    ['sex', 'vaginal', 'suspended congress', 'standing', 'carrying'],
    ['side view', 'full body'],
  ),
];

class PersonSlot {
  PersonSlot({this.gender = '女性'});

  String gender;
  bool detailed = true;
  String mode = '原創';
  String characterId = '';
  String animeQuery = '';
  String animeTag = '';
  String remoteAnimeZh = '';
  String remoteAnimeEn = '';
  String query = '';
  String originalAnimeZh = '';
  String originalAnimeEn = '';
  String originalAnimeTag = '';
  String originalCharacterZh = '';
  String originalCharacterEn = '';
  String originalCharacterTag = '';
  String originalTraits = '';
  String poseExtraPositive = '';
  // Anime character names are always kept.  This flag only controls the
  // character's automatically-applied, stable appearance traits.
  bool characterTraitsEnabled = true;
  // Each person's identity, fixed traits, outfit, and individual actions use
  // one shared outer emphasis block. Turning this off only omits the explicit
  // `:1.05`-style suffix.
  bool promptWeightEnabled = true;
  double personPromptWeight = 1.05;
  // Legacy saved values are retained solely so older local saves can be read.
  // New prompt output and controls use [personPromptWeight].
  double characterPromptWeight = 1.05;
  double clothingPromptWeight = 1.05;
  // This local emphasis applies to all selected hair characteristics (colour,
  // length and style). The former colour-only saved fields are read below for
  // backwards compatibility.
  bool hairPromptWeightEnabled = false;
  double hairPromptWeight = 1.15;
  List<String> hairGradientColorIds = <String>[];
  String hairGradientStyle = _defaultHairGradientStyle;

  Map<String, dynamic> toJson() => {
        'gender': gender,
        'detailed': detailed,
        'mode': mode,
        'characterId': characterId,
        'animeQuery': animeQuery,
        'animeTag': animeTag,
        'remoteAnimeZh': remoteAnimeZh,
        'remoteAnimeEn': remoteAnimeEn,
        'query': query,
        'originalAnimeZh': originalAnimeZh,
        'originalAnimeEn': originalAnimeEn,
        'originalAnimeTag': originalAnimeTag,
        'originalCharacterZh': originalCharacterZh,
        'originalCharacterEn': originalCharacterEn,
        'originalCharacterTag': originalCharacterTag,
        'originalTraits': originalTraits,
        'poseExtraPositive': poseExtraPositive,
        'characterTraitsEnabled': characterTraitsEnabled,
        'promptWeightEnabled': promptWeightEnabled,
        'personPromptWeight': personPromptWeight,
        'characterPromptWeight': characterPromptWeight,
        'clothingPromptWeight': clothingPromptWeight,
        'hairPromptWeightEnabled': hairPromptWeightEnabled,
        'hairPromptWeight': hairPromptWeight,
        // Keep these two keys while old browser saves may still be opened by
        // an earlier deployed build.
        'hairColorWeightEnabled': hairPromptWeightEnabled,
        'hairColorWeight': hairPromptWeight,
        'hairGradientColorIds': hairGradientColorIds,
        'hairGradientStyle': hairGradientStyle,
      };

  factory PersonSlot.fromJson(Map<String, dynamic> json) => PersonSlot(
        gender: '${json['gender'] ?? '女性'}',
      )
        ..detailed = json['detailed'] != false
        ..mode = '${json['mode'] ?? '原創'}'
        ..characterId = '${json['characterId'] ?? ''}'
        ..animeQuery = '${json['animeQuery'] ?? ''}'
        ..animeTag = '${json['animeTag'] ?? ''}'
        ..remoteAnimeZh = '${json['remoteAnimeZh'] ?? ''}'
        ..remoteAnimeEn = '${json['remoteAnimeEn'] ?? ''}'
        ..query = '${json['query'] ?? ''}'
        ..originalAnimeZh = '${json['originalAnimeZh'] ?? ''}'
        ..originalAnimeEn = '${json['originalAnimeEn'] ?? ''}'
        ..originalAnimeTag = '${json['originalAnimeTag'] ?? ''}'
        ..originalCharacterZh = '${json['originalCharacterZh'] ?? ''}'
        ..originalCharacterEn = '${json['originalCharacterEn'] ?? ''}'
        ..originalCharacterTag = '${json['originalCharacterTag'] ?? ''}'
        ..originalTraits = '${json['originalTraits'] ?? ''}'
        ..poseExtraPositive = '${json['poseExtraPositive'] ?? ''}'
        ..characterTraitsEnabled = json['characterTraitsEnabled'] != false
        ..promptWeightEnabled = json['promptWeightEnabled'] != false
        ..personPromptWeight = (double.tryParse(
                    '${json['personPromptWeight'] ?? json['characterPromptWeight'] ?? json['clothingPromptWeight'] ?? 1.05}') ??
                1.05)
            .clamp(0.50, 1.50)
            .toDouble()
        ..characterPromptWeight =
            (double.tryParse('${json['characterPromptWeight'] ?? 1.05}') ??
                    1.05)
                .clamp(0.50, 1.50)
                .toDouble()
        ..clothingPromptWeight =
            (double.tryParse('${json['clothingPromptWeight'] ?? 1.05}') ?? 1.05)
                .clamp(0.50, 1.50)
                .toDouble()
        ..hairPromptWeightEnabled = json['hairPromptWeightEnabled'] == true ||
            json['hairColorWeightEnabled'] == true
        ..hairPromptWeight = (double.tryParse(
                    '${json['hairPromptWeight'] ?? json['hairColorWeight'] ?? 1.15}') ??
                1.15)
            .clamp(0.50, 1.50)
            .toDouble()
        ..hairGradientColorIds = (json['hairGradientColorIds'] as List? ?? [])
            .map((id) => '$id')
            .toList()
        ..hairGradientStyle =
            '${json['hairGradientStyle'] ?? _defaultHairGradientStyle}';
}

class _RemoteAnime {
  const _RemoteAnime({
    required this.id,
    required this.title,
    required this.titleJapanese,
    required this.year,
    this.source = 'jikan',
    this.characters = const <_RemoteCharacter>[],
  });

  final int id;
  final String title;
  final String titleJapanese;
  final int? year;
  final String source;
  final List<_RemoteCharacter> characters;

  String get tag => title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_ -]'), '')
      .replaceAll(RegExp(r'\s+'), '_');
}

class _RemoteCharacter {
  const _RemoteCharacter({
    required this.id,
    required this.name,
    required this.nameKanji,
    required this.role,
    this.about = '',
  });

  final int id;
  final String name;
  final String nameKanji;
  final String role;
  final String about;

  _RemoteCharacter withAbout(String value) => _RemoteCharacter(
        id: id,
        name: name,
        nameKanji: nameKanji,
        role: role,
        about: value,
      );
}

TagItem _catalogTag(CatalogTagData data, {String prefix = 'catalog'}) =>
    TagItem(
      id: '${prefix}_${data.id}',
      group: _catalogPickerGroup(data),
      zh: data.zh,
      en: data.en,
      order: data.order,
      adult: data.adult,
      conflictGroup: data.conflictGroup,
      support: data.support,
    );

TagItem _characterTag(String id, String zh, String en) => TagItem(
      id: 'character_$id',
      group: '角色標籤',
      zh: zh,
      en: en,
      order: 1,
    );

TagItem _tag(
  String id,
  String group,
  String zh,
  String en,
  int order, {
  bool adult = false,
  String? conflictGroup,
}) =>
    TagItem(
        id: id,
        group: group,
        zh: zh,
        en: en,
        order: order,
        adult: adult,
        conflictGroup: conflictGroup);

const _clothingGroupOnePiece = '\u670D\u88DD';
const _clothingGroupTop = '\u4E0A\u8863';
const _clothingGroupPants = '\u8932\u5B50';
const _clothingGroupShorts = '短褲';
const _clothingGroupSkirt = '\u88D9\u5B50';
const _clothingGroupOuterwear = '外套';
const _clothingGroupCostume = '特殊服裝';
const _clothingGroupUnderwear = '\u5167\u8863';
const _clothingGroupBra = '\u80F8\u7F69';
const _clothingGroupPanties = '\u5167\u8932';
const _clothingGroupSocks = '\u896A\u5B50';
const _clothingGroupShoes = '\u978B\u5B50';
const _clothingGroupAccessory = '\u914D\u4EF6';
const _clothingGroupHat = '配件・帽子';
const _clothingGroupHeadAccessory = '配件・頭部';
const _clothingGroupHairAccessory = '配件・髮飾';
const _clothingGroupEyewear = '配件・眼鏡';
const _clothingGroupFaceAccessory = '配件・臉耳';
const _clothingGroupAnimalAccessory = '配件・獸飾';
const _clothingGroupNeckAccessory = '配件・頸肩';
const _clothingGroupHandAccessory = '配件・手臂';
const _clothingGroupWaistAccessory = '配件・腰部';
const _clothingGroupOtherAccessory = '配件・其他';
const _clothingAccessoryPickerGroups = <String>{
  _clothingGroupHat,
  _clothingGroupHeadAccessory,
  _clothingGroupHairAccessory,
  _clothingGroupEyewear,
  _clothingGroupFaceAccessory,
  _clothingGroupAnimalAccessory,
  _clothingGroupNeckAccessory,
  _clothingGroupHandAccessory,
  _clothingGroupWaistAccessory,
  _clothingGroupOtherAccessory,
};
const _cosplayGroup = '角色扮演';
const _legacyClothingDetailGroup = '\u670D\u88DD\u7D30\u7BC0';
const _legacyClothingMaterialGroup = '\u670D\u88DD\u6750\u8CEA';
const _legacyClothingWearGroup = '\u7A7F\u812B\u72C0\u614B';
const _scopedClothingPrefix = 'clothing_scope_';
// UI-only group: all selected clothing wear-state tags are shown together.
const _allClothingWearGroup = 'clothing_all_wear';
const _outfitMainStyleGroup = '服裝・主要風格';
const _outfitSubStyleGroup = '服裝・子風格';
const _outfitMoodGroup = '服裝・氣質';
const _outfitOccasionGroup = '服裝・場合';

const _clothingGarmentPickerGroups = <String>[
  _clothingGroupHat,
  _clothingGroupHeadAccessory,
  _clothingGroupHairAccessory,
  _clothingGroupEyewear,
  _clothingGroupFaceAccessory,
  _clothingGroupAnimalAccessory,
  _clothingGroupNeckAccessory,
  _clothingGroupOuterwear,
  _clothingGroupTop,
  _clothingGroupOnePiece,
  _clothingGroupCostume,
  _clothingGroupPants,
  _clothingGroupShorts,
  _clothingGroupSkirt,
  _clothingGroupUnderwear,
  _clothingGroupBra,
  _clothingGroupPanties,
  _clothingGroupHandAccessory,
  _clothingGroupWaistAccessory,
  _clothingGroupSocks,
  _clothingGroupShoes,
  _clothingGroupOtherAccessory,
];

String _scopedClothingGroup(String slot, String kind) =>
    '$_scopedClothingPrefix${slot}_$kind';

bool _isScopedClothingGroup(String group) =>
    group.startsWith(_scopedClothingPrefix);

String? _scopedClothingSlot(String group) {
  if (!_isScopedClothingGroup(group)) return null;
  final value = group.substring(_scopedClothingPrefix.length);
  for (final kind in const [
    'detail_color',
    'material',
    'pattern',
    'length',
    'detail',
    'style',
    'wear',
    'fit',
    'cut',
  ]) {
    final suffix = '_$kind';
    if (value.endsWith(suffix)) {
      return value.substring(0, value.length - suffix.length);
    }
  }
  return null;
}

String? _scopedClothingKind(String group) {
  if (!_isScopedClothingGroup(group)) return null;
  final value = group.substring(_scopedClothingPrefix.length);
  for (final kind in const [
    'detail_color',
    'material',
    'pattern',
    'length',
    'detail',
    'style',
    'wear',
    'fit',
    'cut',
  ]) {
    if (value.endsWith('_$kind')) return kind;
  }
  return null;
}

String _clothingScopeNoun(String slot) =>
    const {
      'top': 'top',
      'pants': 'pants',
      'shorts': 'shorts',
      'skirt': 'skirt',
      'onepiece': 'one-piece',
      'outerwear': 'outerwear',
      'costume': 'costume',
      'underwear': 'underwear',
      'bra': 'bra',
      'panties': 'panties',
      'socks': 'socks',
      'shoes': 'shoes',
      'accessory': 'accessory',
    }[slot] ??
    slot;

String _clothingScopeLabel(String slot) =>
    const {
      'top': '\u4E0A\u8863',
      'pants': '\u8932\u5B50',
      'shorts': '短褲',
      'skirt': '\u88D9\u5B50',
      'onepiece': '\u9023\u8EAB\u88DD',
      'outerwear': '外套',
      'costume': '特殊服裝',
      'underwear': '\u5167\u8863',
      'bra': '\u80F8\u7F69',
      'panties': '\u5167\u8932',
      'socks': '\u896A\u5B50',
      'shoes': '\u978B\u5B50',
      'accessory': '\u914D\u4EF6',
    }[slot] ??
    slot;

String _clothingScopedKindLabel(String kind) =>
    const {
      'style': '\u98A8\u683C',
      'cut': '剪裁',
      'fit': '版型',
      'length': '長度',
      'detail': '裝飾／細節',
      'material': '\u6750\u8CEA',
      'pattern': '圖案',
      'detail_color': '裝飾色',
      'wear': '\u7A7F\u812B\u72C0\u614B',
    }[kind] ??
    kind;

String _clothingAccessoryPickerGroup(TagItem tag) {
  final english = tag.en.toLowerCase();
  if (RegExp(
    r'\b(?:animal|cat|fox|dog|wolf|bear|bunny|rabbit|bird|feathered|wing)\b.*\b(?:ears?|tail|wings?|headband|headpiece|decoration|hairclip|hairpin)\b',
  ).hasMatch(english)) {
    return _clothingGroupAnimalAccessory;
  }
  if (RegExp(r'\b(hair|hairband|hairclip|hairpin|barrette|headband)\b')
      .hasMatch(english)) {
    return _clothingGroupHairAccessory;
  }
  if (RegExp(
          r'\b(tiara|veil|crown|headdress|wreath|halo|headpiece|fascinator)\b')
      .hasMatch(english)) {
    return _clothingGroupHeadAccessory;
  }
  if (RegExp(r'\b(hat|cap|beret|helmet|hood)\b').hasMatch(english)) {
    return _clothingGroupHat;
  }
  if (RegExp(r'\b(glasses|sunglasses|goggles|monocle|eyepatch|eyewear)\b')
      .hasMatch(english)) {
    return _clothingGroupEyewear;
  }
  if (RegExp(r'\b(mask|earring|ear cuff)\b').hasMatch(english)) {
    return _clothingGroupFaceAccessory;
  }
  if (RegExp(r'\b(choker|necklace|necktie|neck ribbon|scarf|shawl|collar)\b')
      .hasMatch(english)) {
    return _clothingGroupNeckAccessory;
  }
  if (RegExp(r'\b(glove|arm guard|bracelet|wrist|sleeve)\b')
      .hasMatch(english)) {
    return _clothingGroupHandAccessory;
  }
  if (RegExp(r'\b(belt|sash|waist|garter)\b').hasMatch(english)) {
    return _clothingGroupWaistAccessory;
  }
  return _clothingGroupOtherAccessory;
}

void _migrateConsolidatedWearTagIds(Set<String> ids) {
  const replacementsBySlot = <String, Map<String, String>>{
    'top': {
      'open': 'clothing_open',
      'unbuttoned': 'clothing_unbuttoned',
      'half_removed': 'clothing_half_removed',
      'removed': 'clothing_removed',
      'undressing': 'clothing_undressing',
      'holding': 'clothing_holding_clothes',
      'on_floor': 'clothing_on_floor',
      'partially_undressed': 'clothing_partially_undressed',
      'unzipped': 'clothing_unzipped',
      'adjusting_clothes': 'clothing_adjusting',
    },
    'pants': {
      'unbuttoned': 'clothing_unbuttoned',
      'half_removed': 'clothing_half_removed',
      'one_leg_out': 'clothing_one_leg_out',
      'removed': 'clothing_removed',
      'holding': 'clothing_holding_clothes',
      'on_floor': 'clothing_on_floor',
      'partially_undressed': 'clothing_partially_undressed',
      'unzipped': 'clothing_unzipped',
      'adjusting_clothes': 'clothing_adjusting',
    },
    'skirt': {
      'half_removed': 'clothing_half_removed',
      'removed': 'clothing_removed',
      'undressing': 'clothing_undressing',
      'holding': 'clothing_holding_clothes',
      'on_floor': 'clothing_on_floor',
      'partially_undressed': 'clothing_partially_undressed',
      'adjusting_clothes': 'clothing_adjusting',
    },
    'onepiece': {
      'open': 'clothing_open',
      'half_removed': 'clothing_half_removed',
      'removed': 'clothing_removed',
      'undressing': 'clothing_undressing',
      'holding': 'clothing_holding_clothes',
      'on_floor': 'clothing_on_floor',
      'partially_undressed': 'clothing_partially_undressed',
      'adjusting_clothes': 'clothing_adjusting',
    },
    'underwear': {
      'undressing': 'clothing_undressing',
      'holding': 'clothing_holding_clothes',
      'on_floor': 'clothing_on_floor',
      'partially_undressed': 'clothing_partially_undressed',
      'adjusting_clothes': 'clothing_adjusting',
    },
    'bra': {
      'undressing': 'clothing_undressing',
      'holding': 'clothing_holding_clothes',
      'partially_undressed': 'clothing_partially_undressed',
      'adjusting_clothes': 'clothing_adjusting',
    },
    'panties': {
      'one_leg_out': 'clothing_one_leg_out',
      'undressing': 'clothing_undressing',
      'holding': 'clothing_holding_clothes',
      'partially_undressed': 'clothing_partially_undressed',
      'adjusting_clothes': 'clothing_adjusting',
    },
    'socks': {
      'undressing': 'clothing_undressing',
      'holding': 'clothing_holding_clothes',
      'adjusting_clothes': 'clothing_adjusting',
    },
    'shoes': {
      'undressing': 'clothing_undressing',
      'adjusting_clothes': 'clothing_adjusting',
    },
  };
  for (final slot in replacementsBySlot.entries) {
    for (final replacement in slot.value.entries) {
      final oldId =
          '${_scopedClothingPrefix}${slot.key}_wear_${replacement.key}';
      if (ids.remove(oldId)) ids.add(replacement.value);
    }
  }
  const legacySpecificReplacements = <String, String>{
    'clothing_bra_lift': '${_scopedClothingPrefix}bra_wear_lift',
    'clothing_panties_down': '${_scopedClothingPrefix}panties_wear_down',
    'clothing_skirt_around_one_leg':
        '${_scopedClothingPrefix}skirt_wear_around_one_leg',
  };
  for (final replacement in legacySpecificReplacements.entries) {
    if (ids.remove(replacement.key)) ids.add(replacement.value);
  }
}

void _migrateClothingTaxonomyTagIds(Set<String> ids) {
  const replacements = <String, String>{
    'catalog_taxonomy_onepiece_one_piece_dress':
        'catalog_taxonomy_onepiece_dress',
    'catalog_taxonomy_costume_sailor_uniform':
        'catalog_taxonomy_costume_sailor_style_outfit',
    'catalog_taxonomy_costume_serafuku':
        'catalog_taxonomy_costume_sailor_style_outfit',
    'catalog_taxonomy_costume_school_uniform':
        'catalog_taxonomy_costume_formal_blazer_outfit',
    'catalog_taxonomy_pants_slim_pants':
        'catalog_taxonomy_pants_narrow_leg_pants',
    'catalog_taxonomy_shorts_short_shorts': 'catalog_taxonomy_shorts_hot_pants',
    'catalog_taxonomy_shoes_school_shoes': 'catalog_taxonomy_shoes_loafers',
    'catalog_taxonomy_top_fit_slim_fit':
        'catalog_taxonomy_top_fit_tailored_fit',
    'catalog_taxonomy_pants_fit_slim_fit':
        'catalog_taxonomy_pants_fit_tailored_fit',
    'catalog_taxonomy_shorts_fit_slim_fit':
        'catalog_taxonomy_shorts_fit_tailored_fit',
    'catalog_taxonomy_skirt_fit_slim_fit':
        'catalog_taxonomy_skirt_fit_tailored_fit',
    'catalog_taxonomy_onepiece_fit_slim_fit':
        'catalog_taxonomy_onepiece_fit_tailored_fit',
    'catalog_taxonomy_outerwear_fit_slim_fit':
        'catalog_taxonomy_outerwear_fit_tailored_fit',
    'catalog_taxonomy_top_cut_short_sleeves':
        'catalog_taxonomy_top_cut_above_elbow_sleeves',
    'catalog_taxonomy_shorts_length_short_length':
        'catalog_taxonomy_shorts_length_upper_thigh_length',
    'catalog_taxonomy_costume_maid_outfit': 'catalog_taxonomy_costume_maid',
    'catalog_taxonomy_costume_miko_outfit': 'catalog_taxonomy_costume_miko',
    'catalog_taxonomy_skirt_tutu_skirt': 'catalog_taxonomy_skirt_tutu',
    'catalog_taxonomy_shoes_knee_high_boots':
        'catalog_taxonomy_shoes_knee_boots',
    'catalog_taxonomy_shoes_zori': 'catalog_taxonomy_shoes_zouri',
    'catalog_taxonomy_top_cut_puff_sleeves':
        'catalog_taxonomy_top_cut_puffy_sleeves',
    'catalog_outfit_main_style_casual_style':
        'catalog_outfit_main_style_casual',
    'catalog_outfit_main_style_feminine_style':
        'catalog_outfit_main_style_feminine',
    'catalog_outfit_main_style_cute_style':
        'catalog_outfit_main_style_charming',
    'catalog_outfit_main_style_cute': 'catalog_outfit_main_style_charming',
    'catalog_outfit_main_style_elegant_style':
        'catalog_outfit_main_style_elegant',
    'catalog_outfit_main_style_sexy_style': 'catalog_outfit_main_style_sexy',
    'catalog_outfit_main_style_preppy_style':
        'catalog_outfit_main_style_preppy',
    'catalog_outfit_main_style_streetwear_style':
        'catalog_outfit_main_style_streetwear',
    'catalog_outfit_main_style_sporty_style':
        'catalog_outfit_main_style_sportswear',
    'catalog_outfit_main_style_gothic_style':
        'catalog_outfit_main_style_goth_fashion',
    'catalog_outfit_main_style_punk_style': 'catalog_outfit_main_style_punk',
    'catalog_outfit_main_style_vintage_style':
        'catalog_outfit_main_style_vintage',
    'catalog_outfit_main_style_minimalist_style':
        'catalog_outfit_main_style_minimalist',
    'catalog_outfit_main_style_bohemian_style':
        'catalog_outfit_main_style_bohemian',
    'catalog_outfit_main_style_fantasy_style':
        'catalog_outfit_main_style_fantasy',
    'catalog_outfit_main_style_futuristic_style':
        'catalog_outfit_main_style_futuristic',
    'catalog_outfit_sub_style_sweet_cute_style':
        'catalog_outfit_sub_style_sweet_feminine_style',
    'catalog_outfit_mood_cute_mood': 'catalog_outfit_mood_cheerful_mood',
    'catalog_outfit_occasion_school_outfit':
        'catalog_outfit_occasion_daytime_formal_outfit',
    'hair_style_baby_bangs': 'hair_style_micro_bangs',
    'catalog_character_pose_baby_carry': 'catalog_character_pose_cradle_carry',
    'catalog_character_pose_child_carry': 'catalog_character_pose_side_carry',
    'catalog_outfit_sub_style_y2k_style':
        'catalog_outfit_sub_style_y2k_fashion',
  };
  for (final oldId in ids.toList()) {
    var newId = replacements[oldId];
    if (newId == null && oldId.endsWith('_baby_blue')) {
      newId = oldId.replaceFirst(RegExp(r'baby_blue$'), 'pastel_blue');
    }
    if (newId == null && oldId.contains('_pattern_floral_pattern')) {
      newId =
          oldId.replaceAll('_pattern_floral_pattern', '_pattern_floral_print');
    }
    if (newId == null && oldId.contains('_pattern_rose_pattern')) {
      newId = oldId.replaceAll('_pattern_rose_pattern', '_pattern_rose_print');
    }
    if (newId == null && oldId.contains('_pattern_cherry_blossom_pattern')) {
      newId = oldId.replaceAll(
          '_pattern_cherry_blossom_pattern', '_pattern_cherry_blossom_print');
    }
    if (newId == null || newId == oldId) continue;
    ids
      ..remove(oldId)
      ..add(newId);
  }
}

List<TagItem> _createScopedClothingTags() {
  final tags = <TagItem>[];

  void add(
    String slot,
    String kind,
    String id,
    String zh,
    String en, {
    bool adult = false,
    String? conflictGroup,
  }) {
    final interactionIds = {
      'holding',
      'clothes_pull',
      'shirt_pull',
      'collar_pull',
      'pants_pull',
      'skirt_pull',
      'adjusting_clothes',
    };
    final visibilityIds = {
      'off_shoulder',
      'single_off_shoulder',
      'bra_visible',
      'panties_visible',
      'waistband',
    };
    final defaultConflict = kind == 'style'
        ? '${slot}_style'
        : kind == 'detail_color'
            ? '${slot}_detail_color'
            : kind == 'wear'
                ? visibilityIds.contains(id)
                    ? '${slot}_visibility'
                    : interactionIds.contains(id)
                        ? '${slot}_interaction'
                        : '${slot}_wear'
                : conflictGroup;
    tags.add(_tag(
      '${_scopedClothingPrefix}${slot}_${kind}_$id',
      _scopedClothingGroup(slot, kind),
      zh,
      en,
      2,
      adult: adult,
      conflictGroup: conflictGroup ?? defaultConflict,
    ));
  }

  void addMany(
    String slot,
    String kind,
    List<List<String>> values, {
    bool adult = false,
  }) {
    for (final value in values) {
      add(slot, kind, value[0], value[1], value[2], adult: adult);
    }
  }

  addMany('top', 'style', [
    [
      'puff_sleeve',
      '\u6CE1\u6CE1\u8896\u4E0A\u8863\u98A8\u683C',
      'puff sleeve top'
    ],
    ['turtleneck', '\u9AD8\u9818\u4E0A\u8863\u98A8\u683C', 'turtleneck top'],
    ['halter', '\u639B\u9838\u4E0A\u8863\u98A8\u683C', 'halter top'],
    ['corset', '\u675F\u8170\u4E0A\u8863\u98A8\u683C', 'corset style top'],
    [
      'off_shoulder',
      '\u9732\u80A9\u4E0A\u8863\u98A8\u683C',
      'off-shoulder style top'
    ],
    ['cropped', '\u77ED\u7248\u4E0A\u8863\u98A8\u683C', 'cropped style top'],
  ]);
  addMany('pants', 'style', [
    [
      'high_waist',
      '\u9AD8\u8170\u8932\u5B50\u98A8\u683C',
      'high-waisted pants'
    ],
    ['wide_leg', '\u95CA\u817F\u8932\u98A8\u683C', 'wide-leg pants'],
    ['cargo', '\u5DE5\u88DD\u8932\u98A8\u683C', 'cargo pants style'],
    ['skinny', '\u7DCA\u8EAB\u8932\u98A8\u683C', 'skinny pants style'],
    ['track', '\u904B\u52D5\u8932\u98A8\u683C', 'track pants style'],
    ['flared', '\u5587\u53ED\u8932\u98A8\u683C', 'flared pants'],
    ['capri', '\u4E03\u5206\u8932\u98A8\u683C', 'capri pants'],
    ['ripped', '\u7834\u58DE\u8932\u98A8\u683C', 'ripped pants'],
  ]);
  addMany('skirt', 'style', [
    ['pleated', '\u767E\u8936\u88D9\u98A8\u683C', 'pleated style skirt'],
    ['a_line', 'A\u5B57\u88D9\u98A8\u683C', 'a-line style skirt'],
    ['pencil', '\u925B\u7B46\u88D9\u98A8\u683C', 'pencil style skirt'],
    ['tiered', '\u86CB\u7CD5\u88D9\u98A8\u683C', 'tiered style skirt'],
    ['wrap', '\u88F9\u8EAB\u88D9\u98A8\u683C', 'wrap style skirt'],
    ['slit', '\u958B\u8869\u88D9\u98A8\u683C', 'slit style skirt'],
    ['ruffled', '\u8377\u8449\u908A\u88D9\u98A8\u683C', 'ruffled style skirt'],
    ['denim', '\u725B\u4ED4\u88D9\u98A8\u683C', 'denim style skirt'],
  ]);
  addMany('onepiece', 'style', [
    [
      'gothic',
      '\u54E5\u5FB7\u5F0F\u9023\u8EAB\u88DD\u98A8\u683C',
      'gothic style one-piece'
    ],
    [
      'elegant',
      '\u512A\u96C5\u9023\u8EAB\u88DD\u98A8\u683C',
      'elegant style one-piece'
    ],
    [
      'casual',
      '\u4F11\u9592\u9023\u8EAB\u88DD\u98A8\u683C',
      'casual style one-piece'
    ],
    [
      'sporty',
      '\u904B\u52D5\u9023\u8EAB\u88DD\u98A8\u683C',
      'sporty style one-piece'
    ],
    [
      'sailor',
      '\u6C34\u624B\u9023\u8EAB\u88DD\u98A8\u683C',
      'sailor style one-piece'
    ],
    [
      'victorian',
      '\u7DAD\u591A\u5229\u4E9E\u9023\u8EAB\u88DD\u98A8\u683C',
      'Victorian style one-piece'
    ],
    [
      'maid',
      '\u5973\u50D5\u9023\u8EAB\u88DD\u98A8\u683C',
      'maid style one-piece'
    ],
    [
      'formal',
      '\u6B63\u5F0F\u9023\u8EAB\u88DD\u98A8\u683C',
      'formal style one-piece'
    ],
    [
      'dark_academia',
      '\u6697\u9ED1\u5B78\u9662\u9023\u8EAB\u88DD\u98A8\u683C',
      'dark academia style one-piece'
    ],
    [
      'steampunk',
      '\u84B8\u6C23\u9F90\u514B\u9023\u8EAB\u88DD\u98A8\u683C',
      'steampunk style one-piece'
    ],
  ]);
  addMany('underwear', 'style', [
    ['lace', '\u856D\u7D72\u5167\u8863\u98A8\u683C', 'lace style underwear'],
    [
      'camisole',
      '\u540A\u5E36\u5167\u8863\u98A8\u683C',
      'camisole style underwear'
    ],
    ['silk', '\u7D72\u7DB8\u5167\u8863\u98A8\u683C', 'silk style underwear'],
    [
      'strapless',
      '\u7121\u80A9\u5E36\u5167\u8863\u98A8\u683C',
      'strapless style underwear'
    ],
    ['long', '\u9577\u7248\u5167\u8863\u98A8\u683C', 'long underwear style'],
    ['sheer', '\u900F\u8996\u5167\u8863\u98A8\u683C', 'sheer style underwear'],
  ]);
  addMany(
      'bra',
      'style',
      [
        ['lace', '\u856D\u7D72\u80F8\u7F69\u98A8\u683C', 'lace style bra'],
        [
          'push_up',
          '\u96C6\u4E2D\u578B\u80F8\u7F69\u98A8\u683C',
          'push-up style bra'
        ],
        ['sports', '\u904B\u52D5\u80F8\u7F69\u98A8\u683C', 'sports style bra'],
        [
          'strapless',
          '\u7121\u80A9\u5E36\u80F8\u7F69\u98A8\u683C',
          'strapless bra'
        ],
        [
          'triangle',
          '\u4E09\u89D2\u676F\u80F8\u7F69\u98A8\u683C',
          'triangle style bra'
        ],
        [
          'balconette',
          '\u534A\u676F\u578B\u80F8\u7F69\u98A8\u683C',
          'balconette bra'
        ],
        [
          'racerback',
          '\u5DE5\u5B57\u80CC\u80F8\u7F69\u98A8\u683C',
          'racerback bra'
        ],
      ],
      adult: true);
  addMany(
      'panties',
      'style',
      [
        ['lace', '\u856D\u7D72\u5167\u8932\u98A8\u683C', 'lace style panties'],
        [
          'cotton',
          '\u68C9\u8CEA\u5167\u8932\u98A8\u683C',
          'cotton style panties'
        ],
        [
          'high_waist',
          '\u9AD8\u8170\u5167\u8932\u98A8\u683C',
          'high-waisted panties'
        ],
        [
          'low_rise',
          '\u4F4E\u8170\u5167\u8932\u98A8\u683C',
          'low-rise panties'
        ],
        [
          'boyshort',
          '\u56DB\u89D2\u5167\u8932\u98A8\u683C',
          'boyshort style panties'
        ],
        [
          'cheeky',
          '\u534A\u9732\u81C0\u5167\u8932\u98A8\u683C',
          'cheeky style panties'
        ],
        [
          'side_tie',
          '\u5074\u7D81\u5E36\u5167\u8932\u98A8\u683C',
          'side-tie panties'
        ],
        [
          'crotchless',
          '\u7121\u895F\u5167\u8932\u98A8\u683C',
          'crotchless panties'
        ],
      ],
      adult: true);
  addMany('socks', 'style', [
    [
      'lace',
      '\u856D\u7D72\u9577\u897F\u88DD\u98A8\u683C',
      'lace style stockings'
    ],
    ['ribbed', '\u7F85\u7D0B\u896A\u98A8\u683C', 'ribbed socks'],
    ['striped', '\u689D\u7D0B\u896A\u98A8\u683C', 'striped socks'],
    [
      'thigh_high',
      '\u5927\u817F\u9AD8\u7B52\u896A\u98A8\u683C',
      'thigh-high stockings'
    ],
    ['over_knee', '\u904E\u819D\u896A\u98A8\u683C', 'over-knee socks'],
    ['fishnet', '\u7DB2\u72C0\u896A\u98A8\u683C', 'fishnet stockings'],
    ['garter', '\u540A\u5E36\u896A\u98A8\u683C', 'garter stockings'],
    ['ankle', '\u77ED\u7B52\u896A\u98A8\u683C', 'ankle socks'],
  ]);
  addMany('shoes', 'style', [
    ['sneaker', '\u904B\u52D5\u978B\u98A8\u683C', 'sneaker style shoes'],
    ['high_heel', '\u9AD8\u8DDF\u978B\u98A8\u683C', 'high heel shoes'],
    ['platform', '\u539A\u5E95\u978B\u98A8\u683C', 'platform shoes'],
    ['mary_jane', '\u5A18\u60A3\u978B\u98A8\u683C', 'mary jane shoes'],
    ['ankle_boot', '\u77ED\u9774\u98A8\u683C', 'ankle boot shoes'],
    ['knee_boot', '\u904E\u819D\u9774\u98A8\u683C', 'knee-high boot shoes'],
    ['sandals', '\u6DBC\u978B\u98A8\u683C', 'sandals style shoes'],
    ['loafers', '\u4E50\u798F\u978B\u98A8\u683C', 'loafers'],
  ]);
  addMany('accessory', 'style', [
    [
      'gothic',
      '\u54E5\u5FB7\u5F0F\u914D\u4EF6\u98A8\u683C',
      'gothic accessory'
    ],
    ['punk', '\u9F90\u514B\u914D\u4EF6\u98A8\u683C', 'punk accessory'],
    ['ribbon', '\u7D72\u5E36\u914D\u4EF6\u98A8\u683C', 'ribbon accessory'],
    ['bow', '\u8774\u8776\u7D50\u914D\u4EF6\u98A8\u683C', 'bow accessory'],
    ['lace', '\u856D\u7D72\u914D\u4EF6\u98A8\u683C', 'lace accessory'],
    ['choker', '\u9805\u5708\u914D\u4EF6\u98A8\u683C', 'choker accessory'],
    ['hair', '\u9AEE\u98FE\u914D\u4EF6\u98A8\u683C', 'hair accessory'],
    ['jewelry', '\u73E0\u5BF6\u914D\u4EF6\u98A8\u683C', 'jewelry accessory'],
    ['fluffy', '\u84EC\u9B06\u98A8\u683C', 'fluffy style accessory'],
    ['lifelike', '\u64EC\u771F\u98A8\u683C', 'lifelike style accessory'],
  ]);

  const detailNames = [
    ['lace', '\u856D\u7D72', 'lace'],
    ['frills', '\u8377\u8449\u908A', 'frills'],
    ['ruffles', '\u8936\u908A', 'ruffles'],
    ['ribbon', '\u7D72\u5E36', 'ribbon'],
    ['bow', '\u8774\u8776\u7D50', 'bow'],
    ['see_through', '\u900F\u8996', 'see-through'],
    ['sheer', '\u8584\u7D17', 'sheer'],
    ['buttons', '\u9215\u6263', 'buttons'],
    ['zipper', '\u62C9\u934A', 'zipper'],
    ['cutout', '\u93A4\u7A7A', 'cutout'],
    ['striped', '\u689D\u7D0B', 'striped'],
    ['plaid', '\u683C\u7D0B', 'plaid'],
  ];
  const materialNames = [
    ['satin', '\u7DE0\u9762', 'satin'],
    ['silk', '\u7D72\u7DB8', 'silk'],
    ['knit', '\u91DD\u7E54', 'knit'],
    ['latex', '\u4E73\u81A0', 'latex'],
    ['leather', '\u76AE\u9769', 'leather'],
    ['denim', '\u4E39\u5BE7', 'denim'],
    ['cotton', '\u68C9\u8CEA', 'cotton'],
    ['velvet', '\u5929\u9D5D\u7D68', 'velvet'],
    ['wool', '\u7F8A\u6BDB', 'wool'],
    ['mesh', '\u7DB2\u773C', 'mesh'],
  ];
  const slots = [
    'top',
    'pants',
    'shorts',
    'skirt',
    'onepiece',
    'outerwear',
    'costume',
    'underwear',
    'bra',
    'panties',
    'socks',
    'shoes',
    'accessory',
  ];
  for (final slot in slots) {
    final noun = _clothingScopeNoun(slot);
    for (final detail in detailNames) {
      add(slot, 'detail', detail[0], '${detail[1]}\u7D30\u7BC0',
          '${detail[2]} detail $noun');
    }
    for (final material in materialNames) {
      add(slot, 'material', material[0], '${material[1]}\u6750\u8CEA',
          '${material[2]} material $noun');
    }
    final colorOptions = <List<String>>[
      ..._clothingColors.map((color) => [color[0], color[1], color[0]]),
      ..._clothingColorShades,
    ];
    for (final color in colorOptions) {
      add(slot, 'detail_color', color[0], '${color[1]}\u7D30\u7BC0\u8272',
          '${color[2]} detail color $noun');
    }
  }

  addMany('top', 'wear', [
    [
      'one_sleeve_removed',
      '\u55AE\u624B\u812B\u4E0A\u8863',
      'one sleeve removed'
    ],
  ]);
  addMany('top', 'wear', [
    [
      'off_shoulder',
      '\u8863\u670D\u6ED1\u843D\u5230\u80A9\u4E0B',
      'off-shoulder'
    ],
    [
      'single_off_shoulder',
      '\u55AE\u5074\u8863\u670D\u6ED1\u843D',
      'single off shoulder'
    ],
    ['clothes_pull', '\u624B\u62C9\u8863\u670D', 'clothes pull'],
    ['shirt_pull', '\u624B\u62C9\u896F\u886B', 'shirt pull'],
    ['collar_pull', '\u624B\u62C9\u9818\u53E3', 'collar pull'],
    ['open_shirt', '\u896F\u886B\u657E\u958B', 'open shirt'],
    ['bra_visible', '\u9732\u51FA\u80F8\u7F69', 'bra visible'],
  ]);
  addMany('pants', 'wear', [
    ['down', '\u8932\u5B50\u892A\u4E0B', 'pants down'],
    ['around_ankles', '\u8932\u5B50\u5728\u8173\u8E1D', 'pants around ankles'],
  ]);
  addMany('pants', 'wear', [
    ['pants_pull', '\u624B\u62C9\u8932\u5B50', 'pants pull'],
  ]);
  addMany('skirt', 'wear', [
    ['lifted', '\u88D9\u5B50\u88AB\u63C0\u8D77', 'skirt lifted'],
    [
      'around_one_leg',
      '\u88D9\u5B50\u7E8F\u5728\u55AE\u8173',
      'skirt around one leg'
    ],
    ['down', '\u88D9\u5B50\u892A\u4E0B', 'skirt down'],
  ]);
  addMany('skirt', 'wear', [
    ['skirt_pull', '\u624B\u62C9\u88D9\u5B50', 'skirt pull'],
  ]);
  addMany('onepiece', 'wear', [
    [
      'one_shoulder_removed',
      '\u55AE\u80A9\u812B\u843D',
      'one shoulder removed'
    ],
    ['lifted', '\u9023\u8EAB\u88DD\u88AB\u63C0\u8D77', 'dress lifted'],
  ]);
  addMany('underwear', 'wear', [
    ['open', '\u6253\u958B\u5167\u8863', 'open underwear'],
    [
      'half_removed',
      '\u5167\u8863\u812B\u4E00\u534A',
      'half-removed underwear'
    ],
    [
      'one_strap_removed',
      '\u55AE\u908A\u80A9\u5E36\u812B\u843D',
      'one strap removed'
    ],
    ['down', '\u5167\u8863\u892A\u4E0B', 'underwear down'],
    ['removed', '\u8131\u6389\u5167\u8863', 'underwear removed'],
  ]);
  addMany(
      'bra',
      'wear',
      [
        ['lift', '\u63C0\u8D77\u80F8\u7F69', 'bra lift'],
        ['half_removed', '\u80F8\u7F69\u812B\u4E00\u534A', 'half-removed bra'],
        [
          'one_strap_removed',
          '\u55AE\u908A\u80A9\u5E36\u812B\u843D',
          'one bra strap removed'
        ],
        [
          'around_one_arm',
          '\u80F8\u7F69\u7E8F\u5728\u55AE\u81C2',
          'bra around one arm'
        ],
        [
          'pulled_aside',
          '\u80F8\u7F69\u88AB\u62C9\u5230\u65C1\u908A',
          'bra pulled aside'
        ],
        ['removed', '\u8131\u6389\u80F8\u7F69', 'bra removed'],
      ],
      adult: true);
  addMany(
      'panties',
      'wear',
      [
        ['down', '\u5167\u8932\u892A\u4E0B', 'panties down'],
        [
          'half_removed',
          '\u5167\u8932\u812B\u4E00\u534A',
          'half-removed panties'
        ],
        [
          'around_one_leg',
          '\u5167\u8932\u7E8F\u5728\u55AE\u8173',
          'panties around one leg'
        ],
        [
          'pulled_aside',
          '\u5167\u8932\u88AB\u62C9\u5230\u65C1\u908A',
          'panties pulled aside'
        ],
        ['removed', '\u8131\u6389\u5167\u8932', 'panties removed'],
      ],
      adult: true);
  addMany(
      'panties',
      'wear',
      [
        ['panties_visible', '\u9732\u51FA\u5167\u8932', 'panties visible'],
        ['waistband', '\u9732\u51FA\u5167\u8932\u8932\u982D', 'waistband'],
      ],
      adult: true);
  addMany('socks', 'wear', [
    ['down', '\u896A\u5B50\u892A\u4E0B', 'socks down'],
    ['one_removed', '\u55AE\u96BB\u896A\u5B50\u812B\u843D', 'one sock removed'],
    ['thighhighs_down', '\u9577\u7B52\u896A\u892A\u4E0B', 'thighhighs down'],
    ['pulled_down', '\u896A\u5B50\u88AB\u62C9\u4E0B', 'stockings pulled down'],
    ['around_ankles', '\u896A\u5B50\u5728\u8173\u8E1D', 'socks around ankles'],
    ['removed', '\u8131\u6389\u896A\u5B50', 'socks removed'],
  ]);
  addMany('shoes', 'wear', [
    ['one_removed', '\u55AE\u96BB\u978B\u812B\u843D', 'one shoe removed'],
    ['removed', '\u978B\u5B50\u812B\u843D', 'shoes removed'],
    ['shoeless', '\u8D64\u8173', 'shoeless'],
    ['on_floor', '\u978B\u5B50\u6389\u5728\u65C1\u908A', 'shoes on floor'],
    ['holding', '\u624B\u62FF\u978B\u5B50', 'holding shoes'],
    ['untied', '\u978B\u5E36\u89E3\u958B', 'untied shoelaces'],
    ['one_foot_out', '\u55AE\u8173\u812B\u978B', 'one foot out'],
  ]);
  addMany('accessory', 'wear', [
    ['removed', '\u914D\u4EF6\u812B\u843D', 'accessory removed'],
    [
      'one_removed',
      '\u55AE\u4EF6\u914D\u4EF6\u812B\u843D',
      'one accessory removed'
    ],
    ['holding', '\u624B\u62FF\u914D\u4EF6', 'holding accessory'],
    ['on_floor', '\u914D\u4EF6\u6389\u5728\u65C1\u908A', 'accessory on floor'],
    [
      'one_earring_removed',
      '\u55AE\u908A\u8033\u74B0\u812B\u843D',
      'one earring removed'
    ],
    ['choker_removed', '\u9805\u5708\u812B\u843D', 'choker removed'],
    ['gloves_removed', '\u624B\u5957\u812B\u843D', 'gloves removed'],
    [
      'putting_on',
      '\u6B63\u5728\u6234\u4E0A\u914D\u4EF6',
      'putting on accessory'
    ],
  ]);

  return tags;
}

const _clothingColors = <List<String>>[
  ['black', '\u9ED1\u8272'],
  ['white', '\u767D\u8272'],
  ['red', '\u7D05\u8272'],
  ['blue', '\u85CD\u8272'],
  ['pink', '\u7C89\u7D05\u8272'],
  ['purple', '\u7D2B\u8272'],
  ['green', '\u7DA0\u8272'],
  ['yellow', '\u9EC3\u8272'],
  ['brown', '\u68D5\u8272'],
  ['gray', '\u7070\u8272'],
  ['gold', '\u91D1\u8272'],
  ['silver', '\u9280\u8272'],
  ['orange', '\u6A59\u8272'],
  ['multicolored', '\u591A\u5F69'],
];

// Prompt colour words are more useful to the model than arbitrary HEX codes.
// The shade names below are also used to compose a single clothing tag.
const _clothingColorShades = <List<String>>[
  ['aqua', '\u6C34\u85CD\u8272', 'aqua'],
  ['light_blue', '\u6DFA\u85CD\u8272', 'light blue'],
  ['dark_blue', '\u6DF1\u85CD\u8272', 'dark blue'],
  ['navy', '\u6D77\u8ECD\u85CD', 'navy'],
  ['navy_blue_black', '\u6DF1\u85CD\u9ED1\u8272', 'navy blue-black'],
  ['sky_blue', '\u5929\u85CD\u8272', 'sky blue'],
  ['pastel_blue', '\u7C89\u5F69\u85CD', 'pastel blue'],
  ['royal_blue', '\u5BF6\u85CD\u8272', 'royal blue'],
  ['azure', '\u851A\u85CD\u8272', 'azure'],
  ['cobalt_blue', '\u9264\u85CD\u8272', 'cobalt blue'],
  ['sapphire_blue', '\u5BF6\u77F3\u85CD', 'sapphire blue'],
  ['steel_blue', '\u92FC\u85CD\u8272', 'steel blue'],
  ['midnight_blue', '\u5348\u591C\u85CD', 'midnight blue'],
  ['powder_blue', '\u7C89\u85CD', 'powder blue'],
  ['turquoise', '\u7DA0\u677E\u77F3\u8272', 'turquoise'],
  ['teal', '\u85CD\u7DA0\u8272', 'teal'],
  ['light_red', '\u6DFA\u7D05\u8272', 'light red'],
  ['dark_red', '\u6DF1\u7D05\u8272', 'dark red'],
  ['crimson', '\u6DF1\u7D05\u8272', 'crimson'],
  ['scarlet', '\u7336\u7D05\u8272', 'scarlet'],
  ['maroon', '\u6817\u8272', 'maroon'],
  ['burgundy', '\u9152\u7D05\u8272', 'burgundy'],
  ['wine_red', '\u9152\u7D05\u8272', 'wine red'],
  ['coral', '\u73CA\u745A\u8272', 'coral'],
  ['light_green', '\u6DFA\u7DA0\u8272', 'light green'],
  ['dark_green', '\u6DF1\u7DA0\u8272', 'dark green'],
  ['lime', '\u840A\u59C6\u7DA0', 'lime'],
  ['mint_green', '\u8584\u8377\u7DA0', 'mint green'],
  ['emerald_green', '\u7FE0\u7DA0\u8272', 'emerald green'],
  ['jade_green', '\u7389\u7DA0\u8272', 'jade green'],
  ['forest_green', '\u68EE\u6797\u7DA0', 'forest green'],
  ['olive', '\u6A44\u6B16\u7DA0', 'olive'],
  ['sage_green', '\u9F20\u5C3E\u8349\u7DA0', 'sage green'],
  ['light_yellow', '\u6DFA\u9EC3\u8272', 'light yellow'],
  ['dark_yellow', '\u6DF1\u9EC3\u8272', 'dark yellow'],
  ['lemon_yellow', '\u6AB8\u6AAC\u9EC3', 'lemon yellow'],
  ['mustard_yellow', '\u82A5\u672B\u9EC3', 'mustard yellow'],
  ['golden', '\u91D1\u9EC3\u8272', 'golden'],
  ['amber', '\u7425\u73C0\u8272', 'amber'],
  ['peach', '\u871C\u6843\u8272', 'peach'],
  ['salmon', '\u9BDB\u9B5A\u7C89', 'salmon'],
  ['lavender', '\u85B0\u8863\u8349\u7D2B', 'lavender'],
  ['lilac', '\u6DE1\u7D2B\u8272', 'lilac'],
  ['magenta', '\u6D0B\u7D05\u8272', 'magenta'],
  ['hot_pink', '\u6843\u7D05\u8272', 'hot pink'],
  ['light_pink', '\u6DFA\u7C89\u7D05\u8272', 'light pink'],
  ['dark_pink', '\u6DF1\u7C89\u7D05\u8272', 'dark pink'],
  ['rose', '\u73AB\u7470\u8272', 'rose'],
  ['light_gray', '\u6DFA\u7070\u8272', 'light gray'],
  ['dark_gray', '\u6DF1\u7070\u8272', 'dark gray'],
  ['slate_gray', '\u77F3\u677F\u7070', 'slate gray'],
  ['pewter', '\u932B\u7070\u8272', 'pewter'],
  ['charcoal', '\u70AD\u7070\u8272', 'charcoal'],
  ['jet_black', '\u70CF\u9ED1\u8272', 'jet black'],
  ['ebony', '\u70CF\u6728\u9ED1', 'ebony'],
  ['off_black', '\u8FD1\u9ED1\u8272', 'off-black'],
  ['ivory', '\u8C61\u7259\u767D', 'ivory'],
  ['cream', '\u5976\u6CB9\u8272', 'cream'],
  ['beige', '\u7C73\u8272', 'beige'],
  ['light_brown', '\u6DFA\u8910\u8272', 'light brown'],
  ['dark_brown', '\u6DF1\u8910\u8272', 'dark brown'],
  ['coffee', '\u5496\u5561\u8272', 'coffee'],
  ['tan', '\u8910\u8272', 'tan'],
  ['camel', '\u99DD\u8272', 'camel'],
  ['chocolate', '\u5DE7\u514B\u529B\u8272', 'chocolate'],
  ['chestnut', '\u6817\u68D5\u8272', 'chestnut'],
  ['khaki', '\u5361\u5176\u8272', 'khaki'],
  ['taupe', '\u7070\u8910\u8272', 'taupe'],
  ['copper', '\u9285\u8272', 'copper'],
  ['rose_gold', '\u73AB\u7470\u91D1', 'rose gold'],
];

List<List<String>> _allClothingColorOptions() {
  final options = <List<String>>[];
  final seen = <String>{};
  for (final color in _clothingColors) {
    if (seen.add(color[0])) {
      options.add([color[0], color[1], color[0]]);
    }
  }
  for (final color in _clothingColorShades) {
    if (seen.add(color[0])) options.add(color);
  }
  return options;
}

const _promptColorChinese = <String, String>{
  'multicolored': '\u591A\u5F69',
  'black': '\u9ED1\u8272',
  'white': '\u767D\u8272',
  'red': '\u7D05\u8272',
  'blue': '\u85CD\u8272',
  'aqua': '\u6C34\u85CD\u8272',
  'pink': '\u7C89\u7D05\u8272',
  'purple': '\u7D2B\u8272',
  'green': '\u7DA0\u8272',
  'yellow': '\u9EC3\u8272',
  'brown': '\u68D5\u8272',
  'gray': '\u7070\u8272',
  'gold': '\u91D1\u8272',
  'silver': '\u9280\u8272',
  'orange': '\u6A59\u8272',
  'blonde': '\u91D1\u8272',
  'light blue': '\u6DFA\u85CD\u8272',
  'dark blue': '\u6DF1\u85CD\u8272',
  'navy': '\u6D77\u8ECD\u85CD',
  'navy blue-black': '\u6DF1\u85CD\u9ED1\u8272',
  'sky blue': '\u5929\u85CD\u8272',
  'pastel blue': '\u7C89\u5F69\u85CD',
  'royal blue': '\u5BF6\u85CD\u8272',
  'azure': '\u851A\u85CD\u8272',
  'cobalt blue': '\u9264\u85CD\u8272',
  'sapphire blue': '\u5BF6\u77F3\u85CD',
  'steel blue': '\u92FC\u85CD\u8272',
  'midnight blue': '\u5348\u591C\u85CD',
  'powder blue': '\u7C89\u85CD',
  'turquoise': '\u7DA0\u677E\u77F3\u8272',
  'teal': '\u85CD\u7DA0\u8272',
  'light red': '\u6DFA\u7D05\u8272',
  'dark red': '\u6DF1\u7D05\u8272',
  'crimson': '\u6DF1\u7D05\u8272',
  'scarlet': '\u7336\u7D05\u8272',
  'maroon': '\u6817\u8272',
  'burgundy': '\u9152\u7D05\u8272',
  'wine red': '\u9152\u7D05\u8272',
  'coral': '\u73CA\u745A\u8272',
  'light green': '\u6DFA\u7DA0\u8272',
  'dark green': '\u6DF1\u7DA0\u8272',
  'lime': '\u840A\u59C6\u7DA0',
  'mint green': '\u8584\u8377\u7DA0',
  'emerald green': '\u7FE0\u7DA0\u8272',
  'jade green': '\u7389\u7DA0\u8272',
  'forest green': '\u68EE\u6797\u7DA0',
  'olive': '\u6A44\u6B16\u7DA0',
  'sage green': '\u9F20\u5C3E\u8349\u7DA0',
  'light yellow': '\u6DFA\u9EC3\u8272',
  'dark yellow': '\u6DF1\u9EC3\u8272',
  'lemon yellow': '\u6AB8\u6AAC\u9EC3',
  'mustard yellow': '\u82A5\u672B\u9EC3',
  'golden': '\u91D1\u9EC3\u8272',
  'amber': '\u7425\u73C0\u8272',
  'peach': '\u871C\u6843\u8272',
  'salmon': '\u9BDB\u9B5A\u7C89',
  'lavender': '\u85B0\u8863\u8349\u7D2B',
  'lilac': '\u6DE1\u7D2B\u8272',
  'magenta': '\u6D0B\u7D05\u8272',
  'hot pink': '\u6843\u7D05\u8272',
  'light pink': '\u6DFA\u7C89\u7D05\u8272',
  'dark pink': '\u6DF1\u7C89\u7D05\u8272',
  'rose': '\u73AB\u7470\u8272',
  'light gray': '\u6DFA\u7070\u8272',
  'dark gray': '\u6DF1\u7070\u8272',
  'charcoal': '\u70AD\u7070\u8272',
  'ivory': '\u8C61\u7259\u767D',
  'cream': '\u5976\u6CB9\u8272',
  'beige': '\u7C73\u8272',
  'slate gray': '\u77F3\u677F\u7070',
  'pewter': '\u932B\u7070\u8272',
  'jet black': '\u70CF\u9ED1\u8272',
  'ebony': '\u70CF\u6728\u9ED1',
  'off-black': '\u8FD1\u9ED1\u8272',
  'light brown': '\u6DFA\u8910\u8272',
  'dark brown': '\u6DF1\u8910\u8272',
  'coffee': '\u5496\u5561\u8272',
  'tan': '\u8910\u8272',
  'camel': '\u99DD\u8272',
  'chocolate': '\u5DE7\u514B\u529B\u8272',
  'chestnut': '\u6817\u68D5\u8272',
  'khaki': '\u5361\u5176\u8272',
  'taupe': '\u7070\u8910\u8272',
  'copper': '\u9285\u8272',
  'rose gold': '\u73AB\u7470\u91D1',
};

const _promptColorValues = <String, Color>{
  'black': Color(0xff17171c),
  'white': Color(0xfff5f5f5),
  'red': Color(0xffe5484d),
  'blue': Color(0xff3b82f6),
  'aqua': Color(0xff22d3ee),
  'pink': Color(0xffec4899),
  'purple': Color(0xff8b5cf6),
  'green': Color(0xff22c55e),
  'yellow': Color(0xfffacc15),
  'brown': Color(0xff925f38),
  'gray': Color(0xff9ca3af),
  'gold': Color(0xffd4a72c),
  'silver': Color(0xffcbd5e1),
  'orange': Color(0xfff97316),
  'blonde': Color(0xffffd166),
  'light blue': Color(0xff7dd3fc),
  'dark blue': Color(0xff1d4ed8),
  'navy': Color(0xff1e3a8a),
  'navy blue-black': Color(0xff19213d),
  'sky blue': Color(0xff38bdf8),
  'pastel blue': Color(0xff93c5fd),
  'royal blue': Color(0xff4169e1),
  'azure': Color(0xff007fff),
  'cobalt blue': Color(0xff0047ab),
  'sapphire blue': Color(0xff0f52ba),
  'steel blue': Color(0xff4682b4),
  'midnight blue': Color(0xff191970),
  'powder blue': Color(0xffb0e0e6),
  'turquoise': Color(0xff14b8a6),
  'teal': Color(0xff0f766e),
  'light red': Color(0xfff87171),
  'dark red': Color(0xffb91c1c),
  'crimson': Color(0xffdc143c),
  'scarlet': Color(0xffff2400),
  'maroon': Color(0xff800000),
  'burgundy': Color(0xff800020),
  'wine red': Color(0xff722f37),
  'coral': Color(0xffff7f50),
  'light green': Color(0xff86efac),
  'dark green': Color(0xff166534),
  'lime': Color(0xff84cc16),
  'mint green': Color(0xff6ee7b7),
  'emerald green': Color(0xff10b981),
  'jade green': Color(0xff00a86b),
  'forest green': Color(0xff228b22),
  'olive': Color(0xff808000),
  'sage green': Color(0xff9caf88),
  'light yellow': Color(0xfffef08a),
  'dark yellow': Color(0xffca8a04),
  'lemon yellow': Color(0xfffff44f),
  'mustard yellow': Color(0xffffdb58),
  'golden': Color(0xffffd700),
  'amber': Color(0xffffbf00),
  'peach': Color(0xffffcba4),
  'salmon': Color(0xfffa8072),
  'lavender': Color(0xffc4b5fd),
  'lilac': Color(0xffc8a2c8),
  'magenta': Color(0xffff00ff),
  'hot pink': Color(0xffff69b4),
  'light pink': Color(0xfff9a8d4),
  'dark pink': Color(0xffbe185d),
  'rose': Color(0xffff007f),
  'light gray': Color(0xffd1d5db),
  'dark gray': Color(0xff4b5563),
  'charcoal': Color(0xff36454f),
  'ivory': Color(0xfffffff0),
  'cream': Color(0xfffffdd0),
  'beige': Color(0xfff5f5dc),
  'slate gray': Color(0xff708090),
  'pewter': Color(0xff899499),
  'jet black': Color(0xff0a0a0a),
  'ebony': Color(0xff282c35),
  'off-black': Color(0xff202124),
  'light brown': Color(0xffb5651d),
  'dark brown': Color(0xff5c4033),
  'coffee': Color(0xff6f4e37),
  'tan': Color(0xffd2b48c),
  'camel': Color(0xffc19a6b),
  'chocolate': Color(0xff7b3f00),
  'chestnut': Color(0xff954535),
  'khaki': Color(0xffc3b091),
  'taupe': Color(0xff483c32),
  'copper': Color(0xffb87333),
  'rose gold': Color(0xffb76e79),
};

List<TagItem> _clothingColorTags(
  String prefix,
  String group,
  String zhSuffix,
  String enSuffix,
  String conflictGroup, {
  bool adult = false,
}) {
  return _clothingColors
      .map((color) => _tag(
            '${prefix}_${color[0]}',
            group,
            '${color[1]}$zhSuffix',
            '${color[0]} $enSuffix',
            2,
            adult: adult,
            conflictGroup: conflictGroup,
          ))
      .toList();
}

List<TagItem> _missingLegacyClothingColorTags() {
  const existingColors = <String>{
    'black',
    'white',
    'red',
    'blue',
    'pink',
    'purple',
    'green',
    'yellow',
    'multicolored',
  };
  return _clothingColors
      .where((color) => !existingColors.contains(color[0]))
      .map((color) => _tag(
            'clothing_color_${color[0]}',
            '服裝顏色',
            '${color[1]}服裝',
            '${color[0]} clothing',
            2,
            conflictGroup: 'clothing_color',
          ))
      .toList();
}

List<TagItem> _eyeColorTags() {
  const legacyIds = <String, String>{
    'green': 'trait_green_eyes',
    'blue': 'trait_blue_eyes',
    'red': 'trait_red_eyes',
    'purple': 'trait_purple_eyes',
  };
  return _clothingColors
      .map((color) => _tag(
            legacyIds[color[0]] ?? 'eye_color_${color[0]}',
            '眼睛',
            '${color[1]}眼睛',
            '${color[0]} eyes',
            2,
            conflictGroup: 'eye_color',
          ))
      .toList();
}

List<TagItem> _clothingColorShadeTags(
  String prefix,
  String group,
  String zhSuffix,
  String enSuffix,
  String conflictGroup, {
  bool adult = false,
}) {
  return _clothingColorShades
      .map((color) => _tag(
            '${prefix}_${color[0]}',
            group,
            '${color[1]}$zhSuffix',
            '${color[2]} $enSuffix',
            2,
            adult: adult,
            conflictGroup: conflictGroup,
          ))
      .toList();
}

List<TagItem> _clothingTrimColorTags(
  String prefix,
  String group,
  String zhSuffix,
  String conflictGroup,
) {
  final options = _allClothingColorOptions();
  final secondarySuffix =
      zhSuffix == '\u908A\u7DDA' ? '\u6B21\u8272' : zhSuffix;
  return options
      .map((color) => _tag(
            '${prefix}_${color[0]}',
            group,
            '${color[1]}$secondarySuffix',
            '${color[2]} trim',
            2,
            conflictGroup: conflictGroup,
          ))
      .toList();
}

List<TagItem> _extraFeaturePositionTags() => [
      _tag('extra_position_face', '額外特徵位置', '臉上', 'on face', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_forehead', '額外特徵位置', '額頭上', 'on forehead', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_cheek', '額外特徵位置', '臉頰上', 'on cheek', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_eyes', '額外特徵位置', '眼睛周圍', 'around eyes', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_lips', '額外特徵位置', '嘴唇上', 'on lips', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_ear', '額外特徵位置', '耳朵上', 'on ear', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_head', '額外特徵位置', '頭上', 'on head', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_hair', '額外特徵位置', '頭髮上', 'in hair', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_neck', '額外特徵位置', '脖子上', 'around neck', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_chest', '額外特徵位置', '胸口上', 'on chest', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_shoulder', '額外特徵位置', '肩膀上', 'on shoulder', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_arm', '額外特徵位置', '手臂上', 'on arm', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_wrist', '額外特徵位置', '手腕上', 'on wrist', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_hand', '額外特徵位置', '手上', 'on hand', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_finger', '額外特徵位置', '手指上', 'on finger', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_waist', '額外特徵位置', '腰部', 'on waist', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_back', '額外特徵位置', '背部上', 'on back', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_thigh', '額外特徵位置', '大腿上', 'on thigh', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_leg', '額外特徵位置', '腿上', 'on leg', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_ankle', '額外特徵位置', '腳踝上', 'on ankle', 1,
          conflictGroup: 'extra_feature_position'),
      _tag('extra_position_foot', '額外特徵位置', '腳上', 'on foot', 1,
          conflictGroup: 'extra_feature_position'),
    ];

List<TagItem> _extraFeatureColorTags() => [
      ..._clothingColorTags('extra_feature_color', '額外特徵顏色', '特徵', 'feature',
          'extra_feature_color'),
      ..._clothingColorShadeTags('extra_feature_shade_color', '額外特徵顏色', '特徵',
          'feature', 'extra_feature_color'),
    ];

List<TagItem> _accessoryPositionTags() => _extraFeaturePositionTags()
    .map((tag) => TagItem(
          id: tag.id.replaceFirst('extra_position_', 'accessory_position_'),
          group: '配件位置',
          zh: tag.zh,
          en: tag.en,
          order: 2,
          conflictGroup: 'accessory_position',
        ))
    .toList();

List<TagItem> _hairColorShadeTags() {
  return _clothingColorShades
      .map((color) => _tag(
            'trait_${color[0]}_hair',
            '\u9AEE\u8272',
            '${color[1]}\u9AEE',
            '${color[2]} hair',
            1,
            conflictGroup: 'hair_color',
          ))
      .toList();
}

List<TagItem> _wingColorTags() => [
      ..._clothingColorTags(
          'wing_color', _wingColorGroup, '翅膀', 'wings', 'wing_color'),
      ..._clothingColorShadeTags(
          'wing_shade_color', _wingColorGroup, '翅膀', 'wings', 'wing_color'),
    ];

List<TagItem> _animalTraitColorTags() => [
      ..._clothingColorTags('animal_ear_color', _animalEarColorGroup, '獸耳',
          'animal ears', 'animal_ear_color'),
      ..._clothingColorShadeTags('animal_ear_shade_color', _animalEarColorGroup,
          '獸耳', 'animal ears', 'animal_ear_color'),
      ..._clothingColorTags('animal_tail_color', _animalTailColorGroup, '獸尾',
          'animal tail', 'animal_tail_color'),
      ..._clothingColorShadeTags('animal_tail_shade_color',
          _animalTailColorGroup, '獸尾', 'animal tail', 'animal_tail_color'),
      ..._clothingColorTags('animal_hand_color', _animalHandColorGroup, '獸手',
          'animal hands', 'animal_hand_color'),
      ..._clothingColorShadeTags('animal_hand_shade_color',
          _animalHandColorGroup, '獸手', 'animal hands', 'animal_hand_color'),
      ..._clothingColorTags('animal_foot_color', _animalFootColorGroup, '獸足',
          'animal feet', 'animal_foot_color'),
      ..._clothingColorShadeTags('animal_foot_shade_color',
          _animalFootColorGroup, '獸足', 'animal feet', 'animal_foot_color'),
    ];

List<TagItem> _expandedHairStyleTags() {
  const definitions = <List<String>>[
    ['hime_cut', '公主切', 'hime cut'],
    ['wolf_cut', '狼尾剪', 'wolf cut'],
    ['jellyfish_cut', '水母頭', 'jellyfish cut'],
    ['buzz_cut', '寸頭', 'buzz cut'],
    ['crew_cut', '平頭短髮', 'crew cut'],
    ['undercut', '底層剃短髮', 'undercut'],
    ['short_hair_long_locks', '短髮配長髮束', 'cropped hair with long locks'],
    ['front_braid', '前額辮', 'front braid'],
    ['half_crown_braid', '半皇冠辮', 'half crown braid'],
    ['low_twin_braids', '低雙辮', 'low twin braids'],
    ['cornrows', '貼頭辮', 'cornrows'],
    ['dreadlocks', '雷鬼辮', 'dreadlocks'],
    ['box_braids', '方格辮', 'box braids'],
    ['half_up_braid', '半扎辮髮', 'half up braid'],
    ['half_up_half_down_braid', '半扎半放辮髮', 'half up half down braid'],
    ['single_hair_bun', '單髮髻', 'single hair bun'],
    ['very_low_bun', '超低髮髻', 'very low bun'],
    ['heart_hair_bun', '愛心髮髻', 'heart hair bun'],
    ['hair_rings', '環狀髮髻', 'hair rings'],
    ['half_updo', '半盤髮', 'half updo'],
    ['one_side_up', '單側束髮', 'one side up'],
    ['two_side_up', '雙側束髮', 'two side up'],
    ['folded_ponytail', '折疊馬尾', 'folded ponytail'],
    ['short_ponytail', '短馬尾', 'bob-length ponytail'],
    ['high_side_ponytail', '高側馬尾', 'high side ponytail'],
    ['uneven_twintails', '不等長雙馬尾', 'uneven twintails'],
    ['beehive_hairdo', '蜂巢高髮髻', 'beehive hairdo'],
    ['quiff', '前額高梳髮', 'quiff'],
    ['fluffy_hair', '蓬鬆髮', 'fluffy hair'],
    ['choppy_bangs', '碎剪瀏海', 'choppy bangs'],
    ['diagonal_bangs', '斜瀏海', 'diagonal bangs'],
    ['fanged_bangs', '尖牙狀瀏海', 'fanged bangs'],
    ['parted_bangs', '分線瀏海', 'parted bangs'],
    ['middle_part', '中分', 'middle part'],
    ['curtained_hair', '窗簾式分髮', 'curtained hair'],
    ['swept_bangs', '側掃瀏海', 'swept bangs'],
    ['sidelocks', '鬢髮', 'sidelocks'],
    ['asymmetrical_sidelocks', '不對稱鬢髮', 'asymmetrical sidelocks'],
    ['drill_sidelocks', '鑽頭捲鬢髮', 'drill sidelocks'],
    ['heart_ahoge', '愛心呆毛', 'heart ahoge'],
    ['huge_ahoge', '大型呆毛', 'huge ahoge'],
    ['hair_pulled_back', '頭髮向後束起', 'hair pulled back'],
    ['alternate_hairstyle', '替代髮型', 'alternate hairstyle'],
    ['hair_down', '頭髮放下', 'hair down'],
    ['hair_up', '頭髮盤起', 'hair up'],
    ['asymmetrical_hair', '不對稱髮型', 'asymmetrical hair'],
    ['sidecut', '側邊剃髮', 'sidecut'],
    ['blunt_ends', '髮尾齊切', 'blunt ends'],
    ['asymmetrical_bob', '不對稱短髮', 'asymmetrical bob'],
    ['blunt_bob', '齊切短髮', 'blunt bob'],
    ['layered_long_hair', '層次長髮', 'layered long hair'],
    ['feathered_hair', '羽毛剪', 'feathered hair'],
    ['shaggy_hair', '碎剪長髮', 'shaggy hair'],
    ['fluffy_long_hair', '蓬鬆長髮', 'fluffy long hair'],
    ['fluffy_short_hair', '蓬鬆短髮', 'fluffy bob cut'],
    ['side_parted_hair', '側分長髮', 'side-parted hair'],
    ['center_parted_hair', '中分長髮', 'center-parted hair'],
    ['slicked_back_hair', '後梳髮', 'hair slicked back'],
    ['half_up_hair', '半扎髮', 'half-up hair'],
    ['half_up_bun', '半丸子頭', 'half-up bun'],
    ['half_ponytail', '半馬尾', 'half ponytail'],
    ['half_up_half_down', '公主半扎髮', 'half-up half-down hair'],
    ['double_side_buns', '雙側髮髻', 'double side buns'],
    ['high_twintails', '高雙馬尾', 'high twintails'],
    ['very_low_twintails', '超低雙馬尾', 'very low twintails'],
    ['low_side_ponytail', '單側低馬尾', 'low side ponytail'],
    ['bubble_ponytail', '泡泡馬尾', 'bubble ponytail'],
    ['bubble_twintails', '雙泡泡馬尾', 'bubble twintails'],
    ['braided_ponytail', '編織馬尾', 'braided ponytail'],
    ['braided_twintails', '雙編織馬尾', 'braided twintails'],
    ['crown_braid', '皇冠辮', 'crown braid'],
    ['dutch_braid', '荷蘭辮', 'dutch braid'],
    ['fishtail_braid', '魚骨辮', 'fishtail braid'],
    ['waterfall_braid', '瀑布辮', 'waterfall braid'],
    ['rope_braid', '麻花側辮', 'rope braid'],
    ['halo_braid', '環狀辮', 'halo braid'],
    ['braided_bun', '辮子髮髻', 'braided bun'],
    ['double_braided_buns', '雙辮髮髻', 'double braided buns'],
    ['side_swept_hair', '側梳長髮', 'side-swept hair'],
    ['hair_over_one_eye', '單側遮眼髮', 'hair over one eye'],
    ['hair_over_eyes', '遮雙眼瀏海', 'hair over eyes'],
    ['long_sidelocks', '長鬢角', 'long sidelocks'],
    ['short_sidelocks', '短鬢角', 'cropped sidelocks'],
    ['antenna_hair', '天線髮', 'antenna hair'],
    ['two_ahoge', '雙呆毛', 'two ahoge'],
    ['flipped_out_hair', '外翹髮尾', 'flipped hair'],
    ['inward_curled_hair', '內彎髮尾', 'inward curled hair'],
    ['big_wavy_hair', '大波浪長髮', 'big wavy hair'],
    ['spiral_curls', '螺旋捲長髮', 'spiral curls'],
    ['loose_curls', '鬆散捲髮', 'loose curls'],
    ['afro', '爆炸捲', 'afro'],
    ['voluminous_curly_hair', '蓬鬆捲髮', 'voluminous curly hair'],
    ['wet_hair', '濕髮感', 'wet hair'],
    ['messy_long_hair', '凌亂長髮', 'messy long hair'],
    ['hime_bob', '姬鮑伯', 'hime bob'],
    ['bowl_cut', '蘑菇頭', 'bowl cut'],
    ['pageboy_cut', '頁童頭', 'pageboy cut'],
    ['a_line_bob', 'A字鮑伯', 'A-line bob'],
    ['inverted_bob', '倒V鮑伯', 'inverted bob'],
    ['long_bob', '長鮑伯', 'long bob'],
    ['choppy_bob', '碎剪鮑伯', 'choppy bob'],
    ['french_bob', '法式鮑伯', 'French bob'],
    ['wolf_bob', '狼尾鮑伯', 'wolf bob'],
    ['mullet', '現代狼尾／鯔魚頭', 'mullet'],
    ['butterfly_cut', '蝴蝶層次剪', 'butterfly cut'],
    ['octopus_cut', '章魚剪', 'octopus cut'],
    ['shag_cut', '層次碎剪', 'shag cut'],
    ['razor_cut', '刀削感層次髮', 'razor cut'],
    ['v_cut_hair', 'V字長髮', 'V-cut hair'],
    ['u_cut_hair', 'U字長髮', 'U-cut hair'],
    ['princess_hair', '公主長髮', 'princess hair'],
    ['bouffant_hair', '高蓬髮型', 'bouffant hair'],
    ['beehive_hair', '蜂巢高髮髻（舊描述）', 'beehive hair'],
    ['pompadour', '龐巴度髮型', 'pompadour'],
    ['victory_rolls', '復古勝利捲', 'victory rolls'],
    ['finger_waves', '手指波浪捲', 'finger waves'],
    ['retro_curls', '復古大捲髮', 'retro curls'],
    ['hollywood_waves', '好萊塢波浪髮', 'Hollywood waves'],
    ['ringlets', '小螺旋捲', 'ringlets'],
    ['sausage_curls', '大筒狀捲髮', 'sausage curls'],
    ['twin_drills', '雙鑽頭捲', 'twin drills'],
    ['side_drills', '側邊鑽頭捲', 'side drills'],
    ['curled_sidelocks', '捲曲鬢髮', 'curled sidelocks'],
    ['braided_bangs', '編辮瀏海', 'braided bangs'],
    ['twisted_bangs', '扭轉瀏海', 'twisted bangs'],
    ['side_swept_bangs', '側掃瀏海', 'side-swept bangs'],
    ['curtain_bangs', '八字／窗簾瀏海', 'curtain bangs'],
    ['see_through_bangs', '空氣瀏海', 'see-through bangs'],
    ['wispy_bangs', '碎薄瀏海', 'wispy bangs'],
    ['blunt_bangs', '厚齊瀏海', 'blunt bangs'],
    ['arched_bangs', '弧形瀏海', 'arched bangs'],
    ['asymmetrical_bangs', '不對稱瀏海', 'asymmetrical bangs'],
    ['long_bangs', '長瀏海', 'long bangs'],
    ['short_bangs', '短瀏海', 'cropped bangs'],
    ['micro_bangs', '超短瀏海', 'micro bangs'],
    ['braided_headband', '辮子髮箍', 'braided headband'],
    ['milkmaid_braid', '牛奶女工辮', 'milkmaid braid'],
    ['gibson_tuck', '吉布森盤髮', 'Gibson tuck'],
    ['french_twist', '法式盤髮', 'French twist'],
    ['chignon', '低盤髮', 'chignon'],
    ['side_chignon', '側邊盤髮', 'side chignon'],
    ['messy_bun', '凌亂丸子頭', 'messy bun'],
    ['space_buns', '雙太空包頭', 'space buns'],
    ['heart_shaped_buns', '愛心雙髮髻（描述）', 'heart-shaped buns'],
    ['bow_shaped_hair', '蝴蝶結髮型', 'bow-shaped hair'],
    ['looped_ponytail', '環狀馬尾', 'looped ponytail'],
    ['looped_twintails', '環狀雙馬尾', 'looped twintails'],
    ['segmented_ponytail', '分節馬尾', 'segmented ponytail'],
    ['side_loop_braid', '側邊環狀辮', 'side loop braid'],
    ['four_strand_braid', '四股辮', 'four-strand braid'],
    ['five_strand_braid', '五股辮', 'five-strand braid'],
    ['lace_braid', '蕾絲辮', 'lace braid'],
    ['snake_braid', '蛇形辮', 'snake braid'],
    ['micro_braids', '細小辮髮', 'micro braids'],
    ['multiple_braids', '多股辮髮', 'multiple braids'],
    ['side_cornrows', '側邊貼頭辮', 'side cornrows'],
    ['crimped_hair', '玉米鬚波浪髮', 'crimped hair'],
    ['zigzag_part', '鋸齒分線', 'zigzag part'],
    ['deep_side_part', '深側分', 'deep side part'],
    ['no_bangs', '無瀏海', 'no bangs'],
    ['forehead_exposed', '露額髮型', 'forehead exposed'],
  ];
  return definitions.asMap().entries.map((entry) {
    final definition = entry.value;
    return _tag('hair_style_${definition[0]}', '髮型', definition[1],
        definition[2], entry.key + 2,
        conflictGroup: 'hair_style');
  }).toList();
}

List<TagItem> _seedTags() => [
      // Role and character basics.
      _tag('role_girl', '角色類型', '女性角色', '1girl', 0),
      _tag('role_boy', '角色類型', '男性角色', '1boy', 0),
      _tag('role_person', '角色類型', '人物', '1person', 0),
      _tag('role_original', '角色類型', '原創角色', 'original', 0),
      _tag('role_elf', '角色類型', '精靈', 'elf', 0),
      _tag('role_catgirl', '角色類型', '貓娘', 'catgirl', 0),
      _tag('role_bunnygirl', '角色類型', '兔女郎角色', 'bunny girl', 0),
      _tag('role_witch', '角色類型', '魔女', 'witch', 0),
      _tag('role_android', '角色類型', '仿生人/機器人', 'android', 0),
      _tag('role_fairy', '角色類型', '妖精', 'fairy', 0),
      _tag('role_tomboy', '角色類型', '假小子', 'tomboy', 0),

      // Appearance and body.
      _tag('trait_long_hair', '髮長', '長髮', 'long hair', 1,
          conflictGroup: 'hair_length'),
      _tag('trait_short_hair', '髮長', '短髮', 'cropped hair', 1,
          conflictGroup: 'hair_length'),
      _tag('trait_hair_between_eyes', '髮型', '瀏海遮眼', 'hair between eyes', 1),
      _tag('trait_blonde_hair', '髮色', '金髮', 'blonde hair', 1,
          conflictGroup: 'hair_color'),
      _tag('trait_black_hair', '髮色', '黑髮', 'black hair', 1,
          conflictGroup: 'hair_color'),
      _tag('trait_silver_hair', '髮色', '銀髮', 'silver hair', 1,
          conflictGroup: 'hair_color'),
      _tag('trait_blue_hair', '髮色', '藍髮', 'blue hair', 1,
          conflictGroup: 'hair_color'),
      _tag('trait_red_hair', '髮色', '紅髮', 'red hair', 1,
          conflictGroup: 'hair_color'),
      _tag('trait_pink_hair', '髮色', '粉紅髮', 'pink hair', 1,
          conflictGroup: 'hair_color'),
      _tag('trait_purple_hair', '髮色', '紫髮', 'purple hair', 1,
          conflictGroup: 'hair_color'),
      _tag('trait_white_hair', '髮色', '白髮', 'white hair', 1,
          conflictGroup: 'hair_color'),
      _tag('trait_brown_hair', '髮色', '棕髮', 'brown hair', 1,
          conflictGroup: 'hair_color'),
      _tag('trait_green_hair', '髮色', '綠髮', 'green hair', 1,
          conflictGroup: 'hair_color'),
      _tag('trait_orange_hair', '髮色', '橘髮', 'orange hair', 1,
          conflictGroup: 'hair_color'),
      _tag('trait_yellow_hair', '髮色', '黃髮', 'yellow hair', 1,
          conflictGroup: 'hair_color'),
      ..._hairColorShadeTags(),
      ..._animalTraitColorTags(),
      ..._wingColorTags(),
      ..._eyeColorTags(),
      ..._clothingColorShadeTags(
          'eye_shade_color', '眼睛', '眼睛', 'eyes', 'eye_color'),

      // Eye shapes, pupils, effects, and recognizable special eyes.
      _tag('eye_normal', '眼睛', '一般眼睛', 'normal eyes', 2,
          conflictGroup: 'eye_type'),
      _tag('eye_big', '眼睛', '大眼睛', 'big eyes', 2, conflictGroup: 'eye_shape'),
      _tag('eye_small', '眼睛', '小眼睛', 'small eyes', 2,
          conflictGroup: 'eye_shape'),
      _tag('eye_round', '眼睛', '圓眼', 'round eyes', 2,
          conflictGroup: 'eye_shape'),
      _tag('eye_almond', '眼睛', '杏仁眼', 'almond eyes', 2,
          conflictGroup: 'eye_shape'),
      _tag('eye_narrow', '眼睛', '細長眼', 'narrow eyes', 2,
          conflictGroup: 'eye_shape'),
      _tag('eye_sharp', '眼睛', '銳利眼神', 'sharp eyes', 2),
      _tag('eye_upturned', '眼睛', '上挑眼', 'upturned eyes', 2,
          conflictGroup: 'eye_shape'),
      _tag('eye_downturned', '眼睛', '下垂眼', 'downturned eyes', 2,
          conflictGroup: 'eye_shape'),
      _tag('eye_sanpaku', '眼睛', '三白眼', 'sanpaku', 2),
      _tag('eye_heterochromia', '眼睛', '異色瞳', 'heterochromia', 2),
      _tag('eye_slit_pupils', '眼睛', '裂瞳', 'slit pupils', 2),
      _tag('eye_vertical_pupils', '眼睛', '垂直瞳孔', 'vertical pupils', 2),
      _tag('eye_horizontal_pupils', '眼睛', '水平瞳孔', 'horizontal pupils', 2),
      _tag('eye_round_pupils', '眼睛', '圓形瞳孔', 'round pupils', 2),
      _tag('eye_no_pupils', '眼睛', '無瞳孔', 'no pupils', 2),
      _tag('eye_ringed', '眼睛', '環狀眼睛', 'ringed eyes', 2),
      _tag('eye_spiral', '眼睛', '螺旋眼睛', 'spiral eyes', 2),
      _tag('eye_star_pupils', '眼睛', '星形瞳孔', 'star-shaped pupils', 2),
      _tag('eye_cross_pupils', '眼睛', '十字瞳孔', 'cross-shaped pupils', 2),
      _tag('eye_glowing', '眼睛', '發光眼睛', 'glowing eyes', 2),
      _tag('eye_empty', '眼睛', '空洞眼神', 'empty eyes', 2),
      _tag('eye_bright_pupils', '眼睛', '明亮瞳孔', 'bright pupils', 2),
      _tag('eye_white_pupils', '眼睛', '白色瞳孔', 'white pupils', 2),
      _tag('eye_colored_sclera', '眼睛', '有色眼白', 'colored sclera', 2),
      _tag('eye_black_sclera', '眼睛', '黑色眼白', 'black sclera', 2),
      _tag('eye_yellow_sclera', '眼睛', '黃色眼白', 'yellow sclera', 2),
      _tag('eye_extra_pupils', '眼睛', '額外瞳孔', 'extra pupils', 2),
      _tag('eye_multiple', '眼睛', '多重眼睛', 'multiple eyes', 2),
      _tag('eye_sharingan', '眼睛', '寫輪眼', 'sharingan', 2,
          conflictGroup: 'eye_type'),
      _tag('eye_mangekyou_sharingan', '眼睛', '萬花筒寫輪眼', 'mangekyou sharingan', 2,
          conflictGroup: 'eye_type'),
      _tag('eye_eternal_mangekyou_sharingan', '眼睛', '永恆萬花筒寫輪眼',
          'eternal mangekyou sharingan', 2,
          conflictGroup: 'eye_type'),
      _tag('eye_rinnegan', '眼睛', '輪迴眼', 'rinnegan', 2,
          conflictGroup: 'eye_type'),
      _tag('eye_rinnesharingan', '眼睛', '輪迴寫輪眼', 'rinnesharingan', 2,
          conflictGroup: 'eye_type'),
      _tag('eye_byakugan', '眼睛', '白眼', 'byakugan', 2,
          conflictGroup: 'eye_type'),
      _tag('eye_tenseigan', '眼睛', '轉生眼', 'tenseigan', 2,
          conflictGroup: 'eye_type'),
      _tag('eye_jougan', '眼睛', '淨眼', 'jougan', 2, conflictGroup: 'eye_type'),
      _tag('eye_ketsuryugan', '眼睛', '血龍眼', 'ketsuryugan', 2,
          conflictGroup: 'eye_type'),
      _tag('eye_shinigami', '眼睛', '死神之眼', 'shinigami eyes', 2,
          conflictGroup: 'eye_type'),
      _tag('trait_tall', '身體特徵', '高挑身材', 'tall', 1),
      _tag('trait_curvy', '身體特徵', '曲線身材', 'curvy', 1),
      _tag('trait_slim', '身體特徵', '纖細體態', 'slender build', 1),
      _tag('trait_mature', '身體特徵', '成熟外貌（成年）', 'mature female', 1),
      _tag('trait_makeup', '額外特徵', '化妝', 'makeup', 1),
      _tag('trait_earrings', '額外特徵', '耳環', 'earrings', 1),
      _tag('trait_necklace', '額外特徵', '項鍊', 'necklace', 1),
      _tag('trait_tattoo', '額外特徵', '刺青', 'tattoo', 1),
      _tag('trait_nail_polish', '額外特徵', '指甲油', 'nail polish', 1),

      // Hair length.
      _tag('hair_very_short', '髮長', '極短髮', 'close-cropped hair', 1,
          conflictGroup: 'hair_length'),
      _tag('hair_medium', '髮長', '中長髮', 'medium hair', 1,
          conflictGroup: 'hair_length'),
      _tag('hair_very_long', '髮長', '超長髮', 'very long hair', 1,
          conflictGroup: 'hair_length'),
      _tag('hair_absurdly_long', '髮長', '極端超長髮', 'absurdly long hair', 1,
          conflictGroup: 'hair_length'),
      _tag('hair_waist_length', '髮長', '及腰長髮', 'waist-length hair', 1,
          conflictGroup: 'hair_length'),

      // Hairstyle types.
      _tag('hair_bob_cut', '髮型', '鮑伯頭', 'bob cut', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_pixie_cut', '髮型', '精靈短髮', 'pixie cut', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_straight', '髮型', '直髮', 'straight hair', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_wavy', '髮型', '波浪髮', 'wavy hair', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_curly', '髮型', '捲髮', 'curly hair', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_messy', '髮型', '凌亂髮', 'messy hair', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_spiky', '髮型', '尖刺髮', 'spiked hair', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_ponytail', '髮型', '馬尾', 'ponytail', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_high_ponytail', '髮型', '高馬尾', 'high ponytail', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_low_ponytail', '髮型', '低馬尾', 'low ponytail', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_side_ponytail', '髮型', '側馬尾', 'side ponytail', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_twintails', '髮型', '雙馬尾', 'twintails', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_short_twintails', '髮型', '短雙馬尾', 'bob-length twintails', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_low_twintails', '髮型', '低雙馬尾', 'low twintails', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_single_braid', '髮型', '單辮子', 'single braid', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_twin_braids', '髮型', '雙辮子', 'twin braids', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_side_braid', '髮型', '側辮子', 'side braid', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_french_braid', '髮型', '法式辮子', 'french braid', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_bun', '髮型', '髮髻', 'hair bun', 1, conflictGroup: 'hair_style'),
      _tag('hair_double_bun', '髮型', '雙丸子頭', 'double bun', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_odango', '髮型', '丸子頭', 'odango', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_side_bun', '髮型', '側髮髻', 'side bun', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_drill', '髮型', '鑽頭捲', 'drill hair', 1,
          conflictGroup: 'hair_style'),
      _tag('hair_long_straight', '髮型', '長直髮', 'long straight hair', 1),
      ..._expandedHairStyleTags(),

      // Clothing, intentionally split into practical sub-groups.
      _tag('clothing_top', '上衣', '上衣', 'top', 2),
      _tag('clothing_tshirt', '上衣', 'T恤', 't-shirt', 2),
      _tag('clothing_shirt', '上衣', '襯衫', 'shirt', 2),
      _tag('clothing_sweater', '上衣', '毛衣', 'sweater', 2),
      _tag('clothing_hoodie', '上衣', '連帽衫', 'hoodie', 2),
      _tag('clothing_jacket', '上衣', '夾克', 'jacket', 2),
      _tag('clothing_crop_top', '上衣', '短版上衣', 'crop top', 2),
      _tag('clothing_off_shoulder', '上衣', '露肩上衣', 'off-shoulder shirt', 2),
      _tag('clothing_one_shoulder', '上衣風格', '單肩上衣風格', 'one-shoulder top', 2,
          conflictGroup: 'top_style'),
      _tag('clothing_blouse', '上衣', '女式襯衫', 'blouse', 2),
      _tag('clothing_jeans', '褲子', '牛仔褲', 'jeans', 2),
      _tag('clothing_shorts', '褲子', '短褲', 'shorts', 2),
      _tag('clothing_hotpants', '褲子', '熱褲', 'hot pants', 2),
      _tag('clothing_trousers', '褲子', '長褲', 'trousers', 2),
      _tag('clothing_leggings', '褲子', '內搭褲', 'leggings', 2),
      _tag('clothing_skirt', '裙子', '裙子', 'skirt', 2),
      _tag('clothing_miniskirt', '裙子', '迷你裙', 'miniskirt', 2),
      _tag('clothing_pleated_skirt', '下身風格', '百褶裙風格', 'pleated skirt', 2),
      _tag('clothing_short_skirt', '裙子', '膝上裙', 'above-knee skirt', 2),
      _tag('clothing_knee_length_skirt', '裙子', '及膝裙', 'knee-length skirt', 2),
      _tag('clothing_midi_skirt', '裙子', '中長裙', 'midi skirt', 2),
      _tag('clothing_maxi_skirt', '裙子', '超長裙', 'maxi skirt', 2),
      _tag('clothing_pencil_skirt', '下身風格', '鉛筆裙風格', 'pencil skirt', 2),
      _tag('clothing_a_line_skirt', '下身風格', 'A字裙風格', 'a-line skirt', 2),
      _tag('clothing_circle_skirt', '下身風格', '傘裙風格', 'circle skirt', 2),
      _tag('clothing_tiered_skirt', '下身風格', '蛋糕裙風格', 'tiered skirt', 2),
      _tag('clothing_tutu_skirt', '下身風格', '芭蕾舞裙風格', 'tutu skirt', 2),
      _tag('clothing_wrap_skirt', '下身風格', '裹身裙風格', 'wrap skirt', 2),
      _tag('clothing_slit_skirt', '下身風格', '開衩裙風格', 'slit skirt', 2),
      _tag('clothing_denim_skirt', '下身風格', '牛仔裙風格', 'denim skirt', 2),
      _tag('clothing_dress', '服裝', '洋裝', 'dress', 2),
      _tag('clothing_sundress', '服裝', '夏日洋裝', 'sundress', 2),
      _tag('clothing_evening_gown', '服裝', '晚禮服', 'evening gown', 2),
      _tag('clothing_outfit', '服裝', '套裝', 'outfit', 2),
      _tag('clothing_school_uniform', '服裝', '正式西裝外套套裝', 'formal blazer outfit',
          2),
      _tag('clothing_business_suit', '服裝', '商務套裝', 'business suit', 2),
      _tag('clothing_kimono', '服裝', '和服', 'kimono', 2),
      _tag('clothing_apron', '服裝', '圍裙', 'apron', 2),
      _tag('clothing_swimsuit', '服裝', '泳裝', 'swimsuit', 2),
      _tag('clothing_bikini', '服裝', '比基尼', 'bikini', 2),
      _tag('cosplay_dark_magician_girl', '角色扮演', '黑魔導女孩服裝',
          'dark magician girl outfit', 2,
          conflictGroup: 'onepiece_style'),
      _tag('cosplay_dark_magician_girl_tag', '角色扮演', '黑魔導女孩（Cosplay 標籤）',
          'dark magician girl', 2,
          conflictGroup: 'onepiece_style'),
      _tag(
          'cosplay_artoria_saber',
          '角色扮演',
          'Saber 藍白鎧甲洋裝',
          'Saber cosplay outfit with blue armored dress and silver breastplate',
          2,
          conflictGroup: 'onepiece_style'),
      _tag('cosplay_tsunade', '角色扮演', '綱手綠色羽織忍者裝',
          'Tsunade cosplay outfit with green haori and gray wrap top', 2,
          conflictGroup: 'onepiece_style'),
      _tag('cosplay_konan', '角色扮演', '小南曉組織長袍',
          'Konan cosplay outfit with black red-cloud cloak', 2,
          conflictGroup: 'onepiece_style'),
      _tag(
          'cosplay_yoruichi',
          '角色扮演',
          '夜一黑金戰鬥服',
          'Yoruichi cosplay outfit with black sleeveless combat suit and gold arm guards',
          2,
          conflictGroup: 'onepiece_style'),
      _tag('cosplay_rangiku', '角色扮演', '亂菊死霸裝',
          'Rangiku cosplay outfit with black shinigami robe and white sash', 2,
          conflictGroup: 'onepiece_style'),
      _tag(
          'cosplay_android_18',
          '角色扮演',
          '人造人 18 號牛仔背心裝',
          'Android 18 cosplay outfit with denim vest striped shirt and denim skirt',
          2,
          conflictGroup: 'onepiece_style'),
      _tag(
          'cosplay_revy',
          '角色扮演',
          '萊薇傭兵戰鬥裝',
          'Revy cosplay outfit with black crop top denim hot pants and shoulder holsters',
          2,
          conflictGroup: 'onepiece_style'),
      _tag(
          'cosplay_faye_valentine',
          '角色扮演',
          '菲黃色太空賞金獵人裝',
          'Faye Valentine cosplay outfit with yellow crop top yellow hot pants and red jacket',
          2,
          conflictGroup: 'onepiece_style'),
      _tag(
          'cosplay_motoko_kusanagi',
          '角色扮演',
          '草薙素子紫黑戰術服',
          'Motoko Kusanagi cosplay outfit with purple tactical bodysuit and black jacket',
          2,
          conflictGroup: 'onepiece_style'),
      _tag(
          'cosplay_fujiko_mine',
          '角色扮演',
          '峰不二子紅色禮服',
          'Fujiko Mine cosplay outfit with red evening dress and black high heels',
          2,
          conflictGroup: 'onepiece_style'),
      _tag('cosplay_mei_mei', '角色扮演', '冥冥黑色長裙戰鬥裝',
          'Mei Mei cosplay outfit with black long dress and black boots', 2,
          conflictGroup: 'onepiece_style'),
      _tag(
          'cosplay_mirko',
          '角色扮演',
          '米爾科白紫兔英雄裝',
          'Mirko cosplay outfit with white purple rabbit hero bodysuit and thigh boots',
          2,
          conflictGroup: 'onepiece_style'),
      _tag(
          'cosplay_riza_hawkeye',
          '角色扮演',
          '莉莎藍色軍官制服',
          'Riza Hawkeye cosplay outfit with blue military uniform and black boots',
          2,
          conflictGroup: 'onepiece_style'),
      _tag(
          'cosplay_olivier_armstrong',
          '角色扮演',
          '奧莉薇藍色將軍制服',
          'Olivier Armstrong cosplay outfit with blue general uniform and fur-trimmed coat',
          2,
          conflictGroup: 'onepiece_style'),
      _tag(
          'cosplay_nier_2b',
          '角色扮演',
          '2B 黑色哥德戰鬥洋裝',
          '2B YoRHa cosplay outfit with black gothic combat dress and thigh boots',
          2,
          conflictGroup: 'onepiece_style'),
      _tag(
          'cosplay_nier_a2',
          '角色扮演',
          'A2 黑色戰鬥緊身裝',
          'A2 YoRHa cosplay outfit with black combat bodysuit and thigh boots',
          2,
          conflictGroup: 'onepiece_style'),
      _tag('clothing_bra', '胸罩', '胸罩', 'bra', 2, adult: true),
      _tag('clothing_sports_bra', '胸罩', '運動胸罩', 'sports bra', 2),
      _tag('clothing_lace_bra', '胸罩', '蕾絲胸罩', 'lace bra', 2, adult: true),
      _tag('clothing_panties', '內褲', '內褲', 'panties', 2, adult: true),
      _tag(
        'clothing_highleg_panties',
        '內褲',
        '高衩內褲',
        'highleg panties',
        2,
        adult: true,
      ),
      _tag('clothing_thong', '內褲', '丁字褲', 'thong', 2, adult: true),
      _tag('clothing_socks', '襪子', '短襪', 'socks', 2),
      _tag('clothing_kneehighs', '襪子', '膝上襪', 'kneehighs', 2),
      _tag('clothing_thighhighs', '襪子', '大腿襪', 'thighhighs', 2),
      _tag('clothing_lace_stockings', '襪子', '蕾絲長襪', 'lace stockings', 2,
          conflictGroup: 'legwear'),
      _tag('clothing_pantyhose', '襪子', '連褲襪', 'pantyhose', 2),
      _tag('clothing_fishnet', '襪子', '網襪', 'fishnet legwear', 2),
      _tag('clothing_sneakers', '鞋子', '運動鞋', 'sneakers', 2),
      _tag('clothing_boots', '鞋子', '靴子', 'boots', 2),
      _tag('clothing_high_heels', '鞋子', '高跟鞋', 'high heels', 2),
      _tag('clothing_sandals', '鞋子', '涼鞋', 'sandals', 2),
      _tag('clothing_gloves', '配件', '手套', 'gloves', 2),
      _tag('clothing_ribbon', '配件', '蝴蝶結', 'hair ribbon', 2),
      _tag('clothing_choker', '配件', '頸圈', 'choker', 2),
      _tag('clothing_hat', '配件', '帽子', 'hat', 2),
      _tag('clothing_glasses', '配件', '眼鏡', 'glasses', 2),
      ..._clothingColorTags(
          'accessory_color', '配件顏色', '配件', 'accessory', 'accessory_color'),
      ..._clothingColorTags('hat_color', '帽子顏色', '帽子', 'hat', 'hat_color'),
      ..._clothingColorTags(
          'eyewear_color', '眼鏡顏色', '眼鏡', 'eyewear', 'eyewear_color'),

      // Additional underwear, sock and footwear styles.
      _tag('bra_underwire', '胸罩', '鋼圈胸罩', 'underwire bra', 2,
          adult: true, conflictGroup: 'bra'),
      _tag('bra_push_up', '胸罩', '集中型胸罩', 'push-up bra', 2,
          adult: true, conflictGroup: 'bra'),
      _tag('bra_bralette', '胸罩', '無鋼圈胸罩', 'bralette', 2,
          adult: true, conflictGroup: 'bra'),
      _tag('bra_triangle', '胸罩', '三角罩杯胸罩', 'triangle bra', 2,
          adult: true, conflictGroup: 'bra'),
      _tag('bra_racerback', '胸罩', '工字背胸罩', 'racerback bra', 2,
          adult: true, conflictGroup: 'bra'),
      _tag('bra_front_clasp', '胸罩', '前扣式胸罩', 'front-clasp bra', 2,
          adult: true, conflictGroup: 'bra'),
      _tag('underwear_slip', '內衣', '襯裙式內衣', 'slip', 2,
          adult: true, conflictGroup: 'underwear_top'),
      _tag('underwear_long', '內衣', '保暖內衣', 'long underwear', 2,
          conflictGroup: 'underwear_top'),
      _tag('underwear_thermal', '內衣', '發熱內衣', 'thermal underwear', 2,
          conflictGroup: 'underwear_top'),
      _tag('underwear_bodystocking', '內衣', '連身襪衣', 'bodystocking', 2,
          adult: true, conflictGroup: 'underwear_top'),
      _tag('lace_panties', '內褲', '蕾絲內褲', 'lace panties', 2,
          adult: true, conflictGroup: 'underwear_bottom'),
      _tag('cotton_panties', '內褲', '棉質內褲', 'cotton panties', 2,
          adult: true, conflictGroup: 'underwear_bottom'),
      _tag('highwaist_panties', '內褲', '高腰內褲', 'high-waisted panties', 2,
          adult: true, conflictGroup: 'underwear_bottom'),
      _tag('lowrise_panties', '內褲', '低腰內褲', 'low-rise panties', 2,
          adult: true, conflictGroup: 'underwear_bottom'),
      _tag('boyshorts', '內褲', '男孩褲式內褲', 'boyshorts', 2,
          adult: true, conflictGroup: 'underwear_bottom'),
      _tag('cheeky_panties', '內褲', '半露臀內褲', 'cheeky panties', 2,
          adult: true, conflictGroup: 'underwear_bottom'),
      _tag('side_tie_panties', '內褲', '側綁帶內褲', 'side-tie panties', 2,
          adult: true, conflictGroup: 'underwear_bottom'),
      _tag('leg_warmers', '襪子', '腿套', 'leg warmers', 2,
          conflictGroup: 'legwear'),
      _tag('crew_socks', '襪子', '中筒襪', 'crew socks', 2,
          conflictGroup: 'legwear'),
      _tag('over_knee_socks', '襪子', '過膝襪', 'over-knee socks', 2,
          conflictGroup: 'legwear'),
      _tag('toe_socks', '襪子', '五趾襪', 'toe socks', 2, conflictGroup: 'legwear'),
      _tag('tabi_socks', '襪子', '分趾襪', 'tabi socks', 2,
          conflictGroup: 'legwear'),
      _tag('ankle_boots', '鞋子', '踝靴', 'ankle boots', 2,
          conflictGroup: 'footwear'),
      _tag('knee_high_boots', '鞋子', '膝上靴', 'knee-high boots', 2,
          conflictGroup: 'footwear'),
      _tag('mary_janes', '鞋子', '瑪莉珍鞋', 'mary janes', 2,
          conflictGroup: 'footwear'),
      _tag('pumps', '鞋子', '淺口高跟鞋', 'pumps', 2, conflictGroup: 'footwear'),
      _tag('platform_shoes', '鞋子', '厚底鞋', 'platform shoes', 2,
          conflictGroup: 'footwear'),
      _tag('flip_flops', '鞋子', '夾腳拖鞋', 'flip-flops', 2,
          conflictGroup: 'footwear'),
      _tag('slippers', '鞋子', '拖鞋', 'slippers', 2, conflictGroup: 'footwear'),
      _tag('geta', '鞋子', '木屐', 'geta', 2, conflictGroup: 'footwear'),
      _tag('roller_skates', '鞋子', '溜冰鞋', 'roller skates', 2,
          conflictGroup: 'footwear'),
      ..._missingLegacyClothingColorTags(),
      ..._clothingColorTags('top_color', '上衣顏色', '上衣', 'top', 'top_color'),
      ..._clothingColorTags(
          'bottom_color', '下身顏色', '下身', 'bottoms', 'bottom_color'),
      ..._clothingColorTags(
          'underwear_color', '內衣顏色', '內衣', 'underwear', 'underwear_top_color',
          adult: true),
      ..._clothingColorTags('bra_color', '胸罩顏色', '胸罩', 'bra', 'bra_color',
          adult: true),
      ..._clothingColorTags(
          'panties_color', '內褲顏色', '內褲', 'panties', 'underwear_bottom_color',
          adult: true),
      _tag('panties_color_pink_white', '內褲顏色', '粉白色內褲',
          'pink and white panties', 2,
          adult: true, conflictGroup: 'underwear_bottom_color'),
      ..._clothingColorTags(
          'socks_color', '襪子顏色', '襪子', 'socks', 'legwear_color'),
      ..._clothingColorTags(
          'shoes_color', '鞋子顏色', '鞋子', 'shoes', 'footwear_color'),
      ..._clothingColorTags(
          'outerwear_color', '外套顏色', '外套', 'outerwear', 'outerwear_color'),
      ..._clothingColorTags('clothing_detail_color', '服裝細節顏色', '細節', 'detail',
          'clothing_detail_color'),

      ..._clothingColorShadeTags(
          'clothing_shade_color', '服裝顏色', '服裝', 'clothing', 'clothing_color'),
      ..._clothingColorShadeTags(
          'top_shade_color', '上衣顏色', '上衣', 'top', 'top_color'),
      ..._clothingColorShadeTags(
          'bottom_shade_color', '下身顏色', '下身', 'bottoms', 'bottom_color'),
      ..._clothingColorShadeTags('underwear_shade_color', '內衣顏色', '內衣',
          'underwear', 'underwear_top_color',
          adult: true),
      ..._clothingColorShadeTags(
          'bra_shade_color', '胸罩顏色', '胸罩', 'bra', 'bra_color',
          adult: true),
      ..._clothingColorShadeTags('panties_shade_color', '內褲顏色', '內褲', 'panties',
          'underwear_bottom_color',
          adult: true),
      ..._clothingColorShadeTags(
          'socks_shade_color', '襪子顏色', '襪子', 'socks', 'legwear_color'),
      ..._clothingColorShadeTags(
          'shoes_shade_color', '鞋子顏色', '鞋子', 'shoes', 'footwear_color'),
      ..._clothingColorShadeTags('outerwear_shade_color', '外套顏色', '外套',
          'outerwear', 'outerwear_color'),
      ..._clothingColorShadeTags('clothing_detail_shade_color', '服裝細節顏色', '細節',
          'detail', 'clothing_detail_color'),
      ..._clothingColorShadeTags('accessory_shade_color', '配件顏色', '配件',
          'accessory', 'accessory_color'),
      ..._clothingTrimColorTags(
          'clothing_trim_color', '服裝邊線色', '邊線', 'clothing_trim_color'),
      ..._clothingTrimColorTags(
          'top_trim_color', '上衣邊線色', '邊線', 'top_trim_color'),
      ..._clothingTrimColorTags(
          'bottom_trim_color', '下身邊線色', '邊線', 'bottom_trim_color'),
      ..._clothingTrimColorTags(
          'underwear_trim_color', '內衣邊線色', '邊線', 'underwear_trim_color'),
      ..._clothingTrimColorTags(
          'bra_trim_color', '胸罩邊線色', '邊線', 'bra_trim_color'),
      ..._clothingTrimColorTags(
          'panties_trim_color', '內褲邊線色', '邊線', 'panties_trim_color'),
      ..._clothingTrimColorTags(
          'socks_trim_color', '襪子邊線色', '邊線', 'socks_trim_color'),
      ..._clothingTrimColorTags(
          'shoes_trim_color', '鞋子邊線色', '邊線', 'shoes_trim_color'),
      ..._clothingTrimColorTags(
          'outerwear_trim_color', '外套邊線色', '邊線', 'outerwear_trim_color'),
      ..._clothingTrimColorTags(
          'accessory_trim_color', '配件邊線色', '邊線', 'accessory_trim_color'),
      ..._clothingTrimColorTags(
          'hat_trim_color', '帽子邊線色', '邊線', 'hat_trim_color'),
      ..._clothingTrimColorTags(
          'eyewear_trim_color', '眼鏡邊線色', '邊線', 'eyewear_trim_color'),
      ..._extraFeaturePositionTags(),
      ..._extraFeatureColorTags(),
      ..._accessoryPositionTags(),

      // Face tags and expressions.
      _tag('face_smile', '表情', '微笑', 'smile', 3),
      _tag('face_grin', '表情', '露齒笑', 'grin', 3),
      _tag('face_open_mouth', '表情', '張嘴', 'open mouth', 3),
      _tag('face_teeth', '表情', '露出牙齒', 'teeth', 3),
      _tag('face_blush', '表情', '臉紅', 'blush', 3),
      _tag('face_looking_at_viewer', '表情', '看向觀眾', 'looking at viewer', 3),
      _tag('face_closed_eyes', '表情', '閉眼', 'closed eyes', 3),
      _tag('face_wink', '表情', '眨眼', 'wink', 3),
      _tag('face_sweatdrop', '表情', '汗滴', 'sweatdrop', 3),
      _tag('face_tears', '表情', '眼淚', 'tears', 3),
      _tag('face_surprised', '表情', '驚訝', 'surprised', 3),
      _tag('face_embarrassed', '表情', '難為情／尷尬', 'embarrassed', 3),
      _tag('expr_shy', '表情', '靦腆害羞', 'shy', 3,
          conflictGroup: 'expression_mood'),
      _tag('face_serious', '表情', '嚴肅', 'serious', 3),
      _tag('face_angry', '表情', '生氣', 'angry', 3),
      _tag('face_lust', '表情', '情慾表情（成年角色）', 'ahegao', 3, adult: true),
      _tag('face_orgasm', '表情', '高潮表情（成年角色）', 'orgasm', 3, adult: true),

      // More face and expression details commonly used with Amanatsu / Illustrious.
      _tag('expr_closed_mouth', '表情', '閉嘴', 'closed mouth', 3,
          conflictGroup: 'expression_mouth'),
      _tag('expr_parted_lips', '表情', '微張嘴唇', 'parted lips', 3,
          conflictGroup: 'expression_mouth'),
      _tag('expr_pout', '表情', '噘嘴', 'pout', 3,
          conflictGroup: 'expression_mouth'),
      _tag('expr_puckered_lips', '表情', '嘟嘴', 'puckered lips', 3,
          conflictGroup: 'expression_mouth'),
      _tag('expr_tongue_out', '表情', '吐舌', 'tongue out', 3,
          conflictGroup: 'expression_mouth'),
      _tag('expr_biting_lip', '表情', '咬唇', 'biting lip', 3,
          conflictGroup: 'expression_mouth'),
      _tag('expr_biting_own_lip', '表情', '咬自己的嘴唇', 'biting own lip', 3,
          conflictGroup: 'expression_mouth'),
      _tag('expr_exhaling', '表情', '呼氣', 'exhaling', 3),
      _tag('expr_clenched_teeth', '表情', '咬緊牙關', 'clenched teeth', 3,
          conflictGroup: 'expression_mouth'),
      _tag('expr_cat_mouth', '表情', '貓咪嘴（笑）', ':3', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_cat_frown_mouth', '表情', '貓咪嘴（不高興）', '3:', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_round_mouth', '表情', '圓形嘴', 'round mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_wavy_mouth', '表情', '波浪狀嘴', 'wavy mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_triangle_mouth', '表情', '三角形嘴', 'triangle mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_upwards_triangle_mouth', '表情', '上尖三角嘴',
          'upwards triangle mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_downwards_triangle_mouth', '表情', '下尖三角嘴',
          'downwards triangle mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_diamond_mouth', '表情', '菱形嘴', 'diamond mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_chestnut_mouth', '表情', '栗子形嘴', 'chestnut mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_dot_mouth', '表情', '點狀小嘴', 'dot mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_peanut_mouth', '表情', '花生形嘴', 'peanut mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_rectangular_mouth', '表情', '長方形嘴', 'rectangular mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_sideways_mouth', '表情', '側臉外移嘴型', 'sideways mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_snake_mouth', '表情', '蛇形彎曲嘴', 'snake mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_heart_shaped_mouth', '表情', '愛心形嘴', 'heart-shaped mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_hollow_mouth', '表情', '黑色空洞嘴', 'hollow mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_no_mouth', '表情', '無嘴表現', 'no mouth', 3,
          conflictGroup: 'expression_mouth_absence'),
      _tag('expr_x_mouth', '表情', 'X 形閉嘴', 'x mouth', 3,
          conflictGroup: 'expression_mouth_shape'),
      _tag('expr_one_eye_closed', '表情', '單眼閉起', 'one eye closed', 3,
          conflictGroup: 'expression_eyes'),
      _tag('expr_half_closed_eyes', '表情', '半閉眼', 'half-closed eyes', 3,
          conflictGroup: 'expression_eyes'),
      _tag('expr_narrowed_eyes', '表情', '瞇眼', 'narrowed eyes', 3,
          conflictGroup: 'expression_eyes'),
      _tag('expr_sleepy_eyes', '表情', '惺忪睡眼', 'sleepy eyes', 3,
          conflictGroup: 'expression_eyes'),
      _tag('expr_looking_at_viewer', '表情', '看向觀眾', 'looking at viewer', 3,
          conflictGroup: 'expression_eyes'),
      _tag('expr_looking_away', '表情', '移開視線', 'looking away', 3,
          conflictGroup: 'expression_eyes'),
      _tag('expr_looking_up', '表情', '向上看', 'looking up', 3,
          conflictGroup: 'expression_eyes'),
      _tag('expr_looking_down', '表情', '向下看', 'looking down', 3,
          conflictGroup: 'expression_eyes'),
      _tag('expr_sideways_glance', '表情', '側眼看', 'sideways glance', 3,
          conflictGroup: 'expression_eyes'),
      _tag('expr_sparkling_eyes', '表情', '閃亮眼睛', 'sparkling eyes', 3,
          conflictGroup: 'expression_eyes'),
      _tag('expr_heart_shaped_pupils', '眼睛', '愛心瞳孔', 'heart-shaped pupils', 2),
      _tag('expr_nose_blush', '表情', '鼻頭泛紅', 'nose blush', 3,
          conflictGroup: 'expression_face_detail'),
      _tag('expr_steam_from_nose', '表情', '鼻子冒氣', 'steam from nose', 3,
          conflictGroup: 'expression_face_detail'),
      _tag('expr_anger_vein', '表情', '青筋', 'anger vein', 3,
          conflictGroup: 'expression_face_detail'),
      _tag('expr_facial_mark', '表情', '臉部符號', 'facial mark', 3,
          conflictGroup: 'expression_face_detail'),
      _tag('expr_sad', '表情', '悲傷', 'sad', 3, conflictGroup: 'expression_mood'),
      _tag('expr_crying', '表情', '哭泣', 'crying', 3,
          conflictGroup: 'expression_mood'),
      _tag('expr_nervous', '表情', '緊張', 'nervous', 3,
          conflictGroup: 'expression_mood'),
      _tag('expr_worried', '表情', '擔心', 'worried', 3,
          conflictGroup: 'expression_mood'),
      _tag('expr_confident', '表情', '自信', 'confident', 3,
          conflictGroup: 'expression_mood'),
      _tag('expr_smug', '表情', '得意', 'smug', 3,
          conflictGroup: 'expression_mood'),
      _tag('expr_seductive', '表情', '誘惑表情', 'seductive expression', 3,
          adult: true, conflictGroup: 'expression_mood'),
      _tag('expr_seductive_smile', '表情', '誘惑微笑', 'seductive smile', 3,
          adult: true, conflictGroup: 'expression_mood'),
      // Verified Danbooru expression tags. Keep teasing cues in their own
      // picker so they are easy to combine with the eye and mouth details.
      _tag('expr_naughty_face', '表情', '調皮挑逗表情', 'naughty face', 3),
      _tag('expr_licking_lips', '表情', '舔嘴唇', 'licking lips', 3),
      _tag('expr_light_smile', '表情', '淡淡微笑', 'light smile', 3),
      _tag('expr_raised_eyebrow', '表情', '挑眉', 'raised eyebrow', 3),
      _tag('expr_squinting', '表情', '瞇起眼', 'squinting', 3),
      _tag('expr_staring', '表情', '凝視', 'staring', 3),
      // Danbooru-style symbol expressions. Use the canonical symbols: >_<
      // and @_@. The older >o< form is deprecated and is intentionally omitted.
      _tag('expr_symbol_squeezed_face', '表情', '困擾擠壓臉', '>_<', 3),
      _tag('expr_symbol_dizzy_face', '表情', '驚愕暈眩臉', '@_@', 3),
      _tag('expr_symbol_cheerful', '表情', '開心符號表情', '^^^', 3),
      _tag('expr_symbol_happy_eyes', '表情', '彎眼開心符號', '^_^', 3),
      _tag('expr_symbol_round_eyes', '表情', '圓眼驚訝符號', 'o_o', 3),
      _tag('expr_symbol_x_eyes', '表情', 'X 眼符號', 'x_x', 3),
      _tag('expr_symbol_v_mouth', '表情', 'V 形符號嘴', 'v', 3),
      _tag('expr_symbol_playful', '表情', '俏皮眨眼嘴', ';3', 3),
      _tag('expr_spoken_squiggle', '表情', '說話波浪符號', 'spoken squiggle', 3),
      _tag('expr_jitome', '表情', '半閉嫌棄眼', 'jitome', 3),
      _tag('expr_unamused', '表情', '不以為然', 'unamused', 3),
      _tag('expr_flustered', '表情', '慌張害羞', 'flustered', 3),
      _tag('expr_crazy_eyes', '表情', '瘋狂眼神', 'crazy eyes', 3),
      _tag('expr_crazy_smile', '表情', '瘋狂笑容', 'crazy smile', 3),

      // Pose/action.
      _tag('pose_standing', '站立與蹲姿', '站立', 'standing', 4),
      _tag('pose_sitting', '坐姿與跪姿', '坐著', 'sitting', 4),
      _tag('pose_kneeling', '坐姿與跪姿', '跪姿', 'kneeling', 4),
      _tag('pose_lying', '躺臥姿勢', '躺著', 'lying', 4),
      _tag('pose_lying_on_side', '躺臥姿勢', '側躺', 'lying on side', 4),
      _tag('pose_lying_on_back', '躺臥姿勢', '仰躺', 'lying on back', 4),
      _tag('pose_squatting', '站立與蹲姿', '蹲姿', 'squatting', 4),
      _tag('pose_knees_bent', '站立與蹲姿', '膝蓋微蹲', 'knees bent', 4,
          conflictGroup: 'leg_detail'),
      _tag('pose_arms_up', '手臂姿勢', '雙手舉起', 'arms up', 4),
      _tag('pose_hand_on_hip', '手部姿勢', '手放在腰上', 'hand on hip', 4),
      _tag('pose_leaning', '軀幹姿勢', '倚靠', 'leaning', 4),
      _tag('pose_bent_over', '軀幹姿勢', '彎腰', 'bent over', 4, adult: true),
      _tag('pose_presenting', '全身姿勢', '展示姿勢（成年角色）', 'presenting', 4,
          adult: true),
      _tag('pose_ass_up', '全身姿勢', '臀部抬起（成年角色）', 'ass up', 4, adult: true),
      _tag('pose_from_behind', '畫面', '從後方視角', 'from behind', 10),
      _tag('pose_selfie', '畫面', '自拍姿勢', 'selfie', 10),
      _tag('pose_sitting_chair', '坐姿與跪姿', '坐在椅子上', 'sitting on chair', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_sitting_bed', '坐姿與跪姿', '坐在床上', 'sitting on bed', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_sitting_floor', '坐姿與跪姿', '坐在地上', 'sitting on floor', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_sitting_sofa', '坐姿與跪姿', '坐在沙發上', 'sitting on sofa', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_sitting_bench', '坐姿與跪姿', '坐在長椅上', 'sitting on bench', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_standing_straight', '站立與蹲姿', '立正站立', 'standing straight', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_standing_one_leg', '站立與蹲姿', '單腳站立', 'standing on one leg', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_standing_crossed_legs', '站立與蹲姿', '交叉腿站立',
          'standing with crossed legs', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_standing_legs_apart', '站立與蹲姿', '分腿站立',
          'standing with legs apart', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_legs_spread', '腿部姿勢', '雙腿張開（成年角色）', 'legs spread', 4,
          adult: true, conflictGroup: 'leg_spread'),
      _tag('pose_standing_tiptoes', '站立與蹲姿', '踮腳站立', 'standing on tiptoes', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_lying_stomach', '躺臥姿勢', '趴躺', 'lying on stomach', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_lying_bed', '躺臥姿勢', '躺在床上', 'lying on bed', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_lying_floor', '躺臥姿勢', '躺在地上', 'lying on floor', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_lying_table', '躺臥姿勢', '躺在桌上', 'lying on the table', 4,
          conflictGroup: 'basic_pose'),
      _tag('pose_lift_skirt', '動作', '掀起裙子', 'lift up the skirt', 4,
          adult: true, conflictGroup: 'independent_pose_detail'),
      _tag('pose_one_leg_up', '腿部姿勢', '抬起單腳', 'one leg raised', 4,
          conflictGroup: 'leg_raise'),
      _tag('pose_one_leg_kicked_back', '腿部姿勢', '單腳向後翹起',
          'one leg raised behind', 4),
      _tag('pose_left_leg_up', '腿部姿勢', '抬起左腳', 'left leg raised', 4,
          conflictGroup: 'left_leg_raise'),
      _tag('pose_right_leg_up', '腿部姿勢', '抬起右腳', 'right leg raised', 4,
          conflictGroup: 'right_leg_raise'),
      _tag('pose_both_legs_up', '腿部姿勢', '抬起雙腳', 'both legs raised', 4,
          conflictGroup: 'leg_raise'),
      _tag('pose_thigh_raised', '腿部姿勢', '抬起大腿', 'raised thigh', 4,
          conflictGroup: 'leg_detail'),
      _tag('pose_lower_leg_raised', '腿部姿勢', '抬起小腿', 'raised lower leg', 4,
          conflictGroup: 'leg_detail'),
      _tag('pose_bent_leg', '腿部姿勢', '彎曲腿部', 'bent leg', 4,
          conflictGroup: 'leg_detail'),
      _tag('pose_left_hand_up', '手臂姿勢', '抬起左手', 'left hand raised', 4,
          conflictGroup: 'left_arm_pose'),
      _tag('pose_right_hand_up', '手臂姿勢', '抬起右手', 'right hand raised', 4,
          conflictGroup: 'right_arm_pose'),
      _tag('pose_one_hand_up', '手臂姿勢', '抬起單手', 'one hand raised', 4,
          conflictGroup: 'arm_pose'),
      _tag('pose_both_hands_up', '手臂姿勢', '抬起雙手', 'both hands raised', 4,
          conflictGroup: 'arm_pose'),
      _tag('pose_waving', '手部姿勢', '揮手', 'waving', 4,
          conflictGroup: 'hand_gesture'),
      _tag('pose_hands_together', '手部姿勢', '雙手合十', 'hands together', 4,
          conflictGroup: 'hand_gesture'),
      _tag('pose_fist', '手部姿勢', '握拳手勢', 'fist', 4,
          conflictGroup: 'hand_gesture'),
      _tag('pose_hands_behind_back', '手臂姿勢', '雙手放在背後', 'hands behind back', 4,
          conflictGroup: 'hand_gesture'),
      _tag('pose_hand_on_head', '手部姿勢', '手放在頭上', 'hand on head', 4,
          conflictGroup: 'hand_gesture'),
      _tag('pose_peace_sign', '手部姿勢', '比出和平手勢', 'peace sign', 4,
          conflictGroup: 'hand_gesture'),
      _tag('pose_pointing', '手部姿勢', '指向前方', 'pointing', 4,
          conflictGroup: 'hand_gesture'),
      _tag('pose_head_up', '頭部姿勢', '抬頭', 'looking up', 4,
          conflictGroup: 'head_vertical'),
      _tag('pose_head_down', '頭部姿勢', '低頭', 'looking down', 4,
          conflictGroup: 'head_vertical'),
      _tag('pose_head_tilt_left', '頭部姿勢', '頭向左歪', 'head tilt left', 4,
          conflictGroup: 'head_tilt'),
      _tag('pose_head_tilt_right', '頭部姿勢', '頭向右歪', 'head tilt right', 4,
          conflictGroup: 'head_tilt'),
      _tag('pose_head_turn_left', '頭部姿勢', '頭轉向左側', 'head turned left', 4,
          conflictGroup: 'head_direction'),
      _tag('pose_head_turn_right', '頭部姿勢', '頭轉向右側', 'head turned right', 4,
          conflictGroup: 'head_direction'),

      // Dynamic actions and sports poses.
      _tag('action_basketball_shooting', '動作', '投籃', 'shooting basketball', 4),
      _tag(
          'action_basketball_dribbling', '動作', '運球', 'dribbling basketball', 4),
      _tag('action_basketball_dunk', '動作', '灌籃', 'dunking', 4),
      _tag('action_soccer_kicking', '動作', '踢足球', 'kicking soccer ball', 4),
      _tag('action_soccer_dribbling', '動作', '足球帶球', 'dribbling soccer ball', 4),
      _tag('action_baseball_batting', '動作', '打棒球', 'batting', 4),
      _tag('action_baseball_pitching', '動作', '投棒球', 'pitching', 4),
      _tag('action_tennis_swing', '動作', '揮網球拍', 'swinging tennis racket', 4),
      _tag('action_volleyball_spiking', '動作', '排球扣球', 'spiking volleyball', 4),
      _tag('action_badminton_swing', '動作', '揮羽球拍', 'swinging badminton racket',
          4),
      _tag('action_archery', '動作', '射箭', 'drawing bow', 4),
      _tag('action_aiming', '動作', '瞄準', 'aiming', 4),
      _tag('action_sword_swinging', '動作', '揮劍', 'sword swinging', 4),
      _tag('action_fencing', '動作', '擊劍', 'fencing', 4),
      _tag('action_running', '動作', '奔跑', 'running', 4),
      _tag('action_jumping', '動態姿勢', '跳躍中', 'jumping', 4),
      _tag('action_dancing', '動作', '跳舞', 'dancing', 4),
      _tag('action_skating', '動作', '溜冰', 'ice skating', 4),
      _tag('action_swimming', '動作', '游泳', 'swimming', 4),
      _tag('action_cycling', '動作', '騎腳踏車', 'cycling', 4),
      _tag('action_climbing', '動作', '攀爬', 'climbing', 4),
      _tag('action_punching', '動作', '出拳', 'punching', 4),
      _tag('action_kicking', '動作', '踢腿', 'kicking', 4),
      _tag('action_throwing', '動作', '投擲', 'throwing', 4),
      _tag('action_playing_guitar', '動作', '彈吉他', 'playing guitar', 4),
      _tag('action_playing_piano', '動作', '彈鋼琴', 'playing piano', 4),
      _tag('action_reading', '動作', '閱讀', 'reading', 4),
      _tag('action_writing', '動作', '書寫', 'writing', 4),
      _tag('action_painting', '動作', '繪畫', 'painting', 4),
      _tag('action_photographing', '動作', '拍照', 'photography', 4),
      _tag('action_using_phone', '動作', '使用手機', 'using smartphone', 4),
      _tag('action_typing', '動作', '打字', 'typing', 4),
      _tag('action_cooking', '動作', '烹飪', 'cooking', 4),
      _tag('action_eating', '動作', '吃東西', 'eating', 4),
      _tag('action_drinking', '動作', '喝東西', 'drinking', 4),
      _tag('action_holding_flame', '動作', '手持火焰', 'holding flame', 4),

      // Multi-character contact. This remains usable outside adult packages
      // and also gives the same-direction rear-hug poses a clear upper-body
      // relationship.
      _tag(
          'interaction_hug_from_behind', '多人互動', '從後方環抱', 'hug from behind', 4),

      // Composable actions: select one of these together with an object to
      // generate a single prompt noun, such as "hugging teddy bear".
      _tag('action_hugging_object', '動作', '抱著物件', 'hugging object', 4,
          conflictGroup: 'object_interaction_mode'),
      _tag('action_riding_object', '動作', '騎著物件', 'riding object', 4,
          conflictGroup: 'object_interaction_mode'),
      _tag('action_holding_object', '動作', '拿著物件', 'holding object', 4,
          conflictGroup: 'object_interaction_mode'),
      _tag('action_holding_object_overhead', '動作', '高舉物件',
          'holding object overhead', 4,
          conflictGroup: 'object_interaction_mode'),
      _tag('action_holding_staff', '動作', '手持法杖', 'holding staff', 4,
          conflictGroup: 'object_interaction_mode'),
      _tag('action_holding_magic_wand', '動作', '手持魔法棒', 'holding magic wand', 4,
          conflictGroup: 'object_interaction_mode'),
      _tag('action_carrying_object', '動作', '抱持物件', 'carrying object', 4,
          conflictGroup: 'object_interaction_mode'),
      _tag('action_sitting_on_object', '動作', '坐在物件上', 'sitting on object', 4,
          conflictGroup: 'object_interaction_mode'),
      _tag('action_lying_on_object', '動作', '躺在物件上', 'lying on object', 4,
          conflictGroup: 'object_interaction_mode'),
      _tag('action_leaning_on_object', '動作', '靠著物件', 'leaning on object', 4,
          conflictGroup: 'object_interaction_mode'),

      // Common props and handheld objects.
      _tag('object_basketball', '物件', '籃球', 'basketball', 4),
      _tag('object_soccer_ball', '物件', '足球', 'soccer ball', 4),
      _tag('object_volleyball', '物件', '排球', 'volleyball', 4),
      _tag('object_baseball', '物件', '棒球', 'baseball', 4),
      _tag('object_baseball_bat', '物件', '棒球棒', 'baseball bat', 4),
      _tag('object_tennis_racket', '物件', '網球拍', 'tennis racket', 4),
      _tag('object_badminton_racket', '物件', '羽球拍', 'badminton racket', 4),
      _tag('object_bow', '物件', '弓', 'bow', 4),
      _tag('object_arrow', '物件', '箭', 'arrow', 4),
      _tag('object_sword', '物件', '劍', 'sword', 4),
      _tag('object_staff', '物件', '法杖', 'staff', 4),
      _tag('object_magic_wand', '物件', '魔法棒', 'magic wand', 4),
      _tag('object_shield', '物件', '盾牌', 'shield', 4),
      _tag('object_umbrella', '物件', '雨傘', 'umbrella', 4),
      _tag('object_camera', '物件', '相機', 'camera', 4),
      _tag('object_smartphone', '物件', '智慧型手機', 'smartphone', 4),
      _tag('object_laptop', '物件', '筆記型電腦', 'laptop', 4),
      _tag('object_tablet', '物件', '平板電腦', 'tablet', 4),
      _tag('object_headphones', '物件', '耳機', 'headphones', 4),
      _tag('object_book', '物件', '書本', 'book', 4),
      _tag('object_notebook', '物件', '筆記本', 'notebook', 4),
      _tag('object_pen', '物件', '原子筆', 'pen', 4),
      _tag('object_pencil', '物件', '鉛筆', 'pencil', 4),
      _tag('object_backpack', '物件', '背包', 'backpack', 4),
      _tag('object_handbag', '物件', '手提包', 'handbag', 4),
      _tag('object_briefcase', '物件', '公事包', 'briefcase', 4),
      _tag('object_water_bottle', '物件', '水瓶', 'water bottle', 4),
      _tag('object_cup', '物件', '杯子', 'cup', 4),
      _tag('object_mug', '物件', '馬克杯', 'mug', 4),
      _tag('object_plate', '物件', '盤子', 'plate', 4),
      _tag('object_omelet_rice', '物件', '蛋包飯', 'omelet rice', 4),
      _tag('object_fork', '物件', '叉子', 'fork', 4),
      _tag('object_spoon', '物件', '湯匙', 'spoon', 4),
      _tag('object_chopsticks', '物件', '筷子', 'chopsticks', 4),
      _tag('object_microphone', '物件', '麥克風', 'microphone', 4),
      _tag('object_guitar', '物件', '吉他', 'guitar', 4),
      _tag('object_violin', '物件', '小提琴', 'violin', 4),
      _tag('object_piano', '物件', '鋼琴', 'piano', 4),
      _tag('object_paintbrush', '物件', '畫筆', 'paintbrush', 4),
      _tag('object_palette', '物件', '調色盤', 'palette', 4),
      _tag('object_flower', '物件', '花朵', 'flower', 4),
      _tag('object_bouquet', '物件', '花束', 'bouquet', 4),
      _tag('object_balloon', '物件', '氣球', 'balloon', 4),
      _tag('object_teddy_bear', '物件', '泰迪熊', 'teddy bear', 4),
      _tag('object_stuffed_toy', '物件', '玩偶', 'stuffed toy', 4),
      _tag('object_skateboard', '物件', '滑板', 'skateboard', 4),
      _tag('object_bicycle', '物件', '腳踏車', 'bicycle', 4),
      _tag('object_candle', '物件', '蠟燭', 'candle', 4),
      _tag('object_key', '物件', '鑰匙', 'key', 4),
      _tag('object_gift', '物件', '禮物', 'present', 4),
      _tag('object_pillow', '物件', '枕頭', 'pillow', 4),
      _tag('object_cushion', '物件', '抱枕', 'cushion', 4),
      _tag('object_chair', '物件', '椅子', 'chair', 4),
      _tag('object_sofa', '物件', '沙發', 'sofa', 4),
      _tag('object_bed', '物件', '床', 'bed', 4),
      _tag('object_table', '物件', '桌子', 'table', 4),
      _tag('object_motorcycle', '物件', '機車', 'motorcycle', 4),
      _tag('object_scooter', '物件', '滑板車', 'scooter', 4),
      _tag('object_horse', '物件', '馬', 'horse', 4),
      _tag('object_car', '物件', '汽車', 'car', 4),

      // Adult-only accessories and toys; hidden until 18+ categories are enabled.
      _tag('adult_vibrator', '成人道具', '按摩器（成年角色）', 'vibrator', 5, adult: true),
      _tag('adult_wand_vibrator', '成人道具', '魔法棒型按摩器（成年角色）', 'wand vibrator', 5,
          adult: true),
      _tag('adult_dildo', '成人道具', '假陰莖（成年角色）', 'dildo', 5, adult: true),
      _tag('adult_strap_on', '成人道具', '穿戴式假陰莖（成年角色）', 'strap-on dildo', 5,
          adult: true),
      _tag('adult_butt_plug', '成人道具', '肛塞（成年角色）', 'butt plug', 5, adult: true),
      _tag('adult_anal_beads', '成人道具', '肛珠（成年角色）', 'anal beads', 5,
          adult: true),
      _tag('adult_love_egg', '成人道具', '跳蛋（成年角色）', 'love egg', 5, adult: true),
      _tag('adult_remote_vibrator', '成人道具', '遙控按摩器（成年角色）',
          'remote-controlled vibrator', 5,
          adult: true),
      _tag('adult_sex_toy', '成人道具', '成人玩具（成年角色）', 'sex toy', 5, adult: true),
      _tag(
          'adult_bullet_vibrator', '成人道具', '子彈型按摩器（成年角色）', 'bullet vibrator', 5,
          adult: true),
      _tag(
          'adult_rabbit_vibrator', '成人道具', '兔兔型按摩器（成年角色）', 'rabbit vibrator', 5,
          adult: true),
      _tag('adult_handheld_vibrator', '成人道具', '手持按摩器（成年角色）',
          'handheld vibrator', 5,
          adult: true),
      _tag('adult_dildo_under_clothes', '成人道具', '衣物下使用假陰莖（成年角色）',
          'dildo under clothes', 5,
          adult: true),
      _tag('adult_vibrator_under_clothes', '成人道具', '衣物下使用按摩器（成年角色）',
          'vibrator under clothes', 5,
          adult: true),
      _tag('adult_handcuffs', '成人道具', '手銬（成年角色）', 'handcuffs', 5, adult: true),
      _tag('adult_blindfold', '成人道具', '眼罩（成年角色）', 'blindfold', 5, adult: true),

      // Breasts and nudity groups based on the supplied Danbooru references.
      _tag('body_flat_chest', '胸部', '平胸', 'flat chest', 5),
      _tag('body_small_breasts', '胸部', '小胸', 'small breasts', 5),
      _tag('body_medium_breasts', '胸部', '中等胸部', 'medium breasts', 5),
      _tag('body_large_breasts', '胸部', '大胸', 'large breasts', 5),
      _tag('body_huge_breasts', '胸部', '巨乳', 'huge breasts', 5, adult: true),
      _tag('body_breasts', '胸部', '胸部可見', 'breasts', 5, adult: true),
      _tag('body_cleavage', '胸部', '乳溝', 'cleavage', 5, adult: true),
      _tag('body_underboob', '胸部', '下胸', 'underboob', 5, adult: true),
      _tag('body_nipples', '胸部', '乳頭可見', 'nipples', 5, adult: true),
      _tag('body_breast_press', '胸部', '胸部擠壓', 'breast press', 5, adult: true),
      _tag('nudity_nude', '裸露', '裸體', 'nude', 6, adult: true),
      _tag('nudity_nude_female', '裸露', '裸體女性', 'nude female', 6, adult: true),
      _tag('nudity_vagina', '裸露', '陰部（成年角色）', 'vagina', 6, adult: true),
      _tag('nudity_topless', '裸露', '上空', 'topless', 6, adult: true),
      _tag('nudity_bottomless', '裸露', '下空', 'bottomless', 6, adult: true),
      _tag('nudity_bare_shoulders', '裸露', '裸肩', 'bare shoulders', 6),
      _tag('nudity_bare_legs', '裸露', '裸腿', 'bare legs', 6),
      _tag('nudity_barefoot', '裸露', '赤腳', 'barefoot', 6),
      _tag('nudity_midriff', '裸露', '露腰', 'midriff', 6),
      _tag(
        'nudity_covering_breasts',
        '裸露',
        '遮住胸部',
        'covering breasts',
        6,
        adult: true,
      ),
      _tag(
        'nudity_covering_crotch',
        '裸露',
        '遮住胯部',
        'covering crotch',
        6,
        adult: true,
      ),

      // Sex acts and sexual positions. All are adult-only and off by the adult filter.
      _tag('act_sex', '性行為', '性行為（成年角色）', 'sex', 7, adult: true),
      _tag('act_vaginal', '性行為', '陰道性交（成年角色）', 'vaginal', 7, adult: true),
      _tag('act_triple_vaginal', '性行為', '三人陰道性交（成年角色）', 'triple vaginal', 7,
          adult: true),
      _tag('act_anal', '性行為', '肛交（成年角色）', 'anal', 7, adult: true),
      _tag('act_oral', '性行為', '口交（成年角色）', 'oral', 7, adult: true),
      _tag('act_blowjob', '性行為', '口交行為（成年角色）', 'blowjob', 7, adult: true),
      _tag('act_handjob', '性行為', '手交（成年角色）', 'handjob', 7, adult: true),
      _tag('act_fingering', '性行為', '手指刺激（成年角色）', 'fingering', 7,
          adult: true, conflictGroup: 'masturbation_method'),
      _tag('act_masturbation', '性行為', '自慰（成年角色）', 'masturbation', 7,
          adult: true),
      _tag('act_female_masturbation', '性行為', '女性自慰（成年角色）',
          'female masturbation', 7,
          adult: true),
      _tag('act_sex_toy_use', '性行為', '使用成人玩具（成年角色）', 'sex toy use', 7,
          adult: true),
      _tag('act_sex_toy_insertion', '性行為', '成人玩具插入（成年角色）', 'sex toy insertion',
          7,
          adult: true, conflictGroup: 'masturbation_method'),
      _tag('act_dildo_riding', '性行為', '騎乘假陰莖（成年角色）', 'dildo riding', 7,
          adult: true),
      _tag('act_non_penetrative_masturbation', '性行為', '非插入式自慰（成年角色）',
          'non-penetrative masturbation', 7,
          adult: true, conflictGroup: 'masturbation_method'),
      _tag('act_fingering_through_clothes', '性行為', '隔著衣物手指刺激（成年角色）',
          'fingering through clothes', 7,
          adult: true, conflictGroup: 'masturbation_method'),
      _tag('act_fingering_through_panties', '性行為', '隔著內褲手指刺激（成年角色）',
          'fingering through panties', 7,
          adult: true, conflictGroup: 'masturbation_method'),
      _tag('act_vaginal_fingering', '性行為', '陰道手指刺激（成年角色）', 'vaginal fingering',
          7,
          adult: true, conflictGroup: 'masturbation_method'),
      _tag('act_anal_fingering', '性行為', '肛門手指刺激（成年角色）', 'anal fingering', 7,
          adult: true, conflictGroup: 'masturbation_method'),
      _tag('act_masturbation_through_clothes', '性行為', '隔著衣物自慰（成年角色）',
          'masturbation through clothes', 7,
          adult: true, conflictGroup: 'masturbation_method'),
      _tag('act_kissing', '親吻動作', '接吻', 'kiss', 4),
      _tag('act_french_kiss', '親吻動作', '法式接吻（成年角色）', 'french kiss', 4,
          adult: true),
      _tag('act_grinding', '性行為・動態', '貼身磨蹭中（成年角色）', 'grinding', 7, adult: true),
      _tag('act_table_humping', '性行為', '桌上磨蹭（成年角色）', 'table humping', 7,
          adult: true),
      _tag('act_pillow_humping', '性行為', '枕頭磨蹭（成年角色）', 'pillow humping', 7,
          adult: true),
      _tag('act_object_humping', '性行為', '物品磨蹭（成年角色）', 'object humping', 7,
          adult: true),
      _tag('act_scissoring', '性行為', '剪式摩擦（成年角色）', 'scissoring', 7, adult: true),
      _tag('act_breast_grinding', '性行為', '胸部磨蹭（成年角色）', 'breast grinding', 7,
          adult: true),
      _tag('act_paizuri', '性行為', '乳交／胸部夾弄（成年角色）', 'paizuri', 7,
          adult: true, conflictGroup: 'breast_sex_type'),
      _tag('act_autopaizuri', '性行為', '自體乳交（成年角色）', 'autopaizuri', 7,
          adult: true, conflictGroup: 'breast_sex_type'),
      _tag('act_cooperative_paizuri', '性行為', '協力乳交（成年角色）',
          'cooperative paizuri', 7,
          adult: true, conflictGroup: 'breast_sex_type'),
      _tag('act_handsfree_paizuri', '性行為', '無手乳交（成年角色）', 'handsfree paizuri', 7,
          adult: true, conflictGroup: 'breast_sex_type'),
      _tag('act_paizuri_on_lap', '性行為', '膝上乳交（成年角色）', 'paizuri on lap', 7,
          adult: true, conflictGroup: 'breast_sex_type'),
      _tag('act_paizuri_over_clothes', '性行為', '隔衣乳交（成年角色）',
          'paizuri over clothes', 7,
          adult: true, conflictGroup: 'breast_sex_type'),
      _tag('act_paizuri_under_clothes', '性行為', '衣物下乳交（成年角色）',
          'paizuri under clothes', 7,
          adult: true, conflictGroup: 'breast_sex_type'),
      _tag('act_perpendicular_paizuri', '性行為', '垂直乳交（成年角色）',
          'perpendicular paizuri', 7,
          adult: true, conflictGroup: 'breast_sex_type'),
      _tag('act_reverse_paizuri', '性行為', '反向乳交（成年角色）', 'reverse paizuri', 7,
          adult: true, conflictGroup: 'breast_sex_type'),
      _tag('act_straddling_paizuri', '性行為', '跨坐乳交（成年角色）', 'straddling paizuri',
          7,
          adult: true, conflictGroup: 'breast_sex_type'),
      _tag('act_naizuri', '性行為', '無胸乳交（成年角色）', 'naizuri', 7,
          adult: true, conflictGroup: 'breast_sex_type'),
      _tag('act_cooperative_naizuri', '性行為', '協力無胸乳交（成年角色）',
          'cooperative naizuri', 7,
          adult: true, conflictGroup: 'breast_sex_type'),
      _tag('act_breast_smother', '性行為', '胸部壓臉（成年角色）', 'breast smother', 7,
          adult: true),
      _tag('act_bondage', '性行為', '束縛（成年角色）', 'bondage', 7, adult: true),
      _tag('act_bdsm', '性行為', 'BDSM（成年角色）', 'bdsm', 7, adult: true),
      _tag('act_cum', '性行為', '體液（成年角色）', 'cum', 7, adult: true),
      _tag('act_semen_flowing_out', '性行為', '精液流出（成年角色）', 'semen flowing out', 7,
          adult: true),
      _tag('act_cumshot', '性行為', '射精畫面（成年角色）', 'cumshot', 7, adult: true),
      _tag('act_pulling_out', '性行為', '性交結束・抽離動作（成年角色）', 'pulling out', 7,
          adult: true),
      _tag('act_pulling_out_upwards', '性行為', '性交結束・向上抽離（成年角色）',
          'pulling out upwards', 7,
          adult: true),
      _tag('act_pulling_out_sideways', '性行為', '性交結束・向側邊抽離（成年角色）',
          'pulling out sideways', 7,
          adult: true),
      _tag('act_pulling_out_backwards', '性行為', '性交結束・向後抽離（成年角色）',
          'pulling out backwards', 7,
          adult: true),
      _tag('act_pulling_out_downwards', '性行為', '性交結束・向下抽離（成年角色）',
          'pulling out downwards', 7,
          adult: true),
      _tag('act_pulling_out_from_behind', '性行為', '性交結束・從後方抽離（成年角色）',
          'pulling out from behind', 7,
          adult: true),
      _tag('act_pulling_out_standing', '性行為', '性交結束・站立抽離（成年角色）',
          'pulling out while standing', 7,
          adult: true),
      _tag('act_pulling_out_lying', '性行為', '性交結束・躺臥抽離（成年角色）',
          'pulling out while lying down', 7,
          adult: true),
      _tag('act_sweat', '性行為', '汗水', 'sweat', 7),
      _tag(
        'position_missionary',
        '性姿勢',
        '傳教士體位（成年角色）',
        'missionary',
        8,
        adult: true,
      ),
      _tag(
        'position_cowgirl',
        '性姿勢',
        '女上位（成年角色）',
        'cowgirl position',
        8,
        adult: true,
      ),
      _tag(
        'position_reverse_cowgirl',
        '性姿勢',
        '背向女上位（成年角色）',
        'reverse cowgirl',
        8,
        adult: true,
      ),
      _tag('position_doggystyle', '性姿勢', '後入式（成年角色）', 'doggystyle', 8,
          adult: true),
      _tag(
        'position_standing_sex',
        '性姿勢',
        '站立性交（成年角色）',
        'standing sex',
        8,
        adult: true,
      ),
      _tag('position_riding', '性姿勢', '騎乘（成年角色）', 'riding', 8, adult: true),
      _tag('position_sixty_nine', '性姿勢', '六九式（成年角色）', 'sixty-nine', 8,
          adult: true),
      _tag('position_group_sex', '性姿勢', '多人性行為（成年角色）', 'group sex', 8,
          adult: true),

      // Scene, camera and model-friendly quality terms.
      _tag('scene_bedroom', _indoorSceneGroup, '臥室', 'bedroom', 9),
      _tag('scene_in_a_room', _indoorSceneGroup, '在房間內', 'in a room', 9),
      _tag('scene_wet_bed', _indoorSceneGroup, '濕床（成年角色）', 'wet bed', 9,
          adult: true),
      _tag('scene_bathroom', _indoorSceneGroup, '浴室', 'bathroom', 9),
      _tag('scene_classroom', _indoorSceneGroup, '教室', 'classroom', 9),
      _tag('scene_beach', _outdoorSceneGroup, '海灘', 'beach', 9),
      _tag('scene_cherry_blossoms', _outdoorSceneGroup, '櫻花樹下',
          'cherry blossoms', 9),
      _tag('scene_snowing', _outdoorSceneGroup, '下雪', 'snowing', 9),
      _tag('scene_cold', _outdoorSceneGroup, '寒冷', 'cold', 9),
      _tag('scene_sunrise', _outdoorTimeGroup, '日出', 'sunrise', 9,
          conflictGroup: 'outdoor_time'),
      _tag('scene_dusk', _outdoorTimeGroup, '黃昏', 'dusk', 9,
          conflictGroup: 'outdoor_time'),
      _tag('scene_night', _outdoorTimeGroup, '夜晚', 'night', 9,
          conflictGroup: 'outdoor_time'),
      _tag('scene_sunset', _outdoorTimeGroup, '日落', 'sunset', 9,
          conflictGroup: 'outdoor_time'),
      _tag('scene_simple_background', _indoorSceneGroup, '簡單背景',
          'simple background', 9),
      _tag('scene_evening_light', '畫面', '黃昏光線', 'evening light', 10,
          conflictGroup: 'lighting'),
      _tag('effect_breath', '畫面', '呼出白氣', 'breath', 10),
      _tag('effect_snowflakes', '畫面', '飄落雪花', 'snowflakes', 10),
      _tag('effect_shiny_skin', '畫面', '發亮肌膚', 'shiny skin', 10),
      _tag('effect_glitter', '畫面', '閃粉光點', 'glitter', 10),
      _tag('effect_light_particles', '畫面', '光粒子', 'light particles', 10),
      _tag('effect_black_fire', '畫面', '黑色火焰', 'black fire', 10),
      _tag('effect_high_contrast', '畫面', '高對比', 'high contrast', 10),
      _tag('effect_depth_of_field', '畫面', '景深', 'depth of field', 10),
      _tag('effect_complementary_colors', '畫面', '互補色搭配', 'complementary colors',
          10),
      _tag('effect_foreshortening', '畫面', '透視縮短', 'foreshortening', 10),
      _tag('effect_colorful', '畫面', '繽紛色彩', 'colorful', 10),
      _tag('frame_japanese_text', '畫面', '日文文字', 'japanese text', 10),
      // Danbooru image-composition tags: framing from head to toe.
      _tag('camera_portrait', _cameraFramingGroup, '臉部到肩膀肖像', 'portrait', 10),
      _tag('camera_close_up', _cameraFramingGroup, '近距離特寫', 'close-up', 10),
      _tag('camera_upper_body', _cameraFramingGroup, '上半身（頭到軀幹）', 'upper body',
          10),
      _tag('camera_cowboy_shot', _cameraFramingGroup, '膝上構圖（頭到大腿）',
          'cowboy shot', 10),
      _tag('camera_feet_out_of_frame', _cameraFramingGroup, '頭到小腿（腳出框）',
          'feet out of frame', 10),
      _tag('camera_full_body', _cameraFramingGroup, '頭到腳完整全身', 'full body', 10),
      _tag('camera_wide_shot', _cameraFramingGroup, '遠景全身', 'wide shot', 10),
      _tag('camera_very_wide_shot', _cameraFramingGroup, '極遠景全身',
          'very wide shot', 10),
      _tag('camera_lower_body', _cameraFramingGroup, '下半身（腰部以下）', 'lower body',
          10),
      _tag('camera_head_out_of_frame', _cameraFramingGroup, '頸部以下（頭出框）',
          'head out of frame', 10),
      _tag('camera_eyes_out_of_frame', _cameraFramingGroup, '鼻部以下（眼睛出框）',
          'eyes out of frame', 10),

      // Face focus from the head through the neck.
      _tag(
          'camera_head_focus', _cameraFaceFocusGroup, '頭部聚焦', 'head focus', 10),
      _tag('camera_face_focus', _cameraFaceFocusGroup, '臉部／表情聚焦', 'face focus',
          10),
      _tag('camera_forehead_focus', _cameraFaceFocusGroup, '額頭聚焦',
          'forehead focus', 10),
      _tag('camera_eyebrow_focus', _cameraFaceFocusGroup, '眉毛聚焦',
          'eyebrow focus', 10),
      _tag('camera_eye_focus', _cameraFaceFocusGroup, '眼睛聚焦', 'eye focus', 10),
      _tag(
          'camera_nose_focus', _cameraFaceFocusGroup, '鼻子聚焦', 'nose focus', 10),
      _tag('camera_mouth_focus', _cameraFaceFocusGroup, '嘴巴聚焦', 'mouth focus',
          10),
      _tag(
          'camera_lips_focus', _cameraFaceFocusGroup, '嘴唇聚焦', 'lips focus', 10),
      _tag(
          'camera_chin_focus', _cameraFaceFocusGroup, '下巴聚焦', 'chin focus', 10),
      _tag('camera_ear_focus', _cameraFaceFocusGroup, '耳朵聚焦', 'ear focus', 10),
      _tag(
          'camera_neck_focus', _cameraFaceFocusGroup, '頸部聚焦', 'neck focus', 10),

      // Body focus from the hair and shoulders down to the toes. These remain
      // composable with framing and angle tags, so the user can target more
      // than one detail when a scene needs it.
      _tag('camera_hair_focus', _cameraFocusGroup, '髮型聚焦', 'hair focus', 10),
      _tag('camera_shoulder_focus', _cameraFocusGroup, '肩膀聚焦', 'shoulder focus',
          10),
      _tag('camera_collarbone_focus', _cameraFocusGroup, '鎖骨聚焦',
          'collarbone focus', 10),
      _tag('camera_upper_arm_focus', _cameraFocusGroup, '上手臂聚焦',
          'upper arm focus', 10),
      _tag('camera_elbow_focus', _cameraFocusGroup, '手肘聚焦', 'elbow focus', 10),
      _tag('camera_forearm_focus', _cameraFocusGroup, '前臂聚焦', 'forearm focus',
          10),
      _tag('camera_wrist_focus', _cameraFocusGroup, '手腕聚焦', 'wrist focus', 10),
      _tag('camera_hand_focus', _cameraFocusGroup, '手部聚焦', 'hand focus', 10),
      _tag(
          'camera_finger_focus', _cameraFocusGroup, '手指聚焦', 'finger focus', 10),
      _tag('camera_chest_focus', _cameraFocusGroup, '胸口聚焦', 'chest focus', 10),
      _tag('camera_breast_focus', _cameraFocusGroup, '胸部聚焦（成年角色）',
          'breast focus', 10,
          adult: true),
      _tag('camera_torso_focus', _cameraFocusGroup, '軀幹聚焦', 'torso focus', 10),
      _tag('camera_stomach_focus', _cameraFocusGroup, '腹部聚焦', 'stomach focus',
          10),
      _tag('camera_navel_focus', _cameraFocusGroup, '肚臍聚焦', 'navel focus', 10),
      _tag('camera_waist_focus', _cameraFocusGroup, '腰部聚焦', 'waist focus', 10),
      _tag('camera_hip_focus', _cameraFocusGroup, '臀／髖部聚焦', 'hip focus', 10),
      _tag('camera_butt_focus', _cameraFocusGroup, '臀部聚焦（成年角色）', 'butt focus',
          10,
          adult: true),
      _tag('camera_crotch_focus', _cameraFocusGroup, '胯部聚焦（成年角色）',
          'crotch focus', 10,
          adult: true),
      _tag('camera_thigh_focus', _cameraFocusGroup, '大腿聚焦', 'thigh focus', 10),
      _tag('camera_knee_focus', _cameraFocusGroup, '膝蓋聚焦', 'knee focus', 10),
      _tag('camera_leg_focus', _cameraFocusGroup, '腿部聚焦', 'leg focus', 10),
      _tag('camera_calf_focus', _cameraFocusGroup, '小腿聚焦', 'calf focus', 10),
      _tag('camera_ankle_focus', _cameraFocusGroup, '腳踝聚焦', 'ankle focus', 10),
      _tag('camera_foot_focus', _cameraFocusGroup, '腳部聚焦', 'foot focus', 10),
      _tag('camera_toe_focus', _cameraFocusGroup, '腳趾聚焦', 'toe focus', 10),

      // Cropped tags describe a body part being intentionally cut by the frame.
      _tag('camera_cropped_head', _cameraCropGroup, '頭部裁切', 'cropped head', 10),
      _tag('camera_cropped_shoulders', _cameraCropGroup, '肩膀裁切',
          'cropped shoulders', 10),
      _tag('camera_cropped_torso', _cameraCropGroup, '軀幹裁切', 'cropped torso',
          10),
      _tag('camera_cropped_arms', _cameraCropGroup, '手臂裁切', 'cropped arms', 10),
      _tag('camera_cropped_legs', _cameraCropGroup, '腿部裁切', 'cropped legs', 10),
      _tag('camera_from_above', '畫面', '俯視', 'from above', 10),
      _tag('camera_from_below', '畫面', '仰視', 'from below', 10),
      _tag('camera_pov', '畫面', '第一人稱視角', 'pov', 10),
      _tag('camera_birds_eye', '畫面', '鳥瞰視角', 'birds-eye', 10),
      _tag('camera_isometric', '畫面', '等角視角', 'isometric', 10),
      _tag('camera_high_angle', '畫面', '高角度視角', 'high-angle view', 10),
      _tag('camera_low_angle', '畫面', '低角度視角', 'low-angle view', 10),
      _tag('camera_eye_level', '畫面', '平視角度', 'eye-level shot', 10),
      _tag('camera_front_view', '畫面', '正面視角', 'front view', 10),
      _tag('camera_side_view', '畫面', '側面視角', 'side view', 10),
      _tag('camera_rear_view', '畫面', '背面視角', 'rear view', 10),
      _tag('camera_three_quarter', '畫面', '三分之四視角', 'three-quarter view', 10),
      _tag('camera_over_shoulder', '畫面', '越肩視角', 'over-the-shoulder view', 10),
      _tag('quality_masterpiece', '品質', '傑作', 'masterpiece', 11),
      _tag('quality_best_quality', '品質', '最佳品質', 'best quality', 11),
      _tag('quality_newest', '品質', '最新風格', 'newest', 11),
      _tag('quality_absurdres', '品質', '超高解析', 'absurdres', 11),
      _tag('quality_highres', '品質', '高解析', 'highres', 11),
      _tag('quality_score8', '品質', '高品質評分', 'score_8', 11),
      _tag('quality_detailed', '品質', '高度細節', 'highly detailed', 11),
      _tag('quality_anime', '品質', '動漫風格', 'anime style', 11),
      _tag(
        'quality_anatomically_correct',
        '品質',
        '解剖結構正確',
        'anatomically correct',
        11,
      ),
      _tag(
          'quality_proper_proportions', '品質', '比例正確', 'proper proportions', 11),
      _tag('quality_clear_composition', '品質', '清晰構圖', 'clear composition', 11),
      _tag(
        'quality_professional_lighting',
        '品質',
        '專業打光',
        'professional lighting',
        11,
      ),
      _tag('quality_cinematic_light', '品質', '電影感光線', 'cinematic light', 11),
      _tag('quality_soft_shadows', '品質', '柔和陰影', 'soft shadows', 11),
      _tag(
        'quality_detailed_environment',
        '品質',
        '細節環境',
        'detailed environment',
        11,
      ),
      _tag('quality_soft_lighting', '品質', '柔和光線', 'soft lighting', 11),
      _tag('quality_detailed_eyes', '品質', '精細眼睛', 'detailed eyes', 11),
    ];

class PromptBuilderApp extends StatefulWidget {
  const PromptBuilderApp({super.key});

  @override
  State<PromptBuilderApp> createState() => _PromptBuilderAppState();
}

class _PromptBuilderAppState extends State<PromptBuilderApp> {
  late final List<TagItem> _builtIns = _seedTags();
  late final List<TagItem> _supplemental = [
    ...supplementalTags,
    ...expandedPromptTags,
    ...objectCatalogTags,
    ...clothingTaxonomyTags,
    ...clothingDimensionTags,
    ...clothingOverallTags,
  ].map(_catalogTag).toList();
  late final List<TagItem> _scopedClothingTags = _createScopedClothingTags();
  final Set<String> _selectedIds = <String>{};
  final Map<int, Set<String>> _personSelectedIds = <int, Set<String>>{};
  // Legacy session bookkeeping. Animal features no longer add a furry/anthro
  // identity cue automatically; the user selects that identity explicitly.
  final Set<int> _autoFurryIdentityForPerson = <int>{};
  final Map<int, Set<String>> _removedCharacterTags = <int, Set<String>>{};
  final Map<int, String> _personTagQueries = <int, String>{};
  final Map<String, String> _personActiveGroups = <String, String>{};
  final Map<String, String> _pickerTagQueries = <String, String>{};
  final Map<String, TextEditingController> _pickerSearchControllers =
      <String, TextEditingController>{};
  final List<TagItem> _customTags = <TagItem>[];
  List<TagItem>? _allTagsCache;
  Map<String, TagItem>? _tagByIdCache;
  Map<String, TagItem>? _tagByEnglishCache;
  Map<String, List<TagItem>>? _tagsByGroupCache;
  Map<String, List<TagItem>>? _clothingBasesByDisplayGroupCache;
  Set<String>? _hiddenTaxonomyDuplicateIdsCache;
  List<TagItem>? _allClothingWearTagsCache;
  // Extra positive tags that the catalog does not know yet. Keep these in a
  // separate local list so they can be reviewed and added to the catalog later.
  final Set<String> _unregisteredPositiveTags = <String>{};
  final List<CatalogCharacter> _customCharacters = <CatalogCharacter>[];
  final Map<int, List<_RemoteAnime>> _remoteAnimeResults =
      <int, List<_RemoteAnime>>{};
  final Map<int, _RemoteAnime> _remoteAnimeSelection = <int, _RemoteAnime>{};
  final Map<int, List<_RemoteCharacter>> _remoteCharacters =
      <int, List<_RemoteCharacter>>{};
  final Set<int> _remoteLookupLoading = <int>{};
  final Map<int, String> _remoteLookupErrors = <int, String>{};
  final List<PersonSlot> _personSlots = <PersonSlot>[PersonSlot()];
  final List<String> _recentCharacterIds = <String>[];
  final List<Preset> _presets = <Preset>[];
  final List<PromptCombination> _combinations = <PromptCombination>[];
  final Map<int, Set<String>> _personCombinationIds = <int, Set<String>>{};
  final Map<String, _OutfitReferenceResolution> _outfitReferenceCache =
      <String, _OutfitReferenceResolution>{};
  final Map<String, TextEditingController> _personSearchControllers =
      <String, TextEditingController>{};
  final Map<int, GlobalKey> _stepKeys = <int, GlobalKey>{};
  final GlobalKey _pageScrollKey = GlobalKey(debugLabel: 'page-scroll');
  final GlobalKey _outputKey = GlobalKey(debugLabel: 'prompt-output');
  final ScrollController _pageScrollController = ScrollController();
  final TextEditingController _search = TextEditingController();
  final TextEditingController _globalTagSearch = TextEditingController();
  final TextEditingController _extraPositive = TextEditingController();
  final TextEditingController _sharedPoseExtra = TextEditingController();
  final TextEditingController _reversePrompt = TextEditingController();
  final TextEditingController _negative = TextEditingController(
    text: _defaultNegativeText,
  );
  final Map<String, String> _customNegativeTranslations = <String, String>{};
  final TextEditingController _preprompt = TextEditingController(
    text: 'masterpiece, best quality, newest, absurdres, highres',
  );
  Timer? _searchDebounce;
  Timer? _poseExtraDebounce;

  String _activeGroup = '全部';
  String _gender = '女性';
  String _model = 'Amanatsu 1.1';
  String _sampler = 'Euler a';
  int _steps = 28;
  String _cfg = '5.0';
  String _clipSkip = '2';
  int _peopleCount = 1;
  int _stepIndex = 0;
  int _globalSearchPersonIndex = 0;
  int _stepScrollTicket = 0;
  static const double _basePageBottomPadding = 24;
  double _pageBottomPadding = _basePageBottomPadding;
  String _globalTagQuery = '';
  bool _showAdult = false;
  bool _isPreparingCatalog = true;
  static const double _minimumPromptWeight = 0.50;
  static const double _maximumPromptWeight = 1.50;
  static const double _defaultPromptWeight = 1.05;

  List<TagItem> get _allTags {
    final cached = _allTagsCache;
    if (cached != null) return cached;
    final unique = <String, TagItem>{};
    for (final tag in [
      ..._builtIns,
      ..._supplemental,
      ..._scopedClothingTags,
      ..._customTags,
    ]) {
      final englishKey = _englishTagKey(tag.en);
      // The same prompt word (for example "black trim") is valid for every
      // clothing slot, so color groups must not be deduplicated together.
      final preserveClothingColorGroup = _isClothingColorGroup(tag.group);
      final preserveTaxonomyGarment = tag.id.startsWith('catalog_taxonomy_') &&
          _isClothingBaseGroup(tag.group);
      final key = englishKey.isEmpty
          ? 'id:${tag.id}'
          : (_isScopedClothingGroup(tag.group) ||
                  preserveClothingColorGroup ||
                  preserveTaxonomyGarment)
              ? 'en:$englishKey:${tag.group}'
              : 'en:$englishKey';
      unique.putIfAbsent(key, () => tag);
    }
    final tags = List<TagItem>.unmodifiable(unique.values);
    final byId = <String, TagItem>{};
    final byEnglish = <String, TagItem>{};
    final byGroup = <String, List<TagItem>>{};
    final clothingByDisplayGroup = <String, List<TagItem>>{};
    final allWear = <TagItem>[];
    final legacyClothingKeys = <String>{};

    for (final tag in tags) {
      byId.putIfAbsent(tag.id, () => tag);
      final englishKey = _englishTagKey(tag.en);
      if (englishKey.isNotEmpty) byEnglish.putIfAbsent(englishKey, () => tag);
      byGroup.putIfAbsent(tag.group, () => <TagItem>[]).add(tag);
      if (_isClothingBaseTag(tag)) {
        final displayGroup = _clothingBaseDisplayGroup(tag);
        clothingByDisplayGroup
            .putIfAbsent(displayGroup, () => <TagItem>[])
            .add(tag);
        if (!tag.id.startsWith('catalog_taxonomy_')) {
          legacyClothingKeys.add('$displayGroup:$englishKey');
        }
      }
      if (_scopedClothingKind(tag.group) == 'wear' ||
          tag.group == _legacyClothingWearGroup) {
        allWear.add(tag);
      }
    }

    _allTagsCache = tags;
    _tagByIdCache = byId;
    _tagByEnglishCache = byEnglish;
    _tagsByGroupCache = byGroup;
    _clothingBasesByDisplayGroupCache = clothingByDisplayGroup;
    _allClothingWearTagsCache = allWear;
    _hiddenTaxonomyDuplicateIdsCache = tags
        .where((tag) =>
            tag.id.startsWith('catalog_taxonomy_') &&
            _isClothingBaseTag(tag) &&
            legacyClothingKeys.contains(
                '${_clothingBaseDisplayGroup(tag)}:${_englishTagKey(tag.en)}'))
        .map((tag) => tag.id)
        .toSet();
    return tags;
  }

  void _invalidateTagCaches() {
    _allTagsCache = null;
    _tagByIdCache = null;
    _tagByEnglishCache = null;
    _tagsByGroupCache = null;
    _clothingBasesByDisplayGroupCache = null;
    _hiddenTaxonomyDuplicateIdsCache = null;
    _allClothingWearTagsCache = null;
    _outfitReferenceCache.clear();
  }

  Map<String, TagItem> get _tagsById {
    _allTags;
    return _tagByIdCache!;
  }

  Map<String, List<TagItem>> get _tagsByGroup {
    _allTags;
    return _tagsByGroupCache!;
  }

  /// Avoid showing the same English prompt token twice when legacy and newer
  /// catalogs both contain it. The first item keeps its existing ID so saved
  /// selections remain compatible.
  List<TagItem> _uniquePickerTags(Iterable<TagItem> tags) {
    final seen = <String>{};
    return tags
        .where((tag) => seen.add(_cleanTag(tag.en).toLowerCase()))
        .toList();
  }

  List<TagItem> _tagsForPickerGroup(String group) {
    _allTags;
    if (group == _staticFaceAppearanceGroup) {
      return (_tagsByGroupCache!['臉部特徵'] ?? const <TagItem>[])
          .where(_isStaticFaceAppearanceTag)
          .toList();
    }
    if (group == _objectInteractionGroup) {
      return _allTags.where(_isObjectInteractionTag).toList();
    }
    if (_isObjectPickerGroup(group)) {
      return _allTags
          .where((tag) => _objectPickerGroupForTag(tag) == group)
          .toList();
    }
    if (_clothingAccessoryPickerGroups.contains(group)) {
      return (_clothingBasesByDisplayGroupCache![_clothingGroupAccessory] ??
              const <TagItem>[])
          .where((tag) => _clothingAccessoryPickerGroup(tag) == group)
          .toList();
    }
    const clothingBaseGroups = {
      _clothingGroupTop,
      _clothingGroupPants,
      _clothingGroupShorts,
      _clothingGroupSkirt,
      _clothingGroupOnePiece,
      _clothingGroupOuterwear,
      _clothingGroupCostume,
      _clothingGroupUnderwear,
      _clothingGroupBra,
      _clothingGroupPanties,
      _clothingGroupSocks,
      _clothingGroupShoes,
      _clothingGroupAccessory,
    };
    if (clothingBaseGroups.contains(group)) {
      return _clothingBasesByDisplayGroupCache![group] ?? const <TagItem>[];
    }
    if (group == _allClothingWearGroup) {
      return _allClothingWearTagsCache!;
    }
    if (group == '髮型') {
      return <TagItem>[
        ...?_tagsByGroupCache!['髮型'],
        ...?_tagsByGroupCache!['髮色'],
      ];
    }
    if (group == '表情') {
      return _uniquePickerTags(<TagItem>[
        ...?_tagsByGroupCache!['表情'],
        ...?_tagsByGroupCache!['臉部特徵'],
      ].where(_isDynamicHeadActionTag));
    }
    if (_isExpressionPickerGroup(group)) {
      return _uniquePickerTags(<TagItem>[
        ...?_tagsByGroupCache!['表情'],
        ...?_tagsByGroupCache!['臉部特徵'],
      ].where((tag) => _expressionSubgroupForTag(tag) == group));
    }
    if (group == '動作') {
      return (_tagsByGroupCache!['動作'] ?? const <TagItem>[])
          .where((tag) => !_isObjectInteractionTag(tag))
          .toList();
    }
    return _tagsByGroupCache![group] ?? const <TagItem>[];
  }

  List<TagItem> _tagsForPickerGroups(Iterable<String> groups) {
    final unique = <String, TagItem>{};
    for (final group in groups) {
      for (final tag in _tagsForPickerGroup(group)) {
        unique.putIfAbsent(tag.id, () => tag);
      }
    }
    return _uniquePickerTags(unique.values);
  }

  List<CatalogCharacter> get _allCharacters =>
      [...catalogCharacters, ..._customCharacters];

  List<TagItem> get _selectedTags {
    final tags =
        _selectedIds.map((id) => _tagsById[id]).whereType<TagItem>().toList();
    tags.sort(_compareOutputTags);
    return tags;
  }

  List<String> get _sharedActionPickerGroups => <String>[
        '\u89aa\u543b\u52d5\u4f5c',
        '\u591a\u4eba\u4e92\u52d5',
        '\u8c93\u7cfb\u30fb\u4eba\u7269\u4e92\u52d5',
        '\u89d2\u8272\u59ff\u52e2',
        '\u6027\u884c\u70ba',
        '\u6027\u59ff\u52e2',
        ...expandedSexualPoseGroups,
        ...expandedSexualActGroups,
      ].toSet().toList();

  int _outputGroupOrder(String group) {
    if (group == _animalTraitGroup) return 18;
    if (group == _wingTypeGroup || _physicalTraitColorGroups.contains(group)) {
      return 18;
    }
    const order = <String, int>{
      // 人物：由頭部、臉部一路排到身體，再進入服裝。
      '角色類型': 8,
      '角色標籤': 9,
      '髮色': 10,
      '髮長': 11,
      '髮型': 12,
      '眼睛': 13,
      '臉部特徵': 14,
      '表情': 14,
      '額外特徵': 15,
      '額外特徵位置': 16,
      '額外特徵顏色': 17,
      '身體特徵': 18,
      '胸部': 19,
      '裸露': 19,
      // 服裝與配件：頭部 → 軀幹 → 下身 → 腿部 → 腳部。
      '配件': 20,
      '配件顏色': 21,
      '服裝': 22,
      '角色扮演': 23,
      '外套': 24,
      '外套顏色': 25,
      '上衣': 26,
      '上衣風格': 27,
      '上衣顏色': 28,
      '褲子': 29,
      '短褲': 29,
      '裙子': 29,
      '下身風格': 30,
      '下身顏色': 31,
      '內衣': 32,
      '內衣顏色': 33,
      '胸罩': 33,
      '胸罩顏色': 34,
      '內褲': 34,
      '內褲顏色': 35,
      '襪子': 36,
      '襪子顏色': 37,
      '鞋子': 38,
      '鞋子顏色': 39,
      _outfitMainStyleGroup: 40,
      _outfitSubStyleGroup: 40,
      _outfitMoodGroup: 41,
      _outfitOccasionGroup: 42,
      '服裝細節': 40,
      '服裝細節顏色': 41,
      '服裝材質': 41,
      '穿脫狀態': 42,
      '姿勢': 43,
      '性行為': 55,
      '性姿勢': 56,
      '動作': 50,
      '物件': 51,
      '成人道具': 57,
      _indoorSceneGroup: 70,
      _outdoorSceneGroup: 70,
      _outdoorTimeGroup: 71,
      _cameraFramingGroup: 72,
      _cameraFaceFocusGroup: 73,
      _cameraFocusGroup: 74,
      _cameraCropGroup: 75,
      '畫面': 76,
    };
    if (expandedAdultClothingGroups.contains(group)) return 36;
    if (expandedSexualActGroups.contains(group)) return 42;
    if (expandedSexualPoseGroups.contains(group)) return 43;
    if (expandedGeneralPoseGroups.contains(group)) {
      return switch (group) {
        '頭部姿勢' => 43,
        '手臂姿勢' => 44,
        '手部姿勢' || '手指・指向方向' || '手指・手勢形狀' || '手指・嘴臉互動' || '手指・細節動作' => 45,
        '軀幹姿勢' => 46,
        '腿部姿勢' => 47,
        '單人・站姿' ||
        '單人・靠牆姿勢' ||
        '站立與蹲姿' ||
        '單人・椅子坐姿' ||
        '單人・桌邊姿勢' ||
        '單人・地板坐姿' ||
        '單人・床上坐姿' ||
        '坐姿與跪姿' ||
        '單人・仰躺姿勢' ||
        '單人・側躺姿勢' ||
        '單人・俯臥姿勢' ||
        '單人・跪蹲姿勢' ||
        '躺臥姿勢' =>
          48,
        '全身姿勢' => 49,
        '動態姿勢' || '動作' || '身體動作' => 50,
        '物件' => 51,
        '親吻動作' || '多人互動' || '角色姿勢' => 52,
        _ => 53,
      };
    }
    if (expandedAdultToolGroups.contains(group)) return 46;
    return order[group] ?? 50;
  }

  int _compareOutputTags(TagItem a, TagItem b) {
    final groupOrder =
        _outputGroupOrder(a.group).compareTo(_outputGroupOrder(b.group));
    if (groupOrder != 0) return groupOrder;
    final catalogOrder = a.order.compareTo(b.order);
    return catalogOrder == 0 ? a.en.compareTo(b.en) : catalogOrder;
  }

  Set<String> _personTagIds(int index) =>
      _personSelectedIds.putIfAbsent(index, () => <String>{});

  List<TagItem> _selectedTagsForPerson(int index) {
    final ids = _personTagIds(index);
    final tags = ids.map((id) => _tagsById[id]).whereType<TagItem>().toList();
    tags.sort(_compareOutputTags);
    return tags;
  }

  bool _isClothingGroup(String group) =>
      _isScopedClothingGroup(group) ||
      const {
        '服裝',
        _cosplayGroup,
        '上衣',
        '上衣風格',
        '褲子',
        '短褲',
        '裙子',
        '外套',
        '特殊服裝',
        '下身風格',
        '內衣',
        '胸罩',
        '內褲',
        '襪子',
        '鞋子',
        '配件',
        '配件位置',
        '配件顏色',
        '帽子顏色',
        '眼鏡顏色',
        '內衣顏色',
        '胸罩顏色',
        '內褲顏色',
        '襪子顏色',
        '鞋子顏色',
        '外套顏色',
        '服裝顏色',
        '上衣顏色',
        '下身顏色',
        '服裝邊線色',
        '上衣邊線色',
        '下身邊線色',
        '內衣邊線色',
        '胸罩邊線色',
        '內褲邊線色',
        '襪子邊線色',
        '鞋子邊線色',
        '外套邊線色',
        '配件邊線色',
        '服裝細節',
        '服裝細節顏色',
        '服裝材質',
        '穿脫狀態',
        _outfitMainStyleGroup,
        _outfitSubStyleGroup,
        _outfitMoodGroup,
        _outfitOccasionGroup,
      }.contains(group) ||
      group.endsWith('邊線色');

  bool _isFaceExpressionTag(TagItem tag) =>
      tag.group == '臉部特徵' || tag.group == '表情';

  static const _staticFaceAppearanceIds = <String>{
    'face_fangs',
    'face_sharp_teeth',
    'face_horns',
    'face_elf_ears',
    'face_pointy_ears',
    'face_eyebrows',
    'face_lips',
  };

  /// These are permanent visual traits. All other face tags describe a
  /// momentary expression, gaze, mouth shape, or head action and belong to
  /// the pose workflow.
  bool _isStaticFaceAppearanceTag(TagItem tag) =>
      tag.group == '臉部特徵' && _staticFaceAppearanceIds.contains(tag.id);

  bool _isObjectInteractionTag(TagItem tag) =>
      tag.group == '動作' && tag.conflictGroup == 'object_interaction_mode';

  bool _isDynamicHeadActionTag(TagItem tag) =>
      tag.group == '表情' ||
      tag.group == '頭部姿勢' ||
      (tag.group == '臉部特徵' && !_isStaticFaceAppearanceTag(tag));

  bool _isFixedCharacterFeatureTag(TagItem tag) =>
      tag.group == _animalTraitGroup ||
      tag.group == _wingTypeGroup ||
      _physicalTraitColorGroups.contains(tag.group) ||
      const {
        '身體特徵',
        '眼睛',
        '額外特徵',
        '額外特徵位置',
        '額外特徵顏色',
        '髮長',
        '髮型',
        '髮色',
        '胸部',
        '裸露',
      }.contains(tag.group) ||
      _isStaticFaceAppearanceTag(tag);

  bool _isPoseWorkflowTag(TagItem tag) =>
      _isDynamicHeadActionTag(tag) ||
      const {'姿勢', '動作', '物件', '成人道具', '性行為', '性姿勢'}.contains(tag.group) ||
      expandedPickerTagGroups.contains(tag.group);

  bool _isObjectPickerGroup(String group) =>
      _objectPickerGroups.contains(group);

  bool _isObjectTag(TagItem tag) => tag.group == '物件';

  /// Maps both legacy and new object IDs into visual picker sections while
  /// keeping their stored group as 物件 for saved prompts and interactions.
  String? _objectPickerGroupForTag(TagItem tag) {
    if (!_isObjectTag(tag)) return null;
    final id = tag.id;
    if (id.startsWith('obj_furniture_') ||
        const {
          'object_pillow',
          'object_cushion',
          'object_chair',
          'object_sofa',
          'object_bed',
          'object_table',
        }.contains(id)) {
      return _objectFurnitureGroup;
    }
    if (id.startsWith('obj_food_') ||
        const {
          'object_water_bottle',
          'object_cup',
          'object_mug',
          'object_plate',
          'object_omelet_rice',
          'object_fork',
          'object_spoon',
          'object_chopsticks',
        }.contains(id)) {
      return _objectDiningGroup;
    }
    if (id.startsWith('obj_study_') ||
        const {
          'object_book',
          'object_notebook',
          'object_pen',
          'object_pencil',
          'object_microphone',
          'object_guitar',
          'object_violin',
          'object_piano',
          'object_paintbrush',
          'object_palette',
        }.contains(id)) {
      return _objectStudyGroup;
    }
    if (id.startsWith('obj_tech_') ||
        const {
          'object_camera',
          'object_smartphone',
          'object_laptop',
          'object_tablet',
          'object_headphones',
        }.contains(id)) {
      return _objectTechGroup;
    }
    if (id.startsWith('obj_sport_') ||
        const {
          'object_basketball',
          'object_soccer_ball',
          'object_volleyball',
          'object_baseball',
          'object_baseball_bat',
          'object_tennis_racket',
          'object_badminton_racket',
          'object_skateboard',
          'object_bicycle',
          'object_scooter',
          'object_yumi_bow',
          'object_japanese_longbow',
          'object_archery_target',
          'object_mato_target',
        }.contains(id)) {
      return _objectSportGroup;
    }
    if (id.startsWith('obj_tool_')) return _objectToolGroup;
    if (id.startsWith('obj_fantasy_') ||
        const {
          'object_bow',
          'object_arrow',
          'object_sword',
          'object_staff',
          'object_magic_wand',
          'object_shield',
        }.contains(id)) {
      return _objectFantasyGroup;
    }
    if (id.startsWith('obj_travel_') ||
        const {
          'object_backpack',
          'object_handbag',
          'object_briefcase',
          'object_motorcycle',
          'object_horse',
          'object_car',
        }.contains(id)) {
      return _objectTravelGroup;
    }
    return _objectDailyGroup;
  }

  bool _isExpressionPickerGroup(String group) => const {
        _expressionEyesGroup,
        _expressionMouthGroup,
        _expressionTeasingGroup,
        _expressionSymbolGroup,
        _expressionOtherGroup,
      }.contains(group);

  String? _expressionSubgroupForTag(TagItem tag) {
    if (!_isDynamicHeadActionTag(tag)) return null;

    final english = tag.en.toLowerCase();
    const symbolExpressions = <String>{
      '>_<',
      '@_@',
      '^^^',
      '^_^',
      'o_o',
      'x_x',
      'v',
      ';3',
      ':3',
      '3:',
      'spoken squiggle',
      'anger vein',
      'facial mark',
    };
    if (symbolExpressions.contains(english)) {
      return _expressionSymbolGroup;
    }
    const teasingExpressions = <String>{
      'seductive expression',
      'seductive smile',
      'naughty face',
      'licking lips',
      'smug',
      'smirk',
      'evil smile',
    };
    if (teasingExpressions.contains(english)) {
      return _expressionTeasingGroup;
    }

    final conflict = tag.conflictGroup;
    if (const {'eyes', 'expression_eyes'}.contains(conflict)) {
      return _expressionEyesGroup;
    }
    if (const {
      'mouth',
      'expression_mouth',
      'mouth_shape',
      'expression_mouth_shape',
      'expression_mouth_absence',
    }.contains(conflict)) {
      return _expressionMouthGroup;
    }

    // Some imported/custom tags do not carry a conflict group.  Keep the
    // classification stable by using the English Danbooru-style tag name.
    const mouthTerms = <String>[
      'mouth',
      'smile',
      'grin',
      'smirk',
      'pout',
      'lip',
      'tongue',
      'fang',
      'teeth',
      'drool',
      'saliva',
      'exhaling',
      'scream',
      'shout',
      'yawn',
      'whistle',
      'kiss',
    ];
    if (mouthTerms.any((term) => english.contains(term))) {
      return _expressionMouthGroup;
    }

    const eyeTerms = <String>[
      'eye',
      'wink',
      'tear',
      'cry',
      'gaze',
      'look',
      'glance',
      'stare',
      'pupil',
      'brow',
      'eyebrow',
    ];
    if (eyeTerms.any((term) => english.contains(term))) {
      return _expressionEyesGroup;
    }

    return _expressionOtherGroup;
  }

  bool _isScopedClothingColorGroup(String group) =>
      _isScopedClothingGroup(group) &&
      _scopedClothingKind(group) == 'detail_color';

  bool _isClothingColorGroup(String group) =>
      _isScopedClothingColorGroup(group) ||
      const {
        '眼睛',
        '髮色',
        '服裝顏色',
        '上衣顏色',
        '下身顏色',
        '內衣顏色',
        '胸罩顏色',
        '內褲顏色',
        '襪子顏色',
        '鞋子顏色',
        '外套顏色',
        '配件顏色',
        '帽子顏色',
        '眼鏡顏色',
        _animalEarColorGroup,
        _animalTailColorGroup,
        _animalHandColorGroup,
        _animalFootColorGroup,
        _wingColorGroup,
        '服裝細節顏色',
      }.contains(group) ||
      group.endsWith('邊線色') ||
      group == '額外特徵顏色';

  bool _isClothingBaseGroup(String group) => const {
        '服裝',
        '上衣',
        '褲子',
        '短褲',
        '裙子',
        '外套',
        '特殊服裝',
        '內衣',
        '胸罩',
        '內褲',
        '襪子',
        '鞋子',
        '配件',
      }.contains(group);

  bool _isClothingBaseTag(TagItem tag) {
    if (!_isClothingBaseGroup(tag.group)) return false;
    const styleOnlyIds = {
      'bra_underwire',
      'bra_push_up',
      'bra_bralette',
      'bra_triangle',
      'bra_racerback',
      'bra_front_clasp',
      'lace_panties',
      'cotton_panties',
      'highwaist_panties',
      'lowrise_panties',
      'boyshorts',
      'cheeky_panties',
      'side_tie_panties',
      'leg_warmers',
      'crew_socks',
      'over_knee_socks',
      'toe_socks',
      'tabi_socks',
      'ankle_boots',
      'knee_high_boots',
      'mary_janes',
      'pumps',
      'platform_shoes',
      'flip_flops',
      'slippers',
      'geta',
      'roller_skates',
    };
    final tagKey = tag.id.startsWith('catalog_')
        ? tag.id.substring('catalog_'.length)
        : tag.id;
    return !styleOnlyIds.contains(tagKey);
  }

  String _clothingBaseDisplayGroup(TagItem tag) {
    if (tag.group == _clothingGroupShorts ||
        (tag.group == _clothingGroupPants &&
            RegExp(r'\b(shorts|hot pants|bloomers)\b', caseSensitive: false)
                .hasMatch(tag.en))) {
      return _clothingGroupShorts;
    }
    if (tag.group == _clothingGroupOuterwear ||
        ((tag.group == _clothingGroupTop ||
                tag.group == _clothingGroupOnePiece) &&
            RegExp(
              r'\b(jacket|coat|blazer|cape|cloak|shawl|raincoat|lab coat)\b',
              caseSensitive: false,
            ).hasMatch(tag.en))) {
      return _clothingGroupOuterwear;
    }
    if (tag.group == _clothingGroupCostume ||
        tag.group == _cosplayGroup ||
        (tag.group == _clothingGroupOnePiece &&
            RegExp(
              r'\b(uniform|kimono|yukata|hakama|kyudo|miko|ninja|maid|nurse|police|military|cheerleading|gymnastics|swimsuit|bikini|wedding dress)\b',
              caseSensitive: false,
            ).hasMatch(tag.en))) {
      return _clothingGroupCostume;
    }
    return tag.group;
  }

  bool _isLegacyClothingStyleTag(TagItem tag) => const {
        'bra_underwire',
        'bra_push_up',
        'bra_bralette',
        'bra_triangle',
        'bra_racerback',
        'bra_front_clasp',
        'lace_panties',
        'cotton_panties',
        'highwaist_panties',
        'lowrise_panties',
        'boyshorts',
        'cheeky_panties',
        'side_tie_panties',
        'leg_warmers',
        'crew_socks',
        'over_knee_socks',
        'toe_socks',
        'tabi_socks',
        'ankle_boots',
        'knee_high_boots',
        'mary_janes',
        'pumps',
        'platform_shoes',
        'flip_flops',
        'slippers',
        'geta',
        'roller_skates',
      }.contains(tag.id.startsWith('catalog_')
          ? tag.id.substring('catalog_'.length)
          : tag.id);

  bool _isCosplayTag(TagItem tag) => tag.group == _cosplayGroup;

  bool _isOnePieceStyleTag(TagItem tag) =>
      (_scopedClothingKind(tag.group) == 'style' &&
          _scopedClothingSlot(tag.group) == 'onepiece') ||
      _isCosplayTag(tag);

  String? _clothingScopeForBase(TagItem tag) {
    final displayGroup = _clothingBaseDisplayGroup(tag);
    if (displayGroup == _clothingGroupShorts) return 'shorts';
    if (displayGroup == _clothingGroupOuterwear) return 'outerwear';
    if (displayGroup == _clothingGroupCostume) return 'costume';
    final scopedKind = _scopedClothingKind(tag.group);
    if (scopedKind == 'style') return _scopedClothingSlot(tag.group);
    if (!_isClothingBaseTag(tag) && !_isLegacyClothingStyleTag(tag))
      return null;
    if (tag.group == _clothingGroupTop) return 'top';
    if (tag.group == _clothingGroupPants) return 'pants';
    if (tag.group == _clothingGroupShorts) return 'shorts';
    if (tag.group == _clothingGroupSkirt) return 'skirt';
    if (tag.group == _clothingGroupOnePiece) return 'onepiece';
    if (tag.group == _clothingGroupOuterwear) return 'outerwear';
    if (tag.group == _clothingGroupCostume) return 'costume';
    if (tag.group == _clothingGroupUnderwear) return 'underwear';
    if (tag.group == _clothingGroupBra) return 'bra';
    if (tag.group == _clothingGroupPanties) return 'panties';
    if (tag.group == _clothingGroupSocks) return 'socks';
    if (tag.group == _clothingGroupShoes) return 'shoes';
    if (tag.group == _clothingGroupAccessory) return 'accessory';
    return null;
  }

  List<TagItem> _clothingDesignBases(Iterable<TagItem> tags) {
    final selected = tags.toList();
    final bases = selected.where(_isClothingBaseTag).toList();
    if (bases.isEmpty) {
      bases.addAll(selected.where(_isCosplayTag));
    }
    if (bases.isEmpty) {
      // A scoped style can stand on its own (for example, selecting only
      // "high heel shoes" plus a shoe color). Treat it as the garment noun
      // so the color is composed into the same output tag.
      bases.addAll(
          selected.where((tag) => _scopedClothingKind(tag.group) == 'style'));
    }
    final fallbackStyles =
        selected.where(_isLegacyClothingStyleTag).where((tag) {
      final scope = _clothingScopeForBase(tag);
      return scope != null &&
          !bases.any((base) => _clothingScopeForBase(base) == scope);
    }).toList();
    return [...bases, ...fallbackStyles]..sort(_compareClothingBasesForOutput);
  }

  int _clothingBaseHeadToFootOrder(TagItem tag) {
    final scope = _clothingScopeForBase(tag);
    if (scope == 'accessory') {
      return switch (_clothingAccessoryPickerGroup(tag)) {
        _clothingGroupHat => 0,
        _clothingGroupHeadAccessory => 1,
        _clothingGroupHairAccessory => 2,
        _clothingGroupEyewear => 3,
        _clothingGroupFaceAccessory => 4,
        _clothingGroupAnimalAccessory => 5,
        _clothingGroupNeckAccessory => 6,
        _clothingGroupHandAccessory => 7,
        _clothingGroupWaistAccessory => 8,
        _clothingGroupOtherAccessory => 9,
        _ => 9,
      };
    }
    return switch (scope) {
      'outerwear' => 10,
      'top' => 11,
      'onepiece' || 'costume' => 12,
      'pants' => 13,
      'shorts' => 14,
      'skirt' => 15,
      'underwear' => 16,
      'bra' => 17,
      'panties' => 18,
      'socks' => 19,
      'shoes' => 20,
      _ => 99,
    };
  }

  int _compareClothingBasesForOutput(TagItem a, TagItem b) {
    final headToFoot = _clothingBaseHeadToFootOrder(a)
        .compareTo(_clothingBaseHeadToFootOrder(b));
    if (headToFoot != 0) return headToFoot;
    return _compareOutputTags(a, b);
  }

  /// Keeps each garment's generated prompt phrases in a distinct block.
  /// Accessories have one shared data scope, so split them again by their
  /// head-to-foot picker category (hair accessory, eyewear, neck accessory,
  /// and so on) instead of merging every accessory into one parenthesis.
  String _clothingPromptBlockKey(String scope, TagItem base) {
    if (scope != 'accessory') return scope;
    return 'accessory:${_clothingAccessoryPickerGroup(base)}';
  }

  String? _clothingScopeForTag(TagItem tag) {
    if (_isScopedClothingGroup(tag.group)) {
      return _scopedClothingSlot(tag.group);
    }
    if (_isClothingBaseTag(tag) || _isLegacyClothingStyleTag(tag)) {
      return _clothingScopeForBase(tag);
    }
    if (_isCosplayTag(tag)) return 'costume';
    if (_isOnePieceStyleTag(tag)) return 'onepiece';
    if (tag.group == _legacyClothingDetailGroup ||
        tag.group == _legacyClothingMaterialGroup ||
        tag.group == _legacyClothingWearGroup) {
      return null;
    }
    if (tag.group == _clothingGroupTop) return 'top';
    if (tag.group == _clothingGroupPants) return 'pants';
    if (tag.group == _clothingGroupShorts) return 'shorts';
    if (tag.group == _clothingGroupSkirt) return 'skirt';
    if (tag.group == _clothingGroupOnePiece) return 'onepiece';
    if (tag.group == _clothingGroupOuterwear) return 'outerwear';
    if (tag.group == _clothingGroupCostume) return 'costume';
    if (tag.group == _clothingGroupUnderwear) return 'underwear';
    if (tag.group == _clothingGroupBra) return 'bra';
    if (tag.group == _clothingGroupPanties) return 'panties';
    if (tag.group == _clothingGroupSocks) return 'socks';
    if (tag.group == _clothingGroupShoes) return 'shoes';
    if (tag.group == _clothingGroupAccessory) return 'accessory';
    return _clothingScopeForBase(tag);
  }

  List<String> _clothingStyleGroupsForBase(TagItem base) {
    final scope = _clothingScopeForBase(base);
    if (scope == null) return const <String>[];
    final groups = <String>[_scopedClothingGroup(scope, 'style')];
    if (scope == 'top') groups.add('\u4E0A\u8863\u98A8\u683C');
    if (scope == 'pants' || scope == 'skirt') {
      groups.add('\u4E0B\u8EAB\u98A8\u683C');
    }
    if (scope == 'onepiece' || scope == 'costume') {
      groups.add(_cosplayGroup);
    }
    return groups;
  }

  List<String> _clothingDetailGroupsForBase(TagItem base) {
    final scope = _clothingScopeForBase(base);
    if (scope == null) return const <String>[];
    final groups = <String>[
      _scopedClothingGroup(scope, 'cut'),
      _scopedClothingGroup(scope, 'fit'),
      _scopedClothingGroup(scope, 'length'),
      _scopedClothingGroup(scope, 'material'),
      _scopedClothingGroup(scope, 'detail'),
      _scopedClothingGroup(scope, 'detail_color'),
      _scopedClothingGroup(scope, 'pattern'),
    ];
    final colorGroup = _clothingColorGroupForBase(base);
    final trimColorGroup = _clothingTrimColorGroupForBase(base);
    if (colorGroup != null) groups.add(colorGroup);
    if (trimColorGroup != null) groups.add(trimColorGroup);
    return groups;
  }

  List<String> _clothingWearGroupsForBase(TagItem base) {
    final scope = _clothingScopeForBase(base);
    return scope == null
        ? const <String>[]
        : <String>[_scopedClothingGroup(scope, 'wear')];
  }

  Set<String> _clothingDependentGroupsForBase(TagItem base) => <String>{
        ..._clothingStyleGroupsForBase(base),
        ..._clothingDetailGroupsForBase(base),
        ..._clothingWearGroupsForBase(base),
        if (_clothingScopeForBase(base) == 'accessory') '配件位置',
      };

  void _removeOrphanedClothingConfiguration(
    Set<String> selectedIds,
    TagItem removedBase,
  ) {
    if (!_isClothingBaseTag(removedBase)) return;
    final removedScope = _clothingScopeForBase(removedBase);
    if (removedScope == null) return;

    final remainingBases = selectedIds
        .map((id) => _tagsById[id])
        .whereType<TagItem>()
        .where(_isClothingBaseTag)
        .toList();
    if (remainingBases
        .any((base) => _clothingScopeForBase(base) == removedScope)) {
      return;
    }

    final groupsToRemove = _clothingDependentGroupsForBase(removedBase);
    final groupsStillUsed =
        remainingBases.expand(_clothingDependentGroupsForBase).toSet();
    groupsToRemove.removeAll(groupsStillUsed);
    if (remainingBases.isEmpty) {
      groupsToRemove.addAll(const {
        _legacyClothingDetailGroup,
        _legacyClothingMaterialGroup,
        _legacyClothingWearGroup,
        _outfitMainStyleGroup,
        _outfitSubStyleGroup,
        _outfitMoodGroup,
        _outfitOccasionGroup,
      });
    }
    selectedIds.removeWhere((id) {
      final selected = _tagsById[id];
      return selected != null && groupsToRemove.contains(selected.group);
    });
  }

  /// A garment noun and each colour channel describe one concrete value for a
  /// garment slot, so those values replace the previous selection. Design
  /// dimensions (style, cut, fit, length, material, detail, and pattern) are
  /// intentionally composable and may be selected more than once.
  String? _editableClothingSelectionKey(TagItem tag) {
    if (!_isClothingGroup(tag.group)) return null;

    final scope = _clothingScopeForTag(tag);
    final kind = _scopedClothingKind(tag.group);
    if (scope != null && kind == 'detail_color') {
      return '$scope:$kind';
    }

    if (_isClothingBaseTag(tag)) {
      final baseScope = _clothingScopeForBase(tag);
      // Accessories are independent wearable/decorative pieces. Returning a
      // shared "accessory:base" key made selecting a tail decoration remove
      // cat ears (and likewise prevented hats, glasses, jewellery, and wings
      // from coexisting). Their colour channels still keep their own
      // replacement keys, but the accessory nouns themselves are multi-select.
      if (baseScope == 'accessory') return null;
      return baseScope == null ? null : '$baseScope:base';
    }

    // Legacy colour/style groups remain in saved prompts and older custom
    // combinations.  Their conflict key is the stable way to replace only
    // the matching component (for example top_color or shoes_trim_color).
    final conflict = _conflictGroup(tag);
    if (conflict == null) return null;
    if (conflict == 'clothing_color' ||
        conflict.endsWith('_color') ||
        conflict.endsWith('_trim_color') ||
        conflict.endsWith('_detail_color')) {
      return 'legacy:$conflict';
    }
    return null;
  }

  List<TagItem> _clothingEditingReplacements(
    TagItem incoming,
    Iterable<TagItem> current,
  ) {
    final key = _editableClothingSelectionKey(incoming);
    if (key == null) return const <TagItem>[];

    final incomingBaseScope =
        _isClothingBaseTag(incoming) ? _clothingScopeForBase(incoming) : null;
    return current.where((existing) {
      if (existing.id == incoming.id) return false;
      if (incomingBaseScope != null &&
          incomingBaseScope != 'accessory' &&
          _isClothingBaseTag(existing) &&
          _clothingScopeForBase(existing) == incomingBaseScope) {
        return true;
      }
      return _editableClothingSelectionKey(existing) == key;
    }).toList();
  }

  bool _isClothingCombinationId(String combinationId) =>
      outfitReferencePresets
          .any((preset) => preset.combinationId == combinationId) ||
      _combinations.any((combination) =>
          combination.id == combinationId &&
          _isClothingCombinationTags(_combinationTags(combination)));

  void _markClothingTemplateCustomized(int personIndex) {
    _personCombinationIds[personIndex]?.removeWhere(_isClothingCombinationId);
  }

  String? _clothingColorGroup(String group) {
    final scopedSlot = _scopedClothingSlot(group);
    if (scopedSlot != null) {
      return switch (scopedSlot) {
        'onepiece' => '服裝顏色',
        'top' => '上衣顏色',
        'pants' || 'shorts' || 'skirt' => '下身顏色',
        'outerwear' => '外套顏色',
        'costume' => '服裝顏色',
        'underwear' => '內衣顏色',
        'bra' => '胸罩顏色',
        'panties' => '內褲顏色',
        'socks' => '襪子顏色',
        'shoes' => '鞋子顏色',
        'accessory' => '配件顏色',
        _ => null,
      };
    }
    if (group == '服裝' || group == _cosplayGroup || group == '特殊服裝') {
      return '服裝顏色';
    }
    if (group == '上衣') return '上衣顏色';
    if (group == '褲子' || group == '短褲' || group == '裙子') {
      return '下身顏色';
    }
    if (group == '外套') return '外套顏色';
    if (group == '內衣') return '內衣顏色';
    if (group == '胸罩') return '胸罩顏色';
    if (group == '內褲') return '內褲顏色';
    if (group == '襪子') return '襪子顏色';
    if (group == '鞋子') return '鞋子顏色';
    if (group == '配件') return '配件顏色';
    return null;
  }

  String? _clothingTrimColorGroup(String group) {
    final scopedSlot = _scopedClothingSlot(group);
    if (scopedSlot != null) {
      return switch (scopedSlot) {
        'onepiece' => '服裝邊線色',
        'top' => '上衣邊線色',
        'pants' || 'shorts' || 'skirt' => '下身邊線色',
        'outerwear' => '外套邊線色',
        'costume' => '服裝邊線色',
        'underwear' => '內衣邊線色',
        'bra' => '胸罩邊線色',
        'panties' => '內褲邊線色',
        'socks' => '襪子邊線色',
        'shoes' => '鞋子邊線色',
        'accessory' => '配件邊線色',
        _ => null,
      };
    }
    if (group == '服裝' || group == _cosplayGroup || group == '特殊服裝') {
      return '服裝邊線色';
    }
    if (group == '上衣') return '上衣邊線色';
    if (group == '褲子' || group == '短褲' || group == '裙子') {
      return '下身邊線色';
    }
    if (group == '外套') return '外套邊線色';
    if (group == '內衣') return '內衣邊線色';
    if (group == '胸罩') return '胸罩邊線色';
    if (group == '內褲') return '內褲邊線色';
    if (group == '襪子') return '襪子邊線色';
    if (group == '鞋子') return '鞋子邊線色';
    if (group == '配件') return '配件邊線色';
    return null;
  }

  String? _clothingColorGroupForBase(TagItem base) =>
      switch (_clothingScopeForBase(base)) {
        'onepiece' || 'costume' => '服裝顏色',
        'top' => '上衣顏色',
        'pants' || 'shorts' || 'skirt' => '下身顏色',
        'outerwear' => '外套顏色',
        'underwear' => '內衣顏色',
        'bra' => '胸罩顏色',
        'panties' => '內褲顏色',
        'socks' => '襪子顏色',
        'shoes' => '鞋子顏色',
        'accessory' => switch (_clothingAccessoryPickerGroup(base)) {
            _clothingGroupHat => '帽子顏色',
            _clothingGroupEyewear => '眼鏡顏色',
            _ => '配件顏色',
          },
        _ => _clothingColorGroup(base.group),
      };

  String? _clothingTrimColorGroupForBase(TagItem base) =>
      switch (_clothingScopeForBase(base)) {
        'onepiece' || 'costume' => '服裝邊線色',
        'top' => '上衣邊線色',
        'pants' || 'shorts' || 'skirt' => '下身邊線色',
        'outerwear' => '外套邊線色',
        'underwear' => '內衣邊線色',
        'bra' => '胸罩邊線色',
        'panties' => '內褲邊線色',
        'socks' => '襪子邊線色',
        'shoes' => '鞋子邊線色',
        'accessory' => switch (_clothingAccessoryPickerGroup(base)) {
            _clothingGroupHat => '帽子邊線色',
            _clothingGroupEyewear => '眼鏡邊線色',
            _ => '配件邊線色',
          },
        _ => _clothingTrimColorGroup(base.group),
      };

  String _betterWaifuTrimEnglish(TagItem tag) {
    // BetterWaifu's animal-content check can interpret the color word
    // "coral" as the marine animal. Keep the Chinese meaning, but use a
    // color-only English phrase for the generated prompt.
    if (tag.en.trim().toLowerCase() == 'coral trim') {
      return 'pink-orange trim';
    }
    return tag.en.trim();
  }

  String? _accessoryPositionGroup(String group) =>
      group == '配件' ? '配件位置' : null;

  String? _clothingStyleGroup(String group) {
    if (group == '上衣') return '上衣風格';
    if (group == '褲子' || group == '裙子') return '下身風格';
    return null;
  }

  static const _clothingColorNames = <String>[
    'midnight blue',
    'sapphire blue',
    'cobalt blue',
    'powder blue',
    'royal blue',
    'steel blue',
    'pastel blue',
    'sky blue',
    'light blue',
    'dark blue',
    'navy blue-black',
    'wine red',
    'mustard yellow',
    'lemon yellow',
    'forest green',
    'emerald green',
    'mint green',
    'sage green',
    'light green',
    'dark green',
    'light yellow',
    'dark yellow',
    'light pink',
    'dark pink',
    'hot pink',
    'light red',
    'dark red',
    'light gray',
    'dark gray',
    'slate gray',
    'pewter',
    'jet black',
    'off-black',
    'light brown',
    'dark brown',
    'rose gold',
    'multicolored',
    'blonde',
    'black',
    'white',
    'crimson',
    'scarlet',
    'maroon',
    'burgundy',
    'coral',
    'navy',
    'turquoise',
    'teal',
    'azure',
    'purple',
    'pink',
    'magenta',
    'lavender',
    'lilac',
    'rose',
    'red',
    'blue',
    'aqua',
    'green',
    'lime',
    'olive',
    'yellow',
    'golden',
    'amber',
    'peach',
    'salmon',
    'brown',
    'gray',
    'charcoal',
    'ebony',
    'coffee',
    'tan',
    'camel',
    'chocolate',
    'chestnut',
    'khaki',
    'taupe',
    'copper',
    'ivory',
    'cream',
    'beige',
    'gold',
    'silver',
    'orange',
  ];

  List<String> _clothingColorWords(TagItem tag) {
    final value = tag.en.trim().toLowerCase();
    final matches = <_ColorMatch>[];
    for (final color in _clothingColorNames) {
      final match = RegExp(
        r'(^|\s)' + RegExp.escape(color) + r'(?=\s|$)',
      ).firstMatch(value);
      if (match == null) continue;
      matches.add(_ColorMatch(
        color,
        match.start + (match.group(1)?.length ?? 0),
      ));
    }
    matches.sort((a, b) {
      final start = a.start.compareTo(b.start);
      return start == 0 ? b.word.length.compareTo(a.word.length) : start;
    });
    return matches
        .where((match) => !matches.any((other) =>
            other.word.length > match.word.length &&
            other.start <= match.start &&
            other.start + other.word.length >= match.start + match.word.length))
        .map((match) => match.word)
        .toList();
  }

  String? _clothingColorWord(TagItem tag) {
    final words = _clothingColorWords(tag);
    if (words.isNotEmpty) return words.first;
    final value = tag.en.trim().toLowerCase();
    return value.isEmpty ? null : value.split(' ').first;
  }

  bool _isColorPickerTag(TagItem tag) {
    if (tag.group == '髮色') return true;
    if (tag.group == '眼睛') return tag.conflictGroup == 'eye_color';
    return _isClothingColorGroup(tag.group);
  }

  String _clothingColorPrefix(TagItem tag) {
    final words = _clothingColorWords(tag);
    if (words.isNotEmpty) return words.join(' and ');
    return _clothingColorWord(tag) ?? '';
  }

  String _clothingColorChinesePrefix(TagItem tag) {
    const colors = <String, String>{
      'multicolored': '多彩',
      'black': '黑色',
      'white': '白色',
      'red': '紅色',
      'blue': '藍色',
      'aqua': '水藍色',
      'pink': '粉紅色',
      'purple': '紫色',
      'green': '綠色',
      'yellow': '黃色',
      'brown': '棕色',
      'gray': '灰色',
      'gold': '金色',
      'silver': '銀色',
      'orange': '橘色',
    };
    final words = _clothingColorWords(tag);
    if (words.isEmpty) return tag.zh;
    return words
        .map((word) => _promptColorChinese[word] ?? colors[word] ?? word)
        .join('與');
  }

  String _clothingColorChoiceKey(TagItem tag) {
    final colors = _clothingColorWords(tag);
    if (colors.isNotEmpty) return colors.join('|');
    return _englishTagKey(_clothingColorPrefix(tag));
  }

  bool _isSameClothingColorChoice(TagItem first, TagItem second) =>
      _clothingColorChoiceKey(first) == _clothingColorChoiceKey(second);

  TagItem? _selectedClothingColorForGroup(
    Iterable<TagItem> selected,
    String? group,
  ) {
    if (group == null) return null;
    for (final tag in selected) {
      if (tag.group == group && _isColorPickerTag(tag)) return tag;
    }
    return null;
  }

  TagItem? _matchingClothingColorForGroup(String? group, TagItem source) {
    if (group == null) return null;
    for (final tag in _tagsByGroup[group] ?? const <TagItem>[]) {
      if (_isColorPickerTag(tag) && _isSameClothingColorChoice(tag, source)) {
        return tag;
      }
    }
    return null;
  }

  List<TagItem> _clothingColorChoices(
    String? mainGroup,
    String? secondaryGroup,
  ) {
    final choices = <TagItem>[];
    final seen = <String>{};
    for (final group in [mainGroup, secondaryGroup].whereType<String>()) {
      for (final tag in _tagsByGroup[group] ?? const <TagItem>[]) {
        if (!_isColorPickerTag(tag)) continue;
        if (seen.add(_clothingColorChoiceKey(tag))) choices.add(tag);
      }
    }
    choices.sort(_compareOutputTags);
    return choices;
  }

  void _clearClothingColorSlot(int personIndex, String? group) {
    if (personIndex < 0 ||
        personIndex >= _personSlots.length ||
        group == null) {
      return;
    }
    setState(() {
      _personTagIds(personIndex)
          .removeWhere((id) => _tagsById[id]?.group == group);
      _markClothingTemplateCustomized(personIndex);
      _persist();
    });
  }

  /// Clothing uses the same ordered two-colour interaction as hair gradients:
  /// the first picked colour is slot 1 and the next is slot 2. Their generated
  /// wording remains garment-aware: slot 1 is the main colour, slot 2 is trim.
  void _toggleClothingColorPair(
    int personIndex,
    String? mainGroup,
    String? secondaryGroup,
    TagItem choice,
  ) {
    if (personIndex < 0 ||
        personIndex >= _personSlots.length ||
        mainGroup == null ||
        secondaryGroup == null) {
      return;
    }
    final selected = _selectedTagsForPerson(personIndex);
    final main = _selectedClothingColorForGroup(selected, mainGroup);
    final secondary = _selectedClothingColorForGroup(selected, secondaryGroup);
    final isMain = main != null && _isSameClothingColorChoice(main, choice);
    final isSecondary =
        secondary != null && _isSameClothingColorChoice(secondary, choice);

    setState(() {
      final target = _personTagIds(personIndex);
      if (isSecondary) {
        target.removeWhere((id) => _tagsById[id]?.group == secondaryGroup);
      } else if (isMain) {
        target.removeWhere((id) => _tagsById[id]?.group == mainGroup);
      } else {
        final destination = main == null ? mainGroup : secondaryGroup;
        final matched = _matchingClothingColorForGroup(destination, choice);
        if (matched != null) {
          target.removeWhere((id) => _tagsById[id]?.group == destination);
          target.add(matched.id);
        }
      }
      _markClothingTemplateCustomized(personIndex);
      _persist();
    });
  }

  int _clothingColorOrderForTag(TagItem tag) {
    if (tag.group.endsWith('邊線色')) return 2;
    const mainColorGroups = <String>{
      '服裝顏色',
      '上衣顏色',
      '下身顏色',
      '內衣顏色',
      '胸罩顏色',
      '內褲顏色',
      '襪子顏色',
      '鞋子顏色',
      '外套顏色',
      '配件顏色',
      '帽子顏色',
      '眼鏡顏色',
    };
    return mainColorGroups.contains(tag.group) ? 1 : 0;
  }

  String _clothingModifierEnglish(TagItem tag) {
    final value = tag.en.trim();
    final scopedKind = _scopedClothingKind(tag.group);
    final scopedSlot = _scopedClothingSlot(tag.group);
    if (scopedKind == 'wear' || scopedKind == 'detail_color') return '';
    if (scopedKind != null && scopedSlot != null) {
      final noun = RegExp.escape(_clothingScopeNoun(scopedSlot));
      if (scopedKind == 'style') {
        return value.replaceFirst(
            RegExp(r'\s+(?:style\s+)?' + noun + r'$', caseSensitive: false),
            '');
      }
      return value.replaceFirst(
          RegExp(
              r'\s+' +
                  scopedKind.replaceAll('_', r'\s+') +
                  r'\s+' +
                  noun +
                  r'$',
              caseSensitive: false),
          '');
    }
    const simple = <String, String>{
      'lace trim': 'lace',
      'see-through clothing': 'see-through',
      'sheer fabric': 'sheer',
    };
    final normalized = simple[value.toLowerCase()];
    if (normalized != null) return normalized;
    if (_isLegacyClothingStyleTag(tag)) {
      for (final suffix in const [
        ' bra',
        ' panties',
        ' socks',
        ' shoes',
        ' boots'
      ]) {
        if (value.toLowerCase().endsWith(suffix)) {
          return value.substring(0, value.length - suffix.length);
        }
      }
    }
    if (tag.group == '上衣風格' || tag.group == '下身風格') {
      return value.replaceFirst(
          RegExp(r'\s+(?:style\s+)?(?:top|shirt|blouse|skirt|pants)$',
              caseSensitive: false),
          '');
    }
    return value;
  }

  String _clothingModifierChinese(TagItem tag) {
    if (tag.group == '上衣風格') {
      return tag.zh.replaceFirst(RegExp(r'上衣風格$'), '');
    }
    if (tag.group == '下身風格') {
      return tag.zh.replaceFirst(RegExp(r'(下身|裙子|褲子)風格$'), '');
    }
    final scopedKind = _scopedClothingKind(tag.group);
    if (scopedKind == 'style') {
      if (_scopedClothingSlot(tag.group) == 'onepiece') {
        return tag.zh.replaceFirst(RegExp(r'連身裝風格$'), '');
      }
      return tag.zh.replaceFirst(RegExp(r'風格$'), '');
    }
    if (scopedKind == 'detail') {
      return tag.zh.replaceFirst(RegExp(r'細節$'), '');
    }
    if (scopedKind == 'material') {
      return tag.zh.replaceFirst(RegExp(r'材質$'), '');
    }
    if (_isLegacyClothingStyleTag(tag)) {
      if (tag.group == '內衣') {
        return tag.zh.replaceFirst(RegExp(r'內衣$'), '');
      }
      if (tag.group == '胸罩') {
        return tag.zh.replaceFirst(RegExp(r'胸罩$'), '');
      }
      if (tag.group == '內褲') {
        return tag.zh.replaceFirst(RegExp(r'內褲$'), '');
      }
      if (tag.group == '襪子') {
        return tag.zh.replaceFirst(RegExp(r'襪$'), '');
      }
      if (tag.group == '鞋子') {
        return tag.zh.replaceFirst(RegExp(r'(鞋|靴)$'), '');
      }
    }
    return tag.zh;
  }

  String _clothingStyleModifierEnglish(TagItem tag,
      {required bool stripEmbeddedColor}) {
    var value = _clothingModifierEnglish(tag);
    if (!stripEmbeddedColor || !_isOnePieceStyleTag(tag)) return value;
    for (final color in _clothingColorWords(tag)) {
      value = value.replaceFirst(
        RegExp('^${RegExp.escape(color)}\\s+', caseSensitive: false),
        '',
      );
    }
    return value;
  }

  String _clothingStyleModifierChinese(TagItem tag,
      {required bool stripEmbeddedColor}) {
    var value = _clothingModifierChinese(tag);
    if (!stripEmbeddedColor || !_isOnePieceStyleTag(tag)) return value;
    for (final color in _clothingColorWords(tag)) {
      final chinese = _promptColorChinese[color];
      if (chinese != null && value.startsWith(chinese)) {
        value = value.substring(chinese.length);
      }
    }
    return value;
  }

  String _canonicalClothingEnglish(String value) {
    final cleaned = value.trim();
    const replacements = <String, String>{
      'one-piece dress': 'dress',
      'sailor uniform': 'sailor-style outfit',
      'serafuku': 'sailor-style outfit',
      'school uniform': 'formal blazer outfit',
      'student uniform': 'formal blazer outfit',
      'slim pants': 'narrow-leg pants',
      'short shorts': 'hot pants',
      'slim fit': 'tailored fit',
      'short sleeves': 'above-elbow sleeves',
      'short length': 'upper-thigh length',
      'cute': 'charming',
      'sweet cute style': 'sweet feminine style',
      'cute mood': 'cheerful mood',
      'school outfit': 'daytime formal outfit',
      'maid outfit': 'maid',
      'miko outfit': 'miko',
      'puff sleeves': 'puffy sleeves',
      'thigh-high stockings': 'thighhighs',
      'over-knee socks': 'over-kneehighs',
      'knee-high boots': 'knee boots',
      'tutu skirt': 'tutu',
      'floral pattern': 'floral print',
      'rose pattern': 'rose print',
      'cherry blossom pattern': 'cherry blossom print',
      'gothic style': 'goth fashion',
      'sporty style': 'sportswear',
      'Y2K style': 'Y2K fashion',
    };
    return replacements[cleaned] ??
        replacements[cleaned.toLowerCase()] ??
        cleaned;
  }

  String _clothingPromptNoun(String scope, TagItem base) {
    final value = _canonicalClothingEnglish(base.en).toLowerCase();
    switch (scope) {
      case 'top':
        if (value.contains('shirt') ||
            value == 'blouse' ||
            value == 't-shirt') {
          return 'shirt';
        }
        if (value.contains('jersey')) return 'shirt';
        if (value.contains('sweater')) return 'sweater';
        if (value.contains('cardigan')) return 'cardigan';
        if (value.contains('hoodie')) return 'hoodie';
        if (value.contains('vest')) return 'vest';
        return 'top';
      case 'pants':
        if (value == 'jeans') return 'jeans';
        if (value == 'leggings') return 'leggings';
        return 'pants';
      case 'shorts':
        return value == 'bloomers' ? 'bloomers' : 'shorts';
      case 'skirt':
        return 'skirt';
      case 'onepiece':
        if (value.contains('gown')) return 'gown';
        if (value == 'jumpsuit' || value == 'romper') return value;
        return 'dress';
      case 'outerwear':
        if (value.contains('coat')) return 'coat';
        if (value.contains('jacket') || value == 'blazer') return 'jacket';
        if (value == 'cape' || value == 'shawl' || value == 'raincoat') {
          return value;
        }
        return 'outerwear';
      case 'costume':
        if (value.contains('uniform')) return 'uniform';
        if (value.contains('dress')) return 'dress';
        return value;
      case 'underwear':
        return value;
      case 'bra':
        return 'bra';
      case 'panties':
        return value == 'thong' || value == 'g-string' ? value : 'panties';
      case 'socks':
        return value;
      case 'shoes':
        if (value.contains('boot')) return 'boots';
        if (value.contains('sandal')) return 'sandals';
        if (value == 'sneakers') return 'sneakers';
        return 'shoes';
      case 'accessory':
        return value;
      default:
        return _clothingScopeNoun(scope);
    }
  }

  String _clothingPromptNounChinese(String scope, TagItem base) =>
      switch (scope) {
        'top' => '上衣',
        'pants' => '褲子',
        'shorts' => '短褲',
        'skirt' => '裙子',
        'onepiece' => '洋裝',
        'outerwear' => '外套',
        'costume' => '制服／特殊服裝',
        'underwear' => '內衣',
        'bra' => '胸罩',
        'panties' => '內褲',
        'socks' => '襪子',
        'shoes' => '鞋子',
        'accessory' => base.zh,
        _ => base.zh,
      };

  (String, String) _clothingDimensionPromptPiece(
    String scope,
    String kind,
    TagItem tag,
    String noun,
    String nounZh, {
    String? detailColor,
    String? detailColorZh,
  }) {
    final raw = _canonicalClothingEnglish(_clothingModifierEnglish(tag));
    final zh = _clothingModifierChinese(tag);
    final color = detailColor == null || detailColor.isEmpty
        ? ''
        : '${detailColor.trim()} ';
    final colorZh = detailColorZh ?? '';

    if (kind == 'detail') {
      final english = switch (raw.toLowerCase()) {
        'lace trim' => '${color}lace-trimmed $noun',
        'frills' => '${color}frilled $noun',
        'ruffles' => '${color}ruffled $noun',
        'pleats' => '${color}pleated $noun',
        'bow' => '${color}$noun bow',
        'ribbon' => '${color}$noun ribbon',
        'fur trim' => '${color}fur-trimmed $noun',
        'feather trim' => '${color}feather-trimmed $noun',
        'embroidery' => '${color}embroidered $noun',
        'floral embroidery' => '${color}floral embroidery on $noun',
        'buttons' => '${color}buttoned $noun',
        'piping' => '${color}piping on $noun',
        _ => '$color$raw on $noun',
      };
      return ('$colorZh$zh$nounZh', english.trim());
    }

    if (kind == 'pattern') {
      return ('$zh$nounZh', '$raw $noun');
    }

    if (kind == 'material') {
      return ('$zh$nounZh', '$raw $noun');
    }

    if (kind == 'length') {
      final english = switch ((scope, raw.toLowerCase())) {
        ('skirt', 'mini') => 'miniskirt',
        ('skirt', 'above knee') => 'above-knee skirt',
        ('skirt', 'knee length') => 'knee-length skirt',
        ('skirt', 'midi') => 'midi skirt',
        ('skirt', 'calf length') => 'midi skirt',
        ('skirt', 'ankle length') => 'long skirt',
        ('skirt', 'maxi') => 'long skirt',
        ('skirt', 'floor length') => 'long skirt',
        ('onepiece', 'mini') => 'mini dress',
        ('onepiece', 'above knee') => 'above-knee dress',
        ('onepiece', 'knee length') => 'knee-length dress',
        ('onepiece', 'midi') => 'midi dress',
        ('onepiece', 'calf length') => 'midi dress',
        ('onepiece', 'ankle length') => 'long dress',
        ('onepiece', 'maxi') => 'long dress',
        ('onepiece', 'floor length') => 'floor-length dress',
        _ => '$raw $noun',
      };
      return ('$zh$nounZh', english);
    }

    if (kind == 'cut') {
      final english = switch (raw.toLowerCase()) {
        'off-shoulder' => 'off-shoulder $noun',
        'one-shoulder' => 'one-shoulder $noun',
        'halter neck' => 'halter $noun',
        'strapless' => 'strapless $noun',
        'backless' => 'backless $noun',
        'high-waisted' => 'high-waist $noun',
        'low-waisted' => 'low-waist $noun',
        'natural waist' => 'natural-waist $noun',
        'empire waist' => 'empire-waist $noun',
        'drop waist' => 'drop-waist $noun',
        _ => raw,
      };
      return ('$zh$nounZh', english);
    }

    return ('$zh$nounZh', '$raw $noun');
  }

  List<_GeneratedOutputTag> _clothingOutputTagsFromSelection(
    Iterable<TagItem> source, {
    int? personIndex,
  }) {
    final selected =
        source.where((tag) => _isClothingGroup(tag.group)).toList();
    final bases = _clothingDesignBases(selected);
    final consumed = <String>{};
    final result = <_GeneratedOutputTag>[];

    for (final base in bases) {
      final scope = _clothingScopeForBase(base);
      if (scope == null) continue;
      final related = <TagItem>[base];
      final colorGroup = _clothingColorGroupForBase(base);
      final mainColor = colorGroup == null
          ? null
          : selected.cast<TagItem?>().firstWhere(
                (tag) => tag?.group == colorGroup,
                orElse: () => null,
              );
      if (mainColor != null) related.add(mainColor);

      final trimColorGroup = _clothingTrimColorGroupForBase(base);
      final secondaryColor = trimColorGroup == null
          ? null
          : selected.cast<TagItem?>().firstWhere(
                (tag) => tag?.group == trimColorGroup,
                orElse: () => null,
              );
      if (secondaryColor != null) related.add(secondaryColor);

      final accessoryPositionGroup = _accessoryPositionGroup(base.group);
      final accessoryPosition = accessoryPositionGroup == null
          ? null
          : selected.cast<TagItem?>().firstWhere(
                (tag) => tag?.group == accessoryPositionGroup,
                orElse: () => null,
              );
      if (accessoryPosition != null) related.add(accessoryPosition);

      final styleGroups = _clothingStyleGroupsForBase(base);
      final legacyStyles = selected
          .where((tag) =>
              tag.id != base.id &&
              (styleGroups.contains(tag.group) ||
                  (_isLegacyClothingStyleTag(tag) &&
                      _clothingScopeForTag(tag) == scope)))
          .toList();
      related.addAll(legacyStyles);

      List<TagItem> dimension(String kind) => selected
          .where((tag) => tag.group == _scopedClothingGroup(scope, kind))
          .toList();

      final cuts = dimension('cut');
      final fits = dimension('fit');
      final lengths = dimension('length');
      final materials = <TagItem>[
        ...selected.where((tag) => tag.group == _legacyClothingMaterialGroup),
        ...dimension('material'),
      ];
      final details = <TagItem>[
        ...selected.where((tag) => tag.group == _legacyClothingDetailGroup),
        ...dimension('detail'),
      ];
      final patterns = dimension('pattern');
      related.addAll([
        ...cuts,
        ...fits,
        ...lengths,
        ...materials,
        ...details,
        ...patterns,
      ]);

      final legacyDetailColor = selected.cast<TagItem?>().firstWhere(
            (tag) => tag?.group == '服裝細節顏色',
            orElse: () => null,
          );
      final scopedDetailColor = selected.cast<TagItem?>().firstWhere(
            (tag) => tag?.group == _scopedClothingGroup(scope, 'detail_color'),
            orElse: () => null,
          );
      final effectiveDetailColor = scopedDetailColor ?? legacyDetailColor;
      if (effectiveDetailColor != null) {
        related.add(effectiveDetailColor);
      }

      final ids = related.map((tag) => tag.id).toSet().toList();
      consumed.addAll(ids);
      final noun = _clothingPromptNoun(scope, base);
      final nounZh = _clothingPromptNounChinese(scope, base);
      final pieces = <(String, String)>[];
      final pieceKeys = <String>{};
      void addPiece(String zh, String en) {
        final cleanedEnglish = _cleanTag(en);
        if (cleanedEnglish.isEmpty ||
            !pieceKeys.add(cleanedEnglish.toLowerCase())) {
          return;
        }
        pieces.add((zh.trim().ifEmpty(cleanedEnglish), cleanedEnglish));
      }

      final isStyleBase = _scopedClothingKind(base.group) == 'style';
      final canonicalBase = _canonicalClothingEnglish(
        _scopedClothingKind(base.group) == 'style'
            ? _clothingModifierEnglish(base)
            : base.en,
      );
      final colorPrefix =
          mainColor == null ? '' : _clothingColorPrefix(mainColor);
      final colorChinese =
          mainColor == null ? '' : _clothingColorChinesePrefix(mainColor);
      final baseEnglish = isStyleBase
          ? '$canonicalBase $noun'.trim()
          : _englishTagKey(canonicalBase) == _englishTagKey(noun)
              ? noun
              : canonicalBase;
      final baseChinese =
          isStyleBase ? _clothingModifierChinese(base) : base.zh;
      final mainEnglish =
          colorPrefix.isEmpty ? baseEnglish : '$colorPrefix $baseEnglish';
      final mainChinese =
          colorChinese.isEmpty ? baseChinese : '$colorChinese$baseChinese';

      final detailUsesSecondary = details.isNotEmpty &&
          effectiveDetailColor != null &&
          secondaryColor != null &&
          effectiveDetailColor.id == secondaryColor.id;
      final secondaryEnglish = secondaryColor == null
          ? null
          : _betterWaifuTrimEnglish(secondaryColor);
      final secondaryChinese = secondaryColor == null
          ? null
          : _clothingColorChinesePrefix(secondaryColor);
      final combinedEnglish = secondaryEnglish == null || detailUsesSecondary
          ? mainEnglish
          : '$mainEnglish with $secondaryEnglish';
      final combinedChinese = secondaryChinese == null || detailUsesSecondary
          ? mainChinese
          : '$mainChinese（${secondaryChinese}邊線）';
      addPiece(combinedChinese, combinedEnglish);

      for (final style in legacyStyles) {
        final english = _canonicalClothingEnglish(
          _clothingStyleModifierEnglish(style,
              stripEmbeddedColor: mainColor != null),
        );
        final chinese = _clothingStyleModifierChinese(style,
            stripEmbeddedColor: mainColor != null);
        if (_englishTagKey(english) != _englishTagKey(canonicalBase)) {
          addPiece(chinese, english);
        }
      }

      for (final entry in <(String, Iterable<TagItem>)>[
        ('cut', cuts),
        ('fit', fits),
        ('length', lengths),
        ('material', materials),
        ('pattern', patterns),
      ]) {
        for (final tag in entry.$2) {
          final piece =
              _clothingDimensionPromptPiece(scope, entry.$1, tag, noun, nounZh);
          addPiece(piece.$1, piece.$2);
        }
      }

      final detailColorPrefix = effectiveDetailColor == null
          ? null
          : _clothingColorPrefix(effectiveDetailColor);
      final detailColorChinese = effectiveDetailColor == null
          ? null
          : _clothingColorChinesePrefix(effectiveDetailColor);
      for (final detail in details) {
        final piece = _clothingDimensionPromptPiece(
          scope,
          'detail',
          detail,
          noun,
          nounZh,
          detailColor: detailColorPrefix,
          detailColorZh: detailColorChinese,
        );
        addPiece(piece.$1, piece.$2);
      }

      if (accessoryPosition != null) {
        addPiece('${accessoryPosition.zh}${base.zh}',
            '${base.en} ${accessoryPosition.en}');
      }

      result.addAll(pieces.map((piece) => _GeneratedOutputTag(
            zh: piece.$1,
            en: piece.$2,
            tagIds: ids,
            personIndex: personIndex,
            clothingBlockKey: _clothingPromptBlockKey(scope, base),
          )));
    }

    const overallGroups = {
      _outfitMainStyleGroup,
      _outfitSubStyleGroup,
      _outfitMoodGroup,
      _outfitOccasionGroup,
    };
    for (final tag
        in selected.where((tag) => overallGroups.contains(tag.group))) {
      consumed.add(tag.id);
      result.add(_GeneratedOutputTag(
        zh: tag.zh,
        en: tag.en,
        tagId: tag.id,
        tagIds: [tag.id],
        personIndex: personIndex,
      ));
    }

    for (final tag in selected.where((tag) =>
        tag.group == _legacyClothingWearGroup && !consumed.contains(tag.id))) {
      consumed.add(tag.id);
      result.add(_GeneratedOutputTag(
        zh: tag.zh,
        en: tag.en,
        tagId: tag.id,
        tagIds: [tag.id],
        personIndex: personIndex,
      ));
    }
    for (final base in bases) {
      final scope = _clothingScopeForBase(base);
      if (scope == null) continue;
      for (final tag in selected
          .where((tag) => tag.group == _scopedClothingGroup(scope, 'wear'))) {
        consumed.add(tag.id);
        result.add(_GeneratedOutputTag(
          zh: tag.zh,
          en: tag.en,
          tagId: tag.id,
          tagIds: [tag.id],
          personIndex: personIndex,
          clothingBlockKey: _clothingPromptBlockKey(scope, base),
        ));
      }
    }
    for (final tag in selected.where((tag) => !consumed.contains(tag.id))) {
      result.add(_GeneratedOutputTag(
        zh: tag.zh,
        en: tag.en,
        tagId: tag.id,
        tagIds: [tag.id],
        personIndex: personIndex,
      ));
    }
    return result;
  }

  List<_GeneratedOutputTag> _clothingOutputTagsForPerson(int personIndex) =>
      _clothingOutputTagsFromSelection(
        _selectedTagsForPerson(personIndex),
        personIndex: personIndex,
      );

  String? _hairColorWord(TagItem tag) {
    final value = _cleanTag(tag.en).toLowerCase();
    if (!value.endsWith(' hair')) return null;
    final color = value.substring(0, value.length - ' hair'.length).trim();
    return _clothingColorNames.contains(color) ? color : null;
  }

  bool _isHairStyleTag(TagItem tag) =>
      (tag.group == '髮型' && _hairLengthTag(tag.en) == null) ||
      (tag.id.startsWith('hair_') && _hairLengthTag(tag.en) == null) ||
      _traitOverrideGroups(tag.en).contains('hair_style');

  String _hairColorChinese(TagItem tag) {
    final word = _hairColorWord(tag);
    final label = word == null ? null : _promptColorChinese[word];
    if (label != null) {
      return label.replaceFirst(RegExp(r'色$'), '');
    }
    return tag.zh.replaceFirst(RegExp(r'髮$'), '');
  }

  /// Keeps a stable click order for the two gradient colours. Existing saved
  /// prompts did not store this order, so their already-selected colour is
  /// treated as colour 1 the first time the hairstyle picker is opened.
  List<String> _hairGradientColorIdsForPerson(int personIndex) {
    if (personIndex < 0 || personIndex >= _personSlots.length) {
      return const <String>[];
    }
    final available = _selectedTagsForPerson(personIndex)
        .where((tag) => _hairColorWord(tag) != null)
        .map((tag) => tag.id)
        .toSet();
    final configured = _personSlots[personIndex]
        .hairGradientColorIds
        .where(available.contains)
        .toList();
    for (final tag in _selectedTagsForPerson(personIndex)) {
      if (_hairColorWord(tag) != null && !configured.contains(tag.id)) {
        configured.add(tag.id);
      }
    }
    return configured.take(2).toList();
  }

  void _syncHairGradientColorIds(int personIndex, Set<String> selectedIds) {
    if (personIndex < 0 || personIndex >= _personSlots.length) return;
    final available = <String>{};
    for (final id in selectedIds) {
      final tag = _tagsById[id];
      if (tag != null && _hairColorWord(tag) != null) available.add(id);
    }
    final slot = _personSlots[personIndex];
    final ordered =
        slot.hairGradientColorIds.where(available.contains).toList();
    final remaining = available.where((id) => !ordered.contains(id)).toList()
      ..sort((a, b) {
        final first = _tagsById[a];
        final second = _tagsById[b];
        if (first == null || second == null) return a.compareTo(b);
        return _compareOutputTags(first, second);
      });
    ordered.addAll(remaining);
    slot.hairGradientColorIds = ordered.take(2).toList();
    if (slot.hairGradientColorIds.length < 2) {
      slot.hairGradientStyle = _defaultHairGradientStyle;
    }
  }

  _HairGradientStyle _hairGradientStyleForSlot(PersonSlot slot) =>
      _hairGradientStyles.firstWhere(
        (style) => style.id == slot.hairGradientStyle,
        orElse: () => _hairGradientStyles.first,
      );

  int _hairGradientColorOrder(int personIndex, String tagId) {
    final index = _hairGradientColorIdsForPerson(personIndex).indexOf(tagId);
    return index < 0 ? 0 : index + 1;
  }

  ({String zh, String en}) _gradientHairDescription(
    TagItem primary,
    TagItem secondary,
    _HairGradientStyle style,
  ) {
    final primaryEn = _hairColorWord(primary)!;
    final secondaryEn = _hairColorWord(secondary)!;
    final primaryZh = _hairColorChinese(primary);
    final secondaryZh = _hairColorChinese(secondary);
    return switch (style.id) {
      'tips' => (
          zh: '${primaryZh}髮搭配${secondaryZh}色髮尾漸層',
          en: '$primaryEn hair with $secondaryEn tips',
        ),
      'roots' => (
          zh: '${primaryZh}髮搭配${secondaryZh}色髮根漸層',
          en: '$primaryEn hair with $secondaryEn roots',
        ),
      'inner' => (
          zh: '${primaryZh}外層搭配${secondaryZh}內層髮',
          en: '$primaryEn hair with $secondaryEn inner hair',
        ),
      'split' => (
          zh: '${primaryZh}${secondaryZh}左右分色髮',
          en: '$primaryEn and $secondaryEn split-dye hair',
        ),
      'underlayer' => (
          zh: '${primaryZh}表層搭配${secondaryZh}底層髮',
          en: '$primaryEn hair with $secondaryEn underlayer',
        ),
      _ => (
          zh: '${primaryZh}漸層至${secondaryZh}色髮',
          en: '$primaryEn to $secondaryEn gradient hair',
        ),
    };
  }

  List<_GeneratedOutputTag> _hairOutputTagsForPerson(int personIndex) {
    final selected = _selectedTagsForPerson(personIndex);
    final colors = _selectedHairColorTags(personIndex);
    final lengths =
        selected.where((tag) => _hairLengthTag(tag.en) != null).toList();
    final styles = selected
        .where((tag) => _isHairStyleTag(tag) && _hairLengthTag(tag.en) == null)
        .toList();
    if (colors.isEmpty ||
        (colors.length < 2 && lengths.isEmpty && styles.isEmpty)) {
      return const <_GeneratedOutputTag>[];
    }

    final length = lengths.isEmpty ? null : lengths.first;
    final related = <TagItem>[...colors, ...lengths, ...styles];
    if (colors.length >= 2) {
      final gradient = _gradientHairDescription(
        colors[0],
        colors[1],
        _hairGradientStyleForSlot(_personSlots[personIndex]),
      );
      return [
        _GeneratedOutputTag(
          zh: [
            gradient.zh,
            if (length != null) length.zh,
            ...styles.map((tag) => tag.zh),
          ].join('、'),
          en: [
            gradient.en,
            if (length != null) length.en,
            ...styles.map((tag) => tag.en),
          ].join(', '),
          tagIds: related.map((tag) => tag.id).toList(),
          personIndex: personIndex,
        ),
      ];
    }

    final color = colors.first;
    final singleColorRelated = <TagItem>[color, ...lengths, ...styles];
    final english = <String>[_hairColorWord(color)!];
    final chinese = <String>[_hairColorChinese(color)];
    if (length != null) {
      final lengthEnglish = _hairLengthTag(length.en)!;
      english.add(styles.isEmpty
          ? lengthEnglish
          : lengthEnglish.replaceFirst(RegExp(r' hair$'), ''));
      chinese.add(styles.isEmpty
          ? length.zh
          : length.zh.replaceFirst(RegExp(r'髮$'), ''));
    }
    english.addAll(styles.map((tag) => tag.en));
    chinese.addAll(styles.map((tag) => tag.zh));
    return [
      _GeneratedOutputTag(
        zh: chinese.join(),
        en: english.join(' '),
        tagIds: singleColorRelated.map((tag) => tag.id).toList(),
        personIndex: personIndex,
      ),
    ];
  }

  List<_GeneratedOutputTag> _extraFeatureOutputTagsForPerson(int personIndex) {
    final selected = _selectedTagsForPerson(personIndex);
    final bases = selected.where((tag) => tag.group == '額外特徵').toList();
    if (bases.isEmpty) return const <_GeneratedOutputTag>[];
    final position = selected.cast<TagItem?>().firstWhere(
          (tag) => tag?.group == '額外特徵位置',
          orElse: () => null,
        );
    final color = selected.cast<TagItem?>().firstWhere(
          (tag) => tag?.group == '額外特徵顏色',
          orElse: () => null,
        );
    return bases
        .map((base) => _GeneratedOutputTag(
              zh: [
                if (position != null) position.zh,
                if (color != null) _clothingColorChinesePrefix(color),
                base.zh,
              ].join(),
              en: [
                if (color != null) _clothingColorPrefix(color),
                base.en,
                if (position != null) position.en,
              ].join(' '),
              tagIds: [
                base.id,
                if (position != null) position.id,
                if (color != null) color.id,
              ],
              personIndex: personIndex,
            ))
        .toList();
  }

  bool _isAnimalEarTypeTag(TagItem tag) =>
      tag.group == _animalTraitGroup &&
      RegExp(r'\bears?\b', caseSensitive: false).hasMatch(tag.en);

  bool _isAnimalTailTypeTag(TagItem tag) =>
      tag.group == _animalTraitGroup &&
      RegExp(r'\btails?\b', caseSensitive: false).hasMatch(tag.en);

  bool _isAnimalHandTypeTag(TagItem tag) =>
      tag.group == _animalTraitGroup && tag.conflictGroup == 'animal_hand_type';

  bool _isAnimalFootTypeTag(TagItem tag) =>
      tag.group == _animalTraitGroup && tag.conflictGroup == 'animal_foot_type';

  bool _isWingTypeTag(TagItem tag) => tag.group == _wingTypeGroup;

  String _withoutLeadingPromptColor(String value) {
    final cleaned = _cleanTag(value);
    final lower = cleaned.toLowerCase();
    final colors = [..._clothingColorNames]
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final color in colors) {
      if (lower == color) return '';
      if (lower.startsWith('$color ')) {
        return cleaned.substring(color.length).trim();
      }
    }
    return cleaned;
  }

  String _withoutLeadingChineseColor(String value) {
    final cleaned = value.trim();
    final colors = _promptColorChinese.values.toSet().toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final color in colors) {
      if (cleaned == color) return '';
      if (cleaned.startsWith(color)) {
        return cleaned.substring(color.length).trim();
      }
    }
    return cleaned;
  }

  List<_GeneratedOutputTag> _coloredPhysicalTraitOutputTagsForPerson(
    int personIndex, {
    required bool Function(TagItem tag) isType,
    required String colorGroup,
  }) {
    final selected = _selectedTagsForPerson(personIndex);
    final types = selected.where(isType).toList();
    if (types.isEmpty) return const <_GeneratedOutputTag>[];
    final color = selected.cast<TagItem?>().firstWhere(
          (tag) => tag?.group == colorGroup,
          orElse: () => null,
        );
    return types.map((type) {
      final baseEnglish = _withoutLeadingPromptColor(type.en);
      final baseChinese = _withoutLeadingChineseColor(type.zh);
      return _GeneratedOutputTag(
        zh: '${color == null ? '' : _clothingColorChinesePrefix(color)}$baseChinese',
        en: [
          if (color != null) _clothingColorPrefix(color),
          baseEnglish,
        ].where((value) => value.isNotEmpty).join(' '),
        tagIds: [type.id, if (color != null) color.id],
        personIndex: personIndex,
      );
    }).toList();
  }

  List<_GeneratedOutputTag> _animalTraitOutputTagsForPerson(int personIndex) =>
      [
        ..._coloredPhysicalTraitOutputTagsForPerson(
          personIndex,
          isType: _isAnimalEarTypeTag,
          colorGroup: _animalEarColorGroup,
        ),
        ..._coloredPhysicalTraitOutputTagsForPerson(
          personIndex,
          isType: _isAnimalTailTypeTag,
          colorGroup: _animalTailColorGroup,
        ),
        ..._coloredPhysicalTraitOutputTagsForPerson(
          personIndex,
          isType: _isAnimalHandTypeTag,
          colorGroup: _animalHandColorGroup,
        ),
        ..._coloredPhysicalTraitOutputTagsForPerson(
          personIndex,
          isType: _isAnimalFootTypeTag,
          colorGroup: _animalFootColorGroup,
        ),
      ];

  bool _isWingOutputTag(_GeneratedOutputTag output) => output.tagIds.any((id) {
        final tag = _tagsById[id];
        return tag?.group == _wingTypeGroup || tag?.group == _wingColorGroup;
      });

  bool _isAnimalTraitOutputTag(_GeneratedOutputTag output) =>
      output.tagIds.any((id) {
        final tag = _tagsById[id];
        return tag?.group == _animalTraitGroup ||
            const {
              _animalEarColorGroup,
              _animalTailColorGroup,
              _animalHandColorGroup,
              _animalFootColorGroup,
            }.contains(tag?.group);
      });

  /// Keeps each wing set together as its own unweighted prompt block. A color
  /// is not emitted separately: choosing white plus angel wings becomes the
  /// single phrase "white angel wings".
  List<_GeneratedOutputTag> _wingOutputTagsForPerson(int personIndex) =>
      _coloredPhysicalTraitOutputTagsForPerson(
        personIndex,
        isType: _isWingTypeTag,
        colorGroup: _wingColorGroup,
      );

  List<_GeneratedOutputTag> _objectInteractionOutputTagsForPerson(
      int personIndex) {
    final selected = _selectedTagsForPerson(personIndex);
    final mode = selected.cast<TagItem?>().firstWhere(
          (tag) => tag?.conflictGroup == 'object_interaction_mode',
          orElse: () => null,
        );
    if (mode == null) return const <_GeneratedOutputTag>[];

    final objects = selected.where((tag) => tag.group == '物件').toList();
    if (objects.isEmpty) return const <_GeneratedOutputTag>[];

    String englishFor(TagItem object) {
      switch (mode.id) {
        case 'action_hugging_object':
          return 'hugging ${object.en}';
        case 'action_riding_object':
          return 'riding ${object.en}';
        case 'action_holding_object':
          return 'holding ${object.en}';
        case 'action_holding_object_overhead':
          return 'holding ${object.en} overhead';
        case 'action_holding_staff':
          return 'holding ${object.en}';
        case 'action_holding_magic_wand':
          return 'holding ${object.en}';
        case 'action_carrying_object':
          return 'carrying ${object.en}';
        case 'action_sitting_on_object':
          return 'sitting on ${object.en}';
        case 'action_lying_on_object':
          return 'lying on ${object.en}';
        case 'action_leaning_on_object':
          return 'leaning on ${object.en}';
        default:
          return '${mode.en} ${object.en}';
      }
    }

    String chineseFor(TagItem object) {
      switch (mode.id) {
        case 'action_hugging_object':
          return '抱著${object.zh}';
        case 'action_riding_object':
          return '騎著${object.zh}';
        case 'action_holding_object':
          return '拿著${object.zh}';
        case 'action_holding_object_overhead':
          return '高舉${object.zh}';
        case 'action_holding_staff':
          return '手持${object.zh}';
        case 'action_holding_magic_wand':
          return '手持${object.zh}';
        case 'action_carrying_object':
          return '抱持${object.zh}';
        case 'action_sitting_on_object':
          return '坐在${object.zh}上';
        case 'action_lying_on_object':
          return '躺在${object.zh}上';
        case 'action_leaning_on_object':
          return '靠著${object.zh}';
        default:
          return '${mode.zh}${object.zh}';
      }
    }

    return objects
        .map((object) => _GeneratedOutputTag(
              zh: chineseFor(object),
              en: englishFor(object),
              tagIds: [mode.id, object.id],
              personIndex: personIndex,
            ))
        .toList();
  }

  List<_GeneratedOutputTag> _combinationExtraOutputTagsForPerson(
      int personIndex) {
    final appliedIds = _personCombinationIds[personIndex] ?? const <String>{};
    return _combinations
        .where((combination) => appliedIds.contains(combination.id))
        .expand((combination) => _extraTags(combination.extraPositive).map(
              (value) => _GeneratedOutputTag(
                zh: _positiveChineseTag(value),
                en: _positiveEnglishTag(value),
                personIndex: personIndex,
                combinationId: combination.id,
              ),
            ))
        .toList();
  }

  List<String> _poseExtraPrompts(String value) => value
      .split(RegExp(r'[。.;\n\r]+'))
      .map(_cleanTag)
      .where((item) => item.isNotEmpty)
      .toList();

  List<_GeneratedOutputTag> _poseExtraOutputTagsForPerson(int personIndex) {
    if (personIndex < 0 || personIndex >= _personSlots.length) {
      return const <_GeneratedOutputTag>[];
    }
    final slot = _personSlots[personIndex];
    if (!slot.detailed) return const <_GeneratedOutputTag>[];
    return _poseExtraPrompts(slot.poseExtraPositive)
        .map((value) => _GeneratedOutputTag(
              zh: _positiveChineseTag(value),
              en: _positiveEnglishTag(value),
              personIndex: personIndex,
              personPoseExtraValue: value,
            ))
        .toList();
  }

  List<_GeneratedOutputTag> _sharedPoseExtraOutputTags() =>
      _poseExtraPrompts(_sharedPoseExtra.text)
          .map((value) => _GeneratedOutputTag(
                zh: _positiveChineseTag(value),
                en: _positiveEnglishTag(value),
                sharedPoseExtraValue: value,
              ))
          .toList();

  List<_GeneratedOutputTag> _personPromptTags(int index) {
    final selected = _selectedTagsForPerson(index);
    final clothing = _clothingOutputTagsForPerson(index);
    final hair = _hairOutputTagsForPerson(index);
    final animalTraits = _animalTraitOutputTagsForPerson(index);
    final wings = _wingOutputTagsForPerson(index);
    final extra = _extraFeatureOutputTagsForPerson(index);
    final objectInteractions = _objectInteractionOutputTagsForPerson(index);
    final combinationExtra = _combinationExtraOutputTagsForPerson(index);
    final poseExtra = _poseExtraOutputTagsForPerson(index);
    final covered = {
      ...clothing.expand((tag) => tag.tagIds),
      ...hair.expand((tag) => tag.tagIds),
      ...animalTraits.expand((tag) => tag.tagIds),
      ...wings.expand((tag) => tag.tagIds),
      ...selected
          .where((tag) => _physicalTraitColorGroups.contains(tag.group))
          .map((tag) => tag.id),
      ...extra.expand((tag) => tag.tagIds),
      ...objectInteractions.expand((tag) => tag.tagIds),
      ...combinationExtra.expand((tag) => tag.tagIds),
    };
    final other = selected
        .where(
            (tag) => !_isClothingGroup(tag.group) && !covered.contains(tag.id))
        .map((tag) => _GeneratedOutputTag(
              zh: tag.zh,
              en: tag.en,
              tagId: tag.id,
              tagIds: [tag.id],
              personIndex: index,
            ))
        .toList();
    final beforeClothing = other
        .where((tag) =>
            _outputGroupOrder(
                selected.firstWhere((item) => item.id == tag.tagId).group) <
            20)
        .toList();
    final afterClothing = other
        .where((tag) =>
            _outputGroupOrder(
                selected.firstWhere((item) => item.id == tag.tagId).group) >=
            20)
        .toList();
    return [
      ...beforeClothing,
      ...extra,
      ...hair,
      ...animalTraits,
      ...wings,
      ...clothing,
      ...afterClothing,
      ...objectInteractions,
      ...poseExtra,
      ...combinationExtra,
    ];
  }

  List<String> _fixedCharacterFeatureSummaryZh() {
    final result = <String>[];
    final seen = <String>{};
    for (var index = 0; index < _personSlots.length; index++) {
      for (final output in _personPromptTags(index)) {
        final fixed = output.tagIds.any((id) {
          final tag = _tagsById[id];
          return tag != null && _isFixedCharacterFeatureTag(tag);
        });
        if (!fixed || output.zh.trim().isEmpty) continue;
        final value = output.zh.trim();
        if (seen.add(value)) result.add(value);
      }
    }
    return result;
  }

  bool _isFinalPersonOutputTag(int personIndex, _GeneratedOutputTag output) {
    // With a single character, even adult actions remain that character's
    // own action and should stay in its unweighted action block.
    if (_personSlots.length <= 1) return false;
    const finalGroups = {'性行為', '性姿勢'};
    final selected = _selectedTagsForPerson(personIndex);
    return output.tagIds.any((id) => selected.any((tag) =>
        tag.id == id &&
        (finalGroups.contains(tag.group) ||
            expandedSharedFinalGroups.contains(tag.group) ||
            _isSharedActionGroup(tag.group))));
  }

  List<_GeneratedOutputTag> _personScopedPromptTags(int personIndex) =>
      _personPromptTags(personIndex)
          .where((tag) => !_isFinalPersonOutputTag(personIndex, tag))
          .toList();

  List<_GeneratedOutputTag> _personFinalPromptTags(int personIndex) =>
      _personPromptTags(personIndex)
          .where((tag) => _isFinalPersonOutputTag(personIndex, tag))
          .toList();

  static const _characterWeightGroups = <String>{
    '角色類型',
    '角色標籤',
    '自訂角色',
    '自訂特徵',
    '身體特徵',
    '眼睛',
    '胸部',
    '裸露',
    '髮色',
    '髮長',
    '髮型',
    '額外特徵',
    '額外特徵位置',
    '額外特徵顏色',
  };

  bool _isCharacterWeightOutputTag(_GeneratedOutputTag output) {
    if (output.characterTag) return true;
    if (_isAnimalTraitOutputTag(output) || _isWingOutputTag(output)) {
      return true;
    }
    return output.tagIds.any((id) {
      final tag = _tagsById[id];
      return tag != null &&
          (_characterWeightGroups.contains(tag.group) ||
              tag.group == _animalTraitGroup ||
              tag.group == _wingTypeGroup ||
              tag.group == _wingColorGroup ||
              _physicalTraitColorGroups.contains(tag.group) ||
              _isStaticFaceAppearanceTag(tag));
    });
  }

  List<TagItem> _selectedHairColorTags(int personIndex) =>
      _hairGradientColorIdsForPerson(personIndex)
          .map((id) => _tagsById[id])
          .whereType<TagItem>()
          .toList();

  bool _isHairPromptTag(TagItem tag) {
    if (_hairColorWord(tag) != null ||
        _hairLengthTag(tag.en) != null ||
        _isHairStyleTag(tag)) {
      return true;
    }
    return _traitOverrideGroups(tag.en).intersection(const {
      'hair_color',
      'hair_length',
      'hair_style',
    }).isNotEmpty;
  }

  bool _isHairPromptEnglish(String value) {
    final normalized = _cleanTag(value).toLowerCase();
    if (_traitOverrideGroups(normalized).intersection(const {
      'hair_color',
      'hair_length',
      'hair_style',
    }).isNotEmpty) {
      return true;
    }
    return RegExp(r'\b(?:[a-z-]+\s+){0,4}hair$').hasMatch(normalized) ||
        RegExp(r'\b(?:ahoge|cowlick|antenna hair)\b').hasMatch(normalized);
  }

  /// Hair characteristics are normally part of the character-trait block.
  /// When local hair emphasis is enabled, keep colour, length, and hairstyle
  /// together in a nested weighted block within that person's common block.
  bool _isHairPromptOutputTag(int personIndex, _GeneratedOutputTag output) {
    if (personIndex < 0 || personIndex >= _personSlots.length) return false;
    final slot = _personSlots[personIndex];
    if (!slot.hairPromptWeightEnabled) return false;
    final hairIds = _selectedTagsForPerson(personIndex)
        .where(_isHairPromptTag)
        .map((tag) => tag.id)
        .toSet();

    if (output.tagIds.any(hairIds.contains) ||
        (output.tagId != null && hairIds.contains(output.tagId))) {
      return true;
    }

    // Catalogue character traits are generated directly instead of through a
    // selectable TagItem, so they do not always have tag IDs. Only use the
    // English fallback for those ID-less traits; this keeps hair accessories
    // such as hair bows in the outfit block.
    if (output.tagIds.isNotEmpty || output.tagId != null) return false;
    return _isHairPromptEnglish(output.en);
  }

  bool _isClothingWeightOutputTag(_GeneratedOutputTag output) {
    return output.tagIds.any((id) {
      final tag = _tagsById[id];
      return tag != null && _isClothingGroup(tag.group);
    });
  }

  double _boundedPromptWeight(Object? value,
      {double fallback = _defaultPromptWeight}) {
    final parsed = switch (value) {
      num number => number.toDouble(),
      String text => double.tryParse(text),
      _ => null,
    };
    return (parsed ?? fallback)
        .clamp(_minimumPromptWeight, _maximumPromptWeight)
        .toDouble();
  }

  String _promptTagBlock(Iterable<_GeneratedOutputTag> tags, {double? weight}) {
    final values = <String>[];
    final seen = <String>{};
    void addValue(String raw) {
      final value = _moderationSafePromptTag(raw);
      if (value.isNotEmpty && seen.add(value.toLowerCase())) values.add(value);
    }

    for (final tag in tags) {
      addValue(tag.en);
    }
    if (values.isEmpty) return '';
    final suffix = weight == null
        ? ''
        : ':${_boundedPromptWeight(weight).toStringAsFixed(2)}';
    return '(${values.join(', ')}$suffix)';
  }

  /// Renders clothing as readable garment-level sub-blocks. The surrounding
  /// person's outer block supplies the shared character/outfit/action weight.
  /// For example: `(dark blue blouse, cotton blouse). (white skirt, lace)`.
  ///
  /// The inner parentheses do not introduce an extra weight. They merely keep
  /// each garment's type, material, details, colours, and local wear state
  /// together so BetterWaifu receives the intended combinations clearly.
  String _groupedClothingPromptBlock(Iterable<_GeneratedOutputTag> tags) {
    final grouped = <String, List<String>>{};
    final ungrouped = <String>[];
    final seen = <String>{};

    for (final tag in tags) {
      final value = _moderationSafePromptTag(tag.en);
      if (value.isEmpty || !seen.add(value.toLowerCase())) continue;
      final key = tag.clothingBlockKey;
      if (key == null || key.isEmpty) {
        ungrouped.add(value);
      } else {
        grouped.putIfAbsent(key, () => <String>[]).add(value);
      }
    }

    final sections = <String>[
      ...grouped.values
          .where((values) => values.isNotEmpty)
          .map((values) => '(${values.join(', ')})'),
      if (ungrouped.isNotEmpty) ungrouped.join(', '),
    ];
    if (sections.isEmpty) return '';
    return sections.join('. ');
  }

  int get _personSelectedCount =>
      _personSelectedIds.values.fold(0, (total, ids) => total + ids.length);

  List<String> get _groups => [
        '全部',
        ..._allTags
            .map((tag) => tag.group)
            .where((group) => !_isScopedClothingGroup(group))
            .where((group) => group != '髮色' && group != '臉部特徵')
            .toSet(),
        _staticFaceAppearanceGroup,
        _expressionEyesGroup,
        _expressionMouthGroup,
        _expressionTeasingGroup,
        _expressionSymbolGroup,
        _expressionOtherGroup,
      ];

  @override
  void initState() {
    super.initState();
    _checkForVersionUpdate();
    _search.addListener(_scheduleSearchRefresh);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        if (!mounted) return;
        // Build the large catalog and restore local selections after Flutter
        // has produced one frame. This keeps the initial transition from the
        // HTML splash responsive on lower-powered phones.
        _restore();
        if (!mounted) return;
        setState(() => _isPreparingCatalog = false);
        unawaited(_scrollToStep(_stepIndex));
      });
    });
  }

  void _scheduleSearchRefresh() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 160), () {
      if (mounted) setState(() {});
    });
  }

  void _updatePersonPoseExtra(int personIndex, String value) {
    if (personIndex < 0 || personIndex >= _personSlots.length) return;
    _personSlots[personIndex].poseExtraPositive = value;
    _poseExtraDebounce?.cancel();
    _poseExtraDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      _collectUnknownExtraPositiveTags();
      _persist();
      setState(() {});
    });
  }

  void _updateSharedPoseExtra(String value) {
    _poseExtraDebounce?.cancel();
    _poseExtraDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      _collectUnknownExtraPositiveTags();
      _persist();
      setState(() {});
    });
  }

  void _checkForVersionUpdate() {
    final previous = html.window.localStorage[_lastSeenVersionKey];
    html.window.localStorage[_lastSeenVersionKey] = appVersionLabel;
    if (previous != null && previous != appVersionLabel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showVersionHistory(previous);
      });
    }
  }

  String _briefVersionNote(Map<String, String> release) {
    final notes = (release['notes'] ?? '').trim();
    final normalized = notes.toLowerCase();
    if (normalized.contains('direct person removal') &&
        normalized.contains('tag loading')) {
      return '人物卡片可直接刪除，並改善標籤載入效能。';
    }
    if (normalized.contains('rebuild clothing taxonomy')) {
      return '重建服裝分類架構與視覺分層。';
    }
    if (normalized.contains('reorganize pose and clothing tag pickers')) {
      return '整理姿勢與服裝標籤選擇介面。';
    }
    if (normalized.contains('refine mouth expressions')) {
      return '補充並整理嘴部表情標籤。';
    }
    if (normalized.contains('add kyudo prompt catalog')) {
      return '新增弓道服裝、姿勢、場景與道具標籤。';
    }
    if (normalized.contains('pose') && normalized.contains('footwear')) {
      return '重整姿勢分類與配色，並擴充鞋子種類。';
    }
    return notes
        .replaceFirst(RegExp(r'^自動偵測：'), '')
        .replaceFirst(RegExp(r'^(feat|fix|chore):\s*'), '');
  }

  void _showVersionHistory([String? previousVersion]) {
    final latestReleases = appVersionHistory.take(5).toList();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.new_releases_outlined),
            const SizedBox(width: 8),
            Expanded(child: Text('最近 5 次改版 · $appVersionLabel')),
          ],
        ),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (previousVersion != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('已從 $previousVersion 更新到 $appVersionLabel。'),
                  ),
                ...latestReleases.map(
                  (release) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${release['label']} · ${release['date']}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(_briefVersionNote(release)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _poseExtraDebounce?.cancel();
    _collectUnknownExtraPositiveTags();
    _persist();
    _search.removeListener(_scheduleSearchRefresh);
    _search.dispose();
    _globalTagSearch.dispose();
    _extraPositive.dispose();
    _sharedPoseExtra.dispose();
    _reversePrompt.dispose();
    _negative.dispose();
    _preprompt.dispose();
    _pageScrollController.dispose();
    for (final controller in _personSearchControllers.values) {
      controller.dispose();
    }
    for (final controller in _pickerSearchControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _personSearchController(
      int index, String field, String value) {
    final key = '$index:$field';
    final controller = _personSearchControllers.putIfAbsent(
        key, () => TextEditingController(text: value));
    if (controller.text != value) {
      controller.text = value;
    }
    return controller;
  }

  void _clearPersonSearchController(int index, String field) {
    _personSearchControllers['$index:$field']?.clear();
  }

  String _pickerQueryKey(List<String> groups, int? personIndex) {
    final owner = personIndex == null ? 'global' : 'person:$personIndex';
    return '$owner:${groups.join('|')}';
  }

  TextEditingController _pickerSearchController(
      List<String> groups, int? personIndex) {
    final key = _pickerQueryKey(groups, personIndex);
    final value = _pickerTagQueries[key] ?? '';
    final controller = _pickerSearchControllers.putIfAbsent(
      key,
      () => TextEditingController(text: value),
    );
    if (controller.text != value && !controller.selection.isValid) {
      controller.text = value;
    }
    return controller;
  }

  void _clearPickerQuery(List<String> groups, int? personIndex) {
    final key = _pickerQueryKey(groups, personIndex);
    _pickerTagQueries.remove(key);
    _pickerSearchControllers[key]?.clear();
  }

  void _restore() {
    final raw = html.window.localStorage[_storageKey];
    if (raw == null) return;
    try {
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      _invalidateTagCaches();
      _customTags.addAll(
        (data['customTags'] as List? ?? []).map(
          (item) => _normalizeRestoredCharacterTraitTag(
            TagItem.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        ),
      );
      _customCharacters.addAll(
        (data['customCharacters'] as List? ?? [])
            .map(
              (item) => CatalogCharacter.fromJson(
                  Map<String, dynamic>.from(item as Map)),
            )
            .map(_normalizeImportedAnime),
      );
      _personSlots
        ..clear()
        ..addAll(
          (data['personSlots'] as List? ?? []).map(
            (item) =>
                PersonSlot.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
      if (_personSlots.isEmpty) _personSlots.add(PersonSlot());
      // Older builds saved imported remote characters with a malformed mode
      // value. A non-empty characterId that points to the catalog is always
      // an anime-character slot, so repair it when restoring local memory.
      for (final slot in _personSlots) {
        if (slot.characterId.isEmpty) continue;
        for (final character in _allCharacters) {
          if (character.id != slot.characterId) continue;
          slot.mode = '動漫角色';
          slot.animeTag = character.animeTag;
          break;
        }
      }
      _recentCharacterIds.addAll(
        (data['recentCharacterIds'] as List? ?? []).map((id) => '$id'),
      );
      _presets.addAll(
        (data['presets'] as List? ?? []).map(
          (item) => Preset.fromJson(Map<String, dynamic>.from(item as Map)),
        ),
      );
      _combinations.addAll(
        (data['combinations'] as List? ?? []).map(
          (item) => PromptCombination.fromJson(
              Map<String, dynamic>.from(item as Map)),
        ),
      );
      _selectedIds.addAll(
        (data['selectedIds'] as List? ?? []).map((id) => '$id'),
      );
      if (!data.containsKey('personSelectedIds')) {
        final legacyPersonal = _allTags
            .where((tag) =>
                _selectedIds.contains(tag.id) &&
                !_isGlobalPromptGroup(tag.group))
            .toList();
        if (legacyPersonal.isNotEmpty) {
          _personSelectedIds[0] = legacyPersonal.map((tag) => tag.id).toSet();
          _selectedIds.removeAll(legacyPersonal.map((tag) => tag.id));
        }
      }
      final personTags = data['personSelectedIds'] as Map?;
      if (personTags != null) {
        for (final entry in personTags.entries) {
          final index = int.tryParse('${entry.key}');
          if (index == null) continue;
          _personSelectedIds[index] =
              (entry.value as List? ?? []).map((id) => '$id').toSet();
        }
      }
      _migrateConsolidatedWearTagIds(_selectedIds);
      _migrateClothingTaxonomyTagIds(_selectedIds);
      for (final ids in _personSelectedIds.values) {
        _migrateConsolidatedWearTagIds(ids);
        _migrateClothingTaxonomyTagIds(ids);
      }
      for (final combination in _combinations) {
        final migrated = combination.tagIds.toSet();
        _migrateClothingTaxonomyTagIds(migrated);
        combination.tagIds
          ..clear()
          ..addAll(migrated);
      }
      final personCombinations = data['personCombinationIds'] as Map?;
      if (personCombinations != null) {
        for (final entry in personCombinations.entries) {
          final index = int.tryParse('${entry.key}');
          if (index == null) continue;
          _personCombinationIds[index] =
              (entry.value as List? ?? []).map((id) => '$id').toSet();
        }
      }
      final removedCharacterTags = data['removedCharacterTags'] as Map?;
      if (removedCharacterTags != null) {
        for (final entry in removedCharacterTags.entries) {
          final index = int.tryParse('${entry.key}');
          if (index == null) continue;
          _removedCharacterTags[index] =
              (entry.value as List? ?? []).map((tag) => '$tag').toSet();
        }
      }
      _peopleCount = (data['peopleCount'] as num?)?.toInt() ?? 1;
      var savedStep = (data['stepIndex'] as num?)?.toInt() ?? 0;
      final savedLayoutVersion =
          (data['stepLayoutVersion'] as num?)?.toInt() ?? 1;
      if (savedLayoutVersion < 2) {
        // The old layout had a separate expression step at index 4. It now
        // lives inside character features, so map saved progress safely.
        if (savedStep == 4) {
          savedStep = 2;
        } else if (savedStep >= 5) {
          savedStep -= 1;
        }
      }
      if (savedLayoutVersion < _stepLayoutVersion && savedStep >= 2) {
        // Version 3 inserted the reusable-combinations step after characters.
        savedStep += 1;
      }
      _stepIndex = savedStep.clamp(0, 6).toInt();
      _gender = '${data['gender'] ?? '女性'}';
      _model = '${data['model'] ?? 'Amanatsu 1.1'}';
      _sampler = '${data['sampler'] ?? 'Euler a'}';
      _steps = (data['steps'] as num?)?.toInt() ?? 28;
      _cfg = '${data['cfg'] ?? '5.0'}';
      _clipSkip = '${data['clipSkip'] ?? '2'}';
      _showAdult = data['showAdult'] == true;
      _extraPositive.text = '${data['extraPositive'] ?? ''}';
      _sharedPoseExtra.text = '${data['sharedPoseExtra'] ?? ''}';
      _unregisteredPositiveTags
        ..clear()
        ..addAll((data['unregisteredPositiveTags'] as List? ?? [])
            .map((value) => _cleanTag('$value'))
            .where((value) => value.isNotEmpty));
      _collectUnknownExtraPositiveTags();
      _reversePrompt.text = '${data['reversePrompt'] ?? ''}';
      _negative.text = '${data['negative'] ?? _negative.text}';
      _customNegativeTranslations
        ..clear()
        ..addAll(Map<String, dynamic>.from(
          data['customNegativeTranslations'] as Map? ?? <String, dynamic>{},
        ).map((key, value) => MapEntry(key.toLowerCase(), '$value')));
      _preprompt.text = '${data['preprompt'] ?? _preprompt.text}';
      _peopleCount = _personSlots.length;
      for (var index = 0; index < _personSlots.length; index++) {
        _syncCharacterTraitsForSlot(index);
      }
    } catch (_) {
      // A malformed local record should never stop the builder from opening.
    }
  }

  Map<String, dynamic> _snapshot() => {
        'selectedIds': _selectedIds.toList(),
        'personSelectedIds': _personSelectedIds.map(
          (index, ids) => MapEntry('$index', ids.toList()),
        ),
        'removedCharacterTags': _removedCharacterTags.map(
          (index, tags) => MapEntry('$index', tags.toList()),
        ),
        'customTags': _customTags.map((tag) => tag.toJson()).toList(),
        'customCharacters':
            _customCharacters.map((item) => item.toJson()).toList(),
        'personSlots': _personSlots.map((item) => item.toJson()).toList(),
        'recentCharacterIds': _recentCharacterIds,
        'presets': _presets.map((preset) => preset.toJson()).toList(),
        'combinations':
            _combinations.map((combination) => combination.toJson()).toList(),
        'personCombinationIds': _personCombinationIds.map(
          (index, ids) => MapEntry('$index', ids.toList()),
        ),
        'peopleCount': _peopleCount,
        'stepIndex': _stepIndex,
        'stepLayoutVersion': _stepLayoutVersion,
        'gender': _gender,
        'model': _model,
        'sampler': _sampler,
        'steps': _steps,
        'cfg': _cfg,
        'clipSkip': _clipSkip,
        'showAdult': _showAdult,
        'extraPositive': _extraPositive.text,
        'sharedPoseExtra': _sharedPoseExtra.text,
        'unregisteredPositiveTags': _isCompactMobileViewport
            ? const <String>[]
            : _unregisteredPositiveTags.toList(),
        'reversePrompt': _reversePrompt.text,
        'negative': _negative.text,
        'customNegativeTranslations': _customNegativeTranslations,
        'preprompt': _preprompt.text,
      };

  void _persist() {
    html.window.localStorage[_storageKey] = jsonEncode(_snapshot());
  }

  String _peopleTag() {
    if (_gender == '女性')
      return _peopleCount == 1 ? '1girl' : '${_peopleCount}girls';
    if (_gender == '男性')
      return _peopleCount == 1 ? '1boy' : '${_peopleCount}boys';
    return _peopleCount == 1 ? '1person' : '${_peopleCount}people';
  }

  String _peopleZh() {
    final type = _gender == '女性'
        ? '女性角色'
        : _gender == '男性'
            ? '男性角色'
            : '人物';
    return '$_peopleCount 人$type';
  }

  List<String> _peopleTokensNew() {
    final female = _personSlots.where((slot) => slot.gender == '女性').length;
    final male = _personSlots.where((slot) => slot.gender == '男性').length;
    final other = _personSlots.length - female - male;
    final result = <String>[];
    if (female > 0) result.add(female == 1 ? '1girl' : '${female}girls');
    if (male > 0) result.add(male == 1 ? '1boy' : '${male}boys');
    if (other > 0) result.add(other == 1 ? '1other' : '${other}others');
    return result.isEmpty ? ['1person'] : result;
  }

  String _peopleTagNew() => _peopleTokensNew().join(', ');

  String _peopleZhNew() {
    final female = _personSlots.where((slot) => slot.gender == '女性').length;
    final male = _personSlots.where((slot) => slot.gender == '男性').length;
    final other = _personSlots.length - female - male;
    final result = <String>[];
    if (female > 0) result.add('$female 位女性角色');
    if (male > 0) result.add('$male 位男性角色');
    if (other > 0) result.add('$other 位其他/異種角色');
    return result.join('、');
  }

  CatalogCharacter? _characterForNew(PersonSlot slot) {
    if (slot.characterId.isEmpty) return null;
    for (final character in _allCharacters) {
      if (character.id == slot.characterId) return character;
    }
    return null;
  }

  String _englishTagKey(String value) => _cleanTag(value)
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();

  TagItem? _tagByEnglish(String english) {
    final key = _englishTagKey(english);
    _allTags;
    return _tagByEnglishCache![key];
  }

  String _characterTraitGroup(CatalogTagData trait) {
    if (!const {'自訂特徵', '角色標籤'}.contains(trait.group)) {
      return trait.group;
    }
    final value = trait.en.toLowerCase();
    if (RegExp(r'\b(?:ahoge|cowlick)\b').hasMatch(value)) return '髮型';
    if (value.endsWith(' hair')) {
      final color = value.substring(0, value.length - ' hair'.length).trim();
      if (_clothingColorNames.contains(color)) return '髮色';
    }
    if (_hairLengthTag(value) != null) return '髮長';
    if (value.contains('hair')) return '髮型';
    if (RegExp(r'\bwings?\b').hasMatch(value)) return _wingTypeGroup;
    if (RegExp(r'\b(?:[a-z-]+\s+)?eyes?\b').hasMatch(value) ||
        RegExp(r'\b(?:pupils?|sclera|sharingan|rinnegan|byakugan|tenseigan|jougan|ketsuryugan)\b')
            .hasMatch(value)) {
      return '眼睛';
    }
    if (RegExp(r'\b(?:flat|small|medium|large|huge) breasts\b')
        .hasMatch(value)) {
      return '胸部';
    }
    if ([
      'slender build',
      'tall',
      'curvy',
      'muscular',
      'petite',
      'mature female'
    ].contains(value)) {
      return '身體特徵';
    }
    if (RegExp(
      r'\b(?:animal|cat|fox|dog|wolf|bunny|rabbit)\s+(?:ears?|tail)\b|\b(?:feathered|bat|angel|demon)\s+wings?\b',
    ).hasMatch(value)) {
      return _animalTraitGroup;
    }
    if (RegExp(
      r'\b(?:tails?|horns?|wings?|elf ears|animal ears|pointy ears|fangs?|claws?)\b',
    ).hasMatch(value)) {
      return '身體特徵';
    }
    if (['makeup', 'earrings', 'necklace', 'tattoo', 'nail polish', 'glasses']
        .contains(value)) {
      return '額外特徵';
    }
    return '額外特徵';
  }

  TagItem _normalizeRestoredCharacterTraitTag(TagItem tag) {
    if (tag.group != '角色標籤' || !tag.id.startsWith('character_trait_')) {
      return tag;
    }
    final group = _characterTraitGroup(CatalogTagData(
      id: tag.id,
      group: tag.group,
      zh: tag.zh,
      en: tag.en,
      order: tag.order,
      adult: tag.adult,
      conflictGroup: tag.conflictGroup,
    ));
    if (group == tag.group) return tag;
    return TagItem(
      id: tag.id,
      group: group,
      zh: tag.zh,
      en: tag.en,
      order: tag.order,
      adult: tag.adult,
      builtIn: tag.builtIn,
      conflictGroup: tag.conflictGroup,
    );
  }

  TagItem _createCharacterTraitOption(CatalogTagData trait) {
    final existing = _tagByEnglish(trait.en);
    if (existing != null) return existing;
    final id = 'character_trait_${_slug(trait.en)}';
    for (final tag in _customTags) {
      if (tag.id == id) return tag;
    }
    final option = TagItem(
      id: id,
      group: _characterTraitGroup(trait),
      zh: trait.zh,
      en: trait.en,
      order: trait.order,
      adult: trait.adult,
      builtIn: false,
      conflictGroup: trait.conflictGroup,
    );
    _customTags.add(option);
    _invalidateTagCaches();
    return option;
  }

  List<TagItem> _characterTraitOptions(CatalogTagData trait) {
    final direct = _tagByEnglish(trait.en);
    if (direct != null) return [direct];

    final value = _cleanTag(trait.en);
    final lengthFirst = RegExp(
      r'^(close-cropped|cropped|very short|very long|waist-length|long|medium|short)\s+(.+?)\s+hair$',
      caseSensitive: false,
    ).firstMatch(value);
    final colorFirst = RegExp(
      r'^(.+?)\s+(close-cropped|cropped|very short|very long|waist-length|long|medium|short)\s+hair$',
      caseSensitive: false,
    ).firstMatch(value);
    if (lengthFirst == null && colorFirst == null) {
      return [_createCharacterTraitOption(trait)];
    }

    final lengthWord = lengthFirst?.group(1) ?? colorFirst!.group(2)!;
    final colorWord = lengthFirst?.group(2) ?? colorFirst!.group(1)!;
    final length = '$lengthWord hair';
    final color = '$colorWord hair';
    final lengthTag = _tagByEnglish(length);
    final colorTag = _tagByEnglish(color);
    return [
      if (colorTag != null) colorTag,
      if (lengthTag != null) lengthTag,
      if (colorTag == null || lengthTag == null)
        _createCharacterTraitOption(trait),
    ];
  }

  bool _characterTraitUsesTag(CatalogTagData trait, String tagId) =>
      _characterTraitOptions(trait).any((tag) => tag.id == tagId);

  bool _isCurrentCharacterTrait(int index, TagItem tag) {
    if (index < 0 || index >= _personSlots.length) return false;
    final slot = _personSlots[index];
    if (slot.mode != '動漫角色') return false;
    final character = _characterForNew(slot);
    return character?.traits
            .any((trait) => _characterTraitUsesTag(trait, tag.id)) ??
        false;
  }

  void _removeCharacterTraitSelections(int index, CatalogCharacter? character) {
    if (character == null) return;
    final ids = _personTagIds(index);
    for (final trait in character.traits) {
      ids.removeAll(_characterTraitOptions(trait).map((tag) => tag.id));
    }
  }

  Set<String> _exclusiveTraitOverrideGroups(String english) =>
      _traitOverrideGroups(english).intersection(const {
        'hair_color',
        'hair_length',
        'eye_color',
        'body_type',
        'breast_size',
      });

  bool _hasExplicitCharacterTraitOverride(
      int index, CatalogCharacter character, Set<String> groups) {
    if (groups.isEmpty) return false;
    final originalIds = character.traits
        .expand(_characterTraitOptions)
        .map((tag) => tag.id)
        .toSet();
    return _selectedTagsForPerson(index).any((tag) =>
        !originalIds.contains(tag.id) &&
        _exclusiveTraitOverrideGroups(tag.en).intersection(groups).isNotEmpty);
  }

  void _removeOriginalCharacterTraitsForOverride(int index, TagItem tag) {
    if (index < 0 || index >= _personSlots.length) return;
    final character = _characterForNew(_personSlots[index]);
    final groups = _exclusiveTraitOverrideGroups(tag.en);
    if (character == null || groups.isEmpty) return;

    final ids = _personTagIds(index);
    for (final trait in character.traits) {
      if (_exclusiveTraitOverrideGroups(trait.en)
          .intersection(groups)
          .isEmpty) {
        continue;
      }
      _removedCharacterTagSet(index).add(_cleanTag(trait.en).toLowerCase());
      ids.removeAll(_characterTraitOptions(trait).map((option) => option.id));
    }
  }

  void _resetCharacterFeatureSelections(
      int index, CatalogCharacter? previousCharacter) {
    if (index < 0 || index >= _personSlots.length) return;
    _removeCharacterTraitSelections(index, previousCharacter);
    final ids = _personTagIds(index);
    final tagsById = <String, TagItem>{
      for (final tag in _allTags) tag.id: tag,
    };
    ids.removeWhere((id) {
      final tag = tagsById[id];
      return tag != null && _traitOverrideGroups(tag.en).isNotEmpty;
    });
    _personSlots[index].hairGradientColorIds = <String>[];
    _personSlots[index].hairGradientStyle = _defaultHairGradientStyle;
    _personSlots[index].characterTraitsEnabled = true;
    _removedCharacterTags.remove(index);
  }

  bool _isStableCharacterTrait(
      CatalogCharacter character, CatalogTagData trait) {
    final value = _englishTagKey(trait.en);
    final identityValues = <String>{
      _englishTagKey(character.animeTag),
      _englishTagKey(character.characterTag),
      _englishTagKey(character.characterEn),
      _englishTagKey(character.unitTag),
      _englishTagKey(character.unitEn),
    }..removeWhere((item) => item.isEmpty);
    if (identityValues.contains(value)) return false;

    // Expressions, moods, and generic face-quality terms are dynamic choices.
    // They must not be silently re-applied as a character's fixed appearance.
    const dynamicTerms = <String>{
      'expression',
      'smile',
      'melancholic',
      'energetic',
      'disciplined',
      'lively',
      'mature',
      'mysterious',
      'elegant',
      'refined facial features',
      'delicate facial features',
      'sweet face',
      'cute',
      'quiet',
      'tired',
      'serious',
      'calm',
      'distant',
      'soft',
      'playful',
      'lonely',
      'confident',
      'stern',
      'fierce',
      'relaxed',
      'emotionless',
      'tsundere',
    };
    return !dynamicTerms.any((term) =>
        value == term || value.endsWith(' $term') || value.contains('$term '));
  }

  void _setCharacterTraitsEnabled(int index, bool enabled) {
    if (index < 0 || index >= _personSlots.length) return;
    final slot = _personSlots[index];
    final character = _characterForNew(slot);
    if (character == null) return;
    setState(() {
      if (!enabled) {
        _removeCharacterTraitSelections(index, character);
      } else {
        // Restoring means restoring the catalogue defaults, including a trait
        // the user may have previously removed one by one.
        _removedCharacterTags.remove(index);
      }
      slot.characterTraitsEnabled = enabled;
      if (enabled) _syncCharacterTraitsForSlot(index);
      _persist();
    });
  }

  void _syncCharacterTraitsForSlot(int index) {
    if (index < 0 || index >= _personSlots.length) return;
    final slot = _personSlots[index];
    if (!slot.detailed || slot.mode != '動漫角色' || !slot.characterTraitsEnabled) {
      return;
    }
    final character = _characterForNew(slot);
    if (character == null) return;
    final ids = _personTagIds(index);
    // Remove old auto-applied source / expression entries from saved sessions.
    // A manual expression can still be picked normally after this migration.
    for (final trait in character.traits
        .where((trait) => !_isStableCharacterTrait(character, trait))) {
      ids.removeAll(_characterTraitOptions(trait).map((tag) => tag.id));
    }
    for (final trait in character.traits
        .where((trait) => _isStableCharacterTrait(character, trait))) {
      if (_isRemovedCharacterTag(index, trait.en)) continue;
      final groups = _exclusiveTraitOverrideGroups(trait.en);
      if (_hasExplicitCharacterTraitOverride(index, character, groups)) {
        continue;
      }
      ids.addAll(_characterTraitOptions(trait).map((tag) => tag.id));
    }
    // Catalog revision: Ichika's old generic long-hair default is now the
    // more precise `long straight hair` selection. Remove the stale automatic
    // selection from saved sessions so both descriptors are not emitted.
    if (character.id == 'project_sekai_hoshino_ichika') {
      final oldLongHair = _tagByEnglish('long hair');
      if (oldLongHair != null) ids.remove(oldLongHair.id);
    }
    _syncHairGradientColorIds(index, ids);
    _syncAutoFurryIdentity(index, ids);
  }

  Set<String> _traitOverrideGroups(String en) {
    final value = en.trim().toLowerCase();
    final groups = <String>{};
    final hasHairColor = _clothingColorNames.any((color) =>
        RegExp(r'\b' + RegExp.escape(color) + r'\s+hair\b').hasMatch(value) ||
        RegExp(r'\b' +
                RegExp.escape(color) +
                r'\s+(?:close-cropped|cropped|very\s+short|very\s+long|waist-length|long|medium|short)\s+hair\b')
            .hasMatch(value));
    if (hasHairColor) {
      groups.add('hair_color');
    }
    final hasHairLength = RegExp(
            r'\b(close-cropped|cropped|very\s+short|very\s+long|waist-length|long|medium|short)\s+(?:[a-z-]+\s+)?hair\b')
        .hasMatch(value);
    final hasColoredHairLength = _clothingColorNames.any((color) => RegExp(r'\b' +
            RegExp.escape(color) +
            r'\s+(?:close-cropped|cropped|very\s+short|very\s+long|waist-length|long|medium|short)\s+hair\b')
        .hasMatch(value));
    if (hasHairLength || hasColoredHairLength) {
      groups.add('hair_length');
    }
    if (RegExp(
            r'\b(bob\s+cut|pixie\s+cut|straight\s+hair|wavy\s+hair|curly\s+hair|messy\s+hair|spiky\s+hair|braid|braids|ponytail|twintails|bun|odango|drill\s+hair)\b')
        .hasMatch(value)) {
      groups.add('hair_style');
    }
    final eyeColorPattern = _clothingColorNames.map(RegExp.escape).join('|');
    if (RegExp(r'\b(?:' + eyeColorPattern + r')\s+eyes?\b').hasMatch(value)) {
      groups.add('eye_color');
    }
    if (RegExp(
            r'\b(?:normal|big|small|round|almond|narrow|upturned|downturned)\s+eyes?\b')
        .hasMatch(value)) {
      groups.add('eye_shape');
    }
    if (RegExp(
            r'\b(?:sharingan|mangekyou sharingan|eternal mangekyou sharingan|rinnegan|rinnesharingan|byakugan|tenseigan|jougan|ketsuryugan|shinigami eyes)\b')
        .hasMatch(value)) {
      groups.add('eye_type');
    }
    if (['slender build', 'tall', 'curvy', 'muscular', 'petite']
        .contains(value)) {
      groups.add('body_type');
    }
    if ([
      'flat chest',
      'small breasts',
      'medium breasts',
      'large breasts',
      'huge breasts'
    ].contains(value)) {
      groups.add('breast_size');
    }
    return groups;
  }

  Set<String> _personOverrideGroups(int index) => _selectedTagsForPerson(index)
      .expand((tag) => _traitOverrideGroups(tag.en))
      .toSet();

  Set<String> _removedCharacterTagSet(int index) =>
      _removedCharacterTags.putIfAbsent(index, () => <String>{});

  bool _isRemovedCharacterTag(int index, String english) =>
      _removedCharacterTagSet(index).contains(_cleanTag(english).toLowerCase());

  List<CatalogTagData> _characterTraitsForSlot(PersonSlot slot, int index) {
    final character = _characterForNew(slot);
    if (character == null || !slot.characterTraitsEnabled) {
      return const <CatalogTagData>[];
    }
    final replaced = _personOverrideGroups(index);
    return character.traits
        .where((trait) => _isStableCharacterTrait(character, trait))
        .where((trait) =>
            _traitOverrideGroups(trait.en).intersection(replaced).isEmpty &&
            !_characterTraitOptions(trait)
                .any((option) => _personTagIds(index).contains(option.id)) &&
            !_isRemovedCharacterTag(index, trait.en))
        .toList();
  }

  List<String> _characterTokensForSlot(PersonSlot slot, int index) {
    if (!slot.detailed) return [];
    if (slot.mode == '動漫角色') {
      final character = _characterForNew(slot);
      if (character == null) return [];
      // A catalog character tag already carries its source identity (for
      // example `leaf_(pokemon)`). Emitting the franchise tag again adds
      // noise without making the character more specific. Unit tags remain:
      // they distinguish variants such as Nightcord at 25:00 Miku.
      final emitCharacterTag = character.characterTag.trim().isNotEmpty &&
          !_isRemovedCharacterTag(index, character.characterTag);
      return [
        if (!emitCharacterTag &&
            !_isRemovedCharacterTag(index, character.animeTag))
          character.animeTag,
        if (character.unitTag.trim().isNotEmpty &&
            !_isRemovedCharacterTag(index, character.unitTag))
          character.unitTag,
        if (emitCharacterTag) character.characterTag,
        ..._characterTraitsForSlot(slot, index).map((item) => item.en),
      ];
    }
    final own = <String>[];
    final originalCharacterTag = _cleanTag(slot.originalCharacterTag);
    final emitOriginalCharacter = originalCharacterTag.isNotEmpty &&
        !_isRemovedCharacterTag(index, originalCharacterTag);
    if (!emitOriginalCharacter &&
        _cleanTag(slot.originalAnimeTag).isNotEmpty &&
        !_isRemovedCharacterTag(index, slot.originalAnimeTag)) {
      own.add(_cleanTag(slot.originalAnimeTag));
    }
    if (emitOriginalCharacter) {
      own.add(originalCharacterTag);
    }
    own.addAll(_extraTags(slot.originalTraits)
        .where((tag) => !_isRemovedCharacterTag(index, tag)));
    return own.isEmpty ? ['original'] : own;
  }

  List<_GeneratedOutputTag> _characterOutputTagsForSlot(
      PersonSlot slot, int index) {
    if (!slot.detailed) return const <_GeneratedOutputTag>[];
    if (slot.mode == '動漫角色') {
      final character = _characterForNew(slot);
      if (character == null) return const <_GeneratedOutputTag>[];
      final result = <_GeneratedOutputTag>[];
      final emitCharacterTag = character.characterTag.trim().isNotEmpty &&
          !_isRemovedCharacterTag(index, character.characterTag);
      if (!emitCharacterTag &&
          !_isRemovedCharacterTag(index, character.animeTag)) {
        result.add(_GeneratedOutputTag(
          zh: character.animeZh,
          en: character.animeTag,
          personIndex: index,
          characterTag: true,
        ));
      }
      if (character.unitTag.trim().isNotEmpty &&
          !_isRemovedCharacterTag(index, character.unitTag)) {
        result.add(_GeneratedOutputTag(
          zh: character.unitZh.trim().isEmpty
              ? character.unitEn
              : character.unitZh,
          en: character.unitTag,
          personIndex: index,
          characterTag: true,
        ));
      }
      if (emitCharacterTag) {
        result.add(_GeneratedOutputTag(
          zh: character.characterZh,
          en: character.characterTag,
          personIndex: index,
          characterTag: true,
        ));
      }
      for (final trait in _characterTraitsForSlot(slot, index)) {
        result.add(_GeneratedOutputTag(
          zh: trait.zh,
          en: trait.en,
          personIndex: index,
          characterTag: true,
        ));
      }
      return result;
    }
    final result = <_GeneratedOutputTag>[];
    final animeTag = _cleanTag(slot.originalAnimeTag);
    final characterTag = _cleanTag(slot.originalCharacterTag);
    final emitOriginalCharacter =
        characterTag.isNotEmpty && !_isRemovedCharacterTag(index, characterTag);
    if (!emitOriginalCharacter &&
        animeTag.isNotEmpty &&
        !_isRemovedCharacterTag(index, animeTag)) {
      result.add(_GeneratedOutputTag(
        zh: slot.originalAnimeZh.trim().isEmpty
            ? animeTag
            : slot.originalAnimeZh.trim(),
        en: animeTag,
        personIndex: index,
        characterTag: true,
      ));
    }
    if (emitOriginalCharacter) {
      result.add(_GeneratedOutputTag(
        zh: slot.originalCharacterZh.trim().isEmpty
            ? characterTag
            : slot.originalCharacterZh.trim(),
        en: characterTag,
        personIndex: index,
        characterTag: true,
      ));
    }
    for (final trait in _extraTags(slot.originalTraits)) {
      final english = _positiveEnglishTag(trait);
      if (_isRemovedCharacterTag(index, english)) continue;
      result.add(_GeneratedOutputTag(
        zh: _positiveChineseTag(trait),
        en: english,
        personIndex: index,
        characterTag: true,
      ));
    }
    return result;
  }

  List<String> _characterChineseForSlot(PersonSlot slot, int index) {
    if (!slot.detailed) return ['此角色不設定細節'];
    if (slot.mode == '動漫角色' && _characterForNew(slot) == null) {
      return ['尚未選擇動漫角色'];
    }
    final tags = _characterOutputTagsForSlot(slot, index);
    if (tags.isNotEmpty) return tags.map((tag) => tag.zh).toList();
    return ['原創角色'];
  }

  List<String> _characterTokensNew() {
    final result = <String>[];
    for (var index = 0; index < _personSlots.length; index++) {
      result.addAll(_characterTokensForSlot(_personSlots[index], index));
    }
    return result;
  }

  List<String> _characterChineseNew() {
    final result = <String>[];
    for (var index = 0; index < _personSlots.length; index++) {
      result.addAll(_characterChineseForSlot(_personSlots[index], index));
    }
    return result;
  }

  List<_GeneratedOutputTag> _generatedPositiveTags() {
    final result = <_GeneratedOutputTag>[];
    for (var index = 0; index < _personSlots.length; index++) {
      final slot = _personSlots[index];
      result.addAll(_characterOutputTagsForSlot(slot, index));
      result.addAll(_personPromptTags(index));
    }
    result.addAll(_selectedTags.map(
        (tag) => _GeneratedOutputTag(zh: tag.zh, en: tag.en, tagId: tag.id)));
    result.addAll(_sharedPoseExtraOutputTags());
    return _deduplicateGeneratedOutputTags(result);
  }

  List<_GeneratedOutputTag> _deduplicateGeneratedOutputTags(
      List<_GeneratedOutputTag> tags) {
    final result = <_GeneratedOutputTag>[];
    final positions = <String, int>{};
    for (final tag in tags) {
      final key =
          '${tag.personIndex ?? -1}|${tag.characterTag}|${tag.combinationId ?? ''}|${_cleanTag(tag.en).toLowerCase()}';
      final position = positions[key];
      if (position == null) {
        positions[key] = result.length;
        result.add(tag);
        continue;
      }
      final previous = result[position];
      result[position] = _GeneratedOutputTag(
        zh: previous.zh,
        en: previous.en,
        tagId: previous.tagId ?? tag.tagId,
        tagIds: {...previous.tagIds, ...tag.tagIds}.toList(),
        personIndex: previous.personIndex,
        characterTag: previous.characterTag,
        combinationId: previous.combinationId,
        personPoseExtraValue:
            previous.personPoseExtraValue ?? tag.personPoseExtraValue,
        sharedPoseExtraValue:
            previous.sharedPoseExtraValue ?? tag.sharedPoseExtraValue,
        clothingBlockKey: previous.clothingBlockKey ?? tag.clothingBlockKey,
      );
    }
    return result;
  }

  /// Removes repeated English labels while preserving the first label's
  /// Chinese/English pairing and output order.
  ///
  /// This is intentionally separate from [_deduplicateGeneratedOutputTags].
  /// The latter keeps person/character/combination ownership so deleting a
  /// chip can still update the correct source. Prompt rendering, however,
  /// must not print the same English label twice inside one person group.
  List<_GeneratedOutputTag> _deduplicatePromptOutputTags(
      Iterable<_GeneratedOutputTag> tags,
      {Set<String>? used}) {
    final seen = used ?? <String>{};
    final result = <_GeneratedOutputTag>[];
    for (final tag in tags) {
      final key = _moderationSafePromptTag(tag.en).toLowerCase();
      if (key.isEmpty || !seen.add(key)) continue;
      result.add(tag);
    }
    return result;
  }

  void _removeGeneratedOutputTag(_GeneratedOutputTag outputTag) {
    setState(() {
      if (outputTag.combinationId != null && outputTag.personIndex != null) {
        _personCombinationIds[outputTag.personIndex!]
            ?.remove(outputTag.combinationId);
      } else if (outputTag.sharedPoseExtraValue != null) {
        final prompts = _poseExtraPrompts(_sharedPoseExtra.text);
        final target = _cleanTag(outputTag.sharedPoseExtraValue!).toLowerCase();
        prompts.removeWhere(
          (value) => _cleanTag(value).toLowerCase() == target,
        );
        _sharedPoseExtra.text = prompts.join('\n');
      } else if (outputTag.personPoseExtraValue != null &&
          outputTag.personIndex != null) {
        final personIndex = outputTag.personIndex!;
        final prompts = _poseExtraPrompts(
          _personSlots[personIndex].poseExtraPositive,
        );
        final target = _cleanTag(outputTag.personPoseExtraValue!).toLowerCase();
        prompts.removeWhere(
          (value) => _cleanTag(value).toLowerCase() == target,
        );
        final updated = prompts.join('\n');
        _personSlots[personIndex].poseExtraPositive = updated;
        final controller =
            _personSearchControllers['$personIndex:pose-extra-positive'];
        if (controller != null) controller.text = updated;
      } else if (outputTag.characterTag) {
        if (outputTag.personIndex != null) {
          _removedCharacterTagSet(outputTag.personIndex!)
              .add(_cleanTag(outputTag.en).toLowerCase());
        }
      } else if (outputTag.personIndex != null && outputTag.tagIds.isNotEmpty) {
        final character =
            _characterForNew(_personSlots[outputTag.personIndex!]);
        for (final trait in character?.traits ?? const <CatalogTagData>[]) {
          if (_characterTraitOptions(trait)
              .any((option) => outputTag.tagIds.contains(option.id))) {
            _removedCharacterTagSet(outputTag.personIndex!)
                .add(_cleanTag(trait.en).toLowerCase());
          }
        }
        _personTagIds(outputTag.personIndex!).removeAll(outputTag.tagIds);
        _syncHairGradientColorIds(
            outputTag.personIndex!, _personTagIds(outputTag.personIndex!));
      } else if (outputTag.tagId != null) {
        if (outputTag.personIndex == null) {
          _selectedIds.remove(outputTag.tagId);
        } else {
          _personTagIds(outputTag.personIndex!).remove(outputTag.tagId);
        }
      }
      _persist();
    });
  }

  String _cleanTag(String value) => value
      .trim()
      .replaceAll(RegExp(r'^[,，。.;\s]+|[,，。.;\s]+$'), '')
      .replaceAll(RegExp(r'\s+'), ' ');

  /// The unregistered-tag inbox is useful on desktop, but occupies too much
  /// of a phone screen and is hard to manage there. Do not retain it in the
  /// compact mobile layout.
  bool get _isCompactMobileViewport => (html.window.innerWidth ?? 999) < 600;

  List<String> _extraTags(String value) {
    // `;3` is a valid symbolic expression, even though a semicolon normally
    // separates prompt tags. Keep it intact everywhere text is parsed.
    const protectedSymbols = <String, String>{
      ';3': '__bw_symbol_semicolon_three__',
    };
    var normalized = value;
    for (final entry in protectedSymbols.entries) {
      normalized = normalized.replaceAll(entry.key, ' ${entry.value} ');
    }
    final restore = <String, String>{
      for (final entry in protectedSymbols.entries) entry.value: entry.key,
    };
    return normalized
        .split(RegExp(r'[,，、。.;\n\r]+'))
        .map(_cleanTag)
        .where((item) => item.isNotEmpty)
        .map((item) => restore[item] ?? item)
        .toList();
  }

  String _unknownPositiveKey(String value) {
    final englishKey = _englishTagKey(value);
    return englishKey.isEmpty ? _cleanTag(value).toLowerCase() : englishKey;
  }

  bool _isRegisteredPositiveTag(String value) {
    final cleaned = _cleanTag(value);
    if (cleaned.isEmpty) return true;
    final englishKey = _englishTagKey(cleaned);
    return _allTags.any((tag) =>
        tag.zh.trim() == cleaned ||
        (englishKey.isNotEmpty && _englishTagKey(tag.en) == englishKey));
  }

  void _collectUnknownExtraPositiveTags() {
    if (_isCompactMobileViewport) {
      _unregisteredPositiveTags.clear();
      return;
    }
    final candidates = <String>[
      ..._extraTags(_extraPositive.text),
      ..._personSlots.expand(
        (slot) => _poseExtraPrompts(slot.poseExtraPositive),
      ),
      ..._poseExtraPrompts(_sharedPoseExtra.text),
    ];
    for (final token in candidates) {
      if (_isRegisteredPositiveTag(token)) continue;
      final key = _unknownPositiveKey(token);
      if (key.isEmpty) continue;
      final alreadyStored = _unregisteredPositiveTags
          .any((value) => _unknownPositiveKey(value) == key);
      if (!alreadyStored) _unregisteredPositiveTags.add(token);
    }
    _unregisteredPositiveTags.removeWhere(_isRegisteredPositiveTag);
  }

  void _clearExtraPositive() {
    if (_extraPositive.text.trim().isEmpty) return;
    setState(() {
      _extraPositive.clear();
      _collectUnknownExtraPositiveTags();
      _persist();
    });
  }

  Future<void> _pasteAndReplaceExtraPositive() async {
    String? pasted;
    try {
      pasted = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    } catch (_) {
      // Browser clipboard access may be denied when it is not user initiated.
    }
    final value = pasted?.trim() ?? '';
    if (value.isEmpty) {
      return;
    }
    if (!mounted) return;
    setState(() {
      // Replace, rather than append, so pasted prompts never mix with an old
      // extra-positive sentence by accident.
      _extraPositive.text = value;
      _collectUnknownExtraPositiveTags();
      _persist();
    });
  }

  String _positiveEnglishTag(String value) {
    final cleaned = _cleanTag(value);
    if (cleaned.isEmpty || !RegExp(r'[\u4e00-\u9fff]').hasMatch(cleaned)) {
      return cleaned;
    }
    for (final tag in _allTags) {
      if (tag.zh == cleaned) return tag.en;
    }
    const replacements = <String, String>{
      '超長髮': 'very long hair',
      '極短髮': 'close-cropped hair',
      '粉紅色': 'pink',
      '藍色': 'blue',
      '黑色': 'black',
      '白色': 'white',
      '紅色': 'red',
      '紫色': 'purple',
      '綠色': 'green',
      '黃色': 'yellow',
      '棕色': 'brown',
      '灰色': 'gray',
      '銀色': 'silver',
      '金色': 'gold',
      '長髮': 'long hair',
      '短髮': 'cropped hair',
      '蕾絲': 'lace',
      '花邊': 'frills',
      '哥德式': 'gothic',
      '晚禮服': 'evening gown',
      '長裙': 'long skirt',
      '短裙': 'above-knee skirt',
      '迷你裙': 'miniskirt',
      '泳裝': 'swimsuit',
      '運動服': 'sportswear',
      '單肩': 'one shoulder',
      '連身': 'one-piece',
      '外套': 'jacket',
      '上衣': 'top',
      '洋裝': 'dress',
      '裙子': 'skirt',
      '褲子': 'pants',
      '短褲': 'shorts',
      '胸罩': 'bra',
      '內褲': 'panties',
      '內衣': 'underwear',
      '襪子': 'socks',
      '鞋子': 'shoes',
      '靴子': 'boots',
      '微笑': 'smile',
      '臉紅': 'blush',
      '哭泣': 'crying',
      '生氣': 'angry',
      '驚訝': 'surprised',
      '坐著': 'sitting',
      '站立': 'standing',
      '躺著': 'lying',
    };
    var translated = cleaned;
    final entries = replacements.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in entries) {
      translated = translated.replaceAll(entry.key, entry.value);
    }
    return translated;
  }

  String _positiveChineseTag(String value) {
    final cleaned = _cleanTag(value);
    if (cleaned.isEmpty || RegExp(r'[\u4e00-\u9fff]').hasMatch(cleaned)) {
      return cleaned;
    }
    for (final tag in _allTags) {
      if (tag.en.toLowerCase() == cleaned.toLowerCase()) return tag.zh;
    }
    const replacements = <String, String>{
      'very long hair': '超長髮',
      'close-cropped hair': '極短髮',
      'long hair': '長髮',
      'cropped hair': '短髮',
      'blue': '藍色',
      'black': '黑色',
      'white': '白色',
      'red': '紅色',
      'pink': '粉紅色',
      'purple': '紫色',
      'green': '綠色',
      'yellow': '黃色',
      'brown': '棕色',
      'gray': '灰色',
      'silver': '銀色',
      'gold': '金色',
      'jacket': '外套',
      'top': '上衣',
      'dress': '洋裝',
      'skirt': '裙子',
      'pants': '褲子',
      'shorts': '短褲',
      'bra': '胸罩',
      'panties': '內褲',
      'underwear': '內衣',
      'socks': '襪子',
      'shoes': '鞋子',
      'boots': '靴子',
      'lace': '蕾絲',
      'smile': '微笑',
      'blush': '臉紅',
      'crying': '哭泣',
      'angry': '生氣',
      'surprised': '驚訝',
      'sitting': '坐著',
      'standing': '站立',
      'lying': '躺著',
    };
    var translated = cleaned;
    final entries = replacements.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in entries) {
      translated = translated.replaceAll(entry.key, entry.value);
    }
    return translated;
  }

  String? _hairLengthTag(String value) {
    final normalized = _cleanTag(value).toLowerCase();
    final match = RegExp(
            r'^(close-cropped|cropped|very short|very long|waist-length|long|medium|short) hair$')
        .firstMatch(normalized);
    return match?.group(0);
  }

  String? _effectiveHairLength(PersonSlot slot, int index) {
    if (!slot.detailed) return null;
    for (final tag in _selectedTagsForPerson(index)) {
      final selectedLength = _hairLengthTag(tag.en);
      if (selectedLength != null) return selectedLength;
    }
    if (slot.mode == '動漫角色') {
      final character = _characterForNew(slot);
      if (character != null) {
        for (final trait in _characterTraitsForSlot(slot, index)) {
          final originalLength = _hairLengthTag(trait.en);
          if (originalLength != null) return originalLength;
        }
      }
    }
    for (final trait in _extraTags(slot.originalTraits)) {
      final originalLength = _hairLengthTag(trait);
      if (originalLength != null) return originalLength;
    }
    return null;
  }

  List<String> get _hairGuardNegativeTags {
    final lengths = <String>{};
    for (var index = 0; index < _personSlots.length; index++) {
      final length = _effectiveHairLength(_personSlots[index], index);
      if (length != null) lengths.add(length);
    }
    if (lengths.length != 1) return const <String>[];
    final result = <String>[];
    switch (lengths.first) {
      case 'cropped hair':
      case 'short hair':
        result.add('long hair');
        break;
      case 'close-cropped hair':
      case 'very short hair':
        result.add('long hair');
        break;
      case 'long hair':
      case 'very long hair':
        result.add('cropped hair');
        break;
      case 'medium hair':
        result.addAll(['cropped hair', 'long hair']);
        break;
    }
    final seen = <String>{};
    return result.where((tag) => seen.add(tag)).toList();
  }

  String _moderationSafePromptTag(String value) {
    var result = _cleanTag(value);
    const phraseReplacements = <String, String>{
      'baby blue': 'pastel blue',
      'baby bangs': 'micro bangs',
      'baby carry': 'cradle carry',
      'child carry': 'side carry',
      'very short hair': 'close-cropped hair',
      'short hair with long locks': 'cropped hair with long locks',
      'short ponytail': 'bob-length ponytail',
      'short twintails': 'bob-length twintails',
      'fluffy short hair': 'fluffy bob cut',
      'short sidelocks': 'cropped sidelocks',
      'short bangs': 'cropped bangs',
      'short hair': 'cropped hair',
      'school uniform': 'formal blazer outfit',
      'student uniform': 'formal blazer outfit',
      'serafuku': 'sailor-style outfit',
      'school shoes': 'loafers',
      'school outfit': 'daytime formal outfit',
      'short sleeves': 'above-elbow sleeves',
      'short shorts': 'hot pants',
      'short skirt': 'above-knee skirt',
      'short dress': 'above-knee dress',
      'short length': 'upper-thigh length',
      'slim pants': 'narrow-leg pants',
      'slim fit': 'tailored fit',
      'sweet cute style': 'sweet feminine style',
      'cute mood': 'cheerful mood',
    };
    final phrases = phraseReplacements.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in phrases) {
      result = result.replaceAll(
        RegExp(r'\b' + RegExp.escape(entry.key) + r'\b', caseSensitive: false),
        entry.value,
      );
    }
    result = result
        .replaceAll(RegExp(r'\bcute\b', caseSensitive: false), 'charming')
        .replaceAll(RegExp(r'\bslim\b', caseSensitive: false), 'slender')
        .replaceAll(RegExp(r'\bshort\b', caseSensitive: false), 'compact');
    if (RegExp(
      r'\b(baby|child|children|kid|kids|teen|teenage|minor|underage|loli|shota)\b',
      caseSensitive: false,
    ).hasMatch(result)) {
      return '';
    }
    return _cleanTag(result);
  }

  List<String> get _negativeTokens {
    final seen = <String>{};
    return [..._extraTags(_negative.text), ..._hairGuardNegativeTags]
        .map(_moderationSafePromptTag)
        .where((tag) => tag.isNotEmpty && seen.add(tag.toLowerCase()))
        .toList();
  }

  List<String> get _positiveTokens {
    final tokens = <String>[..._peopleTokensNew()];
    for (var index = 0; index < _personSlots.length; index++) {
      tokens.addAll(_characterTokensForSlot(_personSlots[index], index));
      tokens.addAll(_personPromptTags(index).map((tag) => tag.en));
    }
    tokens.addAll(
      _selectedTags
          .where((tag) => !_isSharedActionGroup(tag.group))
          .map((tag) => tag.en),
    );
    tokens.addAll(_extraTags(_extraPositive.text).map(_positiveEnglishTag));
    tokens.addAll(_extraTags(_preprompt.text));
    tokens.addAll(
      _selectedTags
          .where((tag) => _isSharedActionGroup(tag.group))
          .map((tag) => tag.en),
    );
    final seen = <String>{};
    return tokens
        .map(_moderationSafePromptTag)
        .where((token) => token.isNotEmpty && seen.add(token.toLowerCase()))
        .toList();
  }

  List<String> get _sharedPositiveTokens => <String>[
        ..._selectedTags
            .where((tag) => !_isSharedActionGroup(tag.group))
            .map((tag) => tag.en),
        ..._extraTags(_extraPositive.text).map(_positiveEnglishTag),
        ..._extraTags(_preprompt.text),
      ].map(_moderationSafePromptTag).where((tag) => tag.isNotEmpty).toList();

  List<String> get _sharedActionTokens => _selectedTags
      .where((tag) => _isSharedActionGroup(tag.group))
      .map((tag) => tag.en)
      .map(_moderationSafePromptTag)
      .where((tag) => tag.isNotEmpty)
      .toList();

  String _groupedPositiveText() {
    final output = <String>[];
    final usedShared = <String>{};
    void addSharedTokens(Iterable<String> values) {
      for (final value in values.map(_moderationSafePromptTag)) {
        if (value.isNotEmpty && usedShared.add(value.toLowerCase())) {
          output.add('$value.');
        }
      }
    }

    addSharedTokens(_peopleTokensNew());
    for (var index = 0; index < _personSlots.length; index++) {
      final slot = _personSlots[index];
      final personal = _deduplicatePromptOutputTags([
        ..._characterOutputTagsForSlot(slot, index),
        ..._personScopedPromptTags(index),
      ]);
      if (personal.isEmpty) continue;

      // Keep every person's stable identity, outfit, and individual actions
      // inside one outer block with one common weight. Garments keep their
      // own inner parentheses so their colours and details remain local.
      final emphasizeHair =
          personal.where((tag) => _isHairPromptOutputTag(index, tag));
      final characterFeatures = personal.where((tag) =>
          _isCharacterWeightOutputTag(tag) &&
          !_isHairPromptOutputTag(index, tag));
      final clothing = personal.where(_isClothingWeightOutputTag).toList();
      final individualActions = personal
          .where((tag) =>
              !_isCharacterWeightOutputTag(tag) &&
              !_isClothingWeightOutputTag(tag))
          .toList();
      final segments = <String>[
        _promptTagBlock(characterFeatures),
        if (emphasizeHair.isNotEmpty)
          _promptTagBlock(
            emphasizeHair,
            weight: slot.hairPromptWeightEnabled ? slot.hairPromptWeight : null,
          ),
        _groupedClothingPromptBlock(clothing),
        _promptTagBlock(individualActions),
      ].where((block) => block.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        final suffix = slot.promptWeightEnabled
            ? ':${_boundedPromptWeight(slot.personPromptWeight).toStringAsFixed(2)}'
            : '';
        output.add('(${segments.join('. ')}$suffix).');
      }
      usedShared.addAll(
        personal
            .map((tag) => _moderationSafePromptTag(tag.en).toLowerCase())
            .where((value) => value.isNotEmpty),
      );
    }
    for (var index = 0; index < _personSlots.length; index++) {
      addSharedTokens(_personFinalPromptTags(index).map((tag) => tag.en));
    }
    addSharedTokens(_sharedActionTokens);
    addSharedTokens(_sharedPositiveTokens);
    return output.join(' ');
  }

  String get _positiveText {
    final hasDetailedPerson = _personSlots.any((slot) => slot.detailed);
    return hasDetailedPerson
        ? _groupedPositiveText()
        : _positiveTokens.map((tag) => '$tag.').join(' ');
  }

  String get _positiveZh {
    final tokens = <String>[_peopleZhNew()];
    final used = <String>{};

    if (_personSlots.length > 1) {
      for (var index = 0; index < _personSlots.length; index++) {
        final personal = _deduplicatePromptOutputTags([
          ..._characterOutputTagsForSlot(_personSlots[index], index),
          ..._personScopedPromptTags(index),
        ], used: used);
        if (personal.isEmpty) continue;
        tokens
            .add('人物 ${index + 1}：${personal.map((tag) => tag.zh).join('、')}');
      }
      for (var index = 0; index < _personSlots.length; index++) {
        tokens.addAll(_deduplicatePromptOutputTags(
                _personFinalPromptTags(index),
                used: used)
            .map((tag) => tag.zh));
      }
    } else {
      for (var index = 0; index < _personSlots.length; index++) {
        tokens.addAll(_deduplicatePromptOutputTags([
          ..._characterOutputTagsForSlot(_personSlots[index], index),
          ..._personPromptTags(index),
        ], used: used)
            .map((tag) => tag.zh));
      }
    }

    tokens.addAll(_deduplicatePromptOutputTags(
      _selectedTags.map((tag) => _GeneratedOutputTag(
            zh: tag.zh,
            en: tag.en,
            tagId: tag.id,
          )),
      used: used,
    ).map((tag) => tag.zh));
    if (_extraPositive.text.trim().isNotEmpty) {
      final extra = _deduplicatePromptOutputTags(
        _extraTags(_extraPositive.text).map((value) => _GeneratedOutputTag(
              zh: _positiveChineseTag(value),
              en: _positiveEnglishTag(value),
            )),
        used: used,
      );
      if (extra.isNotEmpty) {
        tokens.add('額外正向標籤（中文對照）：${extra.map((tag) => tag.zh).join('、')}');
      }
    }
    if (_preprompt.text.trim().isNotEmpty) {
      tokens.add(
        'Amanatsu 品質前綴：${_extraTags(_preprompt.text).map(_positiveChineseTag).join('、')}',
      );
    }
    return tokens.join('。 ');
  }

  String get _negativeText => _negativeTokens.map((tag) => '$tag.').join(' ');

  void _toggleNegativeTag(String english, String chinese) {
    final tags = _extraTags(_negative.text);
    final index = tags.indexWhere(
      (item) => item.toLowerCase() == english.toLowerCase(),
    );
    setState(() {
      if (index >= 0) {
        tags.removeAt(index);
      } else {
        tags.add(english);
      }
      _customNegativeTranslations[english.toLowerCase()] = chinese;
      _negative.text = tags.join(', ');
      _persist();
    });
  }

  Future<void> _addNegativeTag() async {
    final englishController = TextEditingController();
    final chineseController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('新增負面標籤'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: englishController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '英文標籤',
                hintText: '例如 blurry 或 bad composition',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: chineseController,
              decoration: const InputDecoration(
                labelText: '中文翻譯',
                hintText: '例如 模糊 或 構圖不佳',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('加入'),
          ),
        ],
      ),
    );
    final english = _cleanTag(englishController.text);
    final chinese = _cleanTag(chineseController.text).ifEmpty(english);
    englishController.dispose();
    chineseController.dispose();
    if (confirmed != true || english.isEmpty) return;
    final tags = _extraTags(_negative.text);
    if (!tags.any((item) => item.toLowerCase() == english.toLowerCase())) {
      tags.add(english);
    }
    setState(() {
      _negative.text = tags.join(', ');
      _customNegativeTranslations[english.toLowerCase()] = chinese;
      _persist();
    });
  }

  Widget _negativeTagPicker() {
    final selected =
        _extraTags(_negative.text).map((item) => item.toLowerCase()).toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: _negativeCatalog.map((item) {
            final english = item['en']!;
            final chinese = item['zh']!;
            return FilterChip(
              label: Text('$chinese / $english'),
              selected: selected.contains(english.toLowerCase()),
              onSelected: (_) => _toggleNegativeTag(english, chinese),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addNegativeTag,
          icon: const Icon(Icons.add),
          label: const Text('新增負面標籤（中英文）'),
        ),
      ],
    );
  }

  bool _isPoseCompositionTag(TagItem tag) =>
      const {'姿勢', '性姿勢', '性行為', '動作', 'pose', 'sex_position'}
          .contains(tag.group) ||
      expandedGeneralPoseGroups.contains(tag.group) ||
      expandedSexualPoseGroups.contains(tag.group) ||
      expandedSexualActGroups.contains(tag.group);

  bool _isUnrestrictedCompositionTag(TagItem tag) =>
      _isClothingGroup(tag.group) ||
      _isPoseCompositionTag(tag) ||
      _isFaceExpressionTag(tag);

  String? _conflictGroup(TagItem tag) {
    if (_isOnePieceStyleTag(tag)) return 'onepiece_style';
    if (_isLegacyClothingStyleTag(tag)) {
      final scope = _clothingScopeForTag(tag);
      if (scope != null) return '${scope}_style';
    }
    if (tag.group == '內衣') return 'underwear_top';
    if (tag.group == '內褲') return 'underwear_bottom';
    if (tag.group == '胸罩') return 'bra';
    if (tag.group == '內衣顏色') return 'underwear_top_color';
    if (tag.group == '內褲顏色') return 'underwear_bottom_color';
    if (tag.group == '胸罩顏色') return 'bra_color';
    if (tag.group == '襪子顏色') return 'legwear_color';
    if (tag.group == '鞋子顏色') return 'footwear_color';
    if (tag.group == '服裝細節顏色') return 'clothing_detail_color';
    if (tag.conflictGroup != null) return tag.conflictGroup;
    final traitGroups = _traitOverrideGroups(tag.en);
    if (traitGroups.isNotEmpty) return traitGroups.first;
    if (tag.group == '上衣風格') return 'top_style';
    if (tag.group == '下身風格') return 'bottom_style';
    if (tag.group == '上衣顏色') return 'top_color';
    if (tag.group == '下身顏色') return 'bottom_color';
    if (tag.group == '服裝顏色') return 'clothing_color';
    if (tag.group == '配件顏色') return 'accessory_color';
    if (tag.group == '上衣') return 'top';
    if (['褲子', '裙子'].contains(tag.group)) return 'bottom';
    if (tag.group == '胸罩') return 'bra';
    if (['內衣', '內褲'].contains(tag.group)) return 'underwear';
    if (tag.group == _cosplayGroup) {
      return 'onepiece_style';
    }
    if (tag.group == '服裝') return 'one_piece';
    // Camera/framing tags are composable: for example, full body +
    // low-angle view + from below can intentionally be used together.
    if (_isCameraGroup(tag.group)) return null;
    if (tag.group == '姿勢') {
      const basicPoses = {
        'standing',
        'sitting',
        'kneeling',
        'lying',
        'lying on side',
        'lying on back',
        'squatting',
      };
      if (basicPoses.contains(tag.en)) return 'basic_pose';
      if (tag.en == 'arms up') return 'arm_pose';
      if (tag.en == 'hand on hip') return 'hand_gesture';
      return 'pose';
    }
    if (tag.group == '性姿勢') return 'sex_position';
    if (_isScenePickerGroup(tag.group)) return 'scene';
    if (tag.group == '胸部' &&
        [
          'flat chest',
          'small breasts',
          'medium breasts',
          'large breasts',
          'huge breasts'
        ].contains(tag.en)) return 'breast_size';
    if (tag.group == '表情' && ['closed mouth', 'open mouth'].contains(tag.en))
      return 'mouth';
    if (tag.group == '表情' && ['wink', 'closed eyes'].contains(tag.en))
      return 'eyes';
    return null;
  }

  bool _tagsConflict(TagItem first, TagItem second) {
    // Clothing and pose tags are intentionally composable. A character may
    // wear multiple layers/details and combine several posture/action tags,
    // so do not auto-replace these selections through conflict handling.
    if (_isUnrestrictedCompositionTag(first) ||
        _isUnrestrictedCompositionTag(second)) {
      return false;
    }
    final firstGroup = _conflictGroup(first);
    final secondGroup = _conflictGroup(second);
    if (firstGroup != null && firstGroup == secondGroup) {
      if (firstGroup == 'top_style' || firstGroup == 'bottom_style') {
        return false;
      }
      return firstGroup != 'clothing_color';
    }
    if ((firstGroup == 'arm_pose' &&
            {'left_arm_pose', 'right_arm_pose'}.contains(secondGroup)) ||
        (secondGroup == 'arm_pose' &&
            {'left_arm_pose', 'right_arm_pose'}.contains(firstGroup))) {
      return true;
    }
    final firstNude =
        first.en == 'nude' || first.en == 'topless' || first.en == 'bottomless';
    final secondNude = second.en == 'nude' ||
        second.en == 'topless' ||
        second.en == 'bottomless';
    if (firstNude || secondNude) {
      final clothing = {
        'top',
        'bottom',
        'top_color',
        'bottom_color',
        'top_style',
        'bottom_style',
        'one_piece'
      };
      if ((firstNude && clothing.contains(secondGroup)) ||
          (secondNude && clothing.contains(firstGroup))) return true;
    }
    return false;
  }

  bool _tagBelongsToRandomGroups(TagItem tag, Set<String> groups) {
    if (groups.contains(tag.group)) return true;
    if (groups.contains(_animalTraitGroup) &&
        const {
          _animalEarColorGroup,
          _animalTailColorGroup,
          _animalHandColorGroup,
          _animalFootColorGroup,
        }.contains(tag.group)) {
      return true;
    }
    if (groups.contains(_wingTypeGroup) && tag.group == _wingColorGroup) {
      return true;
    }
    if (groups.contains(_staticFaceAppearanceGroup) &&
        _isStaticFaceAppearanceTag(tag)) {
      return true;
    }
    if (groups.contains(_objectInteractionGroup) &&
        _isObjectInteractionTag(tag)) {
      return true;
    }
    final objectPickerGroup = _objectPickerGroupForTag(tag);
    if (objectPickerGroup != null && groups.contains(objectPickerGroup)) {
      return true;
    }
    if (groups.contains('表情') && _isFaceExpressionTag(tag)) return true;
    if (groups.any(_isExpressionPickerGroup)) {
      final subgroup = _expressionSubgroupForTag(tag);
      if (subgroup != null && groups.contains(subgroup)) return true;
    }
    return groups.contains('髮型') && tag.group == '髮色';
  }

  void _randomizePersonGroups(int personIndex, List<String> groups) {
    if (personIndex < 0 || personIndex >= _personSlots.length) return;
    final random = Random();
    final target = _personTagIds(personIndex);
    final groupSet = groups.toSet();
    final current = _selectedTagsForPerson(personIndex);
    final protectedTags = current
        .where((tag) => !_tagBelongsToRandomGroups(tag, groupSet))
        .toList();
    target.removeWhere((id) => _allTags.any(
        (tag) => tag.id == id && _tagBelongsToRandomGroups(tag, groupSet)));
    final added = <TagItem>[];

    bool add(TagItem? tag) {
      if (tag == null ||
          protectedTags.any((other) => _tagsConflict(other, tag)) ||
          added.any((other) => _tagsConflict(other, tag))) {
        return false;
      }
      target.add(tag.id);
      added.add(tag);
      return true;
    }

    List<TagItem> candidates(String group) => _tagsForPickerGroup(group)
        .where((tag) => _showAdult || !tag.adult)
        .toList()
      ..shuffle(random);

    void addRandomFromGroup(String group, {int min = 0, int max = 1}) {
      final pool = candidates(group);
      if (pool.isEmpty) return;
      final count = min + random.nextInt(max - min + 1);
      if (count == 0) return;
      var attempts = 0;
      for (final tag in pool) {
        if (attempts++ >= pool.length || added.length >= 12) break;
        if (add(tag) &&
            added.where((item) => item.group == group).length >= count) {
          break;
        }
      }
    }

    void addRandomFromExpressionGroup(String group,
        {int min = 0, int max = 1}) {
      final pool = _allTags
          .where((tag) =>
              _expressionSubgroupForTag(tag) == group &&
              (_showAdult || !tag.adult))
          .toList()
        ..shuffle(random);
      if (pool.isEmpty) return;
      final count = min + random.nextInt(max - min + 1);
      var addedCount = 0;
      for (final tag in pool) {
        if (added.length >= 12 || addedCount >= count) break;
        if (add(tag)) addedCount++;
      }
    }

    if (groupSet.contains('眼睛')) {
      addRandomFromGroup('眼睛', max: 2);
    }
    if (groupSet.contains(_animalTraitGroup)) {
      addRandomFromGroup(_animalTraitGroup, max: 2);
      final selected =
          target.map((id) => _tagsById[id]).whereType<TagItem>().toList();
      if (selected.any(_isAnimalEarTypeTag)) {
        addRandomFromGroup(_animalEarColorGroup, min: 1);
      }
      if (selected.any(_isAnimalTailTypeTag)) {
        addRandomFromGroup(_animalTailColorGroup, min: 1);
      }
      if (selected.any(_isAnimalHandTypeTag)) {
        addRandomFromGroup(_animalHandColorGroup, min: 1);
      }
      if (selected.any(_isAnimalFootTypeTag)) {
        addRandomFromGroup(_animalFootColorGroup, min: 1);
      }
    }
    if (groupSet.contains(_wingTypeGroup)) {
      addRandomFromGroup(_wingTypeGroup, min: 1);
      if (target
          .map((id) => _tagsById[id])
          .whereType<TagItem>()
          .any(_isWingTypeTag)) {
        addRandomFromGroup(_wingColorGroup, min: 1);
      }
    }
    if (groupSet.contains(_staticFaceAppearanceGroup)) {
      addRandomFromGroup(_staticFaceAppearanceGroup, max: 2);
    }
    if (groupSet.contains('身體特徵')) {
      addRandomFromGroup('身體特徵', max: 2);
    }
    if (groupSet.contains('額外特徵')) {
      addRandomFromGroup('額外特徵', max: 2);
      addRandomFromGroup('額外特徵位置');
      addRandomFromGroup('額外特徵顏色');
    }
    if (groupSet.contains('髮長')) {
      addRandomFromGroup('髮長', min: 1);
    }
    if (groupSet.contains('髮型')) {
      addRandomFromGroup('髮色', min: 1);
      addRandomFromGroup('髮型', min: 1, max: 2);
    }
    if (groupSet.contains('表情')) {
      addRandomFromExpressionGroup(_expressionEyesGroup, max: 2);
      addRandomFromExpressionGroup(_expressionMouthGroup, max: 2);
      addRandomFromExpressionGroup(_expressionTeasingGroup, max: 1);
      addRandomFromExpressionGroup(_expressionSymbolGroup, max: 1);
      addRandomFromExpressionGroup(_expressionOtherGroup, max: 2);
    }
    if (groupSet.contains(_expressionEyesGroup)) {
      addRandomFromExpressionGroup(_expressionEyesGroup, max: 3);
    }
    if (groupSet.contains(_expressionMouthGroup)) {
      addRandomFromExpressionGroup(_expressionMouthGroup, max: 4);
    }
    if (groupSet.contains(_expressionTeasingGroup)) {
      addRandomFromExpressionGroup(_expressionTeasingGroup, max: 3);
    }
    if (groupSet.contains(_expressionSymbolGroup)) {
      addRandomFromExpressionGroup(_expressionSymbolGroup, max: 2);
    }
    if (groupSet.contains(_expressionOtherGroup)) {
      addRandomFromExpressionGroup(_expressionOtherGroup, max: 3);
    }
    if (groupSet.contains('胸部')) {
      addRandomFromGroup('胸部', min: 1);
    }
    if (groupSet.contains('裸露')) {
      addRandomFromGroup('裸露', max: 1);
    }
    if (groupSet.contains('姿勢')) {
      final basic = candidates('姿勢')
          .where((tag) => _conflictGroup(tag) == 'basic_pose')
          .toList();
      if (basic.isNotEmpty) add(basic.first);
      addRandomFromGroup('姿勢', max: 2);
    }
    if (groupSet.contains('動作')) {
      addRandomFromGroup('動作', max: 2);
    }
    if (groupSet.contains('物件')) {
      addRandomFromGroup('物件', max: 2);
    }
    if (groupSet.contains('成人道具')) {
      addRandomFromGroup('成人道具', max: 1);
    }
    if (groupSet.contains('性行為')) {
      addRandomFromGroup('性行為', max: 1);
    }
    if (groupSet.contains('性姿勢')) {
      addRandomFromGroup('性姿勢', max: 1);
    }

    const directlyHandledGroups = <String>{
      '眼睛',
      _animalTraitGroup,
      _wingTypeGroup,
      _staticFaceAppearanceGroup,
      '身體特徵',
      '額外特徵',
      '髮長',
      '髮型',
      '表情',
      _expressionEyesGroup,
      _expressionMouthGroup,
      _expressionTeasingGroup,
      _expressionSymbolGroup,
      _expressionOtherGroup,
      '胸部',
      '裸露',
      '姿勢',
      '動作',
      '物件',
      '成人道具',
      '性行為',
      '性姿勢',
    };
    final expandedGroups = groupSet.difference(directlyHandledGroups);
    if (expandedGroups.isNotEmpty) {
      final pool = _allTags
          .where((tag) =>
              (expandedGroups.contains(tag.group) ||
                  (expandedGroups.contains(_objectInteractionGroup) &&
                      _isObjectInteractionTag(tag)) ||
                  expandedGroups.contains(_objectPickerGroupForTag(tag))) &&
              (_showAdult || !tag.adult))
          .toList()
        ..shuffle(random);
      final maxCount = expandedGroups.any(expandedSexualPoseGroups.contains)
          ? 1
          : min(2, pool.length);
      for (final tag in pool) {
        if (added
                .where((item) =>
                    expandedGroups.contains(item.group) ||
                    (expandedGroups.contains(_objectInteractionGroup) &&
                        _isObjectInteractionTag(item)) ||
                    expandedGroups.contains(_objectPickerGroupForTag(item)))
                .length >=
            maxCount) {
          break;
        }
        add(tag);
      }
    }

    _removeOrphanedPhysicalTraitColors(target);
    _syncHairGradientColorIds(personIndex, target);
    _syncAutoFurryIdentity(personIndex, target);
    setState(_persist);
  }

  void _randomizeSceneAndFrame() {
    final random = Random();
    final sceneCandidates = _allTags
        .where((tag) =>
            _isScenePickerGroup(tag.group) && (_showAdult || !tag.adult))
        .toList()
      ..shuffle(random);
    final outdoorTimeCandidates = _allTags
        .where((tag) =>
            tag.group == _outdoorTimeGroup && (_showAdult || !tag.adult))
        .toList()
      ..shuffle(random);
    final framingCandidates = _allTags
        .where((tag) =>
            tag.group == _cameraFramingGroup && (_showAdult || !tag.adult))
        .toList()
      ..shuffle(random);
    final viewCandidates = _allTags
        .where((tag) => tag.group == '畫面' && (_showAdult || !tag.adult))
        .toList()
      ..shuffle(random);

    setState(() {
      _selectedIds.removeWhere((id) => _allTags.any((tag) =>
          tag.id == id &&
          (_isScenePickerGroup(tag.group) ||
              tag.group == _outdoorTimeGroup ||
              _isCameraGroup(tag.group))));
      if (sceneCandidates.isNotEmpty) {
        final scene = sceneCandidates.first;
        _selectedIds.add(scene.id);
        if (scene.group == _outdoorSceneGroup &&
            outdoorTimeCandidates.isNotEmpty) {
          _selectedIds.add(outdoorTimeCandidates.first.id);
        }
      }
      if (framingCandidates.isNotEmpty) {
        _selectedIds.add(framingCandidates.first.id);
      }
      if (viewCandidates.isNotEmpty) {
        _selectedIds.add(viewCandidates.first.id);
      }
      _persist();
    });
  }

  TagItem? _randomClothingTag(List<String> groups, Random random) {
    final seen = <String>{};
    final candidates = _allTags
        .where((tag) =>
            groups.contains(tag.group) &&
            (_showAdult || !tag.adult) &&
            seen.add('${tag.group}|${tag.en}'))
        .toList()
      ..shuffle(random);
    return candidates.isEmpty ? null : candidates.first;
  }

  void _randomizeScopedClothing(int personIndex, Random random) {
    final target = _personTagIds(personIndex);
    final bases = _clothingDesignBases(_selectedTagsForPerson(personIndex));

    void choose(String group) {
      final candidate = _randomClothingTag([group], random);
      if (candidate == null) return;
      final conflicts = _selectedTagsForPerson(personIndex)
          .where((tag) => _tagsConflict(tag, candidate))
          .map((tag) => tag.id)
          .toList();
      target.removeAll(conflicts);
      target.add(candidate.id);
    }

    for (final base in bases) {
      final scope = _clothingScopeForBase(base);
      if (scope == null) continue;
      choose(_scopedClothingGroup(scope, 'style'));
      choose(_scopedClothingGroup(scope, 'material'));
      if (random.nextBool()) choose(_scopedClothingGroup(scope, 'detail'));
      if (random.nextBool()) {
        choose(_scopedClothingGroup(scope, 'detail_color'));
      }
      if (random.nextBool()) choose(_scopedClothingGroup(scope, 'wear'));
    }
  }

  void _randomizeClothing(int personIndex) {
    if (personIndex < 0 || personIndex >= _personSlots.length) return;
    final random = Random();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _randomizeScopedClothing(personIndex, Random());
        _persist();
      });
    });
    final clothingGroups = {
      '上衣',
      '褲子',
      '裙子',
      '內衣',
      '胸罩',
      '內褲',
      '襪子',
      '鞋子',
      '服裝',
      _cosplayGroup,
      '配件',
      '配件位置',
      '配件顏色',
      '服裝邊線色',
      '上衣邊線色',
      '下身邊線色',
      '內衣邊線色',
      '胸罩邊線色',
      '內褲邊線色',
      '襪子邊線色',
      '鞋子邊線色',
      '配件邊線色',
      '內衣顏色',
      '胸罩顏色',
      '內褲顏色',
      '襪子顏色',
      '鞋子顏色',
      '上衣風格',
      '下身風格',
      '上衣顏色',
      '下身顏色',
      '服裝顏色',
      '服裝細節',
      '服裝細節顏色',
      '服裝材質',
      '穿脫狀態',
    };
    final target = _personTagIds(personIndex);
    final protectedTags = _selectedTagsForPerson(personIndex)
        .where((tag) =>
            !clothingGroups.contains(tag.group) &&
            !_isScopedClothingGroup(tag.group))
        .toList();
    target.removeWhere((id) => _allTags.any((tag) =>
        tag.id == id &&
        (clothingGroups.contains(tag.group) ||
            _isScopedClothingGroup(tag.group))));

    final added = <TagItem>[];
    void add(TagItem? tag) {
      if (tag == null ||
          protectedTags.any((other) => _tagsConflict(other, tag)) ||
          added.any((other) => _tagsConflict(other, tag))) {
        return;
      }
      target.add(tag.id);
      added.add(tag);
    }

    if (random.nextBool()) {
      add(_randomClothingTag(['服裝'], random));
      if (random.nextBool()) {
        add(_randomClothingTag(
            [_scopedClothingGroup('onepiece', 'style'), _cosplayGroup],
            random));
      }
      add(_randomClothingTag(['服裝顏色'], random));
    } else {
      add(_randomClothingTag(['上衣'], random));
      add(_randomClothingTag(['褲子', '裙子'], random));
      if (random.nextBool()) add(_randomClothingTag(['上衣風格'], random));
      if (random.nextBool()) add(_randomClothingTag(['下身風格'], random));
      if (random.nextBool()) add(_randomClothingTag(['上衣顏色'], random));
      if (random.nextBool()) add(_randomClothingTag(['下身顏色'], random));
    }
    if (random.nextBool()) add(_randomClothingTag(['胸罩'], random));
    if (random.nextBool()) add(_randomClothingTag(['內衣'], random));
    if (random.nextBool()) add(_randomClothingTag(['內褲'], random));
    if (random.nextBool()) add(_randomClothingTag(['襪子'], random));
    if (random.nextBool()) add(_randomClothingTag(['鞋子'], random));
    if (random.nextBool()) add(_randomClothingTag(['穿脫狀態'], random));
    if (random.nextBool()) add(_randomClothingTag(['服裝材質'], random));

    final detailCandidates = _allTags
        .where((tag) => tag.group == '服裝細節' && (_showAdult || !tag.adult))
        .toList()
      ..shuffle(random);
    for (final tag in detailCandidates.take(1 + random.nextInt(3))) {
      add(tag);
    }
    if (added.any((tag) => tag.group == '服裝細節' || tag.group == '服裝材質') &&
        random.nextBool()) {
      add(_randomClothingTag(['服裝細節顏色'], random));
    }
    final accessoryCandidates = _allTags
        .where((tag) => tag.group == '配件' && (_showAdult || !tag.adult))
        .toList()
      ..shuffle(random);
    for (final tag in accessoryCandidates.take(random.nextInt(3))) {
      add(tag);
    }
    if (accessoryCandidates.isNotEmpty && random.nextDouble() < 0.8) {
      add(_randomClothingTag(['配件顏色'], random));
    }
    bool hasTargetGroup(String group) => target
        .any((id) => _allTags.any((tag) => tag.id == id && tag.group == group));
    if (hasTargetGroup('內衣') && random.nextBool()) {
      add(_randomClothingTag(['內衣顏色'], random));
    }
    if (hasTargetGroup('胸罩') && random.nextBool()) {
      add(_randomClothingTag(['胸罩顏色'], random));
    }
    if (hasTargetGroup('內褲') && random.nextBool()) {
      add(_randomClothingTag(['內褲顏色'], random));
    }
    if (hasTargetGroup('襪子') && random.nextBool()) {
      add(_randomClothingTag(['襪子顏色'], random));
    }
    if (hasTargetGroup('鞋子') && random.nextBool()) {
      add(_randomClothingTag(['鞋子顏色'], random));
    }
    if (hasTargetGroup('服裝') && random.nextBool()) {
      add(_randomClothingTag(['服裝邊線色'], random));
    }
    if (hasTargetGroup('上衣') && random.nextBool()) {
      add(_randomClothingTag(['上衣邊線色'], random));
    }
    if ((hasTargetGroup('褲子') || hasTargetGroup('裙子')) && random.nextBool()) {
      add(_randomClothingTag(['下身邊線色'], random));
    }
    if (hasTargetGroup('內衣') && random.nextBool()) {
      add(_randomClothingTag(['內衣邊線色'], random));
    }
    if (hasTargetGroup('胸罩') && random.nextBool()) {
      add(_randomClothingTag(['胸罩邊線色'], random));
    }
    if (hasTargetGroup('內褲') && random.nextBool()) {
      add(_randomClothingTag(['內褲邊線色'], random));
    }
    if (hasTargetGroup('襪子') && random.nextBool()) {
      add(_randomClothingTag(['襪子邊線色'], random));
    }
    if (hasTargetGroup('鞋子') && random.nextBool()) {
      add(_randomClothingTag(['鞋子邊線色'], random));
    }
    if (hasTargetGroup('配件') && random.nextBool()) {
      add(_randomClothingTag(['配件邊線色'], random));
    }
    if (hasTargetGroup('配件') && random.nextBool()) {
      add(_randomClothingTag(['配件位置'], random));
    }

    setState(() {
      _persist();
    });
  }

  bool _isPhysicalAnimalTraitTag(TagItem tag) =>
      tag.group == _animalTraitGroup &&
      (_isAnimalEarTypeTag(tag) ||
          _isAnimalTailTypeTag(tag) ||
          _isAnimalHandTypeTag(tag) ||
          _isAnimalFootTypeTag(tag)) &&
      !const {'catalog_trait_furry', 'catalog_trait_anthro'}.contains(tag.id);

  void _removeOrphanedPhysicalTraitColors(Set<String> selectedIds) {
    final selected =
        selectedIds.map((id) => _tagsById[id]).whereType<TagItem>().toList();
    bool hasType(bool Function(TagItem tag) matcher) => selected.any(matcher);
    final orphanGroups = <String>{
      if (!hasType(_isAnimalEarTypeTag)) _animalEarColorGroup,
      if (!hasType(_isAnimalTailTypeTag)) _animalTailColorGroup,
      if (!hasType(_isAnimalHandTypeTag)) _animalHandColorGroup,
      if (!hasType(_isAnimalFootTypeTag)) _animalFootColorGroup,
      if (!hasType(_isWingTypeTag)) _wingColorGroup,
    };
    if (orphanGroups.isEmpty) return;
    selectedIds
        .removeWhere((id) => orphanGroups.contains(_tagsById[id]?.group));
  }

  void _syncAutoFurryIdentity(int personIndex, Set<String> selectedIds) {
    // `furry` means a full-fur animal person, while ears, tails, hands, and
    // feet alone describe a mostly human character with animal features.
    // Never infer either identity from the selected body parts.
    _autoFurryIdentityForPerson.remove(personIndex);
  }

  Future<void> _toggle(TagItem tag, {int? personIndex}) async {
    if (personIndex != null && _hairColorWord(tag) != null) {
      await _toggleHairColor(tag, personIndex);
      return;
    }
    final targetIds =
        personIndex == null ? _selectedIds : _personTagIds(personIndex);
    final currentTags = personIndex == null
        ? _selectedTags
        : _selectedTagsForPerson(personIndex);
    if (targetIds.contains(tag.id)) {
      setState(() {
        targetIds.remove(tag.id);
        if (personIndex != null) {
          _removeOrphanedClothingConfiguration(targetIds, tag);
          if (_isClothingGroup(tag.group)) {
            _markClothingTemplateCustomized(personIndex);
          }
        }
        if (personIndex != null && _isCurrentCharacterTrait(personIndex, tag)) {
          final character = _characterForNew(_personSlots[personIndex]);
          for (final trait in character?.traits ?? const <CatalogTagData>[]) {
            if (_characterTraitUsesTag(trait, tag.id)) {
              _removedCharacterTagSet(personIndex)
                  .add(_cleanTag(trait.en).toLowerCase());
              targetIds.removeAll(
                  _characterTraitOptions(trait).map((option) => option.id));
            }
          }
        }
        if (personIndex != null) {
          _removeOrphanedPhysicalTraitColors(targetIds);
          _syncAutoFurryIdentity(personIndex, targetIds);
        }
        _persist();
      });
      return;
    }
    var characterOverrideConfirmed = false;
    if (personIndex != null) {
      characterOverrideConfirmed =
          await _confirmCharacterOverride(tag, personIndex);
      if (!characterOverrideConfirmed) return;
    }
    final exclusiveGroups = _exclusiveTraitOverrideGroups(tag.en);
    final conflicts = currentTags
        .where((item) =>
            _tagsConflict(item, tag) ||
            (exclusiveGroups.isNotEmpty &&
                _exclusiveTraitOverrideGroups(item.en)
                    .intersection(exclusiveGroups)
                    .isNotEmpty))
        .toList();
    final clothingReplacements = personIndex == null
        ? const <TagItem>[]
        : _clothingEditingReplacements(tag, currentTags);
    final onlyOriginalCharacterConflicts = personIndex != null &&
        characterOverrideConfirmed &&
        conflicts.isNotEmpty &&
        conflicts.every((item) => _isCurrentCharacterTrait(personIndex, item));
    if (conflicts.isNotEmpty && !onlyOriginalCharacterConflicts) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('標籤可能互相衝突'),
          content: Text(
              '目前已有「${conflicts.map((item) => item.zh).join('、')}」。\n加入「${tag.zh}」會移除原標籤，是否更換？'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('保留原標籤')),
            FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('移除原標籤並更換')),
          ],
        ),
      );
      if (replace != true) return;
    }
    setState(() {
      if (personIndex != null) {
        _removeOriginalCharacterTraitsForOverride(personIndex, tag);
      }
      for (final conflict in conflicts) {
        targetIds.remove(conflict.id);
      }
      for (final replacement in clothingReplacements) {
        targetIds.remove(replacement.id);
      }
      // Replacing a garment noun (for example, a template's shirt with a
      // blouse) also resets the old garment's dependent configuration.  The
      // incoming garment is added afterwards, so its new settings can be
      // selected normally.
      for (final replacement in clothingReplacements) {
        _removeOrphanedClothingConfiguration(targetIds, replacement);
      }
      targetIds.add(tag.id);
      if (personIndex != null) {
        if (tag.id == 'catalog_trait_anthro') {
          _autoFurryIdentityForPerson.remove(personIndex);
        }
        _syncAutoFurryIdentity(personIndex, targetIds);
        _removeOrphanedPhysicalTraitColors(targetIds);
        if (_isClothingGroup(tag.group)) {
          _markClothingTemplateCustomized(personIndex);
        }
        final character = _characterForNew(_personSlots[personIndex]);
        for (final trait in character?.traits ?? const <CatalogTagData>[]) {
          if (_characterTraitUsesTag(trait, tag.id)) {
            _removedCharacterTagSet(personIndex)
                .remove(_cleanTag(trait.en).toLowerCase());
          }
        }
      }
      _persist();
    });
  }

  Future<void> _toggleHairColor(TagItem tag, int personIndex) async {
    if (personIndex < 0 || personIndex >= _personSlots.length) return;
    final targetIds = _personTagIds(personIndex);
    final slot = _personSlots[personIndex];
    final orderedIds = _hairGradientColorIdsForPerson(personIndex);

    if (targetIds.contains(tag.id)) {
      setState(() {
        targetIds.remove(tag.id);
        orderedIds.remove(tag.id);
        slot.hairGradientColorIds = orderedIds;
        if (orderedIds.length < 2) {
          slot.hairGradientStyle = _defaultHairGradientStyle;
        }
        if (_isCurrentCharacterTrait(personIndex, tag)) {
          final character = _characterForNew(slot);
          for (final trait in character?.traits ?? const <CatalogTagData>[]) {
            if (_characterTraitUsesTag(trait, tag.id)) {
              _removedCharacterTagSet(personIndex)
                  .add(_cleanTag(trait.en).toLowerCase());
              targetIds.removeAll(
                  _characterTraitOptions(trait).map((option) => option.id));
            }
          }
        }
        _syncHairGradientColorIds(personIndex, targetIds);
        _persist();
      });
      return;
    }

    final confirmed = await _confirmCharacterOverride(tag, personIndex);
    if (!confirmed) return;
    setState(() {
      // Preserve colour 1 when colour 2 is selected. Selecting a third colour
      // only replaces colour 2; remove colour 1 first when a new base colour
      // is wanted.
      if (orderedIds.length >= 2) {
        targetIds.remove(orderedIds.last);
        orderedIds.removeLast();
      }
      _removeOriginalCharacterTraitsForOverride(personIndex, tag);
      targetIds.addAll(orderedIds);
      targetIds.removeWhere((id) {
        final current = _tagsById[id];
        return current != null &&
            _hairColorWord(current) != null &&
            !orderedIds.contains(id);
      });
      orderedIds.add(tag.id);
      targetIds.add(tag.id);
      slot.hairGradientColorIds = orderedIds.take(2).toList();
      _syncHairGradientColorIds(personIndex, targetIds);
      final character = _characterForNew(slot);
      for (final trait in character?.traits ?? const <CatalogTagData>[]) {
        if (_characterTraitUsesTag(trait, tag.id)) {
          _removedCharacterTagSet(personIndex)
              .remove(_cleanTag(trait.en).toLowerCase());
        }
      }
      _persist();
    });
  }

  Future<bool> _confirmCharacterOverride(TagItem tag, int personIndex) async {
    if (personIndex < 0 || personIndex >= _personSlots.length) return true;
    final slot = _personSlots[personIndex];
    if (slot.mode != '動漫角色') return true;
    final character = _characterForNew(slot);
    final selectedGroups = _traitOverrideGroups(tag.en);
    if (character == null || selectedGroups.isEmpty) return true;
    final originalTraitIds = character.traits
        .expand(_characterTraitOptions)
        .map((tag) => tag.id)
        .toSet();
    if (_selectedTagsForPerson(personIndex).any((selected) =>
        !originalTraitIds.contains(selected.id) &&
        _traitOverrideGroups(selected.en)
            .intersection(selectedGroups)
            .isNotEmpty)) {
      return true;
    }
    final replaced = character.traits
        .where((trait) => _traitOverrideGroups(trait.en)
            .intersection(selectedGroups)
            .isNotEmpty)
        .toList();
    if (replaced.isEmpty) return true;
    final original = replaced.map((item) => '${item.zh}（${item.en}）').join('、');
    final apply = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('這會覆寫角色原始特徵'),
        content: Text('角色「${character.characterZh}」原本包含：$original。\n\n'
            '新增「${tag.zh}（${tag.en}）」會替換同類特徵，輸出時移除原本的標籤。\n\n'
            '例如改變髮色或長短會改變角色原本的形象設定。要套用嗎？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('保留原特徵')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('套用並替換')),
        ],
      ),
    );
    return apply == true;
  }

  Future<void> _copy(String value, String label,
      {bool showFeedback = false}) async {
    try {
      await html.window.navigator.clipboard?.writeText(value);
    } catch (_) {
      final area = html.TextAreaElement()
        ..value = value
        ..style.position = 'fixed'
        ..style.opacity = '0';
      html.document.body?.append(area);
      area.select();
      html.document.execCommand('copy');
      area.remove();
    }
    if (!showFeedback || !mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label已複製')));
  }

  void _downloadUnregisteredPositiveTags() {
    final tags = _unregisteredPositiveTags.toList();
    if (tags.isEmpty) return;
    final blob = html.Blob([tags.join('\r\n')], 'text/plain;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'betterwaifu-unregistered-positive-tags.txt')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  String _compactReverseKey(String value) =>
      _englishTagKey(value).replaceAll(' ', '');

  /// Keeps punctuation so symbolic Danbooru expressions such as `;3`, `>_<`,
  /// and `@_@` can round-trip through reverse import.
  String _reverseExactKey(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  bool _reverseKeyContainsPhrase(String value, String phrase) {
    final key = _englishTagKey(value);
    final candidate = _englishTagKey(phrase);
    if (key.isEmpty || candidate.isEmpty) return false;
    return ' $key '.contains(' $candidate ');
  }

  int _reverseEditDistance(String left, String right) {
    if (left == right) return 0;
    if (left.isEmpty) return right.length;
    if (right.isEmpty) return left.length;
    var previous = List<int>.generate(right.length + 1, (index) => index);
    for (var row = 1; row <= left.length; row++) {
      final current = List<int>.filled(right.length + 1, 0);
      current[0] = row;
      for (var column = 1; column <= right.length; column++) {
        final cost =
            left.codeUnitAt(row - 1) == right.codeUnitAt(column - 1) ? 0 : 1;
        current[column] = [
          current[column - 1] + 1,
          previous[column] + 1,
          previous[column - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      previous = current;
    }
    return previous[right.length];
  }

  double _reverseCharacterScore(String token, CatalogCharacter character) {
    final tokenKey = _compactReverseKey(token);
    if (tokenKey.length < 4) return 0;
    final names = <String>[
      character.characterTag,
      character.characterEn,
      '${character.characterTag}_${character.animeTag}',
    ];
    var best = 0.0;
    for (final name in names) {
      final nameKey = _compactReverseKey(name);
      if (nameKey.isEmpty) continue;
      if (nameKey == tokenKey) return 1.0;
      if (nameKey.contains(tokenKey) || tokenKey.contains(nameKey)) {
        final shorter =
            nameKey.length < tokenKey.length ? nameKey.length : tokenKey.length;
        if (shorter >= 5) best = best < .82 ? .82 : best;
      }
      final distance = _reverseEditDistance(tokenKey, nameKey);
      final similarity = 1 -
          distance /
              (tokenKey.length > nameKey.length
                  ? tokenKey.length
                  : nameKey.length);
      if (similarity > best) best = similarity;
    }
    return best;
  }

  CatalogCharacter? _reverseCharacterMatch(String token) {
    CatalogCharacter? bestCharacter;
    var bestScore = 0.0;
    for (final character in _allCharacters) {
      final score = _reverseCharacterScore(token, character);
      if (score > bestScore) {
        bestScore = score;
        bestCharacter = character;
      }
    }
    return bestScore >= .72 ? bestCharacter : null;
  }

  String? _reverseAnimeMatch(String token) {
    final tokenKey = _compactReverseKey(token);
    if (tokenKey.length < 4) return null;
    String? bestTag;
    var bestScore = 0.0;
    final seen = <String>{};
    for (final character in _allCharacters) {
      if (!seen.add(character.animeTag)) continue;
      final nameKeys = [
        _compactReverseKey(character.animeTag),
        _compactReverseKey(character.animeEn),
      ];
      for (final nameKey in nameKeys) {
        if (nameKey.isEmpty) continue;
        final score = nameKey == tokenKey
            ? 1.0
            : tokenKey.length >= 6 &&
                    (nameKey.contains(tokenKey) || tokenKey.contains(nameKey))
                ? .82
                : 1 -
                    _reverseEditDistance(tokenKey, nameKey) /
                        (tokenKey.length > nameKey.length
                            ? tokenKey.length
                            : nameKey.length);
        if (score > bestScore) {
          bestScore = score;
          bestTag = character.animeTag;
        }
      }
    }
    return bestScore >= .78 ? bestTag : null;
  }

  TagItem? _tagByReverseLabel(String value) {
    final exactKey = _reverseExactKey(value);
    final englishKey = _englishTagKey(value);
    final chineseKey = _cleanTag(value);
    for (final tag in _allTags) {
      if (exactKey.isNotEmpty && _reverseExactKey(tag.en) == exactKey) {
        return tag;
      }
      if (englishKey.isNotEmpty && _englishTagKey(tag.en) == englishKey) {
        return tag;
      }
      if (chineseKey.isNotEmpty && _cleanTag(tag.zh) == chineseKey) return tag;
    }
    return null;
  }

  List<TagItem> _reverseObjectInteractionCandidates(String value) {
    final key = _englishTagKey(value);
    if (key.isEmpty) return const <TagItem>[];

    String? modeId;
    String remainder = '';
    if (key.startsWith('holding ') && key.endsWith(' overhead')) {
      modeId = 'action_holding_object_overhead';
      remainder = key
          .substring('holding '.length, key.length - ' overhead'.length)
          .trim();
    } else {
      const modes = <String, String>{
        'hugging ': 'action_hugging_object',
        'riding ': 'action_riding_object',
        'holding ': 'action_holding_object',
        'carrying ': 'action_carrying_object',
        'sitting on ': 'action_sitting_on_object',
        'lying on ': 'action_lying_on_object',
        'leaning on ': 'action_leaning_on_object',
      };
      for (final entry in modes.entries) {
        if (!key.startsWith(entry.key)) continue;
        modeId = entry.value;
        remainder = key.substring(entry.key.length).trim();
        break;
      }
    }
    if (modeId == null || remainder.isEmpty) return const <TagItem>[];
    final object = _tagByReverseLabel(remainder);
    final mode = _tagsById[modeId];
    if (mode == null || object == null || object.group != '物件') {
      return const <TagItem>[];
    }
    return [mode, object];
  }

  List<TagItem> _reverseExtraFeatureCandidates(String value) {
    final key = _englishTagKey(value);
    if (key.isEmpty) return const <TagItem>[];
    final bases = _allTags
        .where((tag) => tag.group == '額外特徵')
        .where((tag) => _reverseKeyContainsPhrase(key, tag.en))
        .toList()
      ..sort((a, b) =>
          _englishTagKey(b.en).length.compareTo(_englishTagKey(a.en).length));
    if (bases.isEmpty) return const <TagItem>[];

    final result = <TagItem>[bases.first];
    for (final tag in _allTags.where((tag) =>
        tag.group == '額外特徵位置' && _reverseKeyContainsPhrase(key, tag.en))) {
      result.add(tag);
    }
    for (final tag in _allTags.where((tag) => tag.group == '額外特徵顏色')) {
      final words = _clothingColorWords(tag);
      if (words.isNotEmpty &&
          words.every((word) => _reverseKeyContainsPhrase(key, word))) {
        result.add(tag);
      }
    }
    return result.toSet().toList();
  }

  List<TagItem> _reversePhysicalTraitCandidates(String value) {
    final key = _englishTagKey(value);
    if (key.isEmpty) return const <TagItem>[];
    final types = _allTags.where((tag) {
      final physicalType = _isAnimalEarTypeTag(tag) ||
          _isAnimalTailTypeTag(tag) ||
          _isAnimalHandTypeTag(tag) ||
          _isAnimalFootTypeTag(tag) ||
          _isWingTypeTag(tag);
      return physicalType && _reverseKeyContainsPhrase(key, tag.en);
    }).toList()
      ..sort((a, b) =>
          _englishTagKey(b.en).length.compareTo(_englishTagKey(a.en).length));
    if (types.isEmpty) return const <TagItem>[];

    final type = types.first;
    final colorGroup = _isAnimalEarTypeTag(type)
        ? _animalEarColorGroup
        : _isAnimalTailTypeTag(type)
            ? _animalTailColorGroup
            : _isAnimalHandTypeTag(type)
                ? _animalHandColorGroup
                : _isAnimalFootTypeTag(type)
                    ? _animalFootColorGroup
                    : _wingColorGroup;
    final colors = _allTags
        .where((tag) => tag.group == colorGroup)
        .where((tag) {
      final words = _clothingColorWords(tag);
      return words.isNotEmpty &&
          words.every((word) => _reverseKeyContainsPhrase(key, word));
    }).toList()
      ..sort((a, b) => _clothingColorPrefix(b)
          .length
          .compareTo(_clothingColorPrefix(a).length));
    return [type, if (colors.isNotEmpty) colors.first];
  }

  List<TagItem> _reverseTagCandidates(String value) {
    final physicalTrait = _reversePhysicalTraitCandidates(value);
    if (physicalTrait.isNotEmpty) return physicalTrait;
    final exact = _tagByReverseLabel(value);
    if (exact != null) return [exact];
    final key = _englishTagKey(value);
    if (key.isEmpty) return const <TagItem>[];

    final objectInteraction = _reverseObjectInteractionCandidates(value);
    if (objectInteraction.isNotEmpty) return objectInteraction;

    final extraFeature = _reverseExtraFeatureCandidates(value);
    if (extraFeature.isNotEmpty) return extraFeature;

    final hairSuffixes = _allTags
        .where((tag) =>
            (tag.group == '髮型' ||
                tag.group == '髮長' ||
                _hairLengthTag(tag.en) != null) &&
            _reverseKeyContainsPhrase(key, tag.en))
        .toList()
      ..sort((a, b) =>
          _englishTagKey(b.en).length.compareTo(_englishTagKey(a.en).length));
    final hasHairContext = key.contains('hair') || hairSuffixes.isNotEmpty;
    final hair = <TagItem>[];
    if (hasHairContext) {
      final hairColors = _allTags
          .where((tag) => tag.group == '髮色')
          .where((tag) {
        final color = _hairColorWord(tag);
        return color != null && _reverseKeyContainsPhrase(key, color);
      }).toList()
        ..sort((a, b) =>
            _englishTagKey(b.en).length.compareTo(_englishTagKey(a.en).length));
      if (hairColors.isNotEmpty) hair.add(hairColors.first);
    }
    if (hairSuffixes.isNotEmpty) {
      final length = hairSuffixes.firstWhere(
        (tag) => _hairLengthTag(tag.en) != null,
        orElse: () => hairSuffixes.first,
      );
      hair.add(length);
      final style = hairSuffixes.cast<TagItem?>().firstWhere(
            (tag) =>
                tag != null &&
                _isHairStyleTag(tag) &&
                _hairLengthTag(tag.en) == null,
            orElse: () => null,
          );
      if (style != null) hair.add(style);
    }
    if (hair.isNotEmpty) {
      return hair.toSet().toList();
    }

    final bases = _allTags
        .where((tag) =>
            _isClothingBaseGroup(tag.group) &&
            _reverseKeyContainsPhrase(key, tag.en))
        .toList()
      ..sort((a, b) =>
          _englishTagKey(b.en).length.compareTo(_englishTagKey(a.en).length));
    if (bases.isEmpty) return const <TagItem>[];

    final base = bases.first;
    final result = <TagItem>[base];
    final colorGroup = _clothingColorGroupForBase(base);
    if (colorGroup != null) {
      final colors =
          _allTags.where((tag) => tag.group == colorGroup).where((tag) {
        final words = _clothingColorWords(tag);
        return words.isNotEmpty && words.every(key.contains);
      }).toList()
            ..sort((a, b) {
              final wordCount = _clothingColorWords(b)
                  .length
                  .compareTo(_clothingColorWords(a).length);
              return wordCount == 0
                  ? _englishTagKey(b.en)
                      .length
                      .compareTo(_englishTagKey(a.en).length)
                  : wordCount;
            });
      if (colors.isNotEmpty) result.add(colors.first);
    }
    final trimColorGroup = _clothingTrimColorGroupForBase(base);
    final trimColors = trimColorGroup == null
        ? const <TagItem>[]
        : _allTags.where((tag) => tag.group == trimColorGroup).where((tag) {
            final words = _clothingColorWords(tag);
            return words.isNotEmpty && words.every(key.contains);
          }).toList()
      ..sort((a, b) => _clothingColorWords(b)
          .length
          .compareTo(_clothingColorWords(a).length));
    if (trimColors.isNotEmpty) result.add(trimColors.first);

    final detailGroups = <String>{
      _legacyClothingDetailGroup,
      _legacyClothingMaterialGroup,
      ..._clothingDetailGroupsForBase(base).where((group) {
        final kind = _scopedClothingKind(group);
        return const {'cut', 'fit', 'length', 'material', 'detail', 'pattern'}
            .contains(kind);
      }),
    };
    for (final tag
        in _allTags.where((tag) => detailGroups.contains(tag.group))) {
      final modifier = _clothingModifierEnglish(tag);
      if (modifier.isNotEmpty && key.contains(_englishTagKey(modifier))) {
        result.add(tag);
      }
    }

    final styleGroups = <String>{
      ..._clothingStyleGroupsForBase(base),
      if (_clothingStyleGroup(base.group) != null)
        _clothingStyleGroup(base.group)!,
    };
    for (final tag
        in _allTags.where((tag) => styleGroups.contains(tag.group))) {
      final style = _clothingModifierEnglish(tag);
      if (style.isNotEmpty && key.contains(_englishTagKey(style))) {
        result.add(tag);
      }
    }
    for (final tag in _allTags
        .where((tag) => tag.group == '服裝細節' || tag.group == '服裝材質')) {
      final modifier = _clothingModifierEnglish(tag);
      if (modifier.isNotEmpty && key.contains(_englishTagKey(modifier))) {
        result.add(tag);
      }
    }
    return result.length == 1 ? const <TagItem>[] : result.toSet().toList();
  }

  String _reverseExtraKey(String value) {
    final englishKey = _englishTagKey(value);
    return englishKey.isEmpty ? _cleanTag(value).toLowerCase() : englishKey;
  }

  List<String> _reversePromptTokens(String value) {
    return _extraTags(value)
        .where((token) => !['break', 'and'].contains(token.toLowerCase()))
        .toList();
  }

  void _reversePromptTags() {
    // `:3` is a supported symbolic mouth expression. Shield it before
    // stripping optional prompt-weight suffixes such as `tag:1.15`.
    const colonThreeMarker = '__bw_symbol_colon_three__';
    final normalized = _reversePrompt.text
        .replaceAll(':3', colonThreeMarker)
        .replaceAllMapped(RegExp(r':\s*-?(?:\d+(?:\.\d+)?|\.\d+)'), (_) => '')
        .replaceAll(RegExp(r'[()\[\]{}]'), '');
    final tokens = _reversePromptTokens(normalized)
        .map((token) => token == colonThreeMarker ? ':3' : token)
        .toList();
    if (tokens.isEmpty) {
      return;
    }

    final recognized = <TagItem>[];
    final unknown = <String>[];
    int? importedPeopleCount;
    String? importedGender;
    CatalogCharacter? detectedCharacter;
    String? detectedAnimeTag;
    for (final token in tokens) {
      final peopleMatch = RegExp(
        r'^(\d+)\s*(girls?|boys?|people?|persons?)$',
        caseSensitive: false,
      ).firstMatch(_englishTagKey(token));
      if (peopleMatch != null) {
        importedPeopleCount =
            (int.tryParse(peopleMatch.group(1)!) ?? 1).clamp(1, 10).toInt();
        final kind = peopleMatch.group(2)!.toLowerCase();
        importedGender = kind.startsWith('girl')
            ? '女性'
            : kind.startsWith('boy')
                ? '男性'
                : '其他/異種';
        continue;
      }
      final tokenKey = _englishTagKey(token);
      CatalogCharacter? tokenCharacter;
      String? tokenAnimeTag;
      for (final character in _allCharacters) {
        if (_englishTagKey(character.characterTag) == tokenKey) {
          tokenCharacter = character;
          break;
        }
        if (_englishTagKey(character.animeTag) == tokenKey) {
          tokenAnimeTag = character.animeTag;
          break;
        }
      }
      tokenCharacter ??= _reverseCharacterMatch(token);
      tokenAnimeTag ??= _reverseAnimeMatch(token);
      if (tokenCharacter != null) {
        detectedCharacter = tokenCharacter;
        continue;
      }
      if (tokenAnimeTag != null) {
        detectedAnimeTag = tokenAnimeTag;
        continue;
      }
      final tags = _reverseTagCandidates(token);
      if (tags.isEmpty) {
        unknown.add(token);
      } else {
        recognized.addAll(tags);
      }
    }

    final globalGroups = {
      _indoorSceneGroup,
      _outdoorSceneGroup,
      _outdoorTimeGroup,
      _cameraFramingGroup,
      _cameraFaceFocusGroup,
      _cameraFocusGroup,
      _cameraCropGroup,
      '畫面',
      '品質',
      '其他',
    };
    setState(() {
      if (importedPeopleCount != null) {
        while (_personSlots.length < importedPeopleCount!) {
          _personSlots.add(PersonSlot());
        }
        while (_personSlots.length > importedPeopleCount!) {
          _personSlots.removeLast();
        }
        _personSelectedIds
            .removeWhere((index, _) => index >= importedPeopleCount!);
        _removedCharacterTags
            .removeWhere((index, _) => index >= importedPeopleCount!);
        _personTagQueries
            .removeWhere((index, _) => index >= importedPeopleCount!);
        _personActiveGroups.removeWhere((key, _) =>
            int.tryParse(key.split(':').first) != null &&
            int.parse(key.split(':').first) >= importedPeopleCount!);
        _peopleCount = importedPeopleCount!;
        _gender = importedGender ?? _gender;
      }

      if (detectedCharacter != null) {
        final slot = _personSlots[0];
        _resetCharacterFeatureSelections(0, _characterForNew(slot));
        slot.detailed = true;
        slot.mode = '動漫角色';
        slot.characterId = detectedCharacter!.id;
        slot.animeTag = detectedCharacter!.animeTag;
        _removedCharacterTags.remove(0);
        _syncCharacterTraitsForSlot(0);
        _recentCharacterIds
          ..remove(detectedCharacter!.id)
          ..insert(0, detectedCharacter!.id);
        if (_recentCharacterIds.length > 10) _recentCharacterIds.removeLast();
      } else if (detectedAnimeTag != null) {
        _personSlots[0]
          ..detailed = true
          ..mode = '動漫角色'
          ..animeTag = detectedAnimeTag!;
      }

      for (final tag in recognized.toSet()) {
        if (tag.en == '1girl' || tag.en == '1boy' || tag.en == '1person') {
          continue;
        }
        final target =
            globalGroups.contains(tag.group) || _isSharedActionGroup(tag.group)
                ? _selectedIds
                : _personTagIds(0);
        final current =
            target == _selectedIds ? _selectedTags : _selectedTagsForPerson(0);
        for (final conflict
            in current.where((item) => _tagsConflict(item, tag))) {
          target.remove(conflict.id);
        }
        target.add(tag.id);
      }
      _syncAutoFurryIdentity(0, _personTagIds(0));

      final existingExtra = _extraTags(_extraPositive.text);
      final existingKeys = existingExtra.map(_reverseExtraKey).toSet();
      for (final token in unknown) {
        if (existingKeys.add(_reverseExtraKey(token))) existingExtra.add(token);
      }
      _extraPositive.text = existingExtra.join(', ');
      _collectUnknownExtraPositiveTags();
      _persist();
    });
  }

  Future<void> _clearAllTags() async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清除所有標籤？'),
        content: const Text(
            '這會清除目前組合的正向標籤、負向標籤、人物角色、人物細節、額外文字與提示前綴，回到一位女性且不需細節的乾淨狀態。\n\n'
            '自訂標籤、角色資料、已儲存組合與版本記錄不會被刪除。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('確定清除')),
        ],
      ),
    );
    if (clear != true) return;
    setState(() {
      _selectedIds.clear();
      _personSelectedIds.clear();
      _autoFurryIdentityForPerson.clear();
      _personCombinationIds.clear();
      _removedCharacterTags.clear();
      _personTagQueries.clear();
      _personActiveGroups.clear();
      for (final controller in _personSearchControllers.values) {
        controller.clear();
      }
      _personSlots
        ..clear()
        ..add(PersonSlot()..detailed = false);
      _peopleCount = 1;
      _gender = '女性';
      _stepIndex = 0;
      _pageBottomPadding = _basePageBottomPadding;
      _activeGroup = '全部';
      _search.clear();
      _extraPositive.clear();
      _sharedPoseExtra.clear();
      _reversePrompt.clear();
      _negative.text = _defaultNegativeText;
      _preprompt.clear();
      _persist();
    });
    unawaited(_scrollToStep(0));
  }

  Future<void> _clearStepTags(int index) async {
    const titles = <int, String>{
      0: '場景與畫面',
      1: '角色資料',
      2: '組合標籤',
      3: '固定角色外觀',
      4: '服裝與穿脫狀態',
      5: '姿勢、互動與成人分類',
      6: '品質、額外與負面',
    };
    final title = titles[index] ?? '本大項';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('清除「$title」？'),
        content: Text('只會移除「$title」中的目前標籤與輸入內容，不會影響其他大項目。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('確定清除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final removableByGroup = (Set<String> groups) => _allTags
        .where((tag) => groups.contains(tag.group))
        .map((tag) => tag.id)
        .toSet();
    void removePersonTagsWhere(bool Function(TagItem tag) matches) {
      final removable = _allTags.where(matches).map((tag) => tag.id).toSet();
      for (final ids in _personSelectedIds.values) {
        ids.removeWhere(removable.contains);
      }
      _personSelectedIds.removeWhere((_, ids) => ids.isEmpty);
    }

    setState(() {
      switch (index) {
        case 0:
          final removable = removableByGroup({
            _indoorSceneGroup,
            _outdoorSceneGroup,
            _outdoorTimeGroup,
            _cameraFramingGroup,
            _cameraFaceFocusGroup,
            _cameraFocusGroup,
            _cameraCropGroup,
            '畫面',
          });
          _selectedIds.removeWhere(removable.contains);
          _search.clear();
          _activeGroup = '全部';
          break;
        case 1:
          for (final slot in _personSlots) {
            slot
              ..detailed = false
              ..mode = '原創'
              ..characterId = ''
              ..animeQuery = ''
              ..animeTag = ''
              ..remoteAnimeZh = ''
              ..remoteAnimeEn = ''
              ..query = ''
              ..originalAnimeZh = ''
              ..originalAnimeEn = ''
              ..originalAnimeTag = ''
              ..originalCharacterZh = ''
              ..originalCharacterEn = ''
              ..originalCharacterTag = ''
              ..originalTraits = '';
          }
          _removedCharacterTags.clear();
          _personTagQueries.clear();
          _personActiveGroups.clear();
          break;
        case 2:
          for (final entry in _personCombinationIds.entries) {
            final appliedTagIds = _combinations
                .where((combination) => entry.value.contains(combination.id))
                .expand((combination) => combination.tagIds)
                .toSet();
            _personTagIds(entry.key).removeWhere(appliedTagIds.contains);
          }
          _personCombinationIds.clear();
          break;
        case 3:
          removePersonTagsWhere(_isFixedCharacterFeatureTag);
          for (var personIndex = 0;
              personIndex < _personSlots.length;
              personIndex++) {
            final slot = _personSlots[personIndex];
            final character = _characterForNew(slot);
            for (final trait in character?.traits ?? const <CatalogTagData>[]) {
              _removedCharacterTagSet(personIndex)
                  .add(_cleanTag(trait.en).toLowerCase());
            }
            if (slot.mode == '原創') {
              for (final trait in _extraTags(slot.originalTraits)) {
                _removedCharacterTagSet(personIndex)
                    .add(_cleanTag(trait).toLowerCase());
              }
            }
            slot.hairGradientColorIds = <String>[];
            slot.hairGradientStyle = _defaultHairGradientStyle;
          }
          break;
        case 4:
          removePersonTagsWhere((tag) => _isClothingGroup(tag.group));
          break;
        case 5:
          _removeAdultPosePackageTags();
          final sharedActionIds =
              removableByGroup(_sharedActionPickerGroups.toSet());
          _selectedIds.removeWhere(sharedActionIds.contains);
          removePersonTagsWhere(_isPoseWorkflowTag);
          for (var personIndex = 0;
              personIndex < _personSlots.length;
              personIndex++) {
            _personSlots[personIndex].poseExtraPositive = '';
            _clearPersonSearchController(
              personIndex,
              'pose-extra-positive',
            );
          }
          break;
        case 6:
          _extraPositive.clear();
          _reversePrompt.clear();
          _negative.text = _defaultNegativeText;
          _preprompt.clear();
          break;
      }
      _persist();
    });
  }

  String? _clothingScopeForPickerGroup(String group) {
    if (_isScopedClothingGroup(group)) return _scopedClothingSlot(group);
    return switch (group) {
      '服裝' || _cosplayGroup || '服裝顏色' || '服裝邊線色' => 'onepiece',
      '上衣' || '上衣風格' || '上衣顏色' || '上衣邊線色' => 'top',
      '褲子' => 'pants',
      '短褲' => 'shorts',
      '裙子' => 'skirt',
      '下身風格' || '下身顏色' || '下身邊線色' => 'bottom',
      '外套' || '外套顏色' || '外套邊線色' => 'outerwear',
      '特殊服裝' => 'costume',
      '內衣' || '內衣顏色' || '內衣邊線色' => 'underwear',
      '胸罩' || '胸罩顏色' || '胸罩邊線色' => 'bra',
      '內褲' || '內褲顏色' || '內褲邊線色' => 'panties',
      '襪子' || '襪子顏色' || '襪子邊線色' => 'socks',
      '鞋子' || '鞋子顏色' || '鞋子邊線色' => 'shoes',
      _clothingGroupHat ||
      _clothingGroupHeadAccessory ||
      _clothingGroupHairAccessory ||
      _clothingGroupEyewear ||
      _clothingGroupFaceAccessory ||
      _clothingGroupAnimalAccessory ||
      _clothingGroupNeckAccessory ||
      _clothingGroupHandAccessory ||
      _clothingGroupWaistAccessory ||
      _clothingGroupOtherAccessory ||
      '配件' ||
      '配件顏色' ||
      '帽子顏色' ||
      '眼鏡顏色' ||
      '配件邊線色' ||
      '帽子邊線色' ||
      '眼鏡邊線色' ||
      '配件位置' =>
        'accessory',
      _ => null,
    };
  }

  Future<void> _clearPersonPickerGroup(int personIndex, String group) async {
    if (personIndex < 0 || personIndex >= _personSlots.length) return;
    final selected = _selectedTagsForPerson(personIndex);
    final clothingScope = _clothingScopeForPickerGroup(group);
    final isClothingBase = const {
      '上衣',
      '褲子',
      '短褲',
      '裙子',
      '外套',
      '特殊服裝',
      '內衣',
      '胸罩',
      '內褲',
      '襪子',
      '鞋子',
      '服裝',
      _cosplayGroup,
      '配件',
      ..._clothingAccessoryPickerGroups,
    }.contains(group);
    final tags = selected.where((tag) {
      if (group == _staticFaceAppearanceGroup) {
        return _isStaticFaceAppearanceTag(tag);
      }
      if (group == _objectInteractionGroup) {
        return _isObjectInteractionTag(tag);
      }
      if (_isObjectPickerGroup(group)) {
        return _objectPickerGroupForTag(tag) == group;
      }
      if (_isExpressionPickerGroup(group)) {
        return _expressionSubgroupForTag(tag) == group;
      }
      if (group == _allClothingWearGroup) {
        return _scopedClothingKind(tag.group) == 'wear' ||
            tag.group == _legacyClothingWearGroup;
      }
      if (isClothingBase && clothingScope != null) {
        if (_clothingAccessoryPickerGroups.contains(group)) {
          return _clothingBaseDisplayGroup(tag) == _clothingGroupAccessory &&
              _clothingAccessoryPickerGroup(tag) == group;
        }
        final tagScope = _clothingScopeForTag(tag) ??
            _clothingScopeForPickerGroup(tag.group);
        return tagScope == clothingScope;
      }
      return tag.group == group;
    }).toList();
    if (group == _animalTraitGroup) {
      tags.addAll(selected.where((tag) =>
          tag.group == _animalEarColorGroup ||
          tag.group == _animalTailColorGroup ||
          tag.group == _animalHandColorGroup ||
          tag.group == _animalFootColorGroup));
    } else if (group == _wingTypeGroup) {
      tags.addAll(selected.where((tag) => tag.group == _wingColorGroup));
    } else if (group == '髮型') {
      tags.addAll(selected.where((tag) => tag.group == '髮色'));
    }
    if (tags.isEmpty) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清除目前分類？'),
        content: Text(
            '只會移除「${_wizardGroupLabel(group)}」中的 ${tags.length} 個標籤，不會影響其他服裝、姿勢或人物。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('清除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      final ids = _personTagIds(personIndex);
      ids.removeAll(tags.map((tag) => tag.id));
      if (group == '髮型') {
        ids.removeWhere((id) => _tagsById[id]?.group == '髮色');
      }
      _syncHairGradientColorIds(personIndex, ids);
      _removeOrphanedPhysicalTraitColors(ids);
      _syncAutoFurryIdentity(personIndex, ids);
      _persist();
    });
  }

  void _downloadBackup() {
    final blob = html.Blob([jsonEncode(_snapshot())], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'betterwaifu-prompt-backup.json')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _importBackup() {
    final input = html.FileUploadInputElement()
      ..accept = '.json,application/json';
    input.click();
    input.onChange.listen((_) {
      final file = input.files?.first;
      if (file == null) return;
      final reader = html.FileReader();
      reader.readAsText(file);
      reader.onLoad.listen((_) {
        try {
          html.window.localStorage[_storageKey] = '${reader.result}';
          setState(() {
            _selectedIds.clear();
            _personSelectedIds.clear();
            _personCombinationIds.clear();
            _removedCharacterTags.clear();
            _customTags.clear();
            _invalidateTagCaches();
            _presets.clear();
            _combinations.clear();
            _restore();
          });
        } catch (_) {}
      });
    });
  }

  void _savePreset() {
    final controller = TextEditingController(text: '我的 Amanatsu 組合');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('儲存組合'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: '組合名稱'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              setState(
                () => _presets.insert(
                  0,
                  Preset(name: name, payload: _snapshot()),
                ),
              );
              _persist();
              Navigator.pop(dialogContext);
            },
            child: const Text('儲存'),
          ),
        ],
      ),
    );
  }

  void _loadPreset(Preset preset) {
    final data = preset.payload;
    setState(() {
      _selectedIds
        ..clear()
        ..addAll((data['selectedIds'] as List? ?? []).map((id) => '$id'));
      _personSelectedIds
        ..clear()
        ..addAll({
          for (final entry in (data['personSelectedIds'] as Map? ?? {}).entries)
            if (int.tryParse('${entry.key}') != null)
              int.parse('${entry.key}'):
                  (entry.value as List? ?? []).map((id) => '$id').toSet(),
        });
      _migrateClothingTaxonomyTagIds(_selectedIds);
      for (final ids in _personSelectedIds.values) {
        _migrateClothingTaxonomyTagIds(ids);
      }
      _personCombinationIds
        ..clear()
        ..addAll({
          for (final entry
              in (data['personCombinationIds'] as Map? ?? {}).entries)
            if (int.tryParse('${entry.key}') != null)
              int.parse('${entry.key}'):
                  (entry.value as List? ?? []).map((id) => '$id').toSet(),
        });
      _peopleCount = (data['peopleCount'] as num?)?.toInt() ?? 1;
      _gender = '${data['gender'] ?? _gender}';
      _model = '${data['model'] ?? _model}';
      _sampler = '${data['sampler'] ?? _sampler}';
      _steps = (data['steps'] as num?)?.toInt() ?? _steps;
      _cfg = '${data['cfg'] ?? _cfg}';
      _clipSkip = '${data['clipSkip'] ?? _clipSkip}';
      _showAdult = data['showAdult'] == true;
      _extraPositive.text = '${data['extraPositive'] ?? ''}';
      _collectUnknownExtraPositiveTags();
      _reversePrompt.text = '${data['reversePrompt'] ?? ''}';
      _negative.text = '${data['negative'] ?? _negative.text}';
      _customNegativeTranslations
        ..clear()
        ..addAll(Map<String, dynamic>.from(
          data['customNegativeTranslations'] as Map? ?? <String, dynamic>{},
        ).map((key, value) => MapEntry(key.toLowerCase(), '$value')));
      _preprompt.text = '${data['preprompt'] ?? _preprompt.text}';
      _persist();
    });
  }

  void _setPeopleCount(int count) {
    setState(() {
      if (count != _personSlots.length) {
        _removeAdultPosePackageTags();
      }
      while (_personSlots.length < count) _personSlots.add(PersonSlot());
      while (_personSlots.length > count) _personSlots.removeLast();
      _personSelectedIds.removeWhere((index, _) => index >= count);
      _personCombinationIds.removeWhere((index, _) => index >= count);
      _removedCharacterTags.removeWhere((index, _) => index >= count);
      _personTagQueries.removeWhere((index, _) => index >= count);
      _personActiveGroups.removeWhere((key, _) =>
          int.tryParse(key.split(':').first) != null &&
          int.parse(key.split(':').first) >= count);
      _peopleCount = count;
      _persist();
    });
  }

  Future<void> _removePersonAt(int index) async {
    if (_personSlots.length <= 1 || index < 0 || index >= _personSlots.length) {
      return;
    }
    final characterNames = _characterChineseForSlot(_personSlots[index], index);
    final label = characterNames.isEmpty
        ? '人物 ${index + 1}'
        : '人物 ${index + 1}・${characterNames.first}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('刪除此人物？'),
        content: Text(
          '將刪除「$label」以及此人物的特徵、服裝、表情、姿勢和組合設定。其他人物會自動往前遞補編號。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('確認刪除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    void shiftMap<T>(Map<int, T> source) {
      final shifted = <int, T>{};
      for (final entry in source.entries) {
        if (entry.key == index) continue;
        shifted[entry.key > index ? entry.key - 1 : entry.key] = entry.value;
      }
      source
        ..clear()
        ..addAll(shifted);
    }

    void shiftIndexSet(Set<int> source) {
      final shifted = source
          .where((personIndex) => personIndex != index)
          .map((personIndex) =>
              personIndex > index ? personIndex - 1 : personIndex)
          .toSet();
      source
        ..clear()
        ..addAll(shifted);
    }

    setState(() {
      _removeAdultPosePackageTags();
      _personSlots.removeAt(index);
      shiftMap(_personSelectedIds);
      shiftIndexSet(_autoFurryIdentityForPerson);
      shiftMap(_personCombinationIds);
      shiftMap(_removedCharacterTags);
      shiftMap(_personTagQueries);
      shiftMap(_remoteAnimeResults);
      shiftMap(_remoteAnimeSelection);
      shiftMap(_remoteCharacters);
      shiftMap(_remoteLookupErrors);

      final shiftedLoading = _remoteLookupLoading
          .where((personIndex) => personIndex != index)
          .map((personIndex) =>
              personIndex > index ? personIndex - 1 : personIndex)
          .toSet();
      _remoteLookupLoading
        ..clear()
        ..addAll(shiftedLoading);

      final shiftedActiveGroups = <String, String>{};
      for (final entry in _personActiveGroups.entries) {
        final separator = entry.key.indexOf(':');
        final personIndex = separator < 0
            ? null
            : int.tryParse(entry.key.substring(0, separator));
        if (personIndex == null) {
          shiftedActiveGroups[entry.key] = entry.value;
          continue;
        }
        if (personIndex == index) continue;
        final shiftedIndex =
            personIndex > index ? personIndex - 1 : personIndex;
        shiftedActiveGroups['$shiftedIndex${entry.key.substring(separator)}'] =
            entry.value;
      }
      _personActiveGroups
        ..clear()
        ..addAll(shiftedActiveGroups);

      for (final controller in _personSearchControllers.values) {
        controller.dispose();
      }
      _personSearchControllers.clear();
      _peopleCount = _personSlots.length;
      _persist();
    });
  }

  List<CatalogCharacter> _matchingAnime(PersonSlot slot) {
    final lower = slot.animeQuery.trim().toLowerCase();
    final seen = <String>{};
    final matches = _allCharacters.where((item) {
      if (lower.isNotEmpty &&
          !'${item.animeZh} ${item.animeEn} ${item.animeTag} ${item.unitZh} ${item.unitEn} ${item.unitTag}'
              .toLowerCase()
              .contains(lower)) {
        return false;
      }
      return seen.add(item.animeTag);
    }).toList();
    if (slot.animeTag.isNotEmpty) {
      matches.sort((a, b) {
        final aSelected = a.animeTag == slot.animeTag;
        final bSelected = b.animeTag == slot.animeTag;
        if (aSelected == bSelected) return 0;
        return aSelected ? -1 : 1;
      });
    }
    return matches;
  }

  List<CatalogCharacter> _matchingCharacters(PersonSlot slot) {
    final lower = slot.query.trim().toLowerCase();
    final source = _allCharacters.where((item) {
      if (slot.animeTag.isNotEmpty && item.animeTag != slot.animeTag) {
        return false;
      }
      if (lower.isEmpty) return true;
      return '${item.animeZh} ${item.animeEn} ${item.characterZh} ${item.characterEn} ${item.animeTag} ${item.characterTag} ${item.unitZh} ${item.unitEn} ${item.unitTag}'
          .toLowerCase()
          .contains(lower);
    }).toList();
    if (lower.isEmpty && _recentCharacterIds.isNotEmpty) {
      source.sort((a, b) {
        final aIndex = _recentCharacterIds.indexOf(a.id);
        final bIndex = _recentCharacterIds.indexOf(b.id);
        return (aIndex < 0 ? 999 : aIndex).compareTo(bIndex < 0 ? 999 : bIndex);
      });
    }
    return source;
  }

  Future<Map<String, dynamic>> _remoteJson(String url) async {
    final raw = await html.HttpRequest.getString(url);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<Map<String, dynamic>> _anilistJson(
      String query, String keyword) async {
    final response = await html.HttpRequest.request(
      'https://graphql.anilist.co',
      method: 'POST',
      requestHeaders: {'Content-Type': 'application/json'},
      sendData: jsonEncode({
        'query': query,
        'variables': {'search': keyword},
      }),
    );
    return Map<String, dynamic>.from(
        jsonDecode(response.responseText ?? '{}') as Map);
  }

  List<String> _animeSearchTerms(String query) {
    const aliases = <String, List<String>>{
      '棋靈王': ['Hikaru no Go', '棋魂', 'ヒカルの碁'],
      '棋魂': ['Hikaru no Go', '棋靈王', 'ヒカルの碁'],
      '灌籃高手': ['Slam Dunk', 'スラムダンク'],
      '名偵探柯南': ['Detective Conan', 'Case Closed', '名探偵コナン'],
      '航海王': ['One Piece', 'ワンピース'],
      '火影忍者': ['Naruto', 'NARUTO -ナルト-'],
      '死神': ['Bleach', 'BLEACH'],
      '獵人': ['Hunter x Hunter', 'HUNTER×HUNTER'],
      '進擊的巨人': ['Attack on Titan', '進撃の巨人'],
      '鬼滅之刃': ['Demon Slayer', 'Kimetsu no Yaiba', '鬼滅の刃'],
      '咒術迴戰': ['Jujutsu Kaisen', '呪術廻戦'],
      '我的英雄學院': ['My Hero Academia', 'Boku no Hero Academia', '僕のヒーローアカデミア'],
      '間諜家家酒': ['SPY x FAMILY', 'SPY×FAMILY'],
      '葬送的芙莉蓮': [
        "Frieren: Beyond Journey's End",
        'Sousou no Frieren',
        '葬送のフリーレン'
      ],
      '涼宮春日的憂鬱': [
        'The Melancholy of Haruhi Suzumiya',
        'Suzumiya Haruhi no Yuuutsu',
        '涼宮ハルヒの憂鬱'
      ],
      '出包王女': ['To LOVE-Ru', 'To LOVEる -とらぶる-'],
    };
    final input = query.trim();
    final normalized = input.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final terms = <String>[input];
    aliases.forEach((alias, variants) {
      if (alias.toLowerCase().replaceAll(RegExp(r'\s+'), '') == normalized) {
        terms.addAll(variants);
      }
    });
    return terms.toSet().where((term) => term.isNotEmpty).toList();
  }

  Future<void> _searchRemoteAnime(int slotIndex) async {
    if (slotIndex < 0 || slotIndex >= _personSlots.length) return;
    final query = _personSlots[slotIndex].animeQuery.trim();
    if (query.isEmpty) {
      return;
    }
    setState(() {
      _remoteLookupLoading.add(slotIndex);
      _remoteLookupErrors.remove(slotIndex);
    });
    try {
      const queryText = r'''query ($search: String!) {
        Page(perPage: 8) {
          media(search: $search, type: ANIME) {
            id
            title { romaji english native }
            synonyms
            startDate { year }
            characters(perPage: 50) {
              edges { role node { id name { full native } description } }
            }
          }
        }
      }''';
      final results = <Map>[];
      for (final term in _animeSearchTerms(query)) {
        final data = await _anilistJson(queryText, term);
        final page =
            ((data['data'] as Map?)?['Page'] as Map?)?['media'] as List? ?? [];
        results.addAll(page.whereType<Map>());
        if (results.isNotEmpty) break;
      }
      final seenIds = <int>{};
      final mapped = results
          .where((item) {
            final id = (item['id'] as num?)?.toInt() ?? 0;
            if (id <= 0 || seenIds.contains(id)) return false;
            seenIds.add(id);
            return true;
          })
          .map((item) {
            final title =
                Map<String, dynamic>.from(item['title'] as Map? ?? {});
            final date =
                Map<String, dynamic>.from(item['startDate'] as Map? ?? {});
            final characters =
                ((item['characters'] as Map?)?['edges'] as List? ?? [])
                    .whereType<Map>()
                    .map((edge) {
                      final node =
                          Map<String, dynamic>.from(edge['node'] as Map? ?? {});
                      final name =
                          Map<String, dynamic>.from(node['name'] as Map? ?? {});
                      return _RemoteCharacter(
                        id: (node['id'] as num?)?.toInt() ?? 0,
                        name: '${name['full'] ?? ''}',
                        nameKanji: '${name['native'] ?? ''}',
                        role: '${edge['role'] ?? ''}',
                        about: '${node['description'] ?? ''}',
                      );
                    })
                    .where((character) =>
                        character.id > 0 && character.name.isNotEmpty)
                    .toList();
            return _RemoteAnime(
              id: (item['id'] as num?)?.toInt() ?? 0,
              title:
                  '${title['english'] ?? title['romaji'] ?? title['native'] ?? ''}',
              titleJapanese: '${title['native'] ?? ''}',
              year: (date['year'] as num?)?.toInt(),
              source: 'anilist',
              characters: characters,
            );
          })
          .where((item) => item.id > 0 && item.title.isNotEmpty)
          .toList();
      final mappedResults =
          mapped.where((item) => item.id > 0 && item.title.isNotEmpty).toList();
      if (!mounted) return;
      setState(() {
        _remoteAnimeResults[slotIndex] = mappedResults;
        _remoteLookupLoading.remove(slotIndex);
        if (mappedResults.isEmpty) {
          _remoteLookupErrors[slotIndex] = '查無作品。已嘗試常見中文別名，請改用英文／日文名稱或使用手動新增。';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _remoteLookupLoading.remove(slotIndex);
        _remoteLookupErrors[slotIndex] = '自動查詢失敗，請稍後再試或使用手動新增。';
      });
    }
  }

  Future<void> _loadRemoteCharacters(int slotIndex, _RemoteAnime anime) async {
    if (slotIndex < 0 || slotIndex >= _personSlots.length) return;
    setState(() {
      _remoteLookupLoading.add(slotIndex);
      _remoteLookupErrors.remove(slotIndex);
      _remoteAnimeSelection[slotIndex] = anime;
    });
    try {
      final characters = anime.source == 'anilist'
          ? anime.characters
          : ((await _remoteJson(
                          'https://api.jikan.moe/v4/anime/${anime.id}/characters'))[
                      'data'] as List? ??
                  [])
              .whereType<Map>()
              .map((item) {
                final character = Map<String, dynamic>.from(
                    item['character'] as Map? ?? <String, dynamic>{});
                return _RemoteCharacter(
                  id: (character['mal_id'] as num?)?.toInt() ?? 0,
                  name: '${character['name'] ?? ''}',
                  nameKanji: '${character['name_kanji'] ?? ''}',
                  role: '${item['role'] ?? ''}',
                );
              })
              .where((item) => item.id > 0 && item.name.isNotEmpty)
              .toList();
      if (!mounted) return;
      final slot = _personSlots[slotIndex];
      slot.animeTag = anime.tag;
      slot.remoteAnimeZh =
          anime.titleJapanese.isEmpty ? anime.title : anime.titleJapanese;
      slot.remoteAnimeEn = anime.title;
      slot.animeQuery = '';
      _clearPersonSearchController(slotIndex, 'anime');
      // Keep remote results available from the normal anime/character
      // selectors even after the lookup panel is closed.
      for (final remote in characters) {
        final discovered = _remoteCatalogCharacter(anime, remote);
        final existingIndex =
            _customCharacters.indexWhere((item) => item.id == discovered.id);
        if (existingIndex < 0) {
          _customCharacters.add(discovered);
        }
      }
      setState(() {
        _remoteCharacters[slotIndex] = characters;
        _remoteLookupLoading.remove(slotIndex);
        _persist();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _remoteLookupLoading.remove(slotIndex);
        _remoteLookupErrors[slotIndex] = '角色查詢失敗，請稍後再試。';
      });
    }
  }

  Future<String> _remoteCharacterAbout(int id) async {
    try {
      final data =
          await _remoteJson('https://api.jikan.moe/v4/characters/$id/full');
      return '${data['data']?['about'] ?? ''}';
    } catch (_) {
      return '';
    }
  }

  List<CatalogTagData> _remoteTraits(_RemoteCharacter character) {
    var about = character.about.toLowerCase().replaceAll('-', ' ');
    final traits = <CatalogTagData>[];
    void add(String zh, String en) {
      if (traits.any((item) => item.en == en)) return;
      traits.add(CatalogTagData(
        id: 'remote_trait_${DateTime.now().microsecondsSinceEpoch}_${traits.length}',
        group: '自訂特徵',
        zh: zh,
        en: en,
        order: 1,
      ));
    }

    const hairColors = {
      'pink': '粉紅色頭髮',
      'red': '紅色頭髮',
      'blue': '藍色頭髮',
      'green': '綠色頭髮',
      'purple': '紫色頭髮',
      'blonde': '金色頭髮',
      'black': '黑色頭髮',
      'white': '白色頭髮',
      'silver': '銀色頭髮',
      'brown': '棕色頭髮',
      'aqua': '藍綠色頭髮',
      'orange': '橘色頭髮',
      'yellow': '黃色頭髮',
    };
    for (final entry in hairColors.entries) {
      if (RegExp('\\b${entry.key} hair\\b').hasMatch(about)) {
        add(entry.value, '${entry.key} hair');
      }
    }
    if (RegExp(
            r'\b(very\s+short|very\s+long|waist-length|long|medium|short)\s+(?:[a-z-]+\s+)?hair\b')
        .hasMatch(about)) {
      final match = RegExp(
              r'\b(very\s+short|very\s+long|waist-length|long|medium|short)\s+(?:[a-z-]+\s+)?hair\b')
          .firstMatch(about);
      final length = match?.group(1);
      if (length != null) {
        const names = {
          'very short': '極短髮',
          'very long': '超長髮',
          'waist-length': '及腰長髮',
          'long': '長髮',
          'medium': '中長髮',
          'short': '短髮',
        };
        const safeEnglish = {
          'very short': 'close-cropped hair',
          'short': 'cropped hair',
        };
        add(names[length] ?? length, safeEnglish[length] ?? '$length hair');
      }
    }
    const eyeColors = {
      'pink': '粉紅色眼睛',
      'red': '紅色眼睛',
      'blue': '藍色眼睛',
      'green': '綠色眼睛',
      'emerald green': '翠綠色眼睛',
      'purple': '紫色眼睛',
      'brown': '棕色眼睛',
      'aqua': '藍綠色眼睛',
      'yellow': '黃色眼睛',
    };
    for (final entry in eyeColors.entries) {
      if (entry.key == 'green' && about.contains('emerald green eyes')) {
        continue;
      }
      if (RegExp('\\b${entry.key} eyes?\\b').hasMatch(about)) {
        add(entry.value, '${entry.key} eyes');
      }
    }
    const phrases = <String, Map<String, String>>{
      'very long hair': {'zh': '超長髮', 'en': 'very long hair'},
      'waist-length hair': {'zh': '及腰長髮', 'en': 'waist-length hair'},
      'long hair': {'zh': '長髮', 'en': 'long hair'},
      'medium hair': {'zh': '中長髮', 'en': 'medium hair'},
      'short hair': {'zh': '短髮', 'en': 'cropped hair'},
      'very short hair': {'zh': '極短髮', 'en': 'close-cropped hair'},
      'bob cut': {'zh': '鮑伯頭', 'en': 'bob cut'},
      'pixie cut': {'zh': '精靈短髮', 'en': 'pixie cut'},
      'straight hair': {'zh': '直髮', 'en': 'straight hair'},
      'wavy hair': {'zh': '波浪髮', 'en': 'wavy hair'},
      'curly hair': {'zh': '捲髮', 'en': 'curly hair'},
      'twin tails': {'zh': '雙馬尾', 'en': 'twintails'},
      'twintails': {'zh': '雙馬尾', 'en': 'twintails'},
      'ponytail': {'zh': '馬尾', 'en': 'ponytail'},
      'braid': {'zh': '辮子', 'en': 'braid'},
      'bun': {'zh': '髮髻', 'en': 'hair bun'},
      'ahoge': {'zh': '呆毛', 'en': 'ahoge'},
      'cowlick': {'zh': '呆毛', 'en': 'ahoge'},
      'glasses': {'zh': '眼鏡', 'en': 'glasses'},
      'horns': {'zh': '角', 'en': 'horns'},
      'elf ears': {'zh': '精靈耳', 'en': 'elf ears'},
      'pointed ears': {'zh': '尖耳朵', 'en': 'pointed ears'},
      'tail': {'zh': '尾巴', 'en': 'tail'},
      'slim': {'zh': '纖細體態', 'en': 'slender build'},
      'medium breasts': {'zh': '中等胸部', 'en': 'medium breasts'},
      'large breasts': {'zh': '豐滿胸部', 'en': 'large breasts'},
    };
    for (final entry in phrases.entries) {
      if (about.contains(entry.key) &&
          !(entry.key == 'long hair' && about.contains('very long hair')) &&
          !(entry.key == 'short hair' && about.contains('very short hair'))) {
        add(entry.value['zh']!, entry.value['en']!);
      }
    }
    return traits;
  }

  CatalogCharacter _remoteCatalogCharacter(
      _RemoteAnime anime, _RemoteCharacter remote) {
    final animeTag = _resolvedAnimeTag(anime);
    CatalogCharacter? local;
    final normalized =
        remote.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    for (final item in _allCharacters) {
      if (item.animeTag != animeTag) continue;
      final itemName =
          item.characterEn.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (itemName == normalized ||
          item.characterTag.toLowerCase() == _slug(remote.name)) {
        local = item;
        break;
      }
    }
    return CatalogCharacter(
      id: 'jikan_character_${remote.id}',
      animeZh: anime.titleJapanese.isEmpty ? anime.title : anime.titleJapanese,
      animeEn: anime.title,
      animeTag: animeTag,
      characterZh: remote.nameKanji.isEmpty ? remote.name : remote.nameKanji,
      characterEn: remote.name,
      characterTag: _slug(remote.name),
      traits: local?.traits ?? _remoteTraits(remote),
    );
  }

  String _animeKey(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\u4e00-\u9fff]'), '');

  String _resolvedAnimeTag(_RemoteAnime anime) {
    final names = [anime.title, anime.titleJapanese]
        .where((value) => value.trim().isNotEmpty)
        .map(_animeKey)
        .toSet();
    for (final item in catalogCharacters) {
      if (names.contains(_animeKey(item.animeEn)) ||
          names.contains(_animeKey(item.animeZh)) ||
          names.contains(_animeKey(item.animeTag))) {
        return item.animeTag;
      }
    }
    return anime.tag;
  }

  CatalogCharacter _normalizeImportedAnime(CatalogCharacter character) {
    final names = {_animeKey(character.animeEn), _animeKey(character.animeZh)};
    for (final item in catalogCharacters) {
      if (names.contains(_animeKey(item.animeEn)) ||
          names.contains(_animeKey(item.animeZh)) ||
          names.contains(_animeKey(item.animeTag))) {
        if (item.animeTag == character.animeTag) return character;
        return CatalogCharacter(
          id: character.id,
          animeZh: character.animeZh,
          animeEn: character.animeEn,
          animeTag: item.animeTag,
          characterZh: character.characterZh,
          characterEn: character.characterEn,
          characterTag: character.characterTag,
          traits: character.traits,
        );
      }
    }
    return character;
  }

  Future<void> _importRemoteCharacters(int slotIndex,
      {List<_RemoteCharacter>? only}) async {
    final anime = _remoteAnimeSelection[slotIndex];
    final remoteCharacters = _remoteCharacters[slotIndex] ?? const [];
    if (anime == null || remoteCharacters.isEmpty) return;
    final source = only ?? remoteCharacters;
    setState(() => _remoteLookupLoading.add(slotIndex));
    final imported = <CatalogCharacter>[];
    for (var index = 0; index < source.length; index++) {
      var remote = source[index];
      if (remote.about.isEmpty && (only != null || index < 18)) {
        remote = remote.withAbout(await _remoteCharacterAbout(remote.id));
        if (index < source.length - 1) {
          await Future<void>.delayed(const Duration(milliseconds: 350));
        }
      }
      final character = _remoteCatalogCharacter(anime, remote);
      final existingIndex =
          _customCharacters.indexWhere((item) => item.id == character.id);
      if (existingIndex < 0) {
        _customCharacters.add(character);
      } else {
        // A previous lookup may have saved the name without the optional
        // description traits. Replace it with the enriched version now.
        _customCharacters[existingIndex] = character;
      }
      imported.add(character);
    }
    if (imported.isNotEmpty) {
      final slot = _personSlots[slotIndex];
      _resetCharacterFeatureSelections(slotIndex, _characterForNew(slot));
      slot.mode = '動漫角色';
      slot.characterId = imported.first.id;
      slot.animeTag = imported.first.animeTag;
      _removedCharacterTags.remove(slotIndex);
      _syncCharacterTraitsForSlot(slotIndex);
      _recentCharacterIds
        ..remove(imported.first.id)
        ..insert(0, imported.first.id);
      if (_recentCharacterIds.length > 10) _recentCharacterIds.removeLast();
    }
    if (!mounted) return;
    setState(() {
      _remoteLookupLoading.remove(slotIndex);
      _persist();
    });
  }

  Widget _remoteAnimePanel(int index) {
    final results = _remoteAnimeResults[index] ?? const <_RemoteAnime>[];
    final error = _remoteLookupErrors[index];
    if (results.isEmpty && error == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(
              child:
                  Text('自動查詢結果', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            TextButton.icon(
              onPressed: () => _clearRemoteLookup(index),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('清除查詢結果'),
            ),
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(error),
          ),
        ...results.map((anime) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(anime.title),
              subtitle: Text(anime.titleJapanese.isEmpty
                  ? 'Jikan / MyAnimeList 公開資料'
                  : '${anime.titleJapanese} · Jikan / MyAnimeList'),
              trailing: TextButton(
                onPressed: () => _loadRemoteCharacters(index, anime),
                child: const Text('查詢角色'),
              ),
            )),
      ],
    );
  }

  Widget _remoteCharacterPanel(int index) {
    final anime = _remoteAnimeSelection[index];
    final characters = _remoteCharacters[index] ?? const <_RemoteCharacter>[];
    if (anime == null || characters.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text('${anime.title}：自動查詢到 ${characters.length} 名角色',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            TextButton.icon(
              onPressed: () => _clearRemoteLookup(index),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('關閉'),
            ),
          ],
        ),
        const SizedBox(height: 5),
        OutlinedButton.icon(
          onPressed: _remoteLookupLoading.contains(index)
              ? null
              : () => _importRemoteCharacters(index),
          icon: const Icon(Icons.download_outlined),
          label: const Text('匯入此作品角色與可辨識特徵'),
        ),
        SizedBox(
          height: 190,
          child: ListView.builder(
            itemCount: characters.length,
            itemBuilder: (_, characterIndex) {
              final character = characters[characterIndex];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(character.name),
                subtitle: Text(character.nameKanji.isEmpty
                    ? character.role
                    : '${character.nameKanji} · ${character.role}'),
                trailing: TextButton(
                  onPressed: _remoteLookupLoading.contains(index)
                      ? null
                      : () => _importRemoteCharacters(index, only: [character]),
                  child: const Text('匯入'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _clearRemoteLookup(int index) {
    setState(() {
      _remoteAnimeResults.remove(index);
      _remoteAnimeSelection.remove(index);
      _remoteCharacters.remove(index);
      _remoteLookupErrors.remove(index);
      _remoteLookupLoading.remove(index);
    });
  }

  void _selectAnime(int slotIndex, CatalogCharacter anime) {
    if (slotIndex < 0 || slotIndex >= _personSlots.length) return;
    setState(() {
      final slot = _personSlots[slotIndex];
      _resetCharacterFeatureSelections(slotIndex, _characterForNew(slot));
      slot.animeTag = anime.animeTag;
      slot.animeQuery = '';
      slot.query = '';
      slot.characterId = '';
      _removedCharacterTags.remove(slotIndex);
      _clearPersonSearchController(slotIndex, 'anime');
      _clearPersonSearchController(slotIndex, 'character');
      _persist();
    });
  }

  void _selectCharacter(int slotIndex, CatalogCharacter character) {
    if (slotIndex < 0 || slotIndex >= _personSlots.length) return;
    setState(() {
      final slot = _personSlots[slotIndex];
      _resetCharacterFeatureSelections(slotIndex, _characterForNew(slot));
      slot.characterId = character.id;
      slot.mode = '動漫角色';
      slot.animeTag = character.animeTag;
      slot.animeQuery = '';
      slot.query = '';
      _removedCharacterTags.remove(slotIndex);
      _clearPersonSearchController(slotIndex, 'anime');
      _clearPersonSearchController(slotIndex, 'character');
      _syncCharacterTraitsForSlot(slotIndex);
      _recentCharacterIds.remove(character.id);
      _recentCharacterIds.insert(0, character.id);
      if (_recentCharacterIds.length > 10) _recentCharacterIds.removeLast();
      _persist();
    });
  }

  bool _charactersComplete() {
    for (final slot in _personSlots) {
      if (!slot.detailed) continue;
      if (slot.mode == '動漫角色' && _characterForNew(slot) == null) return false;
      if (slot.mode == '原創' &&
          (slot.originalCharacterEn.trim().isEmpty ||
              slot.originalCharacterTag.trim().isEmpty)) return false;
    }
    return true;
  }

  String _slug(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_ -]'), '')
      .replaceAll(RegExp(r'\s+'), '_');

  void _addCustomCharacter() {
    final animeZh = TextEditingController();
    final animeEn = TextEditingController();
    final animeTag = TextEditingController();
    final characterZh = TextEditingController();
    final characterEn = TextEditingController();
    final characterTag = TextEditingController();
    final traitsZh = TextEditingController();
    final traitsEn = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('新增動漫／角色資料'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: animeZh,
                          decoration:
                              const InputDecoration(labelText: '動漫中文名稱'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: TextField(
                          controller: animeEn,
                          decoration: const InputDecoration(
                              labelText: 'Anime English name')))
                ]),
                const SizedBox(height: 10),
                TextField(
                    controller: animeTag,
                    decoration: const InputDecoration(
                        labelText: 'Anime tag', hintText: '留白會由英文名稱產生')),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: characterZh,
                          decoration:
                              const InputDecoration(labelText: '角色中文名稱'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: TextField(
                          controller: characterEn,
                          decoration: const InputDecoration(
                              labelText: 'Character English name')))
                ]),
                const SizedBox(height: 10),
                TextField(
                    controller: characterTag,
                    decoration: const InputDecoration(
                        labelText: 'Character tag', hintText: '留白會由英文名稱產生')),
                const SizedBox(height: 10),
                TextField(
                    controller: traitsZh,
                    decoration: const InputDecoration(
                        labelText: '角色特徵中文', hintText: '粉紅頭髮, 呆毛, 綠眼睛')),
                const SizedBox(height: 10),
                TextField(
                    controller: traitsEn,
                    decoration: const InputDecoration(
                        labelText: 'Character traits English',
                        hintText: 'pink hair, ahoge, green eyes')),
                const SizedBox(height: 8),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('中文與英文特徵依逗號順序配對；資料只會儲存在本機。',
                        style: TextStyle(fontSize: 12))),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final cEn = characterEn.text.trim();
              final cTag = _cleanTag(characterTag.text).isEmpty
                  ? _slug(cEn)
                  : _cleanTag(characterTag.text);
              if (animeZh.text.trim().isEmpty ||
                  animeEn.text.trim().isEmpty ||
                  characterZh.text.trim().isEmpty ||
                  cEn.isEmpty ||
                  cTag.isEmpty) return;
              final zhList = _extraTags(traitsZh.text);
              final enList = _extraTags(traitsEn.text);
              final traits = <CatalogTagData>[];
              final total =
                  zhList.length > enList.length ? zhList.length : enList.length;
              for (var index = 0; index < total; index++) {
                final zh =
                    index < zhList.length ? zhList[index] : enList[index];
                final en = index < enList.length ? enList[index] : _slug(zh);
                traits.add(CatalogTagData(
                    id: 'custom_trait_${DateTime.now().microsecondsSinceEpoch}_$index',
                    group: '角色標籤',
                    zh: zh,
                    en: en,
                    order: 1));
              }
              final character = CatalogCharacter(
                  id:
                      'custom_character_${DateTime.now().microsecondsSinceEpoch}',
                  animeZh: animeZh.text.trim(),
                  animeEn: animeEn.text.trim(),
                  animeTag: _cleanTag(animeTag.text).isEmpty
                      ? _slug(animeEn.text)
                      : _cleanTag(animeTag.text),
                  characterZh: characterZh.text.trim(),
                  characterEn: cEn,
                  characterTag: cTag,
                  traits: traits);
              final slotIndex = _personSlots.indexWhere(
                  (slot) => slot.mode == '動漫角色' && slot.characterId.isEmpty);
              final targetIndex = slotIndex < 0 ? 0 : slotIndex;
              _customCharacters.add(character);
              final target = _personSlots[targetIndex];
              _resetCharacterFeatureSelections(
                  targetIndex, _characterForNew(target));
              target.mode = '動漫角色';
              target.characterId = character.id;
              target.animeTag = character.animeTag;
              _removedCharacterTags.remove(targetIndex);
              _syncCharacterTraitsForSlot(targetIndex);
              target.animeQuery = '';
              target.query = '';
              _clearPersonSearchController(targetIndex, 'anime');
              _clearPersonSearchController(targetIndex, 'character');
              _recentCharacterIds
                ..remove(character.id)
                ..insert(0, character.id);
              if (_recentCharacterIds.length > 10) {
                _recentCharacterIds.removeLast();
              }
              setState(_persist);
              Navigator.pop(dialogContext);
            },
            child: const Text('儲存角色'),
          ),
        ],
      ),
    );
  }

  void _advanceStep() {
    if (_stepIndex == 1 && !_charactersComplete()) {
      return;
    }
    final nextStep = _stepIndex < 6 ? _stepIndex + 1 : _stepIndex;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _stepIndex = nextStep;
      _pageBottomPadding = _basePageBottomPadding;
      _activeGroup = '全部';
      _search.clear();
      _persist();
    });
    unawaited(_scrollToStep(nextStep));
  }

  bool _isCombinationCandidate(TagItem tag) =>
      tag.order > 0 && (_showAdult || !tag.adult);

  List<String> _combinationGroups() => _allTags
      .where(_isCombinationCandidate)
      .map((tag) => tag.group)
      .toSet()
      .toList()
    ..sort((a, b) => _wizardGroupLabel(a).compareTo(_wizardGroupLabel(b)));

  List<TagItem> _combinationOptions(String group, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    final options = _allTags.where((tag) {
      if (!_isCombinationCandidate(tag)) return false;
      if (group.isNotEmpty && tag.group != group) return false;
      if (normalizedQuery.isEmpty) return true;
      return tag.zh.toLowerCase().contains(normalizedQuery) ||
          tag.en.toLowerCase().contains(normalizedQuery);
    }).toList();
    options.sort((a, b) {
      final groupOrder =
          _wizardGroupLabel(a.group).compareTo(_wizardGroupLabel(b.group));
      if (groupOrder != 0) return groupOrder;
      return a.en.compareTo(b.en);
    });
    return options;
  }

  List<TagItem> _combinationTags(PromptCombination combination) {
    final tags = combination.tagIds
        .map((id) => _tagsById[id])
        .whereType<TagItem>()
        .toList();
    tags.sort(_compareOutputTags);
    return tags;
  }

  bool _isClothingCombinationTags(Iterable<TagItem> tags) {
    final values = tags.toList();
    final physicalLookGroups = <String>{
      _animalTraitGroup,
      _animalEarColorGroup,
      _animalTailColorGroup,
      _animalHandColorGroup,
      _animalFootColorGroup,
      _wingTypeGroup,
      _wingColorGroup,
    };
    return values.any((tag) => _isClothingGroup(tag.group)) &&
        values.every((tag) =>
            _isClothingGroup(tag.group) ||
            physicalLookGroups.contains(tag.group));
  }

  TagItem? _outfitReferenceExactTag(
    Iterable<TagItem> candidates,
    String value,
  ) {
    final key = _englishTagKey(value);
    for (final tag in candidates) {
      if (_englishTagKey(tag.en) == key) return tag;
    }
    return null;
  }

  _OutfitReferenceResolution _resolveOutfitReference(
      OutfitReferencePresetData preset) {
    final cached = _outfitReferenceCache[preset.id];
    if (cached != null) return cached;

    final tags = <TagItem>[];
    final ids = <String>{};
    final missing = <String>[];

    void addTag(TagItem? tag, String label) {
      if (tag == null) {
        missing.add(label);
        return;
      }
      if (ids.add(tag.id)) tags.add(tag);
    }

    for (final piece in preset.pieces) {
      final hiddenTaxonomyIds =
          _hiddenTaxonomyDuplicateIdsCache ?? const <String>{};
      final baseCandidates = _allTags
          .where(_isClothingBaseTag)
          .where((tag) => _clothingScopeForBase(tag) == piece.scope)
          .toList()
        ..sort((a, b) {
          // The picker hides taxonomy tags that duplicate a visible legacy
          // tag. Prefer that visible equivalent so a template's base garment
          // remains visibly checked after applying the template.
          final aHidden = hiddenTaxonomyIds.contains(a.id);
          final bHidden = hiddenTaxonomyIds.contains(b.id);
          if (aHidden != bHidden) return aHidden ? 1 : -1;
          final aTaxonomy = a.id.startsWith('catalog_taxonomy_') ? 0 : 1;
          final bTaxonomy = b.id.startsWith('catalog_taxonomy_') ? 0 : 1;
          return aTaxonomy.compareTo(bTaxonomy);
        });
      final base = _outfitReferenceExactTag(baseCandidates, piece.garment);
      addTag(base, '${piece.garment}（服裝主體）');
      if (base == null) continue;

      TagItem? dimension(String kind, String value) => _outfitReferenceExactTag(
            _tagsByGroup[_scopedClothingGroup(piece.scope, kind)] ??
                const <TagItem>[],
            value,
          );

      TagItem? colorForGroup(String? group, String color) {
        if (group == null) return null;
        final expected = _englishTagKey(color);
        return (_tagsByGroup[group] ?? const <TagItem>[])
            .cast<TagItem?>()
            .firstWhere(
          (tag) {
            if (tag == null) return false;
            final tagColor = _clothingColorWord(tag);
            if (tagColor == color) return true;
            final tagKey = _englishTagKey(tag.en);
            return tagKey == expected || tagKey.startsWith('$expected ');
          },
          orElse: () => null,
        );
      }

      if (piece.cut != null) {
        addTag(dimension('cut', piece.cut!), '${piece.garment}／${piece.cut}');
      }
      if (piece.fit != null) {
        addTag(dimension('fit', piece.fit!), '${piece.garment}／${piece.fit}');
      }
      if (piece.length != null) {
        addTag(dimension('length', piece.length!),
            '${piece.garment}／${piece.length}');
      }
      for (final value in piece.materials) {
        addTag(dimension('material', value), '${piece.garment}／$value');
      }
      for (final value in piece.details) {
        addTag(dimension('detail', value), '${piece.garment}／$value');
      }
      for (final value in piece.patterns) {
        addTag(dimension('pattern', value), '${piece.garment}／$value');
      }
      for (final value in piece.styles) {
        final styleCandidates = _allTags.where((tag) {
          if (_clothingScopeForTag(tag) != piece.scope) return false;
          return _scopedClothingKind(tag.group) == 'style' ||
              _isLegacyClothingStyleTag(tag);
        });
        addTag(_outfitReferenceExactTag(styleCandidates, value),
            '${piece.garment}／$value');
      }

      if (piece.mainColor != null) {
        final color = colorForGroup(
          _clothingColorGroupForBase(base),
          piece.mainColor!,
        );
        addTag(color, '${piece.garment}／主色 ${piece.mainColor}');
      }
      if (piece.secondaryColor != null) {
        final color = colorForGroup(
          _clothingTrimColorGroupForBase(base),
          piece.secondaryColor!,
        );
        addTag(color, '${piece.garment}／次色 ${piece.secondaryColor}');
      }
      if (piece.detailColor != null) {
        final color = colorForGroup(
          _scopedClothingGroup(piece.scope, 'detail_color'),
          piece.detailColor!,
        );
        addTag(color, '${piece.garment}／細節色 ${piece.detailColor}');
      }
    }

    for (final value in preset.featureTags) {
      addTag(_outfitReferenceExactTag(_allTags, value), '角色特徵／$value');
    }

    void addOverall(String group, String? value) {
      if (value == null) return;
      addTag(
        _outfitReferenceExactTag(
            _tagsByGroup[group] ?? const <TagItem>[], value),
        value,
      );
    }

    addOverall(_outfitMainStyleGroup, preset.mainStyle);
    addOverall(_outfitSubStyleGroup, preset.subStyle);
    addOverall(_outfitMoodGroup, preset.mood);
    addOverall(_outfitOccasionGroup, preset.occasion);
    tags.sort(_compareOutputTags);
    final resolution = _OutfitReferenceResolution(
      tags: List<TagItem>.unmodifiable(tags),
      missing: List<String>.unmodifiable(missing),
    );
    _outfitReferenceCache[preset.id] = resolution;
    return resolution;
  }

  PromptCombination _outfitReferenceCombination(
      OutfitReferencePresetData preset) {
    final resolved = _resolveOutfitReference(preset);
    return PromptCombination(
      id: preset.combinationId,
      name: preset.name,
      tagIds: resolved.tags.map((tag) => tag.id).toList(),
      extraPositive: '',
    );
  }

  Future<void> _applyOutfitReference(
      OutfitReferencePresetData preset, int personIndex) async {
    final resolution = _resolveOutfitReference(preset);
    if (resolution.missing.isNotEmpty) {
      return;
    }
    await _applyCombination(_outfitReferenceCombination(preset), personIndex);
    if (!mounted) return;
    final firstScope =
        preset.pieces.map((piece) => piece.scope).cast<String?>().firstWhere(
              (scope) => scope != null && scope.isNotEmpty,
              orElse: () => null,
            );
    final firstGroup = switch (firstScope) {
      'top' => _clothingGroupTop,
      'pants' => _clothingGroupPants,
      'shorts' => _clothingGroupShorts,
      'skirt' => _clothingGroupSkirt,
      'onepiece' => _clothingGroupOnePiece,
      'outerwear' => _clothingGroupOuterwear,
      'costume' => _clothingGroupCostume,
      'underwear' => _clothingGroupUnderwear,
      'bra' => _clothingGroupBra,
      'panties' => _clothingGroupPanties,
      'socks' => _clothingGroupSocks,
      'shoes' => _clothingGroupShoes,
      'accessory' => _clothingGroupAccessory,
      _ => null,
    };
    if (firstGroup == null) return;
    setState(() {
      final key = '$personIndex:${_clothingGarmentPickerGroups.join('|')}';
      _personActiveGroups[key] = firstGroup;
    });
  }

  Future<void> _showOutfitReferencePreview(
      OutfitReferencePresetData preset, int personIndex) async {
    final resolution = _resolveOutfitReference(preset);
    final preview = _combinationPreviewTags(resolution.tags);
    final apply = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(preset.name),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 560),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(preset.description),
                const SizedBox(height: 8),
                Text('配色：${preset.palette}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                const Text('中文組合預覽',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                SelectableText(preview.map((tag) => tag.zh).join('。')),
                const SizedBox(height: 14),
                const Text('英文組合預覽',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                SelectableText(preview.map((tag) => '${tag.en}.').join(' ')),
                if (resolution.missing.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    '尚缺少：${resolution.missing.join('、')}',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('關閉'),
          ),
          FilledButton.icon(
            onPressed: resolution.missing.isEmpty
                ? () => Navigator.pop(dialogContext, true)
                : null,
            icon: const Icon(Icons.checkroom_outlined),
            label: Text('套用到人物 ${personIndex + 1}'),
          ),
        ],
      ),
    );
    if (apply == true && mounted) {
      await _applyOutfitReference(preset, personIndex);
    }
  }

  List<_GeneratedOutputTag> _combinationPreviewTags(Iterable<TagItem> source) {
    final tags = source.toList()..sort(_compareOutputTags);
    final clothing = _clothingOutputTagsFromSelection(tags);
    final covered = clothing.expand((tag) => tag.tagIds).toSet();
    final other = tags
        .where((tag) => !covered.contains(tag.id))
        .map((tag) => _GeneratedOutputTag(
              zh: tag.zh,
              en: tag.en,
              tagId: tag.id,
              tagIds: [tag.id],
            ));
    return [...clothing, ...other];
  }

  void _removeCurrentClothingForCombination(Set<String> selectedIds) {
    selectedIds.removeWhere((id) {
      final tag = _tagsById[id];
      return tag != null && _isClothingGroup(tag.group);
    });
  }

  Future<void> _saveClothingCombinationFromPerson(int personIndex) async {
    final clothingTags = _selectedTagsForPerson(personIndex)
        .where((tag) => _isClothingGroup(tag.group))
        .toList();
    if (clothingTags.isEmpty) {
      return;
    }
    final preview = _clothingOutputTagsFromSelection(clothingTags);

    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('\u52A0\u5165\u7D44\u5408\u6A19\u7C64'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '將儲存人物 ${personIndex + 1} 目前的完整服裝配置（${clothingTags.length} 個設定，合成為 ${preview.length} 個輸出標籤）。'),
              const SizedBox(height: 8),
              const Text('新版服裝輸出預覽：',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: preview
                        .map((tag) => Chip(
                              label: Text('${tag.zh} · ${tag.en}'),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: '組合中文名稱',
                  hintText: preview.isEmpty
                      ? '例如白色蕾絲洋裝'
                      : preview.map((tag) => tag.zh).join('、'),
                ),
                onSubmitted: (value) =>
                    Navigator.pop(dialogContext, value.trim()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('\u53D6\u6D88'),
          ),
          FilledButton.icon(
            onPressed: () =>
                Navigator.pop(dialogContext, nameController.text.trim()),
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('\u5132\u5B58'),
          ),
        ],
      ),
    );
    nameController.dispose();

    final trimmedName = name?.trim() ?? '';
    if (trimmedName.isEmpty) return;
    final combination = PromptCombination(
      id: 'combination_${DateTime.now().microsecondsSinceEpoch}',
      name: trimmedName,
      tagIds: clothingTags.map((tag) => tag.id).toList(),
      extraPositive: '',
    );
    setState(() {
      _combinations.insert(0, combination);
      _persist();
    });
  }

  Future<void> _editCombination({PromptCombination? existing}) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final extra = TextEditingController(text: existing?.extraPositive ?? '');
    final search = TextEditingController();
    final selected = <String>{...?existing?.tagIds};
    var activeGroup = '';
    PromptCombination? result;

    result = await showDialog<PromptCombination?>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedTags =
              _allTags.where((tag) => selected.contains(tag.id)).toList();
          final groups = _combinationGroups();
          final options = _combinationOptions(activeGroup, search.text);
          return AlertDialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            title: Text(existing == null
                ? '\u65B0\u589E\u7D44\u5408\u6A19\u7C64'
                : '\u7DE8\u8F2F\u7D44\u5408\u6A19\u7C64'),
            content: SizedBox(
              width: (MediaQuery.of(context).size.width * .94)
                  .clamp(360.0, 980.0)
                  .toDouble(),
              height: (MediaQuery.of(context).size.height - 48)
                  .clamp(520.0, 1000.0)
                  .toDouble(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(right: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: name,
                              autofocus: existing == null,
                              minLines: 2,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText:
                                    '\u7D44\u5408\u4E2D\u6587\u540D\u7A31',
                                hintText:
                                    '\u4F8B\u5982\u5750\u5728\u6905\u5B50\u4E0A\u63A1\u88D9',
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: extra,
                              minLines: 3,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText:
                                    '\u984D\u5916\u6B63\u5411\u6A19\u7C64\uFF08\u4E2D\u6587\u6216\u82F1\u6587\uFF09',
                                hintText:
                                    'custom prompt, \u6216\u7528\u9017\u865F\u5206\u9694',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '\u5DF2\u9078\u6A19\u7C64\uFF1A${selectedTags.length} \u500B\uFF08\u76F8\u540C\u885D\u7A81\u985E\u5225\u6703\u5728\u5957\u7528\u6642\u63D0\u793A\u66FF\u63DB\uFF09',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            if (selectedTags.isNotEmpty)
                              SizedBox(
                                height: 160,
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: selectedTags
                                        .map((tag) => InputChip(
                                              label: Text(tag.en),
                                              onDeleted: () => setDialogState(
                                                  () =>
                                                      selected.remove(tag.id)),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 170,
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    ChoiceChip(
                                      label: const Text(
                                          '\u5168\u90E8\u5206\u985E'),
                                      selected: activeGroup.isEmpty,
                                      onSelected: (_) => setDialogState(
                                          () => activeGroup = ''),
                                    ),
                                    ...groups.map((group) => ChoiceChip(
                                          label: Text(_wizardGroupLabel(group)),
                                          selected: activeGroup == group,
                                          onSelected: (_) => setDialogState(
                                              () => activeGroup = group),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: search,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                labelText:
                                    '\u641C\u5C0B\u53EF\u52A0\u5165\u7684\u6A19\u7C64',
                                suffixIcon: search.text.isEmpty
                                    ? null
                                    : IconButton(
                                        onPressed: () {
                                          search.clear();
                                          setDialogState(() {});
                                        },
                                        icon: const Icon(Icons.clear),
                                      ),
                              ),
                              onChanged: (_) => setDialogState(() {}),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(right: 6),
                        child: Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: options.take(240).map((tag) {
                            final isSelected = selected.contains(tag.id);
                            return FilterChip(
                              selected: isSelected,
                              label: Text(
                                tag.zh.isEmpty
                                    ? tag.en
                                    : '${tag.zh} · ${tag.en}',
                              ),
                              tooltip: tag.en,
                              onSelected: (_) => setDialogState(() {
                                if (isSelected) {
                                  selected.remove(tag.id);
                                } else {
                                  final conflicts = _allTags
                                      .where(
                                          (item) => selected.contains(item.id))
                                      .where((item) => _tagsConflict(item, tag))
                                      .map((item) => item.id)
                                      .toList();
                                  selected.removeAll(conflicts);
                                  selected.add(tag.id);
                                }
                              }),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  if (options.length > 240)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                          '\u7D50\u679C\u8F03\u591A\uFF0C\u8ACB\u4F7F\u7528\u641C\u5C0B\u6216\u5206\u985E\u7E2E\u5C0F\u7BC4\u570D'),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('\u53D6\u6D88'),
              ),
              FilledButton.icon(
                onPressed: () {
                  final trimmedName = name.text.trim();
                  if (trimmedName.isEmpty ||
                      (selected.isEmpty && extra.text.trim().isEmpty)) {
                    return;
                  }
                  Navigator.pop(
                    dialogContext,
                    PromptCombination(
                      id: existing?.id ??
                          'combination_${DateTime.now().microsecondsSinceEpoch}',
                      name: trimmedName,
                      tagIds: selected.toList(),
                      extraPositive: extra.text.trim(),
                    ),
                  );
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('\u5132\u5B58\u7D44\u5408'),
              ),
            ],
          );
        },
      ),
    );
    name.dispose();
    extra.dispose();
    search.dispose();
    if (result == null) return;
    setState(() {
      final index = _combinations.indexWhere((item) => item.id == result!.id);
      if (index < 0) {
        _combinations.insert(0, result!);
      } else {
        _combinations[index] = result!;
      }
      _persist();
    });
  }

  Future<void> _deleteCombination(PromptCombination combination) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('\u522A\u9664\u7D44\u5408\u6A19\u7C64\uFF1F'),
        content: Text(
            '\u522A\u9664\u300C${combination.name}\u300D\u5F8C\uFF0C\u5DF2\u5957\u7528\u5230\u4EBA\u7269\u7684\u7D44\u5408\u984D\u5916\u6B63\u5411\u8A5E\u4E5F\u6703\u79FB\u9664\u3002'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('\u53D6\u6D88')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('\u522A\u9664')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _combinations.removeWhere((item) => item.id == combination.id);
      for (final ids in _personCombinationIds.values) {
        ids.remove(combination.id);
      }
      _persist();
    });
  }

  Future<void> _applyCombination(
      PromptCombination combination, int personIndex) async {
    if (personIndex < 0 || personIndex >= _personSlots.length) return;
    final target = _personTagIds(personIndex);
    final storedTags = _combinationTags(combination);
    final tags = storedTags.where((tag) => _showAdult || !tag.adult).toList();
    final skippedAdult = storedTags.length > tags.length;
    final replacesClothing =
        !skippedAdult && _isClothingCombinationTags(storedTags);
    final conflicts = <String, TagItem>{};
    for (final tag in tags) {
      for (final current in _selectedTagsForPerson(personIndex)) {
        if (current.id != tag.id && _tagsConflict(current, tag)) {
          conflicts[current.id] = current;
        }
      }
    }
    if (conflicts.isNotEmpty) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('\u7D44\u5408\u6709\u885D\u7A81\u6A19\u7C64'),
          content: Text(
              '\u300C${combination.name}\u300D\u6703\u66F4\u63DB\uFF1A${conflicts.values.map((tag) => tag.en).join(', ')}\u3002\n\n\u662F\u5426\u7E7C\u7E8C\u5957\u7528\uFF1F'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('\u53D6\u6D88')),
            FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('\u66FF\u63DB\u4E26\u5957\u7528')),
          ],
        ),
      );
      if (replace != true) return;
    }
    if (replacesClothing) {
      _removeCurrentClothingForCombination(target);
      final clothingCombinationIds = _combinations
          .where((item) => _isClothingCombinationTags(_combinationTags(item)))
          .map((item) => item.id)
          .toSet()
        ..addAll(outfitReferencePresets.map((preset) => preset.combinationId));
      _personCombinationIds[personIndex]
          ?.removeWhere(clothingCombinationIds.contains);
    }
    for (final tag in tags) {
      if (target.contains(tag.id)) continue;
      if (!await _confirmCharacterOverride(tag, personIndex)) continue;
      final current = _selectedTagsForPerson(personIndex);
      final currentConflicts =
          current.where((item) => _tagsConflict(item, tag)).toList();
      for (final conflict in currentConflicts) {
        if (_isCurrentCharacterTrait(personIndex, conflict)) {
          for (final trait
              in _characterForNew(_personSlots[personIndex])?.traits ??
                  const <CatalogTagData>[]) {
            if (_characterTraitUsesTag(trait, conflict.id)) {
              _removedCharacterTagSet(personIndex)
                  .add(_cleanTag(trait.en).toLowerCase());
            }
          }
        }
        target.remove(conflict.id);
      }
      target.add(tag.id);
    }
    _removeOrphanedPhysicalTraitColors(target);
    _syncAutoFurryIdentity(personIndex, target);
    _personCombinationIds
        .putIfAbsent(personIndex, () => <String>{})
        .add(combination.id);
    setState(() {
      _persist();
    });
  }

  Widget _stepCombinations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            '\u5C07\u5E38\u7528\u7684\u8868\u60C5\u3001\u59FF\u52E2\u3001\u670D\u88DD\u6216\u52D5\u4F5C\u5132\u5B58\u6210\u4E00\u5957\uFF0C\u4E4B\u5F8C\u53EF\u76F4\u63A5\u5957\u7528\u5230\u6307\u5B9A\u4EBA\u7269\u3002'),
        const SizedBox(height: 10),
        const Text(
            '\u8ACB\u5728\u300C\u670D\u88DD\u300D\u4E2D\u7684\u4EBA\u7269\u5361\u7247\u6309\u300C\u52A0\u5165\u7D44\u5408\u6A19\u7C64\u300D\uFF0C\u76F4\u63A5\u5132\u5B58\u7576\u524D\u4EBA\u7269\u7684\u670D\u88DD\u8A2D\u8A08\u3002\u65E2\u6709\u7D44\u5408\u4ECD\u53EF\u7DE8\u8F2F\u6216\u5957\u7528\u3002'),
        const SizedBox(height: 12),
        if (_combinations.isEmpty)
          const Text(
              '\u5C1A\u7121\u7D44\u5408\u3002\u53EF\u5EFA\u7ACB\u5982\u300C\u5750\u5728\u6905\u5B50\u4E0A\u300D\u3001\u300C\u904B\u52D5\u59FF\u52E2\u300D\u7B49\u5FEB\u901F\u5957\u7528\u3002')
        else
          ..._combinations.map((combination) {
            final tags = _combinationTags(combination);
            final preview = _combinationPreviewTags(tags);
            final isClothingCombination = _isClothingCombinationTags(tags);
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                key: PageStorageKey<String>(
                    'prompt_combination_${combination.id}'),
                title: Text(
                  combination.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                children: [
                  Row(
                    children: [
                      if (isClothingCombination)
                        const Expanded(
                          child: Text(
                            '完整服裝配置・套用後可自由調整；原始組合不會變更',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      IconButton(
                        tooltip: '\u7DE8\u8F2F\u7D44\u5408',
                        onPressed: () =>
                            _editCombination(existing: combination),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: '\u522A\u9664\u7D44\u5408',
                        onPressed: () => _deleteCombination(combination),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  if (preview.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: preview
                            .map((tag) => Chip(
                                  label: Text('${tag.zh} · ${tag.en}'),
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ),
                  if (combination.extraPositive.trim().isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                            '\u984D\u5916\u6B63\u5411\uFF1A${_extraTags(combination.extraPositive).map(_positiveEnglishTag).join(', ')}'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _personSlots.asMap().entries.map((entry) {
                        final personIndex = entry.key;
                        final characterNames = _characterChineseForSlot(
                            _personSlots[personIndex], personIndex);
                        final personLabel = characterNames.isEmpty
                            ? '\u4EBA\u7269 ${personIndex + 1}'
                            : characterNames.first;
                        final applied = _personCombinationIds[personIndex]
                                ?.contains(combination.id) ??
                            false;
                        return OutlinedButton.icon(
                          onPressed: () =>
                              _applyCombination(combination, personIndex),
                          icon: Icon(applied
                              ? Icons.check_circle_outline
                              : Icons.playlist_add),
                          label: Text(
                              '\u5957\u7528 $personLabel${applied ? '\uFF08\u5DF2\u5957\u7528\uFF09' : ''}'),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _addCustomTag() {
    final zh = TextEditingController();
    final en = TextEditingController();
    String group = '自訂特徵';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('新增自訂標籤'),
          content: SizedBox(
            width: 430,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: zh,
                  decoration: const InputDecoration(labelText: '中文名稱'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: en,
                  decoration: const InputDecoration(
                    labelText: 'English tag',
                    hintText: '例如: blue jacket',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: group,
                  decoration: const InputDecoration(labelText: '分類與輸出順序'),
                  items: const [
                    '自訂角色',
                    '自訂特徵',
                    '身體特徵',
                    '眼睛',
                    '額外特徵',
                    '髮長',
                    '髮色',
                    '髮型',
                    '上衣',
                    '褲子',
                    '裙子',
                    '內衣',
                    '胸罩',
                    '內褲',
                    '襪子',
                    '鞋子',
                    '服裝',
                    _cosplayGroup,
                    '配件',
                    '配件顏色',
                    '帽子顏色',
                    '眼鏡顏色',
                    '內衣顏色',
                    '胸罩顏色',
                    '內褲顏色',
                    '襪子顏色',
                    '鞋子顏色',
                    '上衣風格',
                    '下身風格',
                    '上衣顏色',
                    '下身顏色',
                    '服裝顏色',
                    '服裝邊線色',
                    '上衣邊線色',
                    '下身邊線色',
                    '內衣邊線色',
                    '胸罩邊線色',
                    '內褲邊線色',
                    '襪子邊線色',
                    '鞋子邊線色',
                    '配件邊線色',
                    '帽子邊線色',
                    '眼鏡邊線色',
                    '配件位置',
                    '服裝細節',
                    '服裝材質',
                    '穿脫狀態',
                    '表情',
                    '姿勢',
                    '動作',
                    '物件',
                    '成人道具',
                    _indoorSceneGroup,
                    _outdoorSceneGroup,
                    _outdoorTimeGroup,
                    _cameraFramingGroup,
                    _cameraFaceFocusGroup,
                    _cameraFocusGroup,
                    _cameraCropGroup,
                    '其他',
                  ]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setDialogState(() => group = value ?? group),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '自訂內容會只儲存在此瀏覽器，不會上傳。',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final zhValue = zh.text.trim();
                final enValue = _cleanTag(en.text);
                if (zhValue.isEmpty || enValue.isEmpty) return;
                final order = ['自訂角色'].contains(group)
                    ? 0
                    : ['自訂特徵'].contains(group)
                        ? 1
                        : ['表情'].contains(group)
                            ? 3
                            : ['姿勢'].contains(group)
                                ? 4
                                : _isScenePickerGroup(group) ||
                                        group == _outdoorTimeGroup ||
                                        _isCameraGroup(group)
                                    ? 9
                                    : 2;
                final tag = TagItem(
                  id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
                  group: group,
                  zh: zhValue,
                  en: enValue,
                  order: order,
                  builtIn: false,
                );
                setState(() {
                  _customTags.add(tag);
                  _invalidateTagCaches();
                  const personalGroups = {
                    '內衣顏色',
                    '胸罩顏色',
                    '內褲顏色',
                    '襪子顏色',
                    '鞋子顏色',
                    '自訂角色',
                    '自訂特徵',
                    '身體特徵',
                    '眼睛',
                    '額外特徵',
                    '髮長',
                    '髮色',
                    '髮型',
                    '上衣',
                    '褲子',
                    '裙子',
                    '內衣',
                    '胸罩',
                    '內褲',
                    '襪子',
                    '鞋子',
                    '服裝',
                    _cosplayGroup,
                    '配件',
                    '配件顏色',
                    '帽子顏色',
                    '眼鏡顏色',
                    '上衣風格',
                    '下身風格',
                    '上衣顏色',
                    '下身顏色',
                    '服裝顏色',
                    '服裝邊線色',
                    '上衣邊線色',
                    '下身邊線色',
                    '內衣邊線色',
                    '胸罩邊線色',
                    '內褲邊線色',
                    '襪子邊線色',
                    '鞋子邊線色',
                    '配件邊線色',
                    '帽子邊線色',
                    '眼鏡邊線色',
                    '服裝細節',
                    '服裝細節顏色',
                    '服裝材質',
                    '穿脫狀態',
                    '表情',
                    '姿勢',
                    '動作',
                    '物件',
                    '成人道具',
                  };
                  if (personalGroups.contains(group)) {
                    _personTagIds(0).add(tag.id);
                  } else {
                    _selectedIds.add(tag.id);
                  }
                  _persist();
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('加入並選取'),
            ),
          ],
        ),
      ),
    );
  }

  List<TagItem> _visibleTags(String group) {
    final query = _search.text.trim().toLowerCase();
    final effectiveGroup = group == '髮色'
        ? '髮型'
        : group == '臉部特徵'
            ? '表情'
            : group;
    final tags = _allTags.where((tag) {
      final hairColorInHairGroup = effectiveGroup == '髮型' && tag.group == '髮色';
      final faceExpressionInMergedGroup = effectiveGroup == '表情' &&
          tag.group == '臉部特徵' &&
          _isDynamicHeadActionTag(tag);
      final faceExpressionInSubgroup = _expressionSubgroupForTag(tag) == group;
      final staticFaceAppearanceMatch = group == _staticFaceAppearanceGroup &&
          _isStaticFaceAppearanceTag(tag);
      final objectInteractionMatch =
          group == _objectInteractionGroup && _isObjectInteractionTag(tag);
      final groupMatch = group == '全部' ||
          tag.group == effectiveGroup ||
          hairColorInHairGroup ||
          faceExpressionInMergedGroup ||
          faceExpressionInSubgroup ||
          staticFaceAppearanceMatch ||
          objectInteractionMatch;
      final adultMatch = _showAdult || !tag.adult;
      final queryMatch = query.isEmpty ||
          tag.zh.toLowerCase().contains(query) ||
          tag.en.toLowerCase().contains(query);
      return groupMatch && adultMatch && queryMatch;
    }).toList();
    return _sortPickerTags(tags, effectiveGroup);
  }

  bool _isEyeColorTag(TagItem tag) => RegExp(
          r'\b(blonde|black|silver|blue|red|pink|white|purple|aqua|brown|green|orange|yellow|gray|gold|teal)\s+eyes?\b',
          caseSensitive: false)
      .hasMatch(tag.en);

  List<TagItem> _sortPickerTags(List<TagItem> tags, String activeGroup) {
    tags.sort((a, b) {
      if (activeGroup == _allClothingWearGroup) {
        const wearSlotOrder = <String>[
          'top',
          'onepiece',
          'pants',
          'skirt',
          'underwear',
          'bra',
          'panties',
          'socks',
          'shoes',
          'accessory',
        ];
        final aSlot = _scopedClothingSlot(a.group);
        final bSlot = _scopedClothingSlot(b.group);
        final aOrder =
            aSlot == null ? wearSlotOrder.length : wearSlotOrder.indexOf(aSlot);
        final bOrder =
            bSlot == null ? wearSlotOrder.length : wearSlotOrder.indexOf(bSlot);
        if (aOrder != bOrder) return aOrder.compareTo(bOrder);
      }

      int rank(TagItem tag) {
        if (activeGroup == '髮型') {
          if (tag.group == '髮色') return 2;
          if (tag.group == '髮型') {
            return _isOfficialHairStyleTag(tag) ? 0 : 1;
          }
        }
        if (activeGroup == '眼睛') return _isColorPickerTag(tag) ? 0 : 1;
        return 0;
      }

      final rankCompare = rank(a).compareTo(rank(b));
      return rankCompare == 0 ? _compareOutputTags(a, b) : rankCompare;
    });
    return tags;
  }

  double _adaptiveChipLabelWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 430) return 124;
    if (width < 800) return 154;
    return 190;
  }

  Color _pickerLayerTone(String group) {
    const poseTones = <String, Color>{
      '姿勢': Color(0xffa78bfa),
      '站立與蹲姿': Color(0xfffbbf24),
      '坐姿與跪姿': Color(0xff22d3ee),
      '躺臥姿勢': Color(0xff818cf8),
      '單人・站姿': Color(0xfffbbf24),
      '單人・靠牆姿勢': Color(0xfff59e0b),
      '單人・椅子坐姿': Color(0xff22d3ee),
      '單人・桌邊姿勢': Color(0xff06b6d4),
      '單人・地板坐姿': Color(0xff14b8a6),
      '單人・床上坐姿': Color(0xff38bdf8),
      '單人・仰躺姿勢': Color(0xff818cf8),
      '單人・側躺姿勢': Color(0xff6366f1),
      '單人・俯臥姿勢': Color(0xff8b5cf6),
      '單人・跪蹲姿勢': Color(0xffa78bfa),
      '全身姿勢': Color(0xffe879f9),
      '軀幹姿勢': Color(0xff2dd4bf),
      '頭部姿勢': Color(0xfff472b6),
      _expressionEyesGroup: Color(0xfff472b6),
      _expressionMouthGroup: Color(0xfffb7185),
      _expressionTeasingGroup: Color(0xffe879f9),
      _expressionSymbolGroup: Color(0xfffacc15),
      _expressionOtherGroup: Color(0xffc084fc),
      _staticFaceAppearanceGroup: Color(0xff60a5fa),
      '手臂姿勢': Color(0xff60a5fa),
      '手部姿勢': Color(0xffa3e635),
      '手指・指向方向': Color(0xfffacc15),
      '手指・手勢形狀': Color(0xffa3e635),
      '手指・嘴臉互動': Color(0xfff472b6),
      '手指・細節動作': Color(0xff2dd4bf),
      '腿部姿勢': Color(0xff34d399),
      '動態姿勢': Color(0xffff8a4c),
      '動作': Color(0xfffb923c),
      '身體動作': Color(0xfff97316),
      '親吻動作': Color(0xfff9a8d4),
      '多人互動': Color(0xfffacc15),
      '角色姿勢': Color(0xffc084fc),
      '物件': Color(0xff94a3b8),
      _objectInteractionGroup: Color(0xff14b8a6),
      _objectFurnitureGroup: Color(0xffa8a29e),
      _objectDiningGroup: Color(0xfffb923c),
      _objectStudyGroup: Color(0xff60a5fa),
      _objectTechGroup: Color(0xff22d3ee),
      _objectSportGroup: Color(0xff34d399),
      _objectToolGroup: Color(0xfffbbf24),
      _objectFantasyGroup: Color(0xffc084fc),
      _objectTravelGroup: Color(0xff38bdf8),
      _objectDailyGroup: Color(0xfff9a8d4),
      '性姿勢': Color(0xfffb7185),
      '性姿勢・一般': Color(0xfffb7185),
      '性姿勢・後入': Color(0xfff43f5e),
      '性姿勢・女上位': Color(0xffec4899),
      '性姿勢・男上位': Color(0xffef4444),
      '性姿勢・多人': Color(0xffe11d48),
      '束縛姿勢': Color(0xffdc2626),
      '性行為': Color(0xfff97316),
      '性行為・動態': Color(0xfffb6a3d),
      '性行為・親吻': Color(0xfff43f8c),
      'BDSM行為': Color(0xffb91c1c),
      '成人道具': Color(0xffe879f9),
      '成人道具・插入': Color(0xffd946ef),
      '成人道具・振動': Color(0xffc026d3),
      'BDSM器具': Color(0xffbe123c),
      '情趣用品': Color(0xffdb2777),
      '情趣內衣': Color(0xffe879f9),
      'BDSM服裝': Color(0xffbe123c),
      '暴露服裝': Color(0xfffb7185),
      '體液': Color(0xff38bdf8),
      '公開與窺視': Color(0xfff59e0b),
    };
    final poseTone = poseTones[group];
    if (poseTone != null) return poseTone;
    if (group == _wingTypeGroup) return const Color(0xff818cf8);
    if (group == _animalEarColorGroup) return const Color(0xfff472b6);
    if (group == _animalTailColorGroup) return const Color(0xffc084fc);
    if (group == _animalHandColorGroup) return const Color(0xfffb923c);
    if (group == _animalFootColorGroup) return const Color(0xff34d399);
    if (group == _wingColorGroup) return const Color(0xff38bdf8);
    if (group == _indoorSceneGroup) return const Color(0xff38bdf8);
    if (group == _outdoorSceneGroup) return const Color(0xff4ade80);
    if (group == _outdoorTimeGroup) return const Color(0xfffbbf24);
    if (group == _cameraFramingGroup) return const Color(0xff60a5fa);
    if (group == _cameraFaceFocusGroup) return const Color(0xfff472b6);
    if (group == _cameraFocusGroup) return const Color(0xfff472b6);
    if (group == _cameraCropGroup) return const Color(0xffa78bfa);
    if (expandedSexualActGroups.contains(group)) {
      return const Color(0xfff97316);
    }
    const accessoryTones = <String, Color>{
      _clothingGroupHat: Color(0xffffb454),
      _clothingGroupHeadAccessory: Color(0xfff59e0b),
      _clothingGroupHairAccessory: Color(0xfff472b6),
      _clothingGroupEyewear: Color(0xff60a5fa),
      _clothingGroupFaceAccessory: Color(0xfffb7185),
      _clothingGroupAnimalAccessory: Color(0xffa78bfa),
      _clothingGroupNeckAccessory: Color(0xffc084fc),
      _clothingGroupHandAccessory: Color(0xff38bdf8),
      _clothingGroupWaistAccessory: Color(0xfffacc15),
      _clothingGroupOtherAccessory: Color(0xff94a3b8),
    };
    final accessoryTone = accessoryTones[group];
    if (accessoryTone != null) return accessoryTone;
    final kind = _scopedClothingKind(group);
    if (_isClothingBaseGroup(group) ||
        _clothingAccessoryPickerGroups.contains(group) ||
        group == _cosplayGroup) {
      return const Color(0xffffb454);
    }
    if (kind == 'cut') return const Color(0xff60a5fa);
    if (kind == 'fit') return const Color(0xff2dd4bf);
    if (kind == 'length') return const Color(0xff38bdf8);
    if (kind == 'material' || group == _legacyClothingMaterialGroup) {
      return const Color(0xffc084fc);
    }
    if (kind == 'detail' || group == _legacyClothingDetailGroup) {
      return const Color(0xfff472b6);
    }
    if (kind == 'detail_color') return const Color(0xfffb7185);
    if (kind == 'pattern') return const Color(0xfffb923c);
    if (kind == 'wear' ||
        group == _allClothingWearGroup ||
        group == _legacyClothingWearGroup) {
      return const Color(0xfff87171);
    }
    if (group.endsWith('邊線色')) return const Color(0xfff472b6);
    if (_isClothingColorGroup(group)) return const Color(0xff818cf8);
    if (group == _outfitMainStyleGroup || group == _outfitSubStyleGroup) {
      return const Color(0xffa78bfa);
    }
    if (group == _outfitMoodGroup) return const Color(0xfff472b6);
    if (group == _outfitOccasionGroup) return const Color(0xff4ade80);
    if (group == '配件位置') return const Color(0xfffacc15);
    return const Color(0xffa78bfa);
  }

  Color _pickerLayerSurface(Color tone, {required bool selected}) =>
      Color.alphaBlend(
        tone.withOpacity(selected ? .9 : .18),
        selected ? const Color(0xff171326) : _buttonSurface,
      );

  Color _pickerLayerText(Color tone, {required bool selected}) {
    if (!selected) return Colors.white;
    return tone.computeLuminance() > .42
        ? const Color(0xff171326)
        : Colors.white;
  }

  Widget _tagChip(TagItem tag, {int? personIndex}) {
    final selected = personIndex == null
        ? _selectedIds.contains(tag.id)
        : _personTagIds(personIndex).contains(tag.id);
    if (_isColorPickerTag(tag)) {
      final colorOrder = !selected || personIndex == null
          ? 0
          : tag.group == '髮色'
              ? _hairGradientColorOrder(personIndex, tag.id)
              : _clothingColorOrderForTag(tag);
      return _colorTagChip(
        tag,
        personIndex: personIndex,
        selected: selected,
        colorOrder: colorOrder,
      );
    }
    final tone = _pickerLayerTone(tag.group);
    final isHairStyle = tag.group == '髮型';
    final officialHairStyle =
        isHairStyle ? _isOfficialHairStyleTag(tag) : false;
    final isClothing = _isClothingGroup(tag.group);
    final clothingSupport = isClothing
        ? tag.support == 'official'
            ? '官方｜'
            : tag.support == 'description'
                ? '描述｜'
                : '既有｜'
        : '';
    final labelPrefix = isHairStyle
        ? officialHairStyle
            ? '官方｜'
            : '描述｜'
        : clothingSupport;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: _adaptiveChipLabelWidth(context) + (tag.adult ? 28 : 14),
      ),
      child: FilterChip(
        selected: selected,
        label: Text(
          '$labelPrefix${tag.zh}  ·  ${tag.en}',
          softWrap: true,
          style: TextStyle(
            color: _pickerLayerText(tone, selected: selected),
            fontWeight: FontWeight.w600,
          ),
        ),
        avatar: tag.adult
            ? Icon(Icons.eighteen_mp,
                size: 15,
                color: selected
                    ? _pickerLayerText(tone, selected: true)
                    : const Color(0xffffa7b7))
            : isHairStyle || isClothing
                ? Icon(
                    (isHairStyle && officialHairStyle) ||
                            (isClothing && tag.support == 'official')
                        ? Icons.verified_outlined
                        : Icons.auto_awesome_outlined,
                    size: 16,
                    color: selected
                        ? _pickerLayerText(tone, selected: true)
                        : (isHairStyle && officialHairStyle) ||
                                (isClothing && tag.support == 'official')
                            ? const Color(0xff4ade80)
                            : const Color(0xfffbbf24),
                  )
                : null,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        labelPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.standard,
        backgroundColor: _pickerLayerSurface(tone, selected: false),
        selectedColor: _pickerLayerSurface(tone, selected: true),
        checkmarkColor: _pickerLayerText(tone, selected: true),
        side: BorderSide(
          color: selected ? tone : tone.withOpacity(.7),
        ),
        onSelected: (_) => _toggle(tag, personIndex: personIndex),
      ),
    );
  }

  Widget _colorTagChip(
    TagItem tag, {
    required int? personIndex,
    required bool selected,
    int colorOrder = 0,
    String? colorOrderLabel,
    VoidCallback? onTap,
  }) {
    final colorWord = _clothingColorWord(tag);
    final tone = _pickerLayerTone(tag.group);
    final swatch = SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorWord == 'multicolored'
                  ? null
                  : _promptColorValues[colorWord],
              gradient: colorWord == 'multicolored'
                  ? const LinearGradient(
                      colors: [
                        Color(0xffef4444),
                        Color(0xfffacc15),
                        Color(0xff22c55e),
                        Color(0xff3b82f6),
                        Color(0xffa855f7),
                      ],
                    )
                  : null,
              border: Border.all(
                color: selected ? const Color(0xffffffff) : _buttonBorder,
                width: selected ? 2 : 1,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, size: 17, color: Colors.white)
                : null,
          ),
          if (colorOrder > 0)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xff171326),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  '$colorOrder',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    return Tooltip(
      message: colorOrder > 0
          ? '${tag.zh} · ${tag.en}｜${colorOrderLabel ?? (tag.group == '髮色' ? '漸層色 $colorOrder' : '色 $colorOrder')}'
          : '${tag.zh} · ${tag.en}',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 58, minHeight: 44),
        child: FilterChip(
          selected: selected,
          label: swatch,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          labelPadding: EdgeInsets.zero,
          backgroundColor: _pickerLayerSurface(tone, selected: false),
          selectedColor: _pickerLayerSurface(tone, selected: true),
          checkmarkColor: Colors.transparent,
          side: BorderSide(
            color: selected ? Colors.white : tone.withOpacity(.72),
          ),
          onSelected: (_) {
            if (onTap != null) {
              onTap();
            } else {
              _toggle(tag, personIndex: personIndex);
            }
          },
        ),
      ),
    );
  }

  Widget _clothingColorPairControl(int personIndex, List<TagItem> bases) {
    if (personIndex < 0 ||
        personIndex >= _personSlots.length ||
        bases.isEmpty) {
      return const SizedBox.shrink();
    }
    final base = bases.first;
    final mainGroup = _clothingColorGroupForBase(base);
    final secondaryGroup = _clothingTrimColorGroupForBase(base);
    if (mainGroup == null || secondaryGroup == null) {
      return const SizedBox.shrink();
    }
    final selected = _selectedTagsForPerson(personIndex);
    final main = _selectedClothingColorForGroup(selected, mainGroup);
    final secondary = _selectedClothingColorForGroup(selected, secondaryGroup);
    final choices = _clothingColorChoices(mainGroup, secondaryGroup);
    if (choices.isEmpty) return const SizedBox.shrink();
    const tone = Color(0xff818cf8);

    Widget slotChip(int order, TagItem? color, String group, String role) {
      final label = color == null
          ? '色 $order：未選'
          : '色 $order：${_clothingColorChinesePrefix(color)}';
      return InputChip(
        avatar: CircleAvatar(
          radius: 10,
          backgroundColor: tone,
          child: Text('$order', style: const TextStyle(fontSize: 11)),
        ),
        label: Text(label),
        tooltip: '色 $order（$role）',
        backgroundColor: _pickerLayerSurface(tone, selected: color != null),
        side: BorderSide(color: tone.withOpacity(.75)),
        onDeleted: color == null
            ? null
            : () => _clearClothingColorSlot(personIndex, group),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xff202847),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.withOpacity(.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.palette_outlined, color: tone, size: 20),
              SizedBox(width: 8),
              Text('配色：色 1／色 2', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              slotChip(1, main, mainGroup, '主色'),
              slotChip(2, secondary, secondaryGroup, '次色／邊線色'),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            '依序點選顏色：第一色為主色、第二色為次色。兩色都選好後，再點新色只替換色 2；可用上方 X 分別清除。輸出敘述維持主色與邊線／細節色的原本規則。',
            style: TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: choices.map((choice) {
              final isMain =
                  main != null && _isSameClothingColorChoice(main, choice);
              final isSecondary = secondary != null &&
                  _isSameClothingColorChoice(secondary, choice);
              final order = isSecondary ? 2 : (isMain ? 1 : 0);
              return _colorTagChip(
                choice,
                personIndex: personIndex,
                selected: order > 0,
                colorOrder: order,
                colorOrderLabel: order == 1
                    ? '色 1（主色）'
                    : order == 2
                        ? '色 2（次色）'
                        : null,
                onTap: () => _toggleClothingColorPair(
                  personIndex,
                  mainGroup,
                  secondaryGroup,
                  choice,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _wizardGroupLabel(String group) {
    const clothingColorLabels = <String, String>{
      '服裝顏色': '連身裝色彩 1',
      '上衣顏色': '上衣色彩 1',
      '下身顏色': '下身色彩 1',
      '內衣顏色': '內衣色彩 1',
      '胸罩顏色': '胸罩色彩 1',
      '內褲顏色': '內褲色彩 1',
      '襪子顏色': '襪子色彩 1',
      '鞋子顏色': '鞋子色彩 1',
      '外套顏色': '外套色彩 1',
      '配件顏色': '配件色彩 1',
      '帽子顏色': '帽子色彩 1',
      '眼鏡顏色': '眼鏡色彩 1',
      _animalEarColorGroup: '獸耳顏色',
      _animalTailColorGroup: '獸尾顏色',
      _animalHandColorGroup: '獸手顏色',
      _animalFootColorGroup: '獸足顏色',
      _wingColorGroup: '翅膀顏色',
      '服裝邊線色': '連身裝色彩 2',
      '上衣邊線色': '上衣色彩 2',
      '下身邊線色': '下身色彩 2',
      '內衣邊線色': '內衣色彩 2',
      '胸罩邊線色': '胸罩色彩 2',
      '內褲邊線色': '內褲色彩 2',
      '襪子邊線色': '襪子色彩 2',
      '鞋子邊線色': '鞋子色彩 2',
      '外套邊線色': '外套色彩 2',
      '配件邊線色': '配件色彩 2',
      '帽子邊線色': '帽子色彩 2',
      '眼鏡邊線色': '眼鏡色彩 2',
    };
    final clothingColorLabel = clothingColorLabels[group];
    if (clothingColorLabel != null) return clothingColorLabel;
    if (group == _allClothingWearGroup) return '\u7A7F\u812B\u72C0\u614B';
    if (group == _cosplayGroup) return 'Cosplay／角色扮演';
    if (group == _indoorSceneGroup) return '室內場景';
    if (group == _outdoorSceneGroup) return '戶外場景';
    if (group == _outdoorTimeGroup) return '戶外時段';
    if (group == _cameraFramingGroup) return '鏡頭・取景範圍';
    if (group == _cameraFaceFocusGroup) return '鏡頭・臉部（眼睛／嘴巴／表情）';
    if (group == _cameraFocusGroup) return '鏡頭・身體聚焦（頭到腳）';
    if (group == _cameraCropGroup) return '鏡頭・裁切構圖';
    if (group == _animalTraitGroup) return '獸人特徵（含顏色）';
    if (group == _wingTypeGroup) return '翅膀（含顏色）';
    if (group == _clothingGroupHat) return '帽子／頭戴';
    if (group == _clothingGroupHairAccessory) return '髮飾';
    if (group == _clothingGroupEyewear) return '眼鏡／眼罩';
    if (group == _clothingGroupHeadAccessory) return '其他頭部配件';
    if (group == _clothingGroupAnimalAccessory) return '獸耳／尾飾／翅飾';
    if (group == '褲子') return '下身／褲子';
    if (group == '短褲') return '下身／短褲';
    if (group == '服裝') return '連身裙／洋裝';
    if (group == '特殊服裝') return '特殊服裝／制服';
    if (group == '服裝顏色') return '連身裝顏色';
    final scopedSlot = _scopedClothingSlot(group);
    final scopedKind = _scopedClothingKind(group);
    if (scopedSlot != null && scopedKind != null) {
      return '${_clothingScopeLabel(scopedSlot)} ${_clothingScopedKindLabel(scopedKind)}';
    }
    return group;
  }

  double _wizardGroupChipWidth(String group, double availableWidth) {
    final label = _wizardGroupLabel(group);
    final idealWidth = 38 + label.runes.length * 17.0;
    return idealWidth.clamp(76.0, availableWidth).toDouble();
  }

  List<TagItem> _stepVisibleTags(List<String> groups,
      {String? queryText,
      String? activeGroup,
      int? personIndex,
      bool searchAllGroups = false}) {
    final query = (queryText ?? _search.text).trim().toLowerCase();
    final pickerGroup = activeGroup ?? groups.first;
    final searchAcrossGroups = searchAllGroups;
    final pickerTags = searchAcrossGroups
        ? _tagsForPickerGroups(groups)
        : _tagsForPickerGroup(pickerGroup);
    final pickerTagIds = searchAcrossGroups
        ? pickerTags.map((tag) => tag.id).toSet()
        : const <String>{};
    final selectedClothingScopes = personIndex == null
        ? const <String>{}
        : _clothingDesignBases(_selectedTagsForPerson(personIndex))
            .map(_clothingScopeForBase)
            .whereType<String>()
            .toSet();
    _allTags;
    final hiddenTaxonomyIds = _hiddenTaxonomyDuplicateIdsCache!;
    final tags = pickerTags.where((tag) {
      final allClothingWear = activeGroup == _allClothingWearGroup &&
          _scopedClothingKind(tag.group) == 'wear' &&
          (personIndex == null ||
              selectedClothingScopes.contains(_scopedClothingSlot(tag.group)));
      final hairColorInHairGroup = activeGroup == '髮型' && tag.group == '髮色';
      final faceExpressionInMergedGroup = activeGroup == '表情' &&
          tag.group == '臉部特徵' &&
          _isDynamicHeadActionTag(tag);
      final faceExpressionInSubgroup =
          _expressionSubgroupForTag(tag) == activeGroup;
      final staticFaceAppearanceMatch =
          activeGroup == _staticFaceAppearanceGroup &&
              _isStaticFaceAppearanceTag(tag);
      final staticFaceInPickerGroups =
          groups.contains(_staticFaceAppearanceGroup) &&
              _isStaticFaceAppearanceTag(tag);
      final objectInteractionMatch = activeGroup == _objectInteractionGroup &&
          _isObjectInteractionTag(tag);
      final objectInteractionInPickerGroups =
          groups.contains(_objectInteractionGroup) &&
              _isObjectInteractionTag(tag);
      final objectPickerGroup = _objectPickerGroupForTag(tag);
      final objectCategoryMatch = objectPickerGroup == activeGroup;
      final objectInPickerGroups =
          objectPickerGroup != null && groups.contains(objectPickerGroup);
      final usesClothingBaseDisplayGroup = const {
        _clothingGroupTop,
        _clothingGroupPants,
        _clothingGroupShorts,
        _clothingGroupSkirt,
        _clothingGroupOnePiece,
        _clothingGroupOuterwear,
        _clothingGroupCostume,
        _clothingGroupUnderwear,
        _clothingGroupBra,
        _clothingGroupPanties,
        _clothingGroupSocks,
        _clothingGroupShoes,
        _clothingGroupAccessory,
        ..._clothingAccessoryPickerGroups,
      }.contains(activeGroup);
      final virtualAccessoryMatch = activeGroup != null &&
          _clothingAccessoryPickerGroups.contains(activeGroup) &&
          _isClothingBaseTag(tag) &&
          _clothingBaseDisplayGroup(tag) == _clothingGroupAccessory &&
          _clothingAccessoryPickerGroup(tag) == activeGroup;
      final clothingBaseDisplayMatch = virtualAccessoryMatch ||
          (usesClothingBaseDisplayGroup &&
              _isClothingBaseTag(tag) &&
              _clothingBaseDisplayGroup(tag) == activeGroup);
      final directActiveGroupMatch = usesClothingBaseDisplayGroup
          ? clothingBaseDisplayMatch
          : tag.group == activeGroup ||
              objectCategoryMatch ||
              staticFaceAppearanceMatch ||
              objectInteractionMatch;
      final inGroup = searchAcrossGroups
          ? pickerTagIds.contains(tag.id)
          : (groups.contains(tag.group) ||
                  objectInPickerGroups ||
                  staticFaceInPickerGroups ||
                  objectInteractionInPickerGroups ||
                  clothingBaseDisplayMatch ||
                  allClothingWear ||
                  hairColorInHairGroup ||
                  faceExpressionInMergedGroup ||
                  faceExpressionInSubgroup) &&
              (activeGroup == null ||
                  directActiveGroupMatch ||
                  allClothingWear ||
                  hairColorInHairGroup ||
                  faceExpressionInMergedGroup ||
                  faceExpressionInSubgroup ||
                  staticFaceAppearanceMatch ||
                  objectInteractionMatch);
      final adultMatch = _showAdult || !tag.adult;
      final queryMatch = query.isEmpty ||
          tag.zh.toLowerCase().contains(query) ||
          tag.en.toLowerCase().contains(query);
      final scopedKind = _scopedClothingKind(tag.group);
      final hiddenLegacyScopedDesign =
          tag.id.startsWith(_scopedClothingPrefix) &&
              const {'style', 'detail', 'material'}.contains(scopedKind);
      final hiddenTaxonomyDuplicate = hiddenTaxonomyIds.contains(tag.id);
      return inGroup &&
          adultMatch &&
          queryMatch &&
          !hiddenLegacyScopedDesign &&
          !hiddenTaxonomyDuplicate;
    }).toList();
    return _sortPickerTags(tags, pickerGroup);
  }

  Widget _hairGradientControl(int personIndex) {
    if (personIndex < 0 || personIndex >= _personSlots.length) {
      return const SizedBox.shrink();
    }
    final slot = _personSlots[personIndex];
    final colors = _selectedHairColorTags(personIndex);
    const tone = Color(0xffa78bfa);
    if (colors.length < 2) {
      final first = colors.isEmpty ? null : colors.first;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xff2b2440),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: tone.withOpacity(.72)),
        ),
        child: Row(
          children: [
            const Icon(Icons.gradient_outlined, color: tone, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                first == null
                    ? '選擇第一種髮色後，再選第二種髮色即可建立漸層。'
                    : '色 1：${first.zh}。再選一種髮色即可建立雙色漸層。',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    final primary = colors[0];
    final secondary = colors[1];
    final primaryColor = _promptColorValues[_hairColorWord(primary)] ?? tone;
    final secondaryColor =
        _promptColorValues[_hairColorWord(secondary)] ?? tone;
    final selectedStyle = _hairGradientStyleForSlot(slot);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xff2b2440),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.withOpacity(.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(.8)),
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text('雙色漸層髮',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              Text('色 1：${primary.zh}  →  色 2：${secondary.zh}',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '再點其他顏色會只替換色 2；若要更換色 1，請先點色 1 取消後再選擇。',
            style: TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _hairGradientStyles
                .map((style) => Tooltip(
                      message: style.hint,
                      child: ChoiceChip(
                        selected: selectedStyle.id == style.id,
                        label: Text(style.zh),
                        selectedColor: tone,
                        side: BorderSide(
                          color: selectedStyle.id == style.id
                              ? tone
                              : tone.withOpacity(.65),
                        ),
                        onSelected: (_) => setState(() {
                          slot.hairGradientStyle = style.id;
                          _persist();
                        }),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _hairPromptWeightControl(int personIndex) {
    if (personIndex < 0 || personIndex >= _personSlots.length) {
      return const SizedBox.shrink();
    }
    final slot = _personSlots[personIndex];
    final hairTags =
        _selectedTagsForPerson(personIndex).where(_isHairPromptTag).toList();
    final hasHair = hairTags.isNotEmpty;
    final value = _boundedPromptWeight(slot.hairPromptWeight);
    final hairLabel = !hasHair
        ? '請先在上方選擇髮長、髮型或髮色'
        : hairTags.map((tag) => tag.zh).toSet().join('、');

    void updateEnabled(bool enabled) {
      setState(() {
        slot.hairPromptWeightEnabled = enabled;
        _persist();
      });
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xff153047),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff38bdf8).withOpacity(.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: slot.hairPromptWeightEnabled,
            onChanged: hasHair
                ? updateEnabled
                : (enabled) {
                    if (!enabled) updateEnabled(false);
                  },
            title: const Text('加強髮長／髮型／髮色',
                style: TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(
              hasHair ? '將髮長、髮型與髮色（$hairLabel）一起獨立加強。' : hairLabel,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          if (slot.hairPromptWeightEnabled && hasHair) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                const Expanded(
                  child: Text('髮型權重',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                SizedBox(
                  width: 92,
                  child: TextFormField(
                    key: ValueKey<String>(
                        'hair-prompt-weight-$personIndex-${value.toStringAsFixed(2)}'),
                    initialValue: value.toStringAsFixed(2),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      suffixText: 'x',
                    ),
                    onChanged: (input) {
                      final parsed = double.tryParse(input.trim());
                      if (parsed == null) return;
                      slot.hairPromptWeight = _boundedPromptWeight(parsed);
                      _persist();
                    },
                    onFieldSubmitted: (input) {
                      final parsed = double.tryParse(input.trim());
                      if (parsed == null) return;
                      setState(() {
                        slot.hairPromptWeight = _boundedPromptWeight(parsed);
                        _persist();
                      });
                    },
                  ),
                ),
              ],
            ),
            Slider(
              min: _minimumPromptWeight,
              max: _maximumPromptWeight,
              divisions: 20,
              value: value,
              label: value.toStringAsFixed(2),
              onChanged: (next) => setState(() {
                slot.hairPromptWeight = _boundedPromptWeight(next);
                _persist();
              }),
            ),
            const Text(
              '可輸入或拖曳設定 0.50–1.50；未勾選時髮長、髮型與髮色會維持在角色基本特徵權重區塊。',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _physicalTraitColorSection({
    required int personIndex,
    required String title,
    required String colorGroup,
    required List<TagItem> types,
  }) {
    final selectedIds = _personTagIds(personIndex);
    final selectedColor =
        _selectedTagsForPerson(personIndex).cast<TagItem?>().firstWhere(
              (tag) => tag?.group == colorGroup,
              orElse: () => null,
            );
    final colors = _stepVisibleTags(
      [colorGroup],
      queryText: '',
      activeGroup: colorGroup,
      personIndex: personIndex,
    );
    final tone = _pickerLayerTone(colorGroup);
    final previews = types.map((type) {
      final baseEnglish = _withoutLeadingPromptColor(type.en);
      final baseChinese = _withoutLeadingChineseColor(type.zh);
      final zh =
          '${selectedColor == null ? '' : _clothingColorChinesePrefix(selectedColor)}$baseChinese';
      final en = [
        if (selectedColor != null) _clothingColorPrefix(selectedColor),
        baseEnglish,
      ].where((value) => value.isNotEmpty).join(' ');
      return '$zh · $en';
    }).join('、');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _pickerLayerSurface(tone, selected: false),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.withOpacity(.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, size: 18, color: tone),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '$title（直接合併到特徵）',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (selectedColor != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: '清除$title',
                  onPressed: () =>
                      _toggle(selectedColor, personIndex: personIndex),
                  icon: const Icon(Icons.clear, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '輸出預覽：$previews',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: colors
                .map((tag) => _colorTagChip(
                      tag,
                      personIndex: personIndex,
                      selected: selectedIds.contains(tag.id),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _integratedPhysicalTraitColors(int personIndex, String currentGroup) {
    final selected = _selectedTagsForPerson(personIndex);
    final sections = <Widget>[];
    if (currentGroup == _animalTraitGroup) {
      final ears = selected.where(_isAnimalEarTypeTag).toList();
      final tails = selected.where(_isAnimalTailTypeTag).toList();
      final hands = selected.where(_isAnimalHandTypeTag).toList();
      final feet = selected.where(_isAnimalFootTypeTag).toList();
      if (ears.isNotEmpty) {
        sections.add(_physicalTraitColorSection(
          personIndex: personIndex,
          title: '獸耳顏色',
          colorGroup: _animalEarColorGroup,
          types: ears,
        ));
      }
      if (tails.isNotEmpty) {
        sections.add(_physicalTraitColorSection(
          personIndex: personIndex,
          title: '獸尾顏色',
          colorGroup: _animalTailColorGroup,
          types: tails,
        ));
      }
      if (hands.isNotEmpty) {
        sections.add(_physicalTraitColorSection(
          personIndex: personIndex,
          title: '獸手顏色',
          colorGroup: _animalHandColorGroup,
          types: hands,
        ));
      }
      if (feet.isNotEmpty) {
        sections.add(_physicalTraitColorSection(
          personIndex: personIndex,
          title: '獸足顏色',
          colorGroup: _animalFootColorGroup,
          types: feet,
        ));
      }
    } else if (currentGroup == _wingTypeGroup) {
      final wings = selected.where(_isWingTypeTag).toList();
      if (wings.isNotEmpty) {
        sections.add(_physicalTraitColorSection(
          personIndex: personIndex,
          title: '翅膀顏色',
          colorGroup: _wingColorGroup,
          types: wings,
        ));
      }
    }
    if (sections.isNotEmpty) return Column(children: sections);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 17),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              currentGroup == _wingTypeGroup
                  ? '先選擇翅膀類型，顏色選項就會直接顯示在翅膀設定內。'
                  : '先選擇獸耳、獸尾、獸手或獸足，對應的顏色選項就會直接顯示在特徵內。',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepTagPicker(List<String> groups,
      {required String nextLabel,
      int? personIndex,
      bool showNext = true,
      bool showGroupClear = false,
      List<String>? searchGroups,
      String? pickerStateKey}) {
    if (groups.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
            '\u8ACB\u5148\u9078\u64C7\u4E00\u7A2E\u670D\u88DD\u985E\u578B'),
      );
    }
    // Some pickers expose extra groups only after a prerequisite tag is
    // selected (for example a clothing detail color after choosing a detail).
    // Callers can provide a stable key so that change does not reset the user
    // back to the first category.
    final groupKey = personIndex == null
        ? null
        : '$personIndex:${pickerStateKey ?? groups.join('|')}';
    final storedGroup = personIndex == null
        ? _activeGroup
        : (_personActiveGroups[groupKey!] ?? groups.first);
    final currentGroup =
        groups.contains(storedGroup) ? storedGroup : groups.first;
    final searchScopeGroups = searchGroups ?? groups;
    final pickerQueryKey = _pickerQueryKey(searchScopeGroups, personIndex);
    final tagQuery = _pickerTagQueries[pickerQueryKey] ?? '';
    final visible = _stepVisibleTags(searchScopeGroups,
        queryText: tagQuery,
        activeGroup: currentGroup,
        personIndex: personIndex,
        searchAllGroups: tagQuery.isNotEmpty);
    final allInCurrentGroup = _stepVisibleTags(
      groups,
      queryText: '',
      activeGroup: currentGroup,
      personIndex: personIndex,
    );
    final allInPickerGroups = _stepVisibleTags(
      searchScopeGroups,
      queryText: '',
      activeGroup: null,
      personIndex: personIndex,
      searchAllGroups: true,
    );
    final selectedIds =
        personIndex == null ? _selectedIds : _personTagIds(personIndex);
    final selectedInCurrentGroup =
        allInCurrentGroup.where((tag) => selectedIds.contains(tag.id)).toList();
    int selectedCountForGroup(String group) => _stepVisibleTags(
          groups,
          queryText: '',
          activeGroup: group,
          personIndex: personIndex,
        ).where((tag) => selectedIds.contains(tag.id)).length;
    final maxOptionsHeight =
        MediaQuery.sizeOf(context).height < 720 ? 360.0 : 520.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          groups.length == 1 ? '標籤分類' : '先選擇細分類',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 7),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 6,
            runSpacing: 6,
            children: groups.map((group) {
              final selectedCount = selectedCountForGroup(group);
              final tone = _pickerLayerTone(group);
              final isActive = group == currentGroup;
              final width = _wizardGroupChipWidth(group, constraints.maxWidth) +
                  (selectedCount > 0 ? 30 : 0);
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: SizedBox(
                  width: min(width, constraints.maxWidth),
                  child: ChoiceChip(
                    label: Text(
                      selectedCount == 0
                          ? _wizardGroupLabel(group)
                          : '${_wizardGroupLabel(group)}  $selectedCount',
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: _pickerLayerText(tone, selected: isActive),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    selected: isActive,
                    backgroundColor: _pickerLayerSurface(tone, selected: false),
                    selectedColor: _pickerLayerSurface(tone, selected: true),
                    side: BorderSide(
                      color: isActive ? tone : tone.withOpacity(.72),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onSelected: (_) => setState(() {
                      _clearPickerQuery(searchScopeGroups, personIndex);
                      if (personIndex == null) {
                        _activeGroup = group;
                      } else {
                        _personActiveGroups[groupKey!] = group;
                        _personTagQueries[personIndex] = '';
                      }
                    }),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
          decoration: BoxDecoration(
            color: _pickerLayerSurface(_pickerLayerTone(currentGroup),
                selected: false),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _pickerLayerTone(currentGroup).withOpacity(.7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder_open_outlined, size: 19),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      _wizardGroupLabel(currentGroup),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '已選 ${selectedInCurrentGroup.length}／${allInCurrentGroup.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (showGroupClear && personIndex != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: '只清除此細分類',
                      onPressed: selectedInCurrentGroup.isEmpty
                          ? null
                          : () => _clearPersonPickerGroup(
                              personIndex, currentGroup),
                      icon: const Icon(Icons.delete_sweep_outlined, size: 19),
                    ),
                ],
              ),
              if (selectedInCurrentGroup.isNotEmpty) ...[
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: selectedInCurrentGroup
                      .map(
                        (tag) => Tooltip(
                          message: tag.en,
                          child: InputChip(
                            label: Text(tag.group == '髮型'
                                ? '${_isOfficialHairStyleTag(tag) ? '官方' : '描述'}｜${tag.zh}'
                                : tag.zh),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: _pickerLayerSurface(
                              _pickerLayerTone(currentGroup),
                              selected: false,
                            ),
                            side: BorderSide(
                              color: _pickerLayerTone(currentGroup)
                                  .withOpacity(.75),
                            ),
                            onDeleted: () =>
                                _toggle(tag, personIndex: personIndex),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        if (currentGroup == '髮型') ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff1f3b34),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xff4ade80)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_outlined,
                    size: 19, color: Color(0xff4ade80)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '「官方」是 Danbooru Hair Styles 群組中的精確標籤，通常較容易被 Amanatsu 辨識；「描述」是髮廊名稱或自然語句，效果依模型而異，建議再搭配官方髮型、髮長與髮色。',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (currentGroup == '髮型' && personIndex != null) ...[
          const SizedBox(height: 10),
          _hairGradientControl(personIndex),
          const SizedBox(height: 10),
          _hairPromptWeightControl(personIndex),
        ],
        const SizedBox(height: 10),
        TextField(
          controller: _pickerSearchController(searchScopeGroups, personIndex),
          decoration: InputDecoration(
              labelText: '搜尋此區所有標籤',
              prefixIcon: const Icon(Icons.search),
              hintText: '搜尋此區所有中英文標籤…',
              filled: true,
              suffixIcon: tagQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: '清除搜尋文字',
                      onPressed: () {
                        setState(() =>
                            _clearPickerQuery(searchScopeGroups, personIndex));
                      },
                      icon: const Icon(Icons.clear))),
          onChanged: (value) => setState(() {
            _pickerTagQueries[pickerQueryKey] = value;
          }),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.sell_outlined, size: 17),
            const SizedBox(width: 6),
            Text(
              tagQuery.trim().isEmpty
                  ? '此區可加入 ${allInPickerGroups.length} 個標籤'
                  : '搜尋結果 ${visible.length}／${allInPickerGroups.length} 個',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (visible.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('此分類沒有符合的標籤，可以切換細分類、清除搜尋或新增自訂標籤。'),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxOptionsHeight),
            child: SingleChildScrollView(
              primary: false,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: visible
                    .map((tag) => _tagChip(tag, personIndex: personIndex))
                    .toList(),
              ),
            ),
          ),
        if (visible.length > 18) ...[
          const SizedBox(height: 6),
          Text(
            '此區可上下滑動，建議使用搜尋快速縮小範圍。',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (personIndex != null &&
            (currentGroup == _animalTraitGroup ||
                currentGroup == _wingTypeGroup))
          _integratedPhysicalTraitColors(personIndex, currentGroup),
        if (showNext) ...[
          const SizedBox(height: 14),
          Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                  onPressed: _advanceStep,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(nextLabel))),
        ],
      ],
    );
  }

  Widget _stepPersonTagPicker(List<String> groups,
      {required String nextLabel, required String instruction}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(instruction),
        if (groups.contains(_animalTraitGroup)) ...[
          const SizedBox(height: 6),
          Text(
            '獸耳、獸尾、獸手與獸足在此代表角色本身的生理特徵，不會自動加入 furry。只選部位時會偏人形；需要全身毛茸茸獸人時，請在此分類另外勾選「全身毛茸茸獸人（furry）」。擬人獸可自行勾選 anthro。選好類型後，顏色會直接顯示在該特徵下方並合併輸出；服裝造型用的耳飾、尾飾與翅飾請在服裝的「獸耳／尾飾／翅飾」設定。',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 12),
        ..._personSlots.asMap().entries.map((entry) {
          final index = entry.key;
          final slot = entry.value;
          final characterNames = _characterChineseForSlot(slot, index);
          final title =
              characterNames.isEmpty ? '人物 ${index + 1}' : characterNames.first;
          if (!slot.detailed) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('人物 ${index + 1}'),
                subtitle: const Text('此人物設定為不需細節，不加入此類標籤。'),
              ),
            );
          }
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(.28),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(child: Text('${index + 1}')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('人物 ${index + 1} · $title',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        tooltip: '隨機此大項（自動避開衝突）',
                        onPressed: () => _randomizePersonGroups(index, groups),
                        icon: const Icon(Icons.shuffle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _personPromptWeightControls(index),
                  const SizedBox(height: 8),
                  _stepTagPicker(groups,
                      nextLabel: nextLabel,
                      personIndex: index,
                      showNext: false),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _advanceStep,
            icon: const Icon(Icons.arrow_forward),
            label: Text(nextLabel),
          ),
        ),
      ],
    );
  }

  List<_AdultPosePackage> _matchingAdultPosePackages() {
    final femaleCount =
        _personSlots.where((slot) => slot.gender == '女性').length;
    final maleCount = _personSlots.where((slot) => slot.gender == '男性').length;
    final otherCount = _personSlots.length - femaleCount - maleCount;
    return _adultPosePackages
        .where((package) =>
            package.femaleCount == femaleCount &&
            package.maleCount == maleCount &&
            otherCount == 0)
        .toList();
  }

  int? _adultPosePackageAnchor(_AdultPosePackage package) {
    if (package.femaleCount > 0) {
      final index = _personSlots.indexWhere((slot) => slot.gender == '女性');
      if (index >= 0) return index;
    }
    if (package.maleCount > 0) {
      final index = _personSlots.indexWhere((slot) => slot.gender == '男性');
      if (index >= 0) return index;
    }
    return _personSlots.isEmpty ? null : 0;
  }

  List<TagItem> _adultPosePackageTags(Iterable<String> englishTags) {
    final seen = <String>{};
    return englishTags
        .map(_tagByEnglish)
        .whereType<TagItem>()
        .where((tag) => seen.add(tag.id))
        .toList();
  }

  Set<String> get _adultPosePackagePersonTagIds => _adultPosePackageTags(
        _adultPosePackages.expand((package) => package.allPersonTags),
      ).map((tag) => tag.id).toSet();

  Set<String> get _adultPosePackageFrameTagIds => _adultPosePackageTags(
        _adultPosePackages.expand((package) => package.frameTags),
      ).map((tag) => tag.id).toSet();

  List<TagItem> _selectedAdultPosePackageTags() {
    final personIds = _adultPosePackagePersonTagIds;
    final frameIds = _adultPosePackageFrameTagIds;
    final ids = <String>{
      ..._personSelectedIds.values
          .expand((selected) => selected)
          .where(personIds.contains),
      ..._selectedIds.where(frameIds.contains),
    };
    return ids.map((id) => _tagsById[id]).whereType<TagItem>().toList()
      ..sort(_compareOutputTags);
  }

  bool _adultPosePackageIsSelected(
    _AdultPosePackage package, {
    required bool endPose,
  }) {
    final anchor = _adultPosePackageAnchor(package);
    if (anchor == null) return false;
    final personIds = _adultPosePackageTags(
      package.personTagsFor(endPose: endPose),
    ).map((tag) => tag.id).toSet();
    final frameIds =
        _adultPosePackageTags(package.frameTags).map((tag) => tag.id).toSet();
    return personIds.isNotEmpty &&
        _personTagIds(anchor).containsAll(personIds) &&
        _selectedIds.containsAll(frameIds);
  }

  void _removeAdultPosePackageTags() {
    final personIds = _adultPosePackagePersonTagIds;
    final frameIds = _adultPosePackageFrameTagIds;
    for (final selected in _personSelectedIds.values) {
      selected.removeWhere(personIds.contains);
    }
    _personSelectedIds.removeWhere((_, ids) => ids.isEmpty);
    _selectedIds.removeWhere(frameIds.contains);
  }

  Future<void> _clearAdultPosePackageTags() async {
    final selected = _selectedAdultPosePackageTags();
    if (selected.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清除成人姿勢套件？'),
        content: Text(
          '會移除套件使用的 ${selected.length} 個姿勢、行為與鏡頭標籤；你另外加入且不屬於套件的標籤會保留。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('確定清除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _removeAdultPosePackageTags();
      _persist();
    });
  }

  Future<void> _applyAdultPosePackage(
    _AdultPosePackage package, {
    required bool endPose,
  }) async {
    if (!_showAdult) return;
    if (endPose && !package.supportsEndPose) return;
    final anchor = _adultPosePackageAnchor(package);
    if (anchor == null || !_matchingAdultPosePackages().contains(package)) {
      return;
    }
    final personTags = _adultPosePackageTags(
      package.personTagsFor(endPose: endPose),
    );
    final frameTags = _adultPosePackageTags(package.frameTags);
    final phaseLabel = endPose ? '性愛結束姿勢・${package.endMovementZh}' : '性愛中姿勢';
    final resolvedEnglish = {
      ...personTags.map((tag) => _englishTagKey(tag.en)),
      ...frameTags.map((tag) => _englishTagKey(tag.en)),
    };
    final missing = [
      ...package.personTagsFor(endPose: endPose),
      ...package.frameTags,
    ].where((tag) => !resolvedEnglish.contains(_englishTagKey(tag))).toList();
    if (missing.isNotEmpty) {
      return;
    }

    final existing = _selectedAdultPosePackageTags();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('套用「${package.name}・$phaseLabel」？'),
        content: SizedBox(
          width: 620,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '此功能僅供所有登場人物皆為 18 歲以上的成年角色使用。請確認人物設定符合此條件。',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text('目前人物組成：${_peopleZhNew()}'),
                const SizedBox(height: 8),
                Text('${package.description}\n階段：$phaseLabel'),
                const SizedBox(height: 10),
                const Text('將套用：',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [...personTags, ...frameTags]
                      .map((tag) => Chip(label: Text('${tag.zh} · ${tag.en}')))
                      .toList(),
                ),
                if (existing.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    '目前其他套件使用的 ${existing.length} 個標籤會先移除；手動加入且不屬於套件的標籤會保留。',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('確認成年並套用'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _removeAdultPosePackageTags();
      _personTagIds(anchor).addAll(personTags.map((tag) => tag.id));
      _selectedIds.addAll(frameTags.map((tag) => tag.id));
      _persist();
    });
  }

  Widget _adultPosePackagePanel() {
    final packages = _matchingAdultPosePackages();
    final selected = _selectedAdultPosePackageTags();
    const tone = Color(0xffe8792e);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          tone.withValues(alpha: .12),
          Theme.of(context).colorScheme.surface,
        ),
        border: Border.all(color: tone.withValues(alpha: .72)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_outlined, color: tone),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '成人姿勢套件（限成年角色）',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              if (selected.isNotEmpty)
                TextButton.icon(
                  onPressed: _clearAdultPosePackageTags,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('清除套件'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '目前：${_peopleZhNew()}。選擇套件會一次加入行為、體位、基本姿勢與鏡頭；更換套件時會替換其他套件標籤。',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (packages.isEmpty)
            const Text('目前人物組成尚無預設套件；仍可在下方逐項選擇成人姿勢與行為。')
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 3
                    : constraints.maxWidth >= 560
                        ? 2
                        : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 8) / columns;
                final grouped = <String, List<_AdultPosePackage>>{};
                for (final package in packages) {
                  grouped
                      .putIfAbsent(
                          package.category, () => <_AdultPosePackage>[])
                      .add(package);
                }
                Widget packageCard(_AdultPosePackage package) {
                  final inProgressActive = _adultPosePackageIsSelected(
                    package,
                    endPose: false,
                  );
                  final endPoseActive = package.supportsEndPose &&
                      _adultPosePackageIsSelected(package, endPose: true);
                  final english = [
                    '性愛中：${[
                      ...package.personTags,
                      ...package.frameTags
                    ].join(', ')}',
                    if (package.supportsEndPose)
                      '性愛結束（${package.endMovementZh}）：${[
                        ...package.personTagsFor(endPose: true),
                        ...package.frameTags
                      ].join(', ')}',
                  ].join('\n');

                  Widget phaseButton({
                    required bool endPose,
                    required bool active,
                  }) {
                    final label = endPose ? '性愛結束姿勢' : '性愛中姿勢';
                    return Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          backgroundColor: active
                              ? tone
                              : Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                          foregroundColor: active
                              ? Colors.white
                              : Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                        ),
                        onPressed: () {
                          if (active) {
                            unawaited(_clearAdultPosePackageTags());
                          } else {
                            unawaited(_applyAdultPosePackage(
                              package,
                              endPose: endPose,
                            ));
                          }
                        },
                        icon: Icon(
                          active
                              ? Icons.check_circle
                              : endPose
                                  ? Icons.vertical_align_top
                                  : Icons.play_circle_outline,
                          size: 17,
                        ),
                        label: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    width: width,
                    child: Tooltip(
                      message: english,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (inProgressActive || endPoseActive)
                              ? tone.withOpacity(.15)
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(.46),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (inProgressActive || endPoseActive)
                                ? tone
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  inProgressActive || endPoseActive
                                      ? Icons.check_circle
                                      : Icons.auto_awesome_outlined,
                                  color: tone,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    package.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              package.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11),
                            ),
                            if (package.supportsEndPose)
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  '結束動作：${package.endMovementZh}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: tone,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 9),
                            Row(
                              children: [
                                phaseButton(
                                  endPose: false,
                                  active: inProgressActive,
                                ),
                                if (package.supportsEndPose) ...[
                                  const SizedBox(width: 7),
                                  phaseButton(
                                    endPose: true,
                                    active: endPoseActive,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: grouped.entries.map((entry) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        key: PageStorageKey<String>(
                          'adult-pose-package-${entry.key}',
                        ),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                        childrenPadding: const EdgeInsets.only(bottom: 10),
                        title: Text(
                          '${entry.key}（${entry.value.length}）',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: const Text(
                          '點一下展開姿勢套件',
                          style: TextStyle(fontSize: 11),
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: entry.value.map(packageCard).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  List<TagItem> _promptPackageTags(PromptPackageData package) {
    final seen = <String>{};
    return package.tags
        .map(_tagByEnglish)
        .whereType<TagItem>()
        .where((tag) => seen.add(tag.id))
        .toList();
  }

  bool _hasPoseExtraPrompt(String value, String prompt) {
    final target = _cleanTag(prompt).toLowerCase();
    if (target.isEmpty) return true;
    return _poseExtraPrompts(value)
        .any((item) => _cleanTag(item).toLowerCase() == target);
  }

  String _addPoseExtraPrompt(String value, String prompt) {
    final cleaned = _cleanTag(prompt);
    if (cleaned.isEmpty || _hasPoseExtraPrompt(value, cleaned)) return value;
    return [..._poseExtraPrompts(value), cleaned].join('\n');
  }

  String _removePoseExtraPrompt(String value, String prompt) {
    final target = _cleanTag(prompt).toLowerCase();
    if (target.isEmpty) return value;
    return _poseExtraPrompts(value)
        .where((item) => _cleanTag(item).toLowerCase() != target)
        .join('\n');
  }

  bool _promptPackageIsSelected(PromptPackageData package, int personIndex) {
    final tags = _promptPackageTags(package);
    final hasTags = tags.isNotEmpty;
    final natural = package.naturalPrompt.trim();
    final hasNatural = natural.isNotEmpty;
    if (!hasTags && !hasNatural) return false;
    return (!hasTags ||
            _personTagIds(personIndex)
                .containsAll(tags.map((tag) => tag.id))) &&
        (!hasNatural ||
            _hasPoseExtraPrompt(
                _personSlots[personIndex].poseExtraPositive, natural));
  }

  void _removePromptPackage(PromptPackageData package, int personIndex) {
    final tagIds = _promptPackageTags(package).map((tag) => tag.id);
    setState(() {
      _personTagIds(personIndex).removeAll(tagIds);
      final updated = _removePoseExtraPrompt(
        _personSlots[personIndex].poseExtraPositive,
        package.naturalPrompt,
      );
      _personSlots[personIndex].poseExtraPositive = updated;
      _personSearchControllers['$personIndex:pose-extra-positive']?.text =
          updated;
      _collectUnknownExtraPositiveTags();
      _persist();
    });
  }

  void _applyPromptPackage(PromptPackageData package, int personIndex) {
    final tags = _promptPackageTags(package);
    setState(() {
      _personTagIds(personIndex).addAll(tags.map((tag) => tag.id));
      final updated = _addPoseExtraPrompt(
        _personSlots[personIndex].poseExtraPositive,
        package.naturalPrompt,
      );
      _personSlots[personIndex].poseExtraPositive = updated;
      _personSearchControllers['$personIndex:pose-extra-positive']?.text =
          updated;
      _collectUnknownExtraPositiveTags();
      _persist();
    });
  }

  Widget _promptPackagePanel({
    required int personIndex,
    required String panelId,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color tone,
    required List<PromptPackageData> packages,
  }) {
    final categories =
        packages.map((package) => package.category).toSet().toList();
    final stateKey = 'quick-package:$panelId:$personIndex';
    final stored = _personActiveGroups[stateKey];
    final activeCategory = stored != null && categories.contains(stored)
        ? stored
        : categories.first;
    final visible = packages
        .where((package) => package.category == activeCategory)
        .toList();
    return Card(
      margin: const EdgeInsets.only(top: 10),
      color: tone.withOpacity(.08),
      child: ExpansionTile(
        key: PageStorageKey<String>('quick-package-$panelId-$personIndex'),
        leading: Icon(icon, color: tone),
        title: Text('$title（${packages.length} 組）',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: categories.map((category) {
                final selected = category == activeCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  selectedColor: tone,
                  labelStyle: TextStyle(
                    color: selected ? const Color(0xff171326) : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => setState(
                    () => _personActiveGroups[stateKey] = category,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 560
                      ? 2
                      : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 8) / columns;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: visible.map((package) {
                  final applied =
                      _promptPackageIsSelected(package, personIndex);
                  final english = package.naturalPrompt.trim().isEmpty
                      ? package.tags.join(', ')
                      : package.naturalPrompt;
                  return SizedBox(
                    width: width,
                    child: Tooltip(
                      message: english,
                      child: ChoiceChip(
                        selected: applied,
                        selectedColor: tone,
                        avatar: Icon(
                          applied
                              ? Icons.check_circle
                              : Icons.auto_awesome_outlined,
                          size: 18,
                          color: applied ? const Color(0xff171326) : tone,
                        ),
                        label: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(package.name,
                                  style: TextStyle(
                                    color: applied
                                        ? const Color(0xff171326)
                                        : Colors.white,
                                    fontWeight: FontWeight.w800,
                                  )),
                              const SizedBox(height: 2),
                              Text(
                                package.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: applied
                                      ? const Color(0xff171326)
                                      : Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        labelPadding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 7),
                        onSelected: (selected) {
                          if (selected) {
                            _applyPromptPackage(package, personIndex);
                          } else {
                            _removePromptPackage(package, personIndex);
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _sharedPromptPackageIsSelected(PromptPackageData package) {
    final tags = _promptPackageTags(package);
    final hasTags = tags.isNotEmpty;
    final natural = package.naturalPrompt.trim();
    final hasNatural = natural.isNotEmpty;
    if (!hasTags && !hasNatural) return false;
    return (!hasTags || _selectedIds.containsAll(tags.map((tag) => tag.id))) &&
        (!hasNatural || _hasPoseExtraPrompt(_sharedPoseExtra.text, natural));
  }

  void _applySharedPromptPackage(PromptPackageData package) {
    final tags = _promptPackageTags(package);
    setState(() {
      _selectedIds.addAll(tags.map((tag) => tag.id));
      _sharedPoseExtra.text =
          _addPoseExtraPrompt(_sharedPoseExtra.text, package.naturalPrompt);
      _collectUnknownExtraPositiveTags();
      _persist();
    });
  }

  void _removeSharedPromptPackage(PromptPackageData package) {
    setState(() {
      _selectedIds.removeAll(_promptPackageTags(package).map((tag) => tag.id));
      _sharedPoseExtra.text = _removePoseExtraPrompt(
        _sharedPoseExtra.text,
        package.naturalPrompt,
      );
      _collectUnknownExtraPositiveTags();
      _persist();
    });
  }

  Widget _sharedFelineInteractionPackagePanel() {
    const tone = Color(0xfffbbf24);
    final packages = felineInteractionPackages;
    final categories =
        packages.map((package) => package.category).toSet().toList();
    const stateKey = 'shared-feline-interaction-package';
    final stored = _personActiveGroups[stateKey];
    final activeCategory = stored != null && categories.contains(stored)
        ? stored
        : categories.first;
    final visible = packages
        .where((package) => package.category == activeCategory)
        .toList();
    return Card(
      margin: const EdgeInsets.only(top: 10),
      color: tone.withOpacity(.08),
      child: ExpansionTile(
        key: const PageStorageKey<String>('shared-feline-interaction-package'),
        leading: const Icon(Icons.pets_outlined, color: tone),
        title: Text('貓咪多人互動套件（${packages.length} 組）',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: const Text('16 組抱持、依偎與撒嬌互動；套用後仍可個別調整。',
            style: TextStyle(fontSize: 12)),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: categories.map((category) {
                final selected = category == activeCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  selectedColor: tone,
                  labelStyle: TextStyle(
                    color: selected ? const Color(0xff171326) : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => setState(
                    () => _personActiveGroups[stateKey] = category,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 560
                      ? 2
                      : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 8) / columns;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: visible.map((package) {
                  final applied = _sharedPromptPackageIsSelected(package);
                  return SizedBox(
                    width: width,
                    child: Tooltip(
                      message: package.naturalPrompt.trim().isEmpty
                          ? package.tags.join(', ')
                          : package.naturalPrompt,
                      child: ChoiceChip(
                        selected: applied,
                        selectedColor: tone,
                        avatar: Icon(
                          applied
                              ? Icons.check_circle
                              : Icons.auto_awesome_outlined,
                          size: 18,
                          color: applied ? const Color(0xff171326) : tone,
                        ),
                        label: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(package.name,
                                  style: TextStyle(
                                    color: applied
                                        ? const Color(0xff171326)
                                        : Colors.white,
                                    fontWeight: FontWeight.w800,
                                  )),
                              const SizedBox(height: 2),
                              Text(
                                package.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: applied
                                      ? const Color(0xff171326)
                                      : Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        labelPadding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 7),
                        onSelected: (selected) {
                          if (selected) {
                            _applySharedPromptPackage(package);
                          } else {
                            _removeSharedPromptPackage(package);
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const Divider(height: 24),
          TextField(
            controller: _sharedPoseExtra,
            minLines: 2,
            maxLines: 4,
            onChanged: _updateSharedPoseExtra,
            decoration: const InputDecoration(
              labelText: '共用自然敘述動作',
              hintText: '例如：walking together while playfully holding hands',
              helperText: '套用於所有人物後方的共用動作；可直接輸入未收錄的英文自然敘述。',
              prefixIcon: Icon(Icons.groups_outlined),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sharedActionPicker() {
    final groups = _sharedActionPickerGroups
        .where((group) => (_tagsByGroup[group] ?? const <TagItem>[]).isNotEmpty)
        .toList();
    if (_personSlots.length < 2 || groups.isEmpty) {
      return const SizedBox.shrink();
    }
    final selected =
        _selectedTags.where((tag) => _isSharedActionGroup(tag.group)).toList();
    final sharedActionIds = _allTags
        .where((tag) => _isSharedActionGroup(tag.group))
        .map((tag) => tag.id)
        .toSet();
    return Card(
      margin: const EdgeInsets.only(top: 10),
      color: const Color(0xfff97316).withOpacity(.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.groups_outlined, color: Color(0xfffb923c)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '多人共同動作',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: '清除多人共同動作',
                  onPressed: selected.isEmpty
                      ? null
                      : () => setState(() {
                            _selectedIds.removeWhere(sharedActionIds.contains);
                            _persist();
                          }),
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '這裡設定角色一起進行的互動、親吻或成人姿勢；輸出會放在所有角色資訊之後，不使用括號與角色權重。',
              style: TextStyle(fontSize: 12),
            ),
            _sharedFelineInteractionPackagePanel(),
            const SizedBox(height: 10),
            _stepTagPicker(
              groups,
              nextLabel: '',
              showNext: false,
              searchGroups: groups,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepCategorizedPersonTagPicker(
    Map<String, List<String>> sections, {
    required String nextLabel,
    required String instruction,
  }) {
    final sectionNames = sections.keys.toList();
    if (sectionNames.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(instruction),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _showAdult,
          title: const Text('顯示 18+ 分類'),
          subtitle: const Text('成人姿勢、情趣服飾與成人道具預設隱藏。'),
          onChanged: (value) => setState(() {
            _showAdult = value;
            _persist();
          }),
        ),
        const SizedBox(height: 8),
        if (_showAdult) _adultPosePackagePanel(),
        ..._personSlots.asMap().entries.map((entry) {
          final index = entry.key;
          final slot = entry.value;
          final characterNames = _characterChineseForSlot(slot, index);
          final title =
              characterNames.isEmpty ? '人物 ${index + 1}' : characterNames.first;
          if (!slot.detailed) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('人物 ${index + 1}'),
                subtitle: const Text('此人物設定為不需細節，不加入此類標籤。'),
              ),
            );
          }

          final sectionKey = 'expanded-section:$index';
          final storedSection = _personActiveGroups[sectionKey];
          final currentSection =
              storedSection != null && sections.containsKey(storedSection)
                  ? storedSection
                  : sectionNames.first;
          final currentGroups = sections[currentSection]!;
          int selectedCountForPickerGroup(String pickerGroup) =>
              _selectedTagsForPerson(index)
                  .where((tag) =>
                      (tag.group == pickerGroup &&
                          !(pickerGroup == '動作' &&
                              _isObjectInteractionTag(tag))) ||
                      _objectPickerGroupForTag(tag) == pickerGroup ||
                      (pickerGroup == _staticFaceAppearanceGroup &&
                          _isStaticFaceAppearanceTag(tag)) ||
                      (pickerGroup == _objectInteractionGroup &&
                          _isObjectInteractionTag(tag)) ||
                      (_isExpressionPickerGroup(pickerGroup) &&
                          _expressionSubgroupForTag(tag) == pickerGroup))
                  .length;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(.28),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(child: Text('${index + 1}')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '人物 ${index + 1} · $title',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        tooltip: '隨機目前分類（自動避開衝突）',
                        onPressed: () =>
                            _randomizePersonGroups(index, currentGroups),
                        icon: const Icon(Icons.shuffle),
                      ),
                    ],
                  ),
                  _promptPackagePanel(
                    personIndex: index,
                    panelId: 'pose',
                    title: '一般姿勢套裝',
                    subtitle: '非露骨單人姿勢；每一類提供 10 組可直接套用。',
                    icon: Icons.accessibility_new,
                    tone: const Color(0xff38bdf8),
                    packages: generalPosePackages,
                  ),
                  _promptPackagePanel(
                    personIndex: index,
                    panelId: 'sexy-pose',
                    title: '性感姿勢套裝',
                    subtitle: '非露骨的姿勢、肢體線條與表情搭配；共 100 套，可套用後個別調整。',
                    icon: Icons.auto_awesome_outlined,
                    tone: const Color(0xfff472b6),
                    packages: sexyPosePackages,
                  ),
                  _promptPackagePanel(
                    personIndex: index,
                    panelId: 'feline-solo-pose',
                    title: '貓咪單人姿勢套件',
                    subtitle: '15 組貓系玩耍、休息、撒嬌與警覺姿態；不會自動加入獸耳、獸尾或 furry。',
                    icon: Icons.pets_outlined,
                    tone: const Color(0xfffbbf24),
                    packages: felineSoloPosePackages,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '姿勢大分類',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 7),
                  LayoutBuilder(
                    builder: (context, constraints) => Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: sectionNames.map((section) {
                        final selected = section == currentSection;
                        final sectionGroups =
                            sections[section] ?? const <String>[];
                        final tone = _pickerLayerTone(sectionGroups.first);
                        final selectedCount = sectionGroups.fold<int>(
                          0,
                          (total, group) =>
                              total + selectedCountForPickerGroup(group),
                        );
                        final width = _wizardGroupChipWidth(
                              section,
                              constraints.maxWidth,
                            ) +
                            (selectedCount > 0 ? 30 : 0);
                        return ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: constraints.maxWidth),
                          child: SizedBox(
                            width: min(width, constraints.maxWidth),
                            child: ChoiceChip(
                              label: Text(
                                selectedCount == 0
                                    ? section
                                    : '$section  $selectedCount',
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  color: _pickerLayerText(tone,
                                      selected: selected),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              selected: selected,
                              backgroundColor:
                                  _pickerLayerSurface(tone, selected: false),
                              selectedColor:
                                  _pickerLayerSurface(tone, selected: true),
                              side: BorderSide(
                                color: selected ? tone : tone.withOpacity(.72),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              onSelected: (_) => setState(() {
                                _personActiveGroups[sectionKey] = section;
                                _personTagQueries[index] = '';
                              }),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _stepTagPicker(
                    currentGroups,
                    nextLabel: nextLabel,
                    personIndex: index,
                    showNext: false,
                    showGroupClear: true,
                    searchGroups: sections.values
                        .expand((groups) => groups)
                        .toSet()
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _personSearchController(
                      index,
                      'pose-extra-positive',
                      slot.poseExtraPositive,
                    ),
                    minLines: 2,
                    maxLines: 4,
                    onChanged: (value) => _updatePersonPoseExtra(index, value),
                    decoration: const InputDecoration(
                      labelText: '自行加入姿勢正向標籤／自然敘述',
                      hintText:
                          '例如：swinging a sword in a wide arc while stepping forward',
                      helperText: '內容只套用到此人物；每行或句點分隔一段。英文會原樣保留，中文會依內建對照轉成英文。',
                      prefixIcon: Icon(Icons.edit_note_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (_personSlots.length > 1) ...[
          const SizedBox(height: 10),
          _sharedActionPicker(),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _advanceStep,
            icon: const Icon(Icons.arrow_forward),
            label: Text(nextLabel),
          ),
        ),
      ],
    );
  }

  String _activePersonPickerGroup(int personIndex, List<String> groups) {
    if (groups.isEmpty) return '';
    final key = '$personIndex:${groups.join('|')}';
    final stored = _personActiveGroups[key];
    return stored != null && groups.contains(stored) ? stored : groups.first;
  }

  String _activeClothingPickerGroup(int personIndex, List<String> groups) {
    final active = _activePersonPickerGroup(personIndex, groups);
    if (_clothingBasesForActiveGroup(personIndex, active).isNotEmpty) {
      return active;
    }
    for (final group in groups) {
      if (_clothingBasesForActiveGroup(personIndex, group).isNotEmpty) {
        return group;
      }
    }
    return active;
  }

  List<TagItem> _clothingBasesForActiveGroup(
      int personIndex, String? activeGroup) {
    final bases = _clothingDesignBases(_selectedTagsForPerson(personIndex));
    if (activeGroup == null || activeGroup.isEmpty) return bases;
    final activeScope = switch (activeGroup) {
      '服裝' => 'onepiece',
      '上衣' => 'top',
      '褲子' => 'pants',
      '短褲' => 'shorts',
      '裙子' => 'skirt',
      '外套' => 'outerwear',
      '特殊服裝' => 'costume',
      '內衣' => 'underwear',
      '胸罩' => 'bra',
      '內褲' => 'panties',
      '襪子' => 'socks',
      '鞋子' => 'shoes',
      '配件' => 'accessory',
      _clothingGroupHat ||
      _clothingGroupHeadAccessory ||
      _clothingGroupHairAccessory ||
      _clothingGroupEyewear ||
      _clothingGroupFaceAccessory ||
      _clothingGroupAnimalAccessory ||
      _clothingGroupNeckAccessory ||
      _clothingGroupHandAccessory ||
      _clothingGroupWaistAccessory ||
      _clothingGroupOtherAccessory =>
        'accessory',
      _ => null,
    };
    final virtualAccessory =
        _clothingAccessoryPickerGroups.contains(activeGroup);
    return bases.where((base) {
      if (virtualAccessory) {
        return _clothingBaseDisplayGroup(base) == _clothingGroupAccessory &&
            _clothingAccessoryPickerGroup(base) == activeGroup;
      }
      return _clothingBaseDisplayGroup(base) == activeGroup ||
          (activeScope != null && _clothingScopeForBase(base) == activeScope);
    }).toList();
  }

  List<String> _clothingDetailGroups(int personIndex, {String? activeGroup}) {
    final bases = _clothingBasesForActiveGroup(personIndex, activeGroup);
    final selected = _selectedTagsForPerson(personIndex);
    return bases
        .expand(_clothingDetailGroupsForBase)
        .toSet()
        .where((group) {
          if (_scopedClothingKind(group) != 'detail_color') return true;
          final scope = _scopedClothingSlot(group);
          return selected.any((tag) =>
              tag.group == _scopedClothingGroup(scope ?? '', 'detail'));
        })
        .where((group) => (_tagsByGroup[group] ?? const <TagItem>[]).isNotEmpty)
        .toList();
  }

  List<String> _clothingWearGroups(int personIndex, {String? activeGroup}) {
    final bases = _clothingBasesForActiveGroup(personIndex, activeGroup);
    if (bases.isEmpty) return const <String>[];
    return <String>[
      _legacyClothingWearGroup,
      ...bases.expand(_clothingWearGroupsForBase).toSet(),
    ]
        .where((group) => (_tagsByGroup[group] ?? const <TagItem>[]).isNotEmpty)
        .toList();
  }

  // ignore: unused_element
  List<String> _legacyClothingDetailGroups(int personIndex) {
    final selected = _selectedTagsForPerson(personIndex);
    bool has(String group) => selected.any((tag) => tag.group == group);
    final onePiece =
        selected.any((tag) => ['服裝', _cosplayGroup].contains(tag.group));
    final groups = <String>['服裝細節', '服裝材質', '穿脫狀態'];
    if (has('服裝細節') || has('服裝材質')) {
      groups.insert(0, '服裝細節顏色');
    }
    if (onePiece) {
      groups.insertAll(0, [
        _cosplayGroup,
        '服裝顏色',
        '服裝邊線色',
      ]);
    } else {
      if (has('上衣')) {
        groups.insertAll(0, ['上衣風格', '上衣顏色', '上衣邊線色']);
      }
      if (has('褲子') || has('裙子')) {
        groups.insertAll(0, ['下身風格', '下身顏色', '下身邊線色']);
      }
    }
    if (has('內衣')) groups.insertAll(0, ['內衣顏色', '內衣邊線色']);
    if (has('胸罩')) groups.insertAll(0, ['胸罩顏色', '胸罩邊線色']);
    if (has('內褲')) groups.insertAll(0, ['內褲顏色', '內褲邊線色']);
    if (has('襪子')) groups.insertAll(0, ['襪子顏色', '襪子邊線色']);
    if (has('鞋子')) groups.insertAll(0, ['鞋子顏色', '鞋子邊線色']);
    if (has('配件')) {
      groups.insertAll(0, ['配件顏色', '配件邊線色', '配件位置']);
    }
    return groups.toSet().toList();
  }

  Widget _pickerStage({
    required IconData icon,
    required String title,
    required String description,
    required Color tone,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          tone.withOpacity(.08),
          Theme.of(context).colorScheme.surface.withOpacity(.78),
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withOpacity(.62)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tone,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: _pickerLayerText(tone, selected: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _clothingLayerLegend() {
    const layers = <(String, Color)>[
      ('官方精準', Color(0xff4ade80)),
      ('描述補充', Color(0xfffbbf24)),
      ('衣種', Color(0xffffb454)),
      ('剪裁', Color(0xff60a5fa)),
      ('版型', Color(0xff2dd4bf)),
      ('長度', Color(0xff38bdf8)),
      ('材質', Color(0xffc084fc)),
      ('裝飾', Color(0xfff472b6)),
      ('圖案', Color(0xfffb923c)),
      ('顏色', Color(0xff818cf8)),
      ('整體描述', Color(0xffa78bfa)),
      ('穿脫', Color(0xfff87171)),
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: layers
          .map(
            (layer) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: _pickerLayerSurface(layer.$2, selected: false),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: layer.$2.withOpacity(.75)),
              ),
              child: Text(
                layer.$1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _clothingCompatibilityStatus(int personIndex, String activeGroup) {
    final bases = _clothingBasesForActiveGroup(personIndex, activeGroup);
    if (bases.isEmpty) return const SizedBox.shrink();
    final scope = _clothingScopeForBase(bases.first);
    if (scope == null) return const SizedBox.shrink();
    final selected = _selectedTagsForPerson(personIndex);
    int count(String kind) => selected
        .where((tag) => tag.group == _scopedClothingGroup(scope, kind))
        .length;
    final unusual = count('fit') > 1 ||
        count('length') > 1 ||
        count('cut') > 2 ||
        count('material') > 2 ||
        count('pattern') > 2;
    final configured = const [
      'cut',
      'fit',
      'length',
      'material',
      'detail',
      'pattern'
    ].any((kind) => count(kind) > 0);
    final tone = unusual
        ? const Color(0xfffbbf24)
        : configured
            ? const Color(0xff4ade80)
            : const Color(0xff60a5fa);
    final label = unusual
        ? '少見搭配（仍允許）'
        : configured
            ? '可搭配'
            : '基本組合';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: _pickerLayerSurface(tone, selected: false),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.withOpacity(.7)),
      ),
      child: Row(
        children: [
          Icon(unusual ? Icons.info_outline : Icons.check_circle_outline,
              size: 18, color: tone),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label：相容性只提供提醒，不會限制或移除你的選擇。',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _outfitReferenceTone(String category) => switch (category) {
        '藍色系列' => const Color(0xff38bdf8),
        '日常／正式' => const Color(0xff38bdf8),
        '優雅／正式' => const Color(0xffa78bfa),
        '甜美／浪漫' => const Color(0xfff472b6),
        '街頭／運動' => const Color(0xfffb923c),
        '奇幻／特色' => const Color(0xff818cf8),
        _ => const Color(0xff94a3b8),
      };

  Widget _outfitReferencePicker(int personIndex) {
    final categories = outfitReferencePresets
        .map((preset) => preset.category)
        .toSet()
        .toList();
    final stateKey = 'outfit-reference:$personIndex';
    final stored = _personActiveGroups[stateKey];
    final activeCategory = stored != null && categories.contains(stored)
        ? stored
        : categories.first;
    final visible = outfitReferencePresets
        .where((preset) => preset.category == activeCategory)
        .toList();
    final tone = _outfitReferenceTone(activeCategory);

    return Card(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      clipBehavior: Clip.antiAlias,
      color: tone.withOpacity(.08),
      child: ExpansionTile(
        key: PageStorageKey<String>('outfit-reference-$personIndex'),
        leading: Icon(Icons.auto_awesome, color: tone),
        title: Text(
          '女子服裝靈感套裝（${outfitReferencePresets.length} 套）',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: const Text('套用為一次性副本；之後可改顏色、款式與細節，原始模板不會變更'),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final selected = category == activeCategory;
                final categoryTone = _outfitReferenceTone(category);
                return ChoiceChip(
                  avatar: Icon(
                    selected ? Icons.check_circle : Icons.checkroom_outlined,
                    size: 18,
                    color: selected ? const Color(0xff171326) : categoryTone,
                  ),
                  label: Text(category),
                  selected: selected,
                  selectedColor: categoryTone,
                  labelStyle: TextStyle(
                    color: selected ? const Color(0xff171326) : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) {
                    setState(() => _personActiveGroups[stateKey] = category);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              final cardWidth = compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: visible.map((preset) {
                  final resolution = _resolveOutfitReference(preset);
                  final applied = _personCombinationIds[personIndex]
                          ?.contains(preset.combinationId) ==
                      true;
                  return SizedBox(
                    width: cardWidth,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: applied
                            ? tone.withOpacity(.24)
                            : Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(.38),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: applied ? tone : tone.withOpacity(.48),
                          width: applied ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  preset.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15),
                                ),
                              ),
                              if (applied)
                                Icon(Icons.check_circle, color: tone, size: 20),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            preset.palette,
                            style: TextStyle(
                              color: tone,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(preset.description),
                          if (resolution.missing.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '缺少 ${resolution.missing.length} 個設定',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _showOutfitReferencePreview(
                                    preset, personIndex),
                                icon: const Icon(Icons.visibility_outlined,
                                    size: 18),
                                label: const Text('預覽'),
                              ),
                              FilledButton.icon(
                                onPressed: resolution.missing.isEmpty
                                    ? () => _applyOutfitReference(
                                        preset, personIndex)
                                    : null,
                                icon: Icon(
                                  applied
                                      ? Icons.check
                                      : Icons.checkroom_outlined,
                                  size: 18,
                                ),
                                label: Text(applied ? '已套用・可修改' : '套用'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _stepClothing() {
    const garmentGroups = _clothingGarmentPickerGroups;
    const overallGroups = [
      _outfitMainStyleGroup,
      _outfitSubStyleGroup,
      _outfitMoodGroup,
      _outfitOccasionGroup,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            '服裝依頭部到腳部排列；先選衣種，再控制該部位可用的剪裁、版型、長度、材質、裝飾、圖案與顏色。色彩依點選順序使用色 1／色 2；主體衣種與同一色彩欄位維持替換。官方標籤會優先輸出，描述詞則保留作進階補充。'),
        const SizedBox(height: 8),
        _clothingLayerLegend(),
        const SizedBox(height: 12),
        ..._personSlots.asMap().entries.map((entry) {
          final index = entry.key;
          final slot = entry.value;
          final characterNames = _characterChineseForSlot(slot, index);
          final activeClothingGroup =
              _activeClothingPickerGroup(index, garmentGroups);
          final adaptiveDetails =
              _clothingDetailGroups(index, activeGroup: activeClothingGroup);
          final activeClothingBases =
              _clothingBasesForActiveGroup(index, activeClothingGroup);
          final colorPairBases = <TagItem>[];
          final colorPairGroups = <String>{};
          for (final base in activeClothingBases) {
            final mainGroup = _clothingColorGroupForBase(base);
            final secondaryGroup = _clothingTrimColorGroupForBase(base);
            if (mainGroup == null || secondaryGroup == null) continue;
            final key = '$mainGroup|$secondaryGroup';
            if (colorPairGroups.add(key)) colorPairBases.add(base);
          }
          final colorGroups =
              colorPairGroups.expand((key) => key.split('|')).toSet();
          final nonColorAdaptiveDetails = adaptiveDetails
              .where((group) => !colorGroups.contains(group))
              .toList();
          final adaptiveWear = _clothingWearGroups(index);
          final activeClothingLabel = _wizardGroupLabel(activeClothingGroup);
          final title =
              characterNames.isEmpty ? '人物 ${index + 1}' : characterNames.first;
          if (!slot.detailed) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('人物 ${index + 1}'),
                subtitle: const Text('此人物設定為不需細節，不加入服裝標籤。'),
              ),
            );
          }
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(.28),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(child: Text('${index + 1}')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('人物 ${index + 1} · $title',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        tooltip: '隨機服裝穿搭（自動避開衝突）',
                        onPressed: () => _randomizeClothing(index),
                        icon: const Icon(Icons.shuffle),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _saveClothingCombinationFromPerson(index),
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: const Text('\u52A0\u5165\u7D44\u5408\u6A19\u7C64'),
                    ),
                  ),
                  _outfitReferencePicker(index),
                  _pickerStage(
                    icon: Icons.checkroom_outlined,
                    tone: const Color(0xffffb454),
                    title: '1. 選擇服裝部位與款式',
                    description: '依頭到腳切換部位；切換只隱藏其他部位，已選標籤仍會保留。',
                    child: _stepTagPicker(
                      garmentGroups,
                      nextLabel: '下一步',
                      personIndex: index,
                      showNext: false,
                      showGroupClear: true,
                    ),
                  ),
                  if (adaptiveDetails.isNotEmpty)
                    _pickerStage(
                      icon: Icons.palette_outlined,
                      tone: const Color(0xff60a5fa),
                      title: '2. $activeClothingLabel：多維度設計',
                      description:
                          '色 1／色 2 直接依序選取，分別輸出主色與次色；所有色調均可直接選，不再依既選色系隱藏。風格、剪裁、版型、長度、材質、細節與圖案可多選。',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...colorPairBases.map((base) =>
                              _clothingColorPairControl(index, [base])),
                          if (colorPairBases.isNotEmpty &&
                              nonColorAdaptiveDetails.isNotEmpty)
                            const SizedBox(height: 12),
                          if (nonColorAdaptiveDetails.isNotEmpty)
                            _stepTagPicker(
                              nonColorAdaptiveDetails,
                              nextLabel: '下一步',
                              personIndex: index,
                              showNext: false,
                              showGroupClear: true,
                              pickerStateKey:
                                  'clothing-details:$activeClothingGroup',
                            ),
                        ],
                      ),
                    ),
                  _clothingCompatibilityStatus(index, activeClothingGroup),
                  _pickerStage(
                    icon: Icons.auto_awesome_outlined,
                    tone: const Color(0xffa78bfa),
                    title: '3. 整體風格、氣質與場合',
                    description: '這些描述作用於整套穿搭，不會取代上方已選的服裝種類與細節。',
                    child: _stepTagPicker(
                      overallGroups,
                      nextLabel: '下一步',
                      personIndex: index,
                      showNext: false,
                      showGroupClear: true,
                    ),
                  ),
                  if (adaptiveWear.isNotEmpty)
                    _pickerStage(
                      icon: Icons.dry_cleaning_outlined,
                      tone: const Color(0xfff87171),
                      title: '4. 各部位穿脫狀態',
                      description: '依已選服裝顯示各部位專用狀態；上衣、下身、連身裝、內搭、襪子、鞋子與配件可分別設定。',
                      child: _stepTagPicker(
                        adaptiveWear,
                        nextLabel: '下一步',
                        personIndex: index,
                        showNext: false,
                        showGroupClear: true,
                        pickerStateKey: 'clothing-wear:$activeClothingGroup',
                      ),
                    ),
                  if (adaptiveDetails.isEmpty && adaptiveWear.isEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('請先在上方目前部位選擇一件服裝，再設定其顏色、細節與穿脫狀態。'),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _advanceStep,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('下一步：表情'),
          ),
        ),
      ],
    );
  }

  GlobalKey _stepKey(int index) =>
      _stepKeys.putIfAbsent(index, () => GlobalKey(debugLabel: 'step-$index'));

  Future<void> _scrollToStep(int index) async {
    final ticket = ++_stepScrollTicket;
    // Wait for the selected card to expand and for an unfocused text field to
    // finish changing the mobile viewport height before measuring its header.
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(Duration.zero);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || ticket != _stepScrollTicket) return;
    await _ensureScrollRoomForTop(_stepKey(index));
    if (!mounted || ticket != _stepScrollTicket) return;
    await _scrollKeyToTop(
      _stepKey(index),
      duration: const Duration(milliseconds: 360),
    );
    if (!mounted || ticket != _stepScrollTicket) return;

    // Closing the on-screen keyboard can finish after the first scroll. Make
    // one final alignment pass so the selected step title stays at the top.
    await Future<void>.delayed(const Duration(milliseconds: 260));
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || ticket != _stepScrollTicket) return;
    await _ensureScrollRoomForTop(_stepKey(index));
    if (!mounted || ticket != _stepScrollTicket) return;
    await _scrollKeyToTop(
      _stepKey(index),
      duration: const Duration(milliseconds: 1),
    );
  }

  void _scrollToOutput() {
    final ticket = ++_stepScrollTicket;
    setState(() => _pageBottomPadding = _basePageBottomPadding);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_scrollToOutputAfterLayout(ticket));
    });
  }

  Future<void> _scrollToOutputAfterLayout(int ticket) async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || ticket != _stepScrollTicket) return;
    await _ensureScrollRoomForTop(_outputKey);
    if (!mounted || ticket != _stepScrollTicket) return;
    await _scrollKeyToTop(
      _outputKey,
      duration: const Duration(milliseconds: 280),
    );
  }

  double? _unclampedScrollDestination(GlobalKey targetKey) {
    if (!_pageScrollController.hasClients) return null;
    final targetContext = targetKey.currentContext;
    final scrollContext = _pageScrollKey.currentContext;
    final targetBox = targetContext?.findRenderObject();
    final scrollBox = scrollContext?.findRenderObject();
    if (targetBox is! RenderBox || scrollBox is! RenderBox) return null;
    return _pageScrollController.position.pixels +
        targetBox.localToGlobal(Offset.zero).dy -
        scrollBox.localToGlobal(Offset.zero).dy;
  }

  Future<void> _ensureScrollRoomForTop(GlobalKey targetKey) async {
    final wanted = _unclampedScrollDestination(targetKey);
    if (wanted == null || !_pageScrollController.hasClients) return;
    final position = _pageScrollController.position;
    final shortfall = wanted - position.maxScrollExtent;
    if (shortfall <= 1) return;

    // Only reserve exactly the trailing space needed by the current target.
    // This lets the last cards reach the top without keeping a blank viewport
    // below the page at all times.
    setState(() {
      _pageBottomPadding = (_pageBottomPadding + shortfall).ceilToDouble();
    });
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> _scrollKeyToTop(
    GlobalKey targetKey, {
    required Duration duration,
  }) async {
    if (!_pageScrollController.hasClients) return;
    double destination() {
      final position = _pageScrollController.position;
      return (_unclampedScrollDestination(targetKey) ?? position.pixels)
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble();
    }

    await _pageScrollController.animateTo(
      destination(),
      duration: duration,
      curve: Curves.easeOutCubic,
    );
    if (!mounted || !_pageScrollController.hasClients) return;

    // A large card can change the page extent while another card collapses.
    // Recalculate after the animation so its header still lands at the top.
    final corrected = destination();
    if ((_pageScrollController.offset - corrected).abs() > 1) {
      _pageScrollController.jumpTo(corrected);
    }
  }

  void _openStep(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _stepIndex = index;
      _pageBottomPadding = _basePageBottomPadding;
      _persist();
    });
    // Expansion is committed first; _scrollToStep waits for that frame before
    // positioning the card title at the top of the viewport.
    unawaited(_scrollToStep(index));
  }

  Widget _stepHeader(int index, String title, String summary, IconData icon,
      {VoidCallback? onClear}) {
    final expanded = _stepIndex == index;
    return InkWell(
      onTap: () => _openStep(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(children: [
          CircleAvatar(radius: 15, child: Text('${index + 1}')),
          const SizedBox(width: 12),
          Icon(icon,
              size: 20,
              color: expanded
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 9),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant))
              ])),
          Icon(expanded ? Icons.expand_less : Icons.expand_more),
          if (onClear != null)
            IconButton(
              tooltip: '清除本大項標籤',
              onPressed: onClear,
              icon: const Icon(Icons.delete_outline),
            ),
        ]),
      ),
    );
  }

  Widget _stepCard(
      int index, String title, String summary, IconData icon, Widget child,
      {VoidCallback? onClear}) {
    return Card(
      key: _stepKey(index),
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        _stepHeader(index, title, summary, icon, onClear: onClear),
        if (_stepIndex == index) const Divider(height: 1),
        if (_stepIndex == index)
          Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18), child: child),
      ]),
    );
  }

  Widget _stepPeople() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('先決定畫面中有幾位角色；之後可以逐一指定女性、男性或其他/異種。',
            style: TextStyle(fontSize: 13)),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          value: _personSlots.length,
          decoration: const InputDecoration(
              labelText: '人物數量（必填）', prefixIcon: Icon(Icons.groups_outlined)),
          items: List.generate(10, (index) => index + 1)
              .map((value) =>
                  DropdownMenuItem(value: value, child: Text('$value 人')))
              .toList(),
          onChanged: (value) => _setPeopleCount(value ?? 1),
        ),
        const SizedBox(height: 12),
        Text(
          '模型、Sampler、Steps、CFG 與 Clip skip 請直接在 AI 生成網站設定；本工具只輸出可貼上的提示標籤。',
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
                onPressed: _advanceStep,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('下一步：場景'))),
      ],
    );
  }

  Widget _stepCharacters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.groups_outlined, size: 20),
            const SizedBox(width: 8),
            Text('人物資料數量：${_personSlots.length}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(
              tooltip: '減少人物',
              onPressed: _personSlots.length <= 1
                  ? null
                  : () => _setPeopleCount(_personSlots.length - 1),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            IconButton(
              tooltip: '增加人物（最多 10 人）',
              onPressed: _personSlots.length >= 10
                  ? null
                  : () => _setPeopleCount(_personSlots.length + 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
            '人物數量會依下方角色資料卡自動計算。每個人物都要選擇「動漫角色」、「原創角色」，或明確選擇「不需細節」。動漫角色會自動帶入動漫英文 tag、角色英文 tag 與角色特徵。'),
        const SizedBox(height: 12),
        ..._personSlots.asMap().entries.map((entry) {
          final index = entry.key;
          final slot = entry.value;
          final animeMatches = _matchingAnime(slot);
          final matches = _matchingCharacters(slot);
          final selectedCharacter = _characterForNew(slot);
          return Card(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(.35),
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('人物 ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      IconButton(
                        tooltip: _personSlots.length <= 1
                            ? '至少需要保留一位人物'
                            : '刪除人物 ${index + 1}',
                        visualDensity: VisualDensity.compact,
                        onPressed: _personSlots.length <= 1
                            ? null
                            : () => _removePersonAt(index),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                            width: 150,
                            child: DropdownButtonFormField<String>(
                                value: slot.gender,
                                decoration:
                                    const InputDecoration(labelText: '性別/類型'),
                                items: const ['女性', '男性', '其他/異種']
                                    .map((value) => DropdownMenuItem(
                                        value: value, child: Text(value)))
                                    .toList(),
                                onChanged: (value) => setState(() {
                                      if (value != null &&
                                          value != slot.gender) {
                                        _removeAdultPosePackageTags();
                                      }
                                      slot.gender = value ?? slot.gender;
                                      _persist();
                                    }))),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                                value: slot.detailed,
                                onChanged: (value) => setState(() {
                                      slot.detailed = value;
                                      if (value) {
                                        _syncCharacterTraitsForSlot(index);
                                      }
                                      _persist();
                                    })),
                            const Text('需要細節'),
                          ],
                        ),
                      ],
                    ),
                    if (!slot.detailed)
                      const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('此人物只輸出人數/性別 tag，不加入動漫名稱、角色名稱或特徵。')),
                    if (slot.detailed) ...[
                      const SizedBox(height: 10),
                      Wrap(
                          spacing: 8,
                          children: ['動漫角色', '原創', '不需細節']
                              .map((mode) => ChoiceChip(
                                  label: Text(mode),
                                  selected: slot.mode == mode,
                                  onSelected: (_) => setState(() {
                                        slot.mode = mode;
                                        if (mode == '不需細節')
                                          slot.detailed = false;
                                        _persist();
                                      })))
                              .toList()),
                      if (slot.mode == '動漫角色') ...[
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: TextField(
                                controller: _personSearchController(
                                    index, 'anime', slot.animeQuery),
                                decoration: const InputDecoration(
                                    labelText: '第一步：查詢動漫名稱',
                                    prefixIcon: Icon(Icons.search)),
                                onChanged: (value) =>
                                    setState(() => slot.animeQuery = value)),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: _remoteLookupLoading.contains(index)
                                ? null
                                : () => _searchRemoteAnime(index),
                            icon: const Icon(Icons.public, size: 18),
                            label: const Text('自動查詢'),
                          ),
                        ]),
                        _remoteAnimePanel(index),
                        _remoteCharacterPanel(index),
                        const SizedBox(height: 9),
                        if (animeMatches.isNotEmpty)
                          Wrap(
                              spacing: 7,
                              runSpacing: 7,
                              children: animeMatches
                                  .map((anime) => ChoiceChip(
                                      label: Text(
                                          '${anime.animeZh} · ${anime.animeEn}'),
                                      selected: slot.animeTag == anime.animeTag,
                                      onSelected: (_) =>
                                          _selectAnime(index, anime)))
                                  .toList())
                        else
                          const Text('查無動漫資料，可新增自己的動漫與角色。'),
                        if (slot.animeTag.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          TextField(
                              controller: _personSearchController(
                                  index, 'character', slot.query),
                              decoration: const InputDecoration(
                                  labelText: '第二步：查詢角色名稱',
                                  prefixIcon: Icon(Icons.person_search)),
                              onChanged: (value) =>
                                  setState(() => slot.query = value)),
                          const SizedBox(height: 9),
                          if (matches.isNotEmpty)
                            Wrap(
                                spacing: 7,
                                runSpacing: 7,
                                children: matches
                                    .map((character) => ChoiceChip(
                                        label: Text(
                                            character.unitZh.isEmpty
                                                ? '${character.characterZh} · ${character.characterEn}'
                                                : '${character.characterZh} · ${character.characterEn}\n${character.unitZh}',
                                            textAlign: TextAlign.center),
                                        selected:
                                            slot.characterId == character.id,
                                        onSelected: (_) =>
                                            _selectCharacter(index, character)))
                                    .toList())
                          else
                            const Text('查無此動漫角色，可自行新增角色資料。'),
                        ],
                        const SizedBox(height: 9),
                        OutlinedButton.icon(
                            onPressed: _addCustomCharacter,
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text('新增自訂動漫與角色')),
                        if (selectedCharacter != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(spacing: 8, runSpacing: 6, children: [
                                      Chip(
                                          avatar: const Icon(Icons.auto_awesome,
                                              size: 16),
                                          label: Text(
                                              '${selectedCharacter.animeZh} · ${selectedCharacter.characterZh}')),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _setCharacterTraitsEnabled(index,
                                                !slot.characterTraitsEnabled),
                                        icon: Icon(slot.characterTraitsEnabled
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined),
                                        label: Text(slot.characterTraitsEnabled
                                            ? '保留名稱／取消特徵'
                                            : '保留名稱／恢復特徵'),
                                      ),
                                    ]),
                                    const SizedBox(height: 6),
                                    Text(
                                      slot.characterTraitsEnabled
                                          ? '角色名稱與出處已加入；下方會自動勾選固定外觀特徵，可在特徵中另行調整。'
                                          : '目前只保留角色名稱與出處；固定外觀特徵已取消。',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ])),
                      ],
                      if (slot.mode == '原創') ...[
                        const SizedBox(height: 10),
                        TextFormField(
                            initialValue: slot.originalAnimeZh,
                            decoration: const InputDecoration(
                                labelText: '原創作品/世界觀中文（可選）'),
                            onChanged: (value) {
                              slot.originalAnimeZh = value;
                              _persist();
                            }),
                        const SizedBox(height: 8),
                        TextFormField(
                            initialValue: slot.originalAnimeEn,
                            decoration: const InputDecoration(
                                labelText: 'Original work English（可選）'),
                            onChanged: (value) {
                              slot.originalAnimeEn = value;
                              _persist();
                            }),
                        const SizedBox(height: 8),
                        TextFormField(
                            initialValue: slot.originalCharacterZh,
                            decoration:
                                const InputDecoration(labelText: '原創角色中文名稱'),
                            onChanged: (value) {
                              slot.originalCharacterZh = value;
                              _persist();
                            }),
                        const SizedBox(height: 8),
                        TextFormField(
                            initialValue: slot.originalCharacterEn,
                            decoration: const InputDecoration(
                                labelText:
                                    'Original character English name（必填）'),
                            onChanged: (value) {
                              slot.originalCharacterEn = value;
                              slot.originalCharacterTag =
                                  slot.originalCharacterTag.isEmpty
                                      ? _slug(value)
                                      : slot.originalCharacterTag;
                              _persist();
                            }),
                        const SizedBox(height: 8),
                        TextFormField(
                            initialValue: slot.originalCharacterTag,
                            decoration: const InputDecoration(
                                labelText: 'Character tag（必填）'),
                            onChanged: (value) {
                              slot.originalCharacterTag = value;
                              _persist();
                            }),
                        const SizedBox(height: 8),
                        TextFormField(
                            initialValue: slot.originalTraits,
                            decoration: const InputDecoration(
                                labelText: '原創角色特徵（中英文皆可，逗號分隔）'),
                            onChanged: (value) {
                              slot.originalTraits = value;
                              _persist();
                            }),
                      ],
                    ],
                  ]),
            ),
          );
        }),
        Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
                onPressed: _advanceStep,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('完成角色：下一步特徵'))),
      ],
    );
  }

  Widget _unregisteredPositiveTagsPanel() {
    if (_isCompactMobileViewport) return const SizedBox.shrink();
    final tags = _unregisteredPositiveTags.toList();
    if (tags.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '待收錄標籤（${tags.length}）',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              TextButton.icon(
                onPressed: () => _copy(tags.join(', '), '未加入標籤'),
                icon: const Icon(Icons.copy_outlined),
                label: const Text('複製全部'),
              ),
              TextButton.icon(
                onPressed: _downloadUnregisteredPositiveTags,
                icon: const Icon(Icons.download_outlined),
                label: const Text('下載清單'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _unregisteredPositiveTags.clear();
                    _persist();
                  });
                },
                child: const Text('清除清單'),
              ),
            ],
          ),
          const Text('這些詞語目前不在系統標籤庫中，會保留在本機，之後可整理後加入內建標籤。'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags
                .map(
                  (value) => InputChip(
                    label: Text(value),
                    onDeleted: () {
                      setState(() {
                        _unregisteredPositiveTags.remove(value);
                        _persist();
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _personPromptWeightControls(int personIndex) {
    if (personIndex < 0 || personIndex >= _personSlots.length) {
      return const SizedBox.shrink();
    }
    final slot = _personSlots[personIndex];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xff1f2948),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff818cf8).withOpacity(.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: slot.promptWeightEnabled,
            title: const Text('啟用權重'),
            onChanged: (enabled) => setState(() {
              slot.promptWeightEnabled = enabled;
              _persist();
            }),
          ),
          if (slot.promptWeightEnabled) ...[
            Row(
              children: [
                const Expanded(
                  child: Text('人物權重',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    slot.personPromptWeight = _defaultPromptWeight;
                    _persist();
                  }),
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text('1.05'),
                ),
              ],
            ),
            _promptWeightControl(
              title: '人物權重',
              icon: Icons.person_outline,
              value: slot.personPromptWeight,
              onChanged: (value) => setState(() {
                slot.personPromptWeight = _boundedPromptWeight(value);
                _persist();
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _promptWeightControl({
    required String title,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final boundedValue = _boundedPromptWeight(value);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        color: const Color(0xff1f2948),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff818cf8).withOpacity(.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xffc4b5fd)),
              const SizedBox(width: 7),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              Text('${boundedValue.toStringAsFixed(2)} 倍',
                  style: const TextStyle(
                      color: Color(0xffddd6fe), fontWeight: FontWeight.w800)),
            ],
          ),
          Slider(
            min: _minimumPromptWeight,
            max: _maximumPromptWeight,
            divisions: 20,
            value: boundedValue,
            label: boundedValue.toStringAsFixed(2),
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('0.50', style: TextStyle(fontSize: 11)),
              Text('1.00', style: TextStyle(fontSize: 11)),
              Text('1.50', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepFinal() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
          controller: _preprompt,
          maxLines: 2,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
              labelText: 'Amanatsu 品質前綴（可修改）',
              helperText: '角色基本特徵與整套服裝會分別使用括號權重；表情、姿勢、動作與場景維持一般權重。')),
      const SizedBox(height: 10),
      TextField(
          controller: _extraPositive,
          maxLines: 2,
          onChanged: (_) {
            _collectUnknownExtraPositiveTags();
            _persist();
            setState(() {});
          },
          decoration: InputDecoration(
            labelText: '額外正向標籤',
            hintText: '中文或英文，逗號/換行分隔',
            suffixIconConstraints: const BoxConstraints(minWidth: 0),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: '貼上並取代目前內容',
                  onPressed: () => unawaited(_pasteAndReplaceExtraPositive()),
                  icon: const Icon(Icons.content_paste_go_outlined),
                ),
                IconButton(
                  tooltip: '清除額外正向標籤',
                  onPressed: _extraPositive.text.trim().isEmpty
                      ? null
                      : _clearExtraPositive,
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
          )),
      if (!_isCompactMobileViewport) ...[
        const SizedBox(height: 10),
        _unregisteredPositiveTagsPanel(),
        const SizedBox(height: 10),
      ],
      TextField(
          controller: _reversePrompt,
          maxLines: 4,
          decoration: const InputDecoration(
              labelText: '標籤反推（貼上既有提示詞）',
              hintText:
                  '例如：1girl, pink hair, long hair, formal blazer outfit')),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          onPressed: _reversePromptTags,
          icon: const Icon(Icons.auto_fix_high),
          label: const Text('反推並勾選標籤'),
        ),
      ),
      const SizedBox(height: 4),
      Text('已收錄的英文或中文標籤會自動勾選；查不到的內容會追加到額外正向標籤。括號權重與英文句點會自動整理。',
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 10),
      Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withOpacity(.35),
              borderRadius: BorderRadius.circular(10)),
          child: const Row(children: [
            Icon(Icons.visibility_off_outlined, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('負面提示內容已隱藏；仍可在下方調整，並使用左側「負」按鈕複製英文內容。')),
          ])),
      const SizedBox(height: 12),
      _negativeTagPicker(),
      const SizedBox(height: 12),
      Text(
          '自動髮長防衝突：角色為長髮時會在負面輸出加入 cropped hair；改選短髮後則加入 long hair。這些自動詞不會改寫上方可編輯欄位。',
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 12),
      SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _showAdult,
          title: const Text('顯示 18+ 標籤'),
          subtitle: const Text('只使用成年角色，並遵守 BetterWaifu 內容規範。'),
          onChanged: (value) => setState(() {
                _showAdult = value;
                _persist();
              })),
    ]);
  }

  List<TagItem> _globalTagSearchResults(String rawQuery) {
    final query = rawQuery.trim().toLowerCase().replaceAll('_', ' ');
    if (query.isEmpty) return const <TagItem>[];
    final terms = query.split(RegExp(r'\s+')).where((term) => term.isNotEmpty);
    final allTags = _allTags;
    final hiddenIds = _hiddenTaxonomyDuplicateIdsCache ?? <String>{};
    final results = allTags.where((tag) {
      if (!_showAdult && tag.adult) return false;
      if (hiddenIds.contains(tag.id)) return false;
      final haystack = [
        tag.zh,
        tag.en.replaceAll('_', ' '),
        tag.group,
        _wizardGroupLabel(tag.group),
      ].join(' ').toLowerCase();
      return terms.every(haystack.contains);
    }).toList();

    int matchRank(TagItem tag) {
      final zh = tag.zh.trim().toLowerCase();
      final en = tag.en.trim().toLowerCase().replaceAll('_', ' ');
      if (zh == query || en == query) return 0;
      if (zh.startsWith(query) || en.startsWith(query)) return 1;
      return 2;
    }

    results.sort((a, b) {
      final rankCompare = matchRank(a).compareTo(matchRank(b));
      if (rankCompare != 0) return rankCompare;
      final groupCompare =
          _wizardGroupLabel(a.group).compareTo(_wizardGroupLabel(b.group));
      return groupCompare == 0 ? _compareOutputTags(a, b) : groupCompare;
    });
    return results;
  }

  Widget _globalSearchTagChip(TagItem tag, int targetPersonIndex) {
    final personIndex =
        _isGlobalPromptGroup(tag.group) ? null : targetPersonIndex;
    final selected = personIndex == null
        ? _selectedIds.contains(tag.id)
        : _personTagIds(personIndex).contains(tag.id);
    final tone = _pickerLayerTone(tag.group);
    return FilterChip(
      selected: selected,
      avatar: tag.adult
          ? Icon(
              Icons.eighteen_mp,
              size: 15,
              color: selected
                  ? _pickerLayerText(tone, selected: true)
                  : const Color(0xffffa7b7),
            )
          : null,
      label: Text(
        '${_wizardGroupLabel(tag.group)}｜${tag.zh}  ·  ${tag.en}',
        softWrap: true,
        style: TextStyle(
          color: _pickerLayerText(tone, selected: selected),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: _pickerLayerSurface(tone, selected: false),
      selectedColor: _pickerLayerSurface(tone, selected: true),
      checkmarkColor: _pickerLayerText(tone, selected: true),
      side: BorderSide(color: selected ? tone : tone.withOpacity(.7)),
      onSelected: (_) => _toggle(tag, personIndex: personIndex),
    );
  }

  Widget _globalTagSearchPanel() {
    final targetPersonIndex = min(
      max(0, _globalSearchPersonIndex),
      max(0, _personSlots.length - 1),
    );
    final results = _globalTagSearchResults(_globalTagQuery);
    const displayLimit = 160;
    final displayed = results.take(displayLimit).toList();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.manage_search_outlined),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '全系統標籤搜尋',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                if (_personSlots.length > 1)
                  DropdownButton<int>(
                    value: targetPersonIndex,
                    underline: const SizedBox.shrink(),
                    items: List.generate(
                      _personSlots.length,
                      (index) => DropdownMenuItem<int>(
                        value: index,
                        child: Text('套用到人物 ${index + 1}'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _globalSearchPersonIndex = value);
                    },
                  )
                else
                  const Text('套用到人物 1', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _globalTagSearch,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: '搜尋所有中文、英文標籤或分類…',
                suffixIcon: _globalTagQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: '清除搜尋文字',
                        onPressed: () {
                          _globalTagSearch.clear();
                          setState(() => _globalTagQuery = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                filled: true,
              ),
              onChanged: (value) => setState(() => _globalTagQuery = value),
            ),
            const SizedBox(height: 7),
            Text(
              _globalTagQuery.trim().isEmpty
                  ? '輸入關鍵字後會搜尋整個系統；18+ 標籤會依「顯示 18+ 分類」設定顯示。'
                  : results.isEmpty
                      ? '找不到符合的標籤。'
                      : results.length > displayLimit
                          ? '已搜尋全部 ${results.length} 個結果；為避免畫面延遲，先顯示最相符的 $displayLimit 個。'
                          : '搜尋到 ${results.length} 個標籤；場景與多人動作會全局套用，其他標籤會套用到指定人物。',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (displayed.isNotEmpty) ...[
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: SingleChildScrollView(
                  primary: false,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: displayed
                        .map((tag) =>
                            _globalSearchTagChip(tag, targetPersonIndex))
                        .toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _progressiveBuilder() {
    return Column(children: [
      _stepCard(
          0,
          '場景與畫面',
          _selectedTags
              .where((tag) => _isSceneVisualPromptGroup(tag.group))
              .map((tag) => tag.zh)
              .join('、')
              .ifEmpty('尚未選擇'),
          Icons.landscape_outlined,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: '隨機場景與畫面',
                  onPressed: _randomizeSceneAndFrame,
                  icon: const Icon(Icons.shuffle),
                ),
              ),
              _stepTagPicker(
                [
                  _indoorSceneGroup,
                  _outdoorSceneGroup,
                  _outdoorTimeGroup,
                  _cameraFramingGroup,
                  _cameraFaceFocusGroup,
                  _cameraFocusGroup,
                  _cameraCropGroup,
                  '畫面',
                ],
                nextLabel: '下一步：角色資料',
              ),
            ],
          ),
          onClear: () => _clearStepTags(0)),
      _stepCard(
          1,
          '角色資料',
          _characterChineseNew().join('、').ifEmpty('每個人物都要設定或選擇不需細節'),
          Icons.badge_outlined,
          _stepCharacters(),
          onClear: () => _clearStepTags(1)),
      _stepCard(
          2,
          '\u7D44\u5408\u6A19\u7C64',
          _combinations.isEmpty
              ? '\u5EFA\u7ACB\u53EF\u91CD\u8907\u5957\u7528\u7684\u670D\u88DD\u6216\u59FF\u52E2\u7D44\u5408'
              : '${_combinations.length} \u500B\u7D44\u5408\u53EF\u5957\u7528',
          Icons.auto_awesome_motion_outlined,
          _stepCombinations(),
          onClear: () => _clearStepTags(2)),
      _stepCard(
          3,
          '固定角色外觀',
          _fixedCharacterFeatureSummaryZh()
              .join('、')
              .ifEmpty(_personSelectedIds.isEmpty ? '每位人物分別設定' : '尚未選擇'),
          Icons.face_retouching_natural,
          _stepPersonTagPicker([
            '髮長',
            '髮型',
            '眼睛',
            _staticFaceAppearanceGroup,
            _animalTraitGroup,
            _wingTypeGroup,
            '額外特徵',
            '額外特徵位置',
            '額外特徵顏色',
            '身體特徵',
            '胸部',
            '裸露',
          ],
              nextLabel: '下一步：服裝',
              instruction:
                  '這裡只放固定外觀：髮色、髮型、眼睛類型、臉部結構、身材、獸耳、獸尾、獸手、獸足、翅膀與額外特徵。獸化部位及翅膀的顏色都放在各自特徵內，並自動合併成中英文提示詞；全身毛茸茸 furry 與 anthro 必須自行選擇，不會因耳尾自動加入。表情、視線、嘴型、頭頸動作已移至下一個「姿勢」大項；髮色會在髮型分類中置於下方。'),
          onClear: () => _clearStepTags(3)),
      _stepCard(
          4,
          '服裝與穿脫狀態',
          _personSelectedIds.values
              .expand((ids) => _allTags.where((tag) => ids.contains(tag.id)))
              .where((tag) =>
                  [
                    '上衣',
                    '褲子',
                    '裙子',
                    '內衣',
                    '胸罩',
                    '內褲',
                    '襪子',
                    '鞋子',
                    '服裝',
                    _cosplayGroup,
                    '配件',
                    '配件顏色',
                    '帽子顏色',
                    '眼鏡顏色',
                    '上衣風格',
                    '下身風格',
                    '上衣顏色',
                    '下身顏色',
                    '服裝顏色',
                    '帽子邊線色',
                    '眼鏡邊線色',
                    '服裝細節',
                    '服裝細節顏色',
                    '服裝材質',
                    '穿脫狀態'
                  ].contains(tag.group) ||
                  _isScopedClothingGroup(tag.group))
              .map((tag) => tag.zh)
              .join('、')
              .ifEmpty('每位人物分別設定'),
          Icons.checkroom_outlined,
          _stepClothing(),
          onClear: () => _clearStepTags(4)),
      _stepCard(
          5,
          '姿勢、互動與成人分類',
          _personSelectedIds.values
              .expand((ids) => _allTags.where((tag) => ids.contains(tag.id)))
              .where(_isPoseWorkflowTag)
              .map((tag) => tag.zh)
              .followedBy(_selectedTags
                  .where((tag) => _isSharedActionGroup(tag.group))
                  .map((tag) => tag.zh))
              .join('、')
              .ifEmpty('每位人物分別設定'),
          Icons.accessibility_new,
          _stepCategorizedPersonTagPicker(expandedTagPickerSections,
              nextLabel: '下一步：品質與負面',
              instruction:
                  '依序選頭部、上半身、下半身、全身姿勢，再選物件或人物互動；成人性姿勢與道具集中在最後。每位人物會保留自己的動作與互動。'),
          onClear: () => _clearStepTags(5)),
      _stepCard(6, '品質、額外與負面', '設定品質前綴、negative prompt 與 18+ 顯示', Icons.tune,
          _stepFinal(),
          onClear: () => _clearStepTags(6)),
    ]);
  }

  Widget _builderPanel() {
    final visible = _visibleTags(_activeGroup);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '標籤資料庫',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _addCustomTag,
                  icon: const Icon(Icons.add),
                  label: const Text('新增標籤'),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              '點選標籤加入提示詞；排序會依照角色 → 特徵 → 服裝 → 表情 → 姿勢／動作／物件。',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _search.clear,
                        icon: const Icon(Icons.clear),
                      ),
                hintText: '搜尋中文或英文標籤…',
                filled: true,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: _groups.map((group) {
                return ChoiceChip(
                  label: Text(
                    group,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: _activeGroup == group
                          ? _buttonSelectedText
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  selected: _activeGroup == group,
                  backgroundColor: _buttonSurface,
                  selectedColor: _buttonSelectedSurface,
                  side: BorderSide(
                    color: _activeGroup == group
                        ? const Color(0xfff0eaff)
                        : _buttonBorder,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onSelected: (_) => setState(() => _activeGroup = group),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (visible.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('沒有符合條件的標籤。可以用右上角「新增標籤」建立自己的中文/英文內容。'),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: visible.map(_tagChip).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _setupPanel() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '組合設定',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            const Text(
              '人物數量與性別請在「角色資料」區直接增加、減少人物卡片並分別設定。',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              '模型、Sampler、Steps、CFG 與 Clip skip 請直接在 AI 生成網站設定；本工具只輸出可貼上的提示標籤。',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _showAdult,
              title: const Text('顯示 18+ 標籤分類'),
              subtitle: const Text('包含胸部、裸露、性行為與性姿勢；只建立成年角色內容。'),
              onChanged: (value) => setState(() {
                _showAdult = value;
                _persist();
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _preprompt,
              maxLines: 2,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Amanatsu 品質前綴（可修改）',
                helperText: '會在全部選取標籤之後輸出，避免破壞你指定的角色→服裝→表情→姿勢順序。',
                prefixIcon: Icon(Icons.tune),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _extraPositive,
              maxLines: 2,
              onChanged: (_) {
                _collectUnknownExtraPositiveTags();
                _persist();
                setState(() {});
              },
              decoration: const InputDecoration(
                labelText: '額外正向標籤',
                hintText: '可輸入中文或英文；中文會自動轉成英文標籤',
                helperText: '可用逗號或換行分隔；內建標籤會自動對應英文，英文欄位仍以英文輸出。',
                prefixIcon: Icon(Icons.add_circle_outline),
              ),
            ),
            const SizedBox(height: 12),
            _unregisteredPositiveTagsPanel(),
            const SizedBox(height: 12),
            const Row(children: [
              Icon(Icons.visibility_off_outlined, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('負面提示內容已隱藏；仍可選擇標籤並使用左側「負」按鈕複製。')),
            ]),
            const SizedBox(height: 10),
            _negativeTagPicker(),
          ],
        ),
      ),
    );
  }

  Widget _outputField(
    String label,
    String value, {
    required VoidCallback onCopy,
    int maxLines = 4,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: '複製',
                onPressed: value.isEmpty ? null : onCopy,
                icon: const Icon(Icons.copy_all_outlined),
              ),
            ],
          ),
          TextField(
            controller: TextEditingController(text: value),
            readOnly: true,
            maxLines: maxLines,
            decoration: const InputDecoration(
              filled: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chineseOutputField() {
    final generated = _generatedPositiveTags();
    final extra = _extraPositive.text.trim();
    final preprompt = _preprompt.text.trim();
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '中文翻譯與記憶欄位',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: '複製',
                onPressed: _positiveZh.isEmpty
                    ? null
                    : () => _copy(_positiveZh, '中文欄位'),
                icon: const Icon(Icons.copy_all_outlined),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 150),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor ??
                  Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '人物數量：${_peopleZhNew()}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  if (generated.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: generated.map((tag) {
                        return Tooltip(
                          message: tag.en,
                          child: InputChip(
                            label: Text(tag.zh),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeGeneratedOutputTag(tag),
                            backgroundColor: _buttonSurface,
                            side: const BorderSide(color: _buttonBorder),
                            labelStyle: const TextStyle(color: Colors.white),
                            deleteIconColor: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (extra.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      '額外正向敘述：${_extraTags(extra).map(_positiveChineseTag).join('、')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                  if (preprompt.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Amanatsu 品質前綴：${_extraTags(preprompt).map(_positiveChineseTag).join('、')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outputPanel() {
    final selectedCount = _selectedTags.length + _personSelectedCount;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '輸出結果',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '已選 $selectedCount 個資料庫標籤 · 英文每個標籤以句點結尾',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      _copy(_positiveText, '英文正向標籤', showFeedback: true),
                  icon: const Icon(Icons.copy_all),
                ),
                IconButton(
                  onPressed: _savePreset,
                  icon: const Icon(Icons.bookmark_add_outlined),
                ),
                IconButton(
                  tooltip: '清除所有標籤',
                  onPressed: _clearAllTags,
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 690;
                final english = _outputField(
                  'English prompt · 可直接貼上',
                  _positiveText,
                  onCopy: () =>
                      _copy(_positiveText, '英文正向標籤', showFeedback: true),
                  maxLines: 6,
                );
                final chinese = _chineseOutputField();
                return narrow
                    ? Column(
                        children: [
                          english,
                          const SizedBox(height: 12),
                          chinese,
                        ],
                      )
                    : Row(
                        children: [english, const SizedBox(width: 14), chinese],
                      );
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(.48),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '模型參數請在 AI 生成網站設定；這裡只提供可貼上的提示標籤。',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '輸出順序：${_peopleTagNew()} → 角色/特徵 → 服裝 → 表情 → 姿勢 → 場景/畫面 → 品質前綴。',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _memoryPanel() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '記憶與備份',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: '匯出 JSON',
                  onPressed: _downloadBackup,
                  icon: const Icon(Icons.download_outlined),
                ),
                IconButton(
                  tooltip: '匯入 JSON',
                  onPressed: _importBackup,
                  icon: const Icon(Icons.upload_outlined),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '目前資料只存在這個瀏覽器的 localStorage；清除網站資料會移除記憶。',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (_presets.isEmpty)
              const Text('尚無儲存組合。按輸出結果右上角的書籤按鈕即可保存。')
            else
              ..._presets.asMap().entries.map((entry) {
                final index = entry.key;
                final preset = entry.value;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 15,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(preset.name),
                  subtitle: Text(
                    '${(preset.payload['selectedIds'] as List? ?? []).length} 個標籤 · ${preset.payload['gender'] ?? '女性'} ${preset.payload['peopleCount'] ?? 1} 人',
                  ),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: '載入',
                        onPressed: () => _loadPreset(preset),
                        icon: const Icon(Icons.restore),
                      ),
                      IconButton(
                        tooltip: '刪除',
                        onPressed: () => setState(() {
                          _presets.removeAt(index);
                          _persist();
                        }),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showUsageTips() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.tips_and_updates_outlined),
            SizedBox(width: 8),
            Expanded(child: Text('Amanatsu / BetterWaifu 使用提示')),
          ],
        ),
        content: const SizedBox(
          width: 620,
          child: SingleChildScrollView(
            child: Text(
              '• 模型、Sampler、Steps、CFG、Clip skip 與 seed 請在 AI 生成網站設定；本工具專注產生提示標籤。\n\n'
              '• 本工具使用 Danbooru-style tag，英文標籤會整理成可直接貼上的單行文字。\n\n'
              '• BetterWaifu 提示詞可使用逗號分隔、括號強調及獨立 negative prompt；額外欄位可補充系統尚未收錄的詞語。\n\n'
              '• 品質前綴可以自由編輯，避免將未核實的格式當成固定模型規則。\n\n'
              '• 18+ 分類預設隱藏；開啟後請只使用成年角色，並遵守網站內容規範。',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showVersionHistory();
            },
            child: Text('版本 $appVersionLabel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isPreparingCatalog) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(),
              ),
              SizedBox(height: 16),
              Text('正在準備標籤與本機記憶…'),
            ],
          ),
        ),
      );
    }
    final showSideStepNames = MediaQuery.sizeOf(context).width >= 900;
    final sideStepRailWidth = showSideStepNames ? 126.0 : 46.0;
    final contentLeftPadding = max(sideStepRailWidth + 14, 72.0);
    const sideStepNames = <String>[
      '場景',
      '角色',
      '組合',
      '特徵',
      '服裝',
      '姿勢',
      '品質',
    ];
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 22,
        title: Row(
          children: [
            Icon(Icons.auto_awesome, size: 25),
            SizedBox(width: 10),
            Flexible(child: Text('Prompt Atelier')),
            SizedBox(width: 10),
            Text(
              'v$appVersionLabel',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '版本歷程',
            onPressed: _showVersionHistory,
            icon: const Icon(Icons.new_releases_outlined),
          ),
          IconButton(
            tooltip: '匯出備份',
            onPressed: _downloadBackup,
            icon: const Icon(Icons.save_alt),
          ),
          IconButton(
            tooltip: '匯入備份',
            onPressed: _importBackup,
            icon: const Icon(Icons.file_open_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            key: _pageScrollKey,
            controller: _pageScrollController,
            // The trailing room is calculated only when a selected step needs
            // it to reach the top; keeping it small by default avoids a large
            // blank area after the content.
            padding: EdgeInsets.fromLTRB(
              contentLeftPadding,
              16,
              16,
              _pageBottomPadding,
            ),
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: _globalTagSearchPanel(),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: _progressiveBuilder(),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                key: _outputKey,
                constraints: const BoxConstraints(maxWidth: 1120),
                child: _outputPanel(),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: _memoryPanel(),
              ),
            ],
          ),
          Positioned(
            left: 6,
            top: 112,
            child: SafeArea(
              child: SizedBox(
                width: sideStepRailWidth,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                    child: Column(
                      children: [
                        ...List.generate(7, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: showSideStepNames
                                ? SizedBox(
                                    width: 114,
                                    height: 34,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 9),
                                        backgroundColor: _stepIndex == index
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                            : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                        foregroundColor: _stepIndex == index
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                      ),
                                      onPressed: () => _openStep(index),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${index + 1}  ${sideStepNames[index]}',
                                          maxLines: 1,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                    ),
                                  )
                                : IconButton.filled(
                                    constraints: const BoxConstraints.tightFor(
                                        width: 34, height: 32),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    tooltip:
                                        '${index + 1} ${sideStepNames[index]}',
                                    onPressed: () => _openStep(index),
                                    icon: Text('${index + 1}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800)),
                                  ),
                          );
                        }),
                        const Divider(height: 8),
                        showSideStepNames
                            ? SizedBox(
                                width: 114,
                                height: 34,
                                child: FilledButton.tonalIcon(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9),
                                  ),
                                  onPressed: _scrollToOutput,
                                  icon: const Icon(Icons.vertical_align_bottom,
                                      size: 16),
                                  label: const Text('提示詞',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800)),
                                ),
                              )
                            : IconButton.filled(
                                constraints: const BoxConstraints.tightFor(
                                    width: 34, height: 32),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                tooltip: '前往中英文提示詞輸出',
                                onPressed: _scrollToOutput,
                                icon: const Icon(Icons.vertical_align_bottom,
                                    size: 17),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 154,
            child: SafeArea(
              child: IconButton.filledTonal(
                constraints:
                    const BoxConstraints.tightFor(width: 42, height: 38),
                tooltip: '使用提示',
                onPressed: _showUsageTips,
                icon: const Icon(Icons.help_outline, size: 19),
              ),
            ),
          ),
          Positioned(
            left: 6,
            bottom: 12,
            child: SafeArea(
              child: SizedBox(
                width: 56,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 7),
                    child: Column(
                      children: [
                        const Text('複製',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        IconButton.filled(
                            constraints: const BoxConstraints.tightFor(
                                width: 44, height: 42),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            iconSize: 16,
                            tooltip: '複製正向英文標籤',
                            onPressed: () => _copy(_positiveText, '正向英文標籤',
                                showFeedback: true),
                            icon: const Text('正',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800))),
                        const SizedBox(height: 6),
                        IconButton.filled(
                            constraints: const BoxConstraints.tightFor(
                                width: 44, height: 42),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            iconSize: 16,
                            tooltip: '複製負面英文標籤',
                            onPressed: () => _copy(_negativeText, '負面英文標籤',
                                showFeedback: true),
                            icon: const Text('負',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'BetterWaifu Prompt Atelier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff8c6ef3),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xff11111a),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(_buttonSelectedSurface),
            foregroundColor: MaterialStatePropertyAll(_buttonSelectedText),
            side: MaterialStatePropertyAll(
              BorderSide(color: Color(0xfff0eaff)),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(_buttonSurface),
            foregroundColor: MaterialStatePropertyAll(Colors.white),
            side: MaterialStatePropertyAll(BorderSide(color: _buttonBorder)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(_buttonSelectedSurface),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(Colors.white),
            backgroundColor: MaterialStatePropertyAll(_buttonSurface),
          ),
        ),
        chipTheme: const ChipThemeData(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          labelStyle: TextStyle(
            fontSize: 12,
            height: 1.25,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: _buttonSurface,
          selectedColor: _buttonSelectedSurface,
          checkmarkColor: _buttonSelectedText,
          side: BorderSide(color: _buttonBorder),
        ),
        cardTheme: const CardThemeData(margin: EdgeInsets.zero, elevation: 0),
      ),
      home: const PromptBuilderApp(),
    ),
  );
}

class _ColorMatch {
  const _ColorMatch(this.word, this.start);

  final String word;
  final int start;
}
