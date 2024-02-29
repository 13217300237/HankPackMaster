import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../comm/apk_parser_result.dart';
import '../comm/str_const.dart';
import '../hive/env_config/env_config_operator.dart';

bool cmdDebug = true;

debugCmdPrint(String msg) {
  if (cmdDebug) {
    debugPrint(msg);
  }
}

class ExecuteResult {
  String res;
  int exitCode;
  dynamic data;

  ExecuteResult(this.res, this.exitCode, {this.data});

  @override
  String toString() {
    return "$exitCode \n  $res";
  }
}

class EnvCheckEntity {
  String cmd;
  String param;

  EnvCheckEntity(this.cmd, this.param);

  @override
  String toString() {
    return "$cmd  $param";
  }
}

class MyProcess {
  Process process;

  StreamSubscription<List<int>> stdoutLis;
  StreamSubscription<List<int>> stderrLis;

  MyProcess(
      {required this.process,
      required this.stdoutLis,
      required this.stderrLis});
}

///
/// 执行命令行的唯一类
///
///
///
///
class CommandUtil {
  static CommandUtil? _instance;

  // 私有的构造函数
  CommandUtil._();

  // 公共的静态方法获取实例
  static CommandUtil getInstance() {
    _instance ??= CommandUtil._();
    return _instance!;
  }

  /// 维护一个Process列表
  ///
  final List<MyProcess> _allProcess = [];

  void restEnvParam() {
    EnvParams.gitRoot = <String>{};
    EnvParams.flutterRoot = <String>{};
    EnvParams.adbRoot = <String>{};
    EnvParams.javaRoot = <String>{};
    EnvParams.androidSdkRoot = <String>{};
  }

  Function(String res)? onError;

  ///
  /// 使用where命令查看 可执行文件的根目录
  ///
  /// [order] where后面接的参数
  /// [workDir] 工作目录
  /// [action] 输出动作
  ///
  Future whereCmd(
      {required String order, required Function(String) action}) async {
    var process = await execute(
      cmd: "where",
      params: [order],
      workDir: EnvParams.workRoot,
      action: action,
    );
    await process?.exitCode;
    _stopExec(process);
  }

  ///
  /// 使用where命令查看 可执行文件的根目录
  ///
  ///
  /// ！！！！！！ 2024年1月18日 发现，echo命令并不能实时查询环境变量的值  ！！！！！
  ///
  /// [order] where后面接的参数
  /// [workDir] 工作目录
  /// [action] 输出动作
  ///
  Future<String> echoCmd(
      {required String order, required Function(String) action}) async {
    StringBuffer sb = StringBuffer();
    var process = await execute(
      workDir: EnvParams.workRoot,
      cmd: "cmd",
      params: ['/c', "echo", order],
      action: (r) {
        action(r);
        sb.writeln(r);
      },
    );
    await process?.exitCode;
    debugPrint("pid : ${process?.pid}");
    _stopExec(process);

    return sb.toString().trim();
  }

  Future<String> openEnvSetting({Function(String)? action}) async {
    StringBuffer sb = StringBuffer();
    var process = await execute(
      workDir: EnvParams.workRoot,
      cmd: "cmd",
      params: ['/c', "rundll32", "sysdm.cpl,EditEnvironmentVariables"],
      action: (r) {
        action?.call(r);
        sb.writeln(r);
      },
    );
    await process?.exitCode;
    debugPrint("pid : ${process?.pid}");
    _stopExec(process);

    return sb.toString().trim();
  }

  void _addToEnv(String e, Set<String> listEnv) {
    File f = File(e);
    if (f.parent.existsSync()) {
      listEnv.add(f.parent.path + Platform.pathSeparator);
    }
  }

  void _saveEnv(
      String order, String path, Function(String) action, Set<String> listEnv) {
    // 检查结果里面有没有换行符
    if (path.contains("\n")) {
      // 包含换行符就按照换行符截断成多段，按照多段来解析
      var arr = path.split("\n");
      for (var e in arr) {
        _addToEnv(e, listEnv);
      }
    } else {
      _addToEnv(path, listEnv);
    }
  }

  Future initGitRoot(Function(String) action) async {
    await whereCmd(
        order: "git",
        action: (path) => _saveEnv("git", path, action, EnvParams.gitRoot));
    action("gitRoot = ${EnvParams.gitRoot}");
  }

  Future initFlutterRoot(Function(String) action) async {
    await whereCmd(
        order: "flutter",
        action: (path) =>
            _saveEnv("flutter", path, action, EnvParams.flutterRoot));
    action("flutterRoot =${EnvParams.flutterRoot}");
  }

  Future initAdbRoot(Function(String) action) async {
    await whereCmd(
        order: "adb",
        action: (path) {
          debugPrint("=======================================  $path");
          _saveEnv("adb", path, action, EnvParams.adbRoot);
        });
    action("adbRoot =${EnvParams.adbRoot}");
  }

  Future initJavaRoot(Function(String) action) async {
    await whereCmd(
        order: "java",
        action: (path) => _saveEnv("java", path, action, EnvParams.javaRoot));
    action("javaRoot =${EnvParams.javaRoot}");
  }

  Future initAndroidRoot(Function(String) action) async {
    await echoCmd(
        order: "%ANDROID_HOME%",
        action: (path) {
          debugPrint("androidHome -> $path");
          Directory d = Directory(path);
          if (d.existsSync()) {
            EnvParams.androidSdkRoot.add(d.path);
          }
        });
    action("androidRoot = ${EnvParams.androidSdkRoot}");
  }

  // 2024年1月4日 检查gitRoot的可用性，尝试执行version指令
  Future<String> checkEnv(String title, String binRoot) async {
    switch (title) {
      case "git":
        return _checkGit(binRoot);
      case "flutter":
        return _checkFlutter(binRoot);
      case "adb":
        return _checkAdb(binRoot);
      case "android":
        return _checkAndroid(binRoot);
      case "java":
        return _checkJava(binRoot);
    }
    return "";
  }

  Future<String> checkVersion(String binRoot) async {
    StringBuffer sb = StringBuffer();
    var process = await CommandUtil.getInstance().execute(
      cmd: '"$binRoot" --version',
      params: [],
      action: (s) {
        sb.writeln(s);
      },
      workDir: EnvParams.workRoot,
    );
    await process?.exitCode;
    _stopExec(process);
    return sb.toString();
  }

  ///
  /// 如果git --version命令能走通，那就说明可用
  ///
  Future<String> _commCheckFunc(
      EnvCheckEntity envCheckEntity, String binRoot) async {
    StringBuffer sb = StringBuffer();

    var process = await execute(
      binRoot: binRoot,
      cmd: envCheckEntity.cmd,
      params: [envCheckEntity.param],
      workDir: EnvParams.workRoot,
      action: (res) {
        debugPrint("${envCheckEntity.cmd}---> $res");
        EasyLoading.show(status: res, maskType: EasyLoadingMaskType.clear);
        sb.writeln(res);
      },
    );
    var exitCode = await process?.exitCode;
    _stopExec(process);

    return """
    
    cmd: $envCheckEntity
    
    exitCode : $exitCode
    
    $sb
    """;
  }

  ///
  /// 如果git --version命令能走通，那就说明可用
  ///
  Future<String> _checkGit(String binRoot) async {
    return _commCheckFunc(EnvCheckEntity("git", "--version"), binRoot);
  }

  ///
  /// 如果 adb --version 命令能走通，那就说明可用
  ///
  Future<String> _checkAdb(String binRoot) async {
    return _commCheckFunc(EnvCheckEntity("adb", "--version"), binRoot);
  }

  ///
  /// 如果 flutter.bat doctor 命令能走通，那就说明可用
  ///
  Future<String> _checkFlutter(String binRoot) async {
    return _commCheckFunc(EnvCheckEntity("flutter.bat", "doctor"), binRoot);
  }

  ///
  /// 如果 java -version 命令能走通，那就说明可用
  ///
  Future<String> _checkJava(String binRoot) async {
    return _commCheckFunc(EnvCheckEntity("java", "--version"), binRoot);
  }

  ///
  /// 如果 sdkmanager --version 命令能走通，那就说明可用
  ///
  Future<String> _checkAndroid(String binRoot) async {
    return _commCheckFunc(EnvCheckEntity("sdkmanager.bat", "--version"),
        "$binRoot\\cmdline-tools\\latest\\bin\\");
  }

  Future<Map<String, Set<String>>> _initAllEnvParam(
      {required Function(String) action}) async {
    restEnvParam();

    await initGitRoot(action);
    await initFlutterRoot(action);
    await initAdbRoot(action);
    await initJavaRoot(action);
    await initAndroidRoot(action);

    action("环境参数读取完毕...");
    Map<String, Set<String>> params = {};

    params["git"] = EnvParams.gitRoot;
    params["adb"] = EnvParams.adbRoot;
    params["flutter"] = EnvParams.flutterRoot;
    params["java"] = EnvParams.javaRoot;
    params["android"] = EnvParams.androidSdkRoot;

    return params;
  }

  ///
  /// 注意事项，
  /// 1、如果是.exe结尾的命令，比如 git ，[cmd] 参数 直接赋值为 git即可，但是如果是 .bat结尾的命令，就必须写全 flutter.bat
  /// 2、如果是同时执行多个命令，那么多个命令的 执行结果都有可能通过 [action] 函数输出出去，如果向结束执行，取得 [execute] 的返回值Process之后，执行kill
  ///
  /// [binRoot] 可执行文件的路径
  /// [cmd] 命令
  /// [params] 命令执行的参数列表
  /// [workDir] 命令执行的当前目录
  /// [action] 当有执行结果输出时执行的函数
  ///
  ///
  ///
  Future<Process?> execute({
    String binRoot = "",
    required String cmd,
    required List<String> params,
    required String workDir,
    required Function(String res) action,
  }) async {
    try {
      debugCmdPrint("cmd：$binRoot$cmd params->$params");
      debugCmdPrint("workDir：$workDir");
      debugCmdPrint("binRoot：$binRoot");
      var process = await Process.start("$binRoot$cmd", params,
          workingDirectory: workDir);

      loadAction(data) {
        String r = _utf8Trans(data).trim();
        if (r.isNotEmpty) {
          action(r);
        }
      }

      StreamSubscription<List<int>> stdoutLis =
          process.stdout.listen(loadAction);
      StreamSubscription<List<int>> stderrLis =
          process.stderr.listen(loadAction);

      _allProcess.add(MyProcess(
          process: process, stderrLis: stderrLis, stdoutLis: stdoutLis));
      debugCmdPrint(
          "${process.pid} 已经添加， 当前 _allProcess 中有 ${_allProcess.length} 个进程");

      return process;
    } catch (e, r) {
      debugCmdPrint("命令执行时报错：$e $r");
      return null;
    }

    return null;
  }

  String _utf8Trans(List<int> ori) {
    try {
      return utf8.decode(
        ori,
      );
    } catch (e) {
      debugPrint('遇到无法解析的结果 $ori');
      return "";
    }
  }

  void _stopExec(Process? p) {
    debugCmdPrint("准备kill ${p?.pid}");
    if (p == null) {
      return;
    }

    var killResult = p.kill();
    _allProcess.removeWhere((element) => element.process.pid == p.pid);

    debugCmdPrint(
        "${p.pid} kill结果为： $killResult, 当前 进程列表中还有 ${_allProcess.length} 个进程");
  }

  Future<ExecuteResult> gitClone({
    required String clonePath,
    required String gitUrl,
    required Function(String s) logOutput,
  }) async {
    StringBuffer sb = StringBuffer();

    String binRoot = EnvConfigOperator.searchEnvValue(Const.envGitKey);

    var process = await execute(
      cmd: '"$binRoot"',
      params: ["clone", gitUrl],
      workDir: clonePath,
      action: (res) {
        logOutput(res);
        sb.writeln(res);
      },
    );
    var exitCode = await process?.exitCode;
    _stopExec(process);

    String res = """
cmd: git clone
exitCode : $exitCode
$sb"""
        .trim();

    return ExecuteResult(res, exitCode!);
  }

  /// 采集最近一条提交记录
  Future<ExecuteResult> gitLog(
    String gitProjectDir,
    Function(String s) logOutput,
  ) async {
    StringBuffer sb = StringBuffer();
    var binRoot = EnvConfigOperator.searchEnvValue(Const.envGitKey);
    var process = await execute(
      cmd: '"$binRoot"',
      params: ["log", "-1", "--pretty=format:\"%s\""],
      workDir: gitProjectDir,
      action: (res) {
        sb.writeln(res);
      },
    );
    var exitCode = await process?.exitCode;
    _stopExec(process);

    String res = "$sb".trim();

    return ExecuteResult(res, exitCode!);
  }

  /// 方法内部还可以定义方法，这是dart的特色
  Map<String, dynamic> _parseAapt2Output(String output) {
    Map<String, dynamic> appInfo = {};

    List<String> split = output.split("\n");
    var targetStr = "package:";
    var packageInfo =
        split.firstWhere((element) => element.contains(targetStr));
    var sub = packageInfo
        .substring(packageInfo.indexOf(targetStr) + targetStr.length)
        .trim()
        .split(" ");

    Map<String, String> packageMap = {};

    for (String item in sub) {
      List<String> parts = item.split("=");
      String key = parts[0].replaceAll("'", "").trim();
      String value = parts[1].replaceAll("'", "").trim();
      packageMap[key] = value;
    }

    appInfo.addAll(packageMap);

    var targetStr2 = "application-label:";
    var applicationLabel =
        split.firstWhere((element) => element.contains(targetStr2));
    var appName = applicationLabel
        .substring(applicationLabel.indexOf(targetStr2) + targetStr2.length)
        .trim()
        .replaceAll('\'', '');

    appInfo['appName'] = appName;

    return appInfo;
  }

  int _parseVersionPart(String part) {
    if (part.contains(RegExp(r'[^0-9]'))) {
      // 如果part包含非数字字符，则只取第一个数字字串
      int? number = int.tryParse(part.replaceAll(RegExp(r'[^0-9].*'), ''));
      return number ?? 0;
    } else {
      return int.tryParse(part) ?? 0;
    }
  }

  Future<ExecuteResult> aapt(
    String apkPath, {
    Function(String s)? logOutput,
  }) async {
    // 执行 aapt2 命令获取 APK 中的应用信息
    var androidSdkPath = EnvConfigOperator.searchEnvValue(Const.envAndroidKey);
    debugPrint("androidSdkPath->$androidSdkPath");

    // 找出最新版的buildTool
    Directory directory = Directory('$androidSdkPath/build-tools');

    var oriList = directory.listSync();
    // 自定义比较函数对版本号进行排序
    oriList.sort((a, b) {
      List<String> partsA = path.basename(a.path).split('.');
      List<String> partsB = path.basename(b.path).split('.');

      for (int i = 0; i < partsA.length; i++) {
        if (i >= partsB.length) {
          return 1; // 如果a比b长，则a大
        }

        int numberA = _parseVersionPart(partsA[i]);
        int numberB = _parseVersionPart(partsB[i]);

        if (numberA != numberB) {
          return numberA.compareTo(numberB);
        }
      }

      return partsA.length.compareTo(partsB.length); // 版本号长度相同则通过长度比较
    });
    var lastPath = oriList.last;
    debugPrint("last.path->${lastPath.path}");

    ProcessResult result = await Process.run(
        '${lastPath.path}/aapt2.exe', ['dump', 'badging', apkPath],
        stdoutEncoding: utf8);

    if (result.exitCode == 0) {
      String output = result.stdout as String;

      // 解析应用信息
      Map<String, dynamic> appInfo = _parseAapt2Output(output);

      // 获取包名、版本号和版本名
      String? appName = appInfo['appName'];
      String? packageName = appInfo['name'];
      String? versionCode = appInfo['versionCode'];
      String? versionName = appInfo['versionName'];

      // 打印包名、版本号和版本名
      debugPrint('app Name: $appName');
      debugPrint('Package Name: $packageName');
      debugPrint('Version Code: $versionCode');
      debugPrint('Version Name: $versionName');
      return ExecuteResult("", exitCode,
          data: ApkParserResult(
            appName: appName,
            packageName: packageName,
            versioncode: versionCode,
            versionName: versionName,
          ));
    } else {
      debugPrint('Failed to get APK information using aapt2.');
      return ExecuteResult("", -1);
    }
  }

  Future<ExecuteResult> gitPull(
    String gitProjectDir,
    Function(String s) logOutput,
  ) async {
    StringBuffer sb = StringBuffer();

    var binRoot = EnvConfigOperator.searchEnvValue(Const.envGitKey);
    var process = await execute(
      cmd: '"$binRoot"',
      params: ["pull"],
      workDir: gitProjectDir,
      action: (res) {
        logOutput(res);
        sb.writeln(res);
      },
    );
    var exitCode = await process?.exitCode;
    _stopExec(process);

    String res = """
cmd: git pull
exitCode : $exitCode
$sb"""
        .trim();

    return ExecuteResult(res, exitCode!);
  }

  Future<ExecuteResult> gitCheckout(
    String gitProjectDir,
    String branchName,
    Function(String s) logOutput,
  ) async {
    StringBuffer sb = StringBuffer();

    var binRoot = EnvConfigOperator.searchEnvValue(Const.envGitKey);
    var process = await execute(
      cmd: '"$binRoot"',
      params: ["checkout", branchName],
      workDir: gitProjectDir,
      action: (res) {
        logOutput(res);
        sb.writeln(res);
      },
    );
    var exitCode = await process?.exitCode;
    _stopExec(process);

    String res = """
cmd: git checkout
exitCode : $exitCode
$sb"""
        .trim();

    return ExecuteResult(res, exitCode!);
  }

  Future<ExecuteResult> gradleAssembleTasks(
      String projectRoot, Function(String s) logOutput) async {
    StringBuffer sb = StringBuffer();
    // gradlew.bat app:tasks --all | findstr assemble
    var process = await execute(
      cmd: "gradlew.bat",
      params: ["app:tasks", "--all", "|", "findstr", "assemble"],
      workDir: projectRoot,
      binRoot: projectRoot + Platform.pathSeparator,
      action: (res) {
        logOutput.call(res);
        sb.writeln(res);
        debugCmdPrint(res);
      },
    );
    var exitCode = await process?.exitCode;
    _stopExec(process);

    String res = "$sb";

    return ExecuteResult(res, exitCode!);
  }

  Future<ExecuteResult> gradleAssemble(
      {required String projectRoot,
      required String packageOrder,
      required String versionName,
      required String versionCode,
      required Function(String s) logOutput}) async {
    StringBuffer sb = StringBuffer();

    List<String> params = [];
    params.add("clean");
    params.add(packageOrder);
    params.add("--stacktrace");

    debugPrint("$params");

    var process = await execute(
      cmd: "gradlew.bat",
      params: params,
      workDir: projectRoot,
      binRoot: projectRoot + Platform.pathSeparator,
      action: (res) {
        logOutput.call(res);
        sb.writeln(res);
        debugCmdPrint(res);
      },
    );
    var exitCode = await process?.exitCode;
    _stopExec(process);

    String res = """
    cmd: gradle assemble
    
    exitCode : $exitCode
    
    $sb
    """;

    return ExecuteResult(res, exitCode!);
  }

  /// 停止所有命令的输出
  void stopAllExec() {
    debugCmdPrint("准备批量清空 进程,当前 size ${_allProcess.length}");
    for (var p in _allProcess) {
      p.process.kill();
      p.stdoutLis.cancel();
      p.stderrLis.cancel();
    }
    _allProcess.clear();
    debugCmdPrint("清空完成，当前 size ${_allProcess.length}");
  }

  /// 设置系统环境变量 {setx}
  Future<ExecuteResult> setSystemEnvVar(String key, String value) async {
    StringBuffer sb = StringBuffer();
    var process = await execute(
        cmd: "setx",
        params: [key, value],
        workDir: EnvParams.workRoot,
        action: (res) {
          debugPrint("res---->$res");
          sb.writeln(res);
          debugCmdPrint(res);
        });
    var exitCode = await process?.exitCode;
    _stopExec(process);

    String res = """
    cmd: setx
    
    exitCode : $exitCode
    
    $sb
    """;

    return ExecuteResult(res, exitCode!);
  }
}

class EnvParams {
  static Set<String> gitRoot = <String>{};
  static Set<String> flutterRoot = <String>{};
  static Set<String> adbRoot = <String>{};

  static Set<String> androidSdkRoot = <String>{};
  static Set<String> javaRoot = <String>{};

  static String workRoot = "C:\\";
}
