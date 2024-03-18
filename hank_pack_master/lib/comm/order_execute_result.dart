class OrderExecuteResult {
  // 执行结果的字符串文案
  final String? msg;

  // 是否执行成功
  final bool succeed;

  final dynamic data;

  String? executeLog; // 执行日志

  List<OrderExecuteResult>? children; // 允许自我嵌套

  OrderExecuteResult({
    this.msg,
    required this.succeed,
    this.data,
    this.executeLog,
    this.children,
  });

  void addChild(OrderExecuteResult child) {
    children ??= [];
    children!.add(OrderExecuteResult(
      succeed: child.succeed,
      msg: child.msg,
      data: child.data,
      executeLog: child.executeLog,
    ));
  }

  OrderExecuteResult? getLastChild() {
    if (children == null) {
      return null;
    }
    return children!.last;
  }

  @override
  String toString() {
    String dataStr = "";

    if (data != null) {
      dataStr = "$data";
    }

    return "${msg ?? ""} $dataStr";
  }
}
