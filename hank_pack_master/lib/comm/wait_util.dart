/// 模拟耗时
waitSomeSec() async {
  await Future.delayed(const Duration(milliseconds: 50));
}

/// 模拟耗时
waitThreeSec() async {
  await Future.delayed(const Duration(seconds: 3));
}