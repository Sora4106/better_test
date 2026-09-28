import '../lib/prompt_package_data.dart';

void main() {
  final problems = <String>[];
  final ids = <String>{};
  final chinese = RegExp(r'[\u4e00-\u9fff]');

  for (final package in lalaWolfGirlPosePackages) {
    if (!ids.add(package.id)) {
      problems.add('Duplicate wolf-girl package id: ${package.id}.');
    }
    if (!chinese.hasMatch(package.name) ||
        !chinese.hasMatch(package.description) ||
        !chinese.hasMatch(package.category)) {
      problems.add('Missing Chinese package metadata: ${package.id}.');
    }
    if (package.naturalPrompt.trim().isEmpty ||
        chinese.hasMatch(package.naturalPrompt)) {
      problems.add('Invalid English natural prompt: ${package.id}.');
    }
    if (!chinese.hasMatch(package.naturalPromptZh)) {
      problems.add('Missing Chinese natural prompt: ${package.id}.');
    }
  }

  if (problems.isNotEmpty) throw StateError(problems.join('\n'));
  print(
    'Wolf-girl package translations OK: '
    '${lalaWolfGirlPosePackages.length} bilingual packages.',
  );
}
