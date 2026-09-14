import '../lib/expanded_tag_data.dart';
import '../lib/finger_gesture_data.dart';

void main() {
  final problems = <String>[];
  const expectedCount = 60;
  if (fingerGestureTags.length != expectedCount) {
    problems.add(
        'Expected $expectedCount finger gestures, found ${fingerGestureTags.length}.');
  }

  final ids = <String>{};
  final english = <String>{};
  for (final tag in fingerGestureTags) {
    if (!ids.add(tag.id)) problems.add('Duplicate ID: ${tag.id}.');
    if (!english.add(tag.en.toLowerCase())) {
      problems.add('Duplicate English tag: ${tag.en}.');
    }
    if (tag.zh.trim().isEmpty || tag.en.trim().isEmpty) {
      problems.add('${tag.id}: missing Chinese or English text.');
    }
    if (!fingerGestureGroups.contains(tag.group)) {
      problems.add('${tag.id}: unknown group ${tag.group}.');
    }
    if (tag.support != 'official' && tag.support != 'description') {
      problems.add('${tag.id}: invalid support ${tag.support}.');
    }
    if (tag.adult) problems.add('${tag.id}: unexpectedly marked adult.');
    if (tag.conflictGroup != null) {
      problems.add('${tag.id}: finger gestures must remain stackable.');
    }
    final matches = expandedPromptTags
        .where(
            (candidate) => candidate.en.toLowerCase() == tag.en.toLowerCase())
        .length;
    if (matches != 1) {
      problems.add(
          '${tag.id}: English text appears $matches times in expanded tags.');
    }
  }

  final routedGroups =
      expandedTagPickerSections.values.expand((it) => it).toSet();
  for (final group in fingerGestureGroups) {
    if (!routedGroups.contains(group)) {
      problems.add('Group is not routed to the picker: $group.');
    }
  }

  if (problems.isNotEmpty) throw StateError(problems.join('\n'));
  print('Finger gestures OK: ${fingerGestureTags.length} tags in '
      '${fingerGestureGroups.length} groups.');
}
