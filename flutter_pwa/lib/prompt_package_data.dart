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

/// 10 eye / mood directions × 10 mouth details = 100 editable face packages.
final facialExpressionPackages = List<PromptPackageData>.unmodifiable([
  for (final eyeMood in _faceEyeMoods)
    for (final mouth in _faceMouthDetails)
      PromptPackageData(
        id: 'face_${eyeMood.id}_${mouth.id}',
        name: '${eyeMood.name}・${mouth.name}',
        description: '${eyeMood.name}搭配${mouth.name}的臉部表情。',
        category: eyeMood.name,
        tags: [...eyeMood.tags, ...mouth.tags],
      ),
]);

const _faceEyeMoods = <_PackagePart>[
  _PackagePart('viewer', '正視鏡頭', ['looking at viewer']),
  _PackagePart('wink', '眨眼神情', ['wink']),
  _PackagePart('closed', '閉眼神情', ['closed eyes']),
  _PackagePart('happy', '開朗微笑', ['smile']),
  _PackagePart('shy', '羞澀臉紅', ['shy', 'blush']),
  _PackagePart('surprised', '驚訝反應', ['surprised']),
  _PackagePart('serious', '冷靜嚴肅', ['serious']),
  _PackagePart('angry', '生氣神情', ['angry']),
  _PackagePart('sad', '傷心落淚', ['tears']),
  _PackagePart('playful', '俏皮壞笑', ['smirk']),
];

const _faceMouthDetails = <_PackagePart>[
  _PackagePart('open', '張嘴', ['open mouth']),
  _PackagePart('grin', '露齒笑', ['grin', 'teeth']),
  _PackagePart('closed', '閉嘴', ['closed mouth']),
  _PackagePart('pout', '噘嘴', ['pout']),
  _PackagePart('round', '圓嘴', ['round mouth']),
  _PackagePart('cat', '貓嘴', [':3']),
  _PackagePart('tongue', '吐舌', ['tongue out']),
  _PackagePart('biting_lip', '咬唇', ['biting lip']),
  _PackagePart('parted_lips', '微張雙唇', ['parted lips']),
  _PackagePart('exhaling', '輕吐氣', ['exhaling']),
];
