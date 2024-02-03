import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/pgy_upload_util.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path/path.dart';

import '../../comm/order_execute_result.dart';
import '../../comm/pgy/pgy_entity.dart';
import '../../comm/const.dart';
import '../../comm/text_util.dart';
import '../../core/command_util.dart';
import '../../hive/env_config_operator.dart';

typedef ActionFunc = Future<OrderExecuteResult> Function();

typedef OnStageFinishedFunc = Function(int, String);

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
  String? stageCostTime;
  StageStatue stageStatue = StageStatue.idle;
  ActionFunc
      actionFunc; // 当前阶段的行为, 返回null说明当前阶段正常，非null的情况分两种，一是有特殊输出的阶段，第二是结束阶段

  OnStageFinishedFunc? onStateFinished; // 当前阶段结束之后的行为（无论成功或者失败）

  TaskState(this.stageName, {required this.actionFunc, this.onStateFinished});
}

/// 模拟耗时
waitSomeSec() async {
  await Future.delayed(const Duration(milliseconds: 50));
}

/// 模拟耗时
waitThreeSec() async {
  await Future.delayed(const Duration(seconds: 3));
}

/// 模拟耗时
waitForever() async {
  await Future.delayed(const Duration(seconds: 2));
}

class ProjectTaskVm extends ChangeNotifier {
  final gitUrlController = TextEditingController(); // git地址
  final gitBranchController = TextEditingController(); // 分支名称
  final projectPathController = TextEditingController(); // 工程路径
  final projectAppDescController = TextEditingController(); // 应用描述
  final updateLogController = TextEditingController(); // 更新日志
  final assembleTaskNameController = TextEditingController(); // 可用打包指令名称

  final versionNameController = TextEditingController(); // 强制指定版本名
  final versionCodeController = TextEditingController(); // 强制指定版本号

  final cloneMaxDurationController = TextEditingController(); // clone每次执行的最长时间
  final cloneMaxTimesController = TextEditingController(); // clone的最大可执行次数

  final enableOrderCheckMaxDurationController =
      TextEditingController(); // 可用指令查询的每次最大可执行时间
  final enableOrderCheckMaxTimesController =
      TextEditingController(); // 可用指令查询阶段的最大可执行次数

  final pgyApiKeyController = TextEditingController(); // pgy平台apkKey设置
  final pgyUploadMaxDurationController =
      TextEditingController(); // pgy平台每次上传的最大可执行时间
  final pgyUploadMaxTimesController =
      TextEditingController(); // pgy平台每次上传的最大可执行次数

  final List<TaskState> taskStateList = [];

  final List<String> _cmdExecLog = [];

  final logListViewScrollController = ScrollController();

  List<String> get cmdExecLog => _cmdExecLog;

  String get gitUrl => gitUrlController.text;

  String get gitBranch => gitBranchController.text;

  String get projectPath => projectPathController.text;

  String get projectAppDesc => projectAppDescController.text;

  String get updateLog => updateLogController.text;

  String get packageOrder => assembleTaskNameController.text;

  String get envWorkspaceRoot =>
      EnvConfigOperator.searchEnvValue(Const.envWorkspaceRootKey);

  String get versionName => versionNameController.text;

  String get versionCode => versionCodeController.text;

  bool get jobRunning => _jobRunning;

  bool _jobRunning = false;

  final List<String> _enableAssembleOrders = [];

  void deleteDirectory(String path) {
    Directory directory = Directory(path);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }

  void init() {
    taskStateList.clear();
    taskStateList.add(TaskState(
      "参数准备",
      actionFunc: () async {
        if (gitUrl.isEmpty) {
          return OrderExecuteResult(msg: "git仓库地址 不能为空", succeed: false);
        }
        if (projectPath.isEmpty) {
          return OrderExecuteResult(msg: "工程根目录 不能为空", succeed: false);
        }

        return OrderExecuteResult(
            succeed: true, msg: '打包参数正常 工作目录为,$projectPath ');
      },
      onStateFinished: updateStageCostTime,
    ));
    taskStateList.add(TaskState(
      "工程克隆",
      actionFunc: () async {
        try {
          deleteDirectory(projectPath);
        } catch (e) {
          String err = "删除$projectPath失败,原因是：\n$e\n";
          return OrderExecuteResult(msg: err, succeed: false);
        }

        ExecuteResult gitCloneRes = await CommandUtil.getInstance().gitClone(
            clonePath: envWorkspaceRoot,
            gitUrl: gitUrl,
            logOutput: addNewLogLine);

        if (gitCloneRes.exitCode != 0) {
          return OrderExecuteResult(
              msg: "clone失败，具体问题请看日志... \n${gitCloneRes.res}\n\n",
              succeed: false);
        }
        return OrderExecuteResult(succeed: true);
      },
      onStateFinished: updateStageCostTime,
    ));
    taskStateList.add(TaskState(
      "分支切换",
      actionFunc: () async {
        ExecuteResult gitCheckoutRes = await CommandUtil.getInstance()
            .gitCheckout(projectPath, gitBranch, addNewLogLine);

        if (gitCheckoutRes.exitCode != 0) {
          return OrderExecuteResult(msg: gitCheckoutRes.res, succeed: false);
        }
        return OrderExecuteResult(succeed: true);
      },
      onStateFinished: updateStageCostTime,
    ));
    taskStateList.add(TaskState(
      "工程结构检测",
      actionFunc: () async {
        // 阶段2，工程结构检查
        // 检查目录下是否有 gradlew.bat 文件
        File gradlewFile =
            File("$projectPath${Platform.pathSeparator}gradlew.bat");
        if (!gradlewFile.existsSync()) {
          String er = "工程目录下没找到 gradlew 命令文件，流程终止! ${gradlewFile.path}";
          return OrderExecuteResult(msg: er, succeed: false);
        }
        return OrderExecuteResult(succeed: true);
      },
      onStateFinished: updateStageCostTime,
    ));
    taskStateList.add(TaskState(
      "可用指令查询",
      actionFunc: () async {
        ExecuteResult gitAssembleTasksRes = await CommandUtil.getInstance()
            .gradleAssembleTasks(projectPath, addNewLogLine);
        if (gitAssembleTasksRes.exitCode != 0) {
          return OrderExecuteResult(msg: "可用指令查询 存在问题!!!", succeed: false);
        }
        var ori = gitAssembleTasksRes.res;
        var orders = findLinesWithKeyword(ori: ori, keyword: "assemble");
        // 排除所有带test的，无论大小写
        orders = findLinesExceptKeyword(lines: orders, keyword: "test");
        orders = findLinesExceptKeyword(lines: orders, keyword: "bundle");
        orders =
            findLinesExceptKeyword(lines: orders, keyword: "app:assemble -");

        _enableAssembleOrders.clear();
        for (var e in orders) {
          if (e.lastIndexOf(" - ") != -1) {
            _enableAssembleOrders.add(e.substring(4, e.lastIndexOf(" - ")));
          }
        }

        debugPrint("可用指令查询 完毕，结果是  $_enableAssembleOrders");
        return OrderExecuteResult(succeed: true);
      },
      onStateFinished: updateStageCostTime,
    ));
    taskStateList.add(TaskState(
      "生成apk",
      actionFunc: () async {
        await waitSomeSec();
        // 阶段3，执行打包命令
        ExecuteResult gradleAssembleRes = await CommandUtil.getInstance()
            .gradleAssemble(
                projectRoot: projectPath + Platform.pathSeparator,
                packageOrder: packageOrder,
                versionCode: versionCode,
                versionName: versionName,
                logOutput: addNewLogLine);

        if (gradleAssembleRes.exitCode != 0) {
          String er = "打包失败，详情请看日志";
          return OrderExecuteResult(msg: er, succeed: false);
        }
        return OrderExecuteResult(succeed: true);
      },
      onStateFinished: updateStageCostTime,
    ));
    taskStateList.add(TaskState(
      "apk检测",
      actionFunc: () async {
        // 去默认的apk产出位置去查找是否存在apk文件  app\build\outputs\apk\debug
        String apkLocation =
            "$projectPath${Platform.pathSeparator}app\\build\\outputs\\apk\\debug\\app-debug.apk";

        File apk = File(apkLocation);
        if (await apk.exists()) {
          this.apkLocation = apkLocation;
        }
        return OrderExecuteResult(succeed: true);
      },
      onStateFinished: updateStageCostTime,
    ));

    taskStateList.add(TaskState(
      "获取pgy token",
      actionFunc: () async {
        // 先获取当前git的最新提交记录
        var log =
            await CommandUtil.getInstance().gitLog(projectPath, addNewLogLine);

        if (log.exitCode != 0) {
          return OrderExecuteResult(msg: "获取git最近提交记录失败...", succeed: false);
        }

        var pgyToken = await PgyUploadUtil.getInstance().getPgyToken(
          buildDescription: projectAppDesc,
          buildUpdateDescription: "$log \n $updateLog",
        );

        if (pgyToken == null) {
          return OrderExecuteResult(msg: "pgy token获取失败...", succeed: false);
        }

        _pgyEntity = PgyEntity(
          endpoint: pgyToken.data?.endpoint,
          key: pgyToken.data?.params?.key,
          signature: pgyToken.data?.params?.signature,
          xCosSecurityToken: pgyToken.data?.params?.xCosSecurityToken,
        );

        return OrderExecuteResult(succeed: true);
      },
      onStateFinished: updateStageCostTime,
    ));

    taskStateList.add(TaskState(
      "上传pgy",
      actionFunc: () async {
        if (!_pgyEntity!.isOk()) {
          return OrderExecuteResult(msg: "上传参数为空，流程终止!", succeed: false);
        }

        String oriFileName = basename(File(apkLocation!).path);

        var res = await PgyUploadUtil.getInstance().doUpload(_pgyEntity!,
            filePath: apkLocation!,
            oriFileName: oriFileName,
            uploadProgressAction: addNewLogLine);

        if (res != null) {
          return OrderExecuteResult(msg: "上传失败,$res", succeed: false);
        } else {
          return OrderExecuteResult(succeed: true);
        }
      },
      onStateFinished: updateStageCostTime,
    ));

    taskStateList.add(TaskState(
      "检查pgy发布结果",
      actionFunc: () async {
        var s = await PgyUploadUtil.getInstance()
            .checkUploadRelease(_pgyEntity!, onReleaseCheck: addNewLogLine);

        if (s.code == 1216) {
          // 发布失败，流程终止
          return OrderExecuteResult(succeed: false, msg: "发布失败，流程终止");
        } else {
          // 发布成功，打印结果
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

            return OrderExecuteResult(succeed: true, data: appInfo);
          } else {
            return OrderExecuteResult(succeed: false, msg: "发布结果解析失败");
          }
        }
      },
      onStateFinished: updateStageCostTime,
    ));

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

  void updateStageCostTime(int index, String costTime) {
    TaskState c = taskStateList[index];
    c.stageCostTime = costTime;
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

  void addNewEmptyLine() {
    addNewLogLine("\n\n\n");
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

  int get maxTimes {
    return int.tryParse(EnvConfigOperator.searchEnvValue(
            Const.stageTaskExecuteMaxRetryTimes)) ??
        5;
  }

  Future timeOutCounter() async {
    await Future.delayed(Duration(
        seconds: int.tryParse(EnvConfigOperator.searchEnvValue(
                Const.stageTaskExecuteMaxPeriod)) ??
            3000));
  }

  ///
  /// 开始流水线工作
  ///
  Future<OrderExecuteResult?> startSchedule() async {
    if (_jobRunning) {
      return OrderExecuteResult(succeed: false, msg: "任务正在执行中...");
    }

    _jobRunning = true;

    addNewLogLine("开始流程...");

    OrderExecuteResult? actionResStr;

    Stopwatch totalWatch = Stopwatch();
    totalWatch.start();

    // 开始整体流程
    for (int i = 0; i < taskStateList.length; i++) {
      bool taskOk = false;

      // 对每个阶段执行 规定最大次数的循环
      for (int j = 0; j < maxTimes; j++) {
        // 任务变为执行中的状态
        updateStatue(i, StageStatue.executing);

        // 开始单次执行的计时器
        Stopwatch stageTimeWatch = Stopwatch();
        stageTimeWatch.start();

        var taskName = taskStateList[i].stageName;
        var taskFuture = taskStateList[i].actionFunc();
        addNewLogLine("第${j + 1}次 执行开始: $taskName");

        var result = await Future.any([taskFuture, timeOutCounter()]); // 计算超时

        stageTimeWatch.stop(); // 停止计时器

        // 如果任务在规定时间之内完成，则一定会返回一个OrderExecuteResult
        if (result is OrderExecuteResult) {
          // 如果执行成功，则标记此阶段已完成
          if (result.succeed == true) {
            taskStateList[i]
                .onStateFinished
                ?.call(i, "cost ${stageTimeWatch.elapsed.inMilliseconds} 毫秒");
            taskOk = true;
            addNewLogLine("第${j + 1}次 执行成功: $taskName - $result");
            addNewEmptyLine();
            actionResStr = result;
            break;
          } else {
            updateStatue(i, StageStatue.error);
            if (j == maxTimes - 1) {
              // 失败则打印日志，3秒后开始下一轮
              addNewLogLine("第${j + 1}次 执行失败: $taskName - $result");
            } else {
              // 失败则打印日志，3秒后开始下一轮
              addNewLogLine("第${j + 1}次 执行失败: $taskName - $result 3秒后开始下一轮");
              addNewEmptyLine();
              waitThreeSec();
            }
          }
        } else {
          // 如果没返回 OrderExecuteResult，那么一定是超时了
          addNewLogLine("第${j + 1}次 执行超时: $taskName, 3秒后开始下一轮");
          addNewEmptyLine();

          // 如果到了最后一次
          if (j == maxTimes - 1) {
            actionResStr =
                OrderExecuteResult(succeed: false, msg: "第${j + 1}次:$result");
            CommandUtil.getInstance().stopAllExec();
            break;
          }
          waitSomeSec();
        }
      }

      if (taskOk) {
        updateStatue(i, StageStatue.finished);
      } else {
        updateStatue(i, StageStatue.error);
        _jobRunning = false;
        return actionResStr;
      }
    }

    totalWatch.stop();
    _jobRunning = false;

    return OrderExecuteResult(
        succeed: true,
        msg: "任务总共花费时间${totalWatch.elapsed.inMilliseconds} 毫秒 ",
        data: actionResStr?.data);
  }
}
