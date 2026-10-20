import '../lib/catalog_data.dart';
import '../lib/curated_pose_extension_data.dart';
import '../lib/expanded_tag_data.dart';
import '../lib/single_person_pose_data.dart';

void main() {
  final problems = <String>[];
  final ids = <String>{};
  final english = <String>{};
  final chineseToEnglish = <String, String>{};
  final counts = <String, int>{};

  if (singlePersonPoseTags.length != 100) {
    problems.add(
      'Expected 100 single-person poses, found ${singlePersonPoseTags.length}.',
    );
  }

  if (curatedPoseExtensionTags.length != 215) {
    problems.add(
      'Expected 215 curated pose and motion tags, found '
      '${curatedPoseExtensionTags.length}.',
    );
  }

  final poseTags = [
    ...singlePersonPoseTags,
    ...curatedPoseExtensionTags,
  ];
  final poseGroups = <String>{
    ...singlePersonPoseGroups,
    ...curatedPoseExtensionGroups,
  };
  for (final tag in poseTags) {
    if (!ids.add(tag.id)) problems.add('Duplicate pose id: ${tag.id}.');
    if (!english.add(tag.en.toLowerCase())) {
      problems.add('Duplicate pose English label: ${tag.en}.');
    }
    final chinese = tag.zh.trim();
    final normalizedEnglish = tag.en.trim().toLowerCase();
    final previousEnglish = chineseToEnglish[chinese];
    if (previousEnglish != null && previousEnglish != normalizedEnglish) {
      problems.add(
        'Ambiguous Chinese pose label: $chinese maps to both '
        '"$previousEnglish" and "${tag.en}".',
      );
    } else if (chinese.isNotEmpty) {
      chineseToEnglish[chinese] = normalizedEnglish;
    }
    if (tag.zh.trim().isEmpty || tag.en.trim().isEmpty) {
      problems.add('Missing Chinese or English label: ${tag.id}.');
    }
    if (!poseGroups.contains(tag.group)) {
      problems.add('Unknown pose group: ${tag.group}.');
    }
    if (tag.adult) problems.add('General pose marked adult: ${tag.id}.');
    if (tag.conflictGroup != null) {
      problems.add('Single-person pose must remain composable: ${tag.id}.');
    }
    if (RegExp(
      r'\b(baby|child|children|kid|kids|teen|teenage|minor|underage|loli|shota)\b',
      caseSensitive: false,
    ).hasMatch(tag.en)) {
      problems.add('Age-sensitive pose label: ${tag.en}.');
    }
    counts.update(tag.group, (value) => value + 1, ifAbsent: () => 1);
  }

  for (final group in poseGroups) {
    if ((counts[group] ?? 0) == 0) problems.add('Empty pose group: $group.');
    final sectionExists = expandedTagPickerSections.values.any(
      (groups) => groups.contains(group),
    );
    if (!sectionExists) problems.add('Pose group is not routed in UI: $group.');
  }

  final allEnglishCounts = <String, int>{};
  for (final tag in expandedPromptTags) {
    allEnglishCounts.update(
      tag.en.toLowerCase(),
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }
  for (final tag in poseTags) {
    if ((allEnglishCounts[tag.en.toLowerCase()] ?? 0) > 1) {
      problems.add('Pose duplicates another expanded tag: ${tag.en}.');
    }
  }

  final allGeneralChineseToEnglish = <String, String>{};
  final generalPoseSources = <CatalogTagData>[
    ...expandedPromptTags,
    ...supplementalTags,
  ];
  for (final tag in generalPoseSources.where(
    (tag) => expandedGeneralPoseGroups.contains(tag.group) && !tag.adult,
  )) {
    final chinese = tag.zh.trim();
    final normalizedEnglish = tag.en.trim().toLowerCase();
    final previousEnglish = allGeneralChineseToEnglish[chinese];
    if (previousEnglish != null && previousEnglish != normalizedEnglish) {
      problems.add(
        'Ambiguous Chinese label across general pose tags: $chinese maps to '
        'both "$previousEnglish" and "${tag.en}".',
      );
    } else if (chinese.isNotEmpty) {
      allGeneralChineseToEnglish[chinese] = normalizedEnglish;
    }
  }

  if (problems.isNotEmpty) throw StateError(problems.join('\n'));
  print(
    'Single-person poses OK: ${poseTags.length} tags '
    'in ${counts.length} groups.',
  );
}
