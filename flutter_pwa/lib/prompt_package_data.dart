/// Reusable, non-explicit prompt packages.
///
/// A package may combine editable picker tags with a natural-language prompt.
/// Natural prompts are preserved verbatim, so longer action descriptions do
/// not need to be split into individual catalog tags first.
class PromptPackageData {
  const PromptPackageData({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.tags = const <String>[],
    this.naturalPrompt = '',
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> tags;
  final String naturalPrompt;
}

class _PackagePart {
  const _PackagePart(this.id, this.name, this.tags);

  final String id;
  final String name;
  final List<String> tags;
}

/// 10 base poses × 10 gestures = 100 editable general-pose packages.
final generalPosePackages = List<PromptPackageData>.unmodifiable([
  for (final base in _poseBases)
    for (final gesture in _poseGestures)
      PromptPackageData(
        id: 'pose_${base.id}_${gesture.id}',
        name: '${base.name}・${gesture.name}',
        description: '${base.name}搭配${gesture.name}的單人姿勢。',
        category: base.name,
        tags: [...base.tags, ...gesture.tags],
      ),
]);

/// 10 sensual-but-non-explicit bases × 10 facial/gesture accents.
/// These packages remain in the regular pose workflow and can be adjusted
/// afterwards just like individually selected tags.
final sexyPosePackages = List<PromptPackageData>.unmodifiable([
  for (final base in _sexyPoseBases)
    for (final accent in _sexyPoseAccents)
      PromptPackageData(
        id: 'sexy_${base.id}_${accent.id}',
        name: '${base.name}・${accent.name}',
        description: '${base.name}搭配${accent.name}的性感非露骨姿態。',
        category: base.name,
        tags: [...base.tags, ...accent.tags],
      ),
]);

/// Fifteen feline-inspired single-person pose kits. They are intentionally
/// built from the normal editable pose tags, so a cat tail, ears, paws, or
/// anthro identity can be added separately only when wanted.
const felineSoloPosePackages = <PromptPackageData>[
  PromptPackageData(
    id: 'feline_play_bow_ball',
    name: '玩球預備動作',
    description: '壓低身體、盯著小球，準備撲上去。',
    category: '玩耍與探索',
    tags: const <String>[],
    naturalPrompt:
        'play bow pose, hips raised, upper body lowered, hands hovering above a ball, swaying left and right, staring at the ball, playful focus, ready-to-pounce energy',
  ),
  PromptPackageData(
    id: 'feline_kneeling_chin_stroke',
    name: '跪姿抬頭被摸下巴',
    description: '直身跪姿、抬頭，接受輕撫下巴。',
    category: '休息與撒嬌',
    tags: const <String>[],
    naturalPrompt:
        'kneeling pose, upper body upright, head tilted up, chin being gently stroked, pleased expression, relaxed posture, content feline reaction',
  ),
  PromptPackageData(
    id: 'feline_lying_belly_rub',
    name: '仰躺露肚被摸肚子',
    description: '仰躺放鬆，露出腹部接受撫摸。',
    category: '休息與撒嬌',
    tags: const <String>[],
    naturalPrompt:
        'lying on back, belly exposed, belly being rubbed, trusting pose, relaxed limbs, soft happy expression, cat-like submissive trust',
  ),
  PromptPackageData(
    id: 'feline_crouched_grooming',
    name: '蹲坐整理自己',
    description: '低身蹲坐、做洗臉般的整理動作。',
    category: '玩耍與探索',
    tags: const <String>[],
    naturalPrompt:
        'crouched sitting pose, grooming gesture, one hand near cheek, self-cleaning motion, calm expression, neat feline behavior',
  ),
  PromptPackageData(
    id: 'feline_low_stalking',
    name: '低伏偷偷接近',
    description: '身體前壓、低伏潛行的接近姿態。',
    category: '玩耍與探索',
    tags: const <String>[],
    naturalPrompt:
        'low stalking pose, upper body leaning forward, knees bent, fingertips touching the ground, focused gaze, sneaking movement, hunting-cat posture',
  ),
  PromptPackageData(
    id: 'feline_perched_observing',
    name: '高處蹲坐俯視',
    description: '佔據高處、向下安靜觀察。',
    category: '玩耍與探索',
    tags: const <String>[],
    naturalPrompt:
        'perched sitting pose, upright posture, looking downward, calm observant expression, elegant feline composure, high-ground cat posture',
  ),
  PromptPackageData(
    id: 'feline_side_lying_tail_swish',
    name: '側躺甩尾看人',
    description: '側躺托頭，尾巴輕輕甩動。',
    category: '休息與撒嬌',
    tags: const <String>[],
    naturalPrompt:
        'lying on side, one arm supporting head, tail swishing gently, relaxed gaze, lazy feline mood, calm playful posture',
  ),
  PromptPackageData(
    id: 'feline_stretching_yawn',
    name: '伸長身體打哈欠',
    description: '全身伸展並打哈欠的剛睡醒感。',
    category: '休息與撒嬌',
    tags: const <String>[],
    naturalPrompt:
        'full-body stretch, arms extended, back elongated, yawning, sleepy eyes, relaxed feline motion, just-woke-up mood',
  ),
  PromptPackageData(
    id: 'feline_pawing_toy',
    name: '用手拍玩具',
    description: '前傾伸手、像貓掌般撥弄玩具。',
    category: '玩耍與探索',
    tags: const <String>[],
    naturalPrompt:
        'leaning forward, pawing gesture, one hand reaching to tap a toy, curious expression, playful interaction, cat-like batting motion',
  ),
  PromptPackageData(
    id: 'feline_alert_turn_back',
    name: '驚覺豎耳回頭',
    description: '聽見動靜後警覺地回頭。',
    category: '玩耍與探索',
    tags: const <String>[],
    naturalPrompt:
        'sudden turn, looking back, ears perked up, alert expression, slightly tense posture, startled feline reaction',
  ),
  PromptPackageData(
    id: 'feline_curled_up_resting',
    name: '縮成一團打盹',
    description: '蜷縮成一團、安靜休息。',
    category: '休息與撒嬌',
    tags: const <String>[],
    naturalPrompt:
        'compact curled-up pose, knees drawn close, arms tucked in, sleepy expression, resting cat posture',
  ),
  PromptPackageData(
    id: 'feline_sitting_head_tilt',
    name: '坐姿歪頭好奇',
    description: '坐姿配歪頭，呈現好奇反應。',
    category: '休息與撒嬌',
    tags: const <String>[],
    naturalPrompt:
        'upright sitting pose, head tilt, curious expression, attentive eyes, inquisitive feline behavior',
  ),
  PromptPackageData(
    id: 'feline_light_jump_reach',
    name: '輕跳抓東西',
    description: '輕跳起來，向上伸手抓取物件。',
    category: '玩耍與探索',
    tags: const <String>[],
    naturalPrompt:
        'light jumping pose, arms reaching upward, playful expression, agile feline motion, trying to catch something',
  ),
  PromptPackageData(
    id: 'feline_defensive_fluffed_up',
    name: '炸毛防備',
    description: '背部微拱、尾巴炸毛的警戒姿態。',
    category: '警覺與防備',
    tags: const <String>[],
    naturalPrompt:
        'defensive posture, back slightly arched, shoulders raised, tense expression, tail fluffed up, wary feline reaction',
  ),
  PromptPackageData(
    id: 'feline_standing_tail_wrapped',
    name: '尾巴繞腿安靜站立',
    description: '安靜站著，尾巴自然繞住腿部。',
    category: '休息與撒嬌',
    tags: const <String>[],
    naturalPrompt:
        'standing pose, calm expression, tail wrapped around one leg, quiet feline composure',
  ),
];

/// Sixteen non-explicit shared interaction kits. These belong after all
/// individual character blocks and only appear when at least two people exist.
const felineInteractionPackages = <PromptPackageData>[
  PromptPackageData(
    id: 'feline_piggyback',
    name: '被揹在背上',
    description: '雙手環住對方肩膀的揹人互動。',
    category: '抱持與依偎',
    tags: const <String>[],
    naturalPrompt:
        'being carried piggyback, arms around the other person\'s shoulders, legs wrapped lightly, cheerful expression, playful clingy interaction',
  ),
  PromptPackageData(
    id: 'feline_princess_carry',
    name: '被公主抱',
    description: '被穩穩抱起的親密互動。',
    category: '抱持與依偎',
    tags: const <String>[],
    naturalPrompt:
        'being carried in bridal carry, relaxed posture, soft smile, trusting expression, affectionate interaction',
  ),
  PromptPackageData(
    id: 'feline_sitting_on_shoulder',
    name: '坐在對方肩膀上',
    description: '坐在對方肩膀上的高處姿態。',
    category: '抱持與依偎',
    tags: const <String>[],
    naturalPrompt:
        'sitting on the other person\'s shoulders, balanced posture, playful smile, elevated perch-like pose, cat-like confidence',
  ),
  PromptPackageData(
    id: 'feline_held_in_arms',
    name: '被抱在懷裡',
    description: '蜷在對方懷中的安心感。',
    category: '抱持與依偎',
    tags: const <String>[],
    naturalPrompt:
        'being held in the other person\'s arms, curled-up posture, relaxed expression, cozy affectionate interaction',
  ),
  PromptPackageData(
    id: 'feline_cheek_rub',
    name: '蹭對方臉頰',
    description: '用臉頰輕蹭對方的親近互動。',
    category: '撒嬌互動',
    tags: const <String>[],
    naturalPrompt:
        'cheek rubbing against the other person, affectionate body language, half-closed eyes, gentle smile, cat-like nuzzling',
  ),
  PromptPackageData(
    id: 'feline_resting_on_lap',
    name: '伏在對方腿上',
    description: '放鬆伏在對方腿上的依賴感。',
    category: '抱持與依偎',
    tags: const <String>[],
    naturalPrompt:
        'resting across the other person\'s lap, relaxed posture, content expression, comfortable cat-like closeness',
  ),
  PromptPackageData(
    id: 'feline_clinging_to_arm',
    name: '抱著對方手臂不放',
    description: '緊抱對方手臂的黏人動作。',
    category: '撒嬌互動',
    tags: const <String>[],
    naturalPrompt:
        'clinging to the other person\'s arm, hugging the arm closely, cute needy expression, affectionate feline attachment',
  ),
  PromptPackageData(
    id: 'feline_leaning_on_shoulder',
    name: '依偎在對方肩旁',
    description: '安靜靠著對方肩膀。',
    category: '抱持與依偎',
    tags: const <String>[],
    naturalPrompt:
        'leaning against the other person\'s shoulder, relaxed posture, soft smile, affectionate quiet interaction',
  ),
  PromptPackageData(
    id: 'feline_head_patting',
    name: '被摸頭舒服瞇眼',
    description: '被摸頭的放鬆親近互動。',
    category: '撒嬌互動',
    tags: const <String>[],
    naturalPrompt:
        'head being petted, eyes half-closed, pleased smile, relaxed posture, happy feline reaction',
  ),
  PromptPackageData(
    id: 'feline_being_lifted_up',
    name: '被抱高高',
    description: '被對方抱起舉高的輕快互動。',
    category: '抱持與依偎',
    tags: const <String>[],
    naturalPrompt:
        'being lifted up by the other person, surprised happy expression, limbs slightly raised, playful interaction, light feline energy',
  ),
  PromptPackageData(
    id: 'feline_chin_hold_affection',
    name: '被托著下巴撒嬌',
    description: '下巴被輕托的親密互動。',
    category: '撒嬌互動',
    tags: const <String>[],
    naturalPrompt:
        'chin being gently held, looking up at the other person, soft affectionate expression, cat-like dependence',
  ),
  PromptPackageData(
    id: 'feline_lying_on_back',
    name: '趴在對方背上',
    description: '整個人放鬆趴在對方背上。',
    category: '抱持與依偎',
    tags: const <String>[],
    naturalPrompt:
        'lying across the other person\'s back, relaxed posture, playful clingy pose',
  ),
  PromptPackageData(
    id: 'feline_sitting_on_lap',
    name: '坐在對方膝上',
    description: '自然坐在對方膝上的親近姿態。',
    category: '抱持與依偎',
    tags: const <String>[],
    naturalPrompt:
        'sitting on the other person\'s lap, upright posture, relaxed smile, affectionate interaction',
  ),
  PromptPackageData(
    id: 'feline_holding_hands_leaning',
    name: '牽手時靠過去',
    description: '牽著手並向對方靠近。',
    category: '撒嬌互動',
    tags: const <String>[],
    naturalPrompt:
        'holding hands, leaning closer to the other person, gentle smile, affectionate body language',
  ),
  PromptPackageData(
    id: 'feline_lying_beside_belly_up',
    name: '躺在對方身邊翻肚',
    description: '躺在身邊、展現信任與放鬆。',
    category: '撒嬌互動',
    tags: const <String>[],
    naturalPrompt:
        'lying beside the other person, belly exposed, trusting pose, relaxed limbs, playful dependence',
  ),
  PromptPackageData(
    id: 'feline_forehead_nuzzle',
    name: '用額頭頂對方',
    description: '額頭輕貼，主動親近對方。',
    category: '撒嬌互動',
    tags: const <String>[],
    naturalPrompt:
        'gently pressing forehead against the other person, affectionate feline gesture, soft smile, intimate cat-like interaction',
  ),
];

const _sexyPoseBases = <_PackagePart>[
  _PackagePart(
      'standing_curve', '分腿站姿曲線', ['standing with legs apart', 'hand on hip']),
  _PackagePart(
      'one_leg_back', '單腳後翹', ['standing on one leg', 'one leg raised behind']),
  _PackagePart(
      'tiptoe_back', '踮腳背手', ['standing on tiptoes', 'hands behind back']),
  _PackagePart('chair_crossed', '椅上交叉腿', ['sitting on chair', 'crossed legs']),
  _PackagePart('sofa_knees', '沙發屈膝坐姿', ['sitting on sofa', 'knees bent']),
  _PackagePart('floor_open', '地板舒展坐姿', ['sitting on floor', 'legs apart']),
  _PackagePart('side_recline', '側躺抬單腳', ['lying on side', 'one leg raised']),
  _PackagePart('back_recline', '仰躺屈膝', ['lying on back', 'knees bent']),
  _PackagePart('kneeling_back', '跪姿背手', ['kneeling', 'hands behind back']),
  _PackagePart('squat_hip', '微蹲叉腰', ['squatting', 'hand on hip']),
];

const _sexyPoseAccents = <_PackagePart>[
  _PackagePart('viewer_smile', '直視淡笑', ['looking at viewer', 'light smile']),
  _PackagePart('soft_gaze', '半閉眼微張唇', ['half-closed eyes', 'parted lips']),
  _PackagePart('side_smirk', '側眼壞笑', ['sideways glance', 'smirk']),
  _PackagePart('brow_open', '挑眉張嘴', ['raised eyebrow', 'open mouth']),
  _PackagePart('down_blush', '低頭臉紅', ['looking down', 'blush']),
  _PackagePart('playful_gaze', '調皮直視', ['naughty face', 'looking at viewer']),
  _PackagePart('lip_gaze', '舔唇半閉眼', ['licking lips', 'half-closed eyes']),
  _PackagePart('one_eye_smile', '單眼閉合淡笑', ['one eye closed', 'light smile']),
  _PackagePart('tilt_lips', '歪頭微張唇', ['head tilt left', 'parted lips']),
  _PackagePart('up_smirk', '抬頭壞笑', ['looking up', 'smirk']),
];

const _poseBases = <_PackagePart>[
  _PackagePart('upright', '端正站姿', ['standing', 'standing straight']),
  _PackagePart('one_leg', '單腳站姿', ['standing', 'standing on one leg']),
  _PackagePart('crossed_legs', '交叉腿站姿', ['standing with crossed legs']),
  _PackagePart('tiptoes', '踮腳站姿', ['standing on tiptoes']),
  _PackagePart('chair', '椅上坐姿', ['sitting', 'sitting on chair']),
  _PackagePart('sofa', '沙發坐姿', ['sitting', 'sitting on sofa']),
  _PackagePart('floor', '地板坐姿', ['sitting', 'sitting on floor']),
  _PackagePart('bed', '床邊坐姿', ['sitting', 'sitting on bed']),
  _PackagePart('kneeling', '端正跪姿', ['kneeling']),
  _PackagePart('reclining', '仰躺姿勢', ['lying on back']),
];
const _poseGestures = <_PackagePart>[
  _PackagePart('hand_hip', '手放腰間', ['hand on hip']),
  _PackagePart('hand_head', '手扶頭部', ['hand on head']),
  _PackagePart('wave', '揮手', ['waving']),
  _PackagePart('peace', '和平手勢', ['peace sign']),
  _PackagePart('point', '指向前方', ['pointing']),
  _PackagePart('arms_up', '雙手舉起', ['arms up']),
  _PackagePart('hands_back', '雙手在背後', ['hands behind back']),
  _PackagePart('one_hand_up', '單手舉起', ['one hand raised']),
  _PackagePart('fist', '握拳', ['fist']),
  _PackagePart('hands_together', '雙手合十', ['hands together']),
];
// 臉部表情保留為可個別選取的標籤，不提供快速套裝。
