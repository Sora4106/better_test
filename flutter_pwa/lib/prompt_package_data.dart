/// Reusable, non-explicit prompt packages for one character.
///
/// Every package is built only from tags already registered in the picker, so
/// applying a package remains fully editable through the normal tag controls.
class PromptPackageData {
  const PromptPackageData({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> tags;
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

const _sexyPoseBases = <_PackagePart>[
  _PackagePart(
      'standing_curve', '分腿站姿曲線', ['standing with legs apart', 'hand on hip']),
  _PackagePart('one_leg_back', '單腳後翹',
      ['standing on one leg', 'one leg raised behind']),
  _PackagePart('tiptoe_back', '踮腳背手',
      ['standing on tiptoes', 'hands behind back']),
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
