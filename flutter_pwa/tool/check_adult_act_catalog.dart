import '../lib/expanded_tag_data.dart';

const _requiredByGroup = <String, List<String>>{
  '性行為・男性主動擺動': [
    'thrusting',
    'thrusting hard',
    'thrusting into pussy',
    'thrusting into ass',
    'thrusting into mouth',
    'hip thrust',
    'hip thrusts',
    'reverse pelvic thrust',
    'continue thrust after cum',
    'swaying penis',
    'bouncing penis',
    'bouncing testicles',
  ],
  '性行為・女性主動擺動': [
    'riding dildo',
    'riding strap-on',
    'grinding (sexual)',
    'pussy grinding',
    'ass grinding',
    'grinding on penis',
    'cooperative grinding (sexual)',
    'swaying hips',
    'hip sway',
    'swaying breasts',
    'bouncing ass',
    'bouncing thighs',
  ],
  '性行為・動態輔助': [
    'up and down thrusting',
    'back and forth thrusting',
    'side-to-side thrusting',
    'irregular breast jiggle',
    'irregular ass jiggle',
    'breasts and ass jiggling',
  ],
  '性行為・足交': [
    'footjob',
    'double footjob',
    'implied footjob',
    'cooperative footjob',
    'footjob with footwear',
    'footjob with shoes',
    'footjob with boots',
    'footjob with sandals',
    'footjob with legwear',
    'two-footed footjob',
    'reverse footjob',
    'footjob from behind',
    'female footjob',
    'footjob under table',
    'simulated footjob',
    'after footjob',
  ],
  '性行為・手交': [
    'handjob',
    'caressing testicles',
    'double handjob',
    'cooperative handjob',
    'nursing handjob',
    'cuddling handjob',
    'reverse nursing handjob',
    'reach-around',
    'two-handed handjob',
    'after handjob',
  ],
  '性行為・口交': [
    'oral',
    'anilingus',
    'rusty trombone',
    'breast sucking',
    'cunnilingus',
    'autocunnilingus',
    'implied cunnilingus',
    'fellatio',
    'assisted fellatio',
    'autofellatio',
    'cum swap',
    'deepthroat',
    'implied fellatio',
    'irrumatio',
    'cooperative fellatio',
    'multiple penis fellatio',
    'upright 69',
    'hug and suck',
    'licking testicle',
    'facesitting',
    'testicle sucking',
    'licking armpit',
    'after fellatio',
    'after oral',
  ],
  '性行為・肛交': [
    'anal',
    'imminent anal',
    'double anal',
    'triple anal',
    'multiple anal',
    'pegging',
    'after anal',
  ],
  '性行為・陰道性交': [
    'vaginal',
    'imminent vaginal',
    'double vaginal',
    'triple vaginal',
    'after vaginal',
  ],
};

const _requiredPositionTags = <String>{
  '69',
  'spooning',
  'on side',
  'folded',
  'knees to chest',
  'legs over head',
  'girl on top',
  'amazon position',
  'squatting cowgirl position',
  'reverse cowgirl position',
  'reverse squatting cowgirl position',
  'reverse upright straddle',
  'upright straddle',
  'boy on top',
  'anvil position',
  'standing missionary',
  'prone bone',
  'top-down bottom-up',
  'spitroast',
  'reverse spitroast',
};

void main() {
  final problems = <String>[];
  final byEnglish = <String, List<dynamic>>{};
  for (final tag in expandedPromptTags) {
    byEnglish.putIfAbsent(tag.en.toLowerCase(), () => []).add(tag);
  }

  for (final entry in _requiredByGroup.entries) {
    for (final english in entry.value) {
      final matches = byEnglish[english] ?? const [];
      if (matches.length != 1) {
        problems.add(
          'Expected exactly one "$english" entry, found ${matches.length}.',
        );
        continue;
      }
      final tag = matches.single;
      if (tag.group != entry.key) {
        problems.add(
          '"$english" must be in ${entry.key}, found ${tag.group}.',
        );
      }
      if (!tag.adult) problems.add('"$english" must be adult-only.');
      if (tag.zh.trim().isEmpty)
        problems.add('"$english" has no Chinese label.');
    }
  }

  for (final english in _requiredPositionTags) {
    final matches = byEnglish[english] ?? const [];
    if (matches.length != 1) {
      problems.add(
        'Expected exactly one sexual-position entry "$english", found ${matches.length}.',
      );
      continue;
    }
    final tag = matches.single;
    if (!tag.adult)
      problems.add('Sexual position "$english" must be adult-only.');
  }

  if (problems.isNotEmpty) throw StateError(problems.join('\n'));
  final count = _requiredByGroup.values.fold<int>(
    _requiredPositionTags.length,
    (sum, entries) => sum + entries.length,
  );
  print('Adult act catalog OK: $count act/position tags checked.');
}
