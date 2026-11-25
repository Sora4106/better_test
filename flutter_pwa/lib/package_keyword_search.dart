final _keywordSeparators = RegExp(r'[\s_,，、／/・·-]+');

String _normalizeKeywords(String value) => value
    .toLowerCase()
    .split(_keywordSeparators)
    .where((s) => s.isNotEmpty)
    .join(' ');

/// A searchable preset. Normalization runs once for each built-in preset.
class PackageKeywordEntry<T> {
  PackageKeywordEntry({
    required this.value,
    required String name,
    required String category,
    required Iterable<String> keywords,
  })  : _name = _normalizeKeywords(name),
        _category = _normalizeKeywords(category),
        _content = _normalizeKeywords([name, category, ...keywords].join(' '));

  final T value;
  final String _name;
  final String _category;
  final String _content;
}

class PackageKeywordQuery {
  PackageKeywordQuery(String query) : _text = _normalizeKeywords(query);

  final String _text;

  bool get isEmpty => _text.isEmpty;

  List<T> find<T>(
    Iterable<PackageKeywordEntry<T>> entries, {
    bool Function(T)? available,
  }) {
    if (isEmpty) return <T>[];
    final terms = _text.split(' ');
    final ranked = List.generate(5, (_) => <T>[]);
    for (final entry in entries) {
      if (!terms.every(entry._content.contains) ||
          (available != null && !available(entry.value))) {
        continue;
      }
      final rank = entry._name == _text
          ? 0
          : entry._name.startsWith(_text)
              ? 1
              : entry._name.contains(_text)
                  ? 2
                  : terms.every(entry._category.contains)
                      ? 3
                      : 4;
      ranked[rank].add(entry.value);
    }
    return [for (final bucket in ranked) ...bucket];
  }
}
