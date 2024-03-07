extension StringEmpty on String? {
  bool empty() {
    if (this == null) return true;
    if (this!.isEmpty) return true;
    return false;
  }
}

extension FirstLineExtension on String? {
  String? getFirstLine() {
    if (this == null) {
      return null;
    }
    int end = this!.indexOf('\n');
    if (end == -1) {
      return this;
    }
    return this!.substring(0, end);
  }
}

String escapeBackslashes(String path) {
  return path.replaceAll(r'\', r'\\');
}

String extractFirstWordAfterAssemble(String input) {
  const String assemblePrefix = 'assemble';

  // 判断字符串是否以 assemble 开头
  if (input.startsWith(assemblePrefix)) {
    // 提取 assemble 后的部分
    String remaining = input.substring(assemblePrefix.length);

    // 使用正则表达式匹配第一个单词
    RegExpMatch? match = RegExp(r'[A-Z][a-z]*').firstMatch(remaining);

    if (match != null) {
      // 获取匹配到的单词并转化为小写
      String? firstWord = match.group(0)?.toLowerCase();
      return firstWord ?? "";
    }
  }

  // 如果没有匹配到合适的单词，返回空字符串或者其他你认为合适的默认值
  return '';
}
