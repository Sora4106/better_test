import 'package:betterwaifu_prompt_builder/aeris_outfit_reference_data.dart';
import 'package:betterwaifu_prompt_builder/attached_outfit_reference_data.dart';
import 'package:betterwaifu_prompt_builder/package_keyword_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('searches the attached pose library by category and English prompt', () {
    final entries = [
      for (final pose in attachedPosePackages)
        PackageKeywordEntry(
          value: pose,
          name: pose.name,
          category: pose.category,
          keywords: [pose.description, pose.naturalPrompt],
        ),
    ];
    expect(entries, hasLength(1000));

    final sample = attachedPosePackages.first;
    final categoryMatches = PackageKeywordQuery(sample.category).find(entries);
    expect(categoryMatches, contains(sample));
    expect(
      PackageKeywordQuery(sample.name).find(entries).first,
      same(sample),
    );
    expect(
      PackageKeywordQuery('KNEELING').find(entries),
      isNotEmpty,
    );
  });

  test('matches outfit names, palette and garment keywords together', () {
    final entries = [
      for (final outfit in aerisOutfitReferencePresets)
        PackageKeywordEntry(
          value: outfit,
          name: outfit.name,
          category: outfit.category,
          keywords: [outfit.palette, outfit.unifiedPhraseEn!],
        ),
    ];

    final query = PackageKeywordQuery('皇家藍，armored_boots');
    expect(query.find(entries).map((outfit) => outfit.id), [
      'aeris_outfit_02',
    ]);
    expect(query.find(entries, available: (_) => false), isEmpty);
    expect(PackageKeywordQuery('  ／  ').find(entries), isEmpty);
    expect(PackageKeywordQuery('zz-no-such-outfit').find(entries), isEmpty);
  });
}
