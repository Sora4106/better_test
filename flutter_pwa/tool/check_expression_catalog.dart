import '../lib/expression_catalog_data.dart';

void main() {
  final problems = <String>[];
  final ids = <String>{};
  final english = <String>{};
  final categoryCounts = <String, int>{};

  if (expressionCatalogTags.length < 120) {
    problems.add(
      'Expected at least 120 expression tags, found '
      '${expressionCatalogTags.length}.',
    );
  }

  for (final tag in expressionCatalogTags) {
    if (!ids.add(tag.id)) problems.add('Duplicate expression ID: ${tag.id}.');
    if (!english.add(tag.en.trim().toLowerCase())) {
      problems.add('Duplicate expression English tag: ${tag.en}.');
    }
    if (tag.zh.trim().isEmpty || tag.en.trim().isEmpty) {
      problems.add('${tag.id}: missing Chinese or English text.');
    }
    if (tag.group != '表情') {
      problems.add('${tag.id}: expression is stored in ${tag.group}.');
    }
    if (tag.support != 'official') {
      problems.add('${tag.id}: support must be official.');
    }
    if (RegExp(r'\b(?:fearful|scared)\b', caseSensitive: false)
            .hasMatch(tag.en) ||
        tag.zh.contains('害怕')) {
      problems.add('${tag.id}: contains a disabled fear term.');
    }

    final category = switch (tag.id) {
      final id when id.startsWith('expression_catalog_eyes_') => 'eyes',
      final id when id.startsWith('expression_catalog_mouth_') => 'mouth',
      final id when id.startsWith('expression_catalog_teasing_adult_') =>
        'teasing_adult',
      final id when id.startsWith('expression_catalog_teasing_') => 'teasing',
      final id when id.startsWith('expression_catalog_symbols_') => 'symbols',
      final id when id.startsWith('expression_catalog_emotion_') => 'emotion',
      _ => 'unknown',
    };
    categoryCounts.update(category, (value) => value + 1, ifAbsent: () => 1);
  }

  const minimumCounts = <String, int>{
    'eyes': 25,
    'mouth': 20,
    'teasing': 2,
    'teasing_adult': 6,
    'symbols': 20,
    'emotion': 30,
  };
  for (final entry in minimumCounts.entries) {
    final count = categoryCounts[entry.key] ?? 0;
    if (count < entry.value) {
      problems.add(
        '${entry.key}: expected at least ${entry.value} tags, found $count.',
      );
    }
  }
  if ((categoryCounts['unknown'] ?? 0) > 0) {
    problems.add('Unrouted expression tags: ${categoryCounts['unknown']}.');
  }

  if (problems.isNotEmpty) throw StateError(problems.join('\n'));
  print(
    'Expression catalogue OK: ${expressionCatalogTags.length} tags; '
    '$categoryCounts.',
  );
}
