import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

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
    EnvParams.gitRoot = [];
    EnvParams.flutterRoot = [];
    EnvParams.adbRoot = [];
    EnvParams.jdkRoot = [];
    EnvParams.androidSdkRoot = [];
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

  void _addToEnv(String e, List<String> listEnv) {
    File f = File(e);
    if (f.parent.existsSync()) {
      listEnv.add(f.parent.path + Platform.pathSeparator);
    }
  }

  void _saveEnv(String path, Function(String) action, List<String> listEnv) {
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

  Future initEnvParam({required Function(String) action}) async {
    restEnvParam();

    await whereCmd(
        order: "git",
        action: (path) => _saveEnv(path, action, EnvParams.gitRoot));
    action("gitRoot = ${EnvParams.gitRoot.distinct()}");

    await whereCmd(
        order: "flutter",
        action: (path) => _saveEnv(path, action, EnvParams.flutterRoot));
    action("flutterRoot =${EnvParams.flutterRoot.distinct()}");

    await whereCmd(
        order: "adb",
        action: (path) => _saveEnv(path, action, EnvParams.adbRoot));
    action("flutterRoot =${EnvParams.adbRoot.distinct()}");

    await echoCmd(
        order: "%JAVA_HOME%",
        action: (path) {
          Directory d = Directory(path);
          if (d.existsSync()) {
            EnvParams.jdkRoot.add(d.path);
          }
        });
    action("javaRoot = ${EnvParams.jdkRoot.distinct()}");

    await echoCmd(
        order: "%ANDROID_HOME%",
        action: (path) {
          Directory d = Directory(path);
          if (d.existsSync()) {
            EnvParams.androidSdkRoot.add(d.path);
          }
        });
    action("javaRoot = ${EnvParams.androidSdkRoot.distinct()}");

    action("环境参数读取完毕...");
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
      debugPrint(
          "${process.pid} 已经添加， 当前 _allProcess 中有 ${_allProcess.length} 个进程");

      return process;
    } catch (e, r) {
      debugPrint("$e $r");
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
    debugPrint("准备kill $pid");
    if (p == null) {
      return;
    }

    var killResult = p.kill();
    _allProcess.removeWhere((element) => element.process.pid == p.pid);

    debugPrint(
        "$pid kill结果为： $killResult, 当前 进程列表中还有 ${_allProcess.length} 个进程");
  }

  /// 停止所有命令的输出
  void stopAllExec() {
    debugPrint("准备批量清空 进程,当前 size ${_allProcess.length}");
    for (var p in _allProcess) {
      p.process.kill();
      p.stdoutLis.cancel();
      p.stderrLis.cancel();
    }
    _allProcess.clear();
    debugPrint("清空完成，当前 size ${_allProcess.length}");
  }
}

class EnvParams {
  static List<String> gitRoot = [];
  static List<String> flutterRoot = [];
  static List<String> adbRoot = [];

  static List<String> androidSdkRoot = [];
  static List<String> jdkRoot = [];

  static String workRoot = "D:\\packTest";
}

// 给 List<String> 类型增加一个扩展方法
extension ListExtension on List<String> {
  List<String> distinct() {
    List<String> list = this;
    if (list.isEmpty) return [];

    Set<String> uniqueItems = {};
    for (var item in list) {
      if (!uniqueItems.contains(item)) {
        uniqueItems.add(item);
      }
    }

    return uniqueItems.toList();
  }

  String? distinctAndFirst() {
    List<String> list = this;
    if (list.isEmpty) return null;

    Set<String> uniqueItems = {};
    for (var item in list) {
      if (!uniqueItems.contains(item)) {
        uniqueItems.add(item);
        return item;
      }
    }

    return null;
  }
}
