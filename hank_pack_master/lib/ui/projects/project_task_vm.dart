import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:jiffy/jiffy.dart';

import '../../comm/sp_util.dart';
import '../../core/command_util.dart';

enum StageStatue { idle, executing, finished, error }

class TaskState {
  String stageName;
  StageStatue stageStatue = StageStatue.idle;
  Function? actionFunc; // 当前阶段的行为

  TaskState(this.stageName, {this.actionFunc});
}

/// 模拟耗时
waitOneSec() async {
  await Future.delayed(const Duration(milliseconds: 1000));
}

class ProjectTaskVm extends ChangeNotifier {
  final gitUrlController = TextEditingController(); // git地址
  final gitBranchController = TextEditingController(); // 分支名称
  final projectPathController = TextEditingController(); // 工程路径

  final List<TaskState> taskStateList = [];

  final List<String> _cmdExecLog = [];

  List<String> get cmdExecLog => _cmdExecLog;

  void init() {
    taskStateList.clear();

    taskStateList.add(TaskState("参数准备"));
    taskStateList.add(TaskState("工程克隆"));
    taskStateList.add(TaskState("分支切换"));
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

  void cleanLog() {
    _cmdExecLog.clear();
    notifyListeners();
  }

  void addNewLogLine(String s) {
    _cmdExecLog
        .add("${Jiffy.now().format(pattern: "yyyy-MM-dd HH:mm:ss")}        $s");
    notifyListeners();
  }

  String get gitUrl => gitUrlController.text;

  String get projectPath => projectPathController.text;

  String get envWorkspaceRoot => SpUtil.getValue(SpConst.envWorkspaceRootKey);

  ///
  /// 开始流水线工作
  ///
  Future<String> startSchedule(
      {required Function(String s) cmdLogCallback}) async {
    cmdLogCallback("开始流程...");

    // for (int i = 0; i < projectTaskVm.taskStateList.length; i++) {
    //   var e = projectTaskVm.taskStateList[i];
    //   e.actionFunc?.call();
    // }

    // 阶段0
    // 参数准备
    // git地址
    await waitOneSec();
    updateStatue(0, StageStatue.executing);
    cmdLogCallback("gitUrl-> $gitUrl");
    // 参数：工程本地位置
    cmdLogCallback("projectRoot-> $projectPath...");
    if (gitUrl.isEmpty) {
      updateStatue(0, StageStatue.error);
      return "git仓库地址 不能为空";
    }
    if (projectPath.isEmpty) {
      updateStatue(0, StageStatue.error);
      return "工程根目录 不能为空";
    }
    updateStatue(0, StageStatue.finished);

    // =========================================================================
    // clone 阶段
    await waitOneSec();
    updateStatue(1, StageStatue.executing);
    cmdLogCallback("clone开始...");

    ExecuteResult gitCloneRes = await CommandUtil.getInstance().gitClone(
        clonePath: envWorkspaceRoot, gitUrl: gitUrl, logOutput: cmdLogCallback);
    cmdLogCallback("clone完毕，结果是  $gitCloneRes");

    if (gitCloneRes.exitCode != 0) {
      cmdLogCallback("clone失败，具体问题请看日志...");
      updateStatue(1, StageStatue.error);
      return gitCloneRes.res;
    }
    updateStatue(1, StageStatue.finished);
    // =========================================================================
    // checkout 阶段
    await waitOneSec();
    updateStatue(2, StageStatue.executing);
    cmdLogCallback("checkout 开始...");

    ExecuteResult gitCheckoutRes = await CommandUtil.getInstance().gitCheckout(
        projectPathController.text, gitBranchController.text, cmdLogCallback);
    cmdLogCallback("checkout 完毕，结果是  $gitCheckoutRes");

    if (gitCheckoutRes.exitCode != 0) {
      cmdLogCallback("checkout  失败，具体问题请看日志...");
      updateStatue(2, StageStatue.error);
      return gitCheckoutRes.res;
    }
    updateStatue(2, StageStatue.finished);
    // =========================================================================
    await waitOneSec();
    updateStatue(3, StageStatue.executing);
    cmdLogCallback("开始检查工程目录结构...");
    // 阶段2，工程结构检查
    // 检查目录下是否有 gradlew.bat 文件
    File gradlewFile = File("$projectPath${Platform.pathSeparator}gradlew.bat");
    if (!gradlewFile.existsSync()) {
      String er = "工程目录下没找到 gradlew 命令文件，流程终止! ${gradlewFile.path}";
      cmdLogCallback(er);
      updateStatue(3, StageStatue.error);
      return er;
    }
    cmdLogCallback("工程目录检测成功，工程结构正常，现在开始打包");
    updateStatue(3, StageStatue.finished);

    // =========================================================================
    await waitOneSec();
    updateStatue(4, StageStatue.executing);
    // 阶段3，执行打包命令
    ExecuteResult gradleAssembleRes = await CommandUtil.getInstance()
        .gradleAssemble(projectPath + Platform.pathSeparator, cmdLogCallback);
    cmdLogCallback("打包 完毕，结果是-> $gradleAssembleRes");

    if (gradleAssembleRes.exitCode != 0) {
      String er = "打包失败，详情请看日志";
      cmdLogCallback(er);
      updateStatue(4, StageStatue.error);
      return er;
    }
    updateStatue(4, StageStatue.finished);
    // =========================================================================

    return "流程结束";
  }
}
