import '../lib/expanded_tag_data.dart';

const _requiredOfficialFluidTags = <String>{
  'blood',
  'saliva',
  'sweat',
  'tears',
  'snot',
  'vomit',
  'scat',
  'blood splatter',
  'menstrual blood',
  'saliva trail',
  'very sweaty',
  'streaming tears',
  'cum',
  'cum in throat',
  'cum on fingers',
  'cum through clothes',
  'cumdrip',
  'cum puddle',
  'precum',
  'precum string',
  'pussy juice',
  'pussy juice drip',
  'female ejaculation',
  'female ejaculation through clothes',
  'lactation',
  'projectile lactation',
};

const _retiredUrinationTags = <String>{
  'pee',
  'peeing',
  'peeing self',
  'urine',
  'urination',
  'piss',
  'golden shower',
};

void main() {
  final fluidTags = expandedPromptTags
      .where((tag) => tag.id.startsWith('body_fluids_'))
      .toList();
  final problems = <String>[];
  final byEnglish = <String, List<dynamic>>{};
  final ids = <String>{};

  for (final tag in fluidTags) {
    final english = tag.en.trim().toLowerCase();
    byEnglish.putIfAbsent(english, () => []).add(tag);
    if (!ids.add(tag.id)) problems.add('Duplicate body-fluid id: ${tag.id}.');
    if (!tag.adult) problems.add('"${tag.en}" must be adult-only.');
    if (tag.zh.trim().isEmpty)
      problems.add('"${tag.en}" has no Chinese label.');
    if (_retiredUrinationTags.contains(english)) {
      problems.add('Retired urination tag remains: "${tag.en}".');
    }
  }

  for (final entry in byEnglish.entries) {
    if (entry.value.length > 1) {
      problems.add(
        'Duplicate body-fluid English tag "${entry.key}" '
        '(${entry.value.length} entries).',
      );
    }
  }

  for (final english in _requiredOfficialFluidTags) {
    final matches = byEnglish[english] ?? const [];
    if (matches.length != 1) {
      problems.add(
        'Expected exactly one body-fluid tag "$english", found ${matches.length}.',
      );
    }
  }

  if (fluidTags.length < 160) {
    problems.add(
      'Expected at least 160 official body-fluid tags, found ${fluidTags.length}.',
    );
  }

  if (problems.isNotEmpty) throw StateError(problems.join('\n'));
  print('Body-fluid catalog OK: ${fluidTags.length} tags, no urination tags.');
}
