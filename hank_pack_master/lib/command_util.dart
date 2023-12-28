import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';

///
/// 执行命令行的唯一类
///
///
///
///
class CommandUtil {
  static void restEnvParam() {
    EnvParams.gitRoot = [];
    EnvParams.flutterRoot = [];
    EnvParams.dartRoot = [];
    EnvParams.adbRoot = [];
  }

  ///
  /// 使用where命令查看 可执行文件的根目录
  ///
  /// [order] where后面接的参数
  /// [workDir] 工作目录
  /// [action] 输出动作
  ///
  static Future whereCmd(
      {required String order,
      required String workDir,
      required Function(String) action}) async {
    var process = await execute(
      cmd: "where",
      params: [order],
      workDir: workDir,
      action: action,
    );
    await process?.exitCode;
  }

  static void initEnvParam({required Function(String) action}) async {
    restEnvParam();

    await whereCmd(
        order: "git",
        workDir: EnvParams.workRoot,
        action: (res) {
          File f = File(res);
          if (f.existsSync()) {
            EnvParams.gitRoot.add(f.parent.path + Platform.pathSeparator);
          }
        });
    action("gitRoot = ${EnvParams.gitRoot.length}  ${EnvParams.gitRoot}");

    await whereCmd(
        order: "flutter",
        workDir: EnvParams.workRoot,
        action: (res) {
          File f = File(res);
          if (f.existsSync()) {
            EnvParams.flutterRoot.add(f.parent.path + Platform.pathSeparator);
          }
        });
    action(
        "flutterRoot =${EnvParams.flutterRoot.length} ${EnvParams.flutterRoot}");

    await whereCmd(
        order: "dart",
        workDir: EnvParams.workRoot,
        action: (res) {
          File f = File(res);
          if (f.existsSync()) {
            EnvParams.dartRoot.add(f.parent.path + Platform.pathSeparator);
          }
        });
    action("dartRoot = ${EnvParams.dartRoot.length}   ${EnvParams.dartRoot}");

    await whereCmd(
        order: "adb",
        workDir: EnvParams.workRoot,
        action: (res) {
          File f = File(res);
          if (f.existsSync()) {
            EnvParams.adbRoot.add(f.parent.path + Platform.pathSeparator);
          }
        });
    action("adbRoot = ${EnvParams.adbRoot.length}  ${EnvParams.adbRoot}");

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
  static Future<Process?> execute({
    String binRoot = "",
    required String cmd,
    required List<String> params,
    required String workDir,
    required Function(String res) action,
  }) async {

    if (binRoot.endsWith(Platform.pathSeparator)) {
      debugPrint("$binRoot 必须以分隔符结尾");
      return null;
    }

    try {
      var process = await Process.start("$binRoot$cmd", params,
          workingDirectory: workDir);

      refreshAction(data) {
        String r = _utf8Trans(data).trim();
        if (r.isNotEmpty) {
          action(r);
        }
      }

      process.stdout.listen(refreshAction);
      process.stderr.listen(refreshAction);

      return process;
    } catch (e, r) {
      showToast("$e  $r");
    }

    return null;
  }

  static String _utf8Trans(List<int> ori) {
    try {
      return utf8.decode(ori);
    } catch (e, r) {
      return ori.toString();
    }
  }
}

class EnvParams {
  static List<String> gitRoot = [];
  static List<String> flutterRoot = [];
  static List<String> dartRoot = [];
  static List<String> adbRoot = [];

  static String workRoot = "D:\\packTest";
}
