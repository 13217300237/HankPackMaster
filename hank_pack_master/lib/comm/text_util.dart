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