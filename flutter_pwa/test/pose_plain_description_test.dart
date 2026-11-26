import 'package:betterwaifu_prompt_builder/attached_outfit_reference_data.dart';
import 'package:betterwaifu_prompt_builder/pose_plain_description.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all supplied pose kits retain their original prompts', () {
    expect(attachedPosePackages, hasLength(1000));
    expect(attachedPosePackages.map((package) => package.id).toSet(),
        hasLength(1000));
    for (final package in attachedPosePackages) {
      expect(package.naturalPrompt, isNotEmpty);
      expect(package.description, isNotEmpty);
      expect(package.description, package.naturalPromptZh);
    }
    final first = attachedPosePackages.first;
    expect(first.naturalPrompt, contains('one hand touching hair'));
    expect(first.description, contains('一隻手輕碰頭髮'));
    expect(first.description, contains('重心放在一條腿上'));
    final pillow = attachedPosePackages[800];
    expect(pillow.description, contains('把大抱枕抱在胸前'));
    expect(pillow.description, contains('下巴靠在抱枕上'));
  });

  test('unknown details remain available without inventing a translation', () {
    final result =
        describeAttachedPose('standing, an unusual invented movement');
    expect(result, contains('站著'));
    expect(result, contains('其他細節（英文原文）：an unusual invented movement'));
  });
}
