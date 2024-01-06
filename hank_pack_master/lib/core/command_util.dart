import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

bool cmdDebug = true;

debugCmdPrint(String msg) {
  if (cmdDebug) {
    debugPrint(msg);
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
    stopExec(process);
  }

  ///
  /// 使用where命令查看 可执行文件的根目录
  ///
  /// [order] where后面接的参数
  /// [workDir] 工作目录
  /// [action] 输出动作
  ///
  Future echoCmd(
      {required String order, required Function(String) action}) async {
    var process = await execute(
      workDir: EnvParams.workRoot,
      cmd: "cmd",
      params: ['/c', "echo", order],
      action: action,
    );
    await process?.exitCode;
    stopExec(process);
  }

  void _addToEnv(String e, Set<String> listEnv) {
    File f = File(e);
    if (f.parent.existsSync()) {
      listEnv.add(f.parent.path + Platform.pathSeparator);
    }
  }

  void _saveEnv(String path, Function(String) action, Set<String> listEnv) {
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
        action: (path) => _saveEnv(path, action, EnvParams.gitRoot));
    action("gitRoot = ${EnvParams.gitRoot}");
  }

  Future initFlutterRoot(Function(String) action) async {
    await whereCmd(
        order: "flutter",
        action: (path) => _saveEnv(path, action, EnvParams.flutterRoot));
    action("flutterRoot =${EnvParams.flutterRoot}");
  }

  Future initAdbRoot(Function(String) action) async {
    await whereCmd(
        order: "adb",
        action: (path) => _saveEnv(path, action, EnvParams.adbRoot));
    action("adbRoot =${EnvParams.adbRoot}");
  }

  Future initJavaRoot(Function(String) action) async {
    await whereCmd(
        order: "java",
        action: (path) => _saveEnv(path, action, EnvParams.javaRoot));
    action("javaRoot =${EnvParams.javaRoot}");
  }

  Future initAndroidRoot(Function(String) action) async {
    await echoCmd(
        order: "%ANDROID_HOME%",
        action: (path) {
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
        return checkGit(binRoot);
      case "flutter":
        return checkFlutter(binRoot);
      case "adb":
        return checkAdb(binRoot);
      case "android":
        return checkAndroid(binRoot);
      case "java":
        return checkJava(binRoot);
    }
    return "";
  }

  ///
  /// 如果git --version命令能走通，那就说明可用
  ///
  Future<String> checkGit(String binRoot) async {
    StringBuffer sb = StringBuffer();

    var process = await execute(
      binRoot: binRoot,
      cmd: "git",
      params: ["--version"],
      workDir: EnvParams.workRoot,
      action: (res) {
        debugPrint("checkGit---> $res");
        sb.writeln(res);
      },
    );
    var exitCode = await process?.exitCode;
    stopExec(process);

    return "$exitCode $sb";
  }

  ///
  /// 如果 adb --version 命令能走通，那就说明可用
  ///
  Future<String> checkAdb(String binRoot) async {
    StringBuffer sb = StringBuffer();
    var process = await execute(
      binRoot: binRoot,
      cmd: "adb",
      params: ["--version"],
      workDir: EnvParams.workRoot,
      action: (res) {
        debugPrint("checkAdb---> $res");
        sb.writeln(res);
      },
    );
    var exitCode = await process?.exitCode;
    stopExec(process);
    return "$exitCode $sb";
  }

  ///
  /// 如果 flutter.bat doctor 命令能走通，那就说明可用
  ///
  Future<String> checkFlutter(String binRoot) async {
    StringBuffer sb = StringBuffer();
    var process = await execute(
      binRoot: binRoot,
      cmd: "flutter.bat",
      params: ["doctor"],
      workDir: EnvParams.workRoot,
      action: (res) {
        debugPrint("checkFlutter---> $res");
        EasyLoading.show(status: res);
        sb.writeln(res);
      },
    );
    var exitCode = await process?.exitCode;
    stopExec(process);
    return "$exitCode $sb";
  }

  ///
  /// 如果 java -version 命令能走通，那就说明可用
  ///
  Future<String> checkJava(String binRoot) async {
    StringBuffer sb = StringBuffer();
    var process = await execute(
      binRoot: binRoot,
      cmd: "java",
      params: ["-version"],
      workDir: EnvParams.workRoot,
      action: (res) {
        debugPrint("checkJava---> $res");
        sb.writeln(res);
      },
    );
    var exitCode = await process?.exitCode;
    stopExec(process);
    return "$exitCode $sb";
  }

  ///
  /// 如果 sdkmanager --version 命令能走通，那就说明可用
  ///
  Future<String> checkAndroid(String binRoot) async {
    StringBuffer sb = StringBuffer();
    var process = await execute(
      binRoot: "$binRoot\\cmdline-tools\\latest\\bin\\",
      cmd: "sdkmanager.bat",
      params: ["--version"],
      workDir: EnvParams.workRoot,
      action: (res) {
        debugPrint("checkAndroid---> $res");
        sb.writeln(res);
      },
    );
    var exitCode = await process?.exitCode;
    stopExec(process);
    return "$exitCode $sb";
  }

  Future<Map<String, Set<String>>> initEnvParam(
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
      debugCmdPrint("$e $r");
      // onError?.call('$binRoot$cmd 命令执行失败 ： $e  $r');
    }

    return null;
  }

  String _utf8Trans(List<int> ori) {
    try {
      return utf8.decode(ori);
    } catch (e) {
      return ori.toString();
    }
  }

  void stopExec(Process? p) {
    debugCmdPrint("准备kill $pid");
    if (p == null) {
      return;
    }

    var killResult = p.kill();
    _allProcess.removeWhere((element) => element.process.pid == p.pid);

    debugCmdPrint(
        "$pid kill结果为： $killResult, 当前 进程列表中还有 ${_allProcess.length} 个进程");
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
}

class EnvParams {
  static Set<String> gitRoot = <String>{};
  static Set<String> flutterRoot = <String>{};
  static Set<String> adbRoot = <String>{};

  static Set<String> androidSdkRoot = <String>{};
  static Set<String> javaRoot = <String>{};

  static String workRoot = "C:\\";
}
