class TempLogCacheEntity {
  final StringBuffer _tempLog = StringBuffer();

  void clear() {
    _tempLog.clear();
  }

  String get() {
    return _tempLog.toString();
  }

  void append(String s) {
    _tempLog.writeln(s);
  }
}
