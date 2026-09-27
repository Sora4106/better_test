/// Reusable hairstyle presets. Applying a preset only checks ordinary hair
/// tags, so every colour, length, and style remains editable afterwards.
class HairStylePackageData {
  const HairStylePackageData({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    this.gradientColors = const <String>[],
    this.gradientStyle = 'linear',
  });

  final String id;
  final String name;
  final String description;
  final List<String> tags;

  /// Ordered as colour 1 then colour 2, matching the hairstyle gradient UI.
  final List<String> gradientColors;
  final String gradientStyle;
}

const hairStylePackages = <HairStylePackageData>[
  HairStylePackageData(
    id: 'wolf_girl_white_pink_layered_side_braid',
    name: '白粉層次側辮',
    description: '極長白髮漸層淡粉，帶層次、飄逸髮束與粉紅緞帶側辮。',
    tags: [
      'very long hair',
      'layered long hair',
      'tousled hair',
      'windswept hair',
      'separated hair strands',
      'feathered hair',
      'voluminous flowing hair',
      'uneven wispy ends',
      'loose face-framing strands',
      'pink ribbon-tied side braid',
    ],
    gradientColors: ['white hair', 'light pink hair'],
    gradientStyle: 'tips',
  ),
  HairStylePackageData(
    id: 'wolf_girl_white_pink_windswept',
    name: '白粉迎風長髮',
    description: '極長白髮以淡粉髮尾漸層，保留自然分束與迎風動態。',
    tags: [
      'very long hair',
      'layered long hair',
      'windswept hair',
      'separated hair strands',
      'voluminous flowing hair',
      'loose face-framing strands',
    ],
    gradientColors: ['white hair', 'light pink hair'],
    gradientStyle: 'tips',
  ),
  HairStylePackageData(
    id: 'wolf_girl_white_pink_soft_tousled',
    name: '白粉柔亂長髮',
    description: '極長白粉漸層髮，使用柔和微亂、羽毛剪與碎薄髮尾。',
    tags: [
      'very long hair',
      'layered long hair',
      'tousled hair',
      'feathered hair',
      'uneven wispy ends',
      'loose face-framing strands',
    ],
    gradientColors: ['white hair', 'light pink hair'],
    gradientStyle: 'tips',
  ),
];
