import 'package:hank_pack_master/ui/work_shop/widgets/stage_task_card.dart';

import '../../comm/typedef_functions.dart';

/// 任务阶段
class TaskStage {
  String stageName;
  String? stageCostTime;
  StageStatue stageStatue = StageStatue.idle;
  dynamic executeResultData;
  TimerController timerController = TimerController(); // 阶段任务的正向计时器

  // 当前阶段的行为, 返回null说明当前阶段正常，非null的情况分两种，一是有特殊输出的阶段，第二是结束阶段
  ActionFunc stageAction;

  // 当前阶段结束之后的行为（无论成功或者失败）
  static OnStageFinishedFunc? onStateFinishedFunc;

  static OnStageStartedFunc? onStageStartedFunc;

  TaskStage(
    this.stageName, {
    required this.stageAction,
  });
}

enum StageStatue { idle, executing, finished, error }
