import '../lib/clothing_taxonomy.dart';

void main() {
  final tags = [
    ...clothingTaxonomyTags,
    ...clothingDimensionTags,
    ...clothingOverallTags,
  ];
  final ids = <String>{};
  final duplicateIds = <String>{};
  final labels = <String>{};
  final duplicateLabels = <String>{};
  final groups = <String, int>{};

  for (final tag in tags) {
    if (!ids.add(tag.id)) duplicateIds.add(tag.id);
    final labelKey = '${tag.group}:${tag.en.trim().toLowerCase()}';
    if (!labels.add(labelKey)) duplicateLabels.add(labelKey);
    if (tag.zh.trim().isEmpty || tag.en.trim().isEmpty) {
      throw StateError('Empty clothing label: ${tag.id}');
    }
    if (tag.en.toLowerCase().contains('lolita')) {
      throw StateError('Forbidden clothing term: ${tag.en}');
    }
    groups.update(tag.group, (count) => count + 1, ifAbsent: () => 1);
  }

  if (duplicateIds.isNotEmpty) {
    throw StateError('Duplicate clothing ids: ${duplicateIds.join(', ')}');
  }
  if (duplicateLabels.isNotEmpty) {
    throw StateError(
        'Duplicate clothing labels: ${duplicateLabels.join(', ')}');
  }

  const requiredGroups = {
    '上衣',
    '褲子',
    '短褲',
    '裙子',
    '服裝',
    '外套',
    '特殊服裝',
    '鞋子',
    '服裝・主要風格',
    '服裝・子風格',
    '服裝・氣質',
    '服裝・場合',
  };
  final missingGroups = requiredGroups.difference(groups.keys.toSet());
  if (missingGroups.isNotEmpty) {
    throw StateError('Missing clothing groups: ${missingGroups.join(', ')}');
  }

  const requiredDimensions = {
    'cut',
    'fit',
    'length',
    'material',
    'detail',
    'pattern'
  };
  final dimensions = groups.keys
      .where((group) => group.startsWith('clothing_scope_'))
      .map((group) => requiredDimensions.firstWhere(
            (dimension) => group.endsWith('_$dimension'),
            orElse: () => '',
          ))
      .where((dimension) => dimension.isNotEmpty)
      .toSet();
  final missingDimensions = requiredDimensions.difference(dimensions);
  if (missingDimensions.isNotEmpty) {
    throw StateError(
        'Missing clothing dimensions: ${missingDimensions.join(', ')}');
  }

  print(
      'Clothing taxonomy OK: ${tags.length} tags in ${groups.length} groups.');
}
