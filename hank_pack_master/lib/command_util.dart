import 'dart:convert';
import 'dart:io';

///
/// 执行命令行的唯一类
///
///
///
class CommandUtil {
  ///
  /// [binRoot] 可执行文件的路径
  /// [cmd] 命令
  /// [params] 命令执行的参数列表
  /// [workDir] 命令执行的当前目录
  /// [onLoadRes] 当有执行结果输出时执行的函数
  static void execute({
    required String binRoot,
    required String cmd,
    required List<String> params,
    required String workDir,
    required Function(String res) onLoadRes,
  }) async {
    var process =
        await Process.start("$binRoot$cmd", params, workingDirectory: workDir);
    process.stdout.listen((data) => onLoadRes(utf8.decode(data)));
    process.stderr.listen((data) => onLoadRes(utf8.decode(data)));
    // 等待命令执行完成
    var exitCode = await process.exitCode;
    onLoadRes("命令执行完成，exitCode = $exitCode");
  }
}
