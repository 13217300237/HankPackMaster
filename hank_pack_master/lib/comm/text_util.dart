extension StringEmpty on String? {
  bool empty() {
    if (this == null) return true;
    if (this!.isEmpty) return true;
    if (this == "null") return true;
    return false;
  }
}

extension FirstLineExtension on String? {
  String? getFirstLine() {
    if (this == null) {
      return null;
    }
    int end = this!.indexOf('\n');
    if (end == -1) {
      return this;
    }
    return this!.substring(0, end);
  }
}

String escapeBackslashes(String path) {
  return path.replaceAll(r'\', r'\\');
}

String extractFirstWordAfterAssemble(String input) {
  const String assemblePrefix = 'assemble';

  // 判断字符串是否以 assemble 开头
  if (input.startsWith(assemblePrefix)) {
    // 提取 assemble 后的部分
    String remaining = input.substring(assemblePrefix.length);

    // 使用正则表达式匹配第一个单词
    RegExpMatch? match = RegExp(r'[A-Z][a-z]*').firstMatch(remaining);

    if (match != null) {
      // 获取匹配到的单词并转化为小写
      String? firstWord = match.group(0)?.toLowerCase();
      return firstWord ?? "";
    }
  }

  // 如果没有匹配到合适的单词，返回空字符串或者其他你认为合适的默认值
  return '';
}

/// 将秒数，转化为 时分秒
String formatSeconds(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = seconds % 60;

  String hoursStr = hours > 0 ? '$hours小时' : '';
  String minutesStr = (hours > 0 || minutes > 0) ? '$minutes分' : '';
  String secondsStr = '$remainingSeconds秒';

  if (hoursStr.isNotEmpty) {
    return '$hoursStr$minutesStr$secondsStr';
  } else if (minutesStr.isNotEmpty) {
    return '$minutesStr$secondsStr';
  } else {
    return secondsStr;
  }
}

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
