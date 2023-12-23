import 'dart:convert';
import 'dart:io';

import 'package:oktoast/oktoast.dart';

///
/// 执行命令行的唯一类
///
///
///
///
class CommandUtil {
  ///
  /// 注意事项，
  /// 1、如果是.exe结尾的命令，比如 git ，[cmd] 参数 直接赋值为 git即可，但是如果是 .bat结尾的命令，就必须写全 flutter.bat
  /// 2、如果是同时执行多个命令，那么多个命令的 执行结果都有可能通过 [onLoadRes] 函数输出出去，如果向结束执行，取得 [execute] 的返回值Process之后，执行kill
  ///
  /// [binRoot] 可执行文件的路径
  /// [cmd] 命令
  /// [params] 命令执行的参数列表
  /// [workDir] 命令执行的当前目录
  /// [onLoadRes] 当有执行结果输出时执行的函数
  ///
  ///
  ///
  static void execute({
    required String binRoot,
    required String cmd,
    required List<String> params,
    required String workDir,
    required Function(String res) onLoadRes,
  }) async {
    if (binRoot != "" && !binRoot.endsWith(Platform.pathSeparator)) {
      showToast("binRoot 必须以分隔符结尾");
      return;
    }

    try {
      var process = await Process.start("$binRoot$cmd", params,
          workingDirectory: workDir);
      process.stdout.listen((data) => onLoadRes(utf8.decode(data)));
      process.stderr.listen((data) => onLoadRes(utf8.decode(data)));
      // 等待命令执行完成
      var exitCode = await process.exitCode;
      onLoadRes("命令执行完成，exitCode = $exitCode");
    } catch (e) {
      showToast("$e");
    }
  }
}
