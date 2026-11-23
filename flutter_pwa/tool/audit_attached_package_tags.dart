import 'dart:io';

import '../lib/attached_outfit_reference_data.dart';
import '../lib/attached_standalone_tag_data.dart';
import '../lib/catalog_data.dart';
import '../lib/clothing_taxonomy.dart';
import '../lib/curated_pose_extension_data.dart';
import '../lib/elsword_job_outfit_data.dart';
import '../lib/expanded_tag_data.dart';
import '../lib/expression_catalog_data.dart';
import '../lib/finger_gesture_data.dart';
import '../lib/object_catalog_data.dart';
import '../lib/single_person_pose_data.dart';

String _key(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll(RegExp(r'\s*,\s*$'), '');

Set<String> _catalogEnglish({bool includeAttached = true}) {
  final rows = <CatalogTagData>[
    ...supplementalTags,
    ...expandedPromptTags,
    ...expressionCatalogTags,
    ...objectCatalogTags,
    ...elswordJobWeaponTags,
    ...clothingTaxonomyTags,
    ...clothingDimensionTags,
    ...clothingOverallTags,
    ...singlePersonPoseTags,
    ...curatedPoseExtensionTags,
    ...fingerGestureTags,
    if (includeAttached) ...attachedStandaloneTags,
  ];
  return rows
      .map((row) => _key(row.en))
      .where((value) => value.isNotEmpty)
      .toSet();
}

Set<String> _seedEnglish() {
  final source = File('lib/main.dart').readAsStringSync();
  final result = <String>{};
  var cursor = 0;
  while (true) {
    final start = source.indexOf('_tag(', cursor);
    if (start < 0) break;
    var quote = '';
    var escaped = false;
    var depth = 1;
    var index = start + 5;
    final body = StringBuffer();
    for (; index < source.length; index++) {
      final character = source[index];
      if (quote.isNotEmpty) {
        body.write(character);
        if (escaped) {
          escaped = false;
        } else if (character == r'\') {
          escaped = true;
        } else if (character == quote) {
          quote = '';
        }
        continue;
      }
      if (character == "'" || character == '"') {
        quote = character;
        body.write(character);
      } else if (character == '(') {
        depth++;
        body.write(character);
      } else if (character == ')') {
        depth--;
        if (depth == 0) break;
        body.write(character);
      } else {
        body.write(character);
      }
    }
    cursor = index + 1;
    final arguments = _splitArguments(body.toString());
    if (arguments.length < 4) continue;
    final english = _literal(arguments[3]);
    if (english != null && english.isNotEmpty) result.add(_key(english));
  }
  return result;
}

List<String> _splitArguments(String value) {
  final result = <String>[];
  final current = StringBuffer();
  var quote = '';
  var escaped = false;
  var depth = 0;
  for (var index = 0; index < value.length; index++) {
    final character = value[index];
    if (quote.isNotEmpty) {
      current.write(character);
      if (escaped) {
        escaped = false;
      } else if (character == r'\') {
        escaped = true;
      } else if (character == quote) {
        quote = '';
      }
      continue;
    }
    if (character == "'" || character == '"') {
      quote = character;
      current.write(character);
    } else if ('([{'.contains(character)) {
      depth++;
      current.write(character);
    } else if (')]}'.contains(character)) {
      depth--;
      current.write(character);
    } else if (character == ',' && depth == 0) {
      result.add(current.toString().trim());
      current.clear();
    } else {
      current.write(character);
    }
  }
  result.add(current.toString().trim());
  return result;
}

String? _literal(String value) {
  final trimmed = value.trim();
  if (trimmed.length < 2) return null;
  final quote = trimmed[0];
  if ((quote != "'" && quote != '"') || trimmed[trimmed.length - 1] != quote) {
    return null;
  }
  return trimmed
      .substring(1, trimmed.length - 1)
      .replaceAll(r"\'", "'")
      .replaceAll(r'\"', '"');
}

Set<String> _segments(Iterable<String> phrases) => phrases
    .expand((phrase) => phrase.split(','))
    .map(_key)
    .where((value) => value.isNotEmpty)
    .toSet();

Map<String, int> _segmentCounts(Iterable<String> phrases) {
  final result = <String, int>{};
  for (final phrase in phrases) {
    for (final segment in phrase.split(',').map(_key)) {
      if (segment.isEmpty) continue;
      result.update(segment, (value) => value + 1, ifAbsent: () => 1);
    }
  }
  return result;
}

void main() {
  final seed = _seedEnglish();
  final knownBefore = <String>{
    ..._catalogEnglish(includeAttached: false),
    ...seed,
  };
  final known = <String>{..._catalogEnglish(), ...seed};
  final outfitPhrases = attachedOutfitReferencePresets
      .map((preset) => preset.unifiedPhraseEn ?? '')
      .toList(growable: false);
  final posePhrases = attachedPosePackages
      .map((package) => package.naturalPrompt)
      .toList(growable: false);
  final outfit = _segments(outfitPhrases);
  final pose = _segments(posePhrases);
  final outfitCounts = _segmentCounts(outfitPhrases);
  final missingOutfitBefore = outfit.difference(knownBefore);
  final missingOutfit = outfit.difference(known).toList()..sort();
  final missingPose = pose.difference(known).toList()..sort();
  final standalonePoseEnglish =
      attachedPoseStandaloneTags.map((tag) => _key(tag.en)).toSet();
  final missingStandalonePose = standalonePoseEnglish.difference(known);
  final newStandalonePose = standalonePoseEnglish.difference(knownBefore);
  final duplicateIds = <String>{};
  final seenIds = <String>{};
  for (final tag in attachedStandaloneTags) {
    if (!seenIds.add(tag.id)) duplicateIds.add(tag.id);
    if (tag.zh.trim().isEmpty || tag.en.trim().isEmpty) {
      stderr.writeln('EMPTY\t${tag.id}\t${tag.zh}\t${tag.en}');
      exitCode = 1;
    }
  }
  if (duplicateIds.isNotEmpty) {
    stderr.writeln('DUPLICATE_IDS\t${duplicateIds.join(',')}');
    exitCode = 1;
  }

  final fallbackOutfit =
      attachedOutfitStandaloneTags.where((tag) => tag.zh == '套裝服裝片段').length;
  final fallbackPose =
      attachedPoseStandaloneTags.where((tag) => tag.zh == '可獨立選擇的姿勢細節').length;
  const outfitGroups = <String>{
    '服裝',
    '上衣',
    '褲子',
    '裙子',
    '外套',
    '襪子',
    '鞋子',
    '配件',
    '服裝材質',
    '服裝細節',
  };
  const poseGroups = <String>{
    '畫面',
    '場景',
    '坐姿與跪姿',
    '躺臥姿勢',
    '站立與蹲姿',
    '表情',
    '頭部姿勢',
    '手部姿勢',
    '手臂姿勢',
    '腿部姿勢',
    '軀幹姿勢',
    '全身姿勢',
  };
  final invalidOutfitGroups = attachedOutfitStandaloneTags
      .where((tag) => !outfitGroups.contains(tag.group))
      .toList(growable: false);
  final invalidPoseGroups = attachedPoseStandaloneTags
      .where((tag) => !poseGroups.contains(tag.group))
      .toList(growable: false);
  for (final tag
      in attachedOutfitStandaloneTags.where((tag) => tag.zh == '套裝服裝片段')) {
    stdout.writeln('FALLBACK_OUTFIT\t${tag.en}');
  }
  for (final tag
      in attachedPoseStandaloneTags.where((tag) => tag.zh == '可獨立選擇的姿勢細節')) {
    stdout.writeln('FALLBACK_POSE\t${tag.en}');
  }
  stdout
      .writeln('knownBefore=${knownBefore.length} knownAfter=${known.length}');
  stdout.writeln(
      'outfitSegments=${outfit.length} missingBefore=${missingOutfitBefore.length} missingAfter=${missingOutfit.length}');
  for (final value in missingOutfit) {
    stdout.writeln('OUTFIT\t${outfitCounts[value]}\t$value');
  }
  stdout.writeln(
      'poseSegments=${pose.length} contextualOrOneOff=${missingPose.length}');
  stdout.writeln(
    'registeredOutfit=${attachedOutfitStandaloneTags.length} '
    'registeredPose=${attachedPoseStandaloneTags.length} '
    'newOutfit=${missingOutfitBefore.length} '
    'newPose=${newStandalonePose.length} '
    'missingStandalonePose=${missingStandalonePose.length} '
    'fallbackOutfit=$fallbackOutfit fallbackPose=$fallbackPose',
  );
  stdout.writeln(
    'outfitPackages=${attachedOutfitReferencePresets.length} '
    'posePackages=${attachedPosePackages.length} '
    'invalidOutfitGroups=${invalidOutfitGroups.length} '
    'invalidPoseGroups=${invalidPoseGroups.length}',
  );
  if (missingOutfit.isNotEmpty ||
      missingStandalonePose.isNotEmpty ||
      fallbackOutfit != 0 ||
      fallbackPose != 0 ||
      attachedOutfitReferencePresets.length != 60 ||
      attachedPosePackages.length != 1000 ||
      invalidOutfitGroups.isNotEmpty ||
      invalidPoseGroups.isNotEmpty) {
    exitCode = 1;
  }
}
