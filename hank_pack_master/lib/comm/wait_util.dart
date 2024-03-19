
/// 模拟耗时
waitSomeSec() async {
  await Future.delayed(const Duration(seconds: 1));
}

/// 等待下一轮
waitForNextRound() async {
  await Future.delayed(const Duration(seconds: 30));
}