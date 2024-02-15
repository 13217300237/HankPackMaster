import 'dart:async';
import 'dart:collection';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';

class TaskQueueVm extends ChangeNotifier {
  final ListQueue<ProjectRecordEntity> _taskQueue =
      ListQueue<ProjectRecordEntity>();

  bool hasTask() => _taskQueue.isNotEmpty;

  List<ProjectRecordEntity> getQueueList() => _taskQueue.toList();

  String taskQueueString() => _taskQueue.map((e) => "$e\n").toList().toString();

  void enqueue(ProjectRecordEntity e) {
    _taskQueue.add(e);
    _loop();
    notifyListeners();
  }

  void refresh() {
    _taskQueue.clear();
    notifyListeners();
  }

  ProjectRecordEntity? runningTask;

  Timer? taskTimer;

  void _loop() {
    if (taskTimer != null) {
      // 只允许一个定时器
      return;
    }
    // 每隔3秒，查找队列中是否有任务
    taskTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (runningTask == null) {
        runningTask = _taskQueue.removeFirst();
        debugPrint("当前正在执行的任务为空，现在开始此任务： ${runningTask!.projectName}");
        notifyListeners();
      }
    });
  }
}
