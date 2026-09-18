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
// 臉部表情保留為可個別選取的標籤，不提供快速套裝。
