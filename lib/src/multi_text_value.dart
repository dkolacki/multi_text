class MultiTextValue {
  MultiTextValue(String source) {
    if (source.contains('](')) {
      final trimmed = source.trim();
      final separated = trimmed.substring(1, trimmed.length - 1).split('](');
      args = separated[0].split(',').map((e) => e.trim()).toList();
      text = separated[1];
    } else {
      text = source;
      args = [];
    }
  }

  late final String text;
  late final List<String> args;
}
