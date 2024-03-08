class OrderExecuteResult {
  // 执行结果的字符串文案
  final String? msg;

  // 是否执行成功
  final bool succeed;

  final dynamic data;

  String? executeLog; // 执行日志

  OrderExecuteResult({
    this.msg,
    required this.succeed,
    this.data,
    this.executeLog,
  });

  @override
  String toString() {
    String dataStr = "";

    if (data != null) {
      dataStr = "$data";
    }

    return "${msg ?? ""} $dataStr";
  }
}
