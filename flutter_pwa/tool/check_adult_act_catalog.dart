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
    'guided footjob',
    'standing footjob',
    'footjob over clothes',
    'footjob under clothes',
    'footjob through footwear',
    'footjob during penetration',
    'autofootjob',
    'stealth footjob',
    'footjob invitation',
    'mutual footjob',
    'after footjob',
  ],
  '性行為・腿交／大腿摩擦': [
    'legjob',
    'thigh sex',
    'kneepit sex',
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
    'handjob gesture',
    'gloved handjob',
    'reverse grip handjob',
    'milking handjob',
    'guided handjob',
    'handjob under clothes',
    'handjob with legwear',
    'two-finger handjob',
    'three-finger handjob',
    'four-finger handjob',
    'simulated handjob',
    'stealth handjob',
    'onahole handjob',
    'after handjob',
  ],
  '性行為・手交動態': [
    'standing handjob',
    'kneeling handjob',
    'sitting handjob',
    'handjob from behind',
    'handjob with eye contact',
    'handjob, leaning forward',
    'handjob while kissing',
    'handjob with saliva',
    'handjob, alternating hand motion',
    'handjob, hand movement',
    'handjob, motion lines',
    'handjob, penis twitching',
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
    'fellatio gesture',
    'reverse fellatio',
    'cleanup fellatio',
    'covered fellatio',
    'simulated fellatio',
    'fellatio under mask',
    'fellatio through clothes',
    'sword-swallowing fellatio',
    'after fellatio',
    'after oral',
  ],
  '性行為・口交動態': [
    'kneeling fellatio',
    'standing fellatio',
    'lying down fellatio',
    'oral sex from above',
    'oral sex from below',
    'oral sex with eye contact',
    'oral sex, hand on penis',
    'oral sex, hands on head',
    'oral sex, tongue movement',
    'oral sex, head movement',
    'oral sex, saliva string',
    'oral sex, cheek bulge',
    'oral sex, motion lines',
    'after oral, licking lips',
  ],
  '性行為・舔舐動態': [
    'licking penis',
    'licking penis, licking tip',
    'licking glans',
    'licking shaft',
    'licking clitoris',
    'licking labia',
    'licking breast',
    'licking neck',
    'licking ear',
    'tongue touching',
    'licking, motion lines',
  ],
  '性行為・口交・部位／舌法': [
    'oral sex, tongue lightly licking the glans',
    'oral sex, tongue moving up and down the penis shaft',
    'oral sex, licking the penis base',
    'oral sex, licking the underside of the penis',
    'oral sex, circling tongue around the penis',
    'oral sex, circling tongue around the glans',
    'oral sex, licking testicles and scrotum',
    'oral sex, licking before taking penis into mouth',
    'oral sex, alternating tongue licking and lip suction',
  ],
  '性行為・手交・精細動作': [
    'handjob, one hand stroking up and down',
    'handjob, two hands alternating up and down',
    'handjob, rotating wrist motion',
    'handjob, gripping penis base',
    'handjob, thumb stimulation on glans',
    'handjob, fingers sliding along penis shaft',
    'handjob while licking penis',
    'handjob, slow stroking motion',
    'handjob, rapid stroking motion',
  ],
  '性行為・足／腿交・精細動作': [
    'footjob, both feet sliding up and down penis',
    'footjob, soles rubbing back and forth',
    'footjob, toes touching penis',
    'thigh sex, thighs rubbing back and forth',
    'legjob, squeezing motion',
    'kneepit sex, squeezing motion',
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

const _requiredMotionEffectTags = <String>{
  'speed lines',
  'emphasis lines',
  'afterimage',
  'wind lift',
  'dust cloud',
  'shockwave',
  'sound effects',
};

const _naturalLanguageDetailGroups = <String>{
  '性行為・口交・部位／舌法',
  '性行為・手交・精細動作',
  '性行為・足／腿交・精細動作',
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
      if (_naturalLanguageDetailGroups.contains(entry.key) &&
          tag.support != 'description') {
        problems.add('"$english" must be marked as a natural-language helper.');
      }
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

  for (final english in _requiredMotionEffectTags) {
    final matches = byEnglish[english] ?? const [];
    if (matches.length != 1) {
      problems.add(
        'Expected exactly one motion-effect entry "$english", found ${matches.length}.',
      );
      continue;
    }
    final tag = matches.single;
    if (tag.group != '動態輔助・官方效果') {
      problems.add('"$english" must be in 動態輔助・官方效果, found ${tag.group}.');
    }
    if (tag.adult)
      problems.add('"$english" must remain usable outside adult mode.');
    if (tag.support != 'standard') {
      problems.add('"$english" must be marked as an official-style tag.');
    }
  }

  if (problems.isNotEmpty) throw StateError(problems.join('\n'));
  final count = _requiredByGroup.values.fold<int>(
    _requiredPositionTags.length + _requiredMotionEffectTags.length,
    (sum, entries) => sum + entries.length,
  );
  print('Adult act catalog OK: $count act/position tags checked.');
}
