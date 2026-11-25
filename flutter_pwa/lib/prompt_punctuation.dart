/// Splits prompt sentences while preserving decimal points in numbers.
List<String> splitPromptText(String value, {bool splitCommas = false}) {
  bool isDigit(int unit) => unit >= 48 && unit <= 57;

  final pieces = <String>[];
  final current = StringBuffer();
  void flush() {
    pieces.add(current.toString());
    current.clear();
  }

  for (var i = 0; i < value.length; i++) {
    final unit = value.codeUnitAt(i);
    if (unit == 46) {
      final nextIsDigit =
          i + 1 < value.length && isDigit(value.codeUnitAt(i + 1));
      final previous = i == 0 ? null : value.codeUnitAt(i - 1);
      // A leading decimal may follow a weight colon, whitespace, a sign,
      // or an opening parenthesis. Other periods separate prompt fragments.
      final decimalStart = previous == null ||
          previous == 58 ||
          previous == 40 ||
          previous == 43 ||
          previous == 45 ||
          String.fromCharCode(previous).trim().isEmpty;
      if (nextIsDigit && (decimalStart || isDigit(previous))) {
        current.write('.');
      } else {
        flush();
      }
    } else if (unit == 0x3002 ||
        unit == 59 ||
        unit == 10 ||
        unit == 13 ||
        (splitCommas && (unit == 44 || unit == 0xff0c || unit == 0x3001))) {
      flush();
    } else {
      current.writeCharCode(unit);
    }
  }
  flush();
  return pieces;
}
