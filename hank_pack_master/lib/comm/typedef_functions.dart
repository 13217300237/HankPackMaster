
import 'order_execute_result.dart';

typedef ActionFunc = Future<OrderExecuteResult> Function();

typedef OnStageFinishedFunc = Function(int, String);

typedef OnStageStartedFunc = Function(int);