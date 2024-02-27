import 'package:hank_pack_master/ui/work_shop/work_shop_vm.dart';

import '../../comm/typedef_functions.dart';

/// 任务阶段
class TaskState {
  String stageName;
  String? stageCostTime;
  StageStatue stageStatue = StageStatue.idle;
  dynamic executeResultData;

  // 当前阶段的行为, 返回null说明当前阶段正常，非null的情况分两种，一是有特殊输出的阶段，第二是结束阶段
  ActionFunc actionFunc;

  // 当前阶段结束之后的行为（无论成功或者失败）
  static OnStageFinishedFunc? onStateFinishedFunc;

  static OnStageStartedFunc? onStageStartedFunc;

  TaskState(this.stageName, {required this.actionFunc});
}

enum StageStatue { idle, executing, finished, error }
