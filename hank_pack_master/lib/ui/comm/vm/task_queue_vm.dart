import 'dart:collection';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';

class TaskQueueVm extends ChangeNotifier {
  final ListQueue<ProjectRecordEntity> _taskQueue =
      ListQueue<ProjectRecordEntity>();

  List<ProjectRecordEntity> getQueueList() {
    return _taskQueue.toList();
  }

  String taskQueueString() {
    return _taskQueue.map((e) {
      return "$e\n";
    }).toList().toString();
  }

  void enqueue(ProjectRecordEntity e) {
    _taskQueue.add(e);
    notifyListeners();
  }

  void refresh() {
    _taskQueue.clear();
    notifyListeners();
  }
}
