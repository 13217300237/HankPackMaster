import 'package:fluent_ui/fluent_ui.dart';
import 'package:jiffy/jiffy.dart';

enum StageStatue { idle, executing, finished, error }

class TaskState {
  String stageName;
  StageStatue stageStatue = StageStatue.idle;

  TaskState(this.stageName);
}

class ProjectTaskVm extends ChangeNotifier {
  List<TaskState> taskStateList = [];

  void init() {
    taskStateList.clear();
    taskStateList.add(TaskState("参数准备"));
    taskStateList.add(TaskState("工程克隆"));
    taskStateList.add(TaskState("工程结构检测"));
    taskStateList.add(TaskState("生成apk"));
    taskStateList.add(TaskState("apk检测"));
    notifyListeners();
  }

  Color idleColor = Colors.grey;
  Color executingColor = Colors.blue;
  Color finishedColor = Colors.green;
  Color errColor = Colors.red;

  Color getStatueColor(TaskState state) {
    switch (state.stageStatue) {
      case StageStatue.idle:
        return Colors.grey;
      case StageStatue.executing:
        return Colors.blue;
      case StageStatue.finished:
        return Colors.green;
      case StageStatue.error:
        return Colors.red;
    }
  }

  void updateStatue(int index, StageStatue newStatue) {
    TaskState c = taskStateList[index];
    c.stageStatue = newStatue;
    notifyListeners();
  }

  final List<String> _cmdExecLog = [];

  List<String> get cmdExecLog => _cmdExecLog;

  void cleanLog() {
    _cmdExecLog.clear();
    notifyListeners();
  }

  void addNewLogLine(String s) {
    _cmdExecLog
        .add("${Jiffy.now().format(pattern: "yyyy-MM-dd HH:mm:ss")}        $s");
    notifyListeners();
  }
}
