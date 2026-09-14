import '../lib/expanded_tag_data.dart';
import '../lib/single_person_pose_data.dart';

void main() {
  final problems = <String>[];
  final ids = <String>{};
  final english = <String>{};
  final counts = <String, int>{};

  if (singlePersonPoseTags.length != 100) {
    problems.add(
      'Expected 100 single-person poses, found ${singlePersonPoseTags.length}.',
    );
  }

  for (final tag in singlePersonPoseTags) {
    if (!ids.add(tag.id)) problems.add('Duplicate pose id: ${tag.id}.');
    if (!english.add(tag.en.toLowerCase())) {
      problems.add('Duplicate pose English label: ${tag.en}.');
    }
    if (tag.zh.trim().isEmpty || tag.en.trim().isEmpty) {
      problems.add('Missing Chinese or English label: ${tag.id}.');
    }
    if (!singlePersonPoseGroups.contains(tag.group)) {
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

  for (final group in singlePersonPoseGroups) {
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
  for (final tag in singlePersonPoseTags) {
    if ((allEnglishCounts[tag.en.toLowerCase()] ?? 0) > 1) {
      problems.add('Pose duplicates another expanded tag: ${tag.en}.');
    }
  }

  if (problems.isNotEmpty) throw StateError(problems.join('\n'));
  print(
    'Single-person poses OK: ${singlePersonPoseTags.length} tags '
    'in ${counts.length} groups.',
  );
}
