import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/apk_parser_result.dart';
import 'package:hank_pack_master/comm/hwobs/obs_client.dart';
import 'package:hank_pack_master/comm/pgy/pgy_upload_util.dart';
import 'package:hank_pack_master/ui/work_shop/task_stage.dart';
import 'package:hank_pack_master/ui/work_shop/temp_log_cache_entity.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path/path.dart' as path;

import '../../comm/file_operation.dart';
import '../../comm/order_execute_result.dart';
import '../../comm/pgy/pgy_entity.dart';
import '../../comm/str_const.dart';
import '../../comm/text_util.dart';
import '../../comm/upload_platforms.dart';
import '../../comm/wait_util.dart';
import '../../core/command_util.dart';
import '../../hive/env_config/env_config_operator.dart';
import '../../hive/project_record/project_record_entity.dart';
import '../../hive/project_record/project_record_operator.dart';

class WorkShopVm extends ChangeNotifier {
  /// 所有的输入框控制器
  final projectNameController = TextEditingController(); // 工程名称
  final gitUrlController = TextEditingController(); // git地址
  final gitBranchController = TextEditingController(); // 分支名称
  final projectPathController = TextEditingController(); // 工程路径
  final selectedOrderController = TextEditingController(); // 选中的打包命令
  final selectedUploadPlatformController = TextEditingController(); // 工程路径

  final projectAppDescController = TextEditingController(); // 应用描述
  final updateLogController = TextEditingController(); // 更新日志
  final apkLocationController = TextEditingController(); // 更新日志

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

  final List<TaskStage> taskStateList = [];

  final List<String> _cmdExecLog = [];

  final logListViewScrollController = ScrollController();

  Function(double)? onProcessChanged;

  UploadPlatform? selectedUploadPlatform; // 选中的上传平台

  void setSelectedUploadPlatform(int index) {
    selectedUploadPlatform = uploadPlatforms[index];
    notifyListeners();
  }

  List<String> get cmdExecLog => _cmdExecLog;

  String get gitUrl => gitUrlController.text;

  String get gitBranch => gitBranchController.text;

  String get projectPath => projectPathController.text;

  String get projectAppDesc => projectAppDescController.text;

  String get updateLog => updateLogController.text;

  String get _apkLocation =>
      "$projectPath${Platform.pathSeparator}${apkLocationController.text}";

  void setApkLocation(String newPath) {
    apkLocationController.text = newPath;
  }

  String get envWorkspaceRoot =>
      EnvConfigOperator.searchEnvValue(Const.envWorkspaceRootKey);

  String get versionName => versionNameController.text;

  String get versionCode => versionCodeController.text;

  bool get workThreadRunning => _workThreadRunning;

  bool _workThreadRunning = false;

  final List<String> _enableAssembleOrders = [];

  Map<String, String> get enableAssembleOrders {
    Map<String, String> v = {};
    for (var element in _enableAssembleOrders) {
      v[element] = element;
    }

    return v;
  }

  String? selectedOrder;

  void setSelectedOrder(String order) {
    selectedOrder = order;

    // 同时设置默认的apk路径
    if (order == 'assembleDebug') {
      setApkLocation('app\\build\\outputs\\apk\\debug');
    } else if (order == 'assembleRelease') {
      setApkLocation('app\\build\\outputs\\apk\\release');
    }

    notifyListeners();
  }

  void deleteDirectory(String path) {
    Directory directory = Directory(path);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }

  get prepareParamTask => TaskStage("参数准备", actionFunc: () async {
        if (gitUrl.isEmpty) {
          return OrderExecuteResult(msg: "git仓库地址 不能为空", succeed: false);
        }
        if (projectPath.isEmpty) {
          return OrderExecuteResult(msg: "工程根目录 不能为空", succeed: false);
        }
        return OrderExecuteResult(
            succeed: true, data: '打包参数正常 工作目录为,$projectPath ');
      });

  get gitCloneTask => TaskStage("工程克隆", actionFunc: () async {
        // clone之前不再检查原有文件，而是另外起一个目录，单独存放，这样可以避免文件被占用的问题
        // 与此同时，必须设定缓存删除机制，避免产生过多无用垃圾文件

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

        String cloneFailedSolution = '''
        clone失败：
        如果是由于文件被占用的原因，在 Windows 平台上，
      
方法1：
打开任务管理器，找到JDK相关进程，杀死，然后重新执行任务。

方法2：        

使用资源监视器（Resource Monitor）
打开资源监视器。你可以通过按下 Win + R，然后输入 “resmon” 后按回车键来打开命令提示符，输入 “resmon” 并按回车键，或者在任务管理器的 “性能” 标签页中点击 “资源监视器” 按钮来打开资源监视器。
在资源监视器的 “CPU” 标签页中，找到 “关联的句柄” 部分，并输入文件名或路径以筛选关联的句柄。
根据结果，你可以看到哪个进程正在使用特定的文件。关闭该进程再次尝试clone即可。
        ''';

        if (gitCloneRes.exitCode != 0) {
          return OrderExecuteResult(
              msg:
                  "clone失败，具体问题请看日志... \n${gitCloneRes.res}\n\n $cloneFailedSolution",
              succeed: false);
        }
        return OrderExecuteResult(
            succeed: true, data: 'clone成功,位置在 $projectPath');
      });

  get branchCheckoutTask => TaskStage("分支切换", actionFunc: () async {
        ExecuteResult gitCheckoutRes = await CommandUtil.getInstance()
            .gitCheckout(projectPath, gitBranch, addNewLogLine);

        if (gitCheckoutRes.exitCode != 0) {
          return OrderExecuteResult(msg: gitCheckoutRes.res, succeed: false);
        }
        return OrderExecuteResult(succeed: true, data: '分支 $gitBranch 切换成功');
      });

  get projectStructCheckTask => TaskStage("工程结构检测", actionFunc: () async {
        // 工程结构检查
        // 检查目录下是否有 gradlew.bat 文件
        File gradlewFile =
            File("$projectPath${Platform.pathSeparator}gradlew.bat");
        if (!gradlewFile.existsSync()) {
          String er = "工程目录下没找到 gradlew 命令文件，流程终止! ${gradlewFile.path}";
          return OrderExecuteResult(msg: er, succeed: false);
        }
        return OrderExecuteResult(succeed: true, data: '这是一个正常的安卓工程');
      });

  get assembleOrdersTask => TaskStage("可用指令查询", actionFunc: () async {
        ExecuteResult gitAssembleTasksRes = await CommandUtil.getInstance()
            .gradleAssembleTasks(projectPath, addNewLogLine);
        if (gitAssembleTasksRes.exitCode != 0) {
          return OrderExecuteResult(msg: "可用指令查询 存在问题!!!", succeed: false);
        }
        var ori = gitAssembleTasksRes.res;
        debugPrint("================找到的原始指令是:\n$ori");
        var orders = findLinesWithKeyword(ori: ori, keyword: "assemble");
        // 排除所有带test的，无论大小写
        orders = findLinesExceptKeyword(lines: orders, keyword: "test");
        orders = findLinesExceptKeyword(lines: orders, keyword: "bundle");
        orders = findLinesExceptKeyword(lines: orders, keyword: "assemble -");

        _enableAssembleOrders.clear();
        for (var e in orders) {
          if (e.lastIndexOf(" - ") != -1) {
            _enableAssembleOrders.add(e.substring(0, e.lastIndexOf(" - ")));
          }
        }

        debugPrint("可用指令查询 完毕，结果是  $_enableAssembleOrders");
        return OrderExecuteResult(succeed: true, data: _enableAssembleOrders);
      });

  get gitPullTask => TaskStage("工程同步", actionFunc: () async {
        var gitCheckoutRes =
            await CommandUtil.getInstance().gitPull(projectPath, addNewLogLine);
        if (gitCheckoutRes.exitCode != 0) {
          return OrderExecuteResult(msg: gitCheckoutRes.res, succeed: false);
        }

        return OrderExecuteResult(data: "git pull 成功", succeed: true);
      });

  get modifyGradlePropertiesFile =>
      TaskStage("修改 gradle.properties文件 以指定Java环境", actionFunc: () async {
        // 找到工程位置下的 gradle.properties 文件
        var gradlePropertiesFile =
            File("$projectPath${Platform.pathSeparator}gradle.properties");

        if (!gradlePropertiesFile.existsSync()) {
          return OrderExecuteResult(
              msg: "gradle.properties 文件未找到", succeed: false);
        }

        // 在文件中写入 org.gradle.java.home变量，值为
        var javaHomeValue = runningTask!.setting!.jdk!.envPath;
        File fx = File(javaHomeValue);
        if (!fx.existsSync()) {
          return OrderExecuteResult(
              msg: "$javaHomeValue 文件未找到", succeed: false);
        }

        updateGradleProperties(gradlePropertiesFile, "org.gradle.java.home",
            escapeBackslashes(fx.parent.parent.path));
        return OrderExecuteResult(data: "Java环境指定成功", succeed: true);
      });

  get recoverGradlePropertiesFile =>
      TaskStage("恢复gradle.properties", actionFunc: () async {
        String gradlePropertiesFilePath =
            "$projectPath${Platform.pathSeparator}gradle.properties";

        ExecuteResult executeResult = await CommandUtil.getInstance()
            .gitCheckoutFile(
                projectPath, gradlePropertiesFilePath, (s) => null, tempLog);
        if (executeResult.exitCode != 0) {
          String er = "还原失败，详情请看日志}";
          return OrderExecuteResult(msg: er, succeed: false);
        }

        return OrderExecuteResult(data: "gradle.properties还原成功", succeed: true);
      });

  get generateApkTask => TaskStage("生成apk", actionFunc: () async {
        ExecuteResult gradleAssembleRes = await CommandUtil.getInstance()
            .gradleAssemble(
                projectRoot: projectPath + Platform.pathSeparator,
                packageOrder: selectedOrder!,
                versionCode: versionCode,
                versionName: versionName,
                logOutput: addNewLogLine,
                tempLogCacheEntity: tempLog);

        if (gradleAssembleRes.exitCode != 0) {
          String er = "打包失败，详情请看日志 \n ${tempLog.get()}";
          return OrderExecuteResult(msg: er, succeed: false);
        }
        return OrderExecuteResult(succeed: true, data: gradleAssembleRes.res);
      });

  get apkCheckTask => TaskStage("apk检测", actionFunc: () async {
        // 检查此目录下的apk文件，并且校验它的最后修改时间是不是在10分钟以内
        var list = await findApkFiles(_apkLocation);

        if (list.length > 1) {
          return OrderExecuteResult(
              succeed: false,
              msg: "查找打包产物 失败: $_apkLocation，存在多个apk文件，无法确定需上传的apk");
        }

        apkToUpload = list[0];

        if (await File(apkToUpload!).exists()) {
        } else {
          return OrderExecuteResult(
              succeed: false, msg: "查找打包产物 失败: $apkToUpload，文件不存在");
        }
        return OrderExecuteResult(
            succeed: true, data: "打包产物的位置在: $apkToUpload");
      });

  get pgyTokenFetchTask => TaskStage("获取pgyToken", actionFunc: () async {
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
          return OrderExecuteResult(
              msg: "pgy token获取失败... [$apkToUpload]", succeed: false);
        }

        _pgyEntity = PgyEntity(
          endpoint: pgyToken.data?.endpoint,
          key: pgyToken.data?.params?.key,
          signature: pgyToken.data?.params?.signature,
          xCosSecurityToken: pgyToken.data?.params?.xCosSecurityToken,
        );

        return OrderExecuteResult(
            succeed: true, msg: '获取到的Token是 ${pgyToken.toString()}');
      });

  get uploadToPgyTask => TaskStage("上传pgy", actionFunc: () async {
        if (!_pgyEntity!.isOk()) {
          return OrderExecuteResult(
              msg: "上传参数为空，流程终止!  [$apkToUpload]", succeed: false);
        }

        String oriFileName = path.basename(File(apkToUpload!).path);

        var res = await PgyUploadUtil.getInstance().doUpload(_pgyEntity!,
            filePath: apkToUpload!,
            oriFileName: oriFileName,
            uploadProgressAction: addNewLogLine);

        if (res != null) {
          return OrderExecuteResult(
              msg: "上传失败,$res \n [$apkToUpload] \n", succeed: false);
        } else {
          return OrderExecuteResult(succeed: true, data: '上传成功');
        }
      });

  get pgyResultSearchTask => TaskStage("检查pgy发布结果", actionFunc: () async {
        var s = await PgyUploadUtil.getInstance()
            .checkUploadRelease(_pgyEntity!, onReleaseCheck: addNewLogLine);

        if (s == null) {
          return OrderExecuteResult(
              succeed: false, msg: " \n [$apkToUpload] \n");
        }

        if (s.code == 1216) {
          // 发布失败，流程终止
          return OrderExecuteResult(
              succeed: false, msg: "发布失败，流程终止, \n [$apkToUpload] \n");
        } else {
          // 发布成功，打印结果
          // 开始解析发布结果,
          if (s.data is Map<String, dynamic>) {
            MyAppInfo appInfo =
                MyAppInfo.fromJson(s.data as Map<String, dynamic>);
            appInfo.buildDescription = projectAppDesc; // 应用描述，PGY数据有误，所以直接自己生成
            appInfo.uploadPlatform = '${selectedUploadPlatform?.index}';

            addNewLogLine("应用名称: ${appInfo.buildName}");
            addNewLogLine("大小: ${appInfo.buildFileSize}");
            addNewLogLine("版本号: ${appInfo.buildVersion}");
            addNewLogLine("上传批次: ${appInfo.buildBuildVersion}");
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
            return OrderExecuteResult(
                succeed: false, data: "发布结果解析失败,  \n [$apkToUpload] \n ");
          }
        }
      });

  get uploadToObsTask => TaskStage("上传到华为obs", actionFunc: () async {
        // 先获取当前git的最新提交记录
        var log =
            await CommandUtil.getInstance().gitLog(projectPath, addNewLogLine);

        if (log.exitCode != 0) {
          return OrderExecuteResult(data: "获取git最近提交记录失败...", succeed: false);
        }
        // 上传到OBS的时候，必须重命名,不然无法区分多版本
        File fileToUpload = File(apkToUpload!);

        String childFolderName = path.basename(projectPath); // 用项目名称作为分隔
        String buildUpdated = Jiffy.now().format(pattern: "yyyyMMdd_HHmmss_");

        var oBSResponse = await OBSClient.putFile(
          objectName:
              "${childFolderName}_$buildUpdated${path.basename(apkToUpload!)}",
          file: fileToUpload,
        );

        obsDownloadUrl = oBSResponse?.url;
        if (obsDownloadUrl == null || obsDownloadUrl!.isEmpty) {
          return OrderExecuteResult(
              succeed: false, msg: "OBS上传失败, \n [$apkToUpload]  \n ");
        } else {
          return OrderExecuteResult(
            data: "OBS上传成功,下载地址为 $obsDownloadUrl",
            succeed: true,
          );
        }
      });

  get generateObsUploadResTask => TaskStage("构建打包结果", actionFunc: () async {
        if (apkToUpload == null) {
          return OrderExecuteResult(
              data: "error : apkToUpload is null!", succeed: false);
        }
        MyAppInfo appInfo = MyAppInfo();
        File apkFile = File(apkToUpload!);
        if (await apkFile.exists()) {
          String fileSize = "${await apkFile.length()}"; // 文件大小
          var executeResult =
              await CommandUtil.getInstance().aapt(apkToUpload!);
          var data = executeResult.data;
          if (data is ApkParserResult) {
            appInfo.uploadPlatform = '${selectedUploadPlatform?.index}';
            appInfo.buildName = data.appName;
            appInfo.buildVersion = data.versionName;
            appInfo.buildVersionNo = data.versioncode;
            appInfo.buildIdentifier = data.packageName;
            appInfo.buildFileSize = fileSize;
            appInfo.buildQRCodeURL = obsDownloadUrl;
            appInfo.buildUpdated =
                Jiffy.now().format(pattern: "yyyy-MM-dd HH:mm:ss");
            // 更新日志
            appInfo.buildUpdateDescription = updateLog;
            // 应用描述
            appInfo.buildDescription = projectAppDesc;

            debugPrint("大小: ${appInfo.buildFileSize}");
            debugPrint("版本号: ${appInfo.buildVersion}");
            debugPrint("编译版本号: ${appInfo.buildVersionNo}");
            debugPrint("应用包名: ${appInfo.buildIdentifier}");
            debugPrint("二维码地址: ${appInfo.buildQRCodeURL}");
            debugPrint("应用更新时间: ${appInfo.buildUpdated}");
            debugPrint("应用描述: ${appInfo.buildDescription}");
            debugPrint("更新日志: ${appInfo.buildUpdateDescription}");
            return OrderExecuteResult(data: appInfo, succeed: true);
          } else {
            return OrderExecuteResult(data: null, succeed: false);
          }
        } else {
          return OrderExecuteResult(data: null, succeed: false);
        }
      });

  /// 初始化一个激活任务队列
  void initPreCheckTaskList() {
    selectedOrder = null;
    taskStateList.clear();

    TaskStage.onStateFinishedFunc = updateStageCostTime;
    TaskStage.onStageStartedFunc = updateStateStarted;

    taskStateList.add(prepareParamTask);
    taskStateList.add(gitCloneTask);
    taskStateList.add(branchCheckoutTask);
    taskStateList.add(projectStructCheckTask);
    taskStateList.add(assembleOrdersTask);
  }

  String? apkToUpload; // 即将上传的文件地址
  String? obsDownloadUrl; // obs上传后的下载路径

  /// 初始化一个打包任务队列
  void initPackageTaskList() {
    taskStateList.clear();

    taskStateList.add(gitPullTask);

    // 这里必须增加一个步骤，
    taskStateList.add(modifyGradlePropertiesFile);

    taskStateList.add(generateApkTask);
    taskStateList.add(apkCheckTask);

    taskStateList.add(recoverGradlePropertiesFile);

    // 如果是已有的apk文件进行上传的话，那就直接执行以下步骤就行了

    if (selectedUploadPlatform?.index == 0) {
      taskStateList.add(pgyTokenFetchTask);
      taskStateList.add(uploadToPgyTask);
      taskStateList.add(pgyResultSearchTask);
    } else {
      taskStateList.add(uploadToObsTask);
      taskStateList.add(generateObsUploadResTask);
    }

    notifyListeners();
  }

  /// 初始化一个快速上传的任务队列
  void initFastUploadTaskList(String apkPath) {
    apkToUpload = apkPath;
    if (selectedUploadPlatform!.index == 0) {
      // 0 pgy
      taskStateList.add(pgyTokenFetchTask);
      taskStateList.add(uploadToPgyTask);
      taskStateList.add(pgyResultSearchTask);
    } else {
      // 1 obs
      taskStateList.add(uploadToObsTask);
      taskStateList.add(generateObsUploadResTask);
    }
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

  List<String> findLinesIfLengthEquals(
      {required List<String> lines, required int length}) {
    List<String> result = [];

    for (String line in lines) {
      if (line.length != length) {
        result.add(line.trim());
      }
    }

    return result;
  }

  PgyEntity? _pgyEntity;

  Color idleColor = Colors.grey;

  Color executingColor = Colors.blue;
  Color finishedColor = Colors.green;
  Color errColor = Colors.red;

  Color getStatueColor(TaskStage state) {
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
    TaskStage c = taskStateList[index];
    c.stageStatue = newStatue;
    notifyListeners();
  }

  final stageScrollerController = ScrollController();

  void updateStageCostTime(int index, String costTime) {
    TaskStage c = taskStateList[index];
    c.stageCostTime = costTime;

    notifyListeners();
  }

  void updateStateStarted(int index) {
    // 每个项目的高度，根据实际情况进行调整
    double itemWidth = 100.0;
    // 指定的 item 在 ListView 中的偏移量
    double offset = index * itemWidth;
    if (stageScrollerController.hasClients) {
      stageScrollerController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500), // 动画持续时间
        curve: Curves.easeInOut, // 动画曲线
      );
    }
  }

  void cleanLog() {
    _cmdExecLog.clear();
    notifyListeners();
  }

  TempLogCacheEntity tempLog = TempLogCacheEntity();

  void addNewLogLine(String s) {
    if (s.isEmpty) {
      _cmdExecLog.add(s);
    } else {
      _cmdExecLog.add(
          "${Jiffy.now().format(pattern: "yyyy-MM-dd HH:mm:ss")}        $s");
    }
    notifyListeners();
    _scrollToBottom();
  }

  void addNewEmptyLine() {
    addNewLogLine("\n\n\n");
  }

  ///添加一个延时，以确保listView绘制完毕，再来计算最底端的位置
  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 300), () {
      if (logListViewScrollController.hasClients != true) {
        return;
      }

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
    var t = int.tryParse(EnvConfigOperator.searchEnvValue(
            Const.stageTaskExecuteMaxPeriod)) ??
        5;

    await Future.delayed(Duration(minutes: t));
  }

  double calTaskProcessValue(int taskCount, int current) {
    return ((current / taskCount) * 100).roundToDouble();
  }

  ///
  /// 开始流水线工作
  ///
  Future<OrderExecuteResult?> startSchedule() async {
    cleanLog();

    if (_workThreadRunning) {
      return OrderExecuteResult(succeed: false, msg: "任务正在执行中...");
    }

    _workThreadRunning = true;

    addNewLogLine("开始流程...${taskStateList.length}");

    OrderExecuteResult? actionResStr;

    Stopwatch totalWatch = Stopwatch();
    totalWatch.start();

    onProcessChanged?.call(10);

    // 开始整体流程
    for (int i = 0; i < taskStateList.length; i++) {
      bool taskOk = false;
      onProcessChanged?.call(calTaskProcessValue(taskStateList.length, i));

      // 对每个阶段执行 规定最大次数的循环
      for (int j = 0; j < maxTimes; j++) {
        // 任务变为执行中的状态
        updateStatue(i, StageStatue.executing);

        // 开始单次执行的计时器
        Stopwatch stageTimeWatch = Stopwatch();
        stageTimeWatch.start();

        var stage = taskStateList[i];
        var taskName = stage.stageName;
        var taskFuture = stage.actionFunc();
        addNewLogLine("第${j + 1}次 执行开始: $taskName");

        TaskStage.onStageStartedFunc?.call(i);

        var stageResult =
            await Future.any([taskFuture, timeOutCounter()]); // 计算超时

        stageTimeWatch.stop(); // 停止计时器

        // 如果任务在规定时间之内完成，则一定会返回一个OrderExecuteResult
        if (stageResult is OrderExecuteResult) {
          // 如果执行成功，则标记此阶段已完成
          if (stageResult.succeed == true) {
            TaskStage.onStateFinishedFunc
                ?.call(i, "cost ${stageTimeWatch.elapsed.inMilliseconds} ms");
            taskOk = true;
            addNewLogLine("第${j + 1}次 执行成功: $taskName - $stageResult");
            addNewEmptyLine();
            stage.executeResultData = stageResult; // 保存当前阶段的执行成功的结果
            actionResStr = stageResult; // 本次任务的执行结果
            break;
          } else {
            updateStatue(i, StageStatue.error);
            if (j == maxTimes - 1) {
              // 失败则打印日志，3秒后开始下一轮
              addNewLogLine("第${j + 1}次 执行失败: $taskName - $stageResult");
            } else {
              // 失败则打印日志，3秒后开始下一轮
              addNewLogLine(
                  "第${j + 1}次 执行失败: $taskName - $stageResult 3秒后开始下一轮");
              addNewEmptyLine();

              stage.executeResultData = stageResult;
              actionResStr = stageResult;
              await waitSomeSec();
            }
          }
        } else {
          // 如果没返回 OrderExecuteResult，那么一定是超时了
          addNewLogLine("第${j + 1}次 执行超时: $taskName, 3秒后开始下一轮");
          addNewEmptyLine();

          // 如果到了最后一次
          if (j == maxTimes - 1) {
            actionResStr = OrderExecuteResult(
                succeed: false, msg: "第${j + 1}次:$stageResult");
            CommandUtil.getInstance().stopAllExec();
            break;
          }
        }
      }

      if (taskOk) {
        updateStatue(i, StageStatue.finished);
      } else {
        updateStatue(i, StageStatue.error);
        _workThreadRunning = false;
        break;
      }
    }

    totalWatch.stop();
    _workThreadRunning = false;

    return OrderExecuteResult(
        succeed: true,
        msg:
            "${Jiffy.now().format(pattern: "yyyy年MM月dd日 HH:mm:ss ")}\n${actionResStr?.msg}，任务总共花费时间${totalWatch.elapsed.inMilliseconds} ms ",
        data: actionResStr?.data);
  }

  void _reset() {
    taskStateList.clear();
    _cmdExecLog.clear();
    gitUrlController.text = '';
    projectNameController.text = '';
    gitBranchController.text = "";
    projectPathController.text = "";
    projectAppDescController.text = "";
    updateLogController.text = "";
    apkLocationController.text = "";
    selectedOrder = "";
    selectedOrderController.text = "";
    selectedUploadPlatform = null;
    selectedUploadPlatformController.text = "";
    runningTask = null;
    notifyListeners();
  }

  // 工程任务队列相关
  final ListQueue<ProjectRecordEntity> _taskQueue =
      ListQueue<ProjectRecordEntity>();

  bool hasTask() => _taskQueue.isNotEmpty;

  List<ProjectRecordEntity> getQueueList() => _taskQueue.toList();

  String taskQueueString() => _taskQueue.map((e) => "$e\n").toList().toString();

  bool enqueue(ProjectRecordEntity e) {
    // 入列的时候，一定要检查是否重复，如果重复，拒绝入列
    for (var element in getQueueList()) {
      if (e == element) {
        return false;
      }
    }

    if (runningTask != null) {
      if (e == runningTask) {
        return false;
      }
    }

    _taskQueue.add(e);
    _loop();

    return true;
  }

  Function? onTaskFinished;

  void setProjectPath() {
    var gitText = gitUrlController.text;

    var lastSepIndex = gitText.lastIndexOf("/");
    var endIndex = gitText.length - 4;
    assert(endIndex > 0);
    String projectName = gitText.substring(lastSepIndex + 1, endIndex);
    projectPathController.text =
        EnvConfigOperator.searchEnvValue(Const.envWorkspaceRootKey) +
            Platform.pathSeparator +
            projectName;
  }

  /// 开始项目激活
  Future<void> startActive() async {
    gitUrlController.text = runningTask!.gitUrl;
    gitBranchController.text = runningTask!.branch;
    setProjectPath();

    initPreCheckTaskList();
    var value = await startSchedule();
    if (value == null) {
      setProjectRecordJobRunning(false);
      _reset();
      return;
    }

    if (value.succeed != true || value.data is! List<String>) {
      setProjectRecordJobRunning(false);
      _reset();
      return;
    }

    onProjectActiveFinished(value.data);
    _reset();
    onTaskFinished?.call();
  }

  void refresh() {
    _taskQueue.clear();
    notifyListeners();
  }

  ProjectRecordEntity? runningTask;

  /// 项目激活成功之后
  void onProjectActiveFinished(List<String> assembleOrders) {
    if (assembleOrders.isNotEmpty) {
      runningTask!.preCheckOk = true;
      runningTask!.assembleOrders = assembleOrders;
      setProjectRecordJobRunning(false);
    }
    _reset();
    notifyListeners();
  }

  Timer? taskTimer;

  void _loop() {
    if (taskTimer != null) {
      // 只允许一个定时器
      return;
    }
    // 每隔3秒，查找队列中是否有任务
    taskTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (runningTask == null && _taskQueue.isNotEmpty) {
        runningTask = _taskQueue.removeFirst();
        setProjectRecordJobRunning(true);
        assert(runningTask != null);
        debugPrint("准备切入新任务，请稍后... ${runningTask!.projectName}");
        // 如果此工程已经激活成功，那么，直接进行打包
        // 将这些信息填入到 表单中
        gitUrlController.text = runningTask!.gitUrl;
        gitBranchController.text = runningTask!.branch;
        setProjectPath();
        projectNameController.text = runningTask!.projectName ?? '';
        projectAppDescController.text = runningTask!.projectDesc ?? '';

        if (runningTask!.apkPath != null && runningTask!.apkPath!.isNotEmpty) {
          selectedUploadPlatform = runningTask!.setting!.selectedUploadPlatform;
          selectedUploadPlatformController.text =
              selectedUploadPlatform!.name ?? '';
          apkLocationController.text = runningTask!.apkPath!;

          await startFastUpload(runningTask!.apkPath!);
        } else if (runningTask!.preCheckOk == true) {
          updateLogController.text = runningTask!.setting!.appUpdateLog ?? '';
          apkLocationController.text = runningTask!.setting!.apkLocation ?? '';
          selectedOrder = runningTask!.setting!.selectedOrder ?? "";
          selectedOrderController.text = selectedOrder!;
          selectedUploadPlatform = runningTask!.setting!.selectedUploadPlatform;
          selectedUploadPlatformController.text =
              selectedUploadPlatform!.name ?? '';
          await startPackage();
        } else {
          // 否则，先进行激活
          await startActive();
        }
      } else {
        if (runningTask != null) {
          // debugPrint("当前有任务正在执行，请稍后... ${runningTask?.projectName}");
        } else if (_taskQueue.isEmpty) {
          // debugPrint("任务队列为空...");
        }
      }
    });
  }

  MyAppInfo? myAppInfo;

  Future<void> startPackage() async {
    initPackageTaskList();
    var scheduleRes = await startSchedule();

    if (scheduleRes == null) {
      setProjectRecordJobRunning(false);
      _reset();
      return;
    }
    if (scheduleRes.succeed == true && scheduleRes.data is MyAppInfo) {
      myAppInfo = scheduleRes.data;
    } else {
      myAppInfo = MyAppInfo(errMessage: scheduleRes.msg);
    }

    onProjectPackageFinished(myAppInfo!);
  }

  Future<void> startFastUpload(String apkPath) async {
    initFastUploadTaskList(apkPath);
    var scheduleRes = await startSchedule();

    if (scheduleRes == null) {
      setProjectRecordJobRunning(false);
      _reset();
      return;
    }
    if (scheduleRes.succeed == true && scheduleRes.data is MyAppInfo) {
      myAppInfo = scheduleRes.data;
    } else {
      myAppInfo = MyAppInfo(errMessage: scheduleRes.msg);
    }

    onProjectPackageFinished(myAppInfo!);
  }

  /// 流程结束时，无论成功或者失败
  void onProjectPackageFinished(MyAppInfo myAppInfo) {
    var his = runningTask!.jobHistory;
    if (his == null) {
      runningTask!.jobHistory = [];
    }
    runningTask!.jobHistory!.add(myAppInfo.toJsonString());
    setProjectRecordJobRunning(false);
    _reset();
  }

  void _updateToDb() => ProjectRecordOperator.insertOrUpdate(runningTask!);

  void setProjectRecordJobRunning(bool running) {
    runningTask!.jobRunning = running;
    _updateToDb();
    notifyListeners();
  }
}
