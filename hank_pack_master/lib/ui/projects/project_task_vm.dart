import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/upload_util.dart';
import 'package:jiffy/jiffy.dart';

import '../../comm/sp_util.dart';
import '../../core/command_util.dart';
import '../../comm/text_util.dart';
import 'package:path/path.dart';

typedef ActionFunc = Future<dynamic> Function(int);

enum StageStatue { idle, executing, finished, error }

class PgyEntity {
  String? endpoint;
  String? key;
  String? signature;
  String? xCosSecurityToken;

  PgyEntity({
    required this.endpoint,
    required this.key,
    required this.signature,
    required this.xCosSecurityToken,
  });

  @override
  String toString() {
    return '''
    endpoint-> $endpoint
    key-> $key
    signature-> $signature
    xCosSecurityToken-> $xCosSecurityToken
    ''';
  }

  bool isOk() {
    if (endpoint.empty()) {
      return false;
    }
    if (key.empty()) {
      return false;
    }
    if (signature.empty()) {
      return false;
    }
    if (xCosSecurityToken.empty()) {
      return false;
    }

    return true;
  }
}

class PackageSuccessEntity {
  String title;
  String apkPath;

  PackageSuccessEntity({required this.title, required this.apkPath});

  @override
  String toString() {
    return "$title\n$apkPath";
  }
}

class TaskState {
  String stageName;
  StageStatue stageStatue = StageStatue.idle;
  ActionFunc? actionFunc; // 当前阶段的行为

  TaskState(this.stageName, {this.actionFunc});
}

/// 模拟耗时
waitOneSec() async {
  await Future.delayed(const Duration(milliseconds: 50));
}

class ProjectTaskVm extends ChangeNotifier {
  final gitUrlController = TextEditingController(); // git地址
  final gitBranchController = TextEditingController(); // 分支名称
  final projectPathController = TextEditingController(); // 工程路径

  final List<TaskState> taskStateList = [];

  final List<String> _cmdExecLog = [];

  final logListViewScrollController = ScrollController();

  List<String> get cmdExecLog => _cmdExecLog;

  String get gitUrl => gitUrlController.text;

  String get projectPath => projectPathController.text;

  String get envWorkspaceRoot => SpUtil.getValue(SpConst.envWorkspaceRootKey);

  void init() {
    taskStateList.clear();

    taskStateList.add(TaskState("参数准备", actionFunc: (i) async {
      await waitOneSec();
      updateStatue(i, StageStatue.executing);
      addNewLogLine("gitUrl-> $gitUrl");
      addNewLogLine("projectRoot-> $projectPath...");
      if (gitUrl.isEmpty) {
        updateStatue(i, StageStatue.error);
        return "git仓库地址 不能为空";
      }
      if (projectPath.isEmpty) {
        updateStatue(i, StageStatue.error);
        return "工程根目录 不能为空";
      }
      updateStatue(i, StageStatue.finished);
      return null;
    }));
    taskStateList.add(TaskState("工程克隆", actionFunc: (i) async {
      await waitOneSec();
      updateStatue(i, StageStatue.executing);
      addNewLogLine("clone开始...");

      ExecuteResult gitCloneRes = await CommandUtil.getInstance().gitClone(
          clonePath: envWorkspaceRoot,
          gitUrl: gitUrl,
          logOutput: addNewLogLine);
      addNewLogLine("clone完毕，结果是  $gitCloneRes");

      if (gitCloneRes.exitCode != 0) {
        addNewLogLine("clone失败，具体问题请看日志...");
        updateStatue(i, StageStatue.error);
        return "clone失败，具体问题请看日志... \n${gitCloneRes.res}";
      }
      updateStatue(i, StageStatue.finished);
      return null;
    }));
    taskStateList.add(TaskState("分支切换", actionFunc: (i) async {
      await waitOneSec();
      updateStatue(i, StageStatue.executing);
      addNewLogLine("checkout 开始...");

      ExecuteResult gitCheckoutRes = await CommandUtil.getInstance()
          .gitCheckout(projectPathController.text, gitBranchController.text,
              addNewLogLine);
      addNewLogLine("checkout 完毕，结果是  $gitCheckoutRes");

      if (gitCheckoutRes.exitCode != 0) {
        addNewLogLine("checkout  失败，具体问题请看日志...");
        updateStatue(i, StageStatue.error);
        return gitCheckoutRes.res;
      }
      updateStatue(i, StageStatue.finished);
      return null;
    }));
    taskStateList.add(TaskState("工程结构检测", actionFunc: (i) async {
      await waitOneSec();
      updateStatue(i, StageStatue.executing);
      addNewLogLine("开始检查工程目录结构...");
      // 阶段2，工程结构检查
      // 检查目录下是否有 gradlew.bat 文件
      File gradlewFile =
          File("$projectPath${Platform.pathSeparator}gradlew.bat");
      if (!gradlewFile.existsSync()) {
        String er = "工程目录下没找到 gradlew 命令文件，流程终止! ${gradlewFile.path}";
        addNewLogLine(er);
        updateStatue(i, StageStatue.error);
        return er;
      }
      addNewLogLine("工程目录检测成功，工程结构正常，现在开始打包");
      updateStatue(i, StageStatue.finished);
      return null;
    }));
    taskStateList.add(TaskState("生成apk", actionFunc: (i) async {
      await waitOneSec();
      updateStatue(i, StageStatue.executing);
      // 阶段3，执行打包命令
      ExecuteResult gradleAssembleRes = await CommandUtil.getInstance()
          .gradleAssemble(projectPath + Platform.pathSeparator, addNewLogLine);
      addNewLogLine("打包 完毕，结果是-> $gradleAssembleRes");

      if (gradleAssembleRes.exitCode != 0) {
        String er = "打包失败，详情请看日志";
        addNewLogLine(er);
        updateStatue(i, StageStatue.error);
        return er;
      }
      updateStatue(i, StageStatue.finished);
      return null;
    }));
    taskStateList.add(TaskState("apk检测", actionFunc: (i) async {
      // 去默认的apk产出位置去查找是否存在apk文件  app\build\outputs\apk\debug
      String apkLocation =
          "$projectPath${Platform.pathSeparator}app\\build\\outputs\\apk\\debug\\app-debug.apk";

      File apk = File(apkLocation);
      if (await apk.exists()) {
        addNewLogLine("apk文件已找到,$apkLocation");
        updateStatue(i, StageStatue.finished);
        this.apkLocation = apkLocation;
        // return PackageSuccessEntity(
        //     title: "打包成功，apk输出地址为", apkPath: apkLocation);
      } else {
        addNewLogLine("apk文件未找到,$apkLocation");
        updateStatue(i, StageStatue.error);
      }
      return null;
    }));

    taskStateList.add(TaskState("获取PGY TOKEN", actionFunc: (i) async {
      updateStatue(i, StageStatue.executing);
      var pgyToken = await UploadUtil.getInstance().getPgyToken();

      if (pgyToken == null) {
        updateStatue(i, StageStatue.error);
        return "pgy token获取失败...";
      }

      _pgyEntity = PgyEntity(
        endpoint: pgyToken.data?.endpoint,
        key: pgyToken.data?.params?.key,
        signature: pgyToken.data?.params?.signature,
        xCosSecurityToken: pgyToken.data?.params?.xCosSecurityToken,
      );

      addNewLogLine("pgy参数获取成功,$_pgyEntity");
      updateStatue(i, StageStatue.finished);
      return null;
    }));

    taskStateList.add(TaskState("上传PGY", actionFunc: (i) async {
      if (!_pgyEntity!.isOk()) {
        updateStatue(i, StageStatue.error);
        return "上传参数为空，流程终止!";
      }
      updateStatue(i, StageStatue.executing);

      addNewLogLine("正在上传,$_pgyEntity");
      String oriFileName = basename(File(apkLocation!).path);
      addNewLogLine("文件名为 $oriFileName");

      var res = await UploadUtil.getInstance().doUpload(
        _pgyEntity!,
        filePath: apkLocation!,
        oriFileName: oriFileName,
        uploadProgressAction:addNewLogLine,
      );

      if (res == null) {
        addNewLogLine("上传成功,$oriFileName");
        updateStatue(i, StageStatue.finished);
        return null;
      } else {
        addNewLogLine("上传失败,$res");
        updateStatue(i, StageStatue.error);
        return res;
      }
    }));

    notifyListeners();
  }

  PgyEntity? _pgyEntity;
  String? apkLocation;

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
    _scrollToBottom();
  }

  ///添加一个延时，以确保listView绘制完毕，再来计算最底端的位置
  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      logListViewScrollController.animateTo(
          logListViewScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear);
    });
  }

  ///
  /// 开始流水线工作
  ///
  startSchedule(Function(dynamic s) endAction) async {
    addNewLogLine("开始流程...");

    dynamic actionResStr;

    for (int i = 0; i < taskStateList.length; i++) {
      dynamic result = await taskStateList[i].actionFunc?.call(i);
      if (result != null) {
        actionResStr = result;
        break;
      }
    }
    addNewLogLine("流程结束...");
    endAction(actionResStr);
  }
}
