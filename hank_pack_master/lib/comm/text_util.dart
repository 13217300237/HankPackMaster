extension StringEmpty on String? {
  bool empty() {
    if (this == null) return true;
    if (this!.isEmpty) return true;
    return false;
  }
}
