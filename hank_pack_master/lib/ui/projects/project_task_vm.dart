import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/pgy_upload_util.dart';
import 'package:jiffy/jiffy.dart';

import '../../comm/pgy/pgy_entity.dart';
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
  ActionFunc?
      actionFunc; // 当前阶段的行为, 返回null说明当前阶段正常，非null的情况分两种，一是有特殊输出的阶段，第二是结束阶段

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
  final projectAppDescController = TextEditingController(); // 工程路径

  final List<TaskState> taskStateList = [];

  final List<String> _cmdExecLog = [];

  final logListViewScrollController = ScrollController();

  List<String> get cmdExecLog => _cmdExecLog;

  String get gitUrl => gitUrlController.text;

  String get gitBranch => gitBranchController.text;

  String get projectPath => projectPathController.text;

  String get projectAppDesc => projectAppDescController.text;

  String get envWorkspaceRoot => SpUtil.getValue(SpConst.envWorkspaceRootKey);

  bool get jobRunning => _jobRunning;

  bool _jobRunning = false;

  final List<String> _enableAssembleOrders = [];

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

      ExecuteResult gitCheckoutRes =
          await CommandUtil.getInstance().gitCheckout(
        projectPath,
        gitBranch,
        addNewLogLine,
      );
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
      addNewLogLine("工程目录检测成功，工程结构正常.");
      updateStatue(i, StageStatue.finished);
      return null;
    }));
    taskStateList.add(TaskState("可用指令查询", actionFunc: (i) async {
      await waitOneSec();
      updateStatue(i, StageStatue.executing);
      ExecuteResult gitAssembleTasksRes =
          await CommandUtil.getInstance().gradleAssembleTasks(
        projectPath,
        addNewLogLine,
      );
      if (gitAssembleTasksRes.exitCode != 0) {
        updateStatue(i, StageStatue.error);
        addNewLogLine("可用指令查询 完毕，结果是  $gitAssembleTasksRes");
        return "可用指令查询 存在问题!!!";
      }
      var ori = gitAssembleTasksRes.res;
      var orders = findLinesWithKeyword(ori: ori, keyword: "assemble");
      // 排除所有带test的，无论大小写
      orders = findLinesExceptKeyword(lines: orders, keyword: "test");
      orders = findLinesExceptKeyword(lines: orders, keyword: "bundle");
      orders = findLinesExceptKeyword(lines: orders, keyword: "app:assemble -");

      _enableAssembleOrders.clear();
      for (var e in orders) {
        if (e.lastIndexOf(" - ") != -1) {
          _enableAssembleOrders.add(e.substring(4, e.lastIndexOf(" - ")));
        }
      }

      debugPrint("可用指令查询 完毕，结果是  $_enableAssembleOrders");
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

    taskStateList.add(TaskState("获取pgy token", actionFunc: (i) async {
      updateStatue(i, StageStatue.executing);

      // 先获取当前git的最新提交记录
      var log = await CommandUtil.getInstance().gitLog(
        projectPath,
        addNewLogLine,
      );

      if (log.exitCode != 0) {
        updateStatue(i, StageStatue.error);
        return "获取git最近提交记录失败...";
      }

      addNewLogLine("获取git最近提交记录成功 $log");
      addNewLogLine("获取应用描述成功 $projectAppDesc");

      var pgyToken = await PgyUploadUtil.getInstance().getPgyToken(
        buildDescription: "??????",
        buildUpdateDescription: projectAppDesc,
      );

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

    taskStateList.add(TaskState("上传pgy", actionFunc: (i) async {
      if (!_pgyEntity!.isOk()) {
        updateStatue(i, StageStatue.error);
        return "上传参数为空，流程终止!";
      }
      updateStatue(i, StageStatue.executing);

      addNewLogLine("正在上传,$_pgyEntity");
      String oriFileName = basename(File(apkLocation!).path);
      addNewLogLine("文件名为 $oriFileName");

      var res = await PgyUploadUtil.getInstance().doUpload(
        _pgyEntity!,
        filePath: apkLocation!,
        oriFileName: oriFileName,
        uploadProgressAction: addNewLogLine,
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

    taskStateList.add(TaskState("检查pgy发布结果", actionFunc: (i) async {
      updateStatue(i, StageStatue.executing);
      var s = await PgyUploadUtil.getInstance().checkUploadRelease(
        _pgyEntity!,
        onReleaseCheck: addNewLogLine,
      );

      if (s.code == 1216) {
        // 发布失败，流程终止
        updateStatue(i, StageStatue.error);
        return "发布失败，流程终止";
      } else {
        // 发布成功，打印结果
        debugPrint("发布成功，结果为:${s.message.runtimeType} ${s.data}");
        addNewLogLine("发布成功，开始解析上传成功的参数");
        // 开始解析发布结果,
        if (s.data is Map<String, dynamic>) {
          MyAppInfo appInfo =
              MyAppInfo.fromJson(s.data as Map<String, dynamic>);

          addNewLogLine("应用名称: ${appInfo.buildName}");
          addNewLogLine("大小: ${appInfo.buildFileSize}");
          addNewLogLine("版本号: ${appInfo.buildVersion}");
          addNewLogLine("编译版本号: ${appInfo.buildBuildVersion}");
          addNewLogLine("应用描述: ${appInfo.buildDescription}");
          addNewLogLine("更新日志: ${appInfo.buildUpdateDescription}");
          addNewLogLine("应用包名: ${appInfo.buildIdentifier}");
          addNewLogLine(
              "图标地址: https://www.pgyer.com/image/view/app_icons/${appInfo.buildIcon}");
          addNewLogLine("下载短链接: ${appInfo.buildShortcutUrl}");
          addNewLogLine("二维码地址: ${appInfo.buildQRCodeURL}");
          addNewLogLine("应用更新时间: ${appInfo.buildUpdated}");

          updateStatue(i, StageStatue.finished);

          return appInfo;
        } else {
          addNewLogLine("发布结果解析失败");
          updateStatue(i, StageStatue.error);
        }

        return "发布成功，详情请看日志";
      }
    }));

    notifyListeners();
  }

  List<String> findLinesWithKeyword(
      {required String ori, required String keyword}) {
    List<String> lines = ori.split('\n');
    List<String> result = [];

    for (String line in lines) {
      if (line.toLowerCase().contains(keyword.toLowerCase())) {
        result.add(line.trim());
      }
    }

    return result;
  }

  List<String> findLinesExceptKeyword(
      {required List<String> lines, required String keyword}) {
    List<String> result = [];

    for (String line in lines) {
      if (!line.toLowerCase().contains(keyword.toLowerCase())) {
        result.add(line.trim());
      }
    }

    return result;
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
        return Colors.grey.withOpacity(.5);
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
    Timer(const Duration(milliseconds: 300), () {
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
    if (_jobRunning) {
      return;
    }

    _jobRunning = true;

    addNewLogLine("开始流程...");

    dynamic actionResStr;

    for (int i = 0; i < taskStateList.length; i++) {
      dynamic result = await taskStateList[i].actionFunc?.call(i);
      if (result != null) {
        actionResStr = result;
        break;
      }
    }
    addNewLogLine("流程结束,检查成果...");
    _jobRunning = false;
    endAction(actionResStr);
  }
}
